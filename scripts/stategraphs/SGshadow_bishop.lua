local ShadowChess = require("stategraphs/SGshadow_chesspieces")

--See SGshadow_chesspieces.lua for CommonEventList

local SWARM_PERIOD = .5
local SWARM_START_DELAY = .25

local AREAATTACK_EXCLUDETAGS = { "INLIMBO", "notarget", "invisible", "noattack", "flight", "playerghost", "shadow", "shadowchesspiece", "shadowcreature" }
local function DoSwarmAttack(inst)
    inst.components.combat:DoAreaAttack(inst, inst.components.combat.hitrange, nil, nil, nil, AREAATTACK_EXCLUDETAGS)
end

local function DoSwarmFX(inst)
    local fx = SpawnPrefab("shadow_bishop_fx")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx.Transform:SetScale(inst.Transform:GetScale())
    fx.AnimState:SetMultColour(inst.AnimState:GetMultColour())
end

local states =
{
    State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            if target ~= nil and target:IsValid() then
                inst.sg.statemem.target = target
                inst.sg.statemem.targetpos = target:GetPosition()
            end
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk_side_pre")
        end,

        onupdate = function(inst)
            if inst.sg.statemem.target ~= nil then
                if inst.sg.statemem.target:IsValid() then
                    inst.sg.statemem.targetpos = inst.sg.statemem.target:GetPosition()
                else
                    inst.sg.statemem.target = nil
                end
            end
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                inst.sg:AddStateTag("noattack")
                inst.components.health:SetInvincible(true)
                DoSwarmFX(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.attack, "attack")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.attack = true
                    inst.sg:GoToState("attack_loop", { target = inst.sg.statemem.target, targetpos = inst.sg.statemem.targetpos })
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.attack then
                inst.components.health:SetInvincible(false)
                inst.SoundEmitter:KillSound("attack")
            end
        end,
    },

    State{
        name = "attack_loop",
        tags = { "attack", "busy", "noattack" },

        onenter = function(inst, data)
            inst.components.health:SetInvincible(true)
            if data.targetpos ~= nil then
                inst.Physics:Teleport(data.targetpos:Get())
                if data.target ~= nil and data.target:IsValid() then
                    local scale = inst.Transform:GetScale()
                    inst.sg.statemem.speed = 2 / scale
                    inst.sg.statemem.target = data.target
                    if inst:IsNear(data.target, .5) then
                        inst.Physics:Stop()
                    else
                        inst:ForceFacePoint(data.target.Transform:GetWorldPosition())
                        inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
                    end
                end
            end
            inst.AnimState:PlayAnimation("atk_side_loop_pre")

            inst.sg.statemem.task = inst:DoPeriodicTask(TUNING.SHADOW_BISHOP.ATTACK_TICK, DoSwarmAttack, TUNING.SHADOW_BISHOP.ATTACK_START_TICK)
            inst.sg.statemem.fxtask = inst:DoPeriodicTask(1.2, DoSwarmFX, .5)

            inst.sg:SetTimeout(130 * FRAMES)
        end,

        onupdate = function(inst)
            if inst.sg.statemem.target ~= nil then
                if not inst.sg.statemem.target:IsValid() then
                    inst.sg.statemem.target = nil
                elseif inst:IsNear(inst.sg.statemem.target, .5) then
                    inst.Physics:Stop()
                else
                    inst:ForceFacePoint(inst.sg.statemem.target.Transform:GetWorldPosition())
                    inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
                end
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() and inst.AnimState:IsCurrentAnimation("atk_side_loop_pre") then
                    --V2C: 1) we don't push this anim coz it might make the pre anim loop on clients
                    --     2) we loop this anim and use timeout so that it looks smoother on clients
                    inst.AnimState:PlayAnimation("atk_side_loop", true)
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg.statemem.attack = true
            inst.sg:GoToState("attack_loop_pst", inst.sg.statemem.target)
        end,

        onexit = function(inst)
            inst.sg.statemem.task:Cancel()
            inst.sg.statemem.fxtask:Cancel()
            if not inst.sg.statemem.attack then
                inst.components.health:SetInvincible(false)
                inst.SoundEmitter:KillSound("attack")
            end
        end,
    },

    State{
        name = "attack_loop_pst",
        tags = { "attack", "busy", "noattack" },

        onenter = function(inst, target)
            inst.sg.statemem.target = target
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk_side_loop_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    local pos = inst.sg.statemem.target ~= nil and inst.sg.statemem.target:IsValid() and inst.sg.statemem.target:GetPosition() or inst:GetPosition()
                    local bestoffset = nil
                    local minplayerdistsq = math.huge
                    for i = 1, 4 do
                        local offset = FindWalkableOffset(pos, math.random() * TWOPI, 8 + math.random() * 2, 4, false, true)
                        if offset ~= nil then
                            local player, distsq = FindClosestPlayerInRange(pos.x + offset.x, 0, pos.z + offset.z, 6, true)
                            if player == nil then
                                bestoffset = offset
                                break
                            elseif distsq < minplayerdistsq then
                                bestoffset = offset
                                minplayerdistsq = distsq
                            end
                        end
                    end
                    if bestoffset ~= nil then
                        inst.Physics:Teleport(pos.x + bestoffset.x, 0, pos.z + bestoffset.z)
                    end
                    inst.sg.statemem.attack = true
                    inst.sg:GoToState("attack_pst")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.attack then
                inst.components.health:SetInvincible(false)
            end
            inst.SoundEmitter:KillSound("attack")
        end,
    },

    State{
        name = "attack_pst",
        tags = { "attack", "busy", "noattack" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("atk_side_pst")
        end,

        timeline =
        {
            TimeEvent(21 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("noattack")
                inst.sg:RemoveStateTag("busy")
                inst.components.health:SetInvincible(false)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState(inst:WantsToLevelUp() and "idle" or "taunt")
                end
            end),
        },

        onexit = function(inst)
            inst.components.health:SetInvincible(false)
        end,
    },
}

ShadowChess.States.AddIdle(states, "idle_loop")
ShadowChess.States.AddLevelUp(states, "transform", 22, 58, 95)
ShadowChess.States.AddTaunt(states, "taunt", 3, 12, 47)
ShadowChess.States.AddHit(states, "hit", 0, 14)
ShadowChess.States.AddDeath(states, "disappear", 20,
{
    ShadowChess.Functions.DeathSoundTimelineEvent(19 * FRAMES),
})
ShadowChess.States.AddEvolvedDeath(states, "death", 25,
{
    ShadowChess.Functions.DeathSoundTimelineEvent(26 * FRAMES),
    ShadowChess.Functions.DeathSoundTimelineEvent(38 * FRAMES),
    ShadowChess.Functions.DeathSoundTimelineEvent(41 * FRAMES),
    ShadowChess.Functions.DeathSoundTimelineEvent(55 * FRAMES),
})
ShadowChess.States.AddDespawn(states, "disappear",
{
    ShadowChess.Functions.DeathSoundTimelineEvent(19 * FRAMES),
})
ShadowChess.States.AddAppear(states, "appear")


CommonStates.AddWalkStates(states)
CommonStates.AddSinkAndWashAshoreStates(states, {washashore = "appear"})

return StateGraph("shadow_bishop", states, ShadowChess.CommonEventList, "appear")
