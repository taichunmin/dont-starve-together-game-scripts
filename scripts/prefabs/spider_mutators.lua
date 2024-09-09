local prefabs = {}

local assets =
{
    Asset("ANIM", "anim/spider_mutators.zip"),
    Asset("ANIM", "anim/spider_water_mutator.zip"),
}

local mutator_targets = 
{
    "warrior",
    "dropper",
    "hider",
    "spitter",
    "moon",
    "healer",
    "water",
}

local mutator_extra_data =
{
    ["water"] = {
        bank = "spider_water_mutator",
        build = "spider_water_mutator",
    },
}

local function MakeMutatorFn(mutator_target, extra_data)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank((extra_data and extra_data.bank) or "spider_mutator_all")
    inst.AnimState:SetBuild((extra_data and extra_data.build) or "spider_mutators")
    inst.AnimState:PlayAnimation(mutator_target)
    inst.scrapbook_anim = mutator_target


    inst.scrapbook_deps = { "spider_"..mutator_target }

    MakeInventoryFloatable(inst)

    inst:AddTag("spidermutator")
    inst:AddTag("monstermeat")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.MEAT
    inst.components.edible.secondaryfoodtype = FOODTYPE.MONSTER
    inst.components.edible.healthvalue = -TUNING.HEALING_SMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL

    inst:AddComponent("spidermutator")
    inst.components.spidermutator:SetMutationTarget("spider_" .. mutator_target)

    MakeHauntableLaunch(inst)

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)

    return inst
end

for i, mutator_target in ipairs(mutator_targets) do
    table.insert(prefabs, "spider_" .. mutator_target)
end

local mutator_prefabs = {}
for i, mutator_target in ipairs(mutator_targets) do
    local extra_data = mutator_extra_data[mutator_target]
    table.insert(
        mutator_prefabs,
        Prefab(
            "mutator_" .. mutator_target,
            function()
                return MakeMutatorFn(mutator_target, extra_data)
            end,
            assets,
            prefabs
        )
    )
end

return unpack(mutator_prefabs)