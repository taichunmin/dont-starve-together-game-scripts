local TargetTracker = Class(function(self, inst)
    self.inst = inst

    self.target = nil
    self.timetracking = nil
    self.pausetime = nil

    self.onresettarget = nil
    self.onpausefn = nil
    self.onresumefn = nil
    self.ontimeupdatefn = nil
    self.shouldkeeptrackingfn = nil

    self._updating = false
end)

----------------------------------------------------------------------------------------------------

function TargetTracker:SetOnResetTarget(fn)
    self.onresettarget = fn
end

function TargetTracker:SetOnPauseFn(fn)
    self.onpausefn = fn
end

function TargetTracker:SetOnResumeFn(fn)
    self.onresumefn = fn
end

function TargetTracker:SetOnTimeUpdateFn(fn)
    self.ontimeupdatefn = fn
end

function TargetTracker:SetShouldKeepTrackingFn(fn)
    self.shouldkeeptrackingfn = fn
end

----------------------------------------------------------------------------------------------------

function TargetTracker:HasTarget()
    return self.target ~= nil
end

function TargetTracker:IsTracking(testtarget)
    return self.target == testtarget
end

function TargetTracker:IsPaused()
    return self.pausetime ~= nil
end

function TargetTracker:IsCloningTarget()
    return (self.timetracking or 0) <= 0 and self:IsPaused()
end

function TargetTracker:GetTimeTracking()
    return self.timetracking
end

----------------------------------------------------------------------------------------------------

function TargetTracker:SetTimeTracking(time)
    self.timetracking = time

    if self.ontimeupdatefn ~= nil then
        self.ontimeupdatefn(self.inst, self.timetracking, 0)
    end
end

function TargetTracker:CloneTargetFrom(item, pausetime)
    if item.components.targettracker.timetracking == nil or item.components.targettracker.target == nil then
        return
    end

    self.inst.components.targettracker:TrackTarget(item.components.targettracker.target)

    if pausetime ~= nil then
        self.inst.components.targettracker:Pause(pausetime)
        item.components.targettracker:Pause(pausetime)
    end
end

----------------------------------------------------------------------------------------------------

function TargetTracker:TrackTarget(target)
    if self:HasTarget() then
        return
    end

    self.target = target
    self.timetracking = 0

    self.inst:PushEvent("targettracker_starttrack", target)

    self.targetremovedfn = function() self:StopTracking(true) end
    self.inst:ListenForEvent("onremove", self.targetremovedfn)

    self._updating = true
    self.inst:StartUpdatingComponent(self)
end

function TargetTracker:StopTracking(reset)
    self.target = nil
    self.timetracking = nil
    self.pausetime = nil

    self.inst:PushEvent("targettracker_stoptrack")

    if self.targetremovedfn ~= nil then
        self.inst:RemoveEventCallback("onremove", self.targetremovedfn)
        self.targetremovedfn = nil
    end

    if reset and self.onresettarget ~= nil then
        self.onresettarget(self.inst, self.target)
    end

    if self._updating then
        self._updating = false
        self.inst:StopUpdatingComponent(self)
    end
end

----------------------------------------------------------------------------------------------------

function TargetTracker:Pause(time)
    self.pausetime = time

    if self.onpausefn ~= nil then
        self.onpausefn(self.inst)
    end
end

----------------------------------------------------------------------------------------------------

function TargetTracker:OnUpdate(dt)
    if not self._updating then return end -- For LongUpdate.

    if self.target == nil or
        not self.target:IsValid() or
        self.target:IsInLimbo() or
        self.target:IsAsleep() or
        self.target.components.health == nil or
        self.target.components.health:IsDead() or
        (self.shouldkeeptrackingfn ~= nil and not self.shouldkeeptrackingfn(self.inst, self.target))
    then
        self:StopTracking(true)
        return
    end

    if self:IsPaused() then
        self.pausetime = self.pausetime - dt

        if self.pausetime <= 0 then
            self.pausetime = nil

            if self.onresumefn then
                self.onresumefn(self.inst)
            end
        end

    elseif self.timetracking ~= nil then
        self.lasttime     = self.timetracking
        self.timetracking = self.timetracking + dt

        if self.ontimeupdatefn ~= nil then
            self.ontimeupdatefn(self.inst, self.timetracking, self.lasttime)
        end
    end
end

TargetTracker.LongUpdate = TargetTracker.OnUpdate

----------------------------------------------------------------------------------------------------

function TargetTracker:GetDebugString()
    return string.format(
        "Target: %s || Time Tracking: %d || Pause Time: %d || Updating: %s",
        tostring(self.target) or "???",
        self.timetracking or 0,
        self.pausetime or 0,
        self._updating and "ON" or "OFF"
    )
end

return TargetTracker