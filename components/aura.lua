local Aura = Class(function(self, inst)
    self.inst = inst
    self.radius = 3
    self.tickperiod = 1
    self.active = false
    self.applying = false
    self.pretickfn = nil
    self.auratestfn = nil
    self.auraexcludetags = { "noauradamage", "INLIMBO", "notarget", "noattack", "flight", "invisible", "playerghost" }
    self._fn = function(target) return self.auratestfn(inst, target) end
end)

function Aura:GetDebugString()
    local str = string.format("radius:%2.2f, enabled:%s", self.radius, tostring(self.active) )
    if self.active then
        str = str .. string.format(" %2.2fs applying:%s", self.tickperiod, tostring(self.applying))
    end
    return str
end

local function DoTick(inst, self)
    self:OnTick()
end

function Aura:Enable(val)
    val = val ~= false
    if self.active ~= val then
        self.active = val
        if val then
            self.task = self.inst:DoPeriodicTask(self.tickperiod, DoTick, nil, self)
        else
            if self.task ~= nil then
                self.task:Cancel()
                self.task = nil
            end
            if self.applying then
                self.inst:PushEvent("stopaura")
                self.applying = false
            end
        end
    end
end

function Aura:OnTick()

    if self.pretickfn then
        self.pretickfn(self.inst)
    end

    local applied =
        self.inst.components.combat ~= nil and
        self.inst.components.combat:DoAreaAttack(
            self.inst,
            self.radius,
            nil,
            self.auratestfn ~= nil and self._fn or nil,
            nil,
            self.auraexcludetags
        ) > 0

    if applied ~= self.applying then
        self.inst:PushEvent(applied and "startaura" or "stopaura")
        self.applying = applied
    end
end

return Aura
