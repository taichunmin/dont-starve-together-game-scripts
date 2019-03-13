local assets_soil =
{
    Asset("ANIM", "anim/quagmire_soil.zip"),
}

local assets_seeds =
{
    Asset("ANIM", "anim/quagmire_seeds.zip"),
}

--------------------------------------------------------------------------

local PRODUCT_VALUES =
{
    ["turnip"] =
    {
        raw = {},
        cooked = {},
        leaf = 1,
        bulb = 1,
    },

    ["garlic"] =
    {
        raw = {},
        cooked = {},
        leaf = 1,
        bulb = 1,
    },

    ["onion"] =
    {
        raw = {},
        cooked = {},
        leaf = 1,
        bulb = 1,
    },

    ["carrot"] =
    {
        raw = { prefab_override = "carrot" },
        cooked = { prefab_override = "carrot_cooked" },
        leaf = 1,
        bulb = 1,
    },

    ["potato"] =
    {
        raw = {},
        cooked = {},
        leaf = 2,
        bulb = 2,
    },

    ["tomato"] =
    {
        raw = {},
        cooked = {},
        leaf = 2,
        bulb = 2,
    },

    ["wheat"] =
    {
        raw = { show_spoilage = true },
        cooked = nil,
        leaf = 3,
        bulb = 3,
    },
}

--------------------------------------------------------------------------

