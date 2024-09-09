local function OnEndHappy(inst)
    inst.sg.mem.endhappytask = nil
    inst.happy = false
end

local function SpawnElite(inst, prefab, xoffs, zoffs, strid)
    local x, y, z = inst.Transform:GetWorldPosition()
    local elite = SpawnPrefab(prefab)
    elite.Transform:SetPosition(x, 0, z)
    x = x + xoffs
    z = z + zoffs
    elite.sg:GoToState("flipout", { dest = Vector3(x, 0, z), strtbl = "PIG_ELITE_INTRO", strid = strid })
    if elite.components.entitytracker ~= nil then
        elite.components.entitytracker:TrackEntity("king", inst)
    end
    if elite.components.knownlocations ~= nil then
        elite.components.knownlocations:RememberLocation("home", Point(x, 0, z))
    end
    if elite.components.minigame_participator ~= nil then
        elite.components.minigame_participator:SetMinigame(inst)
    end
    elite.persists = false

    inst._minigame_elites[elite] = true
    inst:ListenForEvent("onremove", inst._onremoveelite, elite)

    return elite
end

local states =
{
    State{
        name = "idle",
        tags = { "idle" },

        onenter = function(inst)
            if inst.sg.mem.sleeping then
                inst.sg:GoToState("sleep")
            else
                inst.AnimState:PlayAnimation("idle", true)
            end
        end,
    },

    State{
        name = "cointoss",

        onenter = function(inst)
            inst.AnimState:PlayAnimation("cointoss")
            inst.happy = true
            if inst.sg.mem.endhappytask ~= nil then
                inst.sg.mem.endhappytask:Cancel()
            end
            inst.sg.mem.endhappytask = inst:DoTaskInTime(5, OnEndHappy)
        end,

        timeline =
        {
            TimeEvent(17 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/pig/PigKingThrowGold") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("happy")
                end
            end),
        },
    },

    State{
        name = "happy",

        onenter = function(inst)
            inst.AnimState:PlayAnimation("happy")
        end,

        timeline =
        {
            TimeEvent(6 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/pig/PigKingHappy") end),
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
        name = "unimpressed",

        onenter = function(inst)
            inst.AnimState:PlayAnimation("unimpressed")
            inst.SoundEmitter:PlaySound("dontstarve/pig/PigKingReject")
            inst.happy = false
            if inst.sg.mem.endhappytask ~= nil then
                inst.sg.mem.endhappytask:Cancel()
                inst.sg.mem.endhappytask = nil
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
        name = "sleep",
        tags = { "sleeping" },

        onenter = function(inst)
            inst.components.trader:Disable()
            inst.AnimState:PlayAnimation("sleep_pre")
            inst.AnimState:PushAnimation("sleep_loop", true)
        end,

        onexit = function(inst)
            inst.components.trader:Enable()
        end,
    },

    State{
        name = "wake",

        onenter = function(inst)
            inst.AnimState:PlayAnimation("sleep_pst")
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
        name = "intro",
        tags = { "intro" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("intro_pre")
            inst:EnableCameraFocus(true)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst:IsMinigameActive() then
                        inst.sg.statemem.continueintro = true
                        inst.sg:GoToState("intro2")
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.continueintro then
                inst:EnableCameraFocus(false)
            end
        end,
    },

    State{
        name = "intro2",
        tags = { "intro" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("intro_loop", true)
            inst:EnableCameraFocus(true)
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() * 2)
        end,

        ontimeout = function(inst)
            if inst:IsMinigameActive() then
                inst.sg.statemem.continueintro = true
                inst.sg:GoToState("intro3")
            else
                inst.sg:GoToState("idle")
            end
        end,

        onexit = function(inst)
            if not inst.sg.statemem.continueintro then
                inst:EnableCameraFocus(false)
            end
        end,
    },

    State{
        name = "intro3",
        tags = { "intro" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("intro_pst")
            inst.SoundEmitter:PlaySound("dontstarve/pig/PigKingThrowGold")
            inst:EnableCameraFocus(true)
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                if inst:IsMinigameActive() then
                    SpawnElite(inst, "pigelite1", -3.5, -3.5, 1)
                    SpawnElite(inst, "pigelite2", 3.5, -3.5, 2)
                    SpawnElite(inst, "pigelite3", -3.5, 3.5, 2)
                    SpawnElite(inst, "pigelite4", 3.5, 3.5, 1)
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst:IsMinigameActive() then
                        inst.sg.statemem.continueintro = true
                        inst.sg:GoToState("intro4")
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.continueintro then
                inst:EnableCameraFocus(false)
            end
        end,
    },

    State{
        name = "intro4",
        tags = { "intro" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("happy")
            inst:EnableCameraFocus(true)
        end,

        timeline =
        {
            TimeEvent(6 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/pig/PigKingHappy") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            for k, v in pairs(inst._minigame_elites) do
                k:PushEvent("introover")
            end
            inst:EnableCameraFocus(false)
        end,
    },
}

return StateGraph("pigking", states, {}, "idle")
