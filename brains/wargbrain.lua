require "behaviours/panic"
require "behaviours/standstill"
require "behaviours/chaseandattack"
require "behaviours/leash"

local WargBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
    --self.reanimatetime = nil
    --self.petrifytime = nil
end)

local function CanSpawnChild(inst)
    return inst:GetTimeAlive() > 5
        and inst:NumHoundsToSpawn() > 0
        and inst.components.combat:HasTarget()
end

local function TryReanimate(self)
    local player, dsq = self.inst:GetNearestPlayer(true)
    if player == nil or dsq >= 25 then
        self.reanimatetime = nil
    elseif self.reanimatetime == nil then
        self.reanimatetime = GetTime() + 3
    elseif self.reanimatetime == true then
        self.inst:PushEvent("reanimate", { target = player })
    elseif self.reanimatetime < GetTime() then
        self.reanimatetime = true
    end
end

function WargBrain:OnStart()
    local isclay = self.inst:HasTag("clay")
    local root = PriorityNode(
    {
        WhileNode(function() return self.inst.sg:HasStateTag("intro_state") end, "intro",
            StandStill(self.inst)),

        WhileNode(function() return isclay and self.inst.sg:HasStateTag("statue") end, "Statue",
            ActionNode(function() TryReanimate(self) end, "TryReanimate")),

        WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
        MinPeriod(self.inst, TUNING.WARG_SUMMONPERIOD, true,
            IfNode(function() return CanSpawnChild(self.inst) end, "needs follower",
                ActionNode(function()
                    if not IsEntityDead(self.inst) then
                        self.inst.sg:GoToState("howl",{howl = true})
                        return SUCCESS
                    end
                    return FAILED
                end, "Summon Hound"))),
        ChaseAndAttack(self.inst),

        IfNode(function() return isclay end, "IsClay",
            ParallelNode{
                LoopNode{
                    WaitNode(3),
                    ActionNode(function() self.inst:PushEvent("becomestatue") end),
                },
                StandStill(self.inst),
            }),

        StandStill(self.inst),
    }, .25)

    self.bt = BT(self.inst, root)
end

return WargBrain
