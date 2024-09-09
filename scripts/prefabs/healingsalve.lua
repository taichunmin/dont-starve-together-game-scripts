local assets = {
    Asset("ANIM", "anim/spider_gland_salve.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("spider_gland_salve")
    inst.AnimState:SetBuild("spider_gland_salve")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "small", 0.05, 0.95)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("healer")
    inst.components.healer:SetHealthAmount(TUNING.HEALING_MED)

    MakeHauntableLaunch(inst)

    return inst
end

local assets_acid = {
    Asset("ANIM", "anim/healingsalve_acid.zip"),
}

local function OnHealFn(inst, target)
    target:AddDebuff("healingsalve_acidbuff", "healingsalve_acidbuff")
end

local function fn_acid()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("healingsalve_acid")
    inst.AnimState:SetBuild("healingsalve_acid")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "small", 0.05, 0.95)

    inst:AddTag("healerbuffs")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    local healer = inst:AddComponent("healer")
    healer:SetHealthAmount(TUNING.HEALING_MED)
    healer:SetOnHealFn(OnHealFn)

    MakeHauntableLaunch(inst)

    return inst
end

local function buff_OnAttached(inst, target)
    -- NOTES(JBK): Do not apply health over time for this item because of healerbuffs tag.
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0)

    inst:ListenForEvent("death", function()
        inst.components.debuff:Stop()
    end, target)

    target:AddTag("acidrainimmune")
end

local function buff_OnDetached(inst, target)
    if target ~= nil and target:IsValid() then
        target:RemoveTag("acidrainimmune")

        if target.components.talker ~= nil and (target.components.health == nil or not target.components.health:IsDead()) then
            target.components.talker:Say(GetString(target, "ANNOUNCE_HEALINGSALVE_ACIDBUFF_DONE"))
        end
    end
    inst:Remove()
end

local function buff_Expire(inst)
    if inst.components.debuff ~= nil then
        inst.components.debuff:Stop()
    end
end

local function buff_OnExtended(inst)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
    inst.task = inst:DoTaskInTime(TUNING.HEALINGSALVE_ACIDBUFF_DURATION, buff_Expire)
end

local function buff_OnSave(inst, data)
    if inst.task ~= nil then
        data.remaining = GetTaskRemaining(inst.task)
    end
end

local function buff_OnLoad(inst, data)
    if data == nil then
        return
    end

    if data.remaining then
        if inst.task ~= nil then
            inst.task:Cancel()
            inst.task = nil
        end
        inst.task = inst:DoTaskInTime(data.remaining, buff_Expire)
    end
end

local function fn_acidbuff()
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
    inst.components.debuff:SetAttachedFn(buff_OnAttached)
    inst.components.debuff:SetDetachedFn(buff_OnDetached)
    inst.components.debuff:SetExtendedFn(buff_OnExtended)
    inst.components.debuff.keepondespawn = true

    buff_OnExtended(inst)

    inst.OnSave = buff_OnSave
    inst.OnLoad = buff_OnLoad

    return inst
end

return Prefab("healingsalve", fn, assets),
Prefab("healingsalve_acid", fn_acid, assets_acid),
Prefab("healingsalve_acidbuff", fn_acidbuff)