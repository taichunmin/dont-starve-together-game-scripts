require("prefabutil")

local assets =
{
    Asset("ANIM", "anim/winona_catapult.zip"),
    Asset("ANIM", "anim/winona_catapult_placement.zip"),
	Asset("ANIM", "anim/winona_catapult_projectile.zip"),
    Asset("ANIM", "anim/winona_battery_placement.zip"),
}

local assets_item =
{
	Asset("ANIM", "anim/winona_catapult.zip"),
}

local prefabs =
{
    "winona_catapult_projectile",
    "winona_battery_sparks",
    "collapse_small",
	"winona_catapult_item",
}

local prefabs_item =
{
	"winona_catapult",
}

local brain = require("brains/winonacatapultbrain")

--------------------------------------------------------------------------

local function CalcAoeRadiusMult(inst)
	return TUNING.SKILLS.WINONA.CATAPULT_AOE_RADIUS_MULT[inst._aoe] or 1
end

local function CalcSleepModeDelay(inst)
	return inst._engineerid and TUNING.WINONA_CATAPULT_SLEEP_MODE_DELAY or TUNING.WINONA_CATAPULT_BASIC_SLEEP_MODE_DELAY
end

local function RefreshAttackPeriod(inst)
	inst.components.combat:SetAttackPeriod(
		TUNING.WINONA_CATAPULT_ATTACK_PERIOD *
		(TUNING.SKILLS.WINONA.CATAPULT_ATTACK_PERIOD_MULT[inst._speed] or 1) *
		(inst.components.timer:TimerExists("boost") and TUNING.SKILLS.WINONA.CATAPULT_BOOST_MULT or 1)
	)
end

local function ApplySkillBonuses(inst)
	RefreshAttackPeriod(inst)
	inst.AOE_RADIUS = TUNING.WINONA_CATAPULT_AOE_RADIUS * CalcAoeRadiusMult(inst)
end

local function ConfigureSkillTreeUpgrades(inst, builder)
	local skilltreeupdater = builder and builder.components.skilltreeupdater or nil

	local speed = skilltreeupdater and
		(	(skilltreeupdater:IsActivated("winona_catapult_speed_3") and 3) or
			(skilltreeupdater:IsActivated("winona_catapult_speed_2") and 2) or
			(skilltreeupdater:IsActivated("winona_catapult_speed_1") and 1)
		) or 0

	local aoe = skilltreeupdater and
		(	(skilltreeupdater:IsActivated("winona_catapult_aoe_3") and 3) or
			(skilltreeupdater:IsActivated("winona_catapult_aoe_2") and 2) or
			(skilltreeupdater:IsActivated("winona_catapult_aoe_1") and 1)
		) or 0

	local dirty = inst._speed ~= speed or inst._aoe ~= aoe

	inst._speed = speed
	inst._aoe = aoe
	inst._engineerid = builder and builder:HasTag("handyperson") and builder.userid or nil

	return dirty
end

--------------------------------------------------------------------------

local function IsTargetTooFar(inst, target)
	return not inst:IsNear(target, TUNING.WINONA_CATAPULT_MAX_RANGE + target:GetPhysicsRadius(0))
end

local function IsTargetTooClose(inst, target)
	return inst:IsNear(target, math.max(0, TUNING.WINONA_CATAPULT_TARGETING_MIN_RANGE - target:GetPhysicsRadius(0)))
end

local function IsTargetTooFarOrTooClose(inst, target)
	local dsq = inst:GetDistanceSqToInst(target)
	local physrad = target:GetPhysicsRadius(0)
	local range = TUNING.WINONA_CATAPULT_MAX_RANGE + physrad
	if dsq >= range * range then
		return true --too far
	end
	range = TUNING.WINONA_CATAPULT_TARGETING_MIN_RANGE - physrad
	if range > 0 and dsq < range * range then
		return true --too close
	end
	return false
end

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "INLIMBO", "player", "engineering", "eyeturret" }
local PHYSICS_PADDING = 3

local function RetargetFn(inst)
	--V2C: redundant, combat component stops retargeting when slept
	--[[if inst:IsAsleep() then
		return
	end]]

    local target = inst.components.combat.target
	if target and not IsTargetTooFarOrTooClose(inst, target) then
        --keep current target
        return
    end

    local playertargets = {}
    for i, v in ipairs(AllPlayers) do
        if v.components.combat.target ~= nil then
            playertargets[v.components.combat.target] = true
        end
    end

    local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, TUNING.WINONA_CATAPULT_MAX_RANGE + PHYSICS_PADDING, RETARGET_MUST_TAGS, RETARGET_CANT_TAGS)
    local tooclosetarget = nil
    for i, v in ipairs(ents) do
        if v ~= inst and
            v ~= target and
            v.entity:IsVisible() and
			not inst:IsTargetTooFar(v) and
            inst.components.combat:CanTarget(v) and
            (   playertargets[v] or
                v.components.combat:TargetIs(inst) or
                (v.components.combat.target ~= nil and v.components.combat.target:HasTag("player"))
            ) then
			if not inst:IsTargetTooClose(v) then
                --new target between the attackable ranges
                return v, target ~= nil
            elseif tooclosetarget == nil then
                tooclosetarget = v
            end
        end
    end
    return tooclosetarget, target ~= nil
