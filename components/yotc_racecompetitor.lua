local YOTC_RaceCompetitor = Class(function(self, inst)
    self.inst = inst

	self.racestate = "prerace"

    --self.race_start_point = nil
    --self.race_begun_fn = nil
	--self.race_finished_fn = nil
    --self.race_prize = nil

	self.checkpoints = {}
	self.race_distance = 0

	self.checkpoint_timer = 0

	self.forgetfulness = 0
	self.stamina_max = 8
	self.stamina_max_var = 2
	self.stamina = self.stamina_max
	self.exhausted_time = 2
	self.exhausted_time_var = 1

    self.onnextcheckpointremove = function(a)
		self.checkpoints[a] = nil
        self.next_checkpoint = nil
    end

    self.start_race = function() self:StartRace(math.random() * 0.5) end
end,
nil,
{})

function YOTC_RaceCompetitor:OnRemoveEntity()
	if TheWorld.components.yotc_raceprizemanager then
		TheWorld.components.yotc_raceprizemanager:RemoveRacer(self.inst)
	end
end

function YOTC_RaceCompetitor:OnRemoveFromEntity()
	self.racestate = ""
	if self.queuedstarttask ~= nil then
		self.queuedstarttask:Cancel()
		self.queuedstarttask = nil
	end

	self:_SetCheckPoint(nil)
    self.inst:RemoveTag("has_prize")
    self.inst:RemoveTag("has_no_prize")
	if self.race_finished_fn ~= nil then
		self.race_finished_fn(self.inst, nil)
	end
	if self.race_over_fn ~= nil then
		self.race_over_fn(self.inst, nil)
	end
	if TheWorld.components.yotc_raceprizemanager then
		TheWorld.components.yotc_raceprizemanager:RemoveRacer(self.inst)
	end
end

function YOTC_RaceCompetitor:OnEntitySleep()
	if self.racestate ~= "postrace" and self.racestate ~= "prerace" and self.racestate ~= "raceover" then
		self.inst:RemoveComponent("yotc_racecompetitor")
    end
end

function YOTC_RaceCompetitor:GetRaceDistance()
	return self.race_distance
end

function YOTC_RaceCompetitor:SetRaceBegunFn(race_begun_fn)
    self.race_begun_fn = race_begun_fn
end

function YOTC_RaceCompetitor:SetRaceFinishedFn(race_finished_fn)
    self.race_finished_fn = race_finished_fn
end

function YOTC_RaceCompetitor:SetRaceOverFn(race_over_fn)
    self.race_over_fn = race_over_fn
end

function YOTC_RaceCompetitor:_SetCheckPoint(checkpoint, is_starting_line)
	if self.next_checkpoint ~= nil then
        self.inst:RemoveEventCallback("onremove", self.onnextcheckpointremove, self.next_checkpoint)
        self.inst:RemoveEventCallback("burntup", self.onnextcheckpointremove, self.next_checkpoint)
        self.inst:RemoveEventCallback("yotc_racebegun", self.start_race, self.next_checkpoint)
	end

	self.next_checkpoint = checkpoint
	self.checkpoint_timer = GetTime()

	if checkpoint ~= nil then
		self.inst:ListenForEvent("onremove", self.onnextcheckpointremove, checkpoint)
		self.inst:ListenForEvent("burntup", self.onnextcheckpointremove, checkpoint)
		if is_starting_line then
			self.inst:ListenForEvent("yotc_racebegun", self.start_race, checkpoint)
		end
	end
end

function YOTC_RaceCompetitor:StartRace(delay)
	self.walkspeechdone = nil -- used for the players speech if the Carrat has a 0 in speed.
	if self.next_checkpoint ~= nil then
		if delay == nil then
			self.queuedstarttask = nil
			self.race_distance = 0
			self.checkpoints = {}
			self.checkpoints[self.next_checkpoint] = 0
			self.forgetfulness = 0
			self:RecoverStamina()

			self.prev_checkpoint = self.next_checkpoint
			self:_FindNextCheckPoint()
			self.inst:StartUpdatingComponent(self)
			self.racestate = "racing"

			if self.race_begun_fn ~= nil then
				self.race_begun_fn(self.inst)
			end
		elseif self.queuedstarttask == nil then
			self.queuedstarttask = self.inst:DoTaskInTime(delay, function() self:StartRace() end)
		end
	end
end

