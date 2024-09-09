require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "gohome"),
    ActionHandler(ACTIONS.EAT, "eat"),
    ActionHandler(ACTIONS.PICKUP, "pickup"),
    ActionHandler(ACTIONS.EQUIP, "pickup"),
    ActionHandler(ACTIONS.ADDFUEL, "pickup"),
}

local events =
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true, true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(nil, TUNING.BUNNYMAN_MAX_STUN_LOCKS),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnHop(),
	CommonHandlers.OnSink(),
    EventHandler("cheer", function(inst, data)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("cheer")
        end
    end),
}

local states =
{
    State{
        name = "funnyidle",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()

            if inst.components.health:GetPercent() < TUNING.BUNNYMAN_PANIC_THRESH then
                inst.AnimState:PlayAnimation("idle_angry")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/angry_idle")
            elseif inst.components.follower:GetLeader() ~= nil and inst.components.follower:GetLoyaltyPercent() < .05 then
                inst.AnimState:PlayAnimation("hungry")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hungry")
            elseif inst.components.combat:HasTarget() then
                inst.AnimState:PlayAnimation("idle_angry")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/angry_idle")
            elseif inst.components.follower:GetLeader() ~= nil and inst.components.follower:GetLoyaltyPercent() > .3 then
                inst.AnimState:PlayAnimation("idle_happy")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/happy")
            else
                inst.AnimState:PlayAnimation("idle_creepy")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/idle_med")
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

        onenter = function(inst, data)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/death")
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.causeofdeath = data ~= nil and data.afflicter or nil
            inst.components.lootdropper:DropLoot(inst:GetPosition())
        end,
    },

    State{
        name = "abandon",
        tags = { "busy" },

        onenter = function(inst, leader)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("abandon")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/angry_idle")
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
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/attack")
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/bite")
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
        name = "eat",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/eat")
        end,

        timeline =
        {
            TimeEvent(20 * FRAMES, function(inst)
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
            inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/hurt")
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()
			CommonHandlers.UpdateHitRecoveryDelay(inst)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
    State{
        name = "cheer",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            CommonHandlers.UpdateHitRecoveryDelay(inst)
            inst.AnimState:PlayAnimation("idle_happy")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/happy")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
}

CommonStates.AddWalkStates(states, {
    walktimeline =
    {
        TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/hop") end),
        TimeEvent(4 * FRAMES, function(inst)
            inst.components.locomotor:WalkForward()
        end),
        TimeEvent(12 * FRAMES, function(inst)
            PlayFootstep(inst)
            inst.Physics:Stop()
        end),
    },
}, nil, true)

CommonStates.AddRunStates(states, {
    runtimeline =
    {
        TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/hop") end),
        TimeEvent(4 * FRAMES, function(inst)
            inst.components.locomotor:RunForward()
        end),
        TimeEvent(8 * FRAMES, function(inst)
            PlayFootstep(inst)
            inst.Physics:Stop()
        end),
    },
}, nil, true)

CommonStates.AddSleepStates(states,
{
    sleeptimeline =
    {
        TimeEvent(35 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/sleep") end),
    },
})

CommonStates.AddIdle(states, "funnyidle")
CommonStates.AddSimpleState(states, "refuse", "pig_reject", { "busy" })
CommonStates.AddFrozenStates(states)
CommonStates.AddSimpleActionState(states, "pickup", "pig_pickup", 10 * FRAMES, { "busy" })
CommonStates.AddSimpleActionState(states, "gohome", "pig_pickup", 4 * FRAMES, { "busy" })
CommonStates.AddHopStates(states, true, { pre = "boat_jump_pre", loop = "boat_jump_loop", pst = "boat_jump_pst"})
CommonStates.AddSinkAndWashAshoreStates(states)

return StateGraph("bunnyman", states, events, "idle", actionhandlers)
