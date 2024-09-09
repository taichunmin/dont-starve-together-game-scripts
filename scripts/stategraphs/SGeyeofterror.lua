require("stategraphs/commonstates")

local actionhandlers =
{
}

local function PlaySpeechOnPlayerTarget(inst, speech_line_name)
    -- We don't want both twins playing speech lines,
    -- so we have a simple toggle set on the prefab.
    if inst._nospeech then
        return
    end

    -- Make our combat target speak.
    local target = inst.components.combat.target

    -- If we don't have a player combat target, find a nearby player.
    if not target or not target:HasTag("player") then
        local x, y, z = inst.Transform:GetWorldPosition()
        target = FindClosestPlayerInRangeSq(x, y, z, 324, true)
    end

    if target ~= nil and target.components.talker ~= nil and target:HasTag("player") then
        target.components.talker:Say(GetString(target, speech_line_name))
    end
end

local events =
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnSleepEx(),
    CommonHandlers.OnWakeEx(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),

    EventHandler("doattack", function(inst)
        if inst.components.health ~= nil and not inst.components.health:IsDead()
                and (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("hit")) then
            inst.sg:GoToState("taunt")
        end
    end),

    EventHandler("spawnminieyes", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            local spawnstate = (inst.sg.mem.transformed and "spawnminieyes_mouth") or "spawnminieyes"
            inst.sg:GoToState(spawnstate)
        elseif not inst.sg:HasStateTag("spawnminieyes") then
            inst.sg.mem.wantstospawn = true
        end
    end),

    EventHandler("chomp", function(inst)
        if not inst.components.health:IsDead()
                and not inst.components.freezable:IsFrozen()
                and not inst.components.sleeper:IsAsleep()
                and not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("chomp", inst.components.combat.target)
        end
    end),

    EventHandler("charge", function(inst)
        if not inst.components.health:IsDead()
                and not inst.components.freezable:IsFrozen()
                and not inst.components.sleeper:IsAsleep()
                and not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("charge_pre", inst.components.combat.target)
        end
    end),

    EventHandler("focustarget", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("focustarget")
        elseif not inst.sg:HasStateTag("focustarget") then
            inst.sg.mem.wantstofocustarget = true
        end
    end),

    EventHandler("health_transform", function(inst)
        if not inst.sg.mem.transformed and not inst.sg.mem.wantstoleave then
            if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
                inst.sg:GoToState("transform")
            elseif not inst.sg:HasStateTag("transform") then
                inst.sg.mem.wantstotransform = true
            end
        end
    end),

    EventHandler("leave", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("flyaway")
        elseif not inst.sg:HasStateTag("leaving") then
            inst.sg.mem.wantstoleave = true
        end
    end),

    EventHandler("arrive", function(inst)
        inst.sg:GoToState("arrive")
    end),

    EventHandler("flyback", function(inst)
        inst.sg:GoToState("flyback")
    end),
}

local function go_to_idle(inst)
    inst.sg:GoToState("idle")
end

local function lower_flying_creature(inst)
    inst:RemoveTag("flying")
    inst:PushEvent("on_landed")
end

local function raise_flying_creature(inst)
    inst:AddTag("flying")
    inst:PushEvent("on_no_longer_landed")
end

