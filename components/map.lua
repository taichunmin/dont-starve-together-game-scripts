require "map/terrain"

local _SetTile = Map.SetTile
function Map:SetTile(x, y, tile, ...)
    local original_tile = self:GetTile(x, y)
    _SetTile(self, x, y, tile, ...)
	TheWorld:PushEvent("onterraform", {x = x, y = y, original_tile = original_tile, tile = tile})
end

--NOTE: Call Map:IsVisualGroundAtPoint(x, y, z) if you want to include the overhang

--NOTE: this is the max of all entities that have custom deploy_extra_spacing
--      see EntityScript:SetDeployExtraSpacing(spacing)
local DEPLOY_EXTRA_SPACING = 0
function Map:RegisterDeployExtraSpacing(spacing)
    DEPLOY_EXTRA_SPACING = math.max(spacing, DEPLOY_EXTRA_SPACING)
end

--NOTE: this is the max of all entities that have custom terraform_extra_spacing
--      see EntityScript:SetTerraformExtraSpacing(spacing)
local TERRAFORM_EXTRA_SPACING = 0
function Map:RegisterTerraformExtraSpacing(spacing)
    TERRAFORM_EXTRA_SPACING = math.max(spacing, TERRAFORM_EXTRA_SPACING)
end

local MAX_GROUND_TARGET_BLOCKER_RADIUS = 0
function Map:RegisterGroundTargetBlocker(radius)
    MAX_GROUND_TARGET_BLOCKER_RADIUS = math.max(radius, MAX_GROUND_TARGET_BLOCKER_RADIUS)
end

local WALKABLE_PLATFORM_TAGS = {"walkableplatform"}
local MAST_TAGS = {"mast"}

function Map:IsPassableAtPoint(x, y, z, allow_water, exclude_boats)
    return self:IsPassableAtPointWithPlatformRadiusBias(x, y, z, allow_water, exclude_boats, 0)
end

function Map:IsPassableAtPointWithPlatformRadiusBias(x, y, z, allow_water, exclude_boats, platform_radius_bias, ignore_land_overhang)
    local valid_tile = self:IsAboveGroundAtPoint(x, y, z, allow_water)
    local is_overhang = false
    if not valid_tile then
        valid_tile = ((not ignore_land_overhang) and self:IsVisualGroundAtPoint(x,y,z) or false)
        if valid_tile then
            is_overhang = true
        end
    end
    if not allow_water and not valid_tile then
        if not exclude_boats then
            local entities = TheSim:FindEntities(x, 0, z, TUNING.MAX_WALKABLE_PLATFORM_RADIUS + platform_radius_bias, WALKABLE_PLATFORM_TAGS)
            for i, v in ipairs(entities) do
                local walkable_platform = v.components.walkableplatform
                if walkable_platform ~= nil then
                    local platform_x, platform_y, platform_z = v.Transform:GetWorldPosition()
                    local distance_sq = VecUtil_LengthSq(x - platform_x, z - platform_z)
                    return distance_sq <= walkable_platform.platform_radius * walkable_platform.platform_radius
                end
            end
        end
		return false
    end
	return valid_tile, is_overhang
end

function Map:IsAboveGroundAtPoint(x, y, z, allow_water)
    local tile = self:GetTileAtPoint(x, y, z)
    local valid_water_tile = (allow_water == true) and tile >= GROUND.OCEAN_START and tile <= GROUND.OCEAN_END
    return (tile < GROUND.UNDERGROUND or valid_water_tile) and
        tile ~= GROUND.IMPASSABLE and
        tile ~= GROUND.INVALID
end

function Map:IsOceanTileAtPoint(x, y, z)
    local tile = self:GetTileAtPoint(x, y, z)
    return tile >= GROUND.OCEAN_START and tile <= GROUND.OCEAN_END and
        tile ~= GROUND.IMPASSABLE and
        tile ~= GROUND.INVALID
end

function Map:IsOceanAtPoint(x, y, z, allow_boats)
    return TheWorld.Map:IsOceanTileAtPoint(x, y, z)                             -- Location is in the ocean tile range
        and not TheWorld.Map:IsVisualGroundAtPoint(x, y, z)                     -- Location is NOT in the world overhang space
        and (allow_boats or TheWorld.Map:GetPlatformAtPoint(x, z) == nil)		-- The location either accepts boats, or is not the location of a boat
end

function Map:IsValidTileAtPoint(x, y, z)
    local tile = self:GetTileAtPoint(x, y, z)
    return tile ~= GROUND.IMPASSABLE and tile ~= GROUND.INVALID
