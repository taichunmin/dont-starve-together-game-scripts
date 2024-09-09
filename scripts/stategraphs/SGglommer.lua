require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "flyaway"),
}

local events=
{
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnLocomote(false,true),
}

local function StartFlap(inst)
	if inst.FlapTask then return end
	inst.FlapTask = inst:DoPeriodicTask(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/glommer/flap") end)
end

local function StopFlap(inst)
	if inst.FlapTask then
		inst.FlapTask:Cancel()
		inst.FlapTask = nil
	end
end

local states=
{
	State{
		name = "idle",
		tags = {"idle"},

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("idle_loop")
			StartFlap(inst)
			if math.random() > 0.75 then
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/glommer/idle_voice")
			end
		end,

		timeline =
		{
			TimeEvent(3*FRAMES, function(inst)
				if math.random() > 0.75 then
					inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/glommer/idle_voice")
				end
			end)
		},

		events =
		{
			EventHandler("animover", function(inst)
				if math.random() < 0.05 then
					inst.sg:GoToState("bored")
				else
					inst.sg:GoToState("idle")
				end
			end)
		},
	},

	State{
		name = "goo",
		tags = {"busy"},

		onenter = function(inst, fuel)
			inst.Physics:Stop()
			if fuel then
				fuel:Hide()
				inst.sg.statemem.fuel = fuel
			end

			inst.AnimState:PlayAnimation("place")
			StartFlap(inst)
		end,

		timeline =
		{
			TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/glommer/vomit_voice") end),
			TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/glommer/vomit_liquid") end),
			TimeEvent(30*FRAMES, function(inst)
				if inst.sg.statemem.fuel then
					inst.sg.statemem.fuel:Show()
				end
			end)
		},

		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
		},
	},

	State{
		name = "bored",
		tags = {"busy"},

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("bored")
			StartFlap(inst)
		end,

		timeline =
		{
			TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/glommer/bounce_voice") end),
            TimeEvent(11*FRAMES, LandFlyingCreature),
			TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/glommer/bounce_ground") end),
            TimeEvent(18*FRAMES, RaiseFlyingCreature),
			TimeEvent(25*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/glommer/bounce_voice") end),
            TimeEvent(33*FRAMES, LandFlyingCreature),
			TimeEvent(34*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/glommer/bounce_ground") end),
            TimeEvent(38*FRAMES, RaiseFlyingCreature),
			TimeEvent(45*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/glommer/bounce_voice") end),
            TimeEvent(54*FRAMES, LandFlyingCreature),
			TimeEvent(55*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/glommer/bounce_ground") end),
            TimeEvent(60*FRAMES, RaiseFlyingCreature),
		},

		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
		},

        onexit = RaiseFlyingCreature,
	},

	State{
        name = "frozen",
        tags = {"busy", "frozen"},

        onenter = function(inst)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("frozen")
            inst.SoundEmitter:PlaySound("dontstarve/common/freezecreature")
            inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
            StopFlap(inst)
            LandFlyingCreature(inst)
        end,

        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol("swap_frozen")
            RaiseFlyingCreature(inst)
        end,

        events=
        {
            EventHandler("onthaw", function(inst) inst.sg:GoToState("thaw") end ),
        },
    },

    State{
        name = "thaw",
        tags = {"busy", "thawing"},

        onenter = function(inst)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("frozen_loop_pst", true)
            inst.SoundEmitter:PlaySound("dontstarve/common/freezethaw", "thawing")
            inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
            StopFlap(inst)
            LandFlyingCreature(inst)
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("thawing")
            inst.AnimState:ClearOverrideSymbol("swap_frozen")
            RaiseFlyingCreature(inst)
        end,

        events =
        {
            EventHandler("unfreeze", function(inst)
                if inst.sg.sg.states.hit then
                    inst.sg:GoToState("hit")
                else
                    inst.sg:GoToState("idle")
                end
            end ),
        },
    },

    State{
        name = "flyaway",
        tags = {"flight", "busy"},
        onenter = function(inst)
            inst.Physics:Stop()
	        inst.DynamicShadow:Enable(false)
            inst.AnimState:PlayAnimation("walk_pre")
           	StartFlap(inst)
        end,

        timeline =
        {
            TimeEvent(9*FRAMES, function(inst)
                inst.AnimState:PushAnimation("walk_loop", true)
                inst.Physics:SetMotorVel(-2 + math.random()*4, 5+math.random()*3,-2 + math.random()*4)
            end),
            TimeEvent(5, function(inst) inst:Remove() end)
        }
    },
}

CommonStates.AddSimpleActionState(states, "action", "idle", FRAMES*5, {"busy"})
CommonStates.AddCombatStates(states,
{
	hittimeline =
	{
		TimeEvent(0, function(inst) StartFlap(inst) end),
		TimeEvent(0, function(inst)	inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/glommer/hurt_voice") end)
	},
	deathtimeline =
	{
		TimeEvent(0, function(inst) StartFlap(inst) end),
		TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/glommer/die_voice") end),
		TimeEvent(10*FRAMES, function(inst) StopFlap(inst) end),
        TimeEvent(10*FRAMES, LandFlyingCreature),
		TimeEvent(18*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/glommer/die_ground") end)
	},
})
CommonStates.AddWalkStates(states,
{
	starttimeline = {TimeEvent(0, function(inst) StartFlap(inst) end)},
	walktimeline = {TimeEvent(0, function(inst) StartFlap(inst) end)},
	endtimeline = {TimeEvent(0, function(inst) StartFlap(inst) end)},
})
CommonStates.AddSleepStates(states,
{
	starttimeline = {TimeEvent(0, function(inst) StartFlap(inst) end)},
	sleeptimeline =
		{
			TimeEvent(0*FRAMES, function(inst) StopFlap(inst) end),
			TimeEvent(35*FRAMES, function(inst) StartFlap(inst) end),
			TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/glommer/sleep_voice") end)
		},
	endtimeline = {TimeEvent(0, function(inst) StartFlap(inst) end)},
},
{
    onsleep = LandFlyingCreature,
    onwake = RaiseFlyingCreature,
})

return StateGraph("glommer", states, events, "idle", actionhandlers)