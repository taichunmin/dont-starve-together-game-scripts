require("prefabutil")

local assets =
{
    Asset("ANIM", "anim/winona_spotlight.zip"),
    Asset("ANIM", "anim/winona_spotlight_placement.zip"),
    Asset("ANIM", "anim/winona_battery_placement.zip"),
}

local assets_head =
{
    Asset("ANIM", "anim/winona_spotlight.zip"),
}

local assets_item = assets_head

local prefabs =
{
    "winona_spotlight_head",
    "winona_battery_sparks",
    "collapse_small",
	"winona_spotlight_item",
}

local prefabs_item =
{
	"winona_spotlight",
}

--------------------------------------------------------------------------

--CLIENT safe!
local function OnIsSummer(inst, issummer)
	if issummer then
		inst._lightinst:RemoveHeat()
		local head = inst._headinst or inst._clientheadinst
		if head then
			head:SetHeated(false)
		end
	else
		inst._lightinst:AddHeat()
		local head = inst._headinst or inst._clientheadinst
		if head then
			head:SetHeated(true)
		end
	end
end

--CLIENT safe!
local function StartHeatWatcher(inst)
	if not inst._heatwatcher then
		inst._heatwatcher = true
		inst:WatchWorldState("issummer", OnIsSummer)
		OnIsSummer(inst, TheWorld.state.issummer)
	end
end

--CLIENT safe!
local function StopHeatWatcher(inst)
	if inst._heatwatcher then
		inst._heatwatcher = nil
		inst:StopWatchingWorldState("issummer", OnIsSummer)
		OnIsSummer(inst, true) --force disable heat
	end
end

--CLIENT safe!
local function ApplySkillBonuses(inst)
	if inst._heated:value() then
		StartHeatWatcher(inst)
	else
		StopHeatWatcher(inst)
	end

	if inst._ranged:value() then
		inst.RADIUS = TUNING.SKILLS.WINONA.SPOTLIGHT_RADIUS2
		inst.MIN_RANGE = TUNING.SKILLS.WINONA.SPOTLIGHT_MIN_RANGE2
		inst.MAX_RANGE = TUNING.SKILLS.WINONA.SPOTLIGHT_MAX_RANGE2
	else
		inst.RADIUS = TUNING.WINONA_SPOTLIGHT_RADIUS
		inst.MIN_RANGE = TUNING.WINONA_SPOTLIGHT_MIN_RANGE
		inst.MAX_RANGE = TUNING.WINONA_SPOTLIGHT_MAX_RANGE
	end
	inst._lightinst:SetRadius(inst.RADIUS)
end

local function ConfigureSkillTreeUpgrades(inst, builder)
	local skilltreeupdater = builder and builder.components.skilltreeupdater or nil

	local heated = skilltreeupdater ~= nil and skilltreeupdater:IsActivated("winona_spotlight_heated")
	local ranged = skilltreeupdater ~= nil and skilltreeupdater:IsActivated("winona_spotlight_range")

	local dirty = inst._heated:value() ~= heated or inst._ranged:value() ~= ranged

	inst._heated:set(heated)
	inst._ranged:set(ranged)
	inst._engineerid = builder and builder:HasTag("handyperson") and builder.userid or nil

	return dirty
end

--------------------------------------------------------------------------

local PLACER_SCALE = 1.5

local function OnUpdatePlacerHelper(helperinst)
    if not helperinst.placerinst:IsValid() then
        helperinst.components.updatelooper:RemoveOnUpdateFn(OnUpdatePlacerHelper)
        helperinst.AnimState:SetAddColour(0, 0, 0, 0)
	else
		local range = TUNING.WINONA_BATTERY_RANGE - TUNING.WINONA_ENGINEERING_FOOTPRINT
		local hx, hy, hz = helperinst.Transform:GetWorldPosition()
		local px, py, pz = helperinst.placerinst.Transform:GetWorldPosition()
		--<= match circuitnode FindEntities range tests
		if distsq(hx, hz, px, pz) <= range * range and TheWorld.Map:GetPlatformAtPoint(hx, hz) == TheWorld.Map:GetPlatformAtPoint(px, pz) then
            helperinst.AnimState:SetAddColour(helperinst.placerinst.AnimState:GetAddColour())
        else
            helperinst.AnimState:SetAddColour(0, 0, 0, 0)
        end
    end
end

local function CreatePlacerBatteryRing()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")

    inst.AnimState:SetBank("winona_battery_placement")
    inst.AnimState:SetBuild("winona_battery_placement")
    inst.AnimState:PlayAnimation("idle_small")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

    return inst
end

local function CreatePlacerRing()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")

    inst.AnimState:SetBank("winona_spotlight_placement")
    inst.AnimState:SetBuild("winona_spotlight_placement")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetAddColour(0, .2, .5, 0)
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

    CreatePlacerBatteryRing().entity:SetParent(inst.entity)

    return inst
end

local function OnEnableHelper(inst, enabled, recipename, placerinst)
    if enabled then
        if inst.helper == nil and inst:HasTag("HAMMER_workable") and not inst:HasTag("burnt") then
			if recipename == "winona_spotlight" or (placerinst and placerinst.prefab == "winona_spotlight_item_placer") then
                inst.helper = CreatePlacerRing()
                inst.helper.entity:SetParent(inst.entity)
            else
                inst.helper = CreatePlacerBatteryRing()
                inst.helper.entity:SetParent(inst.entity)
				if placerinst and (
					placerinst.prefab == "winona_battery_low_item_placer" or
					placerinst.prefab == "winona_battery_high_item_placer" or
					recipename == "winona_battery_low" or
					recipename == "winona_battery_high"
				) then
                    inst.helper:AddComponent("updatelooper")
                    inst.helper.components.updatelooper:AddOnUpdateFn(OnUpdatePlacerHelper)
                    inst.helper.placerinst = placerinst
                    OnUpdatePlacerHelper(inst.helper)
                end
            end
        end
    elseif inst.helper ~= nil then
        inst.helper:Remove()
        inst.helper = nil
    end
