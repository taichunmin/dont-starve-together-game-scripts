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

--NOTE: this merge the max of this into DEPLOY_EXTRA_SPACING
--		see EntityScript:SetDeploySmartRadius(radius)
function Map:RegisterDeploySmartRadius(radius)
	DEPLOY_EXTRA_SPACING = math.max(radius + DEPLOYSPACING_RADIUS[DEPLOYSPACING.LARGE] / 2, DEPLOY_EXTRA_SPACING)
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
    local valid_water_tile = (allow_water == true) and TileGroupManager:IsOceanTile(tile)
    return valid_water_tile or TileGroupManager:IsLandTile(tile)
end

function Map:IsLandTileAtPoint(x, y, z)
    local tile = self:GetTileAtPoint(x, y, z)
    return TileGroupManager:IsLandTile(tile)
end

function Map:IsOceanTileAtPoint(x, y, z)
    local tile = self:GetTileAtPoint(x, y, z)
    return TileGroupManager:IsOceanTile(tile)
end

function Map:IsTemporaryTileAtPoint(x, y, z)
    local tile = self:GetTileAtPoint(x, y, z)
    return TileGroupManager:IsTemporaryTile(tile)
end

function Map:IsOceanAtPoint(x, y, z, allow_boats)
    return self:IsOceanTileAtPoint(x, y, z)                             -- Location is in the ocean tile range
        and not self:IsVisualGroundAtPoint(x, y, z)                     -- Location is NOT in the world overhang space
        and (allow_boats or self:GetPlatformAtPoint(x, z) == nil)		-- The location either accepts boats, or is not the location of a boat
end

function Map:IsValidTileAtPoint(x, y, z)
    local tile = self:GetTileAtPoint(x, y, z)
    return not TileGroupManager:IsInvalidTile(tile)
end

-- Terraform tests
local TERRAFORMBLOCKER_TAGS = { "terraformblocker" }
local TERRAFORMBLOCKER_IGNORE_TAGS = { "INLIMBO" }
function Map:CanTerraformAtPoint(x, y, z)
    local tile = self:GetTileAtPoint(x, y, z)
    if TERRAFORM_IMMUNE[tile] or not TileGroupManager:IsLandTile(tile) then
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

function Map:IsTerraformingBlockedByAnObject(tile_x, tile_y)
    if TERRAFORM_EXTRA_SPACING <= 0 then return false end

    local cx, _, cz = self:GetTileCenterPoint(tile_x, tile_y)
    for _, blocker in ipairs(TheSim:FindEntities(cx, 0, cz, TERRAFORM_EXTRA_SPACING, TERRAFORMBLOCKER_TAGS, TERRAFORMBLOCKER_IGNORE_TAGS)) do
        if blocker.entity:IsVisible() and
                blocker:GetDistanceSqToPoint(cx, 0, cz) < blocker.terraform_extra_spacing * blocker.terraform_extra_spacing then
            return true
        end
    end

    return false
end

function Map:CanPlowAtPoint(x, y, z)
    if not self:CanPlantAtPoint(x, y, z) then
        return false
    elseif TERRAFORM_EXTRA_SPACING > 0 then
        for _, v in ipairs(TheSim:FindEntities(x, 0, z, TERRAFORM_EXTRA_SPACING, TERRAFORMBLOCKER_TAGS, TERRAFORMBLOCKER_IGNORE_TAGS)) do
            if v.entity:IsVisible() and
                v:GetDistanceSqToPoint(x, 0, z) < v.terraform_extra_spacing * v.terraform_extra_spacing then
                return false
            end
        end
    end
    return true
end

function Map:CanPlaceTurfAtPoint(x, y, z)
    return self:GetTileAtPoint(x, y, z) == WORLD_TILES.DIRT
end

--
function Map:CanPlantAtPoint(x, y, z)
    local tile = self:GetTileAtPoint(x, y, z)

    if not TileGroupManager:IsLandTile(tile) then
        return false
    end

    return not GROUND_HARD[tile]
end

local FIND_SOIL_MUST_TAGS = { "soil" }
function Map:CollapseSoilAtPoint(x, y, z)
	local till_spacing = GetFarmTillSpacing()
    for i, v in ipairs(TheSim:FindEntities(x, y, z, till_spacing, FIND_SOIL_MUST_TAGS)) do
        v:PushEvent(v:GetDistanceSqToPoint(x, y, z) < till_spacing * 0.5 and "collapsesoil" or "breaksoil")
    end
end

function Map:IsFarmableSoilAtPoint(x, y, z)
    return self:GetTileAtPoint(x, y, z) == WORLD_TILES.FARMING_SOIL
end

local DEPLOY_IGNORE_TAGS = { "NOBLOCK", "player", "FX", "INLIMBO", "DECOR", "walkableplatform", "walkableperipheral", "isdead"}

local DEPLOY_IGNORE_TAGS_NOPLAYER = shallowcopy(DEPLOY_IGNORE_TAGS)
table.removearrayvalue(DEPLOY_IGNORE_TAGS_NOPLAYER, "player")

local TILLSOIL_IGNORE_TAGS = shallowcopy(DEPLOY_IGNORE_TAGS)
table.insert(TILLSOIL_IGNORE_TAGS, "soil")
table.insert(TILLSOIL_IGNORE_TAGS, "merm")

