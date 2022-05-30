local brain = require "brains/tallbirdbrain"

local assets =
{
    Asset("ANIM", "anim/ds_tallbird_basic.zip"),
    Asset("SOUND", "sound/tallbird.fsb"),
}

local prefabs =
{
    "meat",
}

local loot = { "meat", "meat" }
local MAX_CHASEAWAY_DIST = 32
local MAX_CHASE_DIST = 256

local RETARGET_MUST_TAGS = { "_combat", "_health" }
local RETARGET_PIG_MUST_TAGS = { "pig", "_combat", "_health" }
local RETARGET_CANT_TAGS = { "tallbird" }
local RETARGET_WEREPIG_CANT_TAGS = { "werepig" }
local RETARGET_ONEOF_TAGS = { "character", "monster" }
local RETARGET_ANIMAL_ONEOF_TAGS = { "character", "animal", "monster" }
local function Retarget(inst)
    local function IsValidTarget(guy)
        return not guy.components.health:IsDead()
            and inst.components.combat:CanTarget(guy)
            --smallbirds that aren't companions are parented
            --to other tallbirds, so don't target them!
            and (not inst:HasTag("smallbird") or inst:HasTag("companion"))
    end
    return --Threat to nest
        inst.components.homeseeker ~= nil and
        inst.components.homeseeker:HasHome() and
        FindEntity(
            inst.components.homeseeker.home,
            SpringCombatMod(TUNING.TALLBIRD_DEFEND_DIST),
            IsValidTarget,
            RETARGET_MUST_TAGS,
            RETARGET_CANT_TAGS,
            RETARGET_ANIMAL_ONEOF_TAGS)
        or --Nearby pigman (Why the hatred for pigs? It's expensive!)
        FindEntity(
            inst,
            SpringCombatMod(TUNING.TALLBIRD_TARGET_DIST),
            IsValidTarget,
            RETARGET_PIG_MUST_TAGS,
            RETARGET_WEREPIG_CANT_TAGS)
        or --Nearby character or monster
        FindEntity(
            inst,
            SpringCombatMod(TUNING.TALLBIRD_TARGET_DIST),
            IsValidTarget,
            RETARGET_MUST_TAGS,
            RETARGET_CANT_TAGS,
            RETARGET_ONEOF_TAGS)
end

local function KeepTarget(inst, target)
    local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
    --In case of no home, just say keep the target
    --If there is an egg thief, then chase up to MAX_CHASE_DIST from home
    --Otherwise, only chase up to MAX_CHASEAWAY_DIST from home
    return home == nil or
        inst:IsNear(home,
            target == home.thief and
            home.components.pickable ~= nil and
            not home.components.pickable:CanBePicked() and
            SpringCombatMod(MAX_CHASE_DIST) or
            SpringCombatMod(MAX_CHASEAWAY_DIST))
end

local function ShouldSleep(inst)
    return TheWorld.state.isnight and inst.components.combat.target == nil
end

local function ShouldWake(inst)
    return not TheWorld.state.isnight or inst.components.combat.target ~= nil
end

local function OnAttacked(inst, data)
    if data.attacker == nil then
        return
    end

    local current_target = inst.components.combat.target

    if current_target == data.attacker then
        --Already targeting our attacker, just update the time
        inst._last_attacker = current_target
        inst._last_attacked_time = GetTime()
        return
    end

    if current_target ~= nil then
        local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
        if home ~= nil and
            current_target == home.thief and
            home.components.pickable ~= nil and
            home.components.pickable:CanBePicked() then
            --Don't change target from our egg thief!
            return
        end

        local time = GetTime()
        if inst._last_attacker == current_target and
            inst._last_attacked_time + TUNING.TALLBIRD_ATTACK_AGGRO_TIMEOUT >= time then
            --Our target attacked us recently, stay on it!
            return
        end

        --Switch to new target
        inst.components.combat:SetTarget(data.attacker)
        inst._last_attacker = data.attacker
        inst._last_attacked_time = time

    elseif inst.components.combat:SuggestTarget(data.attacker) then
        inst._last_attacker = data.attacker
        inst._last_attacked_time = GetTime()
    end
end

local function OnEntitySleep(inst, data)
    inst.entitysleeping = true
    if inst.pending_spawn_smallbird then
        local smallbird = SpawnPrefab("smallbird")
        smallbird:PushEvent("SetUpSpringSmallBird", {smallbird=smallbird, tallbird=inst})
        inst.pending_spawn_smallbird = false
    end
end

local function OnEntityWake(inst, data)
    inst.entitysleeping = false
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 10, .5)

    inst.DynamicShadow:SetSize(2.75, 1)
    --inst.Transform:SetScale(1.5, 1.5, 1.5)
    inst.Transform:SetFourFaced()

    ----------
    inst:AddTag("tallbird")
    inst:AddTag("animal")
    inst:AddTag("largecreature")

    inst.AnimState:SetBank("tallbird")
    inst.AnimState:SetBuild("ds_tallbird_basic")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:Hide("beakfull")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._last_attacker = nil
    inst._last_attacked_time = nil

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 7

    inst:SetStateGraph("SGtallbird")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)

    ------------------
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.TALLBIRD_HEALTH)

    ------------------

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "head"
    inst.components.combat:SetDefaultDamage(TUNING.TALLBIRD_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.TALLBIRD_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(3, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetRange(TUNING.TALLBIRD_ATTACK_RANGE)

    MakeLargeBurnableCharacter(inst, "head")
    MakeLargeFreezableCharacter(inst, "head")
    MakeHauntablePanic(inst)
    ------------------

    inst:AddComponent("knownlocations")

    inst:AddComponent("leader")

    ------------------

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODGROUP.OMNI }, { FOODGROUP.OMNI })

    ------------------
    inst:AddComponent("sleeper")
    inst.components.sleeper.watchlight = true
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWake)
    ------------------

    inst:AddComponent("inspectable")

    ------------------

    inst:SetBrain(brain)

    inst:ListenForEvent("attacked", OnAttacked)

    inst:ListenForEvent("entitysleep", OnEntitySleep)
    inst:ListenForEvent("entitywake", OnEntityWake)

    return inst
end

return Prefab("tallbird", fn, assets, prefabs)