local function DoTalkSound(inst)
    if inst.talksoundoverride ~= nil then
        inst.SoundEmitter:PlaySound(inst.talksoundoverride, "talk")
        return true
    elseif not inst:HasTag("mime") then
        inst.SoundEmitter:PlaySound((inst.talker_path_override or "dontstarve/characters/")..(inst.soundsname or inst.prefab).."/ghost_LP", "talk")
        return true
    end
end

local function StopTalkSound(inst, instant)
    if not instant and inst.endghosttalksound ~= nil and inst.SoundEmitter:PlayingSound("talk") then
        inst.SoundEmitter:PlaySound(inst.endghosttalksound)
    end
    inst.SoundEmitter:KillSound("talk")
end

local actionhandlers =
{
    ActionHandler(ACTIONS.HAUNT, "haunt_pre"),
    ActionHandler(ACTIONS.JUMPIN, "jumpin_pre"),
    ActionHandler(ACTIONS.ATTACK,
        function()
            --dummy handler in case any attack controls came through network
            print("Player ghost ignored attack control")
        end),
    ActionHandler(ACTIONS.REMOTERESURRECT, "remoteresurrect"),
    ActionHandler(ACTIONS.MIGRATE, "migrate"),
}

local events =
{
    EventHandler("locomote", function(inst, data)
        if inst.sg:HasStateTag("busy") then
            return
        end
        local is_moving = inst.sg:HasStateTag("moving")
        local should_move = inst.components.locomotor:WantsToMoveForward()

        if is_moving and not should_move then
            inst.sg:GoToState("idle")
        elseif not is_moving and should_move then
            inst.sg:GoToState("run")
        elseif data.force_idle_state and not (is_moving or should_move or inst.sg:HasStateTag("idle")) then
            inst.sg:GoToState("idle")
        end
    end),

    EventHandler("attacked", function(inst)
        if not inst.components.health:IsDead() then
            inst.sg:GoToState("hit")
        end
    end),

    --[[EventHandler("death", function(inst)
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:Enable(false)
        end
        inst.sg:GoToState("dissipate")
    end),]]

    EventHandler("ontalk", function(inst, data)
        if inst.sg:HasStateTag("idle") then
            if inst:HasTag("mime") then
                inst.sg:GoToState("mime")
            else
                inst.sg:GoToState("talk", data.noanim)
            end
        end
    end),
}

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()

            if not inst.AnimState:IsCurrentAnimation("idle") then
                inst.AnimState:PlayAnimation("idle", true)
            end
        end,
    },

    State{
        name = "run",
        tags = { "moving", "running", "canrotate", "autopredict" },

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
        name = "appear",
        tags = { "nopredict" },

        onenter = function(inst)
            if inst.loading_ghost then
                inst.sg:GoToState("idle")
                return
            end

            inst.AnimState:PlayAnimation("appear")
            if not inst:HasTag("mime") then
                inst.SoundEmitter:PlaySound(
                    inst:HasTag("girl") and
                    "dontstarve/ghost/ghost_girl_howl" or
                    "dontstarve/ghost/ghost_howl"
                )
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "remoteresurrect",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("dissipate")
            inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_haunt", nil, nil, true)
            inst:ScreenFade(false, 2)
            inst.sg.statemem.faded = true
            inst.sg:SetTimeout(2)
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst)
                inst.Light:Enable(false)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:Hide()
                    inst.Light:Enable(false)
                end
            end),
        },

        ontimeout = function(inst)
            if inst:PerformBufferedAction() then
                inst.sg.statemem.isresurrecting = true
            else
                inst.sg:GoToState("haunt")
            end
        end,

        onexit = function(inst)
            --Cancelled
            if inst.sg.statemem.faded then
                inst:ScreenFade(true, .5)
            end
            inst:Show()
            inst.Light:Enable(true)
        end,
    },

    State{
        name = "haunt_pre",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("dissipate")
            inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_haunt", nil, nil, true)
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end)
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("haunt")
                end
            end),
        },
    },

    State{
        name = "haunt",
        tags = { "doing", "busy", "nopredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("appear")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() and inst.entity:IsVisible() then --hidden if resurrecting
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "hit",
        tags = { "busy", "pausepredict" },

        onenter = function(inst)
            if inst.hurtsoundoverride ~= nil then
                inst.SoundEmitter:PlaySound(hurtsoundoverride)
            elseif not inst:HasTag("mime") then
                inst.SoundEmitter:PlaySound(
                    inst:HasTag("girl") and
                    "dontstarve/ghost/ghost_girl_howl" or
                    "dontstarve/ghost/ghost_howl"
                )
            end

            inst.AnimState:PlayAnimation("hit")
            inst:ClearBufferedAction()
            inst.components.locomotor:Stop()

            if inst.components.playercontroller ~= nil then
                --Specify 3 frames of pause since "busy" tag may be
                --removed too fast for our network update interval.
                inst.components.playercontroller:RemotePausePrediction(3)
            end
        end,

        timeline =
        {
            TimeEvent(3 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("pausepredict")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "dissipate",
        tags = { "busy", "pausepredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()
            inst:ClearBufferedAction()

            inst.Light:Enable(false)
            inst.AnimState:PlayAnimation("dissipate")
            if not inst:HasTag("mime") then
                inst.SoundEmitter:PlaySound(
                    inst:HasTag("girl") and
                    "dontstarve/ghost/ghost_girl_howl" or
                    "dontstarve/ghost/ghost_howl"
                )
            end

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:PushEvent("ghostdissipated")
                end
            end),
        },
    },

    State{
        name = "start_rewindtime_revive",
        tags = { "busy", "pausepredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()
            inst:ClearBufferedAction()

            inst.Light:Enable(false)
            inst.AnimState:PlayAnimation("dissipate")
            if not inst:HasTag("mime") then
                inst.SoundEmitter:PlaySound(
                    inst:HasTag("girl") and
                    "dontstarve/ghost/ghost_girl_howl" or
                    "dontstarve/ghost/ghost_howl"
                )
            end

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end

            inst:ScreenFade(false, 2)
            inst.sg.statemem.faded = true
        end,

		onexit = function(inst)
            if inst.sg.statemem.faded then -- this is cleared in DoMoveToRezPosition
				inst:ScreenFade(true, .5)
			end
		end,
    },

    State{
        name = "talk",
        tags = { "idle", "talking" },

        onenter = function(inst, noanim)
            if not (noanim or inst.AnimState:IsCurrentAnimation("idle")) then
                inst.AnimState:PlayAnimation("idle", true)
            end
            DoTalkSound(inst)
            inst.sg:SetTimeout(1.5 + math.random() * .5)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,

        events =
        {
            EventHandler("donetalking", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = StopTalkSound,
    },

    State{
        name = "mime",
        tags = { "idle", "talking" },

        onenter = function(inst)
            if not inst.AnimState:IsCurrentAnimation("idle") then
                inst.AnimState:PlayAnimation("idle", true)
            end
            DoTalkSound(inst)
            inst.sg:SetTimeout(1.5 + math.random() * .5)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,

        events =
        {
            EventHandler("donetalking", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = StopTalkSound,
    },

    State{
        name = "jumpin_pre",
        tags = { "doing", "busy", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("dissipate", false)
            inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_haunt", nil, nil, true)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.bufferedaction ~= nil then
                        inst:PerformBufferedAction()
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },
    },

    State{
        name = "jumpin",
        tags = { "doing", "busy", "canrotate" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            --inst.AnimState:PlayAnimation("dissipate")

            inst.sg.statemem.target = data.teleporter
            inst.sg.statemem.teleportarrivestate = "jumpout"

            inst.sg.statemem.target:PushEvent("starttravelsound", inst)
            if inst.sg.statemem.target ~= nil and inst.sg.statemem.target.components.teleporter ~= nil
                and inst.sg.statemem.target.components.teleporter:Activate(inst) then
                inst.sg.statemem.isteleporting = true
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:Enable(false)
                end
                inst:Hide()
            else
                inst.sg:GoToState("jumpout")
            end
        end,

        onexit = function(inst)
            if inst.sg.statemem.isteleporting then
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:Enable(true)
                end
                inst:Show()
            end
        end,
    },

    State{
        name = "jumpout",
        tags = { "doing", "busy", "canrotate", "nopredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("appear")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "pocketwatch_portal_land",
        tags = { "doing", "busy", "canrotate", "nopredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("appear")

			local x, y, z = inst.Transform:GetWorldPosition()
			local fx = SpawnPrefab("pocketwatch_portal_exit_fx")
			fx.Transform:SetPosition(x, 4, z)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "forcetele",
        tags = { "busy", "nopredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.Light:Enable(false)
            inst:Hide()
            inst:ScreenFade(false, 2)

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
            end
        end,

        onexit = function(inst)
            inst.Light:Enable(true)
            inst:Show()

            if inst.sg.statemem.teleport_task ~= nil then
                -- Still have a running teleport_task
                -- Interrupt!
                inst.sg.statemem.teleport_task:Cancel()
                inst.sg.statemem.teleport_task = nil
                inst:ScreenFade(true, .5)
            end

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
        end,
    },

    State{
        name = "migrate",
        tags = { "doing", "busy", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("dissipate")
            inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_haunt", nil, nil, true)

            inst.sg.statemem.action = inst.bufferedaction
        end,

        timeline =
        {
            -- this is just hacked in here to make the sound play BEFORE the player hits the wormhole
            TimeEvent(3 * FRAMES, function(inst)
                if inst.bufferedaction ~= nil and inst.bufferedaction.target ~= nil then
                    inst.bufferedaction.target:PushEvent("starttravelsound", inst)
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() and
                    not inst:PerformBufferedAction() then
                    inst.sg:GoToState("jumpout")
                end
            end),
        },

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action then
                inst:ClearBufferedAction()
            end
        end,
    },
}

return StateGraph("wilsonghost", states, events, "appear", actionhandlers)
