local assets =
{
    Asset("ANIM", "anim/carrat_basic.zip"),
    Asset("ANIM", "anim/carrat_yotc.zip"),
    Asset("ANIM", "anim/carrat_shadow_build.zip"),
    Asset("ANIM", "anim/carrat_exhausted_yotc.zip"),
    Asset("ANIM", "anim/carrat_traits_yotc.zip"),
    Asset("ANIM", "anim/redpouch_yotc.zip"),
}

local shadowcarratsounds =
{
    idle = "turnoftides/creatures/together/carrat/idle",
    hit = "turnoftides/creatures/together/carrat/hit",
    sleep = "turnoftides/creatures/together/carrat/sleep",
    death = "turnoftides/creatures/together/carrat/death",
    emerge = "turnoftides/creatures/together/carrat/emerge",
    submerge = "turnoftides/creatures/together/carrat/submerge",
    eat = "turnoftides/creatures/together/carrat/eat",
    stunned = "turnoftides/creatures/together/carrat/stunned",
	reaction = "turnoftides/creatures/together/carrat/reaction",

	step = "dontstarve/creatures/mandrake/footstep",
}

local prefabs =
{
	"shadow_puff",
}

local brain = require("brains/carratbrain")

local function race_begun(inst)
	if inst.components.yotc_racecompetitor ~= nil and inst.components.yotc_racestats ~= nil then
        inst:RemoveTag("has_no_prize")

		inst.components.yotc_racecompetitor.isforgetful = inst.components.yotc_racestats:GetDirectionModifier() == 0
		inst.components.yotc_racecompetitor.stamina_max = Lerp(TUNING.YOTC_RACER_STAMINA_BAD, TUNING.YOTC_RACER_STAMINA_GOOD, inst.components.yotc_racestats:GetStaminaModifier())
		inst.components.yotc_racecompetitor.exhausted_time = TUNING.YOTC_RACER_STAMINA_EXHAUSTED_TIME
		inst.components.yotc_racecompetitor.exhausted_time_var = TUNING.YOTC_RACER_STAMINA_EXHAUSTED_TIME_VAR
		inst.components.yotc_racecompetitor:RecoverStamina()

		if inst.components.locomotor ~= nil then
			inst.components.locomotor.runspeed = Lerp(TUNING.YOTC_RACER_SPEED_BAD, TUNING.YOTC_RACER_SPEED_GOOD, inst.components.yotc_racestats:GetSpeedModifier()) + math.random() * TUNING.YOTC_RACER_SPEED_VAR
		end

		if inst.components.health == nil or not inst.components.health:IsDead() then
			if inst.components.sleeper ~= nil then
				inst.components.sleeper:WakeUp()
			end

			local reaction_stat = inst.components.yotc_racestats ~= nil and inst.components.yotc_racestats:GetReactionModifier() or 0
			if reaction_stat == 0 then
				inst.sg:GoToState("race_start_stunned", math.random(TUNING.YOTC_RACER_REACTION_START_STUN_LOOPS_MIN, TUNING.YOTC_RACER_REACTION_START_STUN_LOOPS_MAX))
			else
				local start_delay = Lerp(TUNING.YOTC_RACER_REACTION_START_BAD, TUNING.YOTC_RACER_REACTION_START_GOOD, reaction_stat) + math.random() * Lerp(TUNING.YOTC_RACER_REACTION_START_BAD_VAR, TUNING.YOTC_RACER_REACTION_START_GOOD_VAR, reaction_stat)
				if start_delay > 0 then
					inst.components.yotc_racecompetitor:SetLateStarter(start_delay)
					inst.sg:GoToState("race_start_startle")
				end

			end
		end
	end
end

local function pieceout(inst)
	SpawnPrefab("shadow_puff").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst:Remove()
end

local function race_over_fn(inst)
    if inst.components.yotc_racecompetitor ~= nil then
       inst:RemoveComponent("yotc_racecompetitor")
    end

	inst:DoTaskInTime(1 + math.random(), pieceout)
end

local function OnMusicStateDirty(inst)
    if inst._musicstate:value() > 0 then
        if inst._musicstate:value() == CARRAT_MUSIC_STATES.RACE then
            if ThePlayer:GetDistanceSqToInst(inst) < 20*20 then
                ThePlayer:PushEvent("playracemusic")
            end
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 1, 0.5)
    RemovePhysicsColliders(inst)
    inst.Physics:SetCollisionGroup(COLLISION.SANITY)
    inst.Physics:CollidesWith(COLLISION.SANITY)

    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("carrat")
    inst.AnimState:SetBuild("carrat_shadow_build")
    inst.AnimState:PlayAnimation("idle1")
    inst.AnimState:SetMultColour(1, 1, 1, 0.65)

    inst.DynamicShadow:SetSize(1, .75)

    inst:AddTag("shadow")

    if IsSpecialEventActive(SPECIAL_EVENTS.YOTC) then
        inst.AnimState:AddOverrideBuild("redpouch_yotc")
    end

    inst._musicstate = net_tinybyte(inst.GUID, "carrat._musicstate", "musicstatedirty")
    inst._musicstate:set(CARRAT_MUSIC_STATES.NONE)

    if not TheNet:IsDedicated() then
        inst:ListenForEvent("musicstatedirty", OnMusicStateDirty)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst._color = "black"

    inst.sounds = shadowcarratsounds -- sounds must be assigned before the stategraph

    inst:AddComponent("yotc_racestats")

    inst:AddComponent("yotc_racecompetitor")
    inst.components.yotc_racecompetitor:SetRaceBegunFn(race_begun)
    inst.components.yotc_racecompetitor:SetRaceOverFn(race_over_fn)
	inst.components.yotc_racecompetitor.stamina_max_var = TUNING.YOTC_RACER_STAMINA_VAR
	inst.components.yotc_racecompetitor.is_ghostracer = true

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = TUNING.CARRAT.WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.CARRAT.RUN_SPEED

    inst:SetStateGraph("SGcarrat")
    inst:SetBrain(brain)

	inst.persists = false

    inst:AddComponent("inspectable")

    return inst
end

return Prefab("carrat_ghostracer", fn, assets, prefabs)