end

local function ShouldKeepTarget(inst, target)
	return inst:IsActiveMode()
		and target
        and target:IsValid()
        and target.components.health ~= nil
        and not target.components.health:IsDead()
		and inst:IsNear(target, TUNING.WINONA_CATAPULT_MAX_RANGE + TUNING.WINONA_CATAPULT_KEEP_TARGET_BUFFER + target:GetPhysicsRadius(0))
end

local function ShareTargetFn(dude)
	return dude:HasTag("catapult") and (dude.IsActiveMode == nil or dude:IsActiveMode()) and not dude:IsAsleep()
end

local function ShouldAggro(combat, target)
    if target:HasTag("player") then
        return TheNet:GetPVPEnabled()
    end
    return true
end

local function ForceDropTarget(inst, target)
    if inst.components.combat ~= nil and inst.components.combat:TargetIs(target) then
        inst.components.combat:DropTarget()
    end
end

local function OnNewCombatTarget(inst, data)
	inst.components.timer:PauseTimer("active_time")
	inst.components.timer:SetTimeLeft("active_time", CalcSleepModeDelay(inst))
end

local function OnDroppedTarget(inst, data)
	inst.components.timer:ResumeTimer("active_time")
end

local function OnAttacked(inst, data)
	if inst:IsActiveMode() then
		local attacker = data ~= nil and data.attacker or nil
		if attacker ~= nil and not PreventTargetingOnAttacked(inst, attacker, "player") then
			if not IsTargetTooFarOrTooClose(inst, attacker) then
				inst.components.combat:SetTarget(attacker)
			else
				inst.components.combat:SuggestTarget(attacker)
			end
			inst.components.combat:ShareTarget(attacker, 15, ShareTargetFn, 10)
		end
	end
    if data ~= nil and data.damage == 0 and data.weapon ~= nil and (data.weapon:HasTag("rangedlighter") or data.weapon:HasTag("extinguisher")) then
        --V2C: weapon may be invalid by the time it reaches stategraph event handler, so ues a lua property instead
        data.weapon._nocatapulthit = true
    end
end

local function ChangeToItem(inst)
	local item = SpawnPrefab("winona_catapult_item")
	item.Transform:SetPosition(inst.Transform:GetWorldPosition())
	item.AnimState:PlayAnimation("collapse")
	item.AnimState:PushAnimation("idle_ground", false)
	item.SoundEmitter:PlaySound("meta4/winona_catapult/collapse")
	if inst._wired then
		item.SoundEmitter:PlaySound("dontstarve/common/together/spot_light/electricity", nil, .5)
		SpawnPrefab("winona_battery_sparks").Transform:SetPosition(inst.Transform:GetWorldPosition())
	end
end

local function OnWorked(inst, worker, workleft, numworks)
    inst.components.workable:SetWorkLeft(4)
    inst.components.combat:GetAttacked(worker, numworks * TUNING.WINONA_CATAPULT_HEALTH / 4, worker.components.inventory ~= nil and worker.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil)
end

local function OnWorkedBurnt(inst, worker)
	inst.components.workable:SetWorkable(false)
	inst:AddTag("NOCLICK")
	inst.persists = false
	inst.Physics:SetActive(false)
    inst.components.lootdropper:DropLoot()

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")

	inst.AnimState:PlayAnimation("burntbreak")
	inst:DoTaskInTime(1, ErodeAway)
end

local function OnDeath(inst)
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    inst.components.circuitnode:Disconnect()
	inst.components.powerload:SetLoad(0)
    inst.components.workable:SetWorkable(false)
    if inst.components.burnable ~= nil then
        if inst.components.burnable:IsBurning() then
            inst.components.burnable:Extinguish()
        end
        inst.components.burnable.canlight = false
    end
	inst.persists = false
    inst.Physics:SetActive(false)
    inst.components.lootdropper:DropLoot()
	inst.sg:GoToState("death")

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("none")
end

local function OnBurnt(inst)
    DefaultBurntStructureFn(inst)

    inst:ClearStateGraph()
    inst.SoundEmitter:KillAllSounds()

    inst:RemoveEventCallback("attacked", OnAttacked)
    inst:RemoveEventCallback("death", OnDeath)

    inst.components.workable:SetOnWorkCallback(nil)
    inst.components.workable:SetOnFinishCallback(OnWorkedBurnt)

    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    inst.components.circuitnode:Disconnect()
	inst.components.powerload:SetLoad(0)

    inst:RemoveComponent("health")
    inst:RemoveComponent("combat")
	inst:RemoveComponent("portablestructure")
	inst:RemoveComponent("activatable")

    inst:AddTag("notarget") -- just in case???
