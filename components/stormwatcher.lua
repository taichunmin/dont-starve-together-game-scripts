local function onsandstormlevel(self, sandstormlevel)
    if self.inst.player_classified ~= nil then
        self.inst.player_classified.sandstormlevel:set(math.floor(sandstormlevel * 7 + .5))
    end
end

local StormWatcher = Class(function(self, inst)
    self.inst = inst

    self.sandstormlevel = 0
    self.sandstormspeedmult = TUNING.SANDSTORM_SPEED_MOD
    self.delay = nil

    if TheWorld.components.sandstorms ~= nil then
        inst:ListenForEvent("ms_sandstormchanged", function(src, data) self:ToggleSandstorms(data) end, TheWorld)
        self:ToggleSandstorms(TheWorld.components.sandstorms:IsSandstormActive())
    end
end,
nil,
{
    sandstormlevel = onsandstormlevel,
})

local function OnChangeArea(inst)
    local self = inst.components.stormwatcher
    self:UpdateSandstormLevel()
    self.delay = self.sandstormlevel > 0 and self.sandstormlevel < 1 and .5 or 1
end

local function UpdateSandstormWalkSpeed(inst)
    inst.components.stormwatcher:UpdateSandstormWalkSpeed()
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

function StormWatcher:ToggleSandstorms(active)
    if active then
        if self.delay == nil then
            self.delay = math.random()
            self.inst:StartUpdatingComponent(self)
            self.inst:ListenForEvent("changearea", OnChangeArea)
            if self.sandstormspeedmult < 1 then
                AddSandstormWalkSpeedListeners(self.inst)
            end
            self:UpdateSandstormLevel()
        end
    elseif self.delay ~= nil then
        self.delay = nil
        self.inst:StopUpdatingComponent(self)
        self.inst:RemoveEventCallback("changearea", OnChangeArea)
        if self.sandstormspeedmult < 1 then
            RemoveSandstormWalkSpeedListeners(self.inst)
        end
        self.sandstormlevel = 0
    end
end

function StormWatcher:SetSandstormSpeedMultiplier(mult)
    mult = math.clamp(mult, 0, 1)
    if self.sandstormspeedmult ~= mult then
        if self.delay == nil then
            self.sandstormspeedmult = mult
        elseif mult < 1 then
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

function StormWatcher:UpdateSandstormLevel()
    local level = math.floor(TheWorld.components.sandstorms:GetSandstormLevel(self.inst) * 7 + .5) / 7
    if self.sandstormlevel ~= level then
        self.sandstormlevel = level
        self:UpdateSandstormWalkSpeed()
    end
end

function StormWatcher:UpdateSandstormWalkSpeed()
    if self.sandstormspeedmult < 1 then
        if self.sandstormlevel < TUNING.SANDSTORM_FULL_LEVEL or
            self.inst.components.playervision:HasGoggleVision() or
            self.inst.components.playervision:HasGhostVision() or
            self.inst.components.rider:IsRiding() then
            self.inst.components.locomotor:RemoveExternalSpeedMultiplier(self.inst, "sandstorm")
        else
            self.inst.components.locomotor:SetExternalSpeedMultiplier(self.inst, "sandstorm", self.sandstormspeedmult)
        end
    end
end

function StormWatcher:OnUpdate(dt)
    if self.delay > dt then
        self.delay = self.delay - dt
    else
        self:UpdateSandstormLevel()
        self.delay = self.sandstormlevel > 0 and self.sandstormlevel < 1 and .5 or 1
    end
end

return StormWatcher
