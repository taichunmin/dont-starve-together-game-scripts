local Fan = Class(function(self, inst)
    self.inst = inst

    self.canusefn = nil
    self.onusefn = nil
    --self.onchannelingfn = nil
    --self.overridesymbol = nil
end)

function Fan:OnRemoveFromEntity()
    self.inst:RemoveTag("channelingfan")
end

function Fan:SetCanUseFn(fn)
    self.canusefn = fn
end

function Fan:SetOnUseFn(fn)
    self.onusefn = fn
end

function Fan:SetOnChannelingFn(fn)
    self.onchannelingfn = fn
    if fn ~= nil then
        --V2C: Recommended to explicitly add tag to prefab pristine state
        self.inst:AddTag("channelingfan")
    else
        self.inst:RemoveTag("channelingfan")
    end
end

function Fan:SetOverrideSymbol(symbol)
    self.overridesymbol = symbol
end

function Fan:IsChanneling()
    return self.onchannelingfn ~= nil
end

function Fan:Channel(target)
    if self.onchannelingfn and (not self.canusefn or (self.canusefn and self.canusefn(self.inst, target))) then
        self.onchannelingfn(self.inst, target)
        return true
    end
end

function Fan:Fan(target)
    if self.onusefn and (not self.canusefn or (self.canusefn and self.canusefn(self.inst, target))) then
        self.onusefn(self.inst, target)
        return true
    end
end

return Fan
