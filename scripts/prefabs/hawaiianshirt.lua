local assets =
{
    Asset("ANIM", "anim/torso_hawaiian.zip"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "torso_hawaiian", "swap_body")
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
end

local function create()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("hawaiian_shirt")
    inst.AnimState:SetBuild("torso_hawaiian")
    inst.AnimState:PlayAnimation("anim")

    MakeInventoryPhysics(inst)

    inst:AddTag("show_spoilage")

    MakeInventoryFloatable(inst, "small", 0.1, 0.77)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.HAWAIIANSHIRT_PERISHTIME)
    inst.components.perishable:StartPerishing()
    inst.components.perishable:SetOnPerishFn(inst.Remove)

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)
    inst.components.insulator:SetSummer()

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("hawaiianshirt", create, assets)