local function spawn_ground_fx(inst)
    if not TheWorld.Map:IsVisualGroundAtPoint(inst.Transform:GetWorldPosition()) then
        SpawnPrefab("boss_ripple_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
    else
        local fx = SpawnPrefab("slide_puff")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx.Transform:SetScale(1.3, 1.3, 1.3)
    end
end

local CHARGE_RANGE_OFFSET = 3 - TUNING.EYEOFTERROR_CHARGE_AOERANGE
local CHARGE_LOOP_TARGET_ONEOF_TAGS = {"tree", "_health"}

local AOE_RANGE_PADDING = 3
local AOE_TARGET_MUSTHAVE_TAGS = { "_health", "_combat" }
local AOE_TARGET_CANT_TAGS = { "INLIMBO", "eyeofterror", "flight", "invisible", "notarget", "noattack" }
local AOE_TARGET_ONEOF_TAGS = { "animal", "character", "monster", "shadowminion" }
local function DoAOEAttack(inst, range)
	--assert(range <= inst.components.combat.hitrange)
    local x,y,z = inst.Transform:GetWorldPosition()
    local targets = TheSim:FindEntities(
		x, y, z, range + AOE_RANGE_PADDING,
        AOE_TARGET_MUSTHAVE_TAGS, AOE_TARGET_CANT_TAGS, AOE_TARGET_ONEOF_TAGS
    )

	if #targets > 0 then
		local default_damage = inst.components.combat.defaultdamage
		inst.components.combat:SetDefaultDamage(inst._chompdamage or TUNING.EYEOFTERROR_AOE_DAMAGE)
		for _, target in ipairs(targets) do
			if target:IsValid() and not (target.components.health ~= nil and target.components.health:IsDead()) then
				local range1 = range + target:GetPhysicsRadius(0)
				if target:GetDistanceSqToPoint(x, y, z) < range1 * range1 then
					inst.components.combat:DoAttack(target)
				end
			end
		end
		inst.components.combat:SetDefaultDamage(default_damage)
	end
end

local function DoEpicScare(inst, duration)
    inst.components.epicscare:Scare(duration or 5)
    inst.components.commander:AlertAllSoldiers()
end

local function get_rng_cooldown(cooldown)
    return GetRandomWithVariance(cooldown, cooldown/3)
end

local COLLIDE_TIME = 3*FRAMES
local FX_TIME = 5*FRAMES

local states =
{
	State{
		name = "standby",
		tags = { "busy" },

		onenter = function(inst)
			inst.sg.mem.wantstoleave = false
			inst.sg.mem.sleeping = false
		end,
	},

    State {
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            
            if inst.sg.mem.wantstoleave then
                inst.sg:GoToState("flyaway")
            elseif inst.sg.mem.wantstospawn then
                local spawnstate = (inst.sg.mem.transformed and "spawnminieyes_mouth") or "spawnminieyes"
                inst.sg:GoToState(spawnstate)
            elseif inst.sg.mem.wantstofocustarget then
                inst.sg:GoToState("focustarget")
            elseif inst.sg.mem.wantstotransform then
                inst.sg:GoToState("transform")
            else
                inst.AnimState:PlayAnimation("idle")
                inst.SoundEmitter:PlaySound(inst._soundpath .. "mouthbreathing")
            end
        end,

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State {
        name = "taunt",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")

            inst.SoundEmitter:PlaySound(inst._soundpath .. "taunt_roar")
        end,

        timeline =
        {
            TimeEvent(18*FRAMES, function(inst)
                DoEpicScare(inst, 2)
            end),
        },

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State {
        name = "charge_pre",
        tags = {"busy", "canrotate", "charge"},

        onenter = function(inst, target)
            inst.Physics:Stop()

            local cooldown = (inst.sg.mem.transformed and inst._cooldowns.mouthcharge)
                or inst._cooldowns.charge
            inst.components.timer:StartTimer("charge_cd", get_rng_cooldown(cooldown))

            inst.sg.statemem.target = target
			inst.sg.statemem.steering = true

            inst.AnimState:PlayAnimation("charge_pre")

            -- All users of this SG share this sound.
            inst.SoundEmitter:PlaySound("terraria1/eyeofterror/charge_pre_sfx")

			inst.components.stuckdetection:Reset()
        end,

        onupdate = function(inst)
			if inst.sg.statemem.steering and inst.sg.statemem.target ~= nil then
				if inst.sg.statemem.target:IsValid() then
					inst:ForceFacePoint(inst.sg.statemem.target.Transform:GetWorldPosition())
				else
					inst.sg.statemem.target = nil
				end
			end
        end,

        timeline =
        {
            TimeEvent(11 * FRAMES, function(inst)
				--normal: stop tracking early
				inst.sg.statemem.steering = inst.sg.mem.transformed
            end),
			TimeEvent(25 * FRAMES, function(inst)
				--transformed: stop tracking 8 frames b4 dash
				inst.sg.statemem.steering = false
			end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.sg.mem.transformed then
                    inst.sg.mem.mouthcharge_count = math.random(3, 5)
                    inst.sg:GoToState("mouthcharge_loop", inst.sg.statemem.target)
                else
                    inst.sg:GoToState("charge_loop", inst.sg.statemem.target)
                end
            end),
        },
    },

    State {
        name = "charge_loop",
        tags = {"busy", "canrotate", "charge"},

        onenter = function(inst, target)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)

            inst.AnimState:PlayAnimation("charge_loop", true)
            inst.SoundEmitter:PlaySound(inst._soundpath .. "charge_eye")

            inst.Physics:SetMotorVelOverride(inst._chargedata.eyechargespeed, 0, 0)

            inst.sg:SetTimeout(inst._chargedata.eyechargetimeout)
            inst.sg.statemem.collisiontime = 0
            inst.sg.statemem.fxtime = 0
            inst.sg.statemem.target = target
        end,

        onupdate = function(inst, dt)
            if inst.sg.statemem.collisiontime <= 0 then
				--assert(TUNING.EYEOFTERROR_CHARGE_AOERANGE <= inst.components.combat.hitrange)
                local x,y,z = inst.Transform:GetWorldPosition()
				local theta = inst.Transform:GetRotation() * DEGREES
				x = x + math.cos(theta) * CHARGE_RANGE_OFFSET
				z = z - math.sin(theta) * CHARGE_RANGE_OFFSET
				local ents = TheSim:FindEntities(x, y, z, TUNING.EYEOFTERROR_CHARGE_AOERANGE + AOE_RANGE_PADDING, nil, AOE_TARGET_CANT_TAGS, CHARGE_LOOP_TARGET_ONEOF_TAGS)
                for _, ent in ipairs(ents) do
					if ent:IsValid() then
						local range = TUNING.EYEOFTERROR_CHARGE_AOERANGE + ent:GetPhysicsRadius(0)
						if ent:GetDistanceSqToPoint(x, y, z) < range * range then
							inst:OnCollide(ent)
						end
					end
                end

                inst.sg.statemem.collisiontime = COLLIDE_TIME
            end
            inst.sg.statemem.collisiontime = inst.sg.statemem.collisiontime - dt

            if inst.sg.statemem.fxtime <= 0 then
                spawn_ground_fx(inst)

                inst.sg.statemem.fxtime = FX_TIME
            end
            inst.sg.statemem.fxtime = inst.sg.statemem.fxtime - dt
        end,

        onexit = function(inst)
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)

            inst.Physics:ClearMotorVelOverride()

            inst.components.locomotor:Stop()

            inst:ClearRecentlyCharged()
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("charge_pst")
        end,
    },

    State {
        name = "charge_pst",
        tags = {"busy", "canrotate", "charge"},

        onenter = function(inst, target)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("charge_pst")

            -- All users of this SG share this sound.
            inst.SoundEmitter:PlaySound("terraria1/eyeofterror/charge_pst_sfx")

			if inst.sg.mem.mouthcharge_count ~= nil and inst.sg.mem.mouthcharge_count > 0 then
				inst.sg.statemem.mouthcharge = true
				if target ~= nil and target:IsValid() then
					inst.sg.statemem.target = inst.components.stuckdetection:IsStuck() and inst.components.combat.target or target
				else
					inst.components.combat:TryRetarget()
					inst.sg.statemem.target = inst.components.combat.target
				end
			end
        end,

		onupdate = function(inst)
			if inst.sg.statemem.steering and inst.sg.statemem.target ~= nil then
				if inst.sg.statemem.target:IsValid() then
					inst:ForceFacePoint(inst.sg.statemem.target.Transform:GetWorldPosition())
				else
					inst.sg.statemem.target = nil
				end
			end
		end,

        timeline =
        {
			TimeEvent(3 * FRAMES, function(inst)
				inst.sg.statemem.steering = inst.sg.statemem.mouthcharge
			end),
			TimeEvent(13 * FRAMES, function(inst)
				--transformed: stop tracking 4 frames before dash
				inst.sg.statemem.steering = false
			end),
            TimeEvent(17*FRAMES, function(inst)
				if inst.sg.statemem.mouthcharge then
                    inst.sg:GoToState("mouthcharge_loop", inst.sg.statemem.target)
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if math.random() < inst._chargedata.tauntchance then
                    -- Try a target switch after finishing a charge move
                    inst.components.combat:DropTarget()

                    inst.sg:GoToState("taunt")
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State {
        name = "mouthcharge_loop",
        tags = {"busy", "canrotate", "charge"},

        onenter = function(inst, target)

            inst.SoundEmitter:PlaySound(inst._soundpath .. "charge")

            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)

            inst.AnimState:PlayAnimation("charge_loop", true)

            inst.Physics:SetMotorVelOverride(inst._chargedata.mouthchargespeed, 0, 0)

            inst.sg:SetTimeout(inst._chargedata.mouthchargetimeout)
            inst.sg.statemem.collisiontime = 0
            inst.sg.statemem.fxtime = 0
            inst.sg.statemem.target = target
        end,

        onupdate = function(inst, dt)
            if inst.sg.statemem.collisiontime <= 0 then
				--assert(TUNING.EYEOFTERROR_CHARGE_AOERANGE <= inst.components.combat.hitrange)
                local x,y,z = inst.Transform:GetWorldPosition()
				local theta = inst.Transform:GetRotation() * DEGREES
				x = x + math.cos(theta) * CHARGE_RANGE_OFFSET
				z = z - math.sin(theta) * CHARGE_RANGE_OFFSET
				local ents = TheSim:FindEntities(x, y, z, TUNING.EYEOFTERROR_CHARGE_AOERANGE + AOE_RANGE_PADDING, nil, AOE_TARGET_CANT_TAGS, CHARGE_LOOP_TARGET_ONEOF_TAGS)
                for _, ent in ipairs(ents) do
					if ent:IsValid() then
						local range = TUNING.EYEOFTERROR_CHARGE_AOERANGE + ent:GetPhysicsRadius(0)
						if ent:GetDistanceSqToPoint(x, y, z) < range * range then
							inst:OnCollide(ent)
						end
					end
                end

                inst.sg.statemem.collisiontime = COLLIDE_TIME
            end
            inst.sg.statemem.collisiontime = inst.sg.statemem.collisiontime - dt

            if inst.sg.statemem.fxtime <= 0 then
                spawn_ground_fx(inst)

                inst.sg.statemem.fxtime = FX_TIME
            end
            inst.sg.statemem.fxtime = inst.sg.statemem.fxtime - dt
        end,

        onexit = function(inst)
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)

            inst.Physics:ClearMotorVelOverride()

            inst.components.locomotor:Stop()

            inst:ClearRecentlyCharged()
        end,

        ontimeout = function(inst)
            inst.sg.mem.mouthcharge_count = (inst.sg.mem.mouthcharge_count == nil and 0)
                or inst.sg.mem.mouthcharge_count - 1

			inst.sg:GoToState("charge_pst", inst.sg.statemem.target)
        end,
    },

    State {
        name = "spawnminieyes",
        tags = { "spawnminieyes", "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            local target = inst.components.combat.target
            if target ~= nil and target:IsValid() then
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end

            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("spawn")

            inst.components.timer:StartTimer("spawneyes_cd", get_rng_cooldown(inst._cooldowns.spawn))
            inst.sg.mem.wantstospawn = false
        end,

        timeline =
        {
            TimeEvent(6*FRAMES, lower_flying_creature),
            TimeEvent(18*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst._soundpath .. "spawn") end),
            TimeEvent(21*FRAMES, function(inst)
                local minion_egg = SpawnPrefab("eyeofterror_mini_grounded")
                minion_egg.Transform:SetPosition(inst.Transform:GetWorldPosition())

                local angle = 360 * math.random()
                minion_egg.Transform:SetRotation(angle)

                minion_egg:PushEvent("on_landed")

                inst.components.commander:AddSoldier(minion_egg)
            end),

            CommonHandlers.OnNoSleepTimeEvent(32 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nosleep")
                inst.sg:RemoveStateTag("nofreeze")
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },

        onexit = function(inst)
            raise_flying_creature(inst)
        end,
    },

    State {
        name = "spawnminieyes_mouth",
        tags = { "spawnminieyes", "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("spawn2_pre")

            inst.SoundEmitter:PlaySound(inst._soundpath .. "spawn2_pre")

            inst.components.timer:StartTimer("spawneyes_cd", get_rng_cooldown(inst._cooldowns.spawn))
            inst.sg.mem.wantstospawn = false
        end,

        timeline =
        {
            TimeEvent(4*FRAMES, function(inst)
                lower_flying_creature(inst)
                inst.SoundEmitter:PlaySound(inst._soundpath .. "spawn2_pre")
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("spawnminieyes_mouth_loop"),
        },

        onexit = raise_flying_creature,
    },

    State {
        name = "spawnminieyes_mouth_loop",
        tags = { "spawnminieyes", "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("spawn2_loop")

            inst.SoundEmitter:PlaySound(inst._soundpath .. "spawn2_lp")

            lower_flying_creature(inst)

            if inst.sg.mem.minieye_spawns == nil then
                inst.sg.mem.minieye_spawns = math.random(2, inst._mouthspawncount)
            end
            inst.sg.mem.minieye_spawns = inst.sg.mem.minieye_spawns - 1

            -- The spit part of the animation is right at the start,
            -- so we can just spawn the projectiles here.
            local eye_position = inst:GetPosition()

            local minion_egg = SpawnPrefab("eyeofterror_mini_projectile")
            minion_egg.Transform:SetPosition(eye_position.x, eye_position.y + 1.5, eye_position.z)

            local angle = 360 * math.random()
            minion_egg.Transform:SetRotation(angle)

            angle = -angle * DEGREES
            local radius = minion_egg:GetPhysicsRadius(0) + 5.0
            local angle_vector = Vector3(radius * math.cos(angle), 0, radius * math.sin(angle))

            minion_egg.components.complexprojectile:Launch(eye_position + angle_vector, inst)

            inst.components.commander:AddSoldier(minion_egg)
        end,

        events =
        {
            CommonHandlers.OnNoSleepAnimOver(function(inst)
                if inst.sg.mem.minieye_spawns > 0 and
                        inst.components.commander:GetNumSoldiers() < inst:GetDesiredSoldiers() then
                    inst.sg.statemem.looping = true
                    inst.sg:GoToState("spawnminieyes_mouth_loop")
                else
                    inst.sg:GoToState("spawnminieyes_mouth_pst")
                end
            end),
        },

        onexit = function(inst)
            -- If we're not trying to continue spawning (i.e. an unexpected break out, or we're done),
            -- clear out our state-agnostic spawn counter.
            if not inst.sg.statemem.looping then
                inst.sg.mem.minieye_spawns = nil
            end

            raise_flying_creature(inst)
        end,
    },

    State {
        name = "spawnminieyes_mouth_pst",
        tags = { "spawnminieyes", "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("spawn2_pst")

            lower_flying_creature(inst)
        end,

        timeline =
        {
            TimeEvent(6*FRAMES, raise_flying_creature),
            CommonHandlers.OnNoSleepTimeEvent(8*FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nosleep")
                inst.sg:RemoveStateTag("nofreeze")
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },
    },

    State {
        name = "focustarget",
        tags = { "focustarget", "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()

            inst.components.timer:StartTimer("focustarget_cd", get_rng_cooldown(inst._cooldowns.focustarget))
            inst.sg.mem.wantstofocustarget = nil

            inst.AnimState:PlayAnimation("taunt")

            inst.SoundEmitter:PlaySound(inst._soundpath .. "taunt_roar")
        end,

        onexit = function(inst)
            inst.sg.mem.wantstofocustarget = false
        end,

        timeline =
        {
            TimeEvent(7*FRAMES, function(inst)
                inst.components.commander:AlertAllSoldiers()
            end),
            TimeEvent(10*FRAMES, function(inst)
                local soldiers = inst.components.commander:GetAllSoldiers()
                if #soldiers > 0 then
                    local target = inst.components.combat.target
                    if target ~= nil then
                        local soldiers = inst.components.commander:GetAllSoldiers()
                        for _, soldier in ipairs(soldiers) do
                            if soldier.FocusTarget ~= nil then
                                soldier:FocusTarget(target)
                            end
                        end
                    end
                end
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },
    },

    State {
        name = "transform",
        tags = { "busy", "noaoestun", "nofreeze", "nosleep", "nostun" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("transform")
            inst.AnimState:Show("mouth")
            inst.AnimState:Show("ball_mouth")
        end,

        timeline =
        {
            TimeEvent(9*FRAMES, lower_flying_creature),
            TimeEvent(29*FRAMES, raise_flying_creature),
            TimeEvent(30*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst._soundpath .. "taunt_epic")
            end),
            TimeEvent(33*FRAMES, DoEpicScare),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },

        onexit = function(inst)
            inst.sg.mem.transformed = true
            inst.sg.mem.wantstotransform = false

            inst.AnimState:Hide("eye")
            inst.AnimState:Hide("ball_eye")

            raise_flying_creature(inst)
        end,
    },

    State {
        name = "arrive_delay",
        tags = { "busy", "charge", "flight", "noaoestun", "noattack", "nofreeze", "nosleep", "nostun" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.sg:SetTimeout(10*FRAMES)
            inst.components.health:SetInvincible(true)
            inst:Hide()
        end,

        ontimeout = function(inst)
            inst:PushEvent("arrive")
        end,

        onexit = function(inst)
            inst:Show()
            inst.components.health:SetInvincible(false)
        end,
    },

    State {
        name = "arrive",
        tags = { "busy", "charge", "flight", "noaoestun", "noattack", "nofreeze", "nosleep", "nostun" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("arrive")

            local arrive_fx = SpawnPrefab("eyeofterror_arrive_fx")
            arrive_fx.Transform:SetPosition(inst.Transform:GetWorldPosition())

            inst.components.health:SetInvincible(true)
        end,

        timeline =
        {
            TimeEvent(36*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst._soundpath .. "arrive")
            end),
            TimeEvent(44*FRAMES, function(inst)
                PlaySpeechOnPlayerTarget(inst, "ANNOUNCE_EYEOFTERROR_ARRIVE")
            end),
            TimeEvent(122*FRAMES, function(inst)
                inst.sg:RemoveStateTag("flight")
                inst.sg:RemoveStateTag("noattack")
                inst.components.health:SetInvincible(false)
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("taunt"),
        },

        onexit = function(inst)
            inst.components.health:SetInvincible(false)
        end,
    },

    State {
        name = "chomp",
        tags = {"busy", "canrotate"},

        onenter = function(inst, target)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("chomp")

            inst.sg.statemem.target = target
        end,


        timeline =
        {
            TimeEvent(13*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst._soundpath .. "chomp")
            end),
            TimeEvent(25*FRAMES, function(inst)
                DoAOEAttack(inst, TUNING.EYEOFTERROR_AOERANGE)

                local ix, iy, iz = inst.Transform:GetWorldPosition()
                -- We don't want to spawn a splash underneath a boat,
                -- but we also don't want to spawn a leak until later in the animation.
                local boat = TheWorld.Map:GetPlatformAtPoint(ix, iz)
                if not boat then
                    if not TheWorld.Map:IsVisualGroundAtPoint(ix, iy, iz) then
                        SpawnPrefab("splash_green_large").Transform:SetPosition(ix, iy, iz)
                    else
                        inst.sg.statemem.sinkhole = SpawnPrefab("eyeofterror_sinkhole")
                        inst.sg.statemem.sinkhole.Transform:SetPosition(ix, iy, iz)

                        SpawnPrefab("sinkhole_spawn_fx_"..math.random(3)).Transform:SetPosition(ix, iy, iz)

                        local theta = math.random() * TWOPI
                        for i = 1, 7 do
                            local dust = SpawnPrefab("sinkhole_spawn_fx_"..math.random(3))

                            dust.Transform:SetPosition(
                                ix + math.cos(theta) * 1.6 * (1 + math.random() * .1),
                                0,
                                iz - math.sin(theta) * 1.6 * (1 + math.random() * .1)
                            )

                            local s = 0.6 + math.random() * .2
                            local x_scale = (i % 2 == 0 and -s) or s
                            dust.Transform:SetScale(x_scale, s, s)

                            theta = theta + (TWOPI/7)
                        end
                    end
                end

                lower_flying_creature(inst)

                ShakeAllCameras(CAMERASHAKE.VERTICAL, 0.5, 0.15, 0.1, inst, 40)
            end),
            TimeEvent(50*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst._soundpath .. "chomp_pst")

                if inst.sg.statemem.sinkhole and inst.sg.statemem.sinkhole:IsValid() then
                    inst.sg.statemem.sinkhole:PushEvent("docollapse")
                    inst.sg.statemem.sinkhole_collapsing = true
                else
                    local ipos = inst:GetPosition()
                    local boat = TheWorld.Map:GetPlatformAtPoint(ipos.x, ipos.z)
                    if boat then
                        boat:PushEvent("spawnnewboatleak",
                        {
                            pt = ipos,
                            leak_size = "med_leak",
                            playsoundfx = true,
                        })
                    end
                    ShakeAllCameras(CAMERASHAKE.FULL, 0.5, .015, .15, inst, 20)
                end

                raise_flying_creature(inst)
            end),
            TimeEvent(61*FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("taunt")
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.sinkhole_collapsing and
                    (inst.sg.statemem.sinkhole ~= nil and inst.sg.statemem.sinkhole:IsValid()) then
                inst.sg.statemem.sinkhole.components.timer:StartTimer("repair", FRAMES)
            end
        end,
    },

    State {
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            RemovePhysicsColliders(inst)
			inst:AddTag("NOCLICK")

            if not inst.sg.mem.transformed then
                inst.AnimState:Show("mouth")
                inst.AnimState:Show("ball_mouth")
                inst.sg.mem.transformed = true
            end

            inst.AnimState:PlayAnimation("death")

            inst.SoundEmitter:PlaySound(inst._soundpath .. "death")
        end,

        timeline =
        {
            TimeEvent(26*FRAMES, DoEpicScare),
            TimeEvent(31*FRAMES, lower_flying_creature),
            TimeEvent(36*FRAMES, function(inst)
				if inst.persists then
					inst.persists = false
					inst.components.lootdropper:DropLoot(inst:GetPosition())
				end
                ShakeAllCameras(CAMERASHAKE.VERTICAL, 0.5, 0.15, 0.1, inst, 40)
				inst:PushEvent("forgetme")
            end),
			TimeEvent(5, ErodeAway),
        },

        events =
        {
            EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst:PushEvent("turnoff_terrarium")
				end
            end),
        },

		onexit = function(inst)
			--Should NOT happen!
			inst:RemoveTag("NOCLICK")
		end,
    },

    State {
        name = "flyaway",
        tags = {"busy", "charge", "leaving", "noaoestun", "nofreeze", "nosleep", "nostun" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("flyaway")
            inst.SoundEmitter:PlaySound(inst._soundpath .. "flyaway")

            inst.sg.mem.wantstoleave = false
            inst.sg.mem.leaving = true
        end,

        timeline =
        {
            TimeEvent(23*FRAMES, function(inst)
                inst.sg:AddStateTag("flight")
                inst.sg:AddStateTag("noattack")
                inst.components.health:SetInvincible(true)
            end),
            TimeEvent(24*FRAMES, function(inst)
                PlaySpeechOnPlayerTarget(inst, "ANNOUNCE_EYEOFTERROR_FLYAWAY")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.mem.sleeping = false        -- Clean up after the "gotosleep" sleepex listener, since we're doing something weird here.

					inst.sg.mem.leaving = false
					inst.components.health:SetInvincible(false)
					inst:PushEvent("finished_leaving")
				end
            end),
        },

        onexit = function(inst)
            inst.sg.mem.leaving = false
            inst.components.health:SetInvincible(false)
        end,
    },

    State {
        name = "flyback_delay",
        tags = { "busy", "charge", "flight", "noaoestun", "noattack", "nofreeze", "nosleep", "nostun" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.sg:SetTimeout(10*FRAMES)
            inst.components.health:SetInvincible(true)
            inst:Hide()
        end,

        ontimeout = function(inst)
            inst:PushEvent("flyback")
        end,

        onexit = function(inst)
            inst:Show()
            inst.components.health:SetInvincible(false)
        end,
    },

    State {
        name = "flyback",
        tags = { "busy", "charge", "flight", "noaoestun", "noattack", "nofreeze", "nosleep", "nostun" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("flyback")

            local pos = inst:GetPosition()
            inst.components.knownlocations:RememberLocation("spawnpoint", pos)

            inst:FlybackHealthUpdate()

            inst.SoundEmitter:PlaySound(inst._soundpath .. "flyback")

            inst.components.health:SetInvincible(true)
        end,


        timeline =
        {
            TimeEvent(22*FRAMES, function(inst)
                PlaySpeechOnPlayerTarget(inst, "ANNOUNCE_EYEOFTERROR_FLYBACK")
            end),
            TimeEvent(25*FRAMES, function(inst)
                inst.sg:RemoveStateTag("flight")
                inst.sg:RemoveStateTag("noattack")
                inst.components.health:SetInvincible(false)
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("taunt"),
        },

        onexit = function(inst)
            inst.components.health:SetInvincible(false)
        end,
    },
}

CommonStates.AddHitState(states)

CommonStates.AddWalkStates(states)
CommonStates.AddFrozenStates(states, lower_flying_creature, raise_flying_creature)
CommonStates.AddSleepExStates(states,
{
    starttimeline =
    {
        TimeEvent(56*FRAMES, lower_flying_creature),
    },
    waketimeline =
    {
        TimeEvent(35*FRAMES, raise_flying_creature),
    },
},
{
    onsleep = function(inst)
        inst.SoundEmitter:PlaySound(inst._soundpath .. "sleep_pre")
    end,
    onsleeping = function(inst)
        inst.SoundEmitter:PlaySound(inst._soundpath .. "sleep_lp", "sleep_loop")
    end,
    onexitsleeping = function(inst)
        inst.SoundEmitter:KillSound("sleep_loop")
    end,
    onexitwake = raise_flying_creature,
})

return StateGraph("eyeofterror", states, events, "idle", actionhandlers)
