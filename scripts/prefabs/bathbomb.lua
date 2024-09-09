local assets =
{
    Asset("ANIM", "anim/bath_bomb.zip"),
    Asset("INV_IMAGE", "bathbomb"),
}

local prefabs =
{
    "spoiled_food",
}

local function OnPickup(inst, pickupguy, src_pos)
    inst.components.perishable:StartPerishing()
end

local function bathbomb()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("bath_bomb")
    inst.AnimState:SetBuild("bath_bomb")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("show_spoilage")    -- To show spoilage as a bar instead of a percentage.

    MakeInventoryFloatable(inst, "small", 0.2)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
    MakeSmallPropagator(inst)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:SetOnPickupFn(OnPickup)

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

    inst:AddComponent("tradable")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL

    -- Since bath bombs are made of petals, they perish like petals as well.
    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("bathbomb")

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("bathbomb", bathbomb, assets, prefabs)
