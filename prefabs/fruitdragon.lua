local brain = require("brains/fruitdragonbrain")

local assets =
{
    Asset("ANIM", "anim/fruit_dragon.zip"),
    Asset("ANIM", "anim/fruit_dragon_build.zip"),
    Asset("ANIM", "anim/fruit_dragon_ripe_build.zip"),
}

local prefabs =
{
    "dragonfruit",
    "plantmeat",
}

SetSharedLootTable('fruit_dragon',
{
    {'plantmeat',        1.00},
})

SetSharedLootTable('fruit_dragon_ripe',
{
    {'dragonfruit',      1.00},
})

local function IsBetterHeatSource(heat_source, inst, cur_heat)
	local heat = heat_source.components.heater ~= nil and heat_source.components.heater:GetHeat(inst) or 0
	return heat > cur_heat
end

local HEATSOURCE_MUST_TAGS = {"HASHEATER"}
local HEATSOURCE_CANT_TAGS = {"monster"}

local function FindNewHome(inst)
	if inst.components.timer:TimerExists("panicing")
		or inst.components.sleeper:IsAsleep()
		or inst.components.combat.target ~= nil then
		return
	end

	local home = inst.components.entitytracker:GetEntity("home")
	local new_home = (home ~= nil and home.components.heater ~= nil and inst:IsNear(home, TUNING.FRUITDRAGON.KEEP_HOME_RANGE) and home.components.heater:GetHeat(inst) > 0 and home:IsOnValidGround()) and home or nil

	local cur_heat = new_home ~= nil and new_home.components.heater:GetHeat(inst) or 0
	local x, y, z = inst.Transform:GetWorldPosition()
	local heat_sources = TheSim:FindEntities(x, y, z, inst:IsAsleep() and TUNING.FRUITDRAGON.ENTITY_SLEEP_FIND_HOME_RANGE or TUNING.FRUITDRAGON.FIND_HOME_RANGE, HEATSOURCE_MUST_TAGS, HEATSOURCE_CANT_TAGS)
	for i, v in ipairs(heat_sources) do
		if v ~= inst and v ~= new_home and IsBetterHeatSource(v, inst, cur_heat) then
			new_home = v
			break
		end
	end

	if new_home ~= home then
		if home ~= nil then
			inst.components.entitytracker:ForgetEntity("home")
		end
		if new_home ~= nil then
			inst.components.entitytracker:TrackEntity("home", new_home)
		end
	end
end

local function OnNewTarget(inst, data)
	if data.target:HasTag("fruitdragon") then
		inst._min_challenge_attacks = inst._is_ripe and 0 or 2
	end
end

local function KeepTarget(inst, target)
	if target:HasTag("fruitdragon") then
		return (target.components.combat.target == nil or target.components.combat.target:HasTag("fruitdragon"))
				and not target.components.timer:TimerExists("panicing")
				and inst:IsNear(target, TUNING.FRUITDRAGON.CHALLENGE_DIST)
	end

    return target --inst:IsNear(target, TUNING.FRUITDRAGON.CHALLENGE_DIST * 2)
end

local function ShouldTarget(target)
	return target:HasTag("fruitdragon")
			and not target.components.timer:TimerExists("panicing")
			and target.components.combat.target == nil
end

local FRUITDRAGON_TAGS = {"fruitdragon"}
local function RetargetFn(inst)
	if (inst.components.sleeper == nil or not inst.components.sleeper:IsAsleep())
		and not inst.components.timer:TimerExists("panicing") then

		if inst.components.combat.target ~= nil and KeepTarget(inst, inst.components.combat.target) then
			return inst.components.combat.target
		elseif inst.components.entitytracker:GetEntity("home") ~= nil then
			return FindEntity(inst, TUNING.FRUITDRAGON.CHALLENGE_DIST, function(guy) return ShouldTarget(guy) end, FRUITDRAGON_TAGS)
					or FindEntity(inst.components.entitytracker:GetEntity("home"), TUNING.FRUITDRAGON.CHALLENGE_DIST, function(guy) return guy ~= inst and ShouldTarget(guy) end, FRUITDRAGON_TAGS)
		end
	end
    return nil
end

local function OnAttacked(inst, data)
	local home = inst.components.entitytracker:GetEntity("home")
	home = (home ~= nil and home.components.inventoryitem ~= nil) and home.components.inventoryitem:GetGrandOwner() or home

	if data.attacker == home then -- if my home, or the thing holding it, attacked me then this is not my home any more
		inst.components.entitytracker:ForgetEntity("home")
	end
    inst.components.combat:SetTarget(data.attacker)
end

