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
    CommonHandlers.OnHop(),
	CommonHandlers.OnSink(),
}

local states =
{
}

local emotes =
{
	{ anim="emote_stretch",
      timeline=
 		{
			TimeEvent(22*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/yawn") end),
		},
	},
	{ anim="emote_lick",
      timeline=
 		{
			TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/emote_lick") end),
			TimeEvent(36*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/emote_lick") end),
			TimeEvent(58*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/emote_lick") end),
		},
	},
}

SGCritterStates.AddIdle(states, #emotes)
SGCritterStates.AddRandomEmotes(states, emotes)
SGCritterStates.AddEmote(states, "cute",
		{
			TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/emote") end),
			TimeEvent(26*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/emote") end),
		})
SGCritterStates.AddPetEmote(states,
	{
		TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/emote_nuzzle") end),
	})
SGCritterStates.AddCombatEmote(states,
		{
			loop =
			{
				TimeEvent(19*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/hiss") end),
			},
		})
SGCritterStates.AddPlayWithOtherCritter(states, events,
	{
		active =
		{
			TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/pounce") end),
			TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/pounce") end),
			TimeEvent(28*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/pounce") end),
			TimeEvent(36*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/pounce") end),
			TimeEvent(48*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/pounce") end),
			TimeEvent(60*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/pounce") end),
		},
	})
SGCritterStates.AddEat(states,
        {
            TimeEvent(21*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/eat") end),
        })
SGCritterStates.AddHungry(states,
        {
            TimeEvent(23*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/disstress") end),
            TimeEvent(43*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/disstress") end),
        })
SGCritterStates.AddNuzzle(states, actionhandlers,
        {
            TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/emote_nuzzle") end),
        })

SGCritterStates.AddWalkStates(states, nil, true)
CommonStates.AddSleepExStates(states,
		{
			starttimeline =
			{
				TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/yawn") end),
			},
			sleeptimeline =
			{
				TimeEvent(31*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/sleep") end),
			},
		})

CommonStates.AddHopStates(states, true)
CommonStates.AddSinkAndWashAshoreStates(states)

return StateGraph("SGcritter_kitten", states, events, "idle", actionhandlers)
