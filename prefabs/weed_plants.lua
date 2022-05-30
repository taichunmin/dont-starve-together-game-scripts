

local WEED_DEFS = require("prefabs/weed_defs").WEED_DEFS

local function ontendto(inst, doer)
	inst:DoTaskInTime(0.5 + math.random() * 0.5, function()
		local fx = SpawnPrefab("farm_plant_happy")
		fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	end)
	return true
end

local function call_for_reinforcements(inst, target)
	inst:RemoveTag("farm_plant_defender")

	local x, y, z = inst.Transform:GetWorldPosition()
	local defenders = TheSim:FindEntities(x, y, z, TUNING.FARM_PLANT_DEFENDER_SEARCH_DIST, {"farm_plant_defender"})
	for _, defender in ipairs(defenders) do
		if defender.components.burnable == nil or not defender.components.burnable.burning then
			defender:PushEvent("defend_farm_plant", {source = inst, target = target})
			break
		end
	end
end

local function UpdateResearchStage(inst, stage)
	if stage == 1 and inst.mature then	-- stage 3 + mature = picked state
		stage = #inst.weed_def.plantregistryinfo
	end

	inst._research_stage:set(stage - 1) -- to make it a 0 a based range
end

local function GetResearchStage(inst)
	return inst._research_stage:value() + 1	-- +1 to make it 1 a based rage
end

local function GetPlantRegistryKey(inst)
	return inst.plantregistrykey
end

local function ConsumeNutrients(inst)
	if TheWorld.components.farming_manager ~= nil then
		local x, y, z = inst.Transform:GetWorldPosition()
		TheWorld.components.farming_manager:CycleNutrientsAtPoint(x, y, z, inst.weed_def.nutrient_consumption, nil)
	end
end

local function TryGrowResume(inst)
	if inst.components.growable ~= nil and (inst.components.burnable == nil or not inst.components.burnable.burning) then
		inst.components.growable:Resume()
	end
end

local function dig_up(inst, worker)
    if inst.components.lootdropper ~= nil then
		inst.components.lootdropper:DropLoot()
    end

	call_for_reinforcements(inst, worker)

	local x, y, z = inst.Transform:GetWorldPosition()
	if inst.components.growable ~= nil then
		local stage_data = inst.components.growable:GetCurrentStageData()
		if stage_data ~= nil and stage_data.dig_fx ~= nil then
			SpawnPrefab(stage_data.dig_fx).Transform:SetPosition(x, y, z)
		end
	end

	if TheWorld.Map:GetTileAtPoint(x, y, z) == GROUND.FARMING_SOIL then
		local soil = SpawnPrefab("farm_soil")
		soil.Transform:SetPosition(x, y, z)
		soil:PushEvent("breaksoil")
	end

	if inst.weed_def.ondigup ~= nil then
		inst.weed_def.ondigup(inst, worker)
	end

    inst:Remove()
end

local function onburnt(inst)
    SpawnPrefab("ash").Transform:SetPosition(inst.Transform:GetWorldPosition())
	if inst.components.lootdropper ~= nil then
		inst.components.lootdropper:DropLoot()
	end

	inst:Remove()
end

local function onignite(inst, source, doer)
	if inst.components.growable ~= nil then
		inst.components.growable:Pause()
	end
end

local function onextinguish(inst)
	TryGrowResume(inst)
end

local function GetDrinkRate(inst)
	return inst.weed_def.moisture.drink_rate
end

local function SetupLoot(lootdropper)
	local inst = lootdropper.inst
	if inst.components.pickable ~= nil then
		lootdropper:SetLoot({inst.weed_def.product})
	end
end

local function PlayStageAnim(inst, anim, custom_pre)
	if POPULATING or inst:IsAsleep() then
		inst.AnimState:PlayAnimation("crop_"..anim, true)
		inst.AnimState:SetTime(math.random() * inst.AnimState:GetCurrentAnimationLength())
	elseif custom_pre ~= nil then
		inst.AnimState:PlayAnimation(custom_pre, false)
		inst.AnimState:PushAnimation("crop_"..anim, true)
	else
		inst.AnimState:PlayAnimation("grow_"..anim, false)
		inst.AnimState:PushAnimation("crop_"..anim, true)
	end
end

local function OnPickablePicked(inst, doer)
	call_for_reinforcements(inst, doer)

	if inst.components.growable ~= nil then
		inst.components.growable:SetStage(1)
		inst.components.growable:StartGrowing()
	end
end

