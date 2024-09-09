local MoonstormWatcher = Class(function(self, inst)
    self.inst = inst

	self.enabled = false
    self.moonstormlevel = 0
    self.moonstormspeedmult = TUNING.MOONSTORM_SPEED_MOD
    self.delay = nil

    if TheWorld.net.components.moonstorms ~= nil then
        inst:ListenForEvent("ms_stormchanged", function(src, data) self:ToggleMoonstorms(data) end, TheWorld)
		if next(TheWorld.net.components.moonstorms:GetMoonstormNodes()) ~= nil then
			self:ToggleMoonstorms({ stormtype = STORM_TYPES.MOONSTORM, setting = true })
		end
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
	if self.enabled and self.moonstormspeedmult < 1 then
		RemoveMoonstormWalkSpeedListeners(self.inst)
	end
end

function MoonstormWatcher:ToggleMoonstorms(data)
	if data.stormtype == STORM_TYPES.MOONSTORM then
		local enable = data.setting or false
		if self.enabled ~= enable then
			if self.moonstormspeedmult < 1 then
				if enable then
					AddMoonstormWalkSpeedListeners(self.inst)
				else
					RemoveMoonstormWalkSpeedListeners(self.inst)
				end
			end
			self.enabled = enable
			if enable then
				self:UpdateMoonstormLevel()
			end
		end
	end
end

function MoonstormWatcher:SetMoonstormSpeedMultiplier(mult)
    mult = math.clamp(mult, 0, 1)
    if self.moonstormspeedmult ~= mult then
		if self.enabled then
			if mult >= 1 then
				RemoveMoonstormWalkSpeedListeners(self.inst)
			elseif self.moonstormspeedmult >= 1 then
				AddMoonstormWalkSpeedListeners(self.inst)
			end
		end
		self.moonstormspeedmult = mult
		if self.enabled then
			self:UpdateMoonstormWalkSpeed()
		end
    end
end

function MoonstormWatcher:UpdateMoonstormLevel()
	local level = self:GetMoonStormLevel()
	self:UpdateMoonstormWalkSpeed_Internal(level)
	self.inst:PushEvent("moonstormlevel", { level = level })
end

function MoonstormWatcher:UpdateMoonstormWalkSpeed()
	self:UpdateMoonstormWalkSpeed_Internal(self:GetMoonStormLevel())
end

function MoonstormWatcher:UpdateMoonstormWalkSpeed_Internal(level)
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
end

function MoonstormWatcher:GetMoonStormLevel()
    if self.inst.components.stormwatcher then
        return self.inst.components.stormwatcher:GetStormLevel(STORM_TYPES.MOONSTORM)
    end
    return nil
end

return MoonstormWatcher