local assets =
{
    Asset("ANIM", "anim/mosquitofertilizer.zip"),
    Asset("SCRIPT", "scripts/prefabs/fertilizer_nutrient_defs.lua"),
}

local prefabs =
{
    "flies",
    "poopcloud",
    "gridplacer_farmablesoil",
}

----------------------------------------------------------------------------------------------------------------------------------------------

local FERTILIZER_DEFS = require("prefabs/fertilizer_nutrient_defs").FERTILIZER_DEFS

----------------------------------------------------------------------------------------------------------------------------------------------

local function OnBurn(inst)
    DefaultBurnFn(inst)

    if inst.flies ~= nil then
        inst.flies:Remove()
        inst.flies = nil
    end
end

local function FuelTaken(inst, taker)
    local fx = taker.components.burnable ~= nil and taker.components.burnable.fxchildren[1] or nil

    local x, y, z

    if fx ~= nil and fx:IsValid() then
        x, y, z = fx.Transform:GetWorldPosition()
    else
        x, y, z = taker.Transform:GetWorldPosition()
    end

    SpawnPrefab("poopcloud").Transform:SetPosition(x, y + 1, z)
end

----------------------------------------------------------------------------------------------------------------------------------------------

local function OnDropped(inst)
    if inst.flies == nil then
        inst.flies = inst:SpawnChild("flies")
    end
end

local function OnPickup(inst)
    if inst.flies ~= nil then
        inst.flies:Remove()
        inst.flies = nil
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------

local function GetFertilizerKey(inst)
    return inst.prefab
end

local function FertilizerResearchFn(inst)
    return inst:GetFertilizerKey()
end

local function ondeployed_fertilzier_extra_fn(inst, pt, deployer)
    local tile_x, tile_z = TheWorld.Map:GetTileCoordsAtPoint(pt:Get())
    local nutrients = inst.components.fertilizer.nutrients
    if deployer and deployer.components.skilltreeupdater:IsActivated("wurt_mosquito_craft_3") then
        TheWorld.components.farming_manager:AddTileNutrients(tile_x, tile_z, TUNING.WURT_BONUS_FERT, TUNING.WURT_BONUS_FERT, TUNING.WURT_BONUS_FERT)
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("mosquitofertilizer")
    inst.AnimState:SetBuild("mosquitofertilizer")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "small", 0.2, 0.8)
    MakeDeployableFertilizerPristine(inst)

    inst:AddTag("fertilizerresearchable")

    inst.GetFertilizerKey = GetFertilizerKey

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("smotherer")
    inst:AddComponent("stackable")

    inst:AddComponent("fertilizerresearchable")
    inst.components.fertilizerresearchable:SetResearchFn(FertilizerResearchFn)

    inst:AddComponent("fertilizer")
    inst.components.fertilizer.fertilizervalue = TUNING.POOP_FERTILIZE
    inst.components.fertilizer.soil_cycles = TUNING.POOP_SOILCYCLES
    inst.components.fertilizer.withered_cycles = TUNING.POOP_WITHEREDCYCLES
    inst.components.fertilizer:SetNutrients(FERTILIZER_DEFS.mosquitofertilizer.nutrients)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPickupFn(OnPickup)
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPickup)

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL
    inst.components.fuel:SetOnTakenFn(FuelTaken)

    MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
    inst.components.burnable:SetOnIgniteFn(OnBurn)
    MakeSmallPropagator(inst)

    inst.ondeployed_fertilzier_extra_fn = ondeployed_fertilzier_extra_fn

    MakeDeployableFertilizer(inst)
    MakeHauntableLaunchAndIgnite(inst)

    return inst
end

return Prefab("mosquitofertilizer", fn, assets, prefabs)
