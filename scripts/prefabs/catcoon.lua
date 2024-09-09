local brain = require("brains/catcoonbrain")

local assets =
{
	Asset("ANIM", "anim/catcoon_build.zip"),
	Asset("ANIM", "anim/catcoon_basic.zip"),
	Asset("ANIM", "anim/catcoon_actions.zip"),
	Asset("SOUND", "sound/catcoon.fsb"),
}

local prefabs =
{
	"mole",
	"rabbit",
	"flint",
	"tumbleweed",
	"cutgrass",
	"twigs",
	"berries",
	"goldnugget",
	"smallmeat",
	"silk",
	"coontail",
	"rocks",
	"bee",
	"mosquito",
	"cutreeds",
	"tentaclespots",
	"beefalowool",
	"feather_robin",
	"feather_robin_winter",
	"feather_canary",
	"feather_crow",
	"boneshard",
	"red_cap",
	"blue_cap",
	"green_cap",
	"carrot_seeds",
	"corn_seeds",
	"pumpkin_seeds",
	"eggplant_seeds",
	"durian_seeds",
	"pomegranate_seeds",
	"dragonfruit_seeds",
	"watermelon_seeds",
    "potato_seeds",
    "tomato_seeds",
    "asparagus_seeds",
    "onion_seeds",
    "garlic_seeds",
    "pepper_seeds",
	"butterfly",
	"robin",
	"robin_winter",
	"canary",
	"crow",
	"pondfish",
	"transistor",
	"froglegs",
	"batwing",
	"petals",
	"petals_evil",
	"ash",
	"acorn",
	"pinecone",
	"ice",
	"redpouch_yot_catcoon",
}

SetSharedLootTable( 'catcoon',
{
    {'meat',             1.00},
    {'coontail',		 0.33},
})

local neutralGiftPrefabs =
{
	{ --tier 1
		"wetgoop",
	},
	{ --tier 2
		"spoiled_food",
		"wetgoop",
	},
	{ --tier 3
		"cutgrass",
		"spoiled_food",
	},
	{ --tier 4
		"cutgrass",
		"spoiled_food",
	},
	{ --tier 5
		"cutgrass",
		"rocks",
		"petals_evil",
	},
	{ --tier 6
		"rocks",
		"flint",
		"petals",
	},
	{ --tier 7
		"ice",
		"flint",
		"pinecone",
	},
	{ --tier 8
		"flint",
		"pinecone",
		"feather_robin",
	},
	{ --tier 9
		"mole",
		"acorn",
	}
}

local friendGiftPrefabs =
{
	{ -- tier 1 (basic seeds)
		"carrot_seeds",
		"corn_seeds",
        "potato_seeds",
        "tomato_seeds",
	},
	{ -- tier 2 (basic, generic stuff)
		"flint",
		"cutgrass",
		"twigs",
		"rocks",
		"ash",
		"pinecone",
		"petals",
		"petals_evil",
	},
	{ -- tier 3 (non-food animal bits)
		"feather_robin",
		"feather_robin_winter",
		"feather_crow",
		"feather_canary",
		"boneshard",
	},
	{ -- tier 4 (better seeds)
		"pumpkin_seeds",
		"eggplant_seeds",
		"durian_seeds",
		"pomegranate_seeds",
		"dragonfruit_seeds",
		"watermelon_seeds",
        "asparagus_seeds",
        "onion_seeds",
        "garlic_seeds",
        "pepper_seeds",
	},
	{ --tier 5 (food)
		"ice",
		"batwing",
		"acorn",
		"berries",
		"smallmeat",
		"red_cap",
		"blue_cap",
		"green_cap",
		"pondfish",
		"froglegs",
	},
	{ --tier 6 (live animals + tumbleweed)
		"mole",
		"rabbit",
		"bee",
		"butterfly",
		"robin",
		"robin_winter",
		"canary",
		"crow",
		"tumbleweed",
	},
	{ -- tier 7 (good generic stuff)
		"goldnugget",
		"silk",
		"cutreeds",
		"tentaclespots",
		"beefalowool",
		"transistor",
	},
}

local function OnAttacked(inst, data)
	if inst.components.combat and not inst.components.combat.target then
		inst.sg:GoToState("hiss")
	end
    if inst.components.combat then inst.components.combat:SetTarget(data.attacker) end
end

local function KeepTargetFn(inst, target)
	if target:HasTag("catcoon") then
		return (target
	    	and target.components.combat
	        and target.components.health
	        and not target.components.health:IsDead()
	        and not (inst.components.follower and inst.components.follower:IsLeaderSame(target))
	        and not (inst.components.follower and inst.components.follower.leader == target))
	else
	    return (target
	    	and target.components.combat
	        and target.components.health
	        and not target.components.health:IsDead()
	        and not (inst.components.follower and inst.components.follower.leader == target))
	end
