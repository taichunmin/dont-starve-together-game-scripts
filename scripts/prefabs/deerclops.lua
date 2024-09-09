local brain = require "brains/deerclopsbrain"

local normal_assets =
{
    Asset("ANIM", "anim/deerclops_basic.zip"),
    Asset("ANIM", "anim/deerclops_actions.zip"),
    Asset("ANIM", "anim/deerclops_build.zip"),
    Asset("ANIM", "anim/deerclops_yule.zip"),
    Asset("SOUND", "sound/deerclops.fsb"),
}

local mutated_assets =
{
    Asset("ANIM", "anim/deerclops_basic.zip"),
    Asset("ANIM", "anim/deerclops_actions.zip"),
    Asset("ANIM", "anim/deerclops_mutated_actions.zip"),
    Asset("ANIM", "anim/deerclops_mutated.zip"),
	Asset("ANIM", "anim/lunar_flame.zip"),
    Asset("SOUND", "sound/deerclops.fsb"),
}

local normal_prefabs =
{
    "meat",
    "deerclops_eyeball",
    "chesspiece_deerclops_sketch",
	"deerclops_icespike_fx",
    "deerclops_laser",
    "deerclops_laserempty",
    "winter_ornament_light1",
    "deerclopscorpse",
}

local mutated_prefabs =
{
    "deerclops",
	"deerclops_icespike_fx",
	"deerclops_icelance_ping_fx",
	"deerclops_impact_circle_fx",
	"deerclops_aura_circle_fx",
	"deerclops_spikefire_fx",
	"character_fire_flicker",
	"spoiled_food",
	"purebrilliance",
	"ice",
	"chesspiece_deerclops_mutated_sketch",
	"winter_ornament_boss_mutateddeerclops",
}

local normal_sounds =
{
	step = "dontstarve/creatures/deerclops/step",
	taunt_grrr = "dontstarve/creatures/deerclops/taunt_grrr",
	taunt_howl = "dontstarve/creatures/deerclops/taunt_howl",
	hurt = "dontstarve/creatures/deerclops/hurt",
	death = "dontstarve/creatures/deerclops/death",
	attack = "dontstarve/creatures/deerclops/attack",
	swipe = "dontstarve/creatures/deerclops/swipe",
	charge = "dontstarve/creatures/deerclops/charge",
	walk = nil,
}

local mutated_sounds =
{
	step = "dontstarve/creatures/deerclops/step",
	taunt_grrr = "rifts3/mutated_deerclops/taunt_grrr",
	taunt_howl = "rifts3/mutated_deerclops/taunt_howl",
	hurt = "rifts3/mutated_deerclops/hurt",
	death = "rifts3/mutated_deerclops/death",
	attack = "rifts3/mutated_deerclops/attack",
	swipe = "dontstarve/creatures/deerclops/swipe",
	charge = "dontstarve/creatures/deerclops/charge",
	walk = "rifts3/mutated_deerclops/walk", --this is vocalization not footstep
}

local TARGET_DIST = 16
local STRUCTURES_PER_HARASS = 5

local function IsSated(inst)
    return inst.structuresDestroyed >= STRUCTURES_PER_HARASS
end

local function WantsToLeave(inst)
    return
        not TheWorld.state.iswinter or
        (
            not inst.components.combat:HasTarget()
            and inst:IsSated()
            and inst:GetTimeAlive() >= 120
        )
end

local function CalcSanityAura(inst)
    return inst.components.combat.target ~= nil and -TUNING.SANITYAURA_HUGE or -TUNING.SANITYAURA_LARGE
end

local STRUCTURE_TAGS = {"structure"}
local function FindBaseToAttack(inst, target)
	if inst.ignorebase then
		return
	end
    local structure = GetClosestInstWithTag(STRUCTURE_TAGS, target, 40)
    if structure ~= nil then
        inst.components.knownlocations:RememberLocation("targetbase", structure:GetPosition())
		inst.AnimState:Show("head_normal")
		inst.AnimState:Hide("head_neutral")
    end
end

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "prey", "smallcreature", "INLIMBO" }
local function RetargetFn(inst)
    local range = inst:GetPhysicsRadius(0) + 8
    return FindEntity(
            inst,
            TARGET_DIST,
            function(guy)
                return inst.components.combat:CanTarget(guy)
                    and (   guy.components.combat:TargetIs(inst) or
                            guy:IsNear(inst, range)
                        )
            end,
            RETARGET_MUST_TAGS,
            RETARGET_CANT_TAGS
        )
end

local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
end

local function AfterWorking(inst, data)
    if data.target then
        local recipe = AllRecipes[data.target.prefab]
        if recipe then
            inst.structuresDestroyed = inst.structuresDestroyed + 1
            if inst:IsSated() then
                inst.components.knownlocations:ForgetLocation("targetbase")
				inst.AnimState:Hide("head_normal")
				inst.AnimState:Show("head_neutral")
            end
        end
    end
