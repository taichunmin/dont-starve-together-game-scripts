local events =
{
    EventHandler("onturnon", function(inst)
        inst.sg:GoToState("activate")
    end),
}

--V2C: TERRIBLE, but not worth the effort to refactor.
--     plz DO NOT COPY or reuse ANY code from boatmagnetbeacon.

local states =
{
    State {
        name = "idle",
        tags = { "idle" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle", true)
            --inst.AnimState:PlayAnimation("no_target", true)
        end,

		events =
		{
			EventHandler("worked", function(inst)
				if not inst.AnimState:IsCurrentAnimation("hit_inactive") then
					inst.AnimState:PlayAnimation("hit_inactive")
					inst.AnimState:PushAnimation("idle")
				end
			end),
		},
    },

    State {
        name = "place",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("placer")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State {
        name = "hit",
        tags = { "busy" },

        onenter = function(inst)
            if inst.components.boatmagnetbeacon and inst.components.boatmagnetbeacon:IsTurnedOff() then
                inst.AnimState:PlayAnimation("hit_inactive")
            else
                inst.AnimState:PlayAnimation("hit_active")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State {
        name = "activate",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("active_pre")
        end,

        events =
        {
			EventHandler("worked", function(inst)
				if inst.AnimState:IsCurrentAnimation("active_pre") then
					if inst.AnimState:GetCurrentAnimationFrame() < 7 then
						inst.AnimState:PlayAnimation("hit_inactive")
						inst.AnimState:PushAnimation("active_pre", false)
					else
						inst.AnimState:PlayAnimation("hit_active")
					end
				end
			end),
			EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("active")
            end),
        },
    },

    State {
        name = "active",
        tags = { "idle" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("active_loop", true)
        end,

		events =
		{
			EventHandler("worked", function(inst)
				if not inst.AnimState:IsCurrentAnimation("hit_active") then
					inst.AnimState:PlayAnimation("hit_active")
					inst.AnimState:PushAnimation("active_loop")
				end
			end),
		},
    },

    State {
        name = "deactivate",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("active_pst")
        end,

        events =
        {
			EventHandler("worked", function(inst)
				if inst.AnimState:IsCurrentAnimation("active_pst") then
					if inst.AnimState:GetCurrentAnimationFrame() < 9 then
						inst.AnimState:PlayAnimation("hit_active")
					else
						inst.AnimState:PlayAnimation("hit_inactive")
					end
				end
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.AnimState:IsCurrentAnimation("active_pst") then
						inst.sg:GoToState("idle")
					else
						inst.AnimState:PlayAnimation("active_pst")
						inst.AnimState:SetFrame(9)
					end
				end
            end),
        },
    },
}

return StateGraph("boatmagnetbeacon", states, events, "idle")
