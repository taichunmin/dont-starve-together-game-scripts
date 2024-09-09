local assets =
{
    Asset("ANIM", "anim/feather_pencil.zip"),
}

local function OnDrawFn(inst)--, target, image, src, atlas, bgimage, bgatlas)
    inst.components.stackable:Get():Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("feather_pencil")
    inst.AnimState:SetBuild("feather_pencil")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("cattoy")

    MakeInventoryFloatable(inst, "med", 0.15, 0.65)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -----------------
    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

    -----------------
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    ---------------------
    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    MakeHauntableLaunchAndIgnite(inst)

    inst:AddComponent("inspectable")
    ----------------------
    inst:AddComponent("drawingtool")
    inst.components.drawingtool:SetOnDrawFn(OnDrawFn)

    return inst
end

return Prefab("featherpencil", fn, assets)
