require("stategraphs/commonstates")

local DESTROYSTUFF_IGNORE_TAGS = { "INLIMBO", "mushroomsprout", "NET_workable" }
local BOUNCESTUFF_MUST_TAGS = { "_inventoryitem" }
local BOUNCESTUFF_CANT_TAGS = { "locomotor", "INLIMBO" }
SPORECLOUD_TAGS = { "sporecloud" }

local function DestroyStuff(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 3, nil, DESTROYSTUFF_IGNORE_TAGS)
    for i, v in ipairs(ents) do
        if v:IsValid() and
            v.components.workable ~= nil and
            v.components.workable:CanBeWorked() and
            v.components.workable.action ~= ACTIONS.NET then
            SpawnPrefab("collapse_small").Transform:SetPosition(v.Transform:GetWorldPosition())
            v.components.workable:Destroy(inst)
        end
    end
end

local function ClearRecentlyBounced(inst, other)
    inst.sg.mem.recentlybounced[other] = nil
end

local function SmallLaunch(inst, launcher, basespeed)
    local hp = inst:GetPosition()
    local pt = launcher:GetPosition()
    local vel = (hp - pt):GetNormalized()
    local speed = basespeed * 2 + math.random() * 2
    local angle = math.atan2(vel.z, vel.x) + (math.random() * 20 - 10) * DEGREES
    inst.Physics:Teleport(hp.x, .1, hp.z)
    inst.Physics:SetVel(math.cos(angle) * speed, 1.5 * speed + math.random(), math.sin(angle) * speed)

    launcher.sg.mem.recentlybounced[inst] = true
    launcher:DoTaskInTime(.6, ClearRecentlyBounced, inst)
end

local function BounceStuff(inst)
    if inst.sg.mem.recentlybounced == nil then
        inst.sg.mem.recentlybounced = {}
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 6, BOUNCESTUFF_MUST_TAGS, BOUNCESTUFF_CANT_TAGS)
    for i, v in ipairs(ents) do
        if v:IsValid() and not (v.components.inventoryitem.nobounce or inst.sg.mem.recentlybounced[v]) and v.Physics ~= nil and v.Physics:IsActive() then
            local distsq = v:GetDistanceSqToPoint(x, y, z)
            local intensity = math.clamp((36 - distsq) / 27 --[[(36 - 9)]], 0, 1)
            SmallLaunch(v, inst, intensity)
        end
    end
end

local function ShakeIfClose(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, .5, inst, 40)
    BounceStuff(inst)
end

local function DoFootstep(inst)
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/step_soft")
end

local function DoStompstep(inst)
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/step_stomp")
    ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, .7, inst, 40)
    DestroyStuff(inst)
    BounceStuff(inst)
end

local function DoRoarShake(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, .3, inst, 40)
    BounceStuff(inst)
end

local function DoChannelingShake(inst)
    ShakeAllCameras(CAMERASHAKE.VERTICAL, 6 * FRAMES, .02, .2, inst, 40)
    BounceStuff(inst)
end

local function DoSporeBombShake(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, .3, inst, 40)
    BounceStuff(inst)
end

local function DoMushroomBombShake(inst)
    ShakeAllCameras(CAMERASHAKE.VERTICAL, .35, .02, .3, inst, 40)
    BounceStuff(inst)
end

local function DoPoundShake(inst)
    ShakeAllCameras(CAMERASHAKE.VERTICAL, .35, .02, 1, inst, 40)
    BounceStuff(inst)
end

--------------------------------------------------------------------------

local function ChooseAttack(inst)
    if not inst.components.timer:TimerExists("pound_cd") then
        inst.sg:GoToState("pound_pre")
        return true
    elseif not inst.components.timer:TimerExists("sporebomb_cd") then
        local targets = inst:FindSporeBombTargets()
        if #targets > 0 then
            inst.sg:GoToState("sporebomb", targets)
            return true
        end
    end
    if not inst.components.timer:TimerExists("mushroombomb_cd") then
        inst.sg:GoToState("mushroombomb")
        return true
    end
    return false
