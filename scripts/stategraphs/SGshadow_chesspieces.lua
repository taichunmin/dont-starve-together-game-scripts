require("stategraphs/commonstates")

local ShadowChess =
{
    Events = {},
    States = {},
    Functions = {},
}

--------------------------------------------------------------------------
local function FinishExtendedSound(inst, soundid)
    inst.SoundEmitter:KillSound("sound_"..tostring(soundid))
    inst.sg.mem.soundcache[soundid] = nil
    if inst.sg.statemem.readytoremove and next(inst.sg.mem.soundcache) == nil then
        inst:Remove()
    end
end

local function PlayExtendedSound(inst, soundname)
    if inst.sg.mem.soundcache == nil then
        inst.sg.mem.soundcache = {}
        inst.sg.mem.soundid = 0
    else
        inst.sg.mem.soundid = inst.sg.mem.soundid + 1
    end
    inst.sg.mem.soundcache[inst.sg.mem.soundid] = true
    inst.SoundEmitter:PlaySound(inst.sounds[soundname], "sound_"..tostring(inst.sg.mem.soundid))
    inst:DoTaskInTime(10, FinishExtendedSound, inst.sg.mem.soundid)
end

local function ExtendedSoundTimelineEvent(t, soundname)
    return TimeEvent(t, function(inst)
        PlayExtendedSound(inst, soundname)
    end)
end

ShadowChess.Functions.PlayExtendedSound = PlayExtendedSound
ShadowChess.Functions.ExtendedSoundTimelineEvent = ExtendedSoundTimelineEvent

--------------------------------------------------------------------------
ShadowChess.Events.OnAnimOverRemoveAfterSounds = function()
    return EventHandler("animover", function(inst)
        if inst.AnimState:AnimDone() then
            if inst.sg.mem.soundcache == nil or next(inst.sg.mem.soundcache) == nil then
                inst:Remove()
            else
                inst:Hide()
                inst.sg.statemem.readytoremove = true
            end
        end
    end)
end

ShadowChess.Events.IdleOnAnimOver = function()
    return EventHandler("animover", function(inst)
        if inst.AnimState:AnimDone() then
            inst.sg:GoToState("idle")
        end
    end)
end

--------------------------------------------------------------------------
local function PlayDeathSound(inst)
    inst.SoundEmitter:PlaySound(inst.sounds.death)
end

local function DeathSoundTimelineEvent(t)
    return TimeEvent(t, PlayDeathSound)
end

ShadowChess.Functions.DeathSoundTimelineEvent = DeathSoundTimelineEvent

--------------------------------------------------------------------------
local LEVELUP_RADIUS = 25
local AWAKEN_NEARBY_STATUES_RADIUS = 15
local NEARBYSTATUES_TAGS = { "chess_moonevent" }

local function AwakenNearbyStatues(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, AWAKEN_NEARBY_STATUES_RADIUS, NEARBYSTATUES_TAGS)
    for i, v in ipairs(ents) do
        v:PushEvent("shadowchessroar", true)
    end
end

ShadowChess.Functions.AwakenNearbyStatues = AwakenNearbyStatues

--------------------------------------------------------------------------
local function TriggerEpicScare(inst)
    if inst:HasTag("epic") then
        inst.components.epicscare:Scare(5)
    end
end

ShadowChess.Functions.TriggerEpicScare = TriggerEpicScare

--------------------------------------------------------------------------
local function levelup(inst, data)
    if not (inst.components.health:IsDead() or inst.sg:HasStateTag("busy")) and inst:WantsToLevelUp() then
        inst.sg:GoToState("levelup")
    end
end

ShadowChess.Events.LevelUp = function()
    return EventHandler("levelup", levelup)
end

--------------------------------------------------------------------------
local function doattack(inst, data)
    if not (inst.sg:HasStateTag("busy") or
            inst.sg:HasStateTag("attack") or
            inst.sg:HasStateTag("taunt") or
            inst.sg:HasStateTag("levelup") or
            inst.components.health:IsDead()) then
        inst.sg:GoToState("attack", data.target)
    end
