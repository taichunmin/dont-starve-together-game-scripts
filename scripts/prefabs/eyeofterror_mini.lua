local assets =
{
    Asset("ANIM", "anim/eyeofterror_mini_actions.zip"),
    Asset("ANIM", "anim/eyeofterror_mini_basic.zip"),
    Asset("ANIM", "anim/eyeofterror_mini_mob_build.zip"),
    Asset("SOUND", "sound/bee.fsb"),
}

local prefabs = nil

local creature_sounds =
{
    hit = "terraria1/mini_eyeofterror/hit",
    death = "terraria1/mini_eyeofterror/death",
}

local minieyebrain = require("brains/eyeofterror_minibrain")

local function FocusTarget(inst, target)
    inst._focustarget = target
    inst:AddTag("notaunt")

    inst.components.combat:SetTarget(target)
end

local function OnWake(inst)
end

local function OnSleep(inst)
end

local function CheckFocusTarget(inst)
    if inst._focustarget ~= nil and (
                not inst._focustarget:IsValid()
                or (inst._focustarget.components.health ~= nil and
                    inst._focustarget.components.health:IsDead()
                ) or inst._focustarget:HasTag("playerghost")
            ) then
        -- Our focus target isn't a good target anymore; let's clean it up.
        inst._focustarget = nil
        inst:RemoveTag("notaunt")
    end

    return inst._focustarget
end

local RETARGET_DIST = 12
local RETARGET_MUST_TAGS = { "_combat", "_health" }
local RETARGET_CANT_TAGS = { "DECOR", "eyeofterror", "FX", "INLIMBO", "NOCLICK", "notarget", "playerghost", "wall" }
local function Retarget(inst)
    -- Keep on our focus target if we have one, otherwise do a search.
    local ftarget = CheckFocusTarget(inst)
    if ftarget ~= nil then
        return ftarget, not inst.components.combat:TargetIs(ftarget)
    else
        return FindEntity(inst,
                RETARGET_DIST,
                function(guy)
                    return inst.components.combat:CanTarget(guy)
                end,
                RETARGET_MUST_TAGS,
                RETARGET_CANT_TAGS
            ) or nil
    end
end

local KEEPTARGET_DIST = 30
local function KeepTarget(inst, target)
    local ftarget = CheckFocusTarget(inst)
    return (ftarget ~= nil and inst.components.combat:TargetIs(ftarget))
        or (inst.components.combat:CanTarget(target) and inst:IsNear(target, KEEPTARGET_DIST))
end

local function OnAttacked(inst, data)
    local ftarget = CheckFocusTarget(inst)
    if ftarget == nil and (data.attacker ~= nil and not data.attacker:HasTag("eyeofterror")) then
        inst.components.combat:SetTarget(data.attacker)
    end
end

local DIET = { FOODTYPE.MEAT }
local function commonfn(build, tags)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeFlyingCharacterPhysics(inst, 1, .5)

    inst.DynamicShadow:SetSize(.8, .5)
    inst.Transform:SetSixFaced()

    inst:AddTag("eyeofterror")
    inst:AddTag("flying")
    inst:AddTag("hostile")
    inst:AddTag("ignorewalkableplatformdrowning")
    inst:AddTag("monster")
    inst:AddTag("smallcreature")

    inst.AnimState:SetBank("eyeofterror_mini")
    inst.AnimState:SetBuild("eyeofterror_mini_mob_build")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetRayTestOnBB(true)

    MakeInventoryFloatable(inst, "med", 0.1, 0.75)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    ---------------------
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 4
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)

    ---------------------
    inst:AddComponent("lootdropper")

    ------------------
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.EYEOFTERROR_MINI_HEALTH)

    ------------------
    inst:AddComponent("combat")
    inst.components.combat:SetRange(TUNING.EYEOFTERROR_MINI_ATTACK_RANGE, TUNING.EYEOFTERROR_MINI_HIT_RANGE)
    inst.components.combat.hiteffectsymbol = "glomling_body"
    inst.components.combat:SetDefaultDamage(TUNING.EYEOFTERROR_MINI_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.EYEOFTERROR_MINI_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(2, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetHurtSound(creature_sounds.hit)

    ------------------
    inst:AddComponent("sleeper")

    ------------------
    inst:AddComponent("knownlocations")

    ------------------
    inst:AddComponent("inspectable")

    ------------------
    inst:AddComponent("eater")
    inst.components.eater:SetDiet(DIET, DIET)
    inst.components.eater:SetCanEatHorrible()
    inst.components.eater:SetStrongStomach(true)

    ------------------
    MakeSmallBurnableCharacter(inst, "glomling_body")
    MakeTinyFreezableCharacter(inst, "glomling_body")

    ------------------
    MakeHauntable(inst)
    inst.components.hauntable.panicable = true

    ------------------
    inst:SetStateGraph("SGeyeofterror_mini")
    inst:SetBrain(minieyebrain)
    inst.sounds = creature_sounds

    inst:ListenForEvent("attacked", OnAttacked)

    inst.FocusTarget = FocusTarget

    inst.OnEntityWake = OnWake
    inst.OnEntitySleep = OnSleep

    return inst
end

return Prefab("eyeofterror_mini", commonfn, assets, prefabs)
