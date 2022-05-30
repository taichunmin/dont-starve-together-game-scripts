--------------------------------------------------------------------------
--[[ Hounded class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "Hounded should not exist on client")

--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------

local SourceModifierList = require("util/sourcemodifierlist")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local SPAWN_DIST = 30

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst
self.max_thieved_spawn_per_thief = 3

--Private
local _activeplayers = {}
local _targetableplayers = {}
local _warning = false
local _timetoattack = 0
local _warnduration = 30
local _attackplanned = false
local _timetonextwarningsound = 0
local _announcewarningsoundinterval = 4
local _pausesources = SourceModifierList(inst, false, SourceModifierList.boolean)

local _spawnwintervariant = true
local _spawnsummervariant = true

--Configure this data using hounded:SetSpawnData
local _spawndata =
	{
		base_prefab = "hound",
		winter_prefab = "icehound",
		summer_prefab = "firehound",
		upgrade_spawn = "warglet",

		attack_levels =
		{
			intro 	= { warnduration = function() return 120 end, numspawns = function() return 1 end },
			light 	= { warnduration = function() return 60 end, numspawns = function() return 2 + math.random(2) end },
			med 	= { warnduration = function() return 45 end, numspawns = function() return 3 + math.random(3) end },
			heavy 	= { warnduration = function() return 30 end, numspawns = function() return 4 + math.random(3) end },
			crazy 	= { warnduration = function() return 30 end, numspawns = function() return 6 + math.random(4) end },
		},

		--attack delays actually go from shorter to longer, to account for stronger waves
		--these names are describing the strength of the houndwave more than the duration
		attack_delays =
		{
			intro 		= function() return TUNING.TOTAL_DAY_TIME * 5, math.random() * TUNING.TOTAL_DAY_TIME * 3 end,
			light 		= function() return TUNING.TOTAL_DAY_TIME * 5, math.random() * TUNING.TOTAL_DAY_TIME * 5 end,
			med 		= function() return TUNING.TOTAL_DAY_TIME * 7, math.random() * TUNING.TOTAL_DAY_TIME * 5 end,
			heavy 		= function() return TUNING.TOTAL_DAY_TIME * 9, math.random() * TUNING.TOTAL_DAY_TIME * 5 end,
			crazy 		= function() return TUNING.TOTAL_DAY_TIME * 11, math.random() * TUNING.TOTAL_DAY_TIME * 5 end,
		},

		warning_speech = "ANNOUNCE_HOUNDS",
		warning_sound_thresholds =
		{	--Key = time, Value = sound prefab
			{time = 30, sound =  "LVL4"},
			{time = 60, sound =  "LVL3"},
			{time = 90, sound =  "LVL2"},
			{time = 500, sound = "LVL1"},
		},
	}

local _attackdelayfn = _spawndata.attack_delays.med
local _warndurationfn = _spawndata.attack_levels.light.warnduration
local _spawnmode = "escalating"
local _spawninfo = nil
--for players who leave during the warning when spawns are queued
local _delayedplayerspawninfo = {}
local _missingplayerspawninfo = {}

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function GetAveragePlayerAgeInDays()
    local sum = 0
    for i, v in ipairs(_activeplayers) do
        sum = sum + v.components.age:GetAgeInDays()
    end
    return sum > 0 and sum / #_activeplayers or 0
end

local function CalcEscalationLevel()
	local day = GetAveragePlayerAgeInDays()

	if day < 8 then
		_attackdelayfn = _spawndata.attack_delays.intro or _spawndata.attack_delays.rare
		_warndurationfn = _spawndata.attack_levels.intro.warnduration
	elseif day < 25 then
		_attackdelayfn = _spawndata.attack_delays.light or _spawndata.attack_delays.rare
		_warndurationfn = _spawndata.attack_levels.light.warnduration
	elseif day < 50 then
		_attackdelayfn = _spawndata.attack_delays.med or _spawndata.attack_delays.occasional
		_warndurationfn = _spawndata.attack_levels.med.warnduration
	elseif day < 100 then
		_attackdelayfn = _spawndata.attack_delays.heavy or _spawndata.attack_delays.frequent
		_warndurationfn = _spawndata.attack_levels.heavy.warnduration
	else
		_attackdelayfn = _spawndata.attack_delays.crazy or _spawndata.attack_delays.frequent
		_warndurationfn = _spawndata.attack_levels.crazy.warnduration
	end

end

local function CalcPlayerAttackSize(player)
    local day = player.components.age:GetAgeInDays()
    return (day < 10 and _spawndata.attack_levels.intro.numspawns())
        or (day < 25 and _spawndata.attack_levels.light.numspawns())
        or (day < 50 and _spawndata.attack_levels.med.numspawns())
        or (day < 100 and _spawndata.attack_levels.heavy.numspawns())
        or _spawndata.attack_levels.crazy.numspawns()
end

local function ClearWaterImunity()
	for GUID,data in pairs(_targetableplayers) do
		_targetableplayers[GUID] = nil
	end
end

local function PlanNextAttack()
	ClearWaterImunity()
	if _timetoattack > 0 then
		-- we came in through a savegame that already had an attack scheduled
		return
	end
	-- if there are no players then try again later
	if #_activeplayers <= 0 then
		_attackplanned = false
		self.inst:DoTaskInTime(1, PlanNextAttack)
		return
	end

	if _spawnmode == "escalating" then
		CalcEscalationLevel()
	end

	if _spawnmode ~= "never" then
		local timetoattackbase, timetoattackvariance = _attackdelayfn()
		_timetoattack = timetoattackbase + timetoattackvariance
		_warnduration = _warndurationfn()
		_attackplanned = true
	else
		_attackplanned = false
	end
    _warning = false
end

local GROUP_DIST = 20
local EXP_PER_PLAYER = 0.05
local ZERO_EXP = 1 - EXP_PER_PLAYER -- just makes the math a little easier

local function GetWaveAmounts()

	-- first bundle up the players into groups based on proximity
	-- we want to send slightly reduced hound waves when players are clumped so that
	-- the numbers aren't overwhelming
	local groupindex = {}
	local nextgroup = 1
	for i, playerA in ipairs(_activeplayers) do
		for j, playerB in ipairs(_activeplayers) do
			if i == 1 and j == 1 then
				groupindex[playerA] = 1
				nextgroup = 2
			end
			if j > i then
				if playerA:IsNear(playerB, GROUP_DIST) then
					if groupindex[playerA] and groupindex[playerB] and groupindex[playerA] ~= groupindex[playerB] then
						local mingroup = math.min(groupindex[playerA], groupindex[playerB])
						groupindex[playerA] = mingroup
						groupindex[playerB] = mingroup
					else
						groupindex[playerB] = groupindex[playerA]
					end
				elseif groupindex[playerB] == nil then
					groupindex[playerB] = nextgroup
					nextgroup = nextgroup + 1
				end
			end
		end
	end

	-- calculate the hound attack for each player
	_spawninfo = {}
	local thieves = {}
	local groupmap = {}
	for player, group in pairs(groupindex) do
		local attackdelaybase = _attackdelayfn()
		local playerAge = player.components.age:GetAge()

		-- amount of hounds relative to our age
		-- if we never saw a warning or have lived shorter than the minimum wave delay then don't spawn hounds to us
        local playerInGame = GetTime() - player.components.age.spawntime
		local spawnsToRelease = (playerInGame > _warnduration and playerAge >= attackdelaybase) and CalcPlayerAttackSize(player) or 0

		if spawnsToRelease > 0 then
			if groupmap[group] == nil then
				groupmap[group] = #_spawninfo + 1

				table.insert(_spawninfo,
					{
						players = {}, -- tracks the number of spawns for this player
						timetonext = 0,

						-- working data
						target_weight = {},
						spawnstorelease = 0,
						totalplayerage = 0,
					})
			end
			local g = groupmap[group]
			_spawninfo[g].spawnstorelease = _spawninfo[g].spawnstorelease + spawnsToRelease
			_spawninfo[g].totalplayerage = _spawninfo[g].totalplayerage + playerAge

			_spawninfo[g].target_weight[player] = math.sqrt(spawnsToRelease) * (player.components.houndedtarget ~= nil and player.components.houndedtarget:GetTargetWeight() or 1)
			_spawninfo[g].players[player] = 0

			if player.components.houndedtarget ~= nil and player.components.houndedtarget:IsHoundThief() then
				table.insert(thieves, {player = player, group = g})
			end
		end
	end

	groupindex = nil -- this is now invalid, some groups were created then destroyed in the first step

	-- we want fewer hounds for larger groups of players so they don't get overwhelmed
	local thieved_spawns = 0
	for i, info in ipairs(_spawninfo) do
		local group_size = GetTableSize(info.players)

		-- pow the number of hounds by a fractional exponent, to stave off huge groups
		-- e.g. hounds ^ 1/1.1 for three players
		local groupexp = 1 / (ZERO_EXP + (EXP_PER_PLAYER * group_size))
		local spawnstorelease = math.max(group_size, RoundBiasedDown(math.pow(info.spawnstorelease, groupexp)))
		if #thieves > 0 and spawnstorelease > group_size then
			spawnstorelease = spawnstorelease - group_size
			thieved_spawns = thieved_spawns + group_size
		end

		-- assign the hounds to each player
		for p = 1, spawnstorelease do
			local player = weighted_random_choice(info.target_weight)
			info.players[player] = info.players[player] + 1
		end

		-- calculate average age to be used for spawn delay
		info.averageplayerage = info.totalplayerage / group_size

		-- remove working data
		info.target_weight = nil
		info.spawnstorelease = nil
	end

	-- distribute the thieved_spawns amoungst the thieves
	if thieved_spawns > 0 then
		thieved_spawns = math.min(thieved_spawns, (self.max_thieved_spawn_per_thief + 1) * #thieves)  -- +1 because we also removed one from the theif
		if #thieves == 1 then
			local player = thieves[1].player
			local group = thieves[1].group
			_spawninfo[group].players[player] = _spawninfo[group].players[player] + thieved_spawns
		else
			shuffleArray(thieves)
			for i = 1, thieved_spawns do
				local index = ((i-1) % #thieves) + 1
				local player = thieves[index].player
				local group = thieves[index].group
				_spawninfo[group].players[player] = _spawninfo[group].players[player] + 1
			end
		end
	end

end

local function GetDelayedPlayerWaveAmounts(player, data)
	local attackdelaybase = _attackdelayfn()
	local playerAge = player.components.age:GetAge()

	-- amount of hounds relative to our age
	-- if we have lived shorter than the minimum wave delay then don't spawn hounds to us
	local spawnsToRelease = playerAge >= attackdelaybase and CalcPlayerAttackSize(player) or 0

	data._spawninfo = {}
	table.insert(data._spawninfo,
	{
		players = {[player] = spawnsToRelease}, --tracks the number of spawns for this player
		timetonext = 0,
		averageplayerage = playerAge,
	})
end

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function GetSpawnPoint(pt)
	if TheWorld.has_ocean then
		local function OceanSpawnPoint(offset)
			local x = pt.x + offset.x
			local y = pt.y + offset.y
			local z = pt.z + offset.z
			return TheWorld.Map:IsAboveGroundAtPoint(x, y, z, true) and NoHoles(pt)
		end

		local offset = FindValidPositionByFan(math.random() * 2 * PI, SPAWN_DIST, 12, OceanSpawnPoint)
		if offset ~= nil then
			offset.x = offset.x + pt.x
			offset.z = offset.z + pt.z
			return offset
		end
	else
		if not TheWorld.Map:IsAboveGroundAtPoint(pt:Get()) then
			pt = FindNearbyLand(pt, 1) or pt
		end
		local offset = FindWalkableOffset(pt, math.random() * 2 * PI, SPAWN_DIST, 12, true, true, NoHoles)
		if offset ~= nil then
			offset.x = offset.x + pt.x
			offset.z = offset.z + pt.z
			return offset
		end
	end
end

local function GetSpecialSpawnChance()
    local day = GetAveragePlayerAgeInDays()
    local chance = 0
    for i, v in ipairs(TUNING.HOUND_SPECIAL_CHANCE) do
        if day > v.minday then
            chance = v.chance
        elseif day <= v.minday then
            return chance
        end
    end
    return TheWorld.state.issummer and chance * 1.5 or chance
end

local function GetSpawnPrefab(upgrade)
	if upgrade and _spawndata.upgrade_spawn then
		return _spawndata.upgrade_spawn
	end

	local do_seasonal_spawn = math.random() < GetSpecialSpawnChance()

	if do_seasonal_spawn then
		if _spawnwintervariant and (TheWorld.state.iswinter or TheWorld.state.isspring) then
			return _spawndata.winter_prefab
		end
		if _spawnsummervariant and (TheWorld.state.issummer or TheWorld.state.isautumn) then
			return _spawndata.summer_prefab
		end
	end

	return _spawndata.base_prefab
end

local function SummonSpawn(pt, upgrade)
    local spawn_pt = GetSpawnPoint(pt)
    if spawn_pt ~= nil then
        local spawn = SpawnPrefab(GetSpawnPrefab(upgrade))
        if spawn ~= nil then
            spawn.Physics:Teleport(spawn_pt:Get())
            spawn:FacePoint(pt)
            if spawn.components.spawnfader ~= nil then
                spawn.components.spawnfader:FadeIn()
            end
            return spawn
        end
    end
end

local function ReleaseSpawn(target, upgrade)
	if not _targetableplayers[target.GUID] or _targetableplayers[target.GUID] == "land" then
	    local spawn = SummonSpawn(target:GetPosition(), upgrade)
	    if spawn ~= nil then
	        spawn.components.combat:SuggestTarget(target)
	        return true
	    end
	end

    return false
end

local function RemovePendingSpawns(player)
    if _spawninfo ~= nil then
        for i, info in ipairs(_spawninfo) do
			if info.players[player] ~= nil then
				info.players[player] = nil
				if next(info.players) == nil then
					 table.remove(_spawninfo, i)
				end
				return
			end
		end
	end
end

local function GenerateSaveDataFromDelayedSpawnInfo(player, savedata, delayedspawninfo)
	savedata[player.userid] =
	{
		_warning = delayedspawninfo._warning,
		_timetoattack = delayedspawninfo._timetoattack,
		_warnduration = delayedspawninfo._warnduration,
		_timetonextwarningsound = delayedspawninfo._timetonextwarningsound,
		_announcewarningsoundinterval = delayedspawninfo._announcewarningsoundinterval,
		_targetstatus =  _targetableplayers[player.GUID]
	}
	if delayedspawninfo._spawninfo then
		local spawninforec = delayedspawninfo._spawninfo
		savedata[player.userid]._spawninfo = {
			count = spawninforec.players and spawninforec.players[player] or 0,
			timetonext = spawninforec.timetonext,
			averageplayerage = spawninforec.averageplayerage,
		}
	end
end

local function GenerateSaveDataFromSpawnInfo(player, savedata)
	savedata[player.userid] =
	{
		_warning = _warning,
		_timetoattack = _timetoattack,
		_warnduration = _warnduration,
		_timetonextwarningsound = _timetonextwarningsound,
		_announcewarningsoundinterval = _announcewarningsoundinterval,
	}
	if _spawninfo then
		for i, spawninforec in ipairs(_spawninfo) do
			if spawninforec.players[player] then
				savedata[player.userid]._spawninfo =
				{
					count = spawninforec.players[player],
					timetonext = spawninforec.timetonext,
					averageplayerage = spawninforec.averageplayerage,
				}
				break
			end
		end
	end
end

local function LoadSaveDataFromMissingSpawnInfo(player, missingspawninfo)
	_delayedplayerspawninfo[player] =
	{
		_warning = missingspawninfo._warning,
		_timetoattack = missingspawninfo._timetoattack,
		_warnduration = missingspawninfo._warnduration,
		_timetonextwarningsound = missingspawninfo._timetonextwarningsound,
		_announcewarningsoundinterval = missingspawninfo._announcewarningsoundinterval,
	}
	if missingspawninfo._targetstatus then
		_targetableplayers[player.GUID] = missingspawninfo._targetstatus
	end
	if missingspawninfo._spawninfo then
		local spawninforec = missingspawninfo._spawninfo
		_delayedplayerspawninfo[player]._spawninfo =
		{
			players = {[player] = spawninforec.count},
			timetonext = spawninforec.timetonext,
			averageplayerage = spawninforec.averageplayerage,
		}
	end
end

local function LoadPlayerSpawnInfo(player)
	if _missingplayerspawninfo[player.userid] then
		LoadSaveDataFromMissingSpawnInfo(player, _missingplayerspawninfo[player.userid])
		_missingplayerspawninfo[player.userid] = nil
	end
end

local function SavePlayerSpawnInfo(player, savedata, isworldsave)
	if _delayedplayerspawninfo[player] then
		GenerateSaveDataFromDelayedSpawnInfo(player, savedata, _delayedplayerspawninfo[player])
		if not isworldsave then
			_delayedplayerspawninfo[player] = nil
		end
	elseif _warning or _timetoattack < 0 or _spawninfo ~= nil then
		GenerateSaveDataFromSpawnInfo(player, savedata)
		if not isworldsave then
			RemovePendingSpawns(player)
		end
	end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnPlayerJoined(src, player)
    for i, v in ipairs(_activeplayers) do
        if v == player then
            return
        end
    end
    table.insert(_activeplayers, player)

	LoadPlayerSpawnInfo(player)
end

local function OnPlayerLeft(src, player)
	SavePlayerSpawnInfo(player, _missingplayerspawninfo)

	_targetableplayers[player.GUID] = nil

    for i, v in ipairs(_activeplayers) do
        if v == player then
            table.remove(_activeplayers, i)
            return
        end
    end
end

local function OnPauseHounded(src, data)
    if data ~= nil and data.source ~= nil then
        _pausesources:SetModifier(data.source, true, data.reason)
    end
end

local function OnUnpauseHounded(src, data)
    if data ~= nil and data.source ~= nil then
        _pausesources:RemoveModifier(data.source, data.reason)
    end
end

local function CheckForWaterImunity(player)
    if not _targetableplayers[player.GUID] then
		-- block hound wave targeting when target is on water.. for now.
		local x,y,z = player.Transform:GetWorldPosition()
		if TheWorld.Map:IsVisualGroundAtPoint(x,y,z) then
			_targetableplayers[player.GUID] = "land"
		else
			_targetableplayers[player.GUID] = "water"
		end
    end
end

local function CheckForWaterImunityAllPlayers()
	for i, v in ipairs(_activeplayers) do
		CheckForWaterImunity(v)
	end
end

local function SetDifficulty(src, difficulty)
	if difficulty == "never" then
		self:SpawnModeNever()
	elseif difficulty == "rare" then
		self:SpawnModeLight()
	elseif difficulty == "default" then
		self:SpawnModeNormal()
	elseif difficulty == "often" then
		self:SpawnModeMed()
	elseif difficulty == "always" then
		self:SpawnModeHeavy()
	end
end

local function SetSummerVariant(src, enabled)
	if enabled == "never" then
		self:SetSummerVariant(false)
	elseif enabled == "default" then
		self:SetSummerVariant(true)
	end
end

local function SetWinterVariant(src, enabled)
	if enabled == "never" then
		self:SetWinterVariant(false)
	elseif enabled == "default" then
		self:SetWinterVariant(true)
	end
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize variables
for i, v in ipairs(AllPlayers) do
    table.insert(_activeplayers, v)
end

--Register events
inst:ListenForEvent("ms_playerjoined", OnPlayerJoined)
inst:ListenForEvent("ms_playerleft", OnPlayerLeft)

inst:ListenForEvent("pausehounded", OnPauseHounded)
inst:ListenForEvent("unpausehounded", OnUnpauseHounded)

inst:ListenForEvent("hounded_setdifficulty", SetDifficulty)
inst:ListenForEvent("hounded_setsummervariant", SetSummerVariant)
inst:ListenForEvent("hounded_setwintervariant", SetWinterVariant)

self.inst:StartUpdatingComponent(self)
PlanNextAttack()

--------------------------------------------------------------------------
--[[ Public getters and setters ]]
--------------------------------------------------------------------------

function self:GetTimeToAttack()
	return _timetoattack
end

function self:GetWarning()
	return _warning
end

function self:GetAttacking()
	return ((_timetoattack <= 0) and _attackplanned)
end

function self:SetSpawnData(data)
	_spawndata = data
end

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:SetSummerVariant(enabled)
	_spawnsummervariant = enabled
end

function self:SetWinterVariant(enabled)
	_spawnwintervariant = enabled
end

function self:SpawnModeNever()
	_spawnmode = "never"
	PlanNextAttack()
end

function self:SpawnModeLight()
	_spawnmode = "constant"
	_attackdelayfn = _spawndata.attack_delays.heavy or _spawndata.attack_delays.frequent
	_warndurationfn = _spawndata.attack_levels.light.warnduration
	PlanNextAttack()
end

function self:SpawnModeNormal()
	_spawnmode = "escalating"
	PlanNextAttack()
end

self.SpawnModeEscalating = self.SpawnModeNormal

function self:SpawnModeMed()
	_spawnmode = "constant"
	_attackdelayfn = _spawndata.attack_delays.med or _spawndata.attack_delays.occasional
	_warndurationfn = _spawndata.attack_levels.med.warnduration
	PlanNextAttack()
end

function self:SpawnModeHeavy()
	_spawnmode = "constant"
	_attackdelayfn = _spawndata.attack_delays.light or _spawndata.attack_delays.rare
	_warndurationfn = _spawndata.attack_levels.heavy.warnduration
	PlanNextAttack()
end

-- Releases a hound near and attacking 'target'
function self:ForceReleaseSpawn(target)
	if target ~= nil then
		ReleaseSpawn(target)
	end
end

-- Creates a hound near 'pt'
function self:SummonSpawn(pt)
    return pt ~= nil and SummonSpawn(pt) or nil
end

-- Spawns the next wave for debugging
-- TheWorld.components.hounded:ForceNextWave()
function self:ForceNextWave()
	PlanNextAttack()
	_timetoattack = 0
	self:OnUpdate(1)
end

local function _DoWarningSpeech(player)
    player.components.talker:Say(GetString(player, _spawndata.warning_speech))
end

function self:DoWarningSpeech()
    for GUID,data in pairs(_targetableplayers) do
    	if data == "land" then
    		local player = Ents[GUID]
        	player:DoTaskInTime(math.random() * 2, _DoWarningSpeech)
    	end
    end
end

function self:DoWarningSound()
    for k,v in pairs(_spawndata.warning_sound_thresholds) do
    	if _timetoattack <= v.time or _timetoattack == nil then
    		for GUID,data in pairs(_targetableplayers)do
    			local player = Ents[GUID]
    			if player and data == "land" then
    				player:PushEvent("houndwarning",HOUNDWARNINGTYPE[v.sound])
    			end
    		end
    		break
    	end
    end
end

function self:DoDelayedWarningSpeech(player, data)
	if _targetableplayers[player.GUID] == "land" then
		player:DoTaskInTime(math.random() * 2, _DoWarningSpeech)
	end
end

function self:DoDelayedWarningSound(player, data)
    for k,v in pairs(_spawndata.warning_sound_thresholds) do
    	if data._timetoattack <= v.time or data._timetoattack == nil then
			if _targetableplayers[player.GUID] == "land" then
				player:PushEvent("houndwarning",HOUNDWARNINGTYPE[v.sound])
			end
    		break
    	end
    end
end

local function ShouldUpgrade(amount)
	if amount >= 8 then
		return math.random() < 0.7
	elseif amount == 7 then
		return math.random() < 0.3
	elseif amount == 6 then
		return math.random() < 0.15
	elseif amount == 5 then
		return math.random() < 0.05
	end
	return false
end

local function HandleSpawnInfoRec(dt, i, spawninforec, groupsdone)
	spawninforec.timetonext = spawninforec.timetonext - dt
	if next(spawninforec.players) ~= nil and spawninforec.timetonext < 0 then
		local target = weighted_random_choice(spawninforec.players)

		if spawninforec.players[target] <= 0 then
			spawninforec.players[target] = nil
			if next(spawninforec.players) == nil then
				table.insert(groupsdone, 1, i)
			end
			return
		end

		-- TEST IF GROUPS IF HOUNDS SHOULD BE TURNED INTO A VARG (or other)
		local upgrade = _spawndata.upgrade_spawn and ShouldUpgrade(spawninforec.players[target])

		if upgrade then
			spawninforec.players[target] = spawninforec.players[target] - 5
		else
			spawninforec.players[target] = spawninforec.players[target] - 1
		end

		ReleaseSpawn(target, upgrade)

		if spawninforec.players[target] <= 0 then
			spawninforec.players[target] = nil
		end

		local day = spawninforec.averageplayerage / TUNING.TOTAL_DAY_TIME
		if day < 20 then
			spawninforec.timetonext = 3 + math.random()*5
		elseif day < 60 then
			spawninforec.timetonext = 2 + math.random()*3
		elseif day < 100 then
			spawninforec.timetonext = .5 + math.random()*3
		else
			spawninforec.timetonext = .5 + math.random()*1
		end

	end
	if next(spawninforec.players) == nil then
		table.insert(groupsdone, 1, i)
	end
end

function self:OnUpdate(dt)
	if _spawnmode == "never" then
		return
	end

	for player, data in pairs (_delayedplayerspawninfo) do
		data._timetoattack = data._timetoattack - dt
		if data._timetoattack < 0 then
			_warning = false

			-- Okay, it's hound-day, get number of dogs for each player
			if data._spawninfo == nil then
				GetDelayedPlayerWaveAmounts(player, data)
			end

			local groupsdone = {}
			CheckForWaterImunity(player)
			for i, spawninforec in ipairs(data._spawninfo) do
				HandleSpawnInfoRec(dt, i, spawninforec, groupsdone)
			end

			for i, v in ipairs(groupsdone) do
				table.remove(data._spawninfo, v)
			end

			if #data._spawninfo <= 0 then
				_delayedplayerspawninfo[player] = nil
				_targetableplayers[player] = nil
			end
		elseif not data._warning and data._timetoattack < data._warnduration then
			data._warning = true
			data._timetonextwarningsound = 0
		end

		if data._warning then
			data._timetonextwarningsound = data._timetonextwarningsound - dt

			if data._timetonextwarningsound <= 0 then
				CheckForWaterImunity(player)
				data._announcewarningsoundinterval = data._announcewarningsoundinterval - 1
				if data._announcewarningsoundinterval <= 0 then
					data._announcewarningsoundinterval = 10 + math.random(5)
					self:DoDelayedWarningSpeech(player, data)
				end

				data._timetonextwarningsound =
					(data._timetoattack < 30 and .3 + math.random(1)) or
					(data._timetoattack < 60 and 2 + math.random(1)) or
					(data._timetoattack < 90 and 4 + math.random(2)) or
											5 + math.random(4)

				self:DoDelayedWarningSound(player, data)
			end
		end
	end

	-- if there's no players, then don't even try
	if #_activeplayers == 0  or not _attackplanned then
		return
	end

    _timetoattack = _timetoattack - dt

    if _pausesources:Get() and not _warning and (_timetoattack >= 0 or _spawninfo == nil) then
        if _timetoattack < 0 then
            PlanNextAttack()
        end
        return
    end

    if _timetoattack < 0 then
        _warning = false

		-- Okay, it's hound-day, get number of dogs for each player
		if _spawninfo == nil then
			GetWaveAmounts()
		end

		local groupsdone = {}
		CheckForWaterImunityAllPlayers()
		for i, spawninforec in ipairs(_spawninfo) do
			HandleSpawnInfoRec(dt, i, spawninforec, groupsdone)
		end

		for i, v in ipairs(groupsdone) do
			table.remove(_spawninfo, v)
		end

		if #_spawninfo <= 0 then
			_spawninfo = nil

			PlanNextAttack()
		end
	elseif not _warning and _timetoattack < _warnduration then
		_warning = true
		_timetonextwarningsound = 0
	end

    if _warning then
        _timetonextwarningsound	= _timetonextwarningsound - dt

        if _timetonextwarningsound <= 0 then
        	CheckForWaterImunityAllPlayers()
            _announcewarningsoundinterval = _announcewarningsoundinterval - 1
            if _announcewarningsoundinterval <= 0 then
                _announcewarningsoundinterval = 10 + math.random(5)
                self:DoWarningSpeech()
            end

            _timetonextwarningsound =
                (_timetoattack < 30 and .3 + math.random(1)) or
                (_timetoattack < 60 and 2 + math.random(1)) or
                (_timetoattack < 90 and 4 + math.random(2)) or
                                        5 + math.random(4)

            self:DoWarningSound()
        end
    end
end

self.LongUpdate = self.OnUpdate

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
	local missingspawninfo = deepcopy(_missingplayerspawninfo)
	for i, player in ipairs(AllPlayers) do
		SavePlayerSpawnInfo(player, missingspawninfo, true)
	end

	return
	{
		warning = _warning,
		timetoattack = _timetoattack,
		warnduration = _warnduration,
		attackplanned = _attackplanned,
		missingplayerspawninfo = missingspawninfo,
	}
end

function self:OnLoad(data)
	_warning = data.warning or false
	_warnduration = data.warnduration or 0
	_timetoattack = data.timetoattack or 0
	_attackplanned = data.attackplanned  or false
	_missingplayerspawninfo = data.missingplayerspawninfo or {}

	if _timetoattack > _warnduration then
		-- in case everything went out of sync
		_warning = false
	end
	if _attackplanned then
		if _timetoattack < _warnduration then
			-- at least give players a fighting chance if we quit during the warning phase
			_timetoattack = _warnduration + 5
		end
	else
		PlanNextAttack()
	end
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    if _timetoattack > 0 then
        return string.format("%s spawns are coming in %2.2f", (_warning and "WARNING") or (_pausesources:Get() and "BLOCKED") or "WAITING", _timetoattack)
    end

    local s = "DORMANT"
	if _spawnmode ~= "never" then
		s = "ATTACKING"
		for i, spawninforec in ipairs(_spawninfo) do
			s = s.."\n{"
			for player, _ in pairs(spawninforec.players) do
				s = s..tostring(player)..","
			end
			s = s.."} - spawns left:"..tostring(spawninforec.spawnstorelease).." next spawn:"..tostring(spawninforec.timetonext)
		end
	end
    return s
end

end)
