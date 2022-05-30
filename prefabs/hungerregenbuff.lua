local function OnTick(inst, target)
    if target.components.health ~= nil and target.components.hunger ~= nil and
            not target.components.health:IsDead() and
            not target:HasTag("playerghost") then
        local hungerabsorption = (target.components.eater ~= nil and target.components.eater.hungerabsorption)
                or 1.0
        local foodmemory_mult = (target.components.foodmemory ~= nil and target.components.foodmemory:GetFoodMultiplier(inst.prefab))
                or 1.0

        local delta = TUNING.HUNGERREGEN_TICK_VALUE * hungerabsorption * foodmemory_mult
        target.components.hunger:DoDelta(delta, nil, inst.prefab)
    else
        inst.components.debuff:Stop()
    end
end

local function OnAttached(inst, target)
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0) --in case of loading

    inst.task = inst:DoPeriodicTask(TUNING.HUNGERREGEN_TICK_RATE, OnTick, nil, target)
    inst:ListenForEvent("death", function()
        inst.components.debuff:Stop()
    end, target)
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
    inst.entity:Hide()
    inst.persists = false

    inst:AddTag("CLASSIFIED")

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(inst.Remove)

    return inst
end

return Prefab("hungerregenbuff", fn)
