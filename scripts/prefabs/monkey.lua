local assets =
{
    Asset("ANIM", "anim/kiki_basic.zip"),
    Asset("ANIM", "anim/kiki_nightmare_skin.zip"),
    Asset("SOUND", "sound/monkey.fsb"),
}

local prefabs =
{
    "poop",
    "monkeyprojectile",
    "smallmeat",
    "cave_banana",
    "beardhair",
    "nightmarefuel",
	"shadow_despawn",
}

local brain = require "brains/monkeybrain"
local nightmarebrain = require "brains/nightmaremonkeybrain"

local LOOT = { "smallmeat", "cave_banana" }
local FORCED_NIGHTMARE_LOOT = { "nightmarefuel" }
SetSharedLootTable('monkey',
{
    {'smallmeat',     1.0},
    {'cave_banana',   1.0},
    {'beardhair',     1.0},
    {'nightmarefuel', 0.5},
})

local function SetHarassPlayer(inst, player)
    if inst.harassplayer ~= player then
        if inst._harassovertask ~= nil then
            inst._harassovertask:Cancel()
            inst._harassovertask = nil
        end
        if inst.harassplayer ~= nil then
            inst:RemoveEventCallback("onremove", inst._onharassplayerremoved, inst.harassplayer)
            inst.harassplayer = nil
        end
        if player ~= nil then
            inst:ListenForEvent("onremove", inst._onharassplayerremoved, player)
            inst.harassplayer = player
            inst._harassovertask = inst:DoTaskInTime(120, SetHarassPlayer, nil)
        end
    end
end

local function IsPoop(item)
    return item.prefab == "poop"
end

local function oneat(inst)
    --Monkey ate some food. Give him some poop!
    if inst.components.inventory ~= nil then
        local maxpoop = 3
        local poopstack = inst.components.inventory:FindItem(IsPoop)
        if not poopstack or poopstack.components.stackable.stacksize < maxpoop then
            inst.components.inventory:GiveItem(SpawnPrefab("poop"))
        end
    end
end

local function onthrow(weapon, inst)
    if inst.components.inventory ~= nil then
        inst.components.inventory:ConsumeByName("poop")
    end
end

local function hasammo(inst)
    return inst.components.inventory ~= nil and inst.components.inventory:FindItem(IsPoop) ~= nil
end

local function EquipWeapons(inst)
    if inst.components.inventory ~= nil and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
        local thrower = CreateEntity()
        thrower.name = "Thrower"
        thrower.entity:AddTransform()
        thrower:AddComponent("weapon")
        thrower.components.weapon:SetDamage(TUNING.MONKEY_RANGED_DAMAGE)
        thrower.components.weapon:SetRange(TUNING.MONKEY_RANGED_RANGE)
        thrower.components.weapon:SetProjectile("monkeyprojectile")
        thrower.components.weapon:SetOnProjectileLaunch(onthrow)
        thrower:AddComponent("inventoryitem")
        thrower.persists = false
        thrower.components.inventoryitem:SetOnDroppedFn(thrower.Remove)
        thrower:AddComponent("equippable")
        thrower:AddTag("nosteal")
        inst.components.inventory:GiveItem(thrower)
        inst.weaponitems.thrower = thrower

        local hitter = CreateEntity()
        hitter.name = "Hitter"
        hitter.entity:AddTransform()
        hitter:AddComponent("weapon")
        hitter.components.weapon:SetDamage(TUNING.MONKEY_MELEE_DAMAGE)
        hitter.components.weapon:SetRange(0)
        hitter:AddComponent("inventoryitem")
        hitter.persists = false
        hitter.components.inventoryitem:SetOnDroppedFn(hitter.Remove)
        hitter:AddComponent("equippable")
        hitter:AddTag("nosteal")
        inst.components.inventory:GiveItem(hitter)
        inst.weaponitems.hitter = hitter

    end
end

local function _ForgetTarget(inst)
    inst.components.combat:SetTarget(nil)
end

