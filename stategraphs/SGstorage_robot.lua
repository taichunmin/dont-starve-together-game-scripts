require("stategraphs/commonstates")

local events =
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnSink(),
}

local actionhandlers =
{
    ActionHandler( ACTIONS.PICKUP,    "pickup" ),
    ActionHandler( ACTIONS.STORE,     "store"  ),
}

------------------------------------------------------------------------------------------------------------------------------

local WALK_SOUNDNAME = "walk_loop"
local ACTIVE_SOUNDNAME = "active_loop"
local NEUTRAL_VOICE_SOUNDNAME = "neutral_voice"

local NEUTRAL_VOCALIZATION_INTERVAL = 20
local NEUTRAL_VOCALIZATION_CHANCE   = 0.1

local PICKUP_VOCALIZATION_CHANCE = 0.2

------------------------------------------------------------------------------------------------------------------------------

local function _ReturnToIdle(inst)
    if inst.AnimState:AnimDone() then
        inst.sg:GoToState("idle")
    end
end

local idle_on_animover = { EventHandler("animover", _ReturnToIdle) }

------------------------------------------------------------------------------------------------------------------------------

local function MakeImmovable(inst)
    inst.Physics:SetMass(0)
end

local function RestoreMobility(inst)
    inst.Physics:SetMass(inst:GetFueledSectionMass())
end

local function PlaySectionSound(inst, sound, soundname)
    inst.SoundEmitter:PlaySound("qol1/collector_robot/"..sound..inst:GetFueledSectionSuffix(), soundname)
end

local function PlayVocalizationSound(inst, voice, soundname)
    inst.sg.mem.last_vocalization_time = GetTime()
    PlaySectionSound(inst, voice.."_voice", soundname)
end

local function TryPlayingNeutralVocalizationSound(inst)
    if inst.SoundEmitter:PlayingSound(NEUTRAL_VOICE_SOUNDNAME) or inst.components.inventoryitem:IsHeld() then
        return
    end

    if math.random() < NEUTRAL_VOCALIZATION_CHANCE and (
        inst.sg.mem.last_vocalization_time == nil or (GetTime() - inst.sg.mem.last_vocalization_time > NEUTRAL_VOCALIZATION_INTERVAL)
    ) then
        PlayVocalizationSound(inst, "neutral", NEUTRAL_VOICE_SOUNDNAME)
    end
end

------------------------------------------------------------------------------------------------------------------------------

local states =
{
    State {
        name = "idle",
        tags = { "idle" },

        onenter = function(inst, busy)
            -- Safeguard.
            if inst.components.fueled:IsEmpty() then
                inst.sg:GoToState("idle_broken")

                return
            end

            if busy then
                inst.sg:AddStateTag("busy")
            end

            inst.components.fueled:StopConsuming()
            inst.components.locomotor:StopMoving()

            inst.SoundEmitter:KillSound(WALK_SOUNDNAME)
            inst.SoundEmitter:KillSound(ACTIVE_SOUNDNAME)

            TryPlayingNeutralVocalizationSound(inst)

            if not inst.AnimState:IsCurrentAnimation("idle") then
                inst.AnimState:PlayAnimation("idle", true)
            end

            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "pickup",
        tags = { "busy" },
        onenter = function(inst)
            inst.AnimState:PlayAnimation("pickup")

            inst.SoundEmitter:KillSound(WALK_SOUNDNAME)

            PlaySectionSound(inst, "idle", ACTIVE_SOUNDNAME)
            inst.SoundEmitter:PlaySound("qol1/collector_robot/pickup")

            MakeImmovable(inst)
        end,

        timeline =
        {
            FrameEvent(27, function(inst)
                ShakeAllCameras(CAMERASHAKE.VERTICAL, .5, .02, .12, inst, 30)

                inst:PerformBufferedAction()
            end),

            FrameEvent(37, function(inst)
                if math.random() < PICKUP_VOCALIZATION_CHANCE then
                    PlayVocalizationSound(inst, "pickup")
                end
            end),
        },

        events = idle_on_animover,
        onexit = RestoreMobility,
    },

    State{
        name = "store",
        tags = { "busy" },
        onenter = function(inst)
            inst.AnimState:PlayAnimation("dropoff")

            inst.SoundEmitter:KillSound(WALK_SOUNDNAME)

            PlaySectionSound(inst, "idle", ACTIVE_SOUNDNAME)
            inst.SoundEmitter:PlaySound("qol1/collector_robot/dropoff")

            MakeImmovable(inst)
        end,

        timeline =
        {
            FrameEvent(6, function(inst)
                inst:PerformBufferedAction()
            end),

            FrameEvent(50, function(inst)
                PlayVocalizationSound(inst, "dropoff")
            end),
        },

        events = idle_on_animover,

        onexit = function(inst)
            inst.components.inventory:CloseAllChestContainers()

            RestoreMobility(inst)
        end,
    },

    State {
        name = "repairing_pre",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("repair_pre", false)

            --inst.SoundEmitter:PlaySound("qol1/collector_robot/repair_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("repairing")
            end),
        },

        onexit = function(inst)
            inst.AnimState:SetBuild("storage_robot")
        end,
    },

    State {
        name = "repairing",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("repair", false)

            inst.SoundEmitter:PlaySound("qol1/collector_robot/repair")
        end,

        events = idle_on_animover,
    },

    State {
        name = "breaking",
        tags = { "busy", "broken" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.components.inventory:DropEverything()

            inst.AnimState:PlayAnimation("breaking")

            inst.SoundEmitter:KillAllSounds()

            PlayVocalizationSound(inst, "breakdown")
            inst.SoundEmitter:PlaySound("qol1/collector_robot/breakdown")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_broken")
            end),
        },
    },

    State {
        name = "idle_broken",
        tags = { "busy", "broken" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("idle_broken", false)

            inst.SoundEmitter:KillAllSounds()
        end,
    },
}

CommonStates.AddSinkAndWashAshoreStates(states, {washashore = "idle_broken"})

CommonStates.AddWalkStates(
    states,
    nil,
    nil,
    true,
    nil,
    {
        startonenter = function(inst)
            inst.components.fueled:StartConsuming()

            inst.SoundEmitter:KillSound(ACTIVE_SOUNDNAME)

            if not inst.SoundEmitter:PlayingSound(WALK_SOUNDNAME) then
                PlaySectionSound(inst, "walk", WALK_SOUNDNAME)
            end
        end,

        endonexit = function(inst)
            inst.components.fueled:StopConsuming()

            inst.SoundEmitter:KillSound(WALK_SOUNDNAME)
            inst.SoundEmitter:KillSound(ACTIVE_SOUNDNAME)
        end,

        walktimeline =
        {
            FrameEvent(5, TryPlayingNeutralVocalizationSound),
        },
    }
)

return StateGraph("storage_robot", states, events, "idle", actionhandlers)
