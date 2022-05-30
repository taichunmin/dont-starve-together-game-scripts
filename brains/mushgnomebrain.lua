require "behaviours/standandattack"
require "behaviours/standstill"
require "behaviours/wander"

local MushGnomeBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local THREAT_PARAMS =
{
    -- We are avoiding our own target, as well as anyone targeting us.
    fn = function(candidate, inst)
        return candidate.components.combat:TargetIs(inst) or
                inst.components.combat:TargetIs(candidate)
    end,
    tags =
    {
        "_combat",
    },
    notags =
    {
        "DECOR",
        "FX",
        "INLIMBO",
    },
}

local function false_func(inst)
    return false
end

function MushGnomeBrain:OnStart()
    local root =
        PriorityNode(
        {
            WhileNode(function() return self.inst.components.combat:HasTarget() and
                    not self.inst.components.combat:InCooldown() end, "Spray Spores",
                PriorityNode({
                    StandStill(self.inst, nil, false_func),    -- This is a dirty way to stop the locomotor before attacking...
                    StandAndAttack(self.inst, nil, 7)
                }, 1.0)
            ),
            WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire",
                Panic(self.inst)
            ),
            RunAway(self.inst, THREAT_PARAMS, 5, 10),
            Wander(self.inst),
        }, 1)

    self.bt = BT(self.inst, root)
end

return MushGnomeBrain
