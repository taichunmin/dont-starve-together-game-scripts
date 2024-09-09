--Works with shadowdominance component and inherentshadowdominance tag

local function OnReactivate(attacker)
    attacker._shadowdsubmissive_task = nil

    if attacker.components.inventory ~= nil and attacker.components.inventory:EquipHasTag("shadowdominance") then
        attacker:AddTag("shadowdominance")
        return
    end

    if attacker:HasTag("inherentshadowdominance") then
        attacker:AddTag("shadowdominance")
    end
end

local function OnAttacked(inst, data)
    if data ~= nil and data.attacker ~= nil then
        if data.attacker._shadowdsubmissive_task ~= nil then
            data.attacker._shadowdsubmissive_task:Cancel()
        else
            data.attacker:RemoveTag("shadowdominance")
        end
        data.attacker._shadowdsubmissive_task = data.attacker:DoTaskInTime(inst.components.shadowsubmissive.forgetattackertime, OnReactivate)
    end
end

local ShadowSubmissive = Class(function(self, inst)
    self.inst = inst

    self.forgetattackertime = 12

    --V2C: Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("shadowsubmissive")

    inst:ListenForEvent("attacked", OnAttacked)
end)

function ShadowSubmissive:OnRemoveFromEntity()
    inst:RemoveTag("shadowsubmissive")
    self.inst:RemoveEventCallback("attacked", OnAttacked)
end

function ShadowSubmissive:ShouldSubmitToTarget(target)
    return target ~= nil and target:IsValid() and target:HasTag("shadowdominance")
end

function ShadowSubmissive:TargetHasDominance(target)
    return target ~= nil
        and target:IsValid()
        and (
            target.components.inventory ~= nil and
            target.components.inventory:EquipHasTag("shadowdominance")
            or
            target:HasTag("inherentshadowdominance")
        )
end

return ShadowSubmissive
