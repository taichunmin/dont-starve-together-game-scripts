
local function anchor_lowered(inst)
    --if inst.components.anchor ~= nil then
        inst.components.anchor:SetIsAnchorLowered(true)
    --end
end

local function anchor_raised(inst)
    --if inst.components.anchor ~= nil then
        inst.components.anchor:SetIsAnchorLowered(false)
    --end
end

local events=
{

}

local states =
{
    State{
        name = "raised",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("untethered_idle_loop", true)
            anchor_raised(inst)
        end,

        events =
        {
            EventHandler("lowering_anchor",
                function(inst)
                    local anchor_x, anchor_y, anchor_z = inst.Transform:GetWorldPosition()
                    if inst.components.anchor ~= nil and inst.components.anchor.boat ~= nil then
                        inst.sg:GoToState("lowering")
                    else
                        inst.sg:GoToState("lowering_land")
                    end
                end),
            EventHandler("workinghit",
                function(inst, data)
                    inst.AnimState:PlayAnimation("idle_hit")
                    inst.AnimState:PushAnimation("untethered_idle_loop", true)
                end),
        },
    },

    State{
        name = "lowered",
        onenter = function(inst)
            local depth = inst.components.anchor.raiseunits

            if depth > TUNING.ANCHOR_DEPTH_TIMES.DEEP then
                inst.AnimState:PlayAnimation("tethered_idle_loop_empty", true)
            elseif depth > TUNING.ANCHOR_DEPTH_TIMES.BASIC then
                inst.AnimState:PlayAnimation("tethered_idle_loop_low", true)
            elseif depth > TUNING.ANCHOR_DEPTH_TIMES.SHALLOW then
                inst.AnimState:PlayAnimation("tethered_idle_loop_med", true)
            else
                inst.AnimState:PlayAnimation("tethered_idle_loop_full", true)
            end

            anchor_lowered(inst)
        end,

        events =
        {
            EventHandler("lowering_anchor", function(inst) inst.sg:GoToState("lowering") end),
            EventHandler("raising_anchor", function(inst) inst.sg:GoToState("raising") end),
            EventHandler("workinghit",
                function(inst, data)

                    local depth = inst.components.anchor.raiseunits

                    if depth > TUNING.ANCHOR_DEPTH_TIMES.DEEP then
                        inst.AnimState:PlayAnimation("tethered_hit_empty")
                        inst.AnimState:PushAnimation("tethered_idle_loop_empty", true)
                    elseif depth > TUNING.ANCHOR_DEPTH_TIMES.BASIC then
                        inst.AnimState:PlayAnimation("tethered_hit_low")
                        inst.AnimState:PushAnimation("tethered_idle_loop_low", true)
                    elseif depth > TUNING.ANCHOR_DEPTH_TIMES.SHALLOW then
                        inst.AnimState:PlayAnimation("tethered_hit_med")
                        inst.AnimState:PushAnimation("tethered_idle_loop_med", true)
                    else
                        inst.AnimState:PlayAnimation("tethered_hit_full")
                        inst.AnimState:PushAnimation("tethered_idle_loop_full", true)
                    end
                end),
        },
    },

    State{
        name = "lowered_land",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("tether_land_idle")
            anchor_lowered(inst)
        end,

        events =
        {
            EventHandler("raising_anchor", function(inst) inst.sg:GoToState("raising_land") end),
            EventHandler("workinghit",
                function(inst, data)
                    inst.AnimState:PlayAnimation("tether_land_hit")
                    inst.AnimState:PushAnimation("tether_land_idle", false)
                end),
        },
    },

    State{
        name = "raising",
        onenter = function(inst)
            inst.sg.statemem.depth = TUNING.ANCHOR_DEPTH_TIMES.VERY_DEEP
            inst.AnimState:PlayAnimation("untethering_pre_empty")
            inst.AnimState:PushAnimation("untethering_loop_empty", true)
            anchor_raised(inst)
            --inst.sg:SetTimeout(4)
        end,

        onupdate = function(inst)

            local depth = inst.components.anchor.raiseunits

            if depth > TUNING.ANCHOR_DEPTH_TIMES.DEEP then
                if inst.sg.statemem.depth ~= TUNING.ANCHOR_DEPTH_TIMES.VERY_DEEP then
                    inst.sg.statemem.depth = TUNING.ANCHOR_DEPTH_TIMES.VERY_DEEP
                    inst.AnimState:PlayAnimation("untethering_loop_empty", true)
                end
            elseif depth > TUNING.ANCHOR_DEPTH_TIMES.BASIC then
                if inst.sg.statemem.depth ~= TUNING.ANCHOR_DEPTH_TIMES.DEEP then
                    inst.sg.statemem.depth = TUNING.ANCHOR_DEPTH_TIMES.DEEP
                    inst.AnimState:PlayAnimation("untethering_loop_low", true)
                end
            elseif depth > TUNING.ANCHOR_DEPTH_TIMES.SHALLOW then
                if inst.sg.statemem.depth ~= TUNING.ANCHOR_DEPTH_TIMES.BASIC then
                    inst.sg.statemem.depth = TUNING.ANCHOR_DEPTH_TIMES.BASIC
                    inst.AnimState:PlayAnimation("untethering_loop_med", true)
                end
            else
                if inst.sg.statemem.depth ~= TUNING.ANCHOR_DEPTH_TIMES.SHALLOW then
                    inst.sg.statemem.depth = TUNING.ANCHOR_DEPTH_TIMES.SHALLOW
                    inst.AnimState:PlayAnimation("untethering_loop_full", true)
                end
            end
            if not inst.components.anchor.is_anchor_transitioning then
                if inst.components.anchor.raiseunits == 0 then
                    inst.sg:GoToState("raising_pst")
                else
					inst.sg.statemem.keepmooring = true
                    inst.sg:GoToState("lowering_pst")
                end
            end
        end,

        timeline =
        {
            TimeEvent(2 * FRAMES, function(inst)
				if not inst.SoundEmitter:PlayingSound("mooring") then
					inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/anchor/LP", "mooring")
				end
            end),
        },

        events =
        {
            EventHandler("lowering_anchor", function(inst)
                local anchor_x, anchor_y, anchor_z = inst.Transform:GetWorldPosition()
                if inst.components.anchor ~= nil and inst.components.anchor.boat ~= nil then
					inst.sg.statemem.keepmooring = true
                    inst.sg:GoToState("lowering")
                else
                    inst.sg:GoToState("lowering_land")
                end
             end),
        },

		onexit = function(inst)
			if not inst.sg.statemem.keepmooring then
				inst.SoundEmitter:KillSound("mooring")
			end
		end,
    },

    State{
        name = "raising_pst",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("untethering_pst_full")
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/anchor/up")
            end),
        },

        events =
        {
            EventHandler("lowering_anchor", function(inst)
                local anchor_x, anchor_y, anchor_z = inst.Transform:GetWorldPosition()
                if inst.components.anchor ~= nil and inst.components.anchor.boat ~= nil then
                    inst.sg:GoToState("lowering")
                else
                    inst.sg:GoToState("lowering_land")
                end
            end),
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("raised") end),
        },
    },

    State{
        name = "raising_land",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("tether_land_pst")
            anchor_raised(inst)
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/anchor/tether_land_up")
            end),
        },

        events =
        {
            EventHandler("lowering_anchor", function(inst) inst.sg:GoToState("lowering_land") end),
            EventHandler("animover", function(inst) inst.sg:GoToState("raised") end),
        },
    },

    State{
        name = "lowering_land",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("tether_land_pre")
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/anchor/tether_land")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("lowered_land") end),
        }
    },

    State{
        name = "lowering",

        onenter = function(inst)
            inst.sg.statemem.depth = TUNING.ANCHOR_DEPTH_TIMES.LAND
            inst.AnimState:PlayAnimation("tethering_pre_full")
            inst.AnimState:PushAnimation("tethering_loop_full", true)
            anchor_raised(inst)
        end,

        onupdate = function(inst)
            local depth = inst.components.anchor.raiseunits

            if depth < TUNING.ANCHOR_DEPTH_TIMES.SHALLOW then
                if inst.sg.statemem.depth ~= TUNING.ANCHOR_DEPTH_TIMES.LAND then
                    inst.sg.statemem.depth = TUNING.ANCHOR_DEPTH_TIMES.LAND
                    inst.AnimState:PlayAnimation("tethering_loop_full", true)
                end
            elseif depth < TUNING.ANCHOR_DEPTH_TIMES.BASIC then
                if inst.sg.statemem.depth ~= TUNING.ANCHOR_DEPTH_TIMES.SHALLOW then
                    inst.sg.statemem.depth = TUNING.ANCHOR_DEPTH_TIMES.SHALLOW
                    inst.AnimState:PlayAnimation("tethering_loop_med", true)
                end
            elseif depth < TUNING.ANCHOR_DEPTH_TIMES.DEEP then
                if inst.sg.statemem.depth ~= TUNING.ANCHOR_DEPTH_TIMES.BASIC then
                    inst.sg.statemem.depth = TUNING.ANCHOR_DEPTH_TIMES.BASIC
                    inst.AnimState:PlayAnimation("tethering_loop_low", true)
                end
            else
                if inst.sg.statemem.depth ~= TUNING.ANCHOR_DEPTH_TIMES.DEEP then
                    inst.sg.statemem.depth = TUNING.ANCHOR_DEPTH_TIMES.DEEP
                    inst.AnimState:PlayAnimation("tethering_loop_empty", true)
                end
            end

            if not inst.components.anchor.is_anchor_transitioning then
                if inst.components.anchor.raiseunits == 0 then
                    inst.sg:GoToState("raising_pst")
                else
					inst.sg.statemem.keepmooring = true
                    inst.sg:GoToState("lowering_pst")
                end
            end
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/anchor/down")
				if not inst.SoundEmitter:PlayingSound("mooring") then
					inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/anchor/LP", "mooring")
				end
            end),
        },

        events =
        {
			EventHandler("raising_anchor", function(inst)
				inst.sg.statemem.keepmooring = true
				inst.sg:GoToState("raising")
			end),
        },

		onexit = function(inst)
			if not inst.sg.statemem.keepmooring then
				inst.SoundEmitter:KillSound("mooring")
			end
		end,
    },

    State{
        name = "lowering_pst",
        onenter = function(inst)

            local depth = inst.components.anchor.raiseunits

            if depth > TUNING.ANCHOR_DEPTH_TIMES.DEEP then
                inst.AnimState:PlayAnimation("tethering_pst_empty")
            elseif depth > TUNING.ANCHOR_DEPTH_TIMES.BASIC then
                inst.AnimState:PlayAnimation("tethering_pst_low")
            elseif depth > TUNING.ANCHOR_DEPTH_TIMES.SHALLOW then
                inst.AnimState:PlayAnimation("tethering_pst_med")
            else
                inst.AnimState:PlayAnimation("tethering_pst_full")
            end

            anchor_lowered(inst)
        end,

        timeline =
        {
            TimeEvent(2 * FRAMES, function(inst) inst.SoundEmitter:KillSound("mooring") end),
        },

        events =
        {
            EventHandler("lowering_anchor", function(inst) inst.sg:GoToState("lowering") end),
            EventHandler("raising_anchor", function(inst) inst.sg:GoToState("raising") end),
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("lowered") end),
        },

		onexit = function(inst)
			inst.SoundEmitter:KillSound("mooring")
		end,
    },
}

return StateGraph("anchor", states, events, "raised")
