local DefaultOnStrike = function(inst)
    if inst.components.health ~= nil and not (inst.components.health:IsDead() or inst.components.health:IsInvincible()) then
        if not inst.components.inventory:IsInsulated() then
            local mult = TUNING.ELECTRIC_WET_DAMAGE_MULT * inst.components.moisture:GetMoisturePercent()
            local damage = TUNING.LIGHTNING_DAMAGE + mult * TUNING.LIGHTNING_DAMAGE
            -- Magic hit point stuff that isn't being used right now
            -- if damage >= inst.components.health.currenthealth - 5 and inst.components.health.currenthealth > 10 then
            --     damage = inst.components.health.currenthealth - 5
            -- end

            inst.components.health:DoDelta(-damage, false, "lightning")
            if not inst.sg:HasStateTag("dead") then
                inst.sg:GoToState("electrocute")
            end
        else
            inst:PushEvent("lightningdamageavoided")
        end
    end
end

local PlayerLightningTarget = Class(function(self, inst)
    self.inst = inst
    self.hitchance = TUNING.PLAYER_LIGHTNING_TARGET_CHANCE
    self.onstrikefn = DefaultOnStrike
end)

function PlayerLightningTarget:SetHitChance(chance)
    self.hitchance = chance
end

function PlayerLightningTarget:GetHitChance()
    return self.hitchance
end

function PlayerLightningTarget:SetOnStrikeFn(fn)
    self.onstrikefn = fn
end

function PlayerLightningTarget:DoStrike()
    if self.onstrikefn ~= nil then
        self.onstrikefn(self.inst)
    end
end

return PlayerLightningTarget