local assets =
{
    Asset("ANIM", "anim/hound_basic.zip"),
    Asset("ANIM", "anim/hound_basic_water.zip"),
    Asset("ANIM", "anim/hound_ocean.zip"),
    Asset("ANIM", "anim/hound_red_ocean.zip"),
    Asset("ANIM", "anim/hound_ice_ocean.zip"),
    Asset("ANIM", "anim/hound_mutated.zip"),
    Asset("ANIM", "anim/hound_hedge_ocean.zip"),
    Asset("ANIM", "anim/hound_hedge_action.zip"),
    Asset("ANIM", "anim/hound_hedge_action_water.zip"),
    Asset("SOUND", "sound/hound.fsb"),

	--DEPRECATED builds!!!
	Asset("PKGREF", "anim/hound.zip"), --NOTE: unfortunately houndcorpse still uses this
	Asset("PKGREF", "anim/hound_red.zip"),
	Asset("PKGREF", "anim/hound_ice.zip"),
}

local assets_clay =
{
    Asset("ANIM", "anim/clayhound.zip"),
}

local prefabs =
{
    "houndstooth",
    "monstermeat",
    "redgem",
    "bluegem",
    "splash_green",
	"houndcorpse",
}

local prefabs_clay =
{
    "houndstooth",
    "redpouch",
    "eyeflame",
}

local gargoyles =
{
    "gargoyle_houndatk",
    "gargoyle_hounddeath",
}
local prefabs_moon = {}
for i, v in ipairs(gargoyles) do
    table.insert(prefabs_moon, v)
end
for i, v in ipairs(prefabs) do
    table.insert(prefabs_moon, v)
end

local brain = require("brains/houndbrain")
local moonbrain = require("brains/moonbeastbrain")

local sounds =
{
    pant = "dontstarve/creatures/hound/pant",
    attack = "dontstarve/creatures/hound/attack",
    bite = "dontstarve/creatures/hound/bite",
    bark = "dontstarve/creatures/hound/bark",
    death = "dontstarve/creatures/hound/death",
    sleep = "dontstarve/creatures/hound/sleep",
    growl = "dontstarve/creatures/hound/growl",
    howl = "dontstarve/creatures/together/clayhound/howl",
    hurt = "dontstarve/creatures/hound/hurt",
}

local sounds_clay =
{
    pant = "dontstarve/creatures/together/clayhound/pant",
    attack = "dontstarve/creatures/together/clayhound/attack",
    bite = "dontstarve/creatures/together/clayhound/bite",
    bark = "dontstarve/creatures/together/clayhound/bark",
    death = "dontstarve/creatures/together/clayhound/death",
    sleep = "dontstarve/creatures/together/clayhound/sleep",
    growl = "dontstarve/creatures/together/clayhound/growl",
    howl = "dontstarve/creatures/together/clayhound/howl",
    hurt = "dontstarve/creatures/hound/hurt",
}

local sounds_mutated =
{
    pant = "turnoftides/creatures/together/mutated_hound/pant",
    attack = "turnoftides/creatures/together/mutated_hound/attack",
    bite = "turnoftides/creatures/together/mutated_hound/bite",
    bark = "turnoftides/creatures/together/mutated_hound/bark",
    death = "turnoftides/creatures/together/mutated_hound/death",
    sleep = "dontstarve/creatures/hound/sleep",
    growl = "turnoftides/creatures/together/mutated_hound/growl",
    howl = "dontstarve/creatures/together/clayhound/howl",
    hurt = "turnoftides/creatures/together/mutated_hound/hurt",
}

local sounds_hedge =
{
    pant = "dontstarve/creatures/hound/pant",
    attack = "dontstarve/creatures/hound/attack",
    bite = "dontstarve/creatures/hound/bite",
    bark = "dontstarve/creatures/hound/bark",
    death = "stageplay_set/briar_wolf/destroyed",
    sleep = "dontstarve/creatures/hound/sleep",
    growl = "dontstarve/creatures/hound/growl",
    howl = "dontstarve/creatures/together/clayhound/howl",
    hurt = "dontstarve/creatures/hound/hurt",
}

