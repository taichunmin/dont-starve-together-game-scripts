require "tuning"
local PLANT_DEFS = require("prefabs/farm_plant_defs").PLANT_DEFS

local function MakeVegStats(seedweight, hunger, health, perish_time, sanity, cooked_hunger, cooked_health, cooked_perish_time, cooked_sanity, float_settings, cooked_float_settings, dryable, secondary_foodtype, halloweenmoonmutable_settings, lure_data)
    return {
        health = health,
        hunger = hunger,
        cooked_health = cooked_health,
        cooked_hunger = cooked_hunger,
        seed_weight = seedweight,
        perishtime = perish_time,
        cooked_perishtime = cooked_perish_time,
        sanity = sanity,
        cooked_sanity = cooked_sanity,
        float_settings = float_settings,
        cooked_float_settings = cooked_float_settings,
		dryable = dryable,
		halloweenmoonmutable_settings = halloweenmoonmutable_settings,
		secondary_foodtype = secondary_foodtype,
        lure_data = lure_data,
    }
end

local COMMON = TUNING.SEED_CHANCE_COMMON
local UNCOMMON = TUNING.SEED_CHANCE_UNCOMMON
local RARE = TUNING.SEED_CHANCE_RARE

local OVERSIZED_PHYSICS_RADIUS = 0.1
local OVERSIZED_MAXWORK = 1
local OVERSIZED_PERISHTIME_MULT = 4

local QUAGMIRE_PORTS =
{
    "tomato",
    "onion",
}

