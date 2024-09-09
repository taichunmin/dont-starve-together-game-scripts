local assets =
{
    Asset("ANIM", "anim/tentacle_arm.zip"),
    Asset("ANIM", "anim/tentacle_arm_build.zip"),

    Asset("SOUND", "sound/tentacle.fsb"),
}

local prefabs =
{
    "monstermeat",
}

local ARM_SCALE = .95

local function IsAlive(guy)
    return not guy.components.health:IsDead()
end

local RETARGET_MUST_TAGS = { "_combat", "_health" }
local RETARGET_CANT_TAGS = { "tentacle_pillar_arm", "tentacle_pillar", "prey", "INLIMBO" }
local RETARGET_ONEOF_TAGS = { "character", "monster", "animal" }
local function retargetfn(inst)
    return FindEntity(inst,
            TUNING.TENTACLE_PILLAR_ARM_ATTACK_DIST,
            IsAlive,
            RETARGET_MUST_TAGS,-- see entityscript.lua
            RETARGET_CANT_TAGS,
            RETARGET_ONEOF_TAGS
        )
end

local function Emerge(inst)
    if inst.retracted then
        inst.retracted = false
        inst:PushEvent("emerge")
    end
end

local function Retract(inst)
    if not inst.retracted then
        inst.retracted = true
        inst:PushEvent("retract")
    end
end

local function OnFullRetreat(inst)
    if inst:IsAsleep() then
        inst:Remove()
    else
        inst.retreat = true
    end
end

local function OnEntitySleep(inst)
    if inst.retreat and inst.sleeptask == nil then
        inst.sleeptask = inst:DoTaskInTime(1, inst.Remove)
    end
end

local function OnEntityWake(inst)
    if inst.sleeptask ~= nil then
        inst.sleeptask:Cancel()
        inst.sleeptask = nil
    end
end

local function ShouldKeepTarget(inst, target)
    return target ~= nil
        and target:IsValid()
        and target.components.health ~= nil
        and not target.components.health:IsDead()
        and target:IsNear(inst, TUNING.TENTACLE_PILLAR_ARM_STOPATTACK_DIST)
end

local function OnHit(inst, attacker, damage)
    if attacker.components.combat and not attacker:HasTag("player") and math.random() > 0.5 then
        -- Followers should stop hitting the pillar
        attacker.components.combat:SetTarget(nil)
        if inst.components.health.currenthealth and inst.components.health.currenthealth < 0 then
            inst.components.health:DoDelta(damage*.6, false, attacker)
        end
    end
end

local function CustomOnHaunt(inst, haunter)
    if math.random() < TUNING.HAUNT_CHANCE_HALF and
        not inst.components.health:IsDead() then
        inst.components.health:Kill()
        return true
    end
    return false
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddPhysics()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Physics:SetCylinder(.6, 2)

    inst.Transform:SetScale(ARM_SCALE, ARM_SCALE, ARM_SCALE)

    inst.AnimState:SetBank("tentacle_arm")
    inst.AnimState:SetScale(ARM_SCALE, ARM_SCALE)
    inst.AnimState:SetBuild("tentacle_arm_build")
    inst.AnimState:PlayAnimation("breach_pre")
    inst.scrapbook_anim = "atk_idle"
    -- inst.AnimState:SetMultColour(.2, 1, .2, 1.0)

    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("tentacle_pillar_arm")
    inst:AddTag("wet")
    inst:AddTag("soulless")
    inst:AddTag("NPCcanaggro")

    inst.scrapbook_removedeps = {"monstermeat"}

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false -- don't need to save these

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.TENTACLE_PILLAR_ARM_HEALTH)

    inst:AddComponent("combat")
    inst.components.combat:SetRange(TUNING.TENTACLE_PILLAR_ARM_ATTACK_DIST)
    inst.components.combat:SetDefaultDamage(TUNING.TENTACLE_PILLAR_ARM_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.TENTACLE_PILLAR_ARM_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(GetRandomWithVariance(1, .5), retargetfn)
    inst.components.combat:SetKeepTargetFunction(ShouldKeepTarget)
    inst.components.combat:SetOnHit(OnHit)
    inst.components.combat:SetPlayerStunlock(PLAYERSTUNLOCK.OFTEN)

    MakeLargeFreezableCharacter(inst)

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(6, 15)
    inst.components.playerprox:SetOnPlayerNear(Emerge)
    inst.components.playerprox:SetOnPlayerFar(Retract)
    inst.components.playerprox:SetPlayerAliveMode(inst.components.playerprox.AliveModes.AliveOnly)

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

    inst:AddComponent("inspectable")

    inst:AddComponent("acidinfusible")
    inst.components.acidinfusible:SetFXLevel(1)
    inst.components.acidinfusible:SetMultipliers(TUNING.ACID_INFUSION_MULT.WEAKER)

    AddHauntableCustomReaction(inst, CustomOnHaunt)

    inst.retracted = true
    inst.Emerge = Emerge
    inst.Retract = Retract

    inst.sleeptask = nil
    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    inst:ListenForEvent("full_retreat", OnFullRetreat)

    inst:SetStateGraph("SGtentacle_arm")

    return inst
end

return Prefab("tentacle_pillar_arm", fn, assets, prefabs)