local WALKABLEPERIPHERAL_DEPLOY_IGNORE_TAGS = shallowcopy(DEPLOY_IGNORE_TAGS)
table.removearrayvalue(WALKABLEPERIPHERAL_DEPLOY_IGNORE_TAGS, "walkableperipheral")

local CAST_DEPLOY_IGNORE_TAGS = shallowcopy(DEPLOY_IGNORE_TAGS)
table.insert(CAST_DEPLOY_IGNORE_TAGS, "locomotor")
table.insert(CAST_DEPLOY_IGNORE_TAGS, "_inventoryitem")
table.insert(CAST_DEPLOY_IGNORE_TAGS, "allow_casting")

local HOLE_TAGS = { "groundhole" }
local BLOCKED_ONEOF_TAGS = { "groundtargetblocker", "groundhole" }

function Map:CanTillSoilAtPoint(x, y, z, ignore_tile_type)
	return (ignore_tile_type and self:CanPlantAtPoint(x, y, z) or self:IsFarmableSoilAtPoint(x, y, z))
			and self:IsDeployPointClear(Vector3(x, y, z), nil, GetFarmTillSpacing(), nil, nil, nil, TILLSOIL_IGNORE_TAGS)
end

function Map:IsPointNearHole(pt, range)
    range = range or .5
    for _, hole in ipairs(TheSim:FindEntities(pt.x, 0, pt.z, DEPLOY_EXTRA_SPACING + range, HOLE_TAGS)) do
        local radius = (hole._groundhole_outerradius or hole:GetPhysicsRadius(0)) + (hole._groundhole_rangeoverride or range)
        local distsq = hole:GetDistanceSqToPoint(pt)
        if distsq < radius * radius then
            local hole_innerradius = hole._groundhole_innerradius
            return (hole_innerradius == nil) or (distsq >= (hole_innerradius * hole_innerradius))
        end
    end
    return false
end

function Map:IsGroundTargetBlocked(pt, range)
    range = range or .5
    for _, blocker in ipairs(TheSim:FindEntities(pt.x, 0, pt.z, math.max(DEPLOY_EXTRA_SPACING, MAX_GROUND_TARGET_BLOCKER_RADIUS) + range, nil, nil, BLOCKED_ONEOF_TAGS)) do
        local radius = (blocker.ground_target_blocker_radius or blocker._groundhole_outerradius or blocker:GetPhysicsRadius(0)) + (blocker._groundhole_rangeoverride or range)
        local distsq = blocker:GetDistanceSqToPoint(pt.x, 0, pt.z)
        if distsq < radius * radius then
            local blocker_innerradius = blocker._groundhole_innerradius
            return (blocker_innerradius == nil) or (distsq >= (blocker_innerradius * blocker_innerradius))
        end
    end
    return false
end

--V2C: keep backward compatible
--     -original: IsNearOther(other, pt, min_spacing_sq)
--     -new: -added support for deploy_smart_radius
--           -supports missing min_spacing param
local function IsNearOther(other, pt, min_spacing_sq, min_spacing)
    --FindEntities range check is <=, but we want <
	if min_spacing_sq <= 0 and other:HasTag("structure") then
		--special case (e.g. minisigns use DEPLOYSPACING.NONE)
		if other.deploy_extra_spacing then
			min_spacing_sq = other.deploy_extra_spacing * other.deploy_extra_spacing
		end
	elseif other.deploy_smart_radius then
		min_spacing = other.deploy_smart_radius + (min_spacing or math.sqrt(min_spacing_sq)) / 2
		min_spacing_sq = min_spacing * min_spacing
	elseif other.deploy_extra_spacing then
		min_spacing_sq = math.max(other.deploy_extra_spacing * other.deploy_extra_spacing, min_spacing_sq)
	elseif other.replica.inventoryitem then
		min_spacing = other:GetPhysicsRadius(0.5) + (min_spacing or math.sqrt(min_spacing_sq)) / 2
		min_spacing_sq = math.min(min_spacing * min_spacing, min_spacing_sq)
	end
	return other:GetDistanceSqToPoint(pt) < min_spacing_sq
end

function Map:IsDeployPointClear(pt, inst, min_spacing, min_spacing_sq_fn, near_other_fn, check_player, custom_ignore_tags)
    local min_spacing_sq = min_spacing ~= nil and min_spacing * min_spacing or nil
    near_other_fn = near_other_fn or IsNearOther
    for _, v in ipairs(TheSim:FindEntities(pt.x, 0, pt.z, math.max(DEPLOY_EXTRA_SPACING, min_spacing), nil, (custom_ignore_tags ~= nil and custom_ignore_tags) or (check_player and DEPLOY_IGNORE_TAGS_NOPLAYER) or DEPLOY_IGNORE_TAGS)) do
        if v ~= inst and
            v.entity:IsVisible() and
            v.components.placer == nil and
			v.entity:GetParent() == nil
		then
			local v_min_spacing_sq = min_spacing_sq_fn and min_spacing_sq_fn(v) or min_spacing_sq
			if near_other_fn(v, pt, v_min_spacing_sq, (v_min_spacing_sq == min_spacing_sq and min_spacing) or nil) then
				return false
			end
        end
    end
    return true
