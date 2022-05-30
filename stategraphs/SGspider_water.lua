local easing = require("easing")

require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.EAT,
        function(inst, action)
            if action.target:HasTag("spidermutator") and action.target.components.spidermutator:CanMutate(inst) then
                action.target.components.spidermutator:Mutate(inst, true)
                return "mutate"
            else
                return "eat"
            end
        end),
    ActionHandler(ACTIONS.GOHOME, "investigate"),
    ActionHandler(ACTIONS.INVESTIGATE, "investigate"),
}

local events =
{
    CommonHandlers.OnSleepEx(),
    CommonHandlers.OnWakeEx(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnHop(),
    CommonHandlers.OnDeath(),

    EventHandler("attacked", function(inst)
        if not inst.components.health:IsDead() then
            inst.sg:GoToState("hit") -- can still attack
        end
    end),

    EventHandler("doattack", function(inst, data)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            --target CAN go invalid because SG events are buffered
            inst.sg:GoToState("attack", data.target)
        end
    end),

    EventHandler("locomote", function(inst)
        if not inst.sg:HasStateTag("busy") then
            local is_moving = inst.sg:HasStateTag("moving")
            local wants_to_move = inst.components.locomotor:WantsToMoveForward()
            if not inst.sg:HasStateTag("attack") and is_moving ~= wants_to_move then
                if wants_to_move then
                    inst.sg:GoToState("premoving")
                else
                    inst.sg:GoToState("idle", "walk_pst")
                end
            end
        end
    end),

    EventHandler("trapped", function(inst)
        if not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("trapped")
        end
    end),

    EventHandler("mutate", function(inst)
        if not inst.sg:HasStateTag("mutating") then
            inst.sg:GoToState("mutate")
        end
    end),
}

local function SoundPath(event)
    return "waterlogged1/creatures/spider_water/" .. event
end

local function go_to_idle(inst)
    inst.sg:GoToState("idle")
end

local function do_mutate(inst)
    inst.components.inventory:DropEverything()

    local new_spider = SpawnPrefab(inst.mutation_target)
    if new_spider then
        local x,y,z = inst.Transform:GetWorldPosition()
        new_spider.Transform:SetPosition(x,y,z)

        if inst.components.follower.leader ~= nil then
            new_spider.components.follower:SetLeader(inst.components.follower.leader)
        end

        if inst.components.combat:HasTarget() then
            new_spider.components.combat:SetTarget(inst.components.combat.target)
        end

        new_spider.sg:GoToState("mutate_pst")

        inst:Remove()
    end
end

local states =
{
    State {
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst, start_anim)
            inst.Physics:Stop()

            if start_anim then
                inst.AnimState:PlayAnimation(start_anim)
                inst.AnimState:PushAnimation("idle", true)
            else
                inst.AnimState:PlayAnimation("idle", true)
            end

            if math.random() < .3 then
                inst.sg:SetTimeout(math.random()*2 + 2)
            end
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("taunt")
        end,
    },

    State {
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst.SoundEmitter:PlaySound(SoundPath("die"))
            inst.AnimState:PlayAnimation("death")
            inst.AnimState:PushAnimation("death_idle", true)
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(inst:GetPosition())
        end,
    },

    State {
        name = "premoving",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            if inst.components.amphibiouscreature.in_water then
                inst.Physics:Stop()
            else
                inst.components.locomotor:WalkForward()
            end
            inst.AnimState:PlayAnimation("walk_pre")
        end,

        timeline =
        {
            TimeEvent(3*FRAMES, function(inst)
                if not inst.components.amphibiouscreature.in_water then
                    inst.SoundEmitter:PlaySound(SoundPath("walk_spider"))
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("moving")
            end),
        },
    },

    State {
        name = "moving",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            if inst.components.amphibiouscreature.in_water then
                inst.components.locomotor.runspeed = TUNING.SPIDER_WATER_OCEANFLOATSPEED
                inst.components.locomotor:RunForward()

                inst.SoundEmitter:PlaySound(SoundPath("walk_water"))
            else
                inst.components.locomotor:WalkForward()
            end

            inst.AnimState:PushAnimation("walk_loop")
        end,

        timeline =
        {
            -- ON LAND TIME EVENTS
            TimeEvent(0*FRAMES, function(inst)
                if not inst.components.amphibiouscreature.in_water then
                    inst.SoundEmitter:PlaySound(SoundPath("walk_spider"))
                end
            end),
            TimeEvent(3*FRAMES, function(inst)
                if not inst.components.amphibiouscreature.in_water then
                    inst.SoundEmitter:PlaySound(SoundPath("walk_spider"))
                end
            end),
            TimeEvent(7*FRAMES, function(inst)
                if not inst.components.amphibiouscreature.in_water then
                    inst.SoundEmitter:PlaySound(SoundPath("walk_spider"))
                end
            end),
            TimeEvent(12*FRAMES, function(inst)
                if not inst.components.amphibiouscreature.in_water then
                    inst.SoundEmitter:PlaySound(SoundPath("walk_spider"))
                end
            end),

            -- IN WATER TIME EVENTS
            TimeEvent(7*FRAMES, function(inst)
                if inst.components.amphibiouscreature.in_water then
                    inst.SoundEmitter:PlaySound(SoundPath("walk_water"))
                end
            end),
            TimeEvent(16*FRAMES, function(inst)
                if inst.components.amphibiouscreature.in_water then
                    inst.components.locomotor.runspeed = TUNING.SPIDER_WATER_OCEANDASHSPEED
                    inst.components.locomotor:RunForward()

                    inst.SoundEmitter:PlaySound("turnoftides/common/together/water/swim/walk_water_med")

                    -- Spawn a wake opposite of our movement direction
                    local wake = SpawnPrefab("boat_water_fx")
                    local rotation = inst.Transform:GetRotation() - 180
                    local reverse_rot = rotation - math.floor(rotation/360)*360

                    local theta = reverse_rot * DEGREES
                    local pos = inst:GetPosition() + (Vector3(math.cos(theta), 0, -math.sin(theta)) * 0.5)

                    wake.Transform:SetPosition(pos:Get())
                    wake.Transform:SetRotation(reverse_rot - 90)
                    wake.AnimState:SetScale(0.7, 0.7)
                end
            end),
        },

        onupdate = function(inst, dt)
            if inst.components.amphibiouscreature.in_water then
                local current_speed, y, z = inst.Physics:GetMotorVel()
                if current_speed > TUNING.SPIDER_WATER_OCEANFLOATSPEED then
                    inst.sg.statemem._dashtime = (inst.sg.statemem._dashtime or 0) + dt

                    local new_speed = -1 * easing.inQuad(
                        inst.sg.statemem._dashtime,
                        -TUNING.SPIDER_WATER_OCEANDASHSPEED,
                        (TUNING.SPIDER_WATER_OCEANDASHSPEED - TUNING.SPIDER_WATER_OCEANFLOATSPEED),
                        30*FRAMES
                    )

                    -- Locomotor only updates its speed when RunForward is called,
                    -- but we shouldn't need to call that constantly. Might as well
                    -- keep runspeed updated though.
                    inst.Physics:SetMotorVel(new_speed, 0, 0)
                    inst.components.locomotor.runspeed = new_speed
                end
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("moving")
            end),
        },

        onexit = function(inst)
            if inst.components.amphibiouscreature.in_water then
                inst.components.locomotor.runspeed = TUNING.SPIDER_WATER_RUNSPEED
            end
        end,
    },

    State {
        name = "eat",
        tags = {"busy"},

        onenter = function(inst, forced)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat")

            inst.sg.statemem.forced = forced
        end,

        timeline =
        {
            TimeEvent(6*FRAMES, function(inst)
                if inst.components.amphibiouscreature.in_water then
                    local breach_fx = SpawnPrefab("ocean_splash_small1")
                    breach_fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
                end

                inst.SoundEmitter:PlaySound(SoundPath("eat"), "eating")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg.statemem._eating = false

                local action = inst:GetBufferedAction()
                if action and action.target and action.target:IsValid() then
                    -- If somebody is fishing this fish, consider it an attack on you and go after them.
                    if action.target.components.oceanfishable then
                        local rod = action.target.components.oceanfishable:GetRod()
                        if rod then
                            inst:PushEvent("attacked", {attacker = rod.components.oceanfishingrod.fisher})
                        end

                        -- Easier for oceanfishable things for us to just remove them
                        -- instead of trying to "really" eat them
                        action.target:Remove()

                        inst.sg.statemem._eating = true
                        inst:ClearBufferedAction()
                    else
                        inst.sg.statemem._eating = inst:PerformBufferedAction()
                    end
                end

                -- If we ate something, do our chewing loop. Otherwise go straight to idle.
                if inst.sg.statemem._eating then
                    inst.components.timer:StartTimer("eat_cooldown", TUNING.SPIDER_WATER_EATCD)
                    inst.sg:GoToState("eat_loop")
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst:ClearBufferedAction()

            if not inst.sg.statemem._eating then
                inst.SoundEmitter:KillSound("eating")
            end
        end,
    },

    State {
        name = "eat_loop",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat_loop", true)
            inst.sg:SetTimeout(1 + math.random())
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", "eat_pst")
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("eating")
        end,
    },

    State {
        name = "taunt",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.SoundEmitter:PlaySound(SoundPath("scream"))
        end,

        events=
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State {
        name = "investigate",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.SoundEmitter:PlaySound(SoundPath("scream"))
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst:PerformBufferedAction()
                inst.sg:GoToState("idle")
            end),
        },
    },

    State {
        name = "attack",
        tags = {"attack", "busy"},

        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk")
            inst.sg.statemem.target = target
        end,

        timeline=
        {
            TimeEvent(10*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(SoundPath("Attack"))
                inst.SoundEmitter:PlaySound(SoundPath("attack_grunt"))
            end),
            TimeEvent(16*FRAMES, function(inst)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
            end),
        },

        events=
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State {
        name = "hit",

        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()
        end,

        events=
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State {
        name = "dropper_enter",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("enter")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/descend")
        end,

        events=
        {
            EventHandler("animqueueover", go_to_idle),
        },
    },

    State {
        name = "trapped",
        tags = { "busy", "trapped" },

        onenter = function(inst)
            inst.Physics:Stop()

            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("cower")
            inst.AnimState:PushAnimation("cower_loop", true)

            inst.sg:SetTimeout(1)
        end,

        ontimeout = go_to_idle,
    },

    State {
        name = "mutate",
        tags = {"busy", "mutating"},

        onenter = function(inst)
            inst.Physics:Stop()

            inst.AnimState:PlayAnimation("mutate_pre")

            inst.SoundEmitter:PlaySound("webber2/common/mutate")
        end,

        events =
        {
            EventHandler("animover", function(inst) 
                local fx = SpawnPrefab("spider_mutate_fx")
                fx.Transform:SetPosition(inst.Transform:GetWorldPosition())

                inst:DoTaskInTime(0.25, do_mutate)
            end),
        },
    },

    State {
        name = "mutate_pst",
        tags = {"busy", "mutating"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("mutate_pst")
        end,

        events =
        {
            EventHandler("animqueueover", go_to_idle),
        },
    },
}

CommonStates.AddSleepExStates(states,
{
    starttimeline = {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath("fallAsleep")) end ),
    },
    sleeptimeline =
    {
        TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath("sleeping")) end ),
    },
    waketimeline = {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath("wakeUp")) end ),
    },
})
CommonStates.AddFrozenStates(states)

CommonStates.AddAmphibiousCreatureHopStates(states,
{ -- config
    swimming_clear_collision_frame = 5*FRAMES,
},
nil,
{ -- timelines
    hop_pre =
    {
        TimeEvent(0, function(inst)
            if inst:HasTag("swimming") then
                SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())
            end
        end),
    },
    hop_pst = {
        TimeEvent(4 * FRAMES, function(inst)
            if inst:HasTag("swimming") then
                inst.components.locomotor:Stop()
                SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())
            end
        end),
        TimeEvent(6 * FRAMES, function(inst)
            if not inst:HasTag("swimming") then
                inst.components.locomotor:StopMoving()
            end
        end),
    }
})

CommonStates.AddWalkStates(states)

return StateGraph("spider_water", states, events, "idle", actionhandlers)
