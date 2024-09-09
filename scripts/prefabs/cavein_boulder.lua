local easing = require("easing")

local assets =
{
    Asset("ANIM", "anim/cavein_boulder.zip"),
    Asset("ANIM", "anim/swap_cavein_boulder.zip"),
    Asset("MINIMAP_IMAGE", "cavein_formation"),
}

local dustassets =
{
    Asset("ANIM", "anim/cavein_dust_fx.zip"),
}

local prefabs =
{
    "rocks",
    "flint",
    "rock_break_fx",
    "cavein_dust_low",
	"cavein_dust_high",

	"underwater_salvageable",
	"splash_green",
}

SetSharedLootTable("cavein_boulder",
{
    { "rocks",  1 },
    { "rocks",  1 },
    { "rocks",  .4 },
    { "flint",  .1 },
})

local NUM_VARIATIONS = 8

local PHYSICS_RADIUS = .75

local PLAYER_OVERLAP_RADIUS = 1
local OVERLAP_RADIUS = 1
local FORMATION_RADIUS = 2.5
local MINIMAP_RADIUS = 3

--------------------------------------------------------------------------
--Minimap icons

local function SetIconEnabled(inst, enable)
    if enable then
        if inst._iconpos == nil then
            inst._iconpos = inst:GetPosition()
            inst.MiniMapEntity:SetEnabled(true)
        end
    elseif inst._iconpos ~= nil then
        inst._iconpos = nil
        inst.MiniMapEntity:SetEnabled(false)
    end
end

local DISABLEICON_MUST_TAGS = { "caveindebris" }
local DISABLEICON_CANT_TAGS = { "INLIMBO" }

local function UpdateIcon(inst)
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    if inst.fallingtask ~= nil then
        SetIconEnabled(inst, false)
    elseif inst.raised or inst.components.heavyobstaclephysics:IsItem() then
        SetIconEnabled(inst, true)
    elseif inst.formed or inst.components.heavyobstaclephysics:IsFalling() then
        SetIconEnabled(inst, false)
    else
        local x, y, z = inst.Transform:GetWorldPosition()
        for i, v in ipairs(TheSim:FindEntities(x, 0, z, MINIMAP_RADIUS, DISABLEICON_MUST_TAGS, DISABLEICON_CANT_TAGS)) do
            if v ~= inst and v._iconpos ~= nil and v.prefab == inst.prefab then
                SetIconEnabled(inst, false)
                return
            end
        end
        SetIconEnabled(inst, true)
    end
end

local function OnRemoveIcon(inst)
    if inst._iconpos ~= nil then
        local ents = TheSim:FindEntities(inst._iconpos.x, 0, inst._iconpos.z, MINIMAP_RADIUS, DISABLEICON_MUST_TAGS, DISABLEICON_CANT_TAGS)
        SetIconEnabled(inst, false)
        for i, v in ipairs(ents) do
            if v ~= inst and v._iconpos == nil and v.prefab == inst.prefab then
                UpdateIcon(v)
            end
        end
    end
end

--------------------------------------------------------------------------
--workable, inventoryitem, etc.

local function OnWorked(inst, worker)
    local pt = inst:GetPosition()
    SpawnPrefab("rock_break_fx").Transform:SetPosition(pt:Get())

    if inst.raised then
        pt.y = 2
        inst.components.lootdropper:DropLoot(pt)
    elseif inst.formed and worker ~= nil and worker.sg ~= nil and worker.sg:HasStateTag("working") then
        for i, v in ipairs(inst.components.lootdropper:GenerateLoot()) do
            local loot = SpawnPrefab(v)
            loot.components.inventoryitem:InheritMoisture(inst.components.inventoryitem:GetMoisture(), inst.components.inventoryitem:IsWet())
            LaunchAt(loot, inst, worker, 1, 1)
        end
    else
        inst.components.lootdropper:DropLoot(pt)
    end

    inst:Remove()
end

local function UpdateActions(inst)
    inst.components.inventoryitem.canbepickedup = not inst.raised and not inst.components.heavyobstaclephysics:IsFalling() and inst.fallingtask == nil
    inst.components.workable:SetWorkable(not inst.raised and inst.fallingtask == nil)
end

--------------------------------------------------------------------------
--Wobbling base boulders