end

local function OnTickChannel(inst)
    inst:DoMushroomSprout(inst.sg.mem.mushroomsprout_angles)
    inst.components.epicscare:Scare(TUNING.TOADSTOOL_MUSHROOMSPROUT_TICK + 5)
    inst.components.timer:StartTimer("channeltick", TUNING.TOADSTOOL_MUSHROOMSPROUT_TICK)
end

local function OnStartChannel(inst)
    if inst.sg.mem.mushroomsprout_angles == nil then
        --Get new set of angles at start of new channel, or resuming after load
        inst.sg.mem.mushroomsprout_angles = inst:FindMushroomSproutAngles()
    end
    if inst.components.timer:TimerExists("channel") then
        inst.components.timer:ResumeTimer("channel")
        inst.components.timer:ResumeTimer("channeltick")
    else
        inst.components.timer:StartTimer("channel", TUNING.TOADSTOOL_MUSHROOMSPROUT_DURATION)
        OnTickChannel(inst)
    end
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_HUGE
end

local function OnEndChannel(inst)
    inst.SoundEmitter:KillSound("channel")
    if inst.sg.mem.channelshaketask ~= nil then
        inst.sg.mem.channelshaketask:Cancel()
        inst.sg.mem.channelshaketask = nil
    end
    if inst.components.timer:TimerExists("channel") then
        inst.components.timer:PauseTimer("channel")
        inst.components.timer:PauseTimer("channeltick")
    else
        inst.components.timer:StopTimer("channeltick")
        inst.components.timer:StartTimer("mushroomsprout_cd", inst.mushroomsprout_cd)
        inst.sg.mem.mushroomsprout_angles = nil
    end
    inst.components.sanityaura.aura = 0
end

--------------------------------------------------------------------------

local events =
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnSleepEx(),
    CommonHandlers.OnWakeEx(),
    EventHandler("doattack", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            ChooseAttack(inst)
        end
    end),
    EventHandler("attacked", function(inst)
        if not inst.components.health:IsDead() and
            (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("caninterrupt")) and
            not CommonHandlers.HitRecoveryDelay(inst) then
            inst.sg:GoToState("hit")
        end
    end),
    EventHandler("roar", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("roar")
        elseif not inst.sg:HasStateTag("roar") then
            inst.sg.mem.wantstoroar = true
        end
    end),
    EventHandler("startchanneling", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("channel_pre")
        elseif not inst.sg:HasStateTag("channeling") then
            inst.sg.mem.wantstochannel = true
        end
    end),
    EventHandler("flee", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("burrow")
        else
            inst.sg.mem.wantstoburrow = true
        end
    end),
}

