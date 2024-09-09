require("stategraphs/commonstates")
require("ocean_util")

local events =
{
    CommonHandlers.OnLocomote(false, true),
}

local function blink_sound(inst)
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/blink")
end

local function angry_sound(inst)
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/angry")
end

local function go_to_idle(inst)
    inst.sg:GoToState("idle")
end

local states =
{
    State {
        name = "emote_checkpoint",
        tags = {"busy"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("emote_cute")
        end,

        timeline =
        {
            TimeEvent(4*FRAMES, blink_sound),
            TimeEvent(14*FRAMES, blink_sound),
            TimeEvent(24*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/swipe")
            end),
            TimeEvent(42*FRAMES, blink_sound),
            TimeEvent(59*FRAMES, blink_sound),
        },

        events =
        {
            EventHandler("animover", go_to_idle)
        },
    },

    State {
        name = "emote_collision",
        tags = {"busy"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("distress")
        end,

        timeline =
        {
            TimeEvent(12*FRAMES, angry_sound),
            TimeEvent(22*FRAMES, angry_sound),
            TimeEvent(29*FRAMES, angry_sound),
            TimeEvent(36*FRAMES, angry_sound),
        },

        events =
        {
            EventHandler("animover", go_to_idle)
        },
    },

    State {
        name = "fly_away_pre",
        tags = {"busy"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("emote_flame")
        end,

        timeline =
        {
            TimeEvent(4*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/blink")
            end),
            TimeEvent(14*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/emote_flame")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("fly_away")
            end),
        },
    },

    State {
        name = "fly_away",
        tags = { "flight", "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("walk_pre")
            inst.AnimState:PushAnimation("walk_loop", true)

            -- A hardcoded vector direction stolen from the dragonfly's flyaway state.
            local x, y, z = 0.5019684438612,7.5216834009827,2.7178563798944
            inst.Physics:SetMotorVel(x, y, z)

            inst.sg:SetTimeout(3.5)
        end,

        ontimeout = function(inst)
            inst:Remove()
        end,

        onexit = function(inst)
            inst:Remove()
        end,
    },

    State {
        name = "fly_in",
        tags = { "flight", "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("walk_pre")
            inst.AnimState:PushAnimation("walk_loop", true)
            inst.Physics:SetMotorVelOverride(0, -15, 0)
        end,

        onupdate = function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            if y < 1 or inst:IsAsleep() then
                inst.Physics:ClearMotorVelOverride()
                inst.Physics:Stop()
                inst.Physics:Teleport(x, 0, z)
                inst.sg:GoToState("idle")
            end
        end,

        onexit = function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            if y > 0 then
                inst.Transform:SetPosition(x, 0, z)
            end
            inst.Physics:ClearMotorVelOverride()
        end,
    },
}

CommonStates.AddIdle(states)
CommonStates.AddWalkStates(states, nil, nil, true)

return StateGraph("SGboatrace_spectator_dragonling", states, events, "idle")