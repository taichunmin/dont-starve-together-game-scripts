local assets =
{
    Asset("ANIM", "anim/shadow_creatures_ground.zip"),
}

local prefabs =
{
    "shadowhand_arm",
}

local function Dissipate(inst)
    if inst.dissipating then
        return
    end
    inst.dissipating = true
    inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowhand_snuff")
    inst.SoundEmitter:KillSound("creeping")
    inst.SoundEmitter:KillSound("retreat")
    inst.components.locomotor:Stop()
    inst.components.locomotor:Clear()
    if inst.components.playerprox ~= nil then
        inst:RemoveComponent("playerprox")
    end
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
    if inst._distance_test_task ~= nil then
        inst._distance_test_task:Cancel()
        inst._distance_test_task = nil
    end
    if inst.arm ~= nil then
        inst.arm.AnimState:PlayAnimation("arm_scare")
    end
    inst.AnimState:PlayAnimation("hand_scare")
    inst:ListenForEvent("animover", inst.Remove)
end

local function DoConsumeFire(inst)
    inst.task = nil
    inst:PerformBufferedAction()
    inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowhand_snuff")

    --Retract
    inst.SoundEmitter:KillSound("creeping")
    inst.components.locomotor:Stop()
    inst.components.locomotor:Clear()
    inst.components.locomotor.walkspeed = -10
    inst.components.locomotor:GoToEntity(inst.arm)

    inst.AnimState:PlayAnimation("grab_pst")
    inst:ListenForEvent("animover", inst.Remove)
end

local function ConsumeFire(inst, fire)
    if fire ~= nil then
        if inst.task ~= nil then
            inst.task:Cancel()
            inst.task = nil
        end
        inst.AnimState:PlayAnimation("grab")
        inst.AnimState:PushAnimation("grab_pst", false)

        -- We're removing the on-fire-removed callback, so we also need to stop our position update that tests its location!
        if inst._distance_test_task ~= nil then
            inst._distance_test_task:Cancel()
            inst._distance_test_task = nil
        end
        inst:RemoveEventCallback("onextinguish", inst.dissipatefn, fire)
        inst:RemoveEventCallback("onremove", inst.dissipatefn, fire)
        if inst.components.playerprox ~= nil then
            inst:RemoveComponent("playerprox")
        end
        inst.task = inst:DoTaskInTime(17 * FRAMES, DoConsumeFire)
    end
end

local function DoCreeping(inst)
    inst.task = nil
    inst.components.locomotor.walkspeed = 2
    inst.components.locomotor:PushAction(BufferedAction(inst, inst.fire, ACTIONS.EXTINGUISH), false)
end

local function StartCreeping(inst, delay)
    if inst.task ~= nil then
        inst.task:Cancel()
    end
    inst.task = inst:DoTaskInTime(delay or 0, DoCreeping)
    inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowhand_creep", "creeping")
end

local function Regroup(inst)
    inst.AnimState:PushAnimation("hand_in_loop", true)
    inst.SoundEmitter:KillSound("retreat")
    inst.components.locomotor:Stop()
    inst.components.locomotor:Clear()
    StartCreeping(inst, 2 + math.random() * 3)
end

local function Retreat(inst)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
    inst.AnimState:PlayAnimation("scared_loop", true)
    inst.SoundEmitter:KillSound("creeping")
    inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowhand_retreat", "retreat")
    inst.components.locomotor:Stop()
    inst.components.locomotor:Clear()
    inst.components.locomotor.walkspeed = -8
    inst.components.locomotor:PushAction(BufferedAction(inst, inst.arm, ACTIONS.GOHOME, nil, inst.arm:GetPosition()))
end

local function HandleAction(inst, data)
    if data.action ~= nil then
        if data.action.action == ACTIONS.EXTINGUISH then
            ConsumeFire(inst, data.action.target)
        elseif data.action.action == ACTIONS.GOHOME then
            Dissipate(inst)
        end
    end
