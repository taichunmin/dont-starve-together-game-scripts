require("stategraphs/commonstates")
require("stategraphs/SGcritter_common")

local actionhandlers =
{
}

local events =
{
	SGCritterEvents.OnEat(),
    SGCritterEvents.OnAvoidCombat(),
	SGCritterEvents.OnTraitChanged(),

    CommonHandlers.OnSleepEx(),
    CommonHandlers.OnWakeEx(),
    CommonHandlers.OnLocomote(false,true),
}

local states =
{
}

local function StartFlapping(inst)
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/glomling/flap_LP", "flying")
end

local function RestoreFlapping(inst)
    if not inst.SoundEmitter:PlayingSound("flying") then
        StartFlapping(inst)
    end
end

local function StopFlapping(inst)
    inst.SoundEmitter:KillSound("flying")
end

local emotes =
{
	{ anim="emote1",
      timeline=
		{
			TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/glomling/bounce_voice") end),
		},
	},
	{ anim="emote2",
      timeline=
		{
            TimeEvent(7*FRAMES, StopFlapping),
			TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/glomling/bounce_ground") end),
			TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/glomling/bounce_ground") end),
			TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/glomling/emote_2") end),
            TimeEvent(68*FRAMES, StartFlapping),
		},
      fns=
        {
            onexit = RestoreFlapping,
        },
	},
}

SGCritterStates.AddIdle(states, #emotes)
SGCritterStates.AddRandomEmotes(states, emotes)
SGCritterStates.AddEmote(states, "cute", 
		{
			TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/glomling/bounce_ground") end),
			TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/glomling/bounce_voice") end),
			TimeEvent(21*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/glomling/bounce_ground") end),
			TimeEvent(21*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/glomling/bounce_voice") end),
			TimeEvent(46*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/glomling/bounce_ground") end),
			TimeEvent(47*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/glomling/bounce_voice") end),
		})
SGCritterStates.AddPetEmote(states, 
	{
		TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/glomling/emote_2") end),
	})
SGCritterStates.AddCombatEmote(states,
		{
			loop =
			{
				TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/glomling/emote_combat") end),
				TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/glomling/emote_combat") end),
			},
			pst =
			{
				TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/glomling/emote_combat") end),
			},
		})
SGCritterStates.AddPlayWithOtherCritter(states, events,
		{
			active =
			{
				TimeEvent(16*FRAMES, StopFlapping),
				TimeEvent(24*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/pupington/clap") end),
				TimeEvent(29*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/pupington/clap") end),
				TimeEvent(36*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/pupington/clap") end),
				TimeEvent(42*FRAMES, StartFlapping),
			},
		},
		{
			onexit =
			{
				 active = RestoreFlapping,
			},
		})
SGCritterStates.AddEat(states,
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/glomling/bounce_ground") end),
            TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/glomling/bounce_voice") end),

            TimeEvent(22*FRAMES, StopFlapping),

            TimeEvent((26+8)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/glomling/eat_loop") end),
            TimeEvent((26+22)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/glomling/eat_loop") end),

            TimeEvent(74*FRAMES, StartFlapping),
        },
        {
            onexit = RestoreFlapping,
        })
SGCritterStates.AddHungry(states,
        {
            TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/glomling/vomit_voice") end),
            TimeEvent(24*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/glomling/vomit_voice") end),
            TimeEvent(36*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/glomling/vomit_voice") end),
        })
SGCritterStates.AddNuzzle(states, actionhandlers,
		{
            TimeEvent(6*FRAMES, function(inst)
                StopFlapping(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/glomling/bounce_ground")
            end),
            TimeEvent(53*FRAMES, StartFlapping),
        },
        {
            onexit = RestoreFlapping,
        })

SGCritterStates.AddWalkStates(states, nil, true)


local function CleanupIfSleepInterrupted(inst)
    if not inst.sg.statemem.continuesleeping then
        RestoreFlapping(inst)
    end
end

CommonStates.AddSleepExStates(states,
		{
			starttimeline = 
			{
				TimeEvent(35*FRAMES, function(inst)
                    StopFlapping(inst)
                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/glomling/bounce_ground")
                end),
			},
			sleeptimeline = 
			{
				TimeEvent(41*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/glomling/sleep_voice") end),
			},
            endtimeline =
            {
                TimeEvent(12 * FRAMES, StartFlapping),
            },
        },
        {
            onexitsleep = CleanupIfSleepInterrupted,
            onexitsleeping = CleanupIfSleepInterrupted,
            onexitwake = RestoreFlapping,
            onwake = StopFlapping,
        })

return StateGraph("SGcritter_glomling", states, events, "idle", actionhandlers)
