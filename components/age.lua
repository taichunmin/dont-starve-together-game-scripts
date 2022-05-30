local SYNC_PERIOD = 10

local function syncage(inst, self)
	local cur_age = self:GetDisplayAgeInDays()
	if inst.Network:GetPlayerAge() ~= cur_age then
		if cur_age == 20 then
			AwardPlayerAchievement( "survive_20", inst)
		elseif cur_age == 35 then
			AwardPlayerAchievement( "survive_35", inst)
		elseif cur_age == 55 then
			AwardPlayerAchievement( "survive_55", inst)
		elseif cur_age == 70 then
			AwardPlayerAchievement( "survive_70", inst)
		end
		NotifyPlayerProgress("days", cur_age,  inst)
		NotifyPlayerPresence(ShardGameIndex:GetGameMode(), 1, cur_age, inst)
	end
    inst.Network:SetPlayerAge(self:GetDisplayAgeInDays())
end

local function OnSetOwner(inst)
    syncage(inst, inst.components.age)
end

local Age = Class(function(self, inst)
    self.inst = inst

    self.saved_age = 0
    self.paused_time = 0
    self.spawntime = GetTime()
    self.last_pause_time = nil
    self._synctask = nil

    self:RestartPeriodicSync()
    inst:ListenForEvent("setowner", OnSetOwner)
end)

function Age:CancelPeriodicSync()
    if self._synctask ~= nil then
        self._synctask:Cancel()
        self._synctask = nil
    end
    syncage(self.inst, self)
end

function Age:RestartPeriodicSync()
    self:CancelPeriodicSync()
    self._synctask = self.inst:DoPeriodicTask(SYNC_PERIOD, syncage, nil, self)
end

function Age:GetAge()
	return self.saved_age + (self.last_pause_time or GetTime()) - self.spawntime - self.paused_time
end

function Age:GetAgeInDays()
	return math.floor(self:GetAge() / TUNING.TOTAL_DAY_TIME)
end

function Age:GetDisplayAgeInDays()
	return math.floor(self:GetAge() / TUNING.TOTAL_DAY_TIME) + 1
end

function Age:PauseAging()
    if self.last_pause_time == nil then
	   self.last_pause_time = GetTime()
       self:CancelPeriodicSync()
    end
end

function Age:ResumeAging()
	if self.last_pause_time ~= nil then
		self.paused_time = self.paused_time + (GetTime() - self.last_pause_time)
		self.last_pause_time = nil
        self:RestartPeriodicSync()
	end
end

function Age:OnSave()
    return
    {
		age = self:GetAge(),
        ispaused = self.last_pause_time ~= nil or nil,
	}
end

function Age:GetDebugString()
    if self:GetAge() > .5*TUNING.TOTAL_DAY_TIME then
		return string.format("%2.2f days", self:GetAge() / TUNING.TOTAL_DAY_TIME)
	else
		return string.format("%2.2f s", self:GetAge())
	end
end

function Age:LongUpdate(dt)
	self.saved_age = self.saved_age + dt
    if self.last_pause_time ~= nil then
        self.paused_time = self.paused_time + dt
    else
        self:RestartPeriodicSync()
    end
end

function Age:OnLoad(data)
	if data ~= nil then
		self.saved_age = data.age or 0
        if data.ispaused then
            self.last_pause_time = self.spawntime
            self:CancelPeriodicSync()
        else
            self:RestartPeriodicSync()
        end
	end
end

return Age
