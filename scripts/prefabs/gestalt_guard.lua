require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/brightmare_gestalt_evolved.zip"),
}

local prefabs =
{
	"gestalt_head",
	"gestalt_guard_head",
}

local brain = require "brains/brightmare_gestaltguardbrain"

local function SetHeadAlpha(inst, a)
	if inst.blobhead then
		inst.blobhead.AnimState:OverrideMultColour(1, 1, 1, a)
	end
end

local shadow_tags = {"nightmarecreature", "shadowcreature", "shadow", "shadowminion", "stalker", "stalkerminion", "nightmare", "shadow_fire"}

local attack_any_tags = ConcatArrays({"player","gestalt_possessable"}, shadow_tags)
local watch_must_tags = {"player"}


local function FindRelocatePoint(inst)
	-- if dist from home point is too far, then use home point
	local pt = inst:GetPosition()
	local home_pt = inst.components.knownlocations:GetLocation("spawnpoint")
	if home_pt ~= nil and distsq(pt.x, pt.z, home_pt.x, home_pt.z) >= TUNING.GESTALTGUARD_MAX_DISTSQ_FROM_SPAWN_PT then
		pt = home_pt
	end

    local theta = math.random() * TWOPI
	local offset = FindWalkableOffset(pt, theta, 10+math.random()*3, 16, true, true)
					or FindWalkableOffset(pt, theta, 6+math.random()*3, 12, true, true)
					or FindWalkableOffset(pt, theta, 3+math.random()*3, 12, true, true)

	return offset ~= nil and (offset + pt) or pt
end

local function GetLevelForTarget(target)
	-- L1: 0.5 to 1.0 is ignore
	-- L2: 0.0 to 0.5 is look at behaviour
	-- L3: shadow target, attack it!

	if target ~= nil then
		if target:HasTag("gestalt_possessable") then
			return 3, 0
		end

		local inventory = target.replica.inventory
		if inventory ~= nil and inventory:EquipHasTag("shadow_item") then
			return 3, 0
		end

		local sanity_rep = target.replica.sanity
		if sanity_rep ~= nil then
			local sanity = sanity_rep:GetPercentWithPenalty() or 0
			local level = sanity > 0.33 and 1
					or 2
			return level, sanity
		end

		for i = 1, #shadow_tags do
			if target:HasTag(shadow_tags[i]) then
				return 3, 0
			end
		end
	end

	return 1, 1
end

local function Client_CalcTransparencyRating(inst, observer)
	if inst.components.inspectable ~= nil then
		return TUNING.GESTALT_COMBAT_TRANSPERENCY -- 0.85
	end

	local level, sanity = GetLevelForTarget(observer)
	if level >= 3 then
		return TUNING.GESTALT_COMBAT_TRANSPERENCY -- 0.85
	end

	local x = (.7*sanity - .7)
	return math.min(x*x + .2, TUNING.GESTALT_COMBAT_TRANSPERENCY)
end

local function Retarget(inst)
	local targets_level = 1
	local function attacktargetcheck(target)
        if target.components.inventory ~= nil and target.components.inventory:EquipHasTag("gestaltprotection") then
            return false
        end
		targets_level = GetLevelForTarget(target)
		return targets_level == 3
	end
	local function watchtargetcheck(target)
        if target.components.inventory ~= nil and target.components.inventory:EquipHasTag("gestaltprotection") then
            return false
        end
		targets_level = GetLevelForTarget(target)
		return targets_level == 2
	end

	local target = FindEntity(inst, TUNING.GESTALTGUARD_AGGRESSIVE_RANGE, attacktargetcheck, nil, nil, attack_any_tags)
					or FindEntity(inst, TUNING.GESTALTGUARD_WATCHING_RANGE, watchtargetcheck, watch_must_tags)

	if target == nil and inst.components.combat.target ~= nil then
		inst.components.combat:DropTarget()
	elseif target == inst.components.combat.target then
		inst.behaviour_level = target ~= nil and targets_level or 1
	end

	return target, target ~= inst.components.combat.target
end

local function OnNewCombatTarget(inst, data)
	inst.behaviour_level = GetLevelForTarget(data.target)

	if inst.components.inspectable == nil then
		inst:AddComponent("inspectable")
		inst:AddTag("scarytoprey")
	end