end

local function IsNearOther2(other, pt, object_size)
    --FindEntities range check is <=, but we want <
	object_size = object_size + (
		other.deploy_smart_radius or
		other.deploy_extra_spacing or
		(other.replica.inventoryitem and other:GetPhysicsRadius(0.5)) or
		0
	)
    return other:GetDistanceSqToPoint(pt.x, 0, pt.z) < object_size * object_size
end

--this is very similiar to IsDeployPointClear, but does the math a bit better, and DEPLOY_EXTRA_SPACING now works a lot better.
function Map:IsDeployPointClear2(pt, inst, object_size, object_size_fn, near_other_fn, check_player, custom_ignore_tags)
    local entities_radius = object_size + DEPLOY_EXTRA_SPACING
    near_other_fn = near_other_fn or IsNearOther2
    for i, v in ipairs(TheSim:FindEntities(pt.x, 0, pt.z, entities_radius, nil, (custom_ignore_tags ~= nil and custom_ignore_tags) or (check_player and DEPLOY_IGNORE_TAGS_NOPLAYER) or DEPLOY_IGNORE_TAGS)) do
        if v ~= inst and
            v.entity:IsVisible() and
            v.components.placer == nil and
            v.entity:GetParent() == nil and
            near_other_fn(v, pt, object_size_fn and object_size_fn(v) or object_size) then
            return false
        end
    end
    return true
end

function Map:CanDeployAtPoint(pt, inst, mouseover)
    local x,y,z = pt:Get()
    return (mouseover == nil or mouseover:HasTag("player") or mouseover:HasTag("walkableplatform") or mouseover:HasTag("walkableperipheral"))
        and self:IsPassableAtPointWithPlatformRadiusBias(x,y,z, false, false, TUNING.BOAT.NO_BUILD_BORDER_RADIUS, true)
        and self:IsDeployPointClear(pt, inst, inst.replica.inventoryitem ~= nil and inst.replica.inventoryitem:DeploySpacingRadius() or DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT])
end

function Map:CanDeployPlantAtPoint(pt, inst)
    return self:CanPlantAtPoint(pt:Get())
        and self:IsDeployPointClear(pt, inst, inst.replica.inventoryitem ~= nil and inst.replica.inventoryitem:DeploySpacingRadius() or DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT])
end

local function IsNearOtherWallOrPlayer(other, pt, min_spacing_sq, min_spacing)
    if other:HasTag("wall") or other:HasTag("player") then
        local x, y, z = other.Transform:GetWorldPosition()
        return math.floor(x) == math.floor(pt.x) and math.floor(z) == math.floor(pt.z)
    end
	return IsNearOther(other, pt, min_spacing_sq, min_spacing)
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
    if TileGroupManager:IsInvalidTile(tile) then
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
    if TileGroupManager:IsInvalidTile(tile) then
        return false
    end

    -- check if there's a mast in the way
    local mast_min_distance = 1.5
    local entities = TheSim:FindEntities(pt.x, 0, pt.z, mast_min_distance, MAST_TAGS)
    for i, v in ipairs(entities) do
        return false
    end

    return (mouseover == nil or mouseover:HasTag("player") or mouseover:HasTag("walkableplatform") or mouseover:HasTag("walkableperipheral"))
        and self:IsPassableAtPointWithPlatformRadiusBias(pt.x,pt.y,pt.z, false, false, TUNING.BOAT.NO_BUILD_BORDER_RADIUS, true)
        and self:IsDeployPointClear(pt, nil, inst.replica.inventoryitem:DeploySpacingRadius())
end

local function IsNearOtherWalkablePeripheral(other, pt, min_spacing_sq, min_spacing)
	return other:HasTag("walkableperipheral") and IsNearOther(other, pt, min_spacing_sq, min_spacing)
end

function Map:CanDeployWalkablePeripheralAtPoint(pt, inst)
	return self:IsDeployPointClear(pt, nil, inst.replica.inventoryitem:DeploySpacingRadius(), nil, IsNearOtherWalkablePeripheral, nil, WALKABLEPERIPHERAL_DEPLOY_IGNORE_TAGS)
end

local function IsDockNearOtherOnOcean(other, pt, min_spacing_sq, min_spacing)
	return IsNearOther(other, pt, min_spacing_sq, min_spacing)
		and not TheWorld.Map:IsVisualGroundAtPoint(other.Transform:GetWorldPosition())  -- Throw out any tests for anything that's not in the ocean.
end

function Map:HasAdjacentLandTile(tx, ty) -- Tile coordinates only.
    for x_off = -1, 1, 1 do
        for y_off = -1, 1, 1 do
            if (x_off ~= 0 or y_off ~= 0) and IsLandTile(TheWorld.Map:GetTile(tx + x_off, ty + y_off)) then
                return true
            end
        end
    end
    return false
end