end

local function DoBuiltOrDeployed(inst, doer, state)
	ConfigureSkillTreeUpgrades(inst, doer)
	ApplySkillBonuses(inst)

    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    inst.components.circuitnode:Disconnect()
	inst.components.powerload:SetLoad(TUNING.WINONA_CATAPULT_POWER_LOAD_IDLE)
	inst.sg:GoToState(state)
end

local function OnBuilt(inst, data)
	DoBuiltOrDeployed(inst, data and data.builder or nil, "place")
end

local function OnDismantle(inst)--, doer)
	if inst.components.health and not inst.components.health:IsDead() then
		ChangeToItem(inst)
		inst:Remove()
	end
end

--------------------------------------------------------------------------

local function OnHealthDelta(inst)
    if inst.components.health:IsHurt() then
        inst.components.health:StartRegen(TUNING.WINONA_CATAPULT_HEALTH_REGEN, TUNING.WINONA_CATAPULT_HEALTH_REGEN_PERIOD)
    else
        inst.components.health:StopRegen()
    end
end

local function OnSave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    else
        data.power = inst._powertask ~= nil and math.ceil(GetTaskRemaining(inst._powertask) * 1000) or nil

		--skilltree
		data.speed = inst._speed > 0 and inst._speed or nil
		data.aoe = inst._aoe > 0 and inst._aoe or nil
		data.engineerid = inst._engineerid
    end
end

local function OnLoad(inst, data)
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    else
		--skilltree
		if data then
			inst._speed = data.speed or 0
			inst._aoe = data.aoe or 0
			inst._engineerid = data.engineerid
			ApplySkillBonuses(inst)
		else
			--since we skipped ApplySkillBonuses, need to do this in case we have "boost"
			RefreshAttackPeriod(inst)
		end

        if data ~= nil and data.power ~= nil then
            inst:AddBatteryPower(math.max(2 * FRAMES, data.power / 1000))
			inst:SetActiveMode(inst:IsActiveMode())
            if inst.sg:HasStateTag("idle") then
                inst.sg:GoToState("idle", true) --loading = true
            end
		else
			inst:SetActiveMode(false)
        end
        --Enable connections, but leave the initial connection to batteries' OnPostLoad
        inst.components.circuitnode:ConnectTo(nil)
        OnHealthDelta(inst)
    end
end

local function OnLoadPostPass(inst, newents, data)
    if inst.components.savedrotation then
        local savedrotation = data ~= nil and data.savedrotation ~= nil and data.savedrotation.rotation or 0
        inst.components.savedrotation:ApplyPostPassRotation(savedrotation)
    end
end

local function OnInit(inst)
    inst._inittask = nil
    inst.components.circuitnode:ConnectTo("engineeringbattery")
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

local function OnUpdateVolleyHelper(helperinst)
	if not helperinst.placerinst:IsValid() then
		helperinst.components.updatelooper:RemoveOnUpdateFn(OnUpdateVolleyHelper)
		helperinst.AnimState:SetAddColour(0, 0, 0, 0)
	else
		local distsq = helperinst:GetDistanceSqToInst(helperinst.placerinst)
		--<= >= match Volley spell FindEntities and min range tests
		if distsq <= TUNING.WINONA_CATAPULT_MAX_RANGE * TUNING.WINONA_CATAPULT_MAX_RANGE and
			distsq >= TUNING.WINONA_CATAPULT_MIN_RANGE * TUNING.WINONA_CATAPULT_MIN_RANGE and
			helperinst.entity:GetParent():IsPowered()
		then
			helperinst.AnimState:SetAddColour(0.25, 0.75, 0.25, 0)
		else
			helperinst.AnimState:SetAddColour(0, 0, 0, 0)
		end
	end
end

local function OnUpdateElementalVolleyHelper(helperinst)
	if not helperinst.placerinst:IsValid() then
		helperinst.components.updatelooper:RemoveOnUpdateFn(OnUpdateVolleyHelper)
		helperinst.AnimState:SetAddColour(0, 0, 0, 0)
	else
		local canshadow, canlunar
		local skilltreeupdater = ThePlayer and ThePlayer.components.skilltreeupdater or nil
		if skilltreeupdater then
			canshadow = skilltreeupdater:IsActivated("winona_shadow_3")
			canlunar = skilltreeupdater:IsActivated("winona_lunar_3")
		end

		local inrange
		if (canshadow or canlunar) and
			helperinst.entity:GetParent():HasPowerAlignment((not canshadow and "lunar") or (not canlunar and "shadow") or nil--[[either]]) and
			helperinst.entity:GetParent():IsPowered()
		then
			local distsq = helperinst:GetDistanceSqToInst(helperinst.placerinst)
			--<= >= match Volley spell FindEntities and min range tests
			if distsq <= TUNING.WINONA_CATAPULT_MAX_RANGE * TUNING.WINONA_CATAPULT_MAX_RANGE and
				distsq >= TUNING.WINONA_CATAPULT_MIN_RANGE * TUNING.WINONA_CATAPULT_MIN_RANGE
			then
				inrange = true
			end
		end

		if inrange then
			helperinst.AnimState:SetAddColour(0.25, 0.75, 0.25, 0)
		else
			helperinst.AnimState:SetAddColour(0, 0, 0, 0)
		end
	end
