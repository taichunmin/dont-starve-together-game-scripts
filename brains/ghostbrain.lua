require "behaviours/follow"
require "behaviours/wander"

local GhostBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function IsAlive(target)
    return target.entity:IsVisible() and
        target.components.health ~= nil and
        not target.components.health:IsDead()
end

local function GetFollowTarget(ghost)
    if ghost.brain.followtarget ~= nil
        and (not ghost.brain.followtarget:IsValid() or
            not ghost.brain.followtarget.entity:IsVisible() or
            ghost.brain.followtarget:IsInLimbo() or
            ghost.brain.followtarget.components.health == nil or
            ghost.brain.followtarget.components.health:IsDead() or
            ghost:GetDistanceSqToInst(ghost.brain.followtarget) > 15 * 15) then
        ghost.brain.followtarget = nil
    end
    
    if ghost.brain.followtarget == nil then
        ghost.brain.followtarget = FindEntity(ghost, 10, IsAlive, { "character" }, { "INLIMBO" })
    end

    return ghost.brain.followtarget
end

function GhostBrain:OnStart()
    local root = PriorityNode(
    {
        Follow(self.inst, function() return GetFollowTarget(self.inst) end, TUNING.GHOST_RADIUS*.25, TUNING.GHOST_RADIUS*.5, TUNING.GHOST_RADIUS),
        SequenceNode{
			ParallelNodeAny{
				WaitNode(10),
				Wander(self.inst),
			},
            ActionNode(function() self.inst.sg:GoToState("dissipate") end),
        }
    }, 1)
        
    self.bt = BT(self.inst, root)
end

return GhostBrain