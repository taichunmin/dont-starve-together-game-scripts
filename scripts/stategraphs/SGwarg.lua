require("stategraphs/commonstates")
local easing = require("easing")

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "action"),
}

local function ChooseAttack(inst, target)
	target = target or inst.components.combat.target
	if target ~= nil and not target:IsValid() then
		target = nil
	end

	if inst.canflamethrower and not inst.components.timer:TimerExists("flamethrower_cd") then
		inst.sg:GoToState("flamethrower_pre", target)
		return true
	end

	if inst:HasTag("gingerbread") and (inst._next_goo_time == nil or inst._next_goo_time < GetTime()) then
		inst.sg:GoToState("attack_icing", target)
	else
		inst.sg:GoToState("attack", target)
	end
	return true
end

local function TryStagger(inst)
	inst.sg:GoToState("stagger_pre")
	return true
end

local function TryHowl(inst)
	inst.sg:GoToState("howl")
	return true
end

local function SpawnCloseEmberFX(inst, angle)
	local x, y, z = inst.Transform:GetWorldPosition()
	angle = (inst.Transform:GetRotation() + angle) * DEGREES
	x = x + math.cos(angle) * 3.5
	z = z - math.sin(angle) * 3.5
	angle = math.random() * PI2
	x = x + math.cos(angle) * 0.6
	z = z - math.sin(angle) * 0.6

	if not TheWorld.Map:IsPassableAtPoint(x, 0, z) then
		return
	end

	local fx = table.remove(inst.ember_pool)
	if fx == nil then
		fx = SpawnPrefab("warg_mutated_ember_fx")
		fx:SetFXOwner(inst)
	end
	fx.Transform:SetPosition(x, 0, z)
	fx:RestartFX(1.7 + math.random() * 0.3, "nofade")
	fx:DoTaskInTime(math.random(18, 22) * FRAMES, fx.KillFX)
end

local function SpawnBreathFX(inst, angle, dist, targets)
	local fx = table.remove(inst.flame_pool)
	if fx == nil then
		fx = SpawnPrefab("warg_mutated_breath_fx")
		fx:SetFXOwner(inst)
	end

	local scale = (1.4 + math.random() * 0.25)
	if dist < 6 then
		scale = scale * 1.2
	elseif dist > 7 then
		scale = scale * (1 + (dist - 7) / 6)
	end

	local fadeoption = (dist < 6 and "nofade") or (dist <= 7 and "latefade") or nil

	local x, y, z = inst.Transform:GetWorldPosition()
	angle = (inst.Transform:GetRotation() + angle) * DEGREES
	x = x + math.cos(angle) * dist
	z = z - math.sin(angle) * dist
	dist = dist / 20
	angle = math.random() * PI2
	x = x + math.cos(angle) * dist
	z = z - math.sin(angle) * dist

	fx.Transform:SetPosition(x, 0, z)
	fx:RestartFX(scale, fadeoption, targets)
end

local AOE_OFFSET = 3
local AOE_RANGE = 1.7
local AOE_RANGE_PADDING = 3
local AOE_TARGET_TAGS = { "_combat" }
local AOE_TARGET_CANT_TAGS = { "INLIMBO", "flight", "invisible", "playerghost", "lunar_aligned" }
local MULTIHIT_FRAMES = 10

--NOTE: This is for close range that the breath fx doesn't fully cover
local function DoFlamethrowerAOE(inst, angle, targets)
	inst.components.combat.ignorehitrange = true
	inst.components.combat.ignoredamagereflect = true

	local tick = GetTick()
	local x, y, z = inst.Transform:GetWorldPosition()
	angle = (inst.Transform:GetRotation() + angle) * DEGREES
	x = x + math.cos(angle) * AOE_OFFSET
	z = z - math.sin(angle) * AOE_OFFSET
	local ents = TheSim:FindEntities(x, 0, z, AOE_RANGE + AOE_RANGE_PADDING, AOE_TARGET_TAGS, AOE_TARGET_CANT_TAGS)
	for i, v in ipairs(ents) do
		if v:IsValid() and not v:IsInLimbo() and not (v.components.health ~= nil and v.components.health:IsDead()) then
			local range = AOE_RANGE + v:GetPhysicsRadius(0)
			if v:GetDistanceSqToPoint(x, 0, z) < range * range then
				local target_data = targets[v]
				if target_data == nil then
					target_data = {}
					targets[v] = target_data
				end
				if target_data.tick ~= tick then
					target_data.tick = tick
					--Supercool
					if v.components.temperature ~= nil then
						local newtemp = math.max(v.components.temperature.mintemp, TUNING.MUTATED_WARG_COLDFIRE_TEMPERATURE)
						if newtemp < v.components.temperature:GetCurrent() then
							v.components.temperature:SetTemperature(newtemp)
						end
					end
					--Hit
					if (target_data.hit_tick == nil or target_data.hit_tick + MULTIHIT_FRAMES < tick) and inst.components.combat:CanTarget(v) then
						target_data.hit_tick = tick
						inst.components.combat:DoAttack(v)
					end
				end
			end
		end
	end

	inst.components.combat.ignorehitrange = false
	inst.components.combat.ignoredamagereflect = false
end

