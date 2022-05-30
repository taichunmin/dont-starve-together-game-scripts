local assets =
{
    Asset("ANIM", "anim/gold_nugget.zip"),
}

local function shine(inst)
    if not inst.AnimState:IsCurrentAnimation("sparkle") then
        inst.AnimState:PlayAnimation("sparkle")
        inst.AnimState:PushAnimation("idle", false)
    end
    inst:DoTaskInTime(4 + math.random() * 5, shine)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetBank("goldnugget")
    inst.AnimState:SetBuild("gold_nugget")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("molebait")
    inst:AddTag("quakedebris")

	if not IsSpecialEventActive(SPECIAL_EVENTS.YOTP) then
	    inst:AddTag("minigameitem")
	end


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.ELEMENTAL
    inst.components.edible.hungervalue = 2
    inst:AddComponent("tradable")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("stackable")
    inst:AddComponent("bait")

    MakeHauntableLaunchAndSmash(inst)

    shine(inst)

    return inst
end

local function OnDelayInteraction(inst)
    inst._knockbacktask = nil
    inst:RemoveTag("knockbackdelayinteraction")
end

local function OnDelayPlayerInteraction(inst)
    inst._playerknockbacktask = nil
    inst:RemoveTag("NOCLICK")
end

local function OnKnockbackDropped(inst, data)
    if data ~= nil and (data.delayinteraction or 0) > 0 then
        if inst._knockbacktask ~= nil then
            inst._knockbacktask:Cancel()
        else
            inst:AddTag("knockbackdelayinteraction")
        end
        inst._knockbacktask = inst:DoTaskInTime(data.delayinteraction, OnDelayInteraction)
    elseif inst._knockbacktask ~= nil then
        inst._knockbacktask:Cancel()
        OnDelayInteraction(inst)
    end

    if data ~= nil and (data.delayplayerinteraction or 0) > 0 then
        if inst._playerknockbacktask ~= nil then
            inst._playerknockbacktask:Cancel()
        else
            inst:AddTag("NOCLICK")
        end
        inst._playerknockbacktask = inst:DoTaskInTime(data.delayplayerinteraction, OnDelayPlayerInteraction)
    elseif inst._playerknockbacktask ~= nil then
        inst._playerknockbacktask:Cancel()
        OnDelayPlayerInteraction(inst)
    end
end

local function luckyfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetBank("goldnugget")
    inst.AnimState:SetBuild("gold_nugget")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:OverrideSymbol("nugget", "gold_nugget", "lucky_goldnugget")

	if IsSpecialEventActive(SPECIAL_EVENTS.YOTP) then
	    inst:AddTag("minigameitem")
	end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.ELEMENTAL
    inst.components.edible.hungervalue = 2
    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = 1

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("stackable")

    MakeHauntableLaunch(inst)

    shine(inst)

    inst:ListenForEvent("knockbackdropped", OnKnockbackDropped)

    return inst
end

return Prefab("goldnugget", fn, assets),
    Prefab("lucky_goldnugget", luckyfn, assets)
