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

local TARGET_MUST_TAGS = { "character" }
local TARGET_CANT_TAGS = { "INLIMBO", "noauradamage" }

local function GetFollowTarget(ghost)
    if ghost.brain.followtarget ~= nil
        and (not ghost.brain.followtarget:IsValid() or
            not ghost.brain.followtarget.entity:IsVisible() or
            ghost.brain.followtarget:IsInLimbo() or
            ghost.brain.followtarget.components.health == nil or
            ghost.brain.followtarget.components.health:IsDead() or
            ghost:GetDistanceSqToInst(ghost.brain.followtarget) > TUNING.GHOST_FOLLOW_DSQ) then

        ghost.brain.followtarget = nil
    end

    if ghost.brain.followtarget == nil then

        local gx, gy, gz = ghost.Transform:GetWorldPosition()
        local potential_followtargets = TheSim:FindEntities(gx, gy, gz, 10, TARGET_MUST_TAGS, TARGET_CANT_TAGS)
        for _, pft in ipairs(potential_followtargets) do
            -- We should only follow living characters.
            if IsAlive(pft) then
                -- If a character is ghost-friendly, don't immediately target them, unless they're targeting us.
                -- Actively target anybody else.
                local ghost_friendly = pft:HasTag("ghostlyfriend") or pft:HasTag("abigail")
                if ghost_friendly then
                    if ghost.components.combat:TargetIs(pft) or (pft.components.combat ~= nil and pft.components.combat:TargetIs(ghost)) then
                        ghost.brain.followtarget = pft
                        break
                    end
                else
                    ghost.brain.followtarget = pft
                    break
                end
            end
        end
    end

    return ghost.brain.followtarget
end

function GhostBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return GetFollowTarget(self.inst) ~= nil end, "FollowTarget",
            Follow(self.inst, function() return self.inst.brain.followtarget end, TUNING.GHOST_RADIUS*.25, TUNING.GHOST_RADIUS*.5, TUNING.GHOST_RADIUS)
        ),
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