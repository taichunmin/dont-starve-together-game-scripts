require("stategraphs/commonstates")
local easing = require("easing")

local actionhandlers =
{
    ActionHandler(ACTIONS.HAMMER, "attack"),
    ActionHandler(ACTIONS.GOHOME, "taunt"),
}

local SHAKE_DIST = 40

local function SetLightValue(inst, val)
    if inst.Light ~= nil then
        inst.Light:SetIntensity(.6 * val * val)
        inst.Light:SetRadius(8 * val)
        inst.Light:SetFalloff(3 * val)
    end
end

local function SetLightValueAndOverride(inst, val, override)
    if inst.Light ~= nil then
        inst.Light:SetIntensity(.6 * val * val)
        inst.Light:SetRadius(8 * val)
        inst.Light:SetFalloff(3 * val)
        inst.AnimState:SetLightOverride(override)
    end
end

local function SetLightColour(inst, val)
    if inst.Light ~= nil then
        inst.Light:SetColour(val, 0, 0)
    end
end

local AOE_RANGE_PADDING = 3
local AREAATTACK_MUST_TAGS = { "_combat" }
local AREA_EXCLUDE_TAGS = { "INLIMBO", "notarget", "noattack", "flight", "invisible", "playerghost", "deerclops" }
local ICESPAWNTIME = 0.25
local ICESPIKE_RADIUS = 1 --2/3 is more accurate, but 1 matches legacy

local function DoIceSpikeAOE(inst, target, x, z, data)
	inst.components.combat.ignorehitrange = true
	local ents = TheSim:FindEntities(x, 0, z, ICESPIKE_RADIUS + AOE_RANGE_PADDING, AREAATTACK_MUST_TAGS, AREA_EXCLUDE_TAGS)
	for i, v in ipairs(ents) do
		if not data.targets[v] and v:IsValid() and not v:IsInLimbo() and
			not (v.components.health ~= nil and v.components.health:IsDead())
		then
			local range = ICESPIKE_RADIUS + v:GetPhysicsRadius(0)
			if v:GetDistanceSqToPoint(x, 0, z) < range * range and inst.components.combat:CanTarget(v) then
				local shouldknockback = inst.hasknockback and v.components.freezable ~= nil and v.components.freezable:IsFrozen()
				inst.components.combat:DoAttack(v)
				if shouldknockback then
					v:PushEvent("knockback", { knocker = inst, radius = TUNING.DEERCLOPS_ATTACK_RANGE })
				end
				data.targets[v] = true
			end
		end
	end
	inst.components.combat.ignorehitrange = false

	--After the final spike, check if we hit anything at all
	if data.count > 1 then
		data.count = data.count - 1
	elseif next(data.targets) == nil then
		inst:PushEvent("onmissother", { target = target }) -- for ChaseAndAttack
	end
end

local function DoSpawnIceSpike(inst, target, rot, info, data, hitdelay, shouldsfx)
	local fx = table.remove(inst.icespike_pool)
	if fx == nil then
		fx = SpawnPrefab("deerclops_icespike_fx")
		fx:SetFXOwner(inst)
	end
	fx.Transform:SetPosition(info.x, 0, info.z)
	fx.Transform:SetRotation(rot)
	fx:RestartFX(info.big, info.variation)
	if shouldsfx then
		fx.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/ice_small")
	end
	if hitdelay < FRAMES then
		DoIceSpikeAOE(inst, target, info.x, info.z, data)
	else
		inst:DoTaskInTime(hitdelay, DoIceSpikeAOE, target, info.x, info.z, data)
	end
end

local function SpikeInfoNearToFar(a, b)
	return a.radius < b.radius
end

local MAX_ICESPIKE_SFX = 6

local function SpawnIceFx(inst, target)
	local data = { targets = {}, count = 0 }

	local AOEarc = 35

    local x, y, z = inst.Transform:GetWorldPosition()
    local angle = inst.Transform:GetRotation()
	local spikeinfo = {}

	local theta = angle * DEGREES
	local cos_theta = math.cos(theta)
	local sin_theta = math.sin(theta)
    local num = 3
	data.count = data.count + num
	for i = 1, num do
		local radius = TUNING.DEERCLOPS_ATTACK_RANGE / num * i
		table.insert(spikeinfo,
		{
			x = x + radius * cos_theta,
			z = z - radius * sin_theta,
			radius = radius,
		})
    end

	num = math.random(12, 17)
	data.count = data.count + num
	for i = 1, num do
        local theta =  ( angle + math.random(AOEarc *2) - AOEarc ) * DEGREES
        local radius = TUNING.DEERCLOPS_ATTACK_RANGE * math.sqrt(math.random())
		table.insert(spikeinfo,
		{
			x = x + radius * math.cos(theta),
			z = z - radius * math.sin(theta),
			radius = radius,
		})
    end

	num = math.random(5, 8)
	data.count = data.count + num
	local newarc = 180 - AOEarc
	for i = 1, num do
        local theta =  ( angle -180 + math.random(newarc *2) - newarc ) * DEGREES
        local radius = 2 * math.random() +1
		table.insert(spikeinfo,
		{
			x = x + radius * math.cos(theta),
			z = z - radius * math.sin(theta),
			radius = radius,
		})
	end

	table.sort(spikeinfo, SpikeInfoNearToFar)

	num = data.count
	local nextbig = 1
	local delayvar = ICESPAWNTIME / (num - 1) * 0.3
	local cursfxinstance = 0
	for i = 1, num do
		local rnd = math.random()
		rnd = math.floor(rnd * rnd * #spikeinfo * 0.6) + 1
		local info = table.remove(spikeinfo, rnd)
		local delay =
			(i == 1 and 0) or
			(i == num and ICESPAWNTIME) or
			(i - 1) / (num - 1) * ICESPAWNTIME + delayvar * (math.random() - 0.5)
		local hitdelay = math.max(0, 3 * FRAMES - delay)
		local soundidx = math.floor((i - 1) / (num - 1) * (MAX_ICESPIKE_SFX - 1))
		local shouldsfx = soundidx >= cursfxinstance
		if shouldsfx then
			cursfxinstance = soundidx + 1
		end
		if math.floor(i * 4 / num) == nextbig then
			info.big = true
			info.variation = nextbig
			nextbig = nextbig + 1
		end
		inst:DoTaskInTime(delay, DoSpawnIceSpike, target, angle, info, data, hitdelay, shouldsfx)
	end
end

local function SpawnLaser(inst)
    local numsteps = 10
    local x, y, z = inst.Transform:GetWorldPosition()
    local angle = (inst.Transform:GetRotation() + 90) * DEGREES
    local step = .75
    local offset = 2 - step --should still hit players right up against us
    local ground = TheWorld.Map
    local targets, skiptoss = {}, {}
    local i = -1
    local noground = false
    local fx, dist, delay, x1, z1
    while i < numsteps do
        i = i + 1
        dist = i * step + offset
        delay = math.max(0, i - 1)
        x1 = x + dist * math.sin(angle)
        z1 = z + dist * math.cos(angle)
        if not ground:IsPassableAtPoint(x1, 0, z1) then
            if i <= 0 then
                return
            end
            noground = true
        end
        fx = SpawnPrefab(i > 0 and "deerclops_laser" or "deerclops_laserempty")
        fx.caster = inst
        fx.Transform:SetPosition(x1, 0, z1)
        fx:Trigger(delay * FRAMES, targets, skiptoss)
        if i == 0 then
            ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, .6, fx, 30)
        end
        if noground then
            break
        end
    end

    if i < numsteps then
        dist = (i + .5) * step + offset
        x1 = x + dist * math.sin(angle)
        z1 = z + dist * math.cos(angle)
    end
    fx = SpawnPrefab("deerclops_laser")
    fx.Transform:SetPosition(x1, 0, z1)
    fx:Trigger((delay + 1) * FRAMES, targets, skiptoss)

    fx = SpawnPrefab("deerclops_laser")
    fx.Transform:SetPosition(x1, 0, z1)
    fx:Trigger((delay + 2) * FRAMES, targets, skiptoss)
