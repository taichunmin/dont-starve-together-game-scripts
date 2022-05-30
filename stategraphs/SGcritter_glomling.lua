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

local sound_path = "dontstarve_DLC001/creatures/together/glomling/"
local function StartFlapping(inst)
    inst.SoundEmitter:PlaySound( (inst.skin_sound or sound_path) .. "flap_LP", "flying")
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
			TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound( (inst.skin_sound or sound_path) .. "bounce_voice" ) end),
		},
	},
	{ anim="emote2",
      timeline=
		{
            TimeEvent(7*FRAMES, function(inst)
                StopFlapping(inst)
                LandFlyingCreature(inst)
            end),
			TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound( (inst.skin_sound or sound_path) .. "bounce_ground" ) end),
			TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound( (inst.skin_sound or sound_path) .. "bounce_ground" ) end),
			TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound( (inst.skin_sound or sound_path) .. "emote_2" ) end),
            TimeEvent(68*FRAMES, function(inst)
                StartFlapping(inst)
                RaiseFlyingCreature(inst)
            end),
		},
      fns=
        {
            onexit = function(inst)
                RestoreFlapping(inst)
                RaiseFlyingCreature(inst)
            end,
        },
	},
}

SGCritterStates.AddIdle(states, #emotes)
SGCritterStates.AddRandomEmotes(states, emotes)
SGCritterStates.AddEmote(states, "cute",
		{
            TimeEvent(5*FRAMES, LandFlyingCreature),
			TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound( (inst.skin_sound or sound_path) .. "bounce_ground" ) end),
			TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound( (inst.skin_sound or sound_path) .. "bounce_voice" ) end),
            TimeEvent(11*FRAMES, RaiseFlyingCreature),
            TimeEvent(20*FRAMES, LandFlyingCreature),
			TimeEvent(21*FRAMES, function(inst) inst.SoundEmitter:PlaySound( (inst.skin_sound or sound_path) .. "bounce_ground" ) end),
			TimeEvent(21*FRAMES, function(inst) inst.SoundEmitter:PlaySound( (inst.skin_sound or sound_path) .. "bounce_voice" ) end),
            TimeEvent(27*FRAMES, RaiseFlyingCreature),
            TimeEvent(45*FRAMES, LandFlyingCreature),
			TimeEvent(46*FRAMES, function(inst) inst.SoundEmitter:PlaySound( (inst.skin_sound or sound_path) .. "bounce_ground" ) end),
			TimeEvent(47*FRAMES, function(inst) inst.SoundEmitter:PlaySound( (inst.skin_sound or sound_path) .. "bounce_voice" ) end),
            TimeEvent(51*FRAMES, RaiseFlyingCreature),
		})
SGCritterStates.AddPetEmote(states,
	{
		TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound( (inst.skin_sound or sound_path) .. "emote_2" ) end),
	})
SGCritterStates.AddCombatEmote(states,
		{
			loop =
			{
				TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound( (inst.skin_sound or sound_path) .. "emote_combat" ) end),
				TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound( (inst.skin_sound or sound_path) .. "emote_combat" ) end),
			},
			pst =
			{
				TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound( (inst.skin_sound or sound_path) .. "emote_combat" ) end),
			},
		})
SGCritterStates.AddPlayWithOtherCritter(states, events,
		{
			active =
			{
				TimeEvent(16*FRAMES, StopFlapping),
				TimeEvent(24*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/pupington/clap" ) end),
				TimeEvent(29*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/pupington/clap" ) end),
				TimeEvent(36*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/pupington/clap" ) end),
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
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound( (inst.skin_sound or sound_path) .. "bounce_ground" ) end),
            TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound( (inst.skin_sound or sound_path) .. "bounce_voice" ) end),

            TimeEvent(20*FRAMES, LandFlyingCreature),
            TimeEvent(22*FRAMES, StopFlapping),

            TimeEvent((26+8)*FRAMES, function(inst) inst.SoundEmitter:PlaySound( (inst.skin_sound or sound_path) .. "eat_loop" ) end),
            TimeEvent((26+22)*FRAMES, function(inst) inst.SoundEmitter:PlaySound( (inst.skin_sound or sound_path) .. "eat_loop" ) end),

            TimeEvent(74*FRAMES, StartFlapping),
            TimeEvent(82*FRAMES, RaiseFlyingCreature),
        },
        {
            onexit = function(inst)
                RestoreFlapping(inst)
                RaiseFlyingCreature(inst)
            end,
        })
SGCritterStates.AddHungry(states,
        {
            TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound( (inst.skin_sound or sound_path) .. "vomit_voice" ) end),
            TimeEvent(24*FRAMES, function(inst) inst.SoundEmitter:PlaySound( (inst.skin_sound or sound_path) .. "vomit_voice" ) end),
            TimeEvent(36*FRAMES, function(inst) inst.SoundEmitter:PlaySound( (inst.skin_sound or sound_path) .. "vomit_voice" ) end),
        })
SGCritterStates.AddNuzzle(states, actionhandlers,
		{
            TimeEvent(6*FRAMES, function(inst)
                StopFlapping(inst)
                LandFlyingCreature(inst)
                inst.SoundEmitter:PlaySound( (inst.skin_sound or sound_path) .. "bounce_ground" )
            end),
            TimeEvent(45*FRAMES, RaiseFlyingCreature),
            TimeEvent(53*FRAMES, StartFlapping),
        },
        {
            onexit = function(inst)
                RestoreFlapping(inst)
                RaiseFlyingCreature(inst)
            end,
        })

SGCritterStates.AddWalkStates(states, nil, true)


local function CleanupIfSleepInterrupted(inst)
    if not inst.sg.statemem.continuesleeping then
        RestoreFlapping(inst)
    end
    RaiseFlyingCreature(inst)
end

CommonStates.AddSleepExStates(states,
		{
			starttimeline =
			{
				TimeEvent(35*FRAMES, function(inst)
                    StopFlapping(inst)
                    LandFlyingCreature(inst)
                    inst.SoundEmitter:PlaySound( (inst.skin_sound or sound_path) .. "bounce_ground" )
                end),
			},
			sleeptimeline =
			{
				TimeEvent(41*FRAMES, function(inst) inst.SoundEmitter:PlaySound( (inst.skin_sound or sound_path) .. "sleep_voice" ) end),
			},
            waketimeline =
            {
                TimeEvent(12 * FRAMES, StartFlapping),
                TimeEvent(16*FRAMES, RaiseFlyingCreature),
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

return StateGraph("SGcritter_glomling", states, events, "idle", actionhandlers)
