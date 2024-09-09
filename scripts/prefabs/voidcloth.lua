local assets =
{
	Asset("ANIM", "anim/voidcloth.zip"),
}

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("voidcloth")
	inst.AnimState:SetBuild("voidcloth")
	inst.AnimState:PlayAnimation("idle")

	MakeInventoryFloatable(inst, "large", nil, 0.6)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

	MakeHauntableLaunch(inst)

	return inst
end

return Prefab("voidcloth", fn, assets)
