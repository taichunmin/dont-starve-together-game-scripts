local assets =
{
    Asset("ANIM", "anim/ds_pig_basic.zip"),
    Asset("ANIM", "anim/ds_pig_actions.zip"),
    Asset("ANIM", "anim/ds_pig_attacks.zip"),
    Asset("ANIM", "anim/ds_pig_elite.zip"),
    Asset("ANIM", "anim/ds_pig_elite_intro.zip"),
    Asset("ANIM", "anim/pig_elite_build.zip"),
    Asset("ANIM", "anim/pig_guard_build.zip"),
    Asset("ANIM", "anim/slide_puff.zip"),
    Asset("SOUND", "sound/pig.fsb"),
}

local prefabs =
{
    "slide_puff",
}

local brain = require("brains/pigelitebrain")

local function ontalk(inst, script)
    inst.SoundEmitter:PlaySound((inst.sg:HasStateTag("intropose") or inst.sg:HasStateTag("endpose")) and "dontstarve/pig/attack" or "dontstarve/pig/grunt")
end

local TARGET_DIST_SQ = 20 * 20
local KEEP_TARGET_DIST_SQ = 24 * 24
local KING_TARGET_DIST = 12
local KING_KEEP_TARGET_DIST = 16

local function IsCombatTarget(inst, target)
    return inst.components.combat:TargetIs(target) and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
end

local function IsSquadAlreadyTargeting(inst, target, rangesq, checkfn)
    local x, y, z = target.Transform:GetWorldPosition()
    for k, v in pairs(inst.components.squadmember:GetOtherMembers()) do
        if checkfn(k, target) and k:GetDistanceSqToPoint(x, y, z) < rangesq and
            not (k.sg:HasStateTag("knockback") or
                k.components.health.takingfiredamage or
                k.components.hauntable.panic or
                k.components.sleeper:IsAsleep() or
                k.components.freezable:IsFrozen()) then
            return true
        end
    end
    return false
end

local function RetargetFn(inst)
    if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) == nil then
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local target = inst.components.combat.target
    if target ~= nil and not inst:IsSquadAlreadyTargeting(target, target:GetDistanceSqToPoint(x, y, z), IsCombatTarget) then
        return
    end

    local king = inst.components.entitytracker:GetEntity("king")
    local rangesq = TARGET_DIST_SQ
    local closestPlayer = nil
    for i, v in ipairs(AllPlayers) do
        if v ~= target and not IsEntityDeadOrGhost(v) and v.entity:IsVisible() then
            local distsq = v:GetDistanceSqToPoint(x, y, z)
            if distsq < rangesq and
                (king == nil or v:IsNear(king, KING_TARGET_DIST)) and
                inst.components.combat:CanTarget(v) and
                not inst:IsSquadAlreadyTargeting(v, distsq, IsCombatTarget) then
                rangesq = distsq
                closestPlayer = v
            end
        end
    end

    if closestPlayer == nil then
        inst.components.combat.keeptargettimeout = 0
        return
    end
    return closestPlayer, true
end

local function KeepTargetFn(inst, target)
    if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) == nil or not inst.components.combat:CanTarget(target) then
        return false
    end
    local distsq = inst:GetDistanceSqToInst(target)
    if distsq >= KEEP_TARGET_DIST_SQ then
        return false
    end
    local king = inst.components.entitytracker:GetEntity("king")
    if king ~= nil and not target:IsNear(king, KING_KEEP_TARGET_DIST) then
        return false
    end
    return not inst:IsSquadAlreadyTargeting(target, distsq, IsCombatTarget)
end

local function OnEquip(inst, data)
    if data ~= nil and data.eslot == EQUIPSLOTS.HANDS then
        inst.components.combat:SetTarget(RetargetFn(inst))
    end
end

local function OnUnequip(inst, data)
    if data ~= nil and data.eslot == EQUIPSLOTS.HANDS then
        inst.components.combat:SetTarget(nil)
    end
end

local function ShouldSleep()
    return false
end

local function ShouldWake()
    return true
end

local function RefreshSleeperExtraResist(inst)
    if (inst.components.sleeper.extraresist or 0) <= 5 then
        inst.components.sleeper:SetExtraResist(5)
    end
end

local function ClearCheatFlag(inst)
    inst.cheatflag = nil
end

local function SetCheatFlag(inst)
    if inst.cheatflag ~= nil then
        inst.cheatflag:Cancel()
    end
    inst.cheatflag = inst:DoTaskInTime(5, ClearCheatFlag)
end

local function WasCheated(inst)
    return inst.cheatflag ~= nil
        or inst.sg:HasStateTag("sleeping")
        or inst.components.freezable:IsFrozen()
        or inst.components.health.takingfiredamage
        or inst.components.hauntable.panic
end

