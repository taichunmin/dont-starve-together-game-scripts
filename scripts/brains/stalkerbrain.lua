require "behaviours/chaseandattack"
require "behaviours/chaseandattackandavoid"
require "behaviours/findclosest"
require "behaviours/leash"
require "behaviours/faceentity"
require "behaviours/wander"

local SKULLACHE_CD = 18
local FALLAPART_CD = 11
local SEE_LURE_DIST = 20
local SAFE_LURE_DIST = 5

local COMBAT_FEAST_DELAY = 3
local CHECK_MINIONS_PERIOD = 2

local RESET_COMBAT_DELAY = 10

local LOITER_GATE_DIST = 5.5
local LOITER_GATE_RANGE = 1.5

local IDLE_GATE_TIME = 10
local IDLE_GATE_MAX_DIST = 4
local IDLE_GATE_DIST = 3

local AVOID_GATE_DIST = 6 --stargate radius + stalker radius + some breathing room

local StalkerBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
    self.abilityname = nil
    self.abilitydata = nil
    self.snaretargets = nil
    self.hasfeast = nil
    self.hasminions = nil
    self.checkminionstime = nil
    self.wantstospikes = nil
end)

local function GetStargatePos(inst)
    local stargate = inst.components.entitytracker:GetEntity("stargate")
    return stargate ~= nil and stargate:GetPosition() or nil
end

local function GetStargate(inst)
    return inst.components.entitytracker:GetEntity("stargate")
end

local function IsDefensive(self)
    return self.inst.components.health.currenthealth < TUNING.STALKER_ATRIUM_PHASE2_HEALTH
end

local STALKERMINION_TAGS = { "stalkerminion" }
local function CheckMinions(self)
    local t = GetTime()
    if t > (self.checkminionstime or 0) then
        local x, y, z = (GetStargate(self.inst) or self.inst).Transform:GetWorldPosition()
        self.hasminions = #TheSim:FindEntities(x, y, z, 8, STALKERMINION_TAGS) > 0
        self.checkminionstime = t + CHECK_MINIONS_PERIOD
    end
end

local function ShouldSnare(self)
    if not self.inst.components.timer:TimerExists("snare_cd") then
        local targets = self.inst:FindSnareTargets()
        if targets ~= nil then
            self.abilitydata = { targets = targets }
            return true
        end
        self.inst.components.timer:StartTimer("snare_cd", TUNING.STALKER_ABILITY_RETRY_CD)
    end
    return false
end

local SPIKE_TARGET_MUST_TAGS = { "_combat", "_health" }
local SPIKE_TARGET_CANT_TAGS = { "fossil", "playerghost", "shadow", "INLIMBO" }
local function ShouldSpikes(self)
    if not (IsDefensive(self) or self.inst.components.timer:TimerExists("spikes_cd")) then
        if not self.hasminions then
            local stargate = GetStargate(self.inst)
            if stargate == nil or self.inst:IsNear(stargate, 8) then
                local x, y, z = (stargate or self.inst).Transform:GetWorldPosition()
                if #TheSim:FindEntities(x, y, z, 8, SPIKE_TARGET_MUST_TAGS, SPIKE_TARGET_CANT_TAGS) > 0 then
                    self.wantstospikes = true
                    return true
                end
            end
        end
        self.inst.components.timer:StartTimer("spikes_cd", TUNING.STALKER_ABILITY_RETRY_CD)
    end
    return false
end

local function ShouldSummonChannelers(self)
    return IsDefensive(self)
        and self.inst.components.commander:GetNumSoldiers() <= 0
        and not self.inst.components.timer:TimerExists("channelers_cd")
end

local function ShouldSummonMinions(self)
    return not self.hasminions
        and IsDefensive(self)
        and not self.inst.components.timer:TimerExists("minions_cd")
end

local function ShouldMindControl(self)
    if IsDefensive(self) and not self.inst.components.timer:TimerExists("mindcontrol_cd") then
        if self.inst:HasMindControlTarget() then
            return true
        end
        self.inst.components.timer:StartTimer("mindcontrol_cd", TUNING.STALKER_ABILITY_RETRY_CD)
    end
    return false
end

local function ShouldFeast(self)
    if self.hasfeast == nil then
        self.hasfeast = self.inst.components.health:IsHurt() and #self.inst:FindMinions(1) > 0
    end
    return self.hasfeast
end

local function ShouldCombatFeast(self)
    if not self.inst.components.combat:InCooldown() then
        local target = self.inst.components.combat.target
        if target ~= nil and target:IsNear(self.inst, TUNING.STALKER_ATTACK_RANGE + target:GetPhysicsRadius(0)) then
            return false
        end
    end
    if not self.inst.hasshield and self.inst.components.combat:GetLastAttackedTime() + COMBAT_FEAST_DELAY >= GetTime() then
        return false
    end
    return ShouldFeast(self)
end

local function ShouldUseAbility(self)
    local wantstospikes = self.wantstospikes
    self.wantstospikes = nil
    self.hasfeast = nil
    self.inst.returntogate = nil
    self.abilityname = self.inst.components.combat:HasTarget() and (
        (ShouldMindControl(self) and "mindcontrol") or
        (not wantstospikes and ShouldSnare(self) and "fossilsnare") or
        (ShouldSummonChannelers(self) and "shadowchannelers") or
        (ShouldCombatFeast(self) and "fossilfeast") or
        CheckMinions(self) or
        (ShouldSummonMinions(self) and "fossilminions") or
        (ShouldSpikes(self) and "fossilspikes")
    ) or nil
    return self.abilityname ~= nil
