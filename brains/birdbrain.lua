local SEE_THREAT_DIST = 5

local BirdBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function ShouldFlyAway(inst)
    return not (inst.sg:HasStateTag("sleeping") or
                inst.sg:HasStateTag("busy") or
                inst.sg:HasStateTag("flight"))
        and (TheWorld.state.isnight or
            (inst.components.health ~= nil and inst.components.health.takingfiredamage and not (inst.components.burnable and inst.components.burnable:IsBurning())) or
            FindEntity(inst, SEE_THREAT_DIST, nil, nil, { "notarget", "INLIMBO" }, { "player", "monster", "scarytoprey" }) ~= nil)
end

local function FlyAway(inst)
    inst:PushEvent("flyaway")
end

function BirdBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode( function() return self.inst.components.hauntable ~= nil and self.inst.components.hauntable.panic end, "PanicHaunted", Panic(self.inst)),
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
