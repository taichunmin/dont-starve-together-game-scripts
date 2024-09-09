local assets =
{
    Asset("ANIM", "anim/seedpouch.zip"),
    Asset("ANIM", "anim/ui_krampusbag_2x8.zip"),
}

local prefabs =
{
    "ash",
}

local function onequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("backpack", skin_build, "backpack", inst.GUID, "seedpouch" )
        owner.AnimState:OverrideItemSkinSymbol("swap_body", skin_build, "swap_body", inst.GUID, "seedpouch" )
    else
        owner.AnimState:OverrideSymbol("backpack", "seedpouch", "backpack")
        owner.AnimState:OverrideSymbol("swap_body", "seedpouch", "swap_body")
    end
    inst.components.container:Open(owner)
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("backpack")
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst.components.container:Close(owner)
end

local function onequiptomodel(inst, owner)
    inst.components.container:Close(owner)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("seedpouch")
    inst.AnimState:SetBuild("seedpouch")
    inst.AnimState:PlayAnimation("anim")

    inst.foleysound = "dontstarve/movement/foley/backpack"

    inst:AddTag("backpack")

    local swap_data = {bank = "seedpouch", anim = "anim"}
    MakeInventoryFloatable(inst, "med", 0.125, 0.65, nil, nil, swap_data)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.cangoincontainer = false

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("seedpouch")

	inst:AddComponent("preserver")
	inst.components.preserver:SetPerishRateMultiplier(TUNING.SEEDPOUCH_PRESERVER_RATE)

    MakeHauntableLaunchAndDropFirstItem(inst)

    return inst
end

return Prefab("seedpouch", fn, assets, prefabs)
