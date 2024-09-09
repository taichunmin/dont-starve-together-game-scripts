local assets =
{
    Asset("ANIM", "anim/scandata.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:SetBank("scandata")
    inst.AnimState:SetBuild("scandata")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, nil, 0.1)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    ------------------------------------------------------------------
    inst:AddComponent("inventoryitem")

    ------------------------------------------------------------------
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    ------------------------------------------------------------------
    inst:AddComponent("inspectable")

    ------------------------------------------------------------------
    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)
    MakeHauntableLaunchAndIgnite(inst)

    return inst
end

return Prefab("scandata", fn, assets)