local states =
{
    State{
        name = "idle",
        tags = { "idle" },

        onenter = function(inst)
            if inst.sg.mem.wantstoroar then
                inst.sg:GoToState("roar")
            elseif inst.sg.mem.wantstoburrow then
                inst.sg:GoToState("burrow")
            elseif inst.sg.mem.sleeping then
                inst.sg:GoToState("sleep")
            elseif inst.sg.mem.wantstochannel then
                inst.sg:GoToState("channel_pre")
            else
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("idle", true)
            end
        end,
    },

    State{
        name = "walk_start",
        tags = { "moving", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("walk")
                end
            end),
        },
    },

    State{
        name = "walk",
        tags = { "moving", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk")
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, DoFootstep),
            TimeEvent(10 * FRAMES, DoStompstep),
            TimeEvent(19 * FRAMES, DoFootstep),
            TimeEvent(30 * FRAMES, DoStompstep),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("walk")
                end
            end),
        },
    },

    State{
        name = "walk_stop",
        tags = { "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("walk_pst")
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
        name = "surface",
        tags = { "busy", "nosleep", "nofreeze", "noattack" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.components.health:SetInvincible(true)
            inst.AnimState:PlayAnimation("spawn_appear_toad")
            inst.AnimState:SetLightOverride(0)
            inst.DynamicShadow:Enable(false)
            inst.Light:Enable(false)
            inst.sg.mem.wantstoroar = true
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/spawn_appear_pre")
            end),
            TimeEvent(10 * FRAMES, function(inst)
                ShakeAllCameras(CAMERASHAKE.VERTICAL, 40 * FRAMES , .03, 2, inst, 40)
            end),
            TimeEvent(12 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/spawn_appear")
                inst.AnimState:SetLightOverride(.3)
                inst.DynamicShadow:Enable(true)
                inst.Light:Enable(true)
            end),
            TimeEvent(31 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")
            end),
            TimeEvent(32 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/dustpoof")
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("roar"),
        },

        onexit = function(inst)
            inst.components.health:SetInvincible(false)
            inst.AnimState:SetLightOverride(.3)
            inst.DynamicShadow:Enable(true)
            inst.Light:Enable(true)
        end,
    },

    State{
        name = "burrow",
        tags = { "busy", "nosleep", "nofreeze", "noattack" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.components.health:SetInvincible(true)
            inst.AnimState:PlayAnimation("reset")
        end,

        timeline =
        {
            TimeEvent(11 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/roar")
            end),
            TimeEvent(19 * FRAMES, function(inst)
                inst.DynamicShadow:Enable(false)
            end),
            TimeEvent(20 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/spawn_appear")
            end),
            TimeEvent(21 * FRAMES, function(inst)
                ShakeAllCameras(CAMERASHAKE.VERTICAL, 20 * FRAMES , .03, 2, inst, 40)
            end),
            TimeEvent(40 * FRAMES, function(inst)
                ShakeAllCameras(CAMERASHAKE.VERTICAL, 30 * FRAMES , .03, .7, inst, 40)
            end),
            TimeEvent(48 * FRAMES, function(inst)
                inst:FadeOut()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:OnEscaped()
                end
            end),
        },

        onexit = function(inst)
            --Should NOT happen!
            inst.components.health:SetInvincible(false)
            inst.DynamicShadow:Enable(true)
            inst:CancelFade()
        end,
    },

    State{
        name = "hit",
        tags = { "hit", "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/hit")
			CommonHandlers.UpdateHitRecoveryDelay(inst)
        end,

        timeline =
        {
            TimeEvent(12 * FRAMES, function(inst)
                if inst.sg.statemem.doattack then
                    if not inst.components.health:IsDead() and ChooseAttack(inst) then
                        return
                    end
                    inst.sg.statemem.doattack = nil
                end
                inst.sg:RemoveStateTag("busy")
            end),
        },

        events =
        {
            EventHandler("doattack", function(inst)
                inst.sg.statemem.doattack = true
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg.statemem.doattack and ChooseAttack(inst) then
                        return
                    end
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("death")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/death")
            inst:AddTag("NOCLICK")
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/channeling_LP", "channel")
            end),
            TimeEvent(23 * FRAMES, function(inst)
                inst.SoundEmitter:KillSound("channel")
            end),
            TimeEvent(24 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/roar")
            end),
            TimeEvent(35 * FRAMES, function(inst)
                local x, y, z = inst.Transform:GetWorldPosition()
                for i, v in ipairs(TheSim:FindEntities(x, y, z, 8, SPORECLOUD_TAGS)) do
                    v:FinishImmediately()
                end
                ShakeIfClose(inst)
                if inst.persists then
                    inst.persists = false
                    inst.components.lootdropper:DropLoot(inst:GetPosition())
                end
            end),
            TimeEvent(36 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/death_fall")
            end),
            TimeEvent(52 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/death_roar")
            end),
            TimeEvent(5 - FRAMES, function(inst)
                inst:FadeOut()
            end),
            TimeEvent(5, ErodeAway),
        },

        onexit = function(inst)
            --Should NOT happen!
            inst.SoundEmitter:KillSound("channel")
            inst:RemoveTag("NOCLICK")
            inst:CancelFade()
        end,
    },

    State{
        name = "roar",
        tags = { "roar", "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("phase_transition")
            inst.sg.mem.wantstoroar = nil
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/roar_phase")
                DoRoarShake(inst)
            end),
            TimeEvent(9 * FRAMES, function(inst)
                inst.components.epicscare:Scare(5)
            end),
            TimeEvent(21 * FRAMES, DoRoarShake),
            TimeEvent(22 * FRAMES, function(inst)
                inst.components.epicscare:Scare(5)
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },
    },

    State{
        name = "channel_pre",
        tags = { "busy", "channeling" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("attack_channeling_pre")
            inst.sg.mem.wantstochannel = nil
        end,

        timeline =
        {
            TimeEvent(14 * FRAMES, ShakeIfClose),
        },

        events =
        {
            EventHandler("attacked", function(inst)
                if not inst.components.health:IsDead() and not CommonHandlers.HitRecoveryDelay(inst) then
                    inst.sg:GoToState("channel_hit")
                end
            end),
            EventHandler("roar", function(inst)
                if not inst.components.health:IsDead() then
                    inst.sg:GoToState("channel_roar")
                end
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("channel")
                end
            end),
        },
    },

    State{
        name = "channel",
        tags = { "busy", "channeling" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("attack_channeling_loop", true)
            if not inst.SoundEmitter:PlayingSound("channel") then
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/channeling_LP", "channel")
                inst.SoundEmitter:SetParameter("channel", "intensity", 0)
            end
            if inst.sg.mem.channelshaketask ~= nil then
                inst.sg.mem.channelshaketask:Cancel()
            end
            inst.sg.mem.channelshaketask = inst:DoPeriodicTask(inst.AnimState:GetCurrentAnimationLength(), DoChannelingShake, 0)
            inst.sg.mem.wantstochannel = nil
            OnStartChannel(inst)
        end,

        onupdate = function(inst)
            inst.SoundEmitter:SetParameter("channel", "intensity", 1)
        end,

        events =
        {
            EventHandler("attacked", function(inst)
                if not inst.components.health:IsDead() and not CommonHandlers.HitRecoveryDelay(inst) then
                    inst.sg.statemem.continuechannel = true
                    inst.sg:GoToState("channel_hit")
                end
            end),
            EventHandler("roar", function(inst)
                if not inst.components.health:IsDead() then
                    inst.sg.statemem.continuechannel = true
                    inst.sg:GoToState("channel_roar")
                end
            end),
            EventHandler("timerdone", function(inst, data)
                if not inst.components.health:IsDead() then
                    if data.name == "channeltick" then
                        OnTickChannel(inst)
                    elseif data.name == "channel" then
                        inst.sg:GoToState("channel_pst")
                    end
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.continuechannel then
                OnEndChannel(inst)
            end
        end,
    },

    State{
        name = "channel_hit",
        tags = { "hit", "busy", "channeling" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("hit_channeling")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/hit")
            CommonHandlers.UpdateHitRecoveryDelay(inst)
        end,

        timeline =
        {
            TimeEvent(12 * FRAMES, function(inst)
                if not inst.components.health:IsDead() then
                    if inst.sg.statemem.doattack then
                        if ChooseAttack(inst) then
                            return
                        end
                        inst.sg.statemem.doattack = nil
                    end
                    if inst.sg.statemem.stopped then
                        inst.sg:GoToState("channel_pst")
                        return
                    end
                end
                inst.sg.statemem.endstun = true
            end),
        },

        events =
        {
            EventHandler("doattack", function(inst)
                if inst.sg.statemem.endstun and not inst.components.health:IsDead() then
                    ChooseAttack(inst)
                else
                    inst.sg.statemem.doattack = true
                end
            end),
            EventHandler("timerdone", function(inst, data)
                if data.name == "channeltick" then
                    if not inst.components.health:IsDead() then
                        OnTickChannel(inst)
                    end
                elseif data.name == "channel" then
                    if inst.sg.statemem.endstun and not inst.components.health:IsDead() then
                        inst.sg:GoToState("channel_pst")
                    else
                        inst.sg.statemem.stopped = true
                    end
                end
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg.statemem.doattack and ChooseAttack(inst) then
                        return
                    elseif inst.sg.statemem.stopped then
                        inst.sg:GoToState("channel_pst")
                    else
                        inst.sg.statemem.continuechannel = true
                        inst.sg:GoToState("channel")
                    end
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.continuechannel then
                OnEndChannel(inst)
            end
        end,
    },

    State{
        name = "channel_roar",
        tags = { "roar", "busy", "channeling", "nosleep", "nofreeze" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("phase_transition")
            if inst.sg.mem.channelshaketask ~= nil then
                inst.sg.mem.channelshaketask:Cancel()
                inst.sg.mem.channelshaketask = nil
            end
            inst.sg.mem.wantstoroar = nil
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/roar_phase")
                DoRoarShake(inst)
            end),
            TimeEvent(9 * FRAMES, function(inst)
                inst.components.epicscare:Scare(5)
            end),
            TimeEvent(21 * FRAMES, DoRoarShake),
            TimeEvent(22 * FRAMES, function(inst)
                inst.components.epicscare:Scare(5)
            end),
            TimeEvent(40 * FRAMES, function(inst)
                if not inst.components.health:IsDead() then
                    if inst.sg.statemem.stopped then
                        inst.sg:GoToState("channel_pst")
                    else
                        inst.sg.statemem.continuechannel = true
                        inst.sg:GoToState("channel")
                    end
                end
            end),
        },

        events =
        {
            EventHandler("timerdone", function(inst, data)
                if data.name == "channeltick" then
                    if not inst.components.health:IsDead() then
                        OnTickChannel(inst)
                    end
                elseif data.name == "channel" then
                    inst.sg.statemem.stopped = true
                end
            end),
            CommonHandlers.OnNoSleepAnimOver(function(inst)
                if inst.sg.statemem.stopped then
                    inst.sg:GoToState("channel_pst")
                else
                    inst.sg.statemem.continuechannel = true
                    inst.sg:GoToState("channel")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.continuechannel then
                OnEndChannel(inst)
            end
        end,
    },

    State{
        name = "channel_pst",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("attack_channeling_pst")
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst)
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
        name = "sporebomb",
        tags = { "attack", "busy", "sporebombing", "canrotate" },

        onenter = function(inst, targets)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("attack_infection")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/channeling_LP", "channel")
            inst.SoundEmitter:SetParameter("channel", "intensity", 1)
            inst.components.combat:StartAttack()
            inst.sg.statemem.targets = targets
            if #targets > 0 then
                inst:ForceFacePoint(targets[1].Transform:GetWorldPosition())
            end
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst)
                inst.sg:AddStateTag("nosleep")
                inst.sg:AddStateTag("nofreeze")
            end),
            TimeEvent(18 * FRAMES, function(inst)
                inst.SoundEmitter:KillSound("channel")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/infection_attack")
            end),
            TimeEvent(21 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/infection_attack_pre")
            end),
            TimeEvent(22 * FRAMES, function(inst)
                DoSporeBombShake(inst)
                inst:DoSporeBomb(inst.sg.statemem.targets)
                inst.components.timer:StartTimer("sporebomb_cd", inst.sporebomb_cd)
            end),
            CommonHandlers.OnNoSleepTimeEvent(43 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nosleep")
                inst.sg:RemoveStateTag("nofreeze")
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("channel")
        end,
    },

    State{
        name = "mushroombomb",
        tags = { "attack", "busy", "mushroombombing", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("attack_basic")
            inst.components.combat:StartAttack()
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/roar")
            end),
            TimeEvent(10 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/spore_shoot")
            end),
            TimeEvent(12 * FRAMES, function(inst)
                inst.sg:AddStateTag("nosleep")
                inst.sg:AddStateTag("nofreeze")
            end),
            TimeEvent(14 * FRAMES, function(inst)
                DoMushroomBombShake(inst)
                inst:DoMushroomBomb()
                inst.sg.mem.mushroombomb_chains = (inst.sg.mem.mushroombomb_chains or 0) + 1
                if inst.sg.mem.mushroombomb_chains >= inst.mushroombomb_maxchain then
                    inst.sg.mem.mushroombomb_chains = 0
                    inst.components.timer:StartTimer("mushroombomb_cd", inst.mushroombomb_cd)
                end
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },
    },

    State{
        name = "pound_pre",
        tags = { "attack", "busy", "pounding", "nosleep", "nofreeze" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("attack_pound_pre")
            inst.pound_speed = math.min(6, inst.pound_speed + 1)
            local cooldown = Remap(inst.pound_speed, 1, 6, inst.pound_cd, inst.pound_cd * .5)
            if inst.pound_rnd then
                local k = math.random() * .7
                cooldown = cooldown * (1 - k * k)
            end
            inst.components.timer:StartTimer("pound_cd", cooldown)
        end,

        timeline =
        {
            TimeEvent(11 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/roar")
            end),
			FrameEvent(36, function(inst)
                DoPoundShake(inst)
                inst.components.groundpounder:GroundPound()
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("pound")
                end
            end),
        },
    },

    State{
        name = "pound",
        tags = { "attack", "busy", "pounding", "nosleep", "nofreeze" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("attack_pound_loop")
        end,

        timeline =
        {
			FrameEvent(7, function(inst)
                TheWorld:PushEvent("ms_miniquake", { rad = 20, num = 20, duration = 2.5, target = inst })
                inst.components.groundpounder:GroundPound()
                BounceStuff(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("pound_pst")
                end
            end),
        },
    },

    State{
        name = "pound_pst",
        tags = { "attack", "busy", "pounding", "nosleep", "nofreeze" },

        onenter = function(inst, sleeping)
            inst.AnimState:PlayAnimation("attack_pound_pst")
        end,

        timeline =
        {
            CommonHandlers.OnNoSleepTimeEvent(5 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nosleep")
                inst.sg:RemoveStateTag("nofreeze")
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },
    },
}

local function OnUnfreezeTask(inst)
    inst.sg.mem._unfreezetask = nil
    inst:UpdateLevel()
end

CommonStates.AddFrozenStates(states,
    function(inst) --onoverridesymbols
        if inst.level > 0 then
            inst.AnimState:OverrideSymbol("swap_toad_frozen", inst.dark and "toadstool_dark_upg_build" or "toadstool_upg_build", "swap_toad_frozen"..tostring(inst.level))
        else
            inst.AnimState:ClearOverrideSymbol("swap_toad_frozen")
        end
        if inst.sg.mem._unfreezetask ~= nil then
            inst.sg.mem._unfreezetask:Cancel()
            inst.sg.mem._unfreezetask = nil
        end
    end,
    function(inst) --onclearsymbols
        inst.AnimState:ClearOverrideSymbol("swap_toad_frozen")
        if inst.sg.mem._unfreezetask == nil then
            inst.sg.mem._unfreezetask = inst:DoTaskInTime(0, OnUnfreezeTask)
        end
    end
)
CommonStates.AddSleepExStates(states,
{
    starttimeline =
    {
        TimeEvent(45 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("caninterrupt")
        end),
        TimeEvent(46 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/step_stomp")
            ShakeIfClose(inst)
        end),
    },
    waketimeline =
    {
        CommonHandlers.OnNoSleepTimeEvent(45 * FRAMES, function(inst)
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

return StateGraph("SGtoadstool", states, events, "idle")
