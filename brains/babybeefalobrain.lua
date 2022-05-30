require "behaviours/wander"
require "behaviours/panic"
require "behaviours/follow"
require "behaviours/runaway"


local MIN_FOLLOW_DIST = 2
local TARGET_FOLLOW_DIST = 3
local MAX_FOLLOW_DIST = 8
local WANDER_DIST = 8

local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 10

local function NonMountedPlayer(other)
    return other.components.rider == nil
        or other.components.rider:GetMount() == nil
        or not other.components.rider:GetMount():HasTag("beefalo")
end

local BabyBeefaloBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function BabyBeefaloBrain:OnStart()

    local root = PriorityNode(
    {
    	WhileNode( function() return self.inst.components.hauntable and self.inst.components.hauntable.panic end, "PanicHaunted", Panic(self.inst)),
        WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
        RunAway(self.inst, {tags={"character"}, fn=NonMountedPlayer}, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST),
        Follow(self.inst, function() return (self.inst.components.follower ~= nil and
                                            self.inst.components.follower.leader ~= nil and
                                            self.inst.components.follower.leader:GetCurrentPlatform() == self.inst:GetCurrentPlatform() and
                                            self.inst.components.follower.leader) or
                                            nil
                            end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("herd") end, WANDER_DIST)
    }, .25)

    self.bt = BT(self.inst, root)

end

return BabyBeefaloBrain
