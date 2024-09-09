local assets =
{
	Asset("ANIM", "anim/bomb_lunarplant.zip"),
	Asset("ANIM", "anim/sleepcloud.zip"),
}

local prefabs =
{
	"bomb_lunarplant_explode_fx",
	"reticule",
	"reticuleaoe",
	"reticuleaoeping",
}

local function OnHit(inst, attacker, target)
	local x, y, z = inst.Transform:GetWorldPosition()

	if inst.components.planardamage == nil then
		inst:AddComponent("planardamage")
		inst.components.planardamage:SetBaseDamage(TUNING.BOMB_LUNARPLANT_PLANAR_DAMAGE)
	end

	inst.SoundEmitter:KillSound("toss")

	inst:AddComponent("explosive")
	inst.components.explosive.explosiverange = TUNING.BOMB_LUNARPLANT_RANGE
	inst.components.explosive.explosivedamage = 0
	inst.components.explosive.lightonexplode = false
	if inst.ispvp then
		inst.components.explosive:SetPvpAttacker(attacker)
	else
		inst.components.explosive:SetAttacker(attacker)
	end
	inst.components.explosive:OnBurnt()
	--exploding should have removed me

	SpawnPrefab("bomb_lunarplant_explode_fx").Transform:SetPosition(x, y, z)
end

local function onequip(inst, owner)
	local skin_build = inst:GetSkinBuild()
	if skin_build ~= nil then
		owner:PushEvent("equipskinneditem", inst:GetSkinName())
		owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_bomb_lunarplant", inst.GUID, "bomb_lunarplant")
	else
		owner.AnimState:OverrideSymbol("swap_object", "bomb_lunarplant", "swap_bomb_lunarplant")
	end
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
	local skin_build = inst:GetSkinBuild()
	if skin_build ~= nil then
		owner:PushEvent("unequipskinneditem", inst:GetSkinName())
	end
end

local FX_TICKS = 30
local MAX_ADD_COLOUR = .6

local function UpdateSpin(inst, ticks)
	inst.spinticks:set_local(inst.spinticks:value() + ticks)
	--V2C: hack alert: using SetHightlightColour to achieve something like OverrideAddColour
	--     (that function does not exist), because we know this FX can never be highlighted!
	if inst.spinticks:value() < FX_TICKS then
		local k = inst.spinticks:value() / FX_TICKS
		k = k * k * MAX_ADD_COLOUR
		inst.AnimState:SetHighlightColour(k, k, k, 0)
		inst.AnimState:OverrideMultColour(1, 1, 1, k)
		if inst.core ~= nil then
			inst.core.AnimState:SetAddColour(k, k, k, 0)
			inst.core.AnimState:SetLightOverride(k / 3)
		end
	else
		inst.AnimState:SetHighlightColour(MAX_ADD_COLOUR, MAX_ADD_COLOUR, MAX_ADD_COLOUR, 0)
		inst.AnimState:OverrideMultColour(1, 1, 1, MAX_ADD_COLOUR)
		if inst.core ~= nil then
			inst.core.AnimState:SetAddColour(MAX_ADD_COLOUR, MAX_ADD_COLOUR, MAX_ADD_COLOUR, 0)
			inst.core.AnimState:SetLightOverride(MAX_ADD_COLOUR / 3)
		end
		inst.spintask:Cancel()
		inst.spintask = nil
	end
end

local function CreateSpinCore()
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

	inst.AnimState:SetBank("bomb_lunarplant")
	inst.AnimState:SetBuild("bomb_lunarplant")
	inst.AnimState:PlayAnimation("spin_idle")
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

	return inst
end

local function OnSpinTicksDirty(inst)
	if inst.spintask == nil then
		inst.spintask = inst:DoPeriodicTask(0, UpdateSpin, nil, 1)
		--Dedicated server does not need to trigger sfx
		if not TheNet:IsDedicated() then
			--restore teh bomb core at full opacity, since we're fading in the entire
			--entity to fadein the light rays (easier that way to optimize networking!)
			inst.core = CreateSpinCore()
			inst.core.entity:SetParent(inst.entity)
			inst.core.Follower:FollowSymbol(inst.GUID, "bomb_lunarplant_follow", nil, nil, nil, true)
		end
	end
	UpdateSpin(inst, 0)
