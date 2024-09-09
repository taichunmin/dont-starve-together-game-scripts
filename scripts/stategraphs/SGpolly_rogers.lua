require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.GIVE, "give"),
    ActionHandler(ACTIONS.GIVEALLTOPLAYER, "give"),
    ActionHandler(ACTIONS.DROP, "give"),
    ActionHandler(ACTIONS.PICKUP, "take"),
    ActionHandler(ACTIONS.CHECKTRAP, "take"),
}

local events=
{
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    EventHandler("attacked", function(inst) if not inst.components.health:IsDead() then inst.sg:GoToState("hit") end end),
    EventHandler("death", function(inst, data)
				inst.sg:GoToState("death", data)
			end),
    EventHandler("flyaway", function(inst, data)
                if not inst.components.health:IsDead() then
                    inst.sg:GoToState("flyaway")
                end
            end),    
    EventHandler("locomote", function(inst)
                if not inst.sg:HasStateTag("busy") then
                    local is_moving = inst.sg:HasStateTag("moving")
                    local is_running = inst.sg:HasStateTag("running")
                    local is_idling = inst.sg:HasStateTag("idle")
                    local should_move = inst.components.locomotor:WantsToMoveForward() 
                    local should_run = inst.components.locomotor:WantsToRun()
                           
                    if is_moving and not should_move then
                        inst.sg:GoToState("walk_stop", inst.sg:HasStateTag("ground"))
                    elseif not is_moving and should_move then
                        inst.sg:GoToState("walk_start", inst.sg:HasStateTag("ground"))
                    end
                end
            end),
}

