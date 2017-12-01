local assets =
{
    Asset("ANIM", "anim/fish.zip"),
    Asset("ANIM", "anim/fish01.zip"),
}

local prefabs =
{
    "fish_cooked",
    "spoiled_food",
}

local function stopkicking(inst)
    inst.AnimState:PlayAnimation("dead")
end

local function commonfn(build, anim, loop, dryable, cookable)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("fish")
    inst.AnimState:SetBuild("fish")
    inst.AnimState:PlayAnimation(anim, loop)

    inst:AddTag("meat")
    inst:AddTag("catfood")

    if dryable then
        --dryable (from dryable component) added to pristine state for optimization
        inst:AddTag("dryable")
    end

    if cookable then
        --cookable (from cookable component) added to pristine state for optimization
        inst:AddTag("cookable")
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.build = build --This is used within SGwilson, sent from an event in fishingrod.lua

    inst:AddComponent("edible")
    inst.components.edible.ismeat = true
    inst.components.edible.foodtype = FOODTYPE.MEAT

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("bait")

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
        inst.components.cookable.product = "fish_cooked"
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    MakeHauntableLaunchAndPerish(inst)

    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
    inst.data = {}

    return inst
end

local function rawfn(build)
    local inst = commonfn(build, "idle", true, true, true)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)

    inst:DoTaskInTime(5, stopkicking)
    inst.components.inventoryitem:SetOnPickupFn(stopkicking)
    inst.OnLoad = stopkicking

    return inst
end

local function cookedfn(build)
    local inst = commonfn(build, "cooked")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)

    return inst
end

local function makefish(build)
    local function makerawfn()
        return rawfn(build)
    end

    local function makecookedfn()
        return cookedfn(build)
    end

    return makerawfn, makecookedfn
end

local function fish(name, build)
    local raw, cooked = makefish(build)
    return Prefab(name, raw, assets, prefabs),
        Prefab(name.."_cooked", cooked, assets)
end

return fish("fish", "fish01")
