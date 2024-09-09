require "behaviours/panic"
require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/leash"
require "behaviours/wander"
local BrainCommon = require("brains/braincommon")

local BeeGuardBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
    self._shouldchase = false
end)

local function GetQueen(inst)
    return inst:GetQueen() -- Beeguard's function.
end

local function GetQueenPos(inst)
    local queen = GetQueen(inst)
    return queen ~= nil and queen:GetPosition() or nil
end

local function GetQueenOffset(inst)
    return inst.components.knownlocations:GetLocation("queenoffset")
end

local function GetGuardPos(inst)
    local pos = GetQueenPos(inst)
    if pos ~= nil then
        local offset = GetQueenOffset(inst)
        return offset ~= nil and pos + offset or pos
    end
end

local function ShouldPanic(self)
    if BrainCommon.ShouldTriggerPanic(self.inst) then
        self._shouldchase = false
        return true
    end
    return false
end

local function ShouldChase(self)
    local queen = GetQueen(self.inst)
    if queen == nil or
        GetQueenOffset(self.inst) == nil or
        self.inst._focustarget ~= nil or
        (   self.inst.components.combat.target ~= nil and
            self.inst.components.combat.target:IsValid() and
            self.inst.components.combat.target:IsNear(queen, TUNING.BEEGUARD_AGGRO_DIST + (self._shouldchase and 3 or 0))
        ) then
        self._shouldchase = true
        return true
    end
    self._shouldchase = false
    self.inst.components.combat:SetTarget(nil)
    return false
end

local function ShouldDodge(inst)
    return inst.components.combat:HasTarget()
        and inst.components.combat:InCooldown()
end

local function ShouldHoldFormation(inst)
    return GetQueenOffset(inst) ~= nil and GetQueen(inst) ~= nil
end

local RUN_AWAY_PARAMS =
{
    tags = { "_combat", "_health" },
    notags = { "bee", "playerghost", "INLIMBO" },
    fn = function(guy)
        return not guy.components.health:IsDead()
            and (   guy:HasTag("player") or
                    (   guy.components.combat.target ~= nil and
                        guy.components.combat.target:HasTag("bee")  ))
    end,
}

local RUN_AWAY_DIST = 3
local STOP_RUN_AWAY_DIST = 6

function BeeGuardBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return ShouldPanic(self) end, "Panic",
            Panic(self.inst)),
        WhileNode(function() return ShouldChase(self) end, "BreakFormation",
            PriorityNode({
                WhileNode(function() return ShouldDodge(self.inst) end, "Dodge",
                    RunAway(self.inst, RUN_AWAY_PARAMS, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)),
                ChaseAndAttack(self.inst),
            }, .5)),
        WhileNode(function() return ShouldHoldFormation(self.inst) end, "HoldFormation",
            PriorityNode({
                Leash(self.inst, GetGuardPos, .5, .5),
                ActionNode(function()
                    self.inst:FaceAwayFromPoint(GetQueenPos(self.inst))
                end, "BackToBack"),
            }, .5)),
        Wander(self.inst, GetGuardPos, 8),
    }, .5)

    self.bt = BT(self.inst, root)
end

return BeeGuardBrain
