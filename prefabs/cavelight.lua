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

local light_params =
{
    day =
    {
        radius = 5,
        intensity = .85,
        falloff = .3,
        colour = { 180/255, 195/255, 150/255 },
        time = 2,
    },

    dusk =
    {
        radius = 5,
        intensity = .6,
        falloff = .6,
        colour = { 91/255, 164/255, 255/255 },
        time = 4,
    },

    night =
    {
        radius = 0,
        intensity = 0,
        falloff = 1,
        colour = { 0, 0, 0 },
        time = 6,
    },

    fullmoon =
    {
        radius = 5,
        intensity = .6,
        falloff = .6,
        colour = { 131/255, 194/255, 255/255 },
        time = 4,
    },
}

-- Generate light phase ID's
-- Add tint to params
local light_phases = {}
for k, v in pairs(light_params) do
    table.insert(light_phases, k)
    v.id = #light_phases
    v.tint = { v.colour[1] * .5, v.colour[2] * .5, v.colour[3] * .5, 0--[[ alpha, zero for additive blending ]] }
end

local function pushparams(inst, params)
    inst.Light:SetRadius(params.radius * inst.widthscale)
    inst.Light:SetIntensity(params.intensity)
    inst.Light:SetFalloff(params.falloff)
    inst.Light:SetColour(unpack(params.colour))
    inst.AnimState:OverrideMultColour(unpack(params.tint))
    if TheWorld.ismastersim then
        if params.intensity > 0 then
            inst.Light:Enable(true)
            inst:Show()
        else
            inst.Light:Enable(false)
            inst:Hide()
        end
    end
end

-- Not using deepcopy because we want to copy in place
local function copyparams(dest, src)
    for k, v in pairs(src) do
        if type(v) == "table" then
            dest[k] = dest[k] or {}
            copyparams(dest[k], v)
        else
            dest[k] = v
        end
    end
end

local function lerpparams(pout, pstart, pend, lerpk)
    for k, v in pairs(pend) do
        if type(v) == "table" then
            lerpparams(pout[k], pstart[k], v, lerpk)
        else
            pout[k] = pstart[k] * (1 - lerpk) + v * lerpk
        end
    end
end

local function OnUpdateLight(inst, dt)
    inst._currentlight.time = inst._currentlight.time + dt
    if inst._currentlight.time >= inst._endlight.time then
        inst._currentlight.time = inst._endlight.time
        inst._lighttask:Cancel()
        inst._lighttask = nil
    end
    lerpparams(inst._currentlight, inst._startlight, inst._endlight, inst._endlight.time > 0 and inst._currentlight.time / inst._endlight.time or 1)
    pushparams(inst, inst._currentlight)
end

local function OnLightPhaseDirty(inst)
    local phase = light_phases[inst._lightphase:value()]
    if phase ~= nil then
        local params = light_params[phase]
        if params ~= nil and params ~= inst._endlight then
            copyparams(inst._startlight, inst._currentlight)
            inst._currentlight.time = 0
            inst._startlight.time = 0
            inst._endlight = params
            if inst._lighttask == nil then
                inst._lighttask = inst:DoPeriodicTask(FRAMES, OnUpdateLight, nil, FRAMES)
            end
        end
    end
end

local function OnSpawnTask(inst, cavephase)
    inst._spawntask = nil
    if cavephase == "day" then
        inst.components.hideout:StartSpawning()
    else
        inst.components.hideout:StopSpawning()
    end
end

local function OnCavePhase(inst, cavephase)
    local params = light_params[cavephase == "night" and TheWorld.state.isfullmoon and "fullmoon" or cavephase]
    if params ~= nil then
        inst._lightphase:set(params.id)
        OnLightPhaseDirty(inst)
        if inst._spawntask ~= nil then
            inst._spawntask:Cancel()
        end
        inst._spawntask = inst:DoTaskInTime(params.time, OnSpawnTask, cavephase)
    end
end

local function OnInit(inst)
    if TheWorld.ismastersim then
        inst:WatchWorldState("cavephase", OnCavePhase)
        local params = light_params[TheWorld.state.iscavenight and TheWorld.state.isfullmoon and "fullmoon" or TheWorld.state.cavephase]
        if params ~= nil then
            inst._lightphase:set(params.id)
        end
        if inst._lightphase:value() == light_params.day.id then
            inst.components.hideout:StartSpawning()
        else
            inst.components.hideout:StopSpawning()
        end
    else
        inst:ListenForEvent("lightphasedirty", OnLightPhaseDirty)
    end

    local phase = light_phases[inst._lightphase:value()]
    if phase ~= nil then
        local params = light_params[phase]
        if params ~= nil and params ~= inst._endlight then
            copyparams(inst._currentlight, params)
            inst._endlight = params
            if inst._lighttask ~= nil then
                inst._lighttask:Cancel()
                inst._lighttask = nil
            end
            pushparams(inst, inst._currentlight)
        end
    end
end

local function onspawned(inst, child)
    child:PushEvent("fly_back")
end

local function common_fn(widthscale)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("cavelight")
    inst.AnimState:SetBuild("cave_exit_lightsource")
    inst.AnimState:PlayAnimation("idle_loop", false) -- the looping is annoying
    inst.AnimState:SetLightOverride(1)

    inst.Transform:SetScale(2*widthscale, 2, 2*widthscale) -- Art is made small coz of flash weirdness, the giant stage was exporting strangely

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")
    inst:AddTag("daylight")
    inst:AddTag("sinkhole")
    inst:AddTag("batdestination")

    inst.Light:EnableClientModulation(true)

    inst.widthscale = widthscale
    inst._endlight = light_params.day
    inst._startlight = {}
    inst._currentlight = {}
    copyparams(inst._startlight, inst._endlight)
    copyparams(inst._currentlight, inst._endlight)
    pushparams(inst, inst._currentlight)

    inst._lightphase = net_tinybyte(inst.GUID, "cavelight._lightphase", "lightphasedirty")
    inst._lightphase:set(inst._currentlight.id)
    inst._lighttask = nil

    inst:DoTaskInTime(0, OnInit)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._spawntask = nil

    inst:AddComponent("hideout")
    inst.components.hideout:SetSpawnPeriod(5,4)
    inst.components.hideout:SetSpawnedFn(onspawned)
    inst.components.hideout:StopSpawning()

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    return inst
end

local function normalfn()
    return common_fn(1)
end

local function smallfn()
    return common_fn(.5)
end

local function tinyfn()
    return common_fn(.2)
end

local function atriumfn()
    return common_fn(.6)
end

return Prefab("cavelight", normalfn, assets),
       Prefab("cavelight_small", smallfn, assets),
       Prefab("cavelight_tiny", tinyfn, assets),
       Prefab("cavelight_atrium", atriumfn, assets)
