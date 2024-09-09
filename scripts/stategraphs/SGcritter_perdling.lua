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
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnHop(),
	CommonHandlers.OnSink(),
}

local states =
{
}

local emotes =
{
    {
        anim = "emote1",
        timeline =
        {
            TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/perdling/walk") end),
        },
    },
    {
        anim = "emote2",
        timeline =
        {
            TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/perdling/nuzzle") end),
            TimeEvent(5*FRAMES, PlayFootstep),
            TimeEvent(18*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/perdling/nuzzle") end),
            TimeEvent(19*FRAMES, PlayFootstep),
            TimeEvent(25*FRAMES, PlayFootstep),
            TimeEvent(31*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/perdling/nuzzle") end),
            TimeEvent(33*FRAMES, PlayFootstep),
        },
    },
}

SGCritterStates.AddIdle(states, #emotes)
SGCritterStates.AddRandomEmotes(states, emotes)
SGCritterStates.AddEmote(states, "cute",
    {
        TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/perdling/wingflap") end),
        TimeEvent(21*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/perdling/wingflap") end),
        TimeEvent(39*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/perdling/wingflap") end),
        TimeEvent(22*FRAMES, PlayFootstep),
        TimeEvent(40*FRAMES, PlayFootstep),
    })
SGCritterStates.AddPetEmote(states,
    {
        TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/perdling/wingflap") end),
        TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/perdling/wingflap") end),
    })
SGCritterStates.AddCombatEmote(states)
SGCritterStates.AddPlayWithOtherCritter(states, events,
    {
        active =
        {
            TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/perdling/distress") end),
        },
    })
SGCritterStates.AddEat(states,
    {
        TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/perdling/eat_pre") end),
    })
SGCritterStates.AddHungry(states,
    {
        TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.skin_hungry_sound or "dontstarve/creatures/together/perdling/distress_long") end),
    })
SGCritterStates.AddNuzzle(states, actionhandlers,
    {
        TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/perdling/nuzzle") end),
    })

SGCritterStates.AddWalkStates(states,
    {
        walktimeline =
        {
            TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/perdling/walk") end),
            TimeEvent(15*FRAMES, PlayFootstep),
        },
    }, true)

CommonStates.AddSleepExStates(states,
    {
        starttimeline =
        {
            TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/perdling/sleep_pre") end),
        },
        sleeptimeline =
        {
            TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/perdling/sleep_in") end),
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/perdling/sleep_out") end),
        },
    })

CommonStates.AddHopStates(states, true)
CommonStates.AddSinkAndWashAshoreStates(states)

return StateGraph("SGcritter_perdling", states, events, "idle", actionhandlers)
