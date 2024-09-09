local assets =
{
    Asset("ANIM", "anim/storage_robot.zip"),
    Asset("ANIM", "anim/storage_robot_med.zip"),
    Asset("ANIM", "anim/storage_robot_small.zip"),
    Asset("ANIM", "anim/firefighter_placement.zip"),

    Asset("INV_IMAGE", "storage_robot_broken"),
    Asset("MINIMAP_IMAGE", "storage_robot_broken"),

    Asset("SCRIPT", "scripts/prefabs/storage_robot_common.lua"),
}

---------------------------------------------------------------------------------------------------

local brain = require "brains/storage_robotbrain"
local StorageRobotCommon = require "prefabs/storage_robot_common"

--TODO fix load logic
local SPAWNPOINT_NAME = "spawnpoint"

local NUM_FUELED_SECTIONS = 5
local SECTION_MED = 2
local SECTION_SMALL = 1

local VISUAL_SCALE = 1.05
local LIGHT_LIGHTOVERRIDE = 0.5

---------------------------------------------------------------------------------------------------

local CIRCLE_RADIUS_SCALE = 1888 / 150 / 2 -- Source art size / anim_scale / 2 (halved to get radius).

local function CreateHelperRadiusCircle()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")

    inst.AnimState:SetBank("firefighter_placement")
    inst.AnimState:SetBuild("firefighter_placement")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetAddColour(0, .2, .5, 0)
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    local scale = TUNING.STORAGE_ROBOT_WORK_RADIUS / CIRCLE_RADIUS_SCALE -- Convert to rescaling for our desired range.

    inst.AnimState:SetScale(scale, scale)

    return inst
end


local function OnOriginDirty(inst)
    if inst.helper ~= nil then
        inst.helper.Transform:SetPosition(inst._originx:value(), 0, inst._originz:value())
    end
end

local function OnEnableHelper(inst, enabled, recipename, placerinst)
    if enabled and recipename ~= nil and not inst:HasTag("broken") and inst:GetCurrentPlatform() == nil then
        if inst.helper == nil then
            inst.helper = CreateHelperRadiusCircle()

            OnOriginDirty(inst)

            inst.AnimState:SetAddColour(0, .2, .5, 0)
        end

    elseif inst.helper ~= nil then
        inst.AnimState:SetAddColour(0, 0, 0, 0)

        inst.helper:Remove()
        inst.helper = nil
    end
end

local function OnStartHelper(inst)
    if inst.replica.inventoryitem ~= nil and inst.replica.inventoryitem:IsHeld() then
        inst.components.deployhelper:StopHelper()
    end
end

---------------------------------------------------------------------------------------------------

local function DoOnDroppedLogic(inst)
    if inst.components.drownable:ShouldDrown() then
        inst:PushEvent("onsink")

        return
    end

    StorageRobotCommon.UpdateSpawnPoint(inst)
    inst:OnInventoryChange()

    inst.sg:GoToState(inst.components.fueled:IsEmpty() and "idle_broken" or "idle", true)
end

local function OnDropped(inst)
    -- Wait for the platform to be set up.
    inst:DoTaskInTime(0, DoOnDroppedLogic)
end

local function OnPickup(inst, pickupguy, src_pos)
    inst.sg:GoToState("idle", true)

    if inst.brain ~= nil then
        inst.brain:UnignoreItem()
    end

    inst.components.fueled:StopConsuming()
    
    inst.components.locomotor:Stop()
    inst.components.locomotor:Clear()
    inst:ClearBufferedAction()

    inst.SoundEmitter:KillAllSounds()

    local item = inst.components.inventory:GetFirstItemInAnySlot() or inst.components.inventory:GetActiveItem() -- This is intentionally backwards to give the bigger stacks first.
    local hat  = inst.components.inventory:Unequip(EQUIPSLOTS.HEAD)

    if item == nil and hat == nil then
        return
    end

    if pickupguy ~= nil and pickupguy.components.inventory ~= nil then
        if item ~= nil then
            pickupguy.components.inventory:GiveItem(item, nil, src_pos)
        end

        if hat ~= nil then
            pickupguy.components.inventory:GiveItem(hat, nil, src_pos)
        end

    else
        if item ~= nil then
            inst.components.inventory:DropItem(item, true, true)
        end

        if hat ~= nil then
            inst.components.inventory:DropItem(hat, true, true)
        end
    end
end

---------------------------------------------------------------------------------------------------

local function SetBroken(inst)
    inst:AddTag("broken")

    RemovePhysicsColliders(inst)

    inst.MiniMapEntity:SetIcon("storage_robot_broken.png")
    inst.components.inventoryitem:ChangeImageName("storage_robot_broken")
end

