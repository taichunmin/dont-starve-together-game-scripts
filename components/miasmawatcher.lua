local SourceModifierList = require("util/sourcemodifierlist")

local MiasmaWatcher = Class(function(self, inst)
	self.inst = inst
	self.enabled = false
	self.miasmaspeedmult = TUNING.MIASMA_SPEED_MOD
	self.hasmiasmasource = SourceModifierList(inst, false, SourceModifierList.boolean)

    if TheWorld.ismastersim then
        inst:ListenForEvent("miasmacloudexists", function(src, exists)
            self:ToggleMiasma(exists)
        end, TheWorld)
        if TheWorld.GetMiasmaCloudCount and TheWorld:GetMiasmaCloudCount() > 0 then
            self:ToggleMiasma(true)
        end
    end
end)

function MiasmaWatcher:AddMiasmaSource(src)
	local had = self.hasmiasmasource:Get()
	self.hasmiasmasource:SetModifier(src, true)
	if not had then
		if self.inst.player_classified ~= nil then
			self.inst.player_classified.isinmiasma:set(true)
		end
		self:UpdateMiasmaWalkSpeed()
        self.inst:AddDebuff("miasmadebuff", "miasmadebuff")
	end
end

function MiasmaWatcher:RemoveMiasmaSource(src)
	self.hasmiasmasource:RemoveModifier(src)
	if not self.hasmiasmasource:Get() then
		if self.inst.player_classified ~= nil then
			self.inst.player_classified.isinmiasma:set(false)
		end
		self:UpdateMiasmaWalkSpeed()
        self.inst:RemoveDebuff("miasmadebuff")
	end
end

function MiasmaWatcher:IsInMiasma()
	return self.hasmiasmasource:Get()
end

local function UpdateMiasmaWalkSpeed(inst)
	inst.components.miasmawatcher:UpdateMiasmaWalkSpeed()
end

local function AddMiasmaWalkSpeedListeners(inst)
	inst:ListenForEvent("gogglevision", UpdateMiasmaWalkSpeed)
	inst:ListenForEvent("ghostvision", UpdateMiasmaWalkSpeed)
	inst:ListenForEvent("mounted", UpdateMiasmaWalkSpeed)
	inst:ListenForEvent("dismounted", UpdateMiasmaWalkSpeed)
end

local function RemoveMiasmaWalkSpeedListeners(inst)
	inst:RemoveEventCallback("gogglevision", UpdateMiasmaWalkSpeed)
	inst:RemoveEventCallback("ghostvision", UpdateMiasmaWalkSpeed)
	inst:RemoveEventCallback("mounted", UpdateMiasmaWalkSpeed)
	inst:RemoveEventCallback("dismounted", UpdateMiasmaWalkSpeed)
	inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "miasma")
end

function MiasmaWatcher:OnRemoveFromEntity()
	if self.enabled and self.miasmaspeedmult < 1 then
		RemoveMiasmaWalkSpeedListeners(self.inst)
	end
end

function MiasmaWatcher:ToggleMiasma(active)
	active = active or false
	if self.enabled ~= active then
		if self.miasmaspeedmult < 1 then
			if active then
				AddMiasmaWalkSpeedListeners(self.inst)
			else
				RemoveMiasmaWalkSpeedListeners(self.inst)
			end
		end
		self.enabled = active
	end
end

function MiasmaWatcher:SetMiasmaSpeedMultiplier(mult)
	mult = math.clamp(mult, 0, 1)
	if self.miasmaspeedmult ~= mult then
		if self.enabled then
			if mult >= 1 then
				RemoveMiasmaWalkSpeedListeners(self.inst)
			elseif self.miasmaspeedmult >= 1 then
				AddMiasmaWalkSpeedListeners(self.inst)
			end
		end
		self.miasmaspeedmult = mult
		if self.enabled then
			self:UpdateMiasmaWalkSpeed()
		end
	end
end

function MiasmaWatcher:UpdateMiasmaWalkSpeed()
	if self.miasmaspeedmult < 1 then
		if not self.hasmiasmasource:Get() or
			self.inst.components.playervision:HasGoggleVision() or
			self.inst.components.playervision:HasGhostVision() or
			self.inst.components.rider:IsRiding() then
			self.inst.components.locomotor:RemoveExternalSpeedMultiplier(self.inst, "miasma")
		else
			self.inst.components.locomotor:SetExternalSpeedMultiplier(self.inst, "miasma", self.miasmaspeedmult)
		end
	end
end

return MiasmaWatcher
