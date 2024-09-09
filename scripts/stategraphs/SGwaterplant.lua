require("stategraphs/commonstates")

local events =
{
    EventHandler("attacked", function(inst, data)
        if inst.components.health ~= nil and not inst.components.health:IsDead()
                and (not inst.sg:HasStateTag("busy")
                    or not inst.sg:HasStateTag("attack")
                    or inst.sg:HasStateTag("caninterrupt")
                    or inst.sg:HasStateTag("frozen")) then
            inst.sg:GoToState("hit")
        end
    end),
    EventHandler("newcombattarget", function(inst, data)
        if inst._stage == 2
                and (inst.components.health ~= nil and not inst.components.health:IsDead())
                and not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("switch_to_flower")
        end
    end),

    EventHandler("spray_cloud", function(inst, data)
        if (inst.components.sleeper == nil or not inst.components.sleeper:IsAsleep())
                and (inst.components.health ~= nil and not inst.components.health:IsDead())
                and not inst.sg:HasStateTag("busy")
                and not inst.sg:HasStateTag("spraying") then
            inst.sg:GoToState("cloud")
        end
    end),

    EventHandler("barnacle_grown", function(inst)
        if (inst.components.health ~= nil and not inst.components.health:IsDead())
                and not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("barnacle_grow")
        end
    end),

    CommonHandlers.OnAttack(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnSleepEx(),
    CommonHandlers.OnWakeEx(),
    CommonHandlers.OnFreezeEx(),
}

local function return_to_idle(inst)
    inst.sg:GoToState("idle")
end

local function on_unfreeze(inst)
    local has_target = inst.components.combat:HasTarget()
    if has_target and inst._stage == 2 then
        inst.sg:GoToState("switch_to_flower")
    elseif not has_target and inst._stage == 3 then
        inst.sg:GoToState("switch_to_bud")
    else
        inst.sg:GoToState(inst.sg.sg.states.hit ~= nil and "hit" or "idle")
    end
end

local states =
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            inst:PlaySyncAnimation((inst._stage == 2 and "idle3") or "idle")
        end,

        timeline=
        {
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dangerous_sea/creatures/water_plant/breath") end),
        },

        events =
        {
            EventHandler("animover", return_to_idle),
        },
    },

    State{
        name = "barnacle_grow",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            inst.base.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dangerous_sea/creatures/water_plant/grow")
            inst.sg:SetTimeout(12*FRAMES)
        end,

        ontimeout = return_to_idle,
    },

    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            if inst._stage ~= 3 then
                inst:GoToStage(3)
            end

            inst:PlaySyncAnimation("death")
        end,

        timeline =
        {
            TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dangerous_sea/creatures/water_plant/death") end),
            TimeEvent(17*FRAMES, function(inst)
                local pos = inst:GetPosition()
                inst.components.lootdropper:DropLoot(pos)

                inst.SoundEmitter:PlaySound("dangerous_sea/creatures/water_plant/pop")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                local pos = inst:GetPosition()
                if inst.components.harvestable ~= nil and inst.components.harvestable.produce > 0 then
                    for p = 1, inst.components.harvestable.produce do
                        local product = (inst.components.burnable:IsBurning() and "barnacle_cooked") or "barnacle"
                        inst.components.lootdropper:SpawnLootPrefab(product, pos)
                    end
                end
                inst.components.lootdropper:SpawnLootPrefab("waterplant_planter", pos)

                inst.SoundEmitter:PlaySound("dangerous_sea/creatures/water_plant/pop_2")

                inst:RevertToRock()
            end),
        }
    },

    State{
        name = "attack",
        tags = {"attack", "canrotate"},

        onenter = function(inst)
            inst:PlaySyncAnimation("attack")
            inst.SoundEmitter:PlaySound("dangerous_sea/creatures/water_plant/attack_pre")
            inst.components.combat:StartAttack()
        end,

        timeline =
        {
            TimeEvent(10*FRAMES, function(inst)
                inst.components.combat:DoAttack()
                inst.SoundEmitter:PlaySound("dangerous_sea/creatures/water_plant/attack")
            end),
        },

        events =
        {
            EventHandler("animover", return_to_idle),
        },
    },

    State{
        name = "switch_to_flower",
        tags = {"busy"},

        onenter = function(inst)
            inst:PlaySyncAnimation("growth2")
        end,

        timeline =
        {
            TimeEvent(9 * FRAMES, function(inst)
                inst:GoToStage(3)
            end),
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dangerous_sea/creatures/water_plant/grow") end),
        },

        events =
        {
            EventHandler("animover", return_to_idle),
        },
    },

    State{
        name = "switch_to_bud",
        tags = {"busy"},

        onenter = function(inst)
            inst:PlaySyncAnimation("growth3")
        end,

        timeline =
        {
            TimeEvent(6 * FRAMES, function(inst)
                inst:GoToStage(2)
            end),
            TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dangerous_sea/creatures/water_plant/close") end),
        },

        events =
        {
            EventHandler("animover", return_to_idle),
        },
    },

    State{
        name = "hit",
        tags = {"busy"},

        onenter = function(inst)
            inst:PlaySyncAnimation("hit")
            inst.SoundEmitter:PlaySound("dangerous_sea/creatures/water_plant/hit")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst._stage == 2 and inst.components.combat:HasTarget() then
                    inst.sg:GoToState("switch_to_flower")
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "sleep",
        tags = {"busy", "sleeping", "nowake"},

        onenter = function(inst)
            inst:PlaySyncAnimation("sleep_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.continuesleeping = true
                    inst.sg:GoToState(inst.sg.mem.sleeping and "sleeping" or "wake")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.continuesleeping and inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep() then
                inst.components.sleeper:WakeUp()
            end
        end,
    },

    State{
        name = "sleeping",
        tags = { "busy", "sleeping" },

        onenter = function(inst)
            inst:PlaySyncAnimation("sleep_loop")
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dangerous_sea/creatures/water_plant/sleep") end),
            TimeEvent(44*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dangerous_sea/creatures/water_plant/sleep") end),
        },


        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.continuesleeping = true
                    inst.sg:GoToState("sleeping")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.continuesleeping and inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep() then
                inst.components.sleeper:WakeUp()
            end
        end,
    },

    State{
        name = "wake",
        tags = { "busy", "waking", "nosleep" },

        onenter = function(inst)
            inst:PlaySyncAnimation("sleep_pst")
            if inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep() then
                inst.components.sleeper:WakeUp()
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg.mem.sleeping then
                        inst.sg:GoToState("sleep")
                    else
                        local has_target = inst.components.combat:HasTarget()
                        if has_target and inst._stage == 2 then
                            inst.sg:GoToState("switch_to_flower")
                        elseif not has_target and inst._stage == 3 then
                            inst.sg:GoToState("switch_to_bud")
                        else
                            inst.sg:GoToState("idle")
                        end
                    end
                end
            end),
        },
    },

    State{
        name = "taunt",
        tags = {"busy", "canrotate"},

        onenter = function(inst)
            inst:PlaySyncAnimation("taunt")
        end,

        timeline =
        {
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dangerous_sea/creatures/water_plant/taunt") end),
        },

        events =
        {
            EventHandler("animover", return_to_idle),
        },
    },

    State{
        name = "frozen",
        tags = { "busy", "frozen" },

        onenter = function(inst)
            inst:PlaySyncAnimation("frozen", true)

            inst.SoundEmitter:PlaySound("dontstarve/common/freezecreature")
            inst.base.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")

            inst.sg.statemem.stage_name = "swap_frozen"..(inst._stage or "")
            inst.AnimState:OverrideSymbol(inst.sg.statemem.stage_name, "frozen", "frozen")

            inst.sg.mem.frozen_withtarget = inst.components.combat:HasTarget()

            if inst.components.freezable:IsThawing() then
                inst.sg:GoToState("thaw")
            elseif not inst.components.freezable:IsFrozen() then
                on_unfreeze(inst)
            end
        end,

        events =
        {
            EventHandler("unfreeze", on_unfreeze),
            EventHandler("onthaw", function(inst)
                inst.sg:GoToState("thaw")
            end),
        },

        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol(inst.sg.statemem.stage_name)
            inst.base.AnimState:ClearOverrideSymbol("swap_frozen")
        end,
    },

    State{
        name = "thaw",
        tags = { "busy", "thawing" },

        onenter = function(inst)
            inst:PlaySyncAnimation("frozen_loop_pst", true)

            inst.SoundEmitter:PlaySound("dontstarve/common/freezethaw", "thawing")
            inst.base.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")

            inst.sg.statemem.stage_name = "swap_frozen"..(inst._stage or "")
            inst.AnimState:OverrideSymbol(inst.sg.statemem.stage_name, "frozen", "frozen")

            --V2C: cuz... freezable component and SG need to match state,
            --     but messages to SG are queued, so it is not great when
            --     when freezable component tries to change state several
            --     times within one frame...
            if inst.components.freezable == nil or not inst.components.freezable:IsFrozen() then
                on_unfreeze(inst)
            end
        end,

        events =
        {
            EventHandler("unfreeze", on_unfreeze),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("thawing")

            inst.AnimState:ClearOverrideSymbol(inst.sg.statemem.stage_name)
            inst.base.AnimState:ClearOverrideSymbol("swap_frozen")
        end,
    },

    State{
        name = "cloud",
        tags = { "canrotate", "spraying" },

        onenter = function(inst)
            inst:PlaySyncAnimation("cloud")

            inst.sg.statemem.was_stage_2 = (inst._stage == 2)
            if not inst.sg.statemem.was_stage_2 then
                inst:GoToStage(2)
            end
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst)
                inst:SpawnCloud()
                inst.SoundEmitter:PlaySound("dangerous_sea/creatures/water_plant/cloud")
            end),
        },

        events =
        {
            EventHandler("animover", return_to_idle),
        },

        onexit = function(inst)
            if not inst.sg.statemem.was_stage_2 and inst._stage == 2 then
                inst:GoToStage(3)
            end
        end,
    },
}

return StateGraph("waterplant", states, events, "idle")
