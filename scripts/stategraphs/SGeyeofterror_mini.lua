require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.EAT, "eat"),
}

local events =
{
    CommonHandlers.OnSleepEx(),
    CommonHandlers.OnWakeEx(),
    CommonHandlers.OnFreezeEx(),

    CommonHandlers.OnLocomote(false, true),

    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
}

local function return_to_idle(inst)
    inst.sg:GoToState("idle")
end

local function lower_flying_creature(inst)
    inst:RemoveTag("flying")
    inst:PushEvent("on_landed")
end

local function raise_flying_creature(inst)
    inst:AddTag("flying")
    inst:PushEvent("on_no_longer_landed")
end

local states =
{
    State {
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("idle_loop")
        end,

        events =
        {
            EventHandler("animover", return_to_idle),
        },
    },

    State {
        name = "taunt",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("taunt")
        end,

        timeline =
        {
            TimeEvent(21*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("terraria1/mini_eyeofterror/taunt")
            end),
        },

        events =
        {
            EventHandler("animover", return_to_idle),
        },
    },

    State {
        name = "hit",
        tags = { "busy" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound(inst.sounds.hit)
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()
        end,

        events =
        {
            EventHandler("animover", return_to_idle),
        },
    },

    State {
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("death")
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(inst:GetPosition())

            inst.SoundEmitter:PlaySound(inst.sounds.death)
        end,

        timeline =
        {
            TimeEvent(31*FRAMES, lower_flying_creature),
        },
    },

    State {
        name = "attack",
        tags = {"attack", "charge"},

        onenter = function(inst, target)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)

            inst.SoundEmitter:PlaySound("terraria1/mini_eyeofterror/atk_pre")

            inst.components.combat:StartAttack()

            inst.sg.statemem.target = target
        end,

        timeline =
        {
            TimeEvent(5*FRAMES, function(inst)
                inst.Physics:SetMotorVelOverride(4, 0, 0)
                inst.sg.statemem._motorvel_set = true
            end),
            TimeEvent(14*FRAMES, function(inst)
                local target = (
                        inst.sg.statemem.target ~= nil
                        and inst.sg.statemem.target:IsValid()
                        and inst.sg.statemem.target
                    )
                    or nil -- NOTE: nil falls through to combat.target
                inst.components.combat:DoAttack(target)
            end),
            TimeEvent(22*FRAMES, function(inst)
                inst.Physics:ClearMotorVelOverride()
                inst.sg.statemem._motorvel_set = false

                inst.components.locomotor:Stop()
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if math.random() < 0.333 then
                    inst:FocusTarget(nil)
                    inst.sg:GoToState("taunt")
                else
                    return_to_idle(inst)
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem._motorvel_set then
                inst.Physics:ClearMotorVelOverride()
            end
        end,
    },

    State {
        name = "eat",
        tags = {"busy"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()

            inst.AnimState:PlayAnimation("eat_pre")
            inst.AnimState:PushAnimation("eat_loop", false)
            inst.AnimState:PushAnimation("eat_pst", false)

            inst.SoundEmitter:PlaySound("terraria1/mini_eyeofterror/eat_pre")
        end,

        timeline =
        {
            TimeEvent(22*FRAMES, function(inst)
                inst.sg.statemem.eat_succeeded = inst:PerformBufferedAction()

                lower_flying_creature(inst)
            end),
            TimeEvent(26*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("terraria1/mini_eyeofterror/eat_lp", "eat_loop")
            end),
            TimeEvent(58*FRAMES, function(inst)
                inst.SoundEmitter:KillSound("eat_loop")
                inst.SoundEmitter:PlaySound("terraria1/mini_eyeofterror/eat_pst")
            end),
            TimeEvent(84*FRAMES, raise_flying_creature),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.sg.statemem.eat_succeeded then
                    inst:FocusTarget(nil)
                    inst.sg:GoToState("taunt")
                else
                    return_to_idle(inst)
                end
            end),
        },

        onexit = function(inst)
            -- In case we got interrupted somehow
            inst:ClearBufferedAction()

            raise_flying_creature(inst)
        end,
    },
}

CommonStates.AddSleepExStates(states,
{
    starttimeline =
    {
        TimeEvent(36*FRAMES, lower_flying_creature),
    },
    waketimeline =
    {
        TimeEvent(22*FRAMES, raise_flying_creature),
    },
},
{
    onsleep = function(inst)
        inst.SoundEmitter:PlaySound("terraria1/mini_eyeofterror/sleep_pre")
    end,
    onwake = function(inst)
        inst.SoundEmitter:PlaySound("terraria1/mini_eyeofterror/sleep_pst")
    end,
    onexitwake = raise_flying_creature,
})

CommonStates.AddFrozenStates(states, lower_flying_creature, raise_flying_creature)

CommonStates.AddWalkStates(states)

local appear_tags = { "busy" }
local appear_timeline =
{
    TimeEvent(19*FRAMES, raise_flying_creature),
    TimeEvent(43*FRAMES, function(inst)
        inst.SoundEmitter:PlaySound("terraria1/mini_eyeofterror/appear")
    end),
    TimeEvent(93*FRAMES, function(inst)
        inst.sg:RemoveStateTag("busy")
    end),
}
CommonStates.AddSimpleState(states, "appear", "appear", appear_tags, "idle", appear_timeline)

return StateGraph("eyeofterror_mini", states, events, "idle", actionhandlers)
