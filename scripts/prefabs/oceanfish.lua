local FISH_DATA = require("prefabs/oceanfishdef")

local easing = require("easing")

local SWIMMING_COLLISION_MASK   = COLLISION.GROUND
								+ COLLISION.LAND_OCEAN_LIMITS
								+ COLLISION.OBSTACLES
								+ COLLISION.SMALLOBSTACLES
local PROJECTILE_COLLISION_MASK = COLLISION.GROUND

local function CalcNewSize()
	return math.random()
end

local brain = require "brains/oceanfishbrain"

local function flopsoundcheck(inst)
	if inst.AnimState:IsCurrentAnimation("flop_loop") then
		inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishland")
	end
end

local function Flop(inst)
	if inst.flopsnd1 then inst.flopsnd1:Cancel() inst.flopsnd1 = nil end
	if inst.flopsnd2 then inst.flopsnd2:Cancel() inst.flopsnd2 = nil end
	if inst.flopsnd3 then inst.flopsnd3:Cancel() inst.flopsnd3 = nil end
	if inst.flopsnd4 then inst.flopsnd4:Cancel() inst.flopsnd4 = nil end

	inst.AnimState:PlayAnimation("flop_pre", false)
	local num = math.random(3)
	inst.AnimState:PushAnimation("flop_loop", false)
	for i = 1, num do
		inst.AnimState:PushAnimation("flop_loop", false)
	end
	inst.AnimState:PushAnimation("flop_pst", false)

	inst.flopsnd1 = inst:DoTaskInTime((5+9)*FRAMES, flopsoundcheck)
	inst.flopsnd2 = inst:DoTaskInTime((5+9+13)*FRAMES, flopsoundcheck)
	inst.flopsnd3 = inst:DoTaskInTime((5+9+26)*FRAMES, flopsoundcheck)
	inst.flopsnd4 = inst:DoTaskInTime((5+9+39)*FRAMES, flopsoundcheck)

	inst.flop_task = inst:DoTaskInTime(math.random() + 2 + 0.5*num, Flop)
end

