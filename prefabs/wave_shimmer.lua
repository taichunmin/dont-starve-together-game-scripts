local assets =
{
	Asset( "ANIM", "anim/wave_shimmer.zip" ),
	Asset( "ANIM", "anim/wave_shimmer_med.zip" ),
	Asset( "ANIM", "anim/wave_shimmer_deep.zip" ),
	Asset( "ANIM", "anim/wave_shimmer_flood.zip" ),
	Asset( "ANIM", "anim/wave_hurricane.zip" )
}

local function commonfn(Sim)
	local inst = CreateEntity()

	inst.entity:AddTransform()
    inst.entity:AddAnimState()

    --[[Non-networked entity]]
    inst:AddTag("CLASSIFIED")

    inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.WAVE_TINT_AMOUNT)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(ANIM_SORT_ORDER.OCEAN_WAVES)

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst:AddTag("NOBLOCK")
	inst:AddTag("ignorewalkableplatforms")

	inst.OnEntitySleep = inst.Remove
	inst:ListenForEvent("animover", inst.Remove)

	inst.persists = false

    return inst
end

local function shallowfn(Sim)
	local inst = commonfn(Sim)
	inst.AnimState:SetBuild( "wave_shimmer" )
	inst.AnimState:SetBank( "shimmer" )
	inst.AnimState:PlayAnimation( "idle", false )
	return inst
end

local function medfn(Sim)
	local inst = commonfn(Sim)
	inst.AnimState:SetBuild( "wave_shimmer_med" )
	inst.AnimState:SetBank( "shimmer" )
	inst.AnimState:PlayAnimation( "idle", false )
	return inst
end

local function deepfn(Sim)
	local inst = commonfn(Sim)
	inst.AnimState:SetBuild( "wave_shimmer_deep" )
	inst.AnimState:SetBank( "shimmer_deep" )
	inst.AnimState:PlayAnimation( "idle", false )
	return inst
end

local function floodfn(Sim)
	local inst = commonfn(Sim)
    inst.AnimState:SetBuild( "wave_shimmer_flood" )
    inst.AnimState:SetBank( "wave_shimmer_flood" )
    inst.AnimState:PlayAnimation( "idle", false )
	return inst
end

return Prefab("wave_shimmer", shallowfn, assets),
		Prefab("wave_shimmer_med", medfn, assets),
		Prefab("wave_shimmer_deep", deepfn, assets),
		Prefab("wave_shimmer_flood", floodfn, assets)
