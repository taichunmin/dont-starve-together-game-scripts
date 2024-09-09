local normal_assets =
{
    Asset("ANIM", "anim/bearger_build.zip"),
    Asset("ANIM", "anim/bearger_basic.zip"),
    Asset("ANIM", "anim/bearger_actions.zip"),
    Asset("ANIM", "anim/bearger_yule.zip"),
    Asset("SOUND", "sound/bearger.fsb"),
}

local mutated_assets =
{
    Asset("ANIM", "anim/bearger_build.zip"),
    Asset("ANIM", "anim/bearger_basic.zip"),
    Asset("ANIM", "anim/bearger_actions.zip"),
    Asset("ANIM", "anim/bearger_mutated_actions.zip"),
    Asset("ANIM", "anim/bearger_mutated.zip"),
	Asset("ANIM", "anim/lunar_flame.zip"),
    Asset("SOUND", "sound/bearger.fsb"),
}

local normal_prefabs =
{
	"bearger_swipe_fx",
    "groundpound_fx",
    "groundpoundring_fx",
    "bearger_fur",
    "furtuft",
    "meat",
    "chesspiece_bearger_sketch",
    "collapse_small",
    "beargercorpse",
}

local mutated_prefabs =
{
    "bearger",
	"bearger_sinkhole",
	"mutatedbearger_swipe_fx",
	"groundpound_fx",
	"groundpoundring_fx",
	"furtuft",
	"collapse_small",
	"spoiled_food",
	"purebrilliance",
	"chesspiece_bearger_mutated_sketch",
	"winter_ornament_boss_mutatedbearger",
}

local brain = require("brains/beargerbrain")

SetSharedLootTable( 'bearger',
{
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'bearger_fur',      1.00},
    {'chesspiece_bearger_sketch', 1.00},
})

SetSharedLootTable( 'mutatedbearger',
{
	{ "spoiled_food",				1.0  },
	{ "spoiled_food",				1.0  },
	{ "spoiled_food",				1.0  },
	{ "spoiled_food",				0.5  },
	{ "purebrilliance",				1.0  },
	{ "purebrilliance",				0.75 },
    {'chesspiece_bearger_mutated_sketch',   1.00 },
})

local TARGET_DIST = 7.5

local function CalcSanityAura(inst, observer)
    return inst.components.combat.target ~= nil and -TUNING.SANITYAURA_HUGE or -TUNING.SANITYAURA_LARGE
end

local function HoneyedItem(item)
    return item:HasTag("honeyed")
end

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_INV_MUST_TAGS = { "_combat", "_inventory" }
local RETARGET_CANT_TAGS = { "prey", "smallcreature", "INLIMBO" }

local function RetargetFn_Normal(inst)
	return not (inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep())
        and (   FindEntity(
                    inst,
                    TARGET_DIST,
                    function(guy)
                        return guy.components.combat.target == inst
                            and inst.components.combat:CanTarget(guy)
                    end,
                    RETARGET_MUST_TAGS, --see entityreplica.lua
                    RETARGET_CANT_TAGS
                ) or
                (   inst.last_eat_time ~= nil and
                    GetTime() - inst.last_eat_time > TUNING.BEARGER_DISGRUNTLE_TIME and
                    FindEntity(
                        inst,
                        TARGET_DIST * 5,
                        function(guy)
                            return guy.components.inventory:FindItem(HoneyedItem) ~= nil
                                and inst.components.combat:CanTarget(guy)
                        end,
                        RETARGET_INV_MUST_TAGS, --see entityreplica.lua
                        RETARGET_CANT_TAGS
                    )
                )
            )
        or nil
end

local function RetargetFn_Mutated(inst)
    return FindEntity(
        inst,
        TUNING.MUTATED_BEARGER_TARGET_RANGE,
        function(guy)
            return inst.components.combat:CanTarget(guy)
        end,
        RETARGET_MUST_TAGS,
        RETARGET_CANT_TAGS
    )
end

local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
end

local function OnSave(inst, data)
    data.seenbase = inst.seenbase or nil-- from brain
	data.num_food_cherrypicked = inst.num_food_cherrypicked ~= 0 and inst.num_food_cherrypicked or nil
	data.looted = inst.looted
end

local function OnLoad(inst, data)
    if data ~= nil then
        inst.seenbase = data.seenbase or nil-- for brain
        inst.num_food_cherrypicked = data.num_food_cherrypicked or 0
		inst.looted = data.looted
		if inst.looted and inst.components.health:IsDead() then
			inst.sg:GoToState("corpse")
		end
    end
