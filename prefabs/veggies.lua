require "tuning"

local function MakeVegStats(seedweight, hunger, health, perish_time, sanity, cooked_hunger, cooked_health, cooked_perish_time, cooked_sanity, float_settings, cooked_float_settings, dryable)
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
    }
end

local COMMON = 3
local UNCOMMON = 1
local RARE = .5

local QUAGMIRE_PORTS =
{
    "tomato",
    "potato",
    "onion",
    "garlic",
}

VEGGIES =
{
    cave_banana = MakeVegStats(0,   TUNING.CALORIES_SMALL,  TUNING.HEALING_TINY,    TUNING.PERISH_MED, 0,
                                    TUNING.CALORIES_SMALL,  TUNING.HEALING_SMALL,   TUNING.PERISH_FAST, 0,
                                    {"small", 0.05, 0.9},   {"med", nil, 0.75}),

    carrot = MakeVegStats(COMMON,   TUNING.CALORIES_SMALL,  TUNING.HEALING_TINY,    TUNING.PERISH_MED, 0,
                                    TUNING.CALORIES_SMALL,  TUNING.HEALING_SMALL,   TUNING.PERISH_FAST, 0,
                                    {"med", 0.05, 0.8},    {"small", 0.1, nil}),

    corn = MakeVegStats(COMMON, TUNING.CALORIES_MED,    TUNING.HEALING_SMALL,   TUNING.PERISH_MED, 0,
                                TUNING.CALORIES_SMALL,  TUNING.HEALING_SMALL,   TUNING.PERISH_SLOW, 0),
    
    pumpkin = MakeVegStats(UNCOMMON,    TUNING.CALORIES_LARGE,  TUNING.HEALING_SMALL,       IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) and TUNING.PERISH_PRESERVED or TUNING.PERISH_MED, 0,
                                        TUNING.CALORIES_LARGE,  TUNING.HEALING_MEDSMALL,    TUNING.PERISH_FAST, 0,
                                        nil,    {"small", 0.1, nil}),
    
    eggplant = MakeVegStats(UNCOMMON,   TUNING.CALORIES_MED,    TUNING.HEALING_MEDSMALL,    TUNING.PERISH_MED, 0,
                                        TUNING.CALORIES_MED,    TUNING.HEALING_MED,     TUNING.PERISH_FAST, 0),
    
    durian = MakeVegStats(RARE, TUNING.CALORIES_MED,    -TUNING.HEALING_SMALL,  TUNING.PERISH_MED, -TUNING.SANITY_TINY,
                                TUNING.CALORIES_MED,    0,                      TUNING.PERISH_FAST, -TUNING.SANITY_TINY),
    
    pomegranate = MakeVegStats(RARE,    TUNING.CALORIES_TINY,   TUNING.HEALING_SMALL,       TUNING.PERISH_FAST, 0,
                                        TUNING.CALORIES_SMALL,  TUNING.HEALING_MED, TUNING.PERISH_SUPERFAST, 0,
                                        {"small", nil, 0.8},    {"small", nil, 0.8}),
    
    dragonfruit = MakeVegStats(RARE,    TUNING.CALORIES_TINY,   TUNING.HEALING_SMALL,       TUNING.PERISH_FAST, 0,
                                        TUNING.CALORIES_SMALL,  TUNING.HEALING_MED, TUNING.PERISH_SUPERFAST, 0,
                                        {"small", 0.1, 0.8},    {"small", 0.05, nil}),

    berries = MakeVegStats(0,   TUNING.CALORIES_TINY,   0,  TUNING.PERISH_FAST, 0,
                                TUNING.CALORIES_SMALL,  TUNING.HEALING_TINY,    TUNING.PERISH_SUPERFAST, 0,
                                {"med", nil, 0.7},      {"med", nil, 0.65}),

    berries_juicy = MakeVegStats(0,   TUNING.CALORIES_SMALL,  TUNING.HEALING_TINY,  TUNING.PERISH_TWO_DAY, 0,
                                     TUNING.CALORIES_MEDSMALL,  TUNING.HEALING_SMALL,    TUNING.PERISH_ONE_DAY, 0,
                                     {"med", nil, 0.7}),

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
                                  {nil, 0.1, 0.75} ),

    potato = MakeVegStats(COMMON, TUNING.CALORIES_SMALL, -TUNING.HEALING_SMALL, TUNING.PERISH_MED, -TUNING.SANITY_TINY,
                                  TUNING.CALORIES_MED, TUNING.HEALING_MED, TUNING.PERISH_FAST, 0,
                                  {nil, 0.05, 0.65} ),

    asparagus = MakeVegStats(UNCOMMON, TUNING.CALORIES_SMALL, TUNING.HEALING_SMALL, TUNING.PERISH_FAST, 0,
                                     TUNING.CALORIES_MED, TUNING.HEALING_SMALL, TUNING.PERISH_SUPERFAST, 0,
                                     {"med", nil, 0.7}),

    onion = MakeVegStats(RARE, TUNING.CALORIES_TINY, 0, TUNING.PERISH_SLOW, -TUNING.SANITY_SMALL, 
                                   TUNING.CALORIES_TINY, TUNING.HEALING_TINY, TUNING.PERISH_MED, -TUNING.SANITY_TINY,
                                   {"large", 0.05, 0.45} ),
    
    garlic = MakeVegStats(RARE, TUNING.CALORIES_TINY, 0, TUNING.PERISH_SLOW, -TUNING.SANITY_SMALL, 
                                   TUNING.CALORIES_TINY, TUNING.HEALING_TINY, TUNING.PERISH_MED, -TUNING.SANITY_TINY,
                                   {nil, 0.05, 0.775} ),
    
    pepper = MakeVegStats(RARE, TUNING.CALORIES_TINY, -TUNING.HEALING_MED, TUNING.PERISH_SLOW, -TUNING.SANITY_MED, 
                                    TUNING.CALORIES_TINY, -TUNING.HEALING_SMALL, TUNING.PERISH_SLOW, -TUNING.SANITY_SMALL,
                                    {nil, 0.1, 0.75} ),
}

