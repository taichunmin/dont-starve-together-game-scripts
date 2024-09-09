local BirdBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local SHOULDFLYAWAY_MUST_TAGS = { "notarget", "INLIMBO" }
local SHOULDFLYAWAY_CANT_TAGS = { "player", "monster", "scarytoprey" }

local function ShouldFlyAway(inst)
    return not (inst.sg:HasStateTag("sleeping") or
                inst.sg:HasStateTag("busy") or
                inst.sg:HasStateTag("flight"))
        and (TheWorld.state.isnight or
            (inst.components.health ~= nil and inst.components.health.takingfiredamage and not (inst.components.burnable and inst.components.burnable:IsBurning())) or
            FindEntity(inst, inst.flyawaydistance, nil, nil, SHOULDFLYAWAY_MUST_TAGS, SHOULDFLYAWAY_CANT_TAGS) ~= nil)
end

local function FlyAway(inst)
    inst:PushEvent("flyaway")
end

function BirdBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode( function() return self.inst.components.hauntable ~= nil and self.inst.components.hauntable.panic end, "PanicHaunted",
			ActionNode(function() return FlyAway(self.inst) end)),
        IfNode(function() return ShouldFlyAway(self.inst) end, "Threat Near",
            ActionNode(function() return FlyAway(self.inst) end)),
        EventNode(self.inst, "threatnear",
            ActionNode(function() return FlyAway(self.inst) end)),
        EventNode(self.inst, "gohome",
            ActionNode(function() return FlyAway(self.inst) end)),
    }, .25)

    self.bt = BT(self.inst, root)
end

return BirdBrain
