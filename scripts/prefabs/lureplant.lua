local assets =
{
    Asset("ANIM", "anim/eyeplant_trap.zip"),
    Asset("ANIM", "anim/meat_rack_food.zip"),
    Asset("SOUND", "sound/plant.fsb"),
    Asset("MINIMAP_IMAGE", "eyeplant"),
}

local prefabs =
{
    "eyeplant",
    "lureplantbulb",
    "plantmeat",
}

local brain = require "brains/lureplantbrain"

local VALID_TILE_TYPES =
{
    [WORLD_TILES.DIRT] = true,
    [WORLD_TILES.SAVANNA] = true,
    [WORLD_TILES.GRASS] = true,
    [WORLD_TILES.FOREST] = true,
    [WORLD_TILES.MARSH] = true,

    -- CAVES
    [WORLD_TILES.CAVE] = true,
    [WORLD_TILES.FUNGUS] = true,
    [WORLD_TILES.SINKHOLE] = true,
    [WORLD_TILES.MUD] = true,
    [WORLD_TILES.FUNGUSRED] = true,
    [WORLD_TILES.FUNGUSGREEN] = true,

    --EXPANDED FLOOR TILES
    [WORLD_TILES.DECIDUOUS] = true,
}

function adjustIdleSound(inst, vol)
    inst.SoundEmitter:SetParameter("loop", "size", vol)
end

local function TryRevealBait(inst)
    inst.task = nil
    inst.lure = inst.lurefn(inst)
    if inst.lure ~= nil and inst.hibernatetask == nil then --There's something to show as bait!
        inst:ListenForEvent("onremove", inst._OnLurePerished, inst.lure)
        inst.components.shelf.cantakeitem = true
        inst.components.shelf.itemonshelf = inst.lure
        inst.sg:GoToState("showbait")
    else --There was nothing to use as bait. Try to reveal bait again until you can.
        inst.task = inst:DoTaskInTime(1, TryRevealBait)
    end
end

local function HideBait(inst)
    if not (inst.sg:HasStateTag("hiding") or inst.components.health:IsDead()) then --Won't hide if it's already hiding.
        if inst.task == nil then
            inst.components.shelf.cantakeitem = false
            inst.sg:GoToState("hidebait")
        end
    end

    if inst.lure ~= nil then
        inst:RemoveEventCallback("onremove", inst._OnLurePerished, inst.lure)
        inst.lure = nil
    end

    if inst.task ~= nil then
        inst.task:Cancel()
    end
    inst.task = inst:DoTaskInTime(math.random() * 3 + 2, TryRevealBait) --Emerge again after some time.
end

local function WakeUp(inst)
    if TheWorld.state.iswinter then
        --In case it's still winter when we hit this (could happen from save data)
        inst.hibernatetask = inst:DoTaskInTime(TUNING.LUREPLANT_HIBERNATE_TIME, WakeUp)
    else
        inst.hibernatetask = nil
        inst.components.minionspawner.shouldspawn = true
        inst.components.minionspawner:StartNextSpawn()
        if inst.task == nil then
            inst.task = inst:DoTaskInTime(1, TryRevealBait)
        end
        inst.sg:GoToState("emerge")
    end
end

local function ResumeSleep(inst, seconds)
    inst.sg:GoToState("hibernate")
    inst.components.shelf.cantakeitem = false

    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end

    inst.components.minionspawner.shouldspawn = false
    inst.components.minionspawner:KillAllMinions()

    if inst.hibernatetask ~= nil then
        inst.hibernatetask:Cancel()
    end
    inst.hibernatetask = inst:DoTaskInTime(seconds, WakeUp)
end

local function OnPicked(inst)
    if inst.lure ~= nil then
        inst:RemoveEventCallback("onremove", inst._OnLurePerished, inst.lure)
        inst.lure = nil
    end
    inst.components.shelf.cantakeitem = false
    inst.sg:GoToState("picked")

    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end

    inst.components.minionspawner.shouldspawn = false
    inst.components.minionspawner:KillAllMinions()

    if inst.hibernatetask ~= nil then
        inst.hibernatetask:Cancel()
    end
    inst.hibernatetask = inst:DoTaskInTime(TUNING.LUREPLANT_HIBERNATE_TIME, WakeUp)
end

local function OnPotentiallyPicked(inst, data)
    local item = data and data.item or nil
    if item and item:HasTag("lureplant_bait") then
        OnPicked(inst)
    end
end

