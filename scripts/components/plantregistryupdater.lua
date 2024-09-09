local function onplayeractivated(inst)
	local self = inst.components.plantregistryupdater
	if not TheNet:IsDedicated() and inst == ThePlayer then
		self.plantregistry = ThePlantRegistry
		self.plantregistry.save_enabled = true
	end
end

local PlantRegistryUpdater = Class(function(self, inst)
    self.inst = inst

	self.plantregistry = require("plantregistrydata")()
	inst:ListenForEvent("playeractivated", onplayeractivated)
end)

function PlantRegistryUpdater:LearnPlantStage(plant, stage)
    if plant and stage then
		local updated = self.plantregistry:LearnPlantStage(plant, stage)

		if updated and TheFocalPoint.entity:GetParent() == self.inst then
			TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/get_gold")
		end
		--print("PlantRegistryUpdater:LearnPlantStage", plant, stage)

		-- Servers will only tell the clients if this is a new plant stage in this world
		-- Since the servers do not know the client's actual plantregistry data, this is the best we can do for reducing the amount of data sent
		if updated and (TheNet:IsDedicated() or (TheWorld.ismastersim and self.inst ~= ThePlayer)) and self.inst.userid then
			SendRPCToClient(CLIENT_RPC.LearnPlantStage, self.inst.userid, plant, stage)
		end
	end
end

function PlantRegistryUpdater:LearnFertilizer(fertilizer)
    if fertilizer then
		local updated = self.plantregistry:LearnFertilizer(fertilizer)

		if updated and TheFocalPoint.entity:GetParent() == self.inst then
			TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/get_gold")
		end
		--print("PlantRegistryUpdater:LearnFertilizer", fertilizer)

		-- Servers will only tell the clients if this is a new fertilizer in this world
		-- Since the servers do not know the client's actual plantregistry data, this is the best we can do for reducing the amount of data sent
		if updated and (TheNet:IsDedicated() or (TheWorld.ismastersim and self.inst ~= ThePlayer)) and self.inst.userid then
			SendRPCToClient(CLIENT_RPC.LearnFertilizerStage, self.inst.userid, fertilizer)
		end
	end
end

function PlantRegistryUpdater:TakeOversizedPicture(plant, weight, beardskin, beardlength)
	if plant and weight then
		local updated = self.plantregistry:TakeOversizedPicture(plant, weight, self.inst, beardskin, beardlength)
		--print("PlantRegistryUpdater:TakeOversizedPicture", plant, weight, beardskin, beardlength)

		-- Servers will only tell the clients if this is a new picture in this world
		-- Since the servers do not know the client's actual plantregistry data, this is the best we can do for reducing the amount of data sent
		if updated and (TheNet:IsDedicated() or (TheWorld.ismastersim and self.inst ~= ThePlayer)) and self.inst.userid then
			SendRPCToClient(CLIENT_RPC.TakeOversizedPicture, self.inst.userid, plant, weight, beardskin, beardlength)
		end
	end
end


return PlantRegistryUpdater