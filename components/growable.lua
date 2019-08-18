local Growable = Class(function(self, inst)
    self.inst = inst
    self.stages = nil
    self.stage = 1
    self.loopstages = false
    self.growonly = false
    self.springgrowth = false
    --self.growoffscreen = false
    self.magicgrowable = false
end)

function Growable:GetDebugString()
    return (self.targettime ~= nil and string.format("Growing! stage %d, timeleft %2.2fs", self.stage, self.targettime - GetTime()))
        or (self.pausedremaining ~= nil and string.format("Paused! stage %d, timeleft %2.2fs", self.stage, self.pausedremaining))
        or "Not Growing"
end

local function ongrow(inst, self)
    self:DoGrowth()
end

function Growable:StartGrowing(time)
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
            timeToGrow = self.stages[self.stage].time(self.inst, self.stage)
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
            stage = 1
        else
            stage = #self.stages
        end
    end
    return stage
end

function Growable:DoGrowth()
    if self.targettime == nil and self.pausedremaining == nil then
        --neither started nor paused, which means we're fully stopped
        return
    end

    local stage = self:GetNextStage()

    if not self.growonly then
        self:SetStage(stage)
    end

    if self.stages[stage] ~= nil and self.stages[stage].growfn ~= nil then
        self.stages[stage].growfn(self.inst)
    end

    if self.stage < #self.stages or self.loopstages then 
        self:StartGrowing()
    end
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
    local targettime = self.targettime
    self:StopGrowing()
    self.pausedremaining = targettime ~= nil and math.floor(targettime - GetTime()) or nil
end

function Growable:Resume()
    if self.pausedremaining ~= nil then
        local remainingtime = math.max(0, self.pausedremaining)
        self.pausedremaining = nil
        self:StartGrowing(remainingtime)
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
        self.stages[stage].fn(self.inst)
    end
end

function Growable:GetCurrentStageData()
    return self.stages[self.stage]
end

function Growable:OnSave()
    local data =
    {
        stage = self.stage ~= 1 and self.stage or nil, --1 is kind of by default
        time = (self.pausedremaining ~= nil and math.floor(self.pausedremaining))
            or (self.targettime ~= nil and math.floor(self.targettime - GetTime()))
            or nil,
    }
    return next(data) ~= nil and data or nil
end

function Growable:OnLoad(data)
    if data ~= nil then
        self:SetStage(data.stage or self.stage)
        if data.time ~= nil then
            self:StartGrowing(math.max(0, data.time))
        end
    end
end

function Growable:LongUpdate(dt)
    if self.targettime ~= nil then
        local time_from_now = math.max(0, self.targettime - dt - GetTime())
        self:StartGrowing(time_from_now)
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
