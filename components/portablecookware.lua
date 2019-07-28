local PortableCookware = Class(function(self, inst)
    self.inst = inst
    self.ondismantlefn = nil
end)

function PortableCookware:SetOnDismantleFn(fn)
    self.ondismantlefn = fn
end

function PortableCookware:Dismantle(doer)
    if self.ondismantlefn ~= nil then
        self.ondismantlefn(self.inst, doer)
    end
end

return PortableCookware