end

local function OnUpdateWakeUpHelper(helperinst)
	if not helperinst.placerinst:IsValid() then
		helperinst.components.updatelooper:RemoveOnUpdateFn(OnUpdateVolleyHelper)
		helperinst.AnimState:SetAddColour(0, 0, 0, 0)
	else
		local distsq = helperinst:GetDistanceSqToInst(helperinst.placerinst)
		--<= match WakeUp spell FindEntities
		if distsq <= TUNING.WINONA_CATAPULT_MAX_RANGE * TUNING.WINONA_CATAPULT_MAX_RANGE and
			helperinst.entity:GetParent():IsPowered()
		then
			helperinst.AnimState:SetAddColour(0.25, 0.75, 0.25, 0)
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

    inst.AnimState:SetBank("winona_catapult_placement")
    inst.AnimState:SetBuild("winona_catapult_placement")
	inst.AnimState:PlayAnimation("idle_15")
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
			if recipename == "catapult_volley" then
				inst.helper = CreatePlacerBatteryRing()
				inst.helper.entity:SetParent(inst.entity)
				inst.helper:AddComponent("updatelooper")
				inst.helper.components.updatelooper:AddOnUpdateFn(OnUpdateVolleyHelper)
				inst.helper.placerinst = placerinst
				OnUpdateVolleyHelper(inst.helper)
			elseif recipename == "catapult_elementalvolley" then
				inst.helper = CreatePlacerBatteryRing()
				inst.helper.entity:SetParent(inst.entity)
				inst.helper:AddComponent("updatelooper")
				inst.helper.components.updatelooper:AddOnUpdateFn(OnUpdateElementalVolleyHelper)
				inst.helper.placerinst = placerinst
				OnUpdateElementalVolleyHelper(inst.helper)
			elseif recipename == "catapult_wakeup" then
				inst.helper = CreatePlacerBatteryRing()
				inst.helper.entity:SetParent(inst.entity)
				inst.helper:AddComponent("updatelooper")
				inst.helper.components.updatelooper:AddOnUpdateFn(OnUpdateWakeUpHelper)
				inst.helper.placerinst = placerinst
				OnUpdateWakeUpHelper(inst.helper)
			elseif recipename == "winona_catapult" or (placerinst and placerinst.prefab == "winona_catapult_item_placer") then
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
	if inst.AnimState:IsCurrentAnimation("deploy") or inst.AnimState:IsCurrentAnimation("place") then
		inst.components.deployhelper:StopHelper()
	end
end

--------------------------------------------------------------------------

local function GetStatus(inst)
    return (inst:HasTag("burnt") and "BURNT")
        or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning() and "BURNING")
        or (inst._powertask == nil and "OFF")
        or nil
end

local LED_BLINK_DELAY = 1.5
local LED_BLINK_TIME = 0.75

local function SetLedEnabled(inst, enabled)
	if enabled then
		inst.AnimState:OverrideSymbol("led_off", "winona_spotlight", "led_on")
		inst.AnimState:SetSymbolBloom("led_off")
		inst.AnimState:SetSymbolLightOverride("led_off", 0.5)
		inst.AnimState:SetSymbolLightOverride("led_parts", 0.24)
		inst.AnimState:SetSymbolLightOverride("base_bottom", 0.08)
		inst.AnimState:SetSymbolLightOverride("base", 0.08)
		inst.AnimState:SetSymbolLightOverride("cog", 0.04)
		inst.AnimState:SetSymbolLightOverride("arm", 0.04)
	else
		inst.AnimState:ClearOverrideSymbol("led_off")
		inst.AnimState:ClearSymbolBloom("led_off")
		inst.AnimState:SetSymbolLightOverride("led_off", 0)
		inst.AnimState:SetSymbolLightOverride("led_parts", 0)
		inst.AnimState:SetSymbolLightOverride("base_bottom", 0)
		inst.AnimState:SetSymbolLightOverride("base", 0)
		inst.AnimState:SetSymbolLightOverride("cog", 0)
		inst.AnimState:SetSymbolLightOverride("arm", 0)
	end
end

local function CancelLedBlink(inst)
	if inst._ledblinktask then
		inst._ledblinktask:Cancel()
		inst._ledblinktask = nil
		inst._ledblinkon = nil
	else
		inst._ledblinktasktime = nil
	end
	inst.OnEntitySleep = nil
	inst.OnEntityWake = nil
end

