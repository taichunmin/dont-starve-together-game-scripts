require "behaviours/chaseandattack"
require "behaviours/faceentity"
require "behaviours/wander"
require "behaviours/leash"

local FLEE_DELAY = 15
local DODGE_DELAY = 5
local MAX_DODGE_TIME = 3

local BeeQueenBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
    self._act = nil
    self._lastengaged = 0
    self._lastdisengaged = 0
    self._engaged = false
    self._shouldchase = false
    self._dodgedest = nil
    self._dodgetime = nil
end)

local function GetHomePos(inst)
    return inst.components.knownlocations:GetLocation("spawnpoint")
end

local function GetFaceTargetFn(inst)
    return inst.components.combat.target
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.combat:TargetIs(target)
end

local function TryScreech(self)
    if self.inst.components.combat:HasTarget() then
        self._lastengaged = GetTime()
        if not self._engaged and self._lastengaged - self._lastdisengaged > 2 then
            self._engaged = true
            self.inst.sg.mem.wantstoalert = nil
            return "screech"
        end
    else
        self._lastdisengaged = GetTime()
        if self._engaged and self._lastdisengaged - self._lastengaged > 5 then
            self._engaged = false
        end
    end
    if self.inst.sg.mem.wantstoalert then
        self.inst.sg.mem.wantstoalert = nil
        return self.inst.components.commander:IsAnySoldierNotAlert()
            and "screech"
            or nil
    end
end

local function TrySpawnGuards(inst)
    return not inst.components.timer:TimerExists("spawnguards_cd")
        and inst.components.commander:GetNumSoldiers() < (inst.components.combat:HasTarget() and inst.spawnguards_threshold or 1)
        and "spawnguards"
        or nil
end

local function TryFocusTarget(inst)
    return inst.focustarget_cd > 0
        and inst.components.combat:HasTarget()
        and inst.components.commander:GetNumSoldiers() >= TUNING.BEEQUEEN_MIN_GUARDS_PER_SPAWN
        and not inst.components.timer:TimerExists("focustarget_cd")
        and "focustarget"
        or nil
end

local function ShouldUseSpecialMove(self)
    self._act = TryScreech(self) or TrySpawnGuards(self.inst) or TryFocusTarget(self.inst)
    if self._act ~= nil then
        self._shouldchase = false
        return true
    end
    return false
end

local function ShouldChase(self)
    local target = self.inst.components.combat.target
    if self.inst.focustarget_cd <= 0 then
        return not (self.inst.components.combat:InCooldown() and
                    target ~= nil and
                    target:IsValid() and
                    target:IsNear(self.inst, TUNING.BEEQUEEN_ATTACK_RANGE + target:GetPhysicsRadius(0)))
    elseif target == nil or not target:IsValid() then
        self._shouldchase = false
        return false
    end
    local distsq = self.inst:GetDistanceSqToInst(target)
    local range = TUNING.BEEQUEEN_CHASE_TO_RANGE + (self._shouldchase and 0 or 3)
    self._shouldchase = distsq >= range * range
    if self._shouldchase then
        return true
    elseif self.inst.components.combat:InCooldown() then
        return false
    end
    range = TUNING.BEEQUEEN_ATTACK_RANGE + target:GetPhysicsRadius(0) + 1
    return distsq <= range * range
end

local function CalcDodgeMult(self)
    local found = false
    for k, v in pairs(self.inst.components.grouptargeter:GetTargets()) do
        if self.inst:IsNear(k, TUNING.BEEQUEEN_ATTACK_RANGE + k:GetPhysicsRadius(0)) then
            if found then
                return .5
            end
            found = true
        end
    end
    return 1
end

