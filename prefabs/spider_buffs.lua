local function OnExtended(inst, target)
    if inst.decaytimer ~= nil then
        inst.decaytimer:Cancel()
    end

    if inst.extendedfn ~= nil then
        inst.extendedfn(inst, target)
    end

    inst.decaytimer = inst:DoTaskInTime(inst.duration, function() inst.components.debuff:Stop() end)
end

local function OnAttached(inst, target)
    OnExtended(inst, target)
end

local function OnDetached(inst, target)
    if inst.decaytimer ~= nil then
        inst.decaytimer:Cancel()
        inst.decaytimer = nil
    end

    if inst.detachfn ~= nil then
        inst.detachfn(inst, target)
    end

    inst:Remove()
end

local function whistle_fn()
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

    inst.duration = TUNING.SPIDER_WHISTLE_DURATION
    inst.extendedfn = function(buff, target)
        target.defensive = true
        target.no_targeting = true

        if target.components.combat:HasTarget() then
            target.components.combat:DropTarget()
        end
    end

    inst.detachfn = function(buff, target)
        if target ~= nil and target:IsValid() and not target.components.health:IsDead() then
            target.no_targeting = false
        end
    end

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(OnDetached)
    inst.components.debuff:SetExtendedFn(OnExtended)

    return inst
end

local function bedazzle_fn()
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

    inst.duration = TUNING.BEDAZZLEMENT_DURATION
    inst.extendedfn = function(buff, target)
        
        if not target.bedazzled and target.components.follower.leader == nil then
            target.sg:GoToState("hit")
            target:SetHappyFace(true)
        end

        target.bedazzled = true
    end
    inst.detachfn = function(buff, target)
        if target ~= nil and target:IsValid() and not target.components.health:IsDead() then
            if target.components.follower.leader == nil then
                target.sg:GoToState("hit")
                target:SetHappyFace(false)
            end
            
            target.bedazzled = false 
        end
    end

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(OnDetached)
    inst.components.debuff:SetExtendedFn(OnExtended)

    return inst
end

local function summon_fn()
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

    inst.duration = TUNING.SPIDER_SUMMON_TIME + (math.random() * 2)
    inst.extendedfn = function(buff, target)
        target.summoned = true 
    end
    inst.detachfn = function(buff, target)
        target.summoned = false
    end

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(OnDetached)
    inst.components.debuff:SetExtendedFn(OnExtended)

    return inst
end

return Prefab("spider_whistle_buff", whistle_fn),
       Prefab("bedazzle_buff", bedazzle_fn),
       Prefab("spider_summoned_buff", summon_fn)