end

local function OnStartHelper(inst)--, recipename, placerinst)
	if inst.AnimState:IsCurrentAnimation("place") then
		inst.components.deployhelper:StopHelper()
	end
end

--------------------------------------------------------------------------

local TILTS = { "", "_tilt1", "_tilt2" }

local function SetHeadTilt(headinst, tilt, lightenabled)
    headinst._tilt = tilt
    for i, v in ipairs(TILTS) do
        if i == tilt then
            headinst.AnimState:Show("light"..v)
            if lightenabled then
                headinst.AnimState:Show("light_shaft"..v)
            else
                headinst.AnimState:Hide("light_shaft"..v)
            end
        else
            headinst.AnimState:Hide("light"..v)
            headinst.AnimState:Hide("light_shaft"..v)
        end
    end
end

local LED_BLINK_DELAY = 1.5
local LED_BLINK_TIME = 0.75

local function SetLedEnabled(inst, enabled)
	if enabled then
		inst._headinst.AnimState:OverrideSymbol("led_off", "winona_spotlight", "led_on")
		inst._headinst.AnimState:SetSymbolBloom("led_off")
		inst._headinst.AnimState:SetSymbolLightOverride("led_off", 0.5)
		inst._headinst.AnimState:SetSymbolLightOverride("led_parts", 0.24)
		inst._headinst.AnimState:SetSymbolLightOverride("light_base", 0.08)
		inst._headinst.AnimState:SetSymbolLightOverride("bracket1", 0.04)
		inst._headinst.AnimState:SetSymbolLightOverride("bracket2", 0.04)
	else
		inst._headinst.AnimState:ClearOverrideSymbol("led_off")
		inst._headinst.AnimState:ClearSymbolBloom("led_off")
		inst._headinst.AnimState:SetSymbolLightOverride("led_off", 0)
		inst._headinst.AnimState:SetSymbolLightOverride("led_parts", 0)
		inst._headinst.AnimState:SetSymbolLightOverride("light_base", 0)
		inst._headinst.AnimState:SetSymbolLightOverride("bracket1", 0)
		inst._headinst.AnimState:SetSymbolLightOverride("bracket2", 0)
	end
end

local function SetLedStatusOn(inst)
	inst._ledblinkdelay = nil
	SetLedEnabled(inst, true)
end

local function SetLedStatusOff(inst)
	inst._ledblinkdelay = nil
	SetLedEnabled(inst, false)
end

local function SetLedStatusBlink(inst, initialon)
	if inst._ledblinkdelay == nil then
		inst._ledblinkdelay = initialon and -LED_BLINK_TIME or LED_BLINK_DELAY
		SetLedEnabled(inst, initialon)
	end
end

--------------------------------------------------------------------------

local function _DoEnableHeat_Server(inst, enable)
	if enable then
        local heater = inst.components.heater
		if heater == nil then
			heater = inst:AddComponent("heater")
            heater.heat = TUNING.SKILLS.WINONA.SPOTLIGHT_HEAT_VALUE
            heater:SetShouldFalloff(false)
            heater:SetHeatRadiusCutoff(inst.RADIUS)
		end
	else
		inst:RemoveComponent("heater")
	end
end

local function _DoEnableHeat_Client(inst, enable)
	if enable then
		inst:AddTag("HASHEATER")
	else
		inst:RemoveTag("HASHEATER")
	end
end

local function Light_TurnOn(inst)
	inst.Light:Enable(true)
	inst:DoEnableHeat(inst._heated)
end

local function Light_TurnOff(inst)
	inst.Light:Enable(false)
	inst:DoEnableHeat(false)
end

local function Light_AddHeat(inst)
	inst._heated = true
	inst:DoEnableHeat(inst.Light:IsEnabled())
end

local function Light_RemoveHeat(inst)
	inst._heated = false
	inst:DoEnableHeat(false)
end

local function Light_SetRadius(inst, radius)
	inst.Light:SetRadius(radius)
	if inst.components.heater then
		inst.components.heater:SetHeatRadiusCutoff(radius)
	end
end

local LIGHT_EASING = .2
local UPDATE_TARGET_PERIOD = .5
local LIGHT_INTENSITY_MAX = .94
local LIGHT_INTENSITY_DELTA = -.1
local LIGHT_OVERRIDE_LIGHTSHAFT = 0.7
local LIGHT_OVERRIDE_HEAD = 0.3
local LIGHT_OVERRIDE_BASE = .25

local function CreateLight()
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddLight()

    inst.Light:SetFalloff(.9)
    inst.Light:SetIntensity(LIGHT_INTENSITY_MAX)
    inst.Light:SetRadius(TUNING.WINONA_SPOTLIGHT_RADIUS)
    inst.Light:SetColour(255 / 255, 248 / 255, 198 / 255)
    inst.Light:Enable(false)

	inst._heated = false

	inst.SetRadius = Light_SetRadius
	inst.TurnOn = Light_TurnOn
	inst.TurnOff = Light_TurnOff
	inst.AddHeat = Light_AddHeat
	inst.RemoveHeat = Light_RemoveHeat
	inst.DoEnableHeat = TheWorld.ismastersim and _DoEnableHeat_Server or _DoEnableHeat_Client

    return inst
end

local GLOBAL_TARGETS = {}

