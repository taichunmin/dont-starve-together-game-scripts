require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "gohome"),
    ActionHandler(ACTIONS.PICK, "pick"),
}

local events=
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true, true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    EventHandler("attacked", function(inst) if not inst.components.health:IsDead() and not inst.sg:HasStateTag("transform") then inst.sg:GoToState("hit") end end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("onplayernear", function(inst) inst.sg:GoToState("scared") end),
}

local states =
{
    State{
        name = "idle",
        tags = { "idle" },

        onenter = function(inst)
            inst.Physics:Stop()

            if inst.chased then
                inst.AnimState:PlayAnimation("tired_loop", true)
            else
                if math.random() < 0.07 then
                    inst.AnimState:PlayAnimation("idle2")
                else
                    inst.AnimState:PlayAnimation("idle", true)
                end
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        timeline =
        {
            TimeEvent(0*FRAMES, function(inst)
                if inst.chased then
                    inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbreadpig/breath")
                end
            end)
        },
    },

    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("death")
            inst.components.locomotor:StopMoving()

            if (inst.chased and inst.chased_by_player) or inst:IsNearPlayer(30) then
                inst.components.lootdropper:DropLoot(inst:GetPosition())
            end

            RemovePhysicsColliders(inst)
        end,

        timeline =
        {
            TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbreadpig/death1") end),
            TimeEvent(45*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbreadpig/death2") end),
        },
    },

    State{
        name = "scared",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("scare")

        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        timeline=
        {
            TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbreadpig/scared") end),
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbreadpig/hit") end),
            TimeEvent(10*FRAMES, function(inst) inst.StartDroppingCrumbs(inst) end),
            TimeEvent(20 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbreadpig/step") end),
            TimeEvent(22 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbreadpig/step") end),
        },

        onexit = function(inst)
            inst.chased_by_player = true
        end,
    },

    State{
        name = "hit",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        timeline =
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound(" wintersfeast2019/creatures/gingerbreadpig/hit") end)
        },
    },
}

CommonStates.AddRunStates (states,
{
    runtimeline =
    {
        TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbreadpig/jump") end),
        TimeEvent(7 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbreadpig/step") end),
        TimeEvent(7*FRAMES, PlayFootstep,nil,.05),
        TimeEvent(13 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbreadpig/jump") end),
        TimeEvent(17 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbreadpig/step") end),
        TimeEvent(17*FRAMES, PlayFootstep,nil,.05),
    },
})

CommonStates.AddFrozenStates(states)
CommonStates.AddSleepStates(states)

return StateGraph("gingerbreadpig", states, events, "idle", actionhandlers)