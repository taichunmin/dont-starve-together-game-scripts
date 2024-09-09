require "behaviours/chaseandattack"
require "behaviours/leash"
require "behaviours/wander"

local MAX_CHANNEL_LEASH_TIME = 15
local FLEE_WARNING_DELAY = 3.5 --enuf time for combat retarget
local FLEE_DELAY = 10

local ToadstoolBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
    self.timetochanneling = nil
end)

local function GetHomePos(inst)
    return inst.components.knownlocations:GetLocation("spawnpoint")
end

local function ShouldChannel(self)
    if self.inst.components.timer:TimerExists("channel")
        or (self.inst.engaged and
            self.inst.level < 3 and
            not self.inst.components.timer:TimerExists("mushroomsprout_cd")) then
        return true
    end
    self.timetochanneling = nil
    return false
end

local function ShouldTryReturningToHole(self)
    if self.timetochanneling == nil then
        self.timetochanneling = GetTime() + MAX_CHANNEL_LEASH_TIME
        return true
    end
    return self.timetochanneling > 0 and GetTime() < self.timetochanneling
end

function ToadstoolBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return ShouldChannel(self) end, "Channel",
            PriorityNode{
                WhileNode(function() return ShouldTryReturningToHole(self) end, "ReturnToHole",
                    Leash(self.inst, GetHomePos, 8, 6)),
                ActionNode(function()
                    self.timetochanneling = 0
                    self.inst:PushEvent("startchanneling")
                end),
            }, 1),
        Leash(self.inst, GetHomePos, 30, 25),
        ChaseAndAttack(self.inst),
        ParallelNode{
            SequenceNode{
                WaitNode(FLEE_WARNING_DELAY),
                ActionNode(function() self.inst:PushEvent("fleewarning") end),
                WaitNode(FLEE_DELAY),
                ActionNode(function() self.inst:PushEvent("flee") end),
            },
            Wander(self.inst, GetHomePos, 5),
        },
    }, 1)

    self.bt = BT(self.inst, root)
end

function ToadstoolBrain:OnInitializationComplete()
    local pos = self.inst:GetPosition()
    pos.y = 0
    self.inst.components.knownlocations:RememberLocation("spawnpoint", pos, true)
end

return ToadstoolBrain