local function SetTarget(inst, target)
    if inst._target ~= target then
        if inst._target ~= nil then
            local t = GLOBAL_TARGETS[inst._target]
            if t.count > 1 then
                t.count = t.count - 1
				t.lights[inst] = nil
            else
                GLOBAL_TARGETS[inst._target] = nil
            end
        end
        inst._target = target
        if target ~= nil then
            local t = GLOBAL_TARGETS[target]
            if t == nil then
                GLOBAL_TARGETS[target] = { count = 1, lights = { [inst] = true } }
            else
                t.lights[inst] = true
                t.count = t.count + 1
            end
        end
    end
end

local function HasOtherLight(inst, target)
    local t = GLOBAL_TARGETS[target]
    return t ~= nil and (t.lights[inst] and t.count - 1 or t.count) > 0
end

local function UpdateTarget(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
	local maxrangesq = inst.MAX_RANGE * inst.MAX_RANGE
	local startrange = inst.MAX_RANGE + inst.RADIUS + 4
    local rangesq = startrange * startrange
    local targetIsAlive = nil
    local targetHasOtherLight = nil
    if inst._target ~= nil then
        if not (inst._target:IsValid() and inst._target.entity:IsVisible()) then
            SetTarget(inst, nil)
        else
            rangesq = inst._target:GetDistanceSqToPoint(x, y, z)
			local limit = inst.MAX_RANGE + inst.RADIUS + 16
            if rangesq >= limit * limit then
                SetTarget(inst, nil)
                rangesq = startrange * startrange
            else
                targetIsAlive = not (inst._target.components.health:IsDead() or inst._target:HasTag("playerghost"))
                targetHasOtherLight = HasOtherLight(inst, inst._target)
                if targetIsAlive and not targetHasOtherLight and rangesq < maxrangesq then
                    return
                end
            end
        end
    end
    for i, v in ipairs(AllPlayers) do
        if v ~= inst._target and v.entity:IsVisible() then
            local isalive = not (v.components.health:IsDead() or v:HasTag("playerghost"))
            local hasotherlight = HasOtherLight(inst, v)
            if inst._target == nil then
                local distsq = v:GetDistanceSqToPoint(x, y, z)
                if distsq < rangesq then
                    rangesq = distsq
                    SetTarget(inst, v)
                    targetIsAlive = isalive
                    targetHasOtherLight = hasotherlight
                end
            elseif not hasotherlight then
                if isalive and not targetIsAlive or targetHasOtherLight then
                    local distsq = v:GetDistanceSqToPoint(x, y, z)
                    if distsq < maxrangesq then
                        rangesq = distsq
                        SetTarget(inst, v)
                        targetIsAlive = isalive
                        targetHasOtherLight = hasotherlight
                    end
                elseif isalive or not targetIsAlive then
                    local distsq = v:GetDistanceSqToPoint(x, y, z)
                    if distsq < rangesq then
                        rangesq = distsq
                        SetTarget(inst, v)
                        targetIsAlive = isalive
                        targetHasOtherLight = hasotherlight
                    end
                end
            end
        end
    end
end

local function UpdateLightValues(inst, dir, dist)
    local offs = inst._lightoffset:value() * inst._lightoffset:value() / 49
    dir = dir + offs * 15
    dist = dist + offs
    local theta = (dir + 90) * DEGREES
    inst._lightinst.Transform:SetPosition(math.sin(theta) * dist, 0, math.cos(theta) * dist)
	local k = math.clamp((dist - inst.MIN_RANGE) / (inst.MAX_RANGE - inst.MIN_RANGE), 0, 1)
    inst._lightinst.Light:SetIntensity(LIGHT_INTENSITY_MAX + k * k * LIGHT_INTENSITY_DELTA)
end

local function OnUpdateLightCommon(inst)
    if inst._lightoffset:value() > 0 then
        inst._lightoffset:set_local(inst._lightoffset:value() - 1)
    end

    local lightenabled = inst._lightdist:value() > 0

    if inst._curlightdir == nil then
        if not lightenabled then
            return
        end
        inst._curlightdir = inst._lightdir:value()
    else
        if inst._clientheadinst ~= nil then
            --on clients, check to make sure we're predicting the light tween in the correct direction
            --by comparing it against the head transform rotation, which isn't predicted
            local headdir = inst._clientheadinst.Transform:GetRotation()
            local drot = math.abs(inst._curlightdir - headdir)
            if drot > 180 then
                drot = 360 - drot
            end
            if drot >= 90 then
                --differs by over 90 degrees? maybe we're rotating the wrong way, so snap to match the head
                inst._curlightdir = headdir
            end
        end
        local drot = inst._lightdir:value() - inst._curlightdir
        if drot > 180 then
            drot = drot - 360
        elseif drot < -180 then
            drot = drot + 360
        end
        inst._curlightdir = inst._curlightdir + drot * LIGHT_EASING
        if inst._curlightdir > 180 then
            inst._curlightdir = inst._curlightdir - 360
        elseif inst._curlightdir < -180 then
            inst._curlightdir = inst._curlightdir + 360
        end
    end

    if inst._curlightdist == nil then
		inst._curlightdist = math.max(inst.MIN_RANGE, inst._lightdist:value())
    else
		inst._curlightdist = inst._curlightdist * (1 - LIGHT_EASING) + math.max(inst.MIN_RANGE, inst._lightdist:value()) * LIGHT_EASING
    end

    if lightenabled then
        UpdateLightValues(inst, inst._curlightdir, inst._curlightdist)
    end
end

local function OnUpdateLightClient(inst)--, dt)
    if inst.components.updatelooper ~= nil then
        if inst:HasTag("burnt") then
            inst:RemoveComponent("updatelooper")
        else
            OnUpdateLightCommon(inst)
        end
    end
