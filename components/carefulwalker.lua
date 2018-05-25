local function OnUnevenGroundDetected(inst, data)
    inst.components.carefulwalker:TrackTarget(data.inst, data.radius, data.period)
end

local CarefulWalker = Class(function(self, inst)
    self.inst = inst
    self.careful = false
    self.carefulwalkingspeedmult = TUNING.CAREFUL_SPEED_MOD
    self.targets = {}
    inst:ListenForEvent("unevengrounddetected", OnUnevenGroundDetected)
end)

function CarefulWalker:OnRemoveFromEntity()
    inst:RemoveEventCallback("unevengrounddetected", OnUnevenGroundDetected)
end

function CarefulWalker:SetCarefulWalkingSpeedMultiplier(mult)
    mult = math.clamp(mult, 0, 1)
    if self.carefulwalkingspeedmult ~= mult then
        if next(self.targets) == nil then
            self.carefulwalkingspeedmult = mult
        elseif mult >= 1 then
            self.carefulwalkingspeedmult = 1
            self:ToggleCareful(false)
        elseif self.careful then
            self.carefulwalkingspeedmult = mult
            if self.inst.components.locomotor ~= nil then
                self.inst.components.locomotor:SetExternalSpeedMultiplier(self.inst, "carefulwalking", mult)
            end
        elseif self.carefulwalkingspeedmult >= 1 then
            self.carefulwalkingspeedmult = mult
            self:OnUpdate(0)
        else
            self.carefulwalkingspeedmult = mult
        end
    end
end

function CarefulWalker:TrackTarget(target, radius, duration)
    local data = self.targets[target]
    if data == nil then
        data = {}
        self.targets[target] = data
        self.inst:StartUpdatingComponent(self)
    end
    data.rangesq = radius * radius
    data.remaining = duration + .05
end

function CarefulWalker:IsCarefulWalking()
    return self.careful
end

function CarefulWalker:ToggleCareful(careful)
    if careful then
        if not self.careful then
            self.careful = true
            if self.inst.components.locomotor ~= nil then
                self.inst.components.locomotor:SetExternalSpeedMultiplier(self.inst, "carefulwalking", self.carefulwalkingspeedmult)
            end
            self.inst:PushEvent("carefulwalking", { careful = true })
        end
    elseif self.careful then
        self.careful = false
        if self.inst.components.locomotor ~= nil then
            self.inst.components.locomotor:RemoveExternalSpeedMultiplier(self.inst, "carefulwalking")
        end
        self.inst:PushEvent("carefulwalking", { careful = false })
    end
end

function CarefulWalker:OnUpdate(dt)
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local checkcareful = self.carefulwalkingspeedmult < 1 and self.inst.components.locomotor ~= nil and self.inst.components.locomotor:FasterOnRoad()
    local careful = false
    local toremove
    for k, v in pairs(self.targets) do
        if v.remaining > dt and k:IsValid() then
            v.remaining = v.remaining - dt
            if checkcareful and k:GetDistanceSqToPoint(x, y, z) < v.rangesq then
                careful = true
                checkcareful = false
            end
        elseif toremove ~= nil then
            table.insert(toremove, k)
        else
            toremove = { k }
        end
    end

    if toremove ~= nil then
        for i, v in ipairs(toremove) do
            self.targets[v] = nil
        end
        if next(self.targets) == nil then
            self.inst:StopUpdatingComponent(self)
        end
    end

    self:ToggleCareful(careful)
end

return CarefulWalker