end

local function OnNoCombatTarget(inst)
	inst.components.combat:RestartCooldown()
	inst.behaviour_level = 0
	inst:RemoveComponent("inspectable")
	inst:RemoveTag("scarytoprey")
end

local function onattackother(inst, data)
	local target = data ~= nil and data.target or nil

	local burnable = target:IsValid() and target.components.burnable or nil
    if burnable ~= nil and burnable:IsBurning() and target:HasTag("shadow_fire") then
        burnable:Extinguish()
    end
end

local function onkilledtarget(inst, data)
	local target = data ~= nil and data.victim or nil

	local lootdropper = target:IsValid() and target:HasTag("gestaltnoloot") and target.components.lootdropper or nil
	if lootdropper ~= nil then
		lootdropper:SetLoot({})
		lootdropper:SetChanceLootTable(nil)
	end
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
	inst:AddTag("brightmare_guard")
	inst:AddTag("crazy") -- so they can attack shadow creatures
	inst:AddTag("NOBLOCK")
	inst:AddTag("extinguisher") -- to put out nightlights
	inst:AddTag("soulless") -- no wortox souls
	inst:AddTag("lunar_aligned")

    inst.Transform:SetFourFaced()
    inst.Transform:SetScale(0.8, 0.8, 0.8)

    inst.AnimState:SetBuild("brightmare_gestalt_evolved")
    inst.AnimState:SetBank("brightmare_gestalt_evolved")
    inst.AnimState:PlayAnimation("idle", true)

	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst._level = net_tinybyte(inst.GUID, "gestalt.level", "leveldirty")
    inst._level:set(1)

	if not TheNet:IsDedicated() then
		inst.blobhead = SpawnPrefab("gestalt_guard_head")
		inst.blobhead.entity:SetParent(inst.entity) --prevent 1st frame sleep on clients
		inst.blobhead.Follower:FollowSymbol(inst.GUID, "brightmare_gestalt_head_evolved", 0, 0, 0)

		inst.blobhead.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
		inst.blobhead.persists = false

	    inst.highlightchildren = { inst.blobhead }

		-- this is purely view related
		inst:AddComponent("transparentonsanity")
		inst.components.transparentonsanity.most_alpha = .4
		inst.components.transparentonsanity.osc_amp = .05
		inst.components.transparentonsanity.osc_speed = 5.25 + math.random() * 0.5
		inst.components.transparentonsanity.calc_percent_fn = Client_CalcTransparencyRating
		inst.components.transparentonsanity.onalphachangedfn = SetHeadAlpha
		inst.components.transparentonsanity:ForceUpdate()
	end

	inst.scrapbook_inspectonseen = true

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	--inst.persists = false
	inst.isguard = true
	inst._notrail = true
	inst.FindRelocatePoint = FindRelocatePoint

    inst:AddComponent("sanityaura")
	inst.components.sanityaura.aura = TUNING.SANITYAURA_MED

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = TUNING.GESTALTGUARD_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.GESTALTGUARD_WALK_SPEED
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = true }

	inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.GESTALTGUARD_HEALTH)
    --inst.components.health.nofadeout = true


	inst:AddComponent("combat")
	inst.components.combat:SetDefaultDamage(TUNING.GESTALTGUARD_DAMAGE)
	--inst.components.combat:SetAttackPeriod(TUNING.GESTALT_ATTACK_COOLDOWN)
	inst.components.combat:SetRange(TUNING.GESTALTGUARD_ATTACK_RANGE)
	inst.components.combat:SetAttackPeriod(0)
    inst.components.combat:SetRetargetFunction(1, Retarget)
	inst:ListenForEvent("newcombattarget", OnNewCombatTarget)
	inst:ListenForEvent("droppedtarget", OnNoCombatTarget)
	inst:ListenForEvent("losttarget", OnNoCombatTarget)
	inst:ListenForEvent("onattackother", onattackother)
	inst:ListenForEvent("killed", onkilledtarget)

	inst:AddComponent("knownlocations")

    inst:SetStateGraph("SGbrightmare_gestalt")
    inst:SetBrain(brain)

    return inst
end

return Prefab("gestalt_guard", fn, assets, prefabs)
