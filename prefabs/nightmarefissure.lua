require("worldsettingsutil")

local upperLightColour = { 239/255, 194/255, 194/255 }
local lowerLightColour = { 1, 1, 1 }
local MAX_LIGHT_ON_FRAME = 15
local MAX_LIGHT_OFF_FRAME = 10

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

local function returnchildren(inst)
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

local function spawnchildren(inst)
    if inst.components.childspawner ~= nil then
        inst.components.childspawner:StartSpawning()
        inst.components.childspawner:StopRegen()
    end
end

local function killchildren(inst)
    if inst.components.childspawner ~= nil then
        inst.components.childspawner:StopSpawning()
        inst.components.childspawner:StartRegen()
        returnchildren(inst)
    end
end

local states =
{
    calm = function(inst, instant)
        inst.SoundEmitter:KillSound("loop")

        RemovePhysicsColliders(inst)
        fade_to(inst, 0, instant)

        if instant then
            inst.AnimState:PlayAnimation("idle_closed")
            inst.fx.AnimState:PlayAnimation("idle_closed")
        else
            inst.AnimState:PlayAnimation("close_2")
            inst.AnimState:PushAnimation("idle_closed", false)
            inst.fx.AnimState:PlayAnimation("close_2")
            inst.fx.AnimState:PushAnimation("idle_closed", false)
            inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_fissure_open_warning")
        end

        killchildren(inst)
    end,

    warn = function(inst, instant)
        if not (inst:IsAsleep() or inst.SoundEmitter:PlayingSound("loop")) then
            inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_fissure_open_LP", "loop")
        end

        ChangeToObstaclePhysics(inst)
        fade_to(inst, 2, instant)

        inst.AnimState:PlayAnimation("open_1")
        inst.fx.AnimState:PlayAnimation("open_1")

        if not instant then
            inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_fissure_open_warning")
        end
    end,

    wild = function(inst, instant)
        if not (inst:IsAsleep() or inst.SoundEmitter:PlayingSound("loop")) then
            inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_fissure_open_LP", "loop")
        end

        ChangeToObstaclePhysics(inst)
        fade_to(inst, 5, instant)

        if instant then
            inst.AnimState:PlayAnimation("idle_open")
            inst.fx.AnimState:PlayAnimation("idle_open")
        else
            inst.AnimState:PlayAnimation("open_2")
            inst.AnimState:PushAnimation("idle_open", false)
            inst.fx.AnimState:PlayAnimation("open_2")
            inst.fx.AnimState:PushAnimation("idle_open", false)
            inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_fissure_open")
        end

        spawnchildren(inst)
    end,

    dawn = function(inst, instant)
        if not (inst:IsAsleep() or inst.SoundEmitter:PlayingSound("loop")) then
            inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_fissure_open_LP", "loop")
        end

        ChangeToObstaclePhysics(inst)
        fade_to(inst, 2, instant)

        inst.AnimState:PlayAnimation("close_1")
        inst.fx.AnimState:PlayAnimation("close_1")

        if not instant then
            inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_fissure_open")
        end

        spawnchildren(inst)
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
    inst.SoundEmitter:KillSound("loop")
    if inst._phasetask ~= nil then
        inst._phasetask:Cancel()
        ShowPhaseState(inst, TheWorld.state.nightmarephase, true)
    end
end

local function OnEntityWake(inst)
    if not (TheWorld.state.isnightmarecalm or inst.SoundEmitter:PlayingSound("loop")) then
        inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_fissure_open_LP", "loop")
    end
end

local function OnPreLoad(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.NIGHTMARELIGHT_RELEASE_TIME, TUNING.NIGHTMARELIGHT_REGEN_TIME)
end

local function Make(name, build, lightcolour, fxname, masterinit)
    local assets =
    {
        Asset("ANIM", "anim/"..build..".zip"),
    }

    local prefabs =
    {
        "nightmarebeak",
        "crawlingnightmare",
        fxname,
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddLight()
        inst.entity:AddNetwork()

        MakeObstaclePhysics(inst, 1)
        RemovePhysicsColliders(inst)

        inst.AnimState:SetBuild(build)
        inst.AnimState:SetBank(build)
        inst.AnimState:PlayAnimation("idle_closed")
        inst.AnimState:SetFinalOffset(1) --on top of spawned .fx

        inst.Light:SetRadius(0)
        inst.Light:SetIntensity(.9)
        inst.Light:SetFalloff(.9)
        inst.Light:SetColour(unpack(lightcolour))
        inst.Light:Enable(false)
        inst.Light:EnableClientModulation(true)

        inst._lightframe = net_smallbyte(inst.GUID, "fissure._lightframe", "lightdirty")
        inst._lightradius0 = net_tinybyte(inst.GUID, "fissure._lightradius0", "lightdirty")
        inst._lightradius1 = net_tinybyte(inst.GUID, "fissure._lightradius1", "lightdirty")
        inst._lightmaxframe = MAX_LIGHT_OFF_FRAME
        inst._lightframe:set(inst._lightmaxframe)
        inst._lighttask = nil

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            inst:ListenForEvent("lightdirty", OnLightDirty)

            return inst
        end

        inst.fx = SpawnPrefab(fxname)
        inst.fx.entity:SetParent(inst.entity)

        inst:AddComponent("childspawner")
        inst.components.childspawner:SetRegenPeriod(TUNING.NIGHTMARELIGHT_RELEASE_TIME)
        inst.components.childspawner:SetSpawnPeriod(TUNING.NIGHTMARELIGHT_REGEN_TIME)
        inst.components.childspawner:SetMaxChildren(TUNING.NIGHTMAREFISSURE_MAXCHILDREN)
        WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.NIGHTMARELIGHT_RELEASE_TIME, TUNING.NIGHTMAREFISSURE_ENABLED)
        WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.NIGHTMARELIGHT_REGEN_TIME, TUNING.NIGHTMAREFISSURE_ENABLED)
        if not TUNING.NIGHTMAREFISSURE_ENABLED then
            inst.components.childspawner.childreninside = 0
        end
        inst.components.childspawner.childname = "crawlingnightmare"
        inst.components.childspawner:SetRareChild("nightmarebeak", .35)

        inst:WatchWorldState("nightmarephase", OnNightmarePhaseChanged)
        OnNightmarePhaseChanged(inst, TheWorld.state.nightmarephase, true)

        inst.OnEntityWake = OnEntityWake
        inst.OnEntitySleep = OnEntitySleep

		if masterinit ~= nil then
			masterinit(inst)
		end

        inst.OnPreLoad = OnPreLoad

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

local function grottowar_onchildspawned(inst, child)
	if child.components.knownlocations ~= nil then
		child.components.knownlocations:RememberLocation("war_home", inst.components.knownlocations:GetLocation("war_home"))
	end
end

local function grottowar_masterinit(inst)
	inst:AddComponent("knownlocations")
	inst.components.childspawner:SetSpawnedFn(grottowar_onchildspawned)
end

return Make("fissure", "nightmare_crack_upper", upperLightColour, "upper_nightmarefissurefx"),
    Make("fissure_lower", "nightmare_crack_ruins", lowerLightColour, "nightmarefissurefx"),
    Make("fissure_grottowar", "fissure_grottowar", upperLightColour, "fissure_grottowarfx", grottowar_masterinit)

