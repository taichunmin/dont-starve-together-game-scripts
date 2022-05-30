local function ScreenFlash()
    TheWorld:PushEvent("screenflash", .5)
end

local function PlayThunderSound(proxy, theta, radius)
    local inst = CreateEntity()

    --[[Non-networked entity]]

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:SetParent(TheFocalPoint.entity)

    inst.Transform:SetPosition(radius * math.cos(theta), 0, radius * math.sin(theta))
    inst.SoundEmitter:PlaySound("dontstarve/rain/thunder_close")

    inst:Remove()
end

local function OnRandDirty(inst)
    if inst._complete or inst._rand:value() <= 0 then
        return
    end

    --Delay one frame in case we are about to be removed
    inst:DoTaskInTime(0, PlayThunderSound, inst._rand:value() / 255 * 2 * PI, 10)
    inst._complete = true
end

local function OnInitRand(inst)
    inst._rand:set(math.random(255))
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddNetwork()

    inst:AddTag("FX")

    --Delay one frame in case we are about to be removed
    inst:DoTaskInTime(0, ScreenFlash)

    inst._rand = net_byte(inst.GUID, "_rand", "randdirty")

    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
        inst._complete = false
        inst:ListenForEvent("randdirty", OnRandDirty)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetCanSleep(false)
    inst.persists = false

    local delay = .1 + math.random() * .2
    inst:DoTaskInTime(delay, OnInitRand)
    inst:DoTaskInTime(delay + 1, inst.Remove)

    return inst
end

return Prefab("thunder_close", fn)
