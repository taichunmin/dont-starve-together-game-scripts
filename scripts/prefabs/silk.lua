local assets =
{
    Asset("ANIM", "anim/silk.zip"),
}

local function CanUpgrade(inst, target, doer)
    return doer:HasTag("spiderwhisperer")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("silk")
    inst.AnimState:SetBuild("silk")
    inst.AnimState:PlayAnimation("idle")

    inst.pickupsound = "cloth"

    inst:AddTag("cattoy")

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("tradable")

    inst:AddComponent("upgrader")
    inst.components.upgrader.canupgradefn = CanUpgrade
    inst.components.upgrader.upgradetype = UPGRADETYPES.SPIDER

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("silk", fn, assets)