local assets =
{
    Asset("ANIM", "anim/hound_basic.zip"),
    Asset("ANIM", "anim/hound_basic_water.zip"),
    Asset("ANIM", "anim/hound_ocean.zip"),
    Asset("ANIM", "anim/hound_warglet.zip"),
    Asset("SOUND", "sound/hound.fsb"),
}

local prefabs =
{
    "houndstooth",
    "monstermeat",
    "splash_green",
	"houndcorpse",
}

local brain = require("brains/wargbrain")

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

SetSharedLootTable('warglet',
{
    {'monstermeat',             1.00},
    {'monstermeat',             1.00},
    {'monstermeat',             1.00},
    {'monstermeat',             0.50},

    {'houndstooth',             1.00},
    {'houndstooth',             0.33},
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
    if not TheWorld.state.isday then
        DoReturn(inst)
    end
end

local function OnStopDay(inst)
    if inst:IsAsleep() then
        DoReturn(inst)
    end
end

local function OnSave(inst, data)
    data.max_hound_spawns = inst.max_hound_spawns
end

local function OnPreLoad(inst, data)--, newents)
    if data ~= nil and data.reanimated then
        inst.max_hound_spawns = data.max_hound_spawns
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

local function OnStopFollowing(inst)
    inst.leader_offset = nil
    if not inst.components.health:IsDead() then
        local leader = inst.components.entitytracker:GetEntity("leader")
        if leader ~= nil and not leader.components.health:IsDead() then
            inst.leadertask = inst:DoTaskInTime(.2, RestoreLeader)
        end
    end
end

local TARGETS_MUST_TAGS = {"player"}
local TARGETS_CANT_TAGS = {"playerghost"}
local function NumHoundsToSpawn(inst)
    local numHounds = inst.base_hound_num 

    local pt = Vector3(inst.Transform:GetWorldPosition())
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, TUNING.WARG_NEARBY_PLAYERS_DIST, TARGETS_MUST_TAGS, TARGETS_CANT_TAGS)
    for i,player in ipairs(ents) do
        local playerAge = player.components.age:GetAgeInDays()
        local addHounds = math.clamp(Lerp(1, 4, playerAge/100), 1, 4)
        if inst.spawn_fewer_hounds then
            addHounds = math.ceil(addHounds/2)
        end
        numHounds = numHounds + addHounds
    end
    local numFollowers = inst.components.leader:CountFollowers()
    local num = math.min(numFollowers+numHounds/2, numHounds) -- only spawn half the hounds per howl
    num = (math.log(num)/0.4)+1 -- 0.4 is approx log(1.5)

    num = RoundToNearest(num, 1)

    if inst.max_hound_spawns then
        num = math.min(num,inst.max_hound_spawns)
    end

    return num - numFollowers
end

local function fncommon()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 10, .5)
    local scale = 1.5
    inst.Transform:SetScale(scale,scale,scale)

    inst.DynamicShadow:SetSize(2.5, 1.5)
    inst.Transform:SetFourFaced()

    inst:AddTag("scarytoprey")
    inst:AddTag("scarytooceanprey")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("hound")
    inst:AddTag("canbestartled")    
    inst:AddTag("hound_summoner")

    inst.AnimState:SetBank("hound")
    inst.AnimState:SetBuild("hound_warglet")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("spawnfader")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.sounds = sounds
	inst.chomp_power = 1.5

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.HOUND_SPEED * (1/scale)

    inst:SetStateGraph("SGhound")

	inst:AddComponent("embarker")
	inst.components.embarker.embark_speed = inst.components.locomotor.runspeed
    inst.components.embarker.antic = true

    inst.components.locomotor:SetAllowPlatformHopping(true)

	inst:AddComponent("amphibiouscreature")
	inst.components.amphibiouscreature:SetBanks("hound", "hound_water")
    inst.components.amphibiouscreature:SetEnterWaterFn(
        function(inst)
            inst.landspeed = inst.components.locomotor.runspeed 
            inst.components.locomotor.runspeed = TUNING.HOUND_SWIM_SPEED * (1/scale)
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

    inst:SetBrain(brain)

    inst:AddComponent("follower")
    inst:AddComponent("leader")
    inst:AddComponent("entitytracker")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.WARGLET_HEALTH)

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.HOUND_DAMAGE *2)
    inst.components.combat:SetAttackPeriod(TUNING.HOUND_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(3, retargetfn)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetHurtSound(inst.sounds.hurt)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('warglet')

    inst:AddComponent("inspectable")

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.MEAT }, { FOODTYPE.MEAT })
    inst.components.eater:SetCanEatHorrible()
    inst.components.eater:SetStrongStomach(true) -- can eat monster meat!

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)

    inst.spawn_fewer_hounds = true
    inst.max_hound_spawns = TUNING.WARGLET_MAX_HOUND_AMOUNT
    inst.base_hound_num = TUNING.WARGLET_BASE_HOUND_AMOUNT

    inst.NumHoundsToSpawn = NumHoundsToSpawn

    MakeHauntablePanic(inst)

    inst:WatchWorldState("stopday", OnStopDay)
    inst.OnEntitySleep = OnEntitySleep

    inst.OnSave = OnSave
    inst.OnPreLoad = OnPreLoad

    inst:ListenForEvent("newcombattarget", OnNewTarget)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("onattackother", OnAttackOther)
    inst:ListenForEvent("startfollowing", OnStartFollowing)
    inst:ListenForEvent("stopfollowing", OnStopFollowing)

    MakeMediumFreezableCharacter(inst, "hound_body")
    MakeMediumBurnableCharacter(inst, "hound_body")

    return inst
end

return Prefab("warglet", fncommon, assets, prefabs)
