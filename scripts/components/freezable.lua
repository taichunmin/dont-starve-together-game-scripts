local states =
{
    FROZEN = "FROZEN",
    THAWING = "THAWING",
    NORMAL = "NORMAL",
}

local FREEZE_COLOUR = { 82 / 255, 115 / 255, 124 / 255, 0 }

local function WearOff(inst, self)
    if self.state == states.FROZEN then
        self:Thaw()
    elseif self.state == states.THAWING then
        self:Unfreeze()
    elseif self.coldness > 0 then
        self.coldness = math.max(0, self.coldness - 1)
        if self.coldness > 0 then
            self:StartWearingOff()
        end
    end
    self:UpdateTint()
end

local function OnAttacked(inst, data)
    local self = inst.components.freezable
	--IsValid check because other "attacked" handlers may have removed us
	--NOTE: see how EntityScript:PushEvent caches all listeners; that is why an invalid entity could still reach this event listener
	if self:IsFrozen() and inst:IsValid() then
        self.damagetotal = self.damagetotal + math.abs(data.damage)
        if self.damagetotal >= self.damagetobreak then
            self:Unfreeze()
        end
    end
end
-----------------------------------------------------------------------------------------------------

local Freezable = Class(function(self, inst)
    self.inst = inst
    self.state = states.NORMAL
    self.resistance = 1
    self.coldness = 0
    self.wearofftime = 10

    self.damagetotal = 0
    self.damagetobreak = 0

    self.fxlevel = 1
    self.fxdata = {}
    --self.fxchildren = {}

    --these are for diminishing returns (mainly bosses), so nil for default
    --self.diminishingreturns = false
    --self.extraresist = 0
    --self.diminishingtask = nil

	--self.redirectfn = nil

    self.inst:ListenForEvent("attacked", OnAttacked)
    self.inst:AddTag("freezable")
end)

function Freezable:OnRemoveFromEntity()
    self.inst:RemoveEventCallback("attacked", OnAttacked)
    self.inst:RemoveTag("freezable")
    if self.diminishingtask ~= nil then
        self.diminishingtask:Cancel()
    end
    if self.wearofftask ~= nil then
        self.wearofftask:Cancel()
    end
end

function Freezable:SetResistance(resist)
    self.resistance = resist
end

function Freezable:SetDefaultWearOffTime(wearofftime)
    self.wearofftime = wearofftime
end

function Freezable:AddShatterFX(prefab, offset, followsymbol)
    table.insert(self.fxdata, { prefab = prefab, x = offset.x, y = offset.y, z = offset.z, follow = followsymbol })
end

function Freezable:SetShatterFXLevel(level, percent)
    self.fxlevel = level
--[[
    for k, v in pairs(self.fxchildren) do
        if v.components.shatterfx then
            v.components.shatterfx:SetLevel(level)
        end
    end
--]]
end

function Freezable:SpawnShatterFX()
    for k, v in pairs(self.fxdata) do
        local fx = SpawnPrefab(v.prefab)
        if fx ~= nil then
            if v.follow ~= nil then
                local follower = fx.entity:AddFollower()
                follower:FollowSymbol(self.inst.GUID, v.follow, v.x, v.y, v.z)
            else
                self.inst:AddChild(fx)
                fx.Transform:SetPosition(v.x, v.y, v.z)
            end
            --table.insert(self.fxchildren, fx)
            if fx.components.shatterfx ~= nil then
                fx.components.shatterfx:SetLevel(self.fxlevel)
            end
        end
    end
end

function Freezable:IsFrozen()
    return self.state == states.FROZEN or self.state == states.THAWING
end

function Freezable:IsThawing()
    return self.state == states.THAWING
end

function Freezable:GetDebugString()
    return string.format("%s: %2.2f / %2.2f <- %2.2f + %2.2f (Decay: %2.2f)",
        self.state,
        self.coldness,
        self:ResolveResistance(),
        self.resistance,
        self.extraresist or 0,
        self.diminishingtask ~= nil and GetTaskRemaining(self.diminishingtask) or 0)
end

function Freezable:SetRedirectFn(fn)
	self.redirectfn = fn
end

function Freezable:AddColdness(coldness, freezetime, nofreeze)
	if self.redirectfn ~= nil and self.redirectfn(self.inst, coldness, freezetime, nofreeze) then
		return
	end
    self.coldness = math.max(0, self.coldness + coldness)
    --V2C: when removing coldness, don't update freeze states here
    if coldness > 0 then
        if self:IsFrozen() then
            self:Freeze(freezetime)
        elseif self.coldness <= 0 then
            --not possible?
        else
            local resistance = self:ResolveResistance()
            if self.coldness < resistance then
                self:StartWearingOff()
            elseif self.inst.sg ~= nil and (nofreeze or self.inst.sg:HasStateTag("nofreeze")) then
                self.coldness = resistance
                self:StartWearingOff()
            else
                self:Freeze(freezetime)
            end
        end
    end
    self:UpdateTint()
end

function Freezable:StartWearingOff(wearofftime)
    if self.wearofftask ~= nil then
        self.wearofftask:Cancel()
    end
    self.wearofftask = self.inst:DoTaskInTime(self:ResolveWearOffTime(wearofftime or self.wearofftime), WearOff, self)
end

