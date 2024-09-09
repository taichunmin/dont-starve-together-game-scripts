-------------------------------------------------------------------------
---------------------- Attach and dettach functions ---------------------
-------------------------------------------------------------------------

local function playerabsorption_attach(inst, target)
    if target.components.health ~= nil then
        target.components.health.externalabsorbmodifiers:SetModifier(inst, TUNING.BUFF_PLAYERABSORPTION_MODIFIER)
    end
end

local function playerabsorption_detach(inst, target)
    if target.components.health ~= nil then
        target.components.health.externalabsorbmodifiers:RemoveModifier(inst)
    end
end

local function attack_attach(inst, target)
    if target.components.combat ~= nil then
        target.components.combat.externaldamagemultipliers:SetModifier(inst, TUNING.BUFF_ATTACK_MULTIPLIER)
    end
end

local function attack_detach(inst, target)
    if target.components.combat ~= nil then
        target.components.combat.externaldamagemultipliers:RemoveModifier(inst)
    end
end

local function work_attach(inst, target)
    if target.components.workmultiplier == nil then
        target:AddComponent("workmultiplier")
    end
    target.components.workmultiplier:AddMultiplier(ACTIONS.CHOP,   TUNING.BUFF_WORKEFFECTIVENESS_MODIFIER, inst)
    target.components.workmultiplier:AddMultiplier(ACTIONS.MINE,   TUNING.BUFF_WORKEFFECTIVENESS_MODIFIER, inst)
    target.components.workmultiplier:AddMultiplier(ACTIONS.HAMMER, TUNING.BUFF_WORKEFFECTIVENESS_MODIFIER, inst)
end

local function work_detach(inst, target)
    if target.components.workmultiplier ~= nil then
        target.components.workmultiplier:RemoveMultiplier(ACTIONS.CHOP,   inst)
        target.components.workmultiplier:RemoveMultiplier(ACTIONS.MINE,   inst)
        target.components.workmultiplier:RemoveMultiplier(ACTIONS.HAMMER, inst)
    end
end

local function moisture_attach(inst, target)
	if target.components.moistureimmunity == nil then
		target:AddComponent("moistureimmunity")
	end
	target.components.moistureimmunity:AddSource(inst)
end

local function moisture_detach(inst, target)
	if target.components.moistureimmunity ~= nil then
		target.components.moistureimmunity:RemoveSource(inst)
	end
end

local function electric_attach(inst, target)
    if target.components.electricattacks == nil then
        target:AddComponent("electricattacks")
    end
    target.components.electricattacks:AddSource(inst)
    if inst._onattackother == nil then
        inst._onattackother = function(attacker, data)
            if data.weapon ~= nil then
                if data.projectile == nil then
                    --in combat, this is when we're just launching a projectile, so don't do FX yet
                    if data.weapon.components.projectile ~= nil then
                        return
                    elseif data.weapon.components.complexprojectile ~= nil then
                        return
                    elseif data.weapon.components.weapon:CanRangedAttack() then
                        return
                    end
                end
                if data.weapon.components.weapon ~= nil and data.weapon.components.weapon.stimuli == "electric" then
                    --weapon already has electric stimuli, so probably does its own FX
                    return
                end
            end
            if data.target ~= nil and data.target:IsValid() and attacker:IsValid() then
                SpawnPrefab("electrichitsparks"):AlignToTarget(data.target, data.projectile ~= nil and data.projectile:IsValid() and data.projectile or attacker, true)
            end
        end
        inst:ListenForEvent("onattackother", inst._onattackother, target)
    end
    SpawnPrefab("electricchargedfx"):SetTarget(target)
end

local function electric_extend(inst, target)
    SpawnPrefab("electricchargedfx"):SetTarget(target)
end

local function electric_detach(inst, target)
    if target.components.electricattacks ~= nil then
        target.components.electricattacks:RemoveSource(inst)
    end
    if inst._onattackother ~= nil then
        inst:RemoveEventCallback("onattackother", inst._onattackother, target)
        inst._onattackother = nil
    end
end

local function sleepless_attach(inst, target)
    if target.components.grogginess ~= nil then
        target.components.grogginess:AddResistanceSource(inst, TUNING.SLEEPRESISTBUFF_VALUE)
    end
end

local function sleepless_detach(inst, target)
    if target.components.grogginess ~= nil then
        target.components.grogginess:RemoveResistanceSource(inst)
    end
end

-------------------------------------------------------------------------
----------------------- Prefab building functions -----------------------
-------------------------------------------------------------------------

local function OnTimerDone(inst, data)
    if data.name == "buffover" then
        inst.components.debuff:Stop()
    end
end

local function MakeBuff(name, onattachedfn, onextendedfn, ondetachedfn, duration, priority, prefabs)
    local ATTACH_BUFF_DATA = {
        buff = "ANNOUNCE_ATTACH_BUFF_"..string.upper(name),
        priority = priority
    }
    local DETACH_BUFF_DATA = {
        buff = "ANNOUNCE_DETACH_BUFF_"..string.upper(name),
        priority = priority
    }

    local function OnAttached(inst, target)
        inst.entity:SetParent(target.entity)
        inst.Transform:SetPosition(0, 0, 0) --in case of loading
        inst:ListenForEvent("death", function()
            inst.components.debuff:Stop()
        end, target)

        target:PushEvent("foodbuffattached", ATTACH_BUFF_DATA)
        if onattachedfn ~= nil then
            onattachedfn(inst, target)
        end
    end

    local function OnExtended(inst, target)
        inst.components.timer:StopTimer("buffover")
        inst.components.timer:StartTimer("buffover", duration)

        target:PushEvent("foodbuffattached", ATTACH_BUFF_DATA)
        if onextendedfn ~= nil then
            onextendedfn(inst, target)
        end
    end

    local function OnDetached(inst, target)
        if ondetachedfn ~= nil then
            ondetachedfn(inst, target)
        end

        target:PushEvent("foodbuffdetached", DETACH_BUFF_DATA)
        inst:Remove()
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
        inst.components.debuff:SetDetachedFn(OnDetached)
        inst.components.debuff:SetExtendedFn(OnExtended)
        inst.components.debuff.keepondespawn = true

        inst:AddComponent("timer")
        inst.components.timer:StartTimer("buffover", duration)
        inst:ListenForEvent("timerdone", OnTimerDone)

        return inst
    end

    return Prefab("buff_"..name, fn, nil, prefabs)
end

return MakeBuff("attack", attack_attach, nil, attack_detach, TUNING.BUFF_ATTACK_DURATION, 1),
       MakeBuff("playerabsorption", playerabsorption_attach, nil, playerabsorption_detach, TUNING.BUFF_PLAYERABSORPTION_DURATION, 1),
       MakeBuff("workeffectiveness", work_attach, nil, work_detach, TUNING.BUFF_WORKEFFECTIVENESS_DURATION, 1),
       MakeBuff("moistureimmunity", moisture_attach, nil, moisture_detach, TUNING.BUFF_MOISTUREIMMUNITY_DURATION, 2),
       MakeBuff("electricattack", electric_attach, electric_extend, electric_detach, TUNING.BUFF_ELECTRICATTACK_DURATION, 2, { "electrichitsparks", "electricchargedfx" }),
       MakeBuff("sleepresistance", sleepless_attach, nil, sleepless_detach, TUNING.SLEEPRESISTBUFF_TIME, 2)
