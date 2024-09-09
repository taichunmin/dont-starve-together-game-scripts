require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/bulb_plant_single.zip"),
    Asset("ANIM", "anim/bulb_plant_springy.zip"),
    Asset("SOUND", "sound/common.fsb"),
    Asset("MINIMAP_IMAGE", "bulb_plant"),
}

local prefabs =
{
    "lightflier",
}

local LIGHT_STATES =
{
    ON = "ON", --Light current on.
    CHARGED = "CHARGED", --Light currently off but ready to turn on.
    RECHARGING = "RECHARGING", --Light current off and is unable to turn on.
}

local STATE_ANIMS =
{
    [LIGHT_STATES.ON] = { "recharge", "idle" },
    [LIGHT_STATES.CHARGED] = { "revive", "off" },
    [LIGHT_STATES.RECHARGING] = { "drain", "withered" },
}

local LIGHT_MIN_TIME = 4
local LIGHT_MAX_TIME = 8

local MAX_CHILDREN = 1

local FIND_LIGHTFLIER_DISTANCE = 16

local RECALL_FREQUENCY = 8

local function OnUpdateLight(inst, dframes)
    local frame = inst._lightframe:value() + dframes
    if frame >= inst._lightmaxframe then
        inst._lightframe:set_local(inst._lightmaxframe)
        inst._lighttask:Cancel()
        inst._lighttask = nil
    else
        inst._lightframe:set_local(frame)
    end

    local k = frame / inst._lightmaxframe

    if not inst._islighton:value() then
        --radius:    light_params.radius    -> 0
        --intensity: light_params.intensity -> 0
        --falloff:   light_params.falloff   -> 1
        inst.Light:SetRadius(inst.light_params.radius * (1 - k))
        inst.Light:SetIntensity(inst.light_params.intensity * (1 - k))
        inst.Light:SetFalloff(k + inst.light_params.falloff * (1 - k))
    elseif k < .33 then
        k = k / .33
        --radius:    0 -> light_params.radius * 1.33
        --intensity: 0 -> light_params.intensity
        --falloff:   1 -> light_params.falloff * .8
        inst.Light:SetRadius(inst.light_params.radius * 1.33 * k)
        inst.Light:SetIntensity(inst.light_params.intensity * k)
        inst.Light:SetFalloff(inst.light_params.falloff * .8 * k + 1 - k)
    else
        k = (k - .33) / .67
        --radius:    light_params.radius * 1.33 -> light_params.radius
        --intensity: light_params.intensity     -> light_params.intensity
        --falloff:   light_params.falloff * .8  -> light_params.falloff
        inst.Light:SetRadius(inst.light_params.radius * (k + 1.33 * (1 - k)))
        inst.Light:SetIntensity(inst.light_params.intensity)
        inst.Light:SetFalloff(inst.light_params.falloff * (k + .8 * (1 - k)))
    end

    if TheWorld.ismastersim then
        inst.Light:Enable(inst._islighton:value() or frame < inst._lightmaxframe)
    end
end

local function SpawnLightflierFromStalk(inst)
    local lightflier = SpawnPrefab("lightflier")
    inst.components.childspawner:TakeOwnership(lightflier)

    lightflier.Transform:SetPosition(inst:GetPosition():Get())
    lightflier:PushEvent("startled")

    inst.components.childspawner.childreninside = math.max(inst.components.childspawner.childreninside - 1, 0)
end

local function OnLightDirty(inst)
    if inst._lighttask == nil then
        inst._lighttask = inst:DoPeriodicTask(FRAMES, OnUpdateLight, nil, 1)
    end
    inst._lightmaxframe = math.floor((inst._lighttime:value() + LIGHT_MIN_TIME) / FRAMES + .5)
    OnUpdateLight(inst, 0)
end

local function EndLight(inst)
    inst._lightframe:set(inst._lightmaxframe)
    OnLightDirty(inst)
end