SetSharedLootTable('hound',
{
    {'monstermeat', 1.000},
    {'houndstooth', 0.125},
})

SetSharedLootTable('hound_fire',
{
    {'monstermeat', 1.0},
    {'houndstooth', 1.0},
    {'houndfire',   1.0},
    {'houndfire',   1.0},
    {'houndfire',   1.0},
    {'redgem',      0.2},
})

SetSharedLootTable('hound_cold',
{
    {'monstermeat', 1.0},
    {'houndstooth', 1.0},
    {'houndstooth', 1.0},
    {'bluegem',     0.2},
})

SetSharedLootTable('clayhound',
{
    {'redpouch',    0.2},
    {'houndstooth', 0.1},
})

SetSharedLootTable('mutatedhound',
{
    {'monstermeat', 1.0},
    {'houndstooth', 1.0},
    {'houndstooth', 1.0},
})

local WAKE_TO_FOLLOW_DISTANCE = 8
local SLEEP_NEAR_HOME_DISTANCE = 10
local SHARE_TARGET_DIST = 30
local HOME_TELEPORT_DIST = 30

local NO_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO" }
local FREEZABLE_TAGS = { "freezable" }

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst) or (inst.components.follower and inst.components.follower.leader and not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE))
end

local function ShouldSleep(inst)
    return inst:HasTag("pet_hound")
        and not TheWorld.state.isday
        and not (inst.components.combat and inst.components.combat.target)
        and not (inst.components.burnable and inst.components.burnable:IsBurning())
        and (not inst.components.homeseeker or inst:IsNear(inst.components.homeseeker.home, SLEEP_NEAR_HOME_DISTANCE))
end

local function OnNewTarget(inst, data)
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

local RETARGET_CANT_TAGS = { "wall", "houndmound", "hound", "houndfriend" }
local function retargetfn(inst)
    if inst.sg:HasStateTag("statue") then
        return
    end
    local leader = inst.components.follower.leader
    if leader ~= nil and leader.sg ~= nil and leader.sg:HasStateTag("statue") then
        return
    end
    local playerleader = leader ~= nil and leader:HasTag("player")
    local ispet = inst:HasTag("pet_hound")
    return (leader == nil or
            (ispet and not playerleader) or
            inst:IsNear(leader, TUNING.HOUND_FOLLOWER_AGGRO_DIST))
        and FindEntity(
                inst,
                (ispet or leader ~= nil) and TUNING.HOUND_FOLLOWER_TARGET_DIST or TUNING.HOUND_TARGET_DIST,
                function(guy)
                    return guy ~= leader and inst.components.combat:CanTarget(guy)
                end,
                nil,
                RETARGET_CANT_TAGS
            )
        or nil
end

local function KeepTarget(inst, target)
    if inst.sg:HasStateTag("statue") then
        return false
    end
    local leader = inst.components.follower.leader
    local playerleader = leader ~= nil and leader:HasTag("player")
    local ispet = inst:HasTag("pet_hound")
    return (leader == nil or
            (ispet and not playerleader) or
            inst:IsNear(leader, TUNING.HOUND_FOLLOWER_RETURN_DIST))
        and inst.components.combat:CanTarget(target)
        and (not (ispet or leader ~= nil) or
            inst:IsNear(target, TUNING.HOUND_FOLLOWER_TARGET_KEEP))
end

local function IsNearMoonBase(inst, dist)
    local moonbase = inst.components.entitytracker:GetEntity("moonbase")
    return moonbase == nil or inst:IsNear(moonbase, dist)
end

local MOON_RETARGET_CANT_TAGS = { "wall", "houndmound", "hound", "houndfriend", "moonbeast" }
local function moon_retargetfn(inst)
    return IsNearMoonBase(inst, TUNING.MOONHOUND_AGGRO_DIST)
        and FindEntity(
                inst,
                TUNING.HOUND_FOLLOWER_TARGET_DIST,
                function(guy)
                    return inst.components.combat:CanTarget(guy)
                end,
                nil,
                MOON_RETARGET_CANT_TAGS
            )
        or nil
