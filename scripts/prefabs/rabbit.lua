local assets =
{
    Asset("ANIM", "anim/ds_rabbit_basic.zip"),
    Asset("ANIM", "anim/rabbit_build.zip"),
    Asset("ANIM", "anim/beard_monster.zip"),
    Asset("ANIM", "anim/rabbit_winter_build.zip"),
    Asset("SOUND", "sound/rabbit.fsb"),
	Asset("INV_IMAGE", "beard_monster"),
	Asset("INV_IMAGE", "rabbit"),
	Asset("INV_IMAGE", "rabbit_winter"),
}

local prefabs =
{
    "smallmeat",
    "cookedsmallmeat",
    "cookedmonstermeat",
    "beardhair",
    "monstermeat",
    "nightmarefuel",
	"shadow_despawn",
	"statue_transition_2",
}

local rabbitsounds =
{
    scream = "dontstarve/rabbit/scream",
    hurt = "dontstarve/rabbit/scream_short",
}

local beardsounds =
{
    scream = "dontstarve/rabbit/beardscream",
    hurt = "dontstarve/rabbit/beardscream_short",
}

local wintersounds =
{
    scream = "dontstarve/rabbit/winterscream",
    hurt = "dontstarve/rabbit/winterscream_short",
}

local rabbitloot = { "smallmeat" }
local forced_beardlingloot = { "nightmarefuel" }

local brain = require("brains/rabbitbrain")

local function DoShadowFx(inst, isnightmare)
	local x, y, z = inst.Transform:GetWorldPosition()
	local fx = SpawnPrefab("statue_transition_2")
	fx.Transform:SetPosition(x, y, z)
	fx.Transform:SetScale(.5, .5, .5)

	--When forcing into nightmare state, shadow_trap would've already spawned this fx
	if not isnightmare then
		fx = SpawnPrefab("shadow_despawn")
		local platform = inst:GetCurrentPlatform()
		if platform ~= nil then
			fx.entity:SetParent(platform.entity)
			fx.Transform:SetPosition(platform.entity:WorldToLocalSpace(x, y, z))
			fx:ListenForEvent("onremove", function()
				fx.Transform:SetPosition(fx.Transform:GetWorldPosition())
				fx.entity:SetParent(nil)
			end, platform)
		else
			fx.Transform:SetPosition(x, y, z)
		end
	end
end

local function IsNormalRabbit(inst)
	return inst.sounds == rabbitsounds
end

local function IsWinterRabbit(inst)
    return inst.sounds == wintersounds
end

local function IsCrazyGuy(guy)
    local sanity = guy ~= nil and guy.replica.sanity or nil
    return sanity ~= nil and sanity:IsInsanityMode() and sanity:GetPercentNetworked() <= (guy:HasTag("dappereffects") and TUNING.DAPPER_BEARDLING_SANITY or TUNING.BEARDLING_SANITY)
end

local function IsForcedNightmare(inst)
	return inst.components.timer:TimerExists("forcenightmare")
end

local function SetRabbitLoot(lootdropper)
    if lootdropper.loot ~= rabbitloot and not lootdropper.inst._fixedloot then
        lootdropper:SetLoot(rabbitloot)
    end
end

local function SetBeardlingLoot(lootdropper)
	if not lootdropper.inst._fixedloot then
        lootdropper:SetLoot(nil)
        lootdropper:AddRandomLoot("beardhair", .5)
        lootdropper:AddRandomLoot("monstermeat", 1)
        lootdropper:AddRandomLoot("nightmarefuel", 1)
        lootdropper.numrandomloot = 1
    end
end

local function SetForcedBeardlingLoot(lootdropper)
	if not lootdropper.inst._fixedloot then
		lootdropper:SetLoot(forced_beardlingloot)
		if math.random() < .5 then
			lootdropper:AddRandomLoot("beardhair", .5)
			lootdropper:AddRandomLoot("monstermeat", 1)
			lootdropper.numrandomloot = 1
		end
	end
end

local function BecomeRabbit(inst)
	inst.task = nil
    if IsForcedNightmare(inst) or inst.components.health:IsDead() then
        return
    end
    inst.AnimState:SetBuild("rabbit_build")
    if inst.components.inventoryitem then
        inst.components.inventoryitem:ChangeImageName("rabbit")
    end
    inst.sounds = rabbitsounds
end

local function BecomeWinterRabbit(inst)
	inst.task = nil
    if IsForcedNightmare(inst) or inst.components.health:IsDead() then
        return
    end
    inst.AnimState:SetBuild("rabbit_winter_build")
    if inst.components.inventoryitem then
        inst.components.inventoryitem:ChangeImageName("rabbit_winter")
    end
    inst.sounds = wintersounds
