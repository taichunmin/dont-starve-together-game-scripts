require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/terrarium.zip"),
    Asset("INV_IMAGE", "terrarium_cooldown"),
    Asset("INV_IMAGE", "terrarium_crimson"),
}

local prefabs =
{
    "eyeofterror",
    "shadow_despawn",
    "terrarium_fx",
    "twinmanager",
}

-------------------------------------------------------------------------------
local MAX_LIGHT_FRAME = 14
local MAX_LIGHT_RADIUS = 15

-- dframes is like dt, but for frames, not time
local function OnUpdateLight(inst, dframes)
    local done
    if inst._islighton:value() then
        local frame = inst._lightframe:value() + dframes
        done = frame >= MAX_LIGHT_FRAME
        inst._lightframe:set_local(done and MAX_LIGHT_FRAME or frame)
    else
        local frame = inst._lightframe:value() - dframes*3
        done = frame <= 0
        inst._lightframe:set_local(done and 0 or frame)
    end

    inst.Light:SetRadius(MAX_LIGHT_RADIUS * inst._lightframe:value() / MAX_LIGHT_FRAME)

    if done then
        inst._LightTask:Cancel()
        inst._LightTask = nil
    end
end

local function OnUpdateLightColour(inst)
    local red, green, blue = 1, 1, 1
	inst._lighttweener = inst._lighttweener + FRAMES * 1.25
	if inst._lighttweener > 2 * PI then
		inst._lighttweener = inst._lighttweener - 2*PI
	end

    if inst._iscrimson:value() then
        red = 0.90
        green = 0.20
        blue = 0.20
    else
	    local x = inst._lighttweener
	    local s = .15
	    local b = 0.85
	    local sin = math.sin

		red = sin(x) * s + b - s
		green = sin(x + 2/3 * PI) * s + b - s
		blue = sin(x - 2/3 * PI) * s + b - s
    end

	inst.Light:SetColour(red, green, blue)
end

local function OnLightDirty(inst)
    if inst._LightTask == nil then
        inst._LightTask = inst:DoPeriodicTask(FRAMES, OnUpdateLight, nil, 1)
    end
    OnUpdateLight(inst, 0)

	if not TheNet:IsDedicated() then
		if inst._islighton:value() then
			if inst._lightcolourtask == nil then
				inst._lighttweener = 0
				inst._lightcolourtask = inst:DoPeriodicTask(FRAMES, OnUpdateLightColour)
			end
		elseif inst._lightcolourtask ~= nil then
			inst._lightcolourtask:Cancel()
			inst._lightcolourtask = nil
		end
	end
end
-------------------------------------------------------------------------------

local function safely_remove_noncrimson(inst)
    inst:RemoveEventCallback("onremove", inst.on_end_eyeofterror_fn, inst.eyeofterror)

    inst.eyeofterror:Remove()
    inst.eyeofterror = nil
end

local function become_crimson(inst)
    inst.AnimState:Hide("terrarium_tree")
    inst.AnimState:Show("terrarium_tree_crimson")

    inst.components.inventoryitem:ChangeImageName("terrarium_crimson")

    inst._iscrimson:set(true)

    -- If we just got crimson-ified, and there was a previous non-crimson-version boss waiting
    -- in limbo to come back, just get rid of it so we just spawn the crimson-version boss at night.
    -- NOTE: importantly, as written, crimsonification cannot happen while the terrarium is active (on or beaming)
    if inst.eyeofterror ~= nil and inst.eyeofterror.prefab == "eyeofterror" then
        if inst.eyeofterror:IsInLimbo() then
            safely_remove_noncrimson(inst)
        end
    end
end

local function become_normal(inst)
    inst.AnimState:Hide("terrarium_tree_crimson")
    inst.AnimState:Show("terrarium_tree")

    inst.components.inventoryitem:ChangeImageName("terrarium")

    inst._iscrimson:set(false)
end

local function is_crimson(inst)
    return inst._iscrimson:value()
end