local function OnInventoryLanded(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	if TheWorld.Map:IsPassableAtPoint(x, y, z) then
		if inst.flop_task ~= nil then
			inst.flop_task:Cancel()
		end
		inst.flop_task = inst:DoTaskInTime(math.random() + 2 + 0.5*math.random(3), Flop)
	else
		local fish = SpawnPrefab(inst.fish_def.prefab)
		fish.Transform:SetPosition(x, y, z)
		fish.Transform:SetRotation(inst.Transform:GetRotation())
		fish.leaving = true
		fish.persists = false

		SpawnPrefab("splash").Transform:SetPosition(x, y, z)

		inst:Remove()
	end
end

local function onpickup(inst)
	if inst.flop_task ~= nil then
		inst.flop_task:Cancel()
		inst.flop_task = nil
	end
end

local function OnProjectileLand(inst)
	local x, y, z = inst.Transform:GetWorldPosition()

	local landed_in_water = not TheWorld.Map:IsPassableAtPoint(x, y, z)
	if landed_in_water then
	    inst:RemoveComponent("complexprojectile")
		inst.Physics:SetCollisionMask(SWIMMING_COLLISION_MASK)
		inst.AnimState:SetSortOrder(ANIM_SORT_ORDER_BELOW_GROUND.UNDERWATER)
		inst.AnimState:SetLayer(LAYER_WIP_BELOW_OCEAN)
		if inst.Light ~= nil then
			inst.Light:Enable(false)
		end
		if inst.components.weighable ~= nil then
			inst.components.weighable:SetPlayerAsOwner(nil)
		end
		inst.leaving = true
		inst.persists = false
		inst.sg:GoToState("idle")
		inst:RestartBrain()
	    SpawnPrefab("splash").Transform:SetPosition(x, y, z)
	else
		local fish = SpawnPrefab(inst.fish_def.prefab.."_inv")
		fish.Transform:SetPosition(x, y, z)
		fish.Transform:SetRotation(inst.Transform:GetRotation())
		fish.components.inventoryitem:SetLanded(true, false)
		fish.components.inventoryitem:MakeMoistureAtLeast(TUNING.MAX_WETNESS)
		if fish.flop_task then
			fish.flop_task:Cancel()
		end
		Flop(fish)
		if inst.components.oceanfishable ~= nil and fish.components.weighable ~= nil then
			fish.components.weighable:CopyWeighable(inst.components.weighable)
			inst.components.weighable:SetPlayerAsOwner(nil)
		end

	    inst:Remove()
	end
end

local function OnMakeProjectile(inst)
    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetOnHit(OnProjectileLand)

	inst:StopBrain()
	inst.sg:GoToState("launched_out_of_water")

	inst.Physics:SetCollisionMask(PROJECTILE_COLLISION_MASK)

    inst.AnimState:SetSortOrder(0)
    inst.AnimState:SetLayer(LAYER_WORLD)
	if inst.Light ~= nil then
		inst.Light:Enable(true)
	end

    SpawnPrefab("splash").Transform:SetPosition(inst.Transform:GetWorldPosition())

	return inst
end

local function OnTimerDone(inst, data)
	if data ~= nil and data.name == "lifespan" then
		if inst.components.oceanfishable:GetRod() == nil then
			inst:RemoveComponent("oceanfishable")
			inst.sg:GoToState("leave")
		else
			inst.components.timer:StartTimer("lifespan", 30)
		end
	end
end

local function OnReelingIn(inst, doer)
	if inst:HasTag("partiallyhooked") then
		-- now fully hooked!
		inst:RemoveTag("partiallyhooked")
		inst.components.oceanfishable:ResetStruggling()
        if inst.components.homeseeker ~= nil
                and inst.components.homeseeker.home ~= nil
                and inst.components.homeseeker.home:IsValid()
                and inst.components.homeseeker.home.prefab == "oceanfish_shoalspawner" then
            TheWorld:PushEvent("ms_shoalfishhooked", inst.components.homeseeker.home)
        end
	end
end

local function OnSetRod(inst, rod)
	if rod ~= nil then
		inst:AddTag("partiallyhooked")
		inst:AddTag("scarytooceanprey")
	else
		inst:RemoveTag("partiallyhooked")
		inst:RemoveTag("scarytooceanprey")
	end
end

local function ondroppedasloot(inst, data)
	if data ~= nil and data.dropper ~= nil then
		inst.components.weighable.prefab_override_owner = data.dropper.prefab
	end
end

local function HandleEntitySleep(inst)
	local home = inst.components.homeseeker and inst.components.homeseeker.home or nil
	if home ~= nil and home:IsValid() and not inst.leaving and inst.persists then
		home.components.childspawner:GoHome(inst)
	else
		inst:Remove()
	end
	inst.remove_task = nil
end

local function topocket(inst)
	if inst.components.propagator ~= nil then
	    inst.components.propagator:StopSpreading()
	end
end

local function toground(inst)
	if inst.components.propagator ~= nil then
	    inst.components.propagator:StartSpreading()
	end
end

local function spread_protection_at_point(inst, fire_pos)
    inst.components.wateryprotection:SpreadProtectionAtPoint(fire_pos:Get())
end

local function on_find_fire(inst, fire_pos)
    if inst:IsAsleep() then
        inst:DoTaskInTime(1 + math.random(), spread_protection_at_point, fire_pos)
    else
        inst:PushEvent("putoutfire", {firePos = fire_pos})
    end
end

local MAX_SPIT_RANGE_SQ = TUNING.OCEANFISH.SPRINKLER_DETECT_RANGE * TUNING.OCEANFISH.SPRINKLER_DETECT_RANGE
local SPIT_SPEED_BASE = 5
local SPIT_SPEED_ADD = 7
local function launch_water_projectile(inst, target_position)
    local x, y, z = inst.Transform:GetWorldPosition()

    local projectile = SpawnPrefab("waterstreak_projectile")
    projectile.Transform:SetPosition(x, y, z)

    local dx, dz = target_position.x - x, target_position.z - z
    local range_sq = (dx * dx) + (dz * dz)
    local speed = easing.linear(range_sq, SPIT_SPEED_BASE, SPIT_SPEED_ADD, MAX_SPIT_RANGE_SQ)

    projectile.components.complexprojectile:SetHorizontalSpeed(speed)
    projectile.components.complexprojectile:SetLaunchOffset(Vector3(1.0, 2.85, 0))
    projectile.components.complexprojectile:SetGravity(-16)
    projectile.components.complexprojectile:Launch(target_position, inst, inst)
end

local function Inv_LootSetupFn(lootdropper)
	local inst = lootdropper.inst

	if inst.components.weighable ~= nil and
		inst.components.weighable:GetWeightPercent() >= TUNING.WEIGHABLE_HEAVY_LOOT_WEIGHT_PERCENT
	then
		lootdropper:SetLoot(inst.fish_def.heavy_loot)
	end
end

local function OnEntityWake(inst)
	if inst.remove_task ~= nil then
		inst.remove_task:Cancel()
		inst.remove_task = nil
	end
end

local function OnEntitySleep(inst)
	if not POPULATING then
		inst.remove_task = inst:DoTaskInTime(.1, HandleEntitySleep)
	end
end

local function OnSave(inst, data)
	if inst.components.herdmember.herdprefab then
    	data.herdprefab = inst.components.herdmember.herdprefab
    end
    if inst.heavy then
    	data.heavy = true
    end
end

local function OnLoad(inst, data)
    if data ~= nil and data.herdprefab ~= nil then
        inst.components.herdmember.herdprefab = data.herdprefab
    end
    if data ~= nil and data.heavy then
		inst.heavy = data.heavy
    end
end

local function water_common(data)
   local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

	if data.light ~= nil then
		inst.entity:AddLight()
		inst.Light:SetRadius(data.light.r)
		inst.Light:SetFalloff(data.light.f)
		inst.Light:SetIntensity(data.light.i)
		inst.Light:SetColour(unpack(data.light.c))
		inst.Light:Enable(false)
	end

	inst.entity:AddPhysics()

	inst.Transform:SetSixFaced()

    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
	inst.Physics:SetCollisionMask(SWIMMING_COLLISION_MASK)
    inst.Physics:SetCapsule(0.5, 1)

    inst:AddTag("ignorewalkableplatforms")
	inst:AddTag("notarget")
	inst:AddTag("NOCLICK")
	inst:AddTag("NOBLOCK")
	inst:AddTag("oceanfishable")
    inst:AddTag("oceanfishable_creature")
	inst:AddTag("oceanfishinghookable")
	inst:AddTag("oceanfish")
	inst:AddTag("swimming")
	inst:AddTag("herd_"..data.prefab)
	if data.fishtype ~= nil then
	    inst:AddTag("ediblefish_"..data.fishtype)
	end
	if data.tags ~= nil then
		for _, tag in ipairs(data.tags) do
			inst:AddTag(tag)
		end
	end

    inst.AnimState:SetBank(data.bank)
    inst.AnimState:SetBuild(data.build)
    inst.AnimState:PlayAnimation("idle_loop")

    inst.scrapbook_anim = "flop_pst"

    inst.AnimState:SetSortOrder(ANIM_SORT_ORDER_BELOW_GROUND.UNDERWATER)
	inst.AnimState:SetLayer(LAYER_WIP_BELOW_OCEAN)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

	inst.fish_def = data

	--inst.leaving = nil

    local locomotor = inst:AddComponent("locomotor")
    locomotor:EnableGroundSpeedMultiplier(false)
    locomotor:SetTriggersCreep(false)
    locomotor.walkspeed = data and data.walkspeed or TUNING.OCEANFISH.WALKSPEED
    locomotor.runspeed = data and data.runspeed or TUNING.OCEANFISH.RUNSPEED
    locomotor.pathcaps = { allowocean = true, ignoreLand = true }

    local oceanfishable = inst:AddComponent("oceanfishable")
    oceanfishable.makeprojectilefn = OnMakeProjectile
    oceanfishable.onreelinginfn = OnReelingIn
    oceanfishable.onsetrodfn = OnSetRod
    oceanfishable:StrugglingSetup(inst.components.locomotor.walkspeed, inst.components.locomotor.runspeed, data.stamina or TUNING.OCEANFISH.FISHABLE_STAMINA)
    oceanfishable.catch_distance = TUNING.OCEAN_FISHING.FISHING_CATCH_DIST

    local eater = inst:AddComponent("eater")

	if data and data.diet then
		eater:SetDiet(data.diet.caneat or { FOODGROUP.BERRIES_AND_SEEDS }, data.diet.preferseating)
	else
		eater:SetDiet({ FOODGROUP.BERRIES_AND_SEEDS }, { FOODGROUP.BERRIES_AND_SEEDS })
	end

	inst:AddComponent("knownlocations")

	inst:AddComponent("timer")
	inst:ListenForEvent("timerdone", OnTimerDone)

    local herdmember = inst:AddComponent("herdmember")
    herdmember:Enable(false)
	herdmember.herdprefab = "schoolherd_"..data.prefab

	local weighable = inst:AddComponent("weighable")
    -- No need to set a weighable type,
    -- this is just here for data and will be copied over to the inventory item
	--weighable.type = TROPHYSCALE_TYPES.FISH
	weighable:Initialize(inst.fish_def.weight_min, inst.fish_def.weight_max)
	weighable:SetWeight(Lerp(inst.fish_def.weight_min, inst.fish_def.weight_max, CalcNewSize()))

    if inst.fish_def.firesuppressant then
        local firedetector = inst:AddComponent("firedetector")
        firedetector:SetOnFindFireFn(on_find_fire)
        firedetector.range = TUNING.OCEANFISH.SPRINKLER_DETECT_RANGE
        firedetector.detectPeriod = TUNING.OCEANFISH.SPRINKLER_DETECT_PERIOD
        firedetector.fireOnly = true

        local wateryprotection = inst:AddComponent("wateryprotection")
        wateryprotection.extinguishheatpercent = TUNING.FIRESUPPRESSOR_EXTINGUISH_HEAT_PERCENT
        wateryprotection.temperaturereduction = TUNING.FIRESUPPRESSOR_TEMP_REDUCTION
        wateryprotection.witherprotectiontime = TUNING.FIRESUPPRESSOR_PROTECTION_TIME
        wateryprotection.addcoldness = TUNING.FIRESUPPRESSOR_ADD_COLDNESS
        wateryprotection:AddIgnoreTag("player")

        inst.LaunchProjectile = launch_water_projectile

        inst.components.firedetector:Activate(true)
    end

    inst:SetStateGraph("SGoceanfish")
    inst:SetBrain(brain)

	inst.OnEntityWake = OnEntityWake
    inst.OnEntitySleep = OnEntitySleep

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

local function OnInvCommonAnimOver(inst)
    if inst.AnimState:IsCurrentAnimation("flop_loop") then
        inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishland")
    end
end

local function inv_common(fish_def)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

	if fish_def.light ~= nil then
		inst.entity:AddLight()
		inst.Light:SetRadius(fish_def.light.r)
		inst.Light:SetFalloff(fish_def.light.f)
		inst.Light:SetIntensity(fish_def.light.i)
		inst.Light:SetColour(unpack(fish_def.light.c))
	end

	if fish_def.dynamic_shadow then
	    inst.entity:AddDynamicShadow()
	end

    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)

	inst.Transform:SetTwoFaced()

    inst.AnimState:SetBank(fish_def.bank)
    inst.AnimState:SetBuild(fish_def.build)
    inst.AnimState:PlayAnimation("flop_pst")

    inst.scrapbook_anim = "flop_pst"

	if fish_def.dynamic_shadow then
	    inst.DynamicShadow:SetSize(fish_def.dynamic_shadow[1], fish_def.dynamic_shadow[2])
	end

	inst:SetPrefabNameOverride(fish_def.prefab)

    --weighable_fish (from weighable component) added to pristine state for optimization
	inst:AddTag("weighable_fish")

	inst:AddTag("fish")
	inst:AddTag("oceanfish")
	inst:AddTag("catfood")
	inst:AddTag("smallcreature")
	inst:AddTag("smalloceancreature")

	if fish_def.tags ~= nil then
		for _, tag in ipairs(fish_def.tags) do
			inst:AddTag(tag)
		end
	end

	if fish_def.heater ~= nil then
		inst:AddTag("HASHEATER") --(from heater component) added to pristine state for optimization
	end

	inst.no_wet_prefix = true

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

	inst.scrapbook_adddeps = ArrayUnion(fish_def.loot, fish_def.heavy_loot)

	inst.fish_def = fish_def

	inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:SetOnPutInInventoryFn(onpickup)

    local perishable = inst:AddComponent("perishable")
    perishable:SetPerishTime(TUNING.PERISH_ONE_DAY)
    perishable:StartPerishing()
    perishable.onperishreplacement = fish_def.perish_product
	perishable.ignorewentness = true

	inst:AddComponent("murderable")

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot(fish_def.loot)

	if fish_def.heavy_loot ~= nil then
		inst.components.lootdropper:SetLootSetupFn(Inv_LootSetupFn)
	end

    local edible = inst:AddComponent("edible")
	if fish_def.edible_values ~= nil then
		edible.healthvalue = fish_def.edible_values.health or TUNING.HEALING_TINY
		edible.hungervalue = fish_def.edible_values.hunger or TUNING.CALORIES_SMALL
		edible.sanityvalue = fish_def.edible_values.sanity or 0
		edible.foodtype = fish_def.edible_values.foodtype or FOODTYPE.MEAT
	else
		edible.healthvalue = 0
		edible.hungervalue = 0
		edible.sanityvalue = 0
		edible.foodtype = FOODTYPE.MEAT
	end
	if edible.foodtype == FOODTYPE.MEAT then
		--edible.ismeat doesn't appear to actually be used anywhere, might not be necessary.
		edible.ismeat = true
	end

	local weighable = inst:AddComponent("weighable")
	weighable.type = TROPHYSCALE_TYPES.FISH
	weighable:Initialize(fish_def.weight_min, fish_def.weight_max)
	weighable:SetWeight(Lerp(fish_def.weight_min, fish_def.weight_max, CalcNewSize()))

	if fish_def.cooking_product ~= nil then
		local cookable = inst:AddComponent("cookable")
		cookable.product = fish_def.cooking_product
		cookable.oncooked = fish_def.oncooked_fn
	end

    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT

	inst.flop_task = inst:DoTaskInTime(math.random() * 2 + 1, Flop)

	if fish_def.heater ~= nil then
		local heater = inst:AddComponent("heater")
		heater.heat = fish_def.heater.heat
		heater.heatfn = fish_def.heater.heatfn
		heater.carriedheat = fish_def.heater.carriedheat
		heater.carriedheatfn = fish_def.heater.carriedheatfn
	    heater.carriedheatmultiplier = fish_def.heater.carriedheatmultiplier or 1

		if fish_def.heater.endothermic then
	        heater:SetThermics(false, true)
		end
	end

	if fish_def.propagator ~= nil then
		local propagator = inst:AddComponent("propagator")
		propagator.propagaterange = fish_def.propagator.propagaterange
		propagator.heatoutput = fish_def.propagator.heatoutput
		propagator:StartSpreading()

		inst:ListenForEvent("onputininventory", topocket)
		inst:ListenForEvent("ondropped", toground)
	end

	MakeHauntableLaunchAndPerish(inst)

	inst:ListenForEvent("on_landed", OnInventoryLanded)
	inst:ListenForEvent("animover", OnInvCommonAnimOver)
	inst:ListenForEvent("on_loot_dropped", ondroppedasloot)

    return inst
