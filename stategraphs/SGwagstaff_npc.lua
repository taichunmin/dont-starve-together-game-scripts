require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.EQUIP, "pickup"),
    ActionHandler(ACTIONS.TAKEITEM, "pickup"),
}


local function DoTalkSound(inst)
    if inst.talksoundoverride ~= nil then
        inst.SoundEmitter:PlaySound(inst.talksoundoverride, "talk")
        return true
    else

        inst.SoundEmitter:PlaySound("moonstorm/characters/wagstaff/talk_LP", "talk")
        return true
    end
end

local function StopTalkSound(inst, instant)
    if not instant and inst.endtalksound ~= nil and inst.SoundEmitter:PlayingSound("talk") then
        inst.SoundEmitter:PlaySound(inst.endtalksound)
    end
    inst.SoundEmitter:KillSound("talk")
end


local events =
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true, true),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    EventHandler("waitfortool", function(inst)
        inst.sg:GoToState("idle")
    end),
    EventHandler("doexperiment", function(inst)
        inst.sg:GoToState("idle_experiment")
    end),
    EventHandler("doneexperiment", function(inst)
        inst.sg:GoToState("idle")
    end),
    EventHandler("talk", function(inst)
        inst.sg:GoToState("talk")
    end),
    EventHandler("talk_experiment", function(inst)
        inst.sg:GoToState("talk","wait_search")
    end),
    EventHandler("startwork", function(inst, target)
        inst.sg:GoToState("capture_appearandwork", target)
    end),
}

local ERODEOUT_DATA =
{
    time = 4.0,
    erodein = false,
    remove = true,
}

local states =
{

    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end

            inst.AnimState:PlayAnimation("emote_impatient", true)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "talk",
        tags = { "idle", "talking" },

        onenter = function(inst,exitstate)
            if exitstate then
                inst.sg.statemem.exitstate = exitstate
            end
            inst.AnimState:PlayAnimation("dial_loop",true)

            DoTalkSound(inst)
            inst.sg:SetTimeout(1.5 + math.random() * .5)
        end,

        ontimeout = function(inst)
            if inst.sg.statemem.exitstate then
                inst.sg:GoToState(inst.sg.statemem.exitstate)
            else
                inst.sg:GoToState("idle")
            end
        end,

        events =
        {
            EventHandler("donetalking", function(inst)
                if inst.sg.statemem.exitstate then
                    inst.sg:GoToState(inst.sg.statemem.exitstate)
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = StopTalkSound,
    },

    State{
        name = "idle_experiment",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end

            inst.AnimState:PlayAnimation("build_loop", true)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle_experiment")
                end
            end),
        },
    },


    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/pig/grunt")
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(inst:GetPosition())
        end,
    },

    State{
        name = "hit",
        tags = { "busy" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/pig/oink")
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "dropitem",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("pig_pickup")
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst)
                inst:PerformBufferedAction()
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
        name = "cheer",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("buff")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "win_yotb",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("win")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "wait_search",
        tags = { },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("emote_impatient")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("wait_search")
            end),
        },
    },

    State{
        name = "capture_appearandwork",
        tags = {"busy"},

        onenter = function(inst, target)
            inst.Physics:Stop()

            inst.components.talker:Say(STRINGS.WAGSTAFF_NPC_CAPTURESTART)

            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)

            if target ~= nil and target:IsValid() then
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
                inst.sg.statemem.target = target
            end

            inst.sg:SetTimeout(4)
        end,

        ontimeout = function(inst)
            if inst.sg.statemem.target ~= nil and inst.sg.statemem.target:IsValid() then
                inst.sg.statemem.target:PushEvent("orbtaken")
            end

            if inst._device ~= nil and inst._device:IsValid() then
                inst._device:PushEvent("docollect")
            end

            inst.sg:GoToState("capture_pst")
        end,
    },

    State{
        name = "capture_pst",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()

            inst.AnimState:PlayAnimation("build_pst")

            inst.sg:SetTimeout(3 + inst.AnimState:GetCurrentAnimationLength())
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.components.talker:Say(STRINGS.WAGSTAFF_NPC_CAPTURESTOP)
                inst.sg:GoToState("talk", "capture_emotebuffer")
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("capture_emotebuffer")
        end,
    },

    State{
        name = "capture_emotebuffer",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()

            inst.AnimState:PlayAnimation("emote_impatient", true)

            inst.sg:SetTimeout(1.5)
        end,

        ontimeout = function(inst)
            inst.components.talker:Say(STRINGS.WAGSTAFF_NPC_CAPTURESTOP2)
            inst.sg:GoToState("talk", "capture_emote")
        end,
    },

    State{
        name = "capture_emote",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("dial_loop")
            inst.AnimState:PushAnimation("research", true)

            inst.sg:SetTimeout(15)
        end,

        ontimeout = function(inst)
            inst:Remove()
        end,

        timeline =
        {
            TimeEvent(1.0, function(inst)
                inst:PushEvent("doerode", ERODEOUT_DATA)
            end),
        },
    },
}

CommonStates.AddWalkStates(states,
{
    walktimeline =
    {
        TimeEvent(0, PlayFootstep),
        TimeEvent(12 * FRAMES, PlayFootstep),
    },
})

CommonStates.AddRunStates(states,
{
    runtimeline =
    {
        TimeEvent(0, PlayFootstep),
        TimeEvent(10 * FRAMES, PlayFootstep),
    },
})

CommonStates.AddSimpleState(states, "refuse", "pig_reject", { "busy" })
CommonStates.AddSimpleActionState(states, "pickup", "pig_pickup", 10 * FRAMES, { "busy" })
CommonStates.AddSimpleActionState(states, "gohome", "pig_pickup", 4 * FRAMES, { "busy" })

return StateGraph("wagstaff_npc", states, events, "idle", actionhandlers)
