local SoulEater = Class(function(self, inst)
    self.inst = inst

    self.oneatsoulfn = nil

    --V2C: Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("souleater")
end)

function SoulEater:SetOnEatSoulFn(fn)
    self.oneatsoulfn = fn
end

function SoulEater:EatSoul(soul)
    if soul.components.soul == nil then
        return false
    elseif soul.components.stackable ~= nil then
        soul = soul.components.stackable:Get()
    end

    self.inst:PushEvent("oneatsoul", { soul = soul })
    if self.oneatsoulfn ~= nil then
        self.oneatsoulfn(self.inst, soul)
    end

    if soul:IsValid() then --might get removed in OnEatSoul
        soul:Remove()
    end
    return true
end

return SoulEater