end

local function OnLightDistDirty(inst)
	if inst._lightdist:value() > 0 then --light is enabled
		inst._lightinst:TurnOn()
		if inst._curlightdir == nil then
			OnUpdateLightClient(inst)
		end
	else
		inst._lightinst:TurnOff()
	end
end

local function OnStartHum(inst)
    inst._humtask = nil
    inst.SoundEmitter:PlaySound("dontstarve/common/together/spot_light/on_hum_LP", "humloop")
end

local function EnableHum(inst, enable)
    if enable then
        if inst._humtask == nil then
            inst._humtask = inst:DoTaskInTime(0, OnStartHum)
        end
    elseif inst._humtask ~= nil then
        inst._humtask:Cancel()
        inst._humtask = nil
    else
        inst.SoundEmitter:KillSound("humloop")
    end
end

local function NotifyCircuitChanged(inst, node)
	node:PushEvent("engineeringcircuitchanged")
end

local function OnCircuitChanged(inst)
	--Notify other connected batteries
	inst.components.circuitnode:ForEachNode(NotifyCircuitChanged)
end

local function EnableLight(inst, enable)
    if not enable then
        if inst._lightdist:value() > 0 then
            SetHeadTilt(inst._headinst, inst._headinst._tilt, false)
            inst._headinst.AnimState:ClearBloomEffectHandle()
            inst._headinst.AnimState:SetLightOverride(0)
            inst.AnimState:SetLightOverride(0)
			inst._lightinst:TurnOff()
            inst._lightdist:set(0)
			if not inst:HasTag("NOCLICK") then
                inst.SoundEmitter:PlaySound("dontstarve/common/together/spot_light/electricity")
            end
            EnableHum(inst, false)
			SetLedStatusBlink(inst, false)
			inst.components.powerload:SetLoad(TUNING.WINONA_SPOTLIGHT_POWER_LOAD_OFF, true)
			OnCircuitChanged(inst)
        end
    elseif inst._lightdist:value() <= 0 then
        if inst.AnimState:IsCurrentAnimation("place") then
            inst.AnimState:PlayAnimation("idle", true)
            inst._headinst.AnimState:PlayAnimation("idle", true)
        end
        SetHeadTilt(inst._headinst, inst._headinst._tilt, true)
        inst._headinst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst._headinst.AnimState:SetLightOverride(LIGHT_OVERRIDE_HEAD)
        inst.AnimState:SetLightOverride(LIGHT_OVERRIDE_BASE)
		inst._lightinst:TurnOn()
		inst._lightdist:set(inst.MIN_RANGE)
		inst.SoundEmitter:PlaySound("dontstarve/common/together/spot_light/on")
		EnableHum(inst, true)
		SetLedStatusOn(inst)
		inst.components.powerload:SetLoad(TUNING.WINONA_SPOTLIGHT_POWER_LOAD_ON)
		OnCircuitChanged(inst)
    end
end

local function OnUpdateLightServer(inst, dt)
	if inst._ledblinkdelay then
		if inst._ledblinkdelay >= 0 then
			if inst._ledblinkdelay > dt then
				inst._ledblinkdelay = inst._ledblinkdelay - dt
			else
				inst._ledblinkdelay = -LED_BLINK_TIME
				SetLedEnabled(inst, true)
			end
		elseif inst._ledblinkdelay < -dt then
			inst._ledblinkdelay = inst._ledblinkdelay + dt
		else
			inst._ledblinkdelay = LED_BLINK_DELAY
			SetLedEnabled(inst, false)
		end
	end

	if inst._updatedelay then
		if inst._updatedelay > 0 then
			inst._updatedelay = inst._updatedelay - dt
		else
			UpdateTarget(inst)
			inst._updatedelay = UPDATE_TARGET_PERIOD
			EnableLight(inst, inst._target ~= nil)
		end
	end

	local lightenabled = inst._lightdist:value() > 0
	if lightenabled and inst._target then
		if inst._target:IsValid() then
			inst._lightdir:set(inst:GetAngleToPoint(inst._target.Transform:GetWorldPosition()))
			inst._lightdist:set(math.clamp(math.sqrt(inst:GetDistanceSqToInst(inst._target)), inst.MIN_RANGE, inst.MAX_RANGE))
		else
			SetTarget(inst, nil)
			EnableLight(inst, false)
		end
	end
	OnUpdateLightCommon(inst)
	if inst._curlightdir then
		inst._headinst.Transform:SetEightFaced()
		inst._headinst.Transform:SetRotation(inst._curlightdir)
		local range = inst.MAX_RANGE - inst.MIN_RANGE
		local tilt = (inst._curlightdist - inst.MIN_RANGE) / range
		local t1 = inst._headinst._tilt > 1 and 0.3 + 3 / range or 0.3
		local t2 = inst._headinst._tilt > 2 and 0.003 + 1.5 / range or 0.003
		SetHeadTilt(inst._headinst, (tilt > t1 and 1) or (tilt > t2 and 2) or 3, lightenabled)
	end
end

local function EnableTargetSearch(inst, enable)
	if inst._turnofftask then
		inst._turnofftask:Cancel()
		inst._turnofftask = nil
	end
	if not enable then
		inst._updatedelay = nil
		SetTarget(inst, nil)
		EnableLight(inst, false)
	elseif inst._updatedelay == nil then
		if not inst:IsAsleep() then
			inst._updatedelay = 0
			OnUpdateLightServer(inst, 0)
		end
		inst._updatedelay = math.random() * UPDATE_TARGET_PERIOD
	end
end

