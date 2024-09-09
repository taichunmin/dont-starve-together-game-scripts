--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------
local easing = require("easing")

--------------------------------------------------------------------------
--[[ BeargerSpawner class definition ]]
--------------------------------------------------------------------------
return Class(function(self, inst)

assert(TheWorld.ismastersim, "Beargerspawner should not exist on client")

--------------------------------------------------------------------------
--[[ Private constants ]]
--------------------------------------------------------------------------

local HASSLER_SPAWN_DIST = PLAYER_CAMERA_SEE_DISTANCE
local BEARGER_TIMERNAME = "bearger_timetospawn"

--------------------------------------------------------------------------
--[[ Public Member Variables ]]
--------------------------------------------------------------------------

self.inst = inst

--------------------------------------------------------------------------
--[[ Private Member Variables ]]
--------------------------------------------------------------------------
local _warning = false
local _spawndelay = nil
local _warnduration = 60
local _timetonextwarningsound = 0
local _announcewarningsoundinterval = 4

local _worldsettingstimer = TheWorld.components.worldsettingstimer

local _numToSpawn = 0
local _beargerchances = TUNING.BEARGER_CHANCES

local _numSpawned = 0

local _timetospawn

local _targetplayer = nil
local _activehasslers = {}
local _activeplayers = {}

local _lastBeargerKillDay = nil

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function CanSpawnBearger()
	return TheWorld.state.isautumn and
	 		TheWorld.state.cycles > TUNING.NO_BOSS_TIME and
			 _numSpawned < _numToSpawn and
			 (_lastBeargerKillDay == nil or TheWorld.state.cycles - _lastBeargerKillDay > TUNING.NO_BOSS_TIME)
end

local function IsEligible(player)
	local area = player.components.areaaware
	return player:IsValid()
			and TheWorld.Map:IsVisualGroundAtPoint(player.Transform:GetWorldPosition())
			and area:GetCurrentArea() ~= nil
			and not area:CurrentlyInTag("nohasslers")
end

local function PickPlayer()
	_targetplayer = nil

	local playerlist = {}
	if TheWorld ~= nil and TheWorld.Map ~= nil then
		for i, v in ipairs(_activeplayers) do
			if IsEligible(v) then
				table.insert(playerlist, i)
			end
		end
	end
	if #playerlist == 0 then
		return
	end

	local playeri = playerlist[math.min(math.floor(easing.inQuint(math.random(), 1, #playerlist, 1)), #playerlist)]
	local player = _activeplayers[playeri]
	table.remove(_activeplayers, playeri)
	table.insert(_activeplayers, player)
	_targetplayer = player
end

local function GetSpawnPoint(pt)
    if not TheWorld.Map:IsAboveGroundAtPoint(pt:Get()) then
        pt = FindNearbyLand(pt, 1) or pt
    end
    local offset = FindWalkableOffset(pt, math.random() * TWOPI, HASSLER_SPAWN_DIST, 12, true)
    if offset ~= nil then
        offset.x = offset.x + pt.x
        offset.z = offset.z + pt.z
        return offset
    end
end

local function GetActiveHasslerCount()
	return GetTableSize(_activehasslers)
end

local function SpawnBearger()
	local spawndelay = _numToSpawn > 0 and (.25 * TheWorld.state.remainingdaysinseason * TUNING.TOTAL_DAY_TIME / _numToSpawn) or 0
	local spawnrandom = .25 * spawndelay
	local timetospawn = TheWorld.components.worldsettingstimer:GetTimeLeft(BEARGER_TIMERNAME)
	if timetospawn == nil then
		timetospawn = _worldsettingstimer:StartTimer(BEARGER_TIMERNAME, GetRandomWithVariance(spawndelay, spawnrandom))
	elseif timetospawn > spawndelay + spawnrandom then
		timetospawn = _worldsettingstimer:SetTimeLeft(BEARGER_TIMERNAME, GetRandomWithVariance(spawndelay, spawnrandom))
		timetospawn = _worldsettingstimer:ResumeTimer(BEARGER_TIMERNAME)
	end

	self.inst:StartUpdatingComponent(self)
end

local function ReleaseHassler(targetPlayer)
    assert(targetPlayer)

    if _numSpawned >= _numToSpawn then
        print("Not spawning bearger - already at maximum number")
        return nil
    end
	local mutant = TheSim:FindFirstEntityWithTag("bearger_blocker")
	if mutant ~= nil then
		--Not spawning bearger - mutant exists
		return nil
	end

    local spawn_pt = GetSpawnPoint(targetPlayer:GetPosition())
    if spawn_pt ~= nil then
        local hassler = SpawnPrefab("bearger")
		hassler.Physics:Teleport(spawn_pt:Get())

		_numSpawned = _numSpawned + 1
		_activehasslers[hassler] = true

		if CanSpawnBearger() then
			SpawnBearger()
		else
			self.inst:StopUpdatingComponent(self)
			_worldsettingstimer:PauseTimer(BEARGER_TIMERNAME, true)
		end

        return hassler
    end

    print("Not spawning bearger - can't find spawn point")
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnSeasonTick(src, data)
	if data.season == "autumn" and TheWorld.state.cycles > TUNING.NO_BOSS_TIME then
		--update bearger spawn chances if one of these conditions is true:
		--its the first day of autumn
		--its been TUNING.NO_BOSS_TIME since the last bearger kill
		--its the first day after the TUNING.NO_BOSS_TIME grace period.
		if data.elapseddaysinseason == 0 or (_lastBeargerKillDay and TheWorld.state.cycles - _lastBeargerKillDay > TUNING.NO_BOSS_TIME) or TheWorld.state.cycles == TUNING.NO_BOSS_TIME + 1 then
			_numToSpawn = 0
			for i, chance in ipairs(_beargerchances) do
				if math.random() < chance then
					_numToSpawn = _numToSpawn + 1
				end
			end
			_numSpawned = GetActiveHasslerCount()
			if CanSpawnBearger() then
				SpawnBearger()
			end
		end
	elseif data.elapseddaysinseason == 0 then
		_numToSpawn = 0
		_numSpawned = GetActiveHasslerCount()
		self.inst:StopUpdatingComponent(self)
		_worldsettingstimer:PauseTimer(BEARGER_TIMERNAME, true)
	end
end

local function OnPlayerJoined(src,player)
    for i, v in ipairs(_activeplayers) do
        if v == player then
            return
        end
    end
    table.insert(_activeplayers, player)

    if CanSpawnBearger() then
        _worldsettingstimer:ResumeTimer(BEARGER_TIMERNAME)
        self.inst:StartUpdatingComponent(self)
    end
end

local function OnPlayerLeft(src,player)
	--print("Player ", player, "left, targetplayer is ", _targetplayer or "nil")
    for i, v in ipairs(_activeplayers) do
        if v == player then
            table.remove(_activeplayers, i)
            if player == _targetplayer then
            	_targetplayer = nil
            end

            PickPlayer()
            if _targetplayer == nil then
                self.inst:StopUpdatingComponent(self)
                _worldsettingstimer:PauseTimer(BEARGER_TIMERNAME, true)
            end
            return
        end
    end
end

local function OnHasslerRemoved(src, hassler)
	_activehasslers[hassler] = nil
end


local function OnHasslerKilled(src, hassler)
	_activehasslers[hassler] = nil

	_worldsettingstimer:StopTimer(BEARGER_TIMERNAME)

	--don't remove from numSpawned, as that could cause repeated cycles of bearger spawning, instead numSpawned will get clobbered the next time we re-roll bearger spawn chances.
	--numSpawned = numSpawned - 1

	_lastBeargerKillDay = TheWorld.state.cycles
end

local function OnBeargerTimerDone(src, data)
	_warning = false

	--pick a new player just in case we don't have one
	if _targetplayer == nil then
		PickPlayer()
	end

	if _targetplayer ~= nil then
		ReleaseHassler(_targetplayer)
	end
end

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:SetSecondBeargerChance(chance)
	--depreciated
end

function self:SetFirstBeargerChance(chance)
	--depreciated
end

function self:OnPostInit()
	local totalbeargerchance = 0
	for i, v in ipairs(_beargerchances) do
		totalbeargerchance = totalbeargerchance + v
	end
	if totalbeargerchance > 0 then -- NOTES(JBK): In case mods modify chances to make it zero we do not want to make infinite timers.
		_spawndelay = 0.25 * TheWorld.state.autumnlength * TUNING.TOTAL_DAY_TIME / totalbeargerchance
		_worldsettingstimer:AddTimer(BEARGER_TIMERNAME, _spawndelay, TUNING.SPAWN_BEARGER, OnBeargerTimerDone)
	end

	if _timetospawn then
		_worldsettingstimer:StartTimer(BEARGER_TIMERNAME, math.min(_timetospawn, _spawndelay))
	end
end

local function _DoWarningSpeech(player)
    --TODO: bearger specific strings
    player.components.talker:Say(GetString(player, "ANNOUNCE_DEERCLOPS"))
end

function self:DoWarningSpeech(_targetplayer)
    for i, v in ipairs(_activeplayers) do
        if v == _targetplayer or v:IsNear(_targetplayer, HASSLER_SPAWN_DIST * 2) then
            v:DoTaskInTime(math.random() * 2, _DoWarningSpeech)
        end
    end
end

function self:DoWarningSound(_targetplayer)
    --Players near _targetplayer will hear the warning sound from the
    --same direction and volume offset from their own local positions
    local timetospawn = _worldsettingstimer:GetTimeLeft(BEARGER_TIMERNAME)
    SpawnPrefab("beargerwarning_lvl"..
        (((timetospawn == nil or timetospawn < 30) and "4") or (timetospawn < 60 and "3") or (timetospawn < 90 and "2") or "1")
    ).Transform:SetPosition(_targetplayer.Transform:GetWorldPosition())
end


function self:OnUpdate(dt)
    local timetospawn = _worldsettingstimer:GetTimeLeft(BEARGER_TIMERNAME)
	if timetospawn then
		if not _warning then
			_timetonextwarningsound = 0
			if timetospawn > 0 and timetospawn < _warnduration then
				PickPlayer()
				if not _targetplayer then
					return
				end

				_warning = true
			end
		else
			_timetonextwarningsound	= _timetonextwarningsound - dt

			if _timetonextwarningsound <= 0 then
		        if _targetplayer == nil then
		        	PickPlayer()
		        	if _targetplayer == nil then
			            return
			        end
		        end
				_announcewarningsoundinterval = _announcewarningsoundinterval - 1
				if _announcewarningsoundinterval <= 0 then
					_announcewarningsoundinterval = 10 + math.random(5)
					self:DoWarningSpeech(_targetplayer)
				end

                _timetonextwarningsound = timetospawn < 30 and 10 + math.random(1) or 15 + math.random(4)
				self:DoWarningSound(_targetplayer)
			end
		end
	elseif CanSpawnBearger() then
		SpawnBearger()
	else
		self.inst:StopUpdatingComponent(self)
		_worldsettingstimer:PauseTimer(BEARGER_TIMERNAME, true)
    end
end

function self:LongUpdate(dt)
	self:OnUpdate(dt)
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
	local data =
	{
		warning = _warning,
		numToSpawn = _numToSpawn,
		lastKillDay = _lastBeargerKillDay,
		numSpawned = _numSpawned,
	}

	local ents = {}

	data.activehasslers = {}

	for k,v in pairs(_activehasslers) do
		if k ~= nil then
			table.insert(data.activehasslers, k.GUID)
			table.insert(ents, k.GUID)
		end
	end

	return data, ents
end

function self:OnLoad(data)
	_warning = data.warning or false
	_numToSpawn = data.numToSpawn or data.targetnum or 0
	_lastBeargerKillDay = data.lastKillDay
	_numSpawned = data.numSpawned or 0

	self.inst:StopUpdatingComponent(self)
	_worldsettingstimer:PauseTimer(BEARGER_TIMERNAME, true)

    --retrofit old timer to new system
    if data.timetospawn then
        _timetospawn = data.timetospawn
    end
end

function self:LoadPostPass(newents, savedata)
	if savedata.activehasslers ~= nil then
		for k,v in pairs(savedata.activehasslers) do
			if newents[v] ~= nil then
				_activehasslers[newents[v].entity] = true
			end
		end
	end

	if CanSpawnBearger() then
		_worldsettingstimer:ResumeTimer(BEARGER_TIMERNAME)
		self.inst:StartUpdatingComponent(self)
	end

end


--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    local timetospawn = _worldsettingstimer:GetTimeLeft(BEARGER_TIMERNAME)
	local s = ""
	if not timetospawn then
	    s = s .. "DORMANT <no time>"
	elseif self.inst.updatecomponents[self] == nil then
		s = s .. "DORMANT "..timetospawn
	elseif timetospawn > 0 then
		s = s .. string.format("%s Bearger is coming in %2.2f (next warning in %2.2f), target number: %d, current number: %d", _warning and "WARNING" or "WAITING", timetospawn, _timetonextwarningsound, _numToSpawn, _numSpawned)
	else
		s = s .. string.format("SPAWNING!!!")
	end
	s = s .. string.format(" active: %s", GetActiveHasslerCount())
	return s
end

function self:SummonMonster(player)
    if _worldsettingstimer:ActiveTimerExists(BEARGER_TIMERNAME) then
        _worldsettingstimer:SetTimeLeft(BEARGER_TIMERNAME, 10)
		_worldsettingstimer:ResumeTimer(BEARGER_TIMERNAME)
    else
        _worldsettingstimer:StartTimer(BEARGER_TIMERNAME, 10)
    end
	self.inst:StartUpdatingComponent(self)
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------
for i, v in ipairs(AllPlayers) do
    table.insert(_activeplayers, v)
end

self.inst:ListenForEvent("ms_playerjoined", OnPlayerJoined, TheWorld)
self.inst:ListenForEvent("ms_playerleft", OnPlayerLeft, TheWorld)
self.inst:ListenForEvent("seasontick", OnSeasonTick, TheWorld)
self.inst:ListenForEvent("beargerremoved", OnHasslerRemoved, TheWorld)
self.inst:ListenForEvent("beargerkilled", OnHasslerKilled, TheWorld)


end)
