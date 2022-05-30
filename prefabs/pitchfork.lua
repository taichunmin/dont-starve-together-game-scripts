local assets =
{
    Asset("ANIM", "anim/pitchfork.zip"),
    --Asset("ANIM", "anim/goldenpitchfork.zip"),
    Asset("ANIM", "anim/swap_pitchfork.zip"),
    --Asset("ANIM", "anim/swap_goldenpitchfork.zip"),
}

local prefabs =
{
    "sinkhole_spawn_fx_1",
    "sinkhole_spawn_fx_2",
    "sinkhole_spawn_fx_3",
}

local function onequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_pitchfork", inst.GUID, "swap_pitchfork")
    else
        owner.AnimState:OverrideSymbol("swap_object", "swap_pitchfork", "swap_pitchfork")
    end
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

--local function common_fn(bank, build)
local function normal()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    --inst.AnimState:SetBank(bank)
    --inst.AnimState:SetBuild(build)
    inst.AnimState:SetBank("pitchfork")
    inst.AnimState:SetBuild("pitchfork")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    MakeInventoryFloatable(inst, "med", 0.05, {0.78, 0.4, 0.78}, true, 7, {sym_build = "swap_pitchfork"})

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -------
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.PITCHFORK_USES)
    inst.components.finiteuses:SetUses(TUNING.PITCHFORK_USES)
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetConsumption(ACTIONS.TERRAFORM, .125)
    -------

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.PITCHFORK_DAMAGE)

    inst:AddInherentAction(ACTIONS.TERRAFORM)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("terraformer")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    return inst
end

--local function onequipgold(inst, owner)
    --owner.AnimState:OverrideSymbol("swap_object", "swap_goldenpitchfork", "swap_goldenpitchfork")
    --owner.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")
    --owner.AnimState:Show("ARM_carry")
    --owner.AnimState:Hide("ARM_normal")
--end

--local function normal()
    --return common_fn("pitchfork", "pitchfork")
--end

--local function golden()
    --local inst = common_fn("pitchfork", "goldenpitchfork")

    --if not TheWorld.ismastersim then
        --return inst
    --end

    --inst.components.finiteuses:SetConsumption(ACTIONS.TERRAFORM, .125 / TUNING.GOLDENTOOLFACTOR)
    --inst.components.weapon.attackwear = 1 / TUNING.GOLDENTOOLFACTOR
    --inst.components.researchvalue.basevalue = TUNING.RESEARCH_VALUE_GOLD_TOOL

    --inst.components.equippable:SetOnEquip(onequipgold)

    --return inst
--end

return Prefab("pitchfork", normal, assets, prefabs)--,
    --Prefab("goldenpitchfork", golden, assets, prefabs)
