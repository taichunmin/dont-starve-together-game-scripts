local assets =
{
    Asset("ANIM", "anim/cutstone.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("cutstone")
    inst.AnimState:SetBuild("cutstone")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("molebait")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("tradable")
    inst.components.tradable.rocktribute = 3

    inst:AddComponent("bait")

    inst:AddComponent("repairer")
    inst.components.repairer.repairmaterial = MATERIALS.STONE
    inst.components.repairer.healthrepairvalue = TUNING.REPAIR_CUTSTONE_HEALTH

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("cutstone", fn, assets)