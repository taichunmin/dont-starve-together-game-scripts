require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.TOSS,
        function(inst, action)
            if not inst.sg:HasStateTag('busy') then
                inst.sg:GoToState("shoot", action.target)
            end
        end),
}

local events =
{
    CommonHandlers.OnLocomote(false, true),

    EventHandler("death", function(inst)
		inst.sg:GoToState("death", "death")
	end),
    EventHandler("arrive", function(inst)
        inst.sg:GoToState("emerge")
    end),

    EventHandler("doattack", function(inst)
        if not (inst.sg:HasStateTag("busy")) then
            inst.sg:GoToState("attack")
        end
    end),
}

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("idle")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "emerge",
        tags = {"busy", "noattack", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("emerge")
        end,

        timeline=
        {
            --TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/rabbit/hop") end ),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "death",
        tags = {"busy", "noattack"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("melt")
            inst.persists = false
        end,

        events =
        {
            EventHandler("animover", function(inst) inst:Remove() end),
        },

        onexit = function(inst)
        end,
    },


    State{
        name = "attack",
        tags = { "busy", "attack"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("mutate")
			inst.components.locomotor:Stop()
			if inst.components.combat.target ~= nil then
				inst:ForceFacePoint(inst.components.combat.target.Transform:GetWorldPosition())
			end
	        inst.components.combat:StartAttack()
		end,

        timeline=
        {
            TimeEvent(30*FRAMES, function(inst)
					inst.components.combat:DoAttack()
                    inst.sg:RemoveStateTag("attack")
                    inst.sg:RemoveStateTag("busy")
				end ),

        },

        events =
        {
            EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end),
        },
    },

    State{
        name = "shoot",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            if not target then
                target = inst.components.combat.target
            end

            if target then
                inst.sg.statemem.target = target
            end

            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("attack")
        end,

        timeline =
        {
       --     TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.spit) end),
            TimeEvent(24*FRAMES, function(inst)
                if inst.sg.statemem.target and inst.sg.statemem.target:IsValid() then
                    inst.sg.statemem.spitpos = Vector3(inst.sg.statemem.target.Transform:GetWorldPosition())
                    inst:LaunchProjectile(inst.sg.statemem.spitpos)

                    inst.components.timer:StopTimer("spit_cooldown")
                    inst.components.timer:StartTimer("spit_cooldown", 3 + math.random()*3)
                end
            end),
        },

        events =
        {
            EventHandler("animover",function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },


}

local function SpawnTrail(inst)
	if not inst._notrail then
		local trail = SpawnPrefab("gestalt_trail")
		trail.Transform:SetPosition(inst.Transform:GetWorldPosition())
		trail.Transform:SetRotation(inst.Transform:GetRotation())
	end
end

CommonStates.AddWalkStates(states,
{
    starttimeline =
    {
    },
    walktimeline =
    {
        TimeEvent(0*FRAMES, SpawnTrail),
        --TimeEvent(5*FRAMES, SpawnTrail),
    },
    endtimeline =
    {
    },
}
, nil, nil, true)


return StateGraph("gestalt", states, events, "idle", actionhandlers)
