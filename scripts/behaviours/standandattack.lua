StandAndAttack = Class(BehaviourNode, function(self, inst, findnewtargetfn, timeout)
    BehaviourNode._ctor(self, "StandAndAttack")
    self.inst = inst
    self.findnewtargetfn = findnewtargetfn
    self.numattacks = 0
	self.timeout = timeout

    -- we need to store this function as a key to use to remove itself later
    self.onattackfn = function(inst, data)
        self:OnAttackOther(data.target)
    end

    self.inst:ListenForEvent("onattackother", self.onattackfn)
    self.inst:ListenForEvent("onmissother", self.onattackfn)
end)

function StandAndAttack:__tostring()
    return string.format("target %s", tostring(self.inst.components.combat.target))
end

function StandAndAttack:OnStop()
    self.inst:RemoveEventCallback("onattackother", self.onattackfn)
    self.inst:RemoveEventCallback("onmissother", self.onattackfn)
end

function StandAndAttack:OnAttackOther(target)
    --print ("on attack other", target)
    self.numattacks = self.numattacks + 1
    self.starttime = nil -- reset max chase time timer
end

function StandAndAttack:Visit()
    local combat = self.inst.components.combat
    if self.status == READY then
        combat:ValidateTarget()

        if combat.target == nil and self.findnewtargetfn ~= nil then
            combat:SetTarget(self.findnewtargetfn(self.inst))
        end

        if combat.target ~= nil then
            self.inst.components.combat:BattleCry()
            self.starttime = GetTime()
            self.status = RUNNING
        else
            self.status = FAILED
        end
    end

    if self.status == RUNNING then
        local is_attacking = self.inst.sg:HasStateTag("attack")

        if self.starttime == nil then
            self.starttime = GetTime()
		end

        if combat.target == nil or not combat.target.entity:IsValid() then
            self.status = FAILED
            combat:SetTarget(nil)
		elseif (self.timeout ~= nil and self.starttime ~= nil and GetTime() - self.starttime > self.timeout) then
            self.status = FAILED
            combat:SetTarget(nil)
        elseif combat.target.components.health ~= nil and combat.target.components.health:IsDead() then
            self.status = SUCCESS
            combat:SetTarget(nil)
        else
            if self.inst.sg:HasStateTag("canrotate") then
                self.inst:FacePoint(combat.target:GetPosition())
            end

            combat:TryAttack()

            self:Sleep(.125)
        end
    end
end