local function SetLightState(inst, state)
    inst.AnimState:PlayAnimation(STATE_ANIMS[state][1])
    for i=2,#STATE_ANIMS[state] do
        inst.AnimState:PushAnimation(STATE_ANIMS[state][i], STATE_ANIMS[state][i] == "idle")
    end
    inst.light_state = state
end

local function CanTurnOn(inst)
    return inst.light_state == LIGHT_STATES.CHARGED -- and not inst.components.pickable.picked
end

local function ForceOff(inst)
    if inst.light_state == LIGHT_STATES.ON then
        inst:SetLightState(LIGHT_STATES.RECHARGING)
    end
    inst._islighton:set(false)
    EndLight(inst)
end

local function ForceOn(inst)
    if not inst.components.pickable:CanBePicked() then
        return
    end

    inst:SetLightState(LIGHT_STATES.ON)
    inst._islighton:set(true)
    EndLight(inst)
end

local function TurnOff(inst)
    --Light turns off and starts to charge.
    local tween_time = math.random(LIGHT_MIN_TIME, LIGHT_MAX_TIME)
    inst.components.timer:StartTimer("recharge", TUNING.LIGHTFLIER_FLOWER_RECHARGE_TIME + tween_time)
    inst:SetLightState(LIGHT_STATES.RECHARGING)
    inst._islighton:set(false)
    inst._lightframe:set(0)
    inst._lighttime:set(tween_time - LIGHT_MIN_TIME)
    OnLightDirty(inst)
end

local function TurnOn(inst)
    if not inst.components.pickable:CanBePicked() then
        return
    end

    --Turns on and starts to decharge
    if not inst:CanTurnOn() then return end

    inst:SetLightState(LIGHT_STATES.ON)

    local tween_time = math.random(LIGHT_MIN_TIME, LIGHT_MAX_TIME)
    inst._islighton:set(true)
    inst._lightframe:set(0)
    inst._lighttime:set(tween_time - LIGHT_MIN_TIME)
    OnLightDirty(inst)

    if not inst.components.timer:TimerExists("turnoff") then
        inst.components.timer:StartTimer("turnoff", TUNING.LIGHTFLIER_FLOWER_LIGHT_TIME + tween_time + (math.random() * TUNING.LIGHTFLIER_FLOWER_LIGHT_TIME_VARIANCE))
    end
end

local function Recharge(inst)
    --Light is finished charging and can turn on again.
    inst:SetLightState(LIGHT_STATES.CHARGED)
    if inst:IsInLight() then
        TurnOn(inst)
    end
end

local function CancelCallForLightflierTask(inst)
    if inst._call_for_lightflier_task ~= nil then
        inst._call_for_lightflier_task:Cancel()
        inst._call_for_lightflier_task = nil
    end
end

local function makefullfn(inst)
    CancelCallForLightflierTask(inst)

    inst.AnimState:PlayAnimation("grow")
    inst.AnimState:PushAnimation("idle", true)

    ForceOn(inst)
    inst.components.timer:StopTimer("recharge")
    inst.components.timer:StopTimer("turnoff")
    local tween_time = math.random(LIGHT_MIN_TIME, LIGHT_MAX_TIME)
    inst.components.timer:StartTimer("turnoff", TUNING.LIGHTFLIER_FLOWER_RECHARGE_TIME + tween_time)
end

local function CallForLightflier(inst)
    if inst.components.pickable:CanBePicked() or inst.components.childspawner.numchildrenoutside < TUNING.LIGHTFLIER_FLOWER_TARGET_NUM_CHILDREN_OUTSIDE then
        CancelCallForLightflierTask(inst)
        return
    end

    if inst._lightflier_returning_home ~= nil and inst._lightflier_returning_home:IsValid() and not inst._lightflier_returning_home.components.formationfollower.active then
        return
    end

    for k, v in pairs(inst.components.childspawner.childrenoutside) do
        if not v.components.formationfollower.active then
            inst._lightflier_returning_home = v
            return
        end
    end

    inst._lightflier_returning_home = nil
end

