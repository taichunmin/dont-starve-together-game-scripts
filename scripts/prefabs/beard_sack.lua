local assets =
{
    Asset("ANIM", "anim/backpack.zip"),
    Asset("ANIM", "anim/swap_krampus_sack.zip"),
}

local function onequip(inst, owner)
    inst.components.container:Open(owner)
end

local function onunequip(inst, owner)
    inst.components.container:Close(owner)
end
--[[
local function onequiptomodel(inst, owner)
    inst.components.container:Close(owner)
end
]]

local function fn_common()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("backpack1")
    inst.AnimState:SetBuild("swap_krampus_sack")
    inst.AnimState:PlayAnimation("anim")

    --inst.foleysound = "dontstarve/movement/foley/krampuspack"

    return inst
end

local function fn_mastersim(inst, widgetsetupname)
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.cangoincontainer = false

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BEARD
    inst.components.equippable:SetPreventUnequipping(true)
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup(widgetsetupname) 
    inst.components.container.skipopensnd = true
    inst.components.container.skipclosesnd = true
    inst.components.container.stay_open_on_hide = true

    MakeHauntableLaunchAndDropFirstItem(inst)
end

local function fn1()
    local inst = fn_common()

    inst:AddTag("beard_sack_1")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    fn_mastersim(inst, "beard_sack_1")

    return inst
end

local function fn2()
    local inst = fn_common()
    
    inst:AddTag("beard_sack_2")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    fn_mastersim(inst, "beard_sack_2")

    return inst
end

local function fn3()
    local inst = fn_common()
    
    inst:AddTag("beard_sack_3")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    fn_mastersim(inst, "beard_sack_3")

    return inst
end

return Prefab("beard_sack_1", fn1, assets),
       Prefab("beard_sack_2", fn2, assets),
       Prefab("beard_sack_3", fn3, assets)
