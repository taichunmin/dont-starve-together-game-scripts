
local OceanFishingHook = Class(function(self, inst)
    self.inst = inst

	self.interest = {}

	--self.lure_data = nil
	self.lure_fns = {}

	self.reel_mod = 0

    self.inst:StartWallUpdatingComponent(self)

	inst:AddTag("fishinghook")
end)

function OceanFishingHook:OnRemoveFromEntity()
	self.inst:RemoveTag("fishinghook")
end

function OceanFishingHook:SetLureData(lure_data, lure_fns)
	self.lure_data = lure_data
	self.lure_fns = lure_fns or {}

	if self.lure_data.reel_charm ~= nil then
		self.inst:StartUpdatingComponent(self)
	end
end

--V2C: is that supposed to be _CalcCharm?
function OceanFishingHook:_ClacCharm(fish)
	local fish_lure_prefs = fish ~= nil and fish.fish_def.lures or nil

	local weather = TheWorld.state.israining and "raining"
					or TheWorld.state.issnowing and "snowing"
					or "default"

	local mod = (self.inst.components.perishable ~= nil and self.inst.components.perishable:GetPercent() or 1)
				* (self.lure_data.timeofday ~= nil and self.lure_data.timeofday[TheWorld.state.phase] or 0)
				* (fish_lure_prefs == nil and 1 or self.lure_data.style ~= nil and fish_lure_prefs[self.lure_data.style] or 0)
				* (self.lure_data.weather ~= nil and self.lure_data.weather[weather] or TUNING.OCEANFISHING_LURE_WEATHER_DEFAULT[weather] or 1)
				* (self.lure_fns.charm_mod_fn ~= nil and self.lure_fns.charm_mod_fn(fish) or 1)

	self.debug_fish_lure_prefs = fish_lure_prefs
	return (self.lure_data.charm + self.lure_data.reel_charm*self.reel_mod) * mod
end

function OceanFishingHook:HasLostInterest(fish)
	return self.interest[fish.GUID] ~= nil and self.interest[fish.GUID] <= 0
end

function OceanFishingHook:SetLostInterest(fish)
	self.interest[fish.GUID] = 0
end

function OceanFishingHook:ClearLostInterestList()
	self.interest = {}
end

function OceanFishingHook:UpdateInterestForFishable(fish)
	if self.interest[fish.GUID] == nil or self.interest[fish.GUID] > 0 then
		local charm = self:_ClacCharm(fish)
		if self.interest[fish.GUID] == nil then
			self.interest[fish.GUID] = charm
		else
			self.interest[fish.GUID] = self.interest[fish.GUID] + charm * 0.2
		end
	end

	return self.interest[fish.GUID]
end

function OceanFishingHook:OnUpdate(dt)
	local vx, vy, vz = self.inst.Physics:GetVelocity()
	local cur_speed = vx * vx + vz * vz
	if cur_speed >= 0.1 then
		self.reel_mod = 1
	else
		self.reel_mod = Lerp(self.reel_mod, 0, dt/2)
	end
end

function OceanFishingHook:TestInterest(fish)
	return (self.interest[fish.GUID] == nil or self.interest[fish.GUID] > 0)
			and fish:IsNear(self.inst, self.lure_data.radius)
end

function OceanFishingHook:GetDebugString()
	local perish = self.inst.components.perishable ~= nil and self.inst.components.perishable:GetPercent() or 1
	local str = "Total: " .. string.format("%.2f", self:_ClacCharm(nil))
			.. " Charm: " .. string.format("%.2f, %.2f", self.lure_data.charm, self.lure_data.reel_charm*self.reel_mod)
			.. " Perish: " .. string.format("%.2f", self.inst.components.perishable ~= nil and self.inst.components.perishable:GetPercent() or 1)
			.. ", TimeOfDay: " .. string.format("%.2f", self.lure_data.timeofday ~= nil and self.lure_data.timeofday[TheWorld.state.phase] or 0)
			.. ", Style:" .. string.format("%.2f", self.debug_fish_lure_prefs == nil and 1 or self.lure_data.style ~= nil and self.debug_fish_lure_prefs[self.lure_data.style] or 0) .. " (" .. tostring(self.lure_data.style) .. ")"
	for k, v in pairs(self.interest) do
		str = str .. "\n " .. tostring(k) .. string.format(": %.2f", v)
	end
	return str
end

function OceanFishingHook:OnWallUpdate(dt)
    if TheNet:IsServerPaused() then return end

	if self.onwallupdate ~= nil then
		self.onwallupdate(self.inst, dt)
	end
end

return OceanFishingHook