local function StartCallForLightflierTask(inst)
    CancelCallForLightflierTask(inst)
    inst._call_for_lightflier_task = inst:DoPeriodicTask(RECALL_FREQUENCY, CallForLightflier, TUNING.LIGHTFLIER_FLOWER_RECALL_DELAY + math.random() * TUNING.LIGHTFLIER_FLOWER_RECALL_DELAY_VARIANCE)
end

local function ontimerdone(inst, data)
    if data.name == "recharge" then
        Recharge(inst)
    elseif data.name == "turnoff" then
        TurnOff(inst)
        if inst.components.pickable:CanBePicked() then
            inst.components.pickable:Pick()
        end
    end
end

local function enterlight(inst)
    TurnOn(inst)
end

local function onregenfn(inst)
    TurnOff(inst) -- starts recharging

    inst.AnimState:PlayAnimation("grow")
    inst.AnimState:PushAnimation("idle", true)
end

local function onpickedfn(inst, picker, loot)
    SpawnLightflierFromStalk(inst)

    ForceOff(inst)
    inst.components.timer:StopTimer("turnoff")
    inst.components.timer:StopTimer("recharge")

    if picker ~= nil then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_lightbulb")
    end
    inst.AnimState:PlayAnimation("picking")

    if inst.components.pickable:IsBarren() then
        inst.AnimState:PushAnimation("idle_dead")
    else
        inst.AnimState:PushAnimation("picked")
    end

    inst.components.pickable:Pause() -- Do not re-grow until the population is lower than max
    StartCallForLightflierTask(inst)
end

local function makeemptyfn(inst)
    ForceOff(inst)
    inst.components.timer:StopTimer("turnoff")
    inst.components.timer:StopTimer("recharge")

    inst.AnimState:PlayAnimation("picked")
end

local function OnChildKilled(inst, child)
    -- Also called when fly is caught
    inst.components.pickable:Resume()
end

local function OnGoHome(inst, child)
    if not inst.components.pickable:CanBePicked() then
        inst.components.pickable:Regen()
    end
    ForceOn(inst)
end

local function OnIgnite(inst)
    TurnOff(inst)
    if inst.components.pickable:CanBePicked() then
        inst.components.pickable:Pick()
    else
        if inst.AnimState:IsCurrentAnimation("picking") then
            inst.AnimState:PushAnimation("picked")
        else
            inst.AnimState:PlayAnimation("picked")
        end
    end
end

local function OnSave(inst, data)
    data.light_state = inst.light_state
end

local function OnLoad(inst, data)
    if data == nil then return end

    inst.light_state = data.light_state

    if inst.components.pickable:CanBePicked() then
        if inst.light_state == LIGHT_STATES.ON then
            ForceOn(inst)
        elseif inst.light_state == LIGHT_STATES.CHARGED
            or inst.light_state == LIGHT_STATES.RECHARGING then
            ForceOff(inst)
        end
    else
        ForceOff(inst)
    end
end

local function OnLoadPostPass(inst, ents, data)
    if not inst.components.pickable:CanBePicked()
        and inst.components.childspawner.numchildrenoutside >= TUNING.LIGHTFLIER_FLOWER_TARGET_NUM_CHILDREN_OUTSIDE then

        StartCallForLightflierTask(inst)
    end
end

local function TurnOnInLight(inst)
    if inst:IsInLight() then
        TurnOn(inst)
    end
end

local function OnWake(inst)
    -- lightwatcher initializes to "in light", so wait a frame (or a few, apparently)
    inst:DoTaskInTime(1, TurnOnInLight)
end

local function GetDebugString(inst)
    return string.format("State: %s", inst.light_state)
end

