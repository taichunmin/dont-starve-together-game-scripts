local assets =
{
    Asset("ANIM", "anim/sparks.zip"),
}

local function onupdate(inst, dt)
    if inst.sound then
        inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/spark")
        inst.sound = nil
    end

    inst.Light:SetIntensity(inst.i)
    inst.i = inst.i - dt * 2
    if inst.i <= 0 then
        inst:Remove()
    end
end

local function StartFX(proxy, animindex)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    if not TheNet:IsDedicated() then
        inst.entity:AddSoundEmitter()
    end
    inst.entity:AddLight()

    local parent = proxy.entity:GetParent()
    if parent ~= nil then
        inst.entity:SetParent(parent.entity)
    end
    inst.Transform:SetFromProxy(proxy.GUID)

    inst.AnimState:SetBank("sparks")
    inst.AnimState:SetBuild("sparks")
    inst.AnimState:PlayAnimation("sparks_"..tostring(animindex))
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.Light:Enable(true)
    inst.Light:SetRadius(2)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.9)
    inst.Light:SetColour(235 / 255, 121 / 255, 12 / 255)

    local dt = 1 / 20
    inst.i = .9
    inst.sound = inst.SoundEmitter ~= nil
    inst:DoPeriodicTask(dt, onupdate, nil, dt)
end

local function OnRandDirty(inst)
    if inst._complete or inst._rand:value() <= 0 then
        return
    end

    --Delay one frame in case we are about to be removed
    inst:DoTaskInTime(0, StartFX, inst._rand:value())
    inst._complete = true
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Transform:SetScale(2, 2, 2)

    inst._rand = net_tinybyte(inst.GUID, "_rand", "randdirty")
    inst._complete = false
    inst:ListenForEvent("randdirty", OnRandDirty)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:DoTaskInTime(1, inst.Remove)

    inst._rand:set(math.random(3))

    return inst
end

return Prefab("sparks", fn, assets)