end

local function OnEnterLimbo(inst)
	inst.components.timer:PauseTimer("forcenightmare")
end

local function OnExitLimbo(inst)
	inst.components.timer:ResumeTimer("forcenightmare")
end

local function OnTimerDone(inst, data)
	if data ~= nil and data.name == "forcenightmare" then
		if not (inst:IsInLimbo() or inst:IsAsleep()) then
			if inst.sg:HasStateTag("busy") and not inst.sg:HasStateTag("sleeping") then
				inst.components.timer:StartTimer("forcenightmare", 1)
				return
			end
			DoShadowFx(inst, false)
		end
		inst:RemoveEventCallback("timerdone", OnTimerDone)
		inst:RemoveEventCallback("enterlimbo", OnEnterLimbo)
		inst:RemoveEventCallback("exitlimbo", OnExitLimbo)
		if TheWorld.state.iswinter then
			BecomeWinterRabbit(inst)
		else
			BecomeRabbit(inst)
		end
	end
end

local function BecomeBeardling(inst, duration)
	if inst.task ~= nil then
		inst.task:Cancel()
		inst.task = nil
	end
	--duration nil is loading, so don't perform checks
	if duration ~= nil then
		if inst.components.health:IsDead() then
			return
		end
		local t = inst.components.timer:GetTimeLeft("forcenightmare")
		if t ~= nil then
			if t < duration then
				inst.components.timer:SetTimeLeft("forcenightmare", duration)
			end
			return
		end
		inst.components.timer:StartTimer("forcenightmare", duration, inst:IsInLimbo())
	end
	inst.AnimState:SetBuild("beard_monster")
	if inst.components.inventoryitem ~= nil then
		inst.components.inventoryitem:ChangeImageName("beard_monster")
	end
	inst.sounds = beardsounds
	inst:ListenForEvent("timerdone", OnTimerDone)
	inst:ListenForEvent("enterlimbo", OnEnterLimbo)
	inst:ListenForEvent("exitlimbo", OnExitLimbo)
end

local function OnForceNightmareState(inst, data)
	if data ~= nil and data.duration ~= nil then
		DoShadowFx(inst, true)
		BecomeBeardling(inst, data.duration)
	end
end

local function OnIsWinter(inst, iswinter)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
	if not IsForcedNightmare(inst) then
		if iswinter then
			if not IsWinterRabbit(inst) then
				inst.task = inst:DoTaskInTime(math.random() * .5, BecomeWinterRabbit)
			end
		elseif not IsNormalRabbit(inst) then
			inst.task = inst:DoTaskInTime(math.random() * .5, BecomeRabbit)
		end
	end
end

local function OnWake(inst)
    inst:WatchWorldState("iswinter", OnIsWinter)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
	if not IsForcedNightmare(inst) then
		if TheWorld.state.iswinter then
			if not IsWinterRabbit(inst) then
				BecomeWinterRabbit(inst)
			end
		elseif not IsNormalRabbit(inst) then
			BecomeRabbit(inst)
		end
	end
end

local function OnSleep(inst)
    inst:StopWatchingWorldState("iswinter", OnIsWinter)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
end

local function OnLoad(inst)
	if IsForcedNightmare(inst) then
		BecomeBeardling(inst, nil)
		if inst:IsInLimbo() then
			inst.components.timer:PauseTimer("forcenightmare")
		else
			inst.components.timer:ResumeTimer("forcenightmare")
		end
	end
end

local function SetBeardlingTrapData(inst)
	local t = inst.components.timer:GetTimeLeft("forcenightmare")
	return t ~= nil and {
		beardlingtime = t,
	} or nil
end

local function RestoreBeardlingFromTrap(inst, data)
	if data ~= nil and data.beardlingtime ~= nil then
		BecomeBeardling(inst, data.beardlingtime)
	end
end

local function CalcSanityAura(inst, observer)
    return (IsForcedNightmare(inst) or IsCrazyGuy(observer)) and -TUNING.SANITYAURA_MED or 0
end

local function GetCookProductFn(inst, cooker, chef)
    return (IsForcedNightmare(inst) or IsCrazyGuy(chef)) and "cookedmonstermeat" or "cookedsmallmeat"
end

local function OnCookedFn(inst, cooker, chef)
    inst.SoundEmitter:PlaySound((IsForcedNightmare(inst) or IsCrazyGuy(chef)) and beardsounds.hurt or inst.sounds.hurt)
end

