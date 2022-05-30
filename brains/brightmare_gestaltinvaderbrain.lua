require "behaviours/chaseandattack"
require "behaviours/panic"
require "behaviours/attackwall"
require "behaviours/leash"
require "behaviours/standstill"

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

local function GetInvadeTarget(inst)
    return inst.components.entitytracker:GetEntity("invadeTarget")
end

local function LostInvadeTarget(self)
    local target = GetInvadeTarget(self.inst)
    if target ~= nil and self.inst:IsNear(target, LOST_DIST) then
        self._losttime = nil
        return false
    elseif self._losttime == nil then
        self._losttime = GetTime()
        return false
    end
    return GetTime() - self._losttime > LOST_TIME
end

local function LostMoonCharge(self)
    local target = GetInvadeTarget(self.inst)
    if target == nil or
        (   target.components.timer ~= nil and
            target.components.timer:TimerExists("InvadeTarget") ) then
        self._petrifytime = nil
        return false
    elseif self._petrifytime == nil then
        self._petrifytime = GetTime() + GetRandomWithVariance(PETRIFY_TIME, PETRIFY_TIME_VAR)
        return false
    end
    return GetTime() > self._petrifytime
end

local function ShouldTargetInvadeTarget(inst)
    local target = GetInvadeTarget(inst)
    return target ~= nil
        and target:HasTag("wagstaff_npc")
        --and target.components.timer ~= nil
        --and target.components.timer:TimerExists("InvadeTarget")
        and GetTime() - inst.components.combat:GetLastAttackedTime() > AGGRO_TIME
end

local function GetInvadeTargetPos(inst)
    local target = GetInvadeTarget(inst)
    return target ~= nil and target:GetPosition() or nil
end

local function AttackInvadeTarget(inst)
    --inst:PushEvent("workmoonbase", { invadetarget = GetInvadeTarget(inst) })
end

local BREAKSKELETONS_MUST_TAGS = { "playerskeleton", "HAMMER_workable" }
local function BreakSkeletons(inst)
    local skel = FindEntity(inst, 1.25, nil, BREAKSKELETONS_MUST_TAGS)
    if skel ~= nil then
        skel.components.workable:WorkedBy(inst, 1)
    end
end

local function shouldspit(inst)
	if inst:HasTag("gestalt_invader_spitter") then
	    if inst.components.combat.target and not inst.components.timer:TimerExists("spit_cooldown") then
	    	return true
	    end
	end
end

local function spit(inst)
	local act = BufferedAction(inst, inst.components.combat.target, ACTIONS.TOSS)
    return act
end

local function shouldwaittospit(inst)
	if inst:HasTag("gestalt_invader_spitter") then
	    if inst.components.combat.target then
	    	if inst:GetDistanceSqToInst(inst.components.combat.target) <= 4*4 then
	    		return true
	    	end
	    end
	end
end

function MoonBeastBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return self.inst.components.hauntable ~= nil and self.inst.components.hauntable.panic end, "PanicHaunted", Panic(self.inst)),
        WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),

        --Teleported away, or moonbase got removed
        WhileNode(function() return LostInvadeTarget(self) end, "Lost Target",
            ActionNode(function() self.inst.components.health:Kill() end)),

        WhileNode(function() return shouldspit(self.inst) end, "Spit",
        	DoAction(self.inst, spit)),

        WhileNode(function() return shouldwaittospit(self.inst) end, "waittospit",
        	StandStill(self.inst)),

        SequenceNode{
            ActionNode(function() BreakSkeletons(self.inst) end),
            AttackWall(self.inst),
            ActionNode(function() self.inst.components.combat:ResetCooldown() end),
        },

        WhileNode(function() return ShouldTargetInvadeTarget(self.inst) end, "InvadeTarget",
            PriorityNode({
                Leash(self.inst, function() return GetInvadeTarget(self.inst):GetPosition() end, WORK_DIST, WORK_DIST),
                ActionNode(function() AttackInvadeTarget(self.inst) end),
                StandStill(self.inst),
            })),

        ChaseAndAttack(self.inst, 100),
        Leash(self.inst, GetInvadeTargetPos, RETURN_DIST, BASE_DIST),
        Panic(self.inst),
    }, .25)

    self.bt = BT(self.inst, root)
end

return MoonBeastBrain
