local Tributable = Class(function(self, inst)
    self.inst = inst

    self.currenttributevalue = 0
    self.rewardattributevalue = 10

    self.numrewardsgiven = 0

    self.timegiventribute = nil
    self.decaycurrenttributetime = 0
end)

function Tributable:GetDebugString()
    return "current tribute: "..tostring(self.currenttributevalue)
end

function Tributable:HasPendingReward()
	return self.currenttributevalue >= self.rewardattributevalue
end

local function ondecay(inst)
	inst.components.tributable.currenttributevalue = 0
	inst.components.tributable.decaytask = nil
end

function Tributable:OnGivenReward()
	self.currenttributevalue = 0
	self.numrewardsgiven = self.numrewardsgiven + 1

	if self.decaytask ~= nil then
		self.decaytask:Cancel()
		self.decaytask = nil
	end

	if self.ongivenrewardfn ~= nil then
		self.ongivenrewardfn(self.inst)
	end
end

function Tributable:OnAccept(value, tributer)
	self.currenttributevalue = self.currenttributevalue + value
	self.inst:PushEvent("onaccepttribute")

	if self.decaytask ~= nil then
		self.decaytask:Cancel()
		self.decaytask = nil
	end
	if self.decaycurrenttributetime > 0 and not self:HasPendingReward() then
		self.timegiventribute = GetTime()
		self.decaytask = self.inst:DoTaskInTime(self.decaycurrenttributetime, ondecay)
	end
end

function Tributable:OnRefuse()
	self.inst:PushEvent("onrefusetribute")
end

function Tributable:OnSave()
    local data = {}
    data.currenttributevalue = self.currenttributevalue > 0 and self.currenttributevalue or nil
	data.remainingdecaytime = self.decaytask ~= nil and math.max(0, (self.decaycurrenttributetime - (GetTime() - self.timegiventribute))) or nil
    data.numrewardsgiven = self.numrewardsgiven > 0 and self.numrewardsgiven or nil

    return data
end

function Tributable:OnLoad(data)
    if data ~= nil then
		if data.currenttributevalue ~= nil then
			self.currenttributevalue = data.currenttributevalue
		end
		if data.remainingdecaytime ~= nil then
			self.timegiventribute = GetTime()
			self.decaytask = self.inst:DoTaskInTime(data.remainingdecaytime, ondecay)
		end
		if data.numrewardsgiven ~= nil then
			self.numrewardsgiven = data.numrewardsgiven
		end
    end
end



return Tributable
