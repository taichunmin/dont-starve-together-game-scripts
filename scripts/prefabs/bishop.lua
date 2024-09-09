local clockwork_common = require "prefabs/clockwork_common"
local RuinsRespawner = require "prefabs/ruinsrespawner"

local assets =
{
    Asset("ANIM", "anim/bishop.zip"),
    Asset("ANIM", "anim/bishop_build.zip"),
    Asset("ANIM", "anim/bishop_nightmare.zip"),
    Asset("SOUND", "sound/chess.fsb"),
    Asset("SCRIPT", "scripts/prefabs/clockwork_common.lua"),
    Asset("SCRIPT", "scripts/prefabs/ruinsrespawner.lua"),
}

local prefabs =
{
    "gears",
    "bishop_charge",
    "purplegem",
}

local prefabs_nightmare =
{
    "gears",
    "bishop_charge",
    "purplegem",
    "nightmarefuel",
    "thulecite_pieces",
    "bishop_nightmare_ruinsrespawner_inst",
}

local brain = require "brains/bishopbrain"

SetSharedLootTable("bishop",
{
    {"gears",       1.0},
    {"gears",       1.0},
    {"purplegem",   1.0},
})

SetSharedLootTable("bishop_nightmare",
{
    {"purplegem",         1.0},
    {"nightmarefuel",     0.6},
    {"thulecite_pieces",  0.5},
})

local function ShouldSleep(inst)
    return clockwork_common.ShouldSleep(inst)
end

local function ShouldWake(inst)
    return clockwork_common.ShouldWake(inst)
end

local function Retarget(inst)
    return clockwork_common.Retarget(inst, TUNING.BISHOP_TARGET_DIST)
end

local function KeepTarget(inst, target)
    return clockwork_common.KeepTarget(inst, target)
end

local function OnAttacked(inst, data)
    clockwork_common.OnAttacked(inst, data)
end

local function EquipWeapon(inst)
    if inst.components.inventory ~= nil and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
        local weapon = CreateEntity()
        --[[Non-networked entity]]
        weapon.entity:AddTransform()
        weapon:AddComponent("weapon")
        weapon.components.weapon:SetDamage(inst.components.combat.defaultdamage)
        weapon.components.weapon:SetRange(inst.components.combat.attackrange, inst.components.combat.attackrange+4)
        weapon.components.weapon:SetProjectile("bishop_charge")
        weapon:AddComponent("inventoryitem")
        weapon.persists = false
        weapon.components.inventoryitem:SetOnDroppedFn(inst.Remove)
        weapon:AddComponent("equippable")
        weapon:AddTag("nosteal")

        inst.components.inventory:Equip(weapon)
    end
end

local function SetHomePosition(inst)
    inst.components.knownlocations:RememberLocation("home", inst:GetPosition())
end

local function common_fn(build, tag)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 50, .5)

    inst.DynamicShadow:SetSize(1.5, .75)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("bishop")
    inst.AnimState:SetBuild(build)

    inst:AddTag("bishop")
    inst:AddTag("chess")
    inst:AddTag("hostile")
    inst:AddTag("monster")

    if tag then
        inst:AddTag(tag)
    end

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    --
    local combat = inst:AddComponent("combat")
    combat.hiteffectsymbol = "waist"
    combat:SetAttackPeriod(TUNING.BISHOP_ATTACK_PERIOD)
    combat:SetDefaultDamage(TUNING.BISHOP_DAMAGE)
    combat:SetRetargetFunction(3, Retarget)
    combat:SetKeepTargetFunction(KeepTarget)
    combat:SetRange(TUNING.BISHOP_ATTACK_DIST)

    --
    inst:AddComponent("follower")

    --
    local health = inst:AddComponent("health")
    health:SetMaxHealth(TUNING.BISHOP_HEALTH)

    --
    inst:AddComponent("inspectable")

    --
    inst:AddComponent("inventory")

    --
    inst:AddComponent("knownlocations")

    --
    local locomotor = inst:AddComponent("locomotor")
    locomotor.walkspeed = TUNING.BISHOP_WALK_SPEED

    --
    inst:AddComponent("lootdropper")

    --
    local sleeper = inst:AddComponent("sleeper")
    sleeper:SetWakeTest(ShouldWake)
    sleeper:SetSleepTest(ShouldSleep)
    sleeper:SetResistance(3)

    --
    MakeMediumBurnableCharacter(inst, "waist")
    MakeMediumFreezableCharacter(inst, "waist")

    --
    MakeHauntablePanic(inst)

    --
    inst:SetStateGraph("SGbishop")
    inst:SetBrain(brain)

    --
    inst:DoTaskInTime(0, SetHomePosition)

    --
    inst:ListenForEvent("attacked", OnAttacked)

    --
    EquipWeapon(inst)

    return inst
end

local function bishop_fn()
    local inst = common_fn("bishop_build")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.lootdropper:SetChanceLootTable("bishop")
    inst.kind = ""
    inst.soundpath = "dontstarve/creatures/bishop/"
    inst.effortsound = "dontstarve/creatures/bishop/idle"

    return inst
end

local function bishop_nightmare_fn()
    local inst = common_fn("bishop_nightmare", "cavedweller")

    inst:AddTag("shadow_aligned")

    if not TheWorld.ismastersim then
        return inst
    end

    --
    local acidinfusible = inst:AddComponent("acidinfusible")
    acidinfusible:SetFXLevel(3)
    acidinfusible:SetMultipliers(TUNING.ACID_INFUSION_MULT.WEAKER)

    --
    inst.components.lootdropper:SetChanceLootTable("bishop_nightmare")
    inst.kind = "_nightmare"
    inst.soundpath = "dontstarve/creatures/bishop_nightmare/"
    inst.effortsound = "dontstarve/creatures/bishop_nightmare/rattle"

    return inst
end

local function onruinsrespawn(inst, respawner)
	if not respawner:IsAsleep() then
		inst.sg:GoToState("ruinsrespawn")
	end
end

return Prefab("bishop", bishop_fn, assets, prefabs),
    Prefab("bishop_nightmare", bishop_nightmare_fn, assets, prefabs_nightmare),
    RuinsRespawner.Inst("bishop_nightmare", onruinsrespawn), RuinsRespawner.WorldGen("bishop_nightmare", onruinsrespawn)
