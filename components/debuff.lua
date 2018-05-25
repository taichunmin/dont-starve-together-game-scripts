local Debuff = Class(function(self, inst)
    self.inst = inst
    self.name = nil
    self.target = nil
    self.onattachedfn = nil
    self.ondetachedfn = nil
    self.onextendedfn = nil
    --self.keepondespawn = nil
end)

function Debuff:SetAttachedFn(fn)
    self.onattachedfn = fn
end

function Debuff:SetDetachedFn(fn)
    self.ondetachedfn = fn
end

function Debuff:SetExtendedFn(fn)
    self.onextendedfn = fn
end

function Debuff:Stop()
    if self.target ~= nil and self.target.components.debuffable ~= nil then
        self.target.components.debuffable:RemoveDebuff(self.name)
    end
end

--Should only be called by debuffable component
function Debuff:AttachTo(name, target, followsymbol, followoffset)
    self.name = name
    self.target = target
    if self.onattachedfn ~= nil then
        self.onattachedfn(self.inst, target, followsymbol, followoffset)
    end
end

--Should only be called by debuffable component
function Debuff:OnDetach()
    local target = self.target
    self.name = nil
    self.target = nil
    if self.ondetachedfn ~= nil then
        self.ondetachedfn(self.inst, target)
    end
end

function Debuff:Extend(followsymbol, followoffset)
    if self.onextendedfn ~= nil then
        self.onextendedfn(self.inst, self.target, followsymbol, followoffset)
    end
end

return Debuff
