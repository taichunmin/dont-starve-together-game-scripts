require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(
        ACTIONS.EAT,
        function(inst, action)
            return (action.target.components.oceanfishable ~= nil and "bitehook_pre") or nil
        end
    ),
    ActionHandler(ACTIONS.GOHOME, "enter_home"),
}

local events =
{
    CommonHandlers.OnLocomote(true, false),
}

local states =
{
    State{
        name = "bitehook_pre",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("struggle_loop", false)

            inst:PerformBufferedAction()
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.components.oceanfishable ~= nil and inst.components.oceanfishable:GetRod() ~= nil then
                        inst.sg:GoToState("bitehook_loop")
                    else
                        inst.sg:GoToState("bitehook_escape")
                    end
                end
            end),
        },
    },

    State{
        name = "bitehook_loop",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("struggle_loop", true)
            inst.sg:SetTimeout(2 + math.random() * 0.5)
        end,

        onupdate = function(inst)
            if inst.components.oceanfishable ~= nil and inst.components.oceanfishable:GetRod() ~= nil then
                if not inst:HasTag("partiallyhooked") then
                    inst.sg:GoToState("idle")
                end
            else
                inst.sg:GoToState("bitehook_escape")
                inst.components.oceanfishable:SetRod(nil)
            end
        end,

        ontimeout = function(inst)
            if inst:HasTag("partiallyhooked") then
                inst.sg:GoToState("bitehook_escape")
                if inst.components.oceanfishable ~= nil and inst.components.oceanfishable:GetRod() ~= nil then
                    inst.components.oceanfishable:GetRod().components.oceanfishingrod:StopFishing("linetooloose")
                else
                    inst.components.oceanfishable:SetRod(nil)
                end
            end
        end,
    },

    State{
        name = "bitehook_escape",
        tags = { "busy", "jumping" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            local x, y, z = inst.Transform:GetWorldPosition()
            inst.sg.statemem.underboat = (TheWorld.Map:GetPlatformAtPoint(x, y, z, inst:GetPhysicsRadius(0)) ~= nil)

            if inst.sg.statemem.underboat then
                inst.AnimState:PlayAnimation("idle")
            else
                inst.AnimState:PlayAnimation("jump")
                inst.AnimState:PushAnimation("jump_pst", false)
            end
        end,

        timeline =
        {
            TimeEvent(2*FRAMES, function(inst)
                if not inst.sg.statemem.underboat then
                    SpawnPrefab("ocean_splash_small1").Transform:SetPosition(inst.Transform:GetWorldPosition())
                    inst.AnimState:SetSortOrder(0)
                    inst.AnimState:SetLayer(LAYER_WORLD)
                end
            end),

            TimeEvent(3*FRAMES, function(inst)
                if not inst.sg.statemem.underboat then
                    inst.Physics:SetMotorVelOverride(-1, 0, 0)
                end
            end),

            TimeEvent(21*FRAMES, function(inst)
                if not inst.sg.statemem.underboat then
                    SpawnPrefab("ocean_splash_small1").Transform:SetPosition(inst.Transform:GetWorldPosition())
                    inst.Physics:ClearMotorVelOverride()
                end
                inst.components.locomotor:Stop()
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    if not inst.sg.statemem.underboat then
                        SpawnPrefab("ocean_splash_small1").Transform:SetPosition(inst.Transform:GetWorldPosition())
                    end
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.underboat then
                inst.AnimState:SetSortOrder(ANIM_SORT_ORDER_BELOW_GROUND.UNDERWATER)
                inst.AnimState:SetLayer(LAYER_WIP_BELOW_OCEAN)
                inst.Physics:ClearMotorVelOverride()
            end

            if inst:HasTag("partiallyhooked") and inst.components.oceanfishable ~= nil then
                inst.components.oceanfishable:SetRod(nil)
            end
        end,
    },

    State{
        name = "launched_out_of_water",
        tags = { "busy", "jumping" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            SpawnPrefab("ocean_splash_small1").Transform:SetPosition(inst.Transform:GetWorldPosition())

            inst.AnimState:PlayAnimation("jump_loop", true)
        end,
    },

    State{
        name = "hop_pst",
        tags = {"busy", "jumping"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("jump_pst", false)
        end,

        timeline =
        {
            TimeEvent(3*FRAMES, function(inst)
                SpawnPrefab("ocean_splash_small1").Transform:SetPosition(inst.Transform:GetWorldPosition())
            end),
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
        name = "spawn_in",
        tags = {"busy"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("spawn_in")
            inst.SoundEmitter:PlaySound("hookline_2/creatures/wobster/burrow")
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
}

CommonStates.AddIdle(states, false, "idle")

local function play_run_step(inst)
    inst.SoundEmitter:PlaySound("hookline_2/creatures/wobster/step")
end

CommonStates.AddRunStates(states,
{
    starttimeline =
    {
        TimeEvent(2*FRAMES, play_run_step),
    },
    runtimeline =
    {
        TimeEvent(4*FRAMES, play_run_step),
        TimeEvent(8*FRAMES, play_run_step),
        TimeEvent(12*FRAMES, play_run_step),
        TimeEvent(16*FRAMES, play_run_step),
        TimeEvent(20*FRAMES, play_run_step),
        TimeEvent(24*FRAMES, play_run_step),
        TimeEvent(28*FRAMES, play_run_step),
        TimeEvent(32*FRAMES, play_run_step),
    },
    endtimeline =
    {
        TimeEvent(2*FRAMES, play_run_step),
    },
})
CommonStates.AddSimpleActionState(states, "enter_home", "idle", 2*FRAMES, {"busy"})

return StateGraph("wobster", states, events, "spawn_in", actionhandlers)
