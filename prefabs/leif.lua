local brain = require "brains/leifbrain"

local assets =
{
    Asset("ANIM", "anim/leif_walking.zip"),
    Asset("ANIM", "anim/leif_actions.zip"),
    Asset("ANIM", "anim/leif_attacks.zip"),
    Asset("ANIM", "anim/leif_idles.zip"),
    Asset("ANIM", "anim/leif_build.zip"),
    Asset("ANIM", "anim/leif_lumpy_build.zip"),
    Asset("SOUND", "sound/leif.fsb"),
}

local prefabs =
{
    "meat",
    "log",
    "character_fire",
    "livinglog",
}

local function SetLeifScale(inst, scale)
    inst._scale = scale ~= 1 and scale or nil

    inst.Transform:SetScale(scale, scale, scale)
    inst.Physics:SetCapsule(.5 * scale, 1)
    inst.DynamicShadow:SetSize(4 * scale, 1.5 * scale)

    inst.components.locomotor.walkspeed = 1.5 * scale

    inst.components.combat:SetDefaultDamage(TUNING.LEIF_DAMAGE * scale)
    inst.components.combat:SetRange(3 * scale)

    local health_percent = inst.components.health:GetPercent()
    inst.components.health:SetMaxHealth(TUNING.LEIF_HEALTH * scale)
    inst.components.health:SetPercent(health_percent, true)
end

local function onpreloadfn(inst, data)
    if data ~= nil and data.leifscale ~= nil then
        SetLeifScale(inst, data.leifscale)
    end
end

local function onloadfn(inst, data)
    if data ~= nil then
        if data.hibernate then
            inst.components.sleeper.hibernate = true
        end
        if data.sleep_time ~= nil then
            inst.components.sleeper.testtime = data.sleep_time
        end
        if data.sleeping then
            inst.components.sleeper:GoToSleep()
        end
    end
end

local function onsavefn(inst, data)
    data.leifscale = inst._scale

    if inst.components.sleeper:IsAsleep() then
        data.sleeping = true
        data.sleep_time = inst.components.sleeper.testtime
    end

    if inst.components.sleeper:IsHibernating() then
        data.hibernate = true
    end
end

local function CalcSanityAura(inst)
    return inst.components.combat.target ~= nil and -TUNING.SANITYAURA_LARGE or -TUNING.SANITYAURA_MED
end

local function OnBurnt(inst)
    if inst.components.propagator and inst.components.health and not inst.components.health:IsDead() then
        inst.components.propagator.acceptsheat = true
    end
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
end

local function common_fn(build)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 1000, .5)

    inst.DynamicShadow:SetSize(4, 1.5)
    inst.Transform:SetFourFaced()

    inst:AddTag("epic")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("leif")
    inst:AddTag("tree")
    inst:AddTag("evergreens")
    inst:AddTag("largecreature")

    inst.AnimState:SetBank("leif")
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    local color = .5 + math.random() * .5
    inst.AnimState:SetMultColour(color, color, color, 1)

    ------------------------------------------

    inst.OnPreLoad = onpreloadfn
    inst.OnLoad = onloadfn
    inst.OnSave = onsavefn

    ------------------------------------------

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 1.5

    ------------------------------------------
    inst:SetStateGraph("SGLeif")

    ------------------------------------------

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

    MakeLargeBurnableCharacter(inst, "marker")
    inst.components.burnable.flammability = TUNING.LEIF_FLAMMABILITY
    inst.components.burnable:SetOnBurntFn(OnBurnt)
    inst.components.propagator.acceptsheat = true

    MakeHugeFreezableCharacter(inst, "marker")
    ------------------
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.LEIF_HEALTH)

    ------------------

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.LEIF_DAMAGE)
    inst.components.combat.playerdamagepercent = TUNING.LEIF_DAMAGE_PLAYER_PERCENT
    inst.components.combat.hiteffectsymbol = "marker"
    inst.components.combat:SetRange(3)
    inst.components.combat:SetAttackPeriod(TUNING.LEIF_ATTACK_PERIOD)

    ------------------------------------------
    MakeHauntableIgnite(inst)
    ------------------------------------------

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)

    ------------------------------------------

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"livinglog", "livinglog", "livinglog", "livinglog", "livinglog", "livinglog", "monstermeat"})

    ------------------------------------------

    inst:AddComponent("inspectable")
    inst.components.inspectable:RecordViews()
    ------------------------------------------

    inst:SetBrain(brain)

    inst:ListenForEvent("attacked", OnAttacked)

    inst.SetLeifScale = SetLeifScale

    return inst
end

local function normal_fn()
    return common_fn("leif_build")
end

local function sparse_fn()
    return common_fn("leif_lumpy_build")
end

return Prefab("leif", normal_fn, assets, prefabs),
    Prefab("leif_sparse", sparse_fn, assets, prefabs)