local function OnIsDarkOrCold(inst)
	if (TheWorld.state.isnight and not TheWorld.state.isfullmoon) or
		(inst._heated:value() and TheWorld.state.iswinter)
	then
		EnableTargetSearch(inst, true)
	elseif inst._turnofftask == nil then
		inst._turnofftask = inst:DoTaskInTime(2 + math.random() * 0.5, EnableTargetSearch, false)
	end
end

local function SetPowered(inst, powered, duration)
	if not powered then
		if inst._powertask then
			inst._powertask:Cancel()
			inst._powertask = nil
			inst:StopWatchingWorldState("isnight", OnIsDarkOrCold)
			inst:StopWatchingWorldState("isfullmoon", OnIsDarkOrCold)
			inst:StopWatchingWorldState("iswinter", OnIsDarkOrCold)
		end
		EnableTargetSearch(inst, false)
		SetLedStatusOff(inst)
	else
		local waspowered = inst._powertask ~= nil
		local remaining = waspowered and GetTaskRemaining(inst._powertask) or 0
		if duration > remaining then
			if inst._powertask then
				inst._powertask:Cancel()
			end
			inst._powertask = inst:DoTaskInTime(duration, SetPowered, false)
			if not waspowered then
				inst:WatchWorldState("isnight", OnIsDarkOrCold)
				inst:WatchWorldState("isfullmoon", OnIsDarkOrCold)
				inst:WatchWorldState("iswinter", OnIsDarkOrCold)
				SetLedStatusBlink(inst, true)
				OnIsDarkOrCold(inst)
			end
		end
	end
end

local function OnEntitySleep(inst)
	inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateLightServer)
	SetTarget(inst, nil)
	EnableLight(inst, false)
end

local function OnEntityWake(inst)
	inst.components.updatelooper:AddOnUpdateFn(OnUpdateLightServer)
end

local function OnRemoveEntity(inst)
	SetTarget(inst, nil)
end

--------------------------------------------------------------------------

local function OnBuilt2(inst, doer)
    if inst.components.workable:CanBeWorked() then
        inst:RemoveTag("NOCLICK")
        if not inst:HasTag("burnt") then
            inst.components.circuitnode:ConnectTo("engineeringbattery")
			if doer and doer:IsValid() then
				inst.components.circuitnode:ForEachNode(function(inst, node)
					node:OnUsedIndirectly(doer)
				end)
			end
        end
    end
end

local function OnBuilt3(inst)
    inst:RemoveEventCallback("animover", OnBuilt3)
    if inst.AnimState:IsCurrentAnimation("place") then
        inst.AnimState:PlayAnimation("idle", true)
        inst._headinst.AnimState:PlayAnimation("idle", true)
    end
end

local function DoBuiltOrDeployed(inst, doer, fastforward, sound)
	ConfigureSkillTreeUpgrades(inst, doer)
	ApplySkillBonuses(inst)

    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    inst.components.circuitnode:Disconnect()
    inst:AddTag("NOCLICK")
	SetPowered(inst, false)
    inst._headinst.Transform:SetTwoFaced()
    inst.AnimState:PlayAnimation("place")
    inst._headinst.AnimState:PlayAnimation("place")
	if fastforward > 0 then
		inst.AnimState:SetFrame(fastforward)
		inst._headinst.AnimState:SetFrame(fastforward)
	end
	inst.SoundEmitter:PlaySound(sound)
	inst:DoTaskInTime((37 - fastforward) * FRAMES, OnBuilt2, doer)
    inst:ListenForEvent("animover", OnBuilt3)
end

local function OnBuilt(inst, data)
	DoBuiltOrDeployed(inst, data and data.builder or nil, 0, "dontstarve/common/together/spot_light/place")
end

--------------------------------------------------------------------------

local function ChangeToItem(inst)
	local item = SpawnPrefab("winona_spotlight_item")
	item.Transform:SetPosition(inst.Transform:GetWorldPosition())
	item.AnimState:PlayAnimation("collapse")
	item.AnimState:PushAnimation("idle_ground", false)
	item.SoundEmitter:PlaySound("meta4/winona_spotlight/collapse")
	if inst._wired then
		item.SoundEmitter:PlaySound("dontstarve/common/together/spot_light/electricity", nil, .5)
		SpawnPrefab("winona_battery_sparks").Transform:SetPosition(inst.Transform:GetWorldPosition())
	end
end

local function OnWorked(inst)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle", true)
    inst._headinst.AnimState:PlayAnimation("hit")
    inst._headinst.AnimState:PushAnimation("idle", true)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/catapult/hit")
    inst._lightoffset:set(7)
end

local function OnDeath2(inst)
	inst:RemoveEventCallback("animover", OnDeath2)
	inst.persists = false
	inst.Physics:SetActive(false)
	inst.components.lootdropper:DropLoot()
	inst.AnimState:SetSymbolLightOverride("sparks2", 0.3)
	inst.AnimState:PlayAnimation("death_pst")
	inst.SoundEmitter:PlaySound("dontstarve/common/together/spot_light/destroy")

	local fx = SpawnPrefab("collapse_small")
	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	fx:SetMaterial("none")

	inst:DoTaskInTime(1, ErodeAway)
end

local function OnWorkFinished(inst)
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    inst.components.circuitnode:Disconnect()
	inst.components.powerload:SetLoad(0)
    inst.components.workable:SetWorkable(false)
    inst:AddTag("NOCLICK")
    if inst.components.burnable ~= nil then
        if inst.components.burnable:IsBurning() then
            inst.components.burnable:Extinguish()
        end
        inst.components.burnable.canlight = false
    end

	inst.destroyed = true
	SetPowered(inst, false)
    inst._headinst:Hide()
    inst.AnimState:Show("light")

	if not POPULATING then
		inst.AnimState:SetSymbolLightOverride("sprk_1", 0.3)
		inst.AnimState:SetSymbolLightOverride("sprk_2", 0.3)
		inst:ListenForEvent("animover", OnDeath2)
		inst.AnimState:PlayAnimation("death")
	else
		OnDeath2(inst)
	end