local function FreshSpawn(inst)
    inst.components.shelf.cantakeitem = false
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
    inst.components.minionspawner.shouldspawn = false
    inst.components.minionspawner:KillAllMinions()

    if inst.hibernatetask ~= nil then
        inst.hibernatetask:Cancel()
    end
    inst.hibernatetask = inst:DoTaskInTime(TUNING.LUREPLANT_HIBERNATE_TIME, WakeUp)
end

local function CollectItems(inst)
    if inst.components.minionspawner.minions ~= nil then
        for k, v in pairs(inst.components.minionspawner.minions) do
            if v.components.inventory ~= nil then
                for k = 1, v.components.inventory.maxslots do
                    local item = v.components.inventory.itemslots[k]
                    if item ~= nil and not inst.components.inventory:IsFull() then
                        local it = v.components.inventory:RemoveItem(item)
                        if it.components.perishable ~= nil then
                            local top = it.components.perishable:GetPercent()
                            local bottom = .2
                            if top > bottom then
                                it.components.perishable:SetPercent(bottom + math.random() * (top - bottom))
                            end
                        end
                        inst.components.inventory:GiveItem(it)
                    elseif item ~= nil then
                        local item = v.components.inventory:RemoveItem(item)
                        item:Remove()
                    end
                end
            end
        end
    end
end

