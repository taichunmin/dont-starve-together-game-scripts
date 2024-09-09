local function CheckPillars(inst)
	local resonating, idle = inst:CountPillars()
	return resonating ~= 0, resonating ~= 0 and idle == 0
end

local function DoIdleChain(inst)
	inst.SoundEmitter:PlaySound("daywalker/pillar/chain_shake_oneshot", nil, 0.2 + math.random() * 0.1)
	inst.sg.mem.idletask = inst:DoTaskInTime(1 + math.random() * 2, DoIdleChain)
end

local function DoChainBreakShake(inst)
	ShakeAllCameras(CAMERASHAKE.FULL, 1.4, .02, .2, inst, 30)
end

local states =
{
	State{
		name = "transition",
	},

	State{
		name = "idle",

		onenter = function(inst, chatter)
			local any, all = CheckPillars(inst)
			if any then
				inst.sg:GoToState("struggle3")
				return
			end

			if not inst.AnimState:IsCurrentAnimation("chained_idle") then
				inst.AnimState:PlayAnimation("chained_idle", true)
			end
			if inst.sg.mem.idletask == nil then
				inst.sg.mem.idletask = inst:DoTaskInTime(0.5 + math.random(), DoIdleChain)
			end
			local isnear = inst:IsNearPlayer(12, true)
			if chatter then
				local strtbl =
					(not isnear and "DAYWALKER_IMPRISONED_FAR") or
					(	TheWorld.components.daywalkerspawner ~= nil and
						TheWorld.components.daywalkerspawner:GetPowerLevel() > 1 and
						"DAYWALKER_RE_IMPRISONED_NEAR"
					) or
					"DAYWALKER_IMPRISONED_NEAR"
				inst.components.talker:Chatter(strtbl, math.random(#STRINGS[strtbl]), nil, nil, CHATPRIORITIES.HIGH)
			end
			if isnear then
				inst.sg:SetTimeout(3 + 2 * math.random())
			else
				inst.sg:SetTimeout(6 + 4 * math.random())
			end
		end,

		events =
		{
			EventHandler("pillarvibrating", function(inst)
				inst.sg:GoToState("struggle3")
			end),
		},

		ontimeout = function(inst)
			local isnear = inst:IsNearPlayer(12, true)
			local rnd = math.random(isnear and 5 or 4)
			if rnd > 3 then
				inst.sg.statemem.idle = true
				inst.sg:GoToState("idle", true)
			else
				inst.sg:GoToState("struggle"..tostring(rnd))
			end
		end,

		onexit = function(inst)
			if not inst.sg.statemem.idle and inst.sg.mem.idletask ~= nil then
				inst.sg.mem.idletask:Cancel()
				inst.sg.mem.idletask = nil
			end
		end,
	},

	State{
		name = "struggle1",
		tags = { "notalksound" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("chained_1")
			inst.SoundEmitter:PlaySound("daywalker/voice/struggle1")
			local strtbl = "DAYWALKER_IMPRISONED_STRUGGLE"
			inst.components.talker:Chatter(strtbl, math.random(#STRINGS[strtbl]), nil, nil, CHATPRIORITIES.LOW)
		end,

		timeline =
		{
			--chains
			FrameEvent(1, function(inst) inst.SoundEmitter:PlaySound("daywalker/pillar/chain_shake_oneshot", nil, 0.6) end),
			FrameEvent(9, function(inst) inst.SoundEmitter:PlaySound("daywalker/pillar/chain_shake_oneshot") end),
			FrameEvent(23, function(inst) inst.SoundEmitter:PlaySound("daywalker/pillar/chain_shake_oneshot") end),
			FrameEvent(42, function(inst) inst.SoundEmitter:PlaySound("daywalker/pillar/chain_shake_oneshot") end),
			FrameEvent(56, function(inst) inst.SoundEmitter:PlaySound("daywalker/pillar/chain_shake_oneshot") end),

			--steps
			FrameEvent(57, function(inst) inst.SoundEmitter:PlaySound("daywalker/action/step", nil, 0.3) end),
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
		name = "struggle2",
		tags = { "notalksound" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("chained_2")
			inst.SoundEmitter:PlaySound("daywalker/voice/struggle2")
			inst.components.talker:Chatter("DAYWALKER_IMPRISONED_STRUGGLE", 2, nil, nil, CHATPRIORITIES.HIGH)
		end,

		timeline =
		{
			--chains
			FrameEvent(2, function(inst) inst.SoundEmitter:PlaySound("daywalker/pillar/chain_shake_oneshot", nil, 0.6) end),
			FrameEvent(13, function(inst) inst.SoundEmitter:PlaySound("daywalker/pillar/chain_shake_oneshot") end),
			FrameEvent(29, function(inst) inst.SoundEmitter:PlaySound("daywalker/pillar/chain_shake_oneshot") end),
			FrameEvent(41, function(inst) inst.SoundEmitter:PlaySound("daywalker/pillar/chain_shake_oneshot") end),
			FrameEvent(57, function(inst) inst.SoundEmitter:PlaySound("daywalker/pillar/chain_shake_oneshot") end),

			--steps
			FrameEvent(11, function(inst) inst.SoundEmitter:PlaySound("daywalker/action/step", nil, 0.3) end),
			FrameEvent(16, function(inst) inst.SoundEmitter:PlaySound("daywalker/action/step", nil, 0.15) end),
			FrameEvent(25, function(inst) inst.SoundEmitter:PlaySound("daywalker/action/step", nil, 0.2) end),
			FrameEvent(34, function(inst) inst.SoundEmitter:PlaySound("daywalker/action/step", nil, 0.1) end),
			FrameEvent(58, function(inst) inst.SoundEmitter:PlaySound("daywalker/action/step", nil, 0.3) end),
			FrameEvent(65, function(inst) inst.SoundEmitter:PlaySound("daywalker/action/step", nil, 0.2) end),
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
		name = "struggle3",

		onenter = function(inst)
			inst.AnimState:PlayAnimation("chained_3_pre")
			inst.SoundEmitter:PlaySound("daywalker/voice/struggle3")
		end,

		timeline =
		{
			--chains
			FrameEvent(11, function(inst) inst.SoundEmitter:PlaySound("daywalker/pillar/chain_shake_oneshot") end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("struggle3_loop_a", true)
				end
			end),
		},
	},

	State{
		name = "struggle3_loop_a",

		onenter = function(inst, skipsound)
			inst.AnimState:PlayAnimation("chained_3_loop_a")
			inst.sg.statemem.skipsound = skipsound
		end,

		timeline =
		{
			--chains
			FrameEvent(0, function(inst) inst.SoundEmitter:PlaySound("daywalker/pillar/chain_shake_oneshot") end),
			FrameEvent(10, function(inst) inst.SoundEmitter:PlaySound("daywalker/pillar/chain_shake_oneshot", nil, 0.4) end),
			FrameEvent(24, function(inst) inst.SoundEmitter:PlaySound("daywalker/pillar/chain_shake_oneshot") end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("struggle3_loop_b", inst.sg.statemem.skipsound)
				end
			end),
		},
	},

	State{
		name = "struggle3_loop_b",
		tags = { "notalksound" },

		onenter = function(inst, skipsound)
			inst.AnimState:PlayAnimation("chained_3_loop_b")
			if skipsound then
				inst.sg.statemem.skipsound = true
				local any, all = CheckPillars(inst)
				if not all then
					local strtbl = any and "DAYWALKER_IMPRISONED_PILLAR_BREAKING" or "DAYWALKER_IMPRISONED_STRUGGLE"
					inst.components.talker:Chatter(strtbl, math.random(#STRINGS[strtbl]), nil, nil, CHATPRIORITIES.HIGH)
				end
			end
		end,

		timeline =
		{
			--chains
			FrameEvent(10, function(inst) inst.SoundEmitter:PlaySound("daywalker/pillar/chain_shake_oneshot", nil, 0.5) end),

			FrameEvent(8, function(inst)
				local any, all = CheckPillars(inst)
				if inst.sg.statemem.skipsound then
					inst.sg.mem.pendingbreak = all or nil
				else
					if not all then
						inst.sg.mem.pendingbreak = nil
					elseif inst.sg.mem.pendingbreak then
						inst.sg.mem.pendingbreak = nil
						inst.sg.statemem.dobreak = true
					else
						inst.sg.mem.pendingbreak = true
					end
					if not inst.sg.statemem.dobreak then
						inst.SoundEmitter:PlaySound("daywalker/voice/struggle3")
					end
				end
			end),
			FrameEvent(9, function(inst)
				if inst.sg.statemem.dobreak then
					inst.SoundEmitter:PlaySound("daywalker/voice/chainbreak_break_1")
				end
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.sg.statemem.dobreak then
						inst.sg:GoToState("chain_break")
					else
						local any, all = CheckPillars(inst)
						inst.sg.mem.pendingbreak = all or nil
						if any then
							inst.sg:GoToState(math.random() < 0.5 and "struggle3_loop_a" or "struggle3_loop_c", not inst.sg.statemem.skipsound)
						else
							inst.sg:GoToState("struggle3_loop_c", not inst.sg.statemem.skipsound)
						end
					end
				end
			end),
		},
	},

	State{
		name = "struggle3_loop_c",

		onenter = function(inst, skipsound)
			inst.AnimState:PlayAnimation("chained_3_loop_c")
			inst.sg.statemem.skipsound = skipsound
		end,

		timeline =
		{
			--chains
			FrameEvent(0, function(inst) inst.SoundEmitter:PlaySound("daywalker/pillar/chain_shake_oneshot") end),
			FrameEvent(12, function(inst) inst.SoundEmitter:PlaySound("daywalker/pillar/chain_shake_oneshot", nil, 0.4) end),
			FrameEvent(22, function(inst) inst.SoundEmitter:PlaySound("daywalker/pillar/chain_shake_oneshot") end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.sg.statemem.skipsound then
						inst.sg:GoToState("struggle3_loop_b", true)
					else
						local any, all = CheckPillars(inst)
						inst.sg:GoToState(any and "struggle3_loop_b" or "struggle3_pst")
					end
				end
			end),
		},
	},

	State{
		name = "struggle3_pst",

		onenter = function(inst)
			inst.AnimState:PlayAnimation("chained_3_pst")
		end,

		timeline =
		{
			--steps
			FrameEvent(2, function(inst) inst.SoundEmitter:PlaySound("daywalker/action/step", nil, 0.5) end),
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
		name = "chain_break_pre",

		onenter = function(inst)
			inst.AnimState:PlayAnimation("chain_break_pre")
			inst.SoundEmitter:PlaySound("daywalker/voice/chainbreak_break_1")
			inst:AddTag("NOCLICK")
		end,

		timeline =
		{
			--chains
			FrameEvent(11, function(inst) inst.SoundEmitter:PlaySound("daywalker/pillar/chain_shake_oneshot") end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.breaking = true
					inst.sg:GoToState("chain_break")
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.breaking then
				inst:RemoveTag("NOCLICK")
			end
		end,
	},

	State{
		name = "chain_break",

		onenter = function(inst)
			inst.AnimState:PlayAnimation("chain_break")
			inst:AddTag("NOCLICK")
		end,

		timeline =
		{
			--roar
			FrameEvent(5, function(inst) inst.SoundEmitter:PlaySound("daywalker/voice/chainbreak_break_2") end),

			--chains
			FrameEvent(0, function(inst) inst.SoundEmitter:PlaySound("daywalker/pillar/chain_shake_oneshot") end),
			FrameEvent(11, function(inst) inst.SoundEmitter:PlaySound("daywalker/pillar/chain_shake_oneshot") end),

			--steps
			FrameEvent(67, function(inst) inst.SoundEmitter:PlaySound("daywalker/action/step", nil, 0.3) end),
			FrameEvent(69, function(inst) inst.SoundEmitter:PlaySound("daywalker/action/step", nil, 0.3) end),

			FrameEvent(23, function(inst)
				inst.SoundEmitter:PlaySound("daywalker/pillar/chain_shake_oneshot")
				inst.SoundEmitter:PlaySound("daywalker/pillar/chain_break")
				DoChainBreakShake(inst)
				inst:PushEvent("daywalkerchainbreak")
				inst:SpawnLeeches()
			end),
			FrameEvent(71, function(inst)
				inst:RemoveTag("NOCLICK")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst:MakeUnchained()
				end
			end),
		},

		onexit = function(inst)
			inst:RemoveTag("NOCLICK")
		end,
	},
}

return StateGraph("daywalker_imprisoned", states, {}, "idle")
