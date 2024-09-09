require("stategraphs/commonstates")

local events=
{
    CommonHandlers.OnFreeze(),
    EventHandler("arrive", function(inst)
            inst.sg:GoToState("arrive")
        end),
    EventHandler("leave", function(inst)
            inst.sg:GoToState("leave")
        end),
}

local states=
{
    State{
        name = "arrive",
        tags = {"busy"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("breach_pre")
            inst.SoundEmitter:PlaySound("ancientguardian_rework/tentacle_shadow/voice_appear")
        end,

        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "leave",
        tags = {"busy"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("breach_pst")
        end,

        events=
        {
            EventHandler("animover", function(inst)
                inst:Remove()
            end),
        },
    },

    State{
        name = "idle",
        tags = {"idle", "invisible"},
        onenter = function(inst)
            inst.AnimState:PushAnimation("breach_loop", true)
        end,

        onupdate = function(inst)
            if inst.components.combat.target and inst.components.combat:TryAttack() then
                inst.sg:GoToState("attack_pre")
            end
        end
    },

    State{
        name ="attack_pre",
        tags = {"attack"},
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("ancientguardian_rework/tentacle_shadow/voice_appear")
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk_pre")
        end,
        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("attack")
            end),
        },
        timeline=
        {
            SoundTimeEvent(20*FRAMES, "dontstarve/tentacle/tentacle_emerge_VO"),
        },
    },

    State{
        name = "attack",
        tags = {"attack"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("atk_loop")
            inst.AnimState:PushAnimation("atk_idle", false)
        end,

        timeline=
        {
            SoundTimeEvent(2*FRAMES, "ancientguardian_rework/tentacle_shadow/whip"),
			TimeEvent(7*FRAMES, function(inst) inst.components.combat:DoAttack() end),
            SoundTimeEvent(15*FRAMES, "ancientguardian_rework/tentacle_shadow/whip"),
            TimeEvent(17*FRAMES, function(inst) inst.components.combat:DoAttack() end),
            TimeEvent(18*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
        },

        events=
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState((inst.components.combat.target ~= nil and "attack")
                    or "attack_post")
            end),
        },
    },

    State{
        name ="attack_post",
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_disappear")
            inst.AnimState:PlayAnimation("atk_pst")
        end,
        events=
        {
            EventHandler("animover", function(inst) inst:Remove() end),
        },
    },
}
CommonStates.AddFrozenStates(states)

return StateGraph("bigshadowtentacle", states, events, "idle")

