local SandStormWatcher = Class(function(self, inst)
    self.inst = inst
    self.sandstormspeedmult = TUNING.SANDSTORM_SPEED_MOD
end)

local function UpdateSandstormWalkSpeed(inst)
    inst.components.sandstormwatcher:UpdateSandstormWalkSpeed()
end

local function AddSandstormWalkSpeedListeners(inst)
    inst:ListenForEvent("gogglevision", UpdateSandstormWalkSpeed)
    inst:ListenForEvent("ghostvision", UpdateSandstormWalkSpeed)
    inst:ListenForEvent("mounted", UpdateSandstormWalkSpeed)
    inst:ListenForEvent("dismounted", UpdateSandstormWalkSpeed)
end

local function RemoveSandstormWalkSpeedListeners(inst)
    inst:RemoveEventCallback("gogglevision", UpdateSandstormWalkSpeed)
    inst:RemoveEventCallback("ghostvision", UpdateSandstormWalkSpeed)
    inst:RemoveEventCallback("mounted", UpdateSandstormWalkSpeed)
    inst:RemoveEventCallback("dismounted", UpdateSandstormWalkSpeed)
    inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "sandstorm")
end

function SandStormWatcher:ToggleSandstorms(active)
    if active then
        if self.sandstormspeedmult < 1 then
            AddSandstormWalkSpeedListeners(self.inst)
        end
    else
        if self.sandstormspeedmult < 1 then
            RemoveSandstormWalkSpeedListeners(self.inst)
        end
    end
end

function SandStormWatcher:SetSandstormSpeedMultiplier(mult)
    mult = math.clamp(mult, 0, 1)
    if self.sandstormspeedmult ~= mult then
        if mult < 1 then
            if self.sandstormspeedmult >= 1 then
                AddSandstormWalkSpeedListeners(self.inst)
            end
            self.sandstormspeedmult = mult
            self:UpdateSandstormWalkSpeed()
        else
            self.sandstormspeedmult = 1
            RemoveSandstormWalkSpeedListeners(self.inst)
        end
    end
end

function SandStormWatcher:UpdateSandstormLevel()
    self:UpdateSandstormWalkSpeed()
end

function SandStormWatcher:UpdateSandstormWalkSpeed()
    local level = self:GetSandstormLevel()
    if level and self.sandstormspeedmult < 1 then
        if level < TUNING.SANDSTORM_FULL_LEVEL or
            self.inst.components.playervision:HasGoggleVision() or
            self.inst.components.playervision:HasGhostVision() or
            self.inst.components.rider:IsRiding() then
            self.inst.components.locomotor:RemoveExternalSpeedMultiplier(self.inst, "sandstorm")
        else
            self.inst.components.locomotor:SetExternalSpeedMultiplier(self.inst, "sandstorm", self.sandstormspeedmult)
        end
    end
    self.inst:PushEvent("sandstormlevel",{level = level})
end

function SandStormWatcher:GetSandstormLevel()
    if self.inst.components.stormwatcher then
        return self.inst.components.stormwatcher.stormlevel
    end
    return nil
end

return SandStormWatcher
