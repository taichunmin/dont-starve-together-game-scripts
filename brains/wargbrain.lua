require "behaviours/panic"
require "behaviours/standstill"
require "behaviours/chaseandattack"
require "behaviours/leash"

local WargBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function WargBrain:CanSpawnChild(inst)   
    local num = inst.NumHoundsToSpawn(inst)

    return self.inst:GetTimeAlive() > 5 and 
        num > 0 and
        self.inst.components.combat.target
end

function WargBrain:OnStart()
    local root = 
    PriorityNode(
    {
        WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
        MinPeriod(self.inst, TUNING.WARG_SUMMONPERIOD, true,
                    IfNode(function() return self:CanSpawnChild(self.inst) end, "needs follower", 
                        ActionNode(function() self.inst.sg:GoToState("howl") return SUCCESS end, "Summon Hound" ))),
        ChaseAndAttack(self.inst),
        StandStill(self.inst),
    }, .25)
    self.bt = BT(self.inst, root)
end

return WargBrain
