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
	{ anim="emote1",
      timeline=
		{
			TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/emote1") end),
		},
	},
	{ anim="emote2",
      timeline=
		{
			TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/emote2") end),
		},
	},
	{ anim="emote_nuzzle",
      timeline=
		{
            TimeEvent(2*FRAMES, LandFlyingCreature),
			TimeEvent(52*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/emote_nuzzle") end),
            TimeEvent(50*FRAMES, RaiseFlyingCreature),
		},
	},
}

local idle_anim_weights = {3, 2, 1}
local function idle_anim_fn(inst)
	local num = weighted_random_choice(idle_anim_weights)
	inst.sg.statemem.anim_num = num
	return num == 1 and "idle_loop" or ("idle_loop"..num)
end

SGCritterStates.AddIdle(states, #emotes,
	{
		TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/idle") end),
		TimeEvent(2*FRAMES, function(inst) if inst.sg.statemem.anim_num == 3 then inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/flap_fast") end end),
	},
	idle_anim_fn)

SGCritterStates.AddRandomEmotes(states, emotes)
SGCritterStates.AddEmote(states, "cute",
	{
		TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/emote_cute") end),
		TimeEvent(6*FRAMES, LandFlyingCreature),
        TimeEvent(57*FRAMES, RaiseFlyingCreature),
	})
SGCritterStates.AddCombatEmote(states,
	{
		pre =
		{
			TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/emote_combat") end),
            TimeEvent(10*FRAMES, LandFlyingCreature),
		},
		loop =
		{
            TimeEvent(0*FRAMES, LandFlyingCreature),
		},
		pst =
		{
            TimeEvent(0*FRAMES, LandFlyingCreature),
            TimeEvent(8*FRAMES, RaiseFlyingCreature),
		},
	})
SGCritterStates.AddPlayWithOtherCritter(states, events,
	{
		active =
		{
			TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/interact_active") end),
		},
		passive =
		{
            TimeEvent(8*FRAMES, LandFlyingCreature),
			TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/interact_passive") end),
			TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/vo_cute") end),
			TimeEvent(38*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/vo_cute") end),
            TimeEvent(62*FRAMES, RaiseFlyingCreature),
		},
	},
    {
        inactive = RaiseFlyingCreature,
    })
SGCritterStates.AddEat(states,
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/eat_pre") end),
        TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/vo_cute") end),

        TimeEvent(26*FRAMES, LandFlyingCreature),

        TimeEvent((28+0)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/eat_LP") end),

        TimeEvent((28+10)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/eat_LP") end),

        TimeEvent((28+24+0)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/eat_LP") end),

        TimeEvent((28+24+10)*FRAMES, RaiseFlyingCreature),
    })
SGCritterStates.AddHungry(states,
    {
        TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/distress") end),
    })
SGCritterStates.AddNuzzle(states, actionhandlers,
	{
        TimeEvent(2*FRAMES, LandFlyingCreature),
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/emote_nuzzle") end),
        -- `TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/vo_cute") end),
        TimeEvent(23*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/vo_cute") end),

        TimeEvent(50*FRAMES, RaiseFlyingCreature),
    })


SGCritterStates.AddWalkStates(states,
	{
		--- this isn't working Scott
		walktimeline =
		{
			TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/walk") end),
		},
	}, true)


SGCritterStates.AddWalkStates(states, nil, true)
local function StartFlapping(inst)
    -- inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/fly_LP", "flying")
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
		TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/emote_pet") end),
		TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/vo_cute") end),
		TimeEvent(24*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/vo_cute") end),
		TimeEvent(46*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/vo_cute") end),
        -- TimeEvent(4*FRAMES, function(inst) end),
            -- StopFlapping(inst)
            -- LandFlyingCreature(inst)

		-- TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/emote") end),
        -- TimeEvent(27*FRAMES, StartFlapping),
        -- TimeEvent(50*FRAMES, RaiseFlyingCreature),
	},
    function(inst)
        RestoreFlapping(inst)
        RaiseFlyingCreature(inst)
    end)

CommonStates.AddSleepExStates(states,
	{
		starttimeline =
		{
			TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/sleep_pre") end),
            TimeEvent(18*FRAMES, LandFlyingCreature),
            TimeEvent(31*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/sleep_in") end),
            TimeEvent(44*FRAMES, StopFlapping),
		},
		sleeptimeline =
		{
			TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/sleep_out") end),
			TimeEvent(32*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/sleep_in") end),
		},
		waketimeline =
		{
			TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/creatures/together/lunarmothling/sleep_pst") end),
            TimeEvent(12*FRAMES, StartFlapping),
            TimeEvent(18*FRAMES, RaiseFlyingCreature),
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

return StateGraph("SGcritter_lunarmoth", states, events, "idle", actionhandlers)
