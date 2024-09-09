require("stategraphs/commonstates")

local events =
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true, false),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnIpecacPoop(),
    EventHandler("death", function(inst) inst.sg:GoToState("death", inst.sg.statemem.dead) end),
    EventHandler("giveuptarget", function(inst, data) if data.target then inst.sg:GoToState("howl") end end),
    EventHandler("newcombattarget", function(inst, data)
        if data.target and not inst.sg:HasStateTag("busy") then
            if math.random() < 0.3 then
                inst.sg:GoToState("howl")
            else
                inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/idle")
            end
        end
    end),
    EventHandler("workmoonbase", function(inst, data)
        if data ~= nil and data.moonbase ~= nil and not (inst.components.health:IsDead() or inst.sg:HasStateTag("busy")) then
            inst.sg:GoToState("workmoonbase", data.moonbase)
        end
    end),
}

local states =
{
    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst, reanimating)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/grunt")
            if reanimating then
                inst.AnimState:Pause()
            else
                inst.AnimState:PlayAnimation("death")
            end
            inst.components.locomotor:StopMoving()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(inst:GetPosition())
        end,

        timeline =
        {
            TimeEvent(TUNING.GARGOYLE_REANIMATE_DELAY, function(inst)
                if not inst:IsInLimbo() then
                    inst.AnimState:Resume()
                end
            end),
        },

        onexit = function(inst)
            if not inst:IsInLimbo() then
                inst.AnimState:Resume()
            end
        end,
    },

    State{
        name = "howl",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("howl")
        end,

        timeline =
        {
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/howl") end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, pushanim)
            inst.Physics:Stop()
            if pushanim then
                if type(pushanim) == "string" then
                    inst.AnimState:PlayAnimation(pushanim)
                end
                inst.AnimState:PushAnimation("were_idle_loop", true)
            else
                inst.AnimState:PlayAnimation("were_idle_loop", true)
            end
        end,
    },

    State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst)
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("were_atk_pre")
            inst.AnimState:PushAnimation("were_atk", false)
        end,

        timeline =
        {
            TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/attack") end),
            TimeEvent(16*FRAMES, function(inst) inst.components.combat:DoAttack() end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState(
                    not inst.components.combat:HasTarget() and
                    math.random() < 0.3 and
                    "howl" or
                    "idle")
            end),
        },
    },

    State{
        name = "run_start",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("were_run_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("run") end),
        },
    },

    State{
        name = "run",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            if not inst.AnimState:IsCurrentAnimation("were_run_loop") then
                inst.AnimState:PlayAnimation("were_run_loop", true)
            end
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        timeline =
        {
            TimeEvent(0*FRAMES, PlayFootstep),
            TimeEvent(10*FRAMES, PlayFootstep),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("run")
        end,
    },

    State{
        name = "run_stop",
        tags = { "canrotate" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("were_run_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "hit",
        tags = { "busy" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/hurt")
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()
			CommonHandlers.UpdateHitRecoveryDelay(inst)
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "workmoonbase",
        tags = { "busy", "working" },

        onenter = function(inst, moonbase)
            inst.sg.statemem.moonbase = moonbase
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("were_atk_pre")
            inst.AnimState:PushAnimation("were_atk", false)
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/attack")
            end),
            TimeEvent(16 * FRAMES, function(inst)
                local moonbase = inst.sg.statemem.moonbase
                if moonbase ~= nil and
                    moonbase.components.workable ~= nil and
                    moonbase.components.workable:CanBeWorked() then
                    moonbase.components.workable:WorkedBy(inst, 1)
                    SpawnPrefab("mining_fx").Transform:SetPosition(moonbase.Transform:GetWorldPosition())
                    inst.SoundEmitter:PlaySound("dontstarve/impacts/impact_stone_wall_dull")
                end
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.components.combat:SetTarget(nil)
                inst.sg:GoToState(math.random() < 0.3 and "howl" or "idle")
            end),
        },
    },

    State{
        name = "reanimate",
        tags = { "busy" },

        onenter = function(inst, data)
            inst.sg.statemem.howled = data.anim == "howl"
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation(data.anim)
            inst.AnimState:Pause()
			if data.frame ~= nil then
				inst.AnimState:SetFrame(data.frame)
			elseif data.time ~= nil then
                inst.AnimState:SetTime(data.time)
            end
            inst.sg.statemem.dead = data.dead
        end,

        timeline =
        {
            TimeEvent(TUNING.GARGOYLE_REANIMATE_DELAY, function(inst)
                if not inst:IsInLimbo() then
                    inst.AnimState:Resume()
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState(inst.sg.statemem.howled and "idle" or "howl")
            end),
        },

        onexit = function(inst)
            if not inst:IsInLimbo() then
                inst.AnimState:Resume()
            end
        end,
    },
}

CommonStates.AddSleepStates(states,
{
    sleeptimeline =
    {
        TimeEvent(35 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/sleep") end),
    },
})

CommonStates.AddFrozenStates(states)
CommonStates.AddIpecacPoopState(states)

return StateGraph("moonpig", states, events, "idle")
