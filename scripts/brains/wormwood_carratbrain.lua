require "behaviours/follow"
require "behaviours/runaway"
require "behaviours/wander"

local BrainCommon = require("brains/braincommon")

local AVOID_PLAYER_DIST = 3
local AVOID_PLAYER_DIST_SQ = AVOID_PLAYER_DIST * AVOID_PLAYER_DIST
local AVOID_PLAYER_STOP = 5

local FOLLOW_DISTANCE_MIN = 0
local FOLLOW_DISTANCE_TARGET = 8
local FOLLOW_DISTANCE_MAX = 15

local SEE_BAIT_MAXDIST = 20
local MAX_WANDER_DIST = 8

local CarratBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GetLeader(inst)
    return inst.components.follower and inst.components.follower:GetLeader() or nil
end

local function GetLeaderLocation(inst)
    local leader = GetLeader(inst)
    if leader == nil then
        return nil
    end

    return leader:GetPosition()
end

local function ShouldRunFromScary(other, inst)
    local isplayer = other:HasTag("player")
    if isplayer and GetLeader(inst) == other then
        return false
    end

    local isplayerpet = isplayer and other.components.petleash and other.components.petleash:IsPet(inst)
    return (isplayer or isplayerpet) and TheNet:GetPVPEnabled()
end

local function IsItemEdible(inst, item)
    return inst.components.eater ~= nil and inst.components.eater:CanEat(item) and not item:HasTag("planted") and
            not (item.components.inventoryitem and item.components.inventoryitem:IsHeld()) and
            item:IsOnPassablePoint() and
            item:GetCurrentPlatform() == inst:GetCurrentPlatform()
end

local function PickUpFilter(inst, target, leader)
    return IsItemEdible(leader, target)
end

local NORMAL_RUNAWAY_DATA = {tags = {"scarytoprey"}, fn = ShouldRunFromScary}
function CarratBrain:OnStart()
    local leader = GetLeader(self.inst)
    local ignorethese = nil
    if leader ~= nil then
        ignorethese = leader._brain_pickup_ignorethese or {}
        leader._brain_pickup_ignorethese = ignorethese
    end
    local pickupparams = {
        range = SEE_BAIT_MAXDIST,
        custom_pickup_filter = PickUpFilter,
        ignorethese = ignorethese,
    }

    local root = PriorityNode(
    {
        BrainCommon.PanicTrigger(self.inst),
        RunAway(self.inst, NORMAL_RUNAWAY_DATA, AVOID_PLAYER_DIST, AVOID_PLAYER_STOP),
        WhileNode(function() return GetLeader(self.inst) ~= nil end, "Has Leader",
            BrainCommon.NodeAssistLeaderPickUps(self, pickupparams)
        ),
        Follow(self.inst, GetLeader, FOLLOW_DISTANCE_MIN, FOLLOW_DISTANCE_TARGET, FOLLOW_DISTANCE_MAX),
        Wander(self.inst, GetLeaderLocation, MAX_WANDER_DIST),
    }, .25)
    self.bt = BT(self.inst, root)
end

return CarratBrain
