local assets =
{
    Asset("ANIM", "anim/krampus_basic.zip"),
    Asset("ANIM", "anim/krampus_build.zip"),
    Asset("SOUND", "sound/krampus.fsb"),
}

local prefabs =
{
    "charcoal",
    "monstermeat",
    "krampus_sack",
}

local brain = require "brains/krampusbrain"

SetSharedLootTable( 'krampus',
{
    {'monstermeat',  1.0},
    {'charcoal',     1.0},
    {'charcoal',     1.0},
    {'krampus_sack', .01},
})

local function NotifyBrainOfTarget(inst, target)
    if inst.brain and inst.brain.SetTarget then
        inst.brain:SetTarget(target)
    end
end

local function makebagfull(inst)
    inst.AnimState:Show("SACK")
    inst.AnimState:Hide("ARM")
end

local function makebagempty(inst)
    inst.AnimState:Hide("SACK")
    inst.AnimState:Show("ARM")
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    --inst.components.combat:ShareTarget(data.attacker, SEE_DIST, function(dude) return dude:HasTag("hound") and not dude.components.health:IsDead() end, 5)
end

local function OnNewCombatTarget(inst, data)
    NotifyBrainOfTarget(inst, data.target)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 10, .5)

    inst.DynamicShadow:SetSize(3, 1)
    inst.Transform:SetFourFaced()

    inst:AddTag("scarytoprey")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("deergemresistance")

    inst.AnimState:Hide("ARM")
    inst.AnimState:SetBank("krampus")
    inst.AnimState:SetBuild("krampus_build")
    inst.AnimState:PlayAnimation("run_loop", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventory")
    inst.components.inventory.ignorescangoincontainer = true

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.KRAMPUS_SPEED
    inst:SetStateGraph("SGkrampus")

    inst:SetBrain(brain)

    MakeLargeBurnableCharacter(inst, "krampus_torso")
    MakeLargeFreezableCharacter(inst, "krampus_torso")

 --[[   inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.MEAT }, { FOODTYPE.MEAT })
    inst.components.eater:SetCanEatHorrible()
    inst.components.eater:SetStrongStomach(true) -- can eat monster meat!--]]

    inst:AddComponent("sleeper")
    inst.components.sleeper.watchlight = true
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.KRAMPUS_HEALTH)

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "krampus_torso"
    inst.components.combat:SetDefaultDamage(TUNING.KRAMPUS_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.KRAMPUS_ATTACK_PERIOD)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('krampus')

    inst:AddComponent("inspectable")
    inst.components.inspectable:RecordViews()

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("newcombattarget", OnNewCombatTarget)

    MakeHauntablePanic(inst)

    return inst
end

return Prefab("krampus", fn, assets, prefabs)