end

local function IsHibernationSeason(season)
    return season == "winter" or season == "spring"
end

local function OnSeasonChange(inst, season)
    if IsHibernationSeason(season) then
        inst:AddTag("hibernation")
    else
        inst:RemoveTag("hibernation")
    end
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
end

local function ClearRecentlyCharged(inst, other)
    inst.recentlycharged[other] = nil
end

local function OnDestroyOther(inst, other)
    if other:IsValid() and
        other.components.workable ~= nil and
        other.components.workable:CanBeWorked() and
        other.components.workable.action ~= ACTIONS.NET and
        not inst.recentlycharged[other] then
        SpawnPrefab("collapse_small").Transform:SetPosition(other.Transform:GetWorldPosition())
        if other.components.lootdropper ~= nil and (other:HasTag("tree") or other:HasTag("boulder")) then
            other.components.lootdropper:SetLoot({})
        end
        other.components.workable:Destroy(inst)
        if other:IsValid() and other.components.workable ~= nil and other.components.workable:CanBeWorked() then
            inst.recentlycharged[other] = true
            inst:DoTaskInTime(3, ClearRecentlyCharged, other)
        end
    end
end

local function OnCollide(inst, other)
    if other ~= nil and
        other:IsValid() and
        other.components.workable ~= nil and
        other.components.workable:CanBeWorked() and
        other.components.workable.action ~= ACTIONS.NET and
        Vector3(inst.Physics:GetVelocity()):LengthSq() >= 1 and
        not inst.recentlycharged[other] then
        inst:DoTaskInTime(2 * FRAMES, OnDestroyOther, other)
    end
end

local WORKABLES_CANT_TAGS = { "insect", "INLIMBO" }
local WORKABLES_ONEOF_TAGS = { "CHOP_workable", "DIG_workable", "HAMMER_workable", "MINE_workable" }
local function WorkEntities(inst) --deprecated
    local x, y, z = inst.Transform:GetWorldPosition()
    local heading_angle = inst.Transform:GetRotation() * DEGREES
    local x1, z1 = math.cos(heading_angle), -math.sin(heading_angle)
    for i, v in ipairs(TheSim:FindEntities(x, 0, z, 5, nil, WORKABLES_CANT_TAGS, WORKABLES_ONEOF_TAGS)) do
        local x2, y2, z2 = v.Transform:GetWorldPosition()
        local dx, dz = x2 - x, z2 - z
        local len = math.sqrt(dx * dx + dz * dz)
        --Normalized, then Dot product
        if len <= 0 or x1 * dx / len + z1 * dz / len > .3 then
            v.components.workable:Destroy(inst)
        end
    end
end

local function LaunchItem(inst, target, item)
    if item.Physics ~= nil and item.Physics:IsActive() then
        local x, y, z = item.Transform:GetWorldPosition()
        item.Physics:Teleport(x, .1, z)

        x, y, z = inst.Transform:GetWorldPosition()
        local x1, y1, z1 = target.Transform:GetWorldPosition()
        local angle = math.atan2(z1 - z, x1 - x) + (math.random() * 20 - 10) * DEGREES
        local speed = 5 + math.random() * 2
        item.Physics:SetVel(math.cos(angle) * speed, 10, math.sin(angle) * speed)
    end
end

local function OnGroundPound(inst)
    if math.random() < .2 then
        inst.components.shedder:DoMultiShed(3, false) -- can't drop too many, or it'll be really easy to farm for thick furs
    end
end

local function OnHitOther(inst, data)
    if data.redirected then
        return
    end

	if inst.sg:HasStateTag("weapontoss") and data.target ~= nil and data.target.components.inventory ~= nil and not data.target:HasTag("stronggrip") then
        local item = data.target.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if item ~= nil then
            data.target.components.inventory:DropItem(item)
            LaunchItem(inst, data.target, item)
        end
    end
end

local function ShouldSleep(inst)
    -- don't fall asleep if we have a target, we were either chasing it, or it woke us up
    -- don't fall asleep while on fire
    if not (inst.components.combat:HasTarget() or
            inst.components.health.takingfiredamage) and
        IsHibernationSeason(TheWorld.state.season) then
        --Start hibernating
        inst.components.shedder:StopShedding()
        inst:AddTag("hibernation")
        inst:AddTag("asleep")
        inst.AnimState:OverrideSymbol("bearger_head", IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) and "bearger_yule" or "bearger_build", "bearger_head_groggy")
        return true
    end
    return false
