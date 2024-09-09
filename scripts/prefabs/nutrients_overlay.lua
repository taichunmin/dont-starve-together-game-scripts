local assets = {
    Asset("ANIM", "anim/nutrients_overlay.zip"),
    Asset("ANIM", "anim/farm_soil_moisture.zip"),
}

local prefabs = {
    "nutrients_overlay_visual"
}

local nutrient_prefix = "nutrient_"
local symbol_levels = {
    "_low",
    "_med",
    "_high",
    "_full",
}
local function OnNutrientLevelsDirty(inst)
    if inst.visual then
        local nutrientlevels = inst.nutrientlevels:value()
        local nutrients = {
            bit.band(nutrientlevels, 7),
            bit.band(bit.rshift(nutrientlevels, 3), 7),
            bit.band(bit.rshift(nutrientlevels, 6), 7),
        }
        for num, nutrient in ipairs(nutrients) do
            local nutrient_name = nutrient_prefix..tostring(num)
            for i, symbol_postfix in ipairs(symbol_levels) do
                local symbol = nutrient_name..symbol_postfix
                if i <= nutrient then
                    inst.visual.AnimState:ShowSymbol(symbol)
                else
                    inst.visual.AnimState:HideSymbol(symbol)
                end
            end
        end
    end
end

local nutrients_count = {0, 1, 25, 50, 100}
local function UpdateOverlay(inst, _n1, _n2, _n3)
    local nutrientlevels = 0
    for num, nutrient in ipairs({_n1, _n2, _n3}) do
        for i, minimum in ipairs_reverse(nutrients_count) do
            if nutrient >= minimum then
                nutrientlevels = nutrientlevels + bit.lshift(i, (num-1)*3)
                break
            end
        end
    end
    inst.nutrientlevels:set(nutrientlevels)
end

local function UpdateMoisture(inst, percent)
	inst.AnimState:SetPercent("anim", percent)
end

local function visualfn()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("DECOR")
    inst:AddTag("NOCLICK")

    inst.Transform:SetRotation(90 * math.random(0, 3))

    inst.AnimState:SetBuild("nutrients_overlay")
    inst.AnimState:SetBank("nutrients_overlay")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    TheWorld.components.nutrients_visual_manager:UpdateVisualAnimState(inst)

    TheWorld.components.nutrients_visual_manager:RegisterNutrientsVisual(inst)
    inst:ListenForEvent("onremove", function()
        TheWorld.components.nutrients_visual_manager:UnregisterNutrientsVisual(inst)
    end)

    inst.entity:SetPristine()

    inst.persists = false

    return inst
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("farm_soil_moisture")
    inst.AnimState:SetBank("farm_soil_moisture")
	inst.AnimState:SetPercent("anim", 0)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)

    inst.Transform:SetRotation(90 * math.random(0, 3))

    inst:AddTag("DECOR")
    inst:AddTag("NOCLICK")


    inst.nutrientlevels = net_ushortint(inst.GUID, "inst.nutrientlevels", "nutrientlevelsdirty")

    if not TheNet:IsDedicated() then
        inst.visual = inst:SpawnChild("nutrients_overlay_visual")
        inst:ListenForEvent("nutrientlevelsdirty", OnNutrientLevelsDirty)
        OnNutrientLevelsDirty(inst)
        if TheWorld.ismastersim then
            inst:ListenForEvent("entitysleep", function()
                if inst.visual then
                    inst.visual:Remove()
                    inst.visual = nil
                end
            end)
            inst:ListenForEvent("entitywake", function()
                if not inst.visual then
                    inst.visual = inst:SpawnChild("nutrients_overlay_visual")
                    OnNutrientLevelsDirty(inst)
                end
            end)
        end
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.UpdateOverlay = UpdateOverlay
    inst.UpdateMoisture = UpdateMoisture

    inst.persists = false

    return inst
end

return Prefab("nutrients_overlay", fn, nil, prefabs),
    Prefab("nutrients_overlay_visual", visualfn, assets)