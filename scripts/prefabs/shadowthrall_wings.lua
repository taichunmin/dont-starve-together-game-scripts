local assets =
{
	Asset("ANIM", "anim/shadow_thrall_wings.zip"),
}

local prefabs =
{
	"shadowthrall_projectile_fx",
	"voidcloth",
	"horrorfuel",
	"nightmarefuel",
	"winter_ornament_shadowthralls",
}

local brain = require("brains/shadowthrall_wings_brain")

SetSharedLootTable("shadowthrall_wings",
{
	{ "voidcloth",		1.00 },
	{ "voidcloth",		1.00 },
	{ "voidcloth",		0.67 },
	{ "horrorfuel",		1.00 },
	{ "horrorfuel",		1.00 },
	{ "horrorfuel",		0.33 },
	{ "nightmarefuel",	1.00 },
	{ "nightmarefuel",	0.67 },
})

local function RetargetFn(inst)
	if inst.sg:HasStateTag("appearing") or inst.sg:HasStateTag("invisible") then
		return
	end

	local x, y, z = inst.Transform:GetWorldPosition()
	local target = inst.components.combat.target
	if target ~= nil then
		local range = TUNING.SHADOWTHRALL_WINGS_ATTACK_RANGE + target:GetPhysicsRadius(0)
		if target:HasTag("player") and target:GetDistanceSqToPoint(x, y, z) < range * range then
			--Keep target
			return
		end
	end

	local horns = inst.components.entitytracker:GetEntity("horns")
	if horns ~= nil and horns.sg ~= nil and inst.components.combat:IsRecentTarget(horns.sg.statemem.devoured) then
		--Wait for target being devoured
		return
	end

	--V2C: WARNING: FindClosestPlayerInRange returns 2 values, which
	--              we don't want to return as our 2nd return value.  
	local player--[[, rangesq]] = FindClosestPlayerInRange(x, y, z, TUNING.SHADOWTHRALL_AGGRO_RANGE, true)
	return player
end

local function KeepTargetFn(inst, target)
	if not inst.components.combat:CanTarget(target) then
		return false
	end
	local x, y, z = inst.Transform:GetWorldPosition()
	local rangesq = TUNING.SHADOWTHRALL_DEAGGRO_RANGE * TUNING.SHADOWTHRALL_DEAGGRO_RANGE
	if target:GetDistanceSqToPoint(x, y, z) < rangesq then
		return true
	end
	local hands = inst.components.entitytracker:GetEntity("hands")
	if hands ~= nil and hands:GetDistanceSqToPoint(x, y, z) < rangesq then
		return true
	end
	local horns = inst.components.entitytracker:GetEntity("horns")
	if horns ~= nil and horns:GetDistanceSqToPoint(x, y, z) < rangesq then
		return true
	end
	return false
end

local function OnAttacked(inst, data)
	if data.attacker ~= nil then
		local target = inst.components.combat.target
		if not (target ~= nil and
				target:HasTag("player") and
				inst:IsNear(target, TUNING.SHADOWTHRALL_WINGS_ATTACK_RANGE + target:GetPhysicsRadius(0))) then
			--
			inst.components.combat:SetTarget(data.attacker)
		end
	end
end

local function OnNewCombatTarget(inst, data)
	if data ~= nil and data.oldtarget == nil then
		local hands = inst.components.entitytracker:GetEntity("hands")
		if hands ~= nil and hands.components.combat ~= nil then
			hands.components.combat:SuggestTarget(data.target)
		end
		local horns = inst.components.entitytracker:GetEntity("horns")
		if horns ~= nil and horns.components.combat ~= nil then
			horns.components.combat:SuggestTarget(data.target)
		end
	end
end

local function OnLoadPostPass(inst)
	if inst.sg.mem.lastattack == nil then
		local team = { inst }
		local horns = inst.components.entitytracker:GetEntity("horns")
		if horns ~= nil and horns.sg ~= nil then
			table.insert(team, horns)
		end
		local hands = inst.components.entitytracker:GetEntity("hands")
		if hands ~= nil and hands.sg ~= nil then
			table.insert(team, hands)
		end
		local t = GetTime()
		for i = 1, #team do
			local v = table.remove(team, math.random(#team))
			v.sg.mem.lastattack = t - i
		end
	end
end

local function DisplayNameFn(inst)
	return ThePlayer ~= nil and ThePlayer:HasTag("player_shadow_aligned") and STRINGS.NAMES.SHADOWTHRALL_WINGS_ALLEGIANCE or nil
end

--------------------------------------------------------------------------

local function GetWintersFeastOrnaments(inst)
	local hands = inst.components.entitytracker:GetEntity("hands")
	local horns = inst.components.entitytracker:GetEntity("horns")

	return hands == nil and horns == nil and { basic = 1, special = "winter_ornament_shadowthralls" } or nil
end

--------------------------------------------------------------------------

local function CreateFlameFx()
	local inst = CreateEntity()

	inst:AddTag("FX")
	--[[Non-networked entity]]
	if not TheWorld.ismastersim then
		inst.entity:SetCanSleep(false)
	end
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()

	inst.AnimState:SetBank("shadow_thrall_wings")
	inst.AnimState:SetBuild("shadow_thrall_wings")
	inst.AnimState:PlayAnimation("fx_flame", true)
	inst.AnimState:SetSymbolLightOverride("fx_flame_red", 1)
	inst.AnimState:SetSymbolLightOverride("fx_red", 1)
	inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()))

	return inst
end

