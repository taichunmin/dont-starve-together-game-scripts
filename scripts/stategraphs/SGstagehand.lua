require("stategraphs/commonstates")

local function onworked(inst)
    local mem = inst.sg.mem
    local cur_time = GetTime()

    -- if the player stops working it then the stagehand will reset
    if mem.prevtimeworked == nil or ((cur_time - mem.prevtimeworked) > (TUNING.SEG_TIME * 0.5)) then
        mem.hits_left = TUNING.STAGEHAND_HITS_TO_GIVEUP
    end

    -- it now takes 86 hits, instead of work done, in order to '86' the blueprint
    mem.hits_left = (mem.hits_left and (mem.hits_left) or TUNING.STAGEHAND_HITS_TO_GIVEUP) - 1
    if not inst.sg:HasStateTag("givingup") then
        inst.sg:GoToState( mem.hits_left > 0 and "hit" or "giveup")
    end
    mem.prevtimeworked = cur_time
end

local events =
{
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("worked", onworked),
    EventHandler("onignite", function(inst) inst.sg:GoToState("extinguish") end),
    EventHandler("locomote", function(inst)
        local is_moving = inst.sg:HasStateTag("moving")
        local is_idling = inst.sg:HasStateTag("idle")
        local is_busy = inst.sg:HasStateTag("busy")
        local should_move = inst.components.locomotor:WantsToMoveForward()
        if is_moving and not should_move then
            inst.sg:GoToState("walk_stop")
        elseif should_move and not is_moving and is_idling then
            if inst.sg.mem.is_hiding then
                inst.sg:GoToState("standup")
            elseif not is_busy then
                inst.sg:GoToState("walk_start")
            end
        end
    end),
}

local function OnHide(inst)
    inst.components.locomotor:StopMoving()
    inst.Physics:Stop()
    inst.sg.mem.is_hiding = true
    inst:ChangePhysics(false)
end

