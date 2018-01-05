require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.HAMMER, "attack"),
    ActionHandler(ACTIONS.GOHOME, "taunt"),
}

local SHAKE_DIST = 40

local function DeerclopsFootstep(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/step")
    ShakeAllCameras(CAMERASHAKE.VERTICAL, .5, .03, 1, inst, SHAKE_DIST)
end

local function SetLightValue(inst, val)
    if inst.Light ~= nil then
        inst.Light:SetIntensity(.6 * val * val)
        inst.Light:SetRadius(8 * val)
        inst.Light:SetFalloff(3 * val)
    end
end

local function SetLightValueAndOverride(inst, val, override)
    if inst.Light ~= nil then
        inst.Light:SetIntensity(.6 * val * val)
        inst.Light:SetRadius(8 * val)
        inst.Light:SetFalloff(3 * val)
        inst.AnimState:SetLightOverride(override)
    end
end

local function SetLightColour(inst, val)
    if inst.Light ~= nil then
        inst.Light:SetColour(val, 0, 0)
    end
end

local function DoSpawnIceSpike(inst, x, z)
    SpawnPrefab("icespike_fx_"..tostring(math.random(1, 4))).Transform:SetPosition(x, 0, z)
end

local function SpawnIceFx(inst, target)
    if target == nil or not target:IsValid() then
        return
    end
    local numFX = math.random(15, 20)
    local x, y, z = inst.Transform:GetWorldPosition()
    local x1, y1, z1 = target.Transform:GetWorldPosition()
    local dx, dz = x1 - x, z1 - z
    local dist = dx * dx + dz * dz
    if dist > 0 then
        dist = math.sqrt(dist)
        dx, dz = dx / dist, dz / dist
    end
    for i = 1, numFX do
        local offset = GetRandomMinMax(dist * .25, dist)
        inst:DoTaskInTime(math.random() * .25, DoSpawnIceSpike, x + dx * offset + GetRandomWithVariance(0, 3), z + dz * offset + GetRandomWithVariance(0, 3))
    end
end

local function SpawnLaser(inst)
    local numsteps = 10
    local x, y, z = inst.Transform:GetWorldPosition()
    local angle = (inst.Transform:GetRotation() + 90) * DEGREES
    local step = .75
    local offset = 2 - step --should still hit players right up against us
    local ground = TheWorld.Map
    local targets, skiptoss = {}, {}
    local i = -1
    local noground = false
    local fx, dist, delay, x1, z1
    while i < numsteps do
        i = i + 1
        dist = i * step + offset
        delay = math.max(0, i - 1)
        x1 = x + dist * math.sin(angle)
        z1 = z + dist * math.cos(angle)
        if not ground:IsPassableAtPoint(x1, 0, z1) then
            if i <= 0 then
                return
            end
            noground = true
        end
        fx = SpawnPrefab(i > 0 and "deerclops_laser" or "deerclops_laserempty")
        fx.caster = inst
        fx.Transform:SetPosition(x1, 0, z1)
        fx:Trigger(delay * FRAMES, targets, skiptoss)
        if i == 0 then
            ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, .6, fx, 30)
        end
        if noground then
            break
        end
    end

    if i < numsteps then
        dist = (i + .5) * step + offset
        x1 = x + dist * math.sin(angle)
        z1 = z + dist * math.cos(angle)
    end
    fx = SpawnPrefab("deerclops_laser")
    fx.Transform:SetPosition(x1, 0, z1)
    fx:Trigger((delay + 1) * FRAMES, targets, skiptoss)

    fx = SpawnPrefab("deerclops_laser")
    fx.Transform:SetPosition(x1, 0, z1)
    fx:Trigger((delay + 2) * FRAMES, targets, skiptoss)
end

local function EnableEightFaced(inst)
    if not inst.sg.mem.eightfaced then
        inst.sg.mem.eightfaced = true
        inst.Transform:SetEightFaced()
    end
end

local function DisableEightFaced(inst)
    if inst.sg.mem.eightfaced then
        inst.sg.mem.eightfaced = false
        inst.Transform:SetFourFaced()
    end
end