end

ShadowChess.Events.DoAttack = function()
    return EventHandler("doattack", doattack)
end

--------------------------------------------------------------------------
local function onattacked(inst)--, data)
    if not (inst.sg:HasStateTag("busy") or
            inst.components.health:IsDead() or
            inst:WantsToLevelUp()) 
		and not CommonHandlers.HitRecoveryDelay(inst) then

        inst.sg:GoToState("hit")
    end
end

ShadowChess.Events.OnAttacked = function()
    return EventHandler("attacked", onattacked)
end

--------------------------------------------------------------------------
local function ondeath(inst, data)
    inst.sg:GoToState(inst.level == 1 and "death" or "evolved_death", data)
end

ShadowChess.Events.OnDeath = function()
    return EventHandler("death", ondeath)
end

--------------------------------------------------------------------------
local function ondespawn(inst, data)
    if not inst.components.health:IsDead() then
        inst.sg:GoToState("despawn", data)
    end
end

ShadowChess.Events.OnDespawn = function()
    return EventHandler("despawn", ondespawn)
end

--------------------------------------------------------------------------
ShadowChess.States.AddIdle = function(states, idle_anim)
    table.insert(states, State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            if inst:WantsToLevelUp() then
                inst.sg:GoToState("levelup")
            else
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation(idle_anim, true)
            end
        end,

        --[[timeline =
        {
            ExtendedSoundTimelineEvent(0, "idle"),
        },]]
    })
end