end

local TERRAFORMBLOCKER_TAGS = { "terraformblocker" }
local TERRAFORMBLOCKER_IGNORE_TAGS = { "INLIMBO" }
function Map:CanTerraformAtPoint(x, y, z)
    local tile = self:GetTileAtPoint(x, y, z)
    if tile == GROUND.DIRT or
        tile >= GROUND.UNDERGROUND or
        tile == GROUND.IMPASSABLE or
        tile == GROUND.INVALID then
        return false
    elseif TERRAFORM_EXTRA_SPACING > 0 then
        for i, v in ipairs(TheSim:FindEntities(x, 0, z, TERRAFORM_EXTRA_SPACING, TERRAFORMBLOCKER_TAGS, TERRAFORMBLOCKER_IGNORE_TAGS)) do
            if v.entity:IsVisible() and
                v:GetDistanceSqToPoint(x, 0, z) < v.terraform_extra_spacing * v.terraform_extra_spacing then
                return false
            end
        end
    end
    return true
end

function Map:CanPlowAtPoint(x, y, z)
    local tile = self:GetTileAtPoint(x, y, z)
    if not self:CanPlantAtPoint(x, y, z) then
        return false
    elseif TERRAFORM_EXTRA_SPACING > 0 then
        for i, v in ipairs(TheSim:FindEntities(x, 0, z, TERRAFORM_EXTRA_SPACING, TERRAFORMBLOCKER_TAGS, TERRAFORMBLOCKER_IGNORE_TAGS)) do
            if v.entity:IsVisible() and
                v:GetDistanceSqToPoint(x, 0, z) < v.terraform_extra_spacing * v.terraform_extra_spacing then
                return false
            end
        end
    end
    return true
end

function Map:CanPlaceTurfAtPoint(x, y, z)
    return self:GetTileAtPoint(x, y, z) == GROUND.DIRT
end

function Map:CanPlantAtPoint(x, y, z)
    local tile = self:GetTileAtPoint(x, y, z)
    return tile ~= GROUND.ROCKY and
        tile ~= GROUND.ROAD and
        tile ~= GROUND.UNDERROCK and
        tile < GROUND.UNDERGROUND and
        tile ~= GROUND.IMPASSABLE and
        tile ~= GROUND.INVALID and
        not GROUND_FLOORING[tile]
end

local FIND_SOIL_MUST_TAGS = { "soil" }
function Map:CollapseSoilAtPoint(x, y, z)
	local till_spacing = GetFarmTillSpacing()
    for i, v in ipairs(TheSim:FindEntities(x, y, z, till_spacing, FIND_SOIL_MUST_TAGS)) do
        v:PushEvent(v:GetDistanceSqToPoint(x, y, z) < till_spacing * 0.5 and "collapsesoil" or "breaksoil")
    end
end

function Map:IsFarmableSoilAtPoint(x, y, z)
    return self:GetTileAtPoint(x, y, z) == GROUND.FARMING_SOIL
end

local DEPLOY_IGNORE_TAGS = { "NOBLOCK", "player", "FX", "INLIMBO", "DECOR", "WALKABLEPLATFORM" }
local DEPLOY_IGNORE_TAGS_NOPLAYER = { "NOBLOCK", "FX", "INLIMBO", "DECOR", "WALKABLEPLATFORM" }
local TILLSOIL_IGNORE_TAGS = { "NOBLOCK", "player", "FX", "INLIMBO", "DECOR", "WALKABLEPLATFORM", "soil" }
local HOLE_TAGS = { "groundhole" }
local BLOCKED_ONEOF_TAGS = { "groundtargetblocker", "groundhole" }

function Map:CanTillSoilAtPoint(x, y, z, ignore_tile_type)
	return (ignore_tile_type and self:CanPlantAtPoint(x, y, z) or self:IsFarmableSoilAtPoint(x, y, z))
			and self:IsDeployPointClear(Vector3(x, y, z), nil, GetFarmTillSpacing(), nil, nil, nil, TILLSOIL_IGNORE_TAGS)
end

function Map:IsPointNearHole(pt, range)
    range = range or .5
    for i, v in ipairs(TheSim:FindEntities(pt.x, 0, pt.z, DEPLOY_EXTRA_SPACING + range, HOLE_TAGS)) do
        local radius = v:GetPhysicsRadius(0) + range
        if v:GetDistanceSqToPoint(pt) < radius * radius then
            return true
        end
    end
    return false
