local events =
{
    EventHandler("putoutfire", function(inst, data)
        if inst.components.machine:IsOn() then
            if inst.sg:HasStateTag("idle") then
                inst.sg:GoToState("spin_up", { firePos = data.firePos })
            elseif inst.sg:HasStateTag("shooting") then
                inst.sg:GoToState("shoot", { firePos = data.firePos })
            end
        end
    end),
}

local function PlayWarningSound(inst)
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_warningbell")
end

local function ToggleWarningSound(inst, on)
    if on then
        if inst.sg.mem.soundtask == nil then
            inst.sg.mem.soundtask = inst:DoPeriodicTask(24 * FRAMES, PlayWarningSound, 0)
        end
    elseif inst.sg.mem.soundtask ~= nil then
        inst.sg.mem.soundtask:Cancel()
        inst.sg.mem.soundtask = nil
    end
end

local states =
{
    State{
        name = "turn_on",
        tags = { "idle" },

        onenter = function(inst, isemergency)
            ToggleWarningSound(inst, isemergency)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_on")
            inst.AnimState:PlayAnimation("turn_on")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_on")
            end),
        }
    },

    State{
        name = "turn_off",
        tags = { "idle" },

        onenter = function(inst)
            ToggleWarningSound(inst, false)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_off")
            inst.AnimState:PlayAnimation("turn_off")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_off")
            end),
        }
    },

    State{
        name = "idle_on",
        tags = { "idle" },

        onenter = function(inst, forceisemergency)
            if forceisemergency ~= nil then
                ToggleWarningSound(inst, forceisemergency)
            end
            if not inst.SoundEmitter:PlayingSound("firesuppressor_idle") then
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_idle", "firesuppressor_idle")
            end
            inst.AnimState:PlayAnimation("idle_on_loop")
        end,

        timeline =
        {
            TimeEvent(16 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_chuff")
            end)
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_on")
            end),
        }
    },

    State{
        name = "idle_off",
        tags = { "idle" },

        onenter = function(inst)
            ToggleWarningSound(inst, false)
            inst.SoundEmitter:KillSound("firesuppressor_idle")
            inst.AnimState:PlayAnimation("idle_off", true)
        end,
    },

    State{
        name = "light_on",
        tags = { "idle", "light" },

        onenter = function(inst)
            ToggleWarningSound(inst, true)
            inst.AnimState:PlayAnimation("light_on")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_light_on")
            end),
        },
    },

    State{
        name = "light_off",
        tags = { "idle" },

        onenter = function(inst)
            ToggleWarningSound(inst, false)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_off")
            inst.AnimState:PlayAnimation("light_off")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_off")
            end),
        },
    },

    State{
        name = "idle_light_on",
        tags = { "idle", "light" },

        onenter = function(inst)
            ToggleWarningSound(inst, true)
            if not inst.SoundEmitter:PlayingSound("firesuppressor_idle") then
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_idle", "firesuppressor_idle")
            end
            inst.AnimState:PlayAnimation("idle_light_loop", true)
        end,

        --[[events =
        {
            EventHandler("warninglevelchanged", function(inst)
                inst.sg:GoToState("idle_light_change")
            end),
        }]]
    },

    --[[State{
        name = "idle_light_change",
        tags = { "idle", "light" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_on")
            inst.AnimState:PlayAnimation("hit_light")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_light_on")
            end),
        },
    },]]

    State{
        name = "turn_on_light",
        tags = { "idle" },

        onenter = function(inst)
            ToggleWarningSound(inst, true)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_on")
            inst.AnimState:PlayAnimation("turn_on_light")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_on")
            end),
        }
    },

    State{
        name = "spin_up",
        tags = { "busy" },

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("launch_pre")
            inst.sg.statemem.data = data
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("shoot", inst.sg.statemem.data)
            end),
        },
    },

    State{
        name = "shoot",
        tags = { "busy", "shooting" },

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("launch")
            inst.sg.statemem.firePos = data.firePos
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_spin")
        end,

        timeline =
        {
            TimeEvent(6 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_shoot")
                inst:LaunchProjectile(inst.sg.statemem.firePos)
            end),
            TimeEvent(8 * FRAMES, function(inst)
                inst.components.firedetector:DetectFire()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("spin_down")
            end),
        },
    },

    State{
        name = "spin_down",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("launch_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_on")
            end),
        },
    },

    State{
        name = "place",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("place")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_on")
            end),
        },
    },

    State{
        name = "hit",
        tags = { "busy" },

        onenter = function(inst, light)
            if inst.on then
                inst.AnimState:PlayAnimation("hit_on")
            else
                inst.sg.statemem.light = light
                inst.AnimState:PlayAnimation(light and "hit_light" or "hit_off")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.on then
                    inst.sg:GoToState("idle_on")
                else
                    inst.sg:GoToState(inst.sg.statemem.light and "idle_light_on" or "idle_off")
                end
            end),
        },
    },
}

return StateGraph("firesuppressor", states, events, "idle_off")
