require "behaviours/wander"
require "behaviours/chaseandattack"
require "behaviours/follow"

local MIN_FOLLOW = 5
local MED_FOLLOW = 15
local MAX_FOLLOW = 30

local HARASS_MIN = 0
local HARASS_MED = 4
local HARASS_MAX = 5

local function ShouldAttack(self)
    if self.inst.components.shadowsubmissive:ShouldSubmitToTarget(self.inst.components.combat.target) then
        self._harasstarget = self.inst.components.combat.target
        return false
    end
    self._harasstarget = nil
    return true
end

local function ShouldHarass(self)
    return self._harasstarget ~= nil
        and (self.inst.components.combat.nextbattlecrytime == nil or
            self.inst.components.combat.nextbattlecrytime < GetTime())
end

local function ShouldChaseAndHarass(self)
    return self.inst.components.locomotor.walkspeed < 5
        or (self._harasstarget ~= nil and self._harasstarget:IsValid() and not self.inst:IsNear(self._harasstarget, HARASS_MED))
end

local function GetHarassWanderDir(self)
    return (self._harasstarget:GetAngleToPoint(self.inst.Transform:GetWorldPosition()) - 60 + math.random() * 120) * DEGREES
end

local NightmareCreatureBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function NightmareCreatureBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return ShouldAttack(self) end, "Attack", ChaseAndAttack(self.inst, 40)),
        WhileNode(function() return ShouldHarass(self) end, "Harass",
            PriorityNode({
                WhileNode(function() return ShouldChaseAndHarass(self) end, "ChaseAndHarass",
                    Follow(self.inst, function() return self._harasstarget end, HARASS_MIN, HARASS_MED, HARASS_MAX)),
                ActionNode(function()
                    self.inst.components.combat:BattleCry()
                    if self.inst.sg.currentstate.name == "taunt" then
                        self.inst:ForceFacePoint(self._harasstarget.Transform:GetWorldPosition())
                    end
                end),
            }, .25)),
        WhileNode(function() return self._harasstarget ~= nil end, "LoiterAndHarass",
            Wander(self.inst, function() return self._harasstarget:GetPosition() end, 20, { minwaittime = 0, randwaittime = .3 }, function() return GetHarassWanderDir(self) end)),
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("war_home") or self.inst.components.knownlocations:GetLocation("home") end, 20),
    }, .25)

    self.bt = BT(self.inst, root)
end

return NightmareCreatureBrain
