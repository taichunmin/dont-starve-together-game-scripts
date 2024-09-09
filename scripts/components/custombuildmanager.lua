local Custombuildmanager = Class(function(self, inst)
    self.inst = inst
    self.groups = {}
    self.current = {}
end)

function Custombuildmanager:refreshart()
    for g,group in pairs(self.groups) do
        for s,symbol in ipairs(self.groups[g])do
            local build = self.current[g]
            if build then
                print(symbol,build)
                if not self.canswapsymbol or self.canswapsymbol(self.inst) then
                    self.inst.AnimState:OverrideSymbol(symbol, build, symbol)
                end
            else
        --      print("clear symobl",symbol)
        --     self.inst.AnimState:ClearOverrideSymbol(symbol)
            end
        end
    end
end

function Custombuildmanager:SetGroups(data)
    self.groups = data
end

function Custombuildmanager:SetCanSwapSymbol(fn)
    self.canswapsymbol = fn
end

function Custombuildmanager:ChangeGroup(group, build)
    if self.groups[group] then
        if build then
            self.current[group] = build
        else
            self.current[group] = nil
        end
    end
    self:refreshart()
end

function Custombuildmanager:OnSave(data)
    return
    {
        current = self.current,
    }
end

function Custombuildmanager:OnLoad(data)
    if data then
        if data.current then
            self.current = data.current
        end
    end
    self:refreshart()
end

return Custombuildmanager