
local FADE_FRAMES = 5

local LIGHT_RADIUS = 1
local LIGHT_INTENSITY = .6
local LIGHT_FALLOFF = .65

local function OnUpdateFlicker(inst, starttime)
    local time = (GetTime() - starttime) * 15
    local flicker = math.sin(time * 0.7 + math.sin(time * 6.28)) -- range = [-1 , 1]
    flicker = (1 + flicker) * .5 -- range = 0:1
    inst.Light:SetIntensity(LIGHT_INTENSITY + .05 * flicker)
end

local function OnUpdateFade(inst)
    local k
    if inst._fade:value() <= FADE_FRAMES then
        inst._fade:set_local(math.min(inst._fade:value() + 1, FADE_FRAMES))
        k = inst._fade:value() / FADE_FRAMES
    else
        inst._fade:set_local(math.min(inst._fade:value() + 1, FADE_FRAMES * 2 + 1))
        k = (FADE_FRAMES * 2 + 1 - inst._fade:value()) / FADE_FRAMES
    end

    inst.Light:SetIntensity(LIGHT_INTENSITY * k)
    inst.Light:SetRadius(LIGHT_RADIUS * k)
    inst.Light:SetFalloff(1 - (1 - LIGHT_FALLOFF) * k)

    if TheWorld.ismastersim then
        inst.Light:Enable(inst._fade:value() > 0 and inst._fade:value() <= FADE_FRAMES * 2)
    end

    if inst._fade:value() == FADE_FRAMES or inst._fade:value() > FADE_FRAMES * 2 then
        inst._fadetask:Cancel()
        inst._fadetask = nil
    end

    if inst._fade:value() == FADE_FRAMES then
        if inst._flickertask == nil then
            inst._flickertask = inst:DoPeriodicTask(.1, OnUpdateFlicker, 0, GetTime())
        end
    elseif inst._flickertask ~= nil then
        inst._flickertask:Cancel()
        inst._flickertask = nil
		inst:Remove()
    end
end

local function OnFadeDirty(inst)
    if inst._fadetask == nil then
        inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)
    end
    OnUpdateFade(inst)
end

local function EnableLight(inst, enable, instant)
	if instant then
	    inst._fade:set(FADE_FRAMES)
		OnFadeDirty(inst)
	else
		local fade_val
		if enable then
			fade_val = inst._fade:value() <= FADE_FRAMES and inst._fade:value() or math.max(0, 2 * FRAMES + 1 - inst._fade:value())
		else
			fade_val = inst._fade:value() > FADE_FRAMES and inst._fade:value() or 2 * FADE_FRAMES + 1 - inst._fade:value()
		end
        inst._fade:set(fade_val)

        if inst._fadetask == nil then
            inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)
        end
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.Light:SetFalloff(LIGHT_FALLOFF)
    inst.Light:SetIntensity(LIGHT_INTENSITY)
    inst.Light:SetRadius(LIGHT_RADIUS)
    inst.Light:SetColour(0.3, 0.55, 0.45)
    inst.Light:Enable(false)
    inst.Light:EnableClientModulation(true)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")

	inst.persists = false

    inst._fade = net_smallbyte(inst.GUID, "critterbuff_lunarmoth._fade", "fadedirty")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("fadedirty", OnFadeDirty)

        return inst
    end

	inst.EnableLight = EnableLight
	inst:EnableLight(true)

    return inst
end

return Prefab("critterbuff_lunarmoth", fn)



