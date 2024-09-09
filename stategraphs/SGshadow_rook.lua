local ShadowChess = require("stategraphs/SGshadow_chesspieces")

--See SGshadow_chesspieces.lua for CommonEventList

local AREAATTACK_EXCLUDETAGS = { "INLIMBO", "notarget", "invisible", "noattack", "flight", "playerghost", "shadow", "shadowchesspiece", "shadowcreature" }

local states =
{
    State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            inst.sg.statemem.target = target
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("teleport_pre")
            inst.AnimState:PushAnimation("teleport", false)
        end,

        timeline =
        {
            ShadowChess.Functions.ExtendedSoundTimelineEvent(0, "attack_grunt"),
            ShadowChess.Functions.ExtendedSoundTimelineEvent(12 * FRAMES, "teleport"),
            TimeEvent(19 * FRAMES, function(inst)
                inst.sg:AddStateTag("noattack")
                inst.components.health:SetInvincible(true)
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.attack = true
                    inst.sg:GoToState("attack_teleport", inst.sg.statemem.target)
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.attack then
                inst.components.health:SetInvincible(false)
            end
        end,
    },

    State{
        name = "attack_teleport",
        tags = { "attack", "busy", "noattack" },

        onenter = function(inst, target)
            inst.components.health:SetInvincible(true)
            if target ~= nil and target:IsValid() then
                inst.sg.statemem.target = target
                inst.Physics:Teleport(target.Transform:GetWorldPosition())
            end
            inst.AnimState:PlayAnimation("teleport_atk")
            inst.AnimState:PushAnimation("teleport_pst", false)
        end,

        timeline =
        {
            ShadowChess.Functions.ExtendedSoundTimelineEvent(0, "attack"),
            TimeEvent(17 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("noattack")
                inst.components.health:SetInvincible(false)
                inst.components.combat:DoAreaAttack(inst, inst.components.combat.hitrange, nil, nil, nil, AREAATTACK_EXCLUDETAGS)
            end),
            TimeEvent(34 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.components.health:SetInvincible(false)
        end,
    },
}

ShadowChess.States.AddIdle(states, "idle_loop")
ShadowChess.States.AddLevelUp(states, "transform", 20, 60, 88)
ShadowChess.States.AddTaunt(states, "taunt", 7, 30, 45)
ShadowChess.States.AddHit(states, "hit", 0, 14)
ShadowChess.States.AddDeath(states, "disappear", 10)
ShadowChess.States.AddEvolvedDeath(states, "death", 38,
{
    ShadowChess.Functions.DeathSoundTimelineEvent(45 * FRAMES),
    ShadowChess.Functions.DeathSoundTimelineEvent(64 * FRAMES),
})
ShadowChess.States.AddDespawn(states, "disappear")
ShadowChess.States.AddAppear(states, "appear")

CommonStates.AddWalkStates(states)
CommonStates.AddSinkAndWashAshoreStates(states, {washashore = {"teleport_pre", "teleport_pst"}})

return StateGraph("shadow_rook", states, ShadowChess.CommonEventList, "appear")
