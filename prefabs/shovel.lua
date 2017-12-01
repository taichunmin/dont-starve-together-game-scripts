local assets =
{
    Asset("ANIM", "anim/shovel.zip"),
    Asset("ANIM", "anim/goldenshovel.zip"),
    Asset("ANIM", "anim/swap_shovel.zip"),
    Asset("ANIM", "anim/swap_goldenshovel.zip"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_shovel", "swap_shovel")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function common_fn(bank, build)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -----
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.DIG)

    -------
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SHOVEL_USES)
    inst.components.finiteuses:SetUses(TUNING.SHOVEL_USES)
    inst.components.finiteuses:SetOnFinished(inst.Remove) 
    inst.components.finiteuses:SetConsumption(ACTIONS.DIG, 1)
    -------

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SHOVEL_DAMAGE)

    inst:AddInherentAction(ACTIONS.DIG)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    return inst
end

local function onequipgold(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_goldenshovel", "swap_goldenshovel")
    owner.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")     
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function normal()
    return common_fn("shovel", "shovel")
end

local function golden()
    local inst = common_fn("goldenshovel", "goldenshovel")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.finiteuses:SetConsumption(ACTIONS.DIG, 1 / TUNING.GOLDENTOOLFACTOR)
    inst.components.weapon.attackwear = 1 / TUNING.GOLDENTOOLFACTOR

    inst.components.equippable:SetOnEquip(onequipgold)

    return inst
end

return Prefab("shovel", normal, assets),
    Prefab("goldenshovel", golden, assets)
