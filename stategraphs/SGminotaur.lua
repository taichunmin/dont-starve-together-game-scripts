require("stategraphs/commonstates")

local events =
{
    CommonHandlers.OnLocomote(true, true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),

    EventHandler("doattack", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState(inst.sg:HasStateTag("running") and "runningattack" or "attack")
        end
    end),

    EventHandler("locomote", function(inst)
        if inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("attack") or inst.sg:HasStateTag("runningattack") then
            return
        end

        local is_moving = inst.sg:HasStateTag("moving")
        local is_running = inst.sg:HasStateTag("running") or inst.sg:HasStateTag("runningattack")
        local should_move = inst.components.locomotor:WantsToMoveForward()
        local should_run = inst.components.locomotor:WantsToRun()

        if is_moving and not should_move then
            inst.sg:GoToState(is_running and "run_stop" or "walk_stop")
        elseif (not is_moving and should_move) or (is_moving and should_move and is_running ~= should_run) then
            inst.sg:GoToState(should_run and "run_start" or "walk_start")
        end
    end),
}

local states =
{
     State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, playanim)
            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("idle", true)
            else
                inst.AnimState:PlayAnimation("idle", true)
            end

            inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/voice")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "run_start",
        tags = { "moving", "running", "busy", "atk_pre", "canrotate" },

        onenter = function(inst)
            inst.Physics:Stop()
            -- inst.components.locomotor:RunForward()
            inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/pawground")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/voice")
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PlayAnimation("paw_loop", true)
            inst.sg:SetTimeout(1.5)
        end,

        timeline =
        {
            TimeEvent(12 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/pawground") end),
            TimeEvent(30 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/pawground") end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("run")
            inst:PushEvent("attackstart")
        end,
    },

    State{
        name = "run",
        tags = { "moving", "running" },

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            if not inst.AnimState:IsCurrentAnimation("atk") then
                inst.AnimState:PlayAnimation("atk", true)
            end
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
            inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/step")
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/step") end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("run")
        end,
    },

    State{
        name = "run_stop",
        tags = { "canrotate", "idle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("gore")
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst)
                inst.components.combat:DoAttack()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

   State{
        name = "taunt",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/voice")
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/voice") end),
            TimeEvent(27 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/voice") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "runningattack",
        tags = { "runningattack" },

        onenter = function(inst)
            inst.components.combat:StartAttack()
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("gore")
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst.components.combat:DoAttack()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("attack")
            end),
        },
    },

    State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst)
            inst.components.combat:StartAttack()
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("gore")
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst)
                inst.components.combat:DoAttack()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "hit",
        tags = { "hit", "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("hit")
        end,

        timeline =
        {
            TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/hurt") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "death",
        tags = { "death", "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("death")
            inst.persists = false
            inst.components.lootdropper:DropLoot()

            local chest = SpawnPrefab("minotaurchestspawner")
            chest.Transform:SetPosition(inst.Transform:GetWorldPosition())
            chest.minotaur = inst

            inst:AddTag("NOCLICK")
        end,

        timeline =
        {
            TimeEvent(0, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/death")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/death_voice")
            end),
            TimeEvent(2, ErodeAway),
        },

        onexit = function(inst)
            --Should NOT happen!
            inst:RemoveTag("NOCLICK")
        end,
    },
}

CommonStates.AddWalkStates(states,
{
    starttimeline =
    {
        TimeEvent(0, function(inst)
            inst.Physics:Stop()
        end),
    },
    walktimeline =
    {
        TimeEvent(0, function(inst)
            inst.Physics:Stop()
        end),
        TimeEvent(7 * FRAMES, function(inst)
            inst.components.locomotor:WalkForward()
        end),
        TimeEvent(20 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/step")
            ShakeAllCameras(CAMERA.VERTICAL, .5, .05, .1, inst, 40)
            inst.Physics:Stop()
        end),
    },
}, nil, true)

CommonStates.AddSleepStates(states,
{
    starttimeline =
    {
        TimeEvent(11 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/liedown") end),
    },
    sleeptimeline =
    {
        TimeEvent(18 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/sleep") end),
    },
})

CommonStates.AddFrozenStates(states)

return StateGraph("rook", states, events, "idle")
