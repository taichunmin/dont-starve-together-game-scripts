local SourceModifierList = require("util/sourcemodifierlist")

--Called locally as well when chargetimemod changes
local function onchargetime(self)
    if self.inst.replica.inventoryitem ~= nil then
        self.inst.replica.inventoryitem:SetChargeTime(self:GetRechargeTime())
    end
end

local function oncurrent(self, current)
    local pct = current / self.total
end

local function ontotal(self, total)
    if self.current ~= nil then
        oncurrent(self, self.current)
    end
end

local Rechargeable = Class(function(self, inst)
    self.inst = inst
    self.total = 180
    self.current = 180
    self.chargetimemod = SourceModifierList(self.inst, 0, SourceModifierList.additive)
    self.chargetime = 30
    self.ondischargedfn = nil
    self.onchargedfn = nil
    self.updating = false

    --V2C: Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("rechargeable")
end,
nil,
{
    chargetime = onchargetime,
    current = oncurrent,
    total = ontotal,
})

function Rechargeable:OnRemoveFromEntity()
    self.inst:RemoveTag("rechargeable")
end

function Rechargeable:SetOnDischargedFn(fn)
    self.ondischargedfn = fn
end

function Rechargeable:SetOnChargedFn(fn)
    self.onchargedfn = fn
end

local function StopUpdatingCharge(self)
    if self.updating then
        self.updating = false
        self.inst:StopUpdatingComponent(self)
    end
end

local function StartUpdatingCharge(self)
    if not self.updating then
        self.updating = true
        self.inst:StartUpdatingComponent(self)
    end
end

function Rechargeable:OnUpdate(dt)
    local chargetime = self.chargetime * (1 + self.chargetimemod:Get())
    self:SetCharge(chargetime > 0 and self.current + dt * self.total / chargetime or self.total, true)
end

function Rechargeable:SetMaxCharge(val)
    if self.total ~= val then
        self.current = self:IsCharged() and val or self:GetPercent() * val
        self.total = val
        StartUpdatingCharge(self)
    end
end

function Rechargeable:SetChargeTime(t)
    if self.chargetime ~= t then
        self.chargetime = t
        StartUpdatingCharge(self)
    end
end

function Rechargeable:SetChargeTimeMod(source, key, mod)
    if mod == 0 then
        self:RemoveChargeTimeMod(source, key)
    else
        local old = self.chargetimemod:Get()
        self.chargetimemod:SetModifier(source, mod, key)
        if old ~= self.chargetimemod:Get() then
            onchargetime(self)
            StartUpdatingCharge(self)
        end
    end
end

function Rechargeable:RemoveChargeTimeMod(source, key)
    local old = self.chargetimemod:Get()
    self.chargetimemod:RemoveModifier(source, key)
    if old ~= self.chargetimemod:Get() then
        onchargetime(self)
        StartUpdatingCharge(self)
    end
end

function Rechargeable:IsCharged()
    return self.current >= self.total
end

function Rechargeable:SetCharge(val, overtime)
    val = math.clamp(val, 0, self.total)
    if self.current ~= val then
        local was_charged = self:IsCharged()
        self.current = val
        self.inst:PushEvent("rechargechange", { percent = self:GetPercent(), overtime = overtime })
        if self:IsCharged() then
            StopUpdatingCharge(self)
            if not was_charged and self.onchargedfn ~= nil then
                self.onchargedfn(self.inst)
            end
        else
            StartUpdatingCharge(self)
            if was_charged and self.ondischargedfn ~= nil then
                self.ondischargedfn(self.inst)
            end
        end
    end
end

function Rechargeable:GetCharge()
    return self.current
end

function Rechargeable:Discharge(chargetime)
    self:SetChargeTime(chargetime)
    self:SetCharge(0)
end

function Rechargeable:GetPercent()
    return self.current / self.total
end

function Rechargeable:SetPercent(pct)
    self:Charge(self.total * pct)
end

function Rechargeable:GetRechargeTime()
    return math.max(0, self.chargetime * (1 + self.chargetimemod:Get()))
end

function Rechargeable:GetTimeToCharge()
    return self:IsCharged() and 0 or (1 - self:GetPercent()) * self:GetRechargeTime()
end

function Rechargeable:OnSave()
    return not self:IsCharged() and {
        chargetime = self.chargetime,
        charge = self.current,
    } or nil
end

function Rechargeable:OnLoad(data)
    if data.chargetime ~= nil then
        self:SetChargeTime(data.chargetime)
    end
    if data.charge ~= nil then
        self:SetCharge(data.charge)
    end
end

function Rechargeable:GetDebugString()
    return string.format("%d/%d (%.2f%%) @%.1f%% time Charging: %s",
        self.current,
        self.total,
        self:GetPercent() * 100,
        (1 + self.chargetimemod:Get()) * 100,
        self:IsCharged() and "--" or string.format("%.2fs", self:GetTimeToCharge())
    )
end

return Rechargeable
