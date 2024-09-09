require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/runaway"
require "behaviours/leash"
local BrainCommon = require("brains/braincommon")

local MIN_FOLLOW_DIST = 0
local MAX_FOLLOW_DIST = 25
local TARGET_FOLLOW_DIST = 6
local MAX_WANDER_DIST = 8

local LEASH_RETURN_DIST = 15
local LEASH_MAX_DIST = 30


local AVOID_PLAYER_DIST = 7
local AVOID_PLAYER_STOP = 12

local AVOID_DIST = 7
local AVOID_STOP = 12


local NO_TAGS = {"FX", "NOCLICK", "DECOR","INLIMBO", "stump", "burnt"}

local function GetWanderDistFn(inst)
    return MAX_WANDER_DIST
end

local GrassgekkoBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function GrassgekkoBrain:OnStart()
    local root =
    PriorityNode(
    {
		BrainCommon.PanicTrigger(self.inst),
        RunAway(self.inst, "scarytoprey", AVOID_PLAYER_DIST, AVOID_PLAYER_STOP , function() return true end ),
        RunAway(self.inst, "player", AVOID_DIST, AVOID_STOP, nil, nil, NO_TAGS),
        --Wander(self.inst, function() return self.inst:GetPosition() end, MAX_WANDER_DIST),
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("herd") end, GetWanderDistFn)
    }, .25)
    self.bt = BT(self.inst, root)
end

return GrassgekkoBrain