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

function FindClosestEntity(inst, radius, ignoreheight, musttags, canttags, mustoneoftags, fn)
    if inst ~= nil and inst:IsValid() then
        local x, y, z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, ignoreheight and 0 or y, z, radius, musttags, canttags, mustoneoftags)
        local closestEntity = nil
        local rangesq = radius * radius
        for i, v in ipairs(ents) do
            if v ~= inst and (not IsEntityDeadOrGhost(v)) and v.entity:IsVisible() and (fn == nil or fn(v, inst)) then
                local distsq = v:GetDistanceSqToPoint(x, y, z)
                if distsq < rangesq then
                    rangesq = distsq
                    closestEntity = v
                end
            end
        end
        return closestEntity, closestEntity ~= nil and rangesq or nil
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
    local finaloffset = FindValidPositionByFan(math.random() * TWOPI, range or 8, 8, function(offset)
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
    local finaloffset = FindValidPositionByFan(math.random() * TWOPI, range or 8, 8, function(offset)
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
    return (#ents > 0 and ents[math.random(1, #ents)]) or nil
end

function GetClosestInstWithTag(tag, inst, radius)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, radius, type(tag) == "string" and { tag } or tag)
    return ents[1] ~= inst and ents[1] or ents[2]
end

function DeleteCloseEntsWithTag(tag, inst, radius)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, radius, type(tag) == "string" and { tag } or tag)
    for _, ent in ipairs(ents) do
        ent:Remove()
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

local NO_CHARLIE_TAGS = {"lunacyarea"}
function FindCharlieRezSpotFor(inst)
    local x, y, z
    local nightlightmanager = TheWorld.components.nightlightmanager
    if nightlightmanager ~= nil then
        local nightlights = nightlightmanager:GetNightLightsWithFilter(nightlightmanager.Filter_OnlyOutTags, NO_CHARLIE_TAGS)
        local nightlight = nightlightmanager:FindClosestNightLightFromListToInst(nightlights, inst)
        if nightlight ~= nil then
            local theta = math.random() * PI2
            x, y, z = nightlight.Transform:GetWorldPosition()
            local radius = nightlight:GetPhysicsRadius(0) + 1
            local offset = FindWalkableOffset(Vector3(x, y, z), theta, radius, 8, false, false, nil, false, false)
            if offset then
                x, z = x + offset.x, z + offset.z
            else
                x, z = x + radius * math.cos(theta), z + radius * math.sin(theta)
            end
        end
    end
    if x == nil then
        if inst.components.drownable ~= nil then
            x, y, z = inst.components.drownable:GetWashingAshoreTeleportSpot(true)
        else
            x, y, z = inst.Transform:GetWorldPosition() -- We tried.
        end
    end
    return x, y, z
end

local PICKUP_MUST_ONEOF_TAGS = { "_inventoryitem", "pickable" }
local PICKUP_CANT_TAGS = {
    -- Items
    "INLIMBO", "NOCLICK", "irreplaceable", "knockbackdelayinteraction", "event_trigger",
    "minesprung", "mineactive", "catchable",
    "fire", "light", "spider", "cursed", "paired", "bundle",
    "heatrock", "deploykititem", "boatbuilder", "singingshell",
    "archive_lockbox", "simplebook", "furnituredecor",
    -- Pickables
    "flower", "gemsocket", "structure",
    -- Either
    "donotautopick",
}
local function FindPickupableItem_filter(v, ba, owner, radius, furthestfirst, positionoverride, ignorethese, onlytheseprefabs, allowpickables, ispickable, worker, extra_filter)
    if extra_filter ~= nil and not extra_filter(worker, v, owner) then
        return false
    end
    
    if AllBuilderTaggedRecipes[v.prefab] then
        return false
    end
    -- NOTES(JBK): "donotautopick" for general class components here.
    if v.components.armor or v.components.weapon or v.components.tool or v.components.equippable or v.components.sewing or v.components.erasablepaper then
        return false
    end
    if v.components.burnable ~= nil and (v.components.burnable:IsBurning() or v.components.burnable:IsSmoldering()) then
        return false
    end
    if ispickable then
        if not allowpickables then
            return false
        end
    else
        if not (v.components.inventoryitem ~= nil and
            v.components.inventoryitem.canbepickedup and
            v.components.inventoryitem.cangoincontainer and
            not v.components.inventoryitem:IsHeld()) then
            return false
        end
    end
    if ignorethese ~= nil and ignorethese[v] ~= nil and ignorethese[v].worker ~= worker then
        return false
    end
    if onlytheseprefabs ~= nil and onlytheseprefabs[ispickable and v.components.pickable.product or v.prefab] == nil then
        return false
    end
    if v.components.container ~= nil then -- Containers are most likely sorted and placed by the player do not pick them up.
        return false
    end
    if v.components.bundlemaker ~= nil then -- Bundle creators are aesthetically placed do not pick them up.
        return false
    end
    if v.components.bait ~= nil and v.components.bait.trap ~= nil then -- Do not steal baits.
        return false
    end
    if v.components.trap ~= nil and not (v.components.trap:IsSprung() and v.components.trap:HasLoot()) then -- Only interact with traps that have something in it to take.
        return false
    end
    if not ispickable and owner.components.inventory:CanAcceptCount(v, 1) <= 0 then -- TODO(JBK): This is not correct for traps nor pickables but they do not have real prefabs made yet to check against.
        return false
    end
    if ba ~= nil and ba.target == v and (ba.action == ACTIONS.PICKUP or ba.action == ACTIONS.CHECKTRAP or ba.action == ACTIONS.PICK) then
        return false
    end

    return v, ispickable
end
-- This function looks for an item on the ground that could be ACTIONS.PICKUP (or ACTIONS.CHECKTRAP if a trap) by the owner and subsequently put into the owner's inventory.
function FindPickupableItem(owner, radius, furthestfirst, positionoverride, ignorethese, onlytheseprefabs, allowpickables, worker, extra_filter)
    if owner == nil or owner.components.inventory == nil then
        return nil
    end
    local ba = owner:GetBufferedAction()
    local x, y, z
    if positionoverride then
        x, y, z = positionoverride:Get()
    else
        x, y, z = owner.Transform:GetWorldPosition()
    end
    local ents = TheSim:FindEntities(x, y, z, radius, nil, PICKUP_CANT_TAGS, PICKUP_MUST_ONEOF_TAGS)
    local istart, iend, idiff = 1, #ents, 1
    if furthestfirst then
        istart, iend, idiff = iend, istart, -1
    end
    for i = istart, iend, idiff do
        local v = ents[i]
        local ispickable = v:HasTag("pickable")
        if FindPickupableItem_filter(v, ba, owner, radius, furthestfirst, positionoverride, ignorethese, onlytheseprefabs, allowpickables, ispickable, worker, extra_filter) then
            return v, ispickable
        end
    end
    return nil, nil
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

local function _IsEntityInAnyStormOrCloud(inst)
	--NOTE: IsInAnyStormOrCloud is available on players on server and clients, but only accurate for local players.
	if inst.IsInAnyStormOrCloud ~= nil then
		return inst:IsInAnyStormOrCloud()
	end
	-- stormwatcher and miasmawatcher are a server-side components.
	return (inst.components.stormwatcher ~= nil and inst.components.stormwatcher:GetStormLevel() >= TUNING.SANDSTORM_FULL_LEVEL)
		or (inst.components.miasmawatcher ~= nil and inst.components.miasmawatcher:IsInMiasma())
end

function CanEntitySeePoint(inst, x, y, z)
    return inst ~= nil
        and inst:IsValid()
        and (not inst.components.inkable or not inst.components.inkable.inked)
        and (TheSim:GetLightAtPoint(x, y, z) > TUNING.DARK_CUTOFF or
            _CanEntitySeeInDark(inst))
		and (not _IsEntityInAnyStormOrCloud(inst) or
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

function SpringCombatMod(amount, forced) -- NOTES(JBK): This is an amplification modifier to increase damage.
    return (forced or TheWorld.state.isspring) and amount * TUNING.SPRING_COMBAT_MOD or amount
end
function SpringGrowthMod(amount, forced) -- NOTES(JBK): This is a reduction modifier to reduce timer durations.
    return (forced or TheWorld.state.isspring) and amount * TUNING.SPRING_GROWTH_MODIFIER or amount
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
    if inst.components.floater ~= nil then
        inst.components.floater:Erode(time_to_erode)
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

function GetInventoryItemAtlas_Internal(imagename, no_fallback)
    local images1 = "images/inventoryimages1.xml"
    local images2 = "images/inventoryimages2.xml"
    local images3 = "images/inventoryimages3.xml"
    return TheSim:AtlasContains(images1, imagename) and images1
            or TheSim:AtlasContains(images2, imagename) and images2
            or (not no_fallback or TheSim:AtlasContains(images3, imagename)) and images3
            or nil
end

-- Testing and viewing skins on a more close level.
if CAN_USE_DBUI then
    require("dbui_no_package/debug_skins_data/hooks").Hooks("inventoryimages")
end

function GetInventoryItemAtlas(imagename, no_fallback)
	local atlas = inventoryItemAtlasLookup[imagename]
	if atlas then
		return atlas
	end

    atlas = GetInventoryItemAtlas_Internal(imagename, no_fallback)

	if atlas ~= nil then
		inventoryItemAtlasLookup[imagename] = atlas
	end
	return atlas
end

----------------------------------------------------------------------------------------------
function GetMinimapAtlas_Internal(imagename)
    local images1 = "minimap/minimap_data1.xml"
    local images2 = "minimap/minimap_data2.xml"
    return TheSim:AtlasContains(images1, imagename) and images1
            or TheSim:AtlasContains(images2, imagename) and images2
            or nil
end

local minimapAtlasLookup = {}
function GetMinimapAtlas(imagename)
	local atlas = minimapAtlasLookup[imagename]
	if atlas then
		return atlas
	end

    atlas = GetMinimapAtlas_Internal(imagename)

	if atlas ~= nil then
		minimapAtlasLookup[imagename] = atlas
	end

	return atlas
end

----------------------------------------------------------------------------------------------

local scrapbookIconAtlasLookup = {}

function RegisterScrapbookIconAtlas(atlas, imagename)
	if atlas ~= nil and imagename ~= nil then
		if scrapbookIconAtlasLookup[imagename] ~= nil then
			if scrapbookIconAtlasLookup[imagename] ~= atlas then
				print("RegisterScrapbookIconAtlas: Image '" .. imagename .. "' is already registered to atlas '" .. atlas .."'")
			end
		else
			scrapbookIconAtlasLookup[imagename] = atlas
		end
	end
end

function GetScrapbookIconAtlas_Internal(imagename)
    local images1 = "images/scrapbook_icons1.xml"
    local images2 = "images/scrapbook_icons2.xml"
    local images3 = "images/scrapbook_icons3.xml"
    return TheSim:AtlasContains(images1, imagename) and images1
            or TheSim:AtlasContains(images2, imagename) and images2
            or TheSim:AtlasContains(images3, imagename) and images3
            or nil
end

function GetScrapbookIconAtlas(imagename)
	local atlas = scrapbookIconAtlasLookup[imagename]
	if atlas then
		return atlas
	end

    atlas = GetScrapbookIconAtlas_Internal(imagename)

	if atlas ~= nil then
		scrapbookIconAtlasLookup[imagename] = atlas
	end

	return atlas
end

----------------------------------------------------------------------------------------------

local skillTreeBGAtlasLookup = {}

function RegisterSkilltreeBGAtlas(atlas, imagename)
	if atlas ~= nil and imagename ~= nil then
		if skillTreeBGAtlasLookup[imagename] ~= nil then
			if skillTreeBGAtlasLookup[imagename] ~= atlas then
				print("RegisterSkilltreeBGAtlas: Image '" .. imagename .. "' is already registered to atlas '" .. atlas .."'")
			end
		else
			skillTreeBGAtlasLookup[imagename] = atlas
		end
	end
end

function GetSkilltreeBG_Internal(imagename)
    local images1 = "images/skilltree2.xml"
    local images2 = "images/skilltree3.xml"
    local images3 = "images/skilltree4.xml"
    local images4 = "images/skilltree5.xml"
    return TheSim:AtlasContains(images1, imagename) and images1
            or TheSim:AtlasContains(images2, imagename) and images2
            or TheSim:AtlasContains(images3, imagename) and images3
            or TheSim:AtlasContains(images4, imagename) and images4
            or nil
end

function GetSkilltreeBG(imagename)
	local atlas = skillTreeBGAtlasLookup[imagename]
	if atlas then
		return atlas
	end

    atlas = GetSkilltreeBG_Internal(imagename)

	if atlas ~= nil then
		skillTreeBGAtlasLookup[imagename] = atlas
	end

	return atlas
end

local skillTreeIconsAtlasLookup = {}

function RegisterSkilltreeIconsAtlas(atlas, imagename)
	if atlas ~= nil and imagename ~= nil then
		if skillTreeIconsAtlasLookup[imagename] ~= nil then
			if skillTreeIconsAtlasLookup[imagename] ~= atlas then
				print("RegisterSkilltreeIconsAtlas: Image '" .. imagename .. "' is already registered to atlas '" .. atlas .."'")
			end
		else
			skillTreeIconsAtlasLookup[imagename] = atlas
		end
	end
end

function GetSkilltreeIconAtlas_Internal(imagename)
    return "images/skilltree_icons.xml"

    -- NOTES(DiogoW): For future!

    -- local images1 = "images/skilltree_icons1.xml"
    -- local images2 = "images/skilltree_icons2.xml"
    -- return TheSim:AtlasContains(images1, imagename) and images1
    --         or TheSim:AtlasContains(images2, imagename) and images2
    --         or nil
end

function GetSkilltreeIconAtlas(imagename)
	local atlas = skillTreeIconsAtlasLookup[imagename]
	if atlas then
		return atlas
	end

    atlas = GetSkilltreeIconAtlas_Internal(imagename)

	if atlas ~= nil then
		skillTreeIconsAtlasLookup[imagename] = atlas
	end

	return atlas
end

----------------------------------------------------------------------------------------------
