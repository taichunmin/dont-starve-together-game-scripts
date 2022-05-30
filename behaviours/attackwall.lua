AttackWall = Class(BehaviourNode, function(self, inst)
    BehaviourNode._ctor(self, "AttackWall")
    self.inst = inst
end)

function AttackWall:__tostring()
    return string.format("target %s", tostring(self.target))
end

local ATTACKWALL_MUST_TAGS = { "wall" }

function AttackWall:Visit()
    if self.status == READY then
        local rot = self.inst.Transform:GetRotation()
        self.target = FindEntity(self.inst, 1.5 + self.inst:GetPhysicsRadius(0),
            function(guy)
                return math.abs(anglediff(rot, self.inst:GetAngleToPoint(guy.Transform:GetWorldPosition()))) < 30
                    and self.inst.components.combat:CanTarget(guy)
            end,
            ATTACKWALL_MUST_TAGS
        )

        if self.target ~= nil then
            self.status = RUNNING
            self.inst.components.locomotor:Stop()
            self.done = false
        else
            self.status = FAILED
        end
    end

    if self.status == RUNNING then
        --local is_attacking = self.inst.sg:HasStateTag("attack")
        if self.target == nil or not self.target.entity:IsValid() or (self.target.components.health ~= nil and self.target.components.health:IsDead()) then
            self.status = FAILED
            self.inst.components.locomotor:Stop()
        else
            self.status = self.inst.components.combat:TryAttack(self.target) and SUCCESS or FAILED
            self:Sleep(1)
        end
    end
end
