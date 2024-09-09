require "behaviours/wander"
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
local BIG_LEADER_DIST_SQ = 8 * 8

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

local SHADOWCREATURE_MUST_TAGS = { "shadowcreature", "_combat", "locomotor" }
local SHADOWCREATURE_CANT_TAGS = { "INLIMBO", "notaunt" }
local function FindShadowCreatures(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TAUNT_DIST, SHADOWCREATURE_MUST_TAGS, SHADOWCREATURE_CANT_TAGS)
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
    local my_platform = self.inst:GetCurrentPlatform()
    for i, v in ipairs(AllPlayers) do
        if (self.inst.isleadercrazy(self.inst,v) or self.inst:hotheaded(v)) and v.entity:IsVisible() and my_platform == v:GetCurrentPlatform() then
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
            self.inst.isleadercrazy(self.inst,self._leader) and
            self.inst:hotheaded(self._leader)  ) then --self._leader.components.sanity:IsCrazy())
        self._leader = nil
    end
    return self._leader
end

local function countbigbernies(leader)
    local count = 0

    if leader.bigbernies then
        for bernie,i in pairs(leader.bigbernies)do
            count = count + 1
        end
    end

    return count
end

local function ShouldGoBig(self)
    local x, y, z = self.inst.Transform:GetWorldPosition()

    self._leader = nil

    for i, v in ipairs(AllPlayers) do
        if v:HasTag("bernieowner") and
            v.bigbernies == nil and
            v.blockbigbernies == nil and            
            (self.inst.isleadercrazy(self.inst,v) or self.inst:hotheaded(v)) and
            v.entity:IsVisible() and
            v:GetDistanceSqToPoint(x, y, z) < BIG_LEADER_DIST_SQ then
            self._leader = v
            return true
        end
    end
    return false
end

local function OnEndBlockBigBernies(leader)
    leader.blockbigbernies = nil
end

local function DoGoBig(inst,leader)
    if leader and not leader.bigbernies then
        if  leader ~= nil then
            if  leader.blockbigbernies ~= nil then
                 leader.blockbigbernies:Cancel()
            end
            --V2C: block other big bernies from triggering, since brain needs time to detect initial leader
             leader.blockbigbernies =  leader:DoTaskInTime(.5, OnEndBlockBigBernies)
        end
        inst:GoBig( leader )        
    else 
        leader = nil
    end
end

function BernieBrain:OnStart()
    local root =
    PriorityNode({
        IfNode(
            function()
                return not self.inst.sg:HasStateTag("busy")
                    and not self.inst.components.timer:TimerExists("transform_cd")
                    and ShouldGoBig(self)
            end,
            "Go Big",
            ActionNode(function() DoGoBig(self.inst, self._leader) end)),

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