end

local function GetLoiterStargatePos(inst)
    local stargate = inst.components.entitytracker:GetEntity("stargate")
    if stargate ~= nil then
        local x, y, z = stargate.Transform:GetWorldPosition()
        local x1, y1, z1 = inst.Transform:GetWorldPosition()
        if x == x1 and z == z1 then
            return Vector3(x, 0, z)
        end
        local dx, dz = x1 - x, z1 - z
        local normalize = LOITER_GATE_DIST / math.sqrt(dx * dx + dz * dz)
        return Vector3(x + dx * normalize, 0, z + dz * normalize)
    end
end

local function GetIdleStargate(inst)
    local stargate = inst.components.entitytracker:GetEntity("stargate")
    if stargate ~= nil then
        inst.returntogate = true
        return stargate
    end
end

local function KeepIdleStargate(inst)
    inst.returntogate = true
    return true
end

local SHADOWLURE_TAGS = {"shadowlure"}
local function GetShadowLure(inst)
    return GetClosestInstWithTag(SHADOWLURE_TAGS, inst, SAFE_LURE_DIST)
end

local function KeepShadowLure(inst, target)
    return inst:IsNear(target, SAFE_LURE_DIST)
end

function StalkerBrain:OnStart()
    local root

    if self.inst.atriumstalker then
        root = PriorityNode({
            WhileNode(function() return not self.inst:IsNearAtrium() end, "LostAtrium",
                ActionNode(function() self.inst:OnLostAtrium() end)),
            WhileNode(function() return ShouldUseAbility(self) end, "Ability",
                ActionNode(function()
                    self.inst:PushEvent(self.abilityname, self.abilitydata)
                    self.abilityname = nil
                    self.abilitydata = nil
                end)),
            WhileNode(function() return ShouldFeast(self) end, "FossilFeast",
                ActionNode(function() self.inst:PushEvent("fossilfeast") end)),
            ChaseAndAttackAndAvoid(self.inst, GetStargate, AVOID_GATE_DIST),
            SequenceNode{
                ParallelNodeAny{
                    SequenceNode{
                        WaitNode(RESET_COMBAT_DELAY),
                        ActionNode(function() self.inst:SetEngaged(false) end),
                    },
                    Wander(self.inst, GetLoiterStargatePos, LOITER_GATE_RANGE),
                },
                Leash(self.inst, GetStargatePos, IDLE_GATE_MAX_DIST, IDLE_GATE_DIST),
                ParallelNode{
                    FaceEntity(self.inst, GetIdleStargate, KeepIdleStargate),
                    SequenceNode{
                        WaitNode(IDLE_GATE_TIME),
                        ActionNode(function() self.inst:OnLostAtrium() end),
                    },
                },
            },
            Wander(self.inst),
        }, .5)
    elseif self.inst.canfight then
        root = PriorityNode({
            WhileNode(function() return self.inst.components.combat:HasTarget() and ShouldSnare(self) end, "FossilSnare",
                ActionNode(function()
                    self.inst:PushEvent("fossilsnare", self.abilitydata)
                    self.abilitydata = nil
                end)),
            ChaseAndAttack(self.inst),
            ParallelNode{
                SequenceNode{
                    WaitNode(RESET_COMBAT_DELAY),
                    ActionNode(function() self.inst:SetEngaged(false) end),
                },
                PriorityNode({
                    SequenceNode{
                        FindClosest(self.inst, SEE_LURE_DIST, SAFE_LURE_DIST, { "shadowlure" }),
                        FaceEntity(self.inst, GetShadowLure, KeepShadowLure),
                    },
                    Wander(self.inst),
                }, .5),
            },
        }, .5)
    else
        local t = GetTime()
        self.skullachetime = t + 8 + math.random() * SKULLACHE_CD
        self.fallaparttime = t + 8 + math.random() * FALLAPART_CD

        root = PriorityNode({
            WhileNode(function() return not TheWorld.state.isnight end, "Daytime",
                ActionNode(function() self.inst:PushEvent("flinch") end)),
            WhileNode(
                function()
                    local t = GetTime()
                    if t > self.skullachetime then
                        self.skullachetime = t + SKULLACHE_CD
                        return true
                    end
                    return false
                end,
                "SkullAche",
                ActionNode(function() self.inst:PushEvent("skullache") end)),
            WhileNode(
                function()
                    local t = GetTime()
                    if t > self.fallaparttime then
                        self.fallaparttime = t + FALLAPART_CD
                        return true
                    end
                    return false
                end,
                "FallApart",
                ActionNode(function() self.inst:PushEvent("fallapart") end)),
            SequenceNode{
                FindClosest(self.inst, SEE_LURE_DIST, SAFE_LURE_DIST, { "shadowlure" }),
                FaceEntity(self.inst, GetShadowLure, KeepShadowLure),
            },
            Wander(self.inst),
        }, .5)
    end

    self.bt = BT(self.inst, root)
end

return StalkerBrain