VEGGIES =
{
    cave_banana = MakeVegStats(0,   TUNING.CALORIES_SMALL,  TUNING.HEALING_TINY,    TUNING.PERISH_MED, 0,
                                    TUNING.CALORIES_SMALL,  TUNING.HEALING_SMALL,   TUNING.PERISH_FAST, 0,
                                    {"small", 0.05, 0.9},   {"med", nil, 0.75}),

    carrot = MakeVegStats(COMMON,   TUNING.CALORIES_SMALL,  TUNING.HEALING_TINY,    TUNING.PERISH_MED, 0,
                                    TUNING.CALORIES_SMALL,  TUNING.HEALING_SMALL,   TUNING.PERISH_FAST, 0,
                                    {"med", 0.05, 0.8},    {"small", 0.1, nil},
									nil, nil,
                                    {prefab = "carrat"}),

    corn = MakeVegStats(COMMON, TUNING.CALORIES_MED,    TUNING.HEALING_SMALL,   TUNING.PERISH_MED, 0,
                                TUNING.CALORIES_SMALL,  TUNING.HEALING_SMALL,   TUNING.PERISH_SLOW, 0),

    pumpkin = MakeVegStats(UNCOMMON,    TUNING.CALORIES_LARGE,  TUNING.HEALING_SMALL,       IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) and TUNING.PERISH_PRESERVED or TUNING.PERISH_MED, 0,
                                        TUNING.CALORIES_LARGE,  TUNING.HEALING_MEDSMALL,    TUNING.PERISH_FAST, 0,
                                        nil,    {"small", 0.1, nil}),

    eggplant = MakeVegStats(UNCOMMON,   TUNING.CALORIES_MED,    TUNING.HEALING_MEDSMALL,    TUNING.PERISH_MED, 0,
                                        TUNING.CALORIES_MED,    TUNING.HEALING_MED,     TUNING.PERISH_FAST, 0),

    durian = MakeVegStats(RARE, TUNING.CALORIES_MED,    -TUNING.HEALING_SMALL,  TUNING.PERISH_MED, -TUNING.SANITY_TINY,
                                TUNING.CALORIES_MED,    0,                      TUNING.PERISH_FAST, -TUNING.SANITY_TINY,
                                nil, nil, nil, FOODTYPE.MONSTER),

    pomegranate = MakeVegStats(RARE,    TUNING.CALORIES_TINY,   TUNING.HEALING_SMALL,       TUNING.PERISH_FAST, 0,
                                        TUNING.CALORIES_SMALL,  TUNING.HEALING_MED, TUNING.PERISH_SUPERFAST, 0,
                                        {"small", nil, 0.8},    {"small", nil, 0.8}),

    dragonfruit = MakeVegStats(RARE,    TUNING.CALORIES_TINY,   TUNING.HEALING_SMALL,       TUNING.PERISH_FAST, 0,
                                        TUNING.CALORIES_SMALL,  TUNING.HEALING_MED, TUNING.PERISH_SUPERFAST, 0,
                                        {"small", 0.1, 0.8},    {"small", 0.05, nil},
										nil,
										nil,
										{prefab = "fruitdragon", onmutatefn = function(inst, new_inst)
											new_inst:MakeRipe(true)
                                        end}),

    berries = MakeVegStats(0,   TUNING.CALORIES_TINY,   0,  TUNING.PERISH_FAST, 0,
                                TUNING.CALORIES_SMALL,  TUNING.HEALING_TINY,    TUNING.PERISH_SUPERFAST, 0,
                                {"med", nil, 0.7},      {"med", nil, 0.65},
								nil,
								FOODTYPE.BERRY,
								nil,
                                {lure_data = TUNING.OCEANFISHING_LURE.BERRY, single_use = true, build = "oceanfishing_lure_mis", symbol = "hook_berries"}),

    berries_juicy = MakeVegStats(0, TUNING.CALORIES_SMALL,  TUNING.HEALING_TINY,  TUNING.PERISH_TWO_DAY, 0,
                                    TUNING.CALORIES_MEDSMALL,  TUNING.HEALING_SMALL,    TUNING.PERISH_ONE_DAY, 0,
                                    {"med", nil, 0.7}, nil,
									nil,
									FOODTYPE.BERRY,
									nil,
                                    {lure_data = TUNING.OCEANFISHING_LURE.BERRY, single_use = true, build = "oceanfishing_lure_mis", symbol = "hook_juiceberries"}),

    fig = MakeVegStats(0,   TUNING.CALORIES_SMALL,   0,  TUNING.PERISH_FAST, 0,
                                    TUNING.CALORIES_MEDSMALL,  TUNING.HEALING_TINY,    TUNING.PERISH_SUPERFAST, 0,
                                    {"med", nil, 0.7},      {"med", nil, 0.65},
                                    nil,
                                    FOODTYPE.BERRY,
                                    nil,
                                    {lure_data = TUNING.OCEANFISHING_LURE.BERRY, single_use = true, build = "oceanfishing_lure_mis", symbol = "hook_fig"}),

    cactus_meat = MakeVegStats(0, TUNING.CALORIES_SMALL, -TUNING.HEALING_SMALL, TUNING.PERISH_MED, -TUNING.SANITY_TINY,
                                  TUNING.CALORIES_SMALL, TUNING.HEALING_TINY, TUNING.PERISH_MED, TUNING.SANITY_MED),

    watermelon = MakeVegStats(UNCOMMON, TUNING.CALORIES_SMALL, TUNING.HEALING_SMALL, TUNING.PERISH_FAST, TUNING.SANITY_TINY,
                              TUNING.CALORIES_SMALL, TUNING.HEALING_TINY, TUNING.PERISH_SUPERFAST, TUNING.SANITY_TINY*1.5,
                              {"med", 0.05, 0.7}),

	kelp = MakeVegStats(0,   TUNING.CALORIES_TINY,  -TUNING.HEALING_TINY,   TUNING.PERISH_MED, -TUNING.SANITY_SMALL,
                             TUNING.CALORIES_TINY,  0,                      TUNING.PERISH_MED, -TUNING.SANITY_TINY,
                       {"med", nil, 0.7},      {"med", nil, 0.65},
                       { build = "meat_rack_food_tot", hunger = TUNING.CALORIES_TINY, health = TUNING.HEALING_TINY, sanity = TUNING.SANITY_SMALL, perish = TUNING.PERISH_PRESERVED, time = TUNING.DRY_SUPERFAST }),


    tomato = MakeVegStats(COMMON, TUNING.CALORIES_SMALL, TUNING.HEALING_SMALL, TUNING.PERISH_FAST, 0,
                                  TUNING.CALORIES_SMALL, TUNING.HEALING_MED, TUNING.PERISH_MED, 0,
                                  {nil, 0.1, 0.75}),

    potato = MakeVegStats(COMMON, TUNING.CALORIES_SMALL, -TUNING.HEALING_SMALL, TUNING.PERISH_MED, -TUNING.SANITY_TINY,
                                  TUNING.CALORIES_MED, TUNING.HEALING_MED, TUNING.PERISH_FAST, 0,
                                  {nil, 0.05, 0.65}),

    asparagus = MakeVegStats(UNCOMMON, TUNING.CALORIES_SMALL, TUNING.HEALING_SMALL, TUNING.PERISH_FAST, 0,
                                     TUNING.CALORIES_MED, TUNING.HEALING_SMALL, TUNING.PERISH_SUPERFAST, 0,
                                     {"med", nil, 0.7}),

    onion = MakeVegStats(RARE, TUNING.CALORIES_TINY, 0, TUNING.PERISH_SLOW, -TUNING.SANITY_SMALL,
                                   TUNING.CALORIES_TINY, TUNING.HEALING_TINY, TUNING.PERISH_MED, -TUNING.SANITY_TINY,
                                   {"large", 0.05, 0.45}),

    garlic = MakeVegStats(RARE, TUNING.CALORIES_TINY, 0, TUNING.PERISH_SLOW, -TUNING.SANITY_SMALL,
                                   TUNING.CALORIES_TINY, TUNING.HEALING_TINY, TUNING.PERISH_MED, -TUNING.SANITY_TINY,
                                   {nil, 0.05, 0.775}),

    pepper = MakeVegStats(RARE, TUNING.CALORIES_TINY, -TUNING.HEALING_MED, TUNING.PERISH_SLOW, -TUNING.SANITY_MED,
                                    TUNING.CALORIES_TINY, -TUNING.HEALING_SMALL, TUNING.PERISH_SLOW, -TUNING.SANITY_SMALL,
                                    {nil, 0.1, 0.75}),
}

