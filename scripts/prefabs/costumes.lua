local assets =
{
    Asset("ANIM", "anim/costume_blacksmith_body.zip"),
    Asset("ANIM", "anim/costume_doll_body.zip"),
    Asset("ANIM", "anim/costume_fool_body.zip"),
    Asset("ANIM", "anim/costume_king_body.zip"),
    Asset("ANIM", "anim/costume_queen_body.zip"),
    Asset("ANIM", "anim/costume_mirror_body.zip"),
    Asset("ANIM", "anim/costume_tree_body.zip"),
}

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")

    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end
end

local function makecostume(name)

    local function onequip(inst, owner)
        local skin_build = inst:GetSkinBuild()

        if skin_build ~= nil then
            owner:PushEvent("equipskinneditem", inst:GetSkinName())
            owner.AnimState:OverrideItemSkinSymbol("swap_body", skin_build, "swap_body", inst.GUID, name)
        else
            owner.AnimState:OverrideSymbol("swap_body", name, "swap_body")
        end
    end

    local COSTUME_FLOATER_SWAPDATA = {bank = name, anim = "anim"}
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("anim")

        inst.foleysound = "dontstarve/movement/foley/logarmour"

        MakeInventoryFloatable(inst, "small", nil, nil, nil, nil, COSTUME_FLOATER_SWAPDATA)

        inst.scrapbook_specialinfo = "COSTUME"

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.BODY
        inst.components.equippable:SetOnEquip(onequip)
        inst.components.equippable:SetOnUnequip(onunequip)

        MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
        MakeSmallPropagator(inst)

        MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab(name, fn, assets)
end

return  makecostume("costume_doll_body"),
        makecostume("costume_queen_body"),
        makecostume("costume_king_body"),
        makecostume("costume_blacksmith_body"),
        makecostume("costume_mirror_body"),
        makecostume("costume_tree_body"),
        makecostume("costume_fool_body")