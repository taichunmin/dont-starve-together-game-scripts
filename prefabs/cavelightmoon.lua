require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/cave_exit_lightsource.zip"),
}

local large_prefabs =
{
    "molebat",
}

local moonlight_params =
{

    day =
    {
        radius = 2,
        intensity = 0.2,
        falloff = 0.9,
        colour = { 10/255, 120/255, 255/255 },
        time = 2,
    },

    dusk =
    {
        radius = 3,
        intensity = 0.5,
        falloff = 0.6,
        colour = { 40/255, 164/255, 255/255 },
        time = 4,
    },

    night =
    {
        radius = 4,
        intensity = 0.7,
        falloff = 0.5,
        colour = { 90/255, 195/255, 255/255 },
        time = 6,
    },

    fullmoon =
    {
        radius = 6,
        intensity = 0.9,
        falloff = 0.3,
        colour = { 120/255, 225/255, 255/255 },
        time = 4,
    },

    off =
    {
        radius = 0,
        intensity = 0,
        falloff = 1,
        colour = { 0, 0, 0 },
        time = 6,
    },
}

-- Generate light phase ID's
-- Add tint to params
local light_phases = {}
for k, v in pairs(moonlight_params) do
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
        local phase_name = inst.widthscale < 0.5 and phase == "day" and "off"
                or phase
        local params = moonlight_params[phase_name]

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

local function OnCavePhase(inst, cavephase)
    local phase_name = (cavephase == "day" and inst.widthscale < 0.5 and "off")
            or (cavephase == "night" and TheWorld.state.iscavefullmoon and "fullmoon")
            or cavephase
    local params = moonlight_params[phase_name]
    if params ~= nil then
        inst._lightphase:set(params.id)
        OnLightPhaseDirty(inst)
    end
end

local function OnCaveFullMoon(inst, fullmoon)
    if fullmoon then
        local params = moonlight_params.fullmoon
        if params ~= nil then
            inst._lightphase:set(params.id)
            OnLightPhaseDirty(inst)
        end
    end
end

local function OnInit(inst)
    if TheWorld.ismastersim then
        inst:WatchWorldState("cavephase", OnCavePhase)
        inst:WatchWorldState("iscavefullmoon", OnCaveFullMoon)

        local phase_name = (TheWorld.state.cavephase == "day" and inst.widthscale < 0.5 and "off")
                or (TheWorld.state.iscavenight and TheWorld.state.isfullmoon and "fullmoon")
                or TheWorld.state.cavephase
        local params = moonlight_params[phase_name]
        if params ~= nil then
            inst._lightphase:set(params.id)
        end
    else
        inst:ListenForEvent("lightphasedirty", OnLightPhaseDirty)
    end

    local phase = light_phases[inst._lightphase:value()]
    if phase ~= nil then
        local params = moonlight_params[phase]
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

local function onvacate(inst, child)
    child.sg:GoToState("fall")
    if inst._player_spawn_target ~= nil and inst._player_spawn_target:IsValid() then
        child.components.combat:SuggestTarget(inst._player_spawn_target)
    end
end

local function on_player_near(inst, player)
    if inst.components.spawner ~= nil and not inst.components.spawner:IsSpawnPending() then
        inst._player_spawn_target = player
        inst.components.spawner:SpawnWithDelay(5 + math.random() * 5)
    end
end

local function OnPreLoad(inst, data)
    WorldSettings_Spawner_PreLoad(inst, data, TUNING.MOLEBAT_ALLY_COOLDOWN * 2)
end

local function common_fn(widthscale, is_spawner)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("cavelight")
    inst.AnimState:SetBuild("cave_exit_lightsource")
    inst.AnimState:PlayAnimation("idle_loop", false) -- the looping is annoying
    inst.AnimState:SetLightOverride(1)

    -- teal effect to fit moon
    inst.AnimState:SetMultColour(0.3, 0.5, 1.0, 1.0)

    inst.Transform:SetScale(2*widthscale, 2, 2*widthscale) -- Art is made small coz of flash weirdness, the giant stage was exporting strangely

    inst:AddTag("daylight")
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("sinkhole")

    inst.Light:EnableClientModulation(true)

    inst.widthscale = widthscale

    inst._endlight = (widthscale > 0.5 and moonlight_params.day) or moonlight_params.off
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

    if is_spawner then
        inst:AddComponent("spawner")
        WorldSettings_Spawner_SpawnDelay(inst, TUNING.MOLEBAT_ALLY_COOLDOWN * 2, TUNING.MOLEBAT_ENABLED)
        inst.components.spawner:Configure("molebat", TUNING.MOLEBAT_ALLY_COOLDOWN * 2)
        inst.components.spawner.onvacate = onvacate
        inst.components.spawner:CancelSpawning()

        inst:AddComponent("playerprox")
        inst.components.playerprox:SetDist(5, 10)
        inst.components.playerprox:SetOnPlayerNear(on_player_near)

        inst.OnPreLoad = OnPreLoad
    end

    return inst
end

local function normalfn()
    return common_fn(0.7, true)
end

local function smallfn()
    return common_fn(0.4)
end

local function tinyfn()
    return common_fn(0.2)
end

return Prefab("cavelightmoon", normalfn, assets, large_prefabs),
       Prefab("cavelightmoon_small", smallfn, assets),
       Prefab("cavelightmoon_tiny", tinyfn, assets)
