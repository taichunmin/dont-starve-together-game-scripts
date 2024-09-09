local assets =
{
    Asset("ANIM", "anim/shovel.zip"),
    Asset("ANIM", "anim/goldenshovel.zip"),
    Asset("ANIM", "anim/swap_shovel.zip"),
    Asset("ANIM", "anim/swap_goldenshovel.zip"),
}

local function onequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_shovel", inst.GUID, "swap_shovel")
    else
        owner.AnimState:OverrideSymbol("swap_object", "swap_shovel", "swap_shovel")
    end
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end
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

    --tool (from tool component) added to pristine state for optimization
    inst:AddTag("tool")

    if TheNet:GetServerGameMode() ~= "quagmire" then
        --weapon (from weapon component) added to pristine state for optimization
        inst:AddTag("weapon")
    end

    MakeInventoryFloatable(inst, "med", 0.05, {0.8, 0.4, 0.8})

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -----
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.DIG)

    if TheNet:GetServerGameMode() ~= "quagmire" then
        -------
        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(TUNING.SHOVEL_USES)
        inst.components.finiteuses:SetUses(TUNING.SHOVEL_USES)
        inst.components.finiteuses:SetOnFinished(inst.Remove)
        inst.components.finiteuses:SetConsumption(ACTIONS.DIG, 1)

        -------
        inst:AddComponent("weapon")
        inst.components.weapon:SetDamage(TUNING.SHOVEL_DAMAGE)
    end

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
	local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_goldenshovel", inst.GUID, "swap_goldenshovel")
    else
        owner.AnimState:OverrideSymbol("swap_object", "swap_goldenshovel", "swap_goldenshovel")
    end
    owner.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function normal()
    local inst = common_fn("shovel", "shovel")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.floater:SetBankSwapOnFloat(true, 7, {sym_build = "swap_shovel"})

    return inst
end

local function golden()
    local inst = common_fn("goldenshovel", "goldenshovel")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.finiteuses:SetConsumption(ACTIONS.DIG, 1 / TUNING.GOLDENTOOLFACTOR)
    inst.components.weapon.attackwear = 1 / TUNING.GOLDENTOOLFACTOR

    inst.components.equippable:SetOnEquip(onequipgold)

    inst.components.floater:SetBankSwapOnFloat(true, 7, {sym_build = "swap_goldenshovel"})

    return inst
end

return Prefab("shovel", normal, assets),
    Prefab("goldenshovel", golden, assets)