--in order: blue, red, white, green
local BUILD_VARIATIONS =
{
    ["1"] = { "pig_ear", "pig_head", "pig_skirt", "pig_torso", "spin_bod" },
    ["2"] = { "pig_arm", "pig_ear", "pig_head", "pig_skirt", "pig_torso", "spin_bod" },
    ["3"] = { "pig_arm", "pig_ear", "pig_head", "pig_skirt", "pig_torso", "spin_bod" },
    ["4"] = { "pig_head", "pig_skirt", "pig_torso", "spin_bod" },
}

local function MakePigElite(variation)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddDynamicShadow()
        inst.entity:AddNetwork()

        inst:SetPhysicsRadiusOverride(.5)
        MakeCharacterPhysics(inst, 50, inst.physicsradiusoverride)

        inst.DynamicShadow:SetSize(1.5, .75)
        inst.Transform:SetFourFaced()

        inst:AddTag("character")
        inst:AddTag("pig")
        inst:AddTag("pigelite")
        inst:AddTag("scarytoprey")
        inst:AddTag("noepicmusic")
        inst:AddTag("minigame_participator")

        inst.AnimState:SetBank("pigman")
        inst.AnimState:SetBuild("pig_guard_build")
        inst.AnimState:AddOverrideBuild("slide_puff")
        inst.AnimState:PlayAnimation("idle_loop", true)
        inst.AnimState:Hide("hat")
        inst.AnimState:Hide("ARM_carry")
        inst.AnimState:Hide("ARM_carry_up")

        for i, v in ipairs(BUILD_VARIATIONS[variation]) do
            inst.AnimState:OverrideSymbol(v, "pig_elite_build", v.."_"..variation)
        end

        inst:AddComponent("talker")
        inst.components.talker.fontsize = 35
        inst.components.talker.font = TALKINGFONT
        --inst.components.talker.colour = Vector3(133/255, 140/255, 167/255)
        inst.components.talker.offset = Vector3(0, -400, 0)
        inst.components.talker:MakeChatter()

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.talker.ontalk = ontalk

        inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
        inst.components.locomotor.runspeed = TUNING.PIG_ELITE_RUN_SPEED
        inst.components.locomotor.walkspeed = TUNING.PIG_ELITE_WALK_SPEED

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(TUNING.PIG_GUARD_HEALTH)
        inst.components.health:SetAbsorptionAmount(1)

        inst:AddComponent("combat")
        inst.components.combat.hiteffectsymbol = "pig_torso"
        inst.components.combat:SetRange(.7, 2) --props add .5 range (TUNING.PROP_WEAPON_RANGE)
        inst.components.combat:SetDefaultDamage(0)
        inst.components.combat:SetAttackPeriod(0)
        inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
        inst.components.combat:SetRetargetFunction(1, RetargetFn)

        inst:AddComponent("minigame_participator")
        inst.components.minigame_participator.notimeout = true

        inst:AddComponent("squadmember")
        inst.components.squadmember:JoinSquad("pigkingelite4")

        MakeMediumBurnableCharacter(inst, "pig_torso")
        inst.components.burnable:SetBurnTime(6)

        MakeHauntablePanic(inst)

        inst:AddComponent("inspectable")

        inst:AddComponent("inventory")
        inst:AddComponent("knownlocations")
        inst:AddComponent("entitytracker")

        inst:AddComponent("sleeper")
        inst.components.sleeper:SetResistance(3)
        inst.components.sleeper:SetSleepTest(ShouldSleep)
        inst.components.sleeper:SetWakeTest(ShouldWake)
        inst.components.sleeper.diminishingreturns = true
        inst:DoPeriodicTask(5, RefreshSleeperExtraResist, 0)

        MakeMediumFreezableCharacter(inst, "pig_torso")
        inst.components.freezable:SetDefaultWearOffTime(4)
        inst.components.freezable.diminishingreturns = true

        inst.IsSquadAlreadyTargeting = IsSquadAlreadyTargeting

        inst.cheatflag = nil
        inst.SetCheatFlag = SetCheatFlag
        inst.WasCheated = WasCheated

        inst:SetBrain(brain)
        inst:SetStateGraph("SGpigelite")

        inst.sg.mem.variation = variation
        inst.sg.mem.radius = inst.physicsradiusoverride

        inst:ListenForEvent("equip", OnEquip)
        inst:ListenForEvent("unequip", OnUnequip)
        inst:ListenForEvent("onignite", SetCheatFlag)
        inst:ListenForEvent("teleported", SetCheatFlag)
        inst:ListenForEvent("rooted", SetCheatFlag)

        return inst
    end

    return Prefab("pigelite"..variation, fn, assets, prefabs)
end

--For searching: "pigelite1", "pigelite2", "pigelite3", "pigelite4"
return MakePigElite("1"),
    MakePigElite("2"),
    MakePigElite("3"),
    MakePigElite("4")