end

local MAX_ARM_DISTANCE_SQ = 2000
local function FireDistanceTest(inst)
    if inst.fire == nil then
        return
    end

    local fire_x, fire_y, fire_z = inst.fire.Transform:GetWorldPosition()
    local origin = inst.components.knownlocations:GetLocation("origin")
    local fire_distance_sq = distsq(fire_x, fire_z, origin.x, origin.z)
    if fire_distance_sq > MAX_ARM_DISTANCE_SQ then
        Dissipate(inst)
    end
end

local function SetTargetFire(inst, fire)
    if inst.fire ~= nil or fire == nil or inst.dissipating then
        return
    end
    inst.fire = fire

    local pos = inst:GetPosition()
    inst:AddComponent("knownlocations")
    inst.components.knownlocations:RememberLocation("origin", pos)

    inst.arm = SpawnPrefab("shadowhand_arm")
    inst.arm.Transform:SetPosition(pos:Get())
    inst.arm:FacePoint(fire:GetPosition())
    inst.arm.components.stretcher:SetStretchTarget(inst)

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(2, 6)
    inst.components.playerprox:SetOnPlayerNear(Retreat)
    inst.components.playerprox:SetOnPlayerFar(Regroup)

    inst.dissipatefn = function() Dissipate(inst) end
    inst:ListenForEvent("enterlight", inst.dissipatefn, inst.arm)
    inst:ListenForEvent("onextinguish", inst.dissipatefn, fire)
    inst:ListenForEvent("onremove", inst.dissipatefn, fire)
    inst:ListenForEvent("startaction", HandleAction)

    StartCreeping(inst)

    -- Also start a low-frequency distance-testing task, so that if our target
    -- manages to get far away from us, we also dissipate.
    if inst._distance_test_task ~= nil then
        inst._distance_test_task:Cancel()
        inst._distance_test_task = nil
    end
    inst._distance_test_task = inst:DoPeriodicTask(0.5, FireDistanceTest)
end

local function OnRemove(inst)
    inst.SoundEmitter:KillAllSounds()
    if inst.arm ~= nil then
        inst.arm:Remove()
        inst.arm = nil
    end
end

local function create_hand()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 10, .5)
    RemovePhysicsColliders(inst)

    inst:AddTag("shadowhand")
    inst:AddTag("NOCLICK")
    inst:AddTag("ignorewalkableplatforms")

    inst.AnimState:SetBank("shadowcreatures")
    inst.AnimState:SetBuild("shadow_creatures_ground")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:PlayAnimation("hand_in")
    inst.AnimState:PushAnimation("hand_in_loop", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.arm = nil
    inst.fire = nil
    inst.task = nil
    inst.dissipating = nil
    inst.SetTargetFire = SetTargetFire

    inst:WatchWorldState("startday", Dissipate)

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 2
    inst.components.locomotor.directdrive = true
    inst.components.locomotor.slowmultiplier = 1
    inst.components.locomotor.fastmultiplier = 1
	inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = true }

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

    inst.OnRemoveEntity = OnRemove
    inst.persists = false

    return inst
end

local function create_arm()
    local inst = CreateEntity()

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLightWatcher()
    inst.entity:AddNetwork()

    inst.LightWatcher:SetLightThresh(.2)
    inst.LightWatcher:SetDarkThresh(.19)

    inst.AnimState:SetBank("shadowcreatures")
    inst.AnimState:SetBuild("shadow_creatures_ground")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:PlayAnimation("arm_loop", true)

    inst:AddComponent("highlightchild")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stretcher")
    inst.components.stretcher:SetRestingLength(4.75)
    inst.components.stretcher:SetWidthRatio(.35)

    inst.persists = false

    return inst
end

return Prefab("shadowhand", create_hand, assets, prefabs),
    Prefab("shadowhand_arm", create_arm, assets)