local function CancelWobbleTask(inst)
    if inst.wobbletask ~= nil then
        inst.wobbletask:Cancel()
        inst.wobbletask = nil
    end
end

local function OnWobble(inst)
    inst.wobbletask = nil
    inst.AnimState:PlayAnimation("wobble_less")
    inst.AnimState:PushAnimation("idle", false)
end

local function Wobble(inst, delay)
    if inst.wobbletask ~= nil then
        inst.wobbletask:Cancel()
    end
    inst.wobbletask = inst:DoTaskInTime(delay, OnWobble)
end

--------------------------------------------------------------------------
--Tracking propped up boulders

local function CancelFallingTask(inst)
    if inst.fallingtask ~= nil then
        inst.fallingtask:Cancel()
        inst.fallingtask = nil
        inst.fallingpos = nil
        UpdateIcon(inst)
        UpdateActions(inst)
        inst.AnimState:PlayAnimation("idle")
    end
end

local function OnFalling(inst, startpos, starttime, duration)
    local t = math.max(0, GetTime() - starttime)
    if t < duration then
        local pos = startpos + (inst.fallingpos - startpos) * easing.inOutQuad(t, 0, 1, duration)
        inst.Transform:SetPosition(pos:Get())
    else
        inst.Physics:Teleport(inst.fallingpos:Get())
        inst.fallingtask:Cancel()
        inst.fallingtask = nil
        inst.fallingpos = nil
        UpdateIcon(inst)
        UpdateActions(inst)
    end
end

local function StopTrackingRaisedBoulder(base)
    local target = base.components.entitytracker:GetEntity("propped")
    if target ~= nil then
        base.components.entitytracker:ForgetEntity("propped")
        base:RemoveEventCallback("onremove", base._onremoveraisedboulder, target)
        base:RemoveEventCallback("enterlimbo", base._onremoveraisedboulder, target)
        base:RemoveEventCallback("dropraisedboulder", base._onremoveraisedboulder, target)
    end
    base._basepos = nil
end

local function TrackRaisedBoulder(base, target)
    base._basepos = base:GetPosition()
    base._basepos.y = 0
    base:ListenForEvent("onremove", base._onremoveraisedboulder, target)
    base:ListenForEvent("enterlimbo", base._onremoveraisedboulder, target)
    base:ListenForEvent("dropraisedboulder", base._onremoveraisedboulder, target)
end

local function StartTrackingRaisedBoulder(base, target)
    base.components.entitytracker:TrackEntity("propped", target)
    TrackRaisedBoulder(base, target)
end

--------------------------------------------------------------------------
--Boulder variations

local function OnUnequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end
end

local function OnEquip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_body", skin_build, "swap_body", inst.GUID, "swap_body"..tostring(inst.variation or ""))
    else
        owner.AnimState:OverrideSymbol("swap_body", "swap_cavein_boulder", "swap_body"..tostring(inst.variation or ""))
    end
end

local function SetVariation(inst, variation, force)
    if variation ~= nil and (variation <= 1 or variation > NUM_VARIATIONS) then
        variation = nil
    end
    if force or inst.variation ~= variation then
		inst.variation = variation

		if variation ~= nil then
			local new_symbol = "swap_boulder"..tostring(variation)
			inst.AnimState:OverrideSymbol("swap_boulder", "swap_cavein_boulder", new_symbol)
			inst.components.symbolswapdata:SetData("swap_cavein_boulder", new_symbol)
        else
            inst.AnimState:ClearOverrideSymbol("swap_boulder")
        end
        if inst.components.equippable:IsEquipped() and inst.components.inventoryitem.owner ~= nil then
            OnEquip(inst, inst.components.inventoryitem.owner)
        end
    end
end

local function SetRaised(inst, raised)
    if raised then
        if not (inst.raised or inst.components.inventoryitem:IsHeld()) then
            inst.raised = true
            CancelWobbleTask(inst)
            inst.AnimState:PlayAnimation("idle_raised")
            inst.MiniMapEntity:SetIcon("cavein_formation.png")
            UpdateIcon(inst)
            UpdateActions(inst)
            if inst.components.entitytracker ~= nil then
                StopTrackingRaisedBoulder(inst)
                inst:RemoveComponent("entitytracker")
            end
        end
    elseif inst.raised then
        inst.raised = nil
        CancelWobbleTask(inst)
        if inst.AnimState:IsCurrentAnimation("idle_raised") then
            inst.AnimState:PlayAnimation("idle")
        end
        inst.MiniMapEntity:SetIcon("cavein_boulder.png")
        UpdateIcon(inst)
        UpdateActions(inst)
        if inst.formed then
            inst:AddComponent("entitytracker")
        end
        inst:PushEvent("dropraisedboulder")
    end
