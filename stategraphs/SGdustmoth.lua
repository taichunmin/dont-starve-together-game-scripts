require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.PICKUP, "pickup"),
    ActionHandler(ACTIONS.GOHOME, "action"),
    ActionHandler(ACTIONS.EAT, "eat"),
    -- These two are a hack, the actions are never actually performed
    -- but the handlers are used to bring the moth to certain sg states
    ActionHandler(ACTIONS.PET, "dustoff_pre"),
    ActionHandler(ACTIONS.REPAIR, "repair_den_pre"),
}

local events =
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnDeath(),
    EventHandler("dustmothsearch", function(inst)
        inst.sg:GoToState("search")
    end),
    EventHandler("onrefuseitem", function(inst, giver)
        if not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("refuseitem", giver)
        end
    end),
}

local SNEEZE_CHANCE = .2
local REPAIR_LOOP_CLEAN_SOUND_CHANCE = .33

local function reset_dustable_fn(inst)
    if not inst:HasTag("dustable") then
        inst:AddTag("dustable")
    end
end

local function PlaySoundDustoff(inst)
    inst.SoundEmitter:PlaySound(inst._sounds.dustoff)
end

local function PlaySoundClean(inst)
    inst.SoundEmitter:PlaySound(inst._sounds.clean)
end

local DUSTOFF_LOOP_AUDIO_OFFSET = 10*FRAMES
local function PlayDustoffLoopSound(inst)
    if inst.sg:HasStateTag("dusting") then
        PlaySoundDustoff(inst)
    end
