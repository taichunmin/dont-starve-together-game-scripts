local assets =
{
    Asset("ANIM", "anim/thulecite.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("thulecite")
    inst.AnimState:SetBuild("thulecite")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("molebait")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("repairer")
    inst.components.repairer.repairmaterial = MATERIALS.THULECITE
    inst.components.repairer.workrepairvalue = TUNING.REPAIR_THULECITE_WORK
    inst.components.repairer.healthrepairvalue = TUNING.REPAIR_THULECITE_HEALTH

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.ELEMENTAL
    inst.components.edible.hungervalue = 3

    inst:AddComponent("tradable")
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("stackable")

    MakeHauntableLaunchAndSmash(inst)

    inst:AddComponent("bait")

    return inst
end

return Prefab("thulecite", fn, assets)