function Map:CanDeployDockAtPoint(pt, inst, mouseover)
    local tile = self:GetTileAtPoint(pt.x, pt.y, pt.z)
    if TileGroupManager:IsInvalidTile(tile) or not TileGroupManager:IsOceanTile(tile) then
        return false
    end

    -- TILE_SCALE is the dimension of a tile; 1.0 is the approximate overhang, but we overestimate for safety.
    local min_distance_from_entities = (TILE_SCALE/2) + 1.2
    local min_distance_from_boat = min_distance_from_entities + TUNING.MAX_WALKABLE_PLATFORM_RADIUS

    local boat_entities = TheSim:FindEntities(pt.x, 0, pt.z, min_distance_from_boat, WALKABLE_PLATFORM_TAGS)
    for _, v in ipairs(boat_entities) do
        if v.components.walkableplatform ~= nil and
                math.sqrt(v:GetDistanceSqToPoint(pt.x, 0, pt.z)) <= (v.components.walkableplatform.platform_radius + min_distance_from_entities) then
            return false
        end
    end

    for _, entity_on_tile in ipairs(TheWorld.Map:GetEntitiesOnTileAtPoint(pt.x, 0, pt.z)) do
        if entity_on_tile:HasTag("dockjammer") then
            return false
        end
    end

    return (mouseover == nil or mouseover:HasTag("player"))
        and self:IsDeployPointClear(pt, nil, min_distance_from_entities, nil, IsDockNearOtherOnOcean)
end

function Map:IsDockAtPoint(x, y, z)
    local tile = self:GetTileAtPoint(x, y, z)
    return tile == WORLD_TILES.MONKEY_DOCK
end

function Map:IsOceanIceAtPoint(x, y, z)
    local tile = self:GetTileAtPoint(x, y, z)
    return tile == WORLD_TILES.OCEAN_ICE
end


function Map:CanDeployBoatAtPointInWater(pt, inst, mouseover, data)
    local tile = self:GetTileAtPoint(pt.x, pt.y, pt.z)
    if TileGroupManager:IsInvalidTile(tile) then
        return false
    end

    local boat_radius = data.boat_radius
    local boat_extra_spacing = data.boat_extra_spacing
    local min_distance_from_land = data.min_distance_from_land

    local entities = TheSim:FindEntities(pt.x, 0, pt.z, TUNING.MAX_WALKABLE_PLATFORM_RADIUS + boat_radius + boat_extra_spacing, WALKABLE_PLATFORM_TAGS)
    for i, v in ipairs(entities) do
        local v_walkableplatform = v.components.walkableplatform
        if v_walkableplatform then
            local distance_to_position = math.sqrt(v:GetDistanceSqToPoint(pt.x, 0, pt.z))
            local test_distance = (v_walkableplatform.platform_radius + boat_radius + boat_extra_spacing)
            if distance_to_position <= test_distance then
                return false
            end
        end
    end

    return (mouseover == nil or mouseover:HasTag("player"))
        and self:IsDeployPointClear2(pt, nil, boat_radius + boat_extra_spacing)
        and self:IsSurroundedByWater(pt.x, pt.y, pt.z, boat_radius + min_distance_from_land)
end

function Map:CanPlacePrefabFilteredAtPoint(x, y, z, prefab)
    local tile = self:GetTileAtPoint(x, y, z)
    if TileGroupManager:IsInvalidTile(tile) then
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
            is_valid_ground = self:IsSurroundedByWater(pt_x, pt_y, pt_z, 5)
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
    radius = radius + 1 --add 1 to radius for map overhang, way cheaper than doing an IsVisualGround test
    local num_edge_points = math.ceil((radius*2) / 4) - 1

    --test the corners first
    if not self:IsOceanTileAtPoint(x + radius, y, z + radius) then return false end
    if not self:IsOceanTileAtPoint(x - radius, y, z + radius) then return false end
    if not self:IsOceanTileAtPoint(x + radius, y, z - radius) then return false end
    if not self:IsOceanTileAtPoint(x - radius, y, z - radius) then return false end

    --if the radius is less than 1(2 after the +1), it won't have any edges to test and we can end the testing here.
    if num_edge_points == 0 then return true end

    local dist = (radius*2) / (num_edge_points + 1)
    --test the edges next
    for i = 1, num_edge_points do
        local idist = dist * i
        if not self:IsOceanTileAtPoint(x - radius + idist, y, z + radius) then return false end
        if not self:IsOceanTileAtPoint(x - radius + idist, y, z - radius) then return false end
        if not self:IsOceanTileAtPoint(x - radius, y, z - radius + idist) then return false end
        if not self:IsOceanTileAtPoint(x + radius, y, z - radius + idist) then return false end
    end

    --test interior points last
    for i = 1, num_edge_points do
        local idist = dist * i
        for j = 1, num_edge_points do
            local jdist = dist * j
            if not self:IsOceanTileAtPoint(x - radius + idist, y, z - radius + jdist) then return false end
        end
    end
    return true
end

