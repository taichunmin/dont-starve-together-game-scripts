
local function onsetchanneler(self)
    if self.channeler ~= nil then
        self.inst:AddTag("channeled")
    else
        self.inst:RemoveTag("channeled")
    end
end

local function onsetenabled(self)
    if self.enabled then
        self.inst:AddTag("channelable")
    else
        self.inst:RemoveTag("channelable")
    end
end

local function onuse_channel_longaction(self)
    if self.use_channel_longaction then
        self.inst:AddTag("use_channel_longaction")
    else
        self.inst:RemoveTag("use_channel_longaction")
    end
end

local Channelable = Class(function(self, inst)
    self.inst = inst
    self.enabled = true
    self.channeler = nil

    --self.use_channel_longaction = nil
end,
nil,
{
    enabled = onsetenabled,
    channeler = onsetchanneler,
    use_channel_longaction = onuse_channel_longaction,
})

function Channelable:OnRemoveFromEntity()
    self.inst:StopUpdatingComponent(self)
    self.inst:RemoveTag("use_channel_longaction")
end

function Channelable:SetEnabled(enabled)
    self.enabled = enabled
end

function Channelable:SetChannelingFn(startfn, stopfn)
    self.onchannelingfn = startfn
    self.onstopchannelingfn = stopfn
end

function Channelable:IsChanneling()
    return self.channeler ~= nil
        and self.channeler:IsValid()
        and self.channeler.sg ~= nil
        and self.channeler.sg:HasStateTag("channeling")
end

function Channelable:StartChanneling(channeler)
    if self.enabled and
        ( not self:IsChanneling() or self.ignore_prechannel) and
        channeler ~= nil and
        channeler:IsValid() and
        channeler.sg ~= nil and
        (channeler.sg:HasStateTag("prechanneling") or self.skip_state_channeling ) then

        self.channeler = channeler
        if not self.skip_state_channeling then
            channeler.sg:GoToState("channeling", self.inst)
        end

        if self.onchannelingfn ~= nil then
            self.onchannelingfn(self.inst, channeler)
        end

        self.inst:StartUpdatingComponent(self)

        return true
    end
end

function Channelable:StopChanneling(aborted)
    if self:IsChanneling() then
        self.channeler.sg.statemem.stopchanneling = true
        if not self.skip_state_stopchanneling then
            self.channeler.sg:GoToState("stopchanneling")
        end
    end

    if self.onstopchannelingfn ~= nil then
        self.onstopchannelingfn(self.inst, aborted)
    end

    self.channeler = nil
    self.inst:StopUpdatingComponent(self)
end

function Channelable:OnUpdate(dt)
    if not self:IsChanneling() then
        self:StopChanneling(true)
    end
end

function Channelable:GetDebugString()
    return self:IsChanneling() and "Channeling" or "Not Channeling"
end

return Channelable
