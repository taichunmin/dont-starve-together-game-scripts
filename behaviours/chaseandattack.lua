ChaseAndAttack = Class(BehaviourNode, function(self, inst, max_chase_time, give_up_dist, max_attacks, findnewtargetfn, walk, distance_from_ocean_target)
    BehaviourNode._ctor(self, "ChaseAndAttack")
    self.inst = inst
    self.findnewtargetfn = findnewtargetfn
    self.max_chase_time = max_chase_time
    self.give_up_dist = give_up_dist
    self.max_attacks = max_attacks
    self.numattacks = 0
    self.walk = walk
    self.distance_from_ocean_target = distance_from_ocean_target

    -- we need to store this function as a key to use to remove itself later
    self.onattackfn = function(inst)
        self:OnAttackOther()
    end

    self.inst:ListenForEvent("onattackother", self.onattackfn)
    self.inst:ListenForEvent("onmissother", self.onattackfn)
end)

function ChaseAndAttack:__tostring()
    return string.format("target %s", tostring(self.inst.components.combat.target))
end

function ChaseAndAttack:OnStop()
    self.inst:RemoveEventCallback("onattackother", self.onattackfn)
    self.inst:RemoveEventCallback("onmissother", self.onattackfn)
end

function ChaseAndAttack:OnAttackOther()
    --print ("on attack other", target)
    self.numattacks = self.numattacks + 1
    self.startruntime = nil -- reset max chase time timer
end

function ChaseAndAttack:Visit()
    local combat = self.inst.components.combat
    if self.status == READY then
        combat:ValidateTarget()

        if combat.target == nil and self.findnewtargetfn ~= nil then
            combat:SetTarget(self.findnewtargetfn(self.inst))
        end

        if combat.target ~= nil then
            self.inst.components.combat:BattleCry()
            self.startruntime = GetTime()
            self.numattacks = 0
            self.status = RUNNING
        else
            self.status = FAILED
        end
    end

    if self.status == RUNNING then
        local is_attacking = self.inst.sg:HasStateTag("attack")

        if combat.target == nil or not combat.target.entity:IsValid() then
            self.status = FAILED
            combat:SetTarget(nil)
            self.inst.components.locomotor:Stop()
        elseif combat.target.components.health ~= nil and combat.target.components.health:IsDead() then
            self.status = SUCCESS
            combat:SetTarget(nil)
            self.inst.components.locomotor:Stop()
        else
            local target_position = Point(combat.target.Transform:GetWorldPosition())
            local facing_point = target_position
            local me = Point(self.inst.Transform:GetWorldPosition())

            local dsq = distsq(target_position, me)

            local running = self.inst.components.locomotor:WantsToRun()
            --local angle = self.inst:GetAngleToPoint(target_position)

            if self.distance_from_ocean_target ~= nil and dsq > combat:CalcAttackRangeSq() and not combat.target:IsOnValidGround() then
                local reverse_direction = me - target_position
                local rd_normal_x, rd_normal_z = VecUtil_Normalize(reverse_direction.x, reverse_direction.z)

                local ocean_distance = FunctionOrValue(self.distance_from_ocean_target, self.inst, combat.target)
                target_position = Point((rd_normal_x * ocean_distance) + target_position.x, target_position.y, (rd_normal_z * ocean_distance) + target_position.z)
                dsq = distsq(target_position, me)
                --angle = self.inst:GetAngleToPoint(target_position)
            end

            if not self.inst.sg:HasStateTag("longattack") then
                local r = self.inst:GetPhysicsRadius(0) + combat.target:GetPhysicsRadius(-.1) + .1
                if (running and dsq > r * r) or (not running and dsq > combat:CalcAttackRangeSq()) then
                    --self.inst.components.locomotor:RunInDirection(angle)
                    self.inst.components.locomotor:GoToPoint(target_position, nil, not self.walk)
                elseif not (self.inst.sg ~= nil and self.inst.sg:HasStateTag("jumping")) then
                    self.inst.components.locomotor:Stop()
                    if self.inst.sg:HasStateTag("canrotate") then
                        self.inst:FacePoint(facing_point)
                    end
                end

                if combat:TryAttack() then
                    -- reset chase timer when attack hits, not on attempts
                elseif self.startruntime == nil then
                    self.startruntime = GetTime()
                    self.inst.components.combat:BattleCry()
                end
            end

            if self.max_attacks ~= nil and self.numattacks >= self.max_attacks then
                self.status = SUCCESS
                self.inst.components.combat:SetTarget(nil)
                self.inst.components.locomotor:Stop()
                return
            elseif (self.give_up_dist ~= nil and dsq >= self.give_up_dist * self.give_up_dist)
                    or (self.max_chase_time ~= nil and self.startruntime ~= nil and GetTime() - self.startruntime > self.max_chase_time) then
                self.status = FAILED
                self.inst.components.combat:GiveUp()
                self.inst.components.locomotor:Stop()
                return
            end

            self:Sleep(.125)
        end
    end
end
