require("behaviours/standandattack")

local WinonaCatapultBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function WinonaCatapultBrain:OnStart()
    local root = PriorityNode(
    {
        StandAndAttack(self.inst),
    }, .5)

    self.bt = BT(self.inst, root)
end

return WinonaCatapultBrain