function YOTC_RaceCompetitor:FinishRace()
	self.inst:StopUpdatingComponent(self)
	self.racestate = "postrace"

	self.race_start_point = nil

	if self.queuedstarttask ~= nil then
		self.queuedstarttask:Cancel()
		self.queuedstarttask = nil
	end

	if self.race_finished_fn ~= nil then
		self.race_finished_fn(self.inst)
		self.race_finished_fn = nil -- so it does not get run again when the component is removed
	end
end

function YOTC_RaceCompetitor:AbortRace(prize_table)
	self:FinishRace()
	self:OnAllRacersFinished(nil)
	if TheWorld.components.yotc_raceprizemanager ~= nil then
		TheWorld.components.yotc_raceprizemanager:RemoveRacer(self.inst)
	end
end

function YOTC_RaceCompetitor:OnAllRacersFinished(prize_table)
	self.racestate = "raceover"
	self:_SetCheckPoint(nil)

	if prize_table ~= nil then
		self.inst:AddTag("has_prize")
	    self.race_prize = prize_table
	else
		self.inst:AddTag("has_no_prize")
	end

	if self.race_over_fn ~= nil then
		self.race_over_fn(self.inst)
		self.race_over_fn = nil -- so it does not get run again when the component is removed
	end
end

function YOTC_RaceCompetitor:SetRaceStartPoint(start_point_entity)
	self.race_start_point = start_point_entity
	self:_SetCheckPoint(start_point_entity, true)
end

local CHECKPOINT_MUST_TAGS = {"yotc_racecheckpoint"}
local CHECKPOINT_CANT_TAGS = {"fire", "burnt"}
function YOTC_RaceCompetitor:_FindNextCheckPoint()
	local cur_checkpoint = self.next_checkpoint

	if cur_checkpoint ~= nil and TheWorld.components.yotc_raceprizemanager then
		TheWorld.components.yotc_raceprizemanager:RegisterCheckpoint(self.inst, cur_checkpoint)
	end

	if self.prev_checkpoint ~= nil and self.prev_checkpoint:IsValid() and (self.isforgetful and math.random() < (self.forgetfulness*self.forgetfulness)/(TUNING.YOTC_RACER_FORGETFULNESS_MAX_CHECKPOINTS*TUNING.YOTC_RACER_FORGETFULNESS_MAX_CHECKPOINTS)) then
		self:_SetCheckPoint(self.prev_checkpoint)
		self.prev_checkpoint = nil
		self.forgetfulness = 0
		self.inst:PushEvent("carrat_error_direction")
	else
		if cur_checkpoint ~= nil then
			self.checkpoints[cur_checkpoint] = (self.checkpoints[cur_checkpoint] or 0) + 1
		end

		local x, y, z = (cur_checkpoint or self.inst).Transform:GetWorldPosition()
		local nearby_checkpoints = TheSim:FindEntities(x, y, z, TUNING.YOTC_RACER_CHECKPOINT_FIND_DIST + 0.1, CHECKPOINT_MUST_TAGS, CHECKPOINT_CANT_TAGS)
		if #nearby_checkpoints == 0 then
			x, y, z = self.inst.Transform:GetWorldPosition()
			nearby_checkpoints = TheSim:FindEntities(x, y, z, TUNING.YOTC_RACER_CHECKPOINT_FIND_DIST + 0.1, CHECKPOINT_MUST_TAGS, CHECKPOINT_CANT_TAGS)
		end
		if self.race_start_point ~= nil and self.race_start_point:IsValid() and (self.inst:IsNear(self.race_start_point, TUNING.YOTC_RACER_CHECKPOINT_FIND_DIST + 0.1) or (cur_checkpoint ~= nil and cur_checkpoint:IsNear(self.race_start_point, TUNING.YOTC_RACER_CHECKPOINT_FIND_DIST + 0.1))) then
			table.insert(nearby_checkpoints, self.race_start_point)
		end

		local priorities = {}
		for i, checkpoint in ipairs(nearby_checkpoints) do
			if checkpoint ~= cur_checkpoint and (self.checkpoints[checkpoint] == nil or self.checkpoints[checkpoint] <= TUNING.YOTC_RACER_MAX_VISITS_PER_CHECKPOINT) then
				table.insert(priorities, {checkpoint = checkpoint, val = (self.checkpoints[checkpoint] or checkpoint:HasTag("yotc_racefinishline") and 0.5 or 0) + (checkpoint == self.prev_checkpoint and 1 or 0), distsq = checkpoint:GetDistanceSqToPoint(x, y, z) })
			end
		end
		table.sort(priorities, function(a, b) return a.val < b.val or (a.val == b.val and a.distsq < b.distsq) end)

		self.prev_checkpoint = cur_checkpoint
		self:_SetCheckPoint(priorities[1] ~= nil and priorities[1].checkpoint or nil)

		if cur_checkpoint ~= nil and self.next_checkpoint ~= nil and self.checkpoints[self.next_checkpoint] == nil then
			self.race_distance = self.race_distance + math.sqrt(cur_checkpoint:GetDistanceSqToInst(self.next_checkpoint))
		end

		if self.isforgetful then
			self.forgetfulness = self.forgetfulness + 1
		end
	end
