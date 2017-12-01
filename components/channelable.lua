
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

local Channelable = Class(function(self, inst)
    self.inst = inst
    self.enabled = true
    self.channeler = nil
end,
nil,
{
    enabled = onsetenabled,
    channeler = onsetchanneler,
})

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
        not self:IsChanneling() and
        channeler ~= nil and
        channeler:IsValid() and
        channeler.sg ~= nil and
        channeler.sg:HasStateTag("prechanneling") then

        self.channeler = channeler
        channeler.sg:GoToState("channeling", self.inst)

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
        self.channeler.sg:GoToState("stopchanneling")
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
