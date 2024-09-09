require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.GIVE, "give"),
    ActionHandler(ACTIONS.GIVEALLTOPLAYER, "give"),
    ActionHandler(ACTIONS.DROP, "give"),
    ActionHandler(ACTIONS.PICKUP, "pickup"),
    ActionHandler(ACTIONS.CHECKTRAP, "pickup"),
}

local events =
{
    CommonHandlers.OnSleepEx(),
	CommonHandlers.OnWakeEx(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),

    EventHandler("locomote", function(inst)
        local is_moving = inst.sg:HasStateTag("moving")
        local is_running = inst.sg:HasStateTag("running")
        local is_idling = inst.sg:HasStateTag("idle")

        local should_move = inst.components.locomotor:WantsToMoveForward()
        local should_run = inst.components.locomotor:WantsToRun()

        if is_moving and not should_move then
            inst.sg:GoToState(is_running and "run_stop" or "walk_stop")
        elseif (is_idling and should_move) or (is_moving and should_move and is_running ~= should_run) then
            inst.sg:GoToState((should_run and "run_start") or "walk_start")
        end
    end),

    EventHandler("stunbomb", function(inst)
        inst.sg:GoToState("stunned")
    end),
}

local states =
{
    State {
        name = "idle",
        tags = { "idle", "canrotate" },
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("idle1", true)
            elseif not inst.AnimState:IsCurrentAnimation("idle1") then
                inst.AnimState:PlayAnimation("idle1", true)
            end
            inst.sg:SetTimeout(1 + math.random()*1)
        end,

        ontimeout= function(inst)
            if math.random() > 0.55 then
                inst.sg:GoToState("idle2")
            else
                inst.sg:GoToState("idle")
            end
        end,
    },

    State {
        name = "idle2",
        tags = { "idle", "canrotate" },
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle2", false)
        end,

        timeline =
        {
            TimeEvent(10*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.idle)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State {
        name = "pickup",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:SetActive(false)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat_pre", false)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle") 
                end
            end),
        },
        
        timeline =
        {
            FrameEvent(9, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        onexit = function(inst)
            inst.Physics:SetActive(true)
        end,
    },

    State {
        name = "give",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:SetActive(false)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("lose_small_pre", false)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
        
        timeline =
        {
            FrameEvent(7, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        onexit = function(inst)
            inst.Physics:SetActive(true)
        end,
    },

    State {
        name = "stunned",
        tags = { "busy", "stunned" },

        onenter = function(inst, dont_play_sound)
            inst.Physics:Stop()
            if not dont_play_sound then
                inst.SoundEmitter:PlaySound(inst.sounds.stunned)
            end
            inst.AnimState:PlayAnimation("stunned_loop", true)
            inst.sg:SetTimeout(GetRandomWithVariance(6, 2))
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", "stunned_pst")
        end,
    },

    State {
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()

            inst.AnimState:PlayAnimation("death")
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(inst:GetPosition())
        end,

        timeline =
        {
            TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.death) end),
        },
    },
}
CommonStates.AddSleepExStates(states,
{
    sleeptimeline =
    {
        TimeEvent(11 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.sleep) end),
    },
})
CommonStates.AddFrozenStates(states)
CommonStates.AddHitState(states)
CommonStates.AddWalkStates(states,
{
    starttimeline =
    {
        TimeEvent(3*FRAMES, PlayFootstep),
    },
    walktimeline =
    {
        TimeEvent(1*FRAMES, PlayFootstep),
        TimeEvent(3*FRAMES, PlayFootstep),
        TimeEvent(5*FRAMES, PlayFootstep),
        TimeEvent(7*FRAMES, PlayFootstep),
    },
    endtimeline =
    {
        TimeEvent(0*FRAMES, PlayFootstep),
    },
})
CommonStates.AddRunStates(states,
{
    starttimeline =
    {
        TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.stunned) end),
    },
    runtimeline =
    {
        TimeEvent(0, PlayFootstep),
    },
    endtimeline =
    {
        TimeEvent(0, PlayFootstep),
    },
})

return StateGraph("wormwood_carrat", states, events, "idle", actionhandlers)