local function doattack(inst, data)
	if data.target:HasTag("fruitdragon") then
		if data.target:HasTag("sleeping") and data.target.components.sleeper ~= nil then
			data.target.components.sleeper:WakeUp()
			data.target:PushEvent("wake_up_to_challenge")
		end
		data.target.components.combat:SuggestTarget(inst)
	end
end

local function OnLostChallenge(inst)
	inst.components.entitytracker:ForgetEntity("home")
	inst.components.timer:StartTimer("panicing", TUNING.FRUITDRAGON.CHALLENGE_LOST_PANIC_TIME)
	inst.components.combat:DropTarget()
end

local function onattackother(inst, data)
	if data.target:HasTag("fruitdragon") then
		if not KeepTarget(inst, data.target) then
			inst.components.combat:DropTarget()

		elseif inst._min_challenge_attacks <= 0 and math.random() < TUNING.FRUITDRAGON.CHALLENGE_WIN_CHANCE then
			data.target:PushEvent("lostfruitdragonchallenge")

			inst.components.combat:DropTarget()
			inst.components.combat:TryRetarget()
		end
		inst._min_challenge_attacks = inst._min_challenge_attacks - 1
	end
end

local function onblocked(inst, data)
	if data.attacker:HasTag("fruitdragon") and not inst.components.timer:TimerExists("panicing") then
		inst.components.combat:SuggestTarget(data.attacker)
		if inst.components.sleeper ~= nil then
			inst.components.sleeper:WakeUp()
		end
	end
end

local function GetRemainingTimeAwake(inst)
	local max_awake_time = (TUNING.FRUITDRAGON.AWAKE_TIME_MIN + inst.sleep_variance * TUNING.FRUITDRAGON.AWAKE_TIME_VAR) * (inst._is_ripe and TUNING.FRUITDRAGON.AWAKE_TIME_RIPE_MOD or 1) * (inst.components.entitytracker:GetEntity("home") == nil and TUNING.FRUITDRAGON.AWAKE_TIME_HOMELESS_MOD or 1)
	return max_awake_time - (GetTime() - inst._wakeup_time)
end

local function GetRemainingNapTime(inst)
	local max_awake_time = (TUNING.FRUITDRAGON.NAP_TIME_MIN + inst.sleep_variance * TUNING.FRUITDRAGON.NAP_TIME_VAR) * (inst._is_ripe and TUNING.FRUITDRAGON.NAP_TIME_RIPE_MOD or 1) * (inst.components.entitytracker:GetEntity("home") and TUNING.FRUITDRAGON.NAP_TIME_HOMELESS_MOD or 1)
	return max_awake_time - (GetTime() - inst._nap_time)
end

local function StartNextNapTimer(inst)
	inst._wakeup_time = GetTime()
	inst.sleep_variance = math.random()
end

local function StartNappingTimer(inst)
	inst._nap_time = GetTime()
	inst.sleep_variance = math.random()
end

local function QueueRipen(inst)
	inst._ripen_pending = not inst._is_ripe
	inst._unripen_pending = false
end

local function MakeRipe(inst, force)
	if inst._ripen_pending or force then
		inst._ripen_pending = false
		inst._is_ripe = true

	    inst.components.lootdropper:SetChanceLootTable('fruit_dragon_ripe')
		inst.components.combat:SetDefaultDamage(TUNING.FRUITDRAGON.RIPE_DAMAGE)

		inst.AnimState:SetBuild("fruit_dragon_ripe_build")
	end
end

local function QueueUnripe(inst)
	inst._ripen_pending = false
	inst._unripen_pending = inst._is_ripe
end

local function MakeUnripe(inst, force)
	if inst._unripen_pending or force then
		inst._unripen_pending = false
		inst._is_ripe = false

	    inst.components.lootdropper:SetChanceLootTable('fruit_dragon')
		inst.components.combat:SetDefaultDamage(TUNING.FRUITDRAGON.UNRIPE_DAMAGE)

		inst.AnimState:SetBuild("fruit_dragon_build")
	end
end

local function IsHomeGoodEnough(inst, dist, min_temp)
	local home = inst.components.entitytracker:GetEntity("home")
	return home ~= nil and home.components.heater ~= nil
			and inst:IsNear(home, dist)
			and home.components.heater:GetHeat(inst) >= min_temp
end

