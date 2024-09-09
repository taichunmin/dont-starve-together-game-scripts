require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "action"),
    ActionHandler(ACTIONS.POLLINATE, function(inst)
        return inst.sg:HasStateTag("landed") and "pollinate" or "land"
    end),
}

local events =
{
    EventHandler("attacked", function(inst)
        if not inst.components.health:IsDead() then
            inst.sg:GoToState("hit")
        end
    end),
    EventHandler("doattack", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("attack")
        end
    end),
    EventHandler("death", function(inst)
        inst.sg:GoToState("death")
    end),
    CommonHandlers.OnSleepEx(),
    CommonHandlers.OnWakeEx(),
    CommonHandlers.OnFreeze(),
    EventHandler("locomote", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("attack")) and
            inst.sg:HasStateTag("moving") ~= inst.components.locomotor:WantsToMoveForward() then
            inst.sg:GoToState(inst.sg:HasStateTag("moving") and "idle" or "premoving")
        end
    end),
}

local function StartBuzz(inst)
    inst:EnableBuzz(true)
end

local function StopBuzz(inst)
    inst:EnableBuzz(false)
end

local states =
{
    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            StopBuzz(inst)
            inst.SoundEmitter:PlaySound(inst.sounds.death)
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            if inst.components.lootdropper ~= nil then
                inst.components.lootdropper:DropLoot(inst:GetPosition())
            end
        end,

        timeline =
        {
            TimeEvent(12*FRAMES, LandFlyingCreature),
        },
    },

    State{
        name = "action",

        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle", true)
            inst:PerformBufferedAction()
        end,

        events =
        {
            EventHandler("animover", function (inst)
                inst.sg:GoToState("idle")
            end),
        }
    },

    State{
        name = "premoving",
        tags = { "moving", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("moving")
            end),
        },
    },

    State{
        name = "moving",
        tags = { "moving", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            if not inst.AnimState:IsCurrentAnimation("walk_loop") then
                inst.AnimState:PushAnimation("walk_loop", true)
            end
            inst.sg:SetTimeout(2.5 + math.random())
        end,

        ontimeout = function(inst)
            inst.sg:GoToState(
                inst.components.combat ~= nil and
                not inst.components.combat:HasTarget() and
                not inst:GetBufferedAction() and
                inst:HasTag("worker") and
                "catchbreath" or
                "moving"
            )
        end,
    },

    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, start_anim)
            inst.Physics:Stop()
            local animname = (inst.components.combat ~= nil and inst.components.combat:HasTarget() or inst:HasTag("killer")) and "idle_angry" or "idle"
            if start_anim then
                inst.AnimState:PlayAnimation(start_anim)
                inst.AnimState:PushAnimation(animname, true)
            elseif not inst.AnimState:IsCurrentAnimation(animname) then
                inst.AnimState:PlayAnimation(animname, true)
            end
        end,
    },

    State{
        name = "catchbreath",
        tags = { "busy", "landed" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("land")
            inst.AnimState:PushAnimation("land_idle", true)
            inst.sg:SetTimeout(GetRandomWithVariance(4, 2))
        end,

        timeline =
        {
            TimeEvent(20 * FRAMES, function(inst)
                LandFlyingCreature(inst)
                StopBuzz(inst)
                inst.SoundEmitter:PlaySound("dontstarve/bee/bee_tired_LP", "tired")
            end),
        },

        ontimeout = function(inst)
            if not (inst.components.homeseeker ~= nil and inst.components.homeseeker:HasHome()) and
                inst.components.pollinator ~= nil and
                inst.components.pollinator:HasCollectedEnough() and
                inst.components.pollinator:CheckFlowerDensity() then
                inst.components.pollinator:CreateFlower()
            end
            inst.sg.statemem.takingoff = true
            inst.sg:GoToState("takeoff")
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("tired")
            RaiseFlyingCreature(inst)
            if not inst.sg.statemem.takingoff then
                --interrupted, restore sound
                StartBuzz(inst)
            end
        end,
    },

    State{
        name = "land",
        tags = { "busy", "landing" },

        onenter = function(inst)
            inst.Physics:Stop()
            LandFlyingCreature(inst)
            inst.AnimState:PlayAnimation("land")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                StopBuzz(inst)
                inst.sg:GoToState(inst.bufferedaction ~= nil and inst.bufferedaction.action == ACTIONS.POLLINATE and "pollinate" or "land_idle")
            end),
        },

        onexit = RaiseFlyingCreature,
    },

    State{
        name = "land_idle",
        tags = { "busy", "landed" },

        onenter = function(inst)
            inst.AnimState:PushAnimation("land_idle", true)
        end,

        onexit = StartBuzz,
    },

    State{
        name = "pollinate",
        tags = { "busy", "landed" },

        onenter = function(inst)
            inst.AnimState:PushAnimation("land_idle", true)
            LandFlyingCreature(inst)
            inst.sg:SetTimeout(GetRandomWithVariance(3, 1))
        end,

        ontimeout = function(inst)
            inst:PerformBufferedAction()
            inst.sg.statemem.takingoff = true
            inst.sg:GoToState("takeoff")
        end,

        onexit = function(inst)
            RaiseFlyingCreature(inst)
            if not inst.sg.statemem.takingoff then
                StartBuzz(inst)
            end
        end,
    },

    State{
        name = "takeoff",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("take_off")
            inst.SoundEmitter:PlaySound(inst.sounds.takeoff)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = StartBuzz,
    },

    State{
        name = "taunt",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle")
            inst.SoundEmitter:PlaySound(inst.sounds.takeoff)
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
        tags = { "attack" },

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk")
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.attack)
            end),
            TimeEvent(15 * FRAMES, function(inst)
                inst.components.combat:DoAttack()
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
            inst.SoundEmitter:PlaySound(inst.sounds.hit)
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

local function CleanupIfSleepInterrupted(inst)
    if not inst.sg.statemem.continuesleeping then
        StartBuzz(inst)
    end
    RaiseFlyingCreature(inst)
end
CommonStates.AddSleepExStates(states,
{
    starttimeline =
    {
        TimeEvent(10 * FRAMES, LandFlyingCreature),
        TimeEvent(23 * FRAMES, StopBuzz),
    },
    waketimeline =
    {
        TimeEvent(1 * FRAMES, StartBuzz),
        TimeEvent(20 * FRAMES, RaiseFlyingCreature),
        CommonHandlers.OnNoSleepTimeEvent(24 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("busy")
            inst.sg:RemoveStateTag("nosleep")
        end),
    },
},
{
    onexitsleep = CleanupIfSleepInterrupted,
    onsleeping = LandFlyingCreature,
    onexitsleeping = CleanupIfSleepInterrupted,
    onwake = LandFlyingCreature,
    onexitwake = StartBuzz,
})

CommonStates.AddFrozenStates(states,
    function(inst)
        LandFlyingCreature(inst)
        StopBuzz(inst)
    end,
    function(inst)
        RaiseFlyingCreature(inst)
        StartBuzz(inst)
    end)

return StateGraph("bee", states, events, "idle", actionhandlers)
