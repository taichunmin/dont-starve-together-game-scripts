local assets =
{
	Asset("ANIM", "anim/channel_absorb_fire_fx.zip"),
}

local function KillFX(inst)
	if not inst.killed then
		inst.killed = true
		inst:ListenForEvent("animover", inst.Remove)
		inst.AnimState:PlayAnimation("channel_pst")
	end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()
	inst.entity:AddNetwork()

	inst.AnimState:SetBank("channel_absorb_fire_fx")
	inst.AnimState:SetBuild("channel_absorb_fire_fx")
	inst.AnimState:PlayAnimation("channel_pre")
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:SetLightOverride(1)

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.AnimState:PushAnimation("channel_loop")

	inst.persists = false

	inst.KillFX = KillFX

	return inst
end

local function CommonFX(anim)
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()
	inst.entity:AddNetwork()

	inst.AnimState:SetBank("channel_absorb_fire_fx")
	inst.AnimState:SetBuild("channel_absorb_fire_fx")
	inst.AnimState:PlayAnimation(anim)

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:ListenForEvent("animover", function() inst:Remove() end)

	return inst	
end

local function firefn()
	local inst = CommonFX("channel_fire")

	return inst
end

local function smoulderfn()
	local inst = CommonFX("channel_smoulders")

	return inst
end

local function embersfn()
	local inst = CommonFX("channel_embers")

	return inst
end


return Prefab("channel_absorb_fire_fx", fn, assets),
	   Prefab("channel_absorb_fire",    firefn, assets),
	   Prefab("channel_absorb_smoulder",smoulderfn, assets),
	   Prefab("channel_absorb_embers", 	embersfn, assets)
