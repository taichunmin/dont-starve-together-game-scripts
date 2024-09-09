local function OnStatusDirty(inst)
    inst:PushEvent("clienthealthstatusdirty")
end

local function OnHealthPctDirty(inst)
    inst:PushEvent("clienthealthdirty", { percent = inst.components.healthsyncer._healthpct:value() })
end

local function OnHealthDelta(inst, data)
    local self = inst.components.healthsyncer
    if self._healthpct:value() ~= data.newpercent then
        self._healthpct:set(data.newpercent)
        OnHealthPctDirty(inst)
    end
end

local function InitServer(inst)
    OnHealthDelta(inst, { newpercent = inst.components.health ~= nil and inst.components.health:GetPercent() or 1 })
end

local HealthSyncer = Class(function(self, inst)
    self.inst = inst

    self._status = net_tinybyte(inst.GUID, "healthsyncer._status", "healthstatusdirty") -- [0-4] for over time
    self._healthpct = net_float(inst.GUID, "healthsyncer._healthpct", "healthpctdirty")
    self._healthpct:set(1)

    if TheWorld.ismastersim then
        inst:ListenForEvent("healthdelta", OnHealthDelta)
        inst:DoTaskInTime(0, InitServer)

        self.corrosives = {}
        self._onremovecorrosive = function(debuff)
            self.corrosives[debuff] = nil
        end
        inst:ListenForEvent("startcorrosivedebuff", function(inst, debuff)
            if self.corrosives[debuff] == nil then
                self.corrosives[debuff] = true
                inst:ListenForEvent("onremove", self._onremovecorrosive, debuff)
            end
        end)

        self.hots = {}
        self._onremovehots = function(debuff)
            self.hots[debuff] = nil
        end
        inst:ListenForEvent("starthealthregen", function(inst, debuff)
            if self.hots[debuff] == nil then
                self.hots[debuff] = true
                inst:ListenForEvent("onremove", self._onremovehots, debuff)
            end
        end)

        self.small_hots = {}
        self._onremovesmallhots = function(debuff)
            self.small_hots[debuff] = nil
        end
        inst:ListenForEvent("startsmallhealthregen", function(inst, debuff)
            if self.small_hots[debuff] == nil then
                self.small_hots[debuff] = true
                inst:ListenForEvent("onremove", self._onremovesmallhots, debuff)
            end
        end)
        inst:ListenForEvent("stopsmallhealthregen", function(inst, debuff)
            if self.small_hots[debuff] ~= nil then
                self._onremovesmallhots(debuff)
                inst:RemoveEventCallback("onremove", self._onremovesmallhots, debuff)
            end
        end)

        inst:StartUpdatingComponent(self)
    else
        inst:ListenForEvent("healthstatusdirty", OnStatusDirty)
        inst:ListenForEvent("healthpctdirty", OnHealthPctDirty)
        inst:DoTaskInTime(0, OnHealthPctDirty)
    end
end)

--------------------------------------------------------------------------
--Common

function HealthSyncer:GetPercent()
    return self._healthpct:value()
end

function HealthSyncer:GetOverTime()
    -- returns -2 large down, -1 small down, 0 none, 1 small up, 2 large up
    local val = self._status:value()
    return ((val <= 0 or val >= 5) and 0)
        or (val <= 2 and val)
        or val - 5
end

--------------------------------------------------------------------------
--Server only

function HealthSyncer:OnUpdate(dt)
    local down =
        (self.inst.IsFreezing ~= nil and self.inst:IsFreezing()) or
        (self.inst.IsOverheating ~= nil and self.inst:IsOverheating()) or
        (self.inst.components.hunger ~= nil and self.inst.components.hunger:IsStarving()) or
        (self.inst.components.health ~= nil and self.inst.components.health.takingfiredamage) or
        next(self.corrosives) ~= nil

    -- Show the up-arrow when we're sleeping (but not in a straw roll: that doesn't heal us)
    local up = not down and
        (   (self.inst.player_classified ~= nil and self.inst.player_classified.issleephealing:value()) or
            next(self.hots) ~= nil or next(self.small_hots) ~= nil or
            (self.inst.components.inventory ~= nil and self.inst.components.inventory:EquipHasTag("regen"))
        ) and
        self.inst.components.health ~= nil and self.inst.components.health:IsHurt()

    local status =
        (down and 3) or
        (not up and 0) or
        (next(self.hots) ~= nil and 2) or
        1

    if self._status:value() ~= status then
        self._status:set(status)
        OnStatusDirty(self.inst)
    end
end

return HealthSyncer
