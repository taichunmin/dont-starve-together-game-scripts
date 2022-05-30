
local YOTC_RaceStart = Class(function(self, inst)
	self.inst = inst

	self.onstartracefn = nil
	self.rats = {}

    self.inst:AddTag("yotc_racestart")
end,
nil,
{})

function YOTC_RaceStart:OnRemoveFromEntity()
    self.inst:RemoveTag("yotc_racestart")
end

function YOTC_RaceStart:StartRace()
	if self.onstartracefn ~= nil then
		self.onstartracefn(self.inst)
	end
	self.inst:AddTag("race_on")
end

function YOTC_RaceStart:EndRace()
	if self.onendracefn ~= nil then
		self.onendracefn(self.inst)
	end
	self.inst:RemoveTag("race_on")
end

function YOTC_RaceStart:CanInteract()
	if not self.inst:HasTag("race_on") then
		return true
	end
end


return YOTC_RaceStart