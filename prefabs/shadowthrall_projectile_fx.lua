local SpDamageUtil = require("components/spdamageutil")

local assets =
{
	Asset("ANIM", "anim/shadow_thrall_projectile_fx.zip"),
}

local prefabs =
{
	"fused_shadeling_bomb_scorch",
}

local AOE_RANGE = 1
local AOE_RANGE_PADDING = 3
local AOE_TARGET_MUSTHAVE_TAGS = { "_combat" }
local AOE_TARGET_CANT_TAGS = { "INLIMBO", "flight", "invisible", "notarget", "noattack", "shadow_aligned" }

local function OnHit(inst)--, attacker, target)
	inst:RemoveComponent("complexprojectile")
	inst:ListenForEvent("animover", inst.Remove)
	inst.AnimState:PlayAnimation("projectile_impact")
	inst.DynamicShadow:Enable(false)
	local playsfx = true
	if inst.sfx ~= nil then
		if inst.sfx.played then
			playsfx = false
		else
			inst.sfx.played = true
		end
	end
	if playsfx then
		inst.SoundEmitter:PlaySound("rifts2/thrall_wings/projectile")
	end

	local x, y, z = inst.Transform:GetWorldPosition()
	for i, v in ipairs(TheSim:FindEntities(x, y, z, AOE_RANGE + AOE_RANGE_PADDING, AOE_TARGET_MUSTHAVE_TAGS, AOE_TARGET_CANT_TAGS)) do
		if not (inst.targets ~= nil and inst.targets[v]) and
			v:IsValid() and not v:IsInLimbo() and
			not (v.components.health ~= nil and v.components.health:IsDead())
			then
			local range = AOE_RANGE + v:GetPhysicsRadius(0)
			if v:GetDistanceSqToPoint(x, y, z) < range * range then
				local spdmg = SpDamageUtil.CollectSpDamage(inst)
				local attacker = inst.owner ~= nil and inst.owner:IsValid() and inst.owner or inst
				v.components.combat:GetAttacked(attacker, TUNING.SHADOWTHRALL_WINGS_DAMAGE, nil, nil, spdmg)
				if inst.targets ~= nil then
					inst.targets[v] = true
				end
			end
		end
	end

	local scorch = SpawnPrefab("fused_shadeling_bomb_scorch")
	scorch.Transform:SetPosition(x, 0, z)
	scorch.Transform:SetScale(.9, .9, .9)
end

local function OnLaunch(inst, attacker)
	inst.owner = attacker
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
	inst.entity:AddNetwork()

	inst.DynamicShadow:SetSize(.8, .8)

	inst.entity:AddPhysics()
	inst.Physics:SetMass(1)
	inst.Physics:SetFriction(0)
	inst.Physics:SetDamping(0)
	inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
	inst.Physics:ClearCollisionMask()
	inst.Physics:CollidesWith(COLLISION.GROUND)
	inst.Physics:SetCapsule(.2, .2)

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst:AddTag("shadow_aligned")

	inst.Transform:SetSixFaced()

	inst.AnimState:SetBank("shadow_thrall_projectile_fx")
	inst.AnimState:SetBuild("shadow_thrall_projectile_fx")
	inst.AnimState:PlayAnimation("projectile_pre")
	inst.AnimState:SetLightOverride(1)

	--projectile (from complexprojectile component) added to pristine state for optimization
	inst:AddTag("projectile")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.AnimState:PushAnimation("projectile_loop")
	inst.AnimState:PushAnimation("idle_loop")

	inst:AddComponent("complexprojectile")
	inst.components.complexprojectile:SetHorizontalSpeed(15)
	inst.components.complexprojectile:SetGravity(-35)
	inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 3, 0))
	inst.components.complexprojectile:SetOnLaunch(OnLaunch)
	inst.components.complexprojectile:SetOnHit(OnHit)

	inst:AddComponent("planardamage")
	inst.components.planardamage:SetBaseDamage(TUNING.SHADOWTHRALL_WINGS_PLANAR_DAMAGE)

	--inst.targets = nil
	--inst.sfx = nil
	inst.persists = false

	return inst
end

return Prefab("shadowthrall_projectile_fx", fn, assets, prefabs)