local function Sleeper_SleepTest(inst)
    if (inst.components.combat and inst.components.combat.target) or inst.sg:HasStateTag("busy") or inst.components.timer:TimerExists("panicing") then
		return false
	end

	if inst.components.entitytracker:GetEntity("home") then
		if (TheWorld.state.isnight or GetRemainingTimeAwake(inst) <= 0) and IsHomeGoodEnough(inst, TUNING.FRUITDRAGON.NAP_DIST_FROM_HOME, TUNING.FRUITDRAGON.NAP_MIN_HEAT) then
			if inst._is_ripe and not IsHomeGoodEnough(inst, TUNING.FRUITDRAGON.NAP_DIST_FROM_HOME, TUNING.FRUITDRAGON.RIPEN_NAP_MIN_HEAT) then
				QueueUnripe(inst)
			end

			return true
		end
	else
		if TheWorld.state.isnight or GetRemainingTimeAwake(inst) <= 0 then
			if inst._is_ripe then
				QueueUnripe(inst)
			end

			return true
		end
	end

	return false
end

-- TODO: on lose home, call: inst.components.sleeper:WakeUp()

local function Sleeper_WakeTest(inst)
	if (inst.components.combat ~= nil and inst.components.combat.target ~= nil) then
		return true
	end

	if TheWorld.state.isnight then
		return false
	end

	if GetRemainingNapTime(inst) <= 0 then
		inst._sleep_interupted = false
		return true
    end

	return false
end

local function Sleeper_OnSleep(inst)
	StartNappingTimer(inst)
	if not inst.components.health:IsDead() then
		inst.components.health:StartRegen(TUNING.FRUITDRAGON.NAP_REGEN_AMOUNT, TUNING.FRUITDRAGON.NAP_REGEN_INTERVAL)
	end
end

local function Sleeper_OnWakeUp(inst)
	if not inst._sleep_interupted then
		if not inst._ripen_pending and not inst._is_ripe
			and IsHomeGoodEnough(inst, TUNING.FRUITDRAGON.NAP_DIST_FROM_HOME, TUNING.FRUITDRAGON.RIPEN_NAP_MIN_HEAT) then

			QueueRipen(inst)
		end
	end

	if not inst.components.health:IsDead() then
		inst.components.health:StopRegen()
	end

	StartNextNapTimer(inst)
	inst._sleep_interupted = true -- reseting it
end

local function OnSave(inst, data)
	data._is_ripe = inst._is_ripe
end

local function OnLoad(inst, data)
	if data ~= nil and data._is_ripe then
		inst:MakeRipe(true)
	end
end

local function OnEntitySleep(inst)
	inst.components.health:StopRegen()

	if inst._findnewhometask ~= nil then
		inst._findnewhometask:Cancel()
		inst._findnewhometask = nil
	end

	inst._entitysleeptime = GetTime()
end

local function OnEntityWake(inst)
	if inst._entitysleeptime == nil then
		return
	end

	local dt = (GetTime() - inst._entitysleeptime)
	if dt > 1 then
		if inst.components.entitytracker:GetEntity("home") == nil then
			FindNewHome(inst)
		end
		if IsHomeGoodEnough(inst, TUNING.FRUITDRAGON.KEEP_HOME_RANGE, TUNING.FRUITDRAGON.RIPEN_NAP_MIN_HEAT) then
			if not inst._is_ripe then
				inst:MakeRipe(true)
			end
		else
			if inst._is_ripe then
				inst:MakeUnripe(true)
			end
		end

		if not inst.components.health:IsDead() and inst.components.health:IsHurt() then
			local estimated_naps = math.floor(dt / (40 + math.random() * 20))
			inst.components.health:DoDelta(estimated_naps * (TUNING.FRUITDRAGON.NAP_TIME_MIN / TUNING.FRUITDRAGON.NAP_REGEN_INTERVAL)  * TUNING.FRUITDRAGON.NAP_REGEN_AMOUNT) -- fake regen
		end
	end

	inst._findnewhometask = inst:DoPeriodicTask(3, FindNewHome, 0.1 + math.random())

	if not inst.components.health:IsDead() and inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep() then
		inst.components.health:StartRegen(TUNING.FRUITDRAGON.NAP_REGEN_AMOUNT, TUNING.FRUITDRAGON.NAP_REGEN_INTERVAL, true)
	end
end

local function GetStatus(inst)
    return inst._is_ripe and "RIPE" or nil
end

local function GetDebugString(inst)
	return	"Home: " .. tostring(inst.components.entitytracker:GetEntity("home")) ..
			"\nRipe: " .. tostring(inst._is_ripe) ..
			(not inst:HasTag("sleeping") and ("\nSleep in: " .. tostring(GetRemainingTimeAwake(inst))) or ("\nAwake in: " .. tostring(GetRemainingNapTime(inst)))) ..
			"\n\n"
			.. inst:_GetDebugString()
end

