require("stategraphs/commonstates")

local SOUNDS =
{
    hit         = "dontstarve/creatures/together/stagehand/hit",
    awake_pre   = "dontstarve/creatures/together/stagehand/awake_pre",
    footstep    = "dontstarve/creatures/together/stagehand/footstep",
}

local events =
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnAttacked(),

    EventHandler("doattack", function(inst, data)
        if not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("attack", (data and data.target) or nil)
        end
    end),

    EventHandler("standup", function(inst)
        if inst.sg:HasStateTag("busy") then
            inst.sg.mem.wants_to_stand = true
        else
            inst.sg:GoToState("standup")
        end
    end),

    EventHandler("sitdown", function(inst)
        if inst.sg:HasStateTag("busy") then
            inst.sg.mem.wants_to_sit = true
        else
            inst.sg:GoToState("sitdown")
        end
    end),
}

local states =
{
    State {
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()

            if inst.components.burnable:IsBurning() then
                inst.sg:GoToState("extinguish")
                return
            elseif inst.IsStanding ~= nil and inst:IsStanding() then
                if inst.sg.mem.wants_to_sit == true then
                    inst.sg.mem.wants_to_sit = false
                    inst.sg:GoToState("sitdown")
                    return
                else
                    inst.AnimState:PlayAnimation("awake_idle")
                end
            else
                if inst.sg.mem.wants_to_stand then
                    inst.sg.mem.wants_to_stand = false
                    inst.sg:GoToState("standup")
                    return
                else
                    inst.AnimState:PlayAnimation("idle")
                end
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State {
        name = "standup",
        tags = {"busy"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("awake_pre")
        end,

        timeline =
        {
            TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SOUNDS.hit) end),
            TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SOUNDS.awake_pre) end),
            TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SOUNDS.footstep) end),
            TimeEvent(22*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SOUNDS.footstep) end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.ChangeStanding then
                    inst:ChangeStanding(true)
                end

                inst.sg:GoToState((inst.components.locomotor:WantsToMoveForward() and "walk_start")
                                    or "idle")
            end),
        },
    },

    State {
        name = "sitdown",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("sleep")
        end,

        timeline =
        {
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SOUNDS.awake_pre) end),
            TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SOUNDS.hit) end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.ChangeStanding then
                    inst:ChangeStanding(false)
                end

                inst.sg:GoToState("idle")
            end),
        },
    },

    State {
        name = "attack",
        tags = {"attack", "busy"},

        onenter = function(inst, target)
            inst.components.locomotor:StopMoving()

            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("sleep")

            inst.sg.statemem.target = target
        end,

        timeline =
        {
            TimeEvent(15*FRAMES, function(inst)
                local target = inst.sg.statemem.target
                if (target ~= nil and target:IsValid()) and
                        (inst.StartAttackingTarget ~= nil and inst:StartAttackingTarget(target)) then
                    inst.sg.statemem.attack_success = true
                else
                    inst.sg.statemem.attack_success = false
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.sg.statemem.attack_success then
                    inst.sg:GoToState("attack_loop")
                else
                    inst.sg:GoToState("standup")
                end
            end),
        },
    },

    State {
        name = "attack_loop",
        tags = {"attack", "busy"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()

            inst.AnimState:PlayAnimation("idle_loop_01", true)

            -- Safety timeout.
            inst.sg:SetTimeout(10)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("standup")
        end,

        events =
        {
            EventHandler("handfinished", function(inst)
                inst.sg:GoToState("standup")
            end),
        },
    },

    State {
        name = "hit",
        tags = { "hit", "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()

            inst.sg.statemem.is_standing = inst:IsStanding()
            inst.AnimState:PlayAnimation((inst.sg.statemem.is_standing and "awake_hit")
                or "hit")
        end,

        timeline =
        {
            TimeEvent(0*FRAMES, function(inst)
                if inst.sg.statemem.is_standing then
                    inst.SoundEmitter:PlaySound(SOUNDS.hit)
                end
            end),
            TimeEvent(3*FRAMES, function(inst)
                if not inst.sg.statemem.is_standing then
                    inst.SoundEmitter:PlaySound(SOUNDS.hit)
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State {
        name = "extinguish",
        tags = { "busy" },

        onenter = function(inst)
            if inst.IsStanding and inst:IsStanding() then
                inst.sg:GoToState("extinguish_standing")
                return
            end

            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("extinguish")
        end,

        timeline =
        {
            TimeEvent(20*FRAMES, function(inst) inst.components.burnable:Extinguish() end),
            TimeEvent(28*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SOUNDS.hit) end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State {
        name = "extinguish_standing",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()

            inst.AnimState:PlayAnimation("sleep")
            inst.AnimState:PushAnimation("extinguish", false)
            inst.AnimState:PushAnimation("awake_pre", false)
        end,

        timeline =
        {
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SOUNDS.awake_pre) end),
            TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SOUNDS.hit) end),
            TimeEvent(52*FRAMES, function(inst) inst.components.burnable:Extinguish() end),
            TimeEvent(60*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SOUNDS.hit) end),
            TimeEvent(79*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SOUNDS.hit) end),
            TimeEvent(88*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SOUNDS.awake_pre) end),
            TimeEvent(89*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SOUNDS.footstep) end),
            TimeEvent(99*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SOUNDS.footstep) end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
}

CommonStates.AddWalkStates(states,
{
    starttimeline =
    {
        TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SOUNDS.footstep) end),
    },

    walktimeline =
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SOUNDS.footstep) end),
        TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SOUNDS.footstep) end),
        TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SOUNDS.footstep) end),
        TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SOUNDS.footstep) end),
    },

    endtimeline =
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SOUNDS.footstep) end),
        TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SOUNDS.footstep) end),
    },
})

return StateGraph("stageusher", states, events, "idle")
