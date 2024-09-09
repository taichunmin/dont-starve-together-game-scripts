require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.TOSS,
        function(inst, action)
            if not inst.sg:HasStateTag("busy") then
                inst.sg:GoToState("shoot", action.target)
            end
        end),
}

local events =
{
    CommonHandlers.OnLocomote(false, true),

    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),

    EventHandler("death", function(inst)
		inst.sg:GoToState("death", "death")
	end),
    EventHandler("arrive", function(inst)
        inst.sg:GoToState("glide")
    end),

    EventHandler("doattack", function(inst)
        if not (inst.sg:HasStateTag("busy")) then
            inst.sg:GoToState("attack")
        end
    end),

    EventHandler("trapped", function(inst)
        inst.sg:GoToState("trapped")
    end),

    EventHandler("locomote", function(inst)
        if not inst.sg:HasStateTag("busy") and not inst.sg:HasStateTag("moving") then
            inst.sg:GoToState("walk")
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
            inst.AnimState:PlayAnimation("idle",true)
            inst.sg:SetTimeout(math.random() *2 )
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle_taunt")
        end,
    },

    State{
        name = "idle_taunt",
        tags = {"busy", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("caw")
            inst.SoundEmitter:PlaySound(inst.sounds.chirp)
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
            inst.AnimState:PlayAnimation("land")
        end,

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
            RemovePhysicsColliders(inst)
            inst.AnimState:PlayAnimation("death")
            inst.persists = false
        end,
    },


    State{
        name = "attack",
        tags = { "busy", "attack"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("attack")
			inst.components.locomotor:Stop()
			if inst.components.combat.target ~= nil then
				inst:ForceFacePoint(inst.components.combat.target.Transform:GetWorldPosition())
			end
	        inst.components.combat:StartAttack()
            inst.SoundEmitter:PlaySound(inst.sounds.attack)
		end,

        timeline=
        {
            TimeEvent(8*FRAMES, function(inst)
					inst.components.combat:DoAttack()
                    inst.components.combat:DropTarget()
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
            inst.SoundEmitter:PlaySound(inst.sounds.spit_pre)
        end,

        timeline =
        {
            TimeEvent(14*FRAMES, function(inst)
                if inst.sg.statemem.target and inst.sg.statemem.target:IsValid() then
                    inst.sg.statemem.spitpos = Vector3(inst.sg.statemem.target.Transform:GetWorldPosition())
                    inst:LaunchProjectile(inst.sg.statemem.spitpos)

                    inst.SoundEmitter:PlaySound(inst.sounds.chirp)

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

    State{
        name = "walk",
        tags = { "moving", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("hop")

        end,

        onexit = function(inst)
            inst.components.locomotor:StopMoving()
        end,

        timeline =
        {
            TimeEvent(4*FRAMES, function(inst)
                inst.components.locomotor:WalkForward()
            end),
            TimeEvent(10*FRAMES, function(inst)
                inst.components.locomotor:StopMoving()
            end),
        },

        events =
        {
            EventHandler("animover",function(inst)
                if math.random() < 0.1 then
                    inst.sg:GoToState("walk_wait_caw")
                else
                    inst.sg:GoToState("walk_wait")
                end
            end),
        },
    },

    State{
        name = "walk_wait",
        tags = { "moving" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle", true)
            inst.sg:SetTimeout(math.random() *2 )
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("walk")
        end,
    },

    State{
        name = "walk_wait_caw",
        tags = { "moving" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("caw")
            inst.SoundEmitter:PlaySound(inst.sounds.chirp)
        end,
        events =
        {
            EventHandler("animover",function(inst)
                inst.sg:GoToState("walk")
            end),
        },
    },


    State{
        name = "walk_stop",
        tags = { "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "glide",
        tags = { "busy" },
        onenter = function(inst)
            inst.Physics:SetDamping(0)
            inst.Physics:SetMotorVel(0, math.random() * 10 - 20, 0)
            inst.AnimState:PlayAnimation("glide", true)

            inst.sg.statemem.collisionmask = inst.Physics:GetCollisionMask()
            inst.Physics:SetCollisionMask(COLLISION.GROUND)
            if not TheWorld.ismastersim then
                inst.Physics:SetLocalCollisionMask(COLLISION.GROUND)
            end
        end,

        onupdate = function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            if y < 2 then
                inst.Physics:SetMotorVel(0, 0, 0)
                if y <= .1 then
                    inst.Physics:Stop()
                    inst.Physics:SetDamping(5)
                    inst.Physics:Teleport(x, 0, z)
                    inst.sg:GoToState("idle", true)
                end
            end
        end,

        onexit = function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            inst.Transform:SetPosition(x, 0, z)

            inst.Physics:ClearLocalCollisionMask()
            if inst.sg.statemem.collisionmask ~= nil then
                inst.Physics:SetCollisionMask(inst.sg.statemem.collisionmask)
            end
        end,
    },

    State{
        name = "land",
        tags = { "busy" },
        onenter = function(inst)
            inst.AnimState:PlayAnimation("land")
        end,
        events =
        {
            EventHandler("animover",function(inst)
                inst.AnimState:PlayAnimation("idle")
            end),
        },
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
            inst.sg:GoToState("idle")
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
            inst.sg:GoToState("idle")
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

return StateGraph("bird_mutant", states, events, "idle", actionhandlers)
