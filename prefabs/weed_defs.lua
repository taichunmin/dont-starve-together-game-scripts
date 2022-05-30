

local WEED_DEFS = {}

local DAYS = TUNING.TOTAL_DAY_TIME

WEED_DEFS.weed_forgetmelots	= {}
WEED_DEFS.weed_tillweed		= {}
WEED_DEFS.weed_firenettle	= {}
WEED_DEFS.weed_ivy			= {}

WEED_DEFS.weed_forgetmelots	= {build = "weed_forgetmelots", bank = "weed_forgetmelots"}
WEED_DEFS.weed_tillweed		= {build = "weed_tillweed", bank = "weed_tillweed"}
WEED_DEFS.weed_firenettle	= {build = "weed_firenettle", bank = "weed_firenettle"}
WEED_DEFS.weed_ivy			= {build = "weed_ivy", bank = "weed_ivy"}

local function MakeGrowTimes(full_grow_min, full_grow_max, bolting)
	local grow_time = {}

	-- grow time
	if bolting then
		grow_time.small		= {full_grow_min * 0.3, full_grow_max * 0.3}
		grow_time.med		= {full_grow_min * 0.3, full_grow_max * 0.3}
		grow_time.full		= {full_grow_min * 0.4, full_grow_max * 0.4}
	else
		grow_time.small		= {full_grow_min * 0.6, full_grow_max * 0.6}
		grow_time.med		= {full_grow_min * 0.4, full_grow_max * 0.4}
	end

	return grow_time
end
											-- full grow time min / max (will be devided between the growth stages)
WEED_DEFS.weed_forgetmelots.grow_time		= MakeGrowTimes(2 * DAYS, 3 * DAYS, true)
WEED_DEFS.weed_tillweed.grow_time			= MakeGrowTimes(2 * DAYS, 3 * DAYS, false)
WEED_DEFS.weed_firenettle.grow_time			= MakeGrowTimes(2 * DAYS, 3 * DAYS, false)
WEED_DEFS.weed_ivy.grow_time				= MakeGrowTimes(2 * DAYS, 3 * DAYS, false)

WEED_DEFS.weed_forgetmelots.spread			= {stage = "bolting",	time_min = 3.0 * DAYS, time_var = 2.0 * DAYS, tilled_dist =  5, ground_dist = 1.5, ground_dist_var = 3, tooclose_dist = 1.5}
WEED_DEFS.weed_tillweed.spread				= {stage = "full",		time_min = 6.0 * DAYS, time_var = 2.0 * DAYS, tilled_dist = 10, ground_dist = 5,   ground_dist_var = 5, tooclose_dist = 5}
WEED_DEFS.weed_firenettle.spread			= {stage = "full",		time_min = 6.0 * DAYS, time_var = 2.0 * DAYS, tilled_dist = 10, ground_dist = 5,   ground_dist_var = 5, tooclose_dist = 5}
WEED_DEFS.weed_ivy.spread					= {stage = "full",		time_min = 6.0 * DAYS, time_var = 2.0 * DAYS, tilled_dist = 10, ground_dist = 10,  ground_dist_var = 5, tooclose_dist = 7}

WEED_DEFS.weed_forgetmelots.seed_weight		= TUNING.SEED_CHANCE_VERYCOMMON
WEED_DEFS.weed_tillweed.seed_weight			= TUNING.SEED_CHANCE_RARE
WEED_DEFS.weed_firenettle.seed_weight		= TUNING.SEED_CHANCE_RARE
WEED_DEFS.weed_ivy.seed_weight				= TUNING.SEED_CHANCE_RARE

WEED_DEFS.weed_forgetmelots.product			= "forgetmelots"
WEED_DEFS.weed_tillweed.product				= "tillweed"
WEED_DEFS.weed_firenettle.product			= "firenettles"
WEED_DEFS.weed_ivy.product					= nil


-- Nutrients
local nutrient = TUNING.FARM_PLANT_CONSUME_NUTRIENT_LOW
WEED_DEFS.weed_forgetmelots.nutrient_consumption	= {nutrient, nutrient, nutrient}
WEED_DEFS.weed_tillweed.nutrient_consumption		= {nutrient, nutrient, nutrient}
WEED_DEFS.weed_firenettle.nutrient_consumption		= {nutrient, nutrient, nutrient}
WEED_DEFS.weed_ivy.nutrient_consumption				= {nutrient, nutrient, nutrient}


-- moisture
local drink_low = TUNING.FARM_PLANT_DRINK_LOW
local drink_med = TUNING.FARM_PLANT_DRINK_MED
WEED_DEFS.weed_forgetmelots.moisture		= {drink_rate = drink_low}
WEED_DEFS.weed_tillweed.moisture			= {drink_rate = drink_med}
WEED_DEFS.weed_firenettle.moisture			= {drink_rate = drink_med}
WEED_DEFS.weed_ivy.moisture					= {drink_rate = drink_med}


-- Fireproof
--WEED_DEFS.weed_firenettle.fireproof = true

