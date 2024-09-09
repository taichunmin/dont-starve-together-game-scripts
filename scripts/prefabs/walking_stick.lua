local assets =
{
    Asset("ANIM", "anim/walking_stick.zip"),
}

local function OnEquip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "walking_stick", inst.GUID, "swap_walking_stick")
    else
        owner.AnimState:OverrideSymbol("swap_object", "walking_stick", "swap_walking_stick")
    end

    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    inst.components.fueled:StartConsuming()
end

local function OnUnequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end

    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    inst.components.fueled:StopConsuming()
end

local function OnEquipToModel(inst, owner, from_ground)
    if inst.components.fueled ~= nil then
        inst.components.fueled:StopConsuming()
    end
end

local floatable_swap_data = {sym_build = "walking_stick", sym_name = "swap_walking_stick"}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("walking_stick")
    inst.AnimState:SetBuild("walking_stick")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "med", 0.05, {0.95, 0.40, 0.95}, true, 1, floatable_swap_data)

    inst.scrapbook_specialinfo = "WALKINGSTICK"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_animoffsetx = 30

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.USAGE
    inst.components.fueled.no_sewing = true
    inst.components.fueled:SetDepletedFn(inst.Remove)
    inst.components.fueled:InitializeFuelLevel(TUNING.WALKING_STICK_PERISHTIME)

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("equippable")

    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable:SetOnEquipToModel(OnEquipToModel)
    inst.components.equippable.walkspeedmult = TUNING.WALKING_STICK_SPEED_MULT

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("walking_stick", fn, assets)
