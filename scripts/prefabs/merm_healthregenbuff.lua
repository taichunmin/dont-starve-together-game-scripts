local function OnTick(inst, target)
    if target.components.health ~= nil and
        not target.components.health:IsDead() and
        not target:HasTag("playerghost") then
            if target:HasTag("player") then
                target.components.health:DoDelta(TUNING.MERM_HEALTHREGEN_TICK_VALUE_PLAYER, nil, "merm_heal")
            else
                target.components.health:DoDelta(TUNING.MERM_HEALTHREGEN_TICK_VALUE, nil, "merm_heal")
            end
    else
        inst.components.debuff:Stop()
    end
end

local function OnAttached(inst, target)
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0) --in case of loading
    inst.task = inst:DoPeriodicTask(TUNING.MERM_HEALTHREGEN_TICK_RATE, OnTick, nil, target)
    inst:ListenForEvent("death", function()
        inst.components.debuff:Stop()
    end, target)
end

local function OnTimerDone(inst, data)
    if data.name == "merm_heal" then
        inst.components.debuff:Stop()
    end
end

local function OnExtended(inst, target)
    inst.components.timer:StopTimer("merm_heal")
    inst.components.timer:StartTimer("merm_heal", TUNING.MERM_HEALTHREGEN_DURATION)
    inst.task:Cancel()
    inst.task = inst:DoPeriodicTask(TUNING.MERM_HEALTHREGEN_TICK_RATE, OnTick, nil, target)
end

local function fn()
    local inst = CreateEntity()

    if not TheWorld.ismastersim then
        --Not meant for client!
        inst:DoTaskInTime(0, inst.Remove)

        return inst
    end

    inst.entity:AddTransform()

    --[[Non-networked entity]]
    --inst.entity:SetCanSleep(false)
    inst.entity:Hide()
    inst.persists = false

    inst:AddTag("CLASSIFIED")

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(inst.Remove)
    inst.components.debuff:SetExtendedFn(OnExtended)
    inst.components.debuff.keepondespawn = true

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("merm_heal", TUNING.MERM_HEALTHREGEN_DURATION)
    inst:ListenForEvent("timerdone", OnTimerDone)

    return inst
end

return Prefab("merm_healthregenbuff", fn )