end

local function ShouldWake(inst)
    if not IsHibernationSeason(TheWorld.state.season) then
        inst.components.shedder:StartShedding(TUNING.BEARGER_SHED_INTERVAL)
        inst:RemoveTag("hibernation")
        inst:RemoveTag("asleep")
        inst.AnimState:ClearOverrideSymbol("bearger_head")
        return true
    end
    return false
end

local function OnDroppedTarget(inst, data)
    if data.target ~= nil then
        inst:RemoveEventCallback("dropitem", inst._OnTargetDropItem, data.target)
    end
end

local function OnCombatTarget(inst, data)
    --Listen for dropping of items... if it's food, maybe forgive your target?
    if data.oldtarget ~= nil then
        inst:RemoveEventCallback("dropitem", inst._OnTargetDropItem, data.oldtarget)
    end
    if data.target ~= nil then
        inst.num_food_cherrypicked = TUNING.BEARGER_STOLEN_TARGETS_FOR_AGRO - 1
        inst:ListenForEvent("dropitem", inst._OnTargetDropItem, data.target)
    end
end

local function SetStandState(inst, state)
    --"quad" or "bi" state
    inst.StandState = string.lower(state)
end

local function IsStandState(inst, state)
    return inst.StandState == string.lower(state)
end

local function OnDead(inst)
    AwardRadialAchievement("bearger_killed", inst:GetPosition(), TUNING.ACHIEVEMENT_RADIUS_FOR_GIANT_KILL)
    inst.components.shedder:StopShedding()
    TheWorld:PushEvent("beargerkilled", inst)
end

local function OnRemove(inst)
    TheWorld:PushEvent("beargerremoved", inst)
end

local function OnPlayerAction(inst, player, data)
	if data.action == nil or (inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep()) then
        return -- don't react to things when asleep
    end

    local selfAction = inst:GetBufferedAction()
    if selfAction == nil or selfAction.target ~= data.action.target then
        --You're not doing anything, or not doing the same thing as the player
        return
    end

    -- We got a problem bud. (targeting the same thing for action)
    inst.num_food_cherrypicked = inst.num_food_cherrypicked + 1
    if inst.num_food_cherrypicked < TUNING.BEARGER_STOLEN_TARGETS_FOR_AGRO then
        inst.sg:GoToState("targetstolen")
    else
        inst.num_food_cherrypicked = TUNING.BEARGER_STOLEN_TARGETS_FOR_AGRO - 1
        inst.components.combat:SuggestTarget(player)
    end
end

--[[ PLAYER TRACKING ]]

local function OnPlayerJoined(inst, player)
    for i, v in ipairs(inst._activeplayers) do
        if v == player then
            return
        end
    end

    inst:ListenForEvent("performaction", inst._OnPlayerAction, player)
    table.insert(inst._activeplayers, player)
end

local function OnPlayerLeft(inst, player)
    for i, v in ipairs(inst._activeplayers) do
        if v == player then
            inst:RemoveEventCallback("performaction", inst._OnPlayerAction, player)
            table.remove(inst._activeplayers, i)
            return
        end
    end
end

--[[ END PLAYER TRACKING ]]

local function OnWakeUp(inst)
	inst.components.knownlocations:RememberLocation("spawnpoint", inst:GetPosition())
end

local function OnKilledOther(inst, data)
	if data ~= nil and inst.components.combat:TargetIs(data.victim) then
		inst:RemoveEventCallback("dropitem", inst._OnTargetDropItem, data.victim)
		inst.components.combat:DropTarget()
    end
end

local function Mutated_OnDead(inst)
    inst.components.shedder:StopShedding()
    if TheWorld ~= nil and TheWorld.components.lunarriftmutationsmanager ~= nil then
        TheWorld.components.lunarriftmutationsmanager:SetMutationDefeated(inst)
    end
end

local function SwitchToEightFaced(inst)
	if not inst._temp8faced then
		inst._temp8faced = true
		inst.Transform:SetEightFaced()
	end
end

local function SwitchToFourFaced(inst)
	if inst._temp8faced then
		inst._temp8faced = false
		inst.Transform:SetFourFaced()
	end
end

