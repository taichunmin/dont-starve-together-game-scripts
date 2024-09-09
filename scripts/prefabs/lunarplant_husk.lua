local assets =
{
	Asset("ANIM", "anim/lunarplant_husk.zip"),
}

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("lunarplant_husk")
	inst.AnimState:SetBuild("lunarplant_husk")
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

return Prefab("lunarplant_husk", fn, assets)
