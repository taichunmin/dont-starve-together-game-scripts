local assets =
{
    Asset("ANIM", "anim/spoiled_food.zip"),
	Asset("ANIM", "anim/oceanfishing_lure_mis.zip"),
	Asset("SCRIPT", "scripts/prefabs/fertilizer_nutrient_defs.lua"),
}

local prefabs =
{
    "gridplacer_farmablesoil",
}

local fish_assets =
{
    Asset("ANIM", "anim/spoiled_fish.zip"),
}

local fish_small_assets =
{
    Asset("ANIM", "anim/spoiled_fish_small.zip"),
}

local fish_prefabs =
{
	"boneshard",
	"spoiled_food",
}

local fish_loot = {"spoiled_food", "boneshard"}

local FERTILIZER_DEFS = require("prefabs/fertilizer_nutrient_defs").FERTILIZER_DEFS

local function fish_onhit(inst, worker, workleft, workdone)
	local num_loots = math.clamp(workdone / TUNING.SPOILED_FISH_WORK_REQUIRED, 1, TUNING.SPOILED_FISH_LOOT.WORK_MAX_SPAWNS)
	num_loots = math.min(num_loots, inst.components.stackable:StackSize())

	if inst.components.stackable:StackSize() > num_loots then
		--inst.AnimState:PlayAnimation("hit")
		--inst.AnimState:PushAnimation("idle", false)

		if num_loots == TUNING.SPOILED_FISH_LOOT.WORK_MAX_SPAWNS then
			LaunchAt(inst, inst, worker, TUNING.SPOILED_FISH_LOOT.LAUNCH_SPEED, TUNING.SPOILED_FISH_LOOT.LAUNCH_HEIGHT, nil, TUNING.SPOILED_FISH_LOOT.LAUNCH_ANGLE)
		end
	end

	for _ = 1, num_loots do
		inst.components.lootdropper:DropLoot()
	end

	local top_stack_item = inst.components.stackable:Get(num_loots)
	top_stack_item:Remove()
end

local function fish_stack_size_changed(inst, data)
    if data ~= nil and data.stacksize ~= nil and inst.components.workable ~= nil then
        inst.components.workable:SetWorkLeft(data.stacksize * TUNING.SPOILED_FISH_WORK_REQUIRED)
    end
end

local function GetFertilizerKey(inst)
    return inst.prefab
end

local function fertilizerresearchfn(inst)
    return inst:GetFertilizerKey()
end

local function fn(common_init, mastersim_init, nutrients)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("spoiled")
    inst.AnimState:SetBuild("spoiled_food")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("icebox_valid")
	inst:AddTag("saltbox_valid")
    inst:AddTag("show_spoiled")

    MakeInventoryFloatable(inst, "med", nil, 0.73)
    MakeDeployableFertilizerPristine(inst)

    inst:AddTag("fertilizerresearchable")

	if common_init ~= nil then
		common_init(inst)
	end

    inst.GetFertilizerKey = GetFertilizerKey

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("fertilizer")
    inst.components.fertilizer.fertilizervalue = TUNING.SPOILEDFOOD_FERTILIZE
    inst.components.fertilizer.soil_cycles = TUNING.SPOILEDFOOD_SOILCYCLES
    inst.components.fertilizer.withered_cycles = TUNING.SPOILEDFOOD_WITHEREDCYCLES
    inst.components.fertilizer:SetNutrients(nutrients)

    inst:AddComponent("smotherer")

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("fertilizerresearchable")
    inst.components.fertilizerresearchable:SetResearchFn(fertilizerresearchfn)

    inst:AddComponent("selfstacker")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL
    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = TUNING.SPOILED_HEALTH
    inst.components.edible.hungervalue = TUNING.SPOILED_HUNGER

    inst:AddComponent("tradable")

	if mastersim_init ~= nil then
		mastersim_init(inst)
	end

    if TheNet:GetServerGameMode() == "quagmire" then
        event_server_data("quagmire", "prefabs/spoiledfood").master_postinit(inst)
    end

    MakeDeployableFertilizer(inst)
    MakeHauntableLaunchAndIgnite(inst)

    return inst
end

local function food_init(inst)
	inst:AddTag("oceanfishing_lure")
end

local function food_mastersim_init(inst)
	inst:AddComponent("oceanfishingtackle")
	inst.components.oceanfishingtackle:SetupLure({build = "oceanfishing_lure_mis", symbol = "hook_spoiledfood", single_use = true, lure_data = TUNING.OCEANFISHING_LURE.SPOILED_FOOD})
end

local function fish_init(inst)
    inst.AnimState:SetBank("spoiled_fish")
    inst.AnimState:SetBuild("spoiled_fish")
    inst:AddTag("spoiled_fish")

    inst.Transform:SetScale(1.3, 1.3, 1.3)
end

local function fish_mastersim_init(inst)
	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot(fish_loot)
	inst.components.lootdropper.numrandomloot = 1

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(inst.components.stackable.stacksize * TUNING.SPOILED_FISH_WORK_REQUIRED)
    inst.components.workable:SetOnWorkCallback(fish_onhit)

	inst:ListenForEvent("stacksizechange", fish_stack_size_changed)
end

local function fish_small_init(inst)
    inst.AnimState:SetBank("spoiled_fish_small")
    inst.AnimState:SetBuild("spoiled_fish_small")
    inst:AddTag("spoiled_fish")

    inst.Transform:SetScale(1.3, 1.3, 1.3)
end

local function fish_small_mastersim_init(inst)
    inst.components.inspectable.nameoverride = "spoiled_fish"

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:AddRandomLoot("spoiled_food", 1)
	inst.components.lootdropper:AddRandomLoot("boneshard", 1)
	inst.components.lootdropper.numrandomloot = 1

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(inst.components.stackable.stacksize * TUNING.SPOILED_FISH_SMALL_WORK_REQUIRED)
    inst.components.workable:SetOnWorkCallback(fish_onhit)

	inst:ListenForEvent("stacksizechange", fish_stack_size_changed)
end

return Prefab("spoiled_food", function() return fn(food_init, food_mastersim_init, FERTILIZER_DEFS.spoiled_food.nutrients) end, assets, prefabs),
		Prefab("spoiled_fish", function() return fn(fish_init, fish_mastersim_init, FERTILIZER_DEFS.spoiled_fish.nutrients) end, fish_assets, fish_prefabs),
        Prefab("spoiled_fish_small", function() return fn(fish_small_init, fish_small_mastersim_init, FERTILIZER_DEFS.spoiled_fish_small.nutrients) end, fish_small_assets, fish_prefabs)
