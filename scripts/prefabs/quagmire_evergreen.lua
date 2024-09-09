local assets =
{
    Asset("ANIM", "anim/evergreen_new_2.zip"), --build
    Asset("ANIM", "anim/evergreen_short_normal.zip"),
    Asset("ANIM", "anim/evergreen_tall_old.zip"),
    Asset("MINIMAP_IMAGE", "evergreen_lumpy"),
    Asset("MINIMAP_IMAGE", "evergreen_stump"),
}

local prefabs =
{
    "log",
    "pine_needles_chop",
}

local TREE_DEFS =
{
    {
        prefab_name = "quagmire_evergreen_small",
        anim_postfix = "_short",
    },
    {
        prefab_name = "quagmire_evergreen_normal",
        anim_postfix = "_normal",
    },
    {
        prefab_name = "quagmire_evergreen_tall",
        anim_postfix = "_tall",
    },
}

local function fn(treedef_id)
    local tree_def = treedef_id ~= nil and TREE_DEFS[treedef_id] or nil

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .25)

    inst.MiniMapEntity:SetIcon("evergreen_lumpy.png")
    inst.MiniMapEntity:SetPriority(-1)

    inst.Transform:SetScale(1.1, 1.1, 1.1)

    inst:AddTag("plant")
    inst:AddTag("tree")
    inst:AddTag("shelter")

    inst.AnimState:SetBank("evergreen_short")
    inst.AnimState:SetBuild("evergreen_new_2")
    inst.AnimState:PlayAnimation("sway1_loop"..(tree_def ~= nil and tree_def.anim_postfix or "_normal"), true)

    inst:SetPrefabNameOverride("evergreen_sparse")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_evergreen").master_postinit(inst, treedef_id)

    return inst
end

local function MakeTree(id, name, _assets, _prefabs)
    local function _fn()
        local inst = fn(id)

        if not TheWorld.ismastersim then
            return inst
        end

        event_server_data("quagmire", "prefabs/quagmire_evergreen").master_postinit_tree(inst)

        return inst
    end

    return Prefab(name, _fn, _assets, _prefabs)
end

local function MakeStump(name)
    local function _fn()
        local inst = fn(nil)

        if not TheWorld.ismastersim then
            return inst
        end

        event_server_data("quagmire", "prefabs/quagmire_evergreen").master_postinit_stump(inst)

        return inst
    end

    return Prefab(name, _fn)
end

local tree_prefabs = {}
for i, v in ipairs(TREE_DEFS) do
    table.insert(tree_prefabs, MakeTree(i, v.prefab_name))
    table.insert(prefabs, v.prefab_name)
end

table.insert(tree_prefabs, MakeStump("quagmire_evergreen_stump"))
table.insert(prefabs, "quagmire_evergreen_stump")

table.insert(tree_prefabs, MakeTree(nil, "quagmire_evergreen", assets, prefabs))

return unpack(tree_prefabs)
