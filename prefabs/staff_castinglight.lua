local function OnUpdate(inst)
    inst._value:set_local(inst._value:value() + 1)

    if inst._value:value() < inst._duration:value() then
        local k = inst._value:value() / inst._duration:value()
        k = k * k * k * k * k
		if inst.is_small then
			inst.Light:SetRadius(.3 + 4 * k)
			inst.Light:SetIntensity(.8 - .7 * k)
			inst.Light:SetFalloff(1.1 + .3 * k)
		else
			inst.Light:SetRadius(.3 + 10 * k)
			inst.Light:SetIntensity(.8 -.6 * k)
			inst.Light:SetFalloff(.9 -.4 * k)
		end
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

local function common_fn(is_small)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
	inst.is_small = is_small

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

local function fn()
	return common_fn(false)
end

local function small_fn()
	return common_fn(true)
end

return Prefab("staff_castinglight", fn),
		Prefab("staff_castinglight_small", small_fn)