--------------------------------------------------------------------------
ShadowChess.States.AddLevelUp = function(states, anim, sound_frame, transition_frame, busyover_frame)
    table.insert(states, State{
        name = "levelup",
        tags = { "busy", "levelup" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation(anim)
        end,

        timeline =
        {
            TimeEvent(sound_frame * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.levelup) end),
            TimeEvent(transition_frame * FRAMES, function(inst)
                while inst:WantsToLevelUp() do
                    inst:LevelUp()
                end
                AwakenNearbyStatues(inst)
                TriggerEpicScare(inst)
            end),
            TimeEvent(busyover_frame * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

        events =
        {
            ShadowChess.Events.IdleOnAnimOver(),
        },
    })
end

--------------------------------------------------------------------------
ShadowChess.States.AddTaunt = function(states, anim, sound_frame, action_frame, busyover_frame)
    table.insert(states, State{
        name = "taunt",
        tags = { "taunt", "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation(anim)
        end,

        timeline =
        {
            ExtendedSoundTimelineEvent(sound_frame * FRAMES, "taunt"),
            TimeEvent(action_frame * FRAMES, function(inst)
                AwakenNearbyStatues(inst)
                TriggerEpicScare(inst)
            end),
            TimeEvent(busyover_frame * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

        events =
        {
            ShadowChess.Events.IdleOnAnimOver(),
        },
    })
end

--------------------------------------------------------------------------
ShadowChess.States.AddHit = function(states, anim, sound_frame, busyover_frame)
    table.insert(states, State{
        name = "hit",
        tags = { "busy", "hit" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation(anim)
			CommonHandlers.UpdateHitRecoveryDelay(inst)
        end,

        timeline =
        {
            ExtendedSoundTimelineEvent(sound_frame * FRAMES, "hit"),
            TimeEvent(busyover_frame * FRAMES, function(inst)
                if inst:WantsToLevelUp() then
                    inst.sg:GoToState("levelup")
                    return
                elseif inst.sg.statemem.doattacktarget ~= nil then
                    if inst.sg.statemem.doattacktarget:IsValid() and
                        not (inst.sg.statemem.doattacktarget.components.health ~= nil and
                            inst.sg.statemem.doattacktarget.components.health:IsDead() or
                            inst.components.health:IsDead()) then
                        inst.sg:GoToState("attack", inst.sg.statemem.doattacktarget)
                        return
                    end
                    inst.sg.statemem.doattacktarget = nil
                end
                inst.sg:RemoveStateTag("busy")
            end),
        },

        events =
        {
            EventHandler("doattack", function(inst, data)
                inst.sg.statemem.doattacktarget = data.target
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst:WantsToLevelUp() then
                        inst.sg:GoToState("levelup")
                    elseif inst.sg.statemem.doattacktarget ~= nil
                        and inst.sg.statemem.doattacktarget:IsValid()
                        and not (inst.sg.statemem.doattacktarget.components.health ~= nil and
                                inst.sg.statemem.doattacktarget.components.health:IsDead() or
                                inst.components.health:IsDead()) then
                        inst.sg:GoToState("attack", inst.sg.statemem.doattacktarget)
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },
    })
end

--------------------------------------------------------------------------
local SHADOWCHESSPIECE_TARGET_TAGS = { "shadowchesspiece" }
local function LevelUpAlliesTimelineEvent(frame)
    return TimeEvent(frame * FRAMES, function(inst)
        -- trigger all near by shadow chess pieces to level up
        local pos = inst:GetPosition()
        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, LEVELUP_RADIUS, SHADOWCHESSPIECE_TARGET_TAGS)
        for i, v in ipairs(ents) do
            if v ~= inst and not v.components.health:IsDead() then
                v:PushEvent("levelup", { source = inst })
            end
        end

        if inst.persists then
            inst.persists = false
            inst.components.lootdropper:DropLoot(pos)
        end
    end)
end

--------------------------------------------------------------------------
ShadowChess.States.AddDeath = function(states, anim, action_frame, timeline)
    timeline = timeline or {}
    table.insert(timeline, ExtendedSoundTimelineEvent(0, "disappear"))
    table.insert(timeline, LevelUpAlliesTimelineEvent(action_frame))

    table.insert(states, State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation(anim)
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst:AddTag("NOCLICK")
        end,

        timeline = timeline,

        events =
        {
            ShadowChess.Events.OnAnimOverRemoveAfterSounds(),
        },

        onexit = function(inst)
            inst:RemoveTag("NOCLICK")
        end,
    })
end

--------------------------------------------------------------------------
ShadowChess.States.AddEvolvedDeath = function(states, anim, action_frame, timeline)
    timeline = timeline or {}
    table.insert(timeline, ExtendedSoundTimelineEvent(0, "die"))
    table.insert(timeline, LevelUpAlliesTimelineEvent(action_frame))

    table.insert(states, State{
        name = "evolved_death",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation(anim)
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst:AddTag("NOCLICK")
        end,

        timeline = timeline,

        events =
        {
            ShadowChess.Events.OnAnimOverRemoveAfterSounds(),
        },

        onexit = function(inst)
            inst:RemoveTag("NOCLICK")
        end,
    })
end

--------------------------------------------------------------------------
ShadowChess.States.AddDespawn = function(states, anim, timeline)
    timeline = timeline or {}
    table.insert(timeline, ExtendedSoundTimelineEvent(0, "disappear"))

    table.insert(states, State{
        name = "despawn",
        tags = { "busy", "noattack" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation(anim)
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst:AddTag("NOCLICK")
            inst.persists = false
        end,

        timeline = timeline,

        events =
        {
            ShadowChess.Events.OnAnimOverRemoveAfterSounds(),
        },

        onexit = function(inst)
            inst:RemoveTag("NOCLICK")
        end,
    })
end

--------------------------------------------------------------------------
ShadowChess.States.AddAppear = function(states, anim, timeline)
    timeline = timeline or {}
    table.insert(timeline, ExtendedSoundTimelineEvent(0, "disappear"))

    table.insert(states, State{
        name = "appear",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("appear")
            inst.Physics:Stop()
        end,

        timeline = timeline,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
        },
    })
end

--------------------------------------------------------------------------
ShadowChess.CommonEventList =
{
    ShadowChess.Events.LevelUp(),
    ShadowChess.Events.DoAttack(),
    ShadowChess.Events.OnAttacked(),
    ShadowChess.Events.OnDeath(),
    ShadowChess.Events.OnDespawn(),
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnSink(),
}

return ShadowChess
