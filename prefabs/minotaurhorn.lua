local assets =
{
	Asset("ANIM", "anim/horn_rhino.zip"),
}

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    MakeInventoryFloatable(inst, "med", 0.05, 0.75)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:SetBank("horn_rhino")
    inst.AnimState:SetBuild("horn_rhino")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.MEAT
    inst.components.edible.healthvalue = TUNING.HEALING_HUGE
    inst.components.edible.hungervalue = TUNING.CALORIES_HUGE
    inst.components.edible.sanityvalue = -TUNING.SANITY_MED

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("minotaurhorn", fn, assets)