local states =
{
    State{
        name = "initialstate",

        onenter = function(inst)
            inst.sg.mem.is_hiding = true
            inst:ChangePhysics(false)
            inst.sg:GoToState("idle_hiding")
        end,
    },

    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)

            local pos = inst:GetPosition()
            inst.components.lootdropper:DropLoot(pos)
            inst:Remove()

            local fx = SpawnPrefab("collapse_small")
            fx.Transform:SetPosition(pos:Get())
            fx:SetMaterial("pot")
        end,
    },

    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            if inst.components.burnable:IsBurning() then
                inst.sg:GoToState("extinguish")
            elseif not (inst:CanStandUp() or inst.components.locomotor:WantsToMoveForward()) then
                inst.sg:GoToState("idle_hiding")
            elseif inst.sg.mem.is_hiding then
                inst.sg:GoToState("standup")
            else
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("awake_idle")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "idle_hiding",
        tags = { "idle", "hiding" },

        onenter = function(inst)
            if not inst.sg.mem.is_hiding then
                inst.sg:GoToState("hide")
                return
            end

            inst.Physics:Stop()

            if TheWorld.state.isdusk then
                local chance = math.random()
                inst.AnimState:PlayAnimation(
                    (chance < .02 and "peeking_idle_loop_01") or
                    (chance < .04 and "peeking_idle_loop_02") or
                    "idle_loop_01"
                )
            elseif TheWorld.state.isnight then
                local chance = math.random()
                inst.AnimState:PlayAnimation(
                    (chance < .2 and "peeking_idle_loop_01") or
                    (chance < .4 and "peeking_idle_loop_02") or
                    "idle_loop_01"
                )
            else
                inst.AnimState:PlayAnimation("idle_loop_01")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "hide",
        tags = { "busy" },

        onenter = function(inst)
            OnHide(inst)
            inst.AnimState:PlayAnimation("sleep")
        end,

        timeline =
        {
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.awake_pre) end),
            TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.hit) end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "standup",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("awake_pre")
        end,

        timeline =
        {
            TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.hit) end),
            TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.awake_pre) end),
            TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.footstep) end),
            TimeEvent(22*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.footstep) end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.mem.is_hiding = false
                    inst:ChangePhysics(true)
                    inst.sg:GoToState(inst.components.locomotor:WantsToMoveForward() and "walk_start" or "idle")
                end
            end),
        },
    },

    State{
        name = "hit",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation(inst.sg.mem.is_hiding and "hit" or "awake_hit")
            inst.SoundEmitter:PlaySound(inst.sounds.hit)
        end,

        timeline =
        {
            TimeEvent(0*FRAMES, function(inst)
                if not inst.sg.mem.is_hiding then
                    inst.SoundEmitter:PlaySound(inst.sounds.hit)
                end
            end),
            TimeEvent(3*FRAMES, function(inst)
                if inst.sg.mem.is_hiding then
                    inst.SoundEmitter:PlaySound(inst.sounds.hit)
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "extinguish",
        tags = { "busy" },

        onenter = function(inst)
            if not inst.sg.mem.is_hiding then
                inst.sg:GoToState("hide")
                return
            end

            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("extinguish")
        end,

        timeline =
        {
            TimeEvent(20*FRAMES, function(inst)
                inst.components.burnable:Extinguish()
            end),
            TimeEvent(28*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.hit) end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "giveup",
        tags = { "busy", "givingup" },

        onenter = function(inst)
            inst.components.workable:SetWorkable(false)
            if inst.sg.mem.is_hiding then
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("extinguish")
            else
                OnHide(inst)
                inst.AnimState:PlayAnimation("sleep")
                inst.AnimState:PushAnimation("extinguish", false)
                inst.sg.statemem.hide_delay = true
            end
        end,

        timeline =
        {
            TimeEvent(10*FRAMES, function(inst) if inst.sg.statemem.hide_delay then inst.SoundEmitter:PlaySound(inst.sounds.awake_pre) end end),
            TimeEvent(15*FRAMES, function(inst) if inst.sg.statemem.hide_delay then inst.SoundEmitter:PlaySound(inst.sounds.hit) end end),
            TimeEvent(31*FRAMES, function(inst) if inst.sg.statemem.hide_delay then inst.SoundEmitter:PlaySound(inst.sounds.awake_pre) end end),
            TimeEvent((14+31)*FRAMES, function(inst)
                if inst.sg.statemem.hide_delay then
                    inst.components.lootdropper:SpawnLootPrefab("endtable_blueprint", inst:GetPosition())
                end
            end),
            TimeEvent((28+31)*FRAMES, function(inst) if inst.sg.statemem.hide_delay then inst.SoundEmitter:PlaySound(inst.sounds.hit) end end),

            TimeEvent(6*FRAMES, function(inst) if not inst.sg.statemem.hide_delay then inst.SoundEmitter:PlaySound(inst.sounds.awake_pre) end end),
            TimeEvent(14*FRAMES, function(inst)
                if not inst.sg.statemem.hide_delay then
                    inst.components.lootdropper:SpawnLootPrefab("endtable_blueprint", inst:GetPosition())
                end
            end),
            TimeEvent(28*FRAMES, function(inst) if not inst.sg.statemem.hide_delay then inst.SoundEmitter:PlaySound(inst.sounds.hit) end end),
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
            inst.sg.mem.hits_left = TUNING.STAGEHAND_HITS_TO_GIVEUP
            inst.components.workable:SetWorkable(true)
        end,
    },
}

CommonStates.AddWalkStates(states,
{
    starttimeline =
    {
        TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.footstep) end),
    },

    walktimeline =
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.footstep) end),
        TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.footstep) end),
        TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.footstep) end),
        TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.footstep) end),
    },

    endtimeline =
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.footstep) end),
        TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.footstep) end),
    },
})

return StateGraph("stagehand", states, events, "initialstate")
