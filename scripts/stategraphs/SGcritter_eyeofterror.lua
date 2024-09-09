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

local function lower_flying_creature(inst)
    inst:RemoveTag("flying")
    inst:PushEvent("on_landed")
end

local function raise_flying_creature(inst)
    inst:AddTag("flying")
    inst:PushEvent("on_no_longer_landed")
end

local sound_path = "terraria1/mini_eyeofterror/"

local states =
{
}

local emotes =
{
    {
        anim = "emote1",
        timeline =
        {
            TimeEvent(0, function(inst)
                inst.SoundEmitter:PlaySound(sound_path .. "emote1")
            end),
        },
    },
    {
        anim = "emote2",
        timeline =
        {
            TimeEvent(0, function(inst)
                inst.SoundEmitter:PlaySound(sound_path .. "emote2")
            end),
            TimeEvent(11*FRAMES, lower_flying_creature),
            TimeEvent(71*FRAMES, raise_flying_creature),
        },
    },
}

SGCritterStates.AddIdle(states, #emotes)
SGCritterStates.AddRandomEmotes(states, emotes)

SGCritterStates.AddEmote(states, "cute",
{
    TimeEvent(0, function(inst)
        inst.SoundEmitter:PlaySound(sound_path .. "emote_cute")
    end),
})

SGCritterStates.AddPetEmote(states,
{
    TimeEvent(0, function(inst)
        inst.SoundEmitter:PlaySound(sound_path .. "emote_pet")
    end),
    TimeEvent(5*FRAMES, lower_flying_creature),
    TimeEvent(33*FRAMES, raise_flying_creature),
},
raise_flying_creature)

SGCritterStates.AddCombatEmote(states,
{
    pre =
    {
        TimeEvent(0, function(inst)
            inst.SoundEmitter:PlaySound(sound_path .. "emote_combat")
        end),
    },
})
SGCritterStates.AddPlayWithOtherCritter(states, events,
{
    active =
    {
        TimeEvent(0, function(inst)
            inst.SoundEmitter:PlaySound(sound_path .. "interact_active")
        end),
    },
    passive =
    {
        TimeEvent(0, function(inst)
            inst.SoundEmitter:PlaySound(sound_path .. "interact_active")
        end),
    },
})
SGCritterStates.AddEat(states,
{
    TimeEvent(22*FRAMES, lower_flying_creature),
    TimeEvent(26*FRAMES, function(inst)
        inst.SoundEmitter:PlaySound(sound_path .. "eat_lp", "eat_loop")
    end),
    TimeEvent(58*FRAMES, function(inst)
        inst.SoundEmitter:KillSound("eat_loop")
        inst.SoundEmitter:PlaySound(sound_path .. "eat_pst")
    end),
    TimeEvent(84*FRAMES, raise_flying_creature),
},
{
    onenter = function(inst)
        inst.SoundEmitter:PlaySound(sound_path .. "eat_pre")
    end,
    onexit = raise_flying_creature,
})
SGCritterStates.AddHungry(states,
{
    TimeEvent(0, function(inst)
        inst.SoundEmitter:PlaySound(sound_path .. "distress")
    end),
})
SGCritterStates.AddNuzzle(states, actionhandlers,
{
    TimeEvent(6*FRAMES, lower_flying_creature),
    TimeEvent(45*FRAMES, raise_flying_creature),
},
{
    onenter = function(inst)
        inst.SoundEmitter:PlaySound(sound_path .. "emote_nuzzle")
    end,
})

SGCritterStates.AddWalkStates(states, nil, true)

CommonStates.AddSleepExStates(states,
{
    starttimeline =
    {
        TimeEvent(36*FRAMES, lower_flying_creature),
    },
    waketimeline =
    {
        TimeEvent(22*FRAMES, raise_flying_creature),
    },
},
{
    onsleep = function(inst)
        inst.SoundEmitter:PlaySound("terraria1/mini_eyeofterror/sleep_pre")
    end,
    onwake = function(inst)
        inst.SoundEmitter:PlaySound("terraria1/mini_eyeofterror/sleep_pst")
    end,
    onexitwake = raise_flying_creature,
})

return StateGraph("SGcritter_eyeofterror", states, events, "idle", actionhandlers)