-------------------------------------------------------------------------------
local function hookup_eye_listeners(inst, eye)
    inst:ListenForEvent("onremove", inst.on_end_eyeofterror_fn, eye)
    inst:ListenForEvent("turnoff_terrarium", inst.on_end_eyeofterror_fn, eye)

    inst:ListenForEvent("finished_leaving", inst.on_eye_left_fn, eye)
end
-------------------------------------------------------------------------------

local function enable_dynshadow(inst)
	if inst._ShadowDelayTask ~= nil then
		inst._ShadowDelayTask:Cancel()
		inst._ShadowDelayTask = nil
	end
    inst.DynamicShadow:Enable(true)
end

local function disable_dynshadow(inst)
	if inst._ShadowDelayTask ~= nil then
		inst._ShadowDelayTask:Cancel()
		inst._ShadowDelayTask = nil
	end
    inst.DynamicShadow:Enable(false)
end

local function getstatus(inst, viewer)
	return (inst.eyeofterror ~= nil and not inst.eyeofterror:IsInLimbo() and "EYEOFTERROR_SPAWNED")
			or inst._summoning_fx ~= nil and "ENABLED"
			or inst.is_on and "WAITING_FOR_DARK"
            or inst._iscrimson:value() and "CRIMSON"
			or inst.components.worldsettingstimer:ActiveTimerExists("cooldown") and "COOLDOWN"
			or not TUNING.SPAWN_EYEOFTERROR and "SPAWN_DISABLED"
			or nil
end

local function TurnOn(inst, is_loading)
    if inst.is_on then
        return
    end
    inst.is_on = true

    inst.components.activatable.inactive = true -- to allow turning off
    inst.components.trader.enabled = false      -- no trading while activated

    if is_loading then
        inst.AnimState:PlayAnimation("activated_idle", true)

        enable_dynshadow(inst)
    else
        inst.AnimState:PlayAnimation("activate")
        inst.AnimState:PushAnimation("activated_idle", true)

        inst._ShadowDelayTask = inst:DoTaskInTime(4*FRAMES, enable_dynshadow)

        if TheWorld.state.isnight then
            inst.components.timer:StartTimer("summon_delay", TUNING.TERRARIUM_SUMMON_DELAY)
        end
    end

    inst.SoundEmitter:KillSound("beam")
    inst.SoundEmitter:PlaySound("terraria1/terrarium/shimmer_loop", "shimmer")
end

local function TurnLightsOn(inst)
    inst._islighton:set(true)
    OnLightDirty(inst)
    inst._TurnLightsOnTask = nil
end

