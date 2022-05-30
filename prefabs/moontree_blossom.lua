local assets =
{
    Asset("ANIM", "anim/moon_tree_petal.zip"),
}

local prefabs =
{
	"moon_tree_blossom_worldgen",
}

local function OnPickup(inst, pickupguy, src_pos)
    inst.components.perishable:StartPerishing()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst) -- so it can be dropped as loot

    inst.AnimState:SetBank("moon_tree_petal")
    inst.AnimState:SetBuild("moon_tree_petal")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetRayTestOnBB(true)

    inst:AddTag("cattoy")
    inst:AddTag("vasedecoration")

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:SetOnPickupFn(OnPickup)

    inst:AddComponent("vasedecoration")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = 0
    inst.components.edible.foodtype = FOODTYPE.VEGGIE

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)

	MakeHauntableLaunch(inst)

    return inst
end

local function ground_fn()
	local inst = fn()

    inst:SetPrefabName("moon_tree_blossom")

    if not TheWorld.ismastersim then
        return inst
    end

	inst.components.perishable:StopPerishing()
	return inst
end

return Prefab("moon_tree_blossom", fn, assets, prefabs),
	Prefab("moon_tree_blossom_worldgen", ground_fn, assets)
