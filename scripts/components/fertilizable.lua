
local Fertilizable = Class(function(self, inst)
    self.inst = inst

	--self.onfertlizedfn = nil
end)

function Fertilizable:Fertilize(fertilizer)
	return self.onfertlizedfn ~= nil and self.onfertlizedfn(self.inst, fertilizer)
end

return Fertilizable