local function StartSummoning(inst, is_loading)
    if is_loading or
            (   inst.is_on and TheWorld.state.isnight and
                inst._summoning_fx == nil and
                not inst.components.timer:TimerExists("summon_delay")
            ) then

        -- Put the Terrarium itself into an untouchable state.
        inst.components.inventoryitem.canbepickedup = false
        inst.components.activatable.inactive = false
        inst.components.trader.enabled = false      -- no trading while beaming

        -- Spawn the summoning beam, if we do not have one (and we shouldn't)
        if inst._summoning_fx == nil then
            inst._summoning_fx = SpawnPrefab("terrarium_fx")
            inst._summoning_fx.entity:SetParent(inst.entity)
            inst._summoning_fx.AnimState:PlayAnimation("activate_fx")
            inst._summoning_fx.AnimState:PushAnimation("activated_idle_fx", true)
        end
        -- ...including a delayed light activation
        inst._TurnLightsOnTask = inst:DoTaskInTime(7 * FRAMES, TurnLightsOn)

        enable_dynshadow(inst)

        inst.SoundEmitter:KillSound("shimmer")
        inst.SoundEmitter:PlaySound("terraria1/terrarium/beam_loop", "beam")

        -- If we're not starting this summoning sequence via OnLoad, do some extra presentation,
        -- and also queue up a boss spawn.
        if not is_loading then
            if is_crimson(inst) then
                TheNet:Announce(STRINGS.TWINS_COMING)
            else
                TheNet:Announce(STRINGS.EYEOFTERROR_COMING)
            end
            inst.components.timer:StartTimer("warning", TUNING.TERRARIUM_WARNING_TIME)

            inst.SoundEmitter:PlaySound("terraria1/terrarium/beam_shoot")
        end
    end
end

local DEACTIVATE_TIME = 10*FRAMES
local function TurnOff(inst)
    if not inst.is_on then
        return
    end

    inst.is_on = false
    inst.components.activatable.inactive = TUNING.SPAWN_EYEOFTERROR
    inst.components.trader.enabled = true

    inst.components.timer:StopTimer("warning")

    if not inst.components.inventoryitem.canbepickedup then
        inst.components.inventoryitem.canbepickedup = true
    end

    inst.SoundEmitter:KillSound("shimmer")
    inst.SoundEmitter:KillSound("beam")

    if inst._TurnLightsOnTask ~= nil then
        inst._TurnLightsOnTask:Cancel()
        inst._TurnLightsOnTask = nil
    end
    inst._islighton:set(false)
    OnLightDirty(inst)

    if inst._summoning_fx ~= nil then
        inst._summoning_fx.AnimState:PlayAnimation("deactivate_fx")
        inst._summoning_fx:DoTaskInTime(DEACTIVATE_TIME, inst._summoning_fx.Remove)
        inst._summoning_fx = nil

        inst.SoundEmitter:PlaySound("terraria1/terrarium/beam_stop")
    end

    -- The Terrarium is in limbo when it's in an inventory or container.
    if inst:IsInLimbo() then
        inst.AnimState:PlayAnimation("idle", true)

        disable_dynshadow(inst)
    else
        inst.AnimState:PlayAnimation("deactivate")
        inst.AnimState:PushAnimation("idle", true)

        inst._ShadowDelayTask = inst:DoTaskInTime(4*FRAMES, disable_dynshadow)
    end
end

local function OnBossFightOver(inst)
    TurnOff(inst)

    inst.components.activatable.inactive = false

    if inst._iscrimson:value() then
        SpawnPrefab("shadow_despawn").Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst._iscrimson:set(false)
    end
    inst.AnimState:Hide("terrarium_tree")
    inst.AnimState:Hide("terrarium_tree_crimson")
    inst.components.inventoryitem:ChangeImageName("terrarium_cooldown")

    if inst.eyeofterror ~= nil then
        inst.eyeofterror:PushEvent("leave")
    end

    if not inst.components.worldsettingstimer:ActiveTimerExists("cooldown") then
        inst.components.worldsettingstimer:StartTimer("cooldown", TUNING.EYEOFTERROR_SPAWNDELAY)
    end
end

local function OnDay_SendBossAway(inst)
    -- Return to the "on but not shooting a beam" state
    TurnOff(inst)

    -- Tell the boss to leave; it will tell us when it's done so via "finished_leaving"
    if inst.eyeofterror ~= nil then
        inst.eyeofterror:PushEvent("leave")
    end
end

local function spawn_eye_prefab(inst)
    if is_crimson(inst) then
        return SpawnPrefab("twinmanager")
    else
        return SpawnPrefab("eyeofterror")
    end
end

local SPAWN_OFFSET = 10
local function SpawnEyeOfTerror(inst)
    if AllPlayers ~= nil and #AllPlayers > 0 then
        local targeted_player = AllPlayers[math.random(#AllPlayers)]

        local announce_template = (is_crimson(inst) and STRINGS.TWINS_TARGET) or STRINGS.EYEOFTERROR_TARGET
        TheNet:Announce(subfmt(announce_template, {player_name = targeted_player.name}))

        local angle = math.random() * 2 * PI
        local player_pt = targeted_player:GetPosition()
        local spawn_offset = FindWalkableOffset(player_pt, angle, SPAWN_OFFSET, nil, false, true, nil, true, true)
            or Vector3(SPAWN_OFFSET * math.cos(angle), 0, SPAWN_OFFSET * math.sin(angle))
        local spawn_position = player_pt + spawn_offset

        if inst.eyeofterror ~= nil and inst.eyeofterror:IsInLimbo() then
            inst.eyeofterror:ReturnToScene()
            inst.eyeofterror.Transform:SetPosition(spawn_position:Get())    -- Needs to be done so the spawn fx spawn in the right place
            if inst.eyeofterror.sg ~= nil then
                inst.eyeofterror.sg:GoToState("flyback", targeted_player)
            else
                inst.eyeofterror:PushEvent("flyback", targeted_player)
            end
        else
            inst.eyeofterror = spawn_eye_prefab(inst)
            inst.eyeofterror.Transform:SetPosition(spawn_position:Get())    -- Needs to be done so the spawn fx spawn in the right place
            if inst.eyeofterror.sg ~= nil then
                inst.eyeofterror.sg:GoToState("arrive", targeted_player)
            else
                inst.eyeofterror:PushEvent("arrive", targeted_player)
            end
        end
        inst.eyeofterror:PushEvent("set_spawn_target", targeted_player)

        hookup_eye_listeners(inst, inst.eyeofterror)
    end
end

local function OnCooldownOver(inst)
	inst.components.activatable.inactive = TUNING.SPAWN_EYEOFTERROR
	inst.AnimState:Show("terrarium_tree")
	inst.components.inventoryitem:ChangeImageName(nil) -- back to default
end

local function on_night(inst)
	if TheWorld.state.isnight then
		if inst.is_on then
			inst.components.timer:StartTimer("summon_delay", TUNING.TERRARIUM_SUMMON_DELAY)
		end
	else
		if inst.components.timer:TimerExists("warning") then
			TheNet:Announce(STRINGS.EYEOFTERROR_CANCEL)
			TurnOff(inst)
		elseif inst.eyeofterror ~= nil then
            OnDay_SendBossAway(inst)
		end
	end
end

-------------------------------------------------------------------------------

local function AbleToAcceptTest(inst, item, giver)
    if inst.components.worldsettingstimer:ActiveTimerExists("cooldown") then
        return false, "TERRARIUM_COOLDOWN"
    elseif item.prefab ~= "nightmarefuel" then
        return false, "TERRARIUM_REFUSE"
    elseif inst._iscrimson:value() then
        return false, "SLOTFULL"
    else
        return true
    end
end

local function ItemGet(inst, giver, item)
    become_crimson(inst)

    SpawnPrefab("shadow_despawn").Transform:SetPosition(inst.Transform:GetWorldPosition())
end

-------------------------------------------------------------------------------

local function OnActivate(inst, doer)
	if not inst.is_on then
		TurnOn(inst)
	else
		TurnOff(inst)
	end
end

local function OnEyeLeft(eye, inst)
    if eye ~= nil and not eye:IsInLimbo() then
        eye:RemoveFromScene()

        -- If the crimson trade occured while the eye was leaving, but before it left,
        -- we need to clean it up here, when it's finished leaving.
        if eye.prefab == "eyeofterror" and is_crimson(inst) then
            safely_remove_noncrimson(inst)
        end
    end
end

local function OnPutInInventory(inst)
	TurnOff(inst)
end

local function OnDroppedFromInventory(inst)
    disable_dynshadow(inst)
end

local function TimerDone(inst, data)
	local timer = data ~= nil and data.name
	if timer == "summon_delay" then
		StartSummoning(inst)
	elseif timer == "warning" then
		SpawnEyeOfTerror(inst)
	elseif timer == "cooldown" then
		OnCooldownOver(inst)
	end
end

local function GetActivateVerb(inst)
    return "TOUCH"
end

-------------------------------------------------------------------------------

local function OnSave(inst, data)
    data.is_on = inst.is_on
    data.is_crimson = inst._iscrimson:value()

    local refs = nil
    if inst.eyeofterror ~= nil then
        -- If the boss is dying as we save, record it.
        data.boss_dead = inst.eyeofterror:IsDying()

        data.boss_guid = inst.eyeofterror.GUID
        refs = { inst.eyeofterror.GUID }
    end

    return refs
end

local function OnLoad(inst, data)
    if data ~= nil then
        if data.is_crimson then
            become_crimson(inst)
        end
    end
end

local function OnLoadPostPass(inst, newents, data)
    if data ~= nil then
        if data.boss_guid then
            if newents[data.boss_guid] ~= nil then
                inst.eyeofterror = newents[data.boss_guid].entity

                hookup_eye_listeners(inst, inst.eyeofterror)

                if not TheWorld.state.isnight then
                    OnEyeLeft(inst.eyeofterror, inst)
                end
            end
        end

        if data.is_on then
            if (inst.eyeofterror ~= nil and not inst.eyeofterror:IsInLimbo())
                    or inst.components.timer:TimerExists("warning") then
                TurnOn(inst, true)
                StartSummoning(inst, true)
            elseif data.boss_dead then
                -- The boss was dying as we saved, so we should be turned off as though
                -- we received the death message.
                OnBossFightOver(inst)
            elseif TUNING.SPAWN_EYEOFTERROR then
                TurnOn(inst, true)
            end
        elseif inst.components.worldsettingstimer:ActiveTimerExists("cooldown") then
            OnBossFightOver(inst)
        end
    end
end

-------------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
	inst.entity:AddLight()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("terrarium.png")

    inst.Light:SetRadius(0)
    inst.Light:SetIntensity(0.45)
    inst.Light:SetFalloff(1.8)
    inst.Light:SetColour(1, 1, 1)
    inst.Light:Enable(true)
    inst.Light:EnableClientModulation(true)

    inst.DynamicShadow:SetSize(1.25, 1)
    inst.DynamicShadow:Enable(false)

    inst.AnimState:SetBank("terrarium")
    inst.AnimState:SetBuild("terrarium")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:Hide("terrarium_tree_crimson")

    MakeInventoryPhysics(inst)

    inst:AddTag("irreplaceable")

    -- tags from trader.lua for optimization
    inst:AddTag("trader")
    inst:AddTag("alltrader")

    inst.GetActivateVerb = GetActivateVerb

    inst._LightTask = nil
    inst._lightframe = net_smallbyte(inst.GUID, "terrarium._lightframe", "lightdirty")
    inst._iscrimson = net_bool(inst.GUID, "terrarium._iscrimson", "lightdirty")
    inst._islighton = net_bool(inst.GUID, "terrarium._islighton", "lightdirty")
    inst._islighton:set(false)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        inst:ListenForEvent("lightdirty", OnLightDirty)

        return inst
    end

    inst.on_end_eyeofterror_fn = function()
        if inst.eyeofterror ~= nil then
            OnBossFightOver(inst)
        end
    end

    inst.on_eye_left_fn = function(e)
        OnEyeLeft(e, inst)
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("worldsettingstimer")
    inst.components.worldsettingstimer:AddTimer("cooldown", TUNING.EYEOFTERROR_SPAWNDELAY, TUNING.SPAWN_EYEOFTERROR)

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", TimerDone)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem:SetOnDroppedFn(OnDroppedFromInventory)
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = OnActivate
	inst.components.activatable.quickaction = true
	inst.components.activatable.inactive = TUNING.SPAWN_EYEOFTERROR

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(AbleToAcceptTest)
    inst.components.trader.onaccept = ItemGet
    inst.components.trader.acceptnontradable = true

	inst.OnSave = OnSave
	inst.OnLoad = OnLoad
	inst.OnLoadPostPass = OnLoadPostPass

    inst:WatchWorldState("isnight", on_night)

    return inst
end

local function terrarium_fx()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("terrarium")
    inst.AnimState:SetBuild("terrarium")
    inst.AnimState:PlayAnimation("activated_idle_fx", true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(-1)

    inst:AddTag("DECOR")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("terrarium", fn, assets, prefabs),
    Prefab("terrarium_fx", terrarium_fx, assets)