end

local function onthrown(inst, attacker)
	inst:AddTag("NOCLICK")
	inst.persists = false

	inst.ispvp = attacker ~= nil and attacker:IsValid() and attacker:HasTag("player")

	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:PlayAnimation("spin_loop", true)
	inst.AnimState:SetLightOverride(1)

	inst.SoundEmitter:PlaySound("rifts/lunarthrall_bomb/throw", "toss")

	inst.Physics:SetMass(1)
	inst.Physics:SetFriction(0)
	inst.Physics:SetDamping(0)
	inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
	inst.Physics:ClearCollisionMask()
	inst.Physics:CollidesWith(COLLISION.GROUND)
	inst.Physics:CollidesWith(COLLISION.OBSTACLES)
	inst.Physics:CollidesWith(COLLISION.ITEMS)
	inst.Physics:SetCapsule(.2, .2)

	inst.spinticks:set(3)
	OnSpinTicksDirty(inst)
end

local function ReticuleTargetFn()
	local player = ThePlayer
	local ground = TheWorld.Map
	local pos = Vector3()
	--Attack range is 8, leave room for error
	--Min range was chosen to not hit yourself (2 is the hit range)
	for r = 6.5, 3.5, -.25 do
		pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
		if ground:IsPassableAtPoint(pos:Get()) and not ground:IsGroundTargetBlocked(pos) then
			return pos
		end
	end
	return pos
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst.Transform:SetTwoFaced()

	MakeInventoryPhysics(inst)

	inst:AddTag("toughworker")
	inst:AddTag("explosive")

	--projectile (from complexprojectile component) added to pristine state for optimization
	inst:AddTag("projectile")

	inst.AnimState:SetBank("bomb_lunarplant")
	inst.AnimState:SetBuild("bomb_lunarplant")
	inst.AnimState:PlayAnimation("idle")

	inst:AddComponent("reticule")
	inst.components.reticule.targetfn = ReticuleTargetFn
	inst.components.reticule.ease = true

	--weapon (from weapon component) added to pristine state for optimization
	inst:AddTag("weapon")

	MakeInventoryFloatable(inst, "small", 0.1, 0.8)

	inst.spinticks = net_smallbyte(inst.GUID, "bomb_lunarplant.spinticks", "spinticksdirty")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		inst:ListenForEvent("spinticksdirty", OnSpinTicksDirty)

		return inst
	end

	inst:AddComponent("locomotor")

	inst:AddComponent("complexprojectile")
	inst.components.complexprojectile:SetHorizontalSpeed(15)
	inst.components.complexprojectile:SetGravity(-35)
	inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 1, 0))
	inst.components.complexprojectile:SetOnLaunch(onthrown)
	inst.components.complexprojectile:SetOnHit(OnHit)

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(0)
	inst.components.weapon:SetRange(8, 10)

	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")
	inst:AddComponent("stackable")

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
	inst.components.equippable.equipstack = true

	MakeHauntableLaunch(inst)

	return inst
end

--------------------------------------------------------------------------

local function PlayExplodeSound(inst)
	inst.SoundEmitter:PlaySound("rifts/lunarthrall_bomb/explode")
end

local function fxfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.AnimState:SetBank("bomb_lunarplant")
	inst.AnimState:SetBuild("bomb_lunarplant")
	inst.AnimState:PlayAnimation("used")
	inst.AnimState:SetSymbolBloom("light_beam")
	inst.AnimState:SetSymbolBloom("pb_energy_loop")
	inst.AnimState:SetSymbolLightOverride("light_beam", 1)
	inst.AnimState:SetSymbolLightOverride("pb_energy_loop", 1)
	inst.AnimState:OverrideSymbol("sleepcloud_pre", "sleepcloud", "sleepcloud_pre")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:DoTaskInTime(0, PlayExplodeSound)

	inst:ListenForEvent("animover", inst.Remove)
	inst.persists = false

	return inst
end

--------------------------------------------------------------------------

return Prefab("bomb_lunarplant", fn, assets, prefabs),
	Prefab("bomb_lunarplant_explode_fx", fxfn, assets)
