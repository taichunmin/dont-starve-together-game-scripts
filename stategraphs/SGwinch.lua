local events =
{
    EventHandler("start_lowering_winch", function(inst)
        inst.sg:GoToState("lowering")
    end),
    EventHandler("start_raising_winch", function(inst)
        inst.sg:GoToState("raising")
    end),

    EventHandler("winch_fully_lowered", function(inst)
        inst.sg:GoToState("lowering_pst")
    end),
    EventHandler("winch_fully_raised", function(inst)
        if inst:GetCurrentPlatform() == nil then
            inst.sg:GoToState("raised")
        else
            inst.sg:GoToState("raising_pst")
        end
    end),
}

local states =
{
    State{
        name = "raised",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle", true)
        end,

        events =
        {
            EventHandler("workinghit",
                function(inst, data)
                    inst.AnimState:PlayAnimation("hit")
                    inst.AnimState:PushAnimation("idle", true)
                end),
            EventHandler("claw_interact_ground",
                function(inst, data)
                    inst.sg:GoToState("lowered_ground")
                end),
        },
    },

    State{
        name = "lowered_ground",
        tags  = { "lowered_ground" },
        onenter = function(inst)
            inst:AddTag("lowered_ground")
            inst.AnimState:PlayAnimation("drop_ground_pre")
            inst.AnimState:PushAnimation("drop_ground_loop")

            inst.SoundEmitter:PlaySound(inst.sounds.drop_ground_pre)
        end,

        onexit = function(inst)
            inst:RemoveTag("lowered_ground")
        end,

        events =
        {
            EventHandler("workinghit",
                function(inst, data)
                    inst.AnimState:PlayAnimation("drop_ground_hit")
                    inst.AnimState:PushAnimation("drop_ground_loop", true)
                end),
            EventHandler("claw_interact_ground",
                function(inst, data)
                    inst.sg:GoToState("raising_ground")
                end),
        },
    },

    State{
        name = "raising_ground",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("drop_ground_pst")

            inst.SoundEmitter:PlaySound(inst.sounds.drop_ground_pst)
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                    inst.components.winch:FullyRaised()
                end),
        },
    },

    State{
        name = "lowered",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_dropped", true)
        end,

        events =
        {
            EventHandler("workinghit",
                function(inst, data)
                    inst.AnimState:PlayAnimation("drop_pst", true)
                end),
        },
    },

    State{
        name = "raising",
        onenter = function(inst)
            local item = inst.components.inventory:GetItemInSlot(1)
            if item ~= nil and item:HasTag("heavy") then
                inst.AnimState:PlayAnimation("pull_heavy_pre")
                inst.AnimState:PushAnimation("pull_heavy_loop", true)
            else
                inst.AnimState:PlayAnimation("pull_pre")
                inst.AnimState:PushAnimation("pull_loop", true)

                inst.SoundEmitter:PlaySound(inst.sounds.reel_fast, "mooring")
            end
        end,

        timeline =
        {
            TimeEvent(45 * FRAMES, function(inst)
                if not inst.SoundEmitter:PlayingSound("mooring") then
                    inst.SoundEmitter:PlaySound(inst.sounds.reel_slow, "mooring")
                end
            end),
        },
    },

    State{
        name = "raising_pst",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("pull_pst")
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)
                inst.SoundEmitter:KillSound("mooring")
                inst.SoundEmitter:PlaySound(inst.sounds.pull_pst)
            end),
            TimeEvent(18 * FRAMES, function(inst)
                local item = inst.components.inventory ~= nil and inst.components.inventory:GetItemInSlot(1) or nil
                if item ~= nil then
                    local boat = inst:GetCurrentPlatform()
                    if boat ~= nil then
                        if item:HasTag("heavy") then
                            ShakeAllCamerasOnPlatform(CAMERASHAKE.VERTICAL, 0.3, 0.015, 0.35, boat)
                        else
                            ShakeAllCamerasOnPlatform(CAMERASHAKE.VERTICAL, 0.2, 0.015, 0.1, boat)
                        end
                    end
                end
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("raised") end),
        },
    },

    State{
        name = "lowering",

        onenter = function(inst)
            inst.AnimState:PlayAnimation("drop_pre")
            inst.AnimState:PushAnimation("drop_loop", true)

            inst.SoundEmitter:PlaySound(inst.sounds.drop_water_pre)
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.reel_fast, "mooring")
            end),
        },
    },

    State{
        name = "lowering_pst",
        onenter = function(inst)
            inst.AnimState:PlayAnimation(inst.components.inventory:GetItemInSlot(1) ~= nil
                and "drop_success_pst"
                or "drop_fail_pst")
        end,

        timeline =
        {
            TimeEvent(2 * FRAMES, function(inst) inst.SoundEmitter:KillSound("mooring") end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("lowered") end),
        },
    },
}

return StateGraph("winch", states, events, "raised")
