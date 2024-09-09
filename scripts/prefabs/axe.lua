local assets =
{
    Asset("ANIM", "anim/axe.zip"),
    Asset("ANIM", "anim/swap_axe.zip"),
}

local golden_assets =
{
    Asset("ANIM", "anim/goldenaxe.zip"),
    Asset("ANIM", "anim/swap_goldenaxe.zip"),
}

local moonglass_assets =
{
    Asset("ANIM", "anim/glassaxe.zip"),
    Asset("ANIM", "anim/swap_glassaxe.zip"),
}

local function onequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_axe", inst.GUID, "swap_axe")
    else
        owner.AnimState:OverrideSymbol("swap_object", "swap_axe", "swap_axe")
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

    inst:AddTag("sharp")
    inst:AddTag("possessable_axe")

    --tool (from tool component) added to pristine state for optimization
    inst:AddTag("tool")

    if TheNet:GetServerGameMode() ~= "quagmire" then
        --weapon (from weapon component) added to pristine state for optimization
        inst:AddTag("weapon")
    end

    MakeInventoryFloatable(inst, "small", 0.05, {1.2, 0.75, 1.2})

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    -----
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.CHOP, 1)

    if TheNet:GetServerGameMode() ~= "quagmire" then
        -------
        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(TUNING.AXE_USES)
        inst.components.finiteuses:SetUses(TUNING.AXE_USES)
        inst.components.finiteuses:SetOnFinished(inst.Remove)
        inst.components.finiteuses:SetConsumption(ACTIONS.CHOP, 1)

        -------
        inst:AddComponent("weapon")
        inst.components.weapon:SetDamage(TUNING.AXE_DAMAGE)
    end

    inst:AddComponent("inspectable")

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
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_goldenaxe", inst.GUID, "swap_goldenaxe")
    else
        owner.AnimState:OverrideSymbol("swap_object", "swap_goldenaxe", "swap_goldenaxe")
    end
    owner.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onequip_moonglass(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_glassaxe", "swap_glassaxe")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onattack_moonglass(inst, attacker, target)
	inst.components.weapon.attackwear = target ~= nil and target:IsValid()
		and (target:HasTag("shadow") or target:HasTag("shadowminion") or target:HasTag("shadowchesspiece") or target:HasTag("stalker") or target:HasTag("stalkerminion"))
		and TUNING.MOONGLASSAXE.SHADOW_WEAR
		or TUNING.MOONGLASSAXE.ATTACKWEAR
end

local function normal()
    local inst = common_fn("axe", "axe")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.floater:SetBankSwapOnFloat(true, -11, {sym_build = "swap_axe"})

    return inst
end

local function golden()
    local inst = common_fn("goldenaxe", "goldenaxe")

    if not TheWorld.ismastersim then
        return inst
    end

	if inst.components.finiteuses ~= nil then
		inst.components.finiteuses:SetConsumption(ACTIONS.CHOP, 1 / TUNING.GOLDENTOOLFACTOR)
	end
	if inst.components.weapon ~= nil then
	    inst.components.weapon.attackwear = 1 / TUNING.GOLDENTOOLFACTOR
	end
    inst.components.equippable:SetOnEquip(onequipgold)

    inst.components.floater:SetBankSwapOnFloat(true, -11, {sym_build = "swap_goldenaxe"})

    return inst
end

local function moonglass()
    local inst = common_fn("glassaxe", "glassaxe")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.tool:SetAction(ACTIONS.CHOP, TUNING.MOONGLASSAXE.EFFECTIVENESS)

	if inst.components.finiteuses ~= nil then
	    inst.components.finiteuses:SetConsumption(ACTIONS.CHOP, TUNING.MOONGLASSAXE.CONSUMPTION)
	end
	if inst.components.weapon ~= nil then
		inst.components.weapon:SetDamage(TUNING.MOONGLASSAXE.DAMAGE)
		inst.components.weapon:SetOnAttack(onattack_moonglass)
	end
    inst.components.equippable:SetOnEquip(onequip_moonglass)

    local swap_data = {sym_build = "swap_glassaxe", bank = "glassaxe"}
    inst.components.floater:SetBankSwapOnFloat(true, -11, swap_data)

    return inst
end

return Prefab("axe", normal, assets),
    Prefab("goldenaxe", golden, golden_assets),
    Prefab("moonglassaxe", moonglass, moonglass_assets)
