local FrostyBreather = Class(function(self, inst)
    self.inst = inst
    self.breath = nil
    self.offset = Vector3(0, 0, 0)
    self.offset_fn = nil
    self.enabled = true
    self.forced_breath = false

    self.breathevent = net_event(inst.GUID, "frostybreather.breathevent")

    self:WatchWorldState("temperature", self.OnTemperatureChanged)
    self:OnTemperatureChanged(TheWorld.state.temperature)
end)

function FrostyBreather:OnRemoveFromEntity()
    self:StopWatchingWorldState("temperature", self.OnTemperatureChanged)
    self:StopBreath()
end

local function OnBreathEvent(inst)
    inst.components.frostybreather:EmitOnce()
end

local function OnAnimOver(inst)
    if inst.sg:HasStateTag("idle") then
        inst.components.frostybreather.breathevent:push()
        OnBreathEvent(inst)
    end
end

local function StartBreathListeners(self)
    if TheWorld.ismastersim then
        self.inst:ListenForEvent("animover", OnAnimOver)
    else
        self.inst:ListenForEvent("frostybreather.breathevent", OnBreathEvent)
    end
end

local function StopBreathListeners(self)
    if TheWorld.ismastersim then
        self.inst:RemoveEventCallback("animover", OnAnimOver)
    else
        self.inst:RemoveEventCallback("frostybreather.breathevent", OnBreathEvent)
    end
end

function FrostyBreather:StartBreath()
    if self.breath == nil then
        self.breath = SpawnPrefab("frostbreath")
        self.inst:AddChild(self.breath)
        self.breath.Transform:SetPosition(self:GetOffset())
        if self.enabled then
            StartBreathListeners(self)
        end
    end
end

function FrostyBreather:StopBreath()
    if self.breath ~= nil then
        self.inst:RemoveChild(self.breath)
        self.breath:Remove()
        self.breath = nil
        if self.enabled then
            StopBreathListeners(self)
        end
    end
end

function FrostyBreather:Enable()
    self.enabled = true
    if self.breath ~= nil then
        StartBreathListeners(self)
    end
end

function FrostyBreather:Disable()
    self.enabled = false
    if self.breath ~= nil then
        StopBreathListeners(self)
    end
end

function FrostyBreather:OnTemperatureChanged(temperature)
    if not self.forced_breath then
        if temperature > TUNING.FROSTY_BREATH then
            self:StopBreath()
        else
            self:StartBreath()
        end
    end
end

function FrostyBreather:EmitOnce()
    if self.breath ~= nil then
        local facing = self.inst.AnimState:GetCurrentFacing()
        if facing ~= FACING_UP and
            facing ~= FACING_UPRIGHT and
            facing ~= FACING_UPLEFT then
            self.breath.Transform:SetPosition(self:GetOffset())
            self.breath:Emit()
        end
    end
end

function FrostyBreather:ForceBreathOn()
    if not self.forced_breath then
        self.forced_breath = true
        self:StartBreath()
    end
end

function FrostyBreather:ForceBreathOff()
    if self.forced_breath then
        self.forced_breath = false
        self:OnTemperatureChanged(TheWorld.state.temperature)
    end
end

function FrostyBreather:SetOffset(x, y, z)
    self.offset.x, self.offset.y, self.offset.z = x, y, z
end

function FrostyBreather:SetOffsetFn(fn)
    self.offset_fn = fn
end

function FrostyBreather:GetOffset()
    local offset = self.offset_fn ~= nil and self.offset_fn(self.inst) or self.offset
    return offset:Get()
end

return FrostyBreather