local function commonfn(bank, build, light_params)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddLightWatcher()
    inst.entity:AddNetwork()

    inst:AddTag("plant")
    inst:AddTag("lightflier_home")

    inst.LightWatcher:SetLightThresh(.075)
    inst.LightWatcher:SetDarkThresh(.05)

    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(0)
    inst.Light:SetRadius(0)
    inst.Light:SetColour(237/255, 237/255, 209/255)
    inst.Light:Enable(false)
    inst.Light:EnableClientModulation(true)

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("off")

    inst.MiniMapEntity:SetIcon("bulb_plant.png")

    inst.light_params = light_params
    inst._lighttime = net_tinybyte(inst.GUID, "flower_cave._lighttime", "lightdirty")
    inst._lightframe = net_byte(inst.GUID, "flower_cave._lightframe", "lightdirty")
    inst._islighton = net_bool(inst.GUID, "flower_cave._islighton", "lightdirty")
    inst._lightmaxframe = math.floor(LIGHT_MIN_TIME / FRAMES + .5)
    inst._lightframe:set(inst._lightmaxframe)
    inst._lighttask = nil

    inst:SetPrefabNameOverride("flower_cave")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("lightdirty", OnLightDirty)

        return inst
    end

    -- inst._lightflier_returning_home = nil
    -- inst._call_for_lightflier_task = nil

    inst.light_state = LIGHT_STATES.CHARGED

    local color = 0.75 + math.random() * 0.25
    inst.AnimState:SetMultColour(color, color, color, 1)

    inst:AddComponent("timer")

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/pickup_reeds"
    inst.components.pickable.onregenfn = onregenfn
    inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.makeemptyfn = makeemptyfn
    inst.components.pickable.makefullfn = makefullfn

    inst:AddComponent("lootdropper")
    inst:AddComponent("inspectable")

    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "lightflier"
    inst.components.childspawner:SetMaxChildren(MAX_CHILDREN)
    inst.components.childspawner:SetOnChildKilledFn(OnChildKilled)
    inst.components.childspawner:SetGoHomeFn(OnGoHome)

    ---------------------
    MakeMediumBurnable(inst)
    AddToRegrowthManager(inst)
    MakeSmallPropagator(inst)
    ---------------------

    inst.CanTurnOn = CanTurnOn
    inst.SetLightState = SetLightState

    inst.TurnOn = TurnOn

    inst:ListenForEvent("timerdone", ontimerdone)
    inst:ListenForEvent("enterlight", enterlight)

    -- inst:ListenForEvent("picked", onpicked)

    inst:ListenForEvent("onignite", OnIgnite)

    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass
    inst.OnSave = OnSave
    inst.OnEntityWake = OnWake
    inst.debugstringfn = GetDebugString

    MakeHauntableIgnite(inst)

    return inst
end

local plantnames = { "_single", "_springy" }

local function onsave_single(inst, data)
    OnSave(inst, data)
    data.plantname = inst.plantname
end

local function onload_single(inst,data)
    OnLoad(inst, data)
    if data ~= nil and data.plantname ~= nil then
        inst.plantname = data.plantname
        inst.AnimState:SetBank("bulb_plant"..inst.plantname)
        inst.AnimState:SetBuild("bulb_plant"..inst.plantname)
    end
end

local lightparams_single =
{
    falloff = .5,
    intensity = .8,
    radius = 3,
}

local function OnPreLoad(inst, data)
    WorldSettings_Pickable_PreLoad(inst, data, TUNING.LIGHTFLIER_FLOWER_REGROW_TIME)
end

local function single()
    local inst = commonfn("bulb_plant_single", "bulb_plant_single", lightparams_single)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.plantname = plantnames[math.random(1, #plantnames)]
    inst.AnimState:SetBank("bulb_plant"..inst.plantname)
    inst.AnimState:SetBuild("bulb_plant"..inst.plantname)
    WorldSettings_Pickable_RegenTime(inst, TUNING.LIGHTFLIER_FLOWER_REGROW_TIME, TUNING.LIGHTFLIER_FLOWER_PICKABLE)
    inst.components.pickable:SetUp(nil, TUNING.LIGHTFLIER_FLOWER_REGROW_TIME)
    inst.components.pickable.canbepicked = TUNING.LIGHTFLIER_FLOWER_PICKABLE

    inst.OnSave = onsave_single
    inst.OnLoad = onload_single

    inst.OnPreLoad = OnPreLoad

    return inst
end

return Prefab("lightflier_flower", single, assets, prefabs)
