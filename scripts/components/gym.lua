
local Gym = Class(function(self, inst)
    self.inst = inst
    self.trainfn = nil
    self.trainee = nil
    self.inst:ListenForEvent("timerdone", function(inst, data) self:OnTimerDone(data) end )

    self.inst:WatchWorldState("phase", function(inst, phase) self:checktraineesleep(phase) end )

    self.traintime = TUNING.CARRAT_GYM.TRAINING_TIME
end)

function Gym:SetOnRemoveTraineeFn(fn)
    self.onLoseTraineeFn = fn
end

function Gym:RemoveTrainee()
    if self.trainee then
        if self.onLoseTraineeFn then
            self.onLoseTraineeFn(self.inst)
        end
        self.inst:RemoveEventCallback("onremove", self._removetrainee, self.trainee)
        self.inst:RemoveEventCallback("death", self._removetrainee, self.trainee)
        self._removetrainee = nil
        self.trainee = nil
    end
    if self.inst.components.timer:TimerExists("training") then
        self:StopTraining()
    end
end

function Gym:SetTrainee(inst)
    if inst ~= nil then
        self.trainee = inst
        self._removetrainee = function() self:RemoveTrainee() end
        self.inst:ListenForEvent("onremove", self._removetrainee, inst )
        self.inst:ListenForEvent("death", self._removetrainee, inst )
    end
end

function Gym:SetTrainFn(fn)
    self.trainfn = fn
end

function Gym:PushMontage()
    if self.trainee and not TheWorld.state.isnight then
        self.inst._musicstate:set(CARRAT_MUSIC_STATES.NONE)
        self.inst._musicstate:set(CARRAT_MUSIC_STATES.TRAINING)
    end
end

function Gym:StartTraining(inst, time)
    if not time then
        time = self.traintime
    end
    if not self.inst.components.timer:TimerExists("training") then
        self.inst.components.timer:StartTimer("training", time )
    end
    if TheWorld.state.isnight then
        self.inst:PushEvent("rest")
    else
        self.inst:PushEvent("starttraining")
    end
    self.perishcheck = self.inst:DoPeriodicTask(5,function() self:CheckPerish() end)
    self:PushMontage()
    self.montagemusic = self.inst:DoPeriodicTask(4,function() self:PushMontage() end)
end

function Gym:StopTraining()
	self.inst._musicstate:set(CARRAT_MUSIC_STATES.NONE)
    self.inst.components.timer:StopTimer("training")
    self.inst:PushEvent("endtraining")
    if self.resttask then
        self.resttask:Cancel()
        self.resttask = nil
    end
    if self.perishcheck then
        self.perishcheck:Cancel()
        self.perishcheck = nil
    end
    if self.montagemusic then
        self.montagemusic:Cancel()
        self.montagemusic = nil
    end
end

function Gym:CheckPerish()
    if self.trainee and self.trainee.components.perishable then
        if self.inst.components.timer:TimerExists("training") and self.trainee.components.perishable:GetPercent() < 0.1 then
            if math.random() < 0.3 then
                self.inst:PushEvent("endtraining")
                self.resttask = self.inst:DoTaskInTime((math.random()*2)+2,function()
                    if self.inst.components.timer:TimerExists("training") and self.trainee then
                        self.inst:PushEvent("starttraining")
                    end
                end)
            end
        end
    end
end

function Gym:OnTimerDone(data)
    if data.name == "training" then
        self:StopTraining()
        self:Train()
    end
end

function Gym:Train()
    if self.trainfn and self.trainee then
        if not self.trainee.training then
            self.trainee.training = 0
        end
        self.trainee.training = self.trainee.training + 1
        self.trainfn(self.inst,self.trainee)
    end
end

function Gym:checktraineesleep(phase)
    if self.trainee then
        if phase == "night" then
            self.inst:PushEvent("rest")
        elseif phase == "day" then
            self.inst:PushEvent("endrest")
        end
    end
end

function Gym:OnSave()
    return
    {
        timer = self.inst.components.timer:TimerExists("training") and self.inst.components.timer:GetTimeLeft("training") or nil
    }
end

function Gym:LoadPostPass(newents, data)
    if data.timer then
        self.inst:DoTaskInTime(0, function()
		    self:StartTraining(self.inst, data.timer)
        end)
    end
end

function Gym:GetDebugString()
    return string.format("nothing yet")
end

return Gym
