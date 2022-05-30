local PortableStructure = Class(function(self, inst)
    self.inst = inst
    self.ondismantlefn = nil
end)

function PortableStructure:SetOnDismantleFn(fn)
    self.ondismantlefn = fn
end

function PortableStructure:Dismantle(doer)
    if self.ondismantlefn ~= nil then
        self.ondismantlefn(self.inst, doer)
    end
end

return PortableStructure
