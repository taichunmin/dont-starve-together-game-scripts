local Commander = Class(function(self, inst)
    self.inst = inst
    self.soldiers = {}
    self.numsoldiers = 0
    self.trackingdist = 0
    self.trackingperiod = 3

    self._task = nil
    self._onremove = function(ent)
        self:RemoveSoldier(ent)
    end
end)

function Commander:OnRemoveFromEntity()
    local k = next(self.soldiers)
    while k ~= nil do
        self:RemoveSoldier(k)
        k = next(self.soldiers)
    end
end

function Commander:GetNumSoldiers()
    return self.numsoldiers
end

function Commander:GetAllSoldiers()
    local soldiers = {}
    for k, v in pairs(self.soldiers) do
        table.insert(soldiers, k)
    end
    return soldiers
end

function Commander:IsSoldier(ent)
    return self.soldiers[ent] ~= nil
end

function Commander:ShareTargetToAllSoldiers(target)
    for k, v in pairs(self.soldiers) do
        if k.components.combat ~= nil then
            k.components.combat:SuggestTarget(target)
        end
    end
end

function Commander:DropAllSoldierTargets()
    for k, v in pairs(self.soldiers) do
        if k.components.combat ~= nil then
            k.components.combat:SetTarget(nil)
        end
    end
end

function Commander:IsAnySoldierNotAlert()
    for k, v in pairs(self.soldiers) do
        if (k.components.sleeper ~= nil and k.components.sleeper:IsAsleep()) or
            (k.components.freezable ~= nil and k.components.freezable:IsFrozen()) then
            return true
        end
    end
end

function Commander:AlertAllSoldiers()
    for k, v in pairs(self.soldiers) do
        if k.components.freezable ~= nil and k.components.freezable:IsFrozen() then
            k.components.freezable:Unfreeze()
        end
        if k.components.sleeper ~= nil and k.components.sleeper:IsAsleep() then
            k.components.sleeper:WakeUp()
        end
    end
end

function Commander:PushEventToAllSoldiers(ev, data)
    for k, v in pairs(self.soldiers) do
        k:PushEvent(ev, data)
    end
end

function Commander:AddSoldier(ent)
    if not (ent.components.health ~= nil and ent.components.health:IsDead()) and not self.soldiers[ent] then
        self.soldiers[ent] = true
        self.inst:ListenForEvent("onremove", self._onremove, ent)
        self.inst:ListenForEvent("death", self._onremove, ent)
        self.numsoldiers = self.numsoldiers + 1
        self:StartTrackingDistance()
        self.inst:PushEvent("soldierschanged")
        ent:PushEvent("gotcommander", { commander = self.inst })
    end
end

function Commander:RemoveSoldier(ent)
    if self.soldiers[ent] then
        self.soldiers[ent] = nil
        self.inst:RemoveEventCallback("onremove", self._onremove, ent)
        self.inst:RemoveEventCallback("death", self._onremove, ent)
        self.numsoldiers = self.numsoldiers - 1
        if self.numsoldiers <= 0 then
            self:StopTrackingDistance()
        end
        self.inst:PushEvent("soldierschanged")
        ent:PushEvent("lostcommander", { commander = self.inst })
    end
end

function Commander:SetTrackingDistance(dist)
    if self.trackingdist ~= dist then
        self.trackingdist = dist
        if dist > 0 then
            self:StartTrackingDistance()
        else
            self:StopTrackingDistance()
        end
    end
end

local function CheckDistance(inst, self)
    local toremove = {}
    for k, v in pairs(self.soldiers) do
        if not k:IsNear(inst, self.trackingdist) or k:IsAsleep() then
            table.insert(toremove, k)
        end
    end
    for i, v in ipairs(toremove) do
        self:RemoveSoldier(v)
    end
end

function Commander:StartTrackingDistance()
    if self.trackingdist > 0 and self.numsoldiers > 0 and self._task == nil and not self.inst:IsAsleep() then
        self._task = self.inst:DoPeriodicTask(self.trackingperiod, CheckDistance, nil, self)
    end
end

function Commander:StopTrackingDistance()
    if self._task ~= nil then
        self._task:Cancel()
        self._task = nil
    end
end

Commander.OnEntityWake = Commander.StartTrackingDistance
Commander.OnEntitySleep = Commander.StopTrackingDistance

function Commander:GetDebugString()
    return string.format(
        "Soldiers: %d, Tracking Distance: %.2f, Tracking Period: %.2f (%s)",
        self.numsoldiers,
        self.trackingdist,
        self.trackingperiod,
        self._task ~= nil and "Running" or "Stopped"
    )
end

return Commander
