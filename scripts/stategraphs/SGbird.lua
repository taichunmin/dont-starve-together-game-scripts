require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.EAT, "peck"),
    ActionHandler(ACTIONS.GOHOME, "flyaway"),
}

local events =
{
    EventHandler("gotosleep", function(inst)
        if not inst.components.health:IsDead() then
            local x, y, z = inst.Transform:GetWorldPosition()
            inst.sg:GoToState(
                (y > 1 and "fall") or --special bird behaviour
                (inst.sg:HasStateTag("sleeping") and "sleeping") or
                "sleep"
            )
        end
    end),
    CommonHandlers.OnFreeze(),
    EventHandler("attacked", function(inst)
        if not inst.components.health:IsDead() then
            inst.sg:GoToState("hit")
        end
    end),
    EventHandler("death", function(inst)
        inst.sg:GoToState("death")
    end),
    EventHandler("flyaway", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("flyaway")
        end
    end),
    EventHandler("onignite", function(inst)
        if not inst.components.health:IsDead() then
            inst.sg:GoToState("distress_pre")
        end
    end),
    EventHandler("trapped", function(inst)
        inst.sg:GoToState("trapped")
    end),
    EventHandler("stunbomb", function(inst)
        inst.sg:GoToState("stunned")
    end),
}

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, pushanim)
            inst.Physics:Stop()
            if pushanim then
                if type(pushanim) == "string" then
                    inst.AnimState:PlayAnimation(pushanim)
                end
                inst.AnimState:PushAnimation("idle", true)
            elseif not inst.AnimState:IsCurrentAnimation("idle") then
                inst.AnimState:PlayAnimation("idle", true)
            end
            inst.sg:SetTimeout(1 + math.random())
        end,

        ontimeout = function(inst)
            if inst.bufferedaction ~= nil and inst.bufferedaction.action == ACTIONS.EAT then
                inst.sg:GoToState("peck")
            else
                local r = math.random()
                inst.sg:GoToState(
                    (r < .5 and "idle") or
                    (r < .6 and "switch") or
                    (r < .7 and "peck") or
                    (r < .8 and "hop") or
                    (r < .9 and "flyaway") or
                    "caw"
                )
            end
        end,
    },

    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(inst:GetPosition())
        end,
    },

    State{
        name = "caw",
        tags = { "idle" },

        onenter = function(inst)
            if not inst.AnimState:IsCurrentAnimation("caw") then
                inst.AnimState:PlayAnimation("caw", true)
            end
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
            inst.SoundEmitter:PlaySound(inst.sounds.chirp)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState(math.random() < .5 and "caw" or "idle")
        end,
    },

    State{
        name = "distress_pre",
        tags = { "busy" },
        onenter = function(inst)
            inst.AnimState:PlayAnimation("flap_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("distress")
            end),
        },
    },

    State{
        name = "distress",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("flap_loop")
            inst.SoundEmitter:PlaySound("dontstarve/birds/wingflap_cage")
            inst.SoundEmitter:PlaySound(inst.sounds.chirp)
        end,

        events =
        {
            EventHandler("onextinguish", function(inst)
                if not inst.components.health:IsDead() then
                    inst.sg:GoToState("idle", "flap_post")
                end
            end),
            EventHandler("animover", function(inst)
                inst.sg:GoToState("distress")
            end),
        },
    },

    State{
        name = "delay_glide",
        tags = { "busy", "notarget" },

        onenter = function(inst, delay)
            inst:AddTag("NOCLICK")
            inst:Hide()
            inst.Physics:SetActive(false)
            inst.sg:SetTimeout(delay)
        end,

        ontimeout = function(inst)
            inst.sg.statemem.gliding = true
            inst.sg:GoToState("glide")
        end,

        onexit = function(inst)
            if not inst.sg.statemem.gliding then
                inst:RemoveTag("NOCLICK")
            end
            inst:Show()
            inst.Physics:SetActive(true)
        end,
    },

    State{
        name = "glide",
        tags = { "idle", "flight", "notarget" },

        onenter = function(inst)
			inst:AddTag("NOCLICK")
            if not inst.AnimState:IsCurrentAnimation("glide") then
                inst.AnimState:PlayAnimation("glide", true)
            end
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())

            inst.Physics:SetMotorVel(0, math.random() * 10 - 20, 0)
			inst.DynamicShadow:Enable(false)
        end,

        timeline =
        {
            TimeEvent(1 * FRAMES, function(inst)
                if inst.components.inventoryitem == nil or not inst.components.inventoryitem:IsHeld() then
                    inst.SoundEmitter:PlaySound(inst.sounds.flyin)
                end
            end),
        },

        onupdate = function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            if y < 2 then
                inst.Physics:SetMotorVel(0, 0, 0)
            end
            if y <= 0.1 then
                inst.Physics:Stop()
                inst.Physics:Teleport(x, 0, z)
                inst.AnimState:PlayAnimation("land")
                inst.DynamicShadow:Enable(true)
                if inst.components.floater ~= nil then
                    inst:PushEvent("on_landed")
                end
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("glide")
        end,

		onexit = function(inst)
			inst:RemoveTag("NOCLICK")
			inst.DynamicShadow:Enable(true)
		end,
    },

    State{
        name = "switch",
        tags = { "idle" },

        onenter = function(inst)
            inst.Transform:SetRotation(inst.Transform:GetRotation() + 180)
            inst.AnimState:PlayAnimation("switch")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "peck",

        onenter = function(inst)
            inst.Physics:Stop()
            if not inst.AnimState:IsCurrentAnimation("peck") then
                inst.AnimState:PlayAnimation("peck", true)
            end
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        ontimeout = function(inst)
            if math.random() < .3 then
                inst:PerformBufferedAction()
                inst.sg:GoToState("idle")
            else
                inst.sg:GoToState("peck")
            end
        end,
    },

    State{
        name = "flyaway",
        tags = { "flight", "busy", "notarget" },

        onenter = function(inst)
			inst:AddTag("NOCLICK")

            if inst.components.floater ~= nil then
                inst:PushEvent("on_no_longer_landed")
            end
            inst.Physics:Stop()
            inst.sg:SetTimeout(.1 + math.random() * .2)
            inst.sg.statemem.vert = math.random() < .5

            inst.SoundEmitter:PlaySound(inst.sounds.takeoff)

            if inst.components.periodicspawner ~= nil and math.random() <= TUNING.BIRD_LEAVINGS_CHANCE then
                inst.components.periodicspawner:TrySpawn()
            end

            inst.AnimState:PlayAnimation(inst.sg.statemem.vert and "takeoff_vertical_pre" or "takeoff_diagonal_pre")
        end,

        ontimeout = function(inst)
            if inst.sg.statemem.vert then
                inst.AnimState:PushAnimation("takeoff_vertical_loop", true)
                inst.Physics:SetMotorVel(math.random() * 4 - 2, math.random() * 5 + 15, math.random() * 4 - 2)
            else
                inst.AnimState:PushAnimation("takeoff_diagonal_loop", true)
                inst.Physics:SetMotorVel(math.random() * 8 + 8, math.random() * 5 + 15,math.random() * 4 - 2)
            end
			inst.DynamicShadow:Enable(false)
        end,

        timeline =
        {
			FrameEvent(5, function(inst)
				inst.DynamicShadow:SetSize(.6, .5)
			end),
            TimeEvent(2, function(inst)
                inst:Remove()
            end),
        },

		onexit = function(inst)
			inst:RemoveTag("NOCLICK")
			inst.DynamicShadow:SetSize(1, .75)
			inst.DynamicShadow:Enable(true)
		end,
    },

    State{
        name = "hop",
        tags = { "moving", "canrotate", "hopping" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("hop")
            inst.Physics:SetMotorVel(5, 0, 0)
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                inst.Physics:Stop()
                if inst.components.floater ~= nil then
                    inst:PushEvent("on_landed")
                elseif inst.components.inventoryitem ~= nil then
                    inst.components.inventoryitem:TryToSink()
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "hit",
        tags = { "busy" },

        onenter = function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            if y > 1 then
                inst.sg:GoToState("fall")
                return
            end
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState(inst.components.burnable ~= nil and inst.components.burnable:IsBurning() and "distress_pre" or "flyaway")
            end),
        },
    },

    State{
        name = "fall",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("fall_loop", true)
			inst.DynamicShadow:Enable(false)
        end,

        onupdate = function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            if y <= .2 then
                inst.Physics:Stop()
                inst.Physics:Teleport(x, 0, z)
                inst.DynamicShadow:Enable(true)
                inst.sg:GoToState("stunned")
                if inst.components.floater ~= nil then
                    inst:PushEvent("on_landed")
                end
            end
        end,

		onexit = function(inst)
			inst.DynamicShadow:Enable(true)
		end,
    },

    State{
        name = "trapped",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("stunned_loop", true)
            inst.sg:SetTimeout(1)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("flyaway")
        end,
    },

    State{
        name = "stunned",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("stunned_loop", true)
            inst.sg:SetTimeout(GetRandomWithVariance(6, 2))
            if inst.components.inventoryitem ~= nil then
                inst.components.inventoryitem.canbepickedup = true
            end
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("flyaway")
        end,

        onexit = function(inst)
            if inst.components.inventoryitem ~= nil then
                inst.components.inventoryitem.canbepickedup = false
            end
        end,
    },
}

CommonStates.AddSleepStates(states)
CommonStates.AddFrozenStates(states)

return StateGraph("bird", states, events, "glide")
