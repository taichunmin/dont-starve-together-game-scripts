local Growable = Class(function(self, inst)
    self.inst = inst
    self.stages = nil
    self.stage = 1
    --self.loopstages = false
	--self.loopstages_start = 1
    --self.growonly = false
    --self.springgrowth = false
    --self.growoffscreen = false
    --self.magicgrowable = false
    --self.usetimemultiplier = false
end)

function Growable:GetDebugString()
    return (self.targettime ~= nil and self.stage ~= self:GetNextStage() and string.format("Growing! stage %d, timeleft %2.2fs", self.stage, self.targettime - GetTime()))
        or (self.pausedremaining ~= nil and string.format("Paused! stage %d, timeleft %2.2fs", self.stage, self.pausedremaining))
        or "Not Growing"
end

local function ongrow(inst, self)
    self:DoGrowth()
end

function Growable:StartGrowing(time)
    self.usetimemultiplier = false
    if #self.stages == 0 then
        print "Growable component: Trying to grow without setting the stages table"
        return
    end

    if self.stage <= #self.stages then
        self:StopGrowing()

        local timeToGrow = 10
        if time ~= nil then
            timeToGrow = time
        elseif self.stages[self.stage].time ~= nil then
            timeToGrow = self.stages[self.stage].time(self.inst, self.stage, self.stages[self.stage])
            if self.stages[self.stage].multiplier then
                self.usetimemultiplier = true
            end
        end

        if timeToGrow ~= nil then
            if self.springgrowth and TheWorld.state.isspring then
                timeToGrow = timeToGrow * TUNING.SPRING_GROWTH_MODIFIER
            end
            self.targettime = GetTime() + timeToGrow

            if self.growoffscreen or not self.inst:IsAsleep() then
                if self.task ~= nil then
                    self.task:Cancel()
                end
                self.task = self.inst:DoTaskInTime(timeToGrow, ongrow, self)
            end
        end
    end
end

function Growable:GetNextStage()
    local stage = self.stage + 1
    if stage > #self.stages then
        if self.loopstages then
            stage = self.loopstages_start or 1
        else
            stage = #self.stages
        end
    end
    return stage
end

function Growable:DoMagicGrowth(doer)
	return self.domagicgrowthfn ~= nil and self.domagicgrowthfn(self.inst, doer)
end

function Growable:DoGrowth()
    if self.targettime == nil and self.pausedremaining == nil then
        --neither started nor paused, which means we're fully stopped
        return false
    end

    local stage = self:GetNextStage()

    if self.stages[stage] ~= nil and self.stages[stage].pregrowfn ~= nil then
        self.stages[stage].pregrowfn(self.inst, stage)
    end

    if not self.growonly then
        self:SetStage(stage)
    end

	if self.inst:IsValid() then
		if self.stages[stage] ~= nil and self.stages[stage].growfn ~= nil then
			self.stages[stage].growfn(self.inst)
		end

		if self.stage < #self.stages or self.loopstages then
			self:StartGrowing()
		end
	end

	return true
end

function Growable:IsGrowing()
    return self.targettime ~= nil
end

function Growable:StopGrowing()
    self.targettime = nil
    self.pausedremaining = nil

    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
end

function Growable:Pause()
	if self.pausedremaining == nil then
		local targettime = self.targettime
		self:StopGrowing()
		self.pausedremaining = targettime ~= nil and math.floor(targettime - GetTime()) or nil
	end
end

function Growable:Resume()
    if self.pausedremaining ~= nil then
        local _usetimemultiplier = self.usetimemultiplier
        self:StartGrowing(math.max(0, self.pausedremaining))
        self.usetimemultiplier = _usetimemultiplier
        self.pausedremaining = nil
		return true
    end
end

function Growable:ExtendGrowTime(extra_time)
	if self.targettime ~= nil then
		self.targettime = self.targettime + extra_time
	end
	if self.pausedremaining ~= nil then
		self.pausedremaining = self.pausedremaining + extra_time
	end

    if self.task ~= nil then
        self.task:Cancel()
        self.task = self.inst:DoTaskInTime(self.targettime - GetTime(), ongrow, self)
    end
end

function Growable:GetStage()
    return self.stage
end

function Growable:SetStage(stage)
    if stage > #self.stages then
        stage = #self.stages
    end

    self.stage = stage

    if self.stages[stage] ~= nil and self.stages[stage].fn ~= nil then
        self.stages[stage].fn(self.inst, stage, self.stages[stage])
    end
end

function Growable:GetCurrentStageData()
    return self.stages[self.stage]
end

local function GetStageTimeMultiplier(self)
    return self.stages and self.stages[self.stage] and self.stages[self.stage].multiplier or 1
end

function Growable:OnSave()
    local time = (self.pausedremaining ~= nil and math.floor(self.pausedremaining)) or (self.targettime ~= nil and math.floor(self.targettime - GetTime())) or nil
    if time then
        time = math.max(0, time)
        if self.usetimemultiplier then
            time = time / GetStageTimeMultiplier(self)
        end
    end
    local data =
    {
        stage = self.stage,
        time = time,
        usetimemultiplier = self.usetimemultiplier,
    }
    return next(data) ~= nil and data or nil
end

function Growable:OnLoad(data)
    if data ~= nil then
        self:SetStage(data.stage or 1) --1 is kind of by default
        if data.time ~= nil then
            if data.usetimemultiplier then
                self.usetimemultiplier = true
                data.time = data.time * GetStageTimeMultiplier(self)
            end
            self:StartGrowing(math.max(0, data.time))
        end
    end
end

function Growable:LongUpdate(dt)
    if self.targettime ~= nil then
        local _usetimemultiplier = self.usetimemultiplier
        self:StartGrowing(math.max(0, self.targettime - dt - GetTime()))
        self.usetimemultiplier = _usetimemultiplier
    end
end

function Growable:OnEntitySleep()
    if self.task ~= nil and not self.growoffscreen then
        self.task:Cancel()
        self.task = nil
    end
end

function Growable:OnEntityWake()
    if self.targettime ~= nil and not self.growoffscreen then
        local time = GetTime()
        if self.targettime <= time then
            self:DoGrowth()
        else
            if self.task ~= nil then
                self.task:Cancel()
            end
            self.task = self.inst:DoTaskInTime(self.targettime - time, ongrow, self)
        end
    end
end

Growable.OnRemoveFromEntity = Growable.StopGrowing

return Growable
