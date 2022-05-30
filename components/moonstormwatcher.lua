local MoonstormWatcher = Class(function(self, inst)
    self.inst = inst

    self.moonstormlevel = 0
    self.moonstormspeedmult = TUNING.MOONSTORM_SPEED_MOD
    self.delay = nil

    if TheWorld.net.components.moonstorms ~= nil then
        inst:ListenForEvent("ms_stormchanged", function(src, data) self:ToggleMoonstorms(data) end, TheWorld)
        -- self:ToggleMoonstorms(TheWorld.components.moonstorms:IsMoonstormActive())
        self:ToggleMoonstorms({setting=false})
    end
end)

local function UpdateMoonstormWalkSpeed(inst)
    inst.components.moonstormwatcher:UpdateMoonstormWalkSpeed()
end

local function AddMoonstormWalkSpeedListeners(inst)
    inst:ListenForEvent("gogglevision", UpdateMoonstormWalkSpeed)
    inst:ListenForEvent("ghostvision", UpdateMoonstormWalkSpeed)
    inst:ListenForEvent("mounted", UpdateMoonstormWalkSpeed)
    inst:ListenForEvent("dismounted", UpdateMoonstormWalkSpeed)
end

local function RemoveMoonstormWalkSpeedListeners(inst)
    inst:RemoveEventCallback("gogglevision", UpdateMoonstormWalkSpeed)
    inst:RemoveEventCallback("ghostvision", UpdateMoonstormWalkSpeed)
    inst:RemoveEventCallback("mounted", UpdateMoonstormWalkSpeed)
    inst:RemoveEventCallback("dismounted", UpdateMoonstormWalkSpeed)
    inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "moonstorm")
end

function MoonstormWatcher:OnRemoveFromEntity()
    self:ToggleMoonstorms({setting=false})
end

function MoonstormWatcher:ToggleMoonstorms(data)
    if data.setting then
        if self.moonstormspeedmult < 1 then
            AddMoonstormWalkSpeedListeners(self.inst)
        end
        self:UpdateMoonstormLevel()
    else
        if self.moonstormspeedmult < 1 then
            RemoveMoonstormWalkSpeedListeners(self.inst)
        end
    end
end

function MoonstormWatcher:SetMoonstormSpeedMultiplier(mult)
    mult = math.clamp(mult, 0, 1)
    if self.moonstormspeedmult ~= mult then
        if mult < 1 then
            if self.moonstormspeedmult >= 1 then
                AddMoonstormWalkSpeedListeners(self.inst)
            end
            self.moonstormspeedmult = mult
            self:UpdateMoonstormWalkSpeed()
        else
            self.moonstormspeedmult = 1
            RemoveMoonstormWalkSpeedListeners(self.inst)
        end
    end
end

function MoonstormWatcher:UpdateMoonstormLevel()
    self:UpdateMoonstormWalkSpeed()
end

function MoonstormWatcher:UpdateMoonstormWalkSpeed()
    local level = self:GetMoonStormLevel()
    if level and self.moonstormspeedmult < 1 then

        if level < TUNING.SANDSTORM_FULL_LEVEL or
            self.inst.components.playervision:HasGoggleVision() or
            self.inst.components.playervision:HasGhostVision() or
            self.inst.components.rider:IsRiding() then
            self.inst.components.locomotor:RemoveExternalSpeedMultiplier(self.inst, "moonstorm")
        else
            self.inst.components.locomotor:SetExternalSpeedMultiplier(self.inst, "moonstorm", self.moonstormspeedmult)
        end
    end
    self.inst:PushEvent("moonstormlevel",{level = level})
end

function MoonstormWatcher:GetMoonStormLevel()
    if self.inst.components.stormwatcher then
        return self.inst.components.stormwatcher.stormlevel
    end
    return nil
end

return MoonstormWatcher