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

local emotes =
{
	{ anim="emote_bounce",
      timeline=
		{
            TimeEvent(12*FRAMES, LandFlyingCreature),
			TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/buttstomp") inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/buttstomp_voice") end),
			TimeEvent(28*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/buttstomp") inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/buttstomp_voice") end),
			TimeEvent(43*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/buttstomp") inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/buttstomp_voice") end),
            TimeEvent(46*FRAMES, RaiseFlyingCreature),
		},
	},
	{ anim="emote_yawn",
      timeline=
		{
			TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/blink") end),
			TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/sleep_pre") end),
		},
	},
	{ anim="emote_flame",
      timeline=
		{
			TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/blink") end),
			TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/emote_flame") end),
		},
	},
}

SGCritterStates.AddIdle(states, #emotes)
SGCritterStates.AddRandomEmotes(states, emotes)
SGCritterStates.AddEmote(states, "cute",
		{
			TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/blink") end),
			TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/blink") end),
			TimeEvent(24*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/swipe") end),
			TimeEvent(42*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/blink") end),
			TimeEvent(59*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/blink") end),
		})
SGCritterStates.AddCombatEmote(states,
		{
			pre =
			{
				TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/emote_combat") end),
			},
			loop =
			{
				TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/emote_combat_2") end),
			},
			pst =
			{
				TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/blink") end),
			},
		})
SGCritterStates.AddPlayWithOtherCritter(states, events,
	{
		active =
		{
			TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/emote") end),
			TimeEvent(33*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/emote") end),
		},
		passive =
		{
			TimeEvent(57*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/blink") end),
		},
	})
SGCritterStates.AddEat(states,
        {
            TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/eat_pre") end),
            TimeEvent(24*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/blink") end),

            TimeEvent((28+0)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/eat") end),
            TimeEvent((28+10)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/eat") end),

            TimeEvent((28+24+0)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/eat") end),
            TimeEvent((28+24+6)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/blink") end),
        })
SGCritterStates.AddHungry(states,
        {
            TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/angry") end),
            TimeEvent(22*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/angry") end),
            TimeEvent(29*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/angry") end),
            TimeEvent(36*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/angry") end),
        })
SGCritterStates.AddNuzzle(states, actionhandlers,
		{
            TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/emote") end),
        })

SGCritterStates.AddWalkStates(states, nil, true)

local function StartFlapping(inst)
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/fly_LP", "flying")
end

local function RestoreFlapping(inst)
    if not inst.SoundEmitter:PlayingSound("flying") then
        StartFlapping(inst)
    end
end

local function StopFlapping(inst)
    inst.SoundEmitter:KillSound("flying")
end

local function CleanupIfSleepInterrupted(inst)
    if not inst.sg.statemem.continuesleeping then
        RestoreFlapping(inst)
    end
    RaiseFlyingCreature(inst)
end

SGCritterStates.AddPetEmote(states,
		{
			TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/blink") end),
            TimeEvent(4*FRAMES, function(inst)
                StopFlapping(inst)
                LandFlyingCreature(inst)
            end),
			TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/emote") end),
            TimeEvent(27*FRAMES, function(inst)
                StartFlapping(inst)
                RaiseFlyingCreature(inst)
            end),
		},
        function(inst)
            RestoreFlapping(inst)
            RaiseFlyingCreature(inst)
        end)

CommonStates.AddSleepExStates(states,
		{
			starttimeline =
			{
				TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/sleep_pre") end),
                TimeEvent(44*FRAMES, function(inst)
                    StopFlapping(inst)
                    LandFlyingCreature(inst)
                end),
				TimeEvent(48*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/sleep") end),
			},
			sleeptimeline =
			{
				TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/sleep") end),
				TimeEvent(52*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/sleep") end),
			},
			waketimeline =
			{
				TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/blink") end),
                TimeEvent(12*FRAMES, function(inst)
                    StartFlapping(inst)
                    RaiseFlyingCreature(inst)
                end),
			},
		},
        {
            onexitsleep = CleanupIfSleepInterrupted,
            onexitsleeping = CleanupIfSleepInterrupted,
            onsleeping = LandFlyingCreature,
            onexitwake = function(inst)
                RestoreFlapping(inst)
                RaiseFlyingCreature(inst)
            end,
            onwake = function(inst)
                StopFlapping(inst)
                LandFlyingCreature(inst)
            end,
        })

return StateGraph("SGcritter_dragonling", states, events, "idle", actionhandlers)
