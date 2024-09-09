local Disappears = Class(function(self, inst)
    self.inst = inst
    self.delay = 25
    self.disappearsFn = nil
    self.sound = nil
    self.anim = "disappear"
    self.disappeartask = nil
    self.tasktotime = nil
    self.isdisappear = nil
end)

function Disappears:Disappear()
    if self.isdisappear then
        --already triggered disappear
        return
    end

    self.isdisappear = true

    if self.disappeartask ~= nil then
        self.disappeartask:Cancel()
        self.disappeartask = nil
    end

    if self.disappearFn ~= nil then
        self.disappearFn(self.inst)
    end

    if self.inst:IsAsleep() then
        self.inst:Remove()
        return
    end

    self.inst.persists = false
    self.inst:AddTag("NOCLICK")

    if self.inst.components.inventoryitem ~= nil then
        self.inst.components.inventoryitem.canbepickedup = false
        self.inst.components.inventoryitem.canbepickedupalive = false
    end

    if self.sound ~= nil then
        self.inst.SoundEmitter:PlaySound(self.sound)
    end
    self.inst.AnimState:PlayAnimation(self.anim)
    self.inst:ListenForEvent("animover", self.inst.Remove)
    --timer removal in case animation is paused off screen
    self.inst:DoTaskInTime(self.inst.AnimState:GetCurrentAnimationLength() + .1, self.inst.Remove)
end

function Disappears:StopDisappear()
    if self.isdisappear then
        --already triggered disappear
        return
    end
    if self.disappeartask ~= nil then
        self.disappeartask:Cancel()
        self.disappeartask = nil
    end
    self.tasktotime = nil
end

local function OnDisappear(inst, self)
    self.disappeartask = nil
    self:Disappear()
end

function Disappears:PrepareDisappear()
    if self.isdisappear then
        --already triggered disappear
        return
    end
    self:StopDisappear()
    local delay = self.delay + math.random() * 10
    self.disappeartask = self.inst:DoTaskInTime(delay, OnDisappear, self)
    self.tasktotime = GetTime() + delay
end

function Disappears:GetDebugString()
    return (self.isdisappear and "DISAPPEAR")
        or (self.tasktotime ~= nil and string.format("ACTIVE countdown: %2.2f", math.max(0, self.tasktotime - GetTime())))
        or "INACTIVE"
end

Disappears.OnRemoveFromEntity = Disappears.StopDisappear

return Disappears