end

local function SetFormed(inst, formed)
    if formed then
        if not inst.formed then
            inst.formed = true
            UpdateIcon(inst)
            if not inst.raised then
                inst:AddComponent("entitytracker")
            end
        end
    elseif inst.formed then
        inst.formed = nil
        UpdateIcon(inst)
        if inst.components.entitytracker ~= nil then
            StopTrackingRaisedBoulder(inst)
            inst:RemoveComponent("entitytracker")
        end
    end
end

local function OnSave(inst, data)
    data.variation = inst.variation
    data.raised = inst.raised
    data.formed = inst.formed and not inst.raised or nil
    if inst.fallingpos ~= nil then
        data.fallx = inst.fallingpos.x
        data.fallz = inst.fallingpos.z
    end
end

local function OnPreLoad(inst, data)
    local variation = math.floor(data ~= nil and data.variation or 1)
    if inst.skinname ~= nil then
        inst.variation = variation
    else
        SetVariation(inst, variation)
    end
    SetRaised(inst, data ~= nil and data.raised)
    SetFormed(inst, data ~= nil and (data.formed or data.raised))
    if data ~= nil and not inst.raised and data.fallx ~= nil and data.fallz ~= nil then
        inst.Physics:Teleport(data.fallx, 0, data.fallz)
    end
end

local function OnLoadPostPass(inst)--, newents, data)
    if inst.formed and not inst.raised then
        local raisedboulder = inst.components.entitytracker:GetEntity("propped")
        if raisedboulder ~= nil then
            TrackRaisedBoulder(inst, raisedboulder)
        end
    end
    if inst._icontask ~= nil then
        UpdateIcon(inst)
    end
end

--------------------------------------------------------------------------
--Formations

local function GetBoulders()
    local t =
    {
        all = {},
        raised = { 1, 4, 6, 7 },
    }
    for i = 1, NUM_VARIATIONS do
        table.insert(t.all, i)
    end
    for i = #t.raised, 1, -1 do
        if t.raised[i] <= NUM_VARIATIONS then
            return t
        end
        table.remove(t.raised, i)
    end
    return t
end

