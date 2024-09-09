require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/brightmare_gestalt.zip"),
}

local prefabs =
{
	"gestalt_head",
	"gestalt_trail",
}

local assets_trail =
{
    Asset("ANIM", "anim/brightmare_gestalt_trail.zip"),
}

local brain = require "brains/brightmare_gestaltbrain"

local function SetHeadAlpha(inst, a)
	if inst.blobhead then
		inst.blobhead.AnimState:OverrideMultColour(1, 1, 1, a)
	end
end

local function Client_CalcSanityForTransparency(inst, observer)
	if inst.components.inspectable ~= nil then
		return TUNING.GESTALT_COMBAT_TRANSPERENCY
	end

	local x = (observer ~= nil and observer.replica.sanity ~= nil) and (observer.replica.sanity:GetPercentWithPenalty() - TUNING.GESTALT_MIN_SANITY_TO_SPAWN) / (1 - TUNING.GESTALT_MIN_SANITY_TO_SPAWN) or 0
	return math.min(0.5, 0.4*x*x*x + 0.3)
end

local function FindRelocatePoint(inst)
	return TheWorld.components.brightmarespawner:FindRelocatePoint(inst) or nil
end

local function SetTrackingTarget(inst, target, behaviour_level)
	local prev_target = inst.tracking_target
	inst.tracking_target = target
	inst.behaviour_level = behaviour_level
	if prev_target ~= inst.tracking_target then
		if inst.OnTrackingTargetRemoved ~= nil then
			inst:RemoveEventCallback("onremove", inst.OnTrackingTargetRemoved, prev_target)
			inst:RemoveEventCallback("death", inst.OnTrackingTargetRemoved, prev_target)
			inst.OnTrackingTargetRemoved = nil
		end
		if inst.tracking_target ~= nil then
			inst.OnTrackingTargetRemoved = function(target) inst.tracking_target = nil end
			inst:ListenForEvent("onremove", inst.OnTrackingTargetRemoved, inst.tracking_target)
			inst:ListenForEvent("death", inst.OnTrackingTargetRemoved, inst.tracking_target)
		end
	end
end

local function UpdateBestTrackingTarget(inst)
	local target, behaviour_level = TheWorld.components.brightmarespawner:FindBestPlayer(inst)
	SetTrackingTarget(inst, target, behaviour_level)
end

local function Retarget(inst)
    -- If we don't have a tracking target, are in combat cooldown, or are too far away, no target.
    if inst.tracking_target == nil
            or inst.components.combat:InCooldown()
            or not inst:IsNear(inst.tracking_target, TUNING.GESTALT_AGGRESSIVE_RANGE) then
        return nil
    end

    -- If our potential target is sleeping, don't target them.
    local sleeping = inst.tracking_target.sg:HasStateTag("knockout")
        or inst.tracking_target.sg:HasStateTag("sleeping")
        or inst.tracking_target.sg:HasStateTag("bedroll")
        or inst.tracking_target.sg:HasStateTag("tent")
        or inst.tracking_target.sg:HasStateTag("waking")
    if sleeping then
        return nil
    end

    -- If our potential target has a gestalt item, don't target them.
    local target_inventory = inst.tracking_target.components.inventory
    if target_inventory ~= nil and target_inventory:EquipHasTag("gestaltprotection") then
        return nil
    end

    return inst.tracking_target
end

local function OnNewCombatTarget(inst, data)
	if inst.components.inspectable == nil then
		inst:AddComponent("inspectable")
		inst:AddTag("scarytoprey")
	end
end

local function OnNoCombatTarget(inst)
	inst.components.combat:RestartCooldown()
	inst:RemoveComponent("inspectable")
	inst:RemoveTag("scarytoprey")
end

