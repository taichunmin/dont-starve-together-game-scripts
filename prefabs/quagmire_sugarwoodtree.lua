local assets =
{
    Asset("ANIM", "anim/quagmire_sapbucket.zip"),
    Asset("ANIM", "anim/quagmire_tree_cotton_build.zip"),
    Asset("ANIM", "anim/quagmire_tree_cotton_trunk_build.zip"),
    Asset("MINIMAP_IMAGE", "quagmire_sugarwoodtree"),
    Asset("MINIMAP_IMAGE", "quagmire_sugarwoodtree_stump"),
    Asset("MINIMAP_IMAGE", "quagmire_sugarwoodtree_tapped"),
}

local prefabs =
{
    "log",
    "twigs",
    "quagmire_sap",
    "quagmire_sap_spoiled",
    "sugarwood_leaf_fx",
    "sugarwood_leaf_fx_chop",
    "sugarwood_leaf_withered_fx",
    "sugarwood_leaf_withered_fx_chop",
}

local DEFAULT_TREE_DEF = 2
local TREE_DEFS =
{
    {
        prefab_name = "quagmire_sugarwoodtree_small",
        anim_file = "quagmire_tree_cotton_short",
    },
    {
        prefab_name = "quagmire_sugarwoodtree_normal",
        anim_file = "quagmire_tree_cotton_normal",
    },
    {
        prefab_name = "quagmire_sugarwoodtree_tall",
        anim_file = "quagmire_tree_cotton_tall",
    },
}

for i, v in ipairs(TREE_DEFS) do
    table.insert(assets, Asset("ANIM", "anim/"..v.anim_file..".zip"))
end

--Remove CHOP action from RMB so this tree can have harvets/tap actions while equipping axe
local function _IsActionValid(inst, action, right)
    return (not right or action ~= ACTIONS.CHOP) and EntityScript.IsActionValid(inst, action, right)
end

local function fn(tree_def)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .25)

    inst.MiniMapEntity:SetIcon("quagmire_sugarwoodtree.png")
    inst.MiniMapEntity:SetPriority(-1)

    inst.Transform:SetScale(0.8, 0.8, 0.8)

    inst:AddTag("plant")
    inst:AddTag("tree")
    inst:AddTag("shelter")
    inst:AddTag("sugarwoodtree")
    inst:AddTag("tappable")

    inst.AnimState:SetBank(TREE_DEFS[tree_def or DEFAULT_TREE_DEF].anim_file)
    inst.AnimState:SetBuild("quagmire_tree_cotton_build")
    inst.AnimState:AddOverrideBuild("quagmire_sapbucket")
    inst.AnimState:AddOverrideBuild("quagmire_tree_cotton_trunk_build")
    inst.AnimState:Hide("swap_tapper")
    inst.AnimState:Hide("sap") -- wounded sap marks
    inst.AnimState:PlayAnimation("sway1_loop", true)

    MakeSnowCoveredPristine(inst)

    inst.IsActionValid = _IsActionValid

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_sugarwoodtree").master_postinit(inst, tree_def, TREE_DEFS)

    return inst
end

local function MakeTree(i, name, _assets, _prefabs)
    local function _fn()
        local inst = fn(i)
        if not TheWorld.ismastersim then
            return inst
        end
        inst:SetPrefabName("quagmire_sugarwoodtree")
        return inst
    end

    return Prefab(name, _fn, _assets, _prefabs)
end

local tree_prefabs = {}
for i, v in ipairs(TREE_DEFS) do
    table.insert(tree_prefabs, MakeTree(i, v.prefab_name))
    table.insert(prefabs, v.prefab_name)
end

table.insert(tree_prefabs, MakeTree(nil, "quagmire_sugarwoodtree", assets, prefabs))

return unpack(tree_prefabs)
