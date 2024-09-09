local swipe_assets =
{
	Asset("ANIM", "anim/daywalker_swipe_fx.zip"),
}

local function swipe_Reverse(inst)
	inst.AnimState:PlayAnimation("atk2")
end

local function swipe_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.Transform:SetFourFaced()

	inst.AnimState:SetBank("daywalker_swipe_fx")
	inst.AnimState:SetBuild("daywalker_swipe_fx")
	inst.AnimState:PlayAnimation("atk1")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.Reverse = swipe_Reverse

	inst.persists = false
	inst:ListenForEvent("animover", inst.Remove)

	return inst
end

return Prefab("daywalker2_swipe_fx", swipe_fn, swipe_assets)