end

local RETARGET_TAGS = {"_health"}
local RETARGET_NO_TAGS = {"INLIMBO", "notarget", "invisible" }

local function RetargetFn(inst)
    return FindEntity(inst, TUNING.CATCOON_TARGET_DIST,
        function(guy)
        	if guy:HasTag("catcoon") then
        		return 	not (inst.components.follower and inst.components.follower:IsLeaderSame(guy))
        				and not (inst.components.follower and guy.components.follower and inst.components.follower.leader == nil and guy.components.follower.leader == nil)
        				and guy.components.health
	            		and not guy.components.health:IsDead()
	            		and inst.components.combat:CanTarget(guy)
        	else
            	return 	((guy:HasTag("monster") or guy:HasTag("smallcreature"))
	            		and guy.components.health
	            		and not guy.components.health:IsDead()
	            		and inst.components.combat:CanTarget(guy)
	            		and not (inst.components.follower and inst.components.follower.leader ~= nil and guy:HasTag("abigail")))
            			and not (inst.components.follower and inst.components.follower:IsLeaderSame(guy))
	            	or 	(guy:HasTag("cattoyairborne")
            			and not (inst.components.follower and inst.components.follower:IsLeaderSame(guy)))
	        end
        end, 
		RETARGET_TAGS, RETARGET_NO_TAGS)
end

local function SleepTest(inst)
	if ( inst.components.follower and inst.components.follower.leader )
		or ( inst.components.combat and inst.components.combat.target )
		or inst.components.playerprox:IsPlayerClose()
		or TheWorld.state.israining and inst.components.rainimmunity == nil then
		return
	end
	if not inst.sg:HasStateTag("busy") and (not inst.last_wake_time or GetTime() - inst.last_wake_time >= inst.nap_interval) then
		inst.nap_length = math.random(TUNING.MIN_CATNAP_LENGTH, TUNING.MAX_CATNAP_LENGTH)
		inst.last_sleep_time = GetTime()
		return true
	end
end

local function WakeTest(inst)
	if not inst.last_sleep_time
		or GetTime() - inst.last_sleep_time >= inst.nap_length
		or TheWorld.state.israining and inst.components.rainimmunity == nil then
		inst.nap_interval = math.random(TUNING.MIN_CATNAP_INTERVAL, TUNING.MAX_CATNAP_INTERVAL)
		inst.last_wake_time = GetTime()
		return true
	end
end

local function PickRandomGift(inst, tier)
	local table = (inst.components.follower and inst.components.follower.leader) and
		friendGiftPrefabs or neutralGiftPrefabs
	-- Neutral and friend tables aren't the same size. Make sure we're in valid range in case loyalty gets added/expired while retching.
	if tier > #table then tier = #table end
	return GetRandomItem(table[tier])
end

local function ShouldAcceptItem(inst, item)
	if item:HasTag("cattoy") or item:HasTag("catfood") or item:HasTag("cattoyairborne") then
		return true
	else
		return false
	end
end

local function OnGetItemFromPlayer(inst, giver, item)
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
    if inst.components.combat.target == giver then
        inst.components.combat:SetTarget(nil)
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/pickup")
    elseif giver.components.leader ~= nil then
		if giver.components.minigame_participator == nil then
			giver:PushEvent("makefriend")
	        giver.components.leader:AddFollower(inst)
		end
        inst.last_hairball_time = GetTime()
        inst.hairball_friend_interval = math.random(2,4) -- Jumpstart the hairball timer (slot machine time!)
        inst.components.follower:AddLoyaltyTime(TUNING.CATCOON_LOYALTY_PER_ITEM)
        if not inst.sg:HasStateTag("busy") then
            inst:FacePoint(giver.Transform:GetWorldPosition())
            inst.sg:GoToState("pawground")
       	end
    end
    item:Remove()
end

local function OnRefuseItem(inst, item)
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/hiss_pre")
	if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    -- elseif not inst.sg:HasStateTag("busy") then
    -- 	inst.sg:GoToState("hiss")
    end
end

local function ApplyRaining(inst)
    inst._catcoonraintask = nil
    inst.raining = TheWorld.state.israining
end

local function ScheduleRaining(inst)
    if TheWorld.state.israining and inst.components.rainimmunity == nil and inst._catcoonraintask == nil then
        inst._catcoonraintask = inst:DoTaskInTime(math.random(2,6), ApplyRaining)
    end
end

