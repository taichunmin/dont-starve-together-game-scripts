local events=
{
    EventHandler("onbuilt", function(inst, data)
                inst.sg:GoToState("place", data)
            end),
    EventHandler("onburnt", function(inst, data)
                inst.sg:GoToState("burnt", data)
            end),
    EventHandler("hit", function(inst)
                if not inst.sg:HasStateTag("hit") and not inst:HasTag("burnt") then
                    inst.sg:GoToState("hit")
                end
            end),
    EventHandler("ratupdate", function(inst, data)
                if not inst.sg:HasStateTag("hit") and not inst:HasTag("burnt") then
                    inst.sg:GoToState("idle")
                end
            end),
    EventHandler("endtraining", function(inst, data)
                if not inst:HasTag("burnt") then
                    if inst.sg:HasStateTag("active") then
                        inst.sg:GoToState("active_pst", data)
    				else
                        inst.sg:GoToState("idle")
                    end
                end
            end),
    EventHandler("starttraining", function(inst, data)
                if not inst.sg:HasStateTag("active") and not inst:HasTag("burnt") then
                    inst.sg:GoToState("active_pre", data)
                end
            end),
    EventHandler("rest", function(inst, data)
                if not inst.sg:HasStateTag("sleep") and not inst:HasTag("burnt") then
                    inst.sg:GoToState("sleep_pre", data)
                end
            end),
    EventHandler("endrest", function(inst, data)
                if inst.sg:HasStateTag("sleep") and not inst:HasTag("burnt") then
                    inst.sg:GoToState("sleep_pst", data)
                end
            end),
}

