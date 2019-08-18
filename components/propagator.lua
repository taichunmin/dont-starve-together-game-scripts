local Propagator = Class(function(self, inst)
    self.inst = inst
    self.flashpoint = 100
    self.currentheat = 0
    self.decayrate = 1

    self.propagaterange = 3
    self.heatoutput = 5
    
    self.damages = false
    self.damagerange = 3

    self.pvp_damagemod = TUNING.PVP_DAMAGE_MOD or 1 -- players shouldn't hurt other players very much, even with fire

    self.acceptsheat = false
    --We need a separate internal flag since acceptsheat is
    --used as a public property for configuring propagator.
    --self.pauseheating = nil

    self.spreading = false
    self.delay = nil
end)

function Propagator:OnRemoveFromEntity()
    self:StopSpreading(true)
    self:OnUpdate(0)
    if self.delay ~= nil then
        self.delay:Cancel()
        self.delay = nil
    end
end

function Propagator:SetOnFlashPoint(fn)
    self.onflashpoint = fn
end

local function OnDelay(inst, self)
    self.delay = nil
end

function Propagator:Delay(time)
    if self.delay ~= nil then
        self.delay:Cancel()
    end
    self.delay = self.inst:DoTaskInTime(time, OnDelay, self)
end

function Propagator:StopUpdating()
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
end

local function _OnUpdate(inst, self, dt)
    self:OnUpdate(dt)
end

function Propagator:StartUpdating()
    if self.task == nil then
        local dt = .5
        self.task = self.inst:DoPeriodicTask(dt, _OnUpdate, dt + math.random() * .67, self, dt)
    end
end

function Propagator:StartSpreading(source)
    self.source = source
    self.spreading = true
    self:StartUpdating()
end

function Propagator:StopSpreading(reset, heatpct)
    self.source = nil
    self.spreading = false
    if reset then
        self.currentheat = heatpct ~= nil and heatpct * self.flashpoint or 0
        self.pauseheating = nil
    end
end

function Propagator:GetHeatResistance()
    local tile, data = self.inst:GetCurrentTileType()
    return data ~= nil
        and data.flashpoint_modifier ~= nil
        and data.flashpoint_modifier ~= 0
        and math.max(1, self.flashpoint) / math.max(1, self.flashpoint + data.flashpoint_modifier)
        or 1
end

function Propagator:AddHeat(amount)
    if self.delay ~= nil or self.inst:HasTag("fireimmune") then
        return
    end

    if self.currentheat <= 0 then
        self:StartUpdating()
    end

    self.currentheat = self.currentheat + amount * self:GetHeatResistance()

    if self.currentheat > self.flashpoint then
        self.pauseheating = true
        if self.onflashpoint ~= nil then
            self.onflashpoint(self.inst)
        end
    end
end

function Propagator:Flash()
    if self.acceptsheat and not self.pauseheating and self.delay == nil then
        self:AddHeat(self.flashpoint + 1)
    end
end

function Propagator:OnUpdate(dt)
    self.currentheat = math.max(0, self.currentheat - dt * self.decayrate)

    if self.spreading then
        local pos = self.inst:GetPosition()
        local prop_range = TheWorld.state.isspring and self.propagaterange * TUNING.SPRING_FIRE_RANGE_MOD or self.propagaterange
        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, prop_range, nil, { "INLIMBO" })
        if #ents > 0 then
            local dmg_range = TheWorld.state.isspring and self.damagerange * TUNING.SPRING_FIRE_RANGE_MOD or self.damagerange
            local dmg_range_sq = dmg_range * dmg_range
            local prop_range_sq = prop_range * prop_range
            local isendothermic = self.inst.components.heater ~= nil and self.inst.components.heater:IsEndothermic()

            for i, v in ipairs(ents) do
                if v:IsValid() then
                    --3D distance
                    local dsq = distsq(pos, v:GetPosition())

                    if v ~= self.inst then
                        if v.components.propagator ~= nil and
                            v.components.propagator.acceptsheat and
                            not v.components.propagator.pauseheating then
                            local percent_heat = math.max(.1, 1 - dsq / prop_range_sq)
                            v.components.propagator:AddHeat(self.heatoutput * percent_heat * dt)
                        end

                        if v.components.freezable ~= nil then
                            v.components.freezable:AddColdness(-.25 * self.heatoutput *dt)
                            if v.components.freezable:IsFrozen() and v.components.freezable.coldness <= 0 then
                                --Skip thawing
                                v.components.freezable:Unfreeze()
                            end
                        end

                        if not isendothermic and (v:HasTag("frozen") or v:HasTag("meltable")) then
                            v:PushEvent("firemelt")
                            v:AddTag("firemelt")
                        end
                    end

                    if self.damages and
                        --V2C: DST specific (DSV does not check this)--
                        --Affects things with health but not burnable--
                        v.components.propagator ~= nil and
                        -----------------------------------------------
                        dsq < dmg_range_sq and
                        v.components.health ~= nil and
                        --V2C: vulnerabletoheatdamage isn't used, but we'll keep it in case
                        --     for MOD support and make nil default to true to save memory.
                        v.components.health.vulnerabletoheatdamage ~= false then
                        --V2C: Confirmed that distance scaling was intentionally removed as a design decision
                        --local percent_damage = math.min(.5, 1 - math.min(1, dsq / dmg_range_sq))
                        local percent_damage = self.source ~= nil and self.source:HasTag("player") and self.pvp_damagemod or 1
                        v.components.health:DoFireDamage(self.heatoutput * percent_damage * dt)
                    end
                end
            end
        end
    else
        if not (self.inst.components.heater ~= nil and self.inst.components.heater:IsEndothermic()) then
            local x, y, z = self.inst.Transform:GetWorldPosition()
            local prop_range = TheWorld.state.isspring and self.propagaterange * TUNING.SPRING_FIRE_RANGE_MOD or self.propagaterange
            local ents = TheSim:FindEntities(x, y, z, prop_range, { "frozen", "firemelt" })
            for i, v in ipairs(ents) do
                v:PushEvent("stopfiremelt")
                v:RemoveTag("firemelt")
            end
        end
        if self.currentheat <= 0 then
            self:StopUpdating()
        end
    end
end

function Propagator:GetDebugString()
    return string.format("range: %.2f output: %.2f heatresist: %.2f flashpoint: %.2f delay: %s, spread: %s acceptheat: %s curheat: %s", self.propagaterange, self.heatoutput, self:GetHeatResistance(), self.flashpoint, tostring(self.delay ~= nil), tostring(self.spreading), tostring(self.acceptsheat)..(self.pauseheating and " (paused)" or ""), tostring(self.currentheat))
end

return Propagator
