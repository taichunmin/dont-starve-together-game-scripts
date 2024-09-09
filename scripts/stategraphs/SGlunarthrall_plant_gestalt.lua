require("stategraphs/commonstates")

--------------------------------------------------------------------------------------------------------------

local function GoToIdle(inst)
    inst.sg:GoToState("idle")
end

local function Remove(inst)
    inst:Remove()
end

local SimpleAnimoverHandler = {
    EventHandler("animover", GoToIdle),
}

local RemoveOnAnimoverHandler = {
    EventHandler("animover", Remove),
}

--------------------------------------------------------------------------------------------------------------

local actionhandlers = {}

local events =
{
    CommonHandlers.OnLocomote(false, true),
}

--------------------------------------------------------------------------------------------------------------

local states =
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("idle")
        end,

        events = SimpleAnimoverHandler,
    },

    State{
        name = "spawn",
        tags = {"busy", "noattack"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("spawn")
            inst.Physics:SetMotorVelOverride(4, 0, 0)
            inst.SoundEmitter:PlaySound("rifts/lunarthrall/gestalt_vocalization")
        end,

        onexit = function(inst)
            inst.Physics:ClearMotorVelOverride()
            inst.Physics:Stop()
        end,

        events = SimpleAnimoverHandler,
    },

    State{
        name = "infest",
        tags = {"busy", "noattack"},

        onenter = function(inst)
            inst.AnimState:SetFinalOffset(3)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("infest")
            inst.SoundEmitter:PlaySound("rifts/lunarthrall/gestalt_infest")

            inst.sg.statemem.corpse = inst.components.entitytracker ~= nil and inst.components.entitytracker:GetEntity("corpse") or nil
			if inst.sg.statemem.corpse == nil then
				inst.persists = false
			end
        end,

        timeline =
        {
			FrameEvent(25, function(inst)
				inst.persists = false

                -- lunarthrall_plant_gestalt handler.
                if inst.plant_target and inst.plant_target:IsValid() then
                    TheWorld.components.lunarthrall_plantspawner:SpawnPlant(inst.plant_target)

                -- corpse_gestalt handler.
                elseif inst.sg.statemem.corpse ~= nil and inst.sg.statemem.corpse:IsValid() then
                    inst.sg.statemem.corpse:StartMutation()
                end
            end ),
            FrameEvent(30, function(inst)
                if inst.sg.statemem.corpse ~= nil and inst.sg.statemem.corpse:IsValid() then
                    inst:Remove()
                end
            end ),
        },

		events = RemoveOnAnimoverHandler,
    },

	State{
		name = "infest_corpse",
		tags = { "busy", "noattack" },

		onenter = function(inst)
			inst.AnimState:SetFinalOffset(3)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("infest_corpse")
			inst.SoundEmitter:PlaySound("rifts/lunarthrall/gestalt_infest")

			inst.sg.statemem.corpse = inst.components.entitytracker ~= nil and inst.components.entitytracker:GetEntity("corpse") or nil
			if inst.sg.statemem.corpse == nil then
				inst.persists = false
			end
		end,

		timeline =
		{
			FrameEvent(19, function(inst)
				inst.persists = false

				-- lunarthrall_plant_gestalt handler.
				if inst.plant_target and inst.plant_target:IsValid() then
					TheWorld.components.lunarthrall_plantspawner:SpawnPlant(inst.plant_target)

				-- corpse_gestalt handler.
				elseif inst.sg.statemem.corpse ~= nil and inst.sg.statemem.corpse:IsValid() then
                    inst.sg.statemem.corpse:StartMutation()

                    if TheWorld.components.lunarthrall_plantspawner ~= nil then
                        TheWorld.components.lunarthrall_plantspawner:RemoveWave()
                    end
				end
			end),
		},

		events = RemoveOnAnimoverHandler,
	},
}

--------------------------------------------------------------------------------------------------------------

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
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("rifts/lunarthrall/gestalt_vocalization") end),
        },
        walktimeline =
        {
            TimeEvent(0*FRAMES, SpawnTrail),
        },
    },
    nil,
    nil,
    true
)

--------------------------------------------------------------------------------------------------------------

return StateGraph("lunarthrall_plant_gestalt", states, events, "idle", actionhandlers)
