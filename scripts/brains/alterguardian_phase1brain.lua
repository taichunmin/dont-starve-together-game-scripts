require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/standandattack"
require "behaviours/useshield"
require "behaviours/wander"

local AlterGuardian_Phase1Brain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local use_shield_data =
{
    dontupdatetimeonattack = true,
    usecustomanims = true,
    dontshieldforfire = true,
}

local function GetWanderHome(inst)
    -- If we have a target, we want to pick randomly and fall through to GetWanderDir
    if inst.components.combat.target ~= nil then
        return nil
    else
        return inst.components.knownlocations:GetLocation("spawnpoint")
    end
end

local MAX_CHASE_DIST = 60
local wander_times =
{
    minwalktime = 4,
    randwalktime = 1.5,
    minwaittime = 3,
    randwaittime = 2,
}
local function GetWanderDir(inst)
    if inst.components.combat.target == nil then
        return nil
    else
        -- If we have a target, get the angle towards the target,
        -- then add a bit of randomness, and wander in that direction.
        -- Like it's coming for you, but not able to come _right_ at you.
        local tx, _, tz = inst.components.combat.target.Transform:GetWorldPosition()
        return (inst:GetAngleToPoint(tx, 0, tz) + GetRandomWithVariance(0, 30)) * DEGREES
    end
end
local wander_data =
{
    wander_dist = 3,
}

function AlterGuardian_Phase1Brain:OnStart()
    local behaviour_root = PriorityNode({
        UseShield(self.inst, TUNING.ALTERGUARDIAN_PHASE1_SHIELDTRIGGER, 8.5, nil, nil, use_shield_data),

        WhileNode(function()
                    return self.inst.components.combat.target ~= nil
                        and self.inst.components.combat:CanAttack(self.inst.components.combat.target)
                        and not self.inst.components.combat:InCooldown()
                end, "AttackIfNearby",
            StandAndAttack(self.inst, nil, 1)
        ),

        Wander(self.inst, GetWanderHome, MAX_CHASE_DIST, wander_times, GetWanderDir),
    }, .25)

    local charging_barrier = PriorityNode(
    {
        WhileNode(function()
                return not self.inst.sg:HasStateTag("charge")
            end, "While Not Charging",
            behaviour_root
        )
    }, .25)

    self.bt = BT(self.inst, charging_barrier)
end

function AlterGuardian_Phase1Brain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("spawnpoint", self.inst:GetPosition())
end

return AlterGuardian_Phase1Brain
