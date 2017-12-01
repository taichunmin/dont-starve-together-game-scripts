require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/follow"

local BernieBrain = Class(Brain, function(self, inst)
    Brain._ctor(self,inst)
    self._targets = nil
    self._leader = nil
end)

local MIN_FOLLOW_DIST = 0
local MAX_FOLLOW_DIST = 12
local TARGET_FOLLOW_DIST = 6
local TAUNT_DIST = 16
local LOSE_LEADER_DIST_SQ = 30 * 30

local wander_times =
{
    minwalktime = 1,
    minwaittime = 1,
}

local function IsTauntable(inst, target)
    return target.components.combat ~= nil
        and not target.components.combat:TargetIs(inst)
        and target.components.combat:CanTarget(inst)
end

local function FindShadowCreatures(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TAUNT_DIST, { "shadowcreature", "_combat", "locomotor" })
    for i = #ents, 1, -1 do
        if not IsTauntable(inst, ents[i]) then
            table.remove(ents, i)
        end
    end
    return #ents > 0 and ents or nil
end

local function TauntCreatures(self)
    local taunted = false
    if self._targets ~= nil then
        for i, v in ipairs(self._targets) do
            if IsTauntable(self.inst, v) then
                v.components.combat:SetTarget(self.inst)
                taunted = true
            end
        end
    end
    if taunted then
        self.inst.sg:GoToState("taunt")
    end
end

local function FindLeader(self)
    self._leader = nil
    local rangesq = LOSE_LEADER_DIST_SQ
    local x, y, z = self.inst.Transform:GetWorldPosition()
    for i, v in ipairs(AllPlayers) do
        if v.components.sanity:IsCrazy() and v.entity:IsVisible() then
            local distsq = v:GetDistanceSqToPoint(x, y, z)
            if distsq < rangesq then
                rangesq = distsq
                self._leader = v
            end
        end
    end
    return self._leader
end

local function GetLeader(self)
    if self._leader ~= nil and
        not (self._leader:IsValid() and
            self._leader.entity:IsVisible() and
            self._leader.components.sanity:IsCrazy()) then
        self._leader = nil
    end
    return self._leader
end

function BernieBrain:OnStart()
    local root =
    PriorityNode({
        --Get the attention of nearby sanity monsters.
        WhileNode(
            function()
                self._targets =
                    not (self.inst.sg:HasStateTag("busy") or self.inst.components.timer:TimerExists("taunt_cd"))
                    and FindShadowCreatures(self.inst)
                    or nil
                return self._targets ~= nil
            end,
            "Can Taunt",
            ActionNode(function() TauntCreatures(self) end)),

        IfNode(
            function()
                return not self.inst.sg:HasStateTag("busy")
                    and FindLeader(self) == nil
            end,
            "No Leader",
            ActionNode(function() self.inst.sg:GoToState("deactivate") end)),

        Follow(self.inst, function() return GetLeader(self) end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
        Wander(self.inst, nil, nil, wander_times),
    }, 1)
    self.bt = BT(self.inst, root)
end

return BernieBrain
