require("behaviours/chaseandattack")
require("behaviours/faceentity")
require("behaviours/leash")
require("behaviours/wander")

local PRIORITY_NODE_RATE = 0.5
local MAX_CHASE_TIME, CHASE_GIVEUP_DISTANCE = 20, 25

----
local Fused_ShadelingBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function should_combat_jump(inst)
    local target = inst.components.combat.target
    if not target or inst.components.combat:InCooldown() or inst.components.timer:TimerExists("jump_cooldown") then
        return false
    end

    local spawnpoint = inst.components.knownlocations:GetLocation("spawnpoint")
    local aggro_rangesq = (TUNING.FUSED_SHADELING_AGGRO_RANGE * TUNING.FUSED_SHADELING_AGGRO_RANGE)
    if spawnpoint and target:GetDistanceSqToPoint(spawnpoint) > aggro_rangesq then
        return false
    end

    local MAX_JUMP_DSQ = (TUNING.FUSED_SHADELING_MAXJUMPDISTANCE * TUNING.FUSED_SHADELING_MAXJUMPDISTANCE)
    local MIN_JUMP_DSQ = MAX_JUMP_DSQ / 4

    local dsq_to_target = inst:GetDistanceSqToInst(target)
    return (dsq_to_target > MIN_JUMP_DSQ - 0.01) and (dsq_to_target < MAX_JUMP_DSQ + 0.01)
end

local function get_spawnpoint(inst)
    return inst.components.knownlocations:GetLocation("spawnpoint")
end

function Fused_ShadelingBrain:OnStart()
    local root = PriorityNode(
    {
        FailIfSuccessDecorator(ConditionWaitNode(function() return not self.inst.sg:HasStateTag("jumping") end, "<Block While Jumping>")),
        -----------------------------------------------------------------------------------------

        WhileNode(function() return should_combat_jump(self.inst) end, "Should I Jump In?",
            ActionNode(function()
                -- should_combat_jump should have failed if the target is nil, so we can just grab its position here.
                self.inst:PushEvent("try_jump", self.inst.components.combat.target:GetPosition())
            end)),
        ChaseAndAttack(self.inst, MAX_CHASE_TIME, CHASE_GIVEUP_DISTANCE, 2),
        Leash(self.inst, get_spawnpoint, 20, 3, true),
        Wander(self.inst, get_spawnpoint, 20),
    }, PRIORITY_NODE_RATE)

    self.bt = BT(self.inst, root)
end

return Fused_ShadelingBrain