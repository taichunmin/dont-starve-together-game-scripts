require "behaviours/chaseandattack"
require "behaviours/panic"
require "behaviours/attackwall"
require "behaviours/leash"
require "behaviours/standstill"

local RETURN_DIST = 15
local BASE_DIST = 6

local BirdMutantBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
    self._losttime = nil
    self._petrifytime = nil
end)

local function GetSwarmTarget(inst)
    return inst.components.entitytracker:GetEntity("swarmTarget")
end

local function GetSwarmTargetPos(inst)
    local target = GetSwarmTarget(inst)
    return target ~= nil and target:GetPosition() or nil
end

local function CanBirdAttack(inst)
    if inst.components.combat:InCooldown() or inst.sg:HasStateTag("busy") then
        return nil
    end
    local target = GetSwarmTarget(inst)
    if target then
        local dist = inst:GetDistanceSqToInst(target)
        if dist <= inst.components.combat.attackrange *inst.components.combat.attackrange then
            return target
        end
    end
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, inst.components.combat.attackrange)
    local potentials = {}
    for i, ent in ipairs(ents) do
        if ent:HasTag("player") or (ent.components.follower and ent.components.follower:GetLeader() and ent.components.follower:GetLeader():HasTag("player")) then
            table.insert(potentials,ent)
        end
    end
    if #potentials > 0 then
        return potentials[math.random(1,#potentials)]
    end
end

local function AttackTarget(inst)
    local target = CanBirdAttack(inst)
    if target then
		inst.components.combat:TryAttack(target)
    end
end

local BREAKSKELETONS_MUST_TAGS = { "playerskeleton", "HAMMER_workable" }
local function BreakSkeletons(inst)
    local skel = FindEntity(inst, 1.25, nil, BREAKSKELETONS_MUST_TAGS)
    if skel ~= nil then
        skel.components.workable:WorkedBy(inst, 1)
    end
end

local function shouldspit(inst)
    if inst.components.timer:TimerExists("spit_cooldown") then
        return false
    end
    return inst.components.combat.target and
        inst.components.combat.target:IsValid() and
        inst:GetDistanceSqToInst(inst.components.combat.target) <= TUNING.MUTANT_BIRD_SPIT_RANGE * TUNING.MUTANT_BIRD_SPIT_RANGE
end

local function spit(inst)
	local act = BufferedAction(inst, inst.components.combat.target, ACTIONS.TOSS)
    return act
end

local function shouldwaittospit(inst)
    return inst.components.combat.target and inst.components.combat.target:IsValid() and inst:GetDistanceSqToInst(inst.components.combat.target) <= 4*4
end

function BirdMutantBrain:OnStart()
    local brain =
    {

        WhileNode(function() return self.inst.components.hauntable ~= nil and self.inst.components.hauntable.panic end, "PanicHaunted", Panic(self.inst)),
        WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),

        --Mutant Spitter:
            --Spit
            --waittospit

        SequenceNode{
            ActionNode(function() BreakSkeletons(self.inst) end),
            AttackWall(self.inst),
            ActionNode(function() self.inst.components.combat:ResetCooldown() end),
        },

        IfNode(function() return CanBirdAttack(self.inst) end, "Attack",
            ActionNode(function() AttackTarget(self.inst) end)),

        IfNode(function() return GetSwarmTargetPos(self.inst) end, "move to target",
            Leash(self.inst, GetSwarmTargetPos, RETURN_DIST, BASE_DIST)),

        IfNode(function() return GetSwarmTargetPos(self.inst) end, "stand near target",
            StandStill(self.inst)),

        Panic(self.inst),
    }

    if self.inst:HasTag("bird_mutant_spitter") then
        table.insert(brain, 3, WhileNode(function() return shouldspit(self.inst) end, "Spit",
            DoAction(self.inst, spit)))

        table.insert(brain, 4, IfNode(function() return shouldwaittospit(self.inst) end, "waittospit",
            StandStill(self.inst)))
    end

    local root = PriorityNode(brain, .25)
    self.bt = BT(self.inst, root)
end

return BirdMutantBrain
