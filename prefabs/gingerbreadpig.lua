local assets =
{
    Asset("ANIM", "anim/gingerbread_pigman.zip"),
}

local prefabs =
{
    "gingerbreadhouse",
    "wintersfeastfuel",
    "crumbs"
}

local loot =
{
    "wintersfeastfuel",
    "crumbs",
    "crumbs",
    "crumbs",
}

local CRUMB_SPAWN_PERIOD = 3
local brain = require "brains/gingerbreadpigbrain"

local CRUMBS_TAGS = {"crumbs"}
local function DropCrumb(inst)
    if inst.sg:HasStateTag("idle") or inst.sg:HasStateTag("sleeping") then
        return
    end

    if GetClosestInstWithTag(CRUMBS_TAGS, inst, 5) ~= nil then
        return
    end

    local item = SpawnPrefab("crumbs")
    local x, y, z = inst.Transform:GetWorldPosition()
    item.Transform:SetPosition(x, y + 2, z)

    local speed = math.random() * 2 + 2
    local angle = math.random() * 2 * PI

    item.Physics:SetVel(speed * math.cos(angle), math.random() * 2 + 8, speed * math.sin(angle))
end

local function StartDroppingCrumbs(inst)
    DropCrumb(inst)

    if inst.crumb_task then
        inst.crumb_task:Cancel()
        inst.crumb_task = nil
    end

    inst.crumb_task = inst:DoPeriodicTask(CRUMB_SPAWN_PERIOD, function() DropCrumb(inst) end)
end

local function OnPlayerNear(inst)
    inst.sg:PushEvent("onplayernear")
    inst.chased = true
end

local function OnPlayerFar(inst)
    if inst.chased_by_player then
        inst.chased_by_player = false
        if TheWorld.components.gingerbreadhunter and TheWorld.components.gingerbreadhunter:GenerateCrumbPoints(inst:GetPosition(), 5) then
            TheWorld.components.gingerbreadhunter:SpawnCrumbTrail(GetTaskRemaining(inst.killtask) or (1.5 * TUNING.TOTAL_DAY_TIME))
            ReplacePrefab(inst, "crumbs")
        end
    end
end

local function ShouldSleep(inst)
    return false
end

local function ShouldWakeUp(inst)
    return true
end

local function OnSave(inst, data)
    local ents = {}

    if inst.killtask then
        data.killtask = GetTaskRemaining(inst.killtask)
    end

    return ents
end

local function OnLoadPostPass(inst, newents, savedata)
    if savedata.killtask then
        inst.killtask = inst:DoTaskInTime(savedata.killtask, function() inst.components.health:Kill() end)
    else
        inst.killtask = inst:DoTaskInTime(1.5 * TUNING.TOTAL_DAY_TIME, function() inst.components.health:Kill() end)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 50, .5)

    inst.DynamicShadow:SetSize(1.5, .75)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("gingerbread_pigman")
    inst.AnimState:SetBuild("gingerbread_pigman")

    inst:AddTag("character")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = TUNING.GINGERBREADPIG_RUN_SPEED

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetOnPlayerNear(OnPlayerNear)
    inst.components.playerprox:SetOnPlayerFar (OnPlayerFar)
    inst.components.playerprox:SetDist(15, 45)
    inst.components.playerprox:SetPlayerAliveMode(true)

    inst:SetStateGraph("SGgingerbreadpig")

    inst:SetBrain(brain)

    inst:AddComponent("health")
    inst:AddComponent("combat")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)

    inst:AddComponent("inspectable")

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)

    MakeSmallBurnableCharacter(inst, "gingerbread_pigman_body")

    MakeSmallFreezableCharacter(inst)

    MakeHauntablePanic(inst)

    inst.StartDroppingCrumbs = StartDroppingCrumbs
    inst:ListenForEvent("onremove", function()
        if inst.crumb_task then
            inst.crumb_task:Cancel()
            inst.crumb_task = nil
        end

        if inst.killtask then
            inst.killtask:Cancel()
            inst.killtask = nil
        end
    end)

    inst.OnSave = OnSave
    inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

local function dead_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 50, .5)

    local COLLISION_MASK = COLLISION.GROUND
                         + COLLISION.LAND_OCEAN_LIMITS
                         + COLLISION.OBSTACLES
                         + COLLISION.SMALLOBSTACLES

    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(5)
    inst.Physics:SetCollisionGroup(COLLISION.WORLD)
    inst.Physics:SetCollisionMask(COLLISION_MASK)
    inst.Physics:SetCapsule(0.5, 1)

    inst.DynamicShadow:SetSize(1.5, .75)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("gingerbread_pigman")
    inst.AnimState:SetBuild("gingerbread_pigman")

    inst:AddTag("DECOR")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 0.35

    inst:SetStateGraph("SGgingerdeadpig")
    inst:DoTaskInTime(0, function() inst.sg:GoToState("walk_start") end)

    inst.persists = false

    return inst
end

return Prefab("gingerbreadpig", fn, assets, prefabs),
       Prefab("gingerdeadpig", dead_fn, assets, prefabs)