local function commonfn(build, commonfn)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()
    inst.DynamicShadow:SetSize(6, 3.5)

	inst:SetPhysicsRadiusOverride(1.5)
	MakeGiantCharacterPhysics(inst, 1000, inst.physicsradiusoverride)

    inst.AnimState:SetBank("bearger")
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.scrapbook_anim = "idle_loop"

    ------------------------------------------

    inst:AddTag("epic")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("bearger")
    inst:AddTag("scarytoprey")
    inst:AddTag("largecreature")

    if commonfn ~= nil then
        commonfn(inst)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.recentlycharged = {}
    inst.Physics:SetCollisionCallback(OnCollide)

    ------------------------------------------

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

    ------------------

    inst:AddComponent("health")
	inst.components.health.nofadeout = true

    ------------------

    inst:AddComponent("combat")
    inst.components.combat.playerdamagepercent = .5
    inst.components.combat.hiteffectsymbol = "bearger_body"
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/bearger/hurt")

    ------------------------------------------

    inst:AddComponent("explosiveresist")

    ------------------------------------------

    inst:AddComponent("shedder")
    inst.components.shedder.shedItemPrefab = "furtuft"
    inst.components.shedder.shedHeight = 6.5
    inst.components.shedder:StartShedding(TUNING.BEARGER_SHED_INTERVAL)

    ------------------------------------------

    inst:AddComponent("lootdropper")

    ------------------------------------------

    inst:AddComponent("inspectable")
    inst.components.inspectable:RecordViews()

    ------------------------------------------

    inst:AddComponent("knownlocations")
    inst:AddComponent("groundpounder")
	inst.components.groundpounder:UseRingMode()
    inst.components.groundpounder.destroyer = true
	inst.components.groundpounder.damageRings = 3
	inst.components.groundpounder.destructionRings = 3
	inst.components.groundpounder.platformPushingRings = 3
    inst.components.groundpounder.numRings = 3
	inst.components.groundpounder.radiusStepDistance = 2
	inst.components.groundpounder.ringWidth = 1.5
    inst.components.groundpounder.groundpoundFn = OnGroundPound
    inst:AddComponent("timer")

    ------------------------------------------

    inst:AddComponent("drownable")

    ------------------------------------------

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("onhitother", OnHitOther)

    ------------------------------------------

    MakeLargeBurnableCharacter(inst, "swap_fire")
    MakeHugeFreezableCharacter(inst, "bearger_body")

    SetStandState(inst, "quad")--SetStandState(inst, "BI")
    inst.SetStandState = SetStandState
    inst.IsStandState = IsStandState
    inst.WorkEntities = WorkEntities --deprecated

    inst.seenbase = nil -- for brain

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
	inst.SwitchToEightFaced = SwitchToEightFaced
	inst.SwitchToFourFaced = SwitchToFourFaced

    ------------------------------------------

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.BEARGER_CALM_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.BEARGER_RUN_SPEED
    inst.components.locomotor:SetShouldRun(true)

    inst:SetStateGraph("SGbearger")
    inst:SetBrain(brain)

    return inst
end

