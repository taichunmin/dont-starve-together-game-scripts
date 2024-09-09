local assets = {
    Asset("ANIM", "anim/chestupgrade_stacksize.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("chestupgrade_stacksize")
    inst.AnimState:SetBuild("chestupgrade_stacksize")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "med", nil, 0.68)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("tradable")

    inst:AddComponent("inspectable")

    local inventoryitem = inst:AddComponent("inventoryitem")
    inventoryitem:SetSinks(false)

    local upgrader = inst:AddComponent("upgrader")
    upgrader.upgradetype = UPGRADETYPES.CHEST

    MakeHauntableLaunchAndSmash(inst)

    return inst
end

return Prefab("chestupgrade_stacksize", fn, assets)