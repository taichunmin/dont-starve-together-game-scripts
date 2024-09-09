local USE_SETTINGS_FILE = PLATFORM ~= "PS4" and PLATFORM ~= "NACL"

local PLANT_DEFS = require("prefabs/farm_plant_defs").PLANT_DEFS
local WEED_DEFS = require("prefabs/weed_defs").WEED_DEFS
local FERTILIZER_DEFS = require("prefabs/fertilizer_nutrient_defs").FERTILIZER_DEFS

local PlantRegistryData = Class(function(self)
	self.plants = {}
	self.fertilizers = {}
	self.pictures = {}

	self.filters = {}
	self.last_selected_card = {}
	--self.save_enabled = nil
end)

function PlantRegistryData:GetKnownPlants()
	return self.plants
end

function PlantRegistryData:GetKnownPlantStages(plant)
	if self.plants[plant] then
		return self.plants[plant]
	end
	return {}
end

function PlantRegistryData:IsAnyPlantStageKnown(plant)
	if self.plants[plant] then
		return not IsTableEmpty(self.plants[plant])
	end
	return false
end

function PlantRegistryData:KnowsPlantStage(plant, stage)
	if self.plants[plant] then
		return self.plants[plant][stage] == true
	end
	return false
end

function PlantRegistryData:KnowsSeed(plant, plantregistryinfo)
	for stage in pairs(self.plants[plant] or {}) do
		if plantregistryinfo[stage] and plantregistryinfo[stage].learnseed then
			return true
		end
	end
	return false
end

function PlantRegistryData:KnowsPlantName(plant, plantregistryinfo, research_stage) -- research_stage is optional
	if research_stage ~= nil and plantregistryinfo[research_stage] and plantregistryinfo[research_stage].revealplantname then
		return true
	end

	for stage in pairs(self.plants[plant] or {}) do
		if plantregistryinfo[stage] and plantregistryinfo[stage].revealplantname then
			return true
		end
	end
	return false
end

function PlantRegistryData:KnowsFertilizer(fertilizer)
	return self.fertilizers[fertilizer] == true
end

function PlantRegistryData:HasOversizedPicture(plant)
	return self.pictures[plant] ~= nil
end

function PlantRegistryData:GetOversizedPictureData(plant)
	return self.pictures[plant]
end

function PlantRegistryData:GetPlantPercent(plant, plantregistryinfo)
	local totalstages = 0
	local knownstages = 0
	local hasfullgrown = false
	local knowsfullgrown = false
	for stage, data in pairs(plantregistryinfo) do
		if data.growing then
			totalstages = totalstages + 1
			if self:KnowsPlantStage(plant, stage) then
				knownstages = knownstages + 1
			end
		elseif data.fullgrown then
			if not hasfullgrown then
				hasfullgrown = true
				totalstages = totalstages + 1
			end
			if not knowsfullgrown and self:KnowsPlantStage(plant, stage) then
				knowsfullgrown = true
				knownstages = knownstages + 1
			end
		end
	end
	return knownstages / totalstages
end

function PlantRegistryData:Save(force_save)
	if force_save or (self.save_enabled and self.dirty) then
		local str = DataDumper({plants = self.plants, fertilizers = self.fertilizers, pictures = self.pictures, filters = self.filters, last_selected_card = self.last_selected_card}, nil, true)
		TheSim:SetPersistentString("plantregistry", str, false)
		self.dirty = false
	end
end

function PlantRegistryData:Load()
	TheSim:GetPersistentString("plantregistry", function(load_success, data)
		if load_success and data ~= nil then
            local success, plant_registry = RunInSandbox(data)
		    if success and plant_registry then
				self.plants = plant_registry.plants or {}
				self.fertilizers = plant_registry.fertilizers or {}
				self.pictures = plant_registry.pictures or {}
				self.filters = plant_registry.filters or {}
				self.last_selected_card = plant_registry.last_selected_card or {}
			else
				print("Failed to load the plantregistry!", plant_registry)
			end
		end
	end)
end

local function DecodePlantRegistryStages(value)
	local bitstages = tonumber(value, 16)
	local stages = {}
	for i = 1, 8 do
		if checkbit(bitstages, 2^(i-1)) then
			stages[i] = true
		end
	end
	return stages
end

local function EncodePlantRegistryStages(stages)
	local bitstages = 0
	for i in pairs(stages) do
		bitstages = setbit(bitstages, 2^(i-1))
	end
	return string.format("%x", bitstages)
end

