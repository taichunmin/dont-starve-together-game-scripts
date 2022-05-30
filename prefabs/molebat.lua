local assets =
{
    Asset("ANIM", "anim/molebat.zip"),
}

local prefabs =
{
    "batnose",
    "molebathill",
    "monstermeat",
}

local brain = require "brains/molebatbrain"

SetSharedLootTable("molebat",
{
    {'guano',      0.15},
})

local function delete_burrow(inst)
    local burrow = inst.components.entitytracker:GetEntity("burrow")
    if burrow ~= nil then
        burrow:Remove()
    end
end

local function should_summon_allies(inst)
    if inst.components.entitytracker == nil then
        return false
    end

    -- We have no allies and we are allowed to summon them, so let's summon some.
    return inst._can_summon_allies and inst.components.entitytracker:GetEntity("ally") == nil
end

local function summon_ally(inst)
    local i_pos = inst:GetPosition()

    local offset = FindWalkableOffset(i_pos, math.random()*2*PI, 3, 8, false, true)

    -- If we fail to spawn, it's ok. Due to not setting entitytracker,
    -- we'll succeed again once our timer finishes.
    if offset ~= nil then
        local new_bat = SpawnPrefab("molebat")

        -- Become each other's allies.
        new_bat.components.entitytracker:TrackEntity("ally", inst)
        inst.components.entitytracker:TrackEntity("ally", new_bat)

        local spawn_point = i_pos + offset
        new_bat.Transform:SetPosition(spawn_point.x, spawn_point.y, spawn_point.z)
        new_bat.sg:GoToState("fall")

        -- Share our home location with our spawned ally.
        local our_home_location = inst.components.knownlocations:GetLocation("home")
        new_bat.components.knownlocations:RememberLocation("home", our_home_location)

        -- Share our tracked burrow with our spawned ally, if we have one.
        local burrow = inst.components.entitytracker:GetEntity("burrow")
        if burrow ~= nil then
            new_bat.components.entitytracker:TrackEntity("burrow", burrow)
        end
    end
end

local function wants_to_nap(inst)
    return inst._wants_to_nap and not inst._quaking
end

local MAX_DSQ_FROM_BURROW = 36
local function napping_distance_check(inst)
    local burrow = inst.components.entitytracker:GetEntity("burrow")
    if burrow ~= nil and inst:GetDistanceSqToInst(burrow) > MAX_DSQ_FROM_BURROW then
        inst.components.sleeper:WakeUp()
    end
end

local function do_nap(inst)
    inst._wants_to_nap = false
    inst.components.sleeper:AddSleepiness(4, TUNING.MOLEBAT_NAP_LENGTH * (1 + math.random() * 0.5))
    inst._kill_nap_task = inst:DoPeriodicTask(2.5, napping_distance_check)
end

local function ShouldSleep(inst)
    return false
end

local CHARACTER_TAGS = {"character"}
local SLEEP_DIST_FROMTHREAT = 20
local function ShouldWake(inst)
    return StandardWakeChecks(inst)
        or GetClosestInstWithTag(CHARACTER_TAGS, inst, SLEEP_DIST_FROMTHREAT) ~= nil
end

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "bat", "INLIMBO", "FX", "notarget", "noattack", "DECOR" }
local RETARGET_ONEOF_TAGS = { "character", "monster", "smallcreature" }
local function Retarget(inst)
    local closest_bug = nil
    local closest_other = nil

    local mx, my, mz = inst.Transform:GetWorldPosition()

    local entities_in_range = TheSim:FindEntities(
        mx, my, mz,
        TUNING.MOLEBAT_TARGET_DIST,
        RETARGET_MUST_TAGS,
        RETARGET_CANT_TAGS,
        RETARGET_ONEOF_TAGS
    )

    for i, e in ipairs(entities_in_range) do
        if e ~= inst and e.entity:IsVisible() and inst.components.combat:CanTarget(e) then
            if closest_bug == nil and e:HasTag("insect") then
                closest_bug = e
            elseif closest_other == nil then
                closest_other = e
            end

            if closest_bug ~= nil and closest_other ~= nil then
                break
            end
        end
    end

    return closest_bug or closest_other or nil
end

local function KeepTarget(inst, target)
    local homePos = inst.components.knownlocations:GetLocation("home")
    return (homePos ~= nil and target:GetDistanceSqToPoint(homePos:Get()) < TUNING.MOLEBAT_MAX_CHASE_DSQ)
end

local function _ShareTargetFn(dude)
    return dude:HasTag("bat")
end

local SHARE_TARGET_DIST = 40
local MAX_TARGET_SHARES = 5
local function OnAttacked(inst, data)
    local attacker = data ~= nil and data.attacker or nil
    if attacker == nil or attacker:HasTag("bat") then
        return
    end
    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, _ShareTargetFn, MAX_TARGET_SHARES)
end

local function OnWakeUp(inst)
    inst._wants_to_nap = false
    inst.components.timer:StopTimer("resetnap")
    inst.components.timer:StartTimer("resetnap", TUNING.MOLEBAT_NAP_COOLDOWN * (1 + math.random() * 0.3))

    if inst._kill_nap_task ~= nil then
        inst._kill_nap_task:Cancel()
        inst._kill_nap_task = nil
    end

    if not inst:IsAsleep() then
        if not inst.components.timer:TimerExists("cleannest_timer") then
            -- Time this out so that it fires at approximately when the wakeup animation would end
            -- This way, it's ok if wakeup is interrupted, but we don't actively interrupt it.
            -- Also, using the timer component, we'll get save/loaded as well!
            inst.components.timer:StartTimer("cleannest_timer", 33*FRAMES)
        end
    else
        delete_burrow(inst)
    end
