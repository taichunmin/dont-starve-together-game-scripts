local events =
{
}

local states =
{
    State{
        name = "idle",
        tags = { "idle" },

        onenter = function(inst)
            local container = inst.components.container
            if container and inst.sg.mem.lowered then
                if container:IsFull() then
                    inst.AnimState:PlayAnimation("idle_full", true)
                elseif container:IsEmpty() then
                    inst.AnimState:PlayAnimation("idle_2", true)
                else
                    inst.AnimState:PlayAnimation("idle_medium", true)
                end
            else
                inst.AnimState:PlayAnimation("idle", true)
            end
        end,
    },

    State{
        name = "place",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("place")
            inst.SoundEmitter:PlaySound("monkeyisland/trawlingpole/place")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "hit",
        tags = { "busy" },

        onenter = function(inst, data)
            local container = inst.components.container
            if container and inst.sg.mem.lowered then
                if container:IsFull() then
                    inst.AnimState:PlayAnimation("hit_lower_full")
                elseif container:IsEmpty() then
                    inst.AnimState:PlayAnimation("hit_lower")
                else
                    inst.AnimState:PlayAnimation("hit_lower_medium")
                end

                inst.SoundEmitter:PlaySound("monkeyisland/trawlingpole/hit")
            else
                inst.AnimState:PlayAnimation("hit")
                inst.SoundEmitter:PlaySound("monkeyisland/trawlingpole/hit")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "lower",
        tags = { "busy" },

        onenter = function(inst)
            inst.sg.mem.lowered = true
            local container = inst.components.container
            if container then
                if container:IsFull() then
                    inst.AnimState:PlayAnimation("lower_full")
                elseif container:IsEmpty() then
                    inst.AnimState:PlayAnimation("lower")
                else
                    inst.AnimState:PlayAnimation("lower_medium")
                end
            end

            inst.SoundEmitter:PlaySound("monkeyisland/trawlingpole/lower")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "raise",
        tags = { "busy" },

        onenter = function(inst)
            inst.sg.mem.lowered = false
            local container = inst.components.container
            if container then
                if container:IsFull() then
                    inst.AnimState:PlayAnimation("raise_full")
                elseif container:IsEmpty() then
                    inst.AnimState:PlayAnimation("raise")
                else
                    inst.AnimState:PlayAnimation("raise_medium")
                end
            end

            inst.SoundEmitter:PlaySound("monkeyisland/trawlingpole/raise")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "catch",
        tags = { "busy" },

        onenter = function(inst, data)
            local container = inst.components.container
            if container then
                if container:IsFull() then
                    inst.AnimState:PlayAnimation("catch_full")
                elseif container:IsEmpty() then
                    inst.AnimState:PlayAnimation("catch")
                else
                    inst.AnimState:PlayAnimation("catch_medium")
                end
            end

            inst.SoundEmitter:PlaySound("monkeyisland/trawlingpole/shake")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "catch_pst",
        tags = { "busy" },

        onenter = function(inst, data)
            if data ~= nil then
                if data.empty then
                    inst.AnimState:PlayAnimation("empty_medium")
                elseif inst.components.container and inst.components.container:IsFull() then
                    inst.AnimState:PlayAnimation("medium_full")
                else
                    inst.sg:GoToState("idle")
                end
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "overload",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("overload")
            inst.SoundEmitter:PlaySound("monkeyisland/trawlingpole/overload")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("overload_pst1")
            end),
        },
    },

    State{
        name = "overload_pst1",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("full_medium")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("overload_pst2")
            end),
        },
    },

    State{
        name = "overload_pst2",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("medium_empty")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
}

return StateGraph("ocean_trawler", states, events, "idle")