end

local function OnWorkedBurnt(inst)
	inst.components.workable:SetWorkable(false)
	inst:AddTag("NOCLICK")
	inst.persists = false
	inst.Physics:SetActive(false)
	inst.components.lootdropper:DropLoot()
	inst.AnimState:PlayAnimation("burntbreak")

	local fx = SpawnPrefab("collapse_small")
	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	fx:SetMaterial("wood")

	inst:DoTaskInTime(1, ErodeAway)
end

local function OnBurnt(inst)
    DefaultBurntStructureFn(inst)

	SetPowered(inst, false)
    inst._headinst:Hide()

    inst:RemoveComponent("updatelooper")
	inst:RemoveComponent("portablestructure")

    inst.Transform:SetRotation(inst._headinst.Transform:GetRotation())
    inst.OnEntityWake = nil
    inst.OnEntitySleep = nil

    inst.components.workable:SetOnWorkCallback(nil)
    inst.components.workable:SetOnFinishCallback(OnWorkedBurnt)

    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    inst.components.circuitnode:Disconnect()
	inst.components.powerload:SetLoad(0)
end

local function OnDismantle(inst)--, doer)
	ChangeToItem(inst)
	inst:Remove()
end

--------------------------------------------------------------------------

local function GetStatus(inst)
    return (inst:HasTag("burnt") and "BURNT")
        or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning() and "BURNING")
        or (inst._powertask == nil and "OFF")
        or nil
end

local function AddBatteryPower(inst, power)
	SetPowered(inst, true, power)
end

local function OnUpdateSparks(inst)
    if inst._flash > 0 then
        local k = inst._flash * inst._flash
        inst.components.colouradder:PushColour("wiresparks", .3 * k, .3 * k, 0, 0)
        inst._flash = inst._flash - .15
    else
        inst.components.colouradder:PopColour("wiresparks")
        inst._flash = nil
        inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateSparks)
    end
end

local function DoWireSparks(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/spot_light/electricity", nil, .5)
    SpawnPrefab("winona_battery_sparks").entity:AddFollower():FollowSymbol(inst.GUID, "wire", 0, 0, 0)
    if inst.components.updatelooper ~= nil then
        if inst._flash == nil then
            inst.components.updatelooper:AddOnUpdateFn(OnUpdateSparks)
        end
        inst._flash = 1
        OnUpdateSparks(inst)
    end
end

local function OnConnectCircuit(inst)--, node)
    if not inst._wired then
        inst._wired = true
        inst.AnimState:ClearOverrideSymbol("wire")
        if not POPULATING then
            DoWireSparks(inst)
        end
    end
    OnCircuitChanged(inst)
end

local function OnDisconnectCircuit(inst)--, node)
    if inst.components.circuitnode:IsConnected() then
        OnCircuitChanged(inst)
    elseif inst._wired then
        inst._wired = nil
        --This will remove mouseover as well (rather than just :Hide("wire"))
        inst.AnimState:OverrideSymbol("wire", "winona_spotlight", "dummy")
        DoWireSparks(inst)
		SetPowered(inst, false)
    end
end

--------------------------------------------------------------------------

local function OnSave(inst, data)
	if inst.destroyed then
		data.destroyed = true
	elseif inst.components.burnable and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
        data.lightdir = inst.Transform:GetRotation()
        if data.lightdir == 0 then
            data.lightdir = nil
        end
    else
		data.lightdist = inst._lightdist:value() > inst.MIN_RANGE and inst._lightdist:value() or nil
        data.lightdir = inst._lightdir:value() ~= 0 and inst._lightdir:value() or nil
        data.power = inst._powertask ~= nil and math.ceil(GetTaskRemaining(inst._powertask) * 1000) or nil

		--skilltree
		data.heated = inst._heated:value() or nil
		data.ranged = inst._ranged:value() or nil
		data.engineerid = inst._engineerid
    end
end

local function OnLoad(inst, data)
    if data ~= nil then
		if data.destroyed then
			OnWorkFinished(inst)
		elseif data.burnt then
            inst.components.burnable.onburnt(inst)
            if data.lightdir ~= nil then
                inst.Transform:SetRotation(data.lightdir)
            end
        else
			--skilltree
			inst._heated:set(data.heated or false)
			inst._ranged:set(data.ranged or false)
			inst._engineerid = data.engineerid
			ApplySkillBonuses(inst)

            local dirty = false
            if data.lightdir ~= nil and data.lightdir ~= inst._lightdir:value() then
                inst._lightdir:set(data.lightdir)
                inst._curlightdir = data.lightdir
                dirty = true
            end
            if data.power ~= nil then
                AddBatteryPower(inst, math.max(2 * FRAMES, data.power / 1000))
            end
			if data.lightdist ~= nil and data.lightdist ~= inst._lightdist:value() and data.lightdist > inst.MIN_RANGE and inst._lightdist:value() > 0 then
                inst._lightdist:set(data.lightdist)
                inst._curlightdist = inst._curlightdist ~= nil and data.lightdist or nil
                dirty = true
            end
            if dirty then
                if inst._lightdist:value() > 0 then
                    UpdateLightValues(inst, inst._lightdir:value(), inst._lightdist:value())
                elseif inst._curlightdir ~= nil then
                    inst._headinst.Transform:SetEightFaced()
                    inst._headinst.Transform:SetRotation(inst._curlightdir)
                    SetHeadTilt(inst._headinst, 3, false)
                end
            end
        end
    elseif inst._lightdist:value() <= 0 and inst._headinst._tilt == 1 and inst._headinst.Transform:GetRotation() == 0 then
        --never been turned on
        inst._headinst.Transform:SetTwoFaced()
    end

    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    if inst.components.workable:CanBeWorked() and not inst:HasTag("burnt") then
        --Enable connections, but leave the initial connection to batteries' OnPostLoad
        inst.components.circuitnode:ConnectTo(nil)
    end