WEED_DEFS.weed_firenettle.extra_tags	= {"trapdamage"}

WEED_DEFS.weed_firenettle.prefab_deps	= {"firenettle_toxin"}
WEED_DEFS.weed_ivy.prefab_deps			= {"ivy_snare"}

-------------------------------------------------------------------------------
-- Custom Forgetmelots Behaviours
-------------------------------------------------------------------------------
local WEED_FORGETMELOTS_RESPAWNER_TAG = {"weed_forgetmelots_respawner", "CLASSIFIED"}
WEED_DEFS.weed_forgetmelots.ondigup = function(inst)
	local stage_data = inst.components.growable ~= nil and inst.components.growable:GetCurrentStageData()
	if stage_data and stage_data.name == "bolting" then
		local x, y, z = inst.Transform:GetWorldPosition()
		local num_respawners = #TheSim:FindEntities(x, y, z, 12, WEED_FORGETMELOTS_RESPAWNER_TAG)
		local chance = 1 - (num_respawners + 1) / 4
		if chance > 0 and math.random() < chance then
			SpawnPrefab("weed_forgetmelots_respawner").Transform:SetPosition(x, y, z)
		end
	end
end

-------------------------------------------------------------------------------
-- Custom Firenettle Behaviours
-------------------------------------------------------------------------------
local function weed_firenettle_bumped(inst, target)
	if (inst.components.burnable == nil or not inst.components.burnable.burning) and not inst:GetIsWet() and target ~= nil and not target:HasTag("plantkin") then
		inst.AnimState:PlayAnimation("crop_full_atk", false)
		inst.AnimState:PushAnimation("crop_full", true)

		if target.components.health ~= nil and not target.components.health:IsDead() then
			local apply_toxin_debuff = false
			if target.components.combat ~= nil then
				apply_toxin_debuff = target.components.combat:GetAttacked(inst, TUNING.WEED_FIRENETTLE_DAMAGE)
			end

			if apply_toxin_debuff then
				target:AddDebuff("firenettle_toxin", "firenettle_toxin")
			end
		end

		if inst.components.growable ~= nil then
			inst.components.growable:SetStage(1)
			inst.components.growable:StartGrowing()
		end
	end
end

WEED_DEFS.weed_firenettle.OnMakeFullFn = function(inst, isfull)
	if isfull and inst.components.playerprox == nil then
		inst:AddComponent("playerprox")
		inst.components.playerprox:SetDist(0.5, 2.5)
		inst.components.playerprox:SetOnPlayerNear(weed_firenettle_bumped)
		inst.components.playerprox:Schedule(5 * FRAMES)

	elseif not isfull and inst.components.playerprox ~= nil then
		inst:RemoveComponent("playerprox")
	end
end

-------------------------------------------------------------------------------
-- Custom Tillweed Behaviours
-------------------------------------------------------------------------------
local DEBRIS_OBJECTS_ONEOF_TAGS = {"farm_debris"}
WEED_DEFS.weed_tillweed.OnTimerDoneFn = function(inst, data)
	if data.name == "make_debris" then
		local x, y, z = inst.Transform:GetWorldPosition()
		local tilling_dist = inst.weed_def.spread.ground_dist
		local debris = TheSim:FindEntities(x, y, z, tilling_dist, DEBRIS_OBJECTS_ONEOF_TAGS)
		if #debris < TUNING.WEED_TILLWEED_MAX_DEBRIS then
			local pt = nil
			for i = 1, 10 do
				local _x = GetRandomMinMax(-tilling_dist, tilling_dist)
				local _z = GetRandomMinMax(-tilling_dist, tilling_dist)
				if TheWorld.Map:IsFarmableSoilAtPoint(x + _x, y, z + _z) and #TheSim:FindEntities(x + _x, y, z + _z, 0.5) == 0 then
					SpawnPrefab("farm_soil_debris").Transform:SetPosition(x + _x, y, z + _z)
					break
				end
			end
		end

		inst.components.timer:StartTimer("make_debris", TUNING.WEED_TILLWEED_DEBRIS_TIME_MIN + math.random() * TUNING.WEED_TILLWEED_DEBRIS_TIME_VAR)
	end
end

WEED_DEFS.weed_tillweed.OnMakeFullFn = function(inst, isfull)
	if isfull and not inst.components.timer:TimerExists("make_debris") then
		inst.components.timer:StartTimer("make_debris", TUNING.WEED_TILLWEED_DEBRIS_TIME_MIN + math.random() * TUNING.WEED_TILLWEED_DEBRIS_TIME_VAR )
	elseif not isfull then
		inst.components.timer:StopTimer("make_debris")
	end
end

-------------------------------------------------------------------------------
-- Custom Ivy Behaviours
-------------------------------------------------------------------------------
local function KillOffSnares(inst)
	local snares = inst.snares
	if snares ~= nil then
		inst.snares = nil

		for _, v in ipairs(snares) do
			if v:IsValid() then
				v.owner = nil
				v:KillOff()
			end
		end
	end

	inst.AnimState:PlayAnimation("crop_full", true)