local function OnBroken(inst)
    inst:SetBroken()

    if not inst.components.inventoryitem:IsHeld() and inst.sg.currentstate.name ~= "washed_ashore" then
        inst.sg:GoToState("breaking")
    end
end

local function OnRepaired(inst)
    inst:RemoveTag("broken")

    if inst.sg:HasStateTag("broken") then
        inst.sg:GoToState(inst.components.inventoryitem:IsHeld() and "idle" or "repairing_pre")
    end
end

---------------------------------------------------------------------------------------------------

local function OnLoad(inst, newents, data)
    if inst.components.fueled:IsEmpty() then
        inst:SetBroken()

        inst.sg:GoToState("idle_broken")
    end

    StorageRobotCommon.UpdateSpawnPointOnLoad(inst)
end

---------------------------------------------------------------------------------------------------

local function DoOffscreenPickup(inst)
    if not inst:IsAsleep() then
        if inst._sleeptask ~= nil then
            inst._sleeptask:Cancel()
            inst._sleeptask = nil
        end

        return -- Safeguard.
    end

    local item = StorageRobotCommon.FindItemToPickupAndStore(inst)

    if item == nil then
        inst:StartOffscreenPickupTask(5)

        return 
    end

    local container = StorageRobotCommon.FindContainerWithItem(inst, item)

    if container == nil then
        inst.components.inventory:DropItem(item, true, true)

        inst:StartOffscreenPickupTask(5)

        return
    end

    local dist = math.sqrt(distsq(container:GetPosition(), item:GetPosition()))

    local time = (dist * 2 / inst.components.locomotor.walkspeed) + (59 + 57) * FRAMES -- Distance (container -> item and item -> container) / walkspeed + pickup and dropoff anim time.

    BufferedAction(inst, item, ACTIONS.PICKUP, nil, nil, nil, nil, nil, nil, inst.PICKUP_ARRIVE_DIST):Do()
    BufferedAction(inst, container, ACTIONS.STORE, item):Do()

    inst.components.inventory:CloseAllChestContainers()

    local fueled = inst.components.fueled

    fueled:DoDelta(-time * fueled.rate * fueled.rate_modifiers:Get())

    if not fueled:IsEmpty() then
        inst:StartOffscreenPickupTask(time)
    end
end

local function StartOffscreenPickupTask(inst, time)
    if inst._sleeptask ~= nil then
        inst._sleeptask:Cancel()
        inst._sleeptask = nil
    end

    inst._sleeptask = inst:DoTaskInTime(time, inst.DoOffscreenPickup)
end

local function OnEntityWake(inst)
    if inst._sleeptask ~= nil then
        inst._sleeptask:Cancel()
        inst._sleeptask = nil
    end
end

local function OnEntitySleep(inst)
    if inst:IsInLimbo() or inst.components.fueled:IsEmpty() or inst.sg:HasStateTag("drowning") then
        return
    end

    inst.components.fueled:StopConsuming()
    inst.SoundEmitter:KillAllSounds()

    inst.Physics:Teleport(StorageRobotCommon.GetSpawnPoint(inst):Get())

    if inst.brain ~= nil then
        inst.brain:UnignoreItem()
    end

    -- First store the item we are holding.

    local item = inst.components.inventory:GetFirstItemInAnySlot() or inst.components.inventory:GetActiveItem() -- This is intentionally backwards to give the bigger stacks first.

    if item ~= nil then
        local container = StorageRobotCommon.FindContainerWithItem(inst, item)

        if container ~= nil then
            BufferedAction(inst, container, ACTIONS.STORE, item):Do()
            inst.components.inventory:CloseAllChestContainers()
        else
            inst.components.inventory:DropItem(item, true, true)
        end
    end

    -- Then start pickuping others.

    inst:StartOffscreenPickupTask(1.5)
end

---------------------------------------------------------------------------------------------------

local function OnReachDestination(inst, data)
    if data.pos == nil or data.target == nil then
        return
    end

    -- Snap to item position, so we are always layered correctly.
    if data.target.components.inventoryitem ~= nil and data.target.components.container == nil then
        local x, y, z = data.pos:Get()

        inst.Physics:Teleport(x, 0, z)
    end
end

local function OnTakeDrowningDamage(inst, tunings)
    StorageRobotCommon.UpdateSpawnPoint(inst)

    inst.components.inventoryitem:MakeMoistureAtLeast(TUNING.OCEAN_WETNESS)
    inst.components.fueled:SetPercent(0)

    inst.sg:GoToState("idle_broken")
end

local SPARK_INTERVAL_MIN = 3
local SPARK_INTERVAL_MAX = 10

