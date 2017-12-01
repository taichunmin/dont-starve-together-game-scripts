local brain = require("brains/grassgekkobrain")

local assets =
{
    Asset("ANIM", "anim/grassgecko.zip"),
}

local prefabs =
{
    "cutgrass",
    "plantmeat",
    "grassgekkoherd",
}

SetSharedLootTable('grassgekko',
{
    {'plantmeat',        1.00},
    {'cutgrass',         0.75},
    {'cutgrass',         0.75},
})

function GetRunAngle(inst, pt, hp)
    local angle = inst:GetAngleToPoint(hp) + 180 -- + math.random(30)-15
    if angle > 360 then angle = angle - 360 end

    local radius = 6

    local result_offset, result_angle, deflected = FindWalkableOffset(pt, angle*DEGREES, radius, 8, true, false) -- try avoiding walls
    if not result_angle then
        result_offset, result_angle, deflected = FindWalkableOffset(pt, angle*DEGREES, radius, 8, true, true) -- ok don't try to avoid walls, but at least avoid water
    end
    if not result_angle then
        return angle -- ok whatever, just run
    end

    if result_angle then
        result_angle = result_angle/DEGREES
        return result_angle
    end

    return nil
end

local function ontimerdone(inst, data)
    if data.name == "growTail" then
       inst.tailGrowthPending = true
    end
end

local function SleepTest(inst)
    if ( inst.components.follower and inst.components.follower.leader )
        or ( inst.components.combat and inst.components.combat.target )
        or inst.components.playerprox:IsPlayerClose()
        or TheWorld.state.israining then
        return
    end
    if not inst.sg:HasStateTag("busy") and (not inst.last_wake_time or GetTime() - inst.last_wake_time >= inst.nap_interval) then
        inst.nap_length = math.random(TUNING.MIN_CATNAP_LENGTH, TUNING.MAX_CATNAP_LENGTH)
        inst.last_sleep_time = GetTime()
        return true
    end
end

local function WakeTest(inst)
    if not inst.last_sleep_time
        or GetTime() - inst.last_sleep_time >= inst.nap_length
        or TheWorld.state.israining then
        inst.nap_interval = math.random(TUNING.MIN_CATNAP_INTERVAL, TUNING.MAX_CATNAP_INTERVAL)
        inst.last_wake_time = GetTime()
        return true
    end
end

local function OnLoad(inst, data)
    if inst.components.timer:TimerExists("growTail") then
        inst.hasTail = false
        inst.AnimState:Hide("tail")
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(2,0.75)
    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 1, 0.5)

    inst.AnimState:SetBank("grassgecko")
    inst.AnimState:SetBuild("grassgecko")
    inst.AnimState:PlayAnimation("idle_loop")

    inst:AddTag("smallcreature")
    inst:AddTag("animal")
    inst:AddTag("grassgekko")

    --herdmember (from herdmember component) added to pristine state for optimization
    inst:AddTag("herdmember")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("timer")
    inst.hasTail = true
    inst:ListenForEvent("timerdone", ontimerdone)

    inst:AddComponent("inspectable")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.GRASSGEKKO_LIFE)

    inst:AddComponent("combat")
    inst.components.combat:SetHurtSound("dontstarve/creatures/together/grass_gekko/hit")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('grassgekko')

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(3,4)
    inst.components.playerprox:SetOnPlayerNear(function(inst)
        if inst.components.sleeper:IsAsleep() then
            inst.components.sleeper:WakeUp()
        end
    end)

    inst:AddComponent("knownlocations")
    inst:AddComponent("herdmember")
    inst.components.herdmember:SetHerdPrefab("grassgekkoherd")
    --inst.components.herdmember:Enable(true)

    inst:AddComponent("sleeper")
    --inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(12, 4)
    inst.last_sleep_time = nil
    inst.last_wake_time = GetTime()
    inst.nap_interval = math.random(TUNING.MIN_CATNAP_INTERVAL, TUNING.MAX_CATNAP_INTERVAL)
    inst.nap_length = math.random(TUNING.MIN_CATNAP_LENGTH, TUNING.MAX_CATNAP_LENGTH)
    inst.components.sleeper:SetWakeTest(WakeTest)
    inst.components.sleeper:SetSleepTest(SleepTest)

    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = TUNING.GRASSGEKKO_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.GRASSGEKKO_WALK_SPEED

    MakeSmallBurnableCharacter(inst, "grassgecko_body", Vector3(1,0,1))
    MakeSmallFreezableCharacter(inst)

    inst:SetBrain(brain)
    inst:SetStateGraph("SGgrassgekko")

    MakeHauntablePanicAndIgnite(inst)

    inst.OnLoad = OnLoad

    return inst
end

return Prefab("grassgekko", fn, assets, prefabs)