local events =
{
	CommonHandlers.OnSleepEx(),
	CommonHandlers.OnWakeEx(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnLocomote(true, false),

	EventHandler("attacked", function(inst, data)
		--V2C: health check since corpse shares this SG
		if inst.components.health ~= nil and not inst.components.health:IsDead() and (
			not inst.sg:HasStateTag("busy") or
			inst.sg:HasStateTag("caninterrupt") or
			inst.sg:HasStateTag("frozen")
		) then
			if inst.sg:HasStateTag("staggered") then
				inst.sg.statemem.staggered = true
				inst.sg:GoToState("stagger_hit")
			elseif not CommonHandlers.HitRecoveryDelay(inst) then
				inst.sg:GoToState("hit")
			end
		end
	end),
	EventHandler("doattack", function(inst, data)
		if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
			ChooseAttack(inst, data ~= nil and data.target or nil)
		end
	end),
	EventHandler("dohowl", function(inst)
		if not inst.components.health:IsDead() then
			if not inst.sg:HasStateTag("busy") then
				TryHowl(inst)
			else
				inst.sg.mem.dohowl = true
			end
		end
	end),
    EventHandler("heardwhistle", function(inst, data)
        if not (inst.sg:HasStateTag("statue") or
				inst:HasTag("lunar_aligned") or
                inst.components.health:IsDead() or
                (inst.components.freezable ~= nil and inst.components.freezable:IsFrozen())) then
            if inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep() then
                inst.components.sleeper:WakeUp()
                inst.components.combat:SetTarget(nil)
            else
                if inst.components.combat:TargetIs(data.musician) then
                    inst.components.combat:SetTarget(nil)
                end
                if not inst.sg:HasStateTag("howling") then
                    inst.sg:GoToState("howl", {count=2})
                end
            end
        end
    end),

	EventHandler("chomp", function(inst, data)
		if data ~= nil and data.target ~= nil and not inst.components.health:IsDead() then
			if inst.sg:HasStateTag("chewing") then
				inst.sg:GoToState("chomp_pre_from_loop", data.target)
			elseif not inst.sg:HasStateTag("busy") then
				inst.sg:GoToState("chomp_pre", data.target)
			end
		end
	end),

    --Clay warg
    EventHandler("becomestatue", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("transformstatue")
        end
    end),
}

local function ShowEyeFX(inst)
    if inst._eyeflames ~= nil then
        inst._eyeflames:set(true)
    end
end

local function HideEyeFX(inst)
    if inst._eyeflames ~= nil then
        inst._eyeflames:set(false)
    end
end

local function PlayClayShakeSound(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/clayhound/stone_shake")
end

local function PlayClayFootstep(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/clayhound/footstep")
end

local function MakeStatue(inst)
    if not inst.sg.mem.statue then
        inst.sg.mem.statue = true
        local x, y, z = inst.Transform:GetWorldPosition()
        inst.Physics:Stop()
        ChangeToObstaclePhysics(inst)
        inst.Physics:Teleport(x, 0, z)
        inst:AddTag("notarget")
        inst.components.health:SetInvincible(true)

        --Snap to nearest 45 degrees + 15 degree offset for better facing update during camera rotation
        inst.Transform:SetRotation(math.floor(inst.Transform:GetRotation() / 45 + .5) * 45 + 15)

        inst:OnBecameStatue()
    end
end

local function MakeReanimated(inst)
    if inst.sg.mem.statue then
        inst.sg.mem.statue = nil
        local x, y, z = inst.Transform:GetWorldPosition()
        inst.Physics:SetMass(1000)
        ChangeToCharacterPhysics(inst)
        inst.Physics:Teleport(x, 0, z)
        inst:RemoveTag("notarget")
        inst.components.health:SetInvincible(false)

        inst:OnReanimated()
    end
end

local states =
{
	State{
		name = "init",
		onenter = function(inst)
			inst.sg:GoToState(inst.components.locomotor ~= nil and "idle" or "corpse_idle")
		end,
	},

    State{
        name = "idle",
        tags = { "idle" },

        onenter = function(inst)
			if (inst.sg.mem.dostagger and TryStagger(inst)) or
				(inst.sg.mem.dohowl and TryHowl(inst))
			then
				return
			end

			inst.components.locomotor:StopMoving()
			if not inst.AnimState:IsCurrentAnimation("idle_loop") then
				inst.AnimState:PlayAnimation("idle_loop", true)
			end
            if not inst.noidlesound then
                inst.SoundEmitter:PlaySound(inst.sounds.idle)
				inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
            end
        end,

		ontimeout = function(inst)
			inst.sg:GoToState("idle")
		end,
    },

	State{
		name = "hit",
		tags = { "hit", "busy" },

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("hit")
			inst.SoundEmitter:PlaySound(inst.sounds.hit)
			CommonHandlers.UpdateHitRecoveryDelay(inst)
		end,

		timeline =
		{
			FrameEvent(9, function(inst)
				if (inst.sg.mem.dostagger and TryStagger(inst)) or
					(inst.sg.mem.dohowl and TryHowl(inst)) or
					(inst.sg.statemem.doattack ~= nil and ChooseAttack(inst, inst.sg.statemem.doattack))
				then
					return
				end
				inst.sg.statemem.doattack = nil
				inst.sg:RemoveStateTag("busy")
			end),
		},

		events =
		{
			EventHandler("doattack", function(inst, data)
				if not inst.sg.mem.dostagger then
					if not inst.sg:HasStateTag("busy") then
						ChooseAttack(inst, data ~= nil and data.target or nil)
					else
						inst.sg.statemem.doattack = data ~= nil and data.target or nil
					end
				end
				return true
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
	},

	State{
		name = "spawn_shake",
		tags = { "busy", "invisible", "noattack", "temp_invincible" },

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("spawn_shake")
			inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
		end,

		timeline =
		{
			FrameEvent(3, function(inst)
				inst.sg:RemoveStateTag("invisible")
				inst.sg:RemoveStateTag("noattack")
				inst.sg:RemoveStateTag("temp_invincible")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("howl")
				end
			end),
		},
	},

	State{
		name = "death",
		tags = { "dead", "busy", "noattack" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("death")
			inst.components.lootdropper:DropLoot(inst:GetPosition())
			inst.looted = true

			if inst:HasTag("clay") then
				inst.sg.statemem.clay = true
				RemovePhysicsColliders(inst)
				HideEyeFX(inst)
				inst.SoundEmitter:PlaySound("dontstarve/common/destroy_pot")
				inst.SoundEmitter:PlaySoundWithParams("dontstarve/creatures/together/antlion/sfx/ground_break", { size = .1 })
			end
			inst.SoundEmitter:PlaySound(inst.sounds.death)

			if inst.components.burnable ~= nil and inst.components.burnable.nocharring then
				inst.components.burnable.fastextinguish = true
				inst.components.burnable:SetBurnTime(0)
			end
		end,

		timeline =
		{
			TimeEvent(4 * FRAMES, function(inst)
				if inst.sg.statemem.clay then
					PlayClayFootstep(inst)
				end
			end),
			TimeEvent(6 * FRAMES, function(inst)
				if inst.sg.statemem.clay then
					PlayClayFootstep(inst)
				end
			end),
			FrameEvent(19, function(inst)
				if inst.components.burnable ~= nil and inst.components.burnable.nocharring then
					inst.components.burnable:Extinguish()
				end
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if not inst.sg.statemem.clay and inst.AnimState:AnimDone() then
					inst.sg:GoToState("corpse")
				end
			end),
		},
	},

	State{
		name = "corpse",
		tags = { "dead", "busy", "noattack" },

		onenter = function(inst)
			if inst.components.burnable ~= nil and inst.components.burnable.nocharring then
				inst.components.burnable.fastextinguish = true
				inst.components.burnable:SetBurnTime(0)
				inst.components.burnable:Extinguish()
			end
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("corpse")
		end,

		timeline =
		{
			--delay 1 frame in case we are loading
			FrameEvent(1, function(inst)
				local corpse = not inst:HasTag("lunar_aligned") and TheWorld.components.lunarriftmutationsmanager ~= nil and TheWorld.components.lunarriftmutationsmanager:TryMutate(inst, "wargcorpse") or nil
				if corpse == nil then
					inst:AddTag("NOCLICK")
					inst.persists = false
					RemovePhysicsColliders(inst)

					--34 + 1 frames since death anim started
					local delay = (inst.components.health.destroytime or 2) - 35 * FRAMES
					if delay > 0 then
						inst.sg:SetTimeout(delay)
					else
						ErodeAway(inst)
						if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
							inst.components.burnable.fastextinguish = true
							inst.components.burnable:KillFX()
						end
					end
				elseif inst:HasTag("gingerbread") then
					corpse:SetAltBuild("gingerbread")
				end
			end),
		},

		ontimeout = function(inst)
			ErodeAway(inst)
			if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
				inst.components.burnable.fastextinguish = true
				inst.components.burnable:KillFX()
			end
		end,
	},

	--------------------------------------------------------------------------
	--Used by "wargcorpse"

	State{
		name = "corpse_idle",

		onenter = function(inst)
			inst.AnimState:PlayAnimation("corpse")
		end,
	},

	State{
		name = "corpse_mutate_pre",
		tags = { "mutating" },

		onenter = function(inst, mutantprefab)
			inst.AnimState:PlayAnimation("twitch", true)
			inst.sg:SetTimeout(3)
			inst.sg.statemem.mutantprefab = mutantprefab
			inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/twitching_LP", "loop")
		end,

		ontimeout = function(inst)
			inst.sg.statemem.mutating = true
			inst.sg:GoToState("corpse_mutate", inst.sg.statemem.mutantprefab)
		end,

		onexit = function(inst)
			if not inst.sg.statemem.mutating then
				inst.SoundEmitter:KillSound("loop")
			end
		end,
	},

	State{
		name = "corpse_mutate",
		tags = { "mutating" },

		onenter = function(inst, mutantprefab)
			inst.AnimState:OverrideSymbol("SPIKE", "warg_mutated_actions", "SPIKE")
			inst.AnimState:OverrideSymbol("hair_mutate", "warg_mutated_actions", "hair_mutate")
			if inst.build == "gingerbread" then
				inst.AnimState:OverrideSymbol("cookiecrumbs", "warg_mutated_actions", "cookiecrumbs")
				inst.AnimState:PlayAnimation("mutate_pre_gingerbread")
			else
				inst.AnimState:PlayAnimation("mutate_pre")
			end
			inst.SoundEmitter:PlaySound("rifts3/mutated_varg/mutate_pre_f0")
			inst.sg.statemem.mutantprefab = mutantprefab
		end,

		timeline =
		{
			FrameEvent(14, function(inst) inst.SoundEmitter:KillSound("loop") end),
			FrameEvent(14, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_varg/mutate_pre_f14") end),
			FrameEvent(106, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_varg/mutate") end),
			FrameEvent(111, function(inst)
				inst.AnimState:SetAddColour(.5, .5, .5, 0)
				inst.AnimState:SetLightOverride(.5)
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					local rot = inst.Transform:GetRotation()
					local creature = ReplacePrefab(inst, inst.sg.statemem.mutantprefab)
					creature.Transform:SetRotation(rot)
					creature.AnimState:MakeFacingDirty() --not needed for clients
					creature.sg:GoToState("mutate_pst")
				end
			end),
		},

		onexit = function(inst)
			--Shouldn't reach here!
			inst.AnimState:ClearAllOverrideSymbols()
			inst.AnimState:SetAddColour(0, 0, 0, 0)
			inst.AnimState:SetLightOverride(0)
			inst.SoundEmitter:KillSound("loop")
		end,
	},

	--------------------------------------------------------------------------
	--Transitions from corpse_mutate after prefab switch
	State{
		name = "mutate_pst",
		tags = { "busy", "noattack", "temp_invincible" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("mutate")
			inst.sg.statemem.flash = 24
		end,

		onupdate = function(inst)
			local c = inst.sg.statemem.flash
			if c >= 0 then
				inst.sg.statemem.flash = c - 1
				c = easing.inOutQuad(math.min(20, c), 0, 1, 20)
				inst.AnimState:SetAddColour(c, c, c, 0)
				inst.AnimState:SetLightOverride(c)
			end
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},

		onexit = function(inst)
			inst.AnimState:SetAddColour(0, 0, 0, 0)
			inst.AnimState:SetLightOverride(0)
		end,
	},

	--------------------------------------------------------------------------

	State{
		name = "attack",
		tags = { "attack", "busy" },

		onenter = function(inst, target)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("atk")
			inst.SoundEmitter:PlaySound(inst.sounds.attack)
			if target ~= nil and target:IsValid() then
				if inst.components.combat:TargetIs(target) then
					inst.components.combat:StartAttack()
				end
				inst:ForceFacePoint(target.Transform:GetWorldPosition())
				inst.sg.statemem.target = target
			end
		end,

		timeline =
		{
			FrameEvent(11, function(inst)
				inst.components.combat:DoAttack()
			end),
			FrameEvent(20, function(inst)
				if inst.sg.mem.dostagger and TryStagger(inst) then
					return
				end
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(31, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
	},

	State{
		name = "chomp_pre",
		tags = { "busy" },

		onenter = function(inst, target)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("eat_pre")
			inst.SoundEmitter:PlaySound(inst.sounds.attack)
			if target ~= nil and target:IsValid() then
				inst.components.combat:StartAttack()
				inst:ForceFacePoint(target.Transform:GetWorldPosition())
				inst.sg.statemem.target = target
			end
		end,

		timeline =
		{
			FrameEvent(1, function(inst)
				inst.sg:GoToState("chomp_pre_timeline_from_frame1", inst.sg.statemem.target)
			end),
		},
	},

	State{
		name = "chomp_pre_from_loop",

		onenter = function(inst, target)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("eat_pre")
			inst.SoundEmitter:PlaySound(inst.sounds.attack, nil, 0.75)
			if target ~= nil and target:IsValid() then
				inst.components.combat:StartAttack()
				inst:ForceFacePoint(target.Transform:GetWorldPosition())
			else
				target = nil
			end
			inst.AnimState:SetFrame(1)
			inst.sg:GoToState("chomp_pre_timeline_from_frame1", target)
		end,
	},

	State{
		name = "chomp_pre_timeline_from_frame1",
		tags = { "busy" },

		onenter = function(inst, target)
			inst.sg.statemem.target = target
		end,

		timeline =
		{
			FrameEvent(12 - 1, function(inst)
				local target = inst.sg.statemem.target
				if target ~= nil and target:IsValid() and
					inst:IsNear(target, inst.components.combat:GetHitRange() + target:GetPhysicsRadius(0))
				then
					target:PushEvent("chomped", { eater = inst, amount = 2 })
				else
					inst.sg.statemem.target = nil
				end
				inst:ClearBufferedAction()
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.sg.mem.dostagger and TryStagger(inst) then
						return
					end
					inst.sg:GoToState(inst.sg.statemem.target ~= nil and "chomp_loop" or "chomp_pst")
				end
			end),
		},
	},

	State{
		name = "chomp_loop",
		tags = { "chewing", "busy", "caninterrupt" },

		onenter = function(inst, numlooped)
			inst.sg.statemem.numlooped = numlooped or 1
			inst.components.locomotor:StopMoving()
			if not inst.AnimState:IsCurrentAnimation("eat_loop") then
				inst.AnimState:PlayAnimation("eat_loop", true)
			end
			inst.SoundEmitter:PlaySound("rifts3/chewing/warg")
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
		end,

		ontimeout = function(inst)
			if inst.sg.statemem.numlooped > 1 and inst.sg.mem.dohowl then
				inst.sg:GoToState("chomp_pst")
			elseif inst.sg.statemem.numlooped < 4 then
				inst.sg:GoToState("chomp_loop", inst.sg.statemem.numlooped + 1)
			else
				inst.sg:GoToState("chomp_pst")
			end
		end,
	},

	State{
		name = "chomp_pst",
		tags = { "busy", "caninterrupt" },

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("eat_pst")
		end,

		timeline =
		{
			FrameEvent(8, function(inst)
				if inst.sg.mem.dohowl and TryHowl(inst) then
					return
				end
				inst.sg:RemoveStateTag("busy")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
	},

    State{
        name = "howl",
        tags = { "busy", "howling" },

        onenter = function(inst, data)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("howl")
            inst.SoundEmitter:PlaySound(inst.sounds.howl)
            inst.sg.statemem.count = data and data.count or nil
			inst.sg.mem.dohowl = nil
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst)
                if inst.sg.statemem.count == nil then
					local hounds = inst:SpawnHounds()
					if hounds ~= nil then
						local t = GetTime()
						for i, v in ipairs(hounds) do
							--for brain, so hounds called in mid-fight won't go for carcass right away
							local delay = 4 + math.random() * 2
							v.components.combat.lastwasattackedtime = t - TUNING.HOUND_FIND_CARCASS_DELAY + delay
						end
					end
					inst.sg.mem.dohowl = nil
                end
            end),
			FrameEvent(36, function(inst)
				if inst.sg.statemem.count == nil or inst.sg.statemem.count <= 1 then
					if inst.sg.mem.dostagger and TryStagger(inst) then
						return
					end
					inst.sg:AddStateTag("caninterrupt")
				end
			end),
			FrameEvent(45, function(inst)
				if inst.sg:HasStateTag("caninterrupt") then
					inst.sg:RemoveStateTag("busy")
				end
			end),
        },

        events =
        {
            EventHandler("heardwhistle", function(inst)
				if not inst:HasTag("lunar_aligned") then
					inst.sg.statemem.count = 2
					inst.sg:RemoveStateTag("caninterrupt")
					inst.sg:AddStateTag("busy")
				end
            end),
            EventHandler("animover", function(inst)
                if inst.sg.statemem.count ~= nil and inst.sg.statemem.count > 1 then
                    inst.sg:GoToState("howl", {count=inst.sg.statemem.count - 1})
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

	--Gingerbread warg
    State{
        name = "attack_icing",
        tags = { "attack", "busy" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("attack_icing")
            inst.components.combat:StartAttack()
        end,

        timeline =
		{
            TimeEvent(14 * FRAMES, function(inst) inst:LaunchGooIcing() end),
            TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbread_vargr/whoosh") end),
            TimeEvent(17 * FRAMES, function(inst) inst:LaunchGooIcing() end),
            TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbread_vargr/whoosh") end),
            TimeEvent(26 * FRAMES, function(inst) inst:LaunchGooIcing() end),
            TimeEvent(26*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbread_vargr/whoosh") end),
            TimeEvent(33 * FRAMES, function(inst) inst:LaunchGooIcing() end),
            TimeEvent(33*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbread_vargr/whoosh") end),
            TimeEvent(42 * FRAMES, function(inst) inst:LaunchGooIcing() end),
            TimeEvent(42*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbread_vargr/whoosh") end),
            TimeEvent(49 * FRAMES, function(inst) inst:LaunchGooIcing() end),
            TimeEvent(49*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbread_vargr/whoosh") end),
		},

        events =
        {
            EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
			        inst.sg:GoToState("idle")
			    end
			end),
        },
    },

    State{
        name = "gingerbread_intro",
        tags = { "intro_state" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("gingerbread_eat_loop")
        end,

        timeline =
		{
			TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbread_vargr/eat") end),
            TimeEvent(6*FRAMES, function(inst) if math.random() < 0.5 then inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbreadpig/vocal") end end),
            TimeEvent(12*FRAMES, function(inst) if math.random() < 0.7 then inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/vargr/idle") end end),
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbread_vargr/eat") end),
            -- TimeEvent(16*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbreadpig/vocal") end),
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbread_vargr/eat") end),
            -- TimeEvent(26*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbreadpig/vocal") end),
		},

        events =
        {
            EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.components.combat == nil or inst.components.combat:HasTarget() then
				        inst.sg:GoToState("idle")
					else
				        inst.sg:GoToState("gingerbread_intro")
					end
			    end
			end),
        },
    },

    --Clay warg
    State{
        name = "statue",
        tags = { "busy", "noattack", "statue" },

        onenter = function(inst)
            MakeStatue(inst)
            HideEyeFX(inst)
            inst.AnimState:PlayAnimation("statue")
        end,

        events =
        {
            EventHandler("reanimate", function(inst, data)
                inst.sg.statemem.statue = true
                inst.sg:GoToState("reanimatestatue", data ~= nil and data.target or nil)
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.statue then
                MakeReanimated(inst)
                ShowEyeFX(inst)
            end
        end,
    },

    State{
        name = "reanimatestatue",
        tags = { "busy", "noattack", "statue" },

        onenter = function(inst, target)
            MakeStatue(inst)
            ShowEyeFX(inst)
            inst.AnimState:PlayAnimation("statue_pst")
            inst.SoundEmitter:PlaySound("dontstarve/music/clay_resurrection")
            inst.sg.statemem.target = target
        end,

        timeline =
        {
            TimeEvent(1 * FRAMES, PlayClayShakeSound),
            TimeEvent(3 * FRAMES, PlayClayShakeSound),
            TimeEvent(5 * FRAMES, PlayClayShakeSound),
            TimeEvent(7 * FRAMES, PlayClayShakeSound),
            TimeEvent(21 * FRAMES, PlayClayShakeSound),
            TimeEvent(23 * FRAMES, PlayClayShakeSound),
            TimeEvent(25 * FRAMES, PlayClayShakeSound),
            TimeEvent(29 * FRAMES, PlayClayShakeSound),
            TimeEvent(32 * FRAMES, PlayClayShakeSound),
            TimeEvent(34 * FRAMES, PlayClayShakeSound),
            TimeEvent(36 * FRAMES, PlayClayShakeSound),
            TimeEvent(38 * FRAMES, PlayClayShakeSound),
            TimeEvent(39 * FRAMES, PlayClayShakeSound),
            TimeEvent(41 * FRAMES, PlayClayFootstep),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            MakeReanimated(inst)
            if inst.sg.statemem.target ~= nil then
                inst.components.combat:SetTarget(inst.sg.statemem.target)
            end
        end,
    },

    State{
        name = "transformstatue",
        tags = { "busy", "noattack", "statue" },

        onenter = function(inst)
            MakeStatue(inst)
            inst.AnimState:PlayAnimation("statue_pre")
        end,

        timeline =
        {
            TimeEvent(2 * FRAMES, PlayClayShakeSound),
            TimeEvent(4 * FRAMES, PlayClayShakeSound),
            TimeEvent(6 * FRAMES, function(inst)
                PlayClayShakeSound(inst)
                PlayClayFootstep(inst)
            end),
            TimeEvent(8 * FRAMES, PlayClayShakeSound),
            TimeEvent(10 * FRAMES, function(inst)
                PlayClayShakeSound(inst)
                HideEyeFX(inst)
            end),
            TimeEvent(12 * FRAMES, PlayClayShakeSound),
            TimeEvent(14 * FRAMES, PlayClayShakeSound),
            TimeEvent(16 * FRAMES, PlayClayShakeSound),
            TimeEvent(18 * FRAMES, PlayClayShakeSound),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.statue = true
                    inst.sg:GoToState("statue")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.statue then
                MakeReanimated(inst)
                ShowEyeFX(inst)
            end
        end,
    },

	--Mutated
	State{
		name = "flamethrower_pre",
		tags = { "attack", "busy" },

		onenter = function(inst, target)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("atk_breath_pre")
			inst:SwitchToEightFaced()
			local dir
			if target ~= nil and target:IsValid() then
				if inst.components.combat:TargetIs(target) then
					inst.components.combat:StartAttack()
				end
				inst.sg.statemem.target = target
				inst.sg.statemem.targetpos = target:GetPosition()
				dir = inst:GetAngleToPoint(inst.sg.statemem.targetpos)
			else
				dir = inst.Transform:GetRotation()
			end
			--snap to 45's
			inst.Transform:SetRotation(math.floor(dir / 45 + .5) * 45)

			inst.components.combat:SetDefaultDamage(TUNING.MUTATED_WARG_FLAMETHROWER_DAMAGE)
		end,

		onupdate = function(inst)
			local target = inst.sg.statemem.target
			if target ~= nil then
				if target:IsValid() then
					local p = inst.sg.statemem.targetpos
					p.x, p.y, p.z = target.Transform:GetWorldPosition()
					local rot = inst.Transform:GetRotation()
					local rot1 = inst:GetAngleToPoint(p)
					local drot = ReduceAngle(rot1 - rot)
					if math.abs(drot) < 90 then
						rot1 = rot + math.clamp(drot / 2, -1, 1)
						--snap to 45's
						inst.Transform:SetRotation(math.floor(rot1 / 45 + .5) * 45)
					end
				else
					inst.sg.statemem.target = nil
				end
			elseif inst.sg.statemem.angle ~= nil then
				DoFlamethrowerAOE(inst, inst.sg.statemem.angle, inst.sg.statemem.targets)
			end
		end,

		timeline =
		{
			FrameEvent(0, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_varg/blast_pre_f0") end),
			FrameEvent(16, function(inst)
				inst.sg.statemem.target = nil
				inst.sg.statemem.targets = {}
			end),

			FrameEvent(17, function(inst)
				inst.SoundEmitter:PlaySound("rifts3/mutated_varg/blast_pre_f17")
				inst.SoundEmitter:PlaySound("rifts3/mutated_varg/blast_lp", "loop")
			end),
			FrameEvent(19, function(inst) SpawnBreathFX(inst, -40, 4, inst.sg.statemem.targets) end),

			FrameEvent(20, function(inst) inst.sg.statemem.angle = -45 end),
			FrameEvent(21, function(inst) SpawnBreathFX(inst, -45, 6, inst.sg.statemem.targets) end),
			FrameEvent(24, function(inst) SpawnBreathFX(inst, -45, 8, inst.sg.statemem.targets) end),
			FrameEvent(27, function(inst) SpawnBreathFX(inst, -45, 9, inst.sg.statemem.targets) end),

			FrameEvent(29, function(inst) SpawnCloseEmberFX(inst, -45) end),
			FrameEvent(26, function(inst) SpawnBreathFX(inst, -45, 5, inst.sg.statemem.targets) end),
			FrameEvent(29, function(inst) SpawnBreathFX(inst, -45, 7, inst.sg.statemem.targets) end),

			--frame 30 is start of "flamethrower_loop"
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.attacking = true
					inst.sg:GoToState("flamethrower_loop", inst.sg.statemem.targets)
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.attacking then
				inst:SwitchToSixFaced()
				inst.components.combat:SetDefaultDamage(TUNING.WARG_DAMAGE)
				inst.SoundEmitter:KillSound("loop")
			end
		end,
	},

	State{
		name = "flamethrower_loop",
		tags = { "attack", "busy" },

		onenter = function(inst, targets)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("atk_breath_loop")
			inst:SwitchToEightFaced()
			inst.sg.statemem.targets = targets or {}
			inst.sg.statemem.angle = -45
			--inst.sg.statemem.loop = true
			inst.components.timer:StopTimer("flamethrower_cd")
			inst.components.timer:StartTimer("flamethrower_cd", TUNING.MUTATED_WARG_FLAMETHROWER_CD + math.random() * 2)
			inst.components.combat:SetDefaultDamage(TUNING.MUTATED_WARG_FLAMETHROWER_DAMAGE)
			if not inst.SoundEmitter:PlayingSound("loop") then
				inst.SoundEmitter:PlaySound("rifts3/mutated_varg/blast_lp", "loop")
			end
		end,

		onupdate = function(inst)
			DoFlamethrowerAOE(inst, inst.sg.statemem.angle, inst.sg.statemem.targets)
		end,

		timeline =
		{
			--FrameEvent(-1, function(inst) SpawnCloseEmberFX(inst, -45) end),
			--FrameEvent(-4, function(inst) SpawnBreathFX(inst, -45, 5, inst.sg.statemem.targets) end),
			--FrameEvent(-1, function(inst) SpawnBreathFX(inst, -45, 7, inst.sg.statemem.targets) end),
			FrameEvent(3, function(inst) SpawnBreathFX(inst, -45, 9, inst.sg.statemem.targets) end),

			FrameEvent(2, function(inst) inst.sg.statemem.angle = -27 end),
			FrameEvent(3, function(inst) SpawnCloseEmberFX(inst, -27) end),
			FrameEvent(0, function(inst) SpawnBreathFX(inst, -27, 5, inst.sg.statemem.targets) end),
			FrameEvent(3, function(inst) SpawnBreathFX(inst, -27, 7, inst.sg.statemem.targets) end),
			FrameEvent(7, function(inst) SpawnBreathFX(inst, -27, 9, inst.sg.statemem.targets) end),

			FrameEvent(4, function(inst) inst.sg.statemem.angle = -9 end),
			FrameEvent(5, function(inst) SpawnCloseEmberFX(inst, -9) end),
			FrameEvent(2, function(inst) SpawnBreathFX(inst, -9, 5, inst.sg.statemem.targets) end),
			FrameEvent(5, function(inst) SpawnBreathFX(inst, -9, 7, inst.sg.statemem.targets) end),
			FrameEvent(9, function(inst) SpawnBreathFX(inst, -9, 9, inst.sg.statemem.targets) end),

			FrameEvent(6, function(inst) inst.sg.statemem.angle = 9 end),
			FrameEvent(7, function(inst) SpawnCloseEmberFX(inst, 9) end),
			FrameEvent(4, function(inst) SpawnBreathFX(inst, 9, 5, inst.sg.statemem.targets) end),
			FrameEvent(7, function(inst) SpawnBreathFX(inst, 9, 7, inst.sg.statemem.targets) end),
			FrameEvent(11, function(inst) SpawnBreathFX(inst, 9, 9, inst.sg.statemem.targets) end),

			FrameEvent(9, function(inst) inst.sg.statemem.angle = 27 end),
			FrameEvent(10, function(inst) SpawnCloseEmberFX(inst, 27) end),
			FrameEvent(7, function(inst) SpawnBreathFX(inst, 27, 5, inst.sg.statemem.targets) end),
			FrameEvent(10, function(inst) SpawnBreathFX(inst, 27, 7, inst.sg.statemem.targets) end),
			FrameEvent(14, function(inst) SpawnBreathFX(inst, 27, 9, inst.sg.statemem.targets) end),

			FrameEvent(12, function(inst) inst.sg.statemem.angle = 45 end),
			FrameEvent(13, function(inst) SpawnCloseEmberFX(inst, 45) end),
			FrameEvent(10, function(inst) SpawnBreathFX(inst, 45, 5, inst.sg.statemem.targets) end),
			FrameEvent(13, function(inst) SpawnBreathFX(inst, 45, 7, inst.sg.statemem.targets) end),
			FrameEvent(17, function(inst) SpawnBreathFX(inst, 45, 9, inst.sg.statemem.targets) end),

			FrameEvent(15, function(inst) inst.sg.statemem.angle = 27 end),
			FrameEvent(16, function(inst) SpawnCloseEmberFX(inst, 27) end),
			FrameEvent(13, function(inst) SpawnBreathFX(inst, 27, 5, inst.sg.statemem.targets) end),
			FrameEvent(16, function(inst) SpawnBreathFX(inst, 27, 7, inst.sg.statemem.targets) end),
			FrameEvent(20, function(inst) SpawnBreathFX(inst, 27, 9, inst.sg.statemem.targets) end),

			FrameEvent(18, function(inst) inst.sg.statemem.angle = 9 end),
			FrameEvent(19, function(inst) SpawnCloseEmberFX(inst, 9) end),
			FrameEvent(16, function(inst) SpawnBreathFX(inst, 9, 5, inst.sg.statemem.targets) end),
			FrameEvent(19, function(inst) SpawnBreathFX(inst, 9, 7, inst.sg.statemem.targets) end),
			FrameEvent(23, function(inst) SpawnBreathFX(inst, 9, 9, inst.sg.statemem.targets) end),

			FrameEvent(21, function(inst) inst.sg.statemem.angle = -9 end),
			FrameEvent(22, function(inst) SpawnCloseEmberFX(inst, -9) end),
			FrameEvent(19, function(inst) SpawnBreathFX(inst, -9, 5, inst.sg.statemem.targets) end),
			FrameEvent(22, function(inst) SpawnBreathFX(inst, -9, 7, inst.sg.statemem.targets) end),
			FrameEvent(26, function(inst) SpawnBreathFX(inst, -9, 9, inst.sg.statemem.targets) end),

			FrameEvent(24, function(inst) inst.sg.statemem.angle = -27 end),
			FrameEvent(25, function(inst) SpawnCloseEmberFX(inst, -27) end),
			FrameEvent(22, function(inst) SpawnBreathFX(inst, -27, 5, inst.sg.statemem.targets) end),
			FrameEvent(25, function(inst) SpawnBreathFX(inst, -27, 7, inst.sg.statemem.targets) end),
			--FrameEvent(29, function(inst) SpawnBreathFX(inst, -27, 9, inst.sg.statemem.targets) end),

			FrameEvent(27, function(inst) inst.sg.statemem.angle = -45 end),
			FrameEvent(28, function(inst) SpawnCloseEmberFX(inst, -45) end),
			FrameEvent(25, function(inst) SpawnBreathFX(inst, -45, 5, inst.sg.statemem.targets) end),
			FrameEvent(28, function(inst) SpawnBreathFX(inst, -45, 7, inst.sg.statemem.targets) end),
			--FrameEvent(32, function(inst) SpawnBreathFX(inst, -45, 9, inst.sg.statemem.targets) end),

			--frame 29 and beyond goes to "flamethrower_pst"
		},

		events =
		{
			EventHandler("attacked", function(inst, data)
				if not inst.components.health:IsDead() and
					data ~= nil and data.spdamage ~= nil and data.spdamage.planar ~= nil
				then
					if not inst.sg.mem.dostagger then
						inst.sg.mem.dostagger = true
						inst.sg.statemem.staggertime = GetTime() + 0.3
					elseif GetTime() > inst.sg.statemem.staggertime then
						inst.sg:GoToState("hit")
					end
				end
				return true
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.attacking = true
					if inst.sg.statemem.loop then
						SpawnBreathFX(inst, -27, 9, inst.sg.statemem.targets)
						inst.sg:GoToState("flamethrower_loop", inst.sg.statemem.targets)
					else
						inst.sg:GoToState("flamethrower_pst", inst.sg.statemem.targets)
					end
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.attacking then
				inst:SwitchToSixFaced()
				inst.components.combat:SetDefaultDamage(TUNING.WARG_DAMAGE)
				inst.SoundEmitter:KillSound("loop")
			elseif not inst.sg.statemem.loop then
				inst.components.combat:SetDefaultDamage(TUNING.WARG_DAMAGE)
			end
		end,
	},

	State{
		name = "flamethrower_pst",
		tags = { "attack", "busy" },

		onenter = function(inst, targets)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("atk_breath_pst")
			inst:SwitchToEightFaced()
			inst.SoundEmitter:PlaySound("rifts3/mutated_varg/blast_pst")
			inst.sg.statemem.targets = targets or {}
		end,

		timeline =
		{
			FrameEvent(0, function(inst) SpawnBreathFX(inst, -27, 9, inst.sg.statemem.targets) end),

			FrameEvent(3, function(inst) SpawnBreathFX(inst, -45, 9, inst.sg.statemem.targets) end),

			FrameEvent(4, function(inst)
				if inst.sg.mem.dostagger and TryStagger(inst) then
					return
				end
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(6, function(inst) inst.SoundEmitter:KillSound("loop") end),
			FrameEvent(13, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},

		onexit = function(inst)
			inst:SwitchToSixFaced()
			inst.SoundEmitter:KillSound("loop")
		end,
	},

	--------------------------------------------------------------------------

	State{
		name = "stagger_pre",
		tags = { "staggered", "busy", "nosleep" },

		onenter = function(inst)
			inst.sg.mem.dostagger = nil
			inst.sg.mem.dohowl = nil
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("stagger_pre")
			inst.components.timer:StopTimer("stagger")
			inst.components.timer:StartTimer("stagger", TUNING.MUTATED_WARG_STAGGER_TIME)
			inst.components.timer:StopTimer("flamethrower_cd")
			inst.components.timer:StartTimer("flamethrower_cd", TUNING.MUTATED_WARG_STAGGER_TIME + TUNING.MUTATED_WARG_FLAMETHROWER_CD * (0.5 + math.random() * 0.5))
			inst.SoundEmitter:PlaySound(inst.sounds.hit)
		end,

		timeline =
		{
			FrameEvent(16, function(inst)
			end),
			FrameEvent(24, function(inst)
				inst.sg:AddStateTag("caninterrupt")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState(inst.components.timer:TimerExists("stagger") and "stagger_idle" or "stagger_pst")
				end
			end),
		},
	},

	State{
		name = "stagger_idle",
		tags = { "staggered", "busy", "caninterrupt", "nosleep" },

		onenter = function(inst)
			if not inst.components.timer:TimerExists("stagger") then
				inst.sg:GoToState("stagger_pst")
				return
			end
			inst.AnimState:PlayAnimation("stagger", true)
		end,

		events =
		{
			EventHandler("timerdone", function(inst, data)
				if data ~= nil and data.name == "stagger" then
					inst.sg:GoToState("stagger_pst")
				end
			end),
		},
	},

	State{
		name = "stagger_hit",
		tags = { "staggered", "busy", "hit", "nosleep" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("stagger_hit")
		end,

		timeline =
		{
			FrameEvent(9, function(inst)
				if inst.components.timer:TimerExists("stagger") then
					inst.sg:AddStateTag("caninterrupt")
				end
			end),
			FrameEvent(16, function(inst)
				if not inst.components.timer:TimerExists("stagger") then
					inst.sg:GoToState("stagger_pst", true)
					return
				end
				inst.sg.statemem.cangetup = true
			end),
		},

		events =
		{
			EventHandler("timerdone", function(inst, data)
				if data ~= nil and data.name == "stagger" and inst.sg.statemem.cangetup then
					inst.sg:GoToState("stagger_pst", true)
				end
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.components.timer:TimerExists("stagger") then
						inst.sg:GoToState("stagger_idle")
					else
						inst.sg:GoToState("stagger_pst", true)
					end
				end
			end),
		},
	},

	State{
		name = "stagger_pst",
		tags = { "staggered", "busy", "nosleep" },

		onenter = function(inst, nohit)
			inst.AnimState:PlayAnimation("stagger_pst")
			if not nohit then
				inst.sg:AddStateTag("caninterrupt")
			end
			if inst.components.sleeper ~= nil then
				inst.components.sleeper:WakeUp()
			end
		end,

		timeline =
		{
			FrameEvent(10, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.sleep) end),
			FrameEvent(11, function(inst)
				inst.sg:RemoveStateTag("staggered")
				inst.sg:RemoveStateTag("caninterrupt")
			end),
			CommonHandlers.OnNoSleepFrameEvent(66, function(inst)
				if inst.sg.mem.dostagger and TryStagger(inst) then
					return
				end
				inst.sg:RemoveStateTag("nosleep")
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(39, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.idle) end),
			FrameEvent(99, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
	},

	--------------------------------------------------------------------------
}

CommonStates.AddRunStates(states,
{
    runtimeline =
    {
        TimeEvent(5 * FRAMES, function(inst)
            if inst:HasTag("clay") then
                PlayClayFootstep(inst)
            else
                PlayFootstep(inst)
            end
            inst.SoundEmitter:PlaySound(inst.sounds.idle)
        end),
    },
})

CommonStates.AddSleepExStates(states,
{
	starttimeline =
	{
		FrameEvent(22, function(inst)
			inst.sg:RemoveStateTag("caninterrupt")
		end),
	},
    sleeptimeline =
    {
        TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.sleep) end),
    },
	waketimeline =
	{
		CommonHandlers.OnNoSleepFrameEvent(18, function(inst)
			if inst.sg.mem.dostagger and TryStagger(inst) then
				return
			end
			inst.sg:RemoveStateTag("nosleep")
			inst.sg:AddStateTag("caninterrupt")
		end),
		FrameEvent(24, function(inst)
			inst.sg:RemoveStateTag("busy")
		end),
	},
},
{
	onsleep = function(inst)
		inst.sg:AddStateTag("caninterrupt")
		inst.sg.mem.dostagger = nil
		inst.sg.mem.dohowl = nil
	end,
})

CommonStates.AddFrozenStates(states, HideEyeFX, ShowEyeFX)

return StateGraph("warg", states, events, "init", actionhandlers)
