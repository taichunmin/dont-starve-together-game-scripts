require("stategraphs/commonstates")

local actionhandlers =
{}

local events=
{
    EventHandler("locomote", function(inst)
        if not inst.sg:HasStateTag("busy") then
			local is_moving = inst.sg:HasStateTag("moving")
			local wants_to_move = inst.components.locomotor:WantsToMoveForward()
			if is_moving ~= wants_to_move then
				if wants_to_move then
					inst.sg.statemem.wantstomove = true
				else
					inst.sg:GoToState("idle")
				end
			end
        end
    end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
}


local states=
{

    State{
        name = "moving",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
			inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("flight_cycle", true)
        end,
    },

    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("land")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
        end,

        timeline =
        {
            TimeEvent(45*FRAMES, function(inst)
                inst.Light:Enable(false)
                inst.DynamicShadow:Enable(false)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst:Remove() end)
        },
    },

    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            inst.Physics:Stop()
            if not inst.AnimState:IsCurrentAnimation("idle_flight_loop") then
                inst.AnimState:PlayAnimation("idle_flight_loop", true)
            end
            inst.sg:SetTimeout( inst.AnimState:GetCurrentAnimationLength() )
        end,

        ontimeout = function(inst)
            if inst.sg.statemem.wantstomove then
                inst.sg:GoToState("moving")
            else
                inst.sg:GoToState("idle")
            end
        end,
    },

    State{
        name = "land",
        tags = {"busy", "landing"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("land")
        end,

        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("land_idle")
            end),
        },
    },

    State{
        name = "land_idle",
        tags = {"busy", "landed"},

        onenter = function(inst)
            inst.AnimState:PushAnimation("idle", true)
        end,
    },

    State{
        name = "takeoff",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("cough_out")
        end,

        timeline =
        {
            TimeEvent(14*FRAMES, function(inst)
                inst.Light:Enable(true)
                inst.DynamicShadow:Enable(true)
                inst.SoundEmitter:PlaySound("dontstarve/cave/mushtree_tall_spore_land")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },

    },

}
CommonStates.AddFrozenStates(states)

return StateGraph("spore", states, events, "takeoff")