local events =
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),

    EventHandler("doattack", function(inst, data)
        if inst.components.health ~= nil and not inst.components.health:IsDead()
            and (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("hit")) then
            if inst.components.timer == nil then
                --normal deerclops has no laserbeam
                inst.sg:GoToState("attack")
            else
                local target = data ~= nil and data.target or inst.components.combat.target
                local isfrozen, shouldfreeze = false, false
                if target ~= nil then
                    if not target:IsValid() then
                        target = nil
                    elseif target.components.freezable ~= nil then
                        if target.components.freezable:IsFrozen() then
                            isfrozen = true
                        elseif target.components.freezable:ResolveResistance() - target.components.freezable.coldness <= 2 then
                            shouldfreeze = true
                        end
                    end
                end
                if isfrozen or not (shouldfreeze or inst.components.timer:TimerExists("laserbeam_cd")) then
                    inst.sg:GoToState("laserbeam", target)
                else
                    inst.sg:GoToState("attack")
                end
            end
        end
    end),
}

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, pushanim)
            inst.components.locomotor:StopMoving()

            --pushanim could be bool or string?
            if pushanim then
                if type(pushanim) == "string" then
                    inst.AnimState:PlayAnimation(pushanim)
                end
                inst.AnimState:PushAnimation("idle_loop", true)
            elseif not inst.AnimState:IsCurrentAnimation("idle_loop") then
                inst.AnimState:PlayAnimation("idle_loop", true)
            end
        end,

        onexit = DisableEightFaced,
    },

    State{
        name = "gohome",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst:ClearBufferedAction()
            inst.components.knownlocations:RememberLocation("home", nil)
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/taunt_grrr") end),
            TimeEvent(16 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/taunt_howl") end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "taunt",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")

            if inst.bufferedaction and inst.bufferedaction.action == ACTIONS.GOHOME then
                inst:PerformBufferedAction()
            end
        end,

        onupdate = function(inst)
            if inst.sg.statemem.lightval ~= nil then
                inst.sg.statemem.lightval = inst.sg.statemem.lightval * .99
                SetLightValue(inst, inst.sg.statemem.lightval)
            end
        end,

        timeline =
        {
            TimeEvent(2 * FRAMES, function(inst) SetLightColour(inst, .9) end),
            TimeEvent(3 * FRAMES, function(inst) SetLightColour(inst, .87) end),
            TimeEvent(4 * FRAMES, function(inst) SetLightColour(inst, .845) end),
            TimeEvent(5 * FRAMES, function(inst)
                SetLightColour(inst, .825)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/taunt_grrr")
            end),
            TimeEvent(6 * FRAMES, function(inst) SetLightColour(inst, .81) end),
            TimeEvent(7 * FRAMES, function(inst) SetLightColour(inst, .8) end),
            TimeEvent(13 * FRAMES, function(inst)
                inst.sg.statemem.lightval = 1
            end),
            TimeEvent(16 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/taunt_howl")
            end),
            TimeEvent(24 * FRAMES, function(inst)
                inst.sg.statemem.lightval = nil
            end),
            TimeEvent(41 * FRAMES, function(inst)
                SetLightValue(inst, .98)
                SetLightColour(inst, .95)
            end),
            TimeEvent(42 * FRAMES, function(inst)
                SetLightValue(inst, 1)
                SetLightColour(inst, 1)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },

        onexit = function(inst)
            SetLightValue(inst, 1)
            SetLightColour(inst, 1)
        end,
    },

    State{
        name = "laserbeam",
        tags = { "busy" },

        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk2")
            EnableEightFaced(inst)
            if target ~= nil and target:IsValid() then
                if inst.components.combat:TargetIs(target) then
                    inst.components.combat:StartAttack()
                end
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
                inst.sg.statemem.target = target
            end
            inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/charge")
            inst.components.timer:StopTimer("laserbeam_cd")
            inst.components.timer:StartTimer("laserbeam_cd", TUNING.DEERCLOPS_ATTACK_PERIOD * (math.random(3) - .5))
        end,

        onupdate = function(inst)
            if inst.sg.statemem.target ~= nil then
                if inst.sg.statemem.target:IsValid() then
                    local x, y, z = inst.Transform:GetWorldPosition()
                    local x1, y1, z1 = inst.sg.statemem.target.Transform:GetWorldPosition()
                    local dx, dz = x1 - x, z1 - z
                    if dx * dx + dz * dz < 256 and math.abs(anglediff(inst.Transform:GetRotation(), math.atan2(-dz, dx) / DEGREES)) < 45 then
                        inst:ForceFacePoint(x1, y1, z1)
                        return
                    end
                end
                inst.sg.statemem.target = nil
            end
            if inst.sg.statemem.lightval ~= nil then
                inst.sg.statemem.lightval = inst.sg.statemem.lightval * .99
                SetLightValueAndOverride(inst, inst.sg.statemem.lightval, (inst.sg.statemem.lightval - 1) * 3)
            end
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/attack", nil) end),
            TimeEvent(4 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/step", nil, .7) end),
            TimeEvent(6 * FRAMES, function(inst)
                ShakeAllCameras(CAMERASHAKE.VERTICAL, .2, .02, .5, inst, SHAKE_DIST)
                SetLightValue(inst, .97)
            end),
            TimeEvent(7 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1, .2) end),
            TimeEvent(8 * FRAMES, function(inst) SetLightValueAndOverride(inst, .99, .15) end),
            TimeEvent(9 * FRAMES, function(inst) SetLightValueAndOverride(inst, .97, .05) end),
            TimeEvent(10 * FRAMES, function(inst) SetLightValueAndOverride(inst, .96, 0) end),
            TimeEvent(11 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1.01, .35) end),
            TimeEvent(12 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1, .3) end),
            TimeEvent(13 * FRAMES, function(inst) SetLightValueAndOverride(inst, .95, .05) end),
            TimeEvent(14 * FRAMES, function(inst) SetLightValueAndOverride(inst, .94, 0) end),
            TimeEvent(15 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1, .3) end),
            TimeEvent(16 * FRAMES, function(inst) SetLightValueAndOverride(inst, .99, .25) end),
            TimeEvent(17 * FRAMES, function(inst) SetLightValueAndOverride(inst, .92, .05) end),
            TimeEvent(18 * FRAMES, function(inst)
                SetLightValueAndOverride(inst, .9, 0)
                inst.sg.statemem.target = nil
                inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/taunt_howl", nil, .4)
            end),
            TimeEvent(19 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/laser")
                SpawnLaser(inst)
                SetLightValueAndOverride(inst, 1.08, .7)
            end),
            TimeEvent(20 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1.12, 1) end),
            TimeEvent(21 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1.1, .9) end),
            TimeEvent(22 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1.06, .4) end),
            TimeEvent(23 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1.1, .6) end),
            TimeEvent(24 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1.06, .3) end),
            TimeEvent(25 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1.05, .25) end),
            TimeEvent(26 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1.1, .5) end),
            TimeEvent(27 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1.08, .45) end),
            TimeEvent(28 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1.05, .2) end),
            TimeEvent(29 * FRAMES, function(inst) SetLightValueAndOverride(inst, 1.1, .3) end),
            TimeEvent(30 * FRAMES, function(inst)
                inst.sg.statemem.lightval = 1.1
            end),
            TimeEvent(32 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/taunt_grrr", nil, .5)
                inst.sg.statemem.lightval = 1.035
                SetLightColour(inst, .9)
            end),
            TimeEvent(33 * FRAMES, function(inst) SetLightColour(inst, .8) end),
            TimeEvent(41 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/step", nil, .7) end),
            TimeEvent(43 * FRAMES, function(inst)
                ShakeAllCameras(CAMERASHAKE.VERTICAL, .3, .02, .7, inst, SHAKE_DIST)
            end),
            TimeEvent(47 * FRAMES, function(inst)
                inst.sg.statemem.lightval = nil
                SetLightValueAndOverride(inst, .9, 0)
                SetLightColour(inst, .9)
            end),
            TimeEvent(48 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                SetLightValue(inst, 1)
                SetLightColour(inst, 1)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg.statemem.keepfacing = true
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            SetLightValueAndOverride(inst, 1, 0)
            SetLightColour(inst, 1)
            if not inst.sg.statemem.keepfacing then
                DisableEightFaced(inst)
            end
        end,
    },
}