local function MakePickable(inst, enable)
    if not enable then
        inst:RemoveComponent("pickable")
    else
        if inst.components.pickable == nil then
            inst:AddComponent("pickable")
        end
        inst.components.pickable.onpickedfn = OnPickablePicked
	    inst.components.pickable:SetUp(nil)
		inst.components.pickable.use_lootdropper_for_product = true
	    inst.components.pickable.picksound = "dontstarve/wilson/pickup_plants"
    end
end

local function GetGrowTime(inst, stage_num, stage_data)
	local grow_time = inst.weed_def.grow_time[stage_data.name]
	if grow_time ~= nil then
		return GetRandomMinMax(grow_time[1], grow_time[2])
	end
end

local function MakePlantedSeed(inst, seed_state)
	if seed_state then
		inst:AddTag("planted_seed")
		inst:RemoveTag("farm_plant_killjoy")
	else
		inst:RemoveTag("planted_seed")
		inst:AddTag("farm_plant_killjoy")
	end
end

local function UpdateSpreading(inst, stage_data)
	if inst.weed_def.spread ~= nil then
		if inst.weed_def.spread.stage ~= stage_data.name then
			inst.components.timer:StopTimer("spread")
		elseif not inst.components.timer:TimerExists("spread") then
			inst.components.timer:StartTimer("spread", inst.weed_def.spread.time_min + math.random() * inst.weed_def.spread.time_var)
		end
	end
end

local function MakeFull(inst, is_full)
	if inst.weed_def.OnMakeFullFn ~= nil then
		inst.weed_def.OnMakeFullFn(inst, is_full)
	end
end

local GROWTH_STAGES =
{
    {
        name = "small",
        time = GetGrowTime,
		pregrowfn = function(inst)
			if not inst.mature then
				ConsumeNutrients(inst)
			end
		end,
        fn = function(inst, stage, stage_data)
            MakePlantedSeed(inst, false)
            MakePickable(inst, false)
			MakeFull(inst, false)
			UpdateSpreading(inst, stage_data)
			inst.components.farmplanttendable:SetTendable(true)
			inst.components.growable.magicgrowable = true

			inst:UpdateResearchStage(stage)

			if inst.mature then
				PlayStageAnim(inst, "picked")
			else
				PlayStageAnim(inst, "small")
			end
        end,
		dig_fx = "dirt_puff",
		inspect_str = "GROWING",
    },
    {
        name = "med",
        time = GetGrowTime,
		pregrowfn = function(inst)
			ConsumeNutrients(inst)
		end,
        fn = function(inst, stage, stage_data)
            MakePlantedSeed(inst, false)
            MakePickable(inst, false)
			MakeFull(inst, false)
			UpdateSpreading(inst, stage_data)
			inst.components.farmplanttendable:SetTendable(true)
			inst.components.growable.magicgrowable = true

			inst:UpdateResearchStage(stage)
			PlayStageAnim(inst, "med", inst.mature and "picked_to_med" or nil)
        end,
		dig_fx = "dirt_puff",
		inspect_str = "GROWING",
    },
    {
        name = "full",
        time = GetGrowTime,
		pregrowfn = function(inst)
			ConsumeNutrients(inst)
		end,
		fn = function(inst, stage, stage_data)
            MakePickable(inst, inst.weed_def.product ~= nil)
			MakeFull(inst, true)
			UpdateSpreading(inst, stage_data)
			inst.components.farmplanttendable:SetTendable(false)

			inst:UpdateResearchStage(stage)

			if not inst.weed_def.grow_time.full then
				inst.components.growable:StopGrowing()
				inst.components.growable.magicgrowable = false
			else
				inst.components.growable.magicgrowable = true
			end

			PlayStageAnim(inst, "full")

            inst.mature = true
        end,
		dig_fx = "dirt_puff",
		inspect_str = "FULL_WEED",
    },
    {
        name = "bolting",
		pregrowfn = function(inst)
			ConsumeNutrients(inst)
		end,
		fn = function(inst, stage, stage_data)
            MakePickable(inst, false)
			MakeFull(inst, true)
			UpdateSpreading(inst, stage_data)
			inst.components.farmplanttendable:SetTendable(false)

			inst:UpdateResearchStage(stage)

			inst.components.growable:StopGrowing()
			inst.components.growable.magicgrowable = false
			PlayStageAnim(inst, "bloomed")

            inst.mature = true
        end,
		dig_fx = "dirt_puff",
		inspect_str = "FULL_WEED",
    },
}

local FIND_SOIL_TAG = {"soil"}

