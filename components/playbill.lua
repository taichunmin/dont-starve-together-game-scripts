
local Playbill = Class(function(self, inst)
    self.scripts = {}
    self.costumes = {}
    self.starting_act = nil
    self.current_act = nil
end)


function Playbill:SetCurrentAct(act)
	self.current_act = act
end

function Playbill:OnSave()
	local data = {
		current_act = self.current_act
	}
	return data
end

function Playbill:OnLoad(data)
	if data and data.current_act then
		self.current_act = data.current_act
	end
end

return Playbill