VEGGIES.cave_banana.extra_tags_fresh = {"monkeyqueenbribe"}
VEGGIES.cave_banana.extra_tags_cooked = {"monkeyqueenbribe"}

local SEEDLESS =
{
	berries = true,
	cave_banana = true,
	cactus_meat = true,
	berries_juicy = true,
	fig = true,
	kelp = true,
}

local assets_seeds =
{
    Asset("ANIM", "anim/seeds.zip"),
    Asset("ANIM", "anim/farm_plant_seeds.zip"),
}

local prefabs_seeds =
{
    "plant_normal_ground",
    "seeds_placer",
	"carrot_spinner",
}

local function can_plant_seed(inst, pt, mouseover, deployer)
	local x, z = pt.x, pt.z
	return TheWorld.Map:CanTillSoilAtPoint(x, 0, z, true)
end

local function OnDeploy(inst, pt, deployer) --, rot)
    local plant = SpawnPrefab(inst.components.farmplantable.plant)
    plant.Transform:SetPosition(pt.x, 0, pt.z)
	plant:PushEvent("on_planted", {in_soil = false, doer = deployer, seed = inst})
    TheWorld.Map:CollapseSoilAtPoint(pt.x, 0, pt.z)
    --plant.SoundEmitter:PlaySound("dontstarve/wilson/plant_seeds")
    inst:Remove()

--[[
    local plant = SpawnPrefab("plant_normal_ground")
    plant.components.crop:StartGrowing(inst.components.plantable.product, inst.components.plantable.growtime)
    plant.Transform:SetPosition(pt.x, 0, pt.z)
    plant.SoundEmitter:PlaySound("dontstarve/wilson/plant_seeds")
    inst:Remove()
]]
end

local function oversized_calcweightcoefficient(name)
    if PLANT_DEFS[name].weight_data[3] ~= nil and math.random() < PLANT_DEFS[name].weight_data[3] then
        return (math.random() + math.random()) / 2
    else
        return math.random()
    end
end

local function oversized_onequip(inst, owner)
	local swap = inst.components.symbolswapdata
    owner.AnimState:OverrideSymbol("swap_body", swap.build, swap.symbol)
end

local function oversized_onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
end

local function oversized_onfinishwork(inst, chopper)
    inst.components.lootdropper:DropLoot()
    inst:Remove()
end

local function oversized_onburnt(inst)
    inst.components.lootdropper:DropLoot()
    inst:Remove()
end

local function oversized_makeloots(inst, name)
    local product = name
	local seeds = name.."_seeds"
    return {product, product, seeds, seeds, math.random() < 0.75 and product or seeds}
end

local function oversized_onperish(inst)
    -- vars for rotting on a gym
	local owner = inst.components.inventoryitem:GetGrandOwner()
	local gym = owner and owner:HasTag("gym") and owner or nil
    local rot = nil
    local slot = nil

	if owner and gym == nil then
        local loots = {}
        for i=1, #inst.components.lootdropper.loot do
            table.insert(loots, "spoiled_food")
        end
        inst.components.lootdropper:SetLoot(loots)
        inst.components.lootdropper:DropLoot()
    else
        rot = SpawnPrefab(inst.prefab.."_rotten")
        rot.Transform:SetPosition(inst.Transform:GetWorldPosition())
		if gym then
            slot = gym.components.inventory:GetItemSlot(inst)
        end
    end

    inst:Remove()

    if gym and rot then
        gym.components.mightygym:LoadWeight(rot, slot)
    end
end

local function Seed_GetDisplayName(inst)
	local registry_key = inst.plant_def.product

	local plantregistryinfo = inst.plant_def.plantregistryinfo
	return (ThePlantRegistry:KnowsSeed(registry_key, plantregistryinfo) and ThePlantRegistry:KnowsPlantName(registry_key, plantregistryinfo)) and STRINGS.NAMES["KNOWN_"..string.upper(inst.prefab)]
			or nil
end

