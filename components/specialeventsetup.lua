

--------------------------------------------------------------------------
--[[ RetrofitForestMap_ANR class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "SpecialEventSetup should not exist on client")

--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Post initialization ]]
--------------------------------------------------------------------------

local CURRENT_HALLOWEEN = 2017

function self:OnPostInit()
	if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
		-- retrofitting code to support changing from halloweentrinkets as a bool to as a number
		
		if self.halloweentrinkets and self.halloweentrinkets ~= CURRENT_HALLOWEEN then
			local count = 0
			for k,v in pairs(Ents) do
				if v.prefab ~= nil then
					local split_table = string.split(v.prefab, "trinket_")
					if #split_table == 1 then
						local trinket_num = tonumber(split_table[1])
						if trinket_num ~= nil and trinket_num >= HALLOWEDNIGHTS_TINKET_START and trinket_num <= HALLOWEDNIGHTS_TINKET_END then
							print ("Halloween Trinkets founds, no need to add more")
							self.halloweentrinkets = CURRENT_HALLOWEEN
							break
						end
					end
				end
			end
		end

		if (not self.halloweentrinkets) or self.halloweentrinkets ~= CURRENT_HALLOWEEN then
			self.halloweentrinkets = CURRENT_HALLOWEEN
			local count = 0
			
			local trinkets = {}
			for i = HALLOWEDNIGHTS_TINKET_START, HALLOWEDNIGHTS_TINKET_END do
				table.insert(trinkets, i)
			end
			trinkets = shuffleArray(trinkets)
			
			for i,area in pairs(TheWorld.topology.nodes) do
				if (i % 3) == 0 then
					local points_x, points_y = TheWorld.Map:GetRandomPointsForSite(area.x, area.y, area.poly, 1)
					if #points_x == 1 and #points_y == 1 then
						local x = points_x[1]
						local z = points_y[1]

						local ents = TheSim:FindEntities(x, 0, z, 1)
						if #ents == 0 then
							local e = SpawnPrefab("trinket_" .. trinkets[(count % #trinkets) + 1])
							e.Transform:SetPosition(x, 0, z)
							count = count + 1
						end
					end
				end
			end

			print("Halloween Trinkets added: " ..count)
		end
	end

end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
	return {halloweentrinkets = self.halloweentrinkets}
end

function self:OnLoad(data)
    if data ~= nil then
		self.halloweentrinkets = data.halloweentrinkets
    end
end


--------------------------------------------------------------------------
end)