local MONKEY_TAGS = { "monkey" }
local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    SetHarassPlayer(inst, nil)
    if inst.task ~= nil then
        inst.task:Cancel()
    end
    inst.task = inst:DoTaskInTime(math.random(55, 65), _ForgetTarget) --Forget about target after a minute

    local x, y, z = inst.Transform:GetWorldPosition()
    local monkeys = TheSim:FindEntities(x, y, z, 30, MONKEY_TAGS)
    for _, monkey in ipairs(monkeys) do
        if monkey ~= inst and monkey.components.combat then
            monkey.components.combat:SuggestTarget(data.attacker)
            SetHarassPlayer(monkey, nil)
            if monkey.task ~= nil then
                monkey.task:Cancel()
            end
            monkey.task = monkey:DoTaskInTime(math.random(55, 65), _ForgetTarget) --Forget about target after a minute
        end
    end
end

local function IsBanana(item)
    return item.prefab == "cave_banana" or item.prefab == "cave_banana_cooked"
end

local function FindTargetOfInterest(inst)
    if not inst.curious then
        return
    end

    if inst.harassplayer == nil and inst.components.combat.target == nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        -- Get all players in range
        local targets = FindPlayersInRange(x, y, z, 25)
        -- randomly iterate over all players until we find one we're interested in.
        for _ = 1, #targets do
            local randomtarget = math.random(#targets)
            local target = targets[randomtarget]
            table.remove(targets, randomtarget)
            --Higher chance to follow if he has bananas
            if target.components.inventory ~= nil and
                    math.random() < (target.components.inventory:FindItem(IsBanana) ~= nil and .6 or .15) then
                SetHarassPlayer(inst, target)
                return
            end
        end
    end
end

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "playerghost" }
local RETARGET_ONEOF_TAGS = { "character", "monster" }
local function retargetfn(inst)
    return inst:HasTag("nightmare")
        and FindEntity(
                inst,
                20,
                function(guy)
                    return inst.components.combat:CanTarget(guy)
                end,
                RETARGET_MUST_TAGS, --see entityreplica.lua
                RETARGET_CANT_TAGS,
                RETARGET_ONEOF_TAGS
            )
        or nil
end

local function shouldKeepTarget(inst)
    return true
end

local function _DropAndGoHome(inst)
    if inst.components.inventory ~= nil then
        inst.components.inventory:DropEverything(false, true)
    end
    if inst.components.homeseeker ~= nil and inst.components.homeseeker.home ~= nil then
        inst.components.homeseeker.home:PushEvent("monkeydanger")
    end
end

local function OnMonkeyDeath(inst, data)
    --A monkey was killed by a player! Run home!
    if data.afflicter ~= nil and data.inst:HasTag("monkey") and data.afflicter:HasTag("player") then
        --Drop all items, go home
        inst:DoTaskInTime(math.random(), _DropAndGoHome)
    end
end

local function onpickup_delayed(inst, item)
    if item:IsValid() and
            item.components.inventoryitem ~= nil and
            item.components.inventoryitem.owner == inst then
        inst.components.inventory:Equip(item)
    end
end
local function OnPickup(inst, data)
    local item = data.item
    if item ~= nil and
            item.components.equippable ~= nil and
            item.components.equippable.equipslot == EQUIPSLOTS.HEAD and
            not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) then
        --Ugly special case for how the PICKUP action works.
        --Need to wait until PICKUP has called "GiveItem" before equipping item.
        inst:DoTaskInTime(0, onpickup_delayed, item)
    end
end