CommonStates.AddWalkStates(states,
{
    starttimeline =
    {
        TimeEvent(7 * FRAMES, DeerclopsFootstep),
    },
    walktimeline =
    {
        TimeEvent(23 * FRAMES, DeerclopsFootstep),
        TimeEvent(42 * FRAMES, DeerclopsFootstep),
    },
    endtimeline =
    {
        TimeEvent(5 * FRAMES, DeerclopsFootstep),
    },
})

CommonStates.AddCombatStates(states,
{
    hittimeline =
    {
        TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/hurt") end),
    },
    attacktimeline =
    {
        TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/attack") end),
        TimeEvent(29 * FRAMES, function(inst) SpawnIceFx(inst, inst.components.combat.target) end),
        TimeEvent(35 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/swipe")
            inst.components.combat:DoAttack(inst.sg.statemem.target)
            if inst.bufferedaction ~= nil and inst.bufferedaction.action == ACTIONS.HAMMER then
                local target = inst.bufferedaction.target
                inst:ClearBufferedAction()
                if target ~= nil and
                    target:IsValid() and
                    target.components.workable ~= nil and
                    target.components.workable:CanBeWorked() and
                    target.components.workable:GetWorkAction() == ACTIONS.HAMMER then
                    target.components.workable:Destroy(inst)
                end
            end
            ShakeAllCameras(CAMERASHAKE.FULL, .5, .025, 1.25, inst, SHAKE_DIST)
        end),
        TimeEvent(36 * FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
    },
    deathtimeline =
    {
        TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/death") end),
        TimeEvent(3 * FRAMES, function(inst) SetLightValue(inst, 1.01) end),
        TimeEvent(4 * FRAMES, function(inst) SetLightValue(inst, 1.025) end),
        TimeEvent(5 * FRAMES, function(inst) SetLightValue(inst, 1.045) end),
        TimeEvent(6 * FRAMES, function(inst) SetLightValue(inst, 1.07) end),
        TimeEvent(32 * FRAMES, function(inst)
            if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
                local player--[[, rangesq]] = inst:GetNearestPlayer()
                LaunchAt(SpawnPrefab("winter_ornament_light1"), inst, player, 1, 6, .5)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")
            end
        end),
        TimeEvent(33 * FRAMES, function(inst)
            SetLightValue(inst, 1.05)
            SetLightColour(inst, .95)
        end),
        TimeEvent(34 * FRAMES, function(inst)
            SetLightValue(inst, 1.01)
            SetLightColour(inst, .85)
        end),
        TimeEvent(35 * FRAMES, function(inst)
            SetLightValue(inst, 1)
            SetLightColour(inst, .75)
        end),
        TimeEvent(36 * FRAMES, function(inst)
            SetLightColour(inst, .7)
        end),
        TimeEvent(48 * FRAMES, function(inst)
            if inst.Light ~= nil then
                local k = 1
                local task
                task = inst:DoPeriodicTask(0, function(inst)
                    k = k - .025
                    if k > 0 then
                        SetLightValue(inst, k)
                    else
                        inst.Light:Enable(false)
                        task:Cancel()
                    end
                end)
            end
        end),
        TimeEvent(50 * FRAMES, function(inst)
            if TheWorld.state.snowlevel > 0.02 then
                inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/bodyfall_snow")
            else
                inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/bodyfall_dirt")
            end
            ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, 2, inst, SHAKE_DIST)
        end),
    },
})

