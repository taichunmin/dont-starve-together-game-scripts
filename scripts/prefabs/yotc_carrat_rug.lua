local assets =
{
	Asset("ANIM", "anim/yotc_carrat_rug.zip"),
}

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle")
end

local function onburntup(inst)
	inst.AnimState:PlayAnimation("burnt")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("carrat_rug")
    inst.AnimState:SetBuild("yotc_carrat_rug")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(1)

	inst:AddTag("DECOR")
	inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:ListenForEvent("onbuilt", onbuilt)
	inst:ListenForEvent("onburntup", onburntup)

    return inst
end

return Prefab("yotc_carrat_rug", fn, assets)