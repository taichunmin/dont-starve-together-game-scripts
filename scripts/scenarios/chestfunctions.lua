local function PickLootItems(number, loot)
	local refinedloot = {}

	for i = 1, number do
		local num = math.random(#loot)
		table.insert(refinedloot, loot[num])
		table.remove(loot, num)
	end

	return refinedloot
end


local function AddChestItems(chest, loot, num)
	local numloot = num or chest.components.container.numslots
	if #loot >  numloot then
		loot = PickLootItems(numloot, loot)
	end

	for k, itemtype in ipairs(loot) do

		local itemToSpawn = itemtype.item or itemtype
		if type(itemToSpawn) == "table" then
			itemToSpawn = itemToSpawn[math.random(#itemToSpawn)]
		end

		local spawn = math.random() <= (itemtype.chance or 1)

		local count = itemtype.count or 1
		if type(count) == "function" then
			count = count()
		end

		if spawn then
			for i = 1, count do
				local item = SpawnPrefab(itemToSpawn)
				if item ~= nil then
					if itemtype.initfn then
						itemtype.initfn(item)
					end
					chest.components.container:GiveItem( item )
				else
					print("Cant spawn", itemToSpawn)
				end
			end
		end
	end

	if chest.components.container:IsEmpty() then
		AddChestItems(chest, loot, num)
	end
end

local function InitializeChestTrap(inst, scenariorunner, openfn, chance)
	inst.scene_triggerfn = function(inst, data)
		data.player = data.doer or data.worker
		chestfunctions.OnOpenChestTrap(inst,  openfn, scenariorunner, data, chance)
		scenariorunner:ClearScenario()
	end
	inst:ListenForEvent("onopen", inst.scene_triggerfn)
	inst:ListenForEvent("worked", inst.scene_triggerfn)

end

local function OnOpenChestTrap(inst, openfn, scenariorunner, data, chance)
	if math.random() <= (chance or .66) then
		local talkabouttrap = function(inst, txt)
			if inst.components.talker then  -- Apparently inst can be Deerclops, and Deerclops has no talker
				inst.components.talker:Say(txt)
			end
		end

    	inst.SoundEmitter:PlaySound("dontstarve/common/chest_trap")

        local x, y, z = inst.Transform:GetWorldPosition()
	    local fx = SpawnPrefab("statue_transition_2")
	    if fx ~= nil then
	        fx.Transform:SetPosition(x, y, z)
	        fx.Transform:SetScale(1, 2, 1)
	    end
	    fx = SpawnPrefab("statue_transition")
	    if fx ~= nil then
	        fx.Transform:SetPosition(x, y, z)
	        fx.Transform:SetScale(1, 1.5, 1)
	    end

		openfn(inst, scenariorunner, data)
			--get the player, and get him to say oops
		local player = data.player
		if player then
			player:DoTaskInTime(1, talkabouttrap, GetString(player, "ANNOUNCE_TRAP_WENT_OFF"))
		end
	end
end

local function OnDestroy(inst)
	if inst.scene_triggerfn then
		inst:RemoveEventCallback("onopen", inst.scene_triggerfn)
		inst:RemoveEventCallback("worked", inst.scene_triggerfn)
		inst.scene_triggerfn = nil
	end
end

return
{
	OnOpenChestTrap = OnOpenChestTrap,
	AddChestItems = AddChestItems,
	OnDestroy = OnDestroy,
	InitializeChestTrap = InitializeChestTrap
}