local function getfiltersource(src)
    return (src == nil and "[?]")
        or (src:sub(1, 1) == "@" and src:sub(2))
        or src
end

local function getformatinfo(info)
    return info ~= nil
        and string.format("@%s%s in %s",
                getfiltersource(info.source),
                info.currentline ~= nil and (":"..info.currentline) or "",
                info.name or "?")
        or "**error**"
end

function CalledFrom()
    local info = debug.getinfo(3)
    return getformatinfo(info)
end

function GetWorld()
    print("Warning: GetWorld() is deprecated. Please use TheWorld instead. ("..CalledFrom()..")")
    return TheWorld
end

function GetPlayer()
    print("Warning: GetPlayer() is deprecated. Please use ThePlayer instead. ("..CalledFrom()..")")
    return ThePlayer
end

function FindEntity(inst, radius, fn, musttags, canttags, mustoneoftags)
    if inst ~= nil and inst:IsValid() then
        local x, y, z = inst.Transform:GetWorldPosition()
        --print("FIND", inst, radius, musttags and #musttags or 0, canttags and #canttags or 0, mustoneoftags and #mustoneoftags or 0)
        local ents = TheSim:FindEntities(x, y, z, radius, musttags, canttags, mustoneoftags) -- or we could include a flag to the search?
        for i, v in ipairs(ents) do
            if v ~= inst and v.entity:IsVisible() and (fn == nil or fn(v, inst)) then
                return v
            end
        end
    end
end

function FindClosestPlayerInRangeSq(x, y, z, rangesq, isalive)
    local closestPlayer = nil
    for i, v in ipairs(AllPlayers) do
        if (isalive == nil or isalive ~= IsEntityDeadOrGhost(v)) and
            v.entity:IsVisible() then
            local distsq = v:GetDistanceSqToPoint(x, y, z)
            if distsq < rangesq then
                rangesq = distsq
                closestPlayer = v
            end
        end
    end
    return closestPlayer, closestPlayer ~= nil and rangesq or nil
end

function FindClosestPlayerInRange(x, y, z, range, isalive)
    return FindClosestPlayerInRangeSq(x, y, z, range * range, isalive)
end

function FindClosestPlayer(x, y, z, isalive)
    return FindClosestPlayerInRangeSq(x, y, z, math.huge, isalive)
end

function FindClosestPlayerToInst(inst, range, isalive)
    local x, y, z = inst.Transform:GetWorldPosition()
    return FindClosestPlayerInRange(x, y, z, range, isalive)
end

function FindClosestPlayerOnLandInRangeSq(x, y, z, rangesq, isalive)
    local closestPlayer = nil
    for i, v in ipairs(AllPlayers) do
        if (isalive == nil or isalive ~= IsEntityDeadOrGhost(v)) and
                v.entity:IsVisible() and
                v:IsOnValidGround() then
            local distsq = v:GetDistanceSqToPoint(x, y, z)
            if distsq < rangesq then
                rangesq = distsq
                closestPlayer = v
            end
        end
    end
    return closestPlayer, closestPlayer ~= nil and rangesq or nil
end

function FindClosestPlayerToInstOnLand(inst, range, isalive)
    local x, y, z = inst.Transform:GetWorldPosition()
    return FindClosestPlayerOnLandInRangeSq(x, y, z, range * range, isalive)
end

function FindPlayersInRangeSq(x, y, z, rangesq, isalive)
    local players = {}
    for i, v in ipairs(AllPlayers) do
        if (isalive == nil or isalive ~= IsEntityDeadOrGhost(v)) and
            v.entity:IsVisible() and
            v:GetDistanceSqToPoint(x, y, z) < rangesq then
            table.insert(players, v)
        end
    end
    return players
end

function FindPlayersInRange(x, y, z, range, isalive)
    return FindPlayersInRangeSq(x, y, z, range * range, isalive)
end

function IsAnyPlayerInRangeSq(x, y, z, rangesq, isalive)
    for i, v in ipairs(AllPlayers) do
        if (isalive == nil or isalive ~= IsEntityDeadOrGhost(v)) and
            v.entity:IsVisible() and
            v:GetDistanceSqToPoint(x, y, z) < rangesq then
            return true
        end
    end
    return false
end

function IsAnyPlayerInRange(x, y, z, range, isalive)
    return IsAnyPlayerInRangeSq(x, y, z, range * range, isalive)
end

function IsAnyOtherPlayerNearInst(inst, rangesq, isalive)
    local x, y, z = inst.Transform:GetWorldPosition()
    for i, v in ipairs(AllPlayers) do
        if (isalive == nil or isalive ~= IsEntityDeadOrGhost(v)) 
            and v.entity:IsVisible() 
            and v:GetDistanceSqToPoint(x, y, z) < rangesq 
            and v ~= inst then
            return true
        end
    end
    return false
end

-- Get a location where it's safe to spawn an item so it won't get lost in the ocean
function FindSafeSpawnLocation(x, y, z)
    local ent = x ~= nil and z ~= nil and FindClosestPlayer(x, y, z) or nil
    if ent ~= nil then
        return ent.Transform:GetWorldPosition()
    elseif TheWorld.components.playerspawner ~= nil then
        -- we still don't have an enity, find a spawnpoint. That must be in a safe location
        return TheWorld.components.playerspawner:GetAnySpawnPoint()
    else
        -- if everything failed, return origin
        return 0, 0, 0
    end
end

function FindNearbyLand(position, range)
    local finaloffset = FindValidPositionByFan(math.random() * 2 * PI, range or 8, 8, function(offset)
        local x, z = position.x + offset.x, position.z + offset.z
        return TheWorld.Map:IsAboveGroundAtPoint(x, 0, z)
            and not TheWorld.Map:IsPointNearHole(Vector3(x, 0, z))
    end)
    if finaloffset ~= nil then
        finaloffset.x = finaloffset.x + position.x
        finaloffset.z = finaloffset.z + position.z
        return finaloffset
    end
end

function FindNearbyOcean(position, range)
    local finaloffset = FindValidPositionByFan(math.random() * 2 * PI, range or 8, 8, function(offset)
        local x, z = position.x + offset.x, position.z + offset.z
        return TheWorld.Map:IsOceanAtPoint(x, 0, z)
            and not TheWorld.Map:IsPointNearHole(Vector3(x, 0, z))
    end)
    if finaloffset ~= nil then
        finaloffset.x = finaloffset.x + position.x
        finaloffset.z = finaloffset.z + position.z
        return finaloffset
    end
end

function GetRandomInstWithTag(tag, inst, radius)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, radius, type(tag) == "string" and { tag } or tag)
    return #ents > 0 and ents[math.random(1, #ents)] or nil
