
local FlotationDevice = Class(function(self, inst)
    self.inst = inst

	self.enabled = true
	--self.onpreventdrowningdamagefn  = nil
end)

function FlotationDevice:IsEnabled()
    return self.enabled
end

function FlotationDevice:OnPreventDrowningDamage()
	if self.onpreventdrowningdamagefn ~= nil then
		self.onpreventdrowningdamagefn(self.inst)
	end
end

return FlotationDevice
