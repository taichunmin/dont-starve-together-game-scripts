require("stategraphs/commonstates")

local ENTERWORLD_TARGET_CANT_TAGS = { "INLIMBO" }
local ENTERWORLD_TARGET_ONEOF_TAGS = { "CHOP_workable", "DIG_workable", "HAMMER_workable", "MINE_workable" }
local ENTERWORLD_TOSS_MUST_TAGS = { "_inventoryitem" }
local ENTERWORLD_TOSS_CANT_TAGS = { "locomotor", "INLIMBO" }
local ENTERWORLD_TOSSFLOWERS_MUST_TAGS = { "flower", "pickable" }

local function ShakeIfClose(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, .5, .02, .15, inst, 30)
end

local function ShakeCasting(inst)
    ShakeAllCameras(CAMERASHAKE.VERTICAL, .3, .02, 1, inst, 30)
end

local function SproutLaunch(inst, launcher, basespeed)
    local x0, y0, z0 = launcher.Transform:GetWorldPosition()
    local x1, y1, z1 = inst.Transform:GetWorldPosition()
    local dx, dz = x1 - x0, z1 - z0
    local dsq = dx * dx + dz * dz
    local angle
    if dsq > 0 then
        local dist = math.sqrt(dsq)
        angle = math.atan2(dz / dist, dx / dist) + (math.random() * 20 - 10) * DEGREES
    else
        angle = TWOPI * math.random()
    end
    local speed = basespeed + math.random()
    inst.Physics:Teleport(x1, .1, z1)
    inst.Physics:SetVel(math.cos(angle) * speed, speed * 4 + math.random() * 2, math.sin(angle) * speed)
end

local function CanGoToActionState(inst)
    if not inst.sg:HasStateTag("busy") or
        inst.sg:HasStateTag("caninterrupt") or
        inst.sg:HasStateTag("frozen") or
        inst.sg:HasStateTag("thawing") then
        --Just break out of freezing! This is bonus support...
        --Nothing should freeze it normally outside of combat.
        inst.components.freezable:Unfreeze()
        return true
    end
    --Force wake up to perform queued action.
    inst.components.sleeper:WakeUp()
    return false
end

local function TryActionState(inst)
    if inst:HasRewardToGive() then
        inst.sg:GoToState("trinkettribute")
    elseif inst.sg.mem.queueleaveworld then
        inst.sg:GoToState("leaveworld")
    elseif inst.sg.mem.wantstofightdata ~= nil then
        inst.sg:GoToState("fighttribute", inst.sg.mem.wantstofightdata)
    elseif inst.sg.mem.causingsinkholes then
        inst.sg:GoToState("sinkhole_pre")
    else
        return false
    end
    return true
end

local function _OnNoSleepEvent(event, nextstate)
    return EventHandler(event, function(inst)
        if inst.AnimState:AnimDone() then
            if TryActionState(inst) then
                return
            elseif inst.sg.mem.sleeping then
                inst.sg:GoToState("sleep")
            elseif type(nextstate) == "string" then
                inst.sg:GoToState(nextstate)
            elseif nextstate ~= nil then
                nextstate(inst)
            end
        end
    end)
end

local function _OnNoSleepAnimOver(nextstate)
    return _OnNoSleepEvent("animover", nextstate)
end

local function _OnNoSleepAnimQueueOver(nextstate)
    return _OnNoSleepEvent("animqueueover", nextstate)
end

local function _OnNoSleepTimeEvent(t, fn)
    return TimeEvent(t, function(inst)
        if TryActionState(inst) then
            return
        elseif inst.sg.mem.sleeping then
            inst.sg:GoToState("sleep")
        elseif fn ~= nil then
            fn(inst)
        end
    end)
end

local events =
{
    CommonHandlers.OnFreezeEx(),
    CommonHandlers.OnSleepEx(),
    CommonHandlers.OnWakeEx(),
    EventHandler("onacceptfighttribute", function(inst, data)
        --set this always, used by prefab
        inst.sg.mem.wantstofightdata = { target = data.tributer, trigger = data.trigger }
        if CanGoToActionState(inst) then
            inst.sg:GoToState("fighttribute", inst.sg.mem.wantstofightdata)
        end
    end),
    EventHandler("onaccepttribute", function(inst, data)
        if CanGoToActionState(inst) then
            if inst:HasRewardToGive() then
                inst.sg:GoToState("trinkettribute")
            else
                inst.sg:GoToState("rocktribute", data)
            end
        end
    end),
    EventHandler("onrefusetribute", function(inst, data)
        if CanGoToActionState(inst) then
            inst.sg:GoToState("refusetribute", data)
        end
    end),
    EventHandler("antlion_leaveworld", function(inst, data)
        if not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("leaveworld", data)
        else
            inst.sg.mem.queueleaveworld = true
        end
    end),
    EventHandler("onsinkholesstarted", function(inst, data)
        inst.sg.mem.causingsinkholes = true
        if CanGoToActionState(inst) then
            inst.sg:GoToState("sinkhole_pre", data)
        end
    end),
    EventHandler("onsinkholesfinished", function(inst, data)
        inst.sg.mem.causingsinkholes = false
    end),
}

local states =
{
    State{
        name = "idle",
        tags = { "idle" },

        onenter = function(inst, loopcount)
            loopcount = (loopcount or 0) + 1

            if TryActionState(inst) then
                return
            elseif loopcount <= 5 or math.random() < .5 then
                inst.sg.statemem.loopcount = loopcount
                inst.AnimState:PlayAnimation("idle")
            elseif inst:GetRageLevel() < 3 then
                inst.AnimState:PlayAnimation("lookaround")
            else
                inst.sg:GoToState("idle_unhappy")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle", inst.sg.statemem.loopcount)
                end
            end),
        },
    },

    State{
        name = "idle_unhappy",
        tags = { "idle" },

        onenter = function(inst, loopcount)
            inst.AnimState:PlayAnimation("taunt")
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/taunt") end),
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
        name = "rocktribute",
        tags = { "busy", "nosleep", "nofreeze" },

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("eat")
            inst.sg.statemem.tributepercent = data ~= nil and data.tributepercent or 0
        end,

        timeline =
        {
            TimeEvent(12 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/eat") end),
            TimeEvent(36 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/eat") end),
            TimeEvent(71 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/swallow") end),
            _OnNoSleepTimeEvent(85 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nosleep")
                inst.sg:RemoveStateTag("nofreeze")
            end),
        },

        events =
        {
            _OnNoSleepAnimOver(function(inst)
                inst.sg:GoToState(inst:GetRageLevel() <= 1 and "hightributeresponse" or "idle")
            end),
        },
    },

    State{
        name = "hightributeresponse",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("full_pre")
            inst.AnimState:PushAnimation("full_loop", false)
            inst.AnimState:PushAnimation("full_pst", false)
        end,

        timeline =
        {
            TimeEvent(0, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/purr")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/rub")
            end),
            TimeEvent(16 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/rub") end),
            TimeEvent(30 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/rub") end),
            TimeEvent(46 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/rub") end),
            TimeEvent(76 * FRAMES, function(inst)
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
    },

    State{
        name = "refusetribute",
        tags = { "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("unimpressed")
        end,

        timeline =
        {
            _OnNoSleepTimeEvent(48 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nosleep")
                inst.sg:RemoveStateTag("nofreeze")
            end),
            TimeEvent(54 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/unimpressed") end),
        },

        events =
        {
            _OnNoSleepAnimOver("idle"),
        },
    },

    State{
        name = "trinkettribute",
        tags = { "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("eat_talisman")
            inst.AnimState:PushAnimation("spit_talisman", false)
        end,

        timeline =
        {
            TimeEvent(21 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/swallow") end),
            TimeEvent(44 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/unimpressed") end),
            TimeEvent(80 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/spit")
                inst:GiveReward()
            end),
            _OnNoSleepTimeEvent(98 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nosleep")
                inst.sg:RemoveStateTag("nofreeze")
            end),
        },

        events =
        {
            _OnNoSleepAnimQueueOver("idle"),
        },
    },

    State{
        name = "fighttribute",
        tags = { "busy", "nosleep", "nofreeze" },

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("eat_talisman")
            if data ~= nil then
                inst.sg.statemem.target = data.target
                inst.sg.statemem.trigger = data.trigger
            end
        end,

        timeline =
        {
            TimeEvent(21 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/swallow") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.components.sleeper:WakeUp()
                inst.components.freezable:Unfreeze()
                inst:StartCombat(inst.sg.statemem.target, inst.sg.statemem.trigger)
            end),
        },
    },

    State{
        name = "enterworld",
        tags = { "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("enter")
            inst.sg.statemem.spawnpos = inst:GetPosition()

            for i, v in ipairs(TheSim:FindEntities(inst.sg.statemem.spawnpos.x, 0, inst.sg.statemem.spawnpos.z, 2, nil, ENTERWORLD_TARGET_CANT_TAGS, ENTERWORLD_TARGET_ONEOF_TAGS )) do
                v.components.workable:Destroy(inst)
                if v:IsValid() and v:HasTag("stump") then
                    v:Remove()
                end
            end

            local totoss = TheSim:FindEntities(inst.sg.statemem.spawnpos.x, 0, inst.sg.statemem.spawnpos.z, 1.5, ENTERWORLD_TOSS_MUST_TAGS, ENTERWORLD_TOSS_CANT_TAGS)

            --toss flowers out of the way
            for i, v in ipairs(TheSim:FindEntities(inst.sg.statemem.spawnpos.x, 0, inst.sg.statemem.spawnpos.z, 1.5, ENTERWORLD_TOSSFLOWERS_MUST_TAGS)) do
                local loot = v.components.pickable.product ~= nil and SpawnPrefab(v.components.pickable.product) or nil
                if loot ~= nil then
                    loot.Transform:SetPosition(v.Transform:GetWorldPosition())
                    table.insert(totoss, loot)
                end
                v:Remove()
            end

            --toss stuff out of the way
            for i, v in ipairs(totoss) do
                if v:IsValid() then
                    if v.components.mine ~= nil then
                        v.components.mine:Deactivate()
                    end
                    if not v.components.inventoryitem.nobounce and v.Physics ~= nil and v.Physics:IsActive() then
                        SproutLaunch(v, inst, 1.5)
                    end
                end
            end

            inst.Physics:SetMass(999999)
            inst.Physics:CollidesWith(COLLISION.WORLD)
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/sfx/break_spike") end),
        },

        events =
        {
            _OnNoSleepAnimOver("idle"),
        },

        onexit = function(inst)
            inst.Physics:SetMass(0)
            inst.Physics:ClearCollisionMask()
            inst.Physics:CollidesWith(COLLISION.ITEMS)
            inst.Physics:CollidesWith(COLLISION.CHARACTERS)
            inst.Physics:CollidesWith(COLLISION.GIANTS)
            inst.Physics:Teleport(inst.sg.statemem.spawnpos:Get())
        end,
    },

    State{
        name = "leaveworld",
        tags = { "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("out")
        end,

        timeline =
        {
            TimeEvent(28 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/sfx/break_spike") end),
            TimeEvent(35 * FRAMES, function(inst)
                inst.Physics:SetActive(false)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:Remove()
                end
            end),
        },

        onexit = function(inst)
            --Should NOT reach here, but just in case
            inst.Physics:SetActive(true)
        end,
    },

    State{
        name = "sinkhole_pre",
        tags = { "busy", "attack", "nosleep", "nofreeze" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("cast_pre")
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/cast_pre") end),
            TimeEvent(25.5 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/cast_post") end),
            TimeEvent(29 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/sfx/ground_break") end),
            TimeEvent(32 * FRAMES, ShakeCasting),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState(inst.sg.mem.causingsinkholes and "sinkhole_loop" or "sinkhole_pst")
                end
            end),
        },
    },

    State{
        name = "sinkhole_loop",
        tags = { "busy", "attack", "nosleep", "nofreeze" },

        onenter = function(inst, lastloop)
            inst.AnimState:PlayAnimation("cast_loop_active")
            inst.sg.statemem.lastloop = lastloop
        end,

        timeline =
        {
            TimeEvent(28 * FRAMES, function(inst)
                ShakeCasting(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/cast_pre")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/sfx/ground_break")
            end),
            TimeEvent(69 * FRAMES, function(inst)
                ShakeCasting(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/cast_pre")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/sfx/ground_break")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg.statemem.lastloop then
                        inst.sg:GoToState("sinkhole_pst")
                    else
                        inst.sg:GoToState("sinkhole_loop", not inst.sg.mem.causingsinkholes)
                    end
                end
            end),
        },
    },

    State{
        name = "sinkhole_pst",
        tags = { "busy", "attack", "nosleep", "nofreeze" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("cast_pst")
        end,

        timeline =
        {
            _OnNoSleepTimeEvent(10 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nosleep")
                inst.sg:RemoveStateTag("nofreeze")
            end),
        },

        events =
        {
            _OnNoSleepAnimOver("idle"),
        },
    },

    --For unfreezing
    State{
        name = "hit",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/hit")
        end,

        timeline =
        {
            TimeEvent(14 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
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
}

CommonStates.AddSleepExStates(states,
{
    starttimeline =
    {
        TimeEvent(45 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("caninterrupt")
        end),
        TimeEvent(46 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/bodyfall_death") end),
        TimeEvent(48 * FRAMES, ShakeIfClose),
    },
    sleeptimeline =
    {
        TimeEvent(7 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/sleep_in") end),
        TimeEvent(40 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/sleep_out") end),
    },
    waketimeline =
    {
        CommonHandlers.OnNoSleepTimeEvent(23 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("busy")
            inst.sg:RemoveStateTag("nosleep")
        end),
    },
},
{
    onsleep = function(inst)
        inst.sg:AddStateTag("caninterrupt")
    end,
})

CommonStates.AddFrozenStates(states)

return StateGraph("antlion", states, events, "idle")
