local clockwork_common = require "prefabs/clockwork_common"
local RuinsRespawner = require "prefabs/ruinsrespawner"

local assets =
{
    Asset("ANIM", "anim/knight.zip"),
    Asset("ANIM", "anim/knight_build.zip"),
    Asset("ANIM", "anim/knight_nightmare.zip"),
    Asset("SOUND", "sound/chess.fsb"),
    Asset("SCRIPT", "scripts/prefabs/clockwork_common.lua"),
    Asset("SCRIPT", "scripts/prefabs/ruinsrespawner.lua"),
}

local prefabs =
{
    "gears",
}

local prefabs_nightmare =
{
    "gears",
    "thulecite_pieces",
    "nightmarefuel",
    "knight_nightmare_ruinsrespawner_inst",
}

local brain = require "brains/knightbrain"

SetSharedLootTable('knight',
{
    {'gears',  1.0},
    {'gears',  1.0},
})

SetSharedLootTable('knight_nightmare',
{
    {'gears',             1.0},
    {'nightmarefuel',     0.6},
    {'thulecite_pieces',  0.5},
})

local function ShouldSleep(inst)
    return clockwork_common.ShouldSleep(inst)
end

local function ShouldWake(inst)
    return clockwork_common.ShouldWake(inst)
end

local function Retarget(inst)
    return clockwork_common.Retarget(inst, TUNING.KNIGHT_TARGET_DIST)
end

local function KeepTarget(inst, target)
    return clockwork_common.KeepTarget(inst, target)
end

local function OnAttacked(inst, data)
    clockwork_common.OnAttacked(inst, data)
end

local function RememberKnownLocation(inst)
    inst.components.knownlocations:RememberLocation("home", inst:GetPosition())
end

local function fn_common(build, tag)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 50, .5)

    inst.DynamicShadow:SetSize(1.5, .75)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("knight")
    inst.AnimState:SetBuild(build)

    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("chess")
    inst:AddTag("knight")

    if tag ~= nil then
        inst:AddTag(tag)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.kind = ""

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.KNIGHT_WALK_SPEED

    inst:SetStateGraph("SGknight")

    inst:SetBrain(brain)

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetWakeTest(ShouldWake)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetResistance(3)

    inst:AddComponent("health")
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "spring"
    inst.components.combat:SetAttackPeriod(TUNING.KNIGHT_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(3, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)

    inst.components.health:SetMaxHealth(TUNING.KNIGHT_HEALTH)
    inst.components.combat:SetDefaultDamage(TUNING.KNIGHT_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.KNIGHT_ATTACK_PERIOD)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('knight')

    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")

    inst:DoTaskInTime(0, RememberKnownLocation)

    inst:AddComponent("follower")

    MakeMediumBurnableCharacter(inst, "spring")
    MakeMediumFreezableCharacter(inst, "spring")

    MakeHauntablePanic(inst)

    inst:ListenForEvent("attacked", OnAttacked)

    return inst
end

local function fn()
    local inst = fn_common("knight_build")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.kind = ""

    return inst
end

local function nightmarefn()
    local inst = fn_common("knight_nightmare", "cavedweller")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.kind = "_nightmare"
    inst.components.lootdropper:SetChanceLootTable("knight_nightmare")
    return inst
end

local function onruinsrespawn(inst, respawner)
	if not respawner:IsAsleep() then
		inst.sg:GoToState("ruinsrespawn")
	end
end

return Prefab("knight", fn, assets, prefabs),
    Prefab("knight_nightmare", nightmarefn, assets, prefabs_nightmare),
    RuinsRespawner.Inst("knight_nightmare", onruinsrespawn), RuinsRespawner.WorldGen("knight_nightmare", onruinsrespawn)
