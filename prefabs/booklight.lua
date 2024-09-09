local assets =
{
    Asset("ANIM", "anim/cave_exit_lightsource.zip"),
}

local function OnEntityWake(inst)
    inst.SoundEmitter:PlaySound("grotto/common/chandelier_LP", "loop")
end

local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("loop")
end

local function SetDuration(inst, duration)
    inst.duration = duration
    inst.kill_task = inst:DoTaskInTime(duration, inst.Remove)
end

local function FadeOut(inst)
    local radius = 3
    local intensity = 0.85

    inst.AnimState:PlayAnimation("off")

    inst:DoPeriodicTask(21 * FRAMES, function() 
        radius = radius - (3/21)
        intensity = intensity - (0.85/21)
        inst.Light:SetRadius(radius)
        inst.Light:SetIntensity(intensity)
    end)

    --inst:DoTaskInTime(7 * FRAMES, inst.Remove)
end

local function onsave(inst, data)
    local time_remaining = GetTaskRemaining(inst.kill_task)
    data.time_remaining = time_remaining
end

local function onload(inst, data)
    if data and data.time_remaining then
        inst:SetDuration(data.time_remaining)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    
    inst.entity:AddLight()
    inst.Light:SetRadius(3)
    inst.Light:SetFalloff(0.3)
    inst.Light:SetIntensity(0.85)
    inst.Light:EnableClientModulation(true)
    inst.Light:SetColour(180/255, 195/255, 150/255)

    inst.AnimState:SetBank("cavelight")
    inst.AnimState:SetBuild("cave_exit_lightsource")
    inst.AnimState:PlayAnimation("idle_loop", false) -- the looping is annoying
    inst.AnimState:SetLightOverride(1)

    inst.Transform:SetScale(2, 2, 2) -- Art is made small coz of flash weirdness, the giant stage was exporting strangely

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")
    inst:AddTag("daylight")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    inst.OnSave = onsave
    inst.OnLoad = onload

    inst.SetDuration = SetDuration
    inst.FadeOut = FadeOut

    return inst
end

return Prefab("booklight", fn, assets)