local function CancelLedRapidBlink(inst)
	if inst._ledrapidblinktask then
		inst._ledrapidblinktask:Cancel()
		inst._ledrapidblinktask = nil
		inst._ledrapidblinkcount = nil
	end
end

local function OnLedRapidBlink(inst)
	SetLedEnabled(inst, (inst._ledrapidblinkcount % 2) == 0)
	if inst._ledrapidblinkcount > 0 then
		inst._ledrapidblinkcount = inst._ledrapidblinkcount - 1
	else
		CancelLedRapidBlink(inst)
	end
end

local function DoLedRapidBlinkOn(inst, initialon)
	CancelLedBlink(inst)
	if inst._ledrapidblinktask then
		inst._ledrapidblinktask:Cancel()
	end
	inst._ledrapidblinkcount = initialon and 4 or 3
	inst._ledrapidblinktask = inst:DoPeriodicTask(0.07, OnLedRapidBlink)
	OnLedRapidBlink(inst)
end

local function SetLedStatusOn(inst)
	CancelLedBlink(inst)
	if inst._ledrapidblinktask == nil then
		SetLedEnabled(inst, true)
	end
end

local function SetLedStatusOff(inst)
	CancelLedBlink(inst)
	CancelLedRapidBlink(inst)
	SetLedEnabled(inst, false)
end

local function OnLedBlink(inst)
	inst._ledblinkon = not inst._ledblinkon
	inst._ledblinktask = inst:DoTaskInTime(inst._ledblinkon and LED_BLINK_TIME or LED_BLINK_DELAY, OnLedBlink)
	SetLedEnabled(inst, inst._ledblinkon)
end

local function OnEntitySleep(inst)
	if inst._ledblinktask then
		inst._ledblinktasktime = GetTaskRemaining(inst._ledblinktask)
		inst._ledblinktask:Cancel()
		inst._ledblinktask = nil
	end
	inst.components.combat:DropTarget()
end

local function OnEntityWake(inst)
	if inst._ledblinktasktime then
		inst._ledblinktask = inst:DoTaskInTime(inst._ledblinktasktime, OnLedBlink)
		inst._ledblinktasktime = nil
	end
end

local function SetLedStatusBlink(inst, initialon)
	CancelLedRapidBlink(inst)
	if not (inst._ledblinktask or inst._ledblinktasktime) then
		inst.OnEntitySleep = OnEntitySleep
		inst.OnEntityWake = OnEntityWake
		SetLedEnabled(inst, initialon)
		inst._ledblinkon = initialon
		local delay = initialon and LED_BLINK_TIME or LED_BLINK_DELAY
		if inst:IsAsleep() then
			inst._ledblinktasktime = delay
		else
			inst._ledblinktask = inst:DoTaskInTime(delay, OnLedBlink)
		end
	end
end

local function OnTimerDone(inst, data)
	if data then
		if data.name == "active_time" then
			inst:SetActiveMode(false)
		elseif data.name == "boost" then
			RefreshAttackPeriod(inst)
		end
	end
end

local function OnCatapultSpeedBoost(inst)
	if inst:IsActiveMode() then
		if inst.components.timer:TimerExists("boost") then
			inst.components.timer:SetTimeLeft("boost", TUNING.SKILLS.WINONA.CATAPULT_BOOST_DURATION)
		else
			inst.components.timer:StartTimer("boost", TUNING.SKILLS.WINONA.CATAPULT_BOOST_DURATION)
			RefreshAttackPeriod(inst)
		end
	end
end

local function SetActiveMode(inst, active)
	if inst._autoactivetask then
		inst._autoactivetask:Cancel()
		inst._autoactivetask = nil
	end
	local loading = POPULATING
	if not (active and inst._powertask) then
		inst.components.timer:StopTimer("active_time")
		inst.components.timer:StopTimer("boost")
		RefreshAttackPeriod(inst)
		inst:SetBrain(nil)
		inst:RemoveEventCallback("timerdone", OnTimerDone)
		inst:RemoveEventCallback("newcombattarget", OnNewCombatTarget)
		inst:RemoveEventCallback("droppedtarget", OnDroppedTarget)
		inst.components.combat:SetRetargetFunction(nil)
		inst.components.combat:SetTarget(nil)
		inst.components.powerload:SetLoad(TUNING.WINONA_CATAPULT_POWER_LOAD_SLEEP_MODE, true)
		if inst._powertask then
			SetLedStatusBlink(inst, true)
		else
			SetLedStatusOff(inst)
		end
		if not loading then
			inst:PushEvent("togglepower", { ison = false })
		end
	elseif loading or not inst.components.timer:TimerExists("active_time") then
		if loading then
			--no target on load, but could've saved while we had target
			inst.components.timer:ResumeTimer("active_time")
		else
			inst.components.timer:StartTimer("active_time", CalcSleepModeDelay(inst), inst.components.combat:HasTarget())
		end
		inst.components.combat:SetRetargetFunction(1, RetargetFn)
		inst:ListenForEvent("timerdone", OnTimerDone)
		inst:ListenForEvent("newcombattarget", OnNewCombatTarget)
		inst:ListenForEvent("droppedtarget", OnDroppedTarget)
		inst:SetBrain(brain)
		if not inst:IsAsleep() then
			inst:RestartBrain()
		end
		SetLedStatusOn(inst)
		if not loading then
			inst:PushEvent("togglepower", { ison = true })
		end
	end
