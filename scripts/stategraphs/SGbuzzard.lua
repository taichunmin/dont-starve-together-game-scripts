require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.EAT, "eat"),
    ActionHandler(ACTIONS.GOHOME, function(inst)
        if inst.components.health and not inst.components.health:IsDead() then
            inst.sg:GoToState("flyaway")
        end
    end),
}

local events=
{
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),

    EventHandler("flyaway", function(inst)
        if not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("flyaway")
        end
    end),

    EventHandler("onignite", function(inst) if not inst.components.health:IsDead() then inst.sg:GoToState("distress_pre") end end),

    EventHandler("locomote",
    function(inst)
        if (not inst.sg:HasStateTag("idle") and not inst.sg:HasStateTag("moving")) then return end

        if not inst.components.locomotor:WantsToMoveForward() or inst.components.combat.target then
            if not inst.sg:HasStateTag("idle") then
                inst.sg:GoToState("idle")
            end
        else
            if not inst.sg:HasStateTag("hopping") then
                inst.sg:GoToState("hop")
            end
        end
    end),
}

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, pushanim)
            inst.Physics:Stop()
            if pushanim then
                if type(pushanim) == "string" then
                    inst.AnimState:PlayAnimation(pushanim)
                end
                inst.AnimState:PushAnimation("idle", true)
            else
                inst.AnimState:PlayAnimation("idle", true)
            end
            inst.sg:SetTimeout(3 + math.random()*1)
        end,

        ontimeout= function(inst)
			if inst.bufferedaction and inst.bufferedaction.action == ACTIONS.EAT then
				inst.sg:GoToState("eat")
			else
				local r = math.random()
				if r < .75 then
					inst.sg:GoToState("idle")
				else
                    if inst.components.combat.target then
                        inst.sg:GoToState("taunt")
                    else
					   inst.sg:GoToState("caw")
                    end
				end
			end
        end,
    },

    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/buzzard/death")
        end,
    },

    State{
        name = "taunt",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
        end,

        timeline=
        {
            TimeEvent(FRAMES*0, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/buzzard/taunt") end)
        },

        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "caw",
        tags = {"idle"},
        onenter= function(inst)
            inst.AnimState:PlayAnimation("caw")
        end,

        timeline=
        {
            TimeEvent(FRAMES*0, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/buzzard/squack") end)
        },

        events=
        {
            EventHandler("animover", function(inst) if math.random() < .5 then inst.sg:GoToState("caw") else inst.sg:GoToState("idle") end end ),
        },
    },

    State{
        name = "distress_pre",
        tags = {"busy"},
        onenter= function(inst)
            inst.AnimState:PlayAnimation("flap_pre")
        end,
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("distress") end ),
        },
    },

    State{
        name = "distress",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("flap_loop")
        end,

        timeline=
        {
            TimeEvent(FRAMES*0, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/buzzard/squack") end)
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("distress") end ),
            EventHandler("onextinguish", function(inst) if not inst.components.health:IsDead() then inst.sg:GoToState("idle", "flap_pst") end end ),
        },
    },

    State{
        name = "glide",
        tags = {"idle", "flight", "busy"},
        onenter= function(inst)
            inst.AnimState:PlayAnimation("glide", true)
			inst.DynamicShadow:Enable(false)
            inst.Physics:SetMotorVelOverride(0,-15,0)
            inst.flapSound = inst:DoPeriodicTask(6*FRAMES,
                function(inst)
                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/buzzard/flap")
                end)
        end,

        onupdate= function(inst)
            inst.Physics:SetMotorVelOverride(0,-15,0)
            local pt = Point(inst.Transform:GetWorldPosition())
            if pt.y <= 0.1 or inst:IsAsleep() then
                inst.Physics:ClearMotorVelOverride()
                pt.y = 0
                inst.Physics:Stop()
                inst.Physics:Teleport(pt.x,pt.y,pt.z)
                inst.AnimState:PlayAnimation("land")
                inst.DynamicShadow:Enable(true)
                if inst.sg.statemem.target then
                    inst.sg:GoToState("kill", {target = inst.sg.statemem.target})
                else
                    inst.sg:GoToState("idle", true)
                end
            end
        end,

        onexit = function(inst)
			inst.DynamicShadow:Enable(true)
            if inst.flapSound then
                inst.flapSound:Cancel()
                inst.flapSound = nil
            end

            if inst:GetPosition().y > 0 then
                local pos = inst:GetPosition()
                pos.y = 0
                inst.Transform:SetPosition(pos:Get())
            end
            inst.components.knownlocations:RememberLocation("landpoint", inst:GetPosition())
        end,
    },

    State{
        name = "kill",
        tags = {"canrotate"},
        onenter = function(inst, data)
            inst.AnimState:PushAnimation("atk", false)
            if data and data.target:HasTag("prey") then
                inst.sg.statemem.target = data.target
            end
        end,

        timeline =
        {
            TimeEvent(15*FRAMES, function(inst)
                if inst.sg.statemem.target ~= nil and inst.sg.statemem.target:IsValid() then
                    inst:FacePoint(inst.sg.statemem.target.Transform:GetWorldPosition())
                end
            end),
            TimeEvent(27*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/buzzard/attack")
                local target = inst.sg.statemem.target

                if target ~= nil and
                    target:IsValid() and
                    inst:IsNear(target, TUNING.BUZZARD_ATTACK_RANGE) and
                    inst.components.combat:CanAttack(target) then
                    target.components.health:Kill()
                end
            end)
        },

        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "eat",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("peck")
        end,

        events=
        {
            EventHandler("animover", function(inst)
                if math.random() < .3 then
					inst:PerformBufferedAction()
                end
                inst.sg:GoToState("idle")
                if inst.brain then
                    inst.brain:ForceUpdate()
                end
            end),
        },
    },

    State{
        name = "flyaway",
        tags = {"flight", "busy", "canrotate"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.sg:SetTimeout(.1+math.random()*.2)
            inst.sg.statemem.vert = math.random() > .5

            if inst.components.periodicspawner and math.random() <= TUNING.CROW_LEAVINGS_CHANCE then
                inst.components.periodicspawner:TrySpawn()
            end

            if inst.sg.statemem.vert then
                inst.AnimState:PlayAnimation("takeoff_vertical_pre")
            else
                inst.AnimState:PlayAnimation("takeoff_diagonal_pre")
            end

            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/buzzard/flyout")
        end,

        ontimeout= function(inst)
            if inst.sg.statemem.vert then
                inst.AnimState:PushAnimation("takeoff_vertical_loop", true)
                inst.Physics:SetMotorVel(-2 + math.random()*4,15+math.random()*5,-2 + math.random()*4)
            else
                inst.AnimState:PushAnimation("takeoff_diagonal_loop", true)
                local x = 8+ math.random()*8
                inst.Physics:SetMotorVel(x,15+math.random()*5,-2 + math.random()*4)
            end
			inst.DynamicShadow:Enable(false)
        end,

        timeline =
        {
            TimeEvent(2, function(inst)
                if inst.components.homeseeker ~= nil then
                    inst.components.homeseeker.home.components.childspawner:GoHome(inst)
                else
                    --V2C: Debug spawned?
                    inst:Remove()
                end
            end),
        },

		onexit = function(inst)
			inst.DynamicShadow:Enable(true)
		end,
    },

    State{
        name = "hop",
        tags = {"moving", "canrotate", "hopping"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("hop")
            inst.components.locomotor:WalkForward()
            inst.sg:SetTimeout(2*math.random()+.5)
        end,

        onupdate= function(inst)
            if not inst.components.locomotor:WantsToMoveForward() then
                inst.sg:GoToState("idle")
            end
        end,

        timeline=
        {
            TimeEvent(8*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/buzzard/hurt")

                inst.Physics:Stop()
            end),
        },

        ontimeout= function(inst)
            inst.sg:GoToState("hop")
        end,
    },

    State{
        name = "hit",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()
            local pt = Vector3(inst.Transform:GetWorldPosition())
            if pt.y > 1 then
                inst.sg:GoToState("fall")
            end
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },

    State{
        name = "fall",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("fall_loop", true)
			inst.DynamicShadow:Enable(false)
        end,

        onupdate = function(inst)
            local pt = Vector3(inst.Transform:GetWorldPosition())
            if pt.y <= .2 then
                pt.y = 0
                inst.Physics:Stop()
                inst.Physics:Teleport(pt.x,pt.y,pt.z)
	            inst.DynamicShadow:Enable(true)
                inst.sg:GoToState("stunned")
            end
        end,

		onexit = function(inst)
			inst.DynamicShadow:Enable(true)
		end,
    },

    State{
        name = "stunned",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("stunned_loop", true)
            inst.sg:SetTimeout(GetRandomWithVariance(6, 2) )
            if inst.components.inventoryitem then
                inst.components.inventoryitem.canbepickedup = true
            end
        end,

        onexit = function(inst)
            if inst.components.inventoryitem then
                inst.components.inventoryitem.canbepickedup = false
            end
        end,

        ontimeout = function(inst) inst.sg:GoToState("flyaway") end,
    },
}

CommonStates.AddCombatStates(states,
{
    attacktimeline =
    {
        TimeEvent(15*FRAMES, function(inst)
            inst.components.combat:DoAttack(inst.sg.statemem.target)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/buzzard/attack")
        end),
        TimeEvent(20*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
    },
})

CommonStates.AddSleepStates(states)
CommonStates.AddFrozenStates(states)

return StateGraph("buzzard", states, events, "idle", actionhandlers)

