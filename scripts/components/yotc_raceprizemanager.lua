--------------------------------------------------------------------------
--[[ raceprizemanager class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "yotc_raceprizemanager should not exist on client")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst
self._races = {}

--Private
local _prize = -1

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------
local function setbundle(prize)
    local loot = nil
    if prize > 0 then
        loot = {}
        for i = 1, prize do
            table.insert(loot, "lucky_goldnugget")
        end
    end
    return loot
end

function self:GivePrizes(race)
	local prize_available = _prize < TheWorld.state.cycles

	local first_prize, consolation_prize = 0, 0
    if prize_available then
        local distancebonus =  math.min(math.floor(race.results.distance / (TUNING.YOTC_RACER_CHECKPOINT_FIND_DIST - 2)), TUNING.YOTC_RACE_MAX_DISTANCE_REWARDS)
        local multiplier = GetTableSize(race.racers) / race.num_racers
		first_prize = math.max(2, math.floor(multiplier * (distancebonus + 3)))
		consolation_prize = 1
    end

	for racer, _ in pairs(race.racers) do
		if racer:IsValid() and racer.components.yotc_racecompetitor ~= nil then
			racer.components.yotc_racecompetitor:OnAllRacersFinished(setbundle(racer == race.results.first_place and first_prize or consolation_prize))
		end
	end

	if prize_available then
		_prize = TheWorld.state.cycles
		TheWorld:PushEvent("yotc_ratraceprizechange")
	end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------
local function updateprize(inst, cycles)
    if _prize == (cycles - 1) then
        TheWorld:PushEvent("yotc_ratraceprizechange")
    end
end


---------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Register events

inst:WatchWorldState("cycles", updateprize)

--------------------------------------------------------------------------
--[[ Post initialization ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:HasPrizeAvailable()
	return _prize < TheWorld.state.cycles
end

function self:RegisterRacer(new_racer, start_line)
    local racer_trainer = (new_racer.components.entitytracker and new_racer.components.entitytracker:GetEntity("yotc_trainer")) or nil
    if (racer_trainer ~= nil or (new_racer.components.yotc_racecompetitor ~= nil and new_racer.components.yotc_racecompetitor.is_ghostracer)) and self:GetRaceByRacer(new_racer) == nil then
        if not self._races[start_line] then
            self._races[start_line] = {}
            self._races[start_line].race_id = start_line
            self._races[start_line].checkpoints = {}
            self._races[start_line].prize = nil
			self._races[start_line].racers = {}
            self._races[start_line].num_racers = 0 -- number of racers at the start of the race, since race.racers can have people drop out
            self._races[start_line].race_begun = false
        end

        local old_racer = nil
        if self._races[start_line].num_racers > 0 then
            for racer, _ in pairs(self._races[start_line].racers) do
                local existing_racer_trainer = (racer.components.entitytracker and racer.components.entitytracker:GetEntity("yotc_trainer")) or nil
                if existing_racer_trainer == racer_trainer then
                    old_racer = racer
                    break
                end
            end
        end

        self._races[start_line].racers[new_racer] = true
        self._races[start_line].num_racers = self._races[start_line].num_racers + 1

        return true, old_racer
    end

    return false, nil
end

function self:racethemecheck()
    local players = {}
    for k, race in pairs(self._races) do
        for racer,i in pairs(race.racers) do
            racer._musicstate:set(CARRAT_MUSIC_STATES.NONE)
            racer._musicstate:set(CARRAT_MUSIC_STATES.RACE)
        end
    end
    if not next(self._races) then
        self._themetask:Cancel()
        self._themetask = nil
    end
end

function self:BeginRace(start_line)
    local race_data = self._races[start_line]
    if race_data ~= nil and race_data.num_racers > 0 then
        self._races[start_line].race_begun = true
        start_line:PushEvent("yotc_racebegun")
        if not self._themetask then
            self:racethemecheck()
            self._themetask = self.inst:DoPeriodicTask(4,function() self:racethemecheck() end)
        end
    end
end

function self:GetRaceIdByRacer(racer)
    for k, race in pairs(self._races) do
		if race.racers[racer] then
			return k
		end
    end
end

function self:GetRaceByRacer(racer)
    for k, race in pairs(self._races) do
		if race.racers[racer] then
			return race
		end
    end
end

function self:GetRaceById(start_line)
	return self._races[start_line]
end

function self:IsRaceUnderway(start_line)
    return self._races[start_line] ~= nil and self._races[start_line].race_begun
end

function self:EndOfRace(race_id)
	local race = self._races[race_id]
	if race ~= nil then
    for racer,i in pairs(race.racers) do
        print("SETTING NET VAR to OFF")
        racer._musicstate:set(CARRAT_MUSIC_STATES.NONE)
    end

	if race.checkpoints ~= nil then
		for checkpoint, _ in pairs(race.checkpoints) do
			if checkpoint:IsValid() then
				checkpoint:PushEvent("yotc_race_over")
			end
 		end
		race.checkpoints = nil
	end

		self._races[race_id] = nil
	end
end

function self:RemoveRacer(racer)
    racer._musicstate:set(CARRAT_MUSIC_STATES.NONE)

	local race_id = self:GetRaceIdByRacer(racer)
	if race_id ~= nil then
		local race = self._races[race_id]

		if not race.race_begun then
			race.num_racers = race.num_racers - 1
		end

		race.racers[racer] = nil

		if next(race.racers) == nil then -- if no more racers
			self:EndOfRace(race.race_id)
		elseif race.results ~= nil and race.results.num_racers_finished >= GetTableSize(race.racers) then
			self:GivePrizes(race)
			self:EndOfRace(race.race_id)
		end
	end
end

function self:RegisterCheckpoint(racer, checkpoint)
    local race = self:GetRaceByRacer(racer)
    if race then
		race.checkpoints[checkpoint] = true
    end
end

function self:RacerFinishedRace(racer, distance)
	local is_first = false
	local race = self:GetRaceByRacer(racer)
	if race ~= nil then
		if race.results == nil then
			race.results = {}
			race.results.first_place = racer
			race.results.distance = distance
			race.results.num_racers_finished = 1
			is_first = true
		else
			race.results.num_racers_finished = race.results.num_racers_finished + 1
		end

		if race.results.num_racers_finished >= GetTableSize(race.racers) then
			self:GivePrizes(race)
			self:EndOfRace(race.race_id)
		end
	end
	return is_first
end

function self:IsFirstPlaceRacer(racer)
	local race = self:GetRaceByRacer(racer)
	return race ~= nil and race.results == nil and race.results.first_place == racer
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
    local data = {}
    data.prize_date = _prize
    return data
end

function self:LoadPostPass(ents, data)
    if data then
		if data.prize ~= nil then
	        _prize = data.prize == 1 and (TheWorld.state.cycles - 1) or TheWorld.state.cycles -- retrofitting for worlds that had the 0/1 prize value
		elseif data.prize_date then
			_prize = data.prize_date
		end
    end

    TheWorld:PushEvent("yotc_ratraceprizechange")
end


--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    return string.format("prize:%d", _prize)
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)