function Map:IsSurroundedByLand(x, y, z, radius)
    radius = radius + 1 --add 1 to radius for map overhang, way cheaper than doing an IsVisualGround test
    local num_edge_points = math.ceil((radius*2) / 4) - 1

    --test the corners first
    if not self:IsLandTileAtPoint(x + radius, y, z + radius) then return false end
    if not self:IsLandTileAtPoint(x - radius, y, z + radius) then return false end
    if not self:IsLandTileAtPoint(x + radius, y, z - radius) then return false end
    if not self:IsLandTileAtPoint(x - radius, y, z - radius) then return false end

    --if the radius is less than 1(2 after the +1), it won't have any edges to test and we can end the testing here.
    if num_edge_points == 0 then return true end

    local dist = (radius*2) / (num_edge_points + 1)
    --test the edges next
    for i = 1, num_edge_points do
        local idist = dist * i
        if not self:IsLandTileAtPoint(x - radius + idist, y, z + radius) then return false end
        if not self:IsLandTileAtPoint(x - radius + idist, y, z - radius) then return false end
        if not self:IsLandTileAtPoint(x - radius, y, z - radius + idist) then return false end
        if not self:IsLandTileAtPoint(x + radius, y, z - radius + idist) then return false end
    end

    --test interior points last
    for i = 1, num_edge_points do
        local idist = dist * i
        for j = 1, num_edge_points do
            local jdist = dist * j
            if not self:IsLandTileAtPoint(x - radius + idist, y, z - radius + jdist) then return false end
        end
    end
    return true
end

function Map:GetNearestPointOnWater(x, z, radius, iterations)
    local test_increment = radius / iterations

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

function Map:FindRandomPointWithFilter(max_tries, filterfn)
    local w, h = self:GetSize()
    w = w/2 * TILE_SCALE
    h = h/2 * TILE_SCALE
    -- NOTES(JBK): w and h are now half width and half height sample from -w and +w
    while (max_tries > 0) do
        max_tries = max_tries - 1
        local x, z = (2 * math.random() - 1) * w, (2 * math.random() - 1) * h
        if filterfn == nil or filterfn(self, x, 0, z) then
            return Vector3(x, 0, z)
        end
    end
    return nil
end

function Map:FindRandomPointInOcean(max_tries)
    return self:FindRandomPointWithFilter(max_tries, self.IsOceanAtPoint)
end

function Map:FindRandomPointOnLand(max_tries)
    return self:FindRandomPointWithFilter(max_tries, self.IsLandTileAtPoint)
end

function Map:GetTopologyIDAtPoint(x, y, z)
	local node_index = self:GetNodeIdAtPoint(x, y, z)
    return TheWorld.topology.ids[node_index], node_index
end

function Map:FindNodeAtPoint(x, y, z)
	-- Note: If you care about the tile overlap then use FindVisualNodeAtPoint
	local node_index = self:GetNodeIdAtPoint(x, y, z)
	return TheWorld.topology.nodes[node_index], node_index
end

function Map:NodeAtPointHasTag(x, y, z, tag)
	-- Note: If you care about the tile overlap then use FindVisualNodeAtPoint
	local node_index = self:GetNodeIdAtPoint(x, y, z)
	local node = TheWorld.topology.nodes[node_index]
	return node ~= nil and node.tags ~= nil and table.contains(node.tags, tag)
end

function Map:CanAreaTagsHaveAcidRain(tags)
    return not table.contains(tags, "lunacyarea") and not table.contains(tags, "nocavein")
end

function Map:CanPointHaveAcidRain(x, y, z)
    -- Note: If you care about the tile overlap then use FindVisualNodeAtPoint
    local node_index = self:GetNodeIdAtPoint(x, y, z)
    local node = TheWorld.topology.nodes[node_index]
    if node == nil or node.tags == nil then
        return false
    end

    return self:CanAreaTagsHaveAcidRain(node.tags)
end

