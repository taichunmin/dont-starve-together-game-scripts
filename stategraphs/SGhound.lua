require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.EAT, "eat"),
}

local events =
{
    EventHandler("attacked", function(inst) if not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") then inst.sg:GoToState("hit") end end),
    EventHandler("death", function(inst) inst.sg:GoToState("death", inst.sg.statemem.dead) end),
    EventHandler("doattack", function(inst, data) if not inst.components.health:IsDead() and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then inst.sg:GoToState("attack", data.target) end end),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnLocomote(true, false),
    CommonHandlers.OnFreeze(),

    EventHandler("startle", function(inst)
        if not (inst.sg:HasStateTag("startled") or
                inst.components.health:IsDead() or
                (inst.components.freezable ~= nil and inst.components.freezable:IsFrozen())) then
            if inst.components.sleeper:IsAsleep() then
                inst.components.sleeper:WakeUp()
            end
            inst.components.combat:SetTarget(nil)
            inst.sg:GoToState("startle")
        end
    end),

    --Moon hounds
    EventHandler("workmoonbase", function(inst, data)
        if data ~= nil and data.moonbase ~= nil and not (inst.components.health:IsDead() or inst.sg:HasStateTag("busy")) then
            inst.sg:GoToState("workmoonbase", data.moonbase)
        end
    end),
}

local states =
{

    State{
        name = "idle",
        tags = { "idle", "canrotate" },
        onenter = function(inst, playanim)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/hound/pant")
            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("idle", true)
            else
                inst.AnimState:PlayAnimation("idle", true)
            end
            inst.sg:SetTimeout(2*math.random()+.5)
        end,
    },

    State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            inst.sg.statemem.target = target
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
        end,

        timeline =
        {

            TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/hound/attack") end),
            TimeEvent(16*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst) if math.random() < .333 then inst.components.combat:SetTarget(nil) inst.sg:GoToState("taunt") else inst.sg:GoToState("idle", "atk_pst") end end),
        },
    },

    State{
        name = "eat",
        tags = { "busy" },

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
        end,

        timeline =
        {
            TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/hound/bite") end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst) if inst:PerformBufferedAction() then inst.components.combat:SetTarget(nil) inst.sg:GoToState("taunt") else inst.sg:GoToState("idle", "atk_pst") end end),
        },
    },

    State{
        name = "hit",
        tags = { "busy", "hit" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "startle",
        tags = { "busy", "startled" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("scared_pre")
            inst.AnimState:PushAnimation("scared_loop", true)
            inst.SoundEmitter:PlaySound(inst.components.combat.hurtsound)
            inst.sg:SetTimeout(.8 + .3 * math.random())
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", "scared_pst")
        end,
    },

    State{
        name = "taunt",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
        end,

        timeline =
        {
            TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/hound/bark") end),
            TimeEvent(24*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/hound/bark") end),
        },

        events =
        {
            EventHandler("animover", function(inst) if math.random() < .333 then inst.sg:GoToState("taunt") else inst.sg:GoToState("idle") end end),
        },
    },

    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst, reanimating)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/hound/death")
            if reanimating then
                inst.AnimState:Pause()
            else
                inst.AnimState:PlayAnimation("death")
            end
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(inst:GetPosition())
        end,

        timeline =
        {
            TimeEvent(TUNING.GARGOYLE_REANIMATE_DELAY, function(inst)
                if not inst:IsInLimbo() then
                    inst.AnimState:Resume()
                end
            end),
        },

        onexit = function(inst)
            if not inst:IsInLimbo() then
                inst.AnimState:Resume()
            end
        end,
    },

    State{
        name = "forcesleep",
        tags = { "busy", "sleeping" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("sleep_loop", true)
        end,
    },

    --Moon hound
    State{
        name = "workmoonbase",
        tags = { "busy", "working" },

        onenter = function(inst, moonbase)
            inst.sg.statemem.moonbase = moonbase
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
        end,

        timeline =
        {
            --TimeEvent(14 * FRAMES, function(inst)
            --    inst.SoundEmitter:PlaySound("dontstarve/creatures/hound/attack")
            --end),
            TimeEvent(16 * FRAMES, function(inst)
                local moonbase = inst.sg.statemem.moonbase
                if moonbase ~= nil and
                    moonbase.components.workable ~= nil and
                    moonbase.components.workable:CanBeWorked() then
                    moonbase.components.workable:WorkedBy(inst, 1)
                    SpawnPrefab("mining_fx").Transform:SetPosition(moonbase.Transform:GetWorldPosition())
                    inst.SoundEmitter:PlaySound("dontstarve/impacts/impact_stone_wall_sharp")
                end
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.components.combat:SetTarget(nil)
                if math.random() < .333 then
                    inst.sg:GoToState("taunt")
                else
                    inst.sg:GoToState("idle", "atk_pst")
                end
            end),
        },
    },

    State{
        name = "reanimate",
        tags = { "busy" },

        onenter = function(inst, data)
            inst.sg.statemem.taunted = data.anim == "taunt"
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation(data.anim)
            inst.AnimState:Pause()
            if data.time ~= nil then
                inst.AnimState:SetTime(data.time)
            end
            inst.sg.statemem.dead = data.dead
        end,

        timeline =
        {
            TimeEvent(TUNING.GARGOYLE_REANIMATE_DELAY, function(inst)
                if not inst:IsInLimbo() then
                    inst.AnimState:Resume()
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState(inst.sg.statemem.taunted and "idle" or "taunt")
            end),
        },

        onexit = function(inst)
            if not inst:IsInLimbo() then
                inst.AnimState:Resume()
            end
        end,
    },
}

CommonStates.AddSleepStates(states,
{
    sleeptimeline = {
        TimeEvent(30*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/hound/sleep") end),
    },
})

CommonStates.AddRunStates(states,
{
    runtimeline = {
        TimeEvent(0, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/hound/growl")
            PlayFootstep(inst)
        end),
        TimeEvent(4*FRAMES, PlayFootstep),
    },
})
CommonStates.AddFrozenStates(states)

return StateGraph("hound", states, events, "taunt", actionhandlers)
