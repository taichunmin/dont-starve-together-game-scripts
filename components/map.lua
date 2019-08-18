require "map/terrain"

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
	local valid_tile = self:IsAboveGroundAtPoint(x, y, z, allow_water) or ((not ignore_land_overhang) and self:IsVisualGroundAtPoint(x,y,z) or false)
    if not allow_water and not valid_tile then
        if not exclude_boats then
            local entities = TheSim:FindEntities(x, 0, z, TUNING.MAX_WALKABLE_PLATFORM_RADIUS + platform_radius_bias, WALKABLE_PLATFORM_TAGS)
            for i, v in ipairs(entities) do
                local walkable_platform = v.components.walkableplatform            
                if walkable_platform ~= nil then  
                    local platform_x, platform_y, platform_z = v.Transform:GetWorldPosition()
                    local distance_sq = VecUtil_LengthSq(x - platform_x, z - platform_z)
                    return distance_sq <= walkable_platform.radius * walkable_platform.radius
                end
            end
        end
		return false
    end
	return valid_tile
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
function Map:IsValidTileAtPoint(x, y, z)
    local tile = self:GetTileAtPoint(x, y, z)
    return tile ~= GROUND.IMPASSABLE and tile ~= GROUND.INVALID
end

function Map:CanTerraformAtPoint(x, y, z)
    local tile = self:GetTileAtPoint(x, y, z)
    if tile == GROUND.DIRT or
        tile >= GROUND.UNDERGROUND or
        tile == GROUND.IMPASSABLE or
        tile == GROUND.INVALID then
        return false
    elseif TERRAFORM_EXTRA_SPACING > 0 then
        for i, v in ipairs(TheSim:FindEntities(x, 0, z, TERRAFORM_EXTRA_SPACING, { "terraformblocker" }, { "INLIMBO" })) do
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

local DEPLOY_IGNORE_TAGS = { "NOBLOCK", "player", "FX", "INLIMBO", "DECOR", "WALKABLEPLATFORM" }

function Map:IsPointNearHole(pt, range)
    range = range or .5
    for i, v in ipairs(TheSim:FindEntities(pt.x, 0, pt.z, DEPLOY_EXTRA_SPACING + range, { "groundhole" })) do
        local radius = v:GetPhysicsRadius(0) + range
        if v:GetDistanceSqToPoint(pt) < radius * radius then
            return true
        end
    end
    return false
end

function Map:IsGroundTargetBlocked(pt, range)
    range = range or .5
    for i, v in ipairs(TheSim:FindEntities(pt.x, 0, pt.z, math.max(DEPLOY_EXTRA_SPACING, MAX_GROUND_TARGET_BLOCKER_RADIUS) + range, nil, nil, { "groundtargetblocker", "groundhole" })) do
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

function Map:IsDeployPointClear(pt, inst, min_spacing, min_spacing_sq_fn, near_other_fn)
    local min_spacing_sq = min_spacing ~= nil and min_spacing * min_spacing or nil
    near_other_fn = near_other_fn or IsNearOther
    for i, v in ipairs(TheSim:FindEntities(pt.x, 0, pt.z, math.max(DEPLOY_EXTRA_SPACING, min_spacing), nil, DEPLOY_IGNORE_TAGS)) do
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

local function IsNearOtherWall(other, pt, min_spacing_sq)
    if other:HasTag("wall") then
        local x, y, z = other.Transform:GetWorldPosition()
        return math.floor(x) == math.floor(pt.x) and math.floor(z) == math.floor(pt.z)
    end
    return IsNearOther(other, pt, min_spacing_sq)
end

function Map:CanDeployWallAtPoint(pt, inst)
    local x,y,z = pt:Get()
    return self:IsPassableAtPointWithPlatformRadiusBias(x,y,z, false, false, TUNING.BOAT.NO_BUILD_BORDER_RADIUS, true)
        and self:IsDeployPointClear(pt, inst, 1, nil, IsNearOtherWall)
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
        return false
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
        if self:IsVisualGroundAtPoint(x - radius, y, z + i) or self:IsVisualGroundAtPoint(x + radius, y, z + i) then
            return false
        end
    end
    for i = -(radius - 1), radius - 1, 1 do
        if self:IsVisualGroundAtPoint(x + i, y, z -radius) or self:IsVisualGroundAtPoint(x + i, y, z + radius) then
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

function Map:InternalIsPointOnWater(test_x, test_z)
    if self:IsVisualGroundAtPoint(test_x, 0, test_z) or self:GetPlatformAtPoint(test_x, test_z) ~= nil then
        return false
    else        
        return true
    end
end

local WALKABLE_PLATFORM_TAGS = {"walkableplatform"}

function Map:GetPlatformAtPoint(pos_x, pos_z)
    local entities = TheSim:FindEntities(pos_x, 0, pos_z, TUNING.MAX_WALKABLE_PLATFORM_RADIUS, WALKABLE_PLATFORM_TAGS)
    for i, v in ipairs(entities) do
        return v 
    end
    return nil
end

function Map:FindNodeAtPoint(x, y, z)
    for i, node in ipairs(TheWorld.topology.nodes) do
        if TheSim:WorldPointInPoly(x, z, node.poly) then
			return node, i
		end
	end
	return nil
end