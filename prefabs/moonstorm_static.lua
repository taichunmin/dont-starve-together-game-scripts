local assets =
{
    Asset("ANIM", "anim/static_ball_contained.zip"),
}

local prefabs =
{
    "moonstorm_static_item",
}

local item_assets =
{
    Asset("ANIM", "anim/static_ball_contained.zip"),
}

local function onattackedfn(inst)
    if inst.AnimState:IsCurrentAnimation("idle") then
        inst.SoundEmitter:PlaySound("moonstorm/common/static_ball_contained/hit")
        inst.AnimState:PlayAnimation("hit", false)
        inst.AnimState:PushAnimation("idle", true)
    end
end

local function ondeath(inst)
    inst.SoundEmitter:KillSound("loop")
    inst.AnimState:PlayAnimation("explode", false)
    inst.SoundEmitter:PlaySound("moonstorm/common/static_ball_contained/explode")

    inst:ListenForEvent("animover", function()
        inst:Remove()
    end)
end

local function finished(inst)
    inst.SoundEmitter:KillSound("loop")
    inst.AnimState:PlayAnimation("finish", false)
    inst.SoundEmitter:PlaySound("moonstorm/common/static_ball_contained/finish")
    inst.experimentcomplete = true
    inst:ListenForEvent("animover", function()
        local item = SpawnPrefab("moonstorm_static_item")
        item.Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst:Remove()
    end)
end

local function stormstopped(inst)
    inst:DoTaskInTime(1,function()
        if TheWorld.net.components.moonstorms and not TheWorld.net.components.moonstorms:IsInMoonstorm(inst) then
            inst.components.health:Kill()
        end
    end)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .2)

    inst.AnimState:SetBuild("static_ball_contained")
    inst.AnimState:SetBank("static_contained")
    inst.AnimState:PlayAnimation("idle", true)

    inst.DynamicShadow:Enable(true)
    inst.DynamicShadow:SetSize(1, .5)

    inst.Light:SetColour(111/255, 111/255, 227/255)
    inst.Light:SetIntensity(0.75)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetRadius(2)
    inst.Light:Enable(false)

    inst:AddTag("moonstorm_static")

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.persists = false

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    inst.finished = finished

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.MOONSTORM_SPARK_HEALTH)
    inst.components.health.nofadeout = true

    inst:AddComponent("combat")
    inst:ListenForEvent("attacked", onattackedfn)
    inst:ListenForEvent("death", ondeath)

    inst.SoundEmitter:PlaySound("moonstorm/common/static_ball_contained/idle_LP","loop")

    inst:ListenForEvent("ms_stormchanged", function(w, data) print("static:",  data ~= nil and data.stormtype == STORM_TYPES.MOONSTORM) if data ~= nil and data.stormtype == STORM_TYPES.MOONSTORM then stormstopped(inst) end end, TheWorld)

    inst:AddComponent("inspectable")

    return inst
end

local function itemfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("static_contained")
    inst.AnimState:SetBuild("static_ball_contained")
    inst.AnimState:PlayAnimation("finish_idle")

    inst:AddTag("moonstorm_static")

    MakeInventoryFloatable(inst, "med", 0.05, 0.68)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.SoundEmitter:PlaySound("moonstorm/common/static_ball_contained/finished_idle_LP","loop")

    inst:AddComponent("tradable")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPickupFn(function()
        inst.SoundEmitter:KillSound("loop")
    end)
    inst.components.inventoryitem:SetOnDroppedFn(function()
        inst.SoundEmitter:PlaySound("moonstorm/common/static_ball_contained/finished_idle_LP","loop")
    end)

    return inst
end

return Prefab("moonstorm_static", fn, assets, prefabs),
    Prefab("moonstorm_static_item", itemfn, item_assets)
