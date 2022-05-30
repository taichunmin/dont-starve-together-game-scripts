
local prefabs = 
{
	"kitcoon_hider_prop",
	"kitcoon_hide_fx",
}

NUM_BASIC_KITCOONS = 0 -- global constant. This will be set via MakeKitcoon

local brain = require("brains/kitcoonbrain")

local WAKE_TO_FOLLOW_DISTANCE = 4
local SLEEP_NEAR_LEADER_DISTANCE = 2.5
local SCARRY_WAKEUP_DIST = 6

local KITTEN_SCALE = 0.7

-------------------------------------------------------------------------------


local function ShouldWakeUp(inst)
	return DefaultWakeTest(inst) or (inst.components.follower.leader ~= nil and not inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE))
end

local function ShouldSleep(inst)
	return DefaultSleepTest(inst) and (inst.components.follower.leader == nil or inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE))
end

-------------------------------------------------------------------------------
local function GetPeepChance(inst)
    return 0
end

local function IsPlayful(inst)
	return true
end

local function IsSuperCute(inst)
	return true
end

-------------------------------------------------------------------------------

local function DoPanic(inst, data)
	inst.components.timer:StopTimer("panic")
	inst.components.timer:StartTimer("panic", data ~= nil and data.duration or (4 + math.random() * 2))
end

local function TeleportHome(inst)
	local den = inst.components.entitytracker:GetEntity("home")
	if den ~= nil then
		if not den:IsNear(inst, TUNING.KITCOON_NEAR_DEN_DIST) then
            local den_position = den:GetPosition()
            local offset = FindWalkableOffset(den_position, 2*PI*math.random(), 1)
            local return_position = den_position + (offset or 0)

			inst.Physics:Teleport(return_position:Get())
			inst.components.sleeper:WakeUp()
			inst.sg:GoToState("evicted")
		end
		return true
	end
	
	return false
end

-------------------------------------------------------------------------------

local function OnFound(inst, doer)
	inst:RemoveTag("NOCLICK")

	if doer ~= nil and doer.isplayer and doer.components.health ~= nil and not doer.components.health:IsDead() then
		if inst.components.entitytracker:GetEntity("home") ~= nil then
			inst.components.timer:StartTimer("teleport_home", 10)
		else
			if doer.components.leader ~= nil then
				doer:PushEvent("makefriend")
				doer.components.leader:AddFollower(inst)
			end

			if inst._first_nuzzle and doer ~= nil and doer.components.talker ~= nil then
				doer.components.talker:Say(GetString(doer, "ANNOUNCE_KITCOON_FOUND_IN_THE_WILD"))
			end
		end

		inst:FacePoint(doer.Transform:GetWorldPosition())
	    inst.sg:GoToState("found", doer)
	elseif inst:IsAsleep() then
		TeleportHome(inst)
	else
		if inst.components.entitytracker:GetEntity("home") ~= nil then
			inst.components.timer:StartTimer("teleport_home", 10)
		end
	    inst.sg:GoToState("evicted")
		DoPanic(inst)
	end
end

local function do_endofhiding_jump(inst)
	inst.components.timer:StopTimer("panic")
    inst.sg:GoToState("endofhiding_jump")
end

local PREHIDE_ANIM_LEN = 29*FRAMES
local function StartGoingToHidingSpot(inst, hiding_spot, hide_time)
	-- disable interacting
	inst:AddTag("NOCLICK")

    if hide_time < PREHIDE_ANIM_LEN + 2*FRAMES then
	    DoPanic(inst, {duration = hide_time})
    else
        local panic_time = hide_time - PREHIDE_ANIM_LEN
        DoPanic(inst, {duration = panic_time})
        inst:DoTaskInTime(panic_time, do_endofhiding_jump)
    end

    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/pounce")
end

local function OnHide_HideAndSeek(inst, hiding_spot)
    local fx = SpawnPrefab("kitcoon_hide_fx")
	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	fx.Transform:SetRotation(inst.Transform:GetRotation())
	fx.AnimState:OverrideSymbol("hair", inst.AnimState:GetBuild(), "hair")

    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/emote")
end

local function OnPetted(inst, data)
	local doer = data ~= nil and data.doer
	if doer and doer.components.leader ~= nil then
		inst.components.sleeper:WakeUp()

		if inst.components.follower.leader ~= doer then
			doer:PushEvent("makefriend")
			doer.components.leader:AddFollower(inst)
		end

		inst.components.timer:StopTimer("panic")
		inst.components.timer:StopTimer("teleport_home") -- must happen after AddFollower

		inst:FacePoint(doer.Transform:GetWorldPosition())
		inst.sg:GoToState("nuzzle")
	end
end

