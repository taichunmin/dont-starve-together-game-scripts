local assets =
{
    Asset("ANIM", "anim/pocket_scale.zip"),
}

local function doweight(inst, target, doer)
	if inst.components.finiteuses then
		inst.components.finiteuses:Use(1)
	end
	return true
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("pocket_scale")
    inst.AnimState:SetBuild("pocket_scale")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "small", 0.0, 0.8)

	inst:AddTag("trophyscale_fish")
    inst:AddTag("donotautopick")

    inst.scrapbook_specialinfo = "POCKETSCALE"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.POCKETSCALE_USES)
    inst.components.finiteuses:SetUses(TUNING.POCKETSCALE_USES)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

	inst:AddComponent("itemweigher")
	inst.components.itemweigher.type = TROPHYSCALE_TYPES.FISH
	inst.components.itemweigher:SetOnDoWeighInFn(doweight)

    inst:AddComponent("inventoryitem")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.TINY_FUEL

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    MakeHauntableLaunchAndIgnite(inst)

    return inst
end

return Prefab("pocket_scale", fn, assets)
