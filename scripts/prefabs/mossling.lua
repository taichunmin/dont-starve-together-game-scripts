local assets =
{
    Asset("ANIM", "anim/mossling_build.zip"),
    Asset("ANIM", "anim/mossling_basic.zip"),
    Asset("ANIM", "anim/mossling_actions.zip"),
    Asset("ANIM", "anim/mossling_angry_build.zip"),
    Asset("ANIM", "anim/mossling_yule_build.zip"),
    Asset("ANIM", "anim/mossling_yule_angry_build.zip"),
    -- Asset("SOUND", "sound/mossling.fsb"),
}

local prefabs =
{
    "mossling_spin_fx",
    "goose_feather",
    "drumstick",
}

local brain = require("brains/mosslingbrain")

SetSharedLootTable( 'mossling',
{
    {'meat',             1.00},
    {'drumstick',        1.00},
    {'goose_feather',    1.00},
    {'goose_feather',    1.00},
    {'goose_feather',    0.33},
})

local LOSE_TARGET_DIST = 13
local TARGET_DIST = 6

local function HasGuardian(inst)
    return inst.components.herdmember.herd ~= nil
        and inst.components.herdmember.herd.components.guardian:HasGuardian()
end

local RETARGET_CANT_TAGS = { "prey", "smallcreature", "mossling", "moose" }
local RETARGET_ONEOF_TAGS = { "monster", "player" }
local function RetargetFn(inst)
    return (inst.mother_dead or inst:HasGuardian())
        and FindEntity(
                inst,
                TARGET_DIST,
                function(guy)
                    return inst.components.combat:CanTarget(guy)
                end,
                nil,
                RETARGET_CANT_TAGS,
                RETARGET_ONEOF_TAGS
            )
        or nil
end

local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
        and (inst.mother_dead or
            not inst:HasGuardian() or
            not inst:IsNear(target, LOSE_TARGET_DIST))
end

local function OnSave(inst, data)
    data.mother_dead = inst.mother_dead
    data.shouldGoAway = inst.shouldGoAway or nil
end

local function OnLoad(inst, data)
    if data ~= nil and data.mother_dead then
        inst.mother_dead = data.mother_dead
    end
    if data ~= nil and data.shouldGoAway then
        inst.shouldGoAway = data.shouldGoAway
    end
end

local function OnEntitySleep(inst)
    if inst.shouldGoAway then
        inst:Remove()
    end
end

local function OnSpringChange(inst, isspring)
    inst.shouldGoAway = not isspring or TheWorld:HasTag("cave")
    if inst:IsAsleep() then
        OnEntitySleep(inst)
    end
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 60,
        function(guy)
            return guy.prefab == inst.prefab
                or (inst.components.herdmember.herd ~= nil and
                    inst.components.herdmember.herd.components.guardian.guardian == guy)
        end,
    60)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()

    inst.DynamicShadow:SetSize(1.5, 1.25)

    MakeCharacterPhysics(inst, 50, .5)

    inst.AnimState:SetBank("mossling")
    inst.AnimState:SetBuild(IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) and "mossling_yule_build" or "mossling_build")
    inst.AnimState:PlayAnimation("idle", true)

    ------------------------------------------

    inst:AddTag("mossling")
    inst:AddTag("animal")

    --herdmember (from herdmember component) added to pristine state for optimization
    inst:AddTag("herdmember")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    ------------------

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.MOSSLING_HEALTH)
    inst.components.health.destroytime = 5

    ------------------

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.MOSSLING_DAMAGE)
    inst.components.combat.playerdamagepercent = .5
    inst.components.combat:SetRange(TUNING.MOSSLING_ATTACK_RANGE)
    inst.components.combat.hiteffectsymbol = "mossling_body"
    inst.components.combat:SetAttackPeriod(TUNING.MOSSLING_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1.5, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/mossling/hurt")

    ------------------------------------------

    inst:AddComponent("sizetweener")

    ------------------------------------------

    inst:AddComponent("sleeper")
    --inst.components.sleeper:SetResistance(4)

    ------------------------------------------

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('mossling')

    ------------------------------------------

    inst:AddComponent("inspectable")
    inst.components.inspectable:RecordViews()

    ------------------------------------------

    inst:AddComponent("knownlocations")
    inst:AddComponent("inventory")
    inst:AddComponent("herdmember")
    inst.components.herdmember.herdprefab = "mooseegg"

    ------------------------------------------

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODGROUP.MOOSE }, { FOODGROUP.MOOSE })
    inst.components.eater.eatwholestack = true

    ------------------------------------------

    inst:WatchWorldState("isspring", OnSpringChange)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("entitysleep", OnEntitySleep)

    OnSpringChange(inst, TheWorld.state.isspring)

    ------------------------------------------

    MakeMediumBurnableCharacter(inst, "swap_fire")
    inst.components.burnable.lightningimmune = true
    MakeHugeFreezableCharacter(inst, "mossling_body")

    inst.HasGuardian = HasGuardian

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    ------------------------------------------

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.MOSSLING_WALK_SPEED

    inst:SetStateGraph("SGmossling")
    inst:SetBrain(brain)

    MakeHauntablePanic(inst)

    return inst
end

return Prefab("mossling", fn, assets, prefabs)