end

local function ShouldSleep(inst)
    return false
end

local function ShouldWake(inst)
    return true
end

local function OnEntitySleep(inst)
    if inst:WantsToLeave() then
		if not inst.ignorebase then
			inst.structuresDestroyed = 0 -- reset this for the stored version
			TheWorld:PushEvent("storehassler", inst)
		end
        inst:Remove()
    end
end

local function OnStopWinter(inst)
    if inst:IsAsleep() then
		if not inst.ignorebase then
			TheWorld:PushEvent("storehassler", inst)
		end
        inst:Remove()
    end
end

local function OnSave(inst, data)
    data.structuresDestroyed = inst.structuresDestroyed
	data.looted = inst.looted
end

local function OnLoad(inst, data)
    if data then
        inst.structuresDestroyed = data.structuresDestroyed or inst.structuresDestroyed
		inst.looted = data.looted
		if inst.looted ~= nil and inst.components.health:IsDead() then
			inst.sg:GoToState("corpse", true)
		end
    end
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    if data.attacker ~= nil and data.attacker:HasTag("player") and inst.structuresDestroyed < STRUCTURES_PER_HARASS and inst.components.knownlocations:GetLocation("targetbase") == nil then
        FindBaseToAttack(inst, data.attacker)
    end
end

local function OnHitOther(inst, data)
    local other = data.target
    if other ~= nil then
        if not (other.components.health ~= nil and other.components.health:IsDead()) then
            if other.components.freezable ~= nil then
				other.components.freezable:AddColdness(inst.sg.statemem.freezepower or inst.freezepower or 2)
            end
            if other.components.temperature ~= nil then
                local mintemp = math.max(other.components.temperature.mintemp, 0)
                local curtemp = other.components.temperature:GetCurrent()
                if mintemp < curtemp then
                    other.components.temperature:DoDelta(math.max(-5, mintemp - curtemp))
                end
            end
        end
        if other.components.freezable ~= nil then
            other.components.freezable:SpawnShatterFX()
        end
    end
end

local function OnRemove(inst)
	if inst.spikefire ~= nil then
		inst.spikefire:Remove()
		inst.spikefire = nil
	end
	if inst.sg.mem.circle ~= nil then
		inst.sg.mem.circle:KillFX()
		inst.sg.mem.circle = nil
	end
	if inst.icespike_pool ~= nil then
		for i, v in ipairs(inst.icespike_pool) do
			v:Remove()
		end
		inst.icespike_pool = nil
	end
    TheWorld:PushEvent("hasslerremoved", inst)
end

local function OnDead(inst)
	--V2C: make sure we're still burning by the time we actually reach death in stategraph
	if inst.components.burnable:IsBurning() then
		inst.components.burnable:SetBurnTime(nil)
		inst.components.burnable:ExtendBurning()
	end
    AwardRadialAchievement("deerclops_killed", inst:GetPosition(), TUNING.ACHIEVEMENT_RADIUS_FOR_GIANT_KILL)
    TheWorld:PushEvent("hasslerkilled", inst)
end

local function oncollapse(inst, other)
    if other:IsValid() and other.components.workable ~= nil and other.components.workable:CanBeWorked() then
        SpawnPrefab("collapse_small").Transform:SetPosition(other.Transform:GetWorldPosition())
        other.components.workable:Destroy(inst)
    end
end

local function oncollide(inst, other)
    if other ~= nil and
        (other:HasTag("tree") or other:HasTag("boulder")) and --HasTag implies IsValid
        Vector3(inst.Physics:GetVelocity()):LengthSq() >= 1 then
        inst:DoTaskInTime(2 * FRAMES, oncollapse, other)
    end
end

local function OnNewTarget(inst, data)
    FindBaseToAttack(inst, data.target or inst)
    if inst.components.knownlocations:GetLocation("targetbase") and data.target:HasTag("player") then
        inst.structuresDestroyed = inst.structuresDestroyed - 1
        inst.components.knownlocations:ForgetLocation("home")
    end
	if inst._disengagetask ~= nil then
		inst._disengagetask:Cancel()
		inst._disengagetask = nil
	end
end

local function YuleOnNewState(inst, data)
    if not (inst.sg:HasStateTag("sleeping") or inst.sg:HasStateTag("waking")) then
        inst.Light:SetIntensity(.6)
        inst.Light:SetRadius(8)
        inst.Light:SetFalloff(3)
        inst.Light:SetColour(1, 0, 0)
    end
end

local function Mutated_Disengage(inst)
	inst._disengagetask = nil
	if inst.sg.mem.circle ~= nil then
		inst.sg.mem.circle:KillFX()
		inst.sg.mem.circle = nil
	end
end