end

local function moon_keeptargetfn(inst, target)
    return IsNearMoonBase(inst, TUNING.MOONHOUND_RETURN_DIST)
        and inst.components.combat:CanTarget(target)
        and inst:IsNear(target, TUNING.HOUND_FOLLOWER_TARGET_KEEP)
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, SHARE_TARGET_DIST,
        function(dude)
            return not (dude.components.health ~= nil and dude.components.health:IsDead())
                and (dude:HasTag("hound") or dude:HasTag("houndfriend"))
                and data.attacker ~= (dude.components.follower ~= nil and dude.components.follower.leader or nil)
        end, 5)
end

local function OnAttackOther(inst, data)
    inst.components.combat:ShareTarget(data.target, SHARE_TARGET_DIST,
        function(dude)
            return not (dude.components.health ~= nil and dude.components.health:IsDead())
                and (dude:HasTag("hound") or dude:HasTag("houndfriend"))
                and data.target ~= (dude.components.follower ~= nil and dude.components.follower.leader or nil)
        end, 5)
end

local function GetReturnPos(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local rad = 2
    local angle = math.random() * TWOPI
    return x + rad * math.cos(angle), y, z - rad * math.sin(angle)
end

local function DoReturn(inst)
    --print("DoReturn", inst)
    if inst.components.homeseeker ~= nil and inst.components.homeseeker:HasHome() then
        if inst:HasTag("pet_hound") then
            if inst.components.homeseeker.home:IsAsleep() and not inst:IsNear(inst.components.homeseeker.home, HOME_TELEPORT_DIST) then
                inst.Physics:Teleport(GetReturnPos(inst.components.homeseeker.home))
            end
        elseif inst.components.homeseeker.home.components.childspawner ~= nil then
            inst.components.homeseeker.home.components.childspawner:GoHome(inst)
        end
    end
end

local function OnEntitySleep(inst)
    --print("OnEntitySleep", inst)
    if not TheWorld.state.isday then
        DoReturn(inst)
    end
end

local function OnStopDay(inst)
    --print("OnStopDay", inst)
    if inst:IsAsleep() then
        DoReturn(inst)
    end
end

local function OnSpawnedFromHaunt(inst)
    if inst.components.hauntable ~= nil then
        inst.components.hauntable:Panic()
    end
end

local function OnSave(inst, data)
    data.ispet = inst:HasTag("pet_hound") or nil
    --print("OnSave", inst, data.ispet)
    data.hedgeitem = inst.hedgeitem
end

local function OnLoad(inst, data)
    --print("OnLoad", inst, data.ispet)
	if data ~= nil then
		if data.ispet then
			inst:AddTag("pet_hound")
			if inst.sg ~= nil then
				inst.sg:GoToState("idle")
			end
		end
		if data.hedgeitem then
			inst.hedgeitem = data.hedgeitem
		end
	end
end

local function GetStatus(inst)
    return (inst.sg:HasStateTag("statue") and "STATUE")
        or nil
end

local function OnEyeFlamesDirty(inst)
    if TheWorld.ismastersim then
        if not inst._eyeflames:value() then
            inst.AnimState:SetLightOverride(0)
            inst.SoundEmitter:KillSound("eyeflames")
        else
            inst.AnimState:SetLightOverride(.07)
            if not inst.SoundEmitter:PlayingSound("eyeflames") then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/torch_LP", "eyeflames")
                inst.SoundEmitter:SetParameter("eyeflames", "intensity", 1)
            end
        end
        if TheNet:IsDedicated() then
            return
        end
    end

    if inst._eyeflames:value() then
        if inst.eyefxl == nil then
            inst.eyefxl = SpawnPrefab("eyeflame")
            inst.eyefxl.entity:SetParent(inst.entity) --prevent 1st frame sleep on clients
            inst.eyefxl.entity:AddFollower()
            inst.eyefxl.Follower:FollowSymbol(inst.GUID, "hound_eye_left", 0, 0, 0)
        end
        if inst.eyefxr == nil then
            inst.eyefxr = SpawnPrefab("eyeflame")
            inst.eyefxr.entity:SetParent(inst.entity) --prevent 1st frame sleep on clients
            inst.eyefxr.entity:AddFollower()
            inst.eyefxr.Follower:FollowSymbol(inst.GUID, "hound_eye_right", 0, 0, 0)
        end
    else
        if inst.eyefxl ~= nil then
            inst.eyefxl:Remove()
            inst.eyefxl = nil
        end
        if inst.eyefxr ~= nil then
            inst.eyefxr:Remove()
            inst.eyefxr = nil
        end
    end
end

local function OnStartFollowing(inst, data)
    if inst.leadertask ~= nil then
        inst.leadertask:Cancel()
        inst.leadertask = nil
    end
    if data == nil or data.leader == nil then
        inst.components.follower.maxfollowtime = nil
    elseif data.leader:HasTag("player") then
        inst.components.follower.maxfollowtime = TUNING.HOUNDWHISTLE_EFFECTIVE_TIME * 1.5
    else
        inst.components.follower.maxfollowtime = nil
        if inst.components.entitytracker:GetEntity("leader") == nil then
            inst.components.entitytracker:TrackEntity("leader", data.leader)
        end
    end
end

local function RestoreLeader(inst)
    inst.leadertask = nil
    local leader = inst.components.entitytracker:GetEntity("leader")
    if leader ~= nil and not leader.components.health:IsDead() then
        inst.components.follower:SetLeader(leader)
        leader:PushEvent("restoredfollower", { follower = inst })
    end
end

local function OnStopFollowing(inst, data)
    inst.leader_offset = nil
	local leader = inst.components.entitytracker:GetEntity("leader")
    if not inst.components.health:IsDead() then
        if leader ~= nil and not leader.components.health:IsDead() then
            inst.leadertask = inst:DoTaskInTime(.2, RestoreLeader)
        end
	else
		--temp bridge until replaced by an actual hound_corpse.
		--otherwise, there's a tiny window during the death anim for too many
		--hounds to be summoned.
		if leader == nil and data ~= nil and data.leader ~= nil and data.leader:IsValid() then
			leader = data.leader
		end
		if leader.RememberFollowerCorpse ~= nil and inst:IsValid() then
			leader:RememberFollowerCorpse(inst)
		end
    end
end

local function CanMutateFromCorpse(inst)
	if inst.components.amphibiouscreature ~= nil and inst.components.amphibiouscreature.in_water then
		return false
	elseif inst.forcemutate then
		return true
	elseif not TUNING.SPAWN_MUTATED_HOUNDS then
		return false
	elseif math.random() <= TUNING.MUTATEDHOUND_SPAWN_CHANCE then
		return TheWorld.Map:IsInLunacyArea(inst.Transform:GetWorldPosition())
	end
	return false
end

local function OnChangedLeader(inst, new, old)
	--ignore if new is nil, (always nil upon death)
	if new ~= nil then
		if new.prefab == "mutatedwarg" then
			inst.forcemutate = true
			inst.wargleader = new
			inst.components.follower:KeepLeaderOnAttacked()
		else
			inst.forcemutate = nil
			inst.wargleader = nil
			inst.components.follower:LoseLeaderOnAttacked()
		end
	end
end

local function fncommon(bank, build, morphlist, custombrain, tag, data)
	data = data or {}

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 10, .5)

    inst.DynamicShadow:SetSize(2.5, 1.5)
    inst.Transform:SetFourFaced()

    inst:AddTag("scarytoprey")
    inst:AddTag("scarytooceanprey")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("hound")
    inst:AddTag("canbestartled")

    if tag ~= nil then
        inst:AddTag(tag)

        if tag == "clay" then
            inst._eyeflames = net_bool(inst.GUID, "clayhound._eyeflames", "eyeflamesdirty")
            inst:ListenForEvent("eyeflamesdirty", OnEyeFlamesDirty)
        end
    end

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle")

	if data.amphibious and build ~= "hound_ocean" then
		inst.AnimState:OverrideSymbol("shadow_ripple", "hound_ocean", "shadow_ripple")
		inst.AnimState:OverrideSymbol("water_ripple", "hound_ocean", "water_ripple")
	end

    inst:AddComponent("spawnfader")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -- NOTE(DiogoW): Ignore original dependencies.
    inst.scrapbook_deps = { }

	inst._CanMutateFromCorpse = data.canmutatefn

	inst.sounds = sounds

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = tag == "clay" and TUNING.CLAYHOUND_SPEED or TUNING.HOUND_SPEED

    inst:SetStateGraph("SGhound")

    if data.amphibious then
		inst:AddComponent("embarker")
		inst.components.embarker.embark_speed = inst.components.locomotor.runspeed
        inst.components.embarker.antic = true

	    inst.components.locomotor:SetAllowPlatformHopping(true)

		inst:AddComponent("amphibiouscreature")
		inst.components.amphibiouscreature:SetBanks(bank, bank.."_water")
        inst.components.amphibiouscreature:SetEnterWaterFn(
            function(inst)
                inst.landspeed = inst.components.locomotor.runspeed
                inst.components.locomotor.runspeed = TUNING.HOUND_SWIM_SPEED
                inst.hop_distance = inst.components.locomotor.hop_distance
                inst.components.locomotor.hop_distance = 4
            end)
        inst.components.amphibiouscreature:SetExitWaterFn(
            function(inst)
                if inst.landspeed then
                    inst.components.locomotor.runspeed = inst.landspeed
                end
                if inst.hop_distance then
                    inst.components.locomotor.hop_distance = inst.hop_distance
                end
            end)

		inst.components.locomotor.pathcaps = { allowocean = true }
	end

    inst:SetBrain(custombrain or brain)

    inst:AddComponent("follower")
	inst.components.follower.OnChangedLeader = OnChangedLeader

    inst:AddComponent("entitytracker")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.HOUND_HEALTH)

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.HOUND_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.HOUND_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(3, retargetfn)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetHurtSound(inst.sounds.hurt)
	inst.components.combat.lastwasattackedtime = -math.huge --for brain

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('hound')

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    if tag == "clay" then
        inst.sg:GoToState("statue")

        inst:AddComponent("hauntable")
        inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)
    else
        inst:AddComponent("eater")
        inst.components.eater:SetDiet({ FOODTYPE.MEAT }, { FOODTYPE.MEAT })
        inst.components.eater:SetCanEatHorrible()
        inst.components.eater:SetStrongStomach(true) -- can eat monster meat!

        inst:AddComponent("sleeper")
        inst.components.sleeper:SetResistance(3)
        inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
        inst.components.sleeper:SetSleepTest(ShouldSleep)
        inst.components.sleeper:SetWakeTest(ShouldWakeUp)
        inst:ListenForEvent("newcombattarget", OnNewTarget)

        if morphlist ~= nil then
            MakeHauntableChangePrefab(inst, morphlist)
			inst.components.hauntable.panicable = true
            inst:ListenForEvent("spawnedfromhaunt", OnSpawnedFromHaunt)
        else
            MakeHauntablePanic(inst)
        end
    end

    inst:WatchWorldState("stopday", OnStopDay)
    inst.OnEntitySleep = OnEntitySleep

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("onattackother", OnAttackOther)
    inst:ListenForEvent("startfollowing", OnStartFollowing)
    inst:ListenForEvent("stopfollowing", OnStopFollowing)

    return inst
