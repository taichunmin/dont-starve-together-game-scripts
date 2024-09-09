local easing = require("easing")

local assets_ping =
{
	Asset("ANIM", "anim/deerclops_mutated_actions.zip"),
	Asset("ANIM", "anim/deerclops_mutated.zip"),
}

local assets_impact =
{
	Asset("ANIM", "anim/deerclops_mutated_actions.zip"),
	Asset("ANIM", "anim/deerclops_mutated.zip"),
	Asset("ANIM", "anim/deer_ice_circle.zip"),
}

local assets_aura = 
{
	Asset("ANIM", "anim/deer_ice_circle.zip"),
}

local assets_spikefire =
{
	Asset("ANIM", "anim/fire_large_character.zip"),
}

--------------------------------------------------------------------------

local function ping_OnUpdateDisc(inst)
	if inst.delta > 0 then
		if inst.alpha < 1 then
			inst.alpha = math.min(1, inst.alpha + inst.delta)
			local a = easing.outQuad(inst.alpha, 0, 1, 1)
			inst.AnimState:SetMultColour(1, 1, 1, a)
		end
	elseif inst.delta < 0 and inst.alpha > 0 then
		inst.alpha = math.max(0, inst.alpha + inst.delta)
		local a = easing.inQuad(inst.alpha, 0, 1, 1)
		inst.AnimState:SetMultColour(1, 1, 1, a)
		if inst.alpha <= 0 then
			inst:Hide()
		end
	end
end

local function ping_CreateDisc()
	local inst = CreateEntity()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	--[[Non-networked entity]]
	--inst.entity:SetCanSleep(false) --commented out; follow parent sleep instead
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst.AnimState:SetBank("deerclops")
	inst.AnimState:SetBuild("deerclops_mutated")
	inst.AnimState:PlayAnimation("target_fx_ring")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
	inst.AnimState:SetSortOrder(3)
	inst.AnimState:SetMultColour(1, 1, 1, 0)

	inst:AddComponent("updatelooper")
	inst.components.updatelooper:AddOnUpdateFn(ping_OnUpdateDisc)

	inst.alpha = 0
	inst.delta = 0.1

	return inst
end

local function ping_OnFadeDirty(inst)
	--fade: 0=in 1=hold 2=out
	if inst.fade:value() == 1 then
		inst.disc.alpha = 1
		inst.disc.delta = 0
		inst.disc.AnimState:SetMultColour(1, 1, 1, 1)
	else
		inst.disc.delta = inst.fade:value() == 2 and -0.1 or 0.1
	end
end

local function ping_OnAnimQueueOver(inst)
	if inst.fade:value() == 2 then
		inst:Remove()
	else
		inst.AnimState:PlayAnimation("target_fx", true)
		inst.fade:set(1)
		if inst.disc ~= nil then
			ping_OnFadeDirty(inst)
		end
	end
end

local function ping_KillFX(inst)
	if inst.fade:value() ~= 2 then
		inst.AnimState:PlayAnimation("target_fx_pst")
		inst.fade:set(2)
		if inst.disc ~= nil then
			ping_OnFadeDirty(inst)
		end
	end
end

local function pingfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.AnimState:SetBank("deerclops")
	inst.AnimState:SetBuild("deerclops_mutated")
	inst.AnimState:PlayAnimation("target_fx_pre")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
	inst.AnimState:SetSortOrder(3)
	inst.AnimState:SetFinalOffset(1)

	inst.fade = net_tinybyte(inst.GUID, "deerclops_icelance_ping_fx.fade", "fadedirty")

	--Dedicated server does not need to spawn the local fx
	if not TheNet:IsDedicated() then
		inst.disc = ping_CreateDisc(inst)
		inst.disc.entity:SetParent(inst.entity)
	end

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		inst:ListenForEvent("fadedirty", ping_OnFadeDirty)

		return inst
	end

	inst:ListenForEvent("animqueueover", ping_OnAnimQueueOver)

	inst.KillFX = ping_KillFX
	inst.persists = false

	return inst
end

--------------------------------------------------------------------------

local function impact_OnPostUpdateExplosion(inst)
	if inst.dopostupdate then
		inst.dopostupdate = nil

		local parent = inst.entity:GetParent()
		if parent ~= nil then
			if parent.AnimState:AnimDone() then
				inst:Hide()
				inst:DoTaskInTime(0, inst.Remove)
				return
			else
				inst.AnimState:SetFrame(parent.AnimState:GetCurrentAnimationFrame())
			end
		end

		--#V2C: This pattern is used because it is not safe to remove a
		--      postupdate fn during the UpdateLooper_PostUpdate phase.
		inst:DoTaskInTime(0, inst.RemoveComponent, "updatelooper")
	end
end

--@V2C #HACK: first time a world sound is played before positioned, it won't be heard.
local impact_firstplayhack = true
local function impact_DoSound(inst)
	inst.SoundEmitter:PlaySound("dontstarve/common/break_iceblock")
end

local function impact_CreateExplosion()
	local inst = CreateEntity()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	--[[Non-networked entity]]
	--inst.entity:SetCanSleep(false) --commented out; follow parent sleep instead
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

	inst.AnimState:SetBank("deerclops")
	inst.AnimState:SetBuild("deerclops_mutated")
	inst.AnimState:PlayAnimation("ice_impact")

	if impact_firstplayhack then
		impact_firstplayhack = nil
		inst:DoTaskInTime(0, impact_DoSound)
	else
		impact_DoSound(inst)
	end

	if not TheWorld.ismastersim then
		inst:AddComponent("updatelooper")
		inst.components.updatelooper:AddPostUpdateFn(impact_OnPostUpdateExplosion)
		inst.dopostupdate = true
	end

	inst:ListenForEvent("animover", inst.Remove)

	return inst
