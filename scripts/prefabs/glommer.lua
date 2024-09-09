local assets =
{
    Asset("ANIM", "anim/glommer.zip"),
    Asset("SOUND", "sound/glommer.fsb"),
}

local prefabs =
{
    "glommerfuel",
    "glommerwings",
    "monstermeat",
}

local brain = require("brains/glommerbrain")

SetSharedLootTable('glommer',
{
    {'monstermeat',             1.00},
    {'monstermeat',             1.00},
    {'monstermeat',             1.00},
    {'glommerwings',            1.00},
    {'glommerfuel',             1.00},
    {'glommerfuel',             1.00},
})

local WAKE_TO_FOLLOW_DISTANCE = 14
local SLEEP_NEAR_LEADER_DISTANCE = 7

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst)
        or not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE)
end

local function ShouldSleep(inst)
    return DefaultSleepTest(inst)
        and inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE)
        and not TheWorld.state.isfullmoon
end

local function OnEntitySleep(inst)
    if inst.ShouldLeaveWorld then
        inst:Remove()
    end
end

local function OnSave(inst, data)
    data.ShouldLeaveWorld = inst.ShouldLeaveWorld
end

local function OnLoad(inst, data)
    if data ~= nil then
        inst.ShouldLeaveWorld = data.ShouldLeaveWorld
    end
end

local function OnSpawnFuel(inst, fuel)
    inst.sg:GoToState("goo", fuel)
end

local function OnStopFollowing(inst)
    inst:RemoveTag("companion")
end

local function OnStartFollowing(inst)
    if inst.components.follower.leader:HasTag("glommerflower") then
        inst:AddTag("companion")
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(2, .75)
    inst.Transform:SetFourFaced()

    MakeGhostPhysics(inst, 1, .5)

    inst.MiniMapEntity:SetIcon("glommer.png")
    inst.MiniMapEntity:SetPriority(5)

    inst.AnimState:SetBank("glommer")
    inst.AnimState:SetBuild("glommer")
    inst.AnimState:PlayAnimation("idle_loop")

    inst:AddTag("glommer")
    inst:AddTag("flying")
    inst:AddTag("lunar_aligned")
    inst:AddTag("ignorewalkableplatformdrowning")
    inst:AddTag("cattoyairborne")

    MakeInventoryFloatable(inst, "med")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("follower")
    inst:ListenForEvent("stopfollowing", OnStopFollowing)
    inst:ListenForEvent("startfollowing", OnStartFollowing)

    inst:AddComponent("health")
    inst:AddComponent("combat")
    inst:AddComponent("knownlocations")
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('glommer')

    inst:AddComponent("sleeper")
    inst.components.sleeper.watchlight = true
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = TUNING.SANITYAURA_TINY

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 6
    inst.components.locomotor.pathcaps = {allowocean = true}

    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetOnSpawnFn(OnSpawnFuel)
    inst.components.periodicspawner.prefab = "glommerfuel"
    inst.components.periodicspawner.basetime = TUNING.TOTAL_DAY_TIME * 2
    inst.components.periodicspawner.randtime = TUNING.TOTAL_DAY_TIME * 2
    inst.components.periodicspawner:Start()

    inst:SetBrain(brain)
    inst:SetStateGraph("SGglommer")

    MakeMediumFreezableCharacter(inst, "glommer_body")

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnEntitySleep = OnEntitySleep

    MakeHauntablePanic(inst)

    return inst
end

return Prefab("glommer", fn, assets, prefabs)