local function PickBoulder(t, raised)
    if raised and #t.raised > 0 then
        local boulder = table.remove(t.raised, math.random(#t.raised))
        for i, v in ipairs(t.all) do
            if v == boulder then
                table.remove(t.all, i)
                break
            end
        end
        return boulder
    end
    local boulder = table.remove(t.all, math.random(#t.all))
    if not raised and #t.raised > 0 then
        for i, v in ipairs(t.raised) do
            if v == boulder then
                table.remove(t.raised, i)
                break
            end
        end
    end
    return boulder
end

local function MakeQuadFormation()
    local t = GetBoulders()
    return {
        { variation = PickBoulder(t, true), offset = { x = 0, z = 0 }, raised = true },
        { variation = PickBoulder(t, false), offset = { x = 0, z = 1 } },
        { variation = PickBoulder(t, false), offset = { x = -1, z = 0 } },
        { variation = PickBoulder(t, false), offset = { x = 0, z = -1 } },
        { variation = PickBoulder(t, false), offset = { x = 1, z = 0 } },
    }
end
--[[
local function MakeTriFormation()
    local t = GetBoulders()
    local r = .95
    local angle = 30 * DEGREES
    local dx = r * math.cos(angle)
    local dz = -r * math.sin(angle)
    return {
        { variation = PickBoulder(t, false), offset = { x = 0, z = r } },
        { variation = PickBoulder(t, false), offset = { x = dx, z = dz } },
        { variation = PickBoulder(t, false), offset = { x = -dx, z = dz } },
    }
end

local function MakeDuoFormation()
    local t = GetBoulders()
    return {
        { variation = PickBoulder(t, false), offset = { x = 0, z = .75 } },
        { variation = PickBoulder(t, false), offset = { x = 0, z = -.75 } },
    }
end
]]

local FORMATION_MUST_TAGS = { "boulder", "heavy" }
local FORMATION_CANT_TAGS = { "INLIMBO" }
local function CreateFormation(boulders)
    local x, z = 0, 0
    for i, v in ipairs(boulders) do
        local x1, y1, z1 = v.Transform:GetWorldPosition()
        x = x + x1
        z = z + z1
    end
    x = x / #boulders
    z = z / #boulders

    local formation = MakeQuadFormation()
    local angle = math.random() * TWOPI
    local cosa = math.cos(angle)
    local sina = math.sin(angle)
    local raisedboulder = nil
    for i, v in ipairs(formation) do
        local boulder = boulders[i]
        local x1 = x + v.offset.x * cosa - v.offset.z * sina
        local z1 = z + v.offset.x * sina + v.offset.z * cosa
        local fx = SpawnPrefab(v.raised and "cavein_dust_high" or "cavein_dust_low")
        fx.Transform:SetPosition(x1, 0, z1)
        fx:SkipToFull()
        if v.raised then
            fx:PlaySoundFX()
        end
        boulder.Physics:Teleport(x1, 0, z1)
        SetVariation(boulder, v.variation)
        SetRaised(boulder, v.raised)
        SetFormed(boulder, true)
        if v.raised then
            raisedboulder = boulder
        elseif raisedboulder ~= nil then
            StartTrackingRaisedBoulder(boulder, raisedboulder)
        end
    end

    for i, v in ipairs(boulders) do
        if v.formed then
            local x1, y1, z1 = v.Transform:GetWorldPosition()
            for i2, v2 in ipairs(TheSim:FindEntities(x1, 0, z1, OVERLAP_RADIUS, FORMATION_MUST_TAGS, FORMATION_CANT_TAGS)) do
                if not (v2.formed or (v2.components.heavyobstaclephysics ~= nil and v2.components.heavyobstaclephysics:IsFalling())) then
                    v2:Remove()
                end
            end
        end
    end
end

local function TryFormationAt(x, y, z)
    local boulders = {}
    local ents = TheSim:FindEntities(x, 0, z, FORMATION_RADIUS, FORMATION_MUST_TAGS, FORMATION_CANT_TAGS)
    for i, v in ipairs(ents) do
        if v.prefab == "cavein_boulder" and
            not (v.formed or
                v.raised or
                (v.components.heavyobstaclephysics ~= nil and v.components.heavyobstaclephysics:IsFalling())) then
            table.insert(boulders, v)
            if #boulders >= 5 then
                CreateFormation(boulders)
                return
            end
        end
    end
end

--------------------------------------------------------------------------
--Physics stuff

local function OnPhysicsStateChanged(inst, state)
    UpdateIcon(inst)
    UpdateActions(inst)
end

local function OnChangeToItem(inst)
    SetFormed(inst, false)
    SetRaised(inst, false)
    CancelWobbleTask(inst)
    CancelFallingTask(inst)
    if not inst.AnimState:IsCurrentAnimation("idle") then
        inst.AnimState:PlayAnimation("idle")
    end
end

local function OnStartFalling(inst)
    SetFormed(inst, false)
    SetRaised(inst, false)
end

local function OnStopFalling(inst)
    local x, y, z = inst.Transform:GetWorldPosition()

    if IsAnyPlayerInRange(x, 0, z, PLAYER_OVERLAP_RADIUS) then
        local fx = SpawnPrefab("cavein_dust_low")
        fx.Transform:SetPosition(x, 0, z)
        fx:PlaySoundFX()
        inst:Remove()
    else
        TryFormationAt(x, 0, z)
        if not inst.formed then
            local fx = SpawnPrefab("cavein_dust_low")
            fx.Transform:SetPosition(x, 0, z)
            fx:PlaySoundFX()
            for i, v in ipairs(TheSim:FindEntities(x, 0, z, OVERLAP_RADIUS, FORMATION_MUST_TAGS, FORMATION_CANT_TAGS)) do
                if v.formed then
                    inst:Remove()
                    return
                end
            end
            inst.Physics:Teleport(x, 0, z)
        end
    end
end

--------------------------------------------------------------------------

local function OnRemoveRaisedBoulder(inst, target)
    SetFormed(inst, false)
    if target.fallingpos ~= nil then
        if inst:GetDistanceSqToPoint(target.fallingpos) > 2.25 then
            Wobble(inst, 3 * FRAMES)
        else
            Wobble(inst, (5 + math.random() * 3) * FRAMES)
        end
    end
end

local function OnRemoveFromScene(inst)
    OnRemoveIcon(inst)
    if inst.components.entitytracker ~= nil then
        local target = inst.components.entitytracker:GetEntity("propped")
        if target ~= nil and target.raised then
            CancelWobbleTask(inst)
            target.AnimState:PlayAnimation("fall")
            target.AnimState:PushAnimation("idle", false)
            if target.fallingtask ~= nil then
                target.fallingtask:Cancel()
            end
            target.fallingpos = inst._basepos
            target.fallingtask = target:DoPeriodicTask(FRAMES, OnFalling, 0, target:GetPosition(), GetTime(), 10 * FRAMES)
            OnRemoveIcon(target)
            UpdateIcon(inst)
            UpdateActions(inst)
            SetFormed(target, false)
            SetRaised(target, false)
        end
    end
end

local function GetStatus(inst)
    return inst.raised and "RAISED" or nil
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("cavein_boulder.png")
    inst.MiniMapEntity:SetEnabled(false)

    inst.AnimState:SetBank("cavein_boulder")
    inst.AnimState:SetBuild("swap_cavein_boulder")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("heavy")
    inst:AddTag("boulder")
    inst:AddTag("caveindebris")

    MakeHeavyObstaclePhysics(inst, PHYSICS_RADIUS)
    inst:SetPhysicsRadiusOverride(PHYSICS_RADIUS)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("heavyobstaclephysics")
    inst.components.heavyobstaclephysics:SetRadius(PHYSICS_RADIUS)
    inst.components.heavyobstaclephysics:AddFallingStates()
    inst.components.heavyobstaclephysics:SetOnPhysicsStateChangedFn(OnPhysicsStateChanged)
    inst.components.heavyobstaclephysics:SetOnChangeToItemFn(OnChangeToItem)
    inst.components.heavyobstaclephysics:SetOnStartFallingFn(OnStartFalling)
    inst.components.heavyobstaclephysics:SetOnStopFallingFn(OnStopFalling)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("cavein_boulder")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.cangoincontainer = false
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable.walkspeedmult = TUNING.HEAVY_SPEED_MULT

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.CAVEIN_BOULDER_MINE)
	inst.components.workable:SetOnFinishCallback(OnWorked)

	inst:AddComponent("submersible")
	inst:AddComponent("symbolswapdata")
	inst.components.symbolswapdata:SetData("swap_cavein_boulder", "swap_boulder")

    MakeHauntableWork(inst)

    inst.OnSave = OnSave
    inst.OnPreLoad = OnPreLoad
    inst.OnLoadPostPass = OnLoadPostPass

    SetVariation(inst, math.random(NUM_VARIATIONS))
    inst.SetVariation = SetVariation

    inst:ListenForEvent("onremove", OnRemoveFromScene)
    inst:ListenForEvent("enterlimbo", OnRemoveFromScene)

    --inst._iconpos = nil
    --inst._basepos = nil
    inst._onremoveraisedboulder = function(target) OnRemoveRaisedBoulder(inst, target) end

    inst._icontask = inst:DoTaskInTime(0, UpdateIcon)

    return inst
end

--------------------------------------------------------------------------

local function SkipToFull(inst)
	inst.AnimState:SetFrame(4 + math.random(7))
end

local function PlaySoundFX(inst)
    inst.SoundEmitter:PlaySoundWithParams("dontstarve/creatures/together/antlion/sfx/ground_break", { size = 1 })
end

local function MakeFX(name, anim)
    local function fn(inst)
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("cavein_dust_fx")
        inst.AnimState:SetBuild("cavein_dust_fx")
        inst.AnimState:PlayAnimation(anim)

        inst:AddTag("FX")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false
        inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + .5, inst.Remove)

        inst.SkipToFull = SkipToFull
        inst.PlaySoundFX = PlaySoundFX

        return inst
    end
    return Prefab(name, fn, dustassets)
end

return Prefab("cavein_boulder", fn, assets, prefabs),
    MakeFX("cavein_dust_low", "dust_low"),
    MakeFX("cavein_dust_high", "dust_high")