end

local function onsnaredeath(snare)
	local inst = (snare.owner ~= nil and snare.owner:IsValid()) and snare.owner or nil
	if inst ~= nil then
		KillOffSnares(inst)
	end
end

local function dosnaredamage(inst, target)
	if target:IsValid() and target.components.health ~= nil and not target.components.health:IsDead() and target.components.combat ~= nil then
		target.components.combat:GetAttacked(inst, TUNING.WEED_IVY_SNARE_DAMAGE)
		target:PushEvent("snared", { attacker = inst, announce = "ANNOUNCE_SNARED_IVY" })
	end
end

local function SpawnSnare(inst, x, z, r, num, target)
    local count = 0
    local dtheta = PI * 2 / num
    local thetaoffset = math.random() * PI * 2
    local delaytoggle = 0
    local map = TheWorld.Map
    for theta = math.random() * dtheta, PI * 2, dtheta do
        local x1 = x + r * math.cos(theta)
        local z1 = z + r * math.sin(theta)
        if map:IsPassableAtPoint(x1, 0, z1, false, true) and not map:IsPointNearHole(Vector3(x1, 0, z1)) then
            local snare = SpawnPrefab("ivy_snare")
            snare.Transform:SetPosition(x1, 0, z1)

            local delay = delaytoggle == 0 and 0 or .2 + delaytoggle * math.random() * .2
            delaytoggle = delaytoggle == 1 and -1 or 1

			snare.owner = inst
			snare.target = target
			snare.target_max_dist = r + 1.0
            snare:RestartSnare(delay)

			table.insert(inst.snares, snare)
			inst:ListenForEvent("death", onsnaredeath, snare)
            count = count + 1
        end
    end

	return count > 0
end

local function ivy_defend_plant(inst, data)
    local target = data.target
    if target ~= nil and target:IsValid() and not target:HasTag("plantkin") then
		if inst.snares ~= nil and #inst.snares > 0 then
			for _, snare in ipairs(inst.snares) do
				if snare:IsValid() and snare.components.health ~= nil and not snare.components.health:IsDead() then
					snare.components.health:Kill()
				end
			end
		end
		inst.snares = {}

        local x, y, z = target.Transform:GetWorldPosition()
        local islarge = target:HasTag("largecreature")
        local r = target:GetPhysicsRadius(0) + (islarge and 1.4 or .4)
        local num = islarge and 12 or 6
		if SpawnSnare(inst, x, z, r, num, target) then
			inst:DoTaskInTime(0.25, dosnaredamage, target)

			inst.AnimState:PlayAnimation("full_atk", true)
		end
	end
end

WEED_DEFS.weed_ivy.OnMakeFullFn = function(inst, isfull)
	local has_tag = inst:HasTag("farm_plant_defender")
	if isfull and not has_tag then
		inst:AddTag("farm_plant_defender")
	elseif not isfull and has_tag then
		inst:Remove("farm_plant_defender")
	end
end

WEED_DEFS.weed_ivy.masterpostinit = function(inst)
	inst:ListenForEvent("defend_farm_plant", ivy_defend_plant)
	inst:ListenForEvent("onremove", KillOffSnares)
end

for weed, data in pairs(WEED_DEFS) do
	data.prefab = weed
	data.sameweedtags = {weed}

	if data.stage_netvar == nil then
		data.stage_netvar = net_tinybyte
	end

	if data.plantregistryinfo == nil then
		data.plantregistryinfo = {
			{
				text = "small",
				anim = "crop_small",
				grow_anim = "seedless_to_small",
				growing = true,
			},
			{
				text = "medium",
				anim = "crop_med",
				grow_anim = "grow_med",
				growing = true,
			},
			{
				text = "grown",
				anim = "crop_full",
				grow_anim = "grow_full",
				revealplantname = true,
				fullgrown = true,
			},
		}

		if data.grow_time.full then
			table.insert(data.plantregistryinfo, {
				text = "bolting",
				anim = "crop_bloomed",
				grow_anim = "grow_bloomed",
				revealplantname = true,
				fullgrown = true,
				stagepriority = -1,
			})
		end

		if data.product then
			table.insert(data.plantregistryinfo, {
				text = "picked",
				anim = "crop_picked",
				grow_anim = "grow_picked",
				stagepriority = -100
			})
		end
	end
	if data.plantregistrywidget == nil then
		--the path to the widget
		data.plantregistrywidget = "widgets/redux/weedplantpage"
	end
end

setmetatable(WEED_DEFS, {
	__newindex = function(t, k, v)
		v.modded = true
		rawset(t, k, v)
	end,
})

local weighted_seed_table = {}
for k, v in pairs(WEED_DEFS) do
	weighted_seed_table[k] = v.seed_weight
end

return {WEED_DEFS = WEED_DEFS, weighted_seed_table = weighted_seed_table}