local function OnIsRaining(inst, raining)
	if raining then
        inst:ScheduleRaining()
	end
end

local function OnWentHome(inst)
    local den = inst.components.homeseeker and inst.components.homeseeker.home or nil
	if den ~= nil and den.CacheItemsAtHome ~= nil then
		den:CacheItemsAtHome(inst)
	end
end

local function OnLoadPostPass(inst, newents, data)
    inst:ScheduleRaining()
end

local function OnRainImmunity(inst)
    if inst._catcoonraintask ~= nil then
        inst._catcoonraintask:Cancel()
        inst._catcoonraintask = nil
    end
    inst.raining = false
end

local function OnRainVulnerable(inst)
    inst:ScheduleRaining()
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

	inst.DynamicShadow:SetSize(2,0.75)
	inst.Transform:SetFourFaced()

	MakeCharacterPhysics(inst, 1, 0.5)

	inst.AnimState:SetBank("catcoon")
	inst.AnimState:SetBuild("catcoon_build")
	inst.AnimState:PlayAnimation("idle_loop")

	inst.scrapbook_deps = {"meat","coontail"}

	inst:AddTag("smallcreature")
	inst:AddTag("animal")
	inst:AddTag("catcoon")

    --trader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")

	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(TUNING.CATCOON_LIFE)

	inst:AddComponent("combat")
	inst.components.combat:SetDefaultDamage(TUNING.CATCOON_DAMAGE)
	inst.components.combat:SetRange(TUNING.CATCOON_ATTACK_RANGE)
    inst.components.combat:SetAttackPeriod(TUNING.CATCOON_ATTACK_PERIOD)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetRetargetFunction(3, RetargetFn)
    inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/catcoon/hurt")
    inst:ListenForEvent("attacked", OnAttacked)
    inst.components.combat.battlecryinterval = 20

	inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('catcoon')

	inst:AddComponent("follower")
    inst.components.follower.maxfollowtime = TUNING.CATCOON_LOYALTY_MAXTIME

	inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
    inst.components.trader.deleteitemonaccept = false
	inst.components.trader.acceptnontradable = true
    inst.last_hairball_time = GetTime()
    inst.hairball_friend_interval = math.random(TUNING.MIN_HAIRBALL_FRIEND_INTERVAL, TUNING.MAX_HAIRBALL_FRIEND_INTERVAL)
    inst.hairball_neutral_interval = math.random(TUNING.MIN_HAIRBALL_NEUTRAL_INTERVAL, TUNING.MAX_HAIRBALL_NEUTRAL_INTERVAL)

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(3,4)
    inst.components.playerprox:SetOnPlayerNear(function(inst)
    	if inst.components.sleeper:IsAsleep() then
    		inst.components.sleeper:WakeUp()
    	end
    end)

	inst:AddComponent("sleeper")
    --inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.last_sleep_time = nil
    inst.last_wake_time = GetTime()
    inst.nap_interval = math.random(TUNING.MIN_CATNAP_INTERVAL, TUNING.MAX_CATNAP_INTERVAL)
    inst.nap_length = math.random(TUNING.MIN_CATNAP_LENGTH, TUNING.MAX_CATNAP_LENGTH)
    inst.components.sleeper:SetWakeTest(WakeTest)
    inst.components.sleeper:SetSleepTest(SleepTest)

	inst:AddComponent("locomotor")
	inst.components.locomotor.walkspeed = 3

    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = 4

    -- boat hopping
    inst.components.locomotor:SetAllowPlatformHopping(true)
    inst:AddComponent("embarker")
    inst.components.embarker.embark_speed = inst.components.locomotor.walkspeed + 2
    inst:AddComponent("drownable")

	inst:WatchWorldState("israining", OnIsRaining)

    inst.force_onwenthome_message = true -- for onwenthome event
    inst:ListenForEvent("onwenthome", OnWentHome)

	MakeSmallBurnableCharacter(inst, "catcoon_torso", Vector3(1,0,1))
	MakeSmallFreezableCharacter(inst)

	inst:SetBrain(brain)
	inst:SetStateGraph("SGcatcoon")

	inst.neutralGiftPrefabs = neutralGiftPrefabs
	inst.friendGiftPrefabs = friendGiftPrefabs
	inst.PickRandomGift = PickRandomGift

    inst.ScheduleRaining = ScheduleRaining
    inst.OnLoadPostPass = OnLoadPostPass

	MakeHauntablePanicAndIgnite(inst)

    inst:ListenForEvent("gainrainimmunity", OnRainImmunity)
    inst:ListenForEvent("loserainimmunity", OnRainVulnerable)

	return inst
end

return Prefab("catcoon", fn, assets, prefabs)