local function Oversized_OnSave(inst, data)
	data.from_plant = inst.from_plant or false
    data.harvested_on_day = inst.harvested_on_day
end

local function Oversized_OnPreLoad(inst, data)
	inst.from_plant = (data and data.from_plant) ~= false
	if data ~= nil then
        inst.harvested_on_day = data.harvested_on_day
	end
end

local function displayadjectivefn(inst)
    return STRINGS.UI.HUD.WAXED
end

local function dowaxfn(inst, doer, waxitem)
    local waxedveggie = SpawnPrefab(inst.prefab.."_waxed")
    if doer.components.inventory and doer.components.inventory:IsHeavyLifting() and doer.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY) == inst then
        doer.components.inventory:Unequip(EQUIPSLOTS.BODY)
        doer.components.inventory:Equip(waxedveggie)
    else
        waxedveggie.Transform:SetPosition(inst.Transform:GetWorldPosition())
        waxedveggie.AnimState:PlayAnimation("wax_oversized", false)
        waxedveggie.AnimState:PushAnimation("idle_oversized")
    end
    inst:Remove()
    return true
end

local PlayWaxAnimation

local function CancelWaxTask(inst)
	if inst._waxtask ~= nil then
		inst._waxtask:Cancel()
		inst._waxtask = nil
	end
end

local function StartWaxTask(inst)
	if not inst.inlimbo and inst._waxtask == nil then
		inst._waxtask = inst:DoTaskInTime(GetRandomMinMax(20, 40), PlayWaxAnimation)
	end
end

PlayWaxAnimation = function(inst)
    inst.AnimState:PlayAnimation("wax_oversized", false)
    inst.AnimState:PushAnimation("idle_oversized")
end