end

local ICE_LANCE_RADIUS = 5.5

local function DoIceLanceAOE(inst, pt, targets)
	inst.components.combat.ignorehitrange = true
	local dist = math.sqrt(inst:GetDistanceSqToPoint(pt))
	local ents = TheSim:FindEntities(pt.x, 0, pt.z, ICE_LANCE_RADIUS, AREAATTACK_MUST_TAGS, AREA_EXCLUDE_TAGS)
	for i, v in ipairs(ents) do
		if not targets[v] and v:IsValid() and not v:IsInLimbo() and
			not (v.components.health ~= nil and v.components.health:IsDead()) and
			inst.components.combat:CanTarget(v)
		then
			local wasfrozen = v.components.freezable ~= nil and v.components.freezable:IsFrozen()
			inst.components.combat:DoAttack(v)
			if wasfrozen then
				v:PushEvent("knockback", { knocker = inst, radius = dist + ICE_LANCE_RADIUS })
			end
			targets[v] = true
		end
	end
	inst.components.combat.ignorehitrange = false
end

local function TryIceGrow(inst)
	local burning = inst.components.burnable:IsBurning()
	local shouldgrowice
	if not inst.components.combat:HasTarget() then
		--out of combat: regrow missing ice when not burning
		shouldgrowice = not burning and (inst.sg.mem.noice ~= nil or inst.sg.mem.noeyeice)
	else
		--in combat:
		--  -when EYE spike is NOT burning
		--    -either summon circle if needed (can be burning)
		--    -or regrow missing ice when not burning
		shouldgrowice =
			not (burning and inst.sg.mem.noice == 1 and not inst.sg.mem.noeyeice) and
			(
				(inst.hasiceaura and inst.sg.mem.circle == nil) or
				(not burning and inst.sg.mem.noice ~= nil)
			)
	end

	if shouldgrowice then
		inst.sg:GoToState("icegrow")
		return true
	end
	inst.sg.mem.doicegrow = nil
	return false
end

local function TryStagger(inst)
	if inst.sg.mem.noice == 1 and not inst.sg.mem.noeyeice and inst.components.burnable:IsBurning() then
		inst.sg:GoToState("struggle_pre")
		return true
	end
	inst.sg.mem.dostagger = nil
	return false
end

local function ChooseAttack(inst, target)
	target = target or inst.components.combat.target
	if target ~= nil and not target:IsValid() then
		target = nil
	end

	if inst.hasicelance and inst.sg.mem.noice ~= 1 and
		(
			inst.components.burnable:IsBurning() or
			(target ~= nil and not inst:IsNear(target, TUNING.MUTATED_DEERCLOPS_ICELANCE_RANGE.min))
		)
	then
		inst.sg:GoToState("icelance", target)
		return true
	end
	if inst.haslaserbeam then
		local isfrozen, shouldfreeze = false, false
		if target ~= nil and target.components.freezable ~= nil then
			if target.components.freezable:IsFrozen() then
				isfrozen = true
			elseif target.components.freezable:ResolveResistance() - target.components.freezable.coldness <= 2 then
				shouldfreeze = true
			end
		end
		if isfrozen or not (shouldfreeze or inst.components.timer:TimerExists("laserbeam_cd")) then
			inst.sg:GoToState("laserbeam", target)
			return true
		end
	end
	inst.sg:GoToState("attack", target)
	return true
end

local function StartAttackCooldown(inst)
	if inst.sg.mem.combo ~= nil then
		inst.sg.mem.combo = inst.sg.mem.combo + 1
		if inst.sg.mem.combo == 1 then
			inst.components.combat:SetAttackPeriod(1)
		elseif inst.sg.mem.combo == 3 or math.random() < 0.5 then
			inst.sg.mem.combo = 0
			inst.components.combat:SetAttackPeriod(TUNING.MUTATED_DEERCLOPS_COMBO_ATTACK_PERIOD)
		end
	end
	inst.components.combat:StartAttack()
end

local function StartFrenzy(inst)
	if inst.hasfrenzy and not inst.frenzied then
		inst:SetFrenzied(true)
		inst.sg.mem.combo = 0
	end
end

local function StopFrenzy(inst)
	if inst.frenzied then
		inst:SetFrenzied(false)
		inst.sg.mem.combo = nil
		inst.components.combat:SetAttackPeriod(TUNING.MUTATED_DEERCLOPS_ATTACK_PERIOD)
	end
end

local function DeerclopsFootstep(inst, moving, noice)
	inst.SoundEmitter:PlaySound(inst.sounds.step)
	ShakeAllCameras(CAMERASHAKE.VERTICAL, .5, .03, 1, inst, SHAKE_DIST)

	if not noice and inst.sg.mem.circle ~= nil then
		inst.sg.mem.circle:KillFX()
		inst.sg.mem.circle = SpawnPrefab("deerclops_aura_circle_fx")
		local x, y, z = inst.Transform:GetWorldPosition()
		if moving then
			local rot = inst.Transform:GetRotation() * DEGREES
			x = x + math.cos(rot) * 1.5
			z = z - math.sin(rot) * 1.5
		end
		inst.sg.mem.circle.Transform:SetPosition(x, 0, z)
		inst.sg.mem.circle.SoundEmitter:PlaySound("dontstarve/common/break_iceblock", nil, 0.4)
	end
end