end

local function OnInit(inst)
    inst._inittask = nil
    inst.components.circuitnode:ConnectTo("engineeringbattery")
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	inst:SetPhysicsRadiusOverride(0.5)
	MakeObstaclePhysics(inst, inst.physicsradiusoverride)

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.PLACER_DEFAULT] / 2)

    inst.Transform:SetEightFaced()

    inst:AddTag("engineering")
	inst:AddTag("engineeringbatterypowered")
    inst:AddTag("spotlight")
    inst:AddTag("structure")

    inst.AnimState:SetBank("winona_spotlight")
    inst.AnimState:SetBuild("winona_spotlight")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:Hide("light")
    inst.AnimState:Hide("light_tilt1")
    inst.AnimState:Hide("light_tilt2")
    inst.AnimState:Hide("light_shaft")
    inst.AnimState:Hide("light_shaft_tilt1")
    inst.AnimState:Hide("light_shaft_tilt2")
    --disable mouseover over light_shaft (hidden layers still contribute to mouseover!)
    inst.AnimState:OverrideSymbol("light_shimmer", "winona_spotlight", "dummy")
    --This will remove mouseover as well (rather than just :Hide("wire"))
    inst.AnimState:OverrideSymbol("wire", "winona_spotlight", "dummy")

    inst.MiniMapEntity:SetIcon("winona_spotlight.png")

    inst._lightinst = CreateLight()
    inst._lightinst.entity:SetParent(inst.entity)
    inst._lightdir = net_float(inst.GUID, "winona_spotlight._lightdir")
    inst._lightdist = net_float(inst.GUID, "winona_spotlight._lightdist", "lightdistdirty")
    inst._lightoffset = net_tinybyte(inst.GUID, "winona_spotlight._lightoffset")
    inst._lightdist:set(0)
    inst._curlightdir = nil
    inst._curlightdist = nil

	inst.RADIUS = TUNING.WINONA_SPOTLIGHT_RADIUS
	inst.MIN_RANGE = TUNING.WINONA_SPOTLIGHT_MIN_RANGE
	inst.MAX_RANGE = TUNING.WINONA_SPOTLIGHT_MAX_RANGE

	--skilltree
	inst._heated = net_bool(inst.GUID, "winona_spotlight._heated", "skillsdirty")
	inst._ranged = net_bool(inst.GUID, "winona_spotlight._ranged", "skillsdirty")

    --Dedicated server does not need deployhelper
    if not TheNet:IsDedicated() then
        inst:AddComponent("deployhelper")
        inst.components.deployhelper:AddRecipeFilter("winona_spotlight")
        inst.components.deployhelper:AddRecipeFilter("winona_catapult")
        inst.components.deployhelper:AddRecipeFilter("winona_battery_low")
        inst.components.deployhelper:AddRecipeFilter("winona_battery_high")
		inst.components.deployhelper:AddKeyFilter("winona_battery_engineering")
        inst.components.deployhelper.onenablehelper = OnEnableHelper
		inst.components.deployhelper.onstarthelper = OnStartHelper
    end

    inst:AddComponent("updatelooper")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
		inst.components.updatelooper:AddOnUpdateFn(OnUpdateLightClient)
        inst:ListenForEvent("lightdistdirty", OnLightDistDirty)
		inst:ListenForEvent("skillsdirty", ApplySkillBonuses)

        return inst
    end

    inst.scrapbook_specialinfo = "WINONASPOTLIGHT"
    inst.scrapbook_anim = "idle_placer"

    inst._headinst = SpawnPrefab("winona_spotlight_head")
    inst._headinst.entity:SetParent(inst.entity)

    inst.highlightchildren = { inst._headinst }

    inst._state = 1

	inst:AddComponent("portablestructure")
	inst.components.portablestructure:SetOnDismantleFn(OnDismantle)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("colouradder")
	inst.components.colouradder:AttachChild(inst._headinst)

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnWorkCallback(OnWorked)
    inst.components.workable:SetOnFinishCallback(OnWorkFinished)

    inst:AddComponent("circuitnode")
    inst.components.circuitnode:SetRange(TUNING.WINONA_BATTERY_RANGE)
	inst.components.circuitnode:SetFootprint(TUNING.WINONA_ENGINEERING_FOOTPRINT)
    inst.components.circuitnode:SetOnConnectFn(OnConnectCircuit)
    inst.components.circuitnode:SetOnDisconnectFn(OnDisconnectCircuit)
    inst.components.circuitnode.connectsacrossplatforms = false
	inst.components.circuitnode.rangeincludesfootprint = true

	inst:AddComponent("powerload")
	inst.components.powerload:SetLoad(TUNING.WINONA_SPOTLIGHT_POWER_LOAD_OFF, true)

    inst:ListenForEvent("onbuilt", OnBuilt)
    inst:ListenForEvent("engineeringcircuitchanged", OnCircuitChanged)
	inst:ListenForEvent("winona_spotlightskillchanged", function(world, user)
		if user.userid == inst._engineerid and not inst:HasTag("burnt") then
			if ConfigureSkillTreeUpgrades(inst, user) then
				ApplySkillBonuses(inst)
			end
		end
	end, TheWorld)

    MakeHauntableWork(inst)
    MakeMediumBurnable(inst, nil, nil, true)
    MakeMediumPropagator(inst)
    inst.components.burnable:SetOnBurntFn(OnBurnt)

    inst.OnLoad = OnLoad
    inst.OnSave = OnSave
    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake
	inst.OnRemoveEntity = OnRemoveEntity
    inst.AddBatteryPower = AddBatteryPower

	--skilltree
	inst._engineerid = nil

    inst._wired = nil
    inst._flash = nil
    inst._target = nil
	inst._updatedelay = nil
	inst._ledblinkdelay = nil
    inst._inittask = inst:DoTaskInTime(0, OnInit)

    return inst
