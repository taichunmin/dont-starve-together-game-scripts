require "behaviours/wander"
require "behaviours/follow"

local MAX_WANDER_DIST = 20

local MIN_FOLLOW_DIST = 2
local MAX_FOLLOW_DIST = 10
local TARGET_FOLLOW_DIST = 5

local SporeBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local TOFOLLOW_ONEOF_TAGS = {"player", "character", "monster"}
local function FindObjectToFollow(inst)
	--(inst, radius, fn, musttags, canttags, mustoneoftags)
	if not inst.followobj or not inst.followobj:IsValid() or inst.followobj:GetPosition():Dist(inst:GetPosition()) > MAX_FOLLOW_DIST + 10 then
        inst.followobj = FindEntity(inst, MAX_FOLLOW_DIST, nil, nil, nil, TOFOLLOW_ONEOF_TAGS)
	end

	return inst.followobj
end

function SporeBrain:OnStart()

	local root =
	PriorityNode(
	{
		--latch onto nearby creatures and follow them loosely
        Follow(self.inst, FindObjectToFollow, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
		Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_WANDER_DIST,
            {minwalktime=50,  randwalktime=3, minwaittime=1.5, randwaittime=0.5})
	}, 1)

	self.bt = BT(self.inst, root)
end

return SporeBrain
