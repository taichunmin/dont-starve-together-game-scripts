local assets =
{
    Asset("ANIM", "anim/fish.zip"),
    Asset("ANIM", "anim/fish01.zip"),
    Asset("ANIM", "anim/eel.zip"),
    Asset("ANIM", "anim/eel01.zip"),
}

local pondfish_prefabs =
{
	"fishmeat_small",
    "fishmeat_small_cooked",
    "spoiled_fish",
}

local pondeel_prefabs =
{
	"fishmeat_small",
    "fishmeat_small_cooked",
	"eel",
}

local function CalcNewSize()
	local p = 2 * math.random() - 1
	return (p*p*p + 1) * 0.5
end

local function flop(inst)
	local num = math.random(2)
	for i = 1, num do
		inst.AnimState:PushAnimation("idle", false)
	end

	inst.flop_task = inst:DoTaskInTime(math.random() * 2 + num * 2, flop)
end

local function ondropped(inst)
    if inst.flop_task ~= nil then
        inst.flop_task:Cancel()
    end
	inst.AnimState:PlayAnimation("idle", false)
    inst.flop_task = inst:DoTaskInTime(math.random() * 3, flop)
end

local function ondroppedasloot(inst, data)
	if data ~= nil and data.dropper ~= nil then
		inst.components.weighable.prefab_override_owner = data.dropper.prefab
	end
end

local function onpickup(inst)
    if inst.flop_task ~= nil then
        inst.flop_task:Cancel()
        inst.flop_task = nil
    end
end

local function commonfn(bank, build, char_anim_build, data)
    local inst = CreateEntity()

	data = data or {}

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	if data.dynamic_shadow then
	    inst.entity:AddDynamicShadow()
	end
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle", false)
    
	if data.dynamic_shadow then
	    inst.DynamicShadow:SetSize(data.dynamic_shadow[1], data.dynamic_shadow[2])
	end

	inst:AddTag("fish")
	inst:AddTag("pondfish")
    inst:AddTag("meat")
    inst:AddTag("catfood")
	inst:AddTag("smallcreature")

	if data.weight_min ~= nil and data.weight_max ~= nil then
		--weighable_fish (from weighable component) added to pristine state for optimization
		inst:AddTag("weighable_fish")
	end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.build = char_anim_build --This is used within SGwilson, sent from an event in fishingrod.lua

    inst:AddComponent("bait")

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(data.perish_time)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = data.perish_product
	inst.components.perishable.ignorewentness = true

    inst:AddComponent("cookable")
    inst.components.cookable.product = data.cookable_product

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(onpickup)
	inst.components.inventoryitem:SetSinks(true)

	inst:AddComponent("murderable")

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot(data.loot)

    inst:AddComponent("edible")
    inst.components.edible.ismeat = true
	inst.components.edible.healthvalue = data.healthvalue
	inst.components.edible.hungervalue = data.hungervalue
	inst.components.edible.sanityvalue = 0
    inst.components.edible.foodtype = FOODTYPE.MEAT

    MakeHauntableLaunchAndPerish(inst)

    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = data.goldvalue or TUNING.GOLD_VALUES.MEAT
    inst.data = {}--

	if data.weight_min ~= nil and data.weight_max ~= nil then
		inst:AddComponent("weighable")
		inst.components.weighable.type = TROPHYSCALE_TYPES.FISH
		inst.components.weighable:Initialize(data.weight_min, data.weight_max)
		inst.components.weighable:SetWeight(Lerp(data.weight_min, data.weight_max, CalcNewSize()))
	end

	inst:ListenForEvent("on_loot_dropped", ondroppedasloot)

	inst.flop_task = inst:DoTaskInTime(math.random() * 2 + 1, flop)

    return inst
end

local SHADOW_MEDIUM = {1.5, 0.75}
local SHADOW_LONG = {3, 1}

local pondfish_data =
{
    weight_min = 40.89,
    weight_max = 55.28,
    perish_product = "fishmeat_small",
    loot = { "fishmeat_small" },
    cookable_product = "fishmeat_small_cooked",
    healthvalue = TUNING.HEALING_TINY,
    hungervalue = TUNING.CALORIES_SMALL,
    perish_time = TUNING.PERISH_SUPERFAST,
	goldvalue = TUNING.GOLD_VALUES.MEAT,
    dynamic_shadow = SHADOW_MEDIUM,
}
local function pondfishfn()
	return commonfn("fish", "fish", "fish01", pondfish_data)
end

local pondeel_data =
{
    weight_min = 165.16,
    weight_max = 212.12,
    perish_product = "eel",
    loot = { "eel" },
    cookable_product = "eel_cooked",
    healthvalue = TUNING.HEALING_SMALL,
    hungervalue = TUNING.CALORIES_TINY,
    perish_time = TUNING.PERISH_SUPERFAST,
	goldvalue = TUNING.GOLD_VALUES.RAREMEAT,
    dynamic_shadow = SHADOW_LONG,
}
local function pondeelfn()
	return commonfn("eel", "eel", "eel01", pondeel_data)
end

return Prefab("pondfish", pondfishfn, assets, pondeel_prefabs),
	Prefab("pondeel", pondeelfn, assets, pondeel_prefabs)