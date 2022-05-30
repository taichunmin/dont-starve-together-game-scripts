require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "gohome"),
}

local events =
{
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnLocomote(false,true),
    EventHandler("locomote",
        function(inst)
            if not inst.sg:HasStateTag("idle") and not inst.sg:HasStateTag("moving") then return end

            local is_moving = inst.sg:HasStateTag("moving")
            local is_running = inst.sg:HasStateTag("running")
            local is_idling = inst.sg:HasStateTag("idle")

            local should_move = inst.components.locomotor:WantsToMoveForward()
            local should_run = inst.components.locomotor:WantsToRun()

            if not should_move then
                if not inst.sg:HasStateTag("idle") then
                    if not inst.sg:HasStateTag("running") then
                        inst.sg:GoToState("idle")
                    elseif is_moving then
                        inst.sg:GoToState(is_running and "run_stop" or "walk_stop")
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            elseif should_run then
                if not inst.sg:HasStateTag("running") then
                    inst.sg:GoToState("scare")
                end
            else
                if not inst.sg:HasStateTag("moving") then
                    inst.sg:GoToState("walk_start")
                end
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
            if inst.tailGrowthPending then
                inst.sg:GoToState("regrow_tail")
            else
                inst.AnimState:PlayAnimation("idle_loop")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "walk_start",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("walk_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),
        },
    },

    State{
        name = "walk",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk_loop")
        end,
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),
        },
        timeline=
        {
            TimeEvent(FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(8*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(15*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(23*FRAMES, function(inst) PlayFootstep(inst) end),
        },
    },

    State{
        name = "walk_stop",
        tags = {"canrotate"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("walk_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },

    State{
        name = "run_start",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("walk_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),
        },
    },

    State{
        name = "scare",
        tags = {"moving", "canrotate","running"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("tail_off")
        end,
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),
        },
        timeline=
        {
            TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/grass_gekko/tail_off") end),

            TimeEvent(4*FRAMES, function(inst)
                if inst.hasTail then
                    inst.components.lootdropper:SpawnLootPrefab("cutgrass")
                    inst.hasTail = false
                    inst.components.timer:StartTimer("growTail", TUNING.GRASSGEKKO_REGROW_TIME )
                end
            end),

            TimeEvent(15*FRAMES, function(inst) inst.sg:GoToState("run") end),
        },
        onexit = function(inst)
            if not inst.hasTail then
                inst.AnimState:Hide("tail")
            end
        end,
    },

    State{
        name = "run",
        tags = {"moving", "canrotate","running"},

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_loop")
        end,
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),
        },
        timeline=
        {
            TimeEvent(FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(8*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(15*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(23*FRAMES, function(inst) PlayFootstep(inst) end),
        },
    },

    State{
        name = "run_stop",
        tags = {"canrotate"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("run_pst")
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },

    State{
        name = "regrow_tail",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("tail_regrow")
            inst.tailGrowthPending = nil
            inst.AnimState:Show("tail")
            inst.hasTail = true
        end,
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
        timeline=
        {
            TimeEvent(5*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/grass_gekko/tail_regrow")
            end),
        },
    },

    State{
        name = "emerge",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()

            local player = inst:GetNearestPlayer()
            if player ~= nil and inst:IsNear(player, 7) then
                inst:FaceAwayFromPoint(player:GetPosition(), true)
            else
                inst.Transform:SetRotation(math.random(360))
            end

            inst.AnimState:PlayAnimation("gecko_pop")
        end,

        timeline =
        {
            TimeEvent(12 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds")
            end),
            TimeEvent(32 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/grass_gekko/emerge")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },
}

--inst.components.locomotor:WantsToRun()

CommonStates.AddCombatStates(states,
{
    hittimeline = {
        TimeEvent(5*FRAMES, function(inst) inst.sg:GoToState("run") end),
    },

    deathtimeline =
    {
        TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/grass_gekko/death") end),
        TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/grass_gekko/body_fall") end),
    },
})

CommonStates.AddSleepStates(states,
{
    starttimeline =
    {
        TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/grass_gekko/sleep_pre") end)
    },

    sleeptimeline =
    {
        TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/grass_gekko/sleep") end),
        TimeEvent(28*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/grass_gekko/sleep") end)
    },

    waketimeline =
    {
        TimeEvent(1*FRAMES, function(inst)
                if inst.components.locomotor:WantsToRun() then
                    inst.sg:GoToState("scare")
                end
            end),
        TimeEvent(12*FRAMES, function(inst) inst.sg:GoToState("idle") end),
    },
})
CommonStates.AddFrozenStates(states)

return StateGraph("grassgekko", states, events, "idle", actionhandlers)