end

local function fndefault()
    local inst = fncommon("hound", "hound_ocean", { "firehound", "icehound" }, nil, nil, {amphibious = true, canmutatefn = CanMutateFromCorpse})

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_deps = { "gargoyle_hounddeath" }

    MakeMediumFreezableCharacter(inst, "hound_body")
    MakeMediumBurnableCharacter(inst, "hound_body")

	inst:AddComponent("halloweenmoonmutable")
	inst.components.halloweenmoonmutable:SetPrefabMutated("mutatedhound")

    return inst
end

local function PlayFireExplosionSound(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/hound/firehound_explo")
end

local function fnfire()
    local inst = fncommon("hound", "hound_red_ocean", { "hound", "icehound" }, nil, nil, {amphibious = true})

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_deps = { "gargoyle_hounddeath" }

    MakeMediumFreezableCharacter(inst, "hound_body")
    inst.components.freezable:SetResistance(4) --because fire

    inst.components.combat:SetDefaultDamage(TUNING.FIREHOUND_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.FIREHOUND_ATTACK_PERIOD)
    inst.components.locomotor.runspeed = TUNING.FIREHOUND_SPEED
    inst.components.health:SetMaxHealth(TUNING.FIREHOUND_HEALTH)
    inst.components.lootdropper:SetChanceLootTable('hound_fire')

    inst:ListenForEvent("death", PlayFireExplosionSound)

    return inst
end

local function DoIceExplosion(inst)
    if inst.components.freezable == nil then
        MakeMediumFreezableCharacter(inst, "hound_body")
    end
    inst.components.freezable:SpawnShatterFX()
    inst:RemoveComponent("freezable")
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 4, FREEZABLE_TAGS, NO_TAGS)
    for i, v in pairs(ents) do
        if v.components.freezable ~= nil then
            v.components.freezable:AddColdness(2)
        end
    end

    inst.SoundEmitter:PlaySound("dontstarve/creatures/hound/icehound_explo")
