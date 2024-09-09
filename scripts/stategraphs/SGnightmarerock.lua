

local states =
{
    State{
        name = "idle",
        tags = { "idle" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation(inst.active and "idle_active" or "idle_inactive")
        end,
    },

    State{
        name = "raise",
        tags = { "idle", "busy" },

        onenter = function(inst)
			inst:OnActiveStateChanged()
            inst.AnimState:PlayAnimation("raise")
			inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowrock_up")
			SpawnPrefab("sanity_raise").Transform:SetPosition(inst.Transform:GetWorldPosition())
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					if inst.conceal or inst.conceal_queued then
						inst.sg:GoToState("conceal", true)
					else
						inst.sg:GoToState("idle")
					end
                end
            end),
        },
    },

    State{
        name = "lower",
        tags = { "idle", "busy" },

        onenter = function(inst)
			inst:OnActiveStateChanged()
            inst.AnimState:PlayAnimation("lower")
			inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowrock_down")
			SpawnPrefab("sanity_lower").Transform:SetPosition(inst.Transform:GetWorldPosition())
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState((inst.conceal or inst.conceal_queued) and "conceal" or "idle")
                end
            end),
        },
    },

    State{
        name = "conceal",
        tags = { "hidden", "busy" },

        onenter = function(inst, from_raise)
			inst:OnConcealStateChanged()
			if from_raise then
	            inst.AnimState:PlayAnimation("lower_to_conceal")
				inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowrock_down")
				SpawnPrefab("sanity_lower").Transform:SetPosition(inst.Transform:GetWorldPosition())
			else
	            inst.AnimState:PlayAnimation("conceal")
				inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowrock_conseal")
			end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState(inst.conceal_queued and "concealed" or "reveal")
                end
            end),
        },
    },

    State{
        name = "concealed",
        tags = { "hidden", "idle" },

        onenter = function(inst)
			inst:Hide()
        end,

        onexit = function(inst)
			inst:Show()
        end,
    },

    State{
        name = "reveal",
        tags = { "busy" },

        onenter = function(inst)
			inst:OnConcealStateChanged()
            inst.AnimState:PlayAnimation("reveal")
			inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowrock_reveal")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState(inst.conceal_queued and "conceal" or "idle")
                end
            end),
        },
    },

}

return StateGraph("nightmarerock", states, {}, "idle")
