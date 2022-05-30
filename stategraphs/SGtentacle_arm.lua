-- TODO
--  Attack idle state needs to check to see if it attack
--      move newcombat event handling to stategraph
--
require("stategraphs/commonstates")

local EMERGE_MIN = 10
local EMERGE_MIN2 = EMERGE_MIN*EMERGE_MIN
local EMERGE_MAX = 15
local EMERGE_MAX2 = EMERGE_MAX*EMERGE_MAX

local events =
{
    EventHandler("attacked", function(inst)
        if not (inst.components.health:IsDead() or
                inst.sg:HasStateTag("hit") or
                inst.sg:HasStateTag("attack")) then
            inst.sg:GoToState("hit")
        end
    end),
    EventHandler("newcombattarget", function(inst)
        if inst.components.combat:HasTarget() and inst.sg:HasStateTag("attack_idle") then
            --Other cases are handled within the stategraph.
            inst.sg:GoToState("attack")
        end
    end),
    EventHandler("death", function(inst)
        inst.sg:GoToState("death")
    end),
    EventHandler("emerge", function(inst)
        --V2C: This tag is only on the idle state, so
        --     that is why there was no "busy" check.
        if inst.sg:HasStateTag("retracted") then
            inst.sg:GoToState("emerge")
        end
    end),
    EventHandler("retract", function(inst)
        --V2C: This tag is only on the idle state, so
        --     that is why there was no "busy" check.
        if inst.sg:HasStateTag("emerged") then
            inst.sg:GoToState("retract")
        end
    end),
    EventHandler("full_retreat", function(inst)
        if inst.sg:HasStateTag("retracted") then
            inst.sg:GoToState("full_retreat", true)
        elseif inst.sg:HasStateTag("emerged") then
            inst.sg:GoToState("full_retreat", false)
        end
    end),
    CommonHandlers.OnFreeze(),
}

local states =
{
    State{
        name = "idle",
        tags = { "idle", "retracted" },

        onenter = function(inst)
            if inst.retreat then
                inst.sg:GoToState("full_retreat", true)
                return
            end
            inst.AnimState:PlayAnimation("breach_pre")
            inst.AnimState:PushAnimation("breach_loop", true)
            inst.sg.statemem.task = inst:DoTaskInTime(GetRandomWithVariance(30, 1), inst.PushEvent, "full_retreat")
            inst.sg:SetTimeout(GetRandomWithVariance(.3, .2))
        end,

        ontimeout = function(inst)
            if inst.components.playerprox:IsPlayerClose() then
                inst:Emerge()
            end
        end,

        onexit = function(inst)
            inst.sg.statemem.task:Cancel()
        end,
    },

    State{
        name = "attack_idle",
        tags = { "attack_idle", "emerged" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("atk_idle")
            inst.AnimState:SetDeltaTimeMultiplier(GetRandomWithVariance(.9, .1))
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState(
                    (inst.retreat and "full_retreat") or
                    (inst.retracted and "retract") or
                    (inst.components.combat:HasTarget() and "attack") or
                    "attack_idle"
                )
            end),
        },
    },

    State{
        name = "emerge",
        tags = { "emerge" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:SetDeltaTimeMultiplier(GetRandomWithVariance(.9, .1))
            inst.SoundEmitter:PlaySound("dontstarve/tentacle/smalltentacle_emerge")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState(
                    (inst.retreat and "full_retreat") or
                    (inst.retracted and "retract") or
                    (inst.components.combat:HasTarget() and "attack") or
                    "attack_idle"
                )
            end),
        },
    },

    State{
        name = "attack",
        tags = { "attack" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("atk_loop")
            inst.AnimState:SetDeltaTimeMultiplier(GetRandomWithVariance(1, .05))
            inst.components.combat:StartAttack()
        end,

        timeline =
        {
            TimeEvent(2 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/tentacle/smalltentacle_attack") end),
            TimeEvent(7 * FRAMES, function(inst)
                inst.components.combat:DoAttack()
            end),
            TimeEvent(15 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/tentacle/smalltentacle_attack") end),
            TimeEvent(17 * FRAMES, function(inst)
                inst.components.combat:DoAttack()
            end),
            TimeEvent(18 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("attack")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState(
                    (inst.retreat and "full_retreat") or
                    (inst.retracted and "retract") or
                    (inst.components.combat:HasTarget() and "attack") or
                    "attack_idle"
                )
            end),
        },
    },

    State{
        name = "retract",
        tags = { "retract" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("atk_pst")
            inst.AnimState:SetDeltaTimeMultiplier(GetRandomWithVariance(1, .05))
            inst.SoundEmitter:PlaySound("dontstarve/tentacle/smalltentacle_disappear")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.retreat then
                    inst:Remove()
                else
                    inst.sg:GoToState(inst.retracted and "idle" or "emerge")
                end
            end),
        },
    },

    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("death")
            inst.AnimState:SetDeltaTimeMultiplier(GetRandomWithVariance(.8, .2))
        end,

        timeline=
        {
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_splat_arm") end),
        },
    },

    -- main pillar ordering us to hide
    State{
        name = "full_retreat",
        tags = { "busy" },

        onenter = function(inst, retracted)
            if retracted then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk_pst", false)
            else
                inst.AnimState:PlayAnimation("atk_pst")
            end
            inst.AnimState:SetDeltaTimeMultiplier(GetRandomWithVariance(.8, .2))
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst:Remove()
            end),
        },
    },

    State{
        name = "hit",
        tags = { "busy", "hit" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentapiller_hurt_VO")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("attack_idle")
            end),
        },
    },
}

CommonStates.AddFrozenStates(states)

return StateGraph("tentacle", states, events, "idle")