end

function Map:IsGroundTargetBlocked(pt, range)
    range = range or .5
    for i, v in ipairs(TheSim:FindEntities(pt.x, 0, pt.z, math.max(DEPLOY_EXTRA_SPACING, MAX_GROUND_TARGET_BLOCKER_RADIUS) + range, nil, nil, BLOCKED_ONEOF_TAGS)) do
        local radius = (v.ground_target_blocker_radius or v:GetPhysicsRadius(0)) + range
        if v:GetDistanceSqToPoint(pt.x, 0, pt.z) < radius * radius then
            return true
        end
    end
    return false
end

local function IsNearOther(other, pt, min_spacing_sq)
    --FindEntities range check is <=, but we want <
    return other:GetDistanceSqToPoint(pt.x, 0, pt.z) < (other.deploy_extra_spacing ~= nil and math.max(other.deploy_extra_spacing * other.deploy_extra_spacing, min_spacing_sq) or min_spacing_sq)
end

function Map:IsDeployPointClear(pt, inst, min_spacing, min_spacing_sq_fn, near_other_fn, check_player, custom_ignore_tags)
    local min_spacing_sq = min_spacing ~= nil and min_spacing * min_spacing or nil
    near_other_fn = near_other_fn or IsNearOther
    for i, v in ipairs(TheSim:FindEntities(pt.x, 0, pt.z, math.max(DEPLOY_EXTRA_SPACING, min_spacing), nil, custom_ignore_tags ~= nil and custom_ignore_tags or check_player and DEPLOY_IGNORE_TAGS_NOPLAYER or DEPLOY_IGNORE_TAGS)) do
        if v ~= inst and
            v.entity:IsVisible() and
            v.components.placer == nil and
            v.entity:GetParent() == nil and
            near_other_fn(v, pt, min_spacing_sq_fn ~= nil and min_spacing_sq_fn(v) or min_spacing_sq) then
            return false
        end
    end
    return true
end

function Map:CanDeployAtPoint(pt, inst, mouseover)
    local x,y,z = pt:Get()
    return (mouseover == nil or mouseover:HasTag("player") or mouseover:HasTag("walkableplatform"))
        and self:IsPassableAtPointWithPlatformRadiusBias(x,y,z, false, false, TUNING.BOAT.NO_BUILD_BORDER_RADIUS, true)
        and self:IsDeployPointClear(pt, inst, inst.replica.inventoryitem ~= nil and inst.replica.inventoryitem:DeploySpacingRadius() or DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT])
end

function Map:CanDeployPlantAtPoint(pt, inst)
    return self:CanPlantAtPoint(pt:Get())
        and self:IsDeployPointClear(pt, inst, inst.replica.inventoryitem ~= nil and inst.replica.inventoryitem:DeploySpacingRadius() or DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT])
end

local function IsNearOtherWallOrPlayer(other, pt, min_spacing_sq)
    if other:HasTag("wall") or other:HasTag("player") then
        local x, y, z = other.Transform:GetWorldPosition()
        return math.floor(x) == math.floor(pt.x) and math.floor(z) == math.floor(pt.z)
    end
    return IsNearOther(other, pt, min_spacing_sq)
end

function Map:CanDeployWallAtPoint(pt, inst)
    -- We assume that walls use placer.snap_to_meters, so let's emulate the snap here.
    pt = Vector3(math.floor(pt.x) + 0.5, pt.y, math.floor(pt.z) + 0.5)

    local x,y,z = pt:Get()
    local ispassable, is_overhang = self:IsPassableAtPointWithPlatformRadiusBias(x,y,z, false, false, TUNING.BOAT.NO_BUILD_BORDER_RADIUS, false)
    return ispassable and self:IsDeployPointClear(pt, inst, 1, nil, IsNearOtherWallOrPlayer, is_overhang)
end

function Map:CanDeployAtPointInWater(pt, inst, mouseover, data)
    local tile = self:GetTileAtPoint(pt.x, pt.y, pt.z)
    if tile == GROUND.IMPASSABLE or tile == GROUND.INVALID then
        return false
    end

    -- check if there's a boat in the way
    local min_distance_from_boat = (data and data.boat) or 0
    local radius = (data and data.radius) or 0

    local entities = TheSim:FindEntities(pt.x, 0, pt.z, TUNING.MAX_WALKABLE_PLATFORM_RADIUS + radius + min_distance_from_boat, WALKABLE_PLATFORM_TAGS)
    for i, v in ipairs(entities) do
        if v.components.walkableplatform and math.sqrt(v:GetDistanceSqToPoint(pt.x, 0, pt.z)) <= (v.components.walkableplatform.platform_radius + radius + min_distance_from_boat) then
            return false
        end
    end

    local min_distance_from_land = (data and data.land) or 0

    return (mouseover == nil or mouseover:HasTag("player"))
        and self:IsDeployPointClear(pt, nil, min_distance_from_boat + radius)
        and self:IsSurroundedByWater(pt.x, pt.y, pt.z, min_distance_from_land + radius)
end

function Map:CanDeployMastAtPoint(pt, inst, mouseover)
    local tile = self:GetTileAtPoint(pt.x, pt.y, pt.z)
    if tile == GROUND.IMPASSABLE or tile == GROUND.INVALID then
        return false
    end

    -- check if there's a mast in the way
    local mast_min_distance = 1.5
    local entities = TheSim:FindEntities(pt.x, 0, pt.z, mast_min_distance, MAST_TAGS)
    for i, v in ipairs(entities) do
        return false
    end

    return (mouseover == nil or mouseover:HasTag("player") or mouseover:HasTag("walkableplatform"))
        and self:IsPassableAtPointWithPlatformRadiusBias(pt.x,pt.y,pt.z, false, false, TUNING.BOAT.NO_BUILD_BORDER_RADIUS, true)
        and self:IsDeployPointClear(pt, nil, inst.replica.inventoryitem:DeploySpacingRadius())
end

function Map:CanPlacePrefabFilteredAtPoint(x, y, z, prefab)
    local tile = self:GetTileAtPoint(x, y, z)
    if tile == GROUND.INVALID or tile == GROUND.IMPASSABLE then
        return false
    end

    if terrain.filter[prefab] ~= nil then
        for i, v in ipairs(terrain.filter[prefab]) do
            if tile == v then
                -- can't grow on this terrain
                return false
            end
        end
    end
    return true
end

function Map:CanDeployRecipeAtPoint(pt, recipe, rot)
    local is_valid_ground = false;
    if BUILDMODE.WATER == recipe.build_mode then
        local pt_x, pt_y, pt_z = pt:Get()
        is_valid_ground = not self:IsPassableAtPoint(pt_x, pt_y, pt_z)
        if is_valid_ground then
            is_valid_ground = TheWorld.Map:IsSurroundedByWater(pt_x, pt_y, pt_z, 5)
        end
    else
        local pt_x, pt_y, pt_z = pt:Get()
        is_valid_ground = self:IsPassableAtPointWithPlatformRadiusBias(pt_x, pt_y, pt_z, false, false, TUNING.BOAT.NO_BUILD_BORDER_RADIUS, true)
    end

    return is_valid_ground
        and (recipe.testfn == nil or recipe.testfn(pt, rot))
        and self:IsDeployPointClear(pt, nil, recipe.min_spacing or 3.2)
end

function Map:IsSurroundedByWater(x, y, z, radius)
    -- TheSim:ProfilerPush("isSurroundedByWater")

    for i = -radius, radius, 1 do
        if self:IsVisualGroundAtPoint(x - radius, y, z + i) or self:IsVisualGroundAtPoint(x + radius, y, z + i)
			or not self:IsValidTileAtPoint(x - radius, y, z + i) or not self:IsValidTileAtPoint(x + radius, y, z + i) then
            return false
        end
    end
    for i = -(radius - 1), radius - 1, 1 do
        if self:IsVisualGroundAtPoint(x + i, y, z -radius) or self:IsVisualGroundAtPoint(x + i, y, z + radius)
			or not self:IsValidTileAtPoint(x + i, y, z -radius) or not self:IsValidTileAtPoint(x + i, y, z + radius) then
            return false
        end
    end

    -- TheSim:ProfilerPop()
    return true
end

function Map:GetNearestPointOnWater(x, z, radius, iterations)
    local test_increment = radius / iterations
    local map = TheWorld.Map

    for i=1,iterations do
        local test_x, test_z = 0,0

        test_x, test_z = x + test_increment * i, z + 0
        if self:InternalIsPointOnWater(test_x, test_z) then
            return true, test_x, test_z
        end

        test_x, test_z = x +0, z + test_increment * i
        if self:InternalIsPointOnWater(test_x, test_z) then
            return true, test_x, test_z
        end

        test_x, test_z = x + -test_increment * i, z + 0
        if self:InternalIsPointOnWater(test_x, test_z) then
            return true, test_x, test_z
        end

        test_x, test_z = x + 0, z + -test_increment * i
        if self:InternalIsPointOnWater(test_x, test_z) then
            return true, test_x, test_z
        end
    end

    return false, 0, 0
