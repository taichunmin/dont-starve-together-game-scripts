require "behaviours/standandattack"

local CALM_DELAY = 10

local AntlionBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function ShouldEatRocksLowPrio(inst)
    return inst.components.health:IsHurt()
end

local function ShouldEatRocksHighPrio(inst)
    return inst.components.health:IsHurt()
        and (   inst.components.worldsettingstimer:ActiveTimerExists("wall_cd") and
                inst.components.combat:GetLastAttackedTime() + 6 < GetTime()
            )
end

function AntlionBrain:OnStart()
    local root = PriorityNode({
        WhileNode(function() return ShouldEatRocksHighPrio(self.inst) end, "EatRocks",
            ActionNode(function() self.inst:PushEvent("eatrocks") end)),
        StandAndAttack(self.inst),
        WhileNode(function() return ShouldEatRocksLowPrio(self.inst) end, "EatRocks",
            ActionNode(function() self.inst:PushEvent("eatrocks") end)),
        SequenceNode{
            ActionNode(function() self.inst.components.combat:SetAttackPeriod(TUNING.ANTLION_MAX_ATTACK_PERIOD) end),
            WaitNode(CALM_DELAY),
            ActionNode(function() self.inst:PushEvent("antlionstopfighting") end),
        },
    }, .5)

    self.bt = BT(self.inst, root)
end

return AntlionBrain
