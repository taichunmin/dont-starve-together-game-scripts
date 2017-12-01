local PULSE_SYNC_PERIOD = 30

--Needs to save/load time alive.

local function pulse_light(inst)
    local timealive = inst:GetTimeAlive()

    if inst._ismastersim then
        if inst._pulsetime:value() < 0 then
            inst._pulsetime:set_local(-timealive)
        elseif timealive - inst._lastpulsesync > PULSE_SYNC_PERIOD then
            inst._pulsetime:set(timealive)
            inst._lastpulsesync = timealive
        else
            inst._pulsetime:set_local(timealive)
        end

        inst.Light:Enable(true)
    end

    --Client light modulation is enabled:

    --local s = GetSineVal(0.05, true, inst)
    local s = math.abs(math.sin(PI * (timealive + inst._pulseoffs) * 0.05))
    local k = inst._fadek * inst._fadek
    local rad = Lerp(4, 5, s) * k
    local intentsity = Lerp(0.8, 0.7, s) * k
    local falloff = Lerp(0.8, 0.7, s) * k
    inst.Light:SetFalloff(falloff)
    inst.Light:SetIntensity(intentsity)
    inst.Light:SetRadius(rad)

    if inst._fadek <= 0 then
        inst._task:Cancel()
        inst._task = nil
        if inst._ismastersim then
            inst:DoTaskInTime(1, inst.Remove) --delayed remove for network
        end
    elseif inst._fadek < 1 then
        inst._fadek = math.max(0, inst._fadek - FRAMES)
    end
end

local function kill_light(inst)
    if inst._pulsetime:value() >= 0 then
        inst._pulsetime:set(-inst:GetTimeAlive())
        if inst._fadek >= 1 then
            inst._fadek = 1 - FRAMES
            inst._task:Cancel()
            inst._task = inst:DoPeriodicTask(FRAMES, pulse_light, 0)
        end
    end
end

local function onpulsetimedirty(inst)
    if inst._pulsetime:value() >= 0 then
        inst._pulseoffs = inst._pulsetime:value() - inst:GetTimeAlive()
    else
        inst._pulseoffs = -inst._pulsetime:value() - inst:GetTimeAlive()
        if inst._fadek >= 1 then
            inst._fadek = 1 - FRAMES
            inst._task:Cancel()
            inst._task = inst:DoPeriodicTask(FRAMES, pulse_light, 0)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")
    inst:AddTag("spawnlight")

    inst.Light:SetColour(223 / 255, 208 / 255, 69 / 255)
    inst.Light:Enable(false)
    inst.Light:EnableClientModulation(true)

    MakeInventoryPhysics(inst)

    inst._ismastersim = TheWorld.ismastersim
    inst._pulseoffs = 0
    inst._fadek = 1
    inst._pulsetime = net_float(inst.GUID, "_pulsetime", "pulsetimedirty")

    inst._task = inst:DoPeriodicTask(.1, pulse_light)

    inst.entity:SetPristine()

    if not inst._ismastersim then
        inst:ListenForEvent("pulsetimedirty", onpulsetimedirty)
        return inst
    end

    inst._pulsetime:set(inst:GetTimeAlive())
    inst._lastpulsesync = inst._pulsetime:value()

    --Watch "cycles" because it is valid to make a world with no "night" phase
    inst:WatchWorldState("cycles", kill_light)

    inst.persists = false

    return inst
end

return Prefab("spawnlight_multiplayer", fn)