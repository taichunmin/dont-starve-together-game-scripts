local easing = require("easing")
require("stategraphs/commonstates")

local function ChooseAttack(inst, data)
	if data ~= nil and data.target ~= nil and data.target:IsValid() then
		inst.sg:GoToState("devour", data.target)
		return true
	end
	return false
end

local events =
{
	EventHandler("doattack", function(inst, data)
		if inst.sg:HasStateTag("queueattack") then
			inst.sg.statemem.doattack = data
		elseif not inst.sg:HasStateTag("busy") then
			ChooseAttack(inst, data)
		end
	end),
	EventHandler("attacked", function(inst, data)
		if not (data ~= nil and data.spdamage ~= nil and data.spdamage.planar ~= nil) and
			inst.components.health.currenthealth >= TUNING.LUNAR_GRAZER_MELT_HEALTH_THRESHOLD
			then
			--no reaction when resisting non-planar hits
			return
		elseif not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("caninterrupt") then
			inst.sg:GoToState("hit")
		end
	end),
	EventHandler("minhealth", function(inst)
		if not inst.sg:HasStateTag("debris") then
			inst.sg:GoToState("splat")
		end
	end),
	EventHandler("lunar_grazer_despawn", function(inst, data)
		if inst.sg:HasStateTag("invisible") then
			inst:Remove()
			return
		end
		if data ~= nil and data.force then
			inst.sg.mem.force_despawn = true
		end
		if not inst.sg:HasStateTag("busy") then
			inst.sg:GoToState("melt")
		end
	end),
}

local function PlayFootstepDown(inst)
	inst.SoundEmitter:PlaySound("rifts/grazer/step1")
end

local function PlayFootstepUp(inst)
	inst.SoundEmitter:PlaySound("rifts/grazer/step2_pull")
end