local function normalfn()
    local yule = IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST)

    local inst = commonfn(yule and "bearger_yule" or "bearger_build")

    if not TheWorld.ismastersim then
        return inst
    end

	inst.swipefx = "bearger_swipe_fx"

	inst:AddComponent("thief")
	inst:AddComponent("inventory")
	inst:AddComponent("eater")
	inst.components.eater:SetDiet({ FOODGROUP.BEARGER }, { FOODGROUP.BEARGER })
	inst.components.eater.eatwholestack = true

    inst.components.health:SetMaxHealth(TUNING.BEARGER_HEALTH)

    inst.components.combat:SetDefaultDamage(TUNING.BEARGER_DAMAGE)
	inst.components.combat:SetRange(TUNING.BEARGER_ATTACK_RANGE)
    inst.components.combat:SetAttackPeriod(TUNING.BEARGER_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(3, RetargetFn_Normal)

    inst.components.lootdropper:SetChanceLootTable("bearger")

	inst:AddComponent("sleeper")
	inst.components.sleeper:SetResistance(4)
	inst.components.sleeper:SetSleepTest(ShouldSleep)
	inst.components.sleeper:SetWakeTest(ShouldWake)
	inst:ListenForEvent("onwakeup", OnWakeUp)

	inst._OnTargetDropItem = function(target, data)
		if inst.components.eater:CanEat(data.item) then
			--print("Bearger saw dropped food, losing target")
			inst.components.combat:SetTarget(nil)
		end
	end

    inst:WatchWorldState("season", OnSeasonChange)
    OnSeasonChange(inst, TheWorld.state.season)

	inst:ListenForEvent("killed", OnKilledOther)
	inst:ListenForEvent("newcombattarget", OnCombatTarget)
	inst:ListenForEvent("droppedtarget", OnDroppedTarget)
    inst:ListenForEvent("death", OnDead)
    inst:ListenForEvent("onremove", OnRemove)

	--[[ PLAYER TRACKING ]]

	inst.num_food_cherrypicked = 0
	inst._activeplayers = {}
	inst._OnPlayerAction = function(player, data) OnPlayerAction(inst, player, data) end
	inst:ListenForEvent("ms_playerjoined", function(src, player) OnPlayerJoined(inst, player) end, TheWorld)
	inst:ListenForEvent("ms_playerleft", function(src, player) OnPlayerLeft(inst, player) end, TheWorld)

	for i, v in ipairs(AllPlayers) do
		OnPlayerJoined(inst, v)
	end

	--[[ END PLAYER TRACKING ]]

    return inst
end

--------------------------------------------------------------------------

local function Mutated_OnTemp8Faced(inst)
	if inst.temp8faced:value() then
		inst.gestalt.Transform:SetEightFaced()
		inst.eyeL.Transform:SetEightFaced()
		inst.eyeR.Transform:SetEightFaced()
	else
		inst.gestalt.Transform:SetFourFaced()
		inst.eyeL.Transform:SetFourFaced()
		inst.eyeR.Transform:SetFourFaced()
	end
end

local function Mutated_SwitchToEightFaced(inst)
	if not inst.temp8faced:value() then
		inst.temp8faced:set(true)
		if not TheNet:IsDedicated() then
			Mutated_OnTemp8Faced(inst)
		end
		inst.Transform:SetEightFaced()
	end
end

local function Mutated_SwitchToFourFaced(inst)
	if inst.temp8faced:value() then
		inst.temp8faced:set(false)
		if not TheNet:IsDedicated() then
			Mutated_OnTemp8Faced(inst)
		end
		inst.Transform:SetFourFaced()
	end
end

local function Mutated_CreateGestaltFlame()
	local inst = CreateEntity()

	inst:AddTag("FX")
	--[[Non-networked entity]]
	--inst.entity:SetCanSleep(false) --commented out; follow parent sleep instead
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()

	inst.Transform:SetFourFaced()

	inst.AnimState:SetBank("lunar_flame")
	inst.AnimState:SetBuild("lunar_flame")
	inst.AnimState:PlayAnimation("gestalt_eye", true)
	inst.AnimState:SetMultColour(1, 1, 1, 0.6)
	inst.AnimState:SetLightOverride(0.1)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:UsePointFiltering(true)

	return inst
end

local function Mutated_CreateEyeFlame()
	local inst = CreateEntity()

	inst:AddTag("FX")
	--[[Non-networked entity]]
	--inst.entity:SetCanSleep(false) --commented out; follow parent sleep instead
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()

	inst.Transform:SetFourFaced()

	inst.AnimState:SetBank("lunar_flame")
	inst.AnimState:SetBuild("lunar_flame")
	inst.AnimState:PlayAnimation("flameanim", true)
	inst.AnimState:SetMultColour(1, 1, 1, 0.6)
	inst.AnimState:SetLightOverride(0.1)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

	return inst
end

local function Mutated_OnRecoveryHealthDelta(inst, data)
	local hp = data ~= nil and data.newpercent or inst.components.health:GetPercent()
	if inst.recovery_starthp - hp > TUNING.MUTATED_BEARGER_RECOVERY_HP then
		inst.recovery_starthp = nil
		inst:RemoveEventCallback("healthdelta", Mutated_OnRecoveryHealthDelta)
		inst.canrunningbutt = not inst.recovery_norunningbutt
		inst.recovery_norunningbutt = nil
	end
end

local function Mutated_StartButtRecovery(inst, norunningbutt)
	if inst.recovery_starthp == nil then
		inst.recovery_starthp = inst.components.health:GetPercent()
		inst:ListenForEvent("healthdelta", Mutated_OnRecoveryHealthDelta)
		inst.canrunningbutt = false
	end
	inst.recovery_norunningbutt = norunningbutt
end

local function Mutated_IsButtRecovering(inst)
	return inst.recovery_starthp ~= nil
end

local function Mutated_PushMusic(inst)
	if inst.AnimState:IsCurrentAnimation("mutate") then
		inst._playingmusic = false
	elseif ThePlayer == nil then
		inst._playingmusic = false
	elseif ThePlayer:IsNear(inst, inst._playingmusic and 40 or 20) then
		inst._playingmusic = true
		ThePlayer:PushEvent("triggeredevent", { name = "gestaltmutant" })
	elseif inst._playingmusic and not ThePlayer:IsNear(inst, 50) then
		inst._playingmusic = false
	end
end

local mutated_scrapbook_overridedata = {
    { "flameL", "lunar_flame", "flameanim", 0.6 },
    { "flameR", "lunar_flame", "flameanim", 0.6 },
}

local function mutatedcommonfn(inst)
    inst:AddTag("lunar_aligned")
	inst:AddTag("bearger_blocker")
	inst:AddTag("noepicmusic")

	inst.temp8faced = net_bool(inst.GUID, "mutatedbearger.temp8faced", "temp8faceddirty")

	--Dedicated server does not need to trigger music
	--Dedicated server does not need to spawn the local fx
	if not TheNet:IsDedicated() then
		inst._playingmusic = false
		inst:DoPeriodicTask(1, Mutated_PushMusic, 0)

		inst.gestalt = Mutated_CreateGestaltFlame()
		inst.gestalt.entity:SetParent(inst.entity)
		inst.gestalt.Follower:FollowSymbol(inst.GUID, "swap_gestalt_flame", 0, 0, 0, true)
		local frames = inst.gestalt.AnimState:GetCurrentAnimationNumFrames()
		local rnd = math.random(frames) - 1
		inst.gestalt.AnimState:SetFrame(rnd)

		inst.eyeL = Mutated_CreateEyeFlame()
		inst.eyeL.entity:SetParent(inst.entity)
		inst.eyeL.Follower:FollowSymbol(inst.GUID, "flameL", 0, 0, 0, true)
		frames = inst.eyeL.AnimState:GetCurrentAnimationNumFrames()
		rnd = math.random(frames) - 1
		inst.eyeL.AnimState:SetFrame(rnd)

		inst.eyeR = Mutated_CreateEyeFlame()
		inst.eyeR.entity:SetParent(inst.entity)
		inst.eyeR.Follower:FollowSymbol(inst.GUID, "flameR", 0, 0, 0, true)
		rnd = (rnd + math.floor((0.35 + math.random() * 0.35) * frames)) % frames
		inst.eyeR.AnimState:SetFrame(rnd)
	end
end

local function mutatedfn()
    local inst = commonfn("bearger_mutated", mutatedcommonfn)

    if not TheWorld.ismastersim then
		inst:ListenForEvent("temp8faceddirty", Mutated_OnTemp8Faced)

        return inst
    end

    inst.scrapbook_overridedata = mutated_scrapbook_overridedata

	inst.cancombo = true
	inst.canbutt = true
	inst.canrunningbutt = false
	inst.swipefx = "mutatedbearger_swipe_fx"

    inst.components.health:SetMaxHealth(TUNING.MUTATED_BEARGER_HEALTH)

    inst.components.combat:SetDefaultDamage(TUNING.MUTATED_BEARGER_DAMAGE)
	inst.components.combat:SetRange(TUNING.MUTATED_BEARGER_ATTACK_RANGE)
    inst.components.combat:SetAttackPeriod(TUNING.MUTATED_BEARGER_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(3, RetargetFn_Mutated)

	inst:AddComponent("planarentity")
	inst:AddComponent("planardamage")
	inst.components.planardamage:SetBaseDamage(TUNING.MUTATED_BEARGER_PLANAR_DAMAGE)

    inst.components.lootdropper:SetChanceLootTable("mutatedbearger")

    inst:ListenForEvent("death", Mutated_OnDead)

	--Overriding these
	inst.SwitchToEightFaced = Mutated_SwitchToEightFaced
	inst.SwitchToFourFaced = Mutated_SwitchToFourFaced

	inst.StartButtRecovery = Mutated_StartButtRecovery
	inst.IsButtRecovering = Mutated_IsButtRecovering

	inst:StartButtRecovery(true) --norunningbutt = true for initial recovery

    return inst
end

return
        Prefab("bearger",         normalfn,   normal_assets,   normal_prefabs),
        Prefab("mutatedbearger",  mutatedfn,  mutated_assets,  mutated_prefabs )