local function ShouldDodge(self)
    if self._dodgedest ~= nil then
        return true
    end
    local t = GetTime()
    if self.inst.sg.mem.wantstododge then
        --Override dodge timer once
        self.inst.sg.mem.wantstododge = nil
    elseif self.inst.components.combat:GetLastAttackedTime() + DODGE_DELAY < t then
        --Reset dodge timer
        self._dodgetime = nil
        return false
    elseif self._dodgetime == nil then
        --Start dodge timer
        self._dodgetime = t
        return false
    elseif self._dodgetime + DODGE_DELAY * CalcDodgeMult(self) >= t then
        --Wait dodge timer
        return false
    end
    --Find new dodge destination
    local homepos = GetHomePos(self.inst)
    local pos = self.inst:GetPosition()
    local dangerrangesq = TUNING.BEEQUEEN_CHASE_TO_RANGE * TUNING.BEEQUEEN_CHASE_TO_RANGE
    local maxrangesq = TUNING.BEEQUEEN_DEAGGRO_DIST * TUNING.BEEQUEEN_DEAGGRO_DIST
    local mindanger = math.huge
    local bestdest = Vector3()
    local tests = {}
    for i = 2, 6 do
        table.insert(tests, { rsq = i * i })
    end
    for i = 10, 20, 5 do
        local r = i + math.random() * 5
        local theta = TWOPI * math.random()
        local dtheta = PI * .25
        for attempt = 1, 8 do
			local offset = FindWalkableOffset(pos, theta, r, 1, true, true, nil, true, true)
            if offset ~= nil then
                local x, z = offset.x + pos.x, offset.z + pos.z
                if distsq(homepos.x, homepos.z, x, z) < maxrangesq then
                    local nx, nz = offset.x / r, offset.z / r
                    for j, test in ipairs(tests) do
                        test.x = nx * (j - .5) + pos.x
                        test.z = nz * (j - .5) + pos.z
                    end
                    local danger = 0
                    for _, v in ipairs(AllPlayers) do
                        if not v:HasTag("playerghost") and v.entity:IsVisible() then
                            local vx, vy, vz = v.Transform:GetWorldPosition()
                            if distsq(vx, vz, x, z) < dangerrangesq then
                                danger = danger + 1
                            end
                            for j, test in ipairs(tests) do
                                if distsq(vx, vz, test.x, test.z) < test.rsq then
                                    danger = danger + 1
                                end
                            end
                        end
                    end
                    if danger < mindanger then
                        mindanger = danger
                        bestdest.x, bestdest.z = x, z
                        if danger <= 0 then
                            break
                        end
                    end
                end
            end
            theta = theta + dtheta
        end
        if mindanger <= 0 then
            break
        end
    end
    if mindanger < math.huge then
        self._dodgedest = bestdest
        self._dodgetime = nil
        self.inst.components.locomotor.walkspeed = TUNING.BEEQUEEN_DODGE_SPEED
        self.inst.hit_recovery = TUNING.BEEQUEEN_DODGE_HIT_RECOVERY
        CommonHandlers.UpdateHitRecoveryDelay(self.inst)
        return true
    end
    --Reset dodge timer to retry in half the time
    self._dodgetime = t - DODGE_DELAY * .5
    return false
end

function BeeQueenBrain:OnStop()
    self._dodgedest = nil
    self.inst.components.locomotor.walkspeed = TUNING.BEEQUEEN_SPEED
    self.inst.hit_recovery = TUNING.BEEQUEEN_HIT_RECOVERY
end

function BeeQueenBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return ShouldDodge(self) end, "Dodge",
            SequenceNode{
                ParallelNodeAny{
                    WaitNode(MAX_DODGE_TIME),
                    NotDecorator(FailIfSuccessDecorator(
                        Leash(self.inst, function() return self._dodgedest end, 2, 2))),
                },
                ActionNode(function() self:OnStop() end),
            }),
        WhileNode(function() return ShouldUseSpecialMove(self) end, "SpecialMoves",
            ActionNode(function() self.inst:PushEvent(self._act) end)),
        WhileNode(function() return ShouldChase(self) end, "Chase",
            ChaseAndAttack(self.inst)),
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        ParallelNode{
            SequenceNode{
                WaitNode(FLEE_DELAY),
                ActionNode(function() self.inst:PushEvent("flee") end),
            },
            Wander(self.inst, GetHomePos, 5),
        },
    }, .5)

    self.bt = BT(self.inst, root)
end

function BeeQueenBrain:OnInitializationComplete()
    local pos = self.inst:GetPosition()
    pos.y = 0
    self.inst.components.knownlocations:RememberLocation("spawnpoint", pos, true)
end

return BeeQueenBrain
