require("stategraphs/commonstates")

local events =
{
    EventHandler("death", function(inst)
        inst.sg:GoToState("death")
    end),
    EventHandler("newcombattarget", function(inst,data)
        if inst.sg:HasStateTag("idle") and data.target then
            inst.sg:GoToState("taunt")
        end
    end),
}

local states =
{
    State{
        name = "idle",
        tags = {"idle", "invisible"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("breach_pre")
            inst.AnimState:PushAnimation("breach_idle", true)
        end,
    },

    State{
        name = "taunt",
        tags = {"taunting"},
        onenter = function(inst)
            inst.AnimState:PushAnimation("breach_idle", true)
        end,

        onupdate = function(inst)
            if inst.sg.timeinstate > 0.75 and inst.components.combat:TryAttack() then
                inst.sg:GoToState("attack")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.components.combat.target == nil then
                    inst.sg:GoToState("attack_pst")
                end
            end),
        },
    },

    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("death2")
            RemovePhysicsColliders(inst)
        end,
    },

}
CommonStates.AddFrozenStates(states)

CommonStates.AddSimpleState(states, "attack", "atk", {"attack"}, "attack_pst",
{
	FrameEvent(15, function(inst)
		local target = inst.components.combat.target
		inst.components.combat:DoAttack()
		if inst.owner ~= nil and
			target ~= nil and
			target.components.combat ~= nil and
			target.components.combat:TargetIs(inst) and
			target.components.combat:CanTarget(inst.owner)
		then
			--forward aggro back to our owner
			target.components.combat:SetTarget(inst.owner)
		end
	end),
    FrameEvent(18, function(inst) inst.sg:RemoveStateTag("attack") end),
},
{
    onenter = function(inst) inst.components.combat:StartAttack() end,
})
CommonStates.AddSimpleState(states, "attack_pst", "breach_pst", nil, nil, nil,
{
    onexit = function(inst) inst:Remove() end,
})

return StateGraph("lunarplanttentacle", states, events, "idle")

