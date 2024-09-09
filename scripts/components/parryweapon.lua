local ParryWeapon = Class(function(self, inst)
    self.inst = inst
    self.arc = 178
    self.onpreparryfn = nil
    self.onparryfn = nil

    --V2C: Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("parryweapon")
end)

function ParryWeapon:OnRemoveFromEntity()
    self.inst:RemoveTag("parryweapon")
end

function ParryWeapon:SetParryArc(arc)
    self.arc = arc
end

--This is purely for stategraph animation sfx, can actually be bypassed!
function ParryWeapon:SetOnPreParryFn(fn)
    self.onpreparryfn = fn
end

function ParryWeapon:SetOnParryFn(fn)
    self.onparryfn = fn
end

--This is purely for stategraph animation sfx, can actually be bypassed!
function ParryWeapon:OnPreParry(doer)
    if self.onpreparryfn ~= nil then
        self.onpreparryfn(self.inst, doer)
    end
end

function ParryWeapon:EnterParryState(doer, rot, duration)
    doer:PushEvent("combat_parry", { weapon = self.inst, direction = rot, duration = duration })
end

function ParryWeapon:TryParry(doer, attacker, damage, weapon, stimuli)
    if (stimuli ~= nil and stimuli ~= "stun") or attacker:HasTag("groundspike") then
        return false
    end
    --first check if doer is facing attacker
    local rot = doer.Transform:GetRotation()
    local drot = math.abs(rot - doer:GetAngleToPoint(attacker.Transform:GetWorldPosition()))
    while drot > 180 do
        drot = drot - 360
    end
    local threshold = self.arc * .5
    if math.abs(drot) >= threshold then
        --if not, check if locomotor attacker is facing doer (could be a charge attack, going thru the parry)
        if attacker.components.locomotor == nil then
            return false
        end
        drot = math.abs(rot - attacker.Transform:GetRotation() + 180)
        while drot > 180 do
            drot = drot - 360
        end
        if math.abs(drot) >= threshold then
            return false
        end
    end
    if self.onparryfn ~= nil then
        self.onparryfn(self.inst, doer, attacker, damage)
    end
    return true
end

return ParryWeapon