local function SelectLure(inst)
    if inst.components.inventory ~= nil then
        local lures = {}
        for k = 1, inst.components.inventory.maxslots do
            local item = inst.components.inventory.itemslots[k]
            if item ~= nil and item:HasTag("lureplant_bait") then
                table.insert(lures, item)
            end
        end

        if #lures >= 1 then
            return lures[math.random(#lures)]
        elseif inst.components.minionspawner.numminions * 2 >= inst.components.minionspawner.maxminions then
            local meat = SpawnPrefab("plantmeat")
            inst.components.inventory:GiveItem(meat)
            return meat
        end
    end
end

local function OnDeath(inst)
    inst.components.minionspawner.shouldspawn = false
    inst.components.minionspawner:KillAllMinions()
    inst.components.lootdropper:DropLoot(inst:GetPosition())

    TheWorld:PushEvent("CHEVO_lureplantdied",{target=inst,pt=Vector3(inst.Transform:GetWorldPosition())})
end

local function CanDigest(owner, item)
    --If it's not itemonshelf, then go ahead and digest it
    --If it IS itemonshelf, only digest if there's more than a stack of 5
    return item ~= owner.components.shelf.itemonshelf
        or (item.components.stackable ~= nil and
            item.components.stackable.stacksize > 5)
end

local function OnLoad(inst, data)
    if data ~= nil and data.timeuntilwake ~= nil then
        ResumeSleep(inst, math.max(0, data.timeuntilwake))
    end
    if data ~= nil and data.planted then
        inst:AddTag("planted")
    end
end

local function OnSave(inst, data)
    data.timeuntilwake = inst.hibernatetask ~= nil and math.floor(GetTaskRemaining(inst.hibernatetask)) or nil
    data.planted = inst:HasTag("planted")
end

local function OnLongUpdate(inst, dt)
    if inst.hibernatetask ~= nil then
        local t = GetTaskRemaining(inst.hibernatetask)
        inst.hibernatetask:Cancel()

        if t > dt then
            inst.hibernatetask = inst:DoTaskInTime(t - dt, WakeUp)
        else
            WakeUp(inst)
        end
    end
end

local function ExtendHibernation(inst)
    --hibernate if you aren't already
    if inst.sg.currentstate.name ~= "hibernate" then
        OnPicked(inst)
    else
        --it's already hibernating & it's still winter. Make it sleep for longer!
        if inst.hibernatetask ~= nil then
            inst.hibernatetask:Cancel()
        end
        inst.hibernatetask = inst:DoTaskInTime(TUNING.LUREPLANT_HIBERNATE_TIME, WakeUp)
    end
end

local function OnIsWinter(inst, iswinter)
    if iswinter then
        if inst.wintertask == nil then
            inst.wintertask = inst:DoPeriodicTask(30, ExtendHibernation)
            ExtendHibernation(inst)
        end
    elseif inst.wintertask ~= nil then
        inst.wintertask:Cancel()
        inst.wintertask = nil
    end
end

local function OnEntityWake(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/eye_central_idle", "loop")
    adjustIdleSound(inst, inst.components.minionspawner.numminions / inst.components.minionspawner.maxminions)
end

local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("loop")
end

local function OnStartFireDamage(inst)
    inst.components.minionspawner.shouldspawn = false
    inst.components.minionspawner:KillAllMinions()
end

local function OnStopFireDamage(inst)
    if inst.hibernatetask == nil and not (inst.components.health:IsDead() or TheWorld.state.iswinter) then
        inst.components.minionspawner.shouldspawn = true
        inst.components.minionspawner:StartNextSpawn()
    end
end

local function OnMinionChange(inst)
    if not inst:IsAsleep() then
        adjustIdleSound(inst, inst.components.minionspawner.numminions / inst.components.minionspawner.maxminions)
    end
end

local function OnHaunt(inst)
    --if math.random() <= TUNING.HAUNT_CHANCE_ALWAYS then
        HideBait(inst)
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_TINY
        return true
    --end
    --return false
end

local function OnSpawnMinion(inst, minion)
    minion:SetSkin(inst:GetSkinBuild(), inst.GUID)
end

local function SetSkin(inst)
    if inst.components.minionspawner.minions ~= nil then
        local skin_build = inst:GetSkinBuild()
        for k, v in pairs(inst.components.minionspawner.minions) do
            v:SetSkin(skin_build, inst.GUID)
        end
    end
end

local function OnLootPrefabSpawned(inst, data)
	local loot = data.loot
	if loot and loot.prefab == "lureplantbulb" then
        TheSim:ReskinEntity( loot.GUID, loot.skinname, inst.item_skinname, inst.skin_id )
	end
end

local function OnWorkFinished(inst, worker)
	if not inst.components.health:IsDead() then
		inst.components.health:Kill()
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT] / 2) --lureplantbulb deployspacing/2
    inst:SetPhysicsRadiusOverride(.7)
    MakeObstaclePhysics(inst, inst.physicsradiusoverride)

    inst:AddTag("lureplant")
    inst:AddTag("hostile")
    inst:AddTag("veggie")
	inst:AddTag("lifedrainable")
    inst:AddTag("wildfirepriority")
    inst:AddTag("NPCcanaggro")
	inst:AddTag("NPC_workable")

    inst.MiniMapEntity:SetIcon("eyeplant.png")

    inst.AnimState:SetBank("eyeplant_trap")
    inst.AnimState:SetBuild("eyeplant_trap")
    inst.AnimState:PlayAnimation("idle_hidden", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(300)

    inst:AddComponent("combat")
    inst:ListenForEvent("death", OnDeath)
    inst:ListenForEvent("hidebait", HideBait)

    inst:AddComponent("shelf")
    inst.components.shelf.ontakeitemfn = OnPicked
    inst:ListenForEvent("onitemstolen", OnPotentiallyPicked)

    inst:AddComponent("inventory")

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.MEAT }, { FOODTYPE.MEAT })

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"lureplantbulb"})

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(nil)
	inst.components.workable:SetOnFinishCallback(OnWorkFinished)

    inst:AddComponent("minionspawner")
    inst.components.minionspawner.onminionattacked = HideBait
    inst.components.minionspawner.validtiletypes = VALID_TILE_TYPES
    inst.components.minionspawner.onspawnminionfn = OnSpawnMinion

    inst:AddComponent("digester")
    inst.components.digester.itemstodigestfn = CanDigest

    inst:SetStateGraph("SGlureplant")

    inst:ListenForEvent("startfiredamage", OnStartFireDamage)
    inst:ListenForEvent("stopfiredamage", OnStopFireDamage)

    inst:ListenForEvent("freshspawn", FreshSpawn)
    inst:ListenForEvent("minionchange", OnMinionChange)

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    MakeLargeBurnable(inst)
    MakeMediumPropagator(inst)

    MakeHauntableIgnite(inst, TUNING.HAUNT_CHANCE_OCCASIONAL)
    AddHauntableCustomReaction(inst, OnHaunt, false, false, true)

    inst.OnLoad = OnLoad
    inst.OnSave = OnSave

    inst.OnLongUpdate = OnLongUpdate

    inst.OnLoadPostPass = SetSkin
    inst.SetSkin = SetSkin

    inst._OnLurePerished = function() HideBait(inst) end
    inst.lurefn = SelectLure
    inst:DoPeriodicTask(2, CollectItems) -- Always do this.
    TryRevealBait(inst)

    inst:WatchWorldState("iswinter", OnIsWinter)
    OnIsWinter(inst, TheWorld.state.iswinter)

    inst:ListenForEvent("loot_prefab_spawned", OnLootPrefabSpawned)

    inst:SetBrain(brain)

    return inst
end

return Prefab("lureplant", fn, assets, prefabs)
