require("stategraphs/commonstates")

local POSING_MASS = 200
local DEFAULT_MASS = 50

local events =
{
    CommonHandlers.OnAttack(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnSleepEx(),
    CommonHandlers.OnWakeEx(),

    CommonHandlers.OnLocomote(true, true),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnHop(),

    EventHandler("despawn", function(inst)
        if inst.sg:HasStateTag("idle") and (inst.components.health == nil or not inst.components.health:IsDead()) then
            inst.sg:GoToState("despawn")
        end
    end),

	EventHandler("onsink", function(inst)
        if inst.components.health == nil or not inst.components.health:IsDead() then
            inst.sg:GoToState("despawn")
        end
	end),

}

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            if inst.sg.mem.sleeping then
                inst.sg:GoToState("sleep")
            else
                inst.components.locomotor:Stop()
                inst.AnimState:PlayAnimation("idle_object_loop", true)
            end
        end,
    },

    State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst)
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk_combo")
        end,

        timeline =
        {
            TimeEvent(12 * FRAMES, function(inst)
                inst.components.combat:DoAttack()
            inst.SoundEmitter:PlaySound("dontstarve/pig/attack")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
            end),
            TimeEvent(18 * FRAMES, function(inst)
                inst.components.combat:DoAttack()
            inst.SoundEmitter:PlaySound("dontstarve/pig/attack")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
            end),
            TimeEvent(31 * FRAMES, function(inst)
                inst.components.combat:DoAttack()
            inst.SoundEmitter:PlaySound("dontstarve/pig/attack")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
            end),
            TimeEvent(43 * FRAMES, function(inst)
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

    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/pig/grunt")
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
        end,
    },

    State{
        name = "spawnin",
        tags = { "intropose", "busy", "nofreeze", "nosleep", "noattack", "jumping" },

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation(inst.sg.mem.variation == "3" and "side_lob" or "front_lob")
            inst.AnimState:PushAnimation("pose"..inst.sg.mem.variation.."_pre", false)
            inst.AnimState:PushAnimation("pose"..inst.sg.mem.variation.."_pst", false)
            inst.SoundEmitter:PlaySound("dontstarve/movement/twirl_LP", "twirl")
            if data ~= nil then
                if data.dest ~= nil then
                    ToggleOffAllObjectCollisions(inst)
                    inst:ForceFacePoint(data.dest)
                    inst.Physics:SetMotorVelOverride(math.sqrt(inst:GetDistanceSqToPoint(data.dest)) / (22 * FRAMES), 0, 0)
                    inst.Physics:SetMass(POSING_MASS)
                end
            end
            inst.sg:SetTimeout(
                (inst.sg.mem.variation == "1" and (21 + 15) * FRAMES) or
                (inst.sg.mem.variation == "2" and (21 + 15) * FRAMES) or
                (inst.sg.mem.variation == "3" and (21 + 13) * FRAMES) or
                (21 + 13) * FRAMES
            )
        end,

        timeline =
        {
            --lob is 21 frames
            TimeEvent(20.5 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt") end),
            TimeEvent(21.5 * FRAMES, PlayFootstep),
            TimeEvent(22 * FRAMES, function(inst)
                inst.SoundEmitter:KillSound("twirl")
                if inst.sg.mem.isobstaclepassthrough then
                    inst.Physics:ClearMotorVelOverride()
                    inst.Physics:Stop()
                    local x, y, z = inst.Transform:GetWorldPosition()
                    ToggleOnAllObjectCollisionsAt(inst, x, z)
                end
                inst.sg:RemoveStateTag("jumping")
            end),
        },

        ontimeout = function(inst)
            inst.components.talker:Chatter("PIG_ELITE_FIGHTER_INTRO", tonumber(inst.sg.mem.variation))
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.mem.isobstaclepassthrough then
                inst.Physics:ClearMotorVelOverride()
                inst.Physics:Stop()
                local x, y, z = inst.Transform:GetWorldPosition()
                ToggleOnAllObjectCollisionsAt(inst, x, z)
            end
            inst.SoundEmitter:KillSound("twirl")
            inst.Physics:SetMass(DEFAULT_MASS)
        end,
    },

    State{
        name = "despawn",
        tags = { "endpose", "busy", "nofreeze", "nosleep", "noattack", "jumping" },
        --jumping tag to disable brain activity

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:AddOverrideBuild("player_superjump")
            inst.AnimState:PlayAnimation("superjump_pre")
            inst.AnimState:PushAnimation("superjump", false)
            ToggleOffAllObjectCollisions(inst)

            inst.components.talker:Chatter("PIG_ELITE_FIGHTER_OUTRO", tonumber(inst.sg.mem.variation))
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt", nil, .4)
                inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:Remove()
                end
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

CommonStates.AddRunStates(states)

CommonStates.AddSleepExStates(states,
{
    starttimeline =
    {
        TimeEvent(13 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("caninterrupt")
        end),
    },
    sleeptimeline =
    {
        TimeEvent(35 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/pig/sleep") end),
    },
},
{
    onsleep = function(inst)
        inst.sg:AddStateTag("caninterrupt")
    end,
})

CommonStates.AddFrozenStates(states)
CommonStates.AddHopStates(states, true, { pre = "boat_jump_pre", loop = "boat_jump_loop", pst = "boat_jump_pst"})

return StateGraph("pigelite", states, events, "idle")