local fruit_dragon_sounds =
{
    idle = "turnoftides/creatures/together/fruit_dragon/idle",
    death = "turnoftides/creatures/together/fruit_dragon/death",
    eat = "turnoftides/creatures/together/fruit_dragon/eat",
    onhit = "turnoftides/creatures/together/fruit_dragon/hit",
    sleep_loop = "turnoftides/creatures/together/fruit_dragon/sleep",
    stretch = "turnoftides/creatures/together/fruit_dragon/stretch",
    --do_ripen = "turnoftides/creatures/together/fruit_dragon/do_ripen",
    do_unripen = "turnoftides/creatures/together/fruit_dragon/stretch",
    attack = "turnoftides/creatures/together/fruit_dragon/attack",
    attack_fire = "turnoftides/creatures/together/fruit_dragon/attack_fire",
    challenge_pre = "turnoftides/creatures/together/fruit_dragon/challenge_pre",
    challenge = "turnoftides/creatures/together/fruit_dragon/challenge",
    challenge_pst = "turnoftides/creatures/together/fruit_dragon/eat",
    challenge_win = "turnoftides/creatures/together/fruit_dragon/eat",
    challenge_lose = "turnoftides/creatures/together/fruit_dragon/eat",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(2, 0.75)
    inst.Transform:SetFourFaced()
    inst.Transform:SetScale(2, 2, 2) -- woops!

    MakeCharacterPhysics(inst, 1, 0.5)

    inst.AnimState:SetBank("fruit_dragon")
    inst.AnimState:SetBuild("fruit_dragon_build")
    inst.AnimState:PlayAnimation("idle_loop")

    inst.Light:Enable(false)
    inst.Light:SetRadius(1.25)
    inst.Light:SetFalloff(.98)
    inst.Light:SetIntensity(0.5)
    inst.Light:SetColour(235 / 255, 121 / 255, 12 / 255)

    inst:AddTag("smallcreature")
    inst:AddTag("animal")
    inst:AddTag("scarytoprey")
    inst:AddTag("fruitdragon")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.sounds = fruit_dragon_sounds
	inst._sleep_interupted = true
	inst._wakeup_time = GetTime()
	inst._nap_time = -math.huge

    inst:AddComponent("timer")

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.FRUITDRAGON.HEALTH)
    inst.components.health.fire_damage_scale = 0

    inst:AddComponent("combat")
    inst.components.combat:SetHurtSound("turnoftides/creatures/together/fruit_dragon/hit")
    inst.components.combat.hiteffectsymbol = "gecko_torso_middle"
	inst.components.combat:SetAttackPeriod(TUNING.FRUITDRAGON.ATTACK_PERIOD)
	inst.components.combat:SetDefaultDamage(TUNING.FRUITDRAGON.UNRIPE_DAMAGE)
	inst.components.combat:SetRange(TUNING.FRUITDRAGON.ATTACK_RANGE, TUNING.FRUITDRAGON.HIT_RANGE)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
	inst.components.combat:SetRetargetFunction(1, RetargetFn)
	inst:ListenForEvent("doattack", doattack)
    inst:ListenForEvent("attacked", OnAttacked)
	inst:ListenForEvent("onattackother", onattackother)
	inst:ListenForEvent("blocked", onblocked)
	inst:ListenForEvent("newcombattarget", OnNewTarget)

	inst:AddComponent("entitytracker")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('fruit_dragon')

    inst:AddComponent("sleeper")
    inst.components.sleeper.testperiod = 3
    inst.components.sleeper:SetWakeTest(Sleeper_WakeTest)
    inst.components.sleeper:SetSleepTest(Sleeper_SleepTest)
	inst:ListenForEvent("gotosleep", Sleeper_OnSleep)
	inst:ListenForEvent("onwakeup", Sleeper_OnWakeUp)

	StartNextNapTimer(inst)

    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = TUNING.FRUITDRAGON.RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.FRUITDRAGON.WALK_SPEED

    MakeSmallFreezableCharacter(inst)

	inst.MakeRipe = MakeRipe
	inst.MakeUnripe = MakeUnripe

    inst:SetBrain(brain)
    inst:SetStateGraph("SGfruitdragon")

    MakeHauntablePanicAndIgnite(inst)

	inst._findnewhometask = inst:DoPeriodicTask(3, FindNewHome, 0.1 + math.random())

	--    inst:ListenForEvent("moisturedelta", OnMoistureDelta)

	inst:ListenForEvent("lostfruitdragonchallenge", OnLostChallenge)

	inst._GetDebugString = inst.GetDebugString
	inst.GetDebugString = GetDebugString

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake
    if inst:IsAsleep() then
        OnEntitySleep(inst)
    end

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("fruitdragon", fn, assets, prefabs)
