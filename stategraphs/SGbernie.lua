require "stategraphs/commonstates"

local events =
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnAttacked(),
    EventHandler("death", function(inst, data)
        if not inst.sg:HasStateTag("deactivating") then
            inst.sg:GoToState("death", data)
        end
    end),
}

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            if not inst.AnimState:IsCurrentAnimation("idle_loop") then
                inst.AnimState:PlayAnimation("idle_loop", true)
            end
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie/idle")
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "idle_nodir",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("idle_loop_nodir")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie/idle")
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        timeline =
        {
            TimeEvent(.5, function(inst)
                local t = inst.AnimState:GetCurrentAnimationTime()
                inst.AnimState:PlayAnimation("idle_loop", true)
                inst.AnimState:SetTime(t)
                inst.Transform:SetFourFaced()
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,

        onexit = function(inst)
            inst.Transform:SetFourFaced()
        end,
    },

    State{
        name = "taunt",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.components.timer:StartTimer("taunt_cd", 4)
        end,

        timeline =
        {
            --3, 12, 21, 30
            TimeEvent(FRAMES * 3, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie/taunt") end),
            TimeEvent(FRAMES * 12, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie/taunt") end),
            TimeEvent(FRAMES * 21, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie/taunt") end),
            TimeEvent(FRAMES * 30, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie/taunt") end),
            --10, 20, 28, 36
            TimeEvent(FRAMES * 10, PlayFootstep),
            TimeEvent(FRAMES * 20, PlayFootstep),
            TimeEvent(FRAMES * 28, PlayFootstep),
            TimeEvent(FRAMES * 36, PlayFootstep),

            TimeEvent(FRAMES * 20, function(inst) inst.sg:RemoveStateTag("busy") end),
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

    State{
        name = "hit",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie/hit")
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
        name = "death",
        tags = { "busy", "deactivating" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("death")
            inst.Transform:SetNoFaced()
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie/death")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:GoInactive()
                end
            end),
        },

        onexit = function(inst)
            --V2C: shouldn't happen
            inst.Transform:SetFourFaced()
        end,
    },

    State{
        name = "activate",
        tags = { "busy", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("activate")
            inst.Transform:SetNoFaced()
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie/sit_up") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.nodir = true
                    inst.sg:GoToState("idle_nodir")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.nodir then
                inst.Transform:SetFourFaced()
            end
        end,
    },

    State{
        name = "deactivate",
        tags = { "busy", "deactivating" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("deactivate")
            inst.Transform:SetNoFaced()
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie/sit_down") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:GoInactive()
                end
            end),
        },

        onexit = function(inst)
            --V2C: shouldn't happen
            inst.Transform:SetFourFaced()
        end,
    },
}

CommonStates.AddWalkStates(states,
{
    walktimeline =
    {
        TimeEvent(10 * FRAMES, function(inst)
            PlayFootstep(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie/walk")
        end),
        TimeEvent(30 * FRAMES, function(inst)
            PlayFootstep(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie/walk")
        end),
    },
    endtimeline =
    {
        TimeEvent(3 * FRAMES, function(inst)
            PlayFootstep(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie/walk")
        end),
    },
})

return StateGraph("bernie", states, events, "activate")
