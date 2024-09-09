local capassets =
{
    Asset("ANIM", "anim/moon_cap.zip"),
    Asset("INV_IMAGE", "moon_cap")
}

local cookedassets =
{
    Asset("ANIM", "anim/moon_cap.zip"),
    Asset("INV_IMAGE", "moon_cap_cooked")
}

local capprefabs =
{
    "moon_cap_cooked",
    "small_puff",
	"sleepcloud_lunar",
}

local cookedprefabs =
{
    "small_puff",
}

local function mooncap_oneaten(inst, eater)
    if not (eater.components.freezable and eater.components.freezable:IsFrozen()) and
            not (eater.components.pinnable and eater.components.pinnable:IsStuck()) and
            not (eater.components.fossilizable and eater.components.fossilizable:IsFossilized()) then

        local sleeptime = TUNING.MOON_MUSHROOM_SLEEPTIME

        local mount = (eater.components.rider ~= nil and eater.components.rider:GetMount()) or nil
        if mount then
            mount:PushEvent("ridersleep", { sleepiness = 4, sleeptime = sleeptime })
        end

		if eater.components.skilltreeupdater and eater.components.skilltreeupdater:IsActivated("wormwood_moon_cap_eating") then
			local cloud = SpawnPrefab("sleepcloud_lunar")
			cloud.Transform:SetPosition(eater.Transform:GetWorldPosition())
			cloud:SetOwner(eater)
		elseif eater.components.sleeper then
            eater.components.sleeper:AddSleepiness(4, sleeptime)
        elseif eater.components.grogginess then
            eater.components.grogginess:AddGrogginess(2, sleeptime)
        else
            eater:PushEvent("knockedout")
        end
    end
end

local function capfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("moon_cap")
    inst.AnimState:SetBuild("moon_cap")
    inst.AnimState:PlayAnimation("moon_cap")
    inst.scrapbook_anim = "moon_cap"

    inst.pickupsound = "vegetation_firm"

    --cookable (from cookable component) added to pristine state for optimization
    inst:AddTag("cookable")

    inst:AddTag("moonmushroom")
    inst:AddTag("mushroom")

    MakeInventoryFloatable(inst, "med", 0.0, 0.7)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("tradable")
    inst:AddComponent("inspectable")

    MakeSmallBurnable(inst, TUNING.TINY_BURNTIME)
    MakeSmallPropagator(inst)
    inst:AddComponent("inventoryitem")

    --this is where it gets interesting
    inst:AddComponent("edible")
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = TUNING.SANITY_SMALL
    inst.components.edible.foodtype = FOODTYPE.VEGGIE
    inst.components.edible:SetOnEatenFn(mooncap_oneaten)

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    MakeHauntableLaunchAndPerish(inst)

    inst:AddComponent("cookable")
    inst.components.cookable.product = "moon_cap_cooked"

    return inst
end

----
local function mooncap_cooked_oneaten(inst, eater)
    if eater:IsValid() and eater.components.grogginess ~= nil then
        eater.components.grogginess:ResetGrogginess()
    end
end

local function cookedfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("moon_cap")
    inst.AnimState:SetBuild("moon_cap")
    inst.AnimState:PlayAnimation("moon_cap_cooked")
    inst.scrapbook_anim = "moon_cap_cooked"

    MakeInventoryFloatable(inst, "small", 0.05, 1.0)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("tradable")
    inst:AddComponent("inspectable")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.TINY_FUEL

    MakeSmallBurnable(inst, TUNING.TINY_BURNTIME)
    MakeSmallPropagator(inst)

    inst:AddComponent("inventoryitem")

    MakeHauntableLaunchAndPerish(inst)

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = -TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL
    inst.components.edible.foodtype = FOODTYPE.VEGGIE
    inst.components.edible:SetOnEatenFn(mooncap_cooked_oneaten)

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    return inst
end

return Prefab("moon_cap", capfn, capassets, capprefabs),
        Prefab("moon_cap_cooked", cookedfn, cookedassets, cookedprefabs)