CommonStates.AddSleepStates(states,
{
    starttimeline =
    {
        TimeEvent(1 * FRAMES, function(inst) SetLightValue(inst, .995) end),
        TimeEvent(2 * FRAMES, function(inst) SetLightValue(inst, .99) end),
        TimeEvent(3 * FRAMES, function(inst) SetLightValue(inst, .98) end),
        TimeEvent(4 * FRAMES, function(inst) SetLightValue(inst, .97) end),
        TimeEvent(5 * FRAMES, function(inst) SetLightValue(inst, .96) end),
        TimeEvent(6 * FRAMES, function(inst) SetLightValue(inst, .95) end),
        TimeEvent(7 * FRAMES, function(inst) SetLightValue(inst, .945) end),
        TimeEvent(38 * FRAMES, function(inst) SetLightColour(inst, .95) end),
        TimeEvent(39 * FRAMES, function(inst) SetLightColour(inst, .9) end),
        TimeEvent(40 * FRAMES, function(inst) SetLightColour(inst, .8) end),
        TimeEvent(41 * FRAMES, function(inst) SetLightColour(inst, .75) end),
    },
    sleeptimeline =
    {
        --TimeEvent(46*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.grunt) end)
    },
    waketimeline =
    {
        TimeEvent(2 * FRAMES, function(inst) SetLightColour(inst, .9) end),
        TimeEvent(3 * FRAMES, function(inst) SetLightColour(inst, 1) end),
        TimeEvent(36 * FRAMES, function(inst) SetLightValue(inst, .99) end),
        TimeEvent(37 * FRAMES, function(inst) SetLightValue(inst, 1) end),
    },
},
{
    onsleep = function(inst)
        SetLightValue(inst, 1)
        SetLightColour(inst, 1)
    end,
    onwake = function(inst)
        SetLightValue(inst, .945)
        SetLightColour(inst, .75)
    end,
})
CommonStates.AddFrozenStates(states)

return StateGraph("deerclops", states, events, "idle", actionhandlers)