end

local function OnSummon(inst)
    inst._can_summon_allies = false
    inst.components.timer:StartTimer("resetallysummon", TUNING.MOLEBAT_ALLY_COOLDOWN * (1 + math.random()))
end

local function OnTimerDone(inst, data)
    if data.name == "rememberinitiallocation" then
        inst.components.knownlocations:RememberLocation("home", inst:GetPosition())
    elseif data.name == "resetallysummon" then
        inst._can_summon_allies = true and TUNING.MOLEBAT_ENABLED
    elseif data.name == "resetnap" then
        inst._wants_to_nap = true
    elseif data.name == "cleannest_timer" then
        inst._nest_needs_cleaning = true
    end
end

local function OnQuakeBegin(inst)
    inst._quaking = true
    inst.components.sleeper:WakeUp()
end

local function OnQuakeEnd(inst)
    inst._quaking = false
end

local function on_save(inst, data)
    data.can_summon_allies = inst._can_summon_allies or false
    data.wants_to_nap = inst._wants_to_nap or false
    data.is_napping = (inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep()) or false
    data.quaking = inst._quaking or false
    data.nest_needs_cleaning = inst._nest_needs_cleaning or false
end

local function on_load(inst, data)
    if data then
        if data.can_summon_allies then
            inst._can_summon_allies = true

            -- Stop the constructer-started timer. We shouldn't have loaded one.
            inst.components.timer:StopTimer("resetallysummon")
        end

        if data.wants_to_nap then
            inst._wants_to_nap = data.wants_to_nap

            inst.components.timer:StopTimer("resetnap")
        end

        if data.is_napping then
            inst:Nap()
        end

        inst._quaking = data.quaking
        inst._nest_needs_cleaning = data.nest_needs_cleaning
    end
end

local function clean_up_break_action(inst)
    local ba = inst:GetBufferedAction()
    if ba ~= nil and ba.action == ACTIONS.BREAK then
        inst:ClearBufferedAction()

        delete_burrow(inst)
    end
end

local function on_entity_sleep(inst)
    if not POPULATING and inst.components.entitytracker:GetEntity("burrow") ~= nil then
        inst._sleep_cleanup_break_task = inst:DoTaskInTime(3, clean_up_break_action)
    end
end

local function on_entity_wake(inst)
    if inst._sleep_cleanup_break_task ~= nil then
        inst._sleep_cleanup_break_task:Cancel()
        inst._sleep_cleanup_break_task = nil
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

    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("molebat")
    inst.AnimState:SetBuild("molebat")

    inst:AddTag("bat")
    inst:AddTag("cavedweller")
    inst:AddTag("hostile")
    inst:AddTag("monster")
    inst:AddTag("scarytoprey")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.MOLEBAT_WALK_SPEED

    inst:SetStateGraph("SGmolebat")
    inst:SetBrain(brain)

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.sleeptestfn = ShouldSleep
    inst.components.sleeper.waketestfn = ShouldWake

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.MOLEBAT_HEALTH)

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "body"
    inst.components.combat:SetRetargetFunction(3, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetDefaultDamage(TUNING.MOLEBAT_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.MOLEBAT_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.MOLEBAT_ATTACK_RANGE)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("molebat")
    inst.components.lootdropper:AddRandomLoot("monstermeat", 2)
    inst.components.lootdropper:AddRandomLoot("batnose", 1)
    inst.components.lootdropper.numrandomloot = 1

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODGROUP.OMNI }, { FOODGROUP.OMNI })
    inst.components.eater:SetStrongStomach(true)

    inst:AddComponent("entitytracker")      -- track allies and burrow

    inst:AddComponent("timer")              -- primarily for ally summon refresh

    inst:AddComponent("inspectable")

    inst:AddComponent("knownlocations")

    inst.components.timer:StartTimer("rememberinitiallocation", 0)

    inst._can_summon_allies = false
    inst.components.timer:StartTimer("resetallysummon", TUNING.SEG_TIME * (1 + math.random()))

    inst._wants_to_nap = false
    inst.components.timer:StartTimer("resetnap", TUNING.MOLEBAT_NAP_COOLDOWN * (0.2 + math.random() * 0.3))

    inst._quaking = false
    inst._nest_needs_cleaning = false

    inst.ShouldSummonAllies = should_summon_allies
    inst.SummonAlly = summon_ally
    inst.WantsToNap = wants_to_nap
    inst.Nap = do_nap

    MakeMediumBurnableCharacter(inst, "body")
    MakeMediumFreezableCharacter(inst, "body")

    MakeHauntablePanic(inst)

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("onwakeup", OnWakeUp)
    inst:ListenForEvent("summon", OnSummon)
    inst:ListenForEvent("timerdone", OnTimerDone)

    inst:ListenForEvent("startquake", function(wn) OnQuakeBegin(inst) end, TheWorld.net)
    inst:ListenForEvent("endquake", function(wn) OnQuakeEnd(inst) end, TheWorld.net)

    inst.OnSave = on_save
    inst.OnLoad = on_load
    inst.OnEntitySleep = on_entity_sleep
    inst.OnEntityWake = on_entity_wake

    return inst
end

return Prefab("molebat", fn, assets, prefabs)
