local assets =
{
    Asset("ANIM", "anim/shadow_channeler.zip"),
}

local function CalcSanityAura(inst, observer)
    return observer.components.sanity:IsCrazy()
        and -TUNING.SANITYAURA_MED
        or 0
end

local function KeepTargetFn()
    return false
end

local function OnAppear(inst)
    inst:RemoveEventCallback("animover", OnAppear)
    if not inst.killed then
        inst:RemoveTag("notarget")
        inst.components.health:SetInvincible(false)
        inst.AnimState:PlayAnimation("idle", true)
    end
end

local function OnDeath(inst)
    if not inst.killed then
        inst.killed = true

        inst:AddTag("NOCLICK")
        inst.persists = false

        inst:RemoveEventCallback("animover", OnAppear)
        inst:RemoveEventCallback("death", OnDeath)

        inst:ListenForEvent("animover", inst.Remove)
        inst.AnimState:PlayAnimation("disappear")

        inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + FRAMES, inst.Remove)
    end
end

local function OnGotCommander(inst, data)
    local stalker = inst.components.entitytracker:GetEntity("stalker")
    if stalker ~= data.commander then
        inst.components.entitytracker:ForgetEntity("stalker")
        inst.components.entitytracker:TrackEntity("stalker", data.commander)
    end
end

local function OnLostCommander(inst, data)
    local stalker = inst.components.entitytracker:GetEntity("stalker")
    if stalker == data.commander then
        inst.components.entitytracker:ForgetEntity("stalker")
    end
end

local function OnLoadPostPass(inst)
    local stalker = inst.components.entitytracker:GetEntity("stalker")
    if stalker ~= nil and stalker.components.commander ~= nil then
        stalker.components.commander:AddSoldier(inst)
    end
end

local function nodebrisdmg(inst, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
    return afflicter ~= nil and afflicter:HasTag("quakedebris")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .2)
    RemovePhysicsColliders(inst)
    inst.Physics:SetCollisionGroup(COLLISION.SANITY)
    inst.Physics:CollidesWith(COLLISION.SANITY)

    inst.Transform:SetTwoFaced()

    inst:AddTag("shadowcreature")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("shadow")
    inst:AddTag("notraptrigger")
    inst:AddTag("notarget")
    inst:AddTag("shadow_aligned")

    inst.AnimState:SetBank("shadow_channeler")
    inst.AnimState:SetBuild("shadow_channeler")
    inst.AnimState:PlayAnimation("appear")
    inst.AnimState:SetMultColour(1, 1, 1, .5)

    if not TheNet:IsDedicated() then
        -- this is purely view related
        inst:AddComponent("transparentonsanity")
        inst.components.transparentonsanity.most_alpha = .8
        inst.components.transparentonsanity.osc_amp = .1
        inst.components.transparentonsanity:ForceUpdate()
    end

	--Higher priority as if it is always targeting player
	inst.controller_priority_override_is_targeting_player = true

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(1)
    inst.components.health:SetInvincible(true)
    inst.components.health.nofadeout = true
    inst.components.health.redirect = nodebrisdmg

    inst:AddComponent("combat")
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)

    inst:AddComponent("savedrotation")
    inst:AddComponent("entitytracker")

    inst:ListenForEvent("gotcommander", OnGotCommander)
    inst:ListenForEvent("lostcommander", OnLostCommander)
    inst:ListenForEvent("animover", OnAppear)
    inst:ListenForEvent("death", OnDeath)

    inst.OnLoad = OnAppear
    inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

return Prefab("shadowchanneler", fn, assets)
