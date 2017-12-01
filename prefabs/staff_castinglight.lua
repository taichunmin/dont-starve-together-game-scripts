local function OnUpdate(inst)
    inst._value:set_local(inst._value:value() + 1)

    if inst._value:value() < inst._duration:value() then
        local k = inst._value:value() / inst._duration:value()
        k = k * k * k * k * k
        inst.Light:SetRadius(.3 + 10 * k)
        inst.Light:SetIntensity(.8 -.6 * k)
        inst.Light:SetFalloff(.9 -.4 * k)
    else
        inst.Light:Enable(false) -- yea do this on client anyway
        inst.task:Cancel()
        inst.task = nil
        if TheWorld.ismastersim then
            inst:DoTaskInTime(2 * FRAMES, inst.Remove)
        end
    end
end

local function OnSetUpDirty(inst)
    inst.task = inst:DoPeriodicTask(FRAMES, OnUpdate)
    OnUpdate(inst)
end

local function SetUp(inst, colour, duration, delay)
    inst.Light:SetColour(colour[1], colour[2], colour[3], 1)
    inst.Light:EnableClientModulation(true)
    inst._duration:set(math.floor(duration / FRAMES + .5))
    inst.task = inst:DoPeriodicTask(FRAMES, OnUpdate, delay or 0)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetRadius(.3)
    inst.Light:SetIntensity(.8)
    inst.Light:SetFalloff(.9)

    inst._duration = net_smallbyte(inst.GUID, "staff_castinglight._duration", "setupdirty")
    inst._value = net_smallbyte(inst.GUID, "staff_castinglight._value")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("setupdirty", OnSetUpDirty)

        return inst
    end

    inst.SetUp = SetUp

    inst.persists = false

    return inst
end

return Prefab("staff_castinglight", fn)