local function OnUpdateFueled(inst)
    local moisture_pct = inst.components.inventoryitem:GetMoisture() / TUNING.MAX_WETNESS

    inst.components.fueled.rate = 1 + moisture_pct

    if moisture_pct <= 0 then
        return
    end

    if inst._last_spark_time == nil or (inst._last_spark_time + Lerp(SPARK_INTERVAL_MIN, SPARK_INTERVAL_MAX, 1-moisture_pct) <= GetTime()) then
        inst._last_spark_time = GetTime()

        SpawnPrefab("sparks").Transform:SetPosition(inst.Transform:GetWorldPosition())
    end
end

local function FueledSectionCallback(newsection, oldsection, inst)
    if newsection <= SECTION_SMALL then  -- 20%
        inst.AnimState:SetBuild("storage_robot_small")
        inst.components.locomotor.walkspeed = TUNING.STORAGE_ROBOT_WALKSPEED.SMALL
        inst.Physics:SetMass(TUNING.STORAGE_ROBOT_MASS.SMALL)

    elseif newsection <= SECTION_MED then -- 40%
        inst.AnimState:SetBuild("storage_robot_med")
        inst.components.locomotor.walkspeed = TUNING.STORAGE_ROBOT_WALKSPEED.MED
        inst.Physics:SetMass(TUNING.STORAGE_ROBOT_MASS.MED)

    elseif newsection >= NUM_FUELED_SECTIONS then -- On repaired.
        inst.components.locomotor.walkspeed = TUNING.STORAGE_ROBOT_WALKSPEED.FULL

        inst.Physics:SetMass(TUNING.STORAGE_ROBOT_MASS.FULL)
        ChangeToCharacterPhysics(inst)

        inst.MiniMapEntity:SetIcon("storage_robot.png")
        inst.components.inventoryitem:ChangeImageName()

         -- Build swap is handled in stategraph when it's broken.
        if not inst.sg:HasStateTag("broken") or inst.components.inventoryitem:IsHeld() then
            inst.AnimState:SetBuild("storage_robot")
        end
    end
end

local function GetFueledSectionMass(inst)
    local section = inst.components.fueled:GetCurrentSection()

    return
        (section <= SECTION_SMALL and TUNING.STORAGE_ROBOT_MASS.SMALL) or
        (section <= SECTION_MED and TUNING.STORAGE_ROBOT_MASS.MED) or
        TUNING.STORAGE_ROBOT_MASS.FULL
end

local function GetFueledSectionSuffix(inst)
    local section = inst.components.fueled:GetCurrentSection()

    return
        (section == SECTION_SMALL and "_small") or
        (section == SECTION_MED   and "_med")   or
        ""
end

---------------------------------------------------------------------------------------------------

local function ShouldAcceptItem(inst, item)
    return not inst.components.inventoryitem:IsHeld() and item.components.equippable ~= nil and item.components.equippable.equipslot == EQUIPSLOTS.HEAD
end

local function OnGetItemFromPlayer(inst, giver, item)
    if item.components.equippable ~= nil and item.components.equippable.equipslot == EQUIPSLOTS.HEAD then
        local current = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        if current ~= nil then
            if giver ~= nil and giver.components.inventory ~= nil then
                giver.components.inventory:GiveItem(current, nil, inst:GetPosition())
            else
                inst.components.inventory:DropItem(current)
            end
        end

        inst.components.inventory:Equip(item)

        inst.sg.mem.last_vocalization_time = GetTime()
        inst.SoundEmitter:PlaySound("qol1/collector_robot/pickup_voice"..inst:GetFueledSectionSuffix())
    end
end

local function OnRefuseItemFromPlayer(inst, giver, item)
    inst.sg.mem.last_vocalization_time = GetTime()
    inst.SoundEmitter:PlaySound("qol1/collector_robot/dropoff_voice"..inst:GetFueledSectionSuffix())
end

local function OnInventoryChange(inst, data)
    local hat = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)

    if hat ~= nil and not hat:HasTag("open_top_hat") then
        -- No light when wearing a non-open hat!
        return
    end

    local item = inst.components.inventory:GetFirstItemInAnySlot() or inst.components.inventory:GetActiveItem()

    if item ~= nil then
       inst.AnimState:Show("light_on")

       inst.AnimState:SetSymbolLightOverride("ball", LIGHT_LIGHTOVERRIDE)
       inst.AnimState:SetSymbolBloom("ball")
    else
        inst.AnimState:Hide("light_on")

        inst.AnimState:SetSymbolLightOverride("ball", 0)
        inst.AnimState:ClearSymbolBloom("ball")
    end
end

local function OnEquipSomething(inst, data)
    if data.eslot ~= EQUIPSLOTS.HEAD then
        return
    end

    if not data.item:HasTag("open_top_hat") then
        inst.AnimState:Hide("light_on")
        inst.AnimState:Hide("light_off")
        inst.AnimState:Hide("antenna")

        inst.AnimState:SetSymbolLightOverride("ball", 0)
        inst.AnimState:ClearSymbolBloom("ball")
    end