local function MakeVeggie(name, has_seeds)
    local assets =
    {
        Asset("ANIM", "anim/"..name..".zip"),
        Asset("INV_IMAGE", name),
    }
	if VEGGIES[name].lure_data ~= nil then
		table.insert(assets, Asset("ANIM", "anim/"..VEGGIES[name].lure_data.build..".zip"))
	end

    table.insert(assets,Asset("INV_IMAGE", name.."_oversized_rot"))

	if has_seeds then
		table.insert(assets, Asset("ANIM", "anim/oceanfishing_lure_mis.zip"))
	end

    local assets_cooked =
    {
        Asset("ANIM", "anim/"..name..".zip"),
        Asset("INV_IMAGE", name.."_cooked"),
    }

    local usequagmireicon = table.contains(QUAGMIRE_PORTS, name)
    if usequagmireicon then
        table.insert(assets, Asset("INV_IMAGE", "quagmire_"..name))
        table.insert(assets_cooked, Asset("INV_IMAGE", "quagmire_"..name.."_cooked"))
    end

    local prefabs =
    {
        name .."_cooked",
        "spoiled_food",
    }
	local dryable = VEGGIES[name].dryable

    if has_seeds then
        table.insert(prefabs, name.."_seeds")
    end

	local assets_dried = {}
	if dryable ~= nil then
        table.insert(prefabs, name.."_dried")
        table.insert(assets_dried, Asset("ANIM", "anim/"..dryable.build..".zip"))
	end

	local seeds_prefabs = has_seeds and { "farm_plant_"..name } or nil

    local assets_oversized = {}
    if has_seeds then
        table.insert(prefabs, name.."_oversized")
        table.insert(prefabs, name.."_oversized_waxed")
        table.insert(prefabs, name.."_oversized_rotten")
        table.insert(prefabs, "splash_green")

        table.insert(assets_oversized, Asset("ANIM", "anim/"..PLANT_DEFS[name].build..".zip"))
    end

    local function spin(inst, time)
        inst.entity:AddSoundEmitter()
        inst.AnimState:PlayAnimation("spin_pre")
        inst.AnimState:PushAnimation("spin_loop",true)
        inst.components.timer:StartTimer("spin",time or 2)
        inst.SoundEmitter:PlaySound("yotr_2023/common/carrot_spin", "spin_lp")
    end

    local function timerdone(inst,data)
        if data and data.name then
            if data.name == "spin" then
                inst.Transform:SetEightFaced()
                inst.Transform:SetRotation(math.random()*360)
                inst.AnimState:PlayAnimation("spin_pst")
                inst.components.activatable.inactive = true
                inst.SoundEmitter:PlaySound("yotr_2023/common/carrot_spin_pst")
                inst.SoundEmitter:KillSound("spin_lp")

                local fx = SpawnPrefab("carrot_spinner")
                inst:AddChild(fx)
            end
        end
    end

    local function GetActivateVerb()
        return "SPIN"
    end    

    local function OnActivateSpin(inst)
        inst:Spin()
    end

    local function fn_seeds()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("farm_plant_seeds")
        inst.AnimState:SetBuild("farm_plant_seeds")
        inst.AnimState:PlayAnimation(name)
        inst.AnimState:SetRayTestOnBB(true)
        inst.scrapbook_anim = name

        inst.pickupsound = "vegetation_firm"

        --cookable (from cookable component) added to pristine state for optimization
        inst:AddTag("cookable")
        inst:AddTag("deployedplant")
        inst:AddTag("deployedfarmplant")
		inst:AddTag("oceanfishing_lure")

        inst.overridedeployplacername = "seeds_placer"

		inst.plant_def = PLANT_DEFS[name]
		inst.displaynamefn = Seed_GetDisplayName

		inst._custom_candeploy_fn = can_plant_seed -- for DEPLOYMODE.CUSTOM

        MakeInventoryFloatable(inst)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("edible")
        inst.components.edible.foodtype = FOODTYPE.SEEDS

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("tradable")
        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")

        inst.components.edible.healthvalue = TUNING.HEALING_TINY / 2
        inst.components.edible.hungervalue = TUNING.CALORIES_TINY

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW)
        inst.components.perishable:StartPerishing()
        inst.components.perishable.onperishreplacement = "spoiled_food"

        inst:AddComponent("cookable")
        inst.components.cookable.product = "seeds_cooked"

        inst:AddComponent("bait")

	    inst:AddComponent("farmplantable")
	    inst.components.farmplantable.plant = "farm_plant_"..name

         -- deprecated (used for crafted farm structures)
        inst:AddComponent("plantable")
        inst.components.plantable.growtime = TUNING.SEEDS_GROW_TIME
        inst.components.plantable.product = name

         -- deprecated (used for wormwood)
        inst:AddComponent("deployable")
        inst.components.deployable:SetDeployMode(DEPLOYMODE.CUSTOM) -- use inst._custom_candeploy_fn
        inst.components.deployable.restrictedtag = "plantkin"
        inst.components.deployable.ondeploy = OnDeploy

		inst:AddComponent("oceanfishingtackle")
        inst.components.oceanfishingtackle:SetupLure({build = "oceanfishing_lure_mis", symbol = "hook_seeds", single_use = true, lure_data = TUNING.OCEANFISHING_LURE.SEED})

        MakeSmallBurnable(inst)
        MakeSmallPropagator(inst)

        MakeHauntableLaunchAndPerish(inst)

        return inst
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        if name == "carrot" then
            inst.entity:AddSoundEmitter()
            inst.GetActivateVerb = GetActivateVerb
        end

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle")

        inst.pickupsound = "vegetation_firm"

        --cookable (from cookable component) added to pristine state for optimization
        inst:AddTag("cookable")

		if dryable ~= nil then
			--dryable (from dryable component) added to pristine state for optimization
			inst:AddTag("dryable")
        end

        if not SEEDLESS[name] then
            --weighable (from weighable component) added to pristine state for optimization
            inst:AddTag("weighable_OVERSIZEDVEGGIES")
        end

        if VEGGIES[name].extra_tags_fresh then
            for _, extra_tag in ipairs(VEGGIES[name].extra_tags_fresh) do
                inst:AddTag(extra_tag)
            end
        end

        local float = VEGGIES[name].float_settings
        if float ~= nil then
            MakeInventoryFloatable(inst, float[1], float[2], float[3])
        else
            MakeInventoryFloatable(inst)
        end

		if VEGGIES[name].lure_data ~= nil then
			inst:AddTag("oceanfishing_lure")
		end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("edible")
        inst.components.edible.healthvalue = VEGGIES[name].health
        inst.components.edible.hungervalue = VEGGIES[name].hunger
        inst.components.edible.sanityvalue = VEGGIES[name].sanity or 0
        inst.components.edible.foodtype = FOODTYPE.VEGGIE
        inst.components.edible.secondaryfoodtype = VEGGIES[name].secondary_foodtype

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(VEGGIES[name].perishtime)
        inst.components.perishable:StartPerishing()
        inst.components.perishable.onperishreplacement = "spoiled_food"

        inst:AddComponent("stackable")
        if name ~= "pumpkin" and
            name ~= "eggplant" and
            name ~= "durian" and
            name ~= "watermelon" then
            inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
        end

        if name == "watermelon" then
            inst.components.edible.temperaturedelta = TUNING.COLD_FOOD_BONUS_TEMP
            inst.components.edible.temperatureduration = TUNING.FOOD_TEMP_BRIEF
        end

        if name == "kelp" then
            inst:AddComponent("repairer")
            inst.components.repairer.repairmaterial = MATERIALS.KELP
            inst.components.repairer.healthrepairvalue = TUNING.REPAIR_KELP_HEALTH
        end

		if dryable ~= nil then
			inst:AddComponent("dryable")
			inst.components.dryable:SetProduct(name.."_dried")
			inst.components.dryable:SetBuildFile(dryable.build)
			inst.components.dryable:SetDryTime(dryable.time)
		end

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        if usequagmireicon then
            inst.components.inventoryitem:ChangeImageName("quagmire_"..name)
        end

        -- Regular veggies are weighable but don't have a weight. They all show the same
        -- result when put in a trophyscale_oversizedveggies, and always replace other
        -- regular veggies when attempting to do so.
        if not SEEDLESS[name] then
            inst:AddComponent("weighable")
            inst.components.weighable.type = TROPHYSCALE_TYPES.OVERSIZEDVEGGIES
        end

        MakeSmallBurnable(inst)
        MakeSmallPropagator(inst)
        ---------------------

        inst:AddComponent("bait")

        ------------------------------------------------
        inst:AddComponent("tradable")

        ------------------------------------------------

        inst:AddComponent("cookable")
        inst.components.cookable.product = name.."_cooked"

		if VEGGIES[name].lure_data ~= nil then
			inst:AddComponent("oceanfishingtackle")
			inst.components.oceanfishingtackle:SetupLure(VEGGIES[name].lure_data)
		end

		local halloweenmoonmutable_settings = VEGGIES[name].halloweenmoonmutable_settings
		if halloweenmoonmutable_settings ~= nil then
			inst:AddComponent("halloweenmoonmutable")
			inst.components.halloweenmoonmutable:SetPrefabMutated(halloweenmoonmutable_settings.prefab)
			inst.components.halloweenmoonmutable:SetOnMutateFn(halloweenmoonmutable_settings.onmutatefn)
		end

        if TheNet:GetServerGameMode() == "quagmire" then
            event_server_data("quagmire", "prefabs/veggies").master_postinit(inst)
        end

        MakeHauntableLaunchAndPerish(inst)

        if name == "carrot" then
            inst.Spin = spin
            inst:AddComponent("timer")
            inst:ListenForEvent("timerdone", timerdone)
            inst:AddComponent("activatable")
            inst.components.activatable.OnActivate = OnActivateSpin
            inst.components.activatable.quickaction = true
            inst.components.inventoryitem:SetOnPickupFn(function()
                inst.Transform:SetNoFaced()
            end)
        end

        return inst
    end

    local function fn_cooked()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("cooked")
        inst.scrapbook_anim = "cooked"

        if VEGGIES[name].extra_tags_cooked then
            for _, extra_tag in ipairs(VEGGIES[name].extra_tags_cooked) do
                inst:AddTag(extra_tag)
            end
        end

        local float = VEGGIES[name].cooked_float_settings
        if float ~= nil then
            MakeInventoryFloatable(inst, float[1], float[2], float[3])
        else
            MakeInventoryFloatable(inst)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(VEGGIES[name].cooked_perishtime)
        inst.components.perishable:StartPerishing()
        inst.components.perishable.onperishreplacement = "spoiled_food"

        inst:AddComponent("edible")
        inst.components.edible.healthvalue = VEGGIES[name].cooked_health
        inst.components.edible.hungervalue = VEGGIES[name].cooked_hunger
        inst.components.edible.sanityvalue = VEGGIES[name].cooked_sanity or 0
        inst.components.edible.foodtype = FOODTYPE.VEGGIE
        inst.components.edible.secondaryfoodtype = VEGGIES[name].secondary_foodtype

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        if usequagmireicon then
            inst.components.inventoryitem:ChangeImageName("quagmire_"..name.."_cooked")
        end

        MakeSmallBurnable(inst)
        MakeSmallPropagator(inst)
        ---------------------

        inst:AddComponent("bait")

        ------------------------------------------------
        inst:AddComponent("tradable")

        if TheNet:GetServerGameMode() == "quagmire" then
            event_server_data("quagmire", "prefabs/veggies").master_postinit_cooked(inst)
        end

        MakeHauntableLaunchAndPerish(inst)

        return inst
    end

	local function fn_dried()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddNetwork()

		MakeInventoryPhysics(inst)

		inst.AnimState:SetBank(dryable.build)
		inst.AnimState:SetBuild(dryable.build)
		inst.AnimState:PlayAnimation("dried_"..name)
        inst.scrapbook_anim = "dried_"..name

		MakeInventoryFloatable(inst)

		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			return inst
		end

		inst:AddComponent("perishable")
		inst.components.perishable:SetPerishTime(dryable.perish)
		inst.components.perishable:StartPerishing()
		inst.components.perishable.onperishreplacement = "spoiled_food"

		inst:AddComponent("edible")
		inst.components.edible.healthvalue = dryable.health or 0
		inst.components.edible.hungervalue = dryable.hunger or 0
		inst.components.edible.sanityvalue = dryable.sanity or 0
		inst.components.edible.foodtype = FOODTYPE.VEGGIE

		inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

		inst:AddComponent("inspectable")
		inst:AddComponent("inventoryitem")

		MakeSmallBurnable(inst)
		MakeSmallPropagator(inst)

		inst:AddComponent("bait")

		inst:AddComponent("tradable")

		MakeHauntableLaunchAndPerish(inst)

		return inst
    end

    local function fn_oversized()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        local plant_def = PLANT_DEFS[name]

        inst.AnimState:SetBank(plant_def.bank)
        inst.AnimState:SetBuild(plant_def.build)
        inst.AnimState:PlayAnimation("idle_oversized")
        inst.scrapbook_anim = "idle_oversized"

        inst:AddTag("heavy")
        inst:AddTag("waxable")
        inst:AddTag("oversized_veggie")
	    inst:AddTag("show_spoilage")
        inst.gymweight = 4

        MakeHeavyObstaclePhysics(inst, OVERSIZED_PHYSICS_RADIUS)
        inst:SetPhysicsRadiusOverride(OVERSIZED_PHYSICS_RADIUS)

        inst._base_name = name

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.harvested_on_day = inst.harvested_on_day or (TheWorld.state.cycles + 1)

        inst:AddComponent("heavyobstaclephysics")
        inst.components.heavyobstaclephysics:SetRadius(OVERSIZED_PHYSICS_RADIUS)

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(VEGGIES[name].perishtime * OVERSIZED_PERISHTIME_MULT)
        inst.components.perishable:StartPerishing()
        inst.components.perishable.onperishreplacement = nil
        inst.components.perishable:SetOnPerishFn(oversized_onperish)

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.cangoincontainer = false
        inst.components.inventoryitem:SetSinks(true)

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.BODY
        inst.components.equippable:SetOnEquip(oversized_onequip)
        inst.components.equippable:SetOnUnequip(oversized_onunequip)
        inst.components.equippable.walkspeedmult = TUNING.HEAVY_SPEED_MULT

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetOnFinishCallback(oversized_onfinishwork)
        inst.components.workable:SetWorkLeft(OVERSIZED_MAXWORK)

        inst:AddComponent("waxable")
        inst.components.waxable:SetWaxfn(dowaxfn)

        inst:AddComponent("submersible")
        inst:AddComponent("symbolswapdata")
        inst.components.symbolswapdata:SetData(plant_def.build, "swap_body")

        local weight_data = plant_def.weight_data
        inst:AddComponent("weighable")
        inst.components.weighable.type = TROPHYSCALE_TYPES.OVERSIZEDVEGGIES
        inst.components.weighable:Initialize(weight_data[1], weight_data[2])
        local coefficient = oversized_calcweightcoefficient(name)
        inst.components.weighable:SetWeight(Lerp(weight_data[1], weight_data[2], coefficient))

        inst:AddComponent("lootdropper")
        inst.components.lootdropper:SetLoot(oversized_makeloots(inst, name))

        MakeMediumBurnable(inst)
        inst.components.burnable:SetOnBurntFn(oversized_onburnt)
        MakeMediumPropagator(inst)

        MakeHauntableWork(inst)

        inst.from_plant = false

		inst.OnSave = Oversized_OnSave
		inst.OnPreLoad = Oversized_OnPreLoad

        return inst
    end

    local function fn_oversized_waxed()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        local plant_def = PLANT_DEFS[name]

        inst.AnimState:SetBank(plant_def.bank)
        inst.AnimState:SetBuild(plant_def.build)
        inst.AnimState:PlayAnimation("idle_oversized")
        inst.scrapbook_anim = "idle_oversized"

        inst:AddTag("heavy")
        inst:AddTag("oversized_veggie")

        inst.gymweight = 4

        inst.displayadjectivefn = displayadjectivefn
        inst:SetPrefabNameOverride(name.."_oversized")

        MakeHeavyObstaclePhysics(inst, OVERSIZED_PHYSICS_RADIUS)
        inst:SetPhysicsRadiusOverride(OVERSIZED_PHYSICS_RADIUS)

        inst._base_name = name

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("heavyobstaclephysics")
        inst.components.heavyobstaclephysics:SetRadius(OVERSIZED_PHYSICS_RADIUS)

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.cangoincontainer = false
        inst.components.inventoryitem:SetSinks(true)

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.BODY
        inst.components.equippable:SetOnEquip(oversized_onequip)
        inst.components.equippable:SetOnUnequip(oversized_onunequip)
        inst.components.equippable.walkspeedmult = TUNING.HEAVY_SPEED_MULT

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetOnFinishCallback(oversized_onfinishwork)
        inst.components.workable:SetWorkLeft(OVERSIZED_MAXWORK)

        inst:AddComponent("submersible")
        inst:AddComponent("symbolswapdata")
        inst.components.symbolswapdata:SetData(plant_def.build, "swap_body")

        inst:AddComponent("lootdropper")
        inst.components.lootdropper:SetLoot({"spoiled_food"})

        MakeMediumBurnable(inst)
        inst.components.burnable:SetOnBurntFn(oversized_onburnt)
        MakeMediumPropagator(inst)

        MakeHauntableWork(inst)

        inst:ListenForEvent("onputininventory", CancelWaxTask)
        inst:ListenForEvent("ondropped", StartWaxTask)

        inst.OnEntitySleep = CancelWaxTask
        inst.OnEntityWake = StartWaxTask

        StartWaxTask(inst)

        return inst
    end

    local function fn_oversized_rotten()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        local plant_def = PLANT_DEFS[name]

        inst.AnimState:SetBank(plant_def.bank)
        inst.AnimState:SetBuild(plant_def.build)
        inst.AnimState:PlayAnimation("idle_rot_oversized")
        inst.scrapbook_anim = "idle_rot_oversized"

        inst:AddTag("heavy")
        inst:AddTag("farm_plant_killjoy")
        inst:AddTag("pickable_harvest_str")
		inst:AddTag("pickable")
        inst:AddTag("oversized_veggie")
        inst.gymweight = 3

        MakeHeavyObstaclePhysics(inst, OVERSIZED_PHYSICS_RADIUS)
        inst:SetPhysicsRadiusOverride(OVERSIZED_PHYSICS_RADIUS)

		inst._base_name = name

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("heavyobstaclephysics")
        inst.components.heavyobstaclephysics:SetRadius(OVERSIZED_PHYSICS_RADIUS)

        inst:AddComponent("inspectable")
		inst.components.inspectable.nameoverride = "VEGGIE_OVERSIZED_ROTTEN"

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetOnFinishCallback(oversized_onfinishwork)
        inst.components.workable:SetWorkLeft(OVERSIZED_MAXWORK)

        inst:AddComponent("pickable")
		inst.components.pickable.remove_when_picked = true
	    inst.components.pickable:SetUp(nil)
		inst.components.pickable.use_lootdropper_for_product = true
	    inst.components.pickable.picksound = "dontstarve/wilson/harvest_berries"

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.cangoincontainer = false
		--inst.components.inventoryitem.canbepickedup = false
        inst.components.inventoryitem:SetSinks(true)

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.BODY
        inst.components.equippable:SetOnEquip(oversized_onequip)
        inst.components.equippable:SetOnUnequip(oversized_onunequip)
        inst.components.equippable.walkspeedmult = TUNING.HEAVY_SPEED_MULT

        inst:AddComponent("submersible")
        inst:AddComponent("symbolswapdata")
        inst.components.symbolswapdata:SetData(plant_def.build, "swap_body_rotten")

        inst:AddComponent("lootdropper")
        inst.components.lootdropper:SetLoot(plant_def.loot_oversized_rot)

        inst.components.inventoryitem:ChangeImageName( name.."_oversized_rot" )

        MakeMediumBurnable(inst)
        inst.components.burnable:SetOnBurntFn(oversized_onburnt)
        MakeMediumPropagator(inst)

        MakeHauntableWork(inst)

        return inst
    end

    local exported_prefabs = {}

	if has_seeds then
		table.insert(exported_prefabs, Prefab(name.."_seeds", fn_seeds, assets_seeds, seeds_prefabs))
        table.insert(exported_prefabs, Prefab(name.."_oversized", fn_oversized, assets_oversized))
        table.insert(exported_prefabs, Prefab(name.."_oversized_waxed", fn_oversized_waxed, assets_oversized))
        table.insert(exported_prefabs, Prefab(name.."_oversized_rotten", fn_oversized_rotten, assets_oversized))
	end
	if dryable ~= nil then
		table.insert(exported_prefabs, Prefab(name.."_dried", fn_dried, assets_dried))
    end

    table.insert(exported_prefabs, Prefab(name, fn, assets, prefabs))
    table.insert(exported_prefabs, Prefab(name.."_cooked", fn_cooked, assets_cooked))

    return exported_prefabs
end

local prefs = {}
for veggiename,veggiedata in pairs(VEGGIES) do
    local veggies = MakeVeggie(veggiename, not SEEDLESS[veggiename])
	for _, v in ipairs(veggies) do
		table.insert(prefs, v)
	end
end

return unpack(prefs)