local function OnTrySpread(inst)
	local min_delay_mult = 1
	local spread = inst.weed_def.spread

	local x, y, z = inst.Transform:GetWorldPosition()
	local soils = TheSim:FindEntities(x, y, z, spread.tilled_dist, FIND_SOIL_TAG)

	local rnd = math.random
	local spawn_x, spawn_y, spawn_z
	local in_soil = false
	if #soils > 0 then
		local offset = math.random(#soils)
		local MAX_TRIES = 3
		for i = 1, math.min(#soils, MAX_TRIES) do
			local _i = ((i + offset) % #soils) + 1
			local _x, _, _z = soils[_i].Transform:GetWorldPosition()

			if VecUtil_LengthSq(x - _x, z - _z) > spread.tooclose_dist*spread.tooclose_dist and #TheSim:FindEntities(_x, 0, _z, spread.tooclose_dist, inst.weed_def.sameweedtags) == 0 then
				spawn_x, spawn_y, spawn_z = _x, 0, _z
				soils[_i]:Remove()
				in_soil = true
				break
			end
		end
	end
	if spawn_x == nil then
		local t = rnd() * 360
		local MAX_TRIES = 3
		for i = 1, MAX_TRIES do
			local r = spread.ground_dist + math.sqrt(rnd()) * spread.ground_dist_var
			t = t + 360/MAX_TRIES
			local _x, _z = x + r * math.cos(t), z + r * math.sin(t)

			if TheWorld.Map:CanTillSoilAtPoint(_x, 0, _z) and #TheSim:FindEntities(_x, 0, _z, spread.tooclose_dist, inst.weed_def.sameweedtags) == 0 then
				spawn_x, spawn_y, spawn_z = _x, 0, _z
				TheWorld.Map:CollapseSoilAtPoint(spawn_x, spawn_y, spawn_z)
				break
			end
		end
	end

	if spawn_x ~= nil then
		local new_weed = SpawnPrefab(inst.prefab)
		new_weed.Transform:SetPosition(spawn_x, spawn_y, spawn_z)
		new_weed:PushEvent("on_planted", {in_soil = in_soil, doer = inst})

		min_delay_mult = 2
	end

	return (spread.time_min * min_delay_mult) + math.random() * spread.time_var

end

local function timerdone(inst, data)
	if data ~= nil then
		if data.name == "spread" then
			local retry_time = OnTrySpread(inst)
			inst.components.timer:StartTimer("spread", retry_time or (inst.weed_def.spread.time_min + math.random() * inst.weed_def.spread.time_var))
		end

		if inst.weed_def.OnTimerDoneFn ~= nil then
			inst.weed_def.OnTimerDoneFn(inst, data)
		end
	end
end

local function on_planted(inst, data)
	if data ~= nil and not data.in_soil then
		PlayStageAnim(inst, "small", "seedless_to_small")
	end
end

local function domagicgrowthfn(inst)
	if inst:IsValid() and inst.components.growable:IsGrowing() then
		if inst.components.farmsoildrinker ~= nil then
			local remaining_time = inst.components.growable.targettime - GetTime()
			local drink = remaining_time * inst.components.farmsoildrinker:GetMoistureRate()

			local x, y, z = inst.Transform:GetWorldPosition()
			TheWorld.components.farming_manager:AddSoilMoistureAtPoint(x, y, z, drink)
		end

		inst.components.growable:DoGrowth()
		if inst.components.pickable == nil then
			inst:DoTaskInTime(0.5 + math.random() + 0.25, domagicgrowthfn)
		end
		return true
	end

	return false
end

local function GetStatus(inst)
	if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
		return "BURNING"
	end

	local stage_data = inst.components.growable:GetCurrentStageData()
	return stage_data ~= nil and stage_data.inspect_str or nil
end

local function GetDisplayName(inst)
	local plantregistryinfo = inst.weed_def.plantregistryinfo
	if plantregistryinfo == nil then
		return nil
	end
	local registry_key = inst:GetPlantRegistryKey()
	local research_stage = inst:GetResearchStage()

	return not ThePlantRegistry:KnowsPlantName(registry_key, plantregistryinfo, research_stage) and STRINGS.NAMES.FARM_PLANT_UNKNOWN
		or nil
end

local function plantresearchfn(inst)
	return inst:GetPlantRegistryKey(), inst:GetResearchStage()
end

local function OnSave(inst, data)
	data.from_seed = inst.from_seed
	data.mature = inst.mature
end

local function OnPreLoad(inst, data)
	inst.from_seed = data.from_seed
	inst.mature = data.mature
end

local function MakeWeed(weed_def)
    local assets =
    {
        Asset("ANIM", "anim/"..weed_def.bank..".zip"),
        Asset("ANIM", "anim/"..weed_def.build..".zip"),
        Asset("ANIM", "anim/farm_soil.zip"),
		Asset("SCRIPT", "scripts/prefabs/weed_defs.lua"),
    }

    local prefabs =
    {
		"farm_plant_happy",
    }
	if weed_def.product then
		table.insert(prefabs, weed_def.product)
	end

	for k, v in pairs(GROWTH_STAGES) do
		if v.dig_fx ~= nil then
			table.insert(prefabs, v.dig_fx)
		end
	end

	if weed_def.prefab_deps ~= nil then
		for _, v in ipairs(weed_def.prefab_deps) do
			table.insert(prefabs, v)
		end
	end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank(weed_def.bank)
        inst.AnimState:SetBuild(weed_def.build)
        inst.AnimState:PlayAnimation("crop_small")
		inst.AnimState:OverrideSymbol("soil01", "farm_soil", "soil01")

		inst:SetPhysicsRadiusOverride(TUNING.FARM_PLANT_PHYSICS_RADIUS)

        inst:AddTag("plantedsoil")
        inst:AddTag("farm_plant")
		inst:AddTag("farm_plant_killjoy")
		inst:AddTag("weed")
		inst:AddTag("plant")
		inst:AddTag("plantresearchable")
		inst:AddTag("weedplantstress")
		inst:AddTag("tendable_farmplant") -- for farmplanttendable component
		if weed_def.extra_tags ~= nil then
			for k, v in ipairs(weed_def.extra_tags) do
				inst:AddTag(v)
			end
		end
		for k, v in ipairs(weed_def.sameweedtags) do
			inst:AddTag(v)
		end

		inst._research_stage = (weed_def.stage_netvar or net_tinybyte)(inst.GUID, "farm_plant.research_stage") -- use inst:GetResearchStage() to access this value
		inst.plantregistrykey = weed_def.prefab
		inst.GetPlantRegistryKey = GetPlantRegistryKey
		inst.GetResearchStage = GetResearchStage

		inst.displaynamefn = GetDisplayName

        inst.weed_def = weed_def

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

		inst.UpdateResearchStage = UpdateResearchStage

		inst:AddComponent("inspectable")
		inst.components.inspectable.getstatus = GetStatus
		inst.components.inspectable.nameoverride = "FARM_PLANT"

		inst:AddComponent("plantresearchable")
		inst.components.plantresearchable:SetResearchFn(plantresearchfn)

		inst:AddComponent("timer")
		inst:ListenForEvent("timerdone", timerdone)

		inst:AddComponent("farmsoildrinker")
		inst.components.farmsoildrinker.getdrinkratefn = GetDrinkRate

		inst:AddComponent("farmplanttendable")
		inst.components.farmplanttendable.ontendtofn = ontendto

		inst:AddComponent("growable")
		inst.components.growable.growoffscreen = true
		inst.components.growable.stages = GROWTH_STAGES
		inst.components.growable:SetStage(1)
		inst.components.growable:StartGrowing()
		inst.components.growable.domagicgrowthfn = domagicgrowthfn
		inst.components.growable.magicgrowable = true

		inst:AddComponent("hauntable")
		inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

	    inst:AddComponent("lootdropper")
		inst.components.lootdropper.lootsetupfn = SetupLoot

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.DIG)
        inst.components.workable:SetWorkLeft(1)
        inst.components.workable:SetOnFinishCallback(dig_up)

		if not weed_def.fireproof then
			MakeSmallBurnable(inst)
			MakeSmallPropagator(inst)
			inst.components.burnable:SetOnBurntFn(onburnt)
			inst.components.burnable:SetOnIgniteFn(onignite)
			inst.components.burnable:SetOnExtinguishFn(onextinguish)
		end

		inst.OnSave = OnSave
		inst.OnPreLoad = OnPreLoad

		if weed_def.masterpostinit ~= nil then
			weed_def.masterpostinit(inst)
		end

		inst:ListenForEvent("on_planted", on_planted)

        return inst
    end

    return Prefab(weed_def.prefab, fn, assets, prefabs)
end


local plant_prefabs = {}
for k, v in pairs(WEED_DEFS) do
	if not v.data_only then --allow mods to skip our prefab constructor.
		table.insert(plant_prefabs, MakeWeed(v))
	end
end

return unpack(plant_prefabs)
