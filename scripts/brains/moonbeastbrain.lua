require "behaviours/chaseandattack"
require "behaviours/attackwall"
require "behaviours/leash"
require "behaviours/standstill"
local BrainCommon = require("brains/braincommon")

local WORK_DIST = 3 --must be greater than physics radii
local LOST_DIST = 60
local RETURN_DIST = 15
local BASE_DIST = 6

local LOST_TIME = 5
local AGGRO_TIME = 6
local PETRIFY_TIME = 3
local PETRIFY_TIME_VAR = 1

local MoonBeastBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
    self._losttime = nil
    self._petrifytime = nil
end)

function MoonBeastBrain:ForcePetrify()
    self._petrifytime = GetTime() + math.random()
end

local function GetMoonBase(inst)
    return inst.components.entitytracker:GetEntity("moonbase")
end

local function LostMoonBase(self)
    local moonbase = GetMoonBase(self.inst)
    if moonbase ~= nil and self.inst:IsNear(moonbase, LOST_DIST) then
        self._losttime = nil
        return false
    elseif self._losttime == nil then
        self._losttime = GetTime()
        return false
    end
    return GetTime() - self._losttime > LOST_TIME
end

local function LostMoonCharge(self)
    local moonbase = GetMoonBase(self.inst)
    if moonbase == nil or
        (   moonbase.components.timer ~= nil and
            moonbase.components.timer:TimerExists("mooncharge") ) then
        self._petrifytime = nil
        return false
    elseif self._petrifytime == nil then
        self._petrifytime = GetTime() + GetRandomWithVariance(PETRIFY_TIME, PETRIFY_TIME_VAR)
        return false
    end
    return GetTime() > self._petrifytime
end

local function ShouldTargetMoonBase(inst)
    local moonbase = GetMoonBase(inst)
    return moonbase ~= nil
        and moonbase.components.workable ~= nil
        and moonbase.components.workable:CanBeWorked()
        and moonbase.components.timer ~= nil
        and moonbase.components.timer:TimerExists("mooncharge")
        and GetTime() - inst.components.combat:GetLastAttackedTime() > AGGRO_TIME
end

local function GetMoonBasePos(inst)
    local moonbase = GetMoonBase(inst)
    return moonbase ~= nil and moonbase:GetPosition() or nil
end

local function WorkMoonBase(inst)
    inst:PushEvent("workmoonbase", { moonbase = GetMoonBase(inst) })
end

local BREAKSKELETONS_MUST_TAGS = { "playerskeleton", "HAMMER_workable" }
local function BreakSkeletons(inst)
    local skel = FindEntity(inst, 1.25, nil, BREAKSKELETONS_MUST_TAGS)
    if skel ~= nil then
        skel.components.workable:WorkedBy(inst, 1)
    end
end

function MoonBeastBrain:OnStart()
    local root = PriorityNode(
    {
		BrainCommon.PanicTrigger(self.inst),
        BrainCommon.IpecacsyrupPanicTrigger(self.inst),

        --Teleported away, or moonbase got removed
        WhileNode(function() return LostMoonBase(self) end, "Lost Moonbase",
            ActionNode(function() self.inst.components.health:Kill() end)),

        --Mooncharge ended
        WhileNode(function() return LostMoonCharge(self) end, "Petrify",
            ActionNode(function() self.inst:PushEvent("moonpetrify") end)),

        SequenceNode{
            ActionNode(function() BreakSkeletons(self.inst) end),
            AttackWall(self.inst),
            ActionNode(function() self.inst.components.combat:ResetCooldown() end),
        },

        WhileNode(function() return ShouldTargetMoonBase(self.inst) end, "MoonCharge",
            PriorityNode({
                Leash(self.inst, function() return GetMoonBase(self.inst):GetPosition() end, WORK_DIST, WORK_DIST),
                ActionNode(function() WorkMoonBase(self.inst) end),
                StandStill(self.inst),
            })),

        ChaseAndAttack(self.inst, 100),
        Leash(self.inst, GetMoonBasePos, RETURN_DIST, BASE_DIST),
        Panic(self.inst),
    }, .25)

    self.bt = BT(self.inst, root)
end

return MoonBeastBrain