end

local fish_prefabs = {}

local function MakeFish(data)
	local assets = { Asset("ANIM", "anim/"..data.bank..".zip"), Asset("SCRIPT", "scripts/prefabs/oceanfishdef.lua"), }
	if data.bank ~= data.build then
		table.insert(assets, Asset("ANIM", "anim/"..data.build..".zip"))
	end

    if data.extra_anim_assets ~= nil then
        for _, v in ipairs(data.extra_anim_assets) do
            table.insert(assets, Asset("ANIM", "anim/"..v..".zip"))
        end
    end

	local prefabs = {
		data.prefab.."_inv",
		"schoolherd_"..data.prefab,
		"spoiled_fish",
		data.cooking_product,
	}
	ConcatArrays(prefabs, data.loot, data.extra_prefabs)

	table.insert(fish_prefabs, Prefab(data.prefab, function() return water_common(data) end, assets, prefabs))
	table.insert(fish_prefabs, Prefab(data.prefab.."_inv", function() return inv_common(data) end))
    -- NOTES(JBK): Use this to help export the bottom table to make this file findable.
    --print(string.format("%s %s", data.edible_values.foodtype or FOODTYPE.MEAT, data.prefab))
end

for _, fish_def in pairs(FISH_DATA.fish) do
	MakeFish(fish_def)
end

return unpack(fish_prefabs)

-- NOTES(JBK): These are here to make this file findable.
--[[
FOODTYPE.MEAT oceanfish_medium_1
FOODTYPE.MEAT oceanfish_medium_2
FOODTYPE.MEAT oceanfish_medium_3
FOODTYPE.MEAT oceanfish_medium_4
FOODTYPE.MEAT oceanfish_medium_6
FOODTYPE.MEAT oceanfish_medium_7
FOODTYPE.MEAT oceanfish_medium_8
FOODTYPE.MEAT oceanfish_medium_9
FOODTYPE.MEAT oceanfish_small_1
FOODTYPE.MEAT oceanfish_small_2
FOODTYPE.MEAT oceanfish_small_3
FOODTYPE.MEAT oceanfish_small_4
FOODTYPE.MEAT oceanfish_small_6
FOODTYPE.MEAT oceanfish_small_7
FOODTYPE.MEAT oceanfish_small_8
FOODTYPE.MEAT oceanfish_small_9
FOODTYPE.VEGGIE oceanfish_medium_5
FOODTYPE.VEGGIE oceanfish_small_5
]]
