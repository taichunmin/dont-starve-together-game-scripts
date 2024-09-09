local events =
{
    EventHandler("boatmagnet_pull_start", function(inst)
        if inst.sg:HasStateTag("idle") then
            inst.sg:GoToState("pull_pre")
        end
    end),
    EventHandler("boatmagnet_pull_stop", function(inst)
        if inst.sg:HasStateTag("pulling") then
            inst.sg:GoToState("pull_pst")
        end
    end),
}

local function go_to_idle(inst)
    inst.sg:GoToState("idle")
end

--V2C: TERRIBLE, but not worth the effort to refactor.
--     plz DO NOT COPY or reuse ANY code from boatmagnet.

local states =
{
    State {
        name = "idle",
        tags = { "idle" },

        onenter = function(inst)
            if inst.components.boatmagnet and inst.components.boatmagnet:PairedBeacon() ~= nil then
                inst.AnimState:PlayAnimation("idle_activated", true)
            else
                inst.AnimState:PlayAnimation("idle")
            end
        end,

        events =
        {
            EventHandler("worked_off", function(inst)
                inst.sg:GoToState("worked")
            end),
        },
    },

    State {
        name = "worked",
        tags = {"idle"},

        onenter = function(inst, next_state)
            inst.AnimState:PlayAnimation("hit")

            inst.sg.statemem.next_state = next_state
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState(inst.sg.statemem.next_state or "idle")
            end),
        },
    },

    State {
        name = "worked_off",
        tags = {"idle"},

        onenter = function(inst, next_state)
            inst.AnimState:PlayAnimation("hit_off")

            inst.sg.statemem.next_state = next_state
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState(inst.sg.statemem.next_state or "idle")
            end),
        },
    },

    State {
        name = "place",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("place")
        end,

        timeline =
        {
            FrameEvent(27, function(inst)
                inst.sg:AddStateTag("caninterrupt")
            end),
        },

        events =
        {
            EventHandler("worked", function(inst)
                if inst.sg:HasStateTag("caninterrupt") then
                    inst.sg:GoToState("worked_off")
                end
            end),
            EventHandler("animover", go_to_idle),
        },
    },

    State {
        name = "search_pre",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("search_pre")
            inst.SoundEmitter:PlaySound("monkeyisland/autopilot/magnet_search_pre")
        end,

        events =
        {
            EventHandler("worked", function(inst)
                inst.sg:GoToState("worked_off", "search_loop")
            end),
            EventHandler("animover", function(inst)
                inst.sg:GoToState("search_loop")
            end),
        },
    },

    State {
        name = "search_loop",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("search_loop")
            inst.SoundEmitter:PlaySound("monkeyisland/autopilot/beacon_search","search_loop")
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("search_loop")
        end,

        events =
        {
            EventHandler("worked", function(inst)
                -- If we get worked while looping, restart the searching states.
                inst.sg:GoToState("worked_off", "search_pre")
            end),
            EventHandler("animover", function(inst)
                local nearestbeacon = (inst.components.boatmagnet ~= nil and inst.components.boatmagnet:FindNearestBeacon())
                    or nil
                if nearestbeacon then
                    inst.components.boatmagnet:PairWithBeacon(nearestbeacon)
                    inst.sg:GoToState("success")
                else
                    inst.sg:GoToState("fail")
                end
            end),
        },
    },

    State {
        name = "success",
        tags = {},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("success")
            inst.SoundEmitter:PlaySound("monkeyisland/autopilot/paired")
        end,

        events =
        {
            EventHandler("worked", function(inst)
                inst.sg:GoToState("worked_off", "pull_pre")
            end),
            EventHandler("animover", function(inst)
                inst.sg:GoToState("pull_pre")
            end),
        },
    },

    State {
        name = "fail",
        tags = {},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("fail")
            inst.SoundEmitter:PlaySound("monkeyisland/autopilot/pair_failed")
        end,

        events =
        {
            EventHandler("worked", function(inst)
                inst.sg:GoToState("worked_off", "idle")
            end),
            EventHandler("animover", go_to_idle),
        },
    },

    State {
        name = "pull_pre",
        tags = { "busy", "pulling" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("pull_pre")
            inst.SoundEmitter:PlaySound("monkeyisland/autopilot/magnet_lp_start", "pull_loop_start")
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("pull_loop_start")
        end,

        events =
        {
            EventHandler("worked", function(inst)
                inst.sg:GoToState("worked", "pull")
            end),
            EventHandler("animover", function(inst)
                inst.sg:GoToState("pull")
            end),
        },
    },

    State {
        name = "pull",
        tags = { "pulling" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("pull", true)
            inst.SoundEmitter:PlaySound("monkeyisland/autopilot/magnet_lp", "pull_loop")
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("pull_loop")
        end,

        events =
        {
            EventHandler("worked", function(inst)
                inst.sg:GoToState("worked", "pull")
            end),
        },
    },

    State {
        name = "pull_pst",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("pull_pst", false)
            if inst.components.boatmagnet and not inst.components.boatmagnet:PairedBeacon() then
                inst.AnimState:PushAnimation("fail", false)
            end
            inst.SoundEmitter:PlaySound("monkeyisland/autopilot/magnet_lp_end")
        end,

        events =
        {
            EventHandler("worked", function(inst)
                if inst.AnimState:IsCurrentAnimation("pull_pst") then
                    inst.sg:GoToState(
                        "worked",
                        (
                            inst.components.boatmagnet and
                            not inst.components.boatmagnet:PairedBeacon() and
                            "fail"
                        ) or nil
                    )
                else
                    inst.sg:GoToState("worked_off")
                end
            end),
            EventHandler("animqueueover", go_to_idle),
        },
    },

	State {
		name = "burnt",
		tags = { "busy", "burnt" },
		--Dummy state don't do anything
		--V2C: Please don't copy this...
		--     The correct thing is to refactor boatmagnet, and remove the stategraph on burnt.

		onexit = function(inst)
			if BRANCH == "dev" then
				assert(false)
			end
		end,
	},
}

return StateGraph("boatmagnet", states, events, "idle")
