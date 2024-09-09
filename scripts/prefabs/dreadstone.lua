local assets =
{
	Asset("ANIM", "anim/dreadstone.zip"),
}

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("dreadstone")
	inst.AnimState:SetBuild("dreadstone")
	inst.AnimState:PlayAnimation("idle")

	inst.pickupsound = "rock"

	MakeInventoryFloatable(inst, "med", .145, { .77, .75, .77 })

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("tradable")

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")

	inst:AddComponent("repairer")
	inst.components.repairer.repairmaterial = MATERIALS.DREADSTONE
	inst.components.repairer.healthrepairvalue = TUNING.REPAIR_DREADSTONE_HEALTH
	inst.components.repairer.workrepairvalue = TUNING.REPAIR_DREADSTONE_WORK

	MakeHauntableLaunchAndSmash(inst)

	return inst
end

return Prefab("dreadstone", fn, assets)
