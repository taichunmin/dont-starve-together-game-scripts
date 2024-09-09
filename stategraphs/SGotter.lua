require("stategraphs/commonstates")

local function action_condition(inst)
    return not inst.sg:HasStateTag("jumping")
end
local actionhandlers =
{
    ActionHandler(ACTIONS.DROP, "drop", action_condition),
    ActionHandler(ACTIONS.EAT, "eat_pre", action_condition),
    ActionHandler(ACTIONS.GOHOME, "gohome", action_condition),
    ActionHandler(ACTIONS.PICK, "pickup", action_condition),
    ActionHandler(ACTIONS.PICKUP, "pickup", action_condition),
    ActionHandler(ACTIONS.STEAL, "steal", action_condition),
}

local events =
{
    CommonHandlers.OnLocomote(true, false),
    CommonHandlers.OnSleepEx(),
    CommonHandlers.OnWakeEx(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnHop(),
    CommonHandlers.OnFreezeEx(),
}

local function go_to_idle(inst)
    inst.sg:GoToState("idle")
end

local BUSY_TAGS = {"busy"}
local EATING_TAGS = {"busy", "eating"}
local states = {
    State {
        name = "eat",
        tags = EATING_TAGS,

        onenter = function(inst)
            inst.components.locomotor:StopMoving()

            local bufferedaction = inst:GetBufferedAction()
            if not (bufferedaction and bufferedaction.target) then
                inst.sg:GoToState("eat_fail")
                return
            end

            inst.AnimState:PlayAnimation("eat_pst")
        end,

        timeline =
        {
            FrameEvent(1, function(inst)
                if inst:PerformBufferedAction() then
                    inst.SoundEmitter:PlaySound("meta4/otter/eat_chomp_f17")
                else
                    inst.sg:GoToState("eat_fail")
                end
            end),
            SoundFrameEvent(9, "meta4/otter/vo_eat_f21"),
            SoundFrameEvent(26, "meta4/otter/eat_pst_f40"),
        },

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State {
        name = "toss_fish",
        tags = BUSY_TAGS,

        onenter = function(inst, target)
            inst.components.locomotor:StopMoving()

            inst.AnimState:PlayAnimation("attack")

            inst.sg.statemem.toss_target = target
        end,

        timeline =
        {
            FrameEvent(6, function(inst)
                local target = inst.sg.statemem.toss_target
                if target and target:IsValid() and target:IsOnOcean(false) then
                    inst:TossFish(target)
                end

                inst.SoundEmitter:PlaySound("meta4/otter/vo_taunt_f8")
            end),
        },

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },
}

CommonStates.AddIdle(states, nil, "idle")
CommonStates.AddSimpleRunStates(states, nil, {
    starttimeline = {
        FrameEvent(3, function(inst)
            if not inst.components.amphibiouscreature.in_water then
                inst.SoundEmitter:PlaySound("meta4/otter/vo_run_pre_f3")
            end
        end),
        FrameEvent(5, function(inst)
            if not inst.components.amphibiouscreature.in_water then
                inst.SoundEmitter:PlaySound("meta4/otter/run_pre_f5")
            end
        end),
    },
    runtimeline = {
        FrameEvent(8, function(inst)
            if not inst.components.amphibiouscreature.in_water then
                inst.SoundEmitter:PlaySound("meta4/otter/run_lp_f8")
            else
                inst.SoundEmitter:PlaySound("turnoftides/common/together/water/submerge/medium")
            end
        end),
    },
    endtimeline = {
        FrameEvent(4, function(inst)
            if not inst.components.amphibiouscreature.in_water then
                inst.SoundEmitter:PlaySound("meta4/otter/run_pst_f4")
            end
        end),
    },
})

CommonStates.AddSimpleState(states, "eat_pre", "eat_pre", EATING_TAGS, "eat", {
    SoundFrameEvent(6, "meta4/otter/vo_eat_pre_f6"),
})
CommonStates.AddSimpleState(states, "eat_fail", "eat_none", EATING_TAGS)
CommonStates.AddSimpleState(states, "taunt", "taunt", BUSY_TAGS, nil,
{
    SoundFrameEvent(0, "meta4/otter/taunt_f0"),
    SoundFrameEvent(8, "meta4/otter/vo_taunt_f8"),
})

CommonStates.AddSimpleActionState(states, "pickup", "pickup", nil, BUSY_TAGS, nil, {
    SoundFrameEvent(5, "meta4/otter/pickup_f5"),
    FrameEvent(10, function(inst)
        inst:PerformBufferedAction()
    end),
})
CommonStates.AddSimpleActionState(states, "drop", "drop", nil, BUSY_TAGS, nil, {
    SoundFrameEvent(7, "meta4/otter/drop_f7"),
    FrameEvent(40, function(inst)
        inst.SoundEmitter:PlaySound("meta4/otter/attack_f0")
        inst:PerformBufferedAction()
    end),
})
CommonStates.AddSimpleActionState(states, "gohome", "sleep_pre", 23*FRAMES, BUSY_TAGS)

CommonStates.AddSimpleActionState(states, "steal", "attack", nil, nil, "taunt", {
    SoundFrameEvent(0, "meta4/otter/attack_f0"),
    SoundFrameEvent(4, "meta4/otter/vo_attack_f4"),
    FrameEvent(10, function(inst)
        inst:PerformBufferedAction()
    end),
},
{
    onexit = function(inst)
        inst:ClearBufferedAction()
    end,
})

local ATTACK_FRAME = 15
local COMBAT_TIMELINES = {
    attacktimeline = {
        SoundFrameEvent(0, "meta4/otter/attack_f0"),
        SoundFrameEvent(4, "meta4/otter/vo_attack_f4"),
        FrameEvent(ATTACK_FRAME, function(inst)
            inst.components.combat:DoAttack()
        end),
    },
    deathtimeline = {
        SoundFrameEvent(4, "meta4/otter/vo_death_f4"),
        SoundFrameEvent(30, "meta4/otter/death_impact_f30"),
    },
}
local COMBAT_ANIMS = { attack = "bite" }
local COMBAT_FNS = { }
CommonStates.AddCombatStates(states, COMBAT_TIMELINES, COMBAT_ANIMS, COMBAT_FNS)

CommonStates.AddSleepExStates(states,
{
    starttimeline = {
        SoundFrameEvent(5, "meta4/otter/sleep_pre_f5"),
    },
    sleeptimeline = {
        SoundFrameEvent(0, "meta4/otter/vo_sleep_loop_f0"),
        SoundFrameEvent(22, "meta4/otter/vo_sleep_loop_pst_f22"),
    },
    waketimeline = {
        SoundFrameEvent(22, "meta4/otter/sleep_pst_f22"),
    },
})

CommonStates.AddAmphibiousCreatureHopStates(states,
{ -- Config
    swimming_clear_collision_frame = 9 * FRAMES,
},
{ -- Anims
},
{ -- Timelines
    hop_pre =
    {
        FrameEvent(0, function(inst)
            if inst:HasTag("swimming") then
                SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())
            end
        end),
    },
    hop_pst = {
        FrameEvent(4, function(inst)
            if inst:HasTag("swimming") then
                inst.components.locomotor:Stop()
                SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())
            end
        end),
        FrameEvent(6, function(inst)
            if not inst:HasTag("swimming") then
                inst.components.locomotor:StopMoving()
            end
        end),
    }
})

CommonStates.AddFrozenStates(states)

return StateGraph("otter", states, events, "idle", actionhandlers)