local SEEDLESS = 
{
	berries = true, 
	cave_banana = true,
	cactus_meat = true,
	berries_juicy = true,
	kelp = true,
}

local assets_seeds =
{
    Asset("ANIM", "anim/seeds.zip"),
}

local prefabs_seeds =
{
    "plant_normal_ground",
    "seeds_placer",
}

local function OnDeploy(inst, pt)--, deployer, rot)
    local plant = SpawnPrefab("plant_normal_ground")
    plant.components.crop:StartGrowing(inst.components.plantable.product, inst.components.plantable.growtime)
    plant.Transform:SetPosition(pt.x, 0, pt.z)
    plant.SoundEmitter:PlaySound("dontstarve/wilson/plant_seeds")
    inst:Remove()
end

local function MakeVeggie(name, has_seeds)
    local assets =
    {
        Asset("ANIM", "anim/"..name..".zip"),
        Asset("INV_IMAGE", name),
    }

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

    local function fn_seeds()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("seeds")
        inst.AnimState:SetBuild("seeds")
        inst.AnimState:SetRayTestOnBB(true)

        inst:AddTag("deployedplant")

        --cookable (from cookable component) added to pristine state for optimization
        inst:AddTag("cookable")

        inst.overridedeployplacername = "seeds_placer"

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

        inst.AnimState:PlayAnimation("idle")
        inst.components.edible.healthvalue = TUNING.HEALING_TINY / 2
        inst.components.edible.hungervalue = TUNING.CALORIES_TINY

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW)
        inst.components.perishable:StartPerishing()
        inst.components.perishable.onperishreplacement = "spoiled_food"

        inst:AddComponent("cookable")
        inst.components.cookable.product = "seeds_cooked"

        inst:AddComponent("bait")
        inst:AddComponent("plantable")
        inst.components.plantable.growtime = TUNING.SEEDS_GROW_TIME
        inst.components.plantable.product = name

        inst:AddComponent("deployable")
        inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
        inst.components.deployable.restrictedtag = "plantkin"
        inst.components.deployable.ondeploy = OnDeploy

        MakeHauntableLaunchAndPerish(inst)

        return inst
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle")

        --cookable (from cookable component) added to pristine state for optimization
        inst:AddTag("cookable")

		if dryable ~= nil then
			--dryable (from dryable component) added to pristine state for optimization
			inst:AddTag("dryable")
		end

        local float = VEGGIES[name].float_settings
        if float ~= nil then
            MakeInventoryFloatable(inst, float[1], float[2], float[3])
        else
            MakeInventoryFloatable(inst)
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

        MakeSmallBurnable(inst)
        MakeSmallPropagator(inst)
        ---------------------        

        inst:AddComponent("bait")

        ------------------------------------------------
        inst:AddComponent("tradable")

        ------------------------------------------------  

        inst:AddComponent("cookable")
        inst.components.cookable.product = name.."_cooked"

        if TheNet:GetServerGameMode() == "quagmire" then
            event_server_data("quagmire", "prefabs/veggies").master_postinit(inst)
        end

        MakeHauntableLaunchAndPerish(inst)

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

    local base = Prefab(name, fn, assets, prefabs)
    local cooked = Prefab(name.."_cooked", fn_cooked, assets_cooked)
    local seeds = has_seeds and Prefab(name.."_seeds", fn_seeds, assets_seeds, prefabs_seeds) or nil
	local function fn_dried()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddNetwork()

		MakeInventoryPhysics(inst)

		inst.AnimState:SetBank(dryable.build)
		inst.AnimState:SetBuild(dryable.build)
		inst.AnimState:PlayAnimation("dried_"..name)

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

	local prefabs = 
	{
		Prefab(name, fn, assets, prefabs),
		Prefab(name.."_cooked", fn_cooked, assets_cooked)
	}
	if has_seeds then
		table.insert(prefabs, Prefab(name.."_seeds", fn_seeds, assets_seeds))
	end
	if dryable ~= nil then
		table.insert(prefabs, Prefab(name.."_dried", fn_dried, assets_dried))
	end

    return prefabs
end

local prefs = {}
for veggiename,veggiedata in pairs(VEGGIES) do
    local veggies = MakeVeggie(veggiename, not SEEDLESS[veggiename])
	for _, v in ipairs(veggies) do
		table.insert(prefs, v)
	end
end

return unpack(prefs)
