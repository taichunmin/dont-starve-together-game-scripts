--Sewing should be redone without using the fueled component... it's kind of weird.

local SourceModifierList = require("util/sourcemodifierlist")

local function onfueltype(self, fueltype, old_fueltype)
    if old_fueltype ~= nil and old_fueltype ~= self.secondaryfueltype then
        self.inst:RemoveTag(old_fueltype == FUELTYPE.USAGE and "needssewing" or (old_fueltype.."_fueled"))
    end
    if fueltype == self.secondaryfueltype then
        return
    elseif fueltype == FUELTYPE.USAGE then
        if self.currentfuel < self.maxfuel and not self.no_sewing then
            self.inst:AddTag("needssewing")
        end
    elseif fueltype ~= nil and self.accepting then
        self.inst:AddTag(fueltype.."_fueled")
    end
end

local function onsecondaryfueltype(self, fueltype, old_fueltype)
    if old_fueltype ~= nil and old_fueltype ~= self.fueltype then
        self.inst:RemoveTag(old_fueltype == FUELTYPE.USAGE and "needssewing" or (old_fueltype.."_fueled"))
    end
    if fueltype == self.fueltype then
        return
    elseif fueltype == FUELTYPE.USAGE then
        if self.currentfuel < self.maxfuel and not self.no_sewing then
            self.inst:AddTag("needssewing")
        end
    elseif fueltype ~= nil and self.accepting then
        self.inst:AddTag(fueltype.."_fueled")
    end
end

local function onno_sewing(self, no_sewing)
    if (self.fueltype == FUELTYPE.USAGE or self.secondaryfueltype == FUELTYPE.USAGE) and self.currentfuel < self.maxfuel then
        if no_sewing then
            self.inst:RemoveTag("needssewing")
        else
            self.inst:AddTag("needssewing")
        end
    end
end

local function onaccepting(self, accepting)
    if self.fueltype ~= nil and self.fueltype ~= FUELTYPE.USAGE then
        if accepting then
            self.inst:AddTag(self.fueltype.."_fueled")
        else
            self.inst:RemoveTag(self.fueltype.."_fueled")
        end
    end
    if self.secondaryfueltype ~= nil and self.secondaryfueltype ~= self.fueltype and self.secondaryfueltype ~= FUELTYPE.USAGE then
        if accepting then
            self.inst:AddTag(self.secondaryfueltype.."_fueled")
        else
            self.inst:RemoveTag(self.secondaryfueltype.."_fueled")
        end
    end
end

local function onmaxfuel(self, maxfuel)
    if (self.fueltype == FUELTYPE.USAGE or self.secondaryfueltype == FUELTYPE.USAGE) and not self.no_sewing then
        if self.currentfuel < maxfuel then
            self.inst:AddTag("needssewing")
        else
            self.inst:RemoveTag("needssewing")
        end
    end
end

local function oncurrentfuel(self, currentfuel)
    if currentfuel <= 0 then
        self.inst:AddTag("fueldepleted")
    else
        self.inst:RemoveTag("fueldepleted")
    end
    onmaxfuel(self, self.maxfuel)
end

local Fueled = Class(function(self, inst)
    self.inst = inst
    self.consuming = false

    self.maxfuel = 0
    self.currentfuel = 0
    self.rate = 1
	self.rate_modifiers = SourceModifierList(self.inst)

    self.no_sewing = nil --V2C: HACK COLON RIGHT PARANTHESIS, I mean, what choice do I have if I don't want to break mods -_ -
    self.accepting = false
    self.fueltype = FUELTYPE.BURNABLE
    self.secondaryfueltype = nil
    self.sections = 1
    self.sectionfn = nil
    self.period = 1
    --self.firstperiod = nil
    --self.firstperiodfull = nil
    --self.firstperioddt = nil
    self.bonusmult = 1
    self.depleted = nil
end,
nil,
{
    fueltype = onfueltype,
    secondaryfueltype = onsecondaryfueltype,
    accepting = onaccepting,
    no_sewing = onno_sewing,
    maxfuel = onmaxfuel,
    currentfuel = oncurrentfuel,
})

function Fueled:OnRemoveFromEntity()
    self:StopConsuming()
    if self.fueltype ~= nil then
        self.inst:RemoveTag(self.fueltype == FUELTYPE.USAGE and "needssewing" or (self.fueltype.."_fueled"))
    end
    if self.secondaryfueltype ~= nil and self.secondaryfueltype ~= self.fueltype then
        self.inst:RemoveTag(self.secondaryfueltype == FUELTYPE.USAGE and "needssewing" or (self.secondaryfueltype.."_fueled"))
    end
    self.inst:RemoveTag("fueldepleted")
end

function Fueled:MakeEmpty()
    if self.currentfuel > 0 then
        self:DoDelta(-self.currentfuel)
    end
end

function Fueled:OnSave()
    if self.currentfuel ~= self.maxfuel then
        return {fuel = self.currentfuel}
    end
end

function Fueled:OnLoad(data)
    if data.fuel then
        self:InitializeFuelLevel(math.max(0, data.fuel))
    end
end

function Fueled:SetSectionCallback(fn)
    self.sectionfn = fn
end

function Fueled:SetDepletedFn(fn)
    self.depleted = fn
end

function Fueled:IsEmpty()
    return self.currentfuel <= 0
end

function Fueled:SetSections(num)
    self.sections = num
