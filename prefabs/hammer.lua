local assets =
{
    Asset("ANIM", "anim/hammer.zip"),
    Asset("ANIM", "anim/swap_hammer.zip"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_hammer", "swap_hammer")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("hammer")
    inst.AnimState:SetBuild("hammer")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("hammer")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.HAMMER_DAMAGE)

    inst:AddComponent("inventoryitem")
    -----
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.HAMMER)
    -------
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.HAMMER_USES)
    inst.components.finiteuses:SetUses(TUNING.HAMMER_USES)

    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetConsumption(ACTIONS.HAMMER, 1)
    -------

    MakeHauntableLaunch(inst)

    inst:AddComponent("inspectable")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    return inst
end

return Prefab("hammer", fn, assets)