local function fn()
    local inst = CreateEntity()

    --Core components
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    --Initialize physics
    local phys = inst.entity:AddPhysics()
    phys:SetMass(1)
    phys:SetFriction(0)
    phys:SetDamping(5)
    phys:SetCollisionGroup(COLLISION.FLYERS)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.GROUND)
    phys:SetCapsule(0.5, 1)

	inst:AddTag("brightmare")
	inst:AddTag("brightmare_gestalt")
	inst:AddTag("NOBLOCK")
	inst:AddTag("lunar_aligned")

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBuild("brightmare_gestalt")
    inst.AnimState:SetBank("brightmare_gestalt")
    inst.AnimState:PlayAnimation("idle", true)

	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst._level = net_tinybyte(inst.GUID, "gestalt.level", "leveldirty")
    inst._level:set(1)

	if not TheNet:IsDedicated() then
		inst.blobhead = SpawnPrefab("gestalt_head")
		inst.blobhead.entity:SetParent(inst.entity) --prevent 1st frame sleep on clients
		inst.blobhead.Follower:FollowSymbol(inst.GUID, "head_fx", 0, 0, 0)

		inst.blobhead.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

	    inst.highlightchildren = { inst.blobhead }

		-- this is purely view related
		inst:AddComponent("transparentonsanity")
		inst.components.transparentonsanity.most_alpha = .2
		inst.components.transparentonsanity.osc_amp = .05
		inst.components.transparentonsanity.osc_speed = 5.25 + math.random() * 0.5
		inst.components.transparentonsanity.calc_percent_fn = Client_CalcSanityForTransparency
		inst.components.transparentonsanity.onalphachangedfn = SetHeadAlpha
		inst.components.transparentonsanity:ForceUpdate()
	end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.persists = false

	inst.tracking_target = nil
	inst.behaviour_level = 1
	inst.FindRelocatePoint = FindRelocatePoint
	inst.SetTrackingTarget = SetTrackingTarget
	inst:DoPeriodicTask(0.1, UpdateBestTrackingTarget, 0)

    inst:AddComponent("sanityaura")
	inst.components.sanityaura.aura = TUNING.SANITYAURA_MED

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = TUNING.GESTALT_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.GESTALT_WALK_SPEED
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = true }

	inst:AddComponent("combat")
	inst.components.combat:SetDefaultDamage(0)
	inst.components.combat:SetAttackPeriod(TUNING.GESTALT_ATTACK_COOLDOWN)
	inst.components.combat:SetRange(TUNING.GESTALT_ATTACK_RANGE)
    inst.components.combat:SetRetargetFunction(1, Retarget)
	inst:ListenForEvent("newcombattarget", OnNewCombatTarget)
	inst:ListenForEvent("droppedtarget", OnNoCombatTarget)
	inst:ListenForEvent("losttarget", OnNoCombatTarget)

    inst:SetStateGraph("SGbrightmare_gestalt")
    inst:SetBrain(brain)

    return inst
end

local function gestalt_trail_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.AnimState:SetBank("brightmare_gestalt_trail")
    inst.AnimState:SetBuild("brightmare_gestalt_trail")
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetSortOrder(2)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:PlayAnimation("trail1")

	inst.Transform:SetScale(1.2, 1.2, 1.2)

	if not TheNet:IsDedicated() then
		-- this is purely view related
		inst:AddComponent("transparentonsanity")
		inst.components.transparentonsanity.most_alpha = .2
		inst.components.transparentonsanity.osc_amp = .05
		inst.components.transparentonsanity.osc_speed = 5.25 + math.random() * 0.5
		inst.components.transparentonsanity.calc_percent_fn = Client_CalcSanityForTransparency
		inst.components.transparentonsanity:ForceUpdate()
	end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	local anim = math.random(8)
	if anim > 1 then
	    inst.AnimState:PlayAnimation("trail"..anim)
	end

    inst.persists = false
    inst:DoTaskInTime(40 * FRAMES, inst.Remove)

    return inst
end

return Prefab("gestalt", fn, assets, prefabs),
	Prefab("gestalt_trail", gestalt_trail_fn, assets_trail)