end

local function fncold()
    local inst = fncommon("hound", "hound_ice_ocean", { "firehound", "hound" }, nil, nil, {amphibious = true})

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_deps = { "gargoyle_hounddeath" }

    MakeMediumBurnableCharacter(inst, "hound_body")

    inst.components.combat:SetDefaultDamage(TUNING.ICEHOUND_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.ICEHOUND_ATTACK_PERIOD)
    inst.components.locomotor.runspeed = TUNING.ICEHOUND_SPEED
    inst.components.health:SetMaxHealth(TUNING.ICEHOUND_HEALTH)
    inst.components.lootdropper:SetChanceLootTable('hound_cold')

    inst:ListenForEvent("death", DoIceExplosion)

    return inst
end

local function OnMoonPetrify(inst)
    if not inst.components.health:IsDead() and (not inst.sg:HasStateTag("busy") or inst:IsAsleep()) then
        local x, y, z = inst.Transform:GetWorldPosition()
        local rot = inst.Transform:GetRotation()
        inst:Remove()
        local gargoyle = SpawnPrefab(gargoyles[math.random(#gargoyles)])
        gargoyle.Transform:SetPosition(x, y, z)
        gargoyle.Transform:SetRotation(rot)
        gargoyle:Petrify()
    end
end

local function OnMoonTransformed(inst, data)
    if data.old.prefab ~= "hound" then
        SpawnPrefab("small_puff").Transform:SetPosition(inst.Transform:GetWorldPosition())
    end
    inst.sg:GoToState("taunt")
end

local function fnmoon()
	local inst = fncommon("hound", "hound_ocean", nil, moonbrain, "moonbeast", false)

	inst:SetPrefabNameOverride("hound")

    if not TheWorld.ismastersim then
        return inst
    end

    MakeMediumFreezableCharacter(inst, "hound_body")
    MakeMediumBurnableCharacter(inst, "hound_body")

    inst.components.freezable:SetDefaultWearOffTime(TUNING.MOONHOUND_FREEZE_WEAR_OFF_TIME)

    inst.components.combat:SetDefaultDamage(TUNING.MOONHOUND_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.MOONHOUND_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(3, moon_retargetfn)
    inst.components.combat:SetKeepTargetFunction(moon_keeptargetfn)
    inst.components.locomotor.runspeed = TUNING.MOONHOUND_SPEED
    inst.components.health:SetMaxHealth(TUNING.MOONHOUND_HEALTH)

    inst:ListenForEvent("moonpetrify", OnMoonPetrify)
    inst:ListenForEvent("moontransformed", OnMoonTransformed)

    return inst
end

local function OnClaySave(inst, data)
    data.reanimated = not inst.sg:HasStateTag("statue") or nil
end

local function OnClayPreLoad(inst, data)--, newents)
    if data ~= nil and data.reanimated then
        inst.sg:GoToState("idle")
    end
end

local function OnClayUpdateOffset(inst, offset)
    inst.leader_offset = offset
end

local function fnclay()
    local inst = fncommon("clayhound", "clayhound", nil, nil, "clay", false)

    if not TheWorld.ismastersim then
        return inst
    end

	inst.sounds = sounds_clay

    MakeMediumFreezableCharacter(inst, "hound_body")

    inst.components.lootdropper:SetChanceLootTable('clayhound')

    inst.OnSave = OnClaySave
    inst.OnLoad = nil
    inst.OnPreLoad = OnClayPreLoad
    inst.OnUpdateOffset = OnClayUpdateOffset

    return inst
end

local function fnmutated()
    local inst = fncommon("hound", "hound_mutated", nil, nil, "lunar_aligned", {amphibious = true})

    if not TheWorld.ismastersim then
        return inst
    end

	inst.sounds = sounds_mutated

    MakeMediumFreezableCharacter(inst, "hound_body")
    MakeMediumBurnableCharacter(inst, "hound_body")

    inst.components.health:SetMaxHealth(TUNING.MUTATEDHOUND_HEALTH)

	inst.components.combat:SetDefaultDamage(TUNING.MUTATEDHOUND_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.MUTATEDHOUND_ATTACK_PERIOD)

    inst.components.lootdropper:SetChanceLootTable('mutatedhound')

    return inst
end

local function fnfiredrop()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    MakeLargeBurnable(inst, 6 + math.random() * 6)
    MakeLargePropagator(inst)

    --Remove the default handlers that toggle persists flag
    inst.components.burnable:SetOnIgniteFn(nil)
    inst.components.burnable:SetOnExtinguishFn(inst.Remove)
    inst.components.burnable:Ignite()

    return inst
end

local function OnHedgeKilled(inst)
    if inst.hedgeitem then
        local loot = SpawnPrefab(inst.hedgeitem)
        inst.components.lootdropper:FlingItem(loot)
        inst.hedgeitem = nil
    end
end


local function fnhedge()
    local inst = fncommon("hound", "hound_hedge_ocean", nil, nil, nil, {amphibious = true})

    inst.death_shatter = true

    if not TheWorld.ismastersim then
        return inst
    end 

	inst.sounds = sounds_hedge

    MakeMediumFreezableCharacter(inst, "hound_body")
    MakeMediumBurnableCharacter(inst, "hound_body")

    inst.components.health:SetMaxHealth(TUNING.HEDGEHOUND_HEALTH)

    inst.components.combat:SetDefaultDamage(TUNING.HEDGEHOUND_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.HEDGEHOUND_ATTACK_PERIOD)   

    inst.components.lootdropper:SetChanceLootTable(nil)

    inst:ListenForEvent("death", OnHedgeKilled)

    return inst
end


return Prefab("hound", fndefault, assets, prefabs),
        Prefab("firehound", fnfire, assets, prefabs),
        Prefab("icehound", fncold, assets, prefabs),
        Prefab("moonhound", fnmoon, assets, prefabs_moon),
        Prefab("clayhound", fnclay, assets_clay, prefabs_clay),
        Prefab("mutatedhound", fnmutated, assets, prefabs),
        Prefab("hedgehound", fnhedge, assets, prefabs),
        --fx
        Prefab("houndfire", fnfiredrop, assets, prefabs)