local states=
{

    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle", true)
            if not inst.SoundEmitter:PlayingSound("fly_lp") then
                inst.SoundEmitter:PlaySound("monkeyisland/pollyroger/flap_lp", "fly_lp")
            end

            --inst.sg:SetTimeout(1 + math.random())
        end,

        --[[ontimeout = function(inst)
            local x,y,z = inst.Transform:GetWorldPosition()
            if TheWorld.Map:IsVisualGroundAtPoint(x,y,z) or TheWorld.Map:GetPlatformAtPoint(x,z) then
                --inst.SoundEmitter:KillSound("fly_lp")
            else
                inst.sg:GoToState("idle")
            end
        end,]]
    },

    State{
        name = "take",
        tags = {"busy"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("take")
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        events=
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle") 
                end
            end),
        },
    },

    State{
        name = "give",
        tags = {"busy"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("give")
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        events=
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "idle_ground",
        tags = {"idle", "canrotate", "ground"},
        onenter = function(inst, pushanim)
            inst:RemoveTag("flying")
            if pushanim then
                if type(pushanim) == "string" then
                    inst.AnimState:PlayAnimation(pushanim)
                end
                inst.AnimState:PushAnimation("idle_ground", true)
            elseif not inst.AnimState:IsCurrentAnimation("idle_ground") then
                inst.AnimState:PlayAnimation("idle_ground", true)
            end
            inst.sg:SetTimeout(1 + math.random())
        end,

        ontimeout = function(inst)
            inst.sg.statemem.stayonground = true
            local r = math.random()
            inst.sg:GoToState(
                (r < .5 and "idle_ground") or
                (r < .6 and "switch") or
                (r < .7 and "peck") or
                (r < .8 and "hop") or
                "caw"
            )
        end,

        onexit = function(inst)
            if not inst.sg.statemem.stayonground then
                inst:AddTag("flying")
            end
        end,
    },

    State{
        name = "peck",
        tags = {"idle", "canrotate", "ground"},
        onenter = function(inst)
            inst:RemoveTag("flying")
            inst.AnimState:PlayAnimation("peck")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.stayonground = true
                    inst.sg:GoToState("idle_ground")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.stayonground then
                inst:AddTag("flying")
            end
        end,
    },

    State{
        name = "switch",
        tags = {"idle", "canrotate", "ground"},
        onenter = function(inst)
            inst:RemoveTag("flying")
            inst.Transform:SetRotation(inst.Transform:GetRotation() + 180)
            inst.AnimState:PlayAnimation("switch")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.stayonground = true
                    inst.sg:GoToState("idle_ground")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.stayonground then
                inst:AddTag("flying")
            end
        end,
    },

    State{
        name = "hop",
        tags = { "idle", "canrotate", "hopping", "ground" },

        onenter = function(inst)
            inst:RemoveTag("flying")
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
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.stayonground = true
                    inst.sg:GoToState("idle_ground")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.stayonground then
                inst:AddTag("flying")
            end
        end,
    },

    State{
        name = "caw",
        tags = { "idle", "ground" },

        onenter = function(inst)
            inst:RemoveTag("flying")
            if not inst.AnimState:IsCurrentAnimation("caw") then
                inst.AnimState:PlayAnimation("caw", true)
            end
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
            inst.SoundEmitter:PlaySound("monkeyisland/pollyroger/caw")
        end,

        ontimeout = function(inst)
            inst.sg.statemem.stayonground = true
            inst.sg:GoToState(math.random() < .5 and "caw" or "idle_ground")
        end,

        onexit = function(inst)
            if not inst.sg.statemem.stayonground then
                inst:AddTag("flying")
            end
        end,
    },

    State{
        name = "hit",
        tags = { "busy", "ground" },

        onenter = function(inst)
            inst:RemoveTag("flying")
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("monkeyisland/pollyroger/hit")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if not inst.AnimState:AnimDone() then
                    inst.sg.statemem.stayonground = true
                    inst.sg:GoToState("idle_ground")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.stayonground then
                inst:AddTag("flying")
            end
        end,
    },

    State{
        name = "death",
        tags = { "busy", "ground" },
        onenter = function(inst)
            inst:RemoveTag("flying")
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("death")
            inst.SoundEmitter:PlaySound("monkeyisland/pollyroger/death")
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(inst:GetPosition())
        end,
        onexit = function(inst)
            inst:AddTag("flying")
        end,
    },

    State{
        name = "flyaway",
        tags = { "flight", "busy", "notarget" , "flyaway" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.readytogather = nil
            inst:AddTag("NOCLICK")
            if inst.components.floater ~= nil then
                inst:PushEvent("on_no_longer_landed")
            end

            inst.DynamicShadow:Enable(false)
            inst.SoundEmitter:PlaySound("monkeyisland/pollyroger/takeoff")

            if math.random() < 0.5 then
                inst.sg.statemem.vert = true
                inst.AnimState:PlayAnimation("takeoff_vertical_pre")
                inst.AnimState:PushAnimation("takeoff_vertical_loop", true)
            else
                inst.AnimState:PlayAnimation("takeoff_diagonal_pre")
                inst.AnimState:PushAnimation("takeoff_diagonal_loop", true)
            end
            inst.SoundEmitter:KillSound("fly_lp")

            if inst.components.inventory ~= nil then
                inst.components.inventory:DropEverything()
            end

            inst.sg:SetTimeout(.1 + math.random() * .2)
        end,

        ontimeout = function(inst)
            if inst.sg.statemem.vert then
                inst.Physics:SetMotorVel(math.random() * 4 - 2, math.random() * 5 + 15, math.random() * 4 - 2)
            else
                inst.Physics:SetMotorVel(math.random() * 8 + 8, math.random() * 5 + 15, math.random() * 4 - 2)
            end
        end,

        timeline =
        {
            TimeEvent(2, function(inst)
                if inst.flyaway then
                    if inst.hat then
                        inst.hat.components.spawner:GoHome(inst)
                        inst.SoundEmitter:KillSound("fly_lp")
                    else
                        inst:Remove()
                    end
                else
                    inst.sg:GoToState("glide")
                end
            end),
        },

        onexit = function(inst)
            inst.readytogather = true
            inst:RemoveTag("NOCLICK")
        end,
    },

    State{
        name = "glide",
        tags = { "idle", "flight", "notarget", "busy" },

        onenter = function(inst)
            inst.readytogather = nil
            inst:AddTag("NOCLICK")
            if not inst.AnimState:IsCurrentAnimation("glide") then
                inst.AnimState:PlayAnimation("glide", true)
            end
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())

            inst.Physics:SetMotorVel(0, math.random() * 10 - 20, 0)
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
            if y <= 0.5 then
                inst.Physics:Stop()
                inst.Physics:Teleport(x, 0, z)
                inst.AnimState:PlayAnimation("land")
                inst.DynamicShadow:Enable(true)
                if inst.components.floater ~= nil then
                    inst:PushEvent("on_landed")
                end
                inst.sg:GoToState("idle_ground", true)
            end
        end,

        onexit = function(inst)
            inst:RemoveTag("NOCLICK")
            inst.readytogather = true
        end,
    },

    State{
        name = "walk_start",
        tags = { "moving", "canrotate" },

        onenter = function(inst, fromground)
            if fromground then
                inst.AnimState:PlayAnimation("takeoff_walk")
            else
                inst.AnimState:PlayAnimation("walk_pre")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("walk")
                end
            end),
        },
    },

    State{
        name = "walk",
        tags = { "moving", "canrotate" },

        onenter = function(inst)
            if not inst.AnimState:IsCurrentAnimation("walk_loop") then
                inst.AnimState:PlayAnimation("walk_loop", true)
            end
            if not inst.SoundEmitter:PlayingSound("fly_lp") then
                inst.SoundEmitter:PlaySound("monkeyisland/pollyroger/flap_lp", "fly_lp")
            end
            if inst.components.locomotor:WantsToRun() then
                inst.components.locomotor:RunForward()
            else
                inst.components.locomotor:WalkForward()
            end
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("walk")
        end,
    },

    State{
        name = "walk_stop",
        tags = { "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("walk_pst")
            --inst.SoundEmitter:KillSound("fly_lp")
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
}
CommonStates.AddSleepStates(states)
CommonStates.AddFrozenStates(states)

return StateGraph("polly_rogers", states, events, "glide", actionhandlers)