local states =
{
    State{
        name = "idle",
        onenter = function(inst)
            if inst.components.gym and inst.components.gym.trainee then
                inst.AnimState:PlayAnimation("idle_rat")
            else
                inst.AnimState:PlayAnimation("idle")
            end
        end,

        events =
        {
            EventHandler("animover",
                function(inst)
                    if inst.components.gym and inst.components.gym.trainee and math.random()<0.05 then
                        inst.sg:GoToState("idle2")
                    else
                        inst.sg:GoToState("idle")
                    end
                end),
        },
    },

    State{
        name = "burnt",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("burnt")
        end,
    },

    State{
        name = "idle2",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_rat2")
        end,

        events =
        {
            EventHandler("animover",
                function(inst)
                    if inst.components.gym and inst.components.gym.trainee and math.random()<0.05 then
                        inst.sg:GoToState("idle2")
                    else
                        inst.sg:GoToState("idle")
                    end
                end),
        },
    },

    State{
        name = "place",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("place")
        end,

        timeline =
        {
           TimeEvent(0 * FRAMES, function(inst) if inst.prefab == "yotc_carrat_gym_direction" then  inst.SoundEmitter:PlaySound("yotc_2020/gym/direction/place")  end end),

           TimeEvent(0 * FRAMES, function(inst) if inst.prefab == "yotc_carrat_gym_reaction" then  inst.SoundEmitter:PlaySound("yotc_2020/gym/reaction/place")  end end),

           TimeEvent(0 * FRAMES, function(inst) if inst.prefab == "yotc_carrat_gym_speed" then  inst.SoundEmitter:PlaySound("yotc_2020/gym/speed/place")  end end),

           TimeEvent(0 * FRAMES, function(inst) if inst.prefab == "yotc_carrat_gym_stamina" then  inst.SoundEmitter:PlaySound("yotc_2020/gym/stamina/place")  end end),
        },

        events =
        {
            EventHandler("animover",
                function(inst)
                    inst.sg:GoToState("idle")
                end),
        },
    },

    State{
        name = "active_pre",
        tags = {"active"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("active_pre")
        end,

        timeline =
        {
        --------------------    DIRECTION
           TimeEvent(0 * FRAMES, function(inst) if inst.prefab == "yotc_carrat_gym_direction" then  inst.SoundEmitter:PlaySound("yotc_2020/gym/direction/active_pre")  end end),
        --------------------    REACTION
           TimeEvent(0 * FRAMES, function(inst) if inst.prefab == "yotc_carrat_gym_reaction" then  inst.SoundEmitter:PlaySound("yotc_2020/gym/reaction/active_pre")  end end),
        --------------------    SPEED
           TimeEvent(0 * FRAMES, function(inst) if inst.prefab == "yotc_carrat_gym_speed" then  inst.SoundEmitter:PlaySound("yotc_2020/gym/speed/active_pre")  end end),
        --------------------    STAMINA
           TimeEvent(0 * FRAMES, function(inst) if inst.prefab == "yotc_carrat_gym_stamina" then  inst.SoundEmitter:PlaySound("yotc_2020/gym/stamina/active_pre")  end end),
        },
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("active_loop") end),
        },
    },

    State{
        name = "active_loop",
        tags = {"active"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("active_loop")
        end,

        timeline =
        {
        -------------------- DIRECTION
           TimeEvent(0 * FRAMES, function(inst) if inst.prefab == "yotc_carrat_gym_direction" then  inst.SoundEmitter:PlaySound("yotc_2020/gym/direction/active_LP", "active_sound_loop")  end end),

        --------------------  REACTION
           TimeEvent(0 * FRAMES, function(inst) if inst.prefab == "yotc_carrat_gym_reaction" then  inst.SoundEmitter:PlaySound("yotc_2020/gym/reaction/active_LP", "active_sound_loop")  end end),

        -------------------- SPEED
           TimeEvent(0 * FRAMES, function(inst) if inst.prefab == "yotc_carrat_gym_speed" then  inst.SoundEmitter:PlaySound("yotc_2020/gym/speed/active_LP", "active_sound_loop")  end end),

        -------------------- STAMINA
           TimeEvent(0 * FRAMES, function(inst) if inst.prefab == "yotc_carrat_gym_stamina" then  inst.SoundEmitter:PlaySound("yotc_2020/gym/stamina/active_LP", "active_sound_loop")  end end),

        },

        onexit = function(inst)
           inst.SoundEmitter:KillSound("active_sound_loop")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("active_loop") end),
        },
    },
    State{
        name = "active_pst",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("active_pst")
        end,

        timeline =
        {

        --------------------    DIRECTION
           TimeEvent(0 * FRAMES, function(inst) if inst.prefab == "yotc_carrat_gym_direction" then  inst.SoundEmitter:PlaySound("yotc_2020/gym/direction/active_post")  end end),
        --------------------    REACTION

        --------------------    SPEED
           TimeEvent(0 * FRAMES, function(inst) if inst.prefab == "yotc_carrat_gym_speed" then  inst.SoundEmitter:PlaySound("yotc_2020/gym/speed/active_post")  end end),
        --------------------    STAMINA
           TimeEvent(0 * FRAMES, function(inst) if inst.prefab == "yotc_carrat_gym_stamina" then  inst.SoundEmitter:PlaySound("yotc_2020/gym/stamina/active_post")  end end),

        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    State{
        name = "hit",
        tags = {"hit"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")
        end,

        timeline =
        {
           TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/wilson/hit_metal") end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "sleep_pre",
        tags = {"sleep"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_rat_sleep_pre")
            inst.components.timer:PauseTimer("training")
        end,

        onexit = function(inst)
            inst.components.timer:ResumeTimer("training")
        end,

        timeline =
        {
         --   TimeEvent(2 * FRAMES, function(inst) inst.SoundEmitter:KillSound("mooring") end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("sleep") end),
        },
    },

    State{
        name = "sleep",
        tags = {"sleep"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_rat_sleeping")
            inst.components.timer:PauseTimer("training")
        end,

        onexit = function(inst)
            inst.components.timer:ResumeTimer("training")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("sleep") end),
        },
    },
    State{
        name = "sleep_pst",
        tags = {},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_sleep_pst")
            inst.components.timer:PauseTimer("training")
        end,

        onexit = function(inst)
            inst.components.timer:ResumeTimer("training")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.components.timer:TimerExists("training") then
                    inst.sg:GoToState("active_pre")
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },
}

return StateGraph("rat_gym", states, events, "idle")