local function MakeSeed(id, planted_prefabs)
    local assets =
    {
        Asset("ANIM", "anim/quagmire_seeds.zip"),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("quagmire_seeds")
        inst.AnimState:SetBuild("quagmire_seeds")
        inst.AnimState:PlayAnimation("seeds_"..tostring(id))
        inst.AnimState:SetRayTestOnBB(true)

        --cookable (from cookable component) added to pristine state for optimization
        inst:AddTag("cookable")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        event_server_data("quagmire", "prefabs/quagmire_plantables").master_postinit_seed(inst, id)

        return inst
    end

    return Prefab("quagmire_seeds_"..tostring(id), fn, assets_seeds, planted_prefabs)
end

--------------------------------------------------------------------------

local VARIATIONS = 3

local function SetLeafVariation(inst, leafvariation)
    for i = 1, VARIATIONS do
        if i ~= leafvariation then
            inst.AnimState:Hide("crop_leaf"..tostring(i))
        end
    end
end

local function SetBulbVariation(inst, bulbvariation)
    for i = 1, VARIATIONS do
        if i ~= bulbvariation then
            inst.AnimState:Hide("crop_bulb"..tostring(i))
        end
    end
end

--------------------------------------------------------------------------

local function OnRottenDirty(inst)
    inst:SetPrefabNameOverride(inst._rotten:value() and "quagmire_rotten_crop" or "plant_normal")
end

local function MakePlanted(product, bulbvariation)
    local assets =
    {
        Asset("ANIM", "anim/quagmire_crop_"..product..".zip"),
        Asset("ANIM", "anim/quagmire_soil.zip"),
    }

    local prefabs =
    {
        "quagmire_soil",
        "quagmire_planted_soil_front",
        "quagmire_planted_soil_back",
        "quagmire_"..product.."_leaf",
        "quagmire_"..product,
        "spoiled_food",
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("quagmire_soil")
        inst.AnimState:SetBuild("quagmire_crop_"..product)
        inst.AnimState:PlayAnimation("grow_small")
        inst.AnimState:SetLayer(LAYER_BACKGROUND)
        inst.AnimState:SetSortOrder(3)
        inst.AnimState:SetFinalOffset(1)

        SetLeafVariation(inst, nil)
        SetBulbVariation(inst, bulbvariation)
        inst.AnimState:Hide("soil_back")
        inst.AnimState:Hide("soil_front")
        inst.AnimState:Hide("mouseover")
        inst.AnimState:OverrideSymbol("mouseover", "quagmire_soil", "mouseover")

        inst:AddTag("plantedsoil")
        inst:AddTag("fertilizable")

        inst._rotten = net_bool(inst.GUID, "quagmire_"..product.."_planted._rotten", "rottendirty")
        OnRottenDirty(inst)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            inst:ListenForEvent("rottendirty", OnRottenDirty)

            return inst
        end

        event_server_data("quagmire", "prefabs/quagmire_plantables").master_postinit_planted(inst, product, OnRottenDirty)

        return inst
    end

    return Prefab("quagmire_"..product.."_planted", fn, assets, prefabs)
end

--------------------------------------------------------------------------

local function OnLeafReplicated(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil and (parent.prefab == inst.prefab:sub(1, -6).."_planted") then
        parent.highlightchildren = { inst }
    end
end

local function MakeLeaf(product, leafvariation)
    local assets =
    {
        Asset("ANIM", "anim/quagmire_crop_"..product..".zip"),
        Asset("ANIM", "anim/quagmire_soil.zip"),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("quagmire_soil")
        inst.AnimState:SetBuild("quagmire_crop_"..product)
        inst.AnimState:PlayAnimation("grow_small")
        inst.AnimState:SetFinalOffset(3)

        SetLeafVariation(inst, leafvariation)
        SetBulbVariation(inst, nil)
        inst.AnimState:Hide("soil_back")
        inst.AnimState:Hide("soil_front")

        inst:AddTag("FX")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            inst.OnEntityReplicated = OnLeafReplicated

            return inst
        end

        inst.persists = false

        return inst
    end

    return Prefab("quagmire_"..product.."_leaf", fn, assets)
end

--------------------------------------------------------------------------

local function MakeSoilFn(front)
    return function()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("quagmire_soil")
        inst.AnimState:SetBuild("quagmire_soil")
        inst.AnimState:PlayAnimation("grow_small")
        inst.AnimState:SetLayer(LAYER_BACKGROUND)
        inst.AnimState:SetSortOrder(3)
        if front then
            inst.AnimState:SetFinalOffset(2)
        end

        SetLeafVariation(inst, nil)
        SetBulbVariation(inst, nil)
        inst.AnimState:Hide("mouseover")
        inst.AnimState:Hide(front and "soil_back" or "soil_front")

        inst:AddTag("DECOR")
        inst:AddTag("NOCLICK")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false

        return inst
    end
end

--------------------------------------------------------------------------

local function MakeRawProduct(product)
    local params = PRODUCT_VALUES[product].raw
    local cancook = PRODUCT_VALUES[product].cooked ~= nil

    local assets =
    {
        Asset("ANIM", "anim/quagmire_crop_"..product..".zip"),
    }

    if params.prefab_override ~= nil then
        table.insert(assets, Asset("INV_IMAGE", params.prefab_override))
    end

    local prefabs =
    {
        "spoiled_food",
    }
    if cancook then
        table.insert(prefabs, "quagmire_"..product.."_cooked")
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("quagmire_crop_"..product)
        inst.AnimState:SetBuild("quagmire_crop_"..product)
        inst.AnimState:PlayAnimation("idle")

        if cancook then
            --cookable (from cookable component) added to pristine state for optimization
            inst:AddTag("cookable")

            inst:AddTag("quagmire_stewable")
        end

        if params.show_spoilage then
            inst:AddTag("show_spoilage")
        end

        if params.prefab_override ~= nil then
            inst:SetPrefabNameOverride(params.prefab_override)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        event_server_data("quagmire", "prefabs/quagmire_plantables").master_postinit_raw(inst, product, params.prefab_override, cancook)

        return inst
    end

    return Prefab("quagmire_"..product, fn, assets, prefabs)
end

--------------------------------------------------------------------------

local function MakeCookedProduct(product)
    local params = PRODUCT_VALUES[product].cooked

    local assets =
    {
        Asset("ANIM", "anim/quagmire_crop_"..product..".zip"),
    }

    if params.prefab_override ~= nil then
        table.insert(assets, Asset("INV_IMAGE", params.prefab_override))
    end

    local prefabs =
    {
        "spoiled_food",
        "quagmire_burnt_ingredients",
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("quagmire_crop_"..product)
        inst.AnimState:SetBuild("quagmire_crop_"..product)
        inst.AnimState:PlayAnimation("cooked")

        if params.prefab_override ~= nil then
            inst:SetPrefabNameOverride(params.prefab_override)
        end

        inst:AddTag("quagmire_stewable")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        event_server_data("quagmire", "prefabs/quagmire_plantables").master_postinit_cooked(inst, product, params.prefab_override)

        return inst
    end

    return Prefab("quagmire_"..product.."_cooked", fn, assets, prefabs)
end

--------------------------------------------------------------------------

local ret =
{
    Prefab("quagmire_planted_soil_front", MakeSoilFn(true), assets_soil),
    Prefab("quagmire_planted_soil_back", MakeSoilFn(false), assets_soil),
}

local planted_prefabs = {}
for k, v in pairs(PRODUCT_VALUES) do
    table.insert(planted_prefabs, "quagmire_"..k.."_planted")
    table.insert(ret, MakePlanted(k, v.bulb))
    table.insert(ret, MakeLeaf(k, v.leaf))
    table.insert(ret, MakeRawProduct(k))
    if v.cooked ~= nil then
        table.insert(ret, MakeCookedProduct(k))
    end
end
for i = 1, QUAGMIRE_NUM_SEEDS_PREFABS do
    table.insert(ret, MakeSeed(i, planted_prefabs))
end
planted_prefabs = nil

return unpack(ret)