local function DoFx(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")

    local x, y, z = inst.Transform:GetWorldPosition()
    local fx = SpawnPrefab("statue_transition_2")
    if fx ~= nil then
        fx.Transform:SetPosition(x, y, z)
        fx.Transform:SetScale(.8, .8, .8)
    end
    fx = SpawnPrefab("statue_transition")
    if fx ~= nil then
        fx.Transform:SetPosition(x, y, z)
        fx.Transform:SetScale(.8, .8, .8)
    end
end

local function DoForceNightmareFx(inst, isnightmare)
	--Only difference is we use "shadow_despawn" instead of "statue_transition"
	--Same anim, but shadow_despawn has its own sfx and can be attached to platforms.
	--For consistency, shadow_despawn is what shadow_trap uses when forcing nightmare state.

	local x, y, z = inst.Transform:GetWorldPosition()
	local fx = SpawnPrefab("statue_transition_2")
	fx.Transform:SetPosition(x, y, z)
	fx.Transform:SetScale(.8, .8, .8)

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

local function SetNormalMonkey(inst)
    inst:RemoveTag("nightmare")
    inst:SetBrain(brain)
    inst.AnimState:SetBuild("kiki_basic")
    inst.AnimState:SetMultColour(1, 1, 1, 1)
    inst.curious = true
    inst.soundtype = ""
    inst.components.lootdropper:SetLoot(LOOT)
    inst.components.lootdropper:SetChanceLootTable(nil)

    inst.components.acidinfusible:SetMultipliers(TUNING.ACID_INFUSION_MULT.WEAKER)

    inst.components.combat:SetTarget(nil)

    inst:ListenForEvent("entity_death", inst.listenfn, TheWorld)
end

local function SetNightmareMonkey(inst)
    inst:AddTag("nightmare")
    inst.AnimState:SetMultColour(1, 1, 1, .6)
    inst:SetBrain(nightmarebrain)
    inst.AnimState:SetBuild("kiki_nightmare_skin")
    inst.soundtype = "_nightmare"
    SetHarassPlayer(inst, nil)
    inst.curious = false
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end

    inst.components.acidinfusible:SetMultipliers(TUNING.ACID_INFUSION_MULT.BERSERKER)

    inst.components.combat:SetTarget(nil)

    inst:RemoveEventCallback("entity_death", inst.listenfn, TheWorld)
end

local function SetNightmareMonkeyLoot(inst, forced)
	if forced then
		inst.components.lootdropper:SetLoot(FORCED_NIGHTMARE_LOOT)
	else
		inst.components.lootdropper:SetLoot(nil)
	end
    inst.components.lootdropper:SetChanceLootTable("monkey")
end

local function IsForcedNightmare(inst)
	return inst.components.timer:TimerExists("forcenightmare")
end

local function IsWorldNightmare(inst, phase)
	return phase == "wild" or phase == "dawn"
end

local function OnTimerDone(inst, data)
	if not data then
        return
    end

    if data.name == "forcenightmare" then
		if IsWorldNightmare(inst, TheWorld.state.nightmarephase) and inst:HasTag("nightmare") then
			SetNightmareMonkeyLoot(inst, false)
		else
			if not (inst:IsInLimbo() or inst:IsAsleep()) then
				if inst.sg:HasStateTag("busy") and not inst.sg:HasStateTag("sleeping") then
					inst.components.timer:StartTimer("forcenightmare", 1)
					return
				end
				DoForceNightmareFx(inst, false)
			end
			SetNormalMonkey(inst)
		end
		inst:RemoveEventCallback("timerdone", OnTimerDone)
	end
end

local function OnForceNightmareState(inst, data)
	if data ~= nil and data.duration ~= nil then
		if inst.components.health:IsDead() then
			return
		end
		local t = inst.components.timer:GetTimeLeft("forcenightmare")
		if t ~= nil then
			if t < data.duration then
				inst.components.timer:SetTimeLeft("forcenightmare", data.duration)
			end
			return
		end
		inst.components.timer:StartTimer("forcenightmare", data.duration)
		inst:ListenForEvent("timerdone", OnTimerDone)
		if not inst:HasTag("nightmare") then
			DoForceNightmareFx(inst, true)
			SetNightmareMonkey(inst)
		end
		SetNightmareMonkeyLoot(inst, true)
	end
end

local function TestNightmarePhase(inst, phase)
	if not IsForcedNightmare(inst) then
		if IsWorldNightmare(inst, phase) then
			if inst.components.areaaware:CurrentlyInTag("Nightmare") and not inst:HasTag("nightmare") then
				DoFx(inst)
				SetNightmareMonkey(inst)
				SetNightmareMonkeyLoot(inst, false)
			end
		elseif inst:HasTag("nightmare") then
			DoFx(inst)
			SetNormalMonkey(inst)
		end
	end
end

local function TestNightmareArea(inst)--, area)
	TestNightmarePhase(inst, TheWorld.state.nightmarephase)
