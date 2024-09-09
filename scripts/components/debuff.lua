local Debuff = Class(function(self, inst)
    self.inst = inst
    self.name = nil
    self.target = nil
    self.onattachedfn = nil
    self.ondetachedfn = nil
    self.onextendedfn = nil
    self.onchangefollowsymbolfn = nil
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

function Debuff:SetChangeFollowSymbolFn(fn)
    self.onchangefollowsymbolfn = fn
end

function Debuff:Stop()
    if self.target then
        self.target:RemoveDebuff(self.name)
    end
end

--Should only be called by debuffable component
function Debuff:AttachTo(name, target, followsymbol, followoffset, data)
    self.name = name
    self.target = target
    if self.onattachedfn ~= nil then
        self.onattachedfn(self.inst, target, followsymbol, followoffset, data)
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

function Debuff:Extend(followsymbol, followoffset, data)
    if self.onextendedfn ~= nil then
        self.onextendedfn(self.inst, self.target, followsymbol, followoffset, data)
    end
end

--Should only be called by debuffable component
function Debuff:ChangeFollowSymbol(followsymbol, followoffset)
    if self.onchangefollowsymbolfn ~= nil then
        self.onchangefollowsymbolfn(self.inst, self.target, followsymbol, followoffset)
    end
end

return Debuff
