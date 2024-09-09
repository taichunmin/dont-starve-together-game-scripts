ChaseAndAttackAndAvoid = Class(BehaviourNode, function(self, inst, findavoidanceobjectfn, avoid_dist, max_chase_time, give_up_dist, max_attacks, findnewtargetfn, walk)
    BehaviourNode._ctor(self, "ChaseAndAttackAndAvoid")
    self.inst = inst
    self.findnewtargetfn = findnewtargetfn
    self.max_chase_time = max_chase_time
    self.give_up_dist = give_up_dist
    self.max_attacks = max_attacks
    self.numattacks = 0
    self.walk = walk
    self.findavoidanceobjectfn = findavoidanceobjectfn
    self.avoid_dist = avoid_dist

    -- we need to store this function as a key to use to remove itself later
    self.onattackfn = function(inst, data)
        self:OnAttackOther(data.target)
    end

    self.inst:ListenForEvent("onattackother", self.onattackfn)
    self.inst:ListenForEvent("onmissother", self.onattackfn)
end)

function ChaseAndAttackAndAvoid:__tostring()
    return string.format("target %s, avoiding %s", tostring(self.inst.components.combat.target), tostring(self.avoidtarget))
end

function ChaseAndAttackAndAvoid:OnStop()
    self.inst:RemoveEventCallback("onattackother", self.onattackfn)
    self.inst:RemoveEventCallback("onmissother", self.onattackfn)
end

function ChaseAndAttackAndAvoid:OnAttackOther(target)
    --print ("on attack other", target)
    self.numattacks = self.numattacks + 1
    self.startruntime = nil -- reset max chase time timer
end

function ChaseAndAttackAndAvoid:Visit()
    local combat = self.inst.components.combat
    if self.status == READY then
        combat:ValidateTarget()

        if combat.target == nil and self.findnewtargetfn ~= nil then
			combat:SetTarget(self.findnewtargetfn(self.inst))
        end

        if self.findavoidanceobjectfn ~= nil then
            self.avoidtarget = self.findavoidanceobjectfn(self.inst)
        end

		if combat:HasTarget() then
			combat:BattleCry()
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
            local hp = Point(combat.target.Transform:GetWorldPosition())
            local pt = Point(self.inst.Transform:GetWorldPosition())
            local dsq = distsq(hp, pt)
            --local angle = self.inst:GetAngleToPoint(hp)
            local r = self.inst:GetPhysicsRadius(0) + combat.target:GetPhysicsRadius(-.1) + .1
            local running = self.inst.components.locomotor:WantsToRun()

            -- this is probably the biggest hack i've done in my life...
            if self.avoidtarget ~= nil and self.avoidtarget:IsValid() then
                local ap = Point(self.avoidtarget.Transform:GetWorldPosition())
                if distsq(ap, pt) < dsq then
                    local delta_dir = anglediff(--[[angle]]self.inst:GetAngleToPoint(hp), self.inst:GetAngleToPoint(ap))
                    if math.abs(delta_dir) < 45 then
                        local offset = (hp - pt):GetNormalized()
                        if delta_dir < 0 then
                            hp.x = ap.x - offset.z * self.avoid_dist
                            hp.z = ap.z + offset.x * self.avoid_dist
                        else
                            hp.x = ap.x + offset.z * self.avoid_dist
                            hp.z = ap.z - offset.x * self.avoid_dist
                        end
                        hp.y = ap.y + offset.y * self.avoid_dist
                    end
                end
            end

            if (running and dsq > r * r) or (not running and dsq > combat:CalcAttackRangeSq()) then
                --self.inst.components.locomotor:RunInDirection(angle)
                self.inst.components.locomotor:GoToPoint(hp, nil, not self.walk)
            elseif not (self.inst.sg ~= nil and self.inst.sg:HasStateTag("jumping")) then
                self.inst.components.locomotor:Stop()
                if self.inst.sg:HasStateTag("canrotate") then
                    self.inst:FacePoint(hp)
                end
            end

            if combat:TryAttack() then
                -- reset chase timer when attack hits, not on attempts
            elseif self.startruntime == nil then
                self.startruntime = GetTime()
                self.inst.components.combat:BattleCry()
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
