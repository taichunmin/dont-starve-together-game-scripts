local Sanity = Class(function(self, inst)
    self.inst = inst

    self._oldisinsane = false
    self._isinsane = net_bool(inst.GUID, "sanity._isinsane", "isinsanedirty")

    if TheWorld.ismastersim then
        self.classified = inst.player_classified
    elseif self.classified == nil and inst.player_classified ~= nil then
        self:AttachClassified(inst.player_classified)
    end
end)

--------------------------------------------------------------------------

function Sanity:OnRemoveFromEntity()
    if self.classified ~= nil then
        if TheWorld.ismastersim then
            self.classified = nil
        else
            self.inst:RemoveEventCallback("onremove", self.ondetachclassified, self.classified)
            self:DetachClassified()
        end
    end
end

Sanity.OnRemoveEntity = Sanity.OnRemoveFromEntity

local function OnIsInsaneDirty(inst)
    local self = inst.replica.sanity
    if self ~= nil then
        if self._oldisinsane ~= self._isinsane:value() then
            inst:PushEvent(self._oldisinsane and "gosane" or "goinsane")
            self._oldisinsane = not self._oldisinsane
        end
    end
end

function Sanity:AttachClassified(classified)
    self.classified = classified
    self.ondetachclassified = function() self:DetachClassified() end
    self.inst:ListenForEvent("onremove", self.ondetachclassified, classified)
    self.inst:ListenForEvent("isinsanedirty", OnIsInsaneDirty)
    OnIsInsaneDirty(self.inst)
end

function Sanity:DetachClassified()
    self.classified = nil
    self.ondetachclassified = nil
    self.inst:RemoveEventCallback("isinsanedirty", OnIsInsaneDirty)
end

--------------------------------------------------------------------------
--Client helpers

local function GetPenaltyPercent_Client(self)
    return self.classified.sanitypenalty:value() / 200
end

local function MaxWithPenalty_Client(self)
    --V2C: precision error.. gg...
    --return self.classified.maxsanity:value() * (1 - GetPenaltyPercent_Client(self))
    return self.classified.maxsanity:value() * (200 - self.classified.sanitypenalty:value()) / 200
end

--------------------------------------------------------------------------

function Sanity:SetCurrent(current)
    if self.classified ~= nil then
        self.classified:SetValue("currentsanity", current)
    end
end

function Sanity:SetMax(max)
    if self.classified ~= nil then
        self.classified:SetValue("maxsanity", max)
    end
end

function Sanity:SetPenalty(penalty)
    if self.classified ~= nil then
        assert(penalty >= 0 and penalty <= 1, "Player sanitypenalty out of range "..tostring(penalty))
        self.classified.sanitypenalty:set(math.floor(penalty * 200 + .5))
    end
end

function Sanity:Max()
    if self.inst.components.sanity ~= nil then
        return self.inst.components.sanity.max
    elseif self.classified ~= nil then
        return self.classified.maxsanity:value()
    else
        return 100
    end
end

function Sanity:MaxWithPenalty()
    if self.inst.components.sanity ~= nil then
        return self.inst.components.sanity:GetMaxWithPenalty()
    elseif self.classified ~= nil then
        return MaxWithPenalty_Client(self)
    else
        return 100
    end
end

function Sanity:GetPercent()
    if self.inst.components.sanity ~= nil then
        return self.inst.components.sanity:GetPercent()
    end
    return self:GetPercentNetworked()
end

function Sanity:GetPercentNetworked()
    --Use networked value whether we are server or client
    return self.classified ~= nil and self.classified.currentsanity:value() / self.classified.maxsanity:value() or 1
end

function Sanity:GetCurrent()
    if self.inst.components.sanity ~= nil then
        return self.inst.components.sanity.current
    elseif self.classified ~= nil then
        return self.classified.currentsanity:value()
    else
        return 100
    end
end


function Sanity:GetPercentWithPenalty()
    if self.inst.components.sanity ~= nil then
        return self.inst.components.sanity:GetPercentWithPenalty()
    elseif self.classified ~= nil then
        return self.classified.currentsanity:value() / MaxWithPenalty_Client(self)
    else
        return 1
    end
end

function Sanity:GetPenaltyPercent()
    if self.inst.components.sanity ~= nil then
        return self.inst.components.sanity:GetPenaltyPercent()
    elseif self.classified ~= nil then
        return GetPenaltyPercent_Client(self)
    else
        return 0
    end
end

function Sanity:SetRateScale(ratescale)
    if self.classified ~= nil then
        self.classified.sanityratescale:set(ratescale)
    end
end

function Sanity:GetRateScale()
    if self.inst.components.sanity ~= nil then
        return self.inst.components.sanity:GetRateScale()
    elseif self.classified ~= nil then
        return self.classified.sanityratescale:value()
    else
        return RATE_SCALE.NEUTRAL
    end
end

function Sanity:SetIsSane(sane)
    self._isinsane:set(not sane)
end

function Sanity:IsSane()
    return not self._isinsane:value()
end

function Sanity:IsCrazy()
    return self._isinsane:value()
end

function Sanity:SetGhostDrainMult(ghostdrainmult)
    if self.classified ~= nil then
        self.classified.issanityghostdrain:set(ghostdrainmult > 0)
    end
end

function Sanity:IsGhostDrain()
    return self.classified ~= nil and self.classified.issanityghostdrain:value()
end

return Sanity