local function LootSetupFunction(lootdropper)
    local guy = lootdropper.inst.causeofdeath
	if IsForcedNightmare(lootdropper.inst) then
		SetForcedBeardlingLoot(lootdropper)
	elseif IsCrazyGuy(guy ~= nil and guy.components.follower ~= nil and guy.components.follower.leader or guy) then
        SetBeardlingLoot(lootdropper)
    else
        SetRabbitLoot(lootdropper)
    end
end

local RABBIT_MUST_TAGS = { "rabbit" }
local RABBIT_CANT_TAGS = { "INLIMBO" }
local function OnAttacked(inst, data)
	if IsForcedNightmare(inst) and data ~= nil and data.attacker == nil and data.damage == 0 and data.weapon == nil then
		--Ignore this "attacked" event that is just for triggering transformation
		return
	end

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 30, RABBIT_MUST_TAGS, RABBIT_CANT_TAGS)
    local maxnum = 5
    for i, v in ipairs(ents) do
        v:PushEvent("gohome")
        if i >= maxnum then
            break
        end
    end
end

local function OnDropped(inst)
    inst.sg:GoToState("stunned")
end

local function getmurdersound(inst, doer)
    return (IsForcedNightmare(inst) or IsCrazyGuy(doer)) and beardsounds.hurt or inst.sounds.hurt
end

local function getincineratesound(inst, doer)
    return (IsForcedNightmare(inst) or IsCrazyGuy(doer)) and beardsounds.scream or inst.sounds.scream
end

local function drawimageoverride(inst, viewer)
    return (IsForcedNightmare(inst) or IsCrazyGuy(viewer)) and "beard_monster"
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 1, 0.5)

    inst.DynamicShadow:SetSize(1, .75)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("rabbit")
    inst.AnimState:SetBuild("rabbit_build")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("animal")
    inst:AddTag("prey")
    inst:AddTag("rabbit")
    inst:AddTag("smallcreature")
    inst:AddTag("canbetrapped")
    inst:AddTag("cattoy")
    inst:AddTag("catfood")
    inst:AddTag("stunnedbybomb")

    --cookable (from cookable component) added to pristine state for optimization
    inst:AddTag("cookable")

    inst.AnimState:SetClientsideBuildOverride("insane", "rabbit_build", "beard_monster")
    inst.AnimState:SetClientsideBuildOverride("insane", "rabbit_winter_build", "beard_monster")

    inst:SetClientSideInventoryImageOverride("insane", "rabbit.tex", "beard_monster.tex")
    inst:SetClientSideInventoryImageOverride("insane", "rabbit_winter.tex", "beard_monster.tex")

    MakeFeedableSmallLivestockPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.RABBIT_RUN_SPEED
    inst:SetStateGraph("SGrabbit")

    inst:SetBrain(brain)

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.VEGGIE }, { FOODTYPE.VEGGIE })

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.canbepickedupalive = true
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

    inst:AddComponent("cookable")
    inst.components.cookable.product = GetCookProductFn
    inst.components.cookable:SetOnCookedFn(OnCookedFn)

    inst:AddComponent("knownlocations")
	inst:AddComponent("timer")
    inst:AddComponent("drownable")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.RABBIT_HEALTH)
    inst.components.health.murdersound = getmurdersound
    inst.incineratesound = getincineratesound

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLootSetupFn(LootSetupFunction)
    LootSetupFunction(inst.components.lootdropper)

    if TheNet:GetServerGameMode() == "quagmire" then
        event_server_data("quagmire", "prefabs/rabbit").master_postinit(inst)
    else
        inst:AddComponent("combat")
        inst.components.combat.hiteffectsymbol = "chest"

        MakeSmallBurnableCharacter(inst, "chest")
        MakeTinyFreezableCharacter(inst, "chest")
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("sleeper")
    inst.components.sleeper.watchlight = true
    inst:AddComponent("tradable")

    inst.sounds = nil
    inst.task = nil
    BecomeRabbit(inst)

    MakeHauntablePanic(inst)

    inst:ListenForEvent("attacked", OnAttacked)

	--shadow_trap interaction
	inst.has_nightmare_state = true
	inst:ListenForEvent("ms_forcenightmarestate", OnForceNightmareState)

    MakeFeedableSmallLivestock(inst, TUNING.RABBIT_PERISH_TIME, nil, OnDropped)

    inst.drawimageoverride = drawimageoverride
	inst.settrapdata = SetBeardlingTrapData
	inst.restoredatafromtrap = RestoreBeardlingFromTrap

	inst.OnEntityWake = OnWake
	inst.OnEntitySleep = OnSleep
	inst.OnLoad = OnLoad

    return inst
end

return Prefab("rabbit", fn, assets, prefabs)
