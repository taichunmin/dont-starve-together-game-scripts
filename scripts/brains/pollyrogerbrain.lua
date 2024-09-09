require "behaviours/follow"
require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/standstill"

local BrainCommon = require("brains/braincommon")


local MIN_FOLLOW_DIST = 0
local MAX_FOLLOW_DIST = 8
local TARGET_FOLLOW_DIST = 6

local STOP_RUN_DIST = 10
local SEE_MONSTER_DIST = 5
local AVOID_MONSTER_DIST = 3
local AVOID_MONSTER_STOP = 6


local function closetoleader(inst)
    if inst.sg:HasStateTag("busy") then
        return nil
    end
    local leader = inst.components.follower and inst.components.follower.leader or nil
    if leader and leader:GetDistanceSqToInst(inst) < TUNING.POLLY_ROGERS_RANGE * TUNING.POLLY_ROGERS_RANGE then
        return true
    end
end

local ShouldRunAway = {
    tags = { "hostile" },
    notags = { "NOCLICK", "invisible" }, -- NOTES(JBK): You can not fear what you can not see right Polly?
    fn = function(thing, polly)
        if thing.components.follower ~= nil then
            local leader = thing.components.follower:GetLeader()
            if leader and leader:HasTag("player") then -- TODO(JBK): PVP check.
                return false
            end
        end
        return true
    end,
}

local PollyRogerBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function PollyRogerBrain:OnStart()
    local pickupparams = {
        cond = function()
            return self.inst.readytogather
        end,
        range = TUNING.POLLY_ROGERS_RANGE,
        furthestfirst = true,
    }

    local root =
    PriorityNode(
    {
        WhileNode( function() return not self.inst.sg:HasStateTag("busy") end, "NO BRAIN WHEN BUSY",
            PriorityNode({
				BrainCommon.PanicTrigger(self.inst),
                RunAway(self.inst, ShouldRunAway, AVOID_MONSTER_DIST, AVOID_MONSTER_STOP),
                RunAway(self.inst, ShouldRunAway, SEE_MONSTER_DIST, STOP_RUN_DIST), -- NOTES(JBK): Polly Rogers has an atypical home to go back to so do not use typical home run logic!
                WhileNode( function() return closetoleader(self.inst) end, "Stayclose", BrainCommon.NodeAssistLeaderPickUps(self, pickupparams)),
                Follow(self.inst, function() return self.inst.components.follower and self.inst.components.follower.leader or nil end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
                StandStill(self.inst),
            }, .25)
        ),
    }, .25)
    self.bt = BT(self.inst, root)
end

return PollyRogerBrain