end

--------------------------------------------------------------------------

local function CreateLightShaft()
	local inst = CreateEntity()

	inst:AddTag("decor") --no mouse over
	inst:AddTag("NOCLICK")
	--[[Non-networked entity]]
	--inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()

	inst.AnimState:SetBank("winona_spotlight")
	inst.AnimState:SetBuild("winona_spotlight")
	inst.AnimState:PlayAnimation("light_shimmer", true)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:SetLightOverride(LIGHT_OVERRIDE_LIGHTSHAFT)

	return inst
end

--------------------------------------------------------------------------

local function Head_SetHeated(inst, heated)
	if inst.lightshaft then --dedi server does not have this
		local anim = heated and "light_shimmer_heat" or "light_shimmer"
		if not inst.lightshaft.AnimState:IsCurrentAnimation(anim) then
			inst.lightshaft.AnimState:PlayAnimation(anim, true)
		end
	end
end

local function OnHeadEntityReplicated(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil and parent.prefab == "winona_spotlight" then
        parent.highlightchildren = { inst }
        parent._clientheadinst = inst
		if parent._heated:value() and not TheWorld.state.issummer then
			inst:SetHeated(true)
		end
    end
end

local function headfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

	inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.Transform:SetEightFaced()

    inst.AnimState:SetBank("winona_spotlight")
    inst.AnimState:SetBuild("winona_spotlight")
	inst.AnimState:PlayAnimation("idle")
    inst.AnimState:Hide("leg")
    inst.AnimState:Hide("ground_shadow")
    inst.AnimState:Hide("wire")
    inst.AnimState:SetFinalOffset(1)
    SetHeadTilt(inst, 1, false)

    inst.entity:SetPristine()

	--Dedicated server does not need to spawn the local fx
	if not TheNet:IsDedicated() then
		inst.lightshaft = CreateLightShaft()
		inst.lightshaft.entity:SetParent(inst.entity)
		inst.lightshaft.Follower:FollowSymbol(inst.GUID, "light_shaft_follow", 0, 0, 0, true)
	end

	inst.SetHeated = Head_SetHeated

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = OnHeadEntityReplicated

        return inst
    end

    inst:AddComponent("colouradder")

    return inst
end

--------------------------------------------------------------------------

local function CreatePlacerSpotlight()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")

    inst.Transform:SetTwoFaced()

    inst.AnimState:SetBank("winona_spotlight")
    inst.AnimState:SetBuild("winona_spotlight")
    inst.AnimState:PlayAnimation("idle_placer")
    inst.AnimState:SetLightOverride(1)

    return inst
end

local function placer_postinit_fn(inst)
    --Show the spotlight placer on top of the spotlight range ground placer
    --Also add the small battery range indicator

    local placer2 = CreatePlacerBatteryRing()
    placer2.entity:SetParent(inst.entity)
    inst.components.placer:LinkEntity(placer2)

    placer2 = CreatePlacerSpotlight()
    placer2.entity:SetParent(inst.entity)
    inst.components.placer:LinkEntity(placer2)

    inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

	inst.deployhelper_key = "winona_battery_engineering"
end

--------------------------------------------------------------------------

local function OnDeploy(inst, pt, deployer)
	local obj = SpawnPrefab("winona_spotlight")
	if obj then
		obj.Physics:SetCollides(false)
		obj.Physics:Teleport(pt.x, 0, pt.z)
		obj.Physics:SetCollides(true)
		DoBuiltOrDeployed(obj, deployer, 22, "meta4/winona_spotlight/deploy")
		PreventCharacterCollisionsWithPlacedObjects(obj)
	end
	inst:Remove()
end

local function itemfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("winona_spotlight")
	inst.AnimState:SetBuild("winona_spotlight")
	inst.AnimState:PlayAnimation("idle_ground")
	inst.scrapbook_anim = "idle_ground"

	inst:AddTag("portableitem")

	MakeInventoryFloatable(inst, "large", 0.5, { 0.65, 1.05, 1 })

	inst:SetPrefabNameOverride("winona_spotlight")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")

	inst:AddComponent("deployable")
	inst.components.deployable.restrictedtag = "handyperson"
	inst.components.deployable.ondeploy = OnDeploy
	inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.PLACER_DEFAULT)

	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HUANT_TINY)

	MakeMediumBurnable(inst)
	MakeMediumPropagator(inst)

	return inst
end

--------------------------------------------------------------------------

return Prefab("winona_spotlight", fn, assets, prefabs),
    Prefab("winona_spotlight_head", headfn, assets_head),
	MakePlacer("winona_spotlight_item_placer", "winona_spotlight_placement", "winona_spotlight_placement", "idle", true, nil, nil, nil, nil, nil, placer_postinit_fn),
	Prefab("winona_spotlight_item", itemfn, assets_item, prefabs_item)