end

local function OnAutoActiveTaskEnded(inst)
	inst._autoactivetask = nil
end

local function OnReadyForConnection(inst)
	if inst._autoactivetask then
		inst._autoactivetask:Cancel()
		inst._autoactivetask = nil
	end
	inst.components.circuitnode:ConnectTo("engineeringbattery")
	if inst.components.circuitnode:IsConnected() then
		inst._autoactivetask = inst:DoTaskInTime(0.55, OnAutoActiveTaskEnded)

		if inst._engineerid then
			for i, v in ipairs(AllPlayers) do
				if v.userid == inst._engineerid then
					inst.components.circuitnode:ForEachNode(function(inst, node)
						node:OnUsedIndirectly(v)
					end)
					break
				end
			end
		end
	end
end

local function OnAllowReactivate(inst)
	if inst.components.activatable then
		inst.components.activatable.inactive = true
	end
end

local function OnActivate(inst, doer)
	if (doer and doer.userid or nil) ~= inst._engineerid then
		if ConfigureSkillTreeUpgrades(inst, doer) then
			ApplySkillBonuses(inst)
		end
	end
	inst.components.circuitnode:ForEachNode(function(inst, node)
		node:OnUsedIndirectly(doer)
	end)
	DoLedRapidBlinkOn(inst, not inst:IsActiveMode())
	inst:SetActiveMode(true)
	--extend time, silent fail if timer doesn't exist (shouldn't happen tho!)
	inst.components.timer:SetTimeLeft("active_time", CalcSleepModeDelay(inst))
	inst:DoTaskInTime(1, OnAllowReactivate)
	return true
end

local function PowerOff(inst)
    inst._powertask = nil
	inst._ispowered:set(false)
	inst:SetActiveMode(false)
	inst:RemoveComponent("activatable")
end

local function AddBatteryPower(inst, power)
    local remaining = inst._powertask ~= nil and GetTaskRemaining(inst._powertask) or 0
    if power > remaining then
        if inst._powertask ~= nil then
            inst._powertask:Cancel()
        else
			inst._ispowered:set(true)
			SetLedStatusBlink(inst, true)

			inst:AddComponent("activatable")
			inst.components.activatable.standingaction = true
			inst.components.activatable.OnActivate = OnActivate
        end
        inst._powertask = inst:DoTaskInTime(power, PowerOff)
		if inst._autoactivetask then
			inst:SetActiveMode(true)
		end
    end
end

local function IsPowered(inst)
	return inst._ispowered:value()
end

local function OverrideActivateVerb(inst, doer)
	return STRINGS.ENGINEER_REMOTE.WAKEUP
end

local function IsActiveMode(inst)
	return inst.components.timer:TimerExists("active_time")
end

local function OnActiveWakeup(inst, data)
	if inst.components.activatable then
		inst.components.activatable.inactive = true
		inst.components.activatable:DoActivate(data and data.doer or nil)
	end
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

local ELEMENTS = { "shadow", "lunar", "hybrid" }
local ELEMENT_ID = table.invert(ELEMENTS)

local function HasPowerAlignment(inst, element)
	local poweredelement = inst._poweralignment:value()
	if element then
		return poweredelement == ELEMENT_ID[element]
			or poweredelement == ELEMENT_ID.hybrid
	end
	return poweredelement ~= 0
end

local function OnCircuitChanged(inst)
	local hasshadow, haslunar
	--Update our available element
    --Notify other connected batteries
	inst.components.circuitnode:ForEachNode(function(inst, node)
		node:PushEvent("engineeringcircuitchanged")

		if node.components.fueled and not node.components.fueled:IsEmpty() and not (node.IsOverloaded and node:IsOverloaded()) then
			local elem = node:CheckElementalBattery()
			if elem == "horror" then
				hasshadow = true
			elseif elem == "brilliance" then
				haslunar = true
			end
		end
	end)

	inst._poweralignment:set(hasshadow and (haslunar and ELEMENT_ID.hybrid or ELEMENT_ID.shadow) or (haslunar and ELEMENT_ID.lunar) or 0)
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
	if inst._autoactivetask then
		inst._autoactivetask:Cancel()
		inst._autoactivetask = nil
	end
    if inst.components.circuitnode:IsConnected() then
        OnCircuitChanged(inst)
    elseif inst._wired then
        inst._wired = nil
        --This will remove mouseover as well (rather than just :Hide("wire"))
        inst.AnimState:OverrideSymbol("wire", "winona_spotlight", "dummy")
        DoWireSparks(inst)
        if inst._powertask ~= nil then
            inst._powertask:Cancel()
            PowerOff(inst)
        end
    end
