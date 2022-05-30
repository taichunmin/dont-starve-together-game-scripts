require("stategraphs/commonstates")

local function ChooseAttack(inst, target)
    inst.sg:GoToState("attack", target or inst.components.combat.target)
    return true
end

local function EaseShadow(inst, k)
    inst.DynamicShadow:SetSize(inst.sg.statemem.shadowstart[1] + k * (inst.sg.statemem.shadowend[1] - inst.sg.statemem.shadowstart[1]), inst.sg.statemem.shadowstart[2] + k * (inst.sg.statemem.shadowend[2] - inst.sg.statemem.shadowstart[2]))
end

local function EaseOutShadow(inst, k)
    k = 1 - k
    EaseShadow(inst, 1 - k * k)
end

local function EaseInShadow(inst, k)
    EaseShadow(inst, k * k)
end

local function EaseInOutShadow(inst, k)
    if k <= .5 then
        EaseShadow(inst, 2 * k * k)
    else
        k = 2 - 2 * k
        EaseShadow(inst, 1 - .5 * k * k)
    end
end

local events =
{
    CommonHandlers.OnLocomote(true, true),
    CommonHandlers.OnHop(),
    EventHandler("death", function(inst, data)
        if not inst.sg:HasStateTag("deactivating") then
            inst.sg:GoToState("death", data)
        end
    end),
    EventHandler("doattack", function(inst, data)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            ChooseAttack(inst, data ~= nil and data.target or nil)
        end
    end),
    EventHandler("attacked", function(inst)
        if not inst.components.health:IsDead() and
            (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("caninterrupt")) and
            not CommonHandlers.HitRecoveryDelay(inst) then
            inst.sg:GoToState("hit")
        end
    end),
}

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("idle_loop", true)
        end,
    },

    State{
        name = "idle_nodir",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("idle_loop_nodir")
            inst.sg:SetTimeout(.5)
        end,

        ontimeout = function(inst)
            local t = inst.AnimState:GetCurrentAnimationTime()
            inst.AnimState:PlayAnimation("idle_loop", true)
            inst.AnimState:SetTime(t)
            inst.Transform:SetFourFaced()
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                --V2C: shouldn't happen
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.Transform:SetFourFaced()
        end,
    },

    State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("atk")
            inst.components.combat:StartAttack()
            if target ~= nil and target:IsValid() then
                inst.sg.statemem.target = target
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie_big/vo_atk_pre")
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie_big/attack_pre") end),
            TimeEvent(15 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie_big/attack") end),
            TimeEvent(16 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie_big/vo_atk") end),
            TimeEvent(23 * FRAMES, function(inst)
                local target = inst.sg.statemem.target
                if target == nil or not target:IsValid() then
                    target = inst.components.combat.target
                    if target ~= nil and not target:IsValid() then
                        target = nil
                    end
                end
                if target ~= nil and math.abs(anglediff(inst.Transform:GetRotation(), inst:GetAngleToPoint(target.Transform:GetWorldPosition()))) < 90 then
                    inst.components.combat:DoAttack(target)
                end
            end),
            TimeEvent(38 * FRAMES, function(inst)
                inst.sg:AddStateTag("caninterrupt")
            end),
            TimeEvent(39 * FRAMES, function(inst)
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

    State{
        name = "taunt",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("taunt")
        end,

        timeline =
        {
            TimeEvent(3 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie_big/vo_taunt") end),
            TimeEvent(4 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie_big/taunt") end),
            TimeEvent(16 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie_big/taunt") end),
            TimeEvent(28 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie_big/taunt") end),
            TimeEvent(30 * FRAMES, function(inst)
                inst.sg:AddStateTag("caninterrupt")
            end),
            TimeEvent(40 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie_big/taunt") end),
            TimeEvent(52 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie_big/taunt") end),
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
        name = "hit",
        tags = { "hit", "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie_big/hit")
			CommonHandlers.UpdateHitRecoveryDelay(inst)
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                if inst.components.health:IsDead() then
                    inst.sg:RemoveStateTag("busy")
                elseif not (inst.sg.statemem.doattack and ChooseAttack(inst)) then
                    inst.sg.statemem.doattack = nil
                    inst.sg:RemoveStateTag("busy")
                end
            end),
        },

        events =
        {
            EventHandler("doattack", function(inst)
                inst.sg.statemem.doattack = true
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if not (inst.sg.statemem.doattack and ChooseAttack(inst)) then
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },
    },

    State{
        name = "death",
        tags = { "death", "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("death")
            inst.Transform:SetNoFaced()
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie_big/footstep")
                inst.sg.statemem.shadowstart = { 2.75, 1.3 }
                inst.sg.statemem.shadowend = { 2.75 * .7 + .3, 1.3 * .7 + .5 * .3 }
                EaseInOutShadow(inst, .125)
            end),
            TimeEvent(5 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie_big/vo_death_drop")
                EaseInOutShadow(inst, .25)
            end),
            TimeEvent(6 * FRAMES, function(inst) EaseInOutShadow(inst, .375) end),
            TimeEvent(7 * FRAMES, function(inst) EaseInOutShadow(inst, .5) end),
            TimeEvent(8 * FRAMES, function(inst) EaseInOutShadow(inst, .625) end),
            TimeEvent(9 * FRAMES, function(inst) EaseInOutShadow(inst, .75) end),
            TimeEvent(10 * FRAMES, function(inst) EaseInOutShadow(inst, .875) end),
            TimeEvent(11 * FRAMES, function(inst) inst.DynamicShadow:SetSize(unpack(inst.sg.statemem.shadowend)) end),
            TimeEvent(27 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie_big/death") end),
            TimeEvent(31 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie_big/vo_death_collapse") end),
            TimeEvent(32 * FRAMES, function(inst)
                local temp = inst.sg.statemem.shadowstart
                inst.sg.statemem.shadowstart = inst.sg.statemem.shadowend
                inst.sg.statemem.shadowend = temp
                temp[1], temp[2] = 1, .5
                EaseInShadow(inst, .2)
            end),
            TimeEvent(33 * FRAMES, function(inst) EaseInShadow(inst, .4) end),
            TimeEvent(34 * FRAMES, function(inst) EaseInShadow(inst, .6) end),
            TimeEvent(35 * FRAMES, function(inst) EaseInShadow(inst, .8) end),
            TimeEvent(36 * FRAMES, function(inst) inst.DynamicShadow:SetSize(unpack(inst.sg.statemem.shadowend)) end)
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:GoInactive()
                end
            end),
        },

        onexit = function(inst)
            --V2C: shouldn't happen
            inst.DynamicShadow:SetSize(2.75, 1.3)
            inst.Transform:SetFourFaced()
        end,
    },

    State{
        name = "activate",
        tags = { "busy", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("activate")
            inst.Transform:SetNoFaced()
            inst.sg.statemem.shadowstart = { 1, .5 }
            inst.sg.statemem.shadowend = { .7 + 2.75 * .3, .5 * .7 + 1.3 * .3 }
            inst.DynamicShadow:SetSize(unpack(inst.sg.statemem.shadowstart))
        end,

        timeline =
        {
            TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie_big/activate") end),
            TimeEvent(FRAMES, function(inst) EaseOutShadow(inst, .25) end),
            TimeEvent(2 * FRAMES, function(inst) EaseOutShadow(inst, .5) end),
            TimeEvent(3 * FRAMES, function(inst) EaseOutShadow(inst, .75) end),
            TimeEvent(4 * FRAMES, function(inst) inst.DynamicShadow:SetSize(unpack(inst.sg.statemem.shadowend)) end),
            TimeEvent(15 * FRAMES, function(inst)
                local temp = inst.sg.statemem.shadowstart
                inst.sg.statemem.shadowstart = inst.sg.statemem.shadowend
                inst.sg.statemem.shadowend = temp
                temp[1], temp[2] = (1 + 2.75) * .5, (.5 + 1.3) * .5
                EaseShadow(inst, 1 / 3)
            end),
            TimeEvent(16 * FRAMES, function(inst) EaseShadow(inst, 2 / 3) end),
            TimeEvent(17 * FRAMES, function(inst) inst.DynamicShadow:SetSize(unpack(inst.sg.statemem.shadowend)) end),
            TimeEvent(35 * FRAMES, function(inst)
                local temp = inst.sg.statemem.shadowstart
                inst.sg.statemem.shadowstart = inst.sg.statemem.shadowend
                inst.sg.statemem.shadowend = temp
                temp[1], temp[2] = 2.75, 1.3
                EaseOutShadow(inst, .2)
            end),
            TimeEvent(36 * FRAMES, function(inst)
                EaseOutShadow(inst, .4)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie_big/footstep", nil, .5)
            end),
            TimeEvent(37 * FRAMES, function(inst) EaseOutShadow(inst, .6) end),
            TimeEvent(38 * FRAMES, function(inst) EaseOutShadow(inst, .8) end),
            TimeEvent(39 * FRAMES, function(inst) inst.DynamicShadow:SetSize(unpack(inst.sg.statemem.shadowend)) end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.nodir = true
                    inst.sg:GoToState("idle_nodir")
                end
            end),
        },

        onexit = function(inst)
            inst.DynamicShadow:SetSize(2.75, 1.3)
            if not inst.sg.statemem.nodir then
                inst.Transform:SetFourFaced()
            end
        end,
    },

    State{
        name = "deactivate",
        tags = { "busy", "deactivating", "noattack" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("deactivate")
            inst.Transform:SetNoFaced()
            inst.components.health:SetInvincible(true)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie_big/deactivate")
        end,

        timeline =
        {
            TimeEvent(3 * FRAMES, function(inst)
                inst.sg.statemem.shadowstart = { 2.75, 1.3 }
                inst.sg.statemem.shadowend = { 2.75 * .7 + .3, 1.3 * .7 + .5 * .3 }
                EaseOutShadow(inst, .2)
            end),
            TimeEvent(4 * FRAMES, function(inst) EaseOutShadow(inst, .4) end),
            TimeEvent(5 * FRAMES, function(inst) EaseOutShadow(inst, .6) end),
            TimeEvent(6 * FRAMES, function(inst) EaseOutShadow(inst, .8) end),
            TimeEvent(7 * FRAMES, function(inst) inst.DynamicShadow:SetSize(unpack(inst.sg.statemem.shadowend)) end),
            TimeEvent(18 * FRAMES, function(inst)
                local temp = inst.sg.statemem.shadowstart
                inst.sg.statemem.shadowstart = inst.sg.statemem.shadowend
                inst.sg.statemem.shadowend = temp
                temp[1], temp[2] = 1, .5
                EaseInOutShadow(inst, .2)
            end),
            TimeEvent(19 * FRAMES, function(inst) EaseInOutShadow(inst, .4) end),
            TimeEvent(20 * FRAMES, function(inst) EaseInOutShadow(inst, .6) end),
            TimeEvent(21 * FRAMES, function(inst) EaseInOutShadow(inst, .8) end),
            TimeEvent(22 * FRAMES, function(inst) inst.DynamicShadow:SetSize(unpack(inst.sg.statemem.shadowend)) end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:GoInactive()
                end
            end),
        },

        onexit = function(inst)
            --V2C: shouldn't happen
            inst.DynamicShadow:SetSize(2.75, 1.3)
            inst.Transform:SetFourFaced()
            inst.components.health:SetInvincible(false)
        end,
    },
}

local function DoFootStep(inst)
    if inst.sg:HasStateTag("running") then
        inst.SoundEmitter:PlaySoundWithParams("dontstarve/creatures/together/bernie_big/footstep", { speed = 1 })
    else
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie_big/footstep")
    end
    inst.sg.mem.lastfootstep = GetTime()
end

local function DoStopFootStep(inst)
    local t = GetTime()
    if (inst.sg.mem.lastfootstep or 0) + 7 * FRAMES < t then
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie_big/footstep")
        inst.sg.mem.lastfootstep = t
    end
end

CommonStates.AddWalkStates(states,
{
    starttimeline =
    {
        TimeEvent(0, function(inst)
            if inst.sg.statemem.running then
                DoStopFootStep(inst)
            end
        end),
        TimeEvent(11 * FRAMES, DoFootStep),
    },
    walktimeline =
    {
        TimeEvent(21 * FRAMES, DoFootStep),
        TimeEvent(40 * FRAMES, DoFootStep),
    },
    endtimeline =
    {
        TimeEvent(0, DoStopFootStep),
    },
},
{
    startwalk = function(inst)
        if inst.AnimState:IsCurrentAnimation("run_loop") or inst.AnimState:IsCurrentAnimation("run_pre") then
            inst.sg.statemem.running = true
            return "run_walk_pre"
        end
        return "walk_pre"
    end,
})

CommonStates.AddRunStates(states,
{
    starttimeline =
    {
        TimeEvent(0, function(inst)
            local t = GetTime()
            if (inst.sg.mem.lastfootstep or 0) + 7 * FRAMES < t then
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie_big/footstep", nil, .5)
                inst.sg.mem.lastfootstep = t
            end
            if (inst.sg.mem.lastrunvo or 0) + 3 < t then
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bernie_big/vo_run_start")
                inst.sg.mem.lastrunvo = t
            end
        end),
    },
    runtimeline =
    {
        TimeEvent(11 * FRAMES, DoFootStep),
        TimeEvent(27 * FRAMES, DoFootStep),
    },
    endtimeline =
    {
        TimeEvent(0 * FRAMES, DoStopFootStep),
    },
})

CommonStates.AddHopStates(states, true, {pre = "run_pre", loop = "run_loop", pst = "run_pst"})

return StateGraph("berniebig", states, events, "activate")
