require "behaviours/faceentity"
require "behaviours/leash"

local EyeOfTerrorBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
    --self._special_move = nil
end)

local function GetFaceTargetFn(inst)
    return inst.components.combat.target
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.combat:TargetIs(target)
end

local function GetSpawnPoint(inst)
    return inst.components.knownlocations:GetLocation("spawnpoint")
end

local function TrySpawnMiniEyes(inst)
    if inst.components.timer:TimerExists("spawneyes_cd") then
        return nil
    end

    return (inst.components.commander:GetNumSoldiers() < inst:GetDesiredSoldiers() and "spawnminieyes")
        or false
end

local CHOMP_ATTACK_DSQ = (TUNING.EYEOFTERROR_ATTACK_RANGE * TUNING.EYEOFTERROR_ATTACK_RANGE) + 0.01
local function TryChompAttack(inst)
    if inst.sg.mem.transformed then
        local target = inst.components.combat.target
        if target ~= nil then
            local dsq_to_target = inst:GetDistanceSqToInst(target)
            if dsq_to_target < CHOMP_ATTACK_DSQ then
                return "chomp"
            end
        end
    end

    return false
end

local function TryChargeAttack(inst)
    if not inst.components.timer:TimerExists("charge_cd") then
        local target = inst.components.combat.target
        if target ~= nil then
            local dsq_to_target = inst:GetDistanceSqToInst(target)
            if dsq_to_target > TUNING.EYEOFTERROR_CHARGEMINDSQ and dsq_to_target < TUNING.EYEOFTERROR_CHARGEMAXDSQ then
                return "charge"
            end
        end
    end

    return false
end

local function TryFocusMiniEyesOnTarget(inst)
    if inst.components.timer:TimerExists("focustarget_cd") 
            or not inst.components.combat:HasTarget() then
        return nil
    end

    local num_soldiers = inst.components.commander:GetNumSoldiers()
    return (num_soldiers >= TUNING.EYEOFTERROR_MINGUARDS_PERSPAWN and "focustarget")
        or false
end

function EyeOfTerrorBrain:ShouldUseSpecialMove()
    self._special_move = TrySpawnMiniEyes(self.inst)
        or TryFocusMiniEyesOnTarget(self.inst)
        or TryChargeAttack(self.inst)
        or TryChompAttack(self.inst)
        or nil
    if self._special_move then
        return true
    else
        return false
    end
end

function EyeOfTerrorBrain:GetLeashPosition()
    if self._leash_pos == nil then
        local my_pos = self.inst:GetPosition()
        local target = self.inst.components.combat.target
        if target then
            local target_pos = target:GetPosition()
            local normal, _ = (my_pos - target_pos):GetNormalizedAndLength()
            local leash_pos = target_pos + (normal * 7)

            self._leash_pos = leash_pos
        else
            self._leash_pos = my_pos
        end

        self.inst.components.timer:StartTimer("leash_cd", 3)
    end

    return self._leash_pos
end

function EyeOfTerrorBrain:OnStart()
    local root = PriorityNode(
        {
            WhileNode(function() return not self.inst.sg:HasStateTag("charge") end, "Not Charging",
                PriorityNode({
                    WhileNode(function() return self:ShouldUseSpecialMove() end, "Special Moves",
                        ParallelNode {
                            ActionNode(function() self._leash_pos = nil end),
                            ActionNode(function() self.inst:PushEvent(self._special_move) end),
                        }
                    ),

                    IfNode(function() return not self.inst.components.timer:TimerExists("leash_cd") end, "No Recent Leash",
                        PriorityNode({
                            Leash(self.inst, function() return self:GetLeashPosition() end, 0.5, 0.5),
                            ActionNode(function() self._leash_pos = nil end),
                        }, 0.5)
                    ),

                    ParallelNode {
                        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
                        Wander(self.inst, GetSpawnPoint, 30, {minwaittime = 6}),
                    },
                }, 0.5)
            ),
        }, 0.5)
    self.bt = BT(self.inst, root)
end

function EyeOfTerrorBrain:OnInitializationComplete()
    local pos = self.inst:GetPosition()
    pos.y = 0

    self.inst.components.knownlocations:RememberLocation("spawnpoint", pos, true)
end

return EyeOfTerrorBrain
