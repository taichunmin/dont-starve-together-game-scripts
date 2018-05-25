--Alive/ Annoying version.

--prefab transforms between different prefabs depending on state.
    --mandrake_planted --> mandrake_active (picked)
    --mandrake_planted <-- mandrake_active (replant)
    --mandrake_active --> mandrake_inactive (death)

local brain = require "brains/mandrakebrain"

local assets =
{
    Asset("ANIM", "anim/mandrake.zip"),
    Asset("SOUND", "sound/mandrake.fsb"),
}

local prefabs =
{
    "mandrake",
    "mandrake_planted",
}

local function replant(inst)
    --turn into "mandrake_planted"
    local planted = SpawnPrefab("mandrake_planted")
    planted.Transform:SetPosition(inst.Transform:GetWorldPosition())
    planted:replant(inst)

    inst:Remove()
end

local function ondeath(inst)
    --turn into "mandrake_inactive"
    local mandrake = SpawnPrefab("mandrake")
    mandrake.Transform:SetPosition(inst.Transform:GetWorldPosition())
    mandrake.AnimState:PlayAnimation("death")
    mandrake.AnimState:SetTime(2)

    inst:Remove()
end

local function FindNewLeader(inst)
    local player = FindClosestPlayerToInst(inst, 5, true)
    if player ~= nil then
        inst.components.follower:SetLeader(player)
    end
end

local function StartFindLeaderTask(inst)
    if inst._findleadertask == nil then
        inst._findleadertask = inst:DoPeriodicTask(1, FindNewLeader)
    end
end

local function StopFindLeaderTask(inst)
    if inst._findleadertask ~= nil then
        inst._findleadertask:Cancel()
        inst._findleadertask = nil
    end
end

local function CheckDay(inst)
    if TheWorld.state.isday then
        inst.components.health:Kill()
    end
end

local function onpicked(inst, leader)
    --Go to proper animation state
    inst.sg:GoToState("picked")

    FindNewLeader(inst)

    --(Die if it's day time)
    inst:DoTaskInTime(26 * FRAMES, CheckDay)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 10, 0.25)
    inst.Transform:SetFourFaced()
    inst.DynamicShadow:SetSize(1.75, 0.5)

    inst.AnimState:SetBank("mandrake")
    inst.AnimState:SetBuild("mandrake")
    inst.AnimState:PlayAnimation("idle_loop")

    inst:AddTag("character")
    inst:AddTag("small")
    inst:AddTag("smallcreature")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("combat")
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(20)
    inst.components.health.nofadeout = true
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 6
    inst:AddComponent("follower")

    inst:SetStateGraph("SGMandrake")
    inst:SetBrain(brain)

    inst.onpicked = onpicked

    --Watch world state
    inst:WatchWorldState("startday", replant)
    inst:ListenForEvent("startfollowing", StopFindLeaderTask)
    inst:ListenForEvent("stopfollowing", StartFindLeaderTask)
    StartFindLeaderTask(inst)
    inst.ondeath = ondeath

    return inst
end

return Prefab("mandrake_active", fn, assets, prefabs)
