--------------------------------------------------------------------------
--[[ brightmarespawner class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "Brightmare spawner should not exist on client")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local POP_CHANGE_INTERVAL = 10
local POP_CHANGE_VARIANCE = 2

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _map = TheWorld.Map
local _players = {}
local _gestalts = {}
local _poptask = nil

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function GetTuningLevelForPlayer(player)
    local sanity = player.components.sanity:IsLunacyMode() and player.components.sanity:GetPercentWithPenalty() or 0
	if sanity >= TUNING.GESTALT_MIN_SANITY_TO_SPAWN then
		for k, v in ipairs(TUNING.GESTALT_POPULATION_LEVEL) do
			if sanity <= v.MAX_SANITY then
				return k, v
			end
		end
	end

	return 0, nil
end

local function IsValidTrackingTarget(target)
	return target.components.health ~= nil and not target.components.health:IsDead() and not target:HasTag("playerghost") and target.entity:IsVisible()
end

local function StopTracking(ent)
	_gestalts[ent] = nil
end

local SPAWN_ONEOF_TAGS = {"brightmare_gestalt", "player", "playerghost"}
local function FindGestaltSpawnPtForPlayer(player, wantstomorph)
	local x, y, z = player.Transform:GetWorldPosition()
	local function IsValidGestaltSpawnPt(offset)
		local x1, z1 = x + offset.x, z + offset.z
		return #TheSim:FindEntities(x1, 0, z1, 6, nil, nil, SPAWN_ONEOF_TAGS) == 0
	end
    local offset = FindValidPositionByFan(math.random() * TWOPI,
											(wantstomorph and TUNING.GESTALT_SPAWN_MORPH_DIST or TUNING.GESTALT_SPAWN_DIST) + math.random() * 2 * TUNING.GESTALT_SPAWN_DIST_VAR - TUNING.GESTALT_SPAWN_DIST_VAR,
											8,
											IsValidGestaltSpawnPt)
	if offset ~= nil then
		offset.x = offset.x + x
		offset.z = offset.z + z
	end

	return offset
end

local function TrySpawnGestaltForPlayer(player, level, data)
	local pt = FindGestaltSpawnPtForPlayer(player, false)
	if pt ~= nil then
        local ent = SpawnPrefab("gestalt")
		_gestalts[ent] = {}
		inst:ListenForEvent("onremove", StopTracking, ent)
        ent.Transform:SetPosition(pt.x, 0, pt.z)
		ent:SetTrackingTarget(player, GetTuningLevelForPlayer(player))
	end
end

local BRIGHTMARE_TAGS = {"brightmare"}
local function UpdatePopulation()
	local total_levels = 0
	for player, _ in pairs(_players) do
		if IsValidTrackingTarget(player) then
			local level, data = GetTuningLevelForPlayer(player)
			total_levels = total_levels + level

			if level > 0 then
				local x, y, z = player.Transform:GetWorldPosition()
				local gestalts = TheSim:FindEntities(x, y, z, TUNING.GESTALT_POPULATION_DIST, BRIGHTMARE_TAGS)
				local maxpop = data.MAX_SPAWNS
				local inc_chance = 0
				if level == 1 then
					if #gestalts < maxpop then
						inc_chance = .2
					end
				elseif level == 2 then
					if #gestalts < maxpop then
						inc_chance = .3
					end
				else -- level == 3
					if #gestalts < maxpop then
						inc_chance = .4
					end
				end

				if math.random() < inc_chance then
					TrySpawnGestaltForPlayer(player, level, data)
				end
			end

		end
	end

    _poptask = inst:DoTaskInTime(TUNING.GESTALT_POP_CHANGE_INTERVAL - math.min(total_levels, TUNING.GESTALT_POP_CHANGE_INTERVAL / 2) + TUNING.GESTALT_POP_CHANGE_VARIANCE * math.random(), UpdatePopulation)
end

local function Start()
    if _poptask == nil then
        _poptask = inst:DoTaskInTime(0, UpdatePopulation)
    end
end

local function Stop()
    if _poptask ~= nil then
        _poptask:Cancel()
        _poptask = nil
    end
end

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:FindBestPlayer(gestalt)
	local closest_player = nil
	local closest_distsq = TUNING.GESTALT_POPULATION_DIST * TUNING.GESTALT_POPULATION_DIST
	local closest_level = 0

	for player, _ in pairs(_players) do
        if IsValidTrackingTarget(player) then
			local x, y, z = player.Transform:GetWorldPosition()
            local distsq = gestalt:GetDistanceSqToPoint(x, y, z)
            if distsq < closest_distsq then
				local level, data = GetTuningLevelForPlayer(player)
				if level > 0 and #TheSim:FindEntities(x, y, z, TUNING.GESTALT_POPULATION_DIST, BRIGHTMARE_TAGS) <= (data.MAX_SPAWNS + 1) then
	                closest_distsq = distsq
		            closest_player = player
					closest_level = level
				end
            end
        end
	end

	return closest_player, closest_level
end

function self:FindRelocatePoint(gestalt)
	return gestalt.tracking_target ~= nil and FindGestaltSpawnPtForPlayer(gestalt.tracking_target, gestalt.wantstomorph) or nil
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnSanityModeChanged(player, data)
	if data ~= nil and data.mode == SANITY_MODE_LUNACY then
		_players[player] = {}
	else
		_players[player] = nil
	end

	if next(_players) ~= nil then
		Start()
	else
		Stop()
	end
end

local function OnPlayerJoined(inst, player)
    inst:ListenForEvent("sanitymodechanged", OnSanityModeChanged, player)
	if player.components.sanity:IsLunacyMode() then
		OnSanityModeChanged(player, {mode = player.components.sanity:GetSanityMode()})
	end
end

local function OnPlayerLeft(inst, player)
    inst:RemoveEventCallback("sanitymodechanged", OnSanityModeChanged, player)
	OnSanityModeChanged(player, nil)
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize variables
for i, v in ipairs(AllPlayers) do
    OnPlayerJoined(inst, v)
end

--Register events
inst:ListenForEvent("ms_playerjoined", OnPlayerJoined)
inst:ListenForEvent("ms_playerleft", OnPlayerLeft)

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    return tostring(GetTableSize(_gestalts)) .. " Gestalts"
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)