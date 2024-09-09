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
            child.components.health:SetPercent(0)
        end
    end
end

local function spawnchildren(inst)
    if inst._nofissurechildren then
        return
    end

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

local function OnAnimOverControlled(inst)
    if inst.AnimState:IsCurrentAnimation("idle_open_rift") then
        inst:RemoveEventCallback("animover", OnAnimOverControlled)
        local shadowthrallmanager = TheWorld.components.shadowthrallmanager
        if shadowthrallmanager then
            shadowthrallmanager:OnFissureAnimationsFinished(inst)
        end
    end
end

local function DisableTempFissure(inst)
	if inst.persists then
		inst.persists = false
		inst.OnEntityWake = nil
		inst.OnEntitySleep = nil
		inst:StopWatchingWorldState("nightmarephase", inst.OnNightmarePhaseChanged)
		local shadowthrallmanager = TheWorld.components.shadowthrallmanager
		if shadowthrallmanager then
			shadowthrallmanager:UnregisterFissure(inst)
		end
	end
end

local states =
{
    calm = function(inst, instant, oldstate)
        inst.SoundEmitter:KillSound("loop")

        RemovePhysicsColliders(inst)
        fade_to(inst, 0, instant)

        if instant then
            inst.AnimState:PlayAnimation("idle_closed")
            inst.fx.AnimState:PlayAnimation("idle_closed")
        elseif oldstate == "controlled" then -- From wild state animation.
            -- dawn
            inst.AnimState:PushAnimation("close_1")
            inst.fx.AnimState:PushAnimation("close_1")
            -- calm
            inst.AnimState:PushAnimation("close_2")
            inst.AnimState:PushAnimation("idle_closed", false)
            inst.fx.AnimState:PushAnimation("close_2")
            inst.fx.AnimState:PushAnimation("idle_closed", false)
            inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_fissure_open_warning")
        else
            inst.AnimState:PlayAnimation("close_2")
            inst.AnimState:PushAnimation("idle_closed", false)
            inst.fx.AnimState:PlayAnimation("close_2")
            inst.fx.AnimState:PushAnimation("idle_closed", false)
            inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_fissure_open_warning")
        end

        killchildren(inst)
    end,

    warn = function(inst, instant, oldstate)
        if not (inst:IsAsleep() or inst.SoundEmitter:PlayingSound("loop")) then
            inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_fissure_open_LP", "loop")
        end

        ChangeToObstaclePhysics(inst)
        fade_to(inst, 2, instant)

        if oldstate == "controlled" then -- From wild state animation.
            inst.AnimState:PushAnimation("open_1", false)
            inst.fx.AnimState:PushAnimation("open_1", false)
        else
            inst.AnimState:PlayAnimation("open_1")
            inst.fx.AnimState:PlayAnimation("open_1")
        end


        if not instant then
            inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_fissure_open_warning")
        end
    end,

    wild = function(inst, instant, oldstate)
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

    dawn = function(inst, instant, oldstate)
        if not (inst:IsAsleep() or inst.SoundEmitter:PlayingSound("loop")) then
            inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_fissure_open_LP", "loop")
        end

        ChangeToObstaclePhysics(inst)
        fade_to(inst, 2, instant)

        if oldstate == "controlled" then -- From wild state animation.
            inst.AnimState:PushAnimation("close_1", false)
            inst.fx.AnimState:PushAnimation("close_1", false)
        else
            inst.AnimState:PlayAnimation("close_1")
            inst.fx.AnimState:PlayAnimation("close_1")
        end

        if not instant then
            inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_fissure_open")
        end

        spawnchildren(inst)
    end,

    controlled = function(inst, instant, oldstate)
        -- This state assumes instant is from a loading state.
        if oldstate == "controlled" then
            return
        end

        if not (inst:IsAsleep() or inst.SoundEmitter:PlayingSound("loop")) then
            inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_fissure_open_LP", "loop")
        end

        ChangeToObstaclePhysics(inst)
        fade_to(inst, 3, false)
        inst.Light:SetColour(1, 0.3, 0.15)

        inst.fx.AnimState:SetMultColour(1, 0.7, 0.7, 1)
        
        inst.AnimState:SetBank("nightmare_crack_upper")
        inst.AnimState:SetBuild("nightmare_crack_upper")
        inst.AnimState:HideSymbol("stack_under")
        inst.AnimState:HideSymbol("stack_over")
        inst.AnimState:HideSymbol("stack_red")

        if instant then
            inst.AnimState:PlayAnimation("idle_open_rift", true)
            inst.fx.AnimState:PlayAnimation("open_2", false) -- open_2 intentional
        else
            -- These animation selections were simplified down from the state changes.
            if oldstate == "calm" then
                inst.AnimState:PushAnimation("open_1", false)
                inst.fx.AnimState:PushAnimation("open_1", false)
            end
            if oldstate ~= "wild" then
                inst.AnimState:PushAnimation("open_2", false)
                inst.AnimState:PushAnimation("idle_open", false)
                inst.fx.AnimState:PushAnimation("open_2", false)
                inst.fx.AnimState:PushAnimation("idle_open", false)
            end

            inst.AnimState:PushAnimation("idle_open_rift", true)
            --inst.fx.AnimState:PushAnimation("idle_open_rift", true) This animation does not exist we will use the old playing open_2 instead.

            inst:ListenForEvent("animover", OnAnimOverControlled)
        end

		inst.AnimState:SetSymbolLightOverride("crack01", .5)
		inst.AnimState:SetSymbolLightOverride("fx_beam", 1)
		inst.AnimState:SetSymbolLightOverride("fx_spiral", 1)
		inst.AnimState:SetSymbolLightOverride("stack_red", 1)

        killchildren(inst)
    end,
}