local function OnChangedLeader(inst, new_leader)
	if new_leader == nil then
		local x, y, z = inst.Transform:GetWorldPosition()
		local den = TheSim:FindEntities(x, y, z, TUNING.KITCOON_NEAR_DEN_DIST, {"kitcoonden"})[1]
		if den ~= nil then
			den.components.kitcoonden:AddKitcoon(inst)
		end
	else
		inst.components.hideandseekhider:Abort()

		local den = inst.components.entitytracker:GetEntity("home")
		if den ~= nil and den.components.kitcoonden ~= nil then
			den.components.kitcoonden:RemoveKitcoon(inst)
		end
	end
end


local function OnTimerDone(inst, data)
	if data ~= nil then
		if data.name == "teleport_home" then
			TeleportHome(inst)
		end
	end
end

-------------------------------------------------------------------------------
-- Toy Following behaviours

local function clear_toy_follow(inst)
    inst._toy_follow_target = nil
end

local function OnPlayedWithToy(inst, toy)
    if toy and toy:HasTag("kitcoonfollowtoy") then
        inst._toy_follow_target = toy
        inst:DoTaskInTime(2, clear_toy_follow)
    end
end

-------------------------------------------------------------------------------

local function OnSave(inst, data)
	data._first_nuzzle = inst._first_nuzzle
end

local function OnLoad(inst, data)
	inst._first_nuzzle = data ~= nil and data._first_nuzzle or nil
end

local function OnLoadPostPass(inst, newents, data)
	local den = inst.components.entitytracker:GetEntity("home")
	if den ~= nil and den.components.kitcoonden ~= nil then
		den.components.kitcoonden:AddKitcoon(inst)
	end	
end

-------------------------------------------------------------------------------

