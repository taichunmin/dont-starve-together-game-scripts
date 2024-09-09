local function OnSink(inst, data)
	if data ~= nil and data.boat ~= nil then
		-- Sinking from a boat, meaning the location is guaranteed to be accessible by boat
		inst.components.submersible.force_no_repositioning = true
	end

	inst.components.submersible:Submerge()
end

local function OnLanded(inst)
	inst.components.submersible:OnLanded()
end

local CHECK_SPACING = 6
local OFFSETS =
{
	{ x = -CHECK_SPACING, z = -CHECK_SPACING },		{ x = 0, z = -CHECK_SPACING },		{ x = CHECK_SPACING, z = -CHECK_SPACING },
	{ x = -CHECK_SPACING, z = 0 },														{ x = CHECK_SPACING, z = 0 },
	{ x = -CHECK_SPACING, z = CHECK_SPACING },		{ x = 0, z = CHECK_SPACING }, 		{ x = CHECK_SPACING, z = CHECK_SPACING },
}

local function CheckNearbyTiles(x, y, z)
	local waterpoints = {}
	local landpoints = {}
	local area_free = true

	for i, v in ipairs(OFFSETS) do
		local check_x = x + v.x
		local check_z = z + v.z

		if TheWorld.Map:IsOceanTileAtPoint(check_x, 0, check_z) then
			table.insert(waterpoints, { x = check_x, z = check_z })
		else
			table.insert(landpoints, { x = check_x, z = check_z })
			area_free = false
		end
	end

	return { center = { x, y, z }, waterpoints = waterpoints, landpoints = landpoints, area_free = area_free }
end

local Submersible = Class(function(self, inst)
	self.inst = inst

	self.force_no_repositioning = false

	self.inst:ListenForEvent("onsink", OnSink)
	self.inst:ListenForEvent("on_landed", OnLanded)
end)

function Submersible:OnRemoveFromEntity()
	self.inst:RemoveEventCallback("onsink", OnSink)
	self.inst:RemoveEventCallback("on_landed", OnLanded)
end

function Submersible:GetUnderwaterObject()
    if self.inst.components.inventoryitem == nil then
        return nil
    end

    local container = self.inst.components.inventoryitem:GetContainer()
    if container == nil then
        return nil
    end

    if not container.inst:HasTag("underwater_salvageable") then
        return nil
    end

    return container
end

function Submersible:OnLanded()
	if self.inst.components.inventoryitem.owner == nil then
		local x, y, z = self.inst.Transform:GetWorldPosition()
		if TheWorld.Map:IsOceanAtPoint(x, y, z) then
			return self.inst.components.submersible:Submerge()
		end
	end

	return nil
end

function Submersible:Submerge()
	local underwater_object = self:GetUnderwaterObject()
	if underwater_object ~= nil and underwater_object:IsValid() then
		return
	end

	local pt = self.inst:GetPosition()
	local x, y, z = pt.x, pt.y, pt.z
	local spawn_x, spawn_y, spawn_z = x, y, z

	local can_deploy_at_point = TheWorld.Map:IsSurroundedByWater(pt.x, pt.y, pt.z, TUNING.MAX_WALKABLE_PLATFORM_RADIUS + 0.2)

	local has_moved = false
	local data = CheckNearbyTiles(x, y, z)

	local move_to_land = false

	if not self.force_no_repositioning and not can_deploy_at_point and not data.area_free then
		if #data.waterpoints > 0 then
			-- Spot might not be reachable by boat; we need to test nearby positions

			local keep_position = false
			local surrounding_waterpoints = {}

			for i = 1, #data.waterpoints do
				local new_x, new_z = data.waterpoints[i].x, data.waterpoints[i].z
				local data2 = CheckNearbyTiles(new_x, 0, new_z)

				if data2.area_free then
					for _, adjacent_waterpoint in ipairs(data2.waterpoints) do
						local offx, offz = VecUtil_Normalize(x - adjacent_waterpoint.x, z - adjacent_waterpoint.z)
						offx, offz = offx * (TUNING.MAX_WALKABLE_PLATFORM_RADIUS), offz * (TUNING.MAX_WALKABLE_PLATFORM_RADIUS)
						if TheWorld.Map:IsSurroundedByWater(x + offx, 0, z + offz, TUNING.MAX_WALKABLE_PLATFORM_RADIUS) then
							keep_position = true
							break
						end
					end
				end

				if not keep_position then
					local surrounding_waterpoint = { center = data2.center }
					for j, v in ipairs(data2.waterpoints) do
						table.insert(surrounding_waterpoint, v)
						table.insert(surrounding_waterpoints, surrounding_waterpoint)
					end
				end
			end

			if not keep_position then
				local surrounding_waterpoints_shuffled = shuffleArray(surrounding_waterpoints)
				local found_applicable_waterpoint = false

				for i, v in ipairs(surrounding_waterpoints_shuffled) do
					for ii, vv in ipairs(v) do
						if CheckNearbyTiles(vv.x, 0, vv.z).area_free then
							has_moved = true

							spawn_x, spawn_z = v.center[1], v.center[3]
							found_applicable_waterpoint = true
							break
						end
					end
					if found_applicable_waterpoint then
						break
					end
				end

				move_to_land = not found_applicable_waterpoint
			end
		else
			move_to_land = true
		end

		if move_to_land and #data.landpoints > 0 then
			has_moved = true

			local ind = math.random(#data.landpoints)
			spawn_x, spawn_z = data.landpoints[ind].x, data.landpoints[ind].z
			local random_offset = FindWalkableOffset(Vector3(spawn_x, 0, spawn_z), math.random() * TWOPI, math.random() * 3, 8)
			if random_offset ~= nil then
				spawn_x, spawn_z = spawn_x + random_offset.x, spawn_z + random_offset.z
			end
		end
	end

	if move_to_land then
		has_moved = true

		SpawnPrefab("splash_green").Transform:SetPosition(x, 0, z)
		self.inst.Transform:SetPosition(spawn_x, 0, spawn_z)
	else
		self:MakeSunken(spawn_x, spawn_z)
	end

	return has_moved
end

function Submersible:MakeSunken(x, z, ignore_boats, nosplash)
	if TheWorld.Map:IsOceanAtPoint(x, 0, z, ignore_boats) then
		local underwater_object = SpawnPrefab("underwater_salvageable")

		if underwater_object ~= nil then
			underwater_object.Transform:SetPosition(x, 0, z)
			underwater_object.components.inventory:GiveItem(self.inst)

			self.inst:PushEvent("on_submerge", { underwater_object = underwater_object })
			if not nosplash then
				SpawnPrefab("splash_green").Transform:SetPosition(x, 0, z)
			end
		end
	end
end

function Submersible:OnSave()
    return
	{
        force_no_repositioning = self.force_no_repositioning,
    }
end

function Submersible:OnLoad(data)
    self.force_no_repositioning = data.force_no_repositioning or false
end

return Submersible
