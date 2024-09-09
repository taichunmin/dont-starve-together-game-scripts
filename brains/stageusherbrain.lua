require "behaviours/chaseandattack"
require "behaviours/doaction"
require "behaviours/standstill"
require "behaviours/wander"

local PRIORITY_NODE_RATE = 1.0
local MAX_CHASE_DIST = 3*TUNING.STAGEUSHER_ATTACK_RANGE
local RETURN_TO_SPAWN_TIMEOUT = 15

local StageUsherBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function StageUsherBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("spawnpoint", self.inst:GetPosition())
end

local function WalkHomeAction(inst)
    if inst.sg:HasStateTag("busy") then
        return nil
    end

    local location = (inst.components.knownlocations ~= nil and inst.components.knownlocations:GetLocation("spawnpoint"))
                    or nil
    if location ~= nil then
        local ba = BufferedAction(inst, nil, ACTIONS.WALKTO, nil, location)
        if ba ~= nil then
            ba:AddSuccessAction(function() inst:PushEvent("sitdown") end)
        end
        return ba
    else
        return nil
    end
end

function StageUsherBrain:OnStart()
    local standing_root =
        PriorityNode({
            EventNode(self.inst, "minhealth",
                ParallelNode{
                    ActionNode(function() self.inst.components.combat:GiveUp() end),
                    WaitNode(3),
                }),
            ChaseAndAttack(self.inst, nil, MAX_CHASE_DIST),
            WhileNode(function() return not self.inst.components.combat:HasTarget() end, "No Combat Target",
                ParallelNodeAny{
                    DoAction(self.inst, WalkHomeAction, "Return To Spawn", false, RETURN_TO_SPAWN_TIMEOUT + 2),
                    SequenceNode{
                        WaitNode(RETURN_TO_SPAWN_TIMEOUT),
                        ActionNode(function() self.inst:PushEvent("sitdown") end, "Sit Down Here"),
                    },
                }
            ),
            Wander(self.inst, nil, nil),
        }, PRIORITY_NODE_RATE)

    local root =
        PriorityNode({
            WhileNode(function() return self.inst:IsStanding() end, "Is Standing",
                standing_root),
            StandStill(self.inst),
        }, PRIORITY_NODE_RATE)

    self.bt = BT(self.inst, root)
end

return StageUsherBrain
