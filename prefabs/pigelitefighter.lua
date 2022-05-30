local assets =
{
    Asset("ANIM", "anim/ds_pig_basic.zip"),
    Asset("ANIM", "anim/ds_pig_actions.zip"),
    Asset("ANIM", "anim/ds_pig_attacks.zip"),
    Asset("ANIM", "anim/ds_pig_elite.zip"),
    Asset("ANIM", "anim/ds_pig_elite_intro.zip"),
    Asset("ANIM", "anim/pig_elite_build.zip"),
    Asset("ANIM", "anim/pig_guard_build.zip"),
    Asset("ANIM", "anim/ds_pig_attacks_combo.zip"),
    Asset("ANIM", "anim/slide_puff.zip"),
    Asset("SOUND", "sound/pig.fsb"),
}

local prefabs =
{
    "slide_puff",
}

local brain = require("brains/pigelitefighterbrain")

local function ontalk(inst, script)
    inst.SoundEmitter:PlaySound((inst.sg:HasStateTag("intropose") or inst.sg:HasStateTag("endpose")) and "dontstarve/pig/attack" or "dontstarve/pig/grunt")
end

local function ShouldSleep()
    return false
end

local function ShouldWake()
    return true
end

local function onnewcombattarget(inst, data)
	if data ~= nil then
		if data.target ~= nil and inst.components.follower ~= nil then
			inst.components.follower:StopFollowing()
		end

		if data.oldtarget ~= nil and data.target == nil then
			inst._should_despawn = true
			inst.persists = false
		end
	end
end

local function OnTimerDone(inst, data)
    if data.name == "despawn_timer" then
        inst._should_despawn = true
		inst.persists = false
    end
end

local function OnAttacked(inst, data)
    local attacker = data ~= nil and data.attacker or nil
	if attacker ~= nil and inst.components.follower ~= nil and inst.components.follower:GetLeader() == attacker then
		PreventTargetingOnAttacked(inst, attacker, "player")
		inst.components.follower:StopFollowing()
	elseif attacker.components.combat ~= nil and inst.components.combat.target == nil then
        inst.components.combat:SetTarget(attacker)
	end
end

local function OnFullMoon(inst, isfullmoon)
	if isfullmoon then
		if inst.components.follower ~= nil then
			inst.components.follower:StopFollowing()
		end
		if inst.components.combat ~= nil then
			inst.components.combat:DropTarget()
		end
        inst._should_despawn = true
		inst.persists = false
	end
end

local function PushMusic(inst)
    if ThePlayer ~= nil and ThePlayer:IsNear(inst, 30) then
        ThePlayer:PushEvent("triggeredevent", { name = "pigking", duration = 1 })
    end
end

--in order: blue, red, white, green
local BUILD_VARIATIONS =
{
    ["1"] = { "pig_ear", "pig_head", "pig_skirt", "pig_torso", "spin_bod" },
    ["2"] = { "pig_arm", "pig_ear", "pig_head", "pig_skirt", "pig_torso", "spin_bod" },
    ["3"] = { "pig_arm", "pig_ear", "pig_head", "pig_skirt", "pig_torso", "spin_bod" },
    ["4"] = { "pig_head", "pig_skirt", "pig_torso", "spin_bod" },
}

local function MakePigEliteFighter(variation)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddDynamicShadow()
        inst.entity:AddNetwork()

        inst:SetPhysicsRadiusOverride(.5)
        MakeCharacterPhysics(inst, 50, inst.physicsradiusoverride)

        inst.DynamicShadow:SetSize(1.5, .75)
        inst.Transform:SetFourFaced()

        inst:AddTag("character")
        inst:AddTag("pig")
        inst:AddTag("pigelite")
        inst:AddTag("scarytoprey")
        inst:AddTag("noepicmusic")
		inst:AddTag("ignorewalkableplatformdrowning")

        inst.AnimState:SetBank("pigman")
        inst.AnimState:SetBuild("pig_guard_build")
        inst.AnimState:AddOverrideBuild("slide_puff")
        inst.AnimState:PlayAnimation("idle_loop", true)
        inst.AnimState:Hide("hat")
        inst.AnimState:Hide("ARM_carry")

        for i, v in ipairs(BUILD_VARIATIONS[variation]) do
            inst.AnimState:OverrideSymbol(v, "pig_elite_build", v.."_"..variation)
        end

        inst:AddComponent("talker")
        inst.components.talker.fontsize = 35
        inst.components.talker.font = TALKINGFONT
        inst.components.talker.offset = Vector3(0, -400, 0)
        inst.components.talker:MakeChatter()

		if not TheNet:IsDedicated() then
			inst:DoPeriodicTask(0.5, PushMusic, 0)
		end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.talker.ontalk = ontalk

        inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
        inst.components.locomotor.runspeed = TUNING.PIG_ELITE_RUN_SPEED
        inst.components.locomotor.walkspeed = TUNING.PIG_ELITE_WALK_SPEED
		inst.components.locomotor:SetAllowPlatformHopping(true)
		inst:AddComponent("embarker")

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(TUNING.PIG_GUARD_HEALTH)

        inst:AddComponent("combat")
        inst.components.combat.hiteffectsymbol = "pig_torso"
        inst.components.combat:SetRange(2)
        inst.components.combat:SetDefaultDamage(TUNING.PIG_ELITE_FIGHTER_DAMAGE)
        inst.components.combat:SetAttackPeriod(TUNING.PIG_ELITE_FIGHTER_ATTACK_PERIOD)

        inst:AddComponent("follower")
        inst.components.follower:KeepLeaderOnAttacked()

        inst:AddComponent("inspectable")
        inst:AddComponent("entitytracker")

		inst:AddComponent("timer")
		inst.components.timer:StartTimer("despawn_timer", TUNING.PIG_ELITE_FIGHTER_DESPAWN_TIME)
		inst:ListenForEvent("timerdone", OnTimerDone)

        inst:AddComponent("sleeper")
        inst.components.sleeper:SetResistance(3)
        inst.components.sleeper:SetSleepTest(ShouldSleep)
        inst.components.sleeper:SetWakeTest(ShouldWake)

        MakeMediumFreezableCharacter(inst, "pig_torso")
        inst.components.freezable:SetDefaultWearOffTime(4)
        inst.components.freezable.diminishingreturns = true

        MakeMediumBurnableCharacter(inst, "pig_torso")
        MakeHauntablePanic(inst)

        inst:SetBrain(brain)
        inst:SetStateGraph("SGpigelitefighter")

        inst.sg.mem.variation = variation

		inst:ListenForEvent("newcombattarget", onnewcombattarget)
	    inst:ListenForEvent("attacked", OnAttacked)
	    inst:ListenForEvent("blocked", OnAttacked)

        inst:WatchWorldState("isfullmoon", OnFullMoon)
		inst:DoTaskInTime(0, function(i) OnFullMoon(i, TheWorld.state.isfullmoon) end)
        return inst
    end

    return Prefab("pigelitefighter"..variation, fn, assets, prefabs)
end

--For searching: "pigelitefighter1", "pigelitefighter2", "pigelitefighter3", "pigelitefighter4"
return MakePigEliteFighter("1"),
    MakePigEliteFighter("2"),
    MakePigEliteFighter("3"),
    MakePigEliteFighter("4")