end

local function OnCustomHaunt(inst)
    inst.components.periodicspawner:TrySpawn()
    return true
end

local function OnSave(inst, data)
    data.nightmare = inst:HasTag("nightmare") or nil
end

local function OnLoad(inst, data)
	if IsForcedNightmare(inst) then
		inst:ListenForEvent("timerdone", OnTimerDone)
		SetNightmareMonkey(inst)
		SetNightmareMonkeyLoot(inst, true)
	elseif data ~= nil and data.nightmare then
        SetNightmareMonkey(inst)
		SetNightmareMonkeyLoot(inst, false)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(2, 1.25)

    inst.Transform:SetSixFaced()

    MakeCharacterPhysics(inst, 10, 0.25)

    inst.AnimState:SetBank("kiki")
    inst.AnimState:SetBuild("kiki_basic")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst:AddTag("cavedweller")
    inst:AddTag("monkey")
    inst:AddTag("animal")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.soundtype = ""

    MakeMediumBurnableCharacter(inst)
    MakeMediumFreezableCharacter(inst)

    inst:AddComponent("bloomer")

    inst:AddComponent("inventory")

    inst:AddComponent("inspectable")

    inst:AddComponent("thief")

    local locomotor = inst:AddComponent("locomotor")
    locomotor:SetSlowMultiplier( 1 )
    locomotor:SetTriggersCreep(false)
    locomotor.pathcaps = { ignorecreep = false }
    locomotor.walkspeed = TUNING.MONKEY_MOVE_SPEED

    local combat = inst:AddComponent("combat")
    combat:SetAttackPeriod(TUNING.MONKEY_ATTACK_PERIOD)
    combat:SetRange(TUNING.MONKEY_MELEE_RANGE)
    combat:SetRetargetFunction(1, retargetfn)
    combat:SetKeepTargetFunction(shouldKeepTarget)
    combat:SetDefaultDamage(0)  --This doesn't matter, monkey uses weapon damage

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.MONKEY_HEALTH)

    local periodicspawner = inst:AddComponent("periodicspawner")
    periodicspawner:SetPrefab("poop")
    periodicspawner:SetRandomTimes(200,400)
    periodicspawner:SetDensityInRange(20, 2)
    periodicspawner:SetMinimumSpacing(15)
    periodicspawner:Start()

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(LOOT)

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.VEGGIE }, { FOODTYPE.VEGGIE })
    inst.components.eater:SetOnEatFn(oneat)

    inst:AddComponent("sleeper")
    inst.components.sleeper.sleeptestfn = NocturnalSleepTest
    inst.components.sleeper.waketestfn = NocturnalWakeTest

    inst:AddComponent("areaaware")

    inst:AddComponent("acidinfusible")
    inst.components.acidinfusible:SetFXLevel(1)
    inst.components.acidinfusible:SetMultipliers(TUNING.ACID_INFUSION_MULT.WEAKER)

    inst:SetBrain(brain)
    inst:SetStateGraph("SGmonkey")

    inst.FindTargetOfInterestTask = inst:DoPeriodicTask(10, FindTargetOfInterest) --Find something to be interested in!

    inst.HasAmmo = hasammo
    inst.curious = true
    inst.harassplayer = nil
    inst._onharassplayerremoved = function() SetHarassPlayer(inst, nil) end

    inst:AddComponent("knownlocations")
	inst:AddComponent("timer")

    inst.listenfn = function(listento, data) OnMonkeyDeath(inst, data) end

    inst:ListenForEvent("onpickupitem", OnPickup)
    inst:ListenForEvent("attacked", OnAttacked)

    inst:WatchWorldState("nightmarephase", TestNightmarePhase)
    inst:ListenForEvent("changearea", TestNightmareArea)

	--shadow_trap interaction
	inst.has_nightmare_state = true
	inst:ListenForEvent("ms_forcenightmarestate", OnForceNightmareState)

    MakeHauntablePanic(inst)
    AddHauntableCustomReaction(inst, OnCustomHaunt, true, false, true)

    inst.weaponitems = {}
    EquipWeapons(inst)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("monkey", fn, assets, prefabs)
