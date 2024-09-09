local swipe_assets =
{
	Asset("ANIM", "anim/sharkboi_swipe_fx.zip"),
}

local iceplow_assets =
{
	Asset("ANIM", "anim/sharkboi_iceplow_fx.zip"),
}

local icetrail_assets =
{
	Asset("ANIM", "anim/sharkboi_trail.zip"),
}

--------------------------------------------------------------------------

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

	inst.AnimState:SetBank("sharkboi_swipe_fx")
	inst.AnimState:SetBuild("sharkboi_swipe_fx")
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

--------------------------------------------------------------------------

local function iceplow_KillFX(inst)
	inst:ListenForEvent("animover", inst.Remove)
	inst.AnimState:PlayAnimation("iceplow"..tostring(inst.variation).."_pst")
end

local function iceplow_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.AnimState:SetBank("sharkboi_iceplow_fx")
	inst.AnimState:SetBuild("sharkboi_iceplow_fx")
	inst.AnimState:PlayAnimation("iceplow1_pre")
	inst.AnimState:SetFinalOffset(1)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.variation = math.random(2)
	if inst.variation ~= 1 then
		inst.AnimState:PlayAnimation("iceplow"..tostring(inst.variation).."_pre")
	end
	inst.AnimState:PushAnimation("iceplow"..tostring(inst.variation).."_idle", false)
	local scale = 0.6 + math.random() * 0.4
	inst.AnimState:SetScale(math.random() < 0.5 and -scale or scale, scale)

	inst.persists = false
	inst:DoTaskInTime(1.35 + math.random() * 0.3, iceplow_KillFX)

	return inst
end

--------------------------------------------------------------------------

local function iceimpact_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.AnimState:SetBank("sharkboi_iceplow_fx")
	inst.AnimState:SetBuild("sharkboi_iceplow_fx")
	inst.AnimState:PlayAnimation("ice_impact")
	inst.AnimState:SetFinalOffset(1)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.persists = false
	inst:ListenForEvent("animover", inst.Remove)

	return inst
end

--------------------------------------------------------------------------

local function icetrail_KillFX(inst)
	inst:ListenForEvent("animover", inst.Remove)
	inst.AnimState:PlayAnimation("crack"..tostring(inst.variation).."_pst")
end

local function icetrail_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.AnimState:SetBank("sharkboi_trail")
	inst.AnimState:SetBuild("sharkboi_trail")
	inst.AnimState:PlayAnimation("crack1_pre")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.variation = math.random(3)
	if inst.variation ~= 1 then
		inst.AnimState:PlayAnimation("crack"..tostring(inst.variation).."_pre")
	end
	inst.AnimState:PushAnimation("crack"..tostring(inst.variation).."_idle", false)
	if math.random() < 0.5 then
		inst.AnimState:SetScale(-1, 1)
	end

	inst.persists = false
	inst:DoTaskInTime(2, icetrail_KillFX)

	return inst
end

--------------------------------------------------------------------------

local function icehole_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.AnimState:SetBank("sharkboi_trail")
	inst.AnimState:SetBuild("sharkboi_trail")
	inst.AnimState:PlayAnimation("icehole_pst")
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3)
	--NOT ground oriented

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.persists = false
	inst:ListenForEvent("animover", inst.Remove)

	return inst
end

--------------------------------------------------------------------------

return Prefab("sharkboi_swipe_fx", swipe_fn, swipe_assets),
	Prefab("sharkboi_iceplow_fx", iceplow_fn, iceplow_assets),
	Prefab("sharkboi_iceimpact_fx", iceimpact_fn, iceplow_assets),
	Prefab("sharkboi_icetrail_fx", icetrail_fn, icetrail_assets),
	Prefab("sharkboi_icehole_fx", icehole_fn, icetrail_assets)
