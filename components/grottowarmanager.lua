--------------------------------------------------------------------------
--[[ grottowarmanager class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "GrottoWarManager should not exist on client")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local POP_CHANGE_INTERVAL = 10
local POP_CHANGE_VARIANCE = 2
local SPAWN_INTERVAL = 2
local SPAWN_VARIANCE = 4
local NON_INSANITY_MODE_DESPAWN_INTERVAL = 0.1
local NON_INSANITY_MODE_DESPAWN_VARIANCE = 0.1

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _map = TheWorld.Map
local _enabled = false
local _players = {}
local _activeplayers = {}
local _poptask = nil

local _retrofitted_spawnpoints = nil -- used for retrofitted worlds
local _retrofitted_homepoint = nil

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local BRIGHTMARE_TAGS = {"brightmare_guard"}
local NIGHTMARE_TAGS = {"shadow"}

local function RemoveMare(ent)
	--print("    - RemoveMare", ent)
    ent:DoTaskInTime(0, ent.Remove)
end

local function SpawnMare(prefab, x, z, attack_target)
    local ent = SpawnPrefab(prefab)
    ent.Transform:SetPosition(x, 0, z)
	ent.persists = false
	ent:ListenForEvent("entitysleep", RemoveMare)
	--print("    + SpawnMare ", ent)

	if attack_target ~= nil then
		ent.components.combat:SetTarget(attack_target)
	end
end

local CLEAR_SPAWN_POINT_ONEOF_TAGS = {"brightmare", "player", "playerghost", "shadow"}
local function IsValidSpawnPt(pt)
	return #TheSim:FindEntities(pt.x, 0, pt.z, 3, nil, nil, CLEAR_SPAWN_POINT_ONEOF_TAGS) == 0
			and not _map:IsPointNearHole(pt)
end

local function SpawnNightmareForPlayer(player, pt)
	local theta = player.components.locomotor.isrunning and (player.Transform:GetRotation()*DEGREES + math.random()*PI - 0.5*PI) or (math.random() * 2 * PI)

	local offset = FindWalkableOffset(pt, theta, 28 - 5*math.random(), 22, true, true, IsValidSpawnPt)
				or FindWalkableOffset(pt, theta, 23 - 5*math.random(), 16, true, true, IsValidSpawnPt)
				or FindWalkableOffset(pt, theta, 15 - 5*math.random(), 16, false, true, IsValidSpawnPt)

	if offset ~= nil then
		SpawnMare("nightmarebeak", offset.x + pt.x, offset.z + pt.z, math.random() < TUNING.GROTTOWAR_NIGHTMARE_TARGET_PLAYER_CHANCE and player or nil)
	end
end


local function SpawnBrightmareForPlayer(player, pt, target)
	local theta = player.components.locomotor.isrunning and (player.Transform:GetRotation()*DEGREES + math.random()*PI - 0.5*PI) or (math.random() * 2 * PI)

	local offset = FindWalkableOffset(pt, theta, 15 - 8*math.random(), 16, true, true, IsValidSpawnPt)
				or FindWalkableOffset(pt, theta, 10 - 5*math.random(), 16, true, true, IsValidSpawnPt)
				or FindWalkableOffset(pt, theta, 10 - 5*math.random(), 16, false, true, IsValidSpawnPt)

	if offset ~= nil then
		SpawnMare("gestalt_guard", offset.x + pt.x, offset.z + pt.z, target)
	end
end

local function UpdatePopulation()
	for player, _ in pairs(_players) do
		local x, _, z = player.Transform:GetWorldPosition()
		local num_brightmares = #TheSim:FindEntities(x, 0, z, TUNING.GROTTOWAR_POPULATION_DIST, BRIGHTMARE_TAGS)
		local nightmares = TheSim:FindEntities(x, 0, z, TUNING.GROTTOWAR_POPULATION_DIST, NIGHTMARE_TAGS)
		local num_nightmares = #nightmares

		local nightmare_chance = (1 - (num_nightmares / TUNING.GROTTOWAR_MAX_NIGHTMARES)) * 0.15
		local brightmare_chance = num_brightmares < (num_nightmares * TUNING.GROTTOWAR_NUM_BRIGHTMARES_PRE_NIGHTMARE) and 1
								or num_brightmares < TUNING.GROTTOWAR_NUM_AMBIENT_BRIGHTMARES and .8
								or 0

		-- TODO: optimize function calls above into the else statement below when this print is removed
		--print("Count: " .. num_brightmares .. ", " .. num_nightmares, " Chance: " .. brightmare_chance ..", " .. nightmare_chance)

		if nightmare_chance >= 1 or (nightmare_chance > 0 and math.random() < nightmare_chance) then
			SpawnNightmareForPlayer(player, Vector3(x, 0, z))
		else
			if brightmare_chance >= 1 or (brightmare_chance > 0 and math.random() < brightmare_chance) then
				SpawnBrightmareForPlayer(player, Vector3(x, 0, z), nightmares[1])
			end
		end
	end
end

local function TryStart()
    if _enabled and _poptask == nil and next(_players) ~= nil then
        _poptask = inst:DoPeriodicTask(1.57, UpdatePopulation)
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
function self:RetrofittedSpawnFrontLines()
	if _retrofitted_spawnpoints ~= nil and _retrofitted_homepoint ~= nil and _retrofitted_homepoint:IsValid() then
		local count = math.random(3)
		for spawner, _ in pairs(_retrofitted_spawnpoints) do
			if spawner:IsValid() then
				local x, y, z = spawner.Transform:GetWorldPosition()
				spawner:Remove()

				count = count + 1
				local prefab = (count % 3 == 0 or count % 3 == 1 and math.random() < 0.5) and "nightmaregrowth_spawner" or "fissure_grottowar"
				local obj = SpawnPrefab(prefab)
				obj.Transform:SetPosition(x, y, z)
				if obj.components.knownlocations ~= nil then
					obj.components.knownlocations:RememberLocation("war_home", _retrofitted_homepoint:GetPosition())
				end

				if obj.OnSpawnedForWar ~= nil then
					obj:OnSpawnedForWar()
				end

				--SpawnPrefab("statue_transition_2").Transform:SetPosition(x, y, z)
				SpawnPrefab("statue_transition").Transform:SetPosition(x, y, z)

				LaunchAndClearArea(obj, 2, 0.5, 0.5, .2, 2)
				--SpawnPrefab("collapse_small").Transform:SetPosition(x, y, z)
			end
		end

		local pt3 = _retrofitted_homepoint:GetPosition()
		SpawnPrefab("grotto_war_sfx").Transform:SetPosition(pt3.x,pt3.y,pt3.z)

		_retrofitted_homepoint:Remove()
		_retrofitted_homepoint = nil
		_retrofitted_spawnpoints = nil

		return true
	end

	return false
end

function self:SpawnFrontLines()
	if self:RetrofittedSpawnFrontLines() then
		return
	end

	-- this is only public to allow modders access to it
	local node, node_index

	for i = #TheWorld.topology.nodes, 1, -1 do -- iterating backwards only because retrofitted worlds don't properly fix up the topology mesh
		local n = TheWorld.topology.nodes[i]
        if table.contains(n.tags, "GrottoWarEntrance") then
			node_index = i
			node = n
			break
		end
	end

	if node == nil then
		print("Warning, could not find node with tag GrottoWarEntrance.")
		return
	end

	local spacing = 7
	local offset_min = 8
	local noise_r = 5

	local world_topology = TheWorld.topology
	local story_depth = world_topology.story_depths[node_index]
	local center = Vector3(node.cent[1], 0, node.cent[2])

	local function NoHoles(pt)
		return not TheWorld.Map:IsPointNearHole(pt)
	end

	local function dospawn(prefab, p1, p2, percent, dir)
		local pt = p1 + (p2-p1) * percent + dir*(offset_min)
		local offset = FindWalkableOffset(pt, math.random()*2*PI, math.random()*noise_r, 8, true, true, NoHoles)
		if offset ~= nil then
			pt = pt + offset

			local obj = SpawnPrefab(prefab)
			obj.Transform:SetPosition(pt:Get())
			if obj.components.knownlocations ~= nil then
				obj.components.knownlocations:RememberLocation("war_home", center)
			end
			obj:AddTag("grotto_war_wall")

			if obj.OnSpawnedForWar ~= nil then
				obj:OnSpawnedForWar()
			end

			--SpawnPrefab("statue_transition_2").Transform:SetPosition(pt:Get())
		    SpawnPrefab("statue_transition").Transform:SetPosition(pt:Get())

			LaunchAndClearArea(obj, 2, 0.5, 0.5, .2, 2)
			--SpawnPrefab("collapse_small").Transform:SetPosition(pt:Get())
		end
	end

	local flattenedEdges = world_topology.flattenedEdges
	local flattenedPoints = world_topology.flattenedPoints
	local node_edges = world_topology.nodes[node_index].validedges
	for _, edge_index in ipairs(node_edges) do
		local edge_nodes = world_topology.edgeToNodes[edge_index]
		local neighbour_index = edge_nodes[1] ~= node_index and edge_nodes[1] or edge_nodes[2]
		if world_topology.story_depths[neighbour_index] ~= story_depth then
			local edge = flattenedEdges[edge_index]

			local pt1 = Vector3(flattenedPoints[edge[1]][1], 0, flattenedPoints[edge[1]][2])
			local pt2 = Vector3(flattenedPoints[edge[2]][1], 0, flattenedPoints[edge[2]][2])

			local vert = pt1 - pt2
			local length = vert:Length()
			vert = vert/length
			local to_cent = center - pt2
			local dir = (vert * (vert:Dot(to_cent)) - to_cent):GetNormalized()

			local num_steps = math.floor(length / spacing)
			if num_steps <= 1 then
				-- do one fissure at .5
				dospawn("fissure_grottowar", pt1, pt2, 0.5, dir)
			elseif num_steps == 2 then
				dospawn("fissure_grottowar", pt1, pt2, 1/3, dir)
				dospawn("nightmaregrowth_spawner", pt1, pt2, 2/3, dir)
			else
				for i = 1, num_steps - 1 do
					local prefab = i%2 == 0 and "fissure_grottowar" or math.random() < 0.66 and "nightmaregrowth_spawner" or "fissure_grottowar"
					dospawn(prefab, pt1, pt2, i/num_steps, dir)
				end
			end

			local pt3 = (pt1+pt2)/2
			SpawnPrefab("grotto_war_sfx").Transform:SetPosition(pt3.x,pt3.y,pt3.z)

		end
	end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------
local GROTTO_WAR_WALL_HAS_TAGS = {"grotto_war_wall"}
local function StartTheWar()
	if not _enabled then
		self:SpawnFrontLines()
		TheWorld:PushEvent("ms_setnightmarephase", "wild")
		self.inst:DoTaskInTime(5,function()
			ShakeAllCameras(CAMERASHAKE.FULL, 10, .02, .2, nil, 40)
		end)
	end

    _enabled = true
	if next(_players) ~= nil then
		TryStart()
	end
end

local function OnPlayerAreaChanced(player, data)
	if data ~= nil and data.tags ~= nil and table.contains(data.tags, "lunacyarea") then
		_players[player] = true
		TryStart()
	else
		_players[player] = nil
		if next(_players) == nil then
			Stop()
		end
	end
end

local function OnPlayerJoined(inst, player)
    inst:ListenForEvent("changearea", OnPlayerAreaChanced, player)
	OnPlayerAreaChanced(player, player.components.areaaware:GetCurrentArea())

	for i, v in ipairs(_activeplayers) do
        if v == player then
            return
        end
    end
    table.insert(_activeplayers, player)
end

local function OnPlayerLeft(inst, player)
    inst:RemoveEventCallback("changearea", OnPlayerAreaChanced, player)
	OnPlayerAreaChanced(player, nil)

    for i, v in ipairs(_activeplayers) do
        if v == player then
            table.remove(_activeplayers, i)
            return
        end
    end
end

local function OnNightmarePhaseChanged(inst, phase)
	-- TODO: nightmare phase should make the war more intence
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
inst:ListenForEvent("nightmarephasechanged", OnNightmarePhaseChanged)
inst:ListenForEvent("ms_archivesbreached", StartTheWar)

inst:ListenForEvent("ms_register_retrofitted_grotterwar_spawnpoint", function(i, data) if _retrofitted_spawnpoints == nil then _retrofitted_spawnpoints = {} end _retrofitted_spawnpoints[data.inst] = true end)
inst:ListenForEvent("ms_register_retrofitted_grotterwar_homepoint", function(i, data) _retrofitted_homepoint = data.inst end)

function self:IsWarStarted()
	return _enabled
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
	return
	{
		_enabled2 = _enabled,	-- enabled2: I had to rename this to reset the war due to a bug in the beta
	}
end

function self:OnLoad(data)
	if data._enabled2 then
		_enabled = true
	end
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    return tostring(GetTableSize(_players)) .. " players"
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)