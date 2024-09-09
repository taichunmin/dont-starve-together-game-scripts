require("stategraphs/commonstates")

local events =
{
	CommonHandlers.OnLocomote(true, false),
	EventHandler("jump", function(inst, target)
		if not inst.sg:HasStateTag("busy") then
			inst.sg:GoToState("jump_pre", target)
		end
	end),
	EventHandler("attacked", function(inst)
		if not (inst.sg:HasStateTag("noattack") or inst.sg:HasStateTag("temp_invincible") or inst.components.health:IsDead()) then
			inst.sg:GoToState("hit")
		end
	end),
	EventHandler("death", function(inst)
		inst.sg:GoToState("death")
	end),
}

local function TryAttach(inst, target)
	if target ~= nil and target.AttachLeech ~= nil and target:IsValid() and inst:IsNear(target, 1.8) then
		target:AttachLeech(inst)
	end
end

local states =
{
	State{
		name = "idle",
		tags = { "idle", "canrotate" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("idle", true)
		end,
	},

	State{
		name = "spawn_delay",
		tags = { "busy", "noattack", "temp_invincible", "invisible" },

		onenter = function(inst, delay)
			inst.components.locomotor:Stop()
			inst:Hide()
			inst.sg:SetTimeout(delay or math.random())
		end,

		ontimeout = function(inst)
			local target = inst.components.entitytracker:GetEntity("daywalker")
			if target ~= nil then
				inst:ForceFacePoint(target.Transform:GetWorldPosition())
			end
			inst.sg:GoToState("spawn")
		end,

		onexit = function(inst)
			inst:Show()
		end,
	},

	State{
		name = "spawn",
		tags = { "busy", "noattack", "temp_invincible" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("spawn")
		end,

		timeline =
		{
			FrameEvent(35, function(inst)
				inst.sg:RemoveStateTag("noattack")
				inst.sg:RemoveStateTag("temp_invincible")
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
		name = "hit",
		tags = { "busy", "hit", "temp_invincible" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("disappear")
			inst.SoundEmitter:PlaySound("daywalker/leech/die")
			--inst.SoundEmitter:PlaySound("dontstarve/sanity/death_pop")
		end,

		timeline =
		{
			FrameEvent(12, function(inst)
				inst.sg:AddStateTag("noattack")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					local x0, y0, z0 = inst.Transform:GetWorldPosition()
					local daywalker = inst.components.entitytracker:GetEntity("daywalker")
					local dir0 = daywalker ~= nil and daywalker:GetAngleToPoint(x0, y0, z0) or nil
					for k = 1, 4 do
						local radius = GetRandomMinMax(4 - k, 8)
						local angle = dir0 ~= nil and (dir0 + math.random() * 90 - 45) * DEGREES or math.random() * TWOPI
						local x = x0 + math.cos(angle) * radius
						local z = z0 - math.sin(angle) * radius
						if TheWorld.Map:IsPassableAtPoint(x, 0, z) then
							inst.Physics:Teleport(x, 0, z)
							break
						end
					end
					inst.sg:GoToState("appear")
				end
			end),
		},
	},

	State{
		name = "appear",
		tags = { "busy", "temp_invincible" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("appear")
		end,

		timeline =
		{
			FrameEvent(17, function(inst)
				inst.sg:RemoveStateTag("temp_invincible")
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
		name = "death",
		tags = { "busy", "noattack" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("disappear")
			inst.SoundEmitter:PlaySound("daywalker/leech/die")
			inst.SoundEmitter:PlaySound("dontstarve/sanity/death_pop")
			local pt = inst:GetPosition()
			pt.y = 1
			inst.components.lootdropper:DropLoot(pt)
			inst:AddTag("NOCLICK")
			inst.persists = false
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst:Remove()
				end
			end),
		},

		onexit = function(inst)
			--Shouldn't reach here!
			inst:RemoveTag("NOCLICK")
		end,
	},

	State{
		name = "jump_pre",
		tags = { "busy" },

		onenter = function(inst, target)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("jump_pre")
			inst.SoundEmitter:PlaySound("daywalker/leech/leap")
			if target ~= nil and target:IsValid() then
				inst.sg.statemem.target = target
				inst.sg.statemem.targetpos = target:GetPosition()
			end
		end,

		onupdate = function(inst)
			if inst.sg.statemem.target ~= nil then
				if inst.sg.statemem.target:IsValid() then
					local pos = inst.sg.statemem.targetpos
					pos.x, pos.y, pos.z = inst.sg.statemem.target.Transform:GetWorldPosition()
					inst:ForceFacePoint(pos)
				else
					inst.sg.statemem.target = nil
				end
			end
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("jump", inst.sg.statemem.target or inst.sg.statemem.targetpos)
				end
			end),
		},
	},

	State{
		name = "jump",
		tags = { "busy", "jumping", "noattack" },

		onenter = function(inst, target)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("jump")
			inst.SoundEmitter:PlaySound("daywalker/leech/vocalization")
			local dist
			if target == nil then
				dist = 6
				local theta = inst.Transform:GetRotation() * DEGREES
				target = inst:GetPosition()
				target.x = target.x + math.cos(theta) * dist
				target.z = target.z - math.sin(theta) * dist
			elseif EntityScript.is_instance(target) and target:IsValid() then
				inst.sg.statemem.target = target
				target = target:GetPosition()
				dist = math.sqrt(inst:GetDistanceSqToPoint(target))
			end
			inst:ForceFacePoint(target)
			inst.sg.statemem.speed = math.min(16.5, dist / (11 * FRAMES))
			inst.Physics:SetMotorVelOverride(inst.sg.statemem.speed, 0, 0)
			inst.Physics:ClearCollidesWith(COLLISION.SANITY)
		end,

		timeline =
		{
			FrameEvent(11, function(inst)
				TryAttach(inst, inst.sg.statemem.target)
			end),
			FrameEvent(12, function(inst)
				TryAttach(inst, inst.sg.statemem.target)
			end),
			FrameEvent(15, function(inst)
				inst.sg:RemoveStateTag("noattack")
				inst.Physics:SetMotorVelOverride(inst.sg.statemem.speed * .35, 0, 0)
				inst.Physics:CollidesWith(COLLISION.SANITY)
				inst.SoundEmitter:PlaySound("daywalker/leech/vocalization")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("flail")
				end
			end),
		},

		onexit = function(inst)
			inst.Physics:ClearMotorVelOverride()
			inst.Physics:Stop()
			inst.Physics:CollidesWith(COLLISION.SANITY)
		end,
	},

	State{
		name = "flail",
		tags = { "busy" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("flail_loop", true)
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() * 3)
		end,

		ontimeout = function(inst)
			inst.sg:GoToState("flail_pst")
		end,
	},

	State{
		name = "flail_pst",
		tags = { "busy" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("flail_pst")
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
		name = "attached",
		tags = { "busy", "noattack", "temp_invincible" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("attach_loop", true)
			inst.Physics:SetActive(false)
			inst:AddTag("notarget")
			inst:ToggleBrain(false)
			inst.SoundEmitter:PlaySound("daywalker/leech/suck", "suckloop")
		end,

		onexit = function(inst)
			inst.Follower:StopFollowing()
			inst.Physics:SetActive(true)
			inst:RemoveTag("notarget")
			inst:ToggleBrain(true)
			inst.SoundEmitter:KillSound("suckloop")
			local daywalker = inst.components.entitytracker:GetEntity("daywalker")
			if daywalker ~= nil then
				daywalker:OnAttachmentInterrupted(inst)
			end
		end,
	},

	State{
		name = "flung",
		tags = { "busy", "jumping", "noattack", "temp_invincible" },

		onenter = function(inst, speedmult)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("toss")
			inst.SoundEmitter:PlaySound("daywalker/leech/fall_off")
			inst.sg.statemem.speed = -10 * (speedmult or 1)
			inst.Physics:SetMotorVelOverride(inst.sg.statemem.speed, 0, 0)
			inst.Physics:ClearCollidesWith(COLLISION.SANITY)
		end,

		timeline =
		{
			FrameEvent(18, function(inst)
				inst.sg:RemoveStateTag("noattack")
				inst.sg:RemoveStateTag("temp_invincible")
				inst.Physics:SetMotorVelOverride(inst.sg.statemem.speed * .35, 0, 0)
				inst.Physics:CollidesWith(COLLISION.SANITY)
				inst.SoundEmitter:PlaySound("daywalker/leech/vocalization")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("flail")
				end
			end),
		},

		onexit = function(inst)
			inst.Physics:ClearMotorVelOverride()
			inst.Physics:Stop()
			inst.Physics:CollidesWith(COLLISION.SANITY)
		end,
	},
}

CommonStates.AddRunStates(states,
{
	starttimeline =
	{
		FrameEvent(6, function(inst)
			inst.components.locomotor:RunForward()
		end),
	},
},
nil, nil, true--[[delaystart]],
{
	runonenter = function(inst)
		inst.SoundEmitter:PlaySound("daywalker/leech/walk", "walkloop")
	end,
	runonexit = function(inst)
		inst.SoundEmitter:KillSound("walkloop")
	end,
})

return StateGraph("shadow_leech", states, events, "idle")
