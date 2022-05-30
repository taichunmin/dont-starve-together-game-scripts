require "behaviours/wander"
require "behaviours/chaseandattack"
require "behaviours/follow"
require "behaviours/doaction"
require "behaviours/minperiod"
require "behaviours/panic"


local SpiderQueenBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function SpiderQueenBrain:CanSpawnChild()
	return self.inst:GetTimeAlive() > 5
		and not self.inst.sg:HasStateTag("busy")
		and self.inst.components.incrementalproducer and self.inst.components.incrementalproducer:CanProduce()
end

local BLOCKER_TAGS = {'blocker'}
local SPIDERDEN_TAGS = {"spiderden"}
local SPIDERQUEEN_TAGS = {"spiderqueen"}
function SpiderQueenBrain:CanPlantNest()
	if self.inst:GetTimeAlive() > TUNING.SPIDERQUEEN_MINWANDERTIME then
		local pt = Vector3(self.inst.Transform:GetWorldPosition())
	    local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 4, BLOCKER_TAGS)
		local min_spacing = 3

	    for k, v in pairs(ents) do
			if v ~= self.inst and v.entity:IsValid() and v.entity:IsVisible() then
				if distsq( Vector3(v.Transform:GetWorldPosition()), pt) < min_spacing*min_spacing then
					return false
				end
			end
		end

		local den = GetClosestInstWithTag(SPIDERDEN_TAGS, self.inst, TUNING.SPIDERQUEEN_MINDENSPACING)
		local queen = GetClosestInstWithTag(SPIDERQUEEN_TAGS, self.inst, TUNING.SPIDERQUEEN_MINDENSPACING)
		if den or queen then
			return false
		end

		return true
	end

    return false
end

local MIN_FOLLOW = 10
local MAX_FOLLOW = 20
local MED_FOLLOW = 15

function SpiderQueenBrain:OnStart()
    local root = PriorityNode(
    {
    	WhileNode( function() return self.inst.components.hauntable and self.inst.components.hauntable.panic end, "PanicHaunted", Panic(self.inst)),
        WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),

        IfNode(function() return self:CanPlantNest() end, "can plant nest",
			ActionNode(function() self.inst.sg:GoToState("makenest") end)),

		IfNode(function() return self:CanSpawnChild() end, "needs follower",
			ActionNode(function() self.inst.sg:GoToState("poop_pre") return SUCCESS end, "make child" )),

        --SPIDERQUEEN_MINDENSPACING

        ChaseAndAttack(self.inst, 60, 40, nil, nil, nil, TUNING.WINONA_CATAPULT_MAX_RANGE + TUNING.MAX_WALKABLE_PLATFORM_RADIUS + TUNING.WINONA_CATAPULT_KEEP_TARGET_BUFFER + 1),
        Wander(self.inst),
    }, 2)

    self.bt = BT(self.inst, root)

end

return SpiderQueenBrain