end

local function OnUnequipSomething(inst, data)
    if data.eslot ~= EQUIPSLOTS.HEAD then
        return
    end

    inst.AnimState:Show("light_off")
    inst.AnimState:Show("antenna")
end

---------------------------------------------------------------------------------------------------

local function OnTeleported(inst)
    StorageRobotCommon.UpdateSpawnPoint(inst)

    if inst._sleeptask ~= nil and not inst:IsAsleep() then
        inst._sleeptask:Cancel()
        inst._sleeptask = nil
    end
end

---------------------------------------------------------------------------------------------------

local function GetStatus(inst, viewer)
    return inst.components.fueled:IsEmpty() and "BROKEN" or nil
end

---------------------------------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, TUNING.STORAGE_ROBOT_MASS.FULL, 0.4)

    inst.Transform:SetFourFaced()

    inst.MiniMapEntity:SetIcon("storage_robot.png")
    inst.MiniMapEntity:SetPriority(5)

    inst.DynamicShadow:SetSize(2.8, 1.7)

    inst:AddTag("companion")
    inst:AddTag("NOBLOCK")
    inst:AddTag("scarytoprey")
    inst:AddTag("storagerobot")
    inst:AddTag("irreplaceable")

	inst.SCANNABLE_RECIPENAME = "winona_storage_robot"

    inst._originx = net_float(inst.GUID, "storage_robot._originx", "origindirty")
    inst._originz = net_float(inst.GUID, "storage_robot._originz", "origindirty")

    inst.AnimState:SetBank("storage_robot")
    inst.AnimState:SetBuild("storage_robot")
    inst.AnimState:PlayAnimation("idle", true)

    inst.AnimState:SetScale(VISUAL_SCALE, VISUAL_SCALE)

    inst.AnimState:Hide("light_on")

    inst.AnimState:SetFinalOffset(1)

    -- Dedicated server does not need deployhelper.
    if not TheNet:IsDedicated() then
        inst:AddComponent("deployhelper")
        inst.components.deployhelper.onenablehelper = OnEnableHelper
        inst.components.deployhelper.onstarthelper = OnStartHelper
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("origindirty", OnOriginDirty)
        return inst
    end

    inst.PICKUP_ARRIVE_DIST = 0

    inst.DoOffscreenPickup = DoOffscreenPickup
    inst.StartOffscreenPickupTask = StartOffscreenPickupTask

    inst.GetFueledSectionMass = GetFueledSectionMass
    inst.GetFueledSectionSuffix = GetFueledSectionSuffix

    inst.OnReachDestination = OnReachDestination
    inst.OnInventoryChange  = OnInventoryChange
    inst.SetBroken = SetBroken

    inst.OnEquipSomething   = OnEquipSomething
    inst.OnUnequipSomething = OnUnequipSomething

    inst:AddComponent("knownlocations")

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("drownable")
    inst.components.drownable:SetOnTakeDrowningDamageFn(OnTakeDrowningDamage)

    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = 1

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPickupFn(OnPickup)

    inst:AddComponent("locomotor")
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = true }
    inst.components.locomotor.walkspeed = TUNING.STORAGE_ROBOT_WALKSPEED.FULL

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.MAGIC
    inst.components.fueled:InitializeFuelLevel(TUNING.STORAGE_ROBOT_FUEL)
    inst.components.fueled:SetDepletedFn(OnBroken)
    inst.components.fueled:SetUpdateFn(OnUpdateFueled)
    inst.components.fueled:SetSectionCallback(FueledSectionCallback)
    inst.components.fueled:SetSections(NUM_FUELED_SECTIONS)
    inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)

    inst:AddComponent("forgerepairable")
    inst.components.forgerepairable:SetRepairMaterial(FORGEMATERIALS.WAGPUNKBITS)
    inst.components.forgerepairable:SetOnRepaired(OnRepaired)

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader:SetOnAccept(OnGetItemFromPlayer)
    inst.components.trader:SetOnRefuse(OnRefuseItemFromPlayer)
    inst.components.trader.deleteitemonaccept = false

    inst:SetStateGraph("SGstorage_robot")
    inst:SetBrain(brain)

    inst:ListenForEvent("onreachdestination", inst.OnReachDestination)

    inst:ListenForEvent("itemget",  inst.OnInventoryChange)
    inst:ListenForEvent("itemlose", inst.OnInventoryChange)

    inst:ListenForEvent("equip",   inst.OnEquipSomething  )
    inst:ListenForEvent("unequip", inst.OnUnequipSomething)

    inst:ListenForEvent("teleported", OnTeleported)

    inst.OnLoad = OnLoad

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    MakeHauntable(inst)

    return inst
end

return Prefab("storage_robot", fn, assets)
