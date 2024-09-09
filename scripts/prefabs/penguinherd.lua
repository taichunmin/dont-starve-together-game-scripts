local prefabs =
{
    "bird_egg",
}

local function InMood(inst)
    if inst.components.periodicspawner ~= nil then
        inst.components.periodicspawner:SafeStart()
    end
    if inst.components.herd ~= nil then
        for k, v in pairs(inst.components.herd.members) do
            k:PushEvent("entermood")
        end
    end
end

local function LeaveMood(inst)
    if inst.components.periodicspawner ~= nil then
        inst.components.periodicspawner:Stop()
    end
    if inst.components.herd ~= nil then
        for k, v in pairs(inst.components.herd.members) do
            k:PushEvent("leavemood")
        end
    end
end

local function AddMember(inst, member)
    if inst.components.mood ~= nil then
        member:PushEvent(inst.components.mood:IsInMood() and "entermood" or "leavemood")
    end
end

--local function OnFull(inst)
--end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("herd")
    --V2C: Don't use CLASSIFIED because herds use FindEntities on "herd" tag
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")

    inst:AddComponent("herd")
    inst.components.herd:SetMemberTag("penguin")
    inst.components.herd:SetGatherRange(40)
    inst.components.herd:SetUpdateRange(20)
    inst.components.herd:SetOnEmptyFn(inst.Remove)
    --inst.components.herd:SetOnFullFn(OnFull)
    inst.components.herd:SetAddMemberFn(AddMember)

    inst:AddComponent("mood")
    inst.components.mood:SetMoodTimeInDays(TUNING.PENGUIN_MATING_SEASON_LENGTH, 0)
    inst.components.mood:SetInMoodFn(InMood)
    inst.components.mood:SetLeaveMoodFn(LeaveMood)
    inst.components.mood:CheckForMoodChange()

    return inst
end

return Prefab("penguinherd", fn, nil, prefabs)
