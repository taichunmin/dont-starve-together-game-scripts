local assets =
{
    Asset("ANIM", "anim/treegrowthsolution.zip"),
}

local prefabs =
{
    "treegrowthsolution_use_fx",
}

local FERTILIZER_DEFS = require("prefabs/fertilizer_nutrient_defs").FERTILIZER_DEFS

local function GetFertilizerKey(inst)
    return inst.prefab
end

local function fertilizerresearchfn(inst)
    return inst:GetFertilizerKey()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("treegrowthsolution")
    inst.AnimState:SetBuild("treegrowthsolution")
    inst.AnimState:PlayAnimation("item")

    inst:AddTag("allow_action_on_impassable")
    inst:AddTag("boat_patch")

    MakeInventoryFloatable(inst, "med", 0.1)
    MakeDeployableFertilizerPristine(inst)

    inst:AddTag("fertilizerresearchable")
    inst.GetFertilizerKey = GetFertilizerKey

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("fertilizerresearchable")
    inst.components.fertilizerresearchable:SetResearchFn(fertilizerresearchfn)

    inst:AddComponent("fertilizer")
    inst.components.fertilizer.fertilizervalue = TUNING.TREEGROWTH_FERTILIZE
    inst.components.fertilizer.soil_cycles = TUNING.TREEGROWTH_SOILCYCLES
    inst.components.fertilizer.withered_cycles = TUNING.TREEGROWTH_WITHEREDCYCLES
    inst.components.fertilizer:SetNutrients(FERTILIZER_DEFS.treegrowthsolution.nutrients)

    inst:AddComponent("treegrowthsolution")
    inst.components.treegrowthsolution.fx_prefab = "treegrowthsolution_use_fx"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(false)

    inst:AddComponent("boatpatch")
    inst.components.boatpatch.patch_type = "treegrowth"

    inst:AddComponent("repairer")
    inst.components.repairer.repairmaterial = MATERIALS.WOOD
    inst.components.repairer.healthrepairvalue = TUNING.REPAIR_TREEGROWTH_HEALTH
    inst.components.repairer.boatrepairsound = "waterlogged1/common/use_figjam"

    MakeDeployableFertilizer(inst)
    MakeHauntableLaunchAndSmash(inst)

    return inst
end

return Prefab("treegrowthsolution", fn, assets, prefabs)