end

local function CreateElementalRock()
	local inst = CreateEntity()

	inst:AddTag("FX")
	--[[Non-networked entity]]
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()

	inst.Transform:SetSixFaced()

	inst.AnimState:SetBank("winona_catapult_projectile")
	inst.AnimState:SetBuild("winona_catapult_projectile")
	inst.AnimState:SetSymbolBloom("white_parts")
	inst.AnimState:SetSymbolLightOverride("white_parts", 0.1)
	inst.AnimState:SetSymbolLightOverride("red_parts", 1)

	return inst
end

local function OnElementDirty(inst)
	local element = ELEMENTS[inst._element:value()]
	if element then
		if inst._rockfx == nil then
			inst._rockfx = CreateElementalRock()
			inst._rockfx.entity:SetParent(inst.entity)
			inst._rockfx.Follower:FollowSymbol(inst.GUID, "projectile_swap", 0, 0, 0, true)
			inst.highlightchildren = { inst._rockfx }
			inst.AnimState:OverrideSymbol("projectile_swap", "winona_catapult", "dummy") --basically hide it
		end
		local anim = "swap_"..element
		if not inst._rockfx.AnimState:IsCurrentAnimation(anim) then
			inst._rockfx.AnimState:PlayAnimation(anim, true)
		end
	elseif inst._rockfx then
		inst._rockfx:Remove()
		inst._rockfx = nil
		inst.highlightchildren = nil
		inst.AnimState:ClearOverrideSymbol("projectile_swap")
	end
end

local function OnStartAttack(inst, element)
	--extend time, silent fail if timer doesn't exist (shouldn't happen tho!)
	inst.components.timer:SetTimeLeft("active_time", CalcSleepModeDelay(inst))

	local elemid = ELEMENT_ID[element] or 0
	if elemid ~= inst._element:value() then
		inst._element:set(elemid)
		--Dedicated server does not need to spawn the local fx
		if not TheNet:IsDedicated() then
			OnElementDirty(inst)
		end
	end