end

local ICE_CIRCLE_RADIUS = 5.5
local NOTAGS = { "playerghost", "INLIMBO", "deerclops", "flight", "invisible" }
for k, v in pairs(FUELTYPE) do
	table.insert(NOTAGS, v.."_fueled")
end

local FREEZETARGET_ONEOF_TAGS = { "freezable", "fire", "smolder" }
local function OnUpdateIceCircle(inst)
	if inst.radius < ICE_CIRCLE_RADIUS then
		inst.radius = inst.radius * 0.98 + ICE_CIRCLE_RADIUS + 0.02
	end
	local x, y, z = inst.Transform:GetWorldPosition()
	for i, v in ipairs(TheSim:FindEntities(x, 0, z, inst.radius, nil, NOTAGS, FREEZETARGET_ONEOF_TAGS)) do
		if v:IsValid() and not (v.components.health ~= nil and v.components.health:IsDead()) then
			if v.components.burnable ~= nil and v.components.fueled == nil then
				v.components.burnable:Extinguish()
			end
			if v.components.freezable ~= nil and
				not v.components.freezable:IsFrozen() and
				v.components.freezable.coldness < v.components.freezable:ResolveResistance() * (inst.freezelimit or 1)
			then
				v.components.freezable:AddColdness(.1, 1, inst.freezelimit ~= nil)
			end
			if v.components.temperature ~= nil then
				local newtemp = math.max(v.components.temperature.mintemp, TUNING.DEER_ICE_TEMPERATURE)
				if newtemp < v.components.temperature:GetCurrent() then
					v.components.temperature:SetTemperature(newtemp)
				end
			end
			if v.components.grogginess ~= nil and
				not v.components.grogginess:IsKnockedOut() and
				v.components.grogginess.grog_amount < TUNING.DEER_ICE_FATIGUE
			then
				v.components.grogginess:AddGrogginess(TUNING.DEER_ICE_FATIGUE)
			end
		end
	end
end

local function impact_KillFX(inst)
	inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateIceCircle)
	inst:ListenForEvent("animover", inst.Remove)
	inst.AnimState:PlayAnimation("pst")
end

local function impactfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.AnimState:SetBank("deer_ice_circle")
	inst.AnimState:SetBuild("deer_ice_circle")
	inst.AnimState:PlayAnimation("impact")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3)
	inst.AnimState:SetScale(2.2, 2.2)

	--Dedicated server does not need to spawn the local fx
	if not TheNet:IsDedicated() then
		impact_CreateExplosion().entity:SetParent(inst.entity)
	end

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("updatelooper")
	inst.components.updatelooper:AddOnUpdateFn(OnUpdateIceCircle)

	inst.radius = ICE_CIRCLE_RADIUS
	inst.freezelimit = 0.7
	inst.persists = false
	inst:DoTaskInTime(2, impact_KillFX)

	return inst
end

--------------------------------------------------------------------------

local function aura_OnAnimOver(inst)
	inst:RemoveEventCallback("animover", aura_OnAnimOver)
	inst.SoundEmitter:KillSound("loop")
end

local function aura_GrowFX(inst)
	inst.radius = 0.25
	inst.AnimState:PlayAnimation("pre")
	inst.AnimState:SetFrame(20)
	inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/fx/ice_circle_LP", "loop")
	inst:ListenForEvent("animover", aura_OnAnimOver)
end

local function aura_KillFX(inst, quick)
	aura_OnAnimOver(inst)
	if quick then
		impact_KillFX(inst)
		return
	end
	inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateIceCircle)
	ErodeAway(inst, 2)
end

local function aurafn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.AnimState:SetBank("deer_ice_circle")
	inst.AnimState:SetBuild("deer_ice_circle")
	inst.AnimState:PlayAnimation("impact")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3)
	inst.AnimState:SetScale(2.2, 2.2)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.Transform:SetRotation(math.random() * 360)

	inst:AddComponent("updatelooper")
	inst.components.updatelooper:AddOnUpdateFn(OnUpdateIceCircle)

	inst.radius = ICE_CIRCLE_RADIUS
	inst.freezelimit = 0.7
	inst.persists = false
	inst.GrowFX = aura_GrowFX
	inst.KillFX = aura_KillFX

	return inst
end

--------------------------------------------------------------------------

local function spikefire_KillFX(inst)
	inst.AnimState:PlayAnimation("post_med_fast")
	inst:ListenForEvent("animover", inst.Remove)
end

local function spikefirefn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()
	inst.entity:AddNetwork()

	inst.AnimState:SetBank("fire_large_character")
	inst.AnimState:SetBuild("fire_large_character")
	inst.AnimState:PlayAnimation("pre_med")
	inst.AnimState:SetFrame(30)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:SetRayTestOnBB(true)

	inst:AddTag("FX")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.AnimState:PushAnimation("loop_med")

	inst.persists = false
	inst.KillFX = spikefire_KillFX

	return inst
end

--------------------------------------------------------------------------

return Prefab("deerclops_icelance_ping_fx", pingfn, assets_ping),
	Prefab("deerclops_impact_circle_fx", impactfn, assets_impact),
	Prefab("deerclops_aura_circle_fx", aurafn, assets_aura),
	Prefab("deerclops_spikefire_fx", spikefirefn, assets_spikefire)
