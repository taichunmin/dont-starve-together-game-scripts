local EPSILON = 0.001 -- The smallest acceptable range value, basically.
local function onblock_rsq(self, newrsq)
    if newrsq ~= nil and newrsq > EPSILON then
        self.inst:AddTag("lightningblocker")
    else
        self.inst:RemoveTag("lightningblocker")
    end
end

local LightningBlocker = Class(function(self, inst)
    self.inst = inst

    self.block_rsq = 0
    --self.on_strike = nil
end,
nil,
{
    block_rsq = onblock_rsq
})

function LightningBlocker:OnRemoveFromEntity()
    self.inst:RemoveTag("lightningblocker")
end

function LightningBlocker:SetBlockRange(newrange)
    self.block_rsq = (newrange ~= nil and newrange * newrange) or nil
end

function LightningBlocker:SetOnLightningStrike(fn)
    self.on_strike = fn
end

function LightningBlocker:DoLightningStrike(pos)
    if self.on_strike ~= nil then
        self.on_strike(self.inst, pos)
    end
end

return LightningBlocker