end

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

    inst.Transform:SetSixFaced()

    inst:AddTag("companion")
    inst:AddTag("noauradamage")
    inst:AddTag("engineering")
	inst:AddTag("engineeringbatterypowered")
    inst:AddTag("catapult")
    inst:AddTag("structure")

    inst.AnimState:SetBank("winona_catapult")
    inst.AnimState:SetBuild("winona_catapult")
    inst.AnimState:PlayAnimation("idle_off")
    --This will remove mouseover as well (rather than just :Hide("wire"))
    inst.AnimState:OverrideSymbol("wire", "winona_catapult", "dummy")

    inst.MiniMapEntity:SetIcon("winona_catapult.png")

	--used for attack visuals
	inst._element = net_tinybyte(inst.GUID, "winona_catapult._element", "elementdirty")

	--shadow/lunar/hybrid power aligment
	inst._poweralignment = net_tinybyte(inst.GUID, "winona_catapult._poweralignment")
	inst.HasPowerAlignment = HasPowerAlignment

	inst._ispowered = net_bool(inst.GUID, "winona_catapult._ispowered")
	inst.IsPowered = IsPowered

	inst.OverrideActivateVerb = OverrideActivateVerb

    --Dedicated server does not need deployhelper
    if not TheNet:IsDedicated() then
        inst:AddComponent("deployhelper")
        inst.components.deployhelper:AddRecipeFilter("winona_spotlight")
        inst.components.deployhelper:AddRecipeFilter("winona_catapult")
        inst.components.deployhelper:AddRecipeFilter("winona_battery_low")
        inst.components.deployhelper:AddRecipeFilter("winona_battery_high")
		inst.components.deployhelper:AddKeyFilter("winona_battery_engineering")
		inst.components.deployhelper:AddKeyFilter("catapult_volley")
		inst.components.deployhelper:AddKeyFilter("catapult_elementalvolley")
		inst.components.deployhelper:AddKeyFilter("catapult_wakeup")
        inst.components.deployhelper.onenablehelper = OnEnableHelper
		inst.components.deployhelper.onstarthelper = OnStartHelper
    end

    inst.scrapbook_specialinfo = "WINONACATAPULT"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
		inst:ListenForEvent("elementdirty", OnElementDirty)

        return inst
    end

    inst.scrapbook_facing  = FACING_DOWNRIGHT

    inst._state = 1

	inst:AddComponent("portablestructure")
	inst.components.portablestructure:SetOnDismantleFn(OnDismantle)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("updatelooper")
    inst:AddComponent("colouradder")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.WINONA_CATAPULT_HEALTH)
	inst.components.health.destroytime = 1

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.WINONA_CATAPULT_DAMAGE)
    inst.components.combat:SetRange(TUNING.WINONA_CATAPULT_MAX_RANGE)
    inst.components.combat:SetAttackPeriod(TUNING.WINONA_CATAPULT_ATTACK_PERIOD)
    inst.components.combat:SetKeepTargetFunction(ShouldKeepTarget)
    inst.components.combat:SetShouldAggroFn(ShouldAggro)

	inst:AddComponent("planardamage")
	inst:AddComponent("damagetypebonus")

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnWorkCallback(OnWorked)

    inst:AddComponent("savedrotation")

    inst:AddComponent("circuitnode")
    inst.components.circuitnode:SetRange(TUNING.WINONA_BATTERY_RANGE)
	inst.components.circuitnode:SetFootprint(TUNING.WINONA_ENGINEERING_FOOTPRINT)
    inst.components.circuitnode:SetOnConnectFn(OnConnectCircuit)
    inst.components.circuitnode:SetOnDisconnectFn(OnDisconnectCircuit)
    inst.components.circuitnode.connectsacrossplatforms = false
	inst.components.circuitnode.rangeincludesfootprint = true

	inst:AddComponent("powerload")
	inst.components.powerload:SetLoad(TUNING.WINONA_CATAPULT_POWER_LOAD_IDLE)

	inst:AddComponent("timer")

    inst:ListenForEvent("onbuilt", OnBuilt)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("death", OnDeath)
    inst:ListenForEvent("healthdelta", OnHealthDelta)
    inst:ListenForEvent("engineeringcircuitchanged", OnCircuitChanged)
	inst:ListenForEvent("activewakeup", OnActiveWakeup)
	inst:ListenForEvent("catapultspeedboost", OnCatapultSpeedBoost)
	inst:ListenForEvent("winona_catapultskillchanged", function(world, user)
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

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass
    inst.AddBatteryPower = AddBatteryPower
	inst.IsActiveMode = IsActiveMode
	inst.SetActiveMode = SetActiveMode
	inst.OnReadyForConnection = OnReadyForConnection
	inst.OnStartAttack = OnStartAttack
	inst.IsTargetTooFar = IsTargetTooFar
	inst.IsTargetTooClose = IsTargetTooClose
	--inst.OnEntitySleep = OnEntitySleep
	--inst.OnEntityWake = OnEntityWake

    inst:SetStateGraph("SGwinona_catapult")
    --inst:SetBrain(brain)

	--skilltree
	inst._speed = 0
	inst._aoe = 0
	inst._engineerid = nil

	inst.AOE_RADIUS = TUNING.WINONA_CATAPULT_AOE_RADIUS

    inst._wired = nil
    inst._flash = nil
	inst._ledblinktask = nil
	inst._ledblinktasktime = nil
	inst._ledblinkon = nil
	inst._ledrapidblinktask = nil
	inst._ledrapidblinkcount = nil
    inst._inittask = inst:DoTaskInTime(0, OnInit)

    return inst
end

--------------------------------------------------------------------------

local function CreatePlacerCatapult()
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

    inst.AnimState:SetBank("winona_catapult")
    inst.AnimState:SetBuild("winona_catapult")
    inst.AnimState:PlayAnimation("idle_placer")
    inst.AnimState:SetLightOverride(1)

    return inst
end

local function placer_postinit_fn(inst)
    --Show the catapult placer on top of the catapult range ground placer
    --Also add the small battery range indicator

    local placer2 = CreatePlacerBatteryRing()
    placer2.entity:SetParent(inst.entity)
    inst.components.placer:LinkEntity(placer2)

    placer2 = CreatePlacerCatapult()
    placer2.entity:SetParent(inst.entity)
    inst.components.placer:LinkEntity(placer2)

    inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

	inst.deployhelper_key = "winona_battery_engineering"
end

--------------------------------------------------------------------------

local function OnDeploy(inst, pt, deployer)
	local obj = SpawnPrefab("winona_catapult")
	if obj then
		obj.Physics:SetCollides(false)
		obj.Physics:Teleport(pt.x, 0, pt.z)
		obj.Physics:SetCollides(true)
		DoBuiltOrDeployed(obj, deployer, "deploy")
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

	inst.AnimState:SetBank("winona_catapult")
	inst.AnimState:SetBuild("winona_catapult")
	inst.AnimState:PlayAnimation("idle_ground")
	inst.scrapbook_anim = "idle_ground"

	inst:AddTag("portableitem")

	MakeInventoryFloatable(inst, "large", 0.4, { 0.5, 0.9, 1 })

	inst:SetPrefabNameOverride("winona_catapult")

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

return Prefab("winona_catapult", fn, assets, prefabs),
	MakePlacer("winona_catapult_item_placer", "winona_catapult_placement", "winona_catapult_placement", "idle_15", true, nil, nil, nil, nil, nil, placer_postinit_fn),
	Prefab("winona_catapult_item", itemfn, assets_item, prefabs_item)
