local PLANT_DEFS = require("prefabs/farm_plant_defs").PLANT_DEFS
local WEED_DEFS = require("prefabs/weed_defs").WEED_DEFS
local ANCIENT_TREE_DEFS = require("prefabs/ancienttree_defs").TREE_DEFS

-------------------------------------------------------------------------------------------------

local assets =
{
    Asset("ANIM", "anim/plant_spray.zip"),
}

local prefabs = {
    "berrybush",
    "berrybush2",
    "berrybush_juicy",

    "grass",
    "sapling",
    "sapling_moon",
    "bananabush",
    "marbleshrub",
    "monkeytail",
    "rock_avocado_bush",
    "marsh_bush",
    "oceantree",

    "dug_berrybush",
    "dug_berrybush2",
    "dug_berrybush_juicy",
    "dug_sapling",
    "dug_sapling_moon",
    "dug_grass",
    "dug_marsh_bush",
    "dug_rock_avocado_bush",
    "dug_bananabush",
    "dug_monkeytail",

    "evergreen",
    "evergreen_sparse",
    "twiggytree",
    "deciduoustree",
    "moon_tree",
    "palmconetree",

    "pinecone_sapling",
    "lumpy_sapling",
    "acorn_sapling",
    "twiggy_nut_sapling",
    "marblebean_sapling",
    "moonbutterfly_sapling",
    "palmcone_sapling",
}

for i, data in pairs(PLANT_DEFS) do
    table.insert(prefabs, data.prefab)
end

for i, data in pairs(WEED_DEFS) do
    table.insert(prefabs, data.prefab)
end

for type, data in pairs(ANCIENT_TREE_DEFS) do
    table.insert(prefabs, "ancienttree_"..type)
    table.insert(prefabs, "ancienttree_"..type.."_sapling")
end

for i, prefab in ipairs(prefabs) do
    prefabs[i] = prefab.."_waxed"
end

table.insert(prefabs, "beeswax_spray_fx")

-------------------------------------------------------------------------------------------------

local OVERRIDE_BUILD, OVERRIDE_SYMBOL = "plant_spray", "swap_plant_spray"

local function OnEquip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, OVERRIDE_BUILD, inst.GUID, OVERRIDE_SYMBOL)
    else
        owner.AnimState:OverrideSymbol("swap_object", OVERRIDE_BUILD, OVERRIDE_SYMBOL)
    end

    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function OnUnequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end

    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

-------------------------------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBuild("plant_spray")
    inst.AnimState:SetBank("plant_spray")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "small", 0.25, 0.85)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst:AddComponent("inspectable")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    inst:AddComponent("wax")
    inst.components.wax:SetIsSpray()

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.BEESWAX_SPRAY_USES)
    inst.components.finiteuses:SetUses(TUNING.BEESWAX_SPRAY_USES)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("beeswax_spray", fn, assets, prefabs)