end

function YOTC_RaceCompetitor:OnUpdate(dt)
	if GetTime() - self.checkpoint_timer > TUNING.YOTC_RACER_CHECKPOINT_TIMEOUT then
		self:AbortRace()
		return
	end

	if self.next_checkpoint == nil or not self.inst:IsNear(self.next_checkpoint, TUNING.YOTC_RACER_CHECKPOINT_TOO_FAR_AWAY) then
		self:_FindNextCheckPoint()
		if self.next_checkpoint == nil then
			self:AbortRace()
			return
		end
	end

	if self.inst:IsNear(self.next_checkpoint, TUNING.YOTC_RACER_CHECKPOINT_REACHED_DIST) then
		self.next_checkpoint:PushEvent("yotc_racer_at_checkpoint", {racer = self.inst})

		if self.next_checkpoint:HasTag("yotc_racefinishline") then
            if TheWorld.components.yotc_raceprizemanager ~= nil then
				TheWorld.components.yotc_raceprizemanager:RegisterCheckpoint(self.inst, self.next_checkpoint)
            end
			self:FinishRace()
            if TheWorld.components.yotc_raceprizemanager ~= nil then
				self.finished_first = TheWorld.components.yotc_raceprizemanager:RacerFinishedRace(self.inst, self.race_distance)
			end
		else
			self:_FindNextCheckPoint()

			if self.next_checkpoint == nil then
				-- race failure, no consolation prize
				self:AbortRace()
			end
		end
	end

	if not self.inst.sg:HasStateTag("exhausted") and not self.inst:HasTag("sleeping") and self.latestartertask == nil then
		if self.inst:HasTag("moving") then
			self.stamina = self.stamina - dt
		end
		if self.stamina <= 0 then
			self.inst:PushEvent("yotc_racer_exhausted")

			if self.recover_stamina_task == nil then
				self.recover_stamina_task = self.inst:DoTaskInTime(self.exhausted_time + math.random() * self.exhausted_time_var, function() self:RecoverStamina() end)
			end
		end
	end
end

local function on_late_start_finished(inst)
	if inst.components.yotc_racecompetitor ~= nil then
		inst.components.yotc_racecompetitor.latestartertask = nil
	end
end

function YOTC_RaceCompetitor:SetLateStarter(start_delay)
	self.latestartertask = self.inst:DoTaskInTime(start_delay, on_late_start_finished)
end

function YOTC_RaceCompetitor:IsStartingLate()
	return self.latestartertask ~= nil
end

function YOTC_RaceCompetitor:IsExhausted()
	return self.recover_stamina_task ~= nil
end

function YOTC_RaceCompetitor:RecoverStamina()
	self.stamina = self.stamina_max + math.random() * self.stamina_max_var
	if self.recover_stamina_task ~= nil then
		self.recover_stamina_task:Cancel()
		self.recover_stamina_task = nil
	end
end

function YOTC_RaceCompetitor:CollectPrize()
    if self.race_prize ~= nil then
        local pouch = SpawnPrefab("redpouch_yotc")
        pouch.Transform:SetPosition(self.inst.Transform:GetWorldPosition())

        local prize_items = {}
        for _, p in ipairs(self.race_prize) do
            table.insert(prize_items, SpawnPrefab(p))
        end
        pouch.components.unwrappable:WrapItems(prize_items)
		for i, v in ipairs(prize_items) do
			v:Remove()
		end

        self.inst:RemoveTag("has_prize")
        return pouch

    elseif self.inst:HasTag("has_no_prize") then
        self.inst:RemoveTag("has_no_prize")
        return nil

    end

    return nil
end

function YOTC_RaceCompetitor:GetDebugString()
    local s = string.format( "Check Point: %s, Race State: %s, Is Forgetful: %s (%.2f), Stamina: %0.2f/%0.2f %s, Race Dist: %0.2f", tostring(self.next_checkpoint), tostring(self.racestate), tostring(self.isforgetful), self.forgetfulness, self.stamina, self.stamina_max + self.stamina_max_var, self:IsExhausted() and "(Exhausted)" or "", self.race_distance or 0 )
    return s
end

return YOTC_RaceCompetitor