end

function Fueled:CanAcceptFuelItem(item)
    return self.accepting and item and item.components.fuel and (item.components.fuel.fueltype == self.fueltype or item.components.fuel.fueltype == self.secondaryfueltype)
end

function Fueled:GetCurrentSection()
    return self:IsEmpty() and 0 or math.min( math.floor(self:GetPercent()* self.sections)+1, self.sections)
end

function Fueled:ChangeSection(amount)
    self:DoDelta(amount * self.maxfuel / self.sections - 1)
end

function Fueled:SetTakeFuelFn(fn)
    self.ontakefuelfn = fn
end

function Fueled:TakeFuelItem(item, doer)
    if self:CanAcceptFuelItem(item) then
        local oldsection = self:GetCurrentSection()

        local wetmult = item:GetIsWet() and TUNING.WET_FUEL_PENALTY or 1
        local masterymult = doer ~= nil and doer.components.fuelmaster ~= nil and doer.components.fuelmaster:GetBonusMult(item, self.inst) or 1
        self:DoDelta(item.components.fuel.fuelvalue * self.bonusmult * wetmult * masterymult, doer)

        local fuelvalue = 0
        if item.components.fuel ~= nil then
            fuelvalue = item.components.fuel.fuelvalue
            item.components.fuel:Taken(self.inst)
        end
        item:Remove()

        if self.ontakefuelfn ~= nil then
            self.ontakefuelfn(self.inst, fuelvalue)
        end
        self.inst:PushEvent("takefuel", { fuelvalue = fuelvalue })

        return true
    end
end

function Fueled:SetUpdateFn(fn)
    self.updatefn = fn
end

function Fueled:GetDebugString()
    local section = self:GetCurrentSection()

    return string.format("%s %2.2f/%2.2f (-%2.2f) : section %d/%d %2.2f", self.consuming and "ON" or "OFF", self.currentfuel, self.maxfuel, self.rate * self.rate_modifiers:Get(), section, self.sections, self:GetSectionPercent())
end

function Fueled:AddThreshold(percent, fn)
    table.insert(self.thresholds, {percent=percent, fn=fn})
    --table.sort(self.thresholds, function(l,r) return l.percent < r.percent)
end

function Fueled:GetSectionPercent()
    local section = self:GetCurrentSection()
    return (self:GetPercent() - (section - 1)/self.sections) / (1/self.sections)
end

function Fueled:GetPercent()
    return self.maxfuel > 0 and math.max(0, math.min(1, self.currentfuel / self.maxfuel)) or 0
end

function Fueled:SetPercent(amount)
    local target = (self.maxfuel * amount)
    self:DoDelta(target - self.currentfuel)
end

function Fueled:SetFirstPeriod(firstperiod, firstperiodfull)
    self.firstperiod = firstperiod
    self.firstperiodfull = firstperiodfull --optional
end

local function OnDoUpdate(inst, self, period)
    self:DoUpdate(period)
end

function Fueled:StartConsuming()
    self.consuming = true
    if self.task == nil then
        self.task = self.inst:DoPeriodicTask(self.period, OnDoUpdate, nil, self, self.period)
        if self.firstperiod ~= nil then
            self.firstperioddt = self.currentfuel >= self.maxfuel and self.firstperiodfull or self.firstperiod
            self.inst:StartWallUpdatingComponent(self)
        end
    end
end

function Fueled:OnWallUpdate(dt)
    if TheNet:IsServerPaused() then return end

    dt = self.firstperioddt
    self.firstperioddt = nil
    self.inst:StopWallUpdatingComponent(self)
    self:DoUpdate(dt)
end

function Fueled:InitializeFuelLevel(fuel)
    local oldsection = self:GetCurrentSection()
    if self.maxfuel < fuel then
        self.maxfuel = fuel
    end
    self.currentfuel = fuel

    local newsection = self:GetCurrentSection()
    if oldsection ~= newsection then
        if self.sectionfn then
	        self.sectionfn(newsection, oldsection, self.inst)
		end
        self.inst:PushEvent("onfueldsectionchanged", { newsection = newsection, oldsection = oldsection })
    end
end

function Fueled:DoDelta(amount, doer)
    local oldsection = self:GetCurrentSection()

    self.currentfuel = math.max(0, math.min(self.maxfuel, self.currentfuel + amount))

    local newsection = self:GetCurrentSection()

    if oldsection ~= newsection then
        if self.sectionfn then
            self.sectionfn(newsection, oldsection, self.inst, doer)
        end
        self.inst:PushEvent("onfueldsectionchanged", { newsection = newsection, oldsection = oldsection, doer = doer })
        if self.currentfuel <= 0 and self.depleted then
            self.depleted(self.inst)
        end
    end

    self.inst:PushEvent("percentusedchange", { percent = self:GetPercent() })
end

function Fueled:DoUpdate(dt)
    if self.consuming then
        self:DoDelta(-dt * self.rate * self.rate_modifiers:Get())
    end

    if self:IsEmpty() then
        self:StopConsuming()
    end

    if self.updatefn ~= nil then
        self.updatefn(self.inst)
    end
end

function Fueled:StopConsuming()
    self.consuming = false
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
    if self.firstperioddt ~= nil then
        self.firstperioddt = nil
        self.inst:StopWallUpdatingComponent(self)
    end
end

Fueled.LongUpdate = Fueled.DoUpdate

return Fueled
