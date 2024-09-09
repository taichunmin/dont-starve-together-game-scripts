require "behaviours/leash"
require "behaviours/standstill"
require "behaviours/wander"
local BrainCommon = require("brains/braincommon")

local STALKER_RADIUS = .75
local MINION_RADIUS = .3
local LEASH_DIST = STALKER_RADIUS + MINION_RADIUS

local StalkerMinionBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GetTarget(inst)
    return inst.components.entitytracker:GetEntity("stalker")
end

local function GetTargetPos(inst)
    local target = GetTarget(inst)
    return target ~= nil and target:GetPosition() or nil
end

local function ShouldDie(self)
    local t = GetTime()
    if self.delay == nil then
        local dt = self.inst.stalkerdead and 1 or 3
        self.delay = t + dt + math.random() * dt
        return false
    end
    return t > self.delay
end

function StalkerMinionBrain:OnStart()
    local root = PriorityNode({
		BrainCommon.PanicTrigger(self.inst),
        Leash(self.inst, GetTargetPos, LEASH_DIST, LEASH_DIST),
        WhileNode(function() return GetTarget(self.inst) ~= nil end, "ReachedStalker",
            StandStill(self.inst)),
        WhileNode(function() return not ShouldDie(self) end, "DelayDeath",
            Wander(self.inst)),
        ActionNode(function()
            if not self.inst.components.health:IsDead() then
                self.inst.components.health:Kill()
            end
        end),
    }, 1)

    self.bt = BT(self.inst, root)
end

return StalkerMinionBrain
