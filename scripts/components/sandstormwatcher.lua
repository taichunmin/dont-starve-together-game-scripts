local SandStormWatcher = Class(function(self, inst)
    self.inst = inst
	self.enabled = false
    self.sandstormspeedmult = TUNING.SANDSTORM_SPEED_MOD

	if TheWorld.components.sandstorms ~= nil then
		inst:ListenForEvent("ms_stormchanged", function(src, data)
			if data.stormtype == STORM_TYPES.SANDSTORM then
				self:ToggleSandstorms(data.setting)
			end
		end, TheWorld)
		if TheWorld.components.sandstorms:IsSandstormActive() then
			self:ToggleSandstorms({ stormtype = STORM_TYPES.SANDSTORM, setting = true })
		end
	end
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

function SandStormWatcher:OnRemoveFromEntity()
	if self.enabled and self.sandstormspeedmult < 1 then
		RemoveSandstormWalkSpeedListeners(self.inst)
	end
end

function SandStormWatcher:ToggleSandstorms(active)
	active = active or false
	if self.enabled ~= active then
		if self.sandstormspeedmult < 1 then
			if active then
				AddSandstormWalkSpeedListeners(self.inst)
			else
				RemoveSandstormWalkSpeedListeners(self.inst)
			end
		end
		self.enabled = active
		if active then
			self:UpdateSandstormLevel()
		end
	end
end

function SandStormWatcher:SetSandstormSpeedMultiplier(mult)
    mult = math.clamp(mult, 0, 1)
    if self.sandstormspeedmult ~= mult then
		if self.enabled then
			if mult >= 1 then
				RemoveSandstormWalkSpeedListeners(self.inst)
			elseif self.sandstormspeedmult >= 1 then
				AddSandstormWalkSpeedListeners(self.inst)
			end
		end
		self.sandstormspeedmult = mult
		if self.enabled then
			self:UpdateSandstormWalkSpeed()
		end
    end
end

function SandStormWatcher:UpdateSandstormLevel()
	local level = self:GetSandstormLevel()
	self:UpdateSandstormWalkSpeed_Internal(level)
	self.inst:PushEvent("sandstormlevel", { level = level })
end

function SandStormWatcher:UpdateSandstormWalkSpeed()
	self:UpdateSandstormWalkSpeed_Internal(self:GetSandstormLevel())
end

function SandStormWatcher:UpdateSandstormWalkSpeed_Internal(level)
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
end

function SandStormWatcher:GetSandstormLevel()
    if self.inst.components.stormwatcher then
        return self.inst.components.stormwatcher:GetStormLevel(STORM_TYPES.SANDSTORM)
    end
    return nil
end

return SandStormWatcher
