local assets =
{
    Asset("ANIM", "anim/bulb.zip"),
}

local function OnDropped(inst)
    inst.Light:Enable(true)
end

local function OnPickup(inst)
    inst.Light:Enable(false)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("bulb")
    inst.AnimState:SetBuild("bulb")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.pickupsound = "vegetation_firm"

    inst.Light:SetFalloff(0.7)
    inst.Light:SetIntensity(.5)
    inst.Light:SetRadius(0.5)
    inst.Light:SetColour(237/255, 237/255, 209/255)
    inst.Light:Enable(true)

    inst:AddTag("lightbattery")
    inst:AddTag("vasedecoration")
    inst:AddTag("light")

    MakeInventoryFloatable(inst, "small", 0.07, 0.73)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("tradable")
    inst:AddComponent("vasedecoration")
    inst:AddComponent("inspectable")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_LARGE_FUEL
    inst.components.fuel.fueltype = FUELTYPE.CAVE

    MakeSmallBurnable(inst, TUNING.TINY_BURNTIME)
    MakeSmallPropagator(inst)
    MakeHauntableLaunchAndIgnite(inst)

    inst:AddComponent("inventoryitem")

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = 0
    inst.components.edible.foodtype = FOODTYPE.VEGGIE

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPickupFn(OnPickup)

	inst:AddComponent("halloweenmoonmutable")
	inst.components.halloweenmoonmutable:SetPrefabMutated("lightflier")

    return inst
end

return Prefab("lightbulb", fn, assets)