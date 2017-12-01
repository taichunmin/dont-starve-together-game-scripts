require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "gohome"),
    ActionHandler(ACTIONS.EAT, "eat"),
    ActionHandler(ACTIONS.CHOP, "chop"),
    ActionHandler(ACTIONS.PICKUP, "pickup"),
    ActionHandler(ACTIONS.EQUIP, "pickup"),
    ActionHandler(ACTIONS.ADDFUEL, "pickup"),
    ActionHandler(ACTIONS.TAKEITEM, "pickup"),
    ActionHandler(ACTIONS.UNPIN, "pickup"),
}

local events =
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true, true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(true),
    CommonHandlers.OnDeath(),
    EventHandler("transformnormal", function(inst)
        if not inst.components.health:IsDead() then
            inst.sg:GoToState("transformNormal")
        end
    end),
    EventHandler("doaction", function(inst, data)
        if data.action == ACTIONS.CHOP and not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("chop", data.target)
        end
    end),
}

local states =
{
    State{
        name = "funnyidle",
        tags = { "idle" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/pig/oink")

            if inst.components.follower:GetLeader() ~= nil and inst.components.follower:GetLoyaltyPercent() < .05 then
                inst.AnimState:PlayAnimation("hungry")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hungry")
            elseif inst:HasTag("guard") then
                inst.AnimState:PlayAnimation("idle_angry")
            elseif TheWorld.state.isnight then
                inst.AnimState:PlayAnimation("idle_scared")
            elseif inst.components.combat:HasTarget() then
                inst.AnimState:PlayAnimation("idle_angry")
            elseif inst.components.follower:GetLeader() ~= nil and inst.components.follower:GetLoyaltyPercent() > .3 then
                inst.AnimState:PlayAnimation("idle_happy")
            else
                inst.AnimState:PlayAnimation("idle_creepy")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/pig/grunt")
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(inst:GetPosition())
        end,
    },

    State{
        name = "abandon",
        tags = { "busy" },

        onenter = function(inst, leader)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("abandon")
            if leader ~= nil and leader:IsValid() then
                inst:FacePoint(leader:GetPosition())
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "transformNormal",
        tags = { "transform", "busy", "sleeping" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/transformToPig")
            inst.AnimState:SetBuild("werepig_build")
            inst.AnimState:PlayAnimation("transform_were_pig")
            inst:RemoveTag("hostile")
            inst.AnimState:OverrideSymbol("pig_arm_trans", inst.build, "pig_arm")
            inst.AnimState:OverrideSymbol("pig_ear_trans", inst.build, "pig_ear")
            inst.AnimState:OverrideSymbol("pig_head_trans", inst.build, "pig_head")
            inst.AnimState:OverrideSymbol("pig_leg_trans", inst.build, "pig_leg")
            inst.AnimState:OverrideSymbol("pig_torso_trans", inst.build, "pig_torso")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.components.sleeper:GoToSleep(15 + math.random() * 4)
                inst.sg:GoToState("sleeping")
            end),
        },

        onexit = function(inst)
            inst.AnimState:SetBuild(inst.build)
            inst.AnimState:ClearOverrideSymbol("pig_arm_trans")
            inst.AnimState:ClearOverrideSymbol("pig_ear_trans")
            inst.AnimState:ClearOverrideSymbol("pig_head_trans")
            inst.AnimState:ClearOverrideSymbol("pig_leg_trans")
            inst.AnimState:ClearOverrideSymbol("pig_torso_trans")
        end,
    },

    State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/pig/attack")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                inst.components.combat:DoAttack()
                inst.sg:RemoveStateTag("attack")
                inst.sg:RemoveStateTag("busy")
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
        name = "chop",
        tags = { "chopping" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                inst:PerformBufferedAction()
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
        name = "eat",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat")
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst)
                inst:PerformBufferedAction()
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
            inst.SoundEmitter:PlaySound("dontstarve/pig/oink")
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
}

CommonStates.AddWalkStates(states,
{
    walktimeline =
    {
        TimeEvent(0, PlayFootstep),
        TimeEvent(12 * FRAMES, PlayFootstep),
    },
})

CommonStates.AddRunStates(states,
{
    runtimeline =
    {
        TimeEvent(0, PlayFootstep),
        TimeEvent(10 * FRAMES, PlayFootstep),
    },
})

CommonStates.AddSleepStates(states,
{
    sleeptimeline =
    {
        TimeEvent(35 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/pig/sleep") end),
    },
})

CommonStates.AddIdle(states,"funnyidle")
CommonStates.AddSimpleState(states, "refuse", "pig_reject", { "busy" })
CommonStates.AddFrozenStates(states)
CommonStates.AddSimpleActionState(states, "pickup", "pig_pickup", 10 * FRAMES, { "busy" })
CommonStates.AddSimpleActionState(states, "gohome", "pig_pickup", 4 * FRAMES, { "busy" })

return StateGraph("pig", states, events, "idle", actionhandlers)