end

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
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "action",

        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle", true)
            inst:PerformBufferedAction()
        end,

        events =
        {
            EventHandler("animover", function (inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "sneeze",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("sneeze")
        end,

        timeline =
        {
            TimeEvent(36*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst._sounds.sneeze)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                local ba = inst:GetBufferedAction()
                if ba ~= nil and ba.target ~= nil and ba.target:IsValid() then
                    inst.sg:GoToState("dustoff_pre", true)
                else
                    inst.sg:GoToState("idle")
                end
            end)
        },
    },

    State{
        name = "dustoff_pre",
        tags = { "busy", "dusting" },

        onenter = function(inst, has_just_sneezed)
            inst.Physics:Stop()

            if not has_just_sneezed and math.random() < SNEEZE_CHANCE then
                inst.sg:GoToState("sneeze")
            else
                local ba = inst:GetBufferedAction()
                if ba ~= nil and ba.target ~= nil and ba.target:IsValid() and ba.target:HasTag("dustable") then
                    ba.target:RemoveTag("dustable")
                    ba.target:DoTaskInTime(TUNING.DUSTMOTH.DUSTABLE_RESET_TIME + math.random() * TUNING.DUSTMOTH.DUSTABLE_RESET_TIME_VARIANCE, reset_dustable_fn)

                    inst:ClearBufferedAction()
                    inst.AnimState:PlayAnimation("clean_pre")

                    inst:StartDustoffCooldown() -- Function defined in dustmoth prefab
                else
                    inst:ClearBufferedAction()
                    inst.sg:GoToState("idle")
                end
            end
        end,

        events =
        {
            EventHandler("animover", function (inst)
                inst.sg:GoToState("dustoff_loop")
            end),
        },
    },

    State{
        name = "dustoff_loop",
        tags = { "busy", "dusting" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("clean_loop")

            inst.sg.statemem.loop_count = 4 + math.random(3)

            inst:DoTaskInTime(DUSTOFF_LOOP_AUDIO_OFFSET, PlayDustoffLoopSound)
        end,

        timeline=
        {
            TimeEvent(9*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst._sounds.dustoff)
            end),
            TimeEvent(16*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst._sounds.clean)
            end),

            TimeEvent(22*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst._sounds.dustoff)
            end),
        },

        events =
        {
            EventHandler("animover", function (inst)
                inst.sg.statemem.loop_count = inst.sg.statemem.loop_count - 1

                if inst.sg.statemem.loop_count <= 0 then
                    inst.sg:GoToState("dustoff_pst")
                else
                    inst.AnimState:PlayAnimation("clean_loop")
                    inst:DoTaskInTime(DUSTOFF_LOOP_AUDIO_OFFSET, PlayDustoffLoopSound)
                end
            end),
        },
    },

    State{
        name = "dustoff_pst",
        tags = { "busy", "dusting" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("clean_pst")
        end,

        events =
        {
            EventHandler("animover", function (inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "repair_den_pre",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()

            inst.AnimState:PlayAnimation("clean_pre")

            inst.sg.statemem.startpos = inst:GetPosition()
        end,

        timeline=
        {
            TimeEvent(10*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst._sounds.clean)
            end),
        },

        events =
        {
            EventHandler("animover", function (inst)
                local ba = inst:GetBufferedAction()

                if ba ~= nil and ba.target ~= nil and ba.target:IsValid() then
                    inst:ClearBufferedAction()
                    inst.sg:GoToState("repair_den_loop", { target = ba.target, startpos = inst.sg.statemem.startpos })
                else
                    inst.sg:GoToState("repair_den_pst")
                end
            end),
        },
    },

    State{
        name = "repair_den_loop",
        tags = { "busy" },

        onenter = function(inst, data)
            if inst._charged then
                inst.Physics:Stop()

                inst.AnimState:Hide("clean_dust")
                inst.AnimState:PlayAnimation("clean_loop")

                local target = data.target

                if target ~= nil and target:IsValid() and target._start_repairing_fn ~= nil then
                    target:_start_repairing_fn(inst)
                end

                inst.sg.statemem.startpos = data.startpos

                inst.sg.statemem.target = target
                inst.sg.statemem.dust_anim_loops = math.random(5, 9)

                inst.sg.statemem.sound_task1 = inst:DoTaskInTime(9*FRAMES, PlaySoundDustoff)
                if math.random() < REPAIR_LOOP_CLEAN_SOUND_CHANCE then
                    inst.sg.statemem.sound_task2 = inst:DoTaskInTime(16*FRAMES, PlaySoundClean)
                end
                inst.sg.statemem.sound_task3 = inst:DoTaskInTime(22*FRAMES, PlaySoundDustoff)

                inst.sg.statemem.ondenremovedfn = function() inst.sg:GoToState("repair_den_pst") end

                inst:ListenForEvent("onremove", inst.sg.statemem.ondenremovedfn, target)
            else
                inst.sg:GoToState("idle")
            end
        end,

        onupdate = function(inst)
            if inst.sg.statemem.target ~= nil and inst.sg.statemem.target:IsValid() then
                local delta = inst.sg.statemem.startpos - inst:GetPosition()
                if VecUtil_LengthSq(delta.x, delta.z) > 2.25 then
                    inst.sg:GoToState("repair_den_pst")
                end
            end
        end,

        onexit = function(inst)
            inst.AnimState:Show("clean_dust")

            if inst.sg.statemem.target ~= nil and inst.sg.statemem.target:IsValid() and inst.sg.statemem.target._pause_repairing_fn ~= nil then
                inst:RemoveEventCallback("onremove", inst.sg.statemem.ondenremovedfn, inst.sg.statemem.target)
                inst.sg.statemem.target:_pause_repairing_fn()
            end

            if inst.sg.statemem.sound_task1 ~= nil then
                inst.sg.statemem.sound_task1:Cancel()
            end
            if inst.sg.statemem.sound_task2 ~= nil then
                inst.sg.statemem.sound_task2:Cancel()
            end
            if inst.sg.statemem.sound_task3 ~= nil then
                inst.sg.statemem.sound_task3:Cancel()
            end
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.sg.statemem.dust_anim_loops > 0 then
                    inst.AnimState:PlayAnimation("clean_loop")
                    inst.sg.statemem.dust_anim_loops = inst.sg.statemem.dust_anim_loops - 1

                    inst.sg.statemem.sound_task1 = inst:DoTaskInTime(9*FRAMES, PlaySoundDustoff)
                    if math.random() < REPAIR_LOOP_CLEAN_SOUND_CHANCE then
                        inst.sg.statemem.sound_task2 = inst:DoTaskInTime(16*FRAMES, PlaySoundClean)
                    end
                    inst.sg.statemem.sound_task3 = inst:DoTaskInTime(22*FRAMES, PlaySoundDustoff)
                else
                    inst.AnimState:PlayAnimation("clean_pst")
                    inst.AnimState:PushAnimation("clean_pre", false)
                    inst.sg.statemem.dust_anim_loops = math.random(5, 9)
                end
            end),
            EventHandler("dustmothden_repaired", function(inst)
                inst.sg:GoToState("repair_den_pst")
            end),
        },
    },

    State{
        name = "repair_den_pst",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()

            inst.AnimState:PlayAnimation("clean_pst")
        end,

        timeline=
        {
            TimeEvent(10*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst._sounds.mumble)
            end),
        },


        events =
        {
            EventHandler("animover", function (inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "pickup",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("pickup")
        end,

        timeline =
        {
            TimeEvent(10*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst._sounds.eat_slide)
            end),
            TimeEvent(16*FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animover", function (inst)
                inst._time_spent_stuck = 0
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "eat",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat")
        end,

        timeline =
        {
            TimeEvent(5*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst._sounds.eat)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst._time_spent_stuck = 0

                inst:PerformBufferedAction()
                inst.sg:GoToState("idle")
            end)
        },
    },

    State{
        name = "search",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle2")
        end,

        timeline =
        {
            TimeEvent(9*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst._sounds.mumble)
            end),
            TimeEvent(29*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst._sounds.mumble)
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end)
        },
    },

    State{
        name = "refuseitem",
        tags = { "busy" },

        onenter = function(inst, giver)
            inst.Physics:Stop()

            if giver ~= nil and giver:IsValid() then
                inst.Transform:SetRotation(inst:GetAngleToPoint(giver:GetPosition()))
            end

            inst.AnimState:PlayAnimation("idle2")
        end,

        timeline =
        {
            TimeEvent(9*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst._sounds.mumble)
            end),
            TimeEvent(29*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst._sounds.mumble)
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end)
        },
    },
}

CommonStates.AddWalkStates(states,
{
    walktimeline =
    {
        TimeEvent(0*FRAMES, function(inst)
            inst.Physics:Stop()
            inst.SoundEmitter:PlaySound(inst._sounds.slide_out)
        end),

        TimeEvent(9*FRAMES, function(inst) if math.random() < 0.3 then inst.SoundEmitter:PlaySound(inst._sounds.mumble) end end),

        TimeEvent(21*FRAMES, function(inst)
            inst.components.locomotor:WalkForward()
            inst.SoundEmitter:PlaySound(inst._sounds.slide_in)
        end),
        TimeEvent(34*FRAMES, function(inst)
            inst.Physics:Stop()
        end),
	},
},
{
    walk = "walk",
}, true)

CommonStates.AddCombatStates(states,
{
    hittimeline =
    {
        TimeEvent(1*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound(inst._sounds.hit)
        end),
    },
    deathtimeline =
    {
        TimeEvent(7*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound(inst._sounds.death)
        end),
        TimeEvent(20*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound(inst._sounds.death)
        end),
        TimeEvent(24*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound(inst._sounds.fall)
        end),

    },
})

CommonStates.AddFrozenStates(states)
CommonStates.AddSleepStates(states)

return StateGraph("dustmoth", states, events, "idle", actionhandlers)