end

function Map:InternalIsPointOnWater(test_x, test_y, test_z)
	if test_z == nil then -- to support passing in (x, z) instead of (x, y, x)
		test_z = test_y
		test_y = 0
	end
    if self:IsVisualGroundAtPoint(test_x, test_y, test_z) or self:GetPlatformAtPoint(test_x, test_y, test_z) ~= nil then
        return false
    else
        return true
    end
end

local WALKABLE_PLATFORM_TAGS = {"walkableplatform"}

function Map:GetPlatformAtPoint(pos_x, pos_y, pos_z, extra_radius)
	if pos_z == nil then -- to support passing in (x, z) instead of (x, y, x)
		pos_z = pos_y
		pos_y = 0
	end
    local entities = TheSim:FindEntities(pos_x, pos_y, pos_z, TUNING.MAX_WALKABLE_PLATFORM_RADIUS + (extra_radius or 0), WALKABLE_PLATFORM_TAGS)
    for i, v in ipairs(entities) do
        if v.components.walkableplatform and math.sqrt(v:GetDistanceSqToPoint(pos_x, 0, pos_z)) <= v.components.walkableplatform.platform_radius then
            return v
        end
    end
    return nil
end

function Map:FindRandomPointInOcean(max_tries)
	local w, h = TheWorld.Map:GetSize()
	w = (w - w/2) * TILE_SCALE
	h = (h - h/2) * TILE_SCALE
	while (max_tries > 0) do
		max_tries = max_tries - 1
		local x, z = math.random() * w, math.random() * h
        if self:IsOceanAtPoint(x, 0, z)	then
			return Vector3(x, 0, z)
		end
	end
end

function Map:FindNodeAtPoint(x, y, z)
	-- Note: If you care about the tile overlap then use FindVisualNodeAtPoint
	local node_index = TheWorld.Map:GetNodeIdAtPoint(x, y, z)
	return TheWorld.topology.nodes[node_index], node_index
end

function Map:NodeAtPointHasTag(x, y, z, tag)
	-- Note: If you care about the tile overlap then use FindVisualNodeAtPoint
	local node_index = TheWorld.Map:GetNodeIdAtPoint(x, y, z)
	local node = TheWorld.topology.nodes[node_index]
	return node ~= nil and node.tags ~= nil and table.contains(node.tags, tag)
end

local function FindVisualNodeAtPoint_TestArea(map, pt_x, pt_z, on_land, r)
	local best = {tile_type = GROUND.INVALID, render_layer = -1}
	for _z = -1, 1 do
		for _x = -1, 1 do
			local x, z = pt_x + _x*r, pt_z + _z*r

			local tile_type = map:GetTileAtPoint(x, 0, z)
			if on_land == IsLandTile(tile_type) then
				local tile_info = GetTileInfo(tile_type)
				local render_layer = tile_info ~= nil and tile_info._render_layer or 0
				if render_layer > best.render_layer then
					best.tile_type = tile_type
					best.render_layer = render_layer
					best.x = x
					best.z = z
				end
			end
		end
	end

	return best.tile_type ~= GROUND.INVALID and best or nil
end

-- !! NOTE: This function is fairly expensive!
function Map:FindVisualNodeAtPoint(x, y, z, has_tag)
	local on_land = self:IsVisualGroundAtPoint(x, 0, z)

	local best = FindVisualNodeAtPoint_TestArea(self, x, z, on_land, 0.95)
				or FindVisualNodeAtPoint_TestArea(self, x, z, on_land, 1.25) -- this is the handle some of the corner case when there the player is really standing quite far into the water tile, but logically on land
				or FindVisualNodeAtPoint_TestArea(self, x, z, on_land, 1.5)

	local node_index = (on_land and best ~= nil) and self:GetNodeIdAtPoint(best.x, 0, best.z) or 0
	if has_tag == nil then
		return TheWorld.topology.nodes[node_index], node_index
	else
		local node = TheWorld.topology.nodes[node_index]
		return ((node ~= nil and table.contains(node.tags, has_tag)) and node or nil), node_index
	end
end

function Map:IsInLunacyArea(x, y, z)
	return (TheWorld.state.isalterawake and TheWorld.state.isnight) or self:FindVisualNodeAtPoint(x, y, z, "lunacyarea") ~= nil
end