end

function GetClosestInstWithTag(tag, inst, radius)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, radius, type(tag) == "string" and { tag } or tag)
    return ents[1] ~= inst and ents[1] or ents[2]
end

function DeleteCloseEntsWithTag(tag, inst, radius)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, radius, type(tag) == "string" and { tag } or tag)
    for i, v in ipairs(ents) do
        v:Remove()
    end
end

function AnimateUIScale(item, total_time, start_scale, end_scale)
    item:StartThread(function()
        local scale = 1
        local time_left = total_time
        local start_time = GetTime()
        local end_time = start_time + total_time
        local transform = item.UITransform
        while true do
            local t = GetTime()
            local percent = (t - start_time) / total_time
            if percent > 1 then
                transform:SetScale(end_scale, end_scale, end_scale)
                return
            end
            local scale = (1 - percent) * start_scale + percent * end_scale
            transform:SetScale(scale, scale, scale)
            Yield()
        end
    end)
end

function ShakeAllCameras(mode, duration, speed, scale, source_or_pt, maxDist)
    for i, v in ipairs(AllPlayers) do
        v:ShakeCamera(mode, duration, speed, scale, source_or_pt, maxDist)
    end
end

function ShakeAllCamerasOnPlatform(mode, duration, speed, scale, platform)
    local walkableplatform = platform and platform.components.walkableplatform or nil
	if walkableplatform == nil then return end

    for k in pairs(walkableplatform:GetPlayersOnPlatform()) do
        k:ShakeCamera(mode, duration, speed, scale)
    end
end

