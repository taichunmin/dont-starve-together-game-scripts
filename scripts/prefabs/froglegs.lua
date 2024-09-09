local assets =
{
    Asset("ANIM", "anim/frog_legs.zip"),
}

local prefabs =
{
    "froglegs_cooked",
}

local function commonfn(anim, dryable, cookable)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("frog_legs")
    inst.AnimState:SetBuild("frog_legs")
    inst.AnimState:PlayAnimation(anim)

    --inst.pickupsound = "squidgy"

    inst:AddTag("smallmeat")
    inst:AddTag("catfood")
    inst:AddTag("rawmeat")

    if dryable then
        --dryable (from dryable component) added to pristine state for optimization
        inst:AddTag("dryable")
    end

    if cookable then
        --cookable (from cookable component) added to pristine state for optimization
        inst:AddTag("cookable")
    end

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.MEAT

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    if dryable then
        inst:AddComponent("dryable")
        inst.components.dryable:SetProduct("smallmeat_dried")
        inst.components.dryable:SetDryTime(TUNING.DRY_FAST)
    end

    if cookable then
        inst:AddComponent("cookable")
        inst.components.cookable.product = "froglegs_cooked"
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("bait")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    MakeHauntableLaunchAndPerish(inst)

    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = 0

    return inst
end

local function defaultfn()
    local inst = commonfn("idle", true, true)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL

    return inst
end

local function cookedfn()
    local inst = commonfn("cooked")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)

    return inst
end

return Prefab("froglegs", defaultfn, assets, prefabs),
        Prefab("froglegs_cooked", cookedfn, assets)
