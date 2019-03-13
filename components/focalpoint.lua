--NOTE: This is a client side component. No server
--      logic should be driven off this component!

local FocalPoint = Class(function(self, inst)
    self.inst = inst
    self.target = nil
    self.priority = nil
    self.prioritydistsq = nil
    self.focustick = nil
    self.targets = {}
    self._onsourceremoved = function(source) self:StopFocusSource(source) end
end)

function FocalPoint:Reset()
    self.target = nil
    self.priority = nil
    self.prioritydistsq = nil
    TheCamera:SetDefault()
    TheCamera:Snap()
    if self.inst.entity:GetParent() ~= nil and next(self.targets) ~= nil then
        self.inst:StartUpdatingComponent(self)
    else
        self.inst:StopUpdatingComponent(self)
    end
end

function FocalPoint:StartFocusSource(source, id, target, minrange, maxrange, priority)
    id = id or ""
    local sourcetbl = self.targets[source]
    if sourcetbl == nil then
        self.targets[source] = { [id] = { target = target, minrange = minrange, maxrange = maxrange, priority = priority } }
        self.inst:ListenForEvent("onremove", self._onsourceremoved, source)
    else
        local params = sourcetbl[id]
        if params == nil then
            sourcetbl[id] = { target = target, minrange = minrange, maxrange = maxrange, priority = priority }
        else            
            params.target = target
            params.minrange = minrange
            params.maxrange = maxrange
            params.priority = priority
        end
    end
    self:PushTempFocus(target or source, minrange, maxrange, priority)
end

function FocalPoint:StopFocusSource(source, id)
    local sourcetbl = self.targets[source]
    if sourcetbl ~= nil then
        if id ~= nil then
            sourcetbl[id] = nil
            if next(sourcetbl) == nil then
                self.targets[source] = nil
                self.inst:RemoveEventCallback("onremove", self._onsourceremoved, source)
            end
        else
            self.targets[source] = nil
            self.inst:RemoveEventCallback("onremove", self._onsourceremoved, source)
        end
    end
end

function FocalPoint:PushTempFocus(target, minrange, maxrange, priority)
    if target == self.target or self.priority == nil or priority >= self.priority then
        local parent = self.inst.entity:GetParent()
        if parent ~= nil then
            local tpos = target:GetPosition()
            local ppos = parent:GetPosition()
            local distsq = distsq(tpos, ppos) --3d distance
            if distsq < (priority == self.priority and math.min(self.prioritydistsq, maxrange * maxrange) or maxrange * maxrange) then
                local offs = tpos - ppos
                if distsq > minrange * minrange then
                    offs = offs * (maxrange - math.sqrt(distsq)) / (maxrange - minrange)
                end
                offs.y = offs.y + 1.5
                TheCamera:SetOffset(offs)

                self.target = target
                self.priority = priority
                self.prioritydistsq = distsq
                self.focustick = TheSim:GetTick()
                self.inst:StartUpdatingComponent(self)
            end
        end
    end
end

function FocalPoint:OnUpdate()
    local toremove = {}
    for source, sourcetbl in pairs(self.targets) do
        for id, params in pairs(sourcetbl) do
            if params.target == nil or params.target:IsValid() then
                self:PushTempFocus(params.target or source, params.minrange, params.maxrange, params.priority)
            else
                table.insert(toremove, { source, id })
            end
        end
    end
    for i, v in ipairs(toremove) do
        self:StopFocusSource(unpack(toremove))
    end

    if self.focustick == nil then
        self.target = nil
        TheCamera:SetDefaultOffset()
        if next(self.targets) == nil then
            self.inst:StopUpdatingComponent(self)
        end
    elseif self.focustick ~= TheSim:GetTick() then
        self.priority = nil
        self.prioritydistsq = nil
        self.focustick = nil
    end
end

return FocalPoint