-- Use this function to fan out a search for a point that meets a condition.
-- If your condition is basically "walkable ground" use FindWalkableOffset instead.
-- test_fn takes a parameter "offset" which is check_angle*radius.
function FindValidPositionByFan(start_angle, radius, attempts, test_fn)
    attempts = attempts or 8

    local TWOPI = 2 * PI
    local attempt_angle = TWOPI / attempts
    local tmp_angles = {}
    for i = 0, attempts - 1 do
        local a = i * attempt_angle
        table.insert(tmp_angles, a > PI and a - TWOPI or a)
    end

    -- Make the angles fan out from the original point
    local angles = {}
    local iend = math.floor(attempts / 2)
    for i = 1, iend do
        table.insert(angles, tmp_angles[i])
        table.insert(angles, tmp_angles[attempts - i + 1])
    end
    if iend * 2 < attempts then
        table.insert(angles, tmp_angles[iend + 1])
    end

    for i, v in ipairs(angles) do
        local check_angle = start_angle + v
        if check_angle > TWOPI then
            check_angle = check_angle - TWOPI
        end
        local offset = Vector3(radius * math.cos(check_angle), 0, -radius * math.sin(check_angle))
        if test_fn(offset) then
            return offset, check_angle, i > 1 --deflected if not first try
        end
    end
end

-- This function fans out a search from a starting position/direction and looks for a walkable
-- position, and returns the valid offset, valid angle and whether the original angle was obstructed.
-- start_angle is in radians
function FindWalkableOffset(position, start_angle, radius, attempts, check_los, ignore_walls, customcheckfn, allow_water, allow_boats)
    return FindValidPositionByFan(start_angle, radius, attempts,
            function(offset)
                local x = position.x + offset.x
                local y = position.y + offset.y
                local z = position.z + offset.z
                return (TheWorld.Map:IsAboveGroundAtPoint(x, y, z, allow_water) or (allow_boats and TheWorld.Map:GetPlatformAtPoint(x,z) ~= nil))
                    and (not check_los or
                        TheWorld.Pathfinder:IsClear(
                            position.x, position.y, position.z,
                            x, y, z,
                            { ignorewalls = ignore_walls ~= false, ignorecreep = true, allowocean = allow_water }))
                    and (customcheckfn == nil or customcheckfn(Vector3(x, y, z)))
            end)
end

-- like FindWalkableOffset but only in the ocean
function FindSwimmableOffset(position, start_angle, radius, attempts, check_los, ignore_walls, customcheckfn, allow_boats)
    return FindValidPositionByFan(start_angle, radius, attempts,
            function(offset)
                local x = position.x + offset.x
                local y = position.y + offset.y
                local z = position.z + offset.z
                return TheWorld.Map:IsOceanTileAtPoint(x, y, z)                             -- Location is in the ocean tile range
                    and not TheWorld.Map:IsVisualGroundAtPoint(x, y, z)                     -- Location is NOT in the world overhang space
                    and (allow_boats or TheWorld.Map:GetPlatformAtPoint(x, z) == nil)  -- The location either accepts boats, or is not the location of a boat
                    and (not check_los or
                        TheWorld.Pathfinder:IsClear(
                            position.x, position.y, position.z,
                            x, y, z,
                            { ignorewalls = ignore_walls ~= false, ignorecreep = true, allowocean = true, ignoreLand = true }))
                    and (customcheckfn == nil or customcheckfn(Vector3(x, y, z)))
            end)
end

local function _CanEntitySeeInDark(inst)
    if inst.components.playervision ~= nil then
        --component available on clients as well,
        --but only accurate for your local player
        return inst.components.playervision:HasNightVision()
    end
    local inventory = inst.replica.inventory
    return inventory ~= nil and inventory:EquipHasTag("nightvision")
end

function CanEntitySeeInDark(inst)
    return inst ~= nil and inst:IsValid() and _CanEntitySeeInDark(inst)
end

local function _CanEntitySeeInStorm(inst)
    if inst.components.playervision ~= nil then
        --component available on clients as well,
        --but only accurate for your local player
        return inst.components.playervision:HasGoggleVision()
    end
    local inventory = inst.replica.inventory
    return inventory ~= nil and inventory:EquipHasTag("goggles")
end

function CanEntitySeeInStorm(inst)
    return inst ~= nil and inst:IsValid() and _CanEntitySeeInStorm(inst)
end

local function _GetEntityStormLevel(inst)
    --NOTE: GetStormLevel is available on players on server
    --      and clients, but only accurate for local players.
    --      stormwatcher is a server-side component.
    return (inst.GetStormLevel ~= nil and inst:GetStormLevel())
        or (inst.components.stormwatcher ~= nil and inst.components.stormwatcher.sandstormlevel)
        or 0
end

