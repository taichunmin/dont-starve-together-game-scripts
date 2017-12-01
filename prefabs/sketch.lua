local assets =
{
    Asset("ANIM", "anim/blueprint_sketch.zip"),
}

-- Note: The index is saved, always add to the end of the list! and never reorder!
local SKETCHES = 
{
    {item="chesspiece_pawn",        recipe="chesspiece_pawn_builder"},
    {item="chesspiece_rook",        recipe="chesspiece_rook_builder"},
    {item="chesspiece_knight",      recipe="chesspiece_knight_builder"},
    {item="chesspiece_bishop",      recipe="chesspiece_bishop_builder"},
    {item="chesspiece_muse",        recipe="chesspiece_muse_builder"},
    {item="chesspiece_formal",      recipe="chesspiece_formal_builder"},
    {item="chesspiece_deerclops",   recipe="chesspiece_deerclops_builder"},
    {item="chesspiece_bearger",     recipe="chesspiece_bearger_builder"},
    {item="chesspiece_moosegoose",  recipe="chesspiece_moosegoose_builder"},
    {item="chesspiece_dragonfly",   recipe="chesspiece_dragonfly_builder"},
}

local function onload(inst, data)
    if data ~= nil and data.sketchid ~= nil then
        inst.sketchid = data.sketchid
        inst.components.named:SetName(subfmt(STRINGS.NAMES.SKETCH, {item=STRINGS.NAMES[string.upper(SKETCHES[inst.sketchid].recipe)]}))
    end
end

local function onsave(inst, data)
    data.sketchid = inst.sketchid
end

local function GetRecipeName(inst)
    return SKETCHES[inst.sketchid].recipe
end

local function GetSpecificSketchPrefab(inst)
    return SKETCHES[inst.sketchid].item.."_sketch"
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("blueprint_sketch")
    inst.AnimState:SetBuild("blueprint_sketch")
    inst.AnimState:PlayAnimation("idle")

    --Sneak these into pristine state for optimization
    inst:AddTag("_named")
    inst:AddTag("sketch")

    inst:SetPrefabName("sketch")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Remove these tags so that they can be added properly when replicating components below
    inst:RemoveTag("_named")

    inst:AddComponent("named")
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    MakeHauntableLaunch(inst)

    inst.OnLoad = onload
    inst.OnSave = onsave

    inst.sketchid = 1

    inst.GetRecipeName = GetRecipeName
    inst.GetSpecificSketchPrefab = GetSpecificSketchPrefab

    return inst
end

local function MakeSketchPrefab(sketchid)
    return function()
        local inst = fn()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.sketchid = sketchid

        inst.components.named:SetName(subfmt(STRINGS.NAMES.SKETCH, {item=STRINGS.NAMES[string.upper(SKETCHES[sketchid].recipe)]}))
        return inst
    end
end

local prefabs = {}
table.insert(prefabs, Prefab("sketch", fn, assets))
for i, v in ipairs(SKETCHES) do
    table.insert(prefabs, Prefab(v.item.."_sketch", MakeSketchPrefab(i), assets))
end

return unpack(prefabs)