local function ShowPhaseState(inst, phase, instant)
    inst._phasetask = nil

    local fn = states[phase] or states.calm
    fn(inst, instant, inst._oldfissurestate)
    inst._oldfissurestate = phase
end

local function OnNightmarePhaseChanged(inst, phase, instant)
    local shadowthrallmanager = TheWorld.components.shadowthrallmanager
    if shadowthrallmanager and shadowthrallmanager:GetControlledFissure() == inst then
        -- Force phase to controlled if it is being controlled and do not play any animations.
        phase = "controlled"
        instant = true
        inst._nofissurechildren = true
    else
		if inst.temp and phase ~= "controlled" then
			phase = "calm"
		end
        inst._nofissurechildren = nil
    end

    if inst._phasetask ~= nil then
        inst._phasetask:Cancel()
    end
    if instant or inst:IsAsleep() then
        ShowPhaseState(inst, phase, true)
    else
        inst._phasetask = inst:DoTaskInTime(math.random() * 2, ShowPhaseState, phase)
    end
end

local AllowShadowThralls = {
    fissure = true,
    fissure_lower = true,
}

local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("loop")
    if inst._phasetask ~= nil then
        inst._phasetask:Cancel()
		ShowPhaseState(inst, inst.temp and "calm" or TheWorld.state.nightmarephase, true)
    end
    if AllowShadowThralls[inst.prefab] then
        local shadowthrallmanager = TheWorld.components.shadowthrallmanager
        if shadowthrallmanager then
            shadowthrallmanager:UnregisterFissure(inst)
        end
    end
end

local function OnEntityWake(inst)
    if not (TheWorld.state.isnightmarecalm or inst.SoundEmitter:PlayingSound("loop")) then
        inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_fissure_open_LP", "loop")
    end
    if AllowShadowThralls[inst.prefab] then
        local shadowthrallmanager = TheWorld.components.shadowthrallmanager
        if shadowthrallmanager then
            shadowthrallmanager:RegisterFissure(inst)
        end
    end
end

local function OnPreLoad(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.NIGHTMARELIGHT_RELEASE_TIME, TUNING.NIGHTMARELIGHT_REGEN_TIME)
	if data ~= nil and data.temp then
		inst:MakeTempFissure()
	end
end

local function OnSave(inst, data)
	data.temp = inst.temp
end

local function OnFissureMinedFinished(inst, worker)
    if inst.components.inspectable then
        inst:RemoveComponent("inspectable")
    end
    inst:SetPrefabNameOverride(nil)
    inst.AnimState:HideSymbol("stack_under")
    inst.AnimState:HideSymbol("stack_over")
    inst.AnimState:HideSymbol("stack_red")
    local pt = inst:GetPosition()
    for i = 1, 3 do
        inst.components.lootdropper:SpawnLootPrefab("dreadstone", pt)
    end
    inst.SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/fossilized_break")
    local shadowthrallmanager = TheWorld.components.shadowthrallmanager
    if shadowthrallmanager then
        shadowthrallmanager:OnFissureMinedFinished(inst)
    end
end

local function ShowStack(inst)
    if not inst.components.inspectable then
        local inspectable = inst:AddComponent("inspectable")
    end
    inst:SetPrefabNameOverride("dreadstone_stack")
    inst.AnimState:ShowSymbol("stack_under")
    inst.AnimState:ShowSymbol("stack_over")
    inst.AnimState:ShowSymbol("stack_red")
end

local function OnDreadstoneMineCooldown(inst, fromload)
    local workable = inst.components.workable
    if workable then
        workable:SetWorkable(true)
    end
    if not fromload then
        if workable then
            workable:SetWorkLeft(TUNING.FISSURE_DREADSTONE_WORK)
        end
        inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowrock_up")
        local fx = SpawnPrefab("dreadstone_spawn_fx")
        fx.entity:SetParent(inst.entity)
        inst:DoTaskInTime(7 * FRAMES, ShowStack)
    else
        ShowStack(inst)
    end
