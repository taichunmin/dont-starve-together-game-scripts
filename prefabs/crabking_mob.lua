local assets =
{
    Asset("ANIM", "anim/crabking_mob.zip"),
}

local assets_knight =
{
    Asset("ANIM", "anim/crabking_mob.zip"),
    Asset("ANIM", "anim/crabking_mob_knight_build.zip"),
}

local prefabs =
{
    "meat",
    "rocks",
    "flint",
}

local brain = require "brains/crabking_mobbrain"

local SHARE_TARGET_DIST = 30
local MAX_TARGET_SHARES = 10

------------------------------------------------------------------------------------------------------------------------------------

SetSharedLootTable("crabking_mob",
{
    {"meat",  1.00},
    {"meat",  0.25},

    {"rocks", 1.00},
    {"rocks", 0.25},

    {"flint", 0.50},
    {"flint", 0.15},
})

SetSharedLootTable("crabking_mob_knight",
{
    {"meat",  1.00},
    {"meat",  0.50},
    {"meat",  0.25},

    {"rocks", 1.00},
    {"rocks", 0.50},
    {"rocks", 0.50},

    {"flint", 1.00},
    {"flint", 0.25},
})

------------------------------------------------------------------------------------------------------------------------------------

local RETARGET_MUST_TAGS = { "_combat", "_health", "character" }
local RETARGET_CANT_TAGS = { "crabking_ally", "INLIMBO", "notarget", "noattack", "flight", "invisible", "playerghost" }

local function RetargetFn(inst)
    return FindEntity(inst,
        SpringCombatMod(TUNING.CRABKING_MOB_TARGET_DIST),
        function(guy)
            return inst.components.combat:CanTarget(guy)
        end,
        RETARGET_MUST_TAGS,
        RETARGET_CANT_TAGS
    )
end

local function ShareTargetFn(guy)
    return
        guy:HasTag("crab_mob") and
        guy.components.health ~= nil and
        not guy.components.health:IsDead()
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, SpringCombatMod(SHARE_TARGET_DIST), ShareTargetFn, MAX_TARGET_SHARES)
end

local function KeepTargetFn(inst, target)
    return
        target ~= nil and
        target:IsValid() and
        target.components.combat ~= nil and
        target.components.health ~= nil and
        inst.components.combat:CanTarget(target) and
        not target.components.health:IsDead()
 end

local function PlaySound(inst, event, name)
    inst.SoundEmitter:PlaySound("meta4/crabcritter/" .. event, name)
end

------------------------------------------------------------------------------------------------------------------------------------

local function CreateCommon(bank, build, common_init)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 100, .75)

    inst.DynamicShadow:SetSize(1.5, .5)

    inst.Transform:SetSixFaced()

    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("scarytoprey")
    inst:AddTag("crab_mob")
    inst:AddTag("crabking_ally")
    inst:AddTag("lunar_aligned")

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle")

    if common_init ~= nil then
        common_init(inst)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.build = build

    inst.PlaySound = PlaySound -- Used in the stategraph.
    inst._OnAttacked = OnAttacked

    inst:AddComponent("embarker")
    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")
    inst:AddComponent("lootdropper")
    inst:AddComponent("sanityaura")
    inst:AddComponent("drownable")

    inst:AddComponent("locomotor")
    inst.components.locomotor:SetAllowPlatformHopping(true)

    inst:AddComponent("health")
    inst.components.health.save_maxhealth = true

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "cc_bod"
    inst.components.combat:SetRange(TUNING.CRABKING_MOB_ATTACK_RANGE, TUNING.CRABKING_MOB_HIT_RANGE)
    inst.components.combat:SetAttackPeriod(TUNING.CRABKING_MOB_ATTACK_PERIOD + math.random() * 2)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetRetargetFunction(2, RetargetFn)

    inst:AddComponent("sleeper")
    inst.components.sleeper.watchlight = true
    inst.components.sleeper:SetResistance(2)

    inst:SetStateGraph("SGcrabking_mob")
    inst:SetBrain(brain)

    inst:ListenForEvent("attacked", inst._OnAttacked)

    MakeMediumBurnableCharacter(inst,  "cc_bod")
    MakeMediumFreezableCharacter(inst, "cc_bod")
    MakeHauntablePanic(inst)

    return inst
end

------------------------------------------------------------------------------------------------------------------------------------

local function RegularCommongPostInit(inst)
    inst:AddTag("smallcreature")
end

local function RegularFn()
    local inst = CreateCommon("crabking_mob", "crabking_mob", RegularCommongPostInit)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.health:SetMaxHealth(TUNING.CRABKING_MOB_HEALTH)
    inst.components.combat:SetDefaultDamage(TUNING.CRABKING_MOB_DAMAGE)

    inst.components.locomotor.walkspeed = TUNING.CRABKING_MOB_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.CRABKING_MOB_RUN_SPEED

    inst.components.embarker.embark_speed = inst.components.locomotor.runspeed

    inst.components.lootdropper:SetChanceLootTable("crabking_mob")

    inst.components.sanityaura.aura = -TUNING.SANITYAURA_SMALL

    return inst
end

------------------------------------------------------------------------------------------------------------------------------------

local KNIGHT_SCALE = 1.7

local function KnightCommongPostInit(inst)
    inst:AddTag("largecreature")

    inst.Transform:SetScale(KNIGHT_SCALE, KNIGHT_SCALE, KNIGHT_SCALE)
    inst.DynamicShadow:SetSize(1.5 * KNIGHT_SCALE, .5 * KNIGHT_SCALE)
end

local function KnightFn()
    local inst = CreateCommon("crabking_mob", "crabking_mob_knight_build", KnightCommongPostInit )

    inst:AddTag("crab_mob_knight")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_scale = 0.85

    inst.components.health:SetMaxHealth(TUNING.CRABKING_MOB_KNIGHT_HEALTH)

    inst.components.combat:SetDefaultDamage(TUNING.CRABKING_MOB_KNIGHT_DAMAGE)
    inst.components.combat:SetRange(TUNING.CRABKING_MOB_KNIGHT_ATTACK_RANGE, TUNING.CRABKING_MOB_HIT_RANGE)

    inst.components.locomotor.walkspeed = TUNING.CRABKING_MOB_WALK_SPEED * (1/KNIGHT_SCALE) * 0.8
    inst.components.locomotor.runspeed = TUNING.CRABKING_MOB_RUN_SPEED * (1/KNIGHT_SCALE) * 0.8

    inst.components.embarker.embark_speed = inst.components.locomotor.runspeed

    inst.components.lootdropper:SetChanceLootTable("crabking_mob_knight")

    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

    inst.components.sleeper:SetResistance(10)

    return inst
end

------------------------------------------------------------------------------------------------------------------------------------

return
    Prefab("crabking_mob",        RegularFn, assets,        prefabs),
    Prefab("crabking_mob_knight", KnightFn,  assets_knight, prefabs)