local function MakeKitcoon(name, is_unique)
    local assets =
    {
	    Asset("ANIM", "anim/"..name.."_build.zip"),
	    Asset("ANIM", "anim/kitcoon_basic.zip"),
	    Asset("ANIM", "anim/kitcoon_emotes.zip"),
	    Asset("ANIM", "anim/kitcoon_traits.zip"),
	    Asset("ANIM", "anim/kitcoon_jump.zip"),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddDynamicShadow()
        inst.entity:AddNetwork()

        inst.Transform:SetSixFaced()
        inst.Transform:SetScale(KITTEN_SCALE, KITTEN_SCALE, KITTEN_SCALE)

        inst.AnimState:SetBank("kitcoon")
        inst.AnimState:SetBuild(name.."_build")
        inst.AnimState:PlayAnimation("idle_loop")

        inst.DynamicShadow:SetSize(1, .33)

        MakeCharacterPhysics(inst, 1, .5)

		inst.Physics:SetDontRemoveOnSleep(true) -- critters dont really go do entitysleep as it triggers a teleport to near the owner, so no point in hitting the physics engine.

        inst:AddTag("kitcoon")
        inst:AddTag("companion")
        inst:AddTag("notraptrigger")
        inst:AddTag("noauradamage")
        inst:AddTag("NOBLOCK")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.GetPeepChance = GetPeepChance
        inst.IsPlayful = IsPlayful
		inst.playmatetags = {"kitcoon"}

        inst._hiding_prop = "kitcoon_hider_prop"
		
		inst._first_nuzzle = true
		inst.next_play_time = GetTime() + TUNING.KITCOON_PLAYFUL_DELAY + math.random() * TUNING.KITCOON_PLAYFUL_DELAY_RAND

		inst:AddComponent("inspectable")

        inst:AddComponent("follower")
        inst.components.follower.keepleaderduringminigame = true
		inst.components.follower.OnChangedLeader = OnChangedLeader

        inst:AddComponent("entitytracker")

		inst:AddComponent("kitcoon")

		inst:AddComponent("named")

		inst:AddComponent("timer")
		inst:ListenForEvent("timerdone", OnTimerDone)

        inst:AddComponent("sleeper")
        inst.components.sleeper:SetResistance(3)
        inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
        inst.components.sleeper:SetSleepTest(ShouldSleep)
        inst.components.sleeper:SetWakeTest(ShouldWakeUp)

        inst:AddComponent("locomotor")
        inst.components.locomotor:SetTriggersCreep(false)
        inst.components.locomotor.softstop = true
        inst.components.locomotor.walkspeed = TUNING.KITCOON_WALK_SPEED / KITTEN_SCALE
        inst.components.locomotor.runspeed = TUNING.KITCOON_RUN_SPEED / KITTEN_SCALE
        inst.components.locomotor:SetAllowPlatformHopping(true)

        inst:AddComponent("embarker")
        inst.components.embarker.embark_speed = inst.components.locomotor.walkspeed + 2
		inst:AddComponent("drownable")
    
		inst:AddComponent("hideandseekhider")
        inst.components.hideandseekhider.gohide_timeout = TUNING.KITCOON_HIDEANDSEEK_HIDETIMEOUT
		inst.components.hideandseekhider.StartGoingToHidingSpot = StartGoingToHidingSpot
		inst.components.hideandseekhider.OnFound = OnFound
        inst.components.hideandseekhider.OnHide = OnHide_HideAndSeek

		inst:ListenForEvent("on_petted", OnPetted)
		inst:ListenForEvent("epicscare", DoPanic)
        inst:ListenForEvent("on_played_with", OnPlayedWithToy)

        inst:SetBrain(brain)
        inst:SetStateGraph("SGkitcoon")

        inst.OnSave = OnSave
        inst.OnLoad = OnLoad
		inst.OnLoadPostPass = OnLoadPostPass

		if IsSpecialEventActive(SPECIAL_EVENTS.YOT_CATCOON) then
			local on_collect_allkitcoons = function(world, data)
				if data ~= nil and data.kitcoons ~= nil then
					table.insert(data.kitcoons, inst)
				end
			end

			inst:ListenForEvent("ms_collectallkitcoons", on_collect_allkitcoons, TheWorld)
		end

		if is_unique then
			local on_collect_uniquekitcoons = function(world, data)
				if data ~= nil and data.kitcoons ~= nil then
					table.insert(data.kitcoons, inst)
				end
			end

			inst:ListenForEvent("ms_collect_uniquekitcoons", on_collect_uniquekitcoons, TheWorld)
		end

        return inst
    end

	if not is_unique then
		NUM_BASIC_KITCOONS = NUM_BASIC_KITCOONS + 1
	end

    return Prefab(name, fn, assets, prefabs)
end


local function yotbuild_master_postinit(inst)
end

-------------------------------------------------------------------------------

local hiding_sounds = 
{
	"dontstarve_DLC001/creatures/together/kittington/emote",
	"dontstarve_DLC001/creatures/together/kittington/emote_nuzzle",
	"dontstarve_DLC001/creatures/together/kittington/emote_nuzzle",
	"dontstarve_DLC001/creatures/together/kittington/sleep",
	"dontstarve_DLC001/creatures/together/kittington/sleep",
	"dontstarve_DLC001/creatures/together/kittington/sleep",
}

local function play_hider_periodic_sound(inst)
    inst.SoundEmitter:PlaySound(hiding_sounds[math.random(#hiding_sounds)], nil, 0.5)
	
end

local function OnHiderPropSleep(inst)
    if inst._sound_task ~= nil then
        inst._sound_task:Cancel()
        inst._sound_task = nil
    end
end

local function OnHiderPropWake(inst)
    if not inst:IsInLimbo() and inst._sound_task == nil then
        inst._sound_task = inst:DoPeriodicTask(TUNING.KITCOON_HIDING_SOUND_FREQUENCY, play_hider_periodic_sound, math.random(TUNING.KITCOON_HIDING_SOUND_FREQUENCY))
    end
end

local function hider_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetScale(KITTEN_SCALE, KITTEN_SCALE, KITTEN_SCALE)

    inst.AnimState:SetBank("kitcoon")
    inst.AnimState:SetBuild("kitcoon_savanna_build")
    inst.AnimState:PlayAnimation("hiding_small", true)
    inst.AnimState:SetFinalOffset(-1)

	inst:AddTag("DECOR")

    inst:AddComponent("spawnfader")
	inst.components.spawnfader:FadeIn()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.persits = false

    inst._sound_task = inst:DoPeriodicTask(TUNING.KITCOON_HIDING_SOUND_FREQUENCY, play_hider_periodic_sound, math.random(TUNING.KITCOON_HIDING_SOUND_FREQUENCY))

    inst.OnEntitySleep = OnHiderPropSleep
    inst.OnEntityWake = OnHiderPropWake

	return inst
end

-------------------------------------------------------------------------------
local function hide_fx_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetSixFaced()
    --inst.Transform:SetScale(KITTEN_SCALE, KITTEN_SCALE, KITTEN_SCALE)

    inst.AnimState:SetBank("kitcoon_fx")
    inst.AnimState:SetBuild("kitcoon_fx")
    inst.AnimState:PlayAnimation("kitcoon_fx")
    inst.AnimState:SetFinalOffset(1)

	inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.persits = false

	inst:DoTaskInTime(1, inst.Remove)
	inst:ListenForEvent("animover", inst.Remove)

	return inst
end

-------------------------------------------------------------------------------
return MakeKitcoon("kitcoon_forest"),
	MakeKitcoon("kitcoon_savanna"),
	MakeKitcoon("kitcoon_deciduous"),
	MakeKitcoon("kitcoon_marsh"),
	MakeKitcoon("kitcoon_grass"),
	MakeKitcoon("kitcoon_rocky"),
	MakeKitcoon("kitcoon_desert"),
	MakeKitcoon("kitcoon_moon"),
	MakeKitcoon("kitcoon_yot", true),
	Prefab("kitcoon_hider_prop", hider_fn),
	Prefab("kitcoon_hide_fx", hide_fx_fn, {Asset("ANIM", "anim/kitcoon_fx.zip")})