end

local function OnReleasedFromControl_Animation(inst)
    inst.AnimState:SetBankAndPlayAnimation(inst._default_fissure_build, "open_2")
    inst.AnimState:SetBuild(inst._default_fissure_build)
    inst.AnimState:HideSymbol("stack_under")
    inst.AnimState:HideSymbol("stack_over")
    inst.AnimState:HideSymbol("stack_red")

    inst.fx.AnimState:SetMultColour(1, 1, 1, 1)
    inst.Light:SetColour(unpack(inst._default_light_values))

	inst.AnimState:SetSymbolLightOverride("crack01", 0)
	inst.AnimState:SetSymbolLightOverride("fx_beam", 0)
	inst.AnimState:SetSymbolLightOverride("fx_spiral", 0)
	inst.AnimState:SetSymbolLightOverride("stack_red", 0)

    inst:OnNightmarePhaseChanged(TheWorld.state.nightmarephase, false)
    if inst.temp then
        inst:ListenForEvent("animqueueover", ErodeAway)
        DisableTempFissure(inst)
    end
end

local function OnReleasedFromControl(inst)
    inst:RemoveEventCallback("animover", OnAnimOverControlled)
    local played_animation = false
    local workable = inst.components.workable
    if workable then
        if workable:CanBeWorked() and not inst:IsAsleep() then
            inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowrock_down")
            local fx = SpawnPrefab("dreadstone_spawn_fx")
            fx.entity:SetParent(inst.entity)
            inst:DoTaskInTime(7 * FRAMES, OnReleasedFromControl_Animation)
            played_animation = true
        end
        workable:SetWorkable(false)
    end
    if inst.components.inspectable then
        inst:RemoveComponent("inspectable")
    end
    inst:SetPrefabNameOverride(nil)
    
    if not played_animation then
        OnReleasedFromControl_Animation(inst)
    end
end

local function MakeTempFissure(inst)
	inst.temp = true
	inst:OnNightmarePhaseChanged("calm", true)
end

local function displaynamefn(inst)
    -- This is a hack relying on the inspectable tag to flag if the object has dreadstone and should change if this is no longer the case.
    return inst:HasTag("inspectable") and STRINGS.NAMES.DREADSTONE_STACK or nil
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
    
    if AllowShadowThralls[name] then
        table.insert(prefabs, "dreadstone")
        table.insert(prefabs, "dreadstone_spawn_fx")
        if build ~= "nightmare_crack_upper" then
            table.insert(assets, Asset("ANIM", "anim/nightmare_crack_upper.zip"))
        end
    end

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
        
        if AllowShadowThralls[name] then
            inst.displaynamefn = displaynamefn
        end

        inst:AddTag("okayforarena")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            inst:ListenForEvent("lightdirty", OnLightDirty)

            return inst
        end

        inst._default_fissure_build = build
        inst._default_light_values = lightcolour

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

        if AllowShadowThralls[name] then
            local lootdropper = inst:AddComponent("lootdropper")
            local workable = inst:AddComponent("workable")
            workable:SetWorkAction(ACTIONS.MINE)
            workable:SetOnFinishCallback(OnFissureMinedFinished)
            workable:SetMaxWork(TUNING.FISSURE_DREADSTONE_WORK)
            workable:SetWorkLeft(TUNING.FISSURE_DREADSTONE_WORK)
			workable:SetRequiresToughWork(true)
            workable:SetWorkable(false)
            workable.savestate = true
            inst.OnDreadstoneMineCooldown = OnDreadstoneMineCooldown
            inst.OnReleasedFromControl = OnReleasedFromControl
        end

        inst.OnNightmarePhaseChanged = OnNightmarePhaseChanged
        inst:WatchWorldState("nightmarephase", inst.OnNightmarePhaseChanged)
        inst:OnNightmarePhaseChanged(TheWorld.state.nightmarephase, true)

        inst.OnEntityWake = OnEntityWake
        inst.OnEntitySleep = OnEntitySleep

		inst.MakeTempFissure = MakeTempFissure

		if masterinit ~= nil then
			masterinit(inst)
		end

        inst.OnPreLoad = OnPreLoad
		inst.OnSave = OnSave

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

-- NOTES(JBK): Add more to AllowShadowThralls table above if adding more prefabs here that want the shadow thrall event fight.
return Make("fissure", "nightmare_crack_upper", upperLightColour, "upper_nightmarefissurefx"),
    Make("fissure_lower", "nightmare_crack_ruins", lowerLightColour, "nightmarefissurefx"),
    Make("fissure_grottowar", "fissure_grottowar", upperLightColour, "fissure_grottowarfx", grottowar_masterinit)

