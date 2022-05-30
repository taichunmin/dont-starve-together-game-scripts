
local FarmSoilDrinker = Class(function(self, inst)
    self.inst = inst

	self.time = {}
	self:Reset()

    inst:DoTaskInTime(0, function(i) TheWorld:PushEvent("ms_registersoildrinker", i) end)
end)

function FarmSoilDrinker:OnRemoveFromEntity()
    TheWorld:PushEvent("ms_registersoildrinker", self.inst)
end

function FarmSoilDrinker:CopyFrom(rhs)
	self:OnLoad(rhs:OnSave())
end

function FarmSoilDrinker:Reset()
	self.time.dry = 0
	self.time.wet = 0
	self.timer_start_time = GetTime()
end

function FarmSoilDrinker:UpdateMoistureTime(is_soil_moist, was_soil_moist)
	local stress_zone = was_soil_moist and "wet" or "dry"
	local cur_time = GetTime()
	self.time[stress_zone] = self.time[stress_zone] + (cur_time - self.timer_start_time)
	self.timer_start_time = cur_time
end

function FarmSoilDrinker:CalcPercentTimeHydrated()
	local is_moist = TheWorld.components.farming_manager:IsSoilMoistAtPoint(self.inst.Transform:GetWorldPosition())
	self:UpdateMoistureTime(nil, is_moist)

	local wet_time = self.time.wet
	local percent = wet_time > 0 and (wet_time / (self.time.dry + wet_time)) or 0
	return percent
end

function FarmSoilDrinker:GetMoistureRate()
	return self.getdrinkratefn ~= nil and self.getdrinkratefn(self.inst) or 0
end

function FarmSoilDrinker:OnSoilMoistureStateChange(cur_state, prev_state)
	if self.onsoilmoisturestatechangefn ~= nil then
		self.onsoilmoisturestatechangefn(self.inst, cur_state, prev_state)
	end
end

function FarmSoilDrinker:OnSave()
    local data = {
		time = self.time,
		timer_start_time = GetTime() - self.timer_start_time,
	}

	return data
end

function FarmSoilDrinker:OnLoad(data)
	self.time.dry = data.time.dry or 0
	self.time.wet = data.time.wet or 0
	self.timer_start_time = data.timer_start_time ~= nil and (GetTime() - data.timer_start_time) or GetTime()
end

function FarmSoilDrinker:GetDebugString()
	local is_moist = TheWorld.components.farming_manager:IsSoilMoistAtPoint(self.inst.Transform:GetWorldPosition())
	local updating_time = GetTime() - self.timer_start_time

	return "Ground is " .. (is_moist and "wet" or "dry") .. ", Time wet: " .. string.format("%.2f", self.time.wet + (is_moist and updating_time or 0)).. ", dry: " .. string.format("%.2f", self.time.dry + (not is_moist and updating_time or 0))
end

return FarmSoilDrinker
