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

    ActionHandler(ACTIONS.GOHOME, "eat"),
    ActionHandler(ACTIONS.INVESTIGATE, "investigate"),
}

local events =
{
    CommonHandlers.OnHop(),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnSink(),

    EventHandler("attacked", function(inst)
        if not inst.components.health:IsDead() then
            if inst:HasTag("spider_warrior") or inst:HasTag("spider_spitter") or inst:HasTag("spider_moon") then
                if not inst.sg:HasStateTag("attack") then -- don't interrupt attack or exit shield
                    inst.sg:GoToState("hit") -- can still attack
                end
            elseif not inst.sg:HasStateTag("shield") then
                inst.sg:GoToState("hit_stunlock")  -- can't attack during hit reaction
            end
        end
    end),
    EventHandler("doattack", function(inst, data)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            --target CAN go invalid because SG events are buffered
            if inst:HasTag("spider_warrior") then
                inst.sg:GoToState(
                    data.target:IsValid()
                    and not inst:IsNear(data.target, TUNING.SPIDER_WARRIOR_MELEE_RANGE)
                    and "warrior_attack" --Do leap attack
                    or "attack",
                    data.target
                )
            elseif inst:HasTag("spider_spitter") then
                inst.sg:GoToState(
                    data.target:IsValid()
                    and not inst:IsNear(data.target, TUNING.SPIDER_SPITTER_MELEE_RANGE)
                    and "spitter_attack" --Do spit attack
                    or "attack",
                    data.target
                )
			elseif inst:HasTag("spider_moon") then
                inst.sg:GoToState(
                    data.target:IsValid()
                    and not inst:IsNear(data.target, TUNING.SPIDER_WARRIOR_MELEE_RANGE)
                    and "spike_attack"
                    or "attack",
                    data.target
                )
            elseif inst:HasTag("spider_healer") then
                if data.target:IsValid() and
                   (inst.healtime == nil or GetTime() - inst.healtime >= TUNING.SPIDER_HEALING_COOLDOWN) then
                    inst.sg:GoToState("heal", data.target)
                else
                    inst.sg:GoToState("attack", data.target)
                end
            else
                inst.sg:GoToState("attack", data.target)
            end
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
                    inst.sg:GoToState("idle")
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

    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("entershield", function(inst) inst.sg:GoToState("shield") end),
    EventHandler("exitshield", function(inst) inst.sg:GoToState("shield_end") end),
}

local function SoundPath(inst, event)
    local creature = "spider"
    if inst:HasTag("spider_healer") then
        return "webber1/creatures/spider_cannonfodder/" .. event
    elseif inst:HasTag("spider_moon") then
		return "turnoftides/creatures/together/spider_moon/" .. event
    elseif inst:HasTag("spider_warrior") then
        creature = "spiderwarrior"
    elseif inst:HasTag("spider_hider") or inst:HasTag("spider_spitter") then
        creature = "cavespider"
    else
        creature = "spider"
    end
    return "dontstarve/creatures/" .. creature .. "/" .. event
end

local states =
{
    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst.SoundEmitter:PlaySound(SoundPath(inst, "die"))
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
        end,
    },

    State{
        name = "premoving",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk_pre")
        end,

        timeline=
        {
            TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "walk_spider")) end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("moving") end),
        },
    },

    State{
        name = "moving",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PushAnimation("walk_loop")
        end,

        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "walk_spider")) end),
            TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "walk_spider")) end),
            TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "walk_spider")) end),
            TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "walk_spider")) end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("moving") end),
        },
    },

    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        ontimeout = function(inst)
            inst.sg:GoToState("taunt")
        end,

        onenter = function(inst, start_anim)
            inst.Physics:Stop()
            local animname = "idle"
            if math.random() < 0.3 then
                inst.sg:SetTimeout(math.random()*2 + 2)
            end

            if inst:IsLightGreaterThan(1.0) and not inst.bedazzled and not (inst.components.follower and inst.components.follower.leader ~= nil) then
                inst.AnimState:PlayAnimation("cower" )
                inst.AnimState:PushAnimation("cower_loop", true)
            elseif start_anim then
                inst.AnimState:PlayAnimation(start_anim)
                inst.AnimState:PushAnimation("idle", true)
            else
                inst.AnimState:PlayAnimation("idle", true)
            end
        end,
    },

    State{
        name = "eat",
        tags = {"busy"},

        onenter = function(inst, forced)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat")
            inst.sg.statemem.forced = forced
            inst.SoundEmitter:PlaySound(SoundPath(inst, "eat"), "eating")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                local state = (inst:PerformBufferedAction() or inst.sg.statemem.forced) and "eat_loop" or "idle"
                if state == "idle" then
                    inst.SoundEmitter:KillSound("eating")
                end
                inst.sg:GoToState(state)
            end),
        },
    },

    State{
        name = "eat_loop",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat_loop", true)
            inst.sg:SetTimeout(1+math.random()*1)
        end,

        ontimeout = function(inst)
            inst.SoundEmitter:KillSound("eating")
            inst.sg:GoToState("idle", "eat_pst")
        end,
    },

    State{
        name = "born",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("taunt")
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },


    State{
        name = "taunt",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.SoundEmitter:PlaySound(SoundPath(inst, "scream"))
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "investigate",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.SoundEmitter:PlaySound(SoundPath(inst, "scream"))
        end,

        events=
        {
            EventHandler("animover", function(inst)
                inst:PerformBufferedAction()
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
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
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "Attack")) end),
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "attack_grunt")) end),
            TimeEvent(25*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "warrior_attack",
        tags = {"attack", "canrotate", "busy", "jumping"},

        onenter = function(inst, target)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)

            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("warrior_atk")
            inst.sg.statemem.target = target
        end,

        onexit = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            inst.Physics:ClearMotorVelOverride()
        end,

        timeline =
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "attack_grunt")) end),
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "Jump")) end),
            TimeEvent(8*FRAMES, function(inst) inst.Physics:SetMotorVelOverride(20,0,0) end),
            TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "Attack")) end),
            TimeEvent(19*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
            TimeEvent(20*FRAMES,
                function(inst)
                    inst.Physics:ClearMotorVelOverride()
                    inst.components.locomotor:Stop()
                end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("taunt") end),
        },
    },

    State{
        name = "spitter_attack",
        tags = {"attack", "canrotate", "busy", "spitting"},

        onenter = function(inst, target)
            if inst.weapon and inst.components.inventory then
                inst.components.inventory:Equip(inst.weapon)
            end
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("spit")
            inst.sg.statemem.target = target
        end,

        onexit = function(inst)
            if inst.components.inventory then
                inst.components.inventory:Unequip(EQUIPSLOTS.HANDS)
            end
        end,

        timeline =
        {
            TimeEvent(7*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound(SoundPath(inst, "spit_web")) end),

            TimeEvent(21*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst.SoundEmitter:PlaySound(SoundPath(inst, "spit_voice"))
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("taunt") end),
        },
    },

    State{
        name = "spike_attack",
        tags = {"attack", "busy"},

        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("hide")

            inst.sg.statemem.target = target:GetPosition()
        end,

        timeline=
        {
            TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "Attack")) end),
            TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "attack_grunt")) end),
            TimeEvent(14*FRAMES, function(inst) inst:DoSpikeAttack(inst.sg.statemem.target) end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("spike_attack_pst") end),
        },
    },

    State{
        name = "spike_attack_pst",
        tags = {"attack", "busy"},

        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit_shield")
            inst.AnimState:PushAnimation("unhide", false)
        end,

        timeline=
        {
        },

        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "heal",
        tags = {"attack", "busy"},

        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("heal")
        end,

        timeline=
        {
            TimeEvent(30*FRAMES, function(inst)
                
                -- DANY
                --inst.SoundEmitter:PlaySound("SPIDER SMOKE SOUND")

                inst:DoHeal()
            end ),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "hit",

        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },

    State{
        name = "hit_stunlock",
        tags = {"busy"},

        onenter = function(inst)
            inst.SoundEmitter:PlaySound(SoundPath(inst, "hit_response"))
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },

    State{
        name = "shield",
        tags = {"busy", "shield"},

        onenter = function(inst)
            --If taking fire damage, spawn fire effect.
            inst.components.health:SetAbsorptionAmount(TUNING.SPIDER_HIDER_SHELL_ABSORB)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hide")
            inst.AnimState:PushAnimation("hide_loop")
        end,

        onexit = function(inst)
            inst.components.health:SetAbsorptionAmount(0)
        end,
    },

    State{
        name = "shield_end",
        tags = {"busy", "shield"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("unhide")
        end,

        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },

    State{
        name = "dropper_enter",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("enter")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/descend")
        end,

        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("taunt") end),
        },
    },

    State{
        name = "trapped",
        tags = { "busy", "trapped" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("cower")
            inst.AnimState:PushAnimation("cower_loop", true)
            inst.sg:SetTimeout(1)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "mutate",
        tags = {"busy", "mutating"},

        onenter = function(inst, start_anim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("mutate_pre")
            inst.SoundEmitter:PlaySound(SoundPath(inst, "eat"), "eating")
        end,


        timeline=
        {
            TimeEvent(15*FRAMES, function(inst) 
                inst.SoundEmitter:KillSound("eating")
                inst.SoundEmitter:PlaySound("webber2/common/mutate") 
            end),
        },

        events=
        {
            EventHandler("animover", function(inst) 
                local x,y,z = inst.Transform:GetWorldPosition()        
                local fx = SpawnPrefab("spider_mutate_fx")
                fx.Transform:SetPosition(x,y,z)

                inst:DoTaskInTime(0.25, function() 

                    inst.components.inventory:DropEverything()

                    local new_spider = SpawnPrefab(inst.mutation_target)
                    if new_spider then
                        local x,y,z = inst.Transform:GetWorldPosition()
                        new_spider.Transform:SetPosition(x,y,z)

                        if inst.components.follower.leader ~= nil then
                            new_spider.components.follower:SetLeader(inst.components.follower.leader)
                        elseif inst.mutator_giver ~= nil then
                            new_spider.components.follower:SetLeader(inst.mutator_giver)
                        end

                        if inst.components.combat:HasTarget() then
                            new_spider.components.combat:SetTarget(inst.components.combat.target)
                        end

                        new_spider.sg:GoToState("mutate_pst")

                        inst:Remove()
                    end
                end)
            end),
        },
    },

    State{
        name = "mutate_pst",
        tags = {"busy", "mutating"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("mutate_pst")
        end,

        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
}

CommonStates.AddSleepStates(states,
{
    starttimeline = {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "fallAsleep")) end ),
    },
    sleeptimeline =
    {
        TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "sleeping")) end ),
    },
    waketimeline = {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "wakeUp")) end ),
    },
})

CommonStates.AddFrozenStates(states)
CommonStates.AddHopStates(states, true, { pre = "boat_jump_pre", loop = "boat_jump", pst = "boat_jump_pst"})
CommonStates.AddSinkAndWashAsoreStates(states)

return StateGraph("spider", states, events, "idle", actionhandlers)
