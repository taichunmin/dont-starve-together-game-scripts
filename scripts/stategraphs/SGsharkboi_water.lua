require("stategraphs/commonstates")

local function PlaySwimstep(inst, volume)
	inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/jump_small", nil, 0.5 * (volume or 1))
end

local function DoWakeFX(inst) --water wake!
	local wake = SpawnPrefab("wake_small")
	local x, y, z = inst.Transform:GetWorldPosition()
	local rot = inst.Transform:GetRotation()
	local theta = rot * DEGREES
	wake.Transform:SetPosition(x + 2 * math.cos(theta), 0, z - 2 * math.sin(theta))
	wake.Transform:SetScale(2, 1, 1.6)
	wake.Transform:SetRotation(rot - 90)
end

local events =
{
	EventHandler("locomote", function(inst, data)
		local should_move = inst.components.locomotor:WantsToMoveForward()

		if inst.sg:HasStateTag("softstop") then
			if should_move then
				if inst.sg.statemem.stop then
					inst.sg.statemem.stop = false
					inst.sg:AddStateTag("canrotate")
					inst.components.locomotor.pusheventwithdirection = false
				end
			elseif not inst.sg.statemem.stop then
				inst.sg.statemem.stop = true
				inst.sg:RemoveStateTag("canrotate")
				inst.components.locomotor.pusheventwithdirection = true
			end
		else
			local is_moving = inst.sg:HasStateTag("moving")
			local is_running = inst.sg:HasStateTag("running")
			local is_idling = inst.sg:HasStateTag("idle")

			local should_run = inst.components.locomotor:WantsToRun()

			if is_moving and not should_move then
				inst.sg:GoToState(is_running and "run_stop" or "walk_stop")
			elseif (is_idling and should_move) or (is_moving and should_move and is_running ~= should_run) then
				if data and data.dir then
					inst.Transform:SetRotation(data.dir)
				end
				inst.sg:GoToState(should_run and "run_start" or "walk_start")
			end
		end
	end),
}

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
		name = "walk_start",
		tags = { "moving", "canrotate", "softstop" },

		onenter = function(inst)
			inst.components.locomotor:WalkForward()
			inst.AnimState:PlayAnimation("walk_pre")
			PlaySwimstep(inst, 0.5)
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState(inst.sg.statemem.stop and "walk_stop" or "walk")
				end
			end),
		},

		onexit = function(inst)
			inst.components.locomotor.pusheventwithdirection = false
		end,
	},

	State{
		name = "walk",
		tags = { "moving", "canrotate", "softstop" },

		onenter = function(inst)
			inst.components.locomotor:WalkForward()
			if not inst.AnimState:IsCurrentAnimation("walk_loop") then
				inst.AnimState:PlayAnimation("walk_loop", true)
			end
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
		end,

		timeline =
		{
			FrameEvent(31, function(inst) PlaySwimstep(inst, 0.5) end),
		},

		ontimeout = function(inst)
			inst.sg:GoToState(inst.sg.statemem.stop and "walk_stop" or "walk")
		end,

		onexit = function(inst)
			inst.components.locomotor.pusheventwithdirection = false
		end,
	},

	State{
		name = "walk_stop",

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("walk_pst")
			inst.components.locomotor.pusheventwithdirection = true
			inst.sg.statemem.speedmult = 1
		end,

		onupdate = function(inst)
			if inst.sg.statemem.speedmult then
				inst.sg.statemem.speedmult = inst.sg.statemem.speedmult * 0.8
				local speed = inst.components.locomotor:GetWalkSpeed() * inst.sg.statemem.speedmult
				if speed >= 0.1 then
					inst.Physics:SetMotorVel(speed, 0, 0)
				else
					inst.Physics:Stop()
					inst.sg.statemem.speedmult = nil
					inst.sg:AddStateTag("canrotate")
					inst.components.locomotor.pusheventwithdirection = false
				end
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
			if inst.sg.statemem.speedmult then
				inst.Physics:Stop()
			end
			inst.components.locomotor.pusheventwithdirection = false
		end,
	},

	State{
		name = "run_start",
		tags = { "moving", "running", "canrotate" },

		onenter = function(inst)
			inst.components.locomotor:RunForward()
			inst.AnimState:PlayAnimation("run_pre")
			PlaySwimstep(inst)
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("run")
				end
			end),
		},
	},

	State{
		name = "run",
		tags = { "moving", "running", "canrotate" },

		onenter = function(inst, task)
			inst.components.locomotor:RunForward()
			if not inst.AnimState:IsCurrentAnimation("run_loop") then
				inst.AnimState:PlayAnimation("run_loop", true)
			end
			PlaySwimstep(inst)
			inst.sg.statemem.waketask = task or inst:DoPeriodicTask(0.25, DoWakeFX)
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
		end,

		timeline =
		{
			FrameEvent(13, PlaySwimstep),
		},

		ontimeout = function(inst)
			local task = inst.sg.statemem.waketask
			inst.sg.statemem.waketask = nil
			inst.sg:GoToState("run", task)
		end,

		onexit = function(inst)
			if inst.sg.statemem.waketask then
				inst.sg.statemem.waketask:Cancel()
			end
		end,
	},

	State{
		name = "run_stop",
		tags = { "idle" },

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("run_pst")
			PlaySwimstep(inst, 0.5)
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
}

return StateGraph("sharkboi_water", states, events, "idle")
