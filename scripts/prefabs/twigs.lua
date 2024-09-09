local assets =
{
    Asset("ANIM", "anim/twigs.zip"),
    Asset("SOUND", "sound/common.fsb"),
}

local prefabs =
{
	"oceanfishingbobber_twig_projectile",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("twigs")
    inst.AnimState:SetBuild("twigs")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("cattoy")
    inst:AddTag("renewable")
	inst:AddTag("oceanfishing_bobber")
    inst:AddTag("twigs")

    MakeInventoryFloatable(inst, "med", nil, 0.68)

    inst.entity:SetPristine()

    inst.pickupsound = "wood"

    if not TheWorld.ismastersim then
        return inst
    end

    -----------------
    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    inst:AddComponent("tradable")

    -----------------
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.ROUGHAGE
	inst.components.edible.secondaryfoodtype = FOODTYPE.WOOD
    inst.components.edible.healthvalue = TUNING.HEALING_TINY/2
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY

    ---------------------
    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    MakeHauntableLaunchAndIgnite(inst)

    inst:AddComponent("inspectable")
    ----------------------

    inst:AddComponent("repairer")
    inst.components.repairer.repairmaterial = MATERIALS.WOOD
    inst.components.repairer.healthrepairvalue = TUNING.REPAIR_STICK_HEALTH
    inst.components.repairer.boatrepairsound = "turnoftides/common/together/boat/repair_with_wood"

	inst:AddComponent("oceanfishingtackle")
	inst.components.oceanfishingtackle:SetCastingData(TUNING.OCEANFISHING_TACKLE.BOBBER_TWIG, "oceanfishingbobber_twig_projectile")

    if TheNet:GetServerGameMode() == "quagmire" then
        event_server_data("quagmire", "prefabs/twigs").master_postinit(inst)
    end

    return inst
end

return Prefab("twigs", fn, assets, prefabs)
