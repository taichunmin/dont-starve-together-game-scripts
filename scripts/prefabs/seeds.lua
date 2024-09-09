require "prefabs/veggies"
require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/seeds.zip"),
	Asset("ANIM", "anim/oceanfishing_lure_mis.zip"),
}

local prefabs =
{
    "seeds_cooked",
    "spoiled_food",
    "plant_normal_ground",
	"farm_plant_randomseed",
	"carrot",
}

local scrapbook_removedeps =
{
	"berries",
	"cave_banana",
	"cactus_meat",
	"berries_juicy",
	"fig",
	"kelp",
}

for k,v in pairs(VEGGIES) do
    table.insert(prefabs, k)
	if v.seed_weight ~= nil and v.seed_weight > 0 then
	    table.insert(prefabs, "farm_plant_"..k)
	end
end

local WEED_DEFS = require("prefabs/weed_defs").WEED_DEFS
for k, v in pairs(WEED_DEFS) do
	if v.seed_weight ~= nil and v.seed_weight > 0 then
	    table.insert(prefabs, k)
	end
end

local function pickproduct()
    local total_w = 0
    for k,v in pairs(VEGGIES) do
        total_w = total_w + (v.seed_weight or 1)
    end

    local rnd = math.random()*total_w
    for k,v in pairs(VEGGIES) do
        rnd = rnd - (v.seed_weight or 1)
        if rnd <= 0 then
            return k
        end
    end

    return "carrot"
end

local function pickfarmplant()
    return "farm_plant_randomseed"
end

local function common(anim, cookable, oceanfishing_lure)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("seeds")
    inst.AnimState:SetBuild("seeds")
    inst.AnimState:PlayAnimation(anim)
    inst.AnimState:SetRayTestOnBB(true)

    inst.pickupsound = "vegetation_firm"

    if cookable then
        inst:AddTag("deployedplant")
        inst:AddTag("deployedfarmplant")

        --cookable (from cookable component) added to pristine state for optimization
        inst:AddTag("cookable")
    end

	if oceanfishing_lure then
		inst:AddTag("oceanfishing_lure")
	end

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.SEEDS

    if cookable then
        inst:AddComponent("cookable")
        inst.components.cookable.product = "seeds_cooked"
    end

    inst:AddComponent("tradable")
    inst:AddComponent("inspectable")

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    MakeHauntableLaunchAndPerish(inst)

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst.scrapbook_removedeps = scrapbook_removedeps

    return inst
end

local function OnDeploy(inst, pt, deployer) --, rot)
    local plant = SpawnPrefab("farm_plant_randomseed")
    plant.Transform:SetPosition(pt.x, 0, pt.z)
    plant:PushEvent("on_planted", {in_soil = false, doer = deployer, seed = inst})
    TheWorld.Map:CollapseSoilAtPoint(pt.x, 0, pt.z)
    --plant.SoundEmitter:PlaySound("dontstarve/wilson/plant_seeds")
    inst:Remove()
end

local function can_plant_seed(inst, pt, mouseover, deployer)
	local x, z = pt.x, pt.z
	return TheWorld.Map:CanTillSoilAtPoint(x, 0, z, true)
end

local function raw()
    local inst = common("idle", true, true)

	inst._custom_candeploy_fn = can_plant_seed -- for DEPLOYMODE.CUSTOM

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY/2

    inst:AddComponent("bait")

    inst:AddComponent("farmplantable")
    inst.components.farmplantable.plant = pickfarmplant --"farm_plant_watermelon"

	inst:AddComponent("oceanfishingtackle")
	inst.components.oceanfishingtackle:SetupLure({build = "oceanfishing_lure_mis", symbol = "hook_seeds", single_use = true, lure_data = TUNING.OCEANFISHING_LURE.SEED})

    inst:AddComponent("deployable")
    inst.components.deployable:SetDeployMode(DEPLOYMODE.CUSTOM) -- use inst._custom_candeploy_fn
    inst.components.deployable.restrictedtag = "plantkin"
    inst.components.deployable.ondeploy = OnDeploy

	 -- deprecated (used for crafted farm structures)
    inst:AddComponent("plantable")
    inst.components.plantable.growtime = TUNING.SEEDS_GROW_TIME
    inst.components.plantable.product = pickproduct

    return inst
end

local function cooked()
    local inst = common("cooked")

    inst.components.floater:SetScale(0.8)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY / 2
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)

    return inst
end

local function update_seed_placer_outline(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	if TheWorld.Map:CanTillSoilAtPoint(x, y, z) then
		local cx, cy, cz = TheWorld.Map:GetTileCenterPoint(x, y, z)
		inst.outline.Transform:SetPosition(cx, cy, cz)
		inst.outline:Show()
	else
		inst.outline:Hide()
	end
end

local function seed_placer_postinit(inst)
	inst.outline = SpawnPrefab("tile_outline")

	inst.outline.Transform:SetPosition(2, 0, 0)
	inst.outline:ListenForEvent("onremove", function() inst.outline:Remove() end, inst)
	inst.outline.AnimState:SetAddColour(.25, .75, .25, 0)
	inst.outline:Hide()

	inst.components.placer.onupdatetransform = update_seed_placer_outline
end

return Prefab("seeds", raw, assets, prefabs),
    Prefab("seeds_cooked", cooked, assets),
    MakePlacer("seeds_placer", "farm_soil", "farm_soil", "till_idle", nil, nil, nil, nil, nil, nil, seed_placer_postinit)