local function Mutated_OnDroppedTarget(inst)
	if inst._disengagetask == nil then
		inst._disengagetask = inst:DoTaskInTime(6, Mutated_Disengage)
	end
end

local function Mutated_OnDead(inst)
    if TheWorld ~= nil and TheWorld.components.lunarriftmutationsmanager ~= nil then
        TheWorld.components.lunarriftmutationsmanager:SetMutationDefeated(inst)
    end
end

local function Mutated_OnIgnite(inst, source, doer)
	if inst.components.burnable.burntime ~= 0 and inst.spikefire == nil and not (inst.sg.mem.noice == 1 and inst.sg.mem.noeyeice) then
		inst.spikefire = SpawnPrefab("deerclops_spikefire_fx")
		inst.spikefire.Follower:FollowSymbol(inst.GUID,
			(inst.sg.mem.noice == 1 and "swap_fire_2") or
			(inst.sg.mem.noice == 0 and "swap_fire_1") or
			"swap_fire_0",
			0, 0, 0, true)
	end
end

local function Mutated_OnExtinguish(inst)
	if inst.spikefire ~= nil then
		inst.spikefire:KillFX()
		inst.spikefire = nil
	end
	if inst._staggertask ~= nil then
		inst._staggertask:Cancel()
		inst._staggertask = nil
	end
end

SetSharedLootTable("deerclops",
{
    {'meat',                         1.0},
    {'meat',                         1.0},
    {'meat',                         1.0},
    {'meat',                         1.0},
    {'meat',                         1.0},
    {'meat',                         1.0},
    {'meat',                         1.0},
    {'meat',                         1.0},
    {'deerclops_eyeball',            1.0},
    {'chesspiece_deerclops_sketch',  1.0},
})

SetSharedLootTable("mutateddeerclops",
{
	{ "spoiled_food",			        	 1.0  },
	{ "spoiled_food",			        	 1.0  },
	{ "spoiled_food",			        	 1.0  },
	{ "spoiled_food",			        	 0.5  },
	{ "purebrilliance",				         1.0  },
	{ "purebrilliance",				         0.75 },
	{ "ice",						         1.0  },
	{ "ice",						         0.75 },
    {'chesspiece_deerclops_mutated_sketch',  1.0  },
})

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

    MakeGiantCharacterPhysics(inst, 1000, .5)

    local s  = 1.65
    inst.Transform:SetScale(s, s, s)
    inst.DynamicShadow:SetSize(6, 3.5)
    inst.Transform:SetFourFaced()

    inst:AddTag("epic")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("deerclops")
    inst:AddTag("scarytoprey")
    inst:AddTag("largecreature")

    inst.build = build

    inst.AnimState:SetBank("deerclops")
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle_loop", true)
	inst.AnimState:Hide("head_neutral")

    if commonfn ~= nil then
        commonfn(inst)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_hide = { "head_neutral" }

    inst.Physics:SetCollisionCallback(oncollide)

    inst.structuresDestroyed = 0
	inst.icespike_pool = {}

    ------------------------------------------

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 3

    ------------------------------------------
    inst:SetStateGraph("SGdeerclops")

    ------------------------------------------

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

	MakeLargeBurnableCharacter(inst, "swap_fire")

    ------------------

    inst:AddComponent("health")
	inst.components.health.nofadeout = true

    ------------------

    inst:AddComponent("combat")
    inst.components.combat.playerdamagepercent = TUNING.DEERCLOPS_DAMAGE_PLAYER_PERCENT
    inst.components.combat.hiteffectsymbol = "deerclops_body"
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)

    ------------------------------------------
    inst:AddComponent("explosiveresist")

    ------------------------------------------

    inst:AddComponent("lootdropper")

    ------------------------------------------

    inst:AddComponent("inspectable")
    inst.components.inspectable:RecordViews()

    ------------------------------------------

    inst:AddComponent("drownable")

    ------------------------------------------
    inst:AddComponent("knownlocations")
    inst:SetBrain(brain)

    inst:ListenForEvent("working", AfterWorking)
    inst:ListenForEvent("entitysleep", OnEntitySleep)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("onhitother", OnHitOther)
    inst:ListenForEvent("death", OnDead)
    inst:ListenForEvent("onremove", OnRemove)
    inst:ListenForEvent("newcombattarget", OnNewTarget)

    inst:WatchWorldState("stopwinter", OnStopWinter)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.IsSated = IsSated
    inst.WantsToLeave = WantsToLeave
	inst.SwitchToEightFaced = SwitchToEightFaced
	inst.SwitchToFourFaced = SwitchToFourFaced

    return inst
end

local function yulecommonfn(inst)
	inst.entity:AddLight()
	inst.Light:SetIntensity(.6)
	inst.Light:SetRadius(8)
	inst.Light:SetFalloff(3)
	inst.Light:SetColour(1, 0, 0)