local function CreateFabricFx()
	local inst = CreateEntity()

	inst:AddTag("FX")
	--[[Non-networked entity]]
	if not TheWorld.ismastersim then
		inst.entity:SetCanSleep(false)
	end
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()

	inst.AnimState:SetBank("shadow_thrall_wings")
	inst.AnimState:SetBuild("shadow_thrall_wings")
	inst.AnimState:PlayAnimation("fx_fabric", true)
	inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()))

	return inst
end

local function CreateCapeFx()
	local inst = CreateEntity()

	inst:AddTag("FX")
	--[[Non-networked entity]]
	if not TheWorld.ismastersim then
		inst.entity:SetCanSleep(false)
	end
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()

	inst.AnimState:SetBank("shadow_thrall_wings")
	inst.AnimState:SetBuild("shadow_thrall_wings")
	inst.AnimState:PlayAnimation("fx_cape_front", true)
	inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()))

	return inst
end

local function OnColourChanged(inst, r, g, b, a)
	for i, v in ipairs(inst.highlightchildren) do
		v.AnimState:SetAddColour(r, g, b, a)
	end
end

--------------------------------------------------------------------------

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
	inst.entity:AddNetwork()

	inst:SetPhysicsRadiusOverride(.5)
	MakeGhostPhysics(inst, 25, inst.physicsradiusoverride)
	inst.DynamicShadow:SetSize(1.7, .9)
	inst.Transform:SetFourFaced()

	inst:AddTag("monster")
	inst:AddTag("hostile")
	inst:AddTag("scarytoprey")
	inst:AddTag("flying")
	inst:AddTag("shadowthrall")
	inst:AddTag("shadow_aligned")

	inst.AnimState:SetBank("shadow_thrall_wings")
	inst.AnimState:SetBuild("shadow_thrall_wings")
	inst.AnimState:PlayAnimation("idle", true)
	inst.AnimState:SetSymbolLightOverride("fx_red", 1)
	inst.AnimState:SetSymbolLightOverride("fx_red_particle", 1)
	inst.AnimState:SetSymbolLightOverride("wingend_red", 1)

	inst.scrapbook_anim ="scrapbook"
	inst.scrapbook_overridedata ={{"fx_fabric", "shadow_thrall_wings", "fx_fabric"},{"fx_fabric_particle", "shadow_thrall_wings", "fx_fabric_particle"},{"fx_flame_black", "shadow_thrall_wings", "fx_flame_black"},{"fx_flame_red", "shadow_thrall_wings", "fx_flame_red"}}

	inst:AddComponent("colouraddersync")

	--Dedicated server does not need to spawn the local fx
	if not TheNet:IsDedicated() then
		local flames = CreateFlameFx()
		flames.entity:SetParent(inst.entity)
		flames.Follower:FollowSymbol(inst.GUID, "fx_flame_swap", nil, nil, nil, true)

		local fabric = CreateFabricFx()
		fabric.entity:SetParent(inst.entity)
		fabric.Follower:FollowSymbol(inst.GUID, "fx_fabric_swap", nil, nil, nil, true)

		local cape = CreateCapeFx()
		cape.entity:SetParent(inst.entity)
		cape.Follower:FollowSymbol(inst.GUID, "cape_front_swap", nil, nil, nil, true)

		inst.highlightchildren = { flames, fabric, cape }

		inst.components.colouraddersync:SetColourChangedFn(OnColourChanged)
	end

	inst.displaynamefn = DisplayNameFn

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")

	inst:AddComponent("sanityaura")
	inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

	inst:AddComponent("locomotor")
	inst.components.locomotor:EnableGroundSpeedMultiplier(false)
	inst.components.locomotor:SetTriggersCreep(false)
	inst.components.locomotor.walkspeed = TUNING.SHADOWTHRALL_WINGS_WALKSPEED

	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(TUNING.SHADOWTHRALL_WINGS_HEALTH)
	inst.components.health.nofadeout = true

	inst:AddComponent("combat")
	inst.components.combat:SetDefaultDamage(TUNING.SHADOWTHRALL_WINGS_DAMAGE)
	inst.components.combat:SetAttackPeriod(TUNING.SHADOWTHRALL_WINGS_ATTACK_PERIOD)
	inst.components.combat:SetRange(TUNING.SHADOWTHRALL_WINGS_ATTACK_RANGE)
	inst.components.combat:SetRetargetFunction(3, RetargetFn)
	inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
	inst.components.combat.forcefacing = false
	inst.components.combat.hiteffectsymbol = "shad"
	inst:ListenForEvent("attacked", OnAttacked)
	inst:ListenForEvent("newcombattarget", OnNewCombatTarget)

	inst:AddComponent("planarentity")
	inst:AddComponent("planardamage")
	inst.components.planardamage:SetBaseDamage(TUNING.SHADOWTHRALL_WINGS_PLANAR_DAMAGE)

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetChanceLootTable("shadowthrall_wings")
	inst.components.lootdropper.GetWintersFeastOrnaments = GetWintersFeastOrnaments
	inst.components.lootdropper.y_speed = 4
	inst.components.lootdropper.y_speed_variance = 3
	inst.components.lootdropper.spawn_loot_inside_prefab = true

	inst:AddComponent("colouradder")
	inst:AddComponent("knownlocations")
	inst:AddComponent("entitytracker")

	inst:SetStateGraph("SGshadowthrall_wings")
	inst:SetBrain(brain)

	inst.OnLoadPostPass = OnLoadPostPass

	return inst
end

return Prefab("shadowthrall_wings", fn, assets, prefabs)