function Map:GetRandomPointClustersForNodePrefix(prefixes, countpernode)
    local ret = {}

    local topology = TheWorld.topology
    for id, name in ipairs(topology.ids) do
        for _, prefix in ipairs(prefixes) do
            if name:sub(1, #prefix) == prefix then
                local area =  topology.nodes[id]
                table.insert(ret, {self:GetRandomPointsForSite(area.x, area.y, area.poly, countpernode)})
            end
        end
    end

    return ret
end

local function FindVisualNodeAtPoint_TestArea(map, pt_x, pt_z, on_land, r)
	local best = {tile_type = WORLD_TILES.INVALID, render_layer = -1}
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

	return best.tile_type ~= WORLD_TILES.INVALID and best or nil
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

function Map:CanCastAtPoint(pt, alwayspassable, allowwater, deployradius)
	if alwayspassable or (self:IsPassableAtPoint(pt.x, 0, pt.z, allowwater) and not self:IsGroundTargetBlocked(pt)) then
		return deployradius == nil or deployradius <= 0 or self:IsDeployPointClear(pt, nil, deployradius, nil, nil, nil, CAST_DEPLOY_IGNORE_TAGS)
	end
	return false
end

function Map:IsTileLandNoDocks(tile)
    return TileGroupManager:IsLandTile(tile) and tile ~= WORLD_TILES.MONKEY_DOCK
end

function Map:IsTileOcean(tile)
    return TileGroupManager:IsOceanTile(tile)
end

function Map:IsAboveGroundInSquare(x, y, z, r, filterfn)
    r = r or 1
    for dx = -r, r do
        for dz = -r, r do
            if filterfn then
                -- New logic allows for tile based filtering.
                local tile = self:GetTileAtPoint(x + dx * TILE_SCALE, y, z + dz * TILE_SCALE)
                if not filterfn(self, tile) then
                    return false
                end
            else
                -- Old logic assumes point based filtering with no ocean tiles but allows docks.
                if not self:IsAboveGroundAtPoint(x + dx * TILE_SCALE, y, z + dz * TILE_SCALE, false) then
                    return false
                end
            end
        end
    end
    return true
end





local GOOD_ARENA_SQUARE_SIZE = 6
local IS_CLEAR_AREA_RADIUS = TILE_SCALE * GOOD_ARENA_SQUARE_SIZE
local NO_PLAYER_RADIUS = 35
----------------------------------------------------------------------------------------
-- Land
local GOODARENAPOINTS_CACHE_SIZE_MIN = 50 -- 50 points are good enough for a good placement strategy.
local GOODARENAPOINTS_CACHE_SIZE_MAX = 100 -- Do not exceed hard limit for memory's sake.
local GOODARENAPOINTS_ITERATIONS_PER_TICK = 20
local GOODARENAPOINTS_TIME_PER_TICK = 0.1
local GOODARENAPOINTS_SIZE_INTERVAL = 50 -- Tiles to go by per interval.


local GoodArenaPoints = {}
local GoodArenaPoints_Count = 0
function Map:ClearGoodArenaPoints()
    GoodArenaPoints = {}
    GoodArenaPoints_Count = 0
end
function Map:GetGoodArenaPoints()
    return GoodArenaPoints, GoodArenaPoints_Count
end

local BADARENA_CANT_TAGS = {"tree", "boulder", "spiderden", "okayforarena"}
local BADARENA_ONEOF_TAGS = {"structure", "blocker", "plant", "antlion_sinkhole_blocker"}
function Map:CheckForBadThingsInArena(pt, badthingsatspawnpoints)
    local x, y, z = pt.x, pt.y, pt.z
    if self:IsAboveGroundInSquare(x, y, z, GOOD_ARENA_SQUARE_SIZE, self.IsTileLandNoDocks) and not IsAnyPlayerInRange(x, y, z, NO_PLAYER_RADIUS) then
        local badthings = TheSim:FindEntities(x, y, z, IS_CLEAR_AREA_RADIUS, nil, BADARENA_CANT_TAGS, BADARENA_ONEOF_TAGS)
        local badthingscount = #badthings
        for _, v in ipairs(badthings) do
            if (v.components.pickable == nil or not v.components.pickable.transplanted) and v:HasTag("plant") then
                badthingscount = badthingscount - 1
            end
        end
        if badthingsatspawnpoints then
            badthingsatspawnpoints[pt] = badthingscount
        end
        if badthingscount == 0 then
            return false -- No bad things are here.
        end
    end
    return true -- Bad things are here.
end

function Map:StartFindingGoodArenaPoints()
    self:StopFindingGoodArenaPoints()

    local w, h = self:GetSize()
    w = w * TILE_SCALE / 2
    h = h * TILE_SCALE / 2
    local check_pt = Vector3(-w, 0, -h)
    local check_iter_scale = GOODARENAPOINTS_SIZE_INTERVAL * TILE_SCALE
    local check_pt_offset = Vector3(0, 0, 0)

    local function DoIteration()
        --print("DoIteration", GoodArenaPoints_Count, check_pt_offset.x, check_pt_offset.z, check_pt.x, check_pt.z)
        for i = 1, GOODARENAPOINTS_ITERATIONS_PER_TICK do
            -- Check.
            if not self:CheckForBadThingsInArena(check_pt) then
                GoodArenaPoints_Count = GoodArenaPoints_Count + 1
                GoodArenaPoints[GoodArenaPoints_Count] = Vector3(check_pt:Get()) -- Copy.
                --local id, index = self:GetTopologyIDAtPoint(check_pt:Get())
                --local r = (
                --    id:find("BigBatCave") or id:find("RockyLand") or id:find("SpillagmiteCaverns") or id:find("LichenLand") or
                --    id:find("BlueForest") or id:find("RedForest") or id:find("GreenForest")
                --) and true or false
                --if r then
                --    SpawnPrefab("bluemooneye").Transform:SetPosition(check_pt:Get())
                --end
                if GoodArenaPoints_Count >= GOODARENAPOINTS_CACHE_SIZE_MAX then
                    self:StopFindingGoodArenaPoints()
                end
            end

            -- Iterate.
            check_pt.x = check_pt.x + check_iter_scale
            if check_pt.x > w then
                check_pt.x = -w + check_pt_offset.x
                check_pt.z = check_pt.z + check_iter_scale
                if check_pt.z > h then
                    check_pt.z = -h + check_pt_offset.z
                    -- Restart whole grid scan happened here get a new offset.
                    check_pt_offset.x = math.random() * check_iter_scale
                    check_pt_offset.z = math.random() * check_iter_scale
                    if GoodArenaPoints_Count >= GOODARENAPOINTS_CACHE_SIZE_MIN then
                        -- We have at least the cache size from one scan stop finding more.
                        self:StopFindingGoodArenaPoints()
                    end
                end
            end
        end
    end
    TheWorld._GoodArenaPoints_Task = TheWorld:DoPeriodicTask(GOODARENAPOINTS_TIME_PER_TICK, DoIteration)
end
function Map:StopFindingGoodArenaPoints()
    if TheWorld._GoodArenaPoints_Task ~= nil then
        TheWorld._GoodArenaPoints_Task:Cancel()
        TheWorld._GoodArenaPoints_Task = nil
    end
end

function Map:FindBestSpawningPointForArena(CustomAllowTest, perfect_only, spawnpoints)
    if not spawnpoints then
        -- If spawnpoints is nil use the cached good points as reference.
        spawnpoints = GoodArenaPoints
        -- Shuffle the points around randomly.
        shuffleArray(GoodArenaPoints)
    end


    local badthingsatspawnpoints = {}
    local x, y, z
    local spawnpointscount = #spawnpoints
    if spawnpointscount == 0 then
        return nil, nil, nil -- No point.
    end

    -- Perfect test for an ideal arena.
    for i, v in ipairs(spawnpoints) do
        x, y, z = v.x, v.y, v.z
        if CustomAllowTest(self, x, y, z) and not self:CheckForBadThingsInArena(v, badthingsatspawnpoints) then
            return x, y, z -- No bad things nearby and roomy for tiles very good point.
        end
    end

    if perfect_only then
        if spawnpoints == GoodArenaPoints then
            -- There are no good arena points for what called this so let us try to make more good ones for the cache.
            self:ClearGoodArenaPoints()
            self:StartFindingGoodArenaPoints()
        end
        return nil, nil, nil
    end

    -- Try a best case if structures are okay to get.
    local best_count = 999999
    for v, badthingscount in pairs(badthingsatspawnpoints) do
        if badthingscount < best_count then
            best_count = badthingscount
            return v.x, v.y, v.z
        end
    end


    -- Try to find something ground available.
    local pt = spawnpoints[math.random(spawnpointscount)]
    x, y, z = pt.x, pt.y, pt.z

    local function IsValidSpawningPoint_Bridge(pt)
        return self:IsAboveGroundInSquare(pt.x, pt.y, pt.z, GOOD_ARENA_SQUARE_SIZE, self.IsTileLandNoDocks)
    end
    
    for r = 5, 15, 5 do
        local offset = FindWalkableOffset(pt, math.random() * TWOPI, r, 8, false, false, IsValidSpawningPoint_Bridge)
        if offset ~= nil then
            x = x + offset.x
            z = z + offset.z
            return x, y, z -- Do not care for amount of structures but it is roomy for tiles.
        end
    end

    if not x then
        if spawnpoints == GoodArenaPoints then
            -- There are no good arena points for what called this so let us try to make more good ones for the cache.
            self:ClearGoodArenaPoints()
            self:StartFindingGoodArenaPoints()
        end
    end

    return x, y, z
end
-- Land
----------------------------------------------------------------------------------------
-- Ocean
local GOODOCEANARENAPOINTS_CACHE_SIZE_MIN = 50 -- 50 points are good enough for a good placement strategy.
local GOODOCEANARENAPOINTS_CACHE_SIZE_MAX = 100 -- Do not exceed hard limit for memory's sake.
local GOODOCEANARENAPOINTS_ITERATIONS_PER_TICK = 10
local GOODOCEANARENAPOINTS_TIME_PER_TICK = 0.2
local GOODOCEANARENAPOINTS_SIZE_INTERVAL = 50 -- Tiles to go by per interval.


local GoodOceanArenaPoints = {}
local GoodOceanArenaPoints_Count = 0
function Map:ClearGoodOceanArenaPoints()
    GoodOceanArenaPoints = {}
    GoodOceanArenaPoints_Count = 0
end
function Map:GetGoodOceanArenaPoints()
    return GoodOceanArenaPoints, GoodOceanArenaPoints_Count
end

local BADOCEANARENA_CANT_TAGS = {"tree", "boulder", "spiderden", "okayforarena", "FX", "DECOR", "NOCLICK"}
local BADOCEANARENA_ONEOF_TAGS = {"structure", "blocker", "antlion_sinkhole_blocker", "ignorewalkableplatforms"}
function Map:CheckForBadThingsInOceanArena(pt, badthingsatspawnpoints)
    local x, y, z = pt.x, pt.y, pt.z
    if self:IsAboveGroundInSquare(x, y, z, GOOD_ARENA_SQUARE_SIZE, self.IsTileOcean) and not IsAnyPlayerInRange(x, y, z, NO_PLAYER_RADIUS) then
        local badthings = TheSim:FindEntities(x, y, z, IS_CLEAR_AREA_RADIUS, nil, BADOCEANARENA_CANT_TAGS, BADOCEANARENA_ONEOF_TAGS)
        local badthingscount = #badthings
        if badthingsatspawnpoints then
            badthingsatspawnpoints[pt] = badthingscount
        end
        if badthingscount == 0 then
            return false -- No bad things are here.
        end
    end
    return true -- Bad things are here.
end

function Map:StartFindingGoodOceanArenaPoints()
    if TheWorld.components.sharkboimanager and TheWorld.components.sharkboimanager.TEMP_DEBUG_RATE then
        GOODOCEANARENAPOINTS_ITERATIONS_PER_TICK = 3000
        GOODOCEANARENAPOINTS_TIME_PER_TICK = 0.0
    end
    self:StopFindingGoodOceanArenaPoints()

    local w, h = self:GetSize()
    w = w * TILE_SCALE / 2
    h = h * TILE_SCALE / 2
    local check_pt = Vector3(-w, 0, -h)
    local check_iter_scale = GOODOCEANARENAPOINTS_SIZE_INTERVAL * TILE_SCALE
    local check_pt_offset = Vector3(0, 0, 0)

    local function DoIteration()
        --print("DoIteration", GoodOceanArenaPoints_Count, check_pt_offset.x, check_pt_offset.z, check_pt.x, check_pt.z)
        for i = 1, GOODOCEANARENAPOINTS_ITERATIONS_PER_TICK do
            -- Check.
            if not self:CheckForBadThingsInOceanArena(check_pt) then
                GoodOceanArenaPoints_Count = GoodOceanArenaPoints_Count + 1
                GoodOceanArenaPoints[GoodOceanArenaPoints_Count] = Vector3(check_pt:Get()) -- Copy.
                --SpawnPrefab("sentryward").Transform:SetPosition(check_pt:Get())
                if GoodOceanArenaPoints_Count >= GOODOCEANARENAPOINTS_CACHE_SIZE_MAX then
                    self:StopFindingGoodOceanArenaPoints()
                end
            end

            -- Iterate.
            check_pt.x = check_pt.x + check_iter_scale
            if check_pt.x > w then
                check_pt.x = -w + check_pt_offset.x
                check_pt.z = check_pt.z + check_iter_scale
                if check_pt.z > h then
                    check_pt.z = -h + check_pt_offset.z
                    -- Restart whole grid scan happened here get a new offset.
                    check_pt_offset.x = math.random() * check_iter_scale
                    check_pt_offset.z = math.random() * check_iter_scale
                    if GoodOceanArenaPoints_Count >= GOODOCEANARENAPOINTS_CACHE_SIZE_MIN then
                        -- We have at least the cache size from one scan stop finding more.
                        self:StopFindingGoodOceanArenaPoints()
                    end
                end
            end
        end
    end
    TheWorld._GoodOceanArenaPoints_Task = TheWorld:DoPeriodicTask(GOODOCEANARENAPOINTS_TIME_PER_TICK, DoIteration)
end
function Map:StopFindingGoodOceanArenaPoints()
    if TheWorld._GoodOceanArenaPoints_Task ~= nil then
        TheWorld._GoodOceanArenaPoints_Task:Cancel()
        TheWorld._GoodOceanArenaPoints_Task = nil
    end
end

function Map:FindBestSpawningPointForOceanArena(CustomAllowTest, perfect_only, spawnpoints)
    if not spawnpoints then
        -- If spawnpoints is nil use the cached good points as reference.
        spawnpoints = GoodOceanArenaPoints
        -- Shuffle the points around randomly.
        shuffleArray(GoodOceanArenaPoints)
    end


    local badthingsatspawnpoints = {}
    local x, y, z
    local spawnpointscount = #spawnpoints
    if spawnpointscount == 0 then
        return nil, nil, nil -- No point.
    end

    -- Perfect test for an ideal arena.
    for i, v in ipairs(spawnpoints) do
        x, y, z = v.x, v.y, v.z
        if CustomAllowTest(self, x, y, z) and not self:CheckForBadThingsInOceanArena(v, badthingsatspawnpoints) then
            return x, y, z -- No bad things nearby and roomy for tiles very good point.
        end
    end

    if perfect_only then
        if spawnpoints == GoodOceanArenaPoints then
            -- There are no good arena points for what called this so let us try to make more good ones for the cache.
            self:ClearGoodOceanArenaPoints()
            self:StartFindingGoodOceanArenaPoints()
        end
        return nil, nil, nil
    end

    -- Try a best case if structures are okay to get.
    local best_count = 999999
    for v, badthingscount in pairs(badthingsatspawnpoints) do
        if badthingscount < best_count then
            best_count = badthingscount
            return v.x, v.y, v.z
        end
    end


    -- Try to find something ground available.
    local pt = spawnpoints[math.random(spawnpointscount)]
    x, y, z = pt.x, pt.y, pt.z

    local function IsValidSpawningPoint_Bridge(pt)
        return self:IsAboveGroundInSquare(pt.x, pt.y, pt.z, GOOD_ARENA_SQUARE_SIZE, self.IsTileOcean)
    end
    
    for r = 5, 15, 5 do
        local offset = FindWalkableOffset(pt, math.random() * TWOPI, r, 8, false, false, IsValidSpawningPoint_Bridge, true)
        if offset ~= nil then
            x = x + offset.x
            z = z + offset.z
            return x, y, z -- Do not care for amount of structures but it is roomy for tiles.
        end
    end

    if not x then
        if spawnpoints == GoodOceanArenaPoints then
            -- There are no good arena points for what called this so let us try to make more good ones for the cache.
            self:ClearGoodOceanArenaPoints()
            self:StartFindingGoodOceanArenaPoints()
        end
    end

    return x, y, z
end
-- Ocean
----------------------------------------------------------------------------------------

function Map:IsPointInSharkBoiArena(x, y, z)
    local world = TheWorld
    if world.net == nil or world.net.components.sharkboimanagerhelper == nil then
        return false
    end

    return world.net.components.sharkboimanagerhelper:IsPointInArena(x, y, z)
end