function Freezable:GetTimeToWearOff()
	return self.wearofftask ~= nil and GetTaskRemaining(self.wearofftask) or nil
end

local function PushColour(inst, r, g, b, a)
    if inst.components.colouradder ~= nil then
        inst.components.colouradder:PushColour("freezable", r, g, b, a)
    else
        inst.AnimState:SetAddColour(r, g, b, a)
    end
end

local function PopColour(inst)
    if inst.components.colouradder ~= nil then
        inst.components.colouradder:PopColour("freezable")
    else
        inst.AnimState:SetAddColour(0, 0, 0, 0)
    end
end

function Freezable:UpdateTint()
    if self.inst.AnimState ~= nil then
        local r, g, b, a
        if self:IsFrozen() then
            PushColour(self.inst, FREEZE_COLOUR[1], FREEZE_COLOUR[2], FREEZE_COLOUR[3], FREEZE_COLOUR[4])
        else
            local resistance = self:ResolveResistance()
            if self.coldness >= resistance then
                PushColour(self.inst, FREEZE_COLOUR[1], FREEZE_COLOUR[2], FREEZE_COLOUR[3], FREEZE_COLOUR[4])
            elseif self.coldness <= 0 then
                PopColour(self.inst)
            else
                local percent = self.coldness / resistance
                PushColour(self.inst, FREEZE_COLOUR[1] * percent, FREEZE_COLOUR[2] * percent, FREEZE_COLOUR[3] * percent, FREEZE_COLOUR[4] * percent)
            end
        end
    end
end

local function DecayExtraResist(inst, self)
    local new_resist = math.max(0, self.extraresist - .1)
    local current_resist = self.coldness - self.resistance
    if new_resist >= current_resist then
        self:SetExtraResist(new_resist)
    elseif current_resist < self.extraresist then
        self:SetExtraResist(current_resist)
    end
end

function Freezable:SetExtraResist(resist)
    self.extraresist = math.clamp(resist, 0, self.resistance * 2.5)
    if self.extraresist > 0 then
        if self.diminishingtask == nil then
            self.diminishingtask = self.inst:DoPeriodicTask(30, DecayExtraResist, nil, self)
        end
    elseif self.diminishingtask ~= nil then
        self.diminishingtask:Cancel()
        self.diminishingtask = nil
    end
end

function Freezable:ResolveResistance()
    return self.extraresist ~= nil
        and math.min(self.resistance * 2.5, self.resistance + self.extraresist)
        or self.resistance
end

function Freezable:ResolveWearOffTime(t)
    return self.extraresist ~= nil
        and t * math.clamp(1 - self.extraresist / (self.resistance * 2.5), .1, 1)
        or t
end

--V2C: Calling this direclty isn't great; :AddColdness instead!
function Freezable:Freeze(freezetime)
    if self.inst.entity:IsVisible() and not (self.inst.components.health ~= nil and self.inst.components.health:IsDead()) then
        if self.onfreezefn ~= nil then
            self.onfreezefn(self.inst)
        end

        if self.diminishingtask ~= nil then
            --Restart decay timer
            self.diminishingtask:Cancel()
            self.diminishingtask = self.inst:DoPeriodicTask(30, DecayExtraResist, nil, self)
        end

        local prevState = self.state
        self.state = states.FROZEN
        self:StartWearingOff(freezetime)
        self:UpdateTint()

        if self.inst.brain ~= nil then
            self.inst.brain:Stop()
        end

        if self.inst.components.combat ~= nil then
            self.inst.components.combat:SetTarget(nil)
        end

        if self.inst.components.locomotor ~= nil then
            self.inst.components.locomotor:Stop()
        end

        if self.state ~= prevState then
			self.inst:PushEvent("freeze")
            if self.diminishingreturns then
                self:SetExtraResist((self.extraresist or 0) + self.resistance * .25)
            end
        end
    end
end

function Freezable:Unfreeze()
    if self:IsFrozen() then
        self.state = states.NORMAL
        self.coldness = 0
        self.damagetotal = 0

        self:SpawnShatterFX()
        self:UpdateTint()

        if not (self.inst.components.health ~= nil and self.inst.components.health:IsDead()) then
            if self.inst.brain ~= nil then
                self.inst.brain:Start()
            end

            self.inst:PushEvent("unfreeze")

            -- prevent going from unfreeze immediately into an attack, it looks weird
            if self.inst.components.combat ~= nil then
                self.inst.components.combat:BlankOutAttacks(0.3)
            end
        end
    end
end

function Freezable:Thaw(thawtime)
    if self:IsFrozen() and not (self.inst.components.health ~= nil and self.inst.components.health:IsDead()) then
        self.state = states.THAWING
        self.coldness = 0
        self.inst:PushEvent("onthaw")
        self:StartWearingOff(self:ResolveWearOffTime(thawtime or self.wearofftime))
    end
end

-- Note: This doesn't push any events!
function Freezable:Reset()
    self.state = states.NORMAL
    self.coldness = 0
    self:UpdateTint()
end

function Freezable:OnSave()
    return self.extraresist ~= nil
        and self.extraresist > 0
        and { extraresist = math.floor(self.extraresist * 10) * .1 }
        or nil
end

function Freezable:OnLoad(data)
    if data.extraresist ~= nil then
        self:SetExtraResist(data.extraresist)
    end
end

return Freezable
