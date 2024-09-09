require "behaviours/chaseandattack"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/attackwall"
local BrainCommon = require("brains/braincommon")

local LavaeBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

--Spawned with a purpose.
--If no combat target, go to nearest lava pool and despawn
local function ShouldResetFight(inst)
    return inst.reset
end

local LAVA_TAGS = {"lava"}
local function FindHome(inst)
    local pos = inst:GetPosition()
    local lavae_ponds = TheSim:FindEntities(pos.x, pos.y, pos.z, 50, LAVA_TAGS)
    return GetRandomItem(lavae_ponds or {})
end

local function GoHome(inst)
    local target = FindHome(inst)

    if not target then
        target = inst
    end

    return BufferedAction(inst, target, ACTIONS.GOHOME)
end

function LavaeBrain:OnStart()
    local root =
        PriorityNode(
        {
            WhileNode(function() return ShouldResetFight(self.inst) end, "Reset Fight", DoAction(self.inst, GoHome, "Go Home", nil, 10)),
			BrainCommon.PanicTrigger(self.inst),
            AttackWall(self.inst),
            ChaseAndAttack(self.inst),
            StandStill(self.inst),
        }, 1)

    self.bt = BT(self.inst, root)
end

return LavaeBrain