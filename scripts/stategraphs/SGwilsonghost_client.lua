local TIMEOUT = 2

--#V2C #client_prediction
--Clear locally, and on server force dirty when setting new state, even if it was
--same as previous state. Avoid false positives when repeating same action state.
--See playercontroller -> OnNewState
local function ClearCachedServerState(inst)
	if inst.player_classified ~= nil then
		inst.player_classified.currentstate:set_local(0)
	end
end

local actionhandlers =
{
    ActionHandler(ACTIONS.HAUNT, "haunt_pre"),
	ActionHandler(ACTIONS.JUMPIN, "jumpin_pre"),
    ActionHandler(ACTIONS.JUMPIN_MAP, "jumpin_pre"),
    ActionHandler(ACTIONS.REMOTERESURRECT, "remoteresurrect"),
    ActionHandler(ACTIONS.MIGRATE, "migrate"),
}

local events =
{
	EventHandler("sg_cancelmovementprediction", function(inst)
		inst.sg:GoToState("idle", "cancel")
	end),
	EventHandler("locomote", function(inst, data)
        if inst.sg:HasStateTag("busy") or inst:HasTag("busy") then
            return
        end
        local is_moving = inst.sg:HasStateTag("moving")
        local should_move = inst.components.locomotor:WantsToMoveForward()

        if not inst.entity:CanPredictMovement() then
            if not inst.sg:HasStateTag("idle") then
                inst.sg:GoToState("idle")
            end
        elseif is_moving and not should_move then
            inst.sg:GoToState("idle")
        elseif not is_moving and should_move then
			--V2C: Added "dir" param so we don't have to add "canrotate" to all interruptible states
			if data and data.dir then
				inst.Transform:SetRotation(data.dir)
			end
            inst.sg:GoToState("run")
        end
    end),
}

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, pushanim)
            inst.entity:SetIsPredictingMovement(false)

			if pushanim == "cancel" or inst:HasTag("nopredict") or inst:HasTag("pausepredict") then
				--prediction interrupted by server state
				inst.components.locomotor:Stop()
				inst.components.locomotor:Clear()
                inst:ClearBufferedAction()
                return
            elseif pushanim == "noanim" then
				--server confirmed our preview action
				inst.components.locomotor:Stop()
				inst.components.locomotor:Clear()
				ClearCachedServerState(inst)
				--use timeout for clearing preview bufferedaction
                inst.sg:SetTimeout(TIMEOUT)
                return
            end

			--predicted idle state
			if inst.sg.lasttags and not inst.sg.lasttags["busy"] then
				inst.components.locomotor:StopMoving()
			else
				inst.components.locomotor:Stop()
				inst.components.locomotor:Clear()
			end
			inst:ClearBufferedAction()

            if pushanim then
                inst.AnimState:PushAnimation("idle")
            elseif not inst.AnimState:IsCurrentAnimation("idle") then
                inst.AnimState:PlayAnimation("idle", true)
            end
        end,

        ontimeout = function(inst)
            if inst.bufferedaction ~= nil and inst.bufferedaction.ispreviewing then
                inst:ClearBufferedAction()
            end
        end,

        onexit = function(inst)
            inst.entity:SetIsPredictingMovement(true)
        end,
    },

    State{
        name = "run",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            if not inst.AnimState:IsCurrentAnimation("idle") then
                inst.AnimState:PlayAnimation("idle", true)
            end
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,
    },

    State{
        name = "remoteresurrect",
        tags = { "doing", "busy" },
		server_states = { "remoteresurrect" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("dissipate")
            inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_haunt", nil, nil, true)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("appear")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("appear")
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "haunt_pre",
        tags = { "doing", "busy" },
		server_states = { "haunt_pre" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("dissipate")
            inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_haunt", nil, nil, true)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("appear")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("appear")
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "jumpin_pre",
        tags = { "doing", "busy", "canrotate" },
		server_states = { "jumpin_pre", "jumpin" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("dissipate")
            inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_haunt", nil, nil, true)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("appear")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("appear")
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "migrate",
        tags = { "doing", "busy", "canrotate" },
		server_states = { "migrate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("dissipate")
            inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_haunt", nil, nil, true)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("appear")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("appear")
            inst.sg:GoToState("idle", true)
        end,
    },
}

return StateGraph("wilsonghost_client", states, events, "idle", actionhandlers)