function CanEntitySeePoint(inst, x, y, z)
    return inst ~= nil
        and inst:IsValid()
        and (not inst.components.inkable or not inst.components.inkable.inked)
        and (TheSim:GetLightAtPoint(x, y, z) > TUNING.DARK_CUTOFF or
            _CanEntitySeeInDark(inst))
        and (_GetEntityStormLevel(inst) < TUNING.SANDSTORM_FULL_LEVEL or
            _CanEntitySeeInStorm(inst) or
            inst:GetDistanceSqToPoint(x, y, z) < TUNING.SANDSTORM_VISION_RANGE_SQ)
end

function CanEntitySeeTarget(inst, target)
    if target == nil or not target:IsValid() then
        return false
    end
    local x, y, z = target.Transform:GetWorldPosition()
    return CanEntitySeePoint(inst, x, y, z)
end

function SpringCombatMod(amount)
    return TheWorld.state.isspring and amount * TUNING.SPRING_COMBAT_MOD or amount
end

function TemporarilyRemovePhysics(obj, time)
    local origmask = obj.Physics:GetCollisionMask()
    obj.Physics:ClearCollisionMask()
    obj.Physics:CollidesWith(COLLISION.WORLD)
    obj:DoTaskInTime(time, function(obj)
        obj.Physics:ClearCollisionMask()
        obj.Physics:SetCollisionMask(origmask)
    end)
end

function ErodeAway(inst, erode_time)
    local time_to_erode = erode_time or 1
    local tick_time = TheSim:GetTickTime()

    if inst.DynamicShadow ~= nil then
        inst.DynamicShadow:Enable(false)
    end

    inst:StartThread(function()
        local ticks = 0
        while ticks * tick_time < time_to_erode do
            local erode_amount = ticks * tick_time / time_to_erode
            inst.AnimState:SetErosionParams(erode_amount, 0.1, 1.0)
            ticks = ticks + 1
            Yield()
        end
        inst:Remove()
    end)
end

function ErodeCB(inst, erode_time, cb, restore)
    local time_to_erode = erode_time or 1
    local tick_time = TheSim:GetTickTime()

    if inst.DynamicShadow ~= nil then
        inst.DynamicShadow:Enable(false)
    end

    inst:StartThread(function()
        local ticks = 0
        while ticks * tick_time < time_to_erode do
            local erode_amount = ticks * tick_time / time_to_erode
            inst.AnimState:SetErosionParams(erode_amount, 0.1, 1.0)
            ticks = ticks + 1
            Yield()
        end
		if restore then
            inst.AnimState:SetErosionParams(0, 0, 0)
		end
        if cb ~= nil then
			cb(inst)
		end
    end)
end

local function ApplyEvent(event)
    for k, v in pairs(SPECIAL_EVENTS) do
        if v == event and v ~= SPECIAL_EVENTS.NONE then
            local tech = TECH[k]
            if tech ~= nil then
                tech.SCIENCE = 0
            end
        end
    end
end

function ApplySpecialEvent(event)
    if event == nil then
        return
    end

    if event ~= "default" then
        WORLD_SPECIAL_EVENT = event
        print("Overriding World Event to: " .. tostring(event))
    end

    --LOST tech level when event is not active
    ApplyEvent(WORLD_SPECIAL_EVENT)
end

function ApplyExtraEvent(event)
    if event == nil or event == "default" or event == SPECIAL_EVENTS.NONE then
        return
    end

    WORLD_EXTRA_EVENTS[event] = true
    print("Adding extra World Event: " .. tostring(event))

    --LOST tech level when event is not active
    ApplyEvent(event)
end

local inventoryItemAtlasLookup = {}

function RegisterInventoryItemAtlas(atlas, imagename)
	if atlas ~= nil and imagename ~= nil then
		if inventoryItemAtlasLookup[imagename] ~= nil then
			if inventoryItemAtlasLookup[imagename] ~= atlas then
				print("RegisterInventoryItemAtlas: Image '" .. imagename .. "' is already registered to atlas '" .. atlas .."'")
			end
		else
			inventoryItemAtlasLookup[imagename] = atlas
		end
	end
end

function GetInventoryItemAtlas(imagename, no_fallback)
	local atlas = inventoryItemAtlasLookup[imagename]
	if atlas then
		return atlas
	end
	local base_atlas = "images/inventoryimages1.xml"
	local alt_atlas = "images/inventoryimages2.xml"
	atlas = TheSim:AtlasContains(base_atlas, imagename) and base_atlas
			or (not no_fallback or TheSim:AtlasContains(alt_atlas, imagename)) and alt_atlas
			or nil
	if atlas ~= nil then
		inventoryItemAtlasLookup[imagename] = atlas
	end
	return atlas
end