local states =
{
	State{
		name = "idle",
		tags = { "idle", "canrotate" },

		onenter = function(inst)
			if inst.sg.mem.force_despawn then
				inst.sg:GoToState("melt")
				return
			end
			inst.components.locomotor:Stop()
			if not inst.AnimState:IsCurrentAnimation("idle") then
				inst.AnimState:PlayAnimation("idle", true)
			end
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
		end,

		timeline =
		{
			FrameEvent(38, function(inst) inst:SpawnTrail(GetRandomMinMax(.9, 1), GetRandomMinMax(.2, .5)) end),
		},

		ontimeout = function(inst)
			inst.sg.statemem.idle = true
			inst.sg:GoToState("idle")
		end,

		events =
		{
			EventHandler("locomote", function(inst)
				if inst.components.locomotor:WantsToMoveForward() then
					inst.sg:GoToState("walk_start")
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.idle then
				--Might be six-faced from devour attack
				inst.Transform:SetFourFaced()
				inst.core.Transform:SetFourFaced()
			end
		end,
	},

	State{
		name = "spawndelay",
		tags = { "busy", "noattack", "temp_invincible", "invisible" },

		onenter = function(inst, delay)
			inst.components.locomotor:Stop()
			inst.Physics:SetActive(false)
			inst:EnableCloud(false)
			inst:Hide()
			inst:AddTag("NOCLICK")
			inst:HideDebris()
			inst.sg:SetTimeout(delay or 0)
		end,

		ontimeout = function(inst)
			inst.sg.statemem.dissipated = true
			inst.sg:GoToState("dissipated")
		end,

		onexit = function(inst)
			if not inst.sg.statemem.dissipated then
				inst.Physics:SetActive(true)
				inst:EnableCloud(true)
				inst:Show()
				inst:RemoveTag("NOCLICK")
			end
		end,
	},

	State{
		name = "dissipated",
		tags = { "busy", "noattack", "debris" },

		onenter = function(inst, looped)
			inst.components.locomotor:Stop()
			inst.Physics:SetActive(false)
			inst:EnableCloud(false)
			inst:Hide()
			inst:AddTag("NOCLICK")
			inst:ShowDebris()
			inst:ScatterDebris()
			for i, v in ipairs(inst.debris) do
				v.AnimState:PlayAnimation("rock_0"..tostring(v.variation))
			end
			if inst.sg.mem.force_despawn then
				inst.persists = false
				for i, v in ipairs(inst.debris) do
					ErodeCB(v, 1)
				end
				inst:DoTaskInTime(1, inst.Remove)
			else
				inst.components.health:StartRegen(TUNING.LUNAR_GRAZER_HEALTH_REGEN, 1, false)
			end
		end,

		events =
		{
			EventHandler("lunar_grazer_respawn", function(inst)
				if not inst.sg.mem.force_despawn then
					inst.sg.statemem.spawn = true
					inst.sg:GoToState("spawn")
				end
			end),
			EventHandler("lunar_grazer_despawn", function(inst, data)
				if data ~= nil and data.force and inst.persists then
					inst.persists = false
					for i, v in ipairs(inst.debris) do
						ErodeCB(v, 1)
					end
					inst:DoTaskInTime(1, inst.Remove)
				end
				return true
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.spawn then
				inst.Physics:SetActive(true)
				inst:EnableCloud(true)
				inst:Show()
				inst:RemoveTag("NOCLICK")
			end
			inst.components.health:StopRegen()
		end,
	},

	State{
		name = "spawn",
		tags = { "busy", "noattack", "temp_invincible", "debris" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.Physics:SetActive(false)
			inst:EnableCloud(false)
			inst:Hide()
			inst:AddTag("NOCLICK")
			inst:ShowDebris()
			inst:ScatterDebris()
			local x, y, z = inst.Transform:GetWorldPosition()
			for i, v in ipairs(inst.debris) do
				v._x0, y, v._z0 = v.Transform:GetWorldPosition()
				local dx = x - v._x0
				local dz = z - v._z0
				local d = dx * dx + dz * dz
				local r = 0.4
				if d > r * r then
					d = r / math.sqrt(d)
					v._x1 = x - dx * d
					v._z1 = z - dz * d
				else
					v._x1, v._z1 = v._x0, v._z0
				end
				v.AnimState:PlayAnimation("rock_form_0"..tostring(v.variation))
				v.AnimState:PushAnimation("rock_float_0"..tostring(v.variation))
				v.AnimState:SetDeltaTimeMultiplier(0.8 + math.random() * 1.1)
			end
			inst.SoundEmitter:PlaySound("rifts/grazer/rock_gather")
			inst.sg.statemem.delay = 1
			inst.sg:SetTimeout(inst.sg.statemem.delay)
		end,

		onupdate = function(inst, dt)
			if inst.debrisshown then
				local t = inst.sg:GetTimeInState()
				for i, v in ipairs(inst.debris) do
					v.Transform:SetPosition(
						easing.inQuad(t, v._x0, v._x1 - v._x0, inst.sg.statemem.delay),
						0,
						easing.inQuad(t, v._z0, v._z1 - v._z0, inst.sg.statemem.delay)
					)
				end
			end
		end,

		ontimeout = function(inst)
			inst.sg.statemem.spawn = true
			inst.sg:GoToState("spawn_actual")
		end,

		onexit = function(inst)
			if not inst.sg.statemem.spawn then
				inst:EnableCloud(true)
			end
			inst.Physics:SetActive(true)
			inst:Show()
			inst:RemoveTag("NOCLICK")
			for i, v in ipairs(inst.debris) do
				v._x0, v._z0, v._x1, v._z1 = nil, nil, nil, nil
			end
		end,
	},

	State{
		name = "spawn_actual",
		tags = { "busy", "noattack", "temp_invincible", "debris" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("spawn")
			inst.core.AnimState:PlayAnimation("rock_gather")
			inst.core.AnimState:PushAnimation("rock_cycle")
			inst.SoundEmitter:PlaySound("rifts/grazer/spawn")
			if inst.debrisshown then
				for i, v in ipairs(inst.debris) do
					v.AnimState:PlayAnimation("rock_off")
					v.AnimState:SetSymbolMultColour("rock_blob", 1, 1, 1, 0.2)
				end
			end
			inst:EnableCloud(false)
		end,

		onupdate = function(inst)
			if inst.debrisshown then
				local x, y, z = inst.Transform:GetWorldPosition()
				for i, v in ipairs(inst.debris) do
					local x1, y1, z1 = v.Transform:GetWorldPosition()
					v.Transform:SetPosition(
						x * 0.1 + x1 * 0.9,
						0,
						z * 0.1 + z1 * 0.9
					)
				end
			end
		end,

		timeline =
		{
			FrameEvent(24, function(inst)
				inst.sg:RemoveStateTag("debris")
				inst:HideDebris()
			end),
			FrameEvent(86, function(inst)
				inst.sg:RemoveStateTag("noattack")
				inst.sg:RemoveStateTag("temp_invincible")
				inst:EnableCloud(true)
			end),
			FrameEvent(90, function(inst) inst:SpawnTrail(GetRandomMinMax(.8, .9), GetRandomMinMax(.4, .6)) end),
			FrameEvent(96, function(inst)
				inst.sg:AddStateTag("caninterrupt")
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
			if not inst.core.AnimState:IsCurrentAnimation("rock_cycle") then
				inst.core.AnimState:PlayAnimation("rock_cycle", true)
			end
			for i, v in ipairs(inst.debris) do
				v.AnimState:SetSymbolMultColour("rock_blob", 1, 1, 1, 0.4)
			end
			inst:EnableCloud(true)
		end,
	},

	State{
		name = "splat",--oon",
		tags = { "hit", "busy", "nointerrupt" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("despawn_splat")
			inst.core.AnimState:PlayAnimation("despawn_splat_rocks")
			inst.SoundEmitter:PlaySound("rifts/grazer/despawn_splat")
			if inst.last_trail ~= nil and inst.last_trail:IsValid() then
				inst.last_trail:Dissipate()
			end
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("splat_pst")
				end
			end),
		},

		onexit = function(inst)
			inst.core.AnimState:PlayAnimation("rock_cycle", true)
		end,
	},

	State{
		name = "splat_pst",
		tags = { "busy", "nointerrupt", "temp_invincible", "debris" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("despawn_splat_pst")
			inst.Physics:SetActive(false)
			inst:EnableCloud(false)
			inst:ShowDebris()
			inst:TossDebris()
		end,

		timeline =
		{
			FrameEvent(2, function(inst)
				inst.sg:AddStateTag("noattack")
				inst:AddTag("NOCLICK")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.splat = true
					inst.sg:GoToState("splat_fade")
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.splat then
				inst:RemoveTag("NOCLICK")
				inst.Physics:SetActive(true)
				inst:EnableCloud(true)
			end
		end,
	},

	State{
		name = "splat_fade",
		tags = { "busy", "noattack", "debris" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.Transform:SetNoFaced()
			inst.AnimState:PlayAnimation("despawn_splat_pst_ground")
			inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
			inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
			inst.AnimState:SetSortOrder(3)
			inst.Physics:SetActive(false)
			inst:EnableCloud(false)
			inst:AddTag("NOCLICK")
			if not inst.debrisscattered then
				inst:ShowDebris()
				inst:ScatterDebris()
				for i, v in ipairs(inst.debris) do
					v.AnimState:PlayAnimation("rock_0"..tostring(v.variation))
				end
			end
			inst.sg.statemem.erode = -1
		end,

		onupdate = function(inst, dt)
			local t = inst.sg.statemem.erode + dt
			if t >= 1 then
				inst.sg.statemem.dissipated = true
				inst.sg:GoToState("dissipated")
				return
			end
			if t > 0 then
				if t > 0.24 and inst.sg.statemem.erode <= 0.24 then
					inst.AnimState:ClearBloomEffectHandle()
				end
				inst.AnimState:SetErosionParams(t * t, .1, 1)
			end
			inst.sg.statemem.erode = t
		end,

		timeline =
		{
			FrameEvent(32, function(inst)
				for i, v in ipairs(inst.debris) do
					v.AnimState:PlayAnimation("rock_off_0"..tostring(v.variation))
					v.AnimState:PushAnimation("rock_0"..tostring(v.variation), false)
				end
				inst.SoundEmitter:PlaySound("rifts/grazer/rock_off")
			end),
		},

		onexit = function(inst)
			inst.Transform:SetFourFaced()
			inst.AnimState:SetOrientation(ANIM_ORIENTATION.BillBoard)
			inst.AnimState:SetLayer(LAYER_WORLD)
			inst.AnimState:SetSortOrder(0)
			inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
			inst.AnimState:SetErosionParams(0, 0, 0)
			if not inst.sg.statemem.dissipated then
				inst.Physics:SetActive(true)
				inst:EnableCloud(true)
				inst:Show()
				inst:RemoveTag("NOCLICK")
			end
		end,
	},

	State{
		name = "melt",
		tags = { "busy", "nointerrupt", "temp_invincible" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("despawn_fall")
			inst.core.AnimState:PlayAnimation("despawn_fall_rocks")
			inst.SoundEmitter:PlaySound("rifts/grazer/despawn_fall")
			inst.Physics:SetActive(false)
			inst:EnableCloud(false)
			if inst.last_trail ~= nil and inst.last_trail:IsValid() then
				inst.last_trail:Dissipate()
			end
		end,

		timeline =
		{
			FrameEvent(3, function(inst)
				inst.sg:AddStateTag("noattack")
				inst:AddTag("NOCLICK")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.melt = true
					inst.sg:GoToState("melt_fade")
				end
			end),
		},

		onexit = function(inst)
			inst.core.AnimState:PlayAnimation("rock_cycle", true)
			if not inst.sg.statemem.melt then
				inst:RemoveTag("NOCLICK")
				inst.Physics:SetActive(true)
				inst:EnableCloud(true)
			end
		end,
	},

	State{
		name = "melt_fade",
		tags = { "busy", "noattack", "debris" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.Transform:SetNoFaced()
			inst.AnimState:PlayAnimation("despawn_fall_pst_ground")
			inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
			inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
			inst.AnimState:SetSortOrder(3)
			inst.Physics:SetActive(false)
			inst:EnableCloud(false)
			inst:ShowDebris()
			inst:DropDebris()
			inst:AddTag("NOCLICK")
			inst.sg.statemem.erode = -1
		end,

		onupdate = function(inst, dt)
			local t = inst.sg.statemem.erode + dt
			if t >= 1 then
				inst.sg.statemem.dissipated = true
				inst.sg:GoToState("dissipated")
				return
			end
			if t > 0 then
				if t > 0.24 and inst.sg.statemem.erode <= 0.24 then
					inst.AnimState:ClearBloomEffectHandle()
				end
				inst.AnimState:SetErosionParams(t * t, .1, 1)
			end
			inst.sg.statemem.erode = t
		end,

		timeline =
		{
			FrameEvent(32, function(inst)
				for i, v in ipairs(inst.debris) do
					v.AnimState:PlayAnimation("rock_off_0"..tostring(v.variation))
					v.AnimState:PushAnimation("rock_0"..tostring(v.variation), false)
				end
				inst.SoundEmitter:PlaySound("rifts/grazer/rock_off")
			end),
		},

		onexit = function(inst)
			inst.Transform:SetFourFaced()
			inst.AnimState:SetOrientation(ANIM_ORIENTATION.BillBoard)
			inst.AnimState:SetLayer(LAYER_WORLD)
			inst.AnimState:SetSortOrder(0)
			inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
			inst.AnimState:SetErosionParams(0, 0, 0)
			if not inst.sg.statemem.dissipated then
				inst.Physics:SetActive(true)
				inst:EnableCloud(true)
				inst:Show()
				inst:RemoveTag("NOCLICK")
			end
		end,
	},

	State{
		name = "hit",
		tags = { "hit", "busy" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("hit")
			inst.SoundEmitter:PlaySound("rifts/grazer/hit")
		end,

		timeline =
		{
			FrameEvent(2, function(inst)
				if inst.components.health.currenthealth < TUNING.LUNAR_GRAZER_MELT_HEALTH_THRESHOLD then
					inst.sg:GoToState("melt")
				end
			end),
			FrameEvent(7, function(inst)
				inst.sg:AddStateTag("caninterrupt")
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
		name = "walk_start",
		tags = { "moving", "canrotate", "softstop" },

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("walk_pre")
		end,

		timeline =
		{
			FrameEvent(25, PlayFootstepUp),
			FrameEvent(39, PlayFootstepDown),

			FrameEvent(17, function(inst)
				inst.sg:AddStateTag("queueattack")
				inst.components.locomotor:WalkForward()
			end),
			FrameEvent(24, function(inst) inst:SpawnTrail(GetRandomMinMax(.7, .8), 0) end),
			FrameEvent(35, function(inst)
				if ChooseAttack(inst, inst.sg.statemem.doattack) then
					return
				end
				inst.sg.statemem.doattack = nil
				inst.sg:RemoveStateTag("queueattack")
			end),
			FrameEvent(40, function(inst) inst:SpawnTrail(GetRandomMinMax(.85, 1.1), GetRandomMinMax(10, 11)) end),
			--walk_pre is 41 frames
		},

		events =
		{
			EventHandler("locomote", function(inst)
				if inst.components.locomotor:WantsToMoveForward() then
					if inst.sg.statemem.stop then
						inst.sg.statemem.stop = false
						inst.sg:AddStateTag("canrotate")
					end
				elseif not inst.sg.statemem.stop then
					inst.sg.statemem.stop = true
					inst.sg:RemoveStateTag("canrotate")
				end
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState(inst.sg.statemem.stop and "walk_stop" or "walk")
				end
			end),
		},
	},

	State{
		name = "walk",
		tags = { "moving", "canrotate", "softstop" },

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("walk_loop")
		end,

		timeline =
		{
			FrameEvent(32, PlayFootstepUp),
			FrameEvent(46, PlayFootstepDown),
			FrameEvent(80, PlayFootstepUp),
			FrameEvent(94, PlayFootstepDown),

			FrameEvent(24, function(inst)
				inst.sg:AddStateTag("queueattack")
				inst.components.locomotor:WalkForward()
			end),
			FrameEvent(31, function(inst) inst:SpawnTrail(GetRandomMinMax(.7, .8), 0) end),
			FrameEvent(42, function(inst)
				if ChooseAttack(inst, inst.sg.statemem.doattack) then
					return
				end
				inst.sg.statemem.doattack = nil
				inst.sg:RemoveStateTag("queueattack")
			end),
			FrameEvent(47, function(inst) inst:SpawnTrail(GetRandomMinMax(.85, 1.1), GetRandomMinMax(10, 11)) end),
			FrameEvent(48, function(inst)
				inst.components.locomotor:StopMoving()
			end),
			FrameEvent(72, function(inst)
				inst.sg:AddStateTag("queueattack")
				inst.components.locomotor:WalkForward()
			end),
			FrameEvent(79, function(inst) inst:SpawnTrail(GetRandomMinMax(.7, .8), 0) end),
			FrameEvent(90, function(inst)
				if ChooseAttack(inst, inst.sg.statemem.doattack) then
					return
				end
				inst.sg.statemem.doattack = nil
				inst.sg:RemoveStateTag("queueattack")
			end),
			FrameEvent(95, function(inst) inst:SpawnTrail(GetRandomMinMax(.85, 1.1), GetRandomMinMax(10, 11)) end),
			--walk is 96 frames
		},

		events =
		{
			EventHandler("locomote", function(inst)
				if inst.components.locomotor:WantsToMoveForward() then
					if inst.sg.statemem.stop then
						inst.sg.statemem.stop = false
						inst.sg:AddStateTag("canrotate")
					end
				elseif not inst.sg.statemem.stop then
					inst.sg.statemem.stop = true
					inst.sg:RemoveStateTag("canrotate")
				end
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState(inst.sg.statemem.stop and "walk_stop" or "walk")
				end
			end),
		},
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

	State{
		name = "devour",
		tags = { "attack", "busy" },

		onenter = function(inst, target)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("devour")
			inst.core.AnimState:PlayAnimation("devour_rocks")
			inst.Transform:SetSixFaced()
			inst.core.Transform:SetSixFaced()
			if target ~= nil and target:IsValid() then
				inst.sg.statemem.target = target
				inst:ForceFacePoint(target.Transform:GetWorldPosition())
			end
		end,

		timeline =
		{
			FrameEvent(0, function(inst) inst.SoundEmitter:PlaySound("rifts/grazer/devour_scream") end),
			FrameEvent(12, function(inst)
				inst.components.combat:StartAttack()
			end),
			FrameEvent(14, function(inst) inst.SoundEmitter:PlaySound("rifts/grazer/devour_chomp") end),
			FrameEvent(32, function(inst)
				local target = inst.sg.statemem.target or inst.components.combat.target
				if inst.components.combat:CanHitTarget(target) then
					local sleeping = inst:IsTargetSleeping(target) or (target.sg ~= nil and target.sg:HasStateTag("waking"))
					inst.components.combat:DoAttack(target)
					if sleeping then
						target:PushEvent("knockback", { knocker = inst, radius = 1, forcelanded = true, strengthmult = .7 })
						inst:SetCloudProtection(target, 1.5)
					end
				end
			end),
			FrameEvent(43, function(inst)
				inst.sg:AddStateTag("caninterrupt")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.idle = true
					inst.sg:GoToState("idle")
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.idle then
				inst.Transform:SetFourFaced()
				inst.core.Transform:SetFourFaced()
			end
			inst.core.AnimState:PlayAnimation("rock_cycle", true)
		end,
	},
}

return StateGraph("lunar_grazer", states, events, "idle")
