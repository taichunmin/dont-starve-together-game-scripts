require("stategraphs/commonstates")

local events =
{
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnLocomote(true, true),

    EventHandler("doattack", function(inst, data)
        if inst.components.health ~= nil and not inst.components.health:IsDead()
            and (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("hit")) then

            inst.sg:GoToState("attack")
        end
    end),

	EventHandler("attacked", function(inst, data)
		if inst.components.health ~= nil and not inst.components.health:IsDead()
			and (not inst.sg:HasStateTag("busy") or
				inst.sg:HasStateTag("caninterrupt") or
				inst.sg:HasStateTag("frozen")) then
			inst.sg:GoToState("hit")
		end
	end),
}

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.SoundEmitter:PlaySound(inst.sounds.idle)
            inst.AnimState:PlayAnimation("idle_loop")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

	State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("attack")
            inst.components.combat:StartAttack()
            inst.sg.statemem.target = target
        end,

        timeline =
		{
			TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.attack) end),
			TimeEvent(22*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
            TimeEvent(28*FRAMES, function(inst) inst.sg:RemoveStateTag("busy") end),
		},

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
}
CommonStates.AddHitState(states,
{
    TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.onhit) end),
})

CommonStates.AddDeathState(states,
{
    TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.death) end),
    TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/grass_gekko/body_fall") end),
})

CommonStates.AddWalkStates(states,
{
    starttimeline =
    {
    },
    walktimeline =
    {
        TimeEvent(0,            PlayFootstep),
        TimeEvent(4*FRAMES,     PlayFootstep),
        TimeEvent(12*FRAMES,    PlayFootstep),
    },
    endtimeline =
    {
        TimeEvent(0,            PlayFootstep),
    },
}
, nil, nil, true)

CommonStates.AddRunStates(states,
{
    runtimeline =
    {
        TimeEvent(6*FRAMES,     PlayFootstep),
        TimeEvent(10*FRAMES,    PlayFootstep),
    },
    endtimeline =
    {
        TimeEvent(0,            PlayFootstep),
    },
})

CommonStates.AddSleepStates(states,
{
    starttimeline =
    {
        TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.stretch) end)
    },

    sleeptimeline =
    {
        TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.sleep_loop) end),
        TimeEvent(32*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.sleep_loop) end),
    },

    waketimeline =
    {
        TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.stretch) end),
    },
})

CommonStates.AddFrozenStates(states)

return StateGraph("fruit_dragon", states, events, "idle")