function PlantRegistryData:ApplyOnlineProfileData()
	if not self.synced and
		(TheInventory:HasSupportForOfflineSkins() or not (TheFrontEnd ~= nil and TheFrontEnd:GetIsOfflineMode() or not TheNet:IsOnlineMode())) and
		TheInventory:HasDownloadedInventory() then
		self.plants = self.plants or {}
		self.fertilizers = self.fertilizers or {}
		self.pictures = self.pictures or {}
		for k, v in pairs(TheInventory:GetLocalPlantRegistry()) do
			if FERTILIZER_DEFS[k] then
				self.fertilizers[k] = v == "true" or nil
			elseif PLANT_DEFS[k] or WEED_DEFS[k] then
				self.plants[k] = DecodePlantRegistryStages(v)
			elseif string.sub(k, 1, 10) == "oversized_" then
				local success, savedata
				if v and type(v) == "string" then
					success, savedata = RunInSandbox(TheSim:DecodeAndUnzipString(v))
				end
				self.pictures[string.sub(k, 11)] = success and savedata or nil
			end
		end
		self.synced = true
	end
	return self.synced
end

function PlantRegistryData:ClearFilters()
	self.filters = {}
	self.dirty = true
end

function PlantRegistryData:SetFilter(category, value)
	if self.filters[category] ~= value then
		self.filters[category] = value
		self.dirty = true
	end
end

function PlantRegistryData:GetFilter(category)
	return self.filters[category]
end

function PlantRegistryData:GetLastSelectedCard(plant)
	return self.last_selected_card[plant]
end

function PlantRegistryData:SetLastSelectedCard(plant, card)
	self.last_selected_card[plant] = card
	self.dirty = true
end

local function UnlockPlant(self, plant)
	if self.plants[plant] == nil then
		self.plants[plant] = {}
	end
	return self.plants[plant]
end

function PlantRegistryData:LearnPlantStage(plant, stage)
	if plant == nil or stage == nil then
		print("Invalid plant or stage", plant, stage)
		return
	end

	local def = PLANT_DEFS[plant] or WEED_DEFS[plant]

	local previouspercent = def and def.plantregistryinfo and self:GetPlantPercent(plant, def.plantregistryinfo) or 0

	local stages = UnlockPlant(self, plant)
	local updated = stages[stage] == nil
	stages[stage] = true

	if updated and self.save_enabled then
		if def and not def.modded and not TheNet:IsDedicated() then
			TheInventory:SetPlantRegistryValue(plant, EncodePlantRegistryStages(stages))
		end
		local currentpercent = def and def.plantregistryinfo and self:GetPlantPercent(plant, def.plantregistryinfo) or 0

		if previouspercent < 1 and currentpercent >= 1 and def.plantregistrysummarywidget then
			self:SetLastSelectedCard(plant, "summary")
		else
			local higheststage = 0
			for k in pairs(stages) do
				higheststage = math.max(higheststage, k)
			end
			if higheststage == stage then
				self:SetLastSelectedCard(plant, stage)
			end
		end
		self:Save(true)
	end

	return updated
end

function PlantRegistryData:LearnFertilizer(fertilizer)
	if fertilizer == nil then
		print("Invalid fertilizer", fertilizer)
		return
	end

	local updated = self.fertilizers[fertilizer] == nil
	self.fertilizers[fertilizer] = true

	if updated and self.save_enabled then
		local def = FERTILIZER_DEFS[fertilizer]
		if def and not def.modded and not TheNet:IsDedicated() then
			TheInventory:SetPlantRegistryValue(fertilizer, "true")
		end
		self:Save(true)
	end

	return updated
end

local function UnlockPicture(self, plant)
	if self.pictures[plant] == nil then
		self.pictures[plant] = {}
	end
	return self.pictures[plant]
end

function PlantRegistryData:TakeOversizedPicture(plant, weight, player, beardskin, beardlength)
	if plant == nil or weight == nil or player == nil or player.userid == nil then
		print("Invalid plant or weight or player", plant, weight, player)
		return
	end

	if not table.contains(DST_CHARACTERLIST, player.prefab) then
		--modded characters pose too many complications, sorry.
		return false
	end

	if (TheNet:IsDedicated() or player ~= ThePlayer) then
		--because we can't know if the weight is greater than the clients.
		--always send it if we are the server.
		return true
	end

	local updated = self.pictures[plant] == nil
	local picture = UnlockPicture(self, plant)

	updated = updated or (tonumber(weight) > tonumber(picture.weight))

	if updated and self.save_enabled then
		local def = PLANT_DEFS[plant]

		picture.weight = weight
		picture.player = player.prefab
		local clienttable = TheNet:GetClientTableForUser(player.userid)
		picture.clothing = {
			body = clienttable.body_skin,
			hand = clienttable.hand_skin,
			legs = clienttable.legs_skin,
			feet = clienttable.feet_skin,
		}
		picture.base = clienttable.base_skin
		picture.mode = GetSkinModeFromBuild(player)
		if beardlength then
			picture.beardskin = beardskin
			picture.beardlength = beardlength
		else
			--clear out beard data if we overwrite due to larger weight
			picture.beardskin = nil
			picture.beardlength = nil
		end
		if def and not def.modded and not TheNet:IsDedicated() then
			TheInventory:SetPlantRegistryValue("oversized_"..plant, TheSim:ZipAndEncodeString(DataDumper(picture, nil, true)))
		end
		self:Save(true)
	end

	return updated
end

return PlantRegistryData