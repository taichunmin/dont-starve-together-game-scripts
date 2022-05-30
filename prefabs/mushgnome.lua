local brain = require "brains/mushgnomebrain"

local assets =
{
    Asset("ANIM", "anim/grotto_mushgnome.zip"),
    Asset("SOUND", "sound/leif.fsb"),
}

local prefabs =
{
    "character_fire",
    "livinglog",
    "log",
    "spore_moon",
    "spore_moon_coughout",
    "moon_cap",
}

SetSharedLootTable("mushgnome",
{
    {"livinglog",   1.0},
    {"livinglog",   0.5},
    {"spore_moon",  1.0},
    {"spore_moon",  1.0},
    {"spore_moon",  1.0},
    {"spore_moon",  0.5},
    {"spore_moon",  0.5},
    {"moon_cap",   1.0},
    {"moon_cap",   1.0},
})

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
    if inst.components.sleeper:IsAsleep() then
        data.sleeping = true
        data.sleep_time = inst.components.sleeper.testtime
    end

    if inst.components.sleeper:IsHibernating() then
        data.hibernate = true
    end
end

local function CalcSanityAura(inst)
    return inst.components.combat.target ~= nil and -TUNING.SANITYAURA_MED or -TUNING.SANITYAURA_SMALL
end

local function OnBurnt(inst)
    if inst.components.propagator and inst.components.health and not inst.components.health:IsDead() then
        inst.components.propagator.acceptsheat = true
    end
end

local function onspawnfn(inst, spawn)
    inst.SoundEmitter:PlaySound("dontstarve/cave/mushtree_tall_spore_fart")

    local pos = inst:GetPosition()

    local offset = FindWalkableOffset(
        pos,
        math.random() * 2 * PI,
        spawn:GetPhysicsRadius(0) + inst:GetPhysicsRadius(0),
        8
    )
    local off_x = (offset and offset.x) or 0
    local off_z = (offset and offset.z) or 0
    spawn.Transform:SetPosition(pos.x + off_x, 0, pos.z + off_z)
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
end

local COLOUR_R, COLOUR_G, COLOUR_B = 227/255, 227/255, 227/255
local function normal_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 1000, .5)

    inst.DynamicShadow:SetSize(4, 1.5)

    inst.Transform:SetFourFaced()

    inst.Light:SetColour(COLOUR_R, COLOUR_G, COLOUR_B)
    inst.Light:SetIntensity(0.75)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetRadius(0.6)

    inst:AddTag("leif")
    inst:AddTag("monster")
    inst:AddTag("tree")

    inst.AnimState:SetBank("grotto_mushgnome")
    inst.AnimState:SetBuild("grotto_mushgnome")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    local color = .5 + math.random() * .5
    inst.AnimState:SetMultColour(color, color, color, 1)

    ------------------------------------------

    inst.OnLoad = onloadfn
    inst.OnSave = onsavefn

    ------------------------------------------

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 2.0

    ------------------------------------------
    inst:SetStateGraph("SGmushgnome")

    ------------------------------------------

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

    MakeMediumBurnableCharacter(inst, "body")
    inst.components.burnable.flammability = TUNING.LEIF_FLAMMABILITY
    inst.components.burnable:SetOnBurntFn(OnBurnt)
    inst.components.propagator.acceptsheat = true

    MakeMediumFreezableCharacter(inst, "body")

    ------------------
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.MUSHGNOME_HEALTH)

    ------------------

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.LEIF_DAMAGE)
    inst.components.combat.playerdamagepercent = TUNING.LEIF_DAMAGE_PLAYER_PERCENT
    inst.components.combat:SetAttackPeriod(TUNING.MUSHGNOME_ATTACK_PERIOD)
    inst.components.combat.hiteffectsymbol = "body"

    -- Set a high range so that we appear to be "proactively" attacking things
    inst.components.combat:SetRange(15)

    ------------------------------------------
    MakeHauntableIgnite(inst)
    ------------------------------------------

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)

    ------------------------------------------

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("mushgnome")

    ------------------------------------------

    inst:AddComponent("inspectable")

    ------------------------------------------

    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetPrefab("spore_moon")
    inst.components.periodicspawner:SetOnSpawnFn(onspawnfn)
    inst.components.periodicspawner:SetDensityInRange(TUNING.MUSHSPORE_MAX_DENSITY_RAD, TUNING.MUSHSPORE_MAX_DENSITY)
    inst.components.periodicspawner:SetRandomTimes(TUNING.MUSHGNOME_SPORESPAWN_MIN, TUNING.MUSHGNOME_SPORESPAWN_MAX)
    inst.components.periodicspawner:Start()

    ------------------------------------------

    inst:SetBrain(brain)

    inst:ListenForEvent("attacked", OnAttacked)

    return inst
end

return Prefab("mushgnome", normal_fn, assets, prefabs)
