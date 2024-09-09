local assets =
{
    Asset("ANIM", "anim/blueprint_sketch.zip"),
}

local SKETCHES =
{
    { item = "chesspiece_pawn",				recipe = "chesspiece_pawn_builder" },
    { item = "chesspiece_rook",				recipe = "chesspiece_rook_builder" },
    { item = "chesspiece_knight",			recipe = "chesspiece_knight_builder" },
    { item = "chesspiece_bishop",			recipe = "chesspiece_bishop_builder" },
    { item = "chesspiece_muse",				recipe = "chesspiece_muse_builder" },
    { item = "chesspiece_formal",			recipe = "chesspiece_formal_builder" },
    { item = "chesspiece_deerclops",		recipe = "chesspiece_deerclops_builder" },
    { item = "chesspiece_bearger",			recipe = "chesspiece_bearger_builder" },
    { item = "chesspiece_moosegoose",		recipe = "chesspiece_moosegoose_builder" },
    { item = "chesspiece_dragonfly",		recipe = "chesspiece_dragonfly_builder" },
    { item = "chesspiece_clayhound",		recipe = "chesspiece_clayhound_builder",		image = "chesspiece_clayhound_sketch" },
    { item = "chesspiece_claywarg",			recipe = "chesspiece_claywarg_builder",			image = "chesspiece_claywarg_sketch" },
    { item = "chesspiece_butterfly",		recipe = "chesspiece_butterfly_builder",		image = "chesspiece_butterfly_sketch" },
    { item = "chesspiece_anchor",			recipe = "chesspiece_anchor_builder",			image = "chesspiece_anchor_sketch" },
    { item = "chesspiece_moon",				recipe = "chesspiece_moon_builder",				image = "chesspiece_moon_sketch" },
    { item = "chesspiece_carrat",			recipe = "chesspiece_carrat_builder",			image = "chesspiece_carrat_sketch" },
    { item = "chesspiece_malbatross",		recipe = "chesspiece_malbatross_builder" },
    { item = "chesspiece_crabking",			recipe = "chesspiece_crabking_builder" },
    { item = "chesspiece_toadstool",		recipe = "chesspiece_toadstool_builder" },
    { item = "chesspiece_stalker",			recipe = "chesspiece_stalker_builder" },
    { item = "chesspiece_klaus",			recipe = "chesspiece_klaus_builder" },
    { item = "chesspiece_beequeen",			recipe = "chesspiece_beequeen_builder" },
    { item = "chesspiece_antlion",			recipe = "chesspiece_antlion_builder" },
    { item = "chesspiece_minotaur",			recipe = "chesspiece_minotaur_builder" },
    { item = "chesspiece_beefalo",			recipe = "chesspiece_beefalo_builder",			image = "chesspiece_beefalo_sketch" },
    { item = "chesspiece_guardianphase3",	recipe = "chesspiece_guardianphase3_builder",	image = "chesspiece_guardianphase3_sketch" },
    { item = "chesspiece_eyeofterror",		recipe = "chesspiece_eyeofterror_builder" },
    { item = "chesspiece_twinsofterror",	recipe = "chesspiece_twinsofterror_builder" },
    { item = "chesspiece_kitcoon",			recipe = "chesspiece_kitcoon_builder",			image = "chesspiece_kitcoon_sketch" },
    { item = "chesspiece_catcoon",			recipe = "chesspiece_catcoon_builder",			image = "chesspiece_catcoon_sketch" },
    { item = "chesspiece_manrabbit",        recipe = "chesspiece_manrabbit_builder",        image = "chesspiece_manrabbit_sketch" },
    { item = "chesspiece_daywalker",        recipe = "chesspiece_daywalker_builder",        image = "chesspiece_daywalker_sketch" },
    { item = "chesspiece_deerclops_mutated",recipe = "chesspiece_deerclops_mutated_builder" },
    { item = "chesspiece_warg_mutated",		recipe = "chesspiece_warg_mutated_builder" },
    { item = "chesspiece_bearger_mutated",	recipe = "chesspiece_bearger_mutated_builder" },
    { item = "chesspiece_yotd",				recipe = "chesspiece_yotd_builder",				image = "chesspiece_yotd_sketch" },
    { item = "chesspiece_sharkboi",         recipe = "chesspiece_sharkboi_builder" },
}

local function GetSketchID(item)
    for i, v in ipairs(SKETCHES) do
        if v.item == item then
            return i
        end
    end
end

local function GetSketchIDFromName(name)
    for i, v in ipairs(SKETCHES) do
        if name == subfmt(STRINGS.NAMES.SKETCH, { item = STRINGS.NAMES[string.upper(SKETCHES[i].recipe)] }) then
            return i
        end
    end
end

local function onload(inst, data)
    if not data then
        inst.sketchid = GetSketchIDFromName(inst.components.named.name) or 1
    else
        if data.sketchid then
            inst.sketchid = data.sketchid or 1
        elseif data.sketchitem then
            inst.sketchid = GetSketchID(data.sketchitem) or 1
        end
    end

    inst.components.named:SetName(subfmt(STRINGS.NAMES.SKETCH, { item = STRINGS.NAMES[string.upper(SKETCHES[inst.sketchid].recipe)] }))
    if SKETCHES[inst.sketchid].image ~= nil then
        inst.components.inventoryitem:ChangeImageName(SKETCHES[inst.sketchid].image)
    end
end

local function onsave(inst, data)
    data.sketchitem = SKETCHES[inst.sketchid].item
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

    MakeInventoryFloatable(inst, "med", nil, 0.75)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Remove these tags so that they can be added properly when replicating components below
    inst:RemoveTag("_named")

    inst:AddComponent("named")
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst:AddComponent("erasablepaper")

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

        inst.components.named:SetName(subfmt(STRINGS.NAMES.SKETCH, { item = STRINGS.NAMES[string.upper(SKETCHES[sketchid].recipe)] }))

        if SKETCHES[sketchid].image ~= nil then
            inst.components.inventoryitem:ChangeImageName(SKETCHES[sketchid].image)
        end

        return inst
    end
end

local ret = {}
table.insert(ret, Prefab("sketch", fn, assets))
for i, v in ipairs(SKETCHES) do
    local temp_assets = assets
    if v.image ~= nil then
        temp_assets = { Asset("INV_IMAGE", v.image) }
        for _, asset in ipairs(assets) do
            table.insert(temp_assets, asset)
        end
    end
    table.insert(ret, Prefab(v.item.."_sketch", MakeSketchPrefab(i), temp_assets))
end

return unpack(ret)
