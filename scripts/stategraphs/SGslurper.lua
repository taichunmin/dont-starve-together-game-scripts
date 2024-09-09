require("stategraphs/commonstates")

local actionhandlers =
{
    -- ActionHandler(ACTIONS.GOHOME, "action"),
    -- ActionHandler(ACTIONS.EAT, "eat"),
}

local events=
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnAttack(),
}

local states =
{
    State{

        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            inst._light.Light:Enable(true)
            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("idle_loop", true)
            else
                inst.AnimState:PlayAnimation("idle_loop", true)
            end
        end,

        events=
        {
            EventHandler("animover", function(inst)
                if math.random() < 0.15 then
                    inst.sg:GoToState("rumble")
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{

        name = "rumble",
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_rumble")
            inst._light.SoundEmitter:PlaySound("dontstarve/creatures/slurper/rumble")
        end,
        events=
        {
            EventHandler("animover", function (inst)
                inst.sg:GoToState("idle")
            end),
        }
    },

    State{
        name = "taunt",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
        end,

        timeline =
        {
            TimeEvent(5*FRAMES, function(inst) inst._light.SoundEmitter:PlaySound("dontstarve/creatures/slurper/taunt") end),
            TimeEvent(17*FRAMES, function(inst) inst._light.SoundEmitter:PlaySound("dontstarve/creatures/slurper/taunt") end),
            TimeEvent(25*FRAMES, function(inst) inst._light.SoundEmitter:PlaySound("dontstarve/creatures/slurper/taunt") end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "burp",
        tags = {"busy"},

        onenter = function(inst)
            inst.shouldburp = false
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("burp")
            inst._light.SoundEmitter:PlaySound("dontstarve/creatures/slurper/burp")
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "headslurp",
        tags = {"attack", "busy", "jumping"},

        onenter = function(inst, target)
            inst.AnimState:PlayAnimation("headslurp")
        end,

        timeline =
        {
            TimeEvent(8*FRAMES, function(inst)
                inst.Physics:SetMotorVelOverride(8,0,0)
                inst._light.SoundEmitter:PlaySound("dontstarve/creatures/slurper/jump")
             end),

            TimeEvent(23*FRAMES, function(inst)
                inst.Physics:ClearMotorVelOverride()
                inst.components.locomotor:Stop()
            end),

            TimeEvent(24*FRAMES, function(inst)
                --V2C: Need to revalidate target! Combat target could've
                --     changed after all these frames and state changes!
                local target = inst.components.combat.target
                if target ~= nil and
                    target:IsValid() and
                    inst:IsNear(target, 2) and
                    inst.HatTest ~= nil and
                    inst:HatTest(target) then
                    local oldhat = target.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
                    if oldhat ~= nil then
                        target.components.inventory:DropItem(oldhat)
                    end
                    target.components.inventory:Equip(inst)
                end
            end),
        },

        events =
        {
            --Check attachment eligibility. Either go into hat mode or miss mode.
            EventHandler("animover", function(inst)
                inst.sg:GoToState("headslurpmiss")
            end),
        },

        onexit = function(inst)
            inst.Physics:ClearMotorVelOverride()
        end,
    },

    State{
        name = "headslurpmiss",
        tags = {"attack", "busy"},

        onenter = function(inst, target)
            inst.AnimState:PlayAnimation("headslurpmiss")
            inst._light.SoundEmitter:PlaySound("dontstarve/creatures/slurper/miss")

        end,

        events =
        {
            --Go to taunt
            EventHandler("animover", function(inst)
                --inst.shouldburp gets set in "onequip". This means he's been "feeding" so he should burp.
                if not inst.shouldburp then
                    inst.sg:GoToState("taunt")
                else
                    inst.sg:GoToState("burp")
                end
            end),
        },
    },

    State{
        name = "attack",
        tags = {"attack", "busy", "jumping"},

        onenter = function(inst, target)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)

            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk")
            inst.sg.statemem.target = target

        end,

        onexit = function(inst)
            inst._light.SoundEmitter:KillSound("roll_VO")
            inst._light.SoundEmitter:KillSound("roll_dirt")
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            inst.Physics:ClearMotorVelOverride()
        end,

        timeline = {
            TimeEvent(20*FRAMES, function(inst)
                inst._light.SoundEmitter:PlaySound("dontstarve/creatures/slurper/roll_VO", "roll_VO")
                inst._light.SoundEmitter:PlaySound("dontstarve/creatures/slurper/roll_dirt", "roll_dirt")
                inst.Physics:SetMotorVelOverride(20,0,0)
            end),

            TimeEvent(30*FRAMES, function(inst)
                local target = inst.components.combat.target
                if target ~= nil and target:IsValid() then
                    if inst:IsNear(target, 2) then
                        inst.components.combat:DoAttack(target)
                    end
                    if inst.HatTest ~= nil and inst:HatTest(target) then
                        inst.sg:GoToState("headslurp")
                    end
                end

                inst._light.SoundEmitter:KillSound("roll_VO")
                inst._light.SoundEmitter:KillSound("roll_dirt")
                inst.Physics:ClearMotorVelOverride()
                inst.components.locomotor:Stop()
            end),

        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },


    State{
        name = "hit",
        tags = {"hit", "busy"},

        onenter = function(inst, cb)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("hit")
            inst._light.SoundEmitter:PlaySound("dontstarve/creatures/slurper/hurt")
			CommonHandlers.UpdateHitRecoveryDelay(inst)
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("death")
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            RemovePhysicsColliders(inst)
        end,

        timeline =
        {
            TimeEvent(12*FRAMES, function(inst) inst._light.SoundEmitter:PlaySound("dontstarve/creatures/slurper/die") end),
            TimeEvent(60*FRAMES,function(inst)
                inst._light.SoundEmitter:PlaySound("dontstarve/creatures/slurper/pop")
                inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
            end),
        },

    },

    State{
            name = "walk_start",
            tags = {"moving", "canrotate"},

            onenter = function(inst)
                inst.AnimState:PlayAnimation("roll_pre")
            end,

            timeline =
            {
                TimeEvent(7*FRAMES, function(inst) inst.components.locomotor:WalkForward() end),
            },

            events =
            {
                EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),
            },
        },

    State{

            name = "walk",
            tags = {"moving", "canrotate"},

            onenter = function(inst)
                inst.components.locomotor:WalkForward()
                inst.AnimState:PlayAnimation("roll_loop", true)
                inst._light.SoundEmitter:PlaySound("dontstarve/creatures/slurper/roll_VO", "roll_VO")
                inst._light.SoundEmitter:PlaySound("dontstarve/creatures/slurper/roll_dirt", "roll_dirt")
            end,

            onexit = function(inst)
                inst._light.SoundEmitter:KillSound("roll_VO")
                inst._light.SoundEmitter:KillSound("roll_dirt")
            end,

            events=
            {
                --EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),
            },
        },

    State{

            name = "walk_stop",
            tags = {"canrotate"},

            onenter = function(inst)
                inst.AnimState:PlayAnimation("roll_pst")
                inst.components.locomotor:StopMoving()
            end,

            events=
            {
                EventHandler("animover", function(inst)
                inst.sg:GoToState("idle") end ),
            },
        },

    State{
			name = "ruinsrespawn",
			tags = {"idle"},

			onenter = function(inst)
				inst.AnimState:PlayAnimation("spawn")
			end,

			events =
			{
				EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
			},
		},

}

CommonStates.AddSleepStates(states,
{
    starttimeline =
    {
        TimeEvent(7*FRAMES, function(inst) inst._light.Light:Enable(false) end),
    },

    sleeptimeline =
    {
        TimeEvent(0*FRAMES, function(inst) inst._light.SoundEmitter:PlaySound("dontstarve/creatures/slurper/sleep") end),
    },

    endtimeline =
    {
        TimeEvent(5*FRAMES, function(inst) inst._light.Light:Enable(true) end),
    },
})


CommonStates.AddFrozenStates(states)


return StateGraph("slurper", states, events, "idle", actionhandlers)