local events =
{
    CommonHandlers.OnLocomote(false, true),
	CommonHandlers.OnSleepEx(),
	CommonHandlers.OnWakeEx(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnSink(),

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
				--hit out of struggle state lowers priority for chain re-entering struggle state
				inst.sg:GoToState("hit", inst.sg:HasStateTag("struggle"))
			end
		end
	end),
    EventHandler("doattack", function(inst, data)
		if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
			ChooseAttack(inst, data ~= nil and data.target or nil)
        end
    end),

	--Mutated
	EventHandler("doicegrow", function(inst)
		if not (inst.sg:HasStateTag("icegrow") or inst.components.health:IsDead()) then
			if inst.sg:HasStateTag("busy") then
				inst.sg.mem.doicegrow = true
			else
				TryIceGrow(inst)
			end
		end
	end),
	EventHandler("onignite", function(inst)
		if inst.sg.mem.noice == 1 and not inst.sg.mem.noeyeice and inst.components.burnable:IsBurning() and
			not (inst.sg:HasStateTag("staggered") or inst.components.health:IsDead())
		then
			if inst.sg:HasStateTag("busy") and not inst.sg:HasStateTag("caninterrupt") then
				inst.sg.mem.dostagger = true
			else
				TryStagger(inst)
			end
		end
	end),
}

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
        tags = { "idle", "canrotate" },

        onenter = function(inst, pushanim)
			if (inst.sg.mem.doicegrow and TryIceGrow(inst)) or
				(inst.sg.mem.dostagger and TryStagger(inst)) then
				return
			end

            inst.components.locomotor:StopMoving()
            if pushanim then
				inst.AnimState:PushAnimation("idle_loop")
			else
                inst.AnimState:PlayAnimation("idle_loop", true)
            end
        end,

		onexit = function(inst)
			inst:SwitchToFourFaced()
		end,
    },

	State{
		name = "walk_start",
		tags = { "moving", "canrotate" },

		onenter = function(inst)
			inst.components.locomotor:WalkForward()
			inst.AnimState:PlayAnimation("walk_pre")
		end,

		timeline =
		{
			FrameEvent(7, function(inst)
				if (inst.sg.statemem.doicegrow and TryIceGrow(inst)) or
					(inst.sg.statemem.doattack ~= nil and ChooseAttack(inst, inst.sg.statemem.doattack)) then
					return
				end
				inst.sg.statemem.doicegrow = nil
				inst.sg.statemem.doattack = nil
				inst.sg.statemem.canact = true
				DeerclopsFootstep(inst, true)
			end),
		},

		events =
		{
			EventHandler("doattack", function(inst, data)
				if inst.sg.mem.circle ~= nil then
					if inst.sg.statemem.canact then
						ChooseAttack(inst, data ~= nil and data.target or nil)
					else
						inst.sg.statemem.doattack = data ~= nil and data.target or nil
					end
					return true
				end
			end),
			EventHandler("doicegrow", function(inst)
				if inst.sg.statemem.canact then
					TryIceGrow(inst)
				else
					inst.sg.statemem.doicegrow = true
				end
				return true
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.walking = true
					inst.sg:GoToState("walk")
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.walking then
				DeerclopsFootstep(inst, false)
			end
		end,
	},

	State{
		name = "walk",
		tags = { "moving", "canrotate" },

		onenter = function(inst)
			inst.components.locomotor:WalkForward()
			inst.AnimState:PlayAnimation("walk_loop", true)
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
			inst.sg.statemem.canact = true
			if inst.sounds.walk ~= nil then
				inst.SoundEmitter:PlaySound(inst.sounds.walk)
			end
		end,

		timeline =
		{
			FrameEvent(1, function(inst)
				inst.sg.statemem.canact = false
			end),
			FrameEvent(23, function(inst)
				if (inst.sg.statemem.doicegrow and TryIceGrow(inst)) or
					(inst.sg.statemem.doattack ~= nil and ChooseAttack(inst, inst.sg.statemem.doattack)) then
					return
				end
				inst.sg.statemem.doicegrow = nil
				inst.sg.statemem.doattack = nil
				inst.sg.statemem.canact = true
				DeerclopsFootstep(inst, true)
			end),
			FrameEvent(25, function(inst)
				inst.sg.statemem.canact = false
			end),
			--
			FrameEvent(47, function(inst)
				if (inst.sg.statemem.doicegrow and TryIceGrow(inst)) or
					(inst.sg.statemem.doattack ~= nil and ChooseAttack(inst, inst.sg.statemem.doattack)) then
					return
				end
				inst.sg.statemem.doicegrow = nil
				inst.sg.statemem.doattack = nil
				inst.sg.statemem.canact = true
				DeerclopsFootstep(inst, true)
			end),
		},

		ontimeout = function(inst)
			inst.sg.statemem.walking = true
			inst.sg:GoToState("walk")
		end,

		events =
		{
			EventHandler("doattack", function(inst, data)
				if inst.sg.mem.circle ~= nil then
					if inst.sg.statemem.canact then
						ChooseAttack(inst, data ~= nil and data.target or nil)
					else
						inst.sg.statemem.doattack = data ~= nil and data.target or nil
					end
					return true
				end
			end),
			EventHandler("doicegrow", function(inst)
				if inst.sg.statemem.canact then
					TryIceGrow(inst)
				else
					inst.sg.statemem.doicegrow = true
				end
				return true
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.walking then
				DeerclopsFootstep(inst, false)
			end
		end,
    },

	State{
		name = "walk_stop",
		tags = { "canrotate" },

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("walk_pst")
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
	},

	--unused?
    State{
        name = "gohome",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst:ClearBufferedAction()
            inst.components.knownlocations:RememberLocation("home", nil)
        end,

        timeline =
        {
			FrameEvent(5, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.taunt_grrr) end),
			FrameEvent(16, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.taunt_howl) end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "taunt",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")

            if inst.bufferedaction and inst.bufferedaction.action == ACTIONS.GOHOME then
                inst:PerformBufferedAction()
			else
				inst.components.combat.battlecryenabled = false
            end
        end,

        onupdate = function(inst)
            if inst.sg.statemem.lightval ~= nil then
                inst.sg.statemem.lightval = inst.sg.statemem.lightval * .99
                SetLightValue(inst, inst.sg.statemem.lightval)
            end
        end,

        timeline =
        {
            TimeEvent(2 * FRAMES, function(inst) SetLightColour(inst, .9) end),
            TimeEvent(3 * FRAMES, function(inst) SetLightColour(inst, .87) end),
            TimeEvent(4 * FRAMES, function(inst) SetLightColour(inst, .845) end),
            TimeEvent(5 * FRAMES, function(inst)
                SetLightColour(inst, .825)
				inst.SoundEmitter:PlaySound(inst.sounds.taunt_grrr)
            end),
            TimeEvent(6 * FRAMES, function(inst) SetLightColour(inst, .81) end),
            TimeEvent(7 * FRAMES, function(inst) SetLightColour(inst, .8) end),
            TimeEvent(13 * FRAMES, function(inst)
                inst.sg.statemem.lightval = 1
            end),
            TimeEvent(16 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound(inst.sounds.taunt_howl)
            end),
            TimeEvent(24 * FRAMES, function(inst)
                inst.sg.statemem.lightval = nil
            end),
            TimeEvent(41 * FRAMES, function(inst)
                SetLightValue(inst, .98)
                SetLightColour(inst, .95)
            end),
            TimeEvent(42 * FRAMES, function(inst)
                SetLightValue(inst, 1)
                SetLightColour(inst, 1)
            end),
			FrameEvent(43, function(inst)
				if inst.sg.mem.dostagger and TryStagger(inst) then
					return
				end
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(46, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },

        onexit = function(inst)
            SetLightValue(inst, 1)
            SetLightColour(inst, 1)
        end,
    },

	State{
		name = "hit",
		tags = { "hit", "busy" },

		onenter = function(inst, ignorestagger)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("hit")
			inst.SoundEmitter:PlaySound(inst.sounds.hurt)
			CommonHandlers.UpdateHitRecoveryDelay(inst)
			inst.sg.statemem.ignorestagger = ignorestagger
		end,

		timeline =
		{
			FrameEvent(8, function(inst)
				if (inst.sg.mem.dostagger and not inst.sg.statemem.ignorestagger) or
					(inst.sg.statemem.doicegrow and TryIceGrow(inst)) then
					return
				end
				inst.sg.statemem.doicegrow = nil
				inst.sg.statemem.canicegrow = true
			end),
			FrameEvent(10, function(inst)
				if (inst.sg.mem.dostagger and not inst.sg.statemem.ignorestagger and TryStagger(inst)) or
					(inst.sg.statemem.doattack ~= nil and ChooseAttack(inst, inst.sg.statemem.doattack)) then
					return
				end
				inst.sg.statemem.doattack = nil
				inst.sg:RemoveStateTag("busy")
			end),
		},

		events =
		{
			EventHandler("doattack", function(inst, data)
				if not inst.sg.mem.dostagger or inst.sg.statemem.ignorestagger then
					if not inst.sg:HasStateTag("busy") then
						ChooseAttack(inst, data ~= nil and data.target or nil)
					else
						inst.sg.statemem.doattack = data ~= nil and data.target or nil
					end
				end
				return true
			end),
			EventHandler("doicegrow", function(inst)
				if not inst.sg.mem.dostagger or inst.sg.statemem.ignorestagger then
					if inst.sg.statemem.canicegrow then
						TryIceGrow(inst)
					else
						inst.sg.statemem.doicegrow = true
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
		name = "death",
		tags = { "dead", "busy", "noattack" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("death")
			inst.SoundEmitter:PlaySound(inst.sounds.death)
			inst.components.lootdropper:DropLoot(inst:GetPosition())
			inst.looted = 1
			if inst.components.burnable.nocharring then
				inst.components.burnable.fastextinguish = true
				inst.components.burnable:SetBurnTime(0)
			end
		end,

		timeline =
		{
			FrameEvent(3, function(inst) SetLightValue(inst, 1.01) end),
			FrameEvent(4, function(inst) SetLightValue(inst, 1.025) end),
			FrameEvent(5, function(inst) SetLightValue(inst, 1.045) end),
			FrameEvent(6, function(inst) SetLightValue(inst, 1.07) end),
			FrameEvent(32, function(inst)
				if inst.yule then
					local player--[[, rangesq]] = inst:GetNearestPlayer()
					LaunchAt(SpawnPrefab("winter_ornament_light1"), inst, player, 1, 6, .5)
					inst.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")
					inst.looted = 2
				end
			end),
			FrameEvent(33, function(inst)
				SetLightValue(inst, 1.05)
				SetLightColour(inst, .95)
			end),
			FrameEvent(34, function(inst)
				SetLightValue(inst, 1.01)
				SetLightColour(inst, .85)
			end),
			FrameEvent(35, function(inst)
				SetLightValue(inst, 1)
				SetLightColour(inst, .75)
			end),
			FrameEvent(36, function(inst)
				SetLightColour(inst, .7)
			end),
			FrameEvent(48, function(inst)
				if inst.Light ~= nil then
					local k = 1
					local task
					task = inst:DoPeriodicTask(0, function(inst)
						k = k - .025
						if k > 0 then
							SetLightValue(inst, k)
						else
							inst.Light:Enable(false)
							task:Cancel()
						end
					end)
				end
			end),
			FrameEvent(48, function(inst)
				if inst.components.burnable.nocharring then
					inst.components.burnable:Extinguish()
				end
				if TheWorld.state.snowlevel > 0.02 then
					inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/bodyfall_snow")
				else
					inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/bodyfall_dirt")
				end
				ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, 2, inst, SHAKE_DIST)
				if inst.sg.mem.circle ~= nil then
					inst.sg.mem.circle:KillFX(true)
					inst.sg.mem.circle = nil
				end
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("corpse")
				end
			end),
		},

		onexit = function(inst)
			if inst.sg.mem.circle ~= nil then
				inst.sg.mem.circle:KillFX(true)
				inst.sg.mem.circle = nil
			end
		end,
	},

	State{
		name = "corpse",
		tags = { "dead", "busy", "noattack" },

		onenter = function(inst, loading)
			if inst.components.burnable.nocharring then
				inst.components.burnable.fastextinguish = true
				inst.components.burnable:SetBurnTime(0)
				inst.components.burnable:Extinguish()
			end
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("corpse")
			if loading and inst.yule and inst.looted ~= 2 then
				inst.components.lootdropper:SpawnLootPrefab("winter_ornament_light1")
				inst.looted = 2
			end
		end,

		timeline =
		{
			--delay 1 frame in case we are loading
			FrameEvent(1, function(inst)
				local corpse = not inst:HasTag("lunar_aligned") and TheWorld.components.lunarriftmutationsmanager ~= nil and TheWorld.components.lunarriftmutationsmanager:TryMutate(inst, "deerclopscorpse") or nil
				if corpse == nil then
					inst:AddTag("NOCLICK")
					inst.persists = false
					RemovePhysicsColliders(inst)

					--68 + 1 frames since death anim started
					local delay = (inst.components.health.destroytime or 2) - 69 * FRAMES
					if delay > 0 then
						inst.sg:SetTimeout(delay)
					else
						ErodeAway(inst)
						if inst.components.burnable:IsBurning() then
							inst.components.burnable.fastextinguish = true
							inst.components.burnable:KillFX()
						end
					end
				elseif inst.yule then
					corpse:SetAltBuild("yule")
				end
			end),
		},

		ontimeout = function(inst)
			ErodeAway(inst)
			if inst.components.burnable:IsBurning() then
				inst.components.burnable.fastextinguish = true
				inst.components.burnable:KillFX()
			end
		end,
	},

	--------------------------------------------------------------------------
	--Used by "deerclopscorpse"

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
			inst.sg:GoToState("corpse_mutate", inst.sg.statemem.mutantprefab)
		end,

		onexit = function(inst)
			inst.SoundEmitter:KillSound("loop")
		end,
	},

	State{
		name = "corpse_mutate",
		tags = { "mutating" },

		onenter = function(inst, mutantprefab)
			inst.AnimState:OverrideSymbol("eye_crystal", "deerclops_mutated", "eye_crystal")
			inst.AnimState:OverrideSymbol("frozen_debris", "deerclops_mutated", "frozen_debris")
			inst.AnimState:PlayAnimation("mutate_pre")
			inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_crackling_LP", "loop")
			inst.sg.statemem.mutantprefab = mutantprefab
		end,

		timeline =
		{
			FrameEvent(0, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/mutate_pre_f0") end),
			FrameEvent(6, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_grow_4f_leadin") end),
			FrameEvent(10, function(inst)
				inst.components.burnable.fastextinguish = true
				inst.components.burnable:Extinguish()
				inst.components.burnable.fastextinguish = false
			end),
			FrameEvent(45, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/mutate_pre_f45") end),
			FrameEvent(46, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_grow_4f_leadin") end),
			FrameEvent(50, function(inst)
				inst.components.burnable.fastextinguish = true
				inst.components.burnable:Extinguish()
				inst.components.burnable.fastextinguish = false
			end),
			FrameEvent(61, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_grow_4f_leadin") end),
			FrameEvent(65, function(inst)
				inst.components.burnable.fastextinguish = true
				inst.components.burnable:Extinguish()
				inst.components.burnable.fastextinguish = false
			end),
			FrameEvent(66, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_grow_4f_leadin") end),
			FrameEvent(70, function(inst)
				inst.SoundEmitter:KillSound("loop")
				inst.components.burnable.fastextinguish = true
				inst.components.burnable:Extinguish()
				inst.components.burnable.fastextinguish = false
			end),
			FrameEvent(71, function(inst)
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
			inst.components.burnable:SetBurnTime(TUNING.MED_BURNTIME)
			inst.components.burnable.fastextinguish = false
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

		timeline =
		{
			FrameEvent(16, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/stunned_pst_f70") end),
			FrameEvent(20, function(inst)
				DeerclopsFootstep(inst, false, true)
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("taunt")
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
			StartAttackCooldown(inst)
			if target ~= nil and target:IsValid() then
				inst:ForceFacePoint(target.Transform:GetWorldPosition())
				inst.sg.statemem.target = target
			end
			inst.sg.statemem.original_target = target --remember for onmissother event
		end,

		onupdate = function(inst)
			if inst.sg.statemem.target ~= nil then
				if inst.sg.statemem.target:IsValid() then
					local rot = inst.Transform:GetRotation()
					local rot1 = inst:GetAngleToPoint(inst.sg.statemem.target.Transform:GetWorldPosition())
					if DiffAngle(rot, rot1) < 45 then
						inst.Transform:SetRotation(rot1)
						return
					end
				end
				inst.sg.statemem.target = nil
			end
		end,

		timeline =
		{
			FrameEvent(16, function(inst)
				inst.sg.statemem.target = nil
			end),
			FrameEvent(31, function(inst)
				SpawnIceFx(inst, inst.sg.statemem.original_target)
			end),
			FrameEvent(34, function(inst)
				inst.SoundEmitter:PlaySound(inst.sounds.swipe)
				-- THE ATTACK DAMAGE COMES FROM THE DEERCLOPS SMALL ICE SPICE FX NOW.
				--inst.components.combat:DoAttack(inst.sg.statemem.target)
				if inst.bufferedaction ~= nil and inst.bufferedaction.action == ACTIONS.HAMMER then
					local target = inst.bufferedaction.target
					inst:ClearBufferedAction()
					if target ~= nil and
						target:IsValid() and
						target.components.workable ~= nil and
						target.components.workable:CanBeWorked() and
						target.components.workable:GetWorkAction() == ACTIONS.HAMMER
					then
						target.components.workable:Destroy(inst)
					end
				end
				ShakeAllCameras(CAMERASHAKE.FULL, .5, .025, 1.25, inst, SHAKE_DIST)
			end),
			FrameEvent(35, function(inst) inst.sg:RemoveStateTag("attack") end),
			FrameEvent(51, function(inst)
				if inst.sg.mem.dostagger and TryStagger(inst) then
					return
				end
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(56, function(inst) inst.sg:RemoveStateTag("busy") end),
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

	--yule
    State{
        name = "laserbeam",
        tags = { "busy" },

        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk2")
			inst:SwitchToEightFaced()
			StartAttackCooldown(inst)
            if target ~= nil and target:IsValid() then
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
                inst.sg.statemem.target = target
            end
            inst.SoundEmitter:PlaySound(inst.sounds.charge)
            inst.components.timer:StopTimer("laserbeam_cd")
            inst.components.timer:StartTimer("laserbeam_cd", TUNING.DEERCLOPS_ATTACK_PERIOD * (math.random(3) - .5))
        end,

        onupdate = function(inst)
            if inst.sg.statemem.target ~= nil then
                if inst.sg.statemem.target:IsValid() then
                    local x, y, z = inst.Transform:GetWorldPosition()
                    local x1, y1, z1 = inst.sg.statemem.target.Transform:GetWorldPosition()
                    local dx, dz = x1 - x, z1 - z
                    if dx * dx + dz * dz < 256 and math.abs(anglediff(inst.Transform:GetRotation(), math.atan2(-dz, dx) / DEGREES)) < 45 then
                        inst:ForceFacePoint(x1, y1, z1)
                        return
                    end
                end
                inst.sg.statemem.target = nil
            end
            if inst.sg.statemem.lightval ~= nil then
                inst.sg.statemem.lightval = inst.sg.statemem.lightval * .99
                SetLightValueAndOverride(inst, inst.sg.statemem.lightval, (inst.sg.statemem.lightval - 1) * 3)
            end
        end,

        timeline =
        {
			TimeEvent(FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.attack, nil) end),
			TimeEvent(4 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.step, nil, .7) end),
            TimeEvent(6 * FRAMES, function(inst)
                ShakeAllCameras(CAMERASHAKE.VERTICAL, .2, .02, .5, inst, SHAKE_DIST)
                SetLightValue(inst, .97)
            end),
            TimeEvent(7 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1, .2) end),
            TimeEvent(8 * FRAMES, function(inst) SetLightValueAndOverride(inst, .99, .15) end),
            TimeEvent(9 * FRAMES, function(inst) SetLightValueAndOverride(inst, .97, .05) end),
            TimeEvent(10 * FRAMES, function(inst) SetLightValueAndOverride(inst, .96, 0) end),
            TimeEvent(11 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1.01, .35) end),
            TimeEvent(12 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1, .3) end),
            TimeEvent(13 * FRAMES, function(inst) SetLightValueAndOverride(inst, .95, .05) end),
            TimeEvent(14 * FRAMES, function(inst) SetLightValueAndOverride(inst, .94, 0) end),
            TimeEvent(15 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1, .3) end),
            TimeEvent(16 * FRAMES, function(inst) SetLightValueAndOverride(inst, .99, .25) end),
            TimeEvent(17 * FRAMES, function(inst) SetLightValueAndOverride(inst, .92, .05) end),
            TimeEvent(18 * FRAMES, function(inst)
                SetLightValueAndOverride(inst, .9, 0)
                inst.sg.statemem.target = nil
				inst.SoundEmitter:PlaySound(inst.sounds.taunt_howl, nil, .4)
            end),
            TimeEvent(19 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/laser")
                SpawnLaser(inst)
                SetLightValueAndOverride(inst, 1.08, .7)
            end),
            TimeEvent(20 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1.12, 1) end),
            TimeEvent(21 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1.1, .9) end),
            TimeEvent(22 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1.06, .4) end),
            TimeEvent(23 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1.1, .6) end),
            TimeEvent(24 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1.06, .3) end),
            TimeEvent(25 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1.05, .25) end),
            TimeEvent(26 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1.1, .5) end),
            TimeEvent(27 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1.08, .45) end),
            TimeEvent(28 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1.05, .2) end),
            TimeEvent(29 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1.1, .3) end),
            TimeEvent(30 * FRAMES, function(inst)
                inst.sg.statemem.lightval = 1.1
            end),
            TimeEvent(32 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound(inst.sounds.taunt_grrr, nil, .5)
                inst.sg.statemem.lightval = 1.035
                SetLightColour(inst, .9)
            end),
            TimeEvent(33 * FRAMES, function(inst) SetLightColour(inst, .8) end),
			TimeEvent(41 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.step, nil, .7) end),
            TimeEvent(43 * FRAMES, function(inst)
                ShakeAllCameras(CAMERASHAKE.VERTICAL, .3, .02, .7, inst, SHAKE_DIST)
            end),
            TimeEvent(47 * FRAMES, function(inst)
                inst.sg.statemem.lightval = nil
                SetLightValueAndOverride(inst, .9, 0)
                SetLightColour(inst, .9)
            end),
            TimeEvent(48 * FRAMES, function(inst)
				if inst.sg.mem.dostagger and TryStagger(inst) then
					return
				end
                inst.sg:RemoveStateTag("busy")
                SetLightValue(inst, 1)
                SetLightColour(inst, 1)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg.statemem.keepfacing = true
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            SetLightValueAndOverride(inst, 1, 0)
            SetLightColour(inst, 1)
            if not inst.sg.statemem.keepfacing then
				inst:SwitchToFourFaced()
            end
        end,
    },

	--mutated
	State{
		name = "icelance",
		tags = { "attack", "busy" },

		onenter = function(inst, target)
			inst.components.locomotor:Stop()
			inst:SwitchToEightFaced()
			if inst.sg.mem.noice == nil then
				inst.AnimState:PlayAnimation("throw")
			else
				if inst.sg.mem.noice == 1 then
					inst.sg.mem.noice = 0
					inst.AnimState:Show("ice_1")
				end
				inst.AnimState:PlayAnimation("throw_2")
			end
			StartAttackCooldown(inst)
			if target ~= nil and target:IsValid() then
				inst.sg.statemem.target = target
				inst.sg.statemem.targetpos = target:GetPosition()
				inst:ForceFacePoint(inst.sg.statemem.targetpos)
			end
			inst.sg.statemem.original_target = target --remember for onmissother event
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
						inst.Transform:SetRotation(rot1)
					end
				else
					inst.sg.statemem.target = nil
				end
			end
		end,

		timeline =
		{
			FrameEvent(8, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_throw_f13") end),
			FrameEvent(30, function(inst)
				inst.sg.statemem.target = nil

				local range = TUNING.MUTATED_DEERCLOPS_ICELANCE_RANGE
				local p = inst.sg.statemem.targetpos
				local x, y, z = inst.Transform:GetWorldPosition()
				local rot = inst.Transform:GetRotation() * DEGREES
				local dist
				if p ~= nil then
					local dx = p.x - x
					local dz = p.z - z
					if dx ~= 0 or dz ~= 0 then
						local rot1 = math.atan2(-dz, dx)
						local diff = DiffAngleRad(rot, rot1)
						if diff * RADIANS < 90 then
							dist = math.sqrt(dx * dx + dz * dz) * math.cos(diff)
							dist = math.clamp(dist, range.min, range.max)
						else
							dist = range.min
						end
					else
						dist = range.min
					end
					p.y = 0
				else
					dist = (range.min + range.max) * 0.5
					p = Vector3(0, 0, 0)
					inst.sg.statemem.targetpos = p
				end
				p.x = x + math.cos(rot) * dist
				p.z = z - math.sin(rot) * dist

				inst.sg.statemem.ping = SpawnPrefab("deerclops_icelance_ping_fx")
				inst.sg.statemem.ping.Transform:SetPosition(p:Get())
			end),
			FrameEvent(34, function(inst)
				inst.components.burnable:Extinguish()
				inst.sg.mem.noice = inst.sg.mem.noice == nil and 0 or 1
			end),
			FrameEvent(47, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_throw_f47") end),
			FrameEvent(56, function(inst)
				DeerclopsFootstep(inst, false, true)
			end),
			FrameEvent(60, function(inst)
				inst.SoundEmitter:PlaySound(inst.sounds.attack)
				inst.sg.statemem.ping:KillFX()
				inst.sg.statemem.ping = nil

				local lance = SpawnPrefab("deerclops_impact_circle_fx")
				lance.Transform:SetPosition(inst.sg.statemem.targetpos:Get())
				inst.sg.statemem.targets = {}
				inst.sg.statemem.freezepower = 99
				inst.components.combat:SetDefaultDamage(TUNING.MUTATED_DEERCLOPS_ICELANCE_DAMAGE)
				DoIceLanceAOE(inst, inst.sg.statemem.targetpos, inst.sg.statemem.targets)
			end),
			FrameEvent(61, function(inst)
				DoIceLanceAOE(inst, inst.sg.statemem.targetpos, inst.sg.statemem.targets)
			end),
			FrameEvent(62, function(inst)
				DoIceLanceAOE(inst, inst.sg.statemem.targetpos, inst.sg.statemem.targets)
				if next(inst.sg.statemem.targets) == nil then
					inst:PushEvent("onmissother", { target = inst.sg.statemem.original_target }) --for ChaseAndAttack
				end
			end),
			FrameEvent(72, function(inst)
				if inst.sg.mem.dostagger and TryStagger(inst) then
					return
				end
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(76, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.keepfacing = true
					inst.sg:GoToState("idle")
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.keepfacing then
				inst:SwitchToFourFaced()
			end
			if inst.sg.mem.noice == 0 then
				inst.AnimState:Hide("ice_0")
			elseif inst.sg.mem.noice == 1 then
				inst.AnimState:Hide("ice_1")
				inst.components.combat:SetRange(TUNING.DEERCLOPS_ATTACK_RANGE)
			end
			if inst.sg.statemem.ping ~= nil then
				inst.sg.statemem.ping:KillFX()
			end
			inst.components.combat:SetDefaultDamage(TUNING.MUTATED_DEERCLOPS_DAMAGE)
		end,
	},

	State{
		name = "icegrow",
		tags = { "icegrow", "busy" },

		onenter = function(inst)
			inst.sg.mem.doicegrow = nil
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("ice_grow")
			local growice
			if inst.sg.mem.noice == nil then
				inst.AnimState:Hide("grow_ice_0")
				inst.AnimState:Hide("grow_ice_1")
			else
				inst.AnimState:Show("grow_ice_0")
				if inst.sg.mem.noice == 1 then
					inst.AnimState:Show("grow_ice_1")
				else
					inst.AnimState:Hide("grow_ice_1")
				end
				growice = true
			end
			if inst.sg.mem.noeyeice and not (inst.hasfrenzy and inst:ShouldStayFrenzied()) then
				inst.sg.statemem.groweyeice = true
				growice = true
			end
			if growice then
				inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_crackling_LP", "loop")
			end
			inst.sg.statemem.burninterrupt = true
		end,

		timeline =
		{
			FrameEvent(7, function(inst)
				DeerclopsFootstep(inst, false, true)
			end),
			FrameEvent(9, function(inst)
				inst.sg.statemem.burninterrupt = nil
				inst.components.burnable:Extinguish()
				inst.components.burnable:SetBurnTime(0)
				if inst.hasiceaura and inst.sg.mem.circle == nil and (not inst.frenzied or inst.sg.statemem.groweyeice) and inst.components.combat:HasTarget() then
					inst.sg.mem.circle = SpawnPrefab("deerclops_aura_circle_fx")
					local x, y, z = inst.Transform:GetWorldPosition()
					inst.sg.mem.circle.Transform:SetPosition(x, 0, z)
					inst.sg.mem.circle:GrowFX()
					inst.sg.statemem.newcircle = true
				end
				inst.sg.mem.dostagger = nil
			end),
			FrameEvent(5, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.taunt_grrr) end),
			FrameEvent(6, function(inst)
				if inst.sg.mem.noice == 1 then
					inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_grow_4f_leadin")
				end
			end),
			FrameEvent(10, function(inst)
				if inst.sg.mem.noice == 1 then
					inst.sg.mem.noice = 0
				end
			end),
			FrameEvent(9, function(inst)
				if inst.sg.mem.noice == 0 then
					inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_grow_4f_leadin")
				end
			end),
			FrameEvent(13, function(inst)
				if inst.sg.mem.noice == 0 then
					inst.sg.mem.noice = nil
					if not inst.sg.statemem.groweyeice then
						inst.SoundEmitter:KillSound("loop")
					end
				end
			end),
			FrameEvent(35, function(inst)
				if inst.sg.statemem.groweyeice then
					inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_grow_4f_leadin")
				end
			end),
		},

		events =
		{
			EventHandler("onignite", function(inst)
				if inst.sg.statemem.burninterrupt and inst.sg.mem.noice == 1 and not inst.sg.mem.noeyeice and inst.components.burnable:IsBurning() then
					inst.sg:GoToState("hit")
					--don't return true, let stategraph "onignite" handler manage stagger
				end
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.sg.statemem.newcircle or inst.sg.statemem.groweyeice then
						inst.sg.statemem.icegrow = true
						inst.sg:GoToState("icegrow2")
					else
						inst.sg:GoToState("icegrow_pst")
					end
				end
			end),
		},

		onexit = function(inst)
			if inst.sg.mem.noice ~= 1 then
				inst.AnimState:Show("ice_1")
				if inst.sg.mem.noice ~= 0 then
					inst.AnimState:Show("ice_0")
				end
				inst.components.combat:SetRange(TUNING.MUTATED_DEERCLOPS_ATTACK_RANGE)
			end
			if not inst.sg.statemem.icegrow then
				inst.SoundEmitter:KillSound("loop")
				inst.components.burnable:SetBurnTime(10)
			end
		end,
	},

	State{
		name = "icegrow2",
		tags = { "busy" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("ice_grow_2")
			inst.SoundEmitter:PlaySound(inst.sounds.taunt_howl)
			if not inst.SoundEmitter:PlayingSound("loop") then
				inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_crackling_LP", "loop")
			end
			if inst.sg.mem.noeyeice then
				inst.AnimState:Show("grow_ice_2")
				inst.AnimState:Hide("gestalt_eye")
			else
				inst.AnimState:Hide("grow_ice_2")
			end
		end,

		timeline =
		{
			FrameEvent(3, function(inst)
				inst.sg.mem.noeyeice = nil
				StopFrenzy(inst)
			end),
			FrameEvent(8, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_grow_4f_leadin", nil, 0.5) end),
			FrameEvent(17, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_grow_4f_leadin", nil, 0.6) end),
			FrameEvent(21, function(inst)
				inst.SoundEmitter:KillSound("loop")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("icegrow_pst")
				end
			end),
		},

		onexit = function(inst)
			if inst.sg.mem.noeyeice then
				inst.AnimState:Show("gestalt_eye")
			else
				inst.AnimState:Show("ice_2")
			end
			inst.components.burnable:SetBurnTime(10)
			inst.SoundEmitter:KillSound("loop")
		end,
	},

	State{
		name = "icegrow_pst",
		tags = { "busy" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("ice_grow_pst")
		end,

		timeline =
		{
			FrameEvent(12, function(inst)
				if inst.sg.mem.dostagger and TryStagger(inst) then
					return
				end
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(14, function(inst)
				inst.sg:GoToState("idle", true)
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

	State{
		name = "struggle_pre",
		tags = { "struggle", "busy" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("struggle_pre")
			inst.SoundEmitter:PlaySound(inst.sounds.hurt)
			if inst.sg.mem.noice ~= 1 then
				inst.sg.mem.noice = 1
				inst.AnimState:Hide("ice_0")
				inst.AnimState:Hide("ice_1")
			end
		end,

		timeline =
		{
			FrameEvent(14, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.attack, nil, 0.5) end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState(inst.components.burnable:IsBurning() and "struggle_loop" or "struggle_pst")
				end
			end),
		},
	},

	State{
		name = "struggle_loop",
		tags = { "struggle", "busy" },

		onenter = function(inst, loops)
			inst.components.locomotor:Stop()
			if not inst.AnimState:IsCurrentAnimation("struggle_loop") then
				inst.AnimState:PlayAnimation("struggle_loop", true)
			end
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
			inst.sg.statemem.loops = (loops or 0) + 1
			if inst.sg.mem.noice ~= 1 then
				inst.sg.mem.noice = 1
				inst.AnimState:Hide("ice_0")
				inst.AnimState:Hide("ice_1")
			end
		end,

		timeline =
		{
			FrameEvent(0, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.hurt) end),
			FrameEvent(10, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.attack, nil, 0.5) end),
		},

		ontimeout = function(inst)
			if not inst.components.burnable:IsBurning() then
				inst.sg:GoToState("struggle_pst")
			elseif inst.sg.statemem.loops >= 2 then
				inst.sg:GoToState("stagger_pre")
			else
				inst.sg:GoToState("struggle_loop", inst.sg.statemem.loops)
			end
		end,
	},

	State{
		name = "struggle_pst",
		tags = { "struggle", "busy" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("struggle_pst")
			inst.components.burnable:Extinguish()
			inst.SoundEmitter:PlaySound(inst.sounds.hurt)
			if inst.sg.mem.noice ~= 1 then
				inst.sg.mem.noice = 1
				inst.AnimState:Hide("ice_0")
				inst.AnimState:Hide("ice_1")
			end
		end,

		timeline =
		{
			FrameEvent(7, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.taunt_grrr, nil, .6) end),
			FrameEvent(21, function(inst)
				if inst.sg.statemem.doattack == nil then
					if inst.sg.mem.dostagger and TryStagger(inst) then
						return
					end
					inst.sg:AddStateTag("caninterrupt")
				end
			end),
		},

		events =
		{
			EventHandler("doattack", function(inst, data)
				inst.sg.statemem.doattack = data ~= nil and data.target or nil
				inst.sg:RemoveStateTag("caninterrupt")
				return true
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.sg.statemem.doattack ~= nil and ChooseAttack(inst, inst.sg.statemem.doattack) then
						return
					end
					inst.sg:GoToState("idle")
				end
			end),
		},
	},

	--------------------------------------------------------------------------

	State{
		name = "stagger_pre",
		tags = { "staggered", "busy", "nosleep" },

		onenter = function(inst)
			inst.sg.mem.dostagger = nil
			inst.sg.mem.doicegrow = nil
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("stagger_pre")
			inst.components.timer:StopTimer("stagger")
			inst.components.timer:StartTimer("stagger", TUNING.MUTATED_DEERCLOPS_STAGGER_TIME)
			if inst.components.burnable:IsBurning() then
				inst.components.burnable:SetBurnTime(8 * FRAMES)
				inst.components.burnable:ExtendBurning()
			end
			if inst.sg.mem.noice ~= 1 then
				inst.sg.mem.noice = 1
				inst.AnimState:Hide("ice_0")
				inst.AnimState:Hide("ice_1")
			end
		end,

		timeline =
		{
			FrameEvent(3, function(inst)
				if not inst.sg.mem.noeyeice then
					inst.sg.statemem.shatter = true
					inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/stunned_pre_break_f13")
				end
			end),
			FrameEvent(8, function(inst)
				inst.components.burnable:Extinguish()
				inst.components.burnable:SetBurnTime(10)
				inst.sg.mem.noeyeice = true
			end),
			FrameEvent(24, function(inst)
				DeerclopsFootstep(inst, false, true)
			end),
			FrameEvent(26, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/iceboulder_smash", nil, .5) end),
			FrameEvent(27, function(inst)
				if inst.sg.mem.circle ~= nil then
					inst.sg.mem.circle:KillFX(true)
					inst.sg.mem.circle = nil
				end
			end),
			FrameEvent(44, function(inst)
				if TheWorld.state.snowlevel > 0.02 then
					inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/bodyfall_snow")
				else
					inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/bodyfall_dirt")
				end
				ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, 2, inst, SHAKE_DIST)
			end),
			FrameEvent(46, function(inst)
				inst.sg:AddStateTag("caninterrupt")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.staggered = true
					inst.sg:GoToState(inst.components.timer:TimerExists("stagger") and "stagger_idle" or "stagger_pst")
				end
			end),
		},

		onexit = function(inst)
			if inst.sg.mem.noeyeice then
				inst.AnimState:Hide("ice_2")
				inst.AnimState:Show("gestalt_eye")
			end
			inst.components.burnable:SetBurnTime(10)
		end,
	},

	State{
		name = "stagger_idle",
		tags = { "staggered", "busy", "caninterrupt", "nosleep" },

		onenter = function(inst)
			if not inst.components.timer:TimerExists("stagger") then
				inst.sg.statemem.staggered = true
				inst.sg:GoToState("stagger_pst")
				return
			end
			inst.AnimState:PlayAnimation("stagger", true)
			if inst.sg.mem.noice ~= 1 then
				inst.sg.mem.noice = 1
				inst.AnimState:Hide("ice_0")
				inst.AnimState:Hide("ice_1")
			end
			if not inst.sg.mem.noeyeice then
				inst.sg.mem.noeyeice = true
				inst.AnimState:Hide("ice_2")
				inst.AnimState:Show("gestalt_eye")
			end
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
		end,

		events =
		{
			EventHandler("timerdone", function(inst, data)
				if data ~= nil and data.name == "stagger" then
					inst.sg.statemem.staggered = true
					inst.sg:GoToState("stagger_pst", true)
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
			if inst.sg.mem.noice ~= 1 then
				inst.sg.mem.noice = 1
				inst.AnimState:Hide("ice_0")
				inst.AnimState:Hide("ice_1")
			end
			if not inst.sg.mem.noeyeice then
				inst.sg.mem.noeyeice = true
				inst.AnimState:Hide("ice_2")
				inst.AnimState:Show("gestalt_eye")
			end
		end,

		timeline =
		{
			FrameEvent(8, function(inst)
				if inst.components.timer:TimerExists("stagger") then
					inst.sg:AddStateTag("caninterrupt")
				end
			end),
			FrameEvent(21, function(inst)
				if not inst.components.timer:TimerExists("stagger") then
					inst.sg.statemem.staggered = true
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
					inst.sg.statemem.staggered = true
					inst.sg:GoToState("stagger_pst", true)
				end
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.staggered = true
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
			inst.AnimState:Show("ice_0")
			inst.AnimState:Show("ice_1")
			inst.sg.statemem.groweyeice = false --hard-coded toggle
			if inst.sg.statemem.groweyeice then
				inst.AnimState:Show("ice_2")
				inst.AnimState:Hide("gestalt_eye")
			else
				inst.AnimState:Hide("ice_2")
				inst.AnimState:Show("gestalt_eye")
				inst.sg.mem.doicegrow = nil
			end
			inst.sg.mem.noice = 1
			inst.sg.mem.noeyeice = true
			if not nohit then
				inst.sg:AddStateTag("caninterrupt")
			end
			if inst.components.sleeper ~= nil then
				inst.components.sleeper:WakeUp()
			end
			inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/stunned_pst_f0")
		end,

		timeline =
		{
			FrameEvent(33, function(inst)
				inst.sg:RemoveStateTag("staggered")
				inst.sg:RemoveStateTag("caninterrupt")
				inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_crackling_LP", "loop")
			end),
			FrameEvent(51, function(inst)
				if inst.sg.statemem.groweyeice then
					inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_grow_4f_leadin")
				end
			end),
			FrameEvent(55, function(inst)
				if inst.sg.statemem.groweyeice then
					inst.components.burnable:Extinguish()
					inst.components.burnable:SetBurnTime(0)
					inst.sg.mem.noeyeice = nil
				end
			end),
			FrameEvent(52, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_grow_4f_leadin") end),
			FrameEvent(56, function(inst)
				inst.SoundEmitter:KillSound("loop")
				if inst.sg.statemem.groweyeice then
					inst.components.burnable:SetBurnTime(10)
				else
					inst.components.burnable:Extinguish()
				end
				inst.sg.mem.noice = nil
			end),
			FrameEvent(70, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/stunned_pst_f70") end),
			FrameEvent(73, function(inst)
				DeerclopsFootstep(inst, false, true)
			end),
			CommonHandlers.OnNoSleepFrameEvent(92, function(inst)
				if inst.sg.mem.dostagger and TryStagger(inst) then
					return
				end
				inst.sg:RemoveStateTag("nosleep")
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(100, function(inst)
				inst.sg:RemoveStateTag("busy")
				if inst.sg.mem.noeyeice then
					StartFrenzy(inst)
					inst.sg.mem.doicegrow = nil
				end
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
			inst.SoundEmitter:KillSound("loop")
			if inst.sg.mem.noice ~= nil then
				inst.AnimState:Hide("ice_0")
				if inst.sg.mem.noice ~= 0 then
					inst.AnimState:Hide("ice_1")
				end
			end
			if inst.sg.mem.noeyeice then
				inst.AnimState:Hide("ice_2")
				inst.AnimState:Show("gestalt_eye")
				if not inst.sg:HasStateTag("staggered") then
					StartFrenzy(inst)
					inst.sg.mem.doicegrow = nil
				end
			else
				inst.AnimState:Show("ice_2")
				inst.AnimState:Hide("gestalt_eye")
			end
			inst.components.burnable:SetBurnTime(10)
		end,
	},

	--------------------------------------------------------------------------
}

CommonStates.AddSleepExStates(states,
{
    starttimeline =
    {
        TimeEvent(1 * FRAMES, function(inst) SetLightValue(inst, .995) end),
        TimeEvent(2 * FRAMES, function(inst) SetLightValue(inst, .99) end),
        TimeEvent(3 * FRAMES, function(inst) SetLightValue(inst, .98) end),
        TimeEvent(4 * FRAMES, function(inst) SetLightValue(inst, .97) end),
        TimeEvent(5 * FRAMES, function(inst) SetLightValue(inst, .96) end),
        TimeEvent(6 * FRAMES, function(inst) SetLightValue(inst, .95) end),
        TimeEvent(7 * FRAMES, function(inst) SetLightValue(inst, .945) end),
		FrameEvent(36, function(inst)
			inst.sg:RemoveStateTag("caninterrupt")
		end),
        TimeEvent(38 * FRAMES, function(inst) SetLightColour(inst, .95) end),
        TimeEvent(39 * FRAMES, function(inst) SetLightColour(inst, .9) end),
        TimeEvent(40 * FRAMES, function(inst) SetLightColour(inst, .8) end),
        TimeEvent(41 * FRAMES, function(inst) SetLightColour(inst, .75) end),
    },
    --[[sleeptimeline =
    {
        --TimeEvent(46*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.grunt) end)
    },]]
    waketimeline =
    {
        TimeEvent(2 * FRAMES, function(inst) SetLightColour(inst, .9) end),
        TimeEvent(3 * FRAMES, function(inst) SetLightColour(inst, 1) end),
        TimeEvent(36 * FRAMES, function(inst) SetLightValue(inst, .99) end),
        TimeEvent(37 * FRAMES, function(inst) SetLightValue(inst, 1) end),
		CommonHandlers.OnNoSleepFrameEvent(42, function(inst)
			if inst.sg.mem.dostagger and TryStagger(inst) then
				return
			end
			inst.sg:RemoveStateTag("nosleep")
			inst.sg:AddStateTag("caninterrupt")
		end),
		FrameEvent(49, function(inst)
			inst.sg:RemoveStateTag("busy")
		end),
    },
},
{
    onsleep = function(inst)
        SetLightValue(inst, 1)
        SetLightColour(inst, 1)
		inst.sg:AddStateTag("caninterrupt")
		inst.sg.mem.dostagger = nil
    end,
    onwake = function(inst)
        SetLightValue(inst, .945)
        SetLightColour(inst, .75)
    end,
})
CommonStates.AddFrozenStates(states)
CommonStates.AddSinkAndWashAshoreStates(states)

return StateGraph("deerclops", states, events, "init", actionhandlers)