end

local function normalfn()
    local yule = IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST)

	local inst = yule and
		commonfn("deerclops_yule", yulecommonfn) or
		commonfn("deerclops_build")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.sounds = normal_sounds

    inst.components.health:SetMaxHealth(TUNING.DEERCLOPS_HEALTH)

    inst.components.combat:SetDefaultDamage(TUNING.DEERCLOPS_DAMAGE)
	inst.components.combat:SetRange(TUNING.DEERCLOPS_ATTACK_RANGE)
    inst.components.combat:SetAttackPeriod(TUNING.DEERCLOPS_ATTACK_PERIOD)

    inst.components.lootdropper:SetChanceLootTable("deerclops")

	inst:AddComponent("sleeper")
	inst.components.sleeper:SetResistance(4)
	inst.components.sleeper:SetSleepTest(ShouldSleep)
	inst.components.sleeper:SetWakeTest(ShouldWake)

	MakeHugeFreezableCharacter(inst, "deerclops_body")

    if yule then
		inst.yule = true
		inst.haslaserbeam = true

        inst:AddComponent("timer")

        inst:ListenForEvent("newstate", YuleOnNewState)
    end

    return inst
end

--------------------------------------------------------------------------

local function Mutated_OnTemp8Faced(inst)
	if inst.temp8faced:value() then
		inst.gestalt.Transform:SetEightFaced()
	else
		inst.gestalt.Transform:SetFourFaced()
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

local function Mutated_SetFrenzied(inst, frenzied)
	if frenzied then
		if not inst.frenzied then
			inst.frenzied = true
			inst.frenzy_starttime = GetTime()
			inst.frenzy_starthp = inst.components.health:GetPercent()
		end
	elseif inst.frenzied then
		inst.frenzied = nil
		inst.frenzy_starttime = nil
		inst.frenzy_starthp = nil
	end
end

local function Mutated_ShouldStayFrenzied(inst)
	--frenzy ends after losing enough hp
	--frenzy must last minimum duration (even if hp requirement is met)
	return inst.frenzied
		and (	inst.frenzy_starttime + TUNING.MUTATED_DEERCLOPS_FRENZY_MIN_TIME > GetTime() or
				inst.frenzy_starthp - inst.components.health:GetPercent() < TUNING.MUTATED_DEERCLOPS_FRENZY_HP
			)
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

local function mutatedcommonfn(inst)
    inst:AddTag("lunar_aligned")
	inst:AddTag("noepicmusic")

	inst.AnimState:Hide("gestalt_eye")

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
	end
end

local function mutatedfn()
    local inst = commonfn("deerclops_mutated", mutatedcommonfn)

    if not TheWorld.ismastersim then
		inst:ListenForEvent("temp8faceddirty", Mutated_OnTemp8Faced)

        return inst
    end

    inst.sounds = mutated_sounds
	inst.hasiceaura = true
	inst.hasknockback = true
	inst.hasicelance = true
	inst.hasfrenzy = true
	inst.freezepower = 3
	inst.ignorebase = true

    inst:AddComponent("timer")

    inst.components.health:SetMaxHealth(TUNING.MUTATED_DEERCLOPS_HEALTH)

    inst.components.combat:SetDefaultDamage(TUNING.MUTATED_DEERCLOPS_DAMAGE)
	inst.components.combat:SetRange(TUNING.MUTATED_DEERCLOPS_ATTACK_RANGE)
    inst.components.combat:SetAttackPeriod(TUNING.MUTATED_DEERCLOPS_ATTACK_PERIOD)

	inst:AddComponent("planarentity")
	inst:AddComponent("planardamage")
	inst.components.planardamage:SetBaseDamage(TUNING.MUTATED_DEERCLOPS_PLANAR_DAMAGE)

    inst.components.lootdropper:SetChanceLootTable("mutateddeerclops")

	inst.components.burnable.fxdata[1].prefab = "character_fire_flicker"
	inst.components.burnable.nocharring = true
	inst.components.burnable:SetOnIgniteFn(Mutated_OnIgnite)
	inst.components.burnable:SetOnExtinguishFn(Mutated_OnExtinguish)

	inst:ListenForEvent("droppedtarget", Mutated_OnDroppedTarget)
    inst:ListenForEvent("death", Mutated_OnDead)

	--Overriding these
	inst.SwitchToEightFaced = Mutated_SwitchToEightFaced
	inst.SwitchToFourFaced = Mutated_SwitchToFourFaced

	inst.SetFrenzied = Mutated_SetFrenzied
	inst.ShouldStayFrenzied = Mutated_ShouldStayFrenzied

    return inst
end

return
        Prefab("deerclops",         normalfn, normal_assets, normal_prefabs),
        Prefab("mutateddeerclops",  mutatedfn,  mutated_assets,  mutated_prefabs )
