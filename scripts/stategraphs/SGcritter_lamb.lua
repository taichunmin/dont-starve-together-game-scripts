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
	{ anim="emote_shuffle",
      timeline=
		{
			TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/sheepington/walk") end),
			TimeEvent(19*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/sheepington/walk") end),
			TimeEvent(25*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/sheepington/walk") end),
			TimeEvent(30*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/sheepington/walk") end),
		},
    },
	{ anim="emote_stallion",
      timeline=
 		{
            TimeEvent(24*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/sheepington/stallion") end),
			TimeEvent(24*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/sheepington/grunt") end),
            TimeEvent(28*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/sheepington/stallion") end),
            TimeEvent(40*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/sheepington/stallion") end),
			TimeEvent(40*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/sheepington/grunt") end),
            TimeEvent(45*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/sheepington/stallion") end),
		},
	},
}

SGCritterStates.AddIdle(states, #emotes)
SGCritterStates.AddRandomEmotes(states, emotes)
SGCritterStates.AddEmote(states, "cute",
        {
            TimeEvent(28*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/sheepington/yell") end),
        })
SGCritterStates.AddPetEmote(states,
        {
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/sheepington/yell") end),
        })
SGCritterStates.AddCombatEmote(states, nil)
SGCritterStates.AddPlayWithOtherCritter(states, events, nil)
SGCritterStates.AddEat(states,
        {
            TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/sheepington/curious") end),

            TimeEvent((22+16)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/sheepington/chew") end),
        })
SGCritterStates.AddHungry(states,
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/sheepington/angry") end),
        })
SGCritterStates.AddNuzzle(states, actionhandlers,
        {
            TimeEvent(19*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/sheepington/grunt") end),
        })

SGCritterStates.AddWalkStates(states,
	{
		walktimeline =
		{
			TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/sheepington/walk") end),
		},
		endtimeline =
		{
			TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/sheepington/walk") end),
		},
	}, true)
CommonStates.AddSleepExStates(states,
		{
			starttimeline =
			{
				TimeEvent(22*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/sheepington/bodyfall") end),
			},
			sleeptimeline =
			{
				TimeEvent(22*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/sheepington/sleep") end),
				TimeEvent(57*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/sheepington/sleep") end),
			},
		})

CommonStates.AddHopStates(states, true)
CommonStates.AddSinkAndWashAshoreStates(states)

return StateGraph("SGcritter_lamb", states, events, "idle", actionhandlers)
