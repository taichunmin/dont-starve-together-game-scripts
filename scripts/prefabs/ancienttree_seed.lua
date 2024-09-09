local ancienttree_defs = require("prefabs/ancienttree_defs")
local TREE_DEFS  = ancienttree_defs.TREE_DEFS
local PLANT_DATA = ancienttree_defs.PLANT_DATA

require "prefabutil" -- For the MakePlacer function.

local assets =
{
    Asset("ANIM", "anim/ancienttree_seed.zip"),
    Asset("SCRIPT", "scripts/prefabs/ancienttree_defs.lua"),
}

local prefabs =
{
    "ancienttree_seed_placer",
    "ancienttree_gem",
    "ancienttree_nightvision",
}

local function OnDeploy(inst, pt, deployer)
    -- Making sure type and _plantdata are not nil somehow.
    if inst.type == nil then
        inst:SetType(GetRandomItemWithIndex(TREE_DEFS))
    end

    if inst._plantdata == nil then
        inst:RandomizePlantData()
    end

    local sapling = SpawnPrefab("ancienttree_"..inst.type.."_sapling")
    sapling.Transform:SetPosition(pt:Get())
    sapling.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")

    sapling.components.growable:StartGrowing()
    inst:TransferPlantData(sapling)

    inst:Remove()
end

local function RandomizePlantData(inst)
    inst._plantdata = {}

    for attr, data in pairs(PLANT_DATA) do
        inst._plantdata[attr] = GetRandomMinMax(data.min, data.max)
    end
end

local function TransferPlantData(inst, target)
    target._plantdata = inst._plantdata
end

local function SetType(inst, type)
    inst.type = type
end

local function OnSave(inst, data)
    data.type = inst.type
    data.plantdata = inst._plantdata
end

local function OnLoad(inst, data)
    if data == nil then
        return
    end

    if data.type ~= nil then
        inst:SetType(data.type)
    end

    if data.plantdata ~= nil then
        inst:SetPlantData(data.plantdata)
    end
end

local function SetPlantData(inst, data)
    inst._plantdata = data
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("ancienttree_seed")
    inst.AnimState:SetBuild("ancienttree_seed")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("treeseed")
    inst:AddTag("deployedplant")

    MakeInventoryFloatable(inst, "small", 0.25, {.75, .9, .9})

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.SetType = SetType
    inst.SetPlantData = SetPlantData
    inst.RandomizePlantData = RandomizePlantData
    inst.TransferPlantData = TransferPlantData

    if not POPULATING then
        inst:SetType(GetRandomItemWithIndex(TREE_DEFS))
        inst:RandomizePlantData()
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("deployable")
    inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.PLACER_DEFAULT)
    inst.components.deployable.ondeploy = OnDeploy

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    MakeHauntableLaunch(inst)

    return inst
end

return
    Prefab("ancienttree_seed", fn, assets, prefabs),
    MakePlacer("ancienttree_seed_placer", "ancienttree_seed", "ancienttree_seed", "idle_planted")
