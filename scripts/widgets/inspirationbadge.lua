local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

-------------------------------------------------------------------------------------------------------

local NUM_SLOTS = 3

local InspirationBadge = Class(Badge, function(self, owner, colour)
    Badge._ctor(self, nil, owner, { 132/255, 62/255, 162/255, 1 }, nil, true, true, true)

	self._clientpredicteddraining = false

    self.circleframe:GetAnimState():SetBank ("status_wathgrithr")
    self.circleframe:GetAnimState():SetBuild("status_wathgrithr")

	self.slots = {}
	for i = 1, NUM_SLOTS do
		self.slots[i] = self:AddChild(UIAnim())
		self.slots[i]:GetAnimState():SetBank ("status_wathgrithr")
		self.slots[i]:GetAnimState():SetBuild("status_wathgrithr")
		self.slots[i]:GetAnimState():PlayAnimation("slot_deactivated_"..tostring(i))
		self.slots[i]:GetAnimState():AnimateWhilePaused(false)
	end
	self.buffs = {}
	for i = 1, NUM_SLOTS do
		self.buffs[i] = self:AddChild(UIAnim())
		self.buffs[i]:GetAnimState():SetBank ("status_wathgrithr")
		self.buffs[i]:GetAnimState():SetBuild("status_wathgrithr")
		self.buffs[i]:GetAnimState():PlayAnimation("buff_off")
		self.buffs[i]:GetAnimState():AnimateWhilePaused(false)
	end
	self.num_active_slots = 0
end)

function InspirationBadge:OnUpdateSlots(num)
	if num > self.num_active_slots then
		for i = self.num_active_slots + 1, num do
		    self.slots[i]:GetAnimState():PlayAnimation("slot_activate_"..tostring(i))
		end
		TheFrontEnd:GetSound():PlaySoundWithParams("dontstarve_DLC001/characters/wathgrithr/inspiration_up", { intensity = (num-1)/(NUM_SLOTS-1) }) -- intensity: 0, 0.5, 1
	elseif num < self.num_active_slots then
		for i = self.num_active_slots, num+1, -1 do
		    self.slots[i]:GetAnimState():PlayAnimation("slot_deactivate_"..tostring(i))
		    self.slots[i]:GetAnimState():PushAnimation("slot_deactivated_"..tostring(i), false)
		end
		TheFrontEnd:GetSound():PlaySound("dontstarve_DLC001/characters/wathgrithr/inspiration_down")
	end

	self.num_active_slots = num
end

function InspirationBadge:OnBuffChanged(num, name)
	if num ~= nil and self.buffs[num] ~= nil then
		if name ~= nil then
			self.buffs[num]:GetAnimState():OverrideSymbol("buff_icon"..tostring(num), "status_wathgrithr", name)
			self.buffs[num]:GetAnimState():PlayAnimation("buff_activate_"..tostring(num))
		else
			if not self.buffs[num]:GetAnimState():IsCurrentAnimation("buff_off") and not self.buffs[num]:GetAnimState():IsCurrentAnimation("buff_deactivate_"..tostring(num)) then
				self.buffs[num]:GetAnimState():PlayAnimation("buff_deactivate_"..tostring(num))
				self.buffs[num]:GetAnimState():PushAnimation("buff_off", false)
			end
		end
	end
end

function InspirationBadge:EnableClientPredictedDraining(enable)
	if enable == nil then
		enable = false
	end
	if self._clientpredicteddraining ~= enable then
		if enable then
            self:StartUpdating()
		else
	        self:StopUpdating()
		end

		self._clientpredicteddraining = enable == true
	end
end

function InspirationBadge:OnUpdate(dt)
	if TheNet:IsServerPaused() then return end

	local percent = math.max(0, self.percent + dt * TUNING.INSPIRATION_DRAIN_RATE * 0.98 / 100) -- just go a little bit slower than the server so there will be less jumping backwards in the meter
    self:SetPercent(percent)
end

return InspirationBadge