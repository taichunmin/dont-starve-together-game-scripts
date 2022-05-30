require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/rock_light.zip"),
}

local prefabs =
{
    "nightmarebeak",
    "crawlingnightmare",
    "nightmarelightfx",
}

local MAX_LIGHT_ON_FRAME = 15
local MAX_LIGHT_OFF_FRAME = 30

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
    inst.Light:SetRadius(inst._lightradius1:value() * k + inst._lightradius0:value() * (1 - k))

    if TheWorld.ismastersim then
        inst.Light:Enable(inst._lightradius1:value() > 0 or frame < inst._lightmaxframe)
    end
end

local function OnLightDirty(inst)
    if inst._lighttask == nil then
        inst._lighttask = inst:DoPeriodicTask(FRAMES, OnUpdateLight, nil, 1)
    end
    inst._lightmaxframe = inst._lightradius1:value() > 0 and MAX_LIGHT_ON_FRAME or MAX_LIGHT_OFF_FRAME
    OnUpdateLight(inst, 0)
end

local function fade_to(inst, rad, instant)
    if inst._lightradius1:value() ~= rad then
        local k = inst._lightframe:value() / inst._lightmaxframe
        local radius = inst._lightradius1:value() * k + inst._lightradius0:value() * (1 - k)
        local minradius0 = math.min(inst._lightradius0:value(), inst._lightradius1:value())
        local maxradius0 = math.max(inst._lightradius0:value(), inst._lightradius1:value())
        if radius > rad then
            inst._lightradius0:set(radius > minradius0 and maxradius0 or minradius0)
        else
            inst._lightradius0:set(radius < maxradius0 and minradius0 or maxradius0)
        end
        local maxframe = rad > 0 and MAX_LIGHT_ON_FRAME or MAX_LIGHT_OFF_FRAME
        inst._lightradius1:set(rad)
        inst._lightframe:set(instant and maxframe or math.max(0, math.floor((radius - inst._lightradius0:value()) / (rad - inst._lightradius0:value()) * maxframe + .5)))
        OnLightDirty(inst)
    end
end

local function ReturnChildren(inst)
    for k, child in pairs(inst.components.childspawner.childrenoutside) do
        if child.components.combat ~= nil then
            child.components.combat:SetTarget(nil)
        end

        if child.components.lootdropper ~= nil then
            child.components.lootdropper:SetLoot({})
            child.components.lootdropper:SetChanceLootTable(nil)
        end

        if child.components.health ~= nil then
            child.components.health:Kill()
        end
    end
end

local states =
{
    calm = function(inst, instant)
        inst.SoundEmitter:KillSound("warnLP")
        inst.SoundEmitter:KillSound("nightmareLP")

        inst.components.sanityaura.aura = 0
        fade_to(inst, 0, instant)

        if instant then
            inst.AnimState:PlayAnimation("idle_closed")
            inst.fx.AnimState:PlayAnimation("idle_closed")
        else
            inst.AnimState:PlayAnimation("close_2")
            inst.AnimState:PushAnimation("idle_closed", false)
            inst.fx.AnimState:PlayAnimation("close_2")
            inst.fx.AnimState:PushAnimation("idle_closed", false)
            inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_spawner_close")
        end

        if inst.components.childspawner ~= nil then
            inst.components.childspawner:StopSpawning()
            inst.components.childspawner:StartRegen()
            ReturnChildren(inst)
        end
    end,

    warn = function(inst, instant)
        inst.SoundEmitter:KillSound("nightmareLP")
        if not (inst:IsAsleep() or inst.SoundEmitter:PlayingSound("warnLP")) then
            inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_spawner_warning_LP", "warnLP")
        end

        inst.components.sanityaura.aura = -TUNING.SANITY_SMALL
        fade_to(inst, 3, instant)

        inst.AnimState:PlayAnimation("open_1")
        inst.fx.AnimState:PlayAnimation("open_1")

        if not instant then
            inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_spawner_open_warning")
        end
    end,

    wild = function(inst, instant)
        inst.SoundEmitter:KillSound("warnLP")
        if not (inst:IsAsleep() or inst.SoundEmitter:PlayingSound("nightmareLP")) then
            inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_spawner_open_LP", "nightmareLP")
        end

        inst.components.sanityaura.aura = -TUNING.SANITY_MED
        fade_to(inst, 6, instant)

        if instant then
            inst.AnimState:PlayAnimation("idle_open")
            inst.fx.AnimState:PlayAnimation("idle_open")
        else
            inst.AnimState:PlayAnimation("open_2")
            inst.AnimState:PushAnimation("idle_open", false)
            inst.fx.AnimState:PlayAnimation("open_2")
            inst.fx.AnimState:PushAnimation("idle_open", false)
            inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_spawner_open")
        end

        if inst.components.childspawner ~= nil then
            inst.components.childspawner:StartSpawning()
            inst.components.childspawner:StopRegen()
        end
    end,

    dawn = function(inst, instant)
        inst.SoundEmitter:KillSound("warnLP")
        if not (inst:IsAsleep() or inst.SoundEmitter:PlayingSound("nightmareLP")) then
            inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_spawner_open_LP", "nightmareLP")
        end

        inst.components.sanityaura.aura = -TUNING.SANITY_SMALL
        fade_to(inst, 3, instant)

        inst.AnimState:PlayAnimation("close_1")
        inst.fx.AnimState:PlayAnimation("close_1")
        if not instant then
            inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_spawner_open")
        end

        if inst.components.childspawner ~= nil then
            inst.components.childspawner:StartSpawning()
            inst.components.childspawner:StopRegen()
        end
    end,
}

local function ShowPhaseState(inst, phase, instant)
    inst._phasetask = nil

    local fn = states[phase] or states.calm
    fn(inst, instant)
end

local function OnNightmarePhaseChanged(inst, phase, instant)
    if inst._phasetask ~= nil then
        inst._phasetask:Cancel()
    end
    if instant or inst:IsAsleep() then
        ShowPhaseState(inst, phase, true)
    else
        inst._phasetask = inst:DoTaskInTime(math.random() * 2, ShowPhaseState, phase)
    end
end

local function OnEntitySleep(inst)
    if inst._phasetask ~= nil then
        inst._phasetask:Cancel()
        ShowPhaseState(inst, TheWorld.state.nightmarephase, true)
    end
    inst.SoundEmitter:KillSound("warnLP")
    inst.SoundEmitter:KillSound("nightmareLP")
end

local function OnEntityWake(inst)
    if TheWorld.state.nightmarephase == "warn" then
        if not inst.SoundEmitter:PlayingSound("warnLP") then
            inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_spawner_warning_LP", "warnLP")
        end
    elseif (TheWorld.state.nightmarephase == "wild" or TheWorld.state.nightmarephase == "dawn")
        and not inst.SoundEmitter:PlayingSound("nigtmareLP") then
        inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_spawner_open_LP", "nightmareLP")
    end
end
local function OnPreLoad(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.NIGHTMAREFISSURE_RELEASE_TIME, TUNING.NIGHTMAREFISSURE_REGEN_TIME)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("nightmarelight.png")

    inst.AnimState:SetBuild("rock_light")
    inst.AnimState:SetBank("rock_light")
    inst.AnimState:PlayAnimation("idle_closed",false)
    inst.AnimState:SetFinalOffset(1) --on top of spawned .fx

    inst.Light:SetRadius(0)
    inst.Light:SetIntensity(.9)
    inst.Light:SetFalloff(.9)
    inst.Light:SetColour(1, 1, 1)
    inst.Light:Enable(false)
    inst.Light:EnableClientModulation(true)

    inst._lightframe = net_smallbyte(inst.GUID, "nightmarelight._lightframe", "lightdirty")
    inst._lightradius0 = net_tinybyte(inst.GUID, "nightmarelight._lightradius0", "lightdirty")
    inst._lightradius1 = net_tinybyte(inst.GUID, "nightmarelight._lightradius1", "lightdirty")
    inst._lightmaxframe = MAX_LIGHT_OFF_FRAME
    inst._lightframe:set(inst._lightmaxframe)
    inst._lighttask = nil

    MakeObstaclePhysics(inst, 1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("lightdirty", OnLightDirty)

        return inst
    end

    inst.fx = SpawnPrefab("nightmarelightfx")
    inst.fx.entity:SetParent(inst.entity)

    inst.highlightchildren = { inst.fx }

    inst:AddComponent("sanityaura")

    inst:AddComponent("childspawner")
    inst.components.childspawner:SetRegenPeriod(TUNING.NIGHTMAREFISSURE_RELEASE_TIME)
    inst.components.childspawner:SetSpawnPeriod(TUNING.NIGHTMAREFISSURE_REGEN_TIME)
    inst.components.childspawner:SetMaxChildren(math.random(TUNING.NIGHTMARELIGHT_MINCHILDREN, TUNING.NIGHTMARELIGHT_MAXCHILDREN))
    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.NIGHTMAREFISSURE_RELEASE_TIME, TUNING.NIGHTMARELIGHT_ENABLED)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.NIGHTMAREFISSURE_REGEN_TIME, TUNING.NIGHTMARELIGHT_ENABLED)
    if not TUNING.NIGHTMARELIGHT_ENABLED then
        inst.components.childspawner.childreninside = 0
    end

    inst.components.childspawner.childname = "crawlingnightmare"
    inst.components.childspawner:SetRareChild("nightmarebeak", .35)

    inst:AddComponent("inspectable")

    inst:WatchWorldState("nightmarephase", OnNightmarePhaseChanged)
    OnNightmarePhaseChanged(inst, TheWorld.state.nightmarephase, true)

    inst.OnEntityWake = OnEntityWake
    inst.OnEntitySleep = OnEntitySleep

    inst.OnPreLoad = OnPreLoad

    return inst
end

return Prefab("nightmarelight", fn, assets, prefabs)
