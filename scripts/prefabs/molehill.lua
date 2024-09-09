require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/mole_build.zip"),
    Asset("ANIM", "anim/mole_basic.zip"),
}

local prefabs =
{
    "mole",
}

local function onvacatedig_up_vacate(inst, child)
    if child ~= nil and child:IsValid() then
        child:PushEvent("molehill_dug_up")
    end
end

local function dig_up(inst)
    if inst.components.spawner.child ~= nil then
        inst.components.spawner.child.needs_home_time = GetTime()
        if inst.components.spawner:IsOccupied() then
            inst.components.spawner:SetQueueSpawning(false)
            inst.components.spawner:SetOnVacateFn(onvacatedig_up_vacate)
            inst.components.spawner:ReleaseChild()
        end
    end
    inst.components.lootdropper:DropLoot()
    inst.components.inventory:DropEverything(false, true)
    inst:Remove()
end

local function startspawning(inst)
    if inst.components.spawner ~= nil then
        inst.components.spawner:SetQueueSpawning(false)
        if not inst.components.spawner:IsSpawnPending() then
            inst.components.spawner:SpawnWithDelay(math.random(5, 20))
        end
    end
end

local function stopspawning(inst)
    if inst.components.spawner ~= nil then
        inst.components.spawner:SetQueueSpawning(true, math.random(5, 15))
    end
end

local function onoccupied(inst)
    if not TheWorld.state.iscaveday then
        startspawning(inst)
    end
end

local function OnIsDay(inst, isday)
    if not isday and inst.components.spawner ~= nil and inst.components.spawner:IsOccupied() then
        startspawning(inst)
    else
        stopspawning(inst)
    end
end

local function AdoptChild(inst, child)
    inst.AdoptChild = nil
    if inst.components.spawner ~= nil then
        inst.components.spawner:CancelSpawning()
        inst.components.spawner:TakeOwnership(child)
        stopspawning(inst)
    end
end

local function OnInit(inst)
    inst.AdoptChild = nil
    inst:WatchWorldState("iscaveday", OnIsDay)
    OnIsDay(inst, TheWorld.state.iscaveday)
end

local function OnHaunt(inst)
    return inst.components.spawner ~= nil
        and inst.components.spawner:IsOccupied()
        and inst.components.spawner:ReleaseChild()
end

local function OnPreLoad(inst, data)
    WorldSettings_Spawner_PreLoad(inst, data, TUNING.MOLE_RESPAWN_TIME)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("mole")
    inst.AnimState:SetBuild("mole_build")
    inst.AnimState:PlayAnimation("mound_idle", true)
    inst.scrapbook_anim = "mound_idle"
    --inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("lootdropper")
    inst.components.lootdropper.numrandomloot = 1
    inst.components.lootdropper:AddRandomLoot("rocks", 4)
    inst.components.lootdropper:AddRandomLoot("nitre", 1.5)
    inst.components.lootdropper:AddRandomLoot("goldnugget", .5)
    inst.components.lootdropper:AddRandomLoot("flint", 1.5)

    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = 50

    inst:AddComponent("spawner")
    inst.components.spawner:SetOnOccupiedFn(onoccupied)
    inst.components.spawner:SetOnVacateFn(stopspawning)
    WorldSettings_Spawner_SpawnDelay(inst, TUNING.MOLE_RESPAWN_TIME, TUNING.MOLE_ENABLED)
    inst.components.spawner:Configure("mole", TUNING.MOLE_RESPAWN_TIME)

    inst:DoTaskInTime(0, OnInit)
    inst.AdoptChild = AdoptChild

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(dig_up)
    inst.components.workable:SetWorkLeft(1)

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_SMALL)
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    inst.OnPreLoad = OnPreLoad

    return inst
end

return Prefab("molehill", fn, assets, prefabs)
