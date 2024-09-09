local assets =
{
    Asset("ANIM", "anim/tentacle_arm.zip"),
    Asset("ANIM", "anim/tentacle_arm_black_build.zip"),
    Asset("SOUND", "sound/tentacle.fsb"),
}

local CAN_CHOOSE_TARGET_TAGS = {"animal", "character", "monster"}

local RETARGET_MUST_TAGS = { "_combat", "_health" }
local RETARGET_CANT_TAGS = { "minotaur" }
local function retargetfn(inst)
    return FindEntity(
        inst,
        TUNING.TENTACLE_ATTACK_DIST,
        function(guy)
            return guy.prefab ~= inst.prefab
                and not guy.components.health:IsDead()
                and (guy.components.combat.target == inst or
                    guy:HasOneOfTags(CAN_CHOOSE_TARGET_TAGS))
				and (guy:HasTag("player") or
					not (guy.sg and guy.sg:HasStateTag("hiding")))
        end,
        RETARGET_MUST_TAGS,
        RETARGET_CANT_TAGS)
end

local function shouldKeepTarget(inst, target)
    return target ~= nil
        and target:IsValid()
        and target.entity:IsVisible()
        and target.components.health ~= nil
        and not target.components.health:IsDead()
        and target:IsNear(inst, TUNING.TENTACLE_STOPATTACK_DIST)
		and (target:HasTag("player") or
			not (target.sg and target.sg:HasStateTag("hiding")))
end

local function testremove(inst)
    if inst.sg:HasStateTag("idle") then
        inst:PushEvent("leave")
    else
        inst:DoTaskInTime(30, testremove)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddPhysics()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Physics:SetCylinder(0.25, 2)

    inst.Transform:SetScale(1.3,1.3,1.3)

    inst.AnimState:SetMultColour(1, 1, 1, 0.5)

    inst.AnimState:SetBank("tentacle_arm")
    inst.AnimState:SetBuild("tentacle_arm_black_build")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("shadow")
    inst:AddTag("notarget")
    inst:AddTag("NOCLICK")
    inst:AddTag("shadow_aligned")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._last_attacker = nil
    inst._last_attacked_time = nil

    inst:AddComponent("combat")
    inst.components.combat:SetRange(TUNING.TENTACLE_ATTACK_DIST)
    inst.components.combat:SetDefaultDamage(TUNING.BIG_TENTACLE_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.TENTACLE_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(0.5, retargetfn)
    inst.components.combat:SetKeepTargetFunction(shouldKeepTarget)

    MakeLargeFreezableCharacter(inst)

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

    inst:AddComponent("inspectable")

    inst:SetStateGraph("SGbigshadowtentacle")

    inst:PushEvent("arrive")
    inst:DoTaskInTime(30, testremove)

    return inst
end

return Prefab("bigshadowtentacle", fn, assets)