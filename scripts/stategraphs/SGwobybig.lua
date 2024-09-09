require("stategraphs/commonstates")
require("stategraphs/SGcritter_common")

local RANDOM_IDLES = { "bark_idle", "shake", "sit", "scratch" }

local actionhandlers =
{
}


local events=
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true,true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnHop(),
    CommonHandlers.OnSink(),

    EventHandler("transform", function(inst, data)
        if inst.sg.currentstate.name ~= "transform" then
            inst.sg:GoToState("transform")
        end
    end),

    SGCritterEvents.OnEat(),
}

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst, pushanim)
            inst.components.locomotor:StopMoving()

            if pushanim then
                inst.AnimState:PushAnimation("idle_loop", true)
            else
                inst.AnimState:PlayAnimation("idle_loop", true)
            end

            inst.sg:SetTimeout(2 + math.random())

        end,

        ontimeout=function(inst)
            if not inst.components.sleeper:IsAsleep() then
                local hounded = TheWorld.components.hounded
                if hounded ~= nil and (hounded:GetWarning() or hounded:GetAttacking()) then
                    inst.sg:GoToState("bark_idle")
                else
                    inst.sg:GoToState(RANDOM_IDLES[math.random(1, #RANDOM_IDLES)])
                end

            end
        end,
    },

    State{
        name = "despawn",
        tags = {"busy", "nointerrupt"},

        onenter = function(inst, pushanim)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("idle_loop", true)
        end,

        onexit = function(inst)
			inst:DoTaskInTime(0, inst.Remove)
        end,
    },

    State{
        name = "bark_idle",
        tags = { "idle" },
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            if not inst.AnimState:IsCurrentAnimation("bark1_woby") then
                inst.AnimState:PlayAnimation("bark1_woby", false)
                inst.AnimState:PushAnimation("bark1_woby", false)
            end
        end,

        timeline=
        {
            TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/bark") end),
            TimeEvent(34*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/bark") end),
        },

        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "shake",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("shake_woby")
        end,

        timeline=
        {
            TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/foley") end),
            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/foley") end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name="eat",
        tags = {"busy"},

        onenter = function(inst, data)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("eat_pre", false)
            inst.AnimState:PushAnimation("eat_loop", false)
            inst.AnimState:PushAnimation("eat_pst", false)
            inst.SoundEmitter:PlaySound("dontstarve/beefalo/chew")
        end,

        timeline =
        {
            TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/chuff") end),
        },

        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "sit",
        tags = {},
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            if not (inst.AnimState:IsCurrentAnimation("sit_woby") or
               inst.AnimState:IsCurrentAnimation("sit_woby_loop") or
               inst.AnimState:IsCurrentAnimation("sit_woby_pst")) then

                inst.AnimState:PlayAnimation("sit_woby", false)
                inst.AnimState:PushAnimation("sit_woby_loop", false)
                inst.AnimState:PushAnimation("sit_woby_loop", false)
                inst.AnimState:PushAnimation("sit_woby_loop", false)
                inst.AnimState:PushAnimation("sit_woby_pst", false)
            end
        end,

        timeline=
        {
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/foley") end),
            TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/foley") end),
            TimeEvent(18*FRAMES, function(inst) inst.SoundEmitter:PlaySoundWithParams("dontstarve/characters/walter/woby/big/footstep", {intensity= .8}) end),
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySoundWithParams("dontstarve/characters/walter/woby/big/footstep", {intensity= 1}) end),

        },

        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "cower",
        tags = {"canrotate", "alert"},

        onenter = function(inst)
            inst.sg:GoToState("actual_cower")
        end,
    },

    State{
        name = "actual_cower",
        tags = {"idle", "canrotate", "alert"},
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            if not inst.AnimState:IsCurrentAnimation("cower_woby_loop") then
                inst.AnimState:PlayAnimation("cower_woby_pre", false)
                inst.AnimState:PushAnimation("cower_woby_loop", true)
            end
        end,

        timeline=
        {
            TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/foley") end),
            TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/wimper") end),
        },

        onexit = function(inst)
            inst.AnimState:PlayAnimation("cower_woby_pst", false)
        end,
    },

    State{
        name = "scratch",
        tags = {"idle"},
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            if not (inst.AnimState:IsCurrentAnimation("scratch_woby_pre") or
               inst.AnimState:IsCurrentAnimation("scratch_woby_loop") or
               inst.AnimState:IsCurrentAnimation("scratch_woby_pst")) then

                inst.AnimState:PlayAnimation("scratch_woby_pre", false)
                inst.AnimState:PushAnimation("scratch_woby_loop", false)
                inst.AnimState:PushAnimation("scratch_woby_pst", false)
            end
        end,

        timeline=
        {
            TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySoundWithParams("dontstarve/characters/walter/woby/big/foley", {intensity= .5}) end),
            TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySoundWithParams("dontstarve/characters/walter/woby/big/foley", {intensity= .7}) end),
            TimeEvent(24*FRAMES, function(inst) inst.SoundEmitter:PlaySoundWithParams("dontstarve/characters/walter/woby/big/foley", {intensity= .9}) end),
        },

        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name="transform",
        tags = {"busy"},

        onenter = function(inst, data)
            inst.components.locomotor:StopMoving()
            inst.DynamicShadow:Enable(false)
            inst.AnimState:AddOverrideBuild("pupington_woby_build")
            inst.AnimState:PlayAnimation("transform_big_to_small")
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/transform_big_to_small") end),
            -- TimeEvent(39*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/transform_big_to_small") end),
            TimeEvent(70*FRAMES, function(inst) inst:FinishTransformation() end),
        },
    },

    -- Used when the player is about to mount
    State{
        name = "alert",
        tags = {"idle", "canrotate", "alert"},

        onenter = function(inst)
            inst.sg:GoToState("actual_alert")
        end,
    },

    State{
        name = "actual_alert",
        tags = {"idle", "canrotate", "alert"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            if not inst.AnimState:IsCurrentAnimation("alert_woby_loop") then
                inst.AnimState:PlayAnimation("alert_woby_pre")
                inst.AnimState:PushAnimation("alert_woby_loop", true)
            end
        end,
        timeline=
        {
            TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/foley") end),
            TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/chuff") end),
        },

    },

    State{
        name = "sit_alert_tailwag",
        tags = {"idle", "canrotate", "alert"},

        onenter = function(inst)
            inst.sg:GoToState("actual_sit_alert_tailwag")
        end,
    },

    State{
        name = "actual_sit_alert_tailwag",
        tags = {"idle", "canrotate", "alert"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("sit_woby")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("actual_sit_alert_tailwag_loop") end),
        },
    },


    State{
        name = "actual_sit_alert_tailwag_loop",
        tags = {"idle", "canrotate", "alert"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("sit_woby_tailwag_loop", true)
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        timeline=
        {
            TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/tail") end),
            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/tail") end),
            TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/tail") end),
            TimeEvent(16*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/tail") end),
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/tail") end),
            TimeEvent(24*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/tail") end),
            TimeEvent(28*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/tail") end),
            TimeEvent(31*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/tail") end),
            TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/tail") end),
        },

        ontimeout = function(inst) inst.sg:GoToState("actual_sit_alert_tailwag_loop") end,
    },

    State{
        name = "sit_alert",
        tags = {"idle", "canrotate", "alert"},

        onenter = function(inst)
            inst.sg:GoToState("actual_sit_alert")
        end,
    },

    State{
        name = "actual_sit_alert",
        tags = {"idle", "canrotate", "alert"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            if not inst.AnimState:IsCurrentAnimation("sit_woby_loop") then
                inst.AnimState:PlayAnimation("sit_woby")
                inst.AnimState:PushAnimation("sit_woby_loop", true)
            end
        end,

        timeline=
        {
            TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/foley") end),
            TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/chuff") end),
        },


    },

    State{
        name = "run_start",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_woby_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("run")
            end),
        },
    },

    State{
        name = "run",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_woby_loop", true)
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        timeline=
        {
            TimeEvent(math.random(1,11)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/run_chuff") end),
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySoundWithParams("dontstarve/characters/walter/woby/big/footstep", {intensity= 1}) end),
            TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySoundWithParams("dontstarve/characters/walter/woby/big/footstep", {intensity= 1}) end),
            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySoundWithParams("dontstarve/characters/walter/woby/big/footstep", {intensity= 1}) end),
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySoundWithParams("dontstarve/characters/walter/woby/big/footstep", {intensity= 1}) end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("run")
        end,
    },

    State{
        name = "run_stop",
        tags = { "idle" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("run_woby_pst")
        end,

        timeline=
        {
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/footstep") end),
            TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/footstep") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
}

CommonStates.AddWalkStates(
    states,
    {
        walktimeline =
        {

            ---- SNIFF SOUNDS-----
            TimeEvent(4*FRAMES, function(inst)
                if inst.AnimState:IsCurrentAnimation("sniff_woby_pre") or
                   inst.AnimState:IsCurrentAnimation("sniff_woby_loop") or
                   inst.AnimState:IsCurrentAnimation("sniff_woby_pst") then
                   inst.SoundEmitter:PlaySoundWithParams("dontstarve/characters/walter/woby/big/sniff")-- Sniff walk sounds
                end
            end),

            TimeEvent(15*FRAMES, function(inst)
                if inst.AnimState:IsCurrentAnimation("sniff_woby_pre") or
                   inst.AnimState:IsCurrentAnimation("sniff_woby_loop") or
                   inst.AnimState:IsCurrentAnimation("sniff_woby_pst") then
                   inst.SoundEmitter:PlaySoundWithParams("dontstarve/characters/walter/woby/big/sniff")-- Sniff walk sounds
                end
            end),

            TimeEvent(31*FRAMES, function(inst)
                if inst.AnimState:IsCurrentAnimation("sniff_woby_pre") or
                   inst.AnimState:IsCurrentAnimation("sniff_woby_loop") or
                   inst.AnimState:IsCurrentAnimation("sniff_woby_pst") then
                   inst.SoundEmitter:PlaySoundWithParams("dontstarve/characters/walter/woby/big/sniff")-- Sniff walk sounds
                end
            end),

            TimeEvent(43*FRAMES, function(inst)
                if inst.AnimState:IsCurrentAnimation("sniff_woby_pre") or
                   inst.AnimState:IsCurrentAnimation("sniff_woby_loop") or
                   inst.AnimState:IsCurrentAnimation("sniff_woby_pst") then
                   inst.SoundEmitter:PlaySoundWithParams("dontstarve/characters/walter/woby/big/sniff")-- Sniff walk sounds
                end
            end),

            --FOOTSTEPS SOUNDS----

            TimeEvent(7*FRAMES, function(inst)
                if inst.AnimState:IsCurrentAnimation("sniff_woby_pre") or
                   inst.AnimState:IsCurrentAnimation("sniff_woby_loop") or
                   inst.AnimState:IsCurrentAnimation("sniff_woby_pst") then
                    inst.SoundEmitter:PlaySoundWithParams("dontstarve/characters/walter/woby/big/footstep", {intensity= .1})
                else
                    inst.SoundEmitter:PlaySoundWithParams("dontstarve/characters/walter/woby/big/footstep", {intensity= .3}) -- Regular walk sounds
                end
            end),


            TimeEvent(30*FRAMES, function(inst)
                if inst.AnimState:IsCurrentAnimation("sniff_woby_pre") or
                   inst.AnimState:IsCurrentAnimation("sniff_woby_loop") or
                   inst.AnimState:IsCurrentAnimation("sniff_woby_pst") then
                    inst.SoundEmitter:PlaySoundWithParams("dontstarve/characters/walter/woby/big/footstep", {intensity= .1})
                else
                    inst.SoundEmitter:PlaySoundWithParams("dontstarve/characters/walter/woby/big/footstep", {intensity= .3}) -- Regular walk sounds
                end
            end),

            TimeEvent(45*FRAMES, function(inst)
                if inst.AnimState:IsCurrentAnimation("sniff_woby_pre") or
                   inst.AnimState:IsCurrentAnimation("sniff_woby_loop") or
                   inst.AnimState:IsCurrentAnimation("sniff_woby_pst") then
                    inst.SoundEmitter:PlaySoundWithParams("dontstarve/characters/walter/woby/big/footstep", {intensity= .1})
                else
                    inst.SoundEmitter:PlaySoundWithParams("dontstarve/characters/walter/woby/big/footstep", {intensity= .3}) -- Regular walk sounds
                end
            end),


            TimeEvent(60*FRAMES, function(inst)
                if inst.AnimState:IsCurrentAnimation("sniff_woby_pre") or
                   inst.AnimState:IsCurrentAnimation("sniff_woby_loop") or
                   inst.AnimState:IsCurrentAnimation("sniff_woby_pst") then
                    inst.SoundEmitter:PlaySoundWithParams("dontstarve/characters/walter/woby/big/footstep", {intensity= .1}) -- Sniff walk sounds
                else
                    inst.SoundEmitter:PlaySoundWithParams("dontstarve/characters/walter/woby/big/footstep", {intensity= .3}) -- Regular walk sounds
                end
            end),


        }
    },
    {
        startwalk =  function(inst)
            if math.random() < 0.33 then
                return "sniff_woby_pre"
            end

            return "walk_woby_pre"
        end,

        walk = function(inst)
            if inst.AnimState:IsCurrentAnimation("sniff_woby_pre") then
                return "sniff_woby_loop"
            end
            return "walk_woby_loop"
        end,

        stopwalk = function(inst)
            if inst.AnimState:IsCurrentAnimation("sniff_woby_pre") or
               inst.AnimState:IsCurrentAnimation("sniff_woby_loop") then
                return "sniff_woby_pst"
            end

            return "walk_woby_pst"
        end,
    })

CommonStates.AddFrozenStates(states)
CommonStates.AddSinkAndWashAshoreStates(states)
CommonStates.AddHopStates(states, true, { pre = "boat_jump_pre", loop = "boat_jump_loop", pst = "boat_jump_pst"},
{
    hop_pre =
    {
        TimeEvent(46*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/sleep") end)
    },

    hop_loop =
    {
        TimeEvent(46*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/sleep") end)
    },

    hop_pst =
    {
        TimeEvent(46*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/sleep") end)
    },
})

CommonStates.AddSleepStates(states,
{
    sleeptimeline =
    {
        TimeEvent(46*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/sleep") end)
    },
})

return StateGraph("wobybig", states, events, "idle", actionhandlers)