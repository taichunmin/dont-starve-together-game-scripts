local prefabs =
{

}

local function OnInit(inst)
    inst.components.mood:ValidateMood()
end

local function RegisterWithWorld(inst)    
    TheWorld:PushEvent("plantherdspawned",inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("herd")
    --V2C: Don't use CLASSIFIED because herds use FindEntities on "herd" tag
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")

    inst:AddComponent("herd")

    inst.components.herd:SetGatherRange(TUNING.DOMESTICPLANTHERD_RANGE)
    inst.components.herd:SetUpdateRange(20)
    inst.components.herd:SetOnEmptyFn(inst.Remove)
    inst.components.herd:SetMemberTag("lunarplant_target")
    inst.components.herd:SetMaxSize(36)

    inst:DoTaskInTime(0,RegisterWithWorld)

    return inst
end

return Prefab("domesticplantherd", fn, nil, prefabs)
