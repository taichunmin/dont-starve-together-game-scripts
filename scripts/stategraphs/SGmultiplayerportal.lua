local function PlaySound(inst, sound, id)
    if inst.sounds[sound] ~= nil and (id == nil or not inst.SoundEmitter:PlayingSound(id)) then
        inst.SoundEmitter:PlaySound(inst.sounds[sound], id)
    end
end

local function PlayAnimation(inst, anim, loop, update_while_paused)
    inst.AnimState:AnimateWhilePaused(update_while_paused)
    inst.AnimState:PlayAnimation(anim, loop)
    if inst.fx ~= nil then
        inst.fx.AnimState:AnimateWhilePaused(update_while_paused)
        inst.fx.AnimState:PlayAnimation(anim, loop)
    end
end

local function PushAnimation(inst, anim, loop)
    inst.AnimState:PushAnimation(anim, loop)
    if inst.fx ~= nil then
        inst.fx.AnimState:PushAnimation(anim, loop)
    end
end

local states =
{
    State{
        name = "idle",
        tags = { "idle" },

        onenter = function(inst)
            --Construction portals only, otherwise should just be both nil
            if inst.sg.mem.targetconstructionphase ~= inst.sg.mem.constructionphase then
                inst.sg:GoToState("constructionphase"..tostring(inst.sg.mem.constructionphase + 1))
                return
            end

            PlayAnimation(inst, "idle_loop")
            --PlaySound(inst, "blink")
            PlaySound(inst, "jacob")
            PlaySound(inst, "idle_loop", "portalidle")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState(not inst.sg.mem.nofunny and math.random() < .3 and "funnyidle" or "idle")
            end),
        },

        timeline =
        {
            TimeEvent(1 * FRAMES, function(inst) PlaySound(inst, "blink") end),
            TimeEvent(9 * FRAMES, function(inst) PlaySound(inst, "vines") end),
            TimeEvent(18 * FRAMES, function(inst) PlaySound(inst, "vines") end),
            TimeEvent(30 * FRAMES, function(inst) PlaySound(inst, "jacob") end),
        },
    },

    State{
        name = "funnyidle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            PlayAnimation(inst, "idle_eyescratch")
            --PlaySound(inst, "blink")
            PlaySound(inst, "jacob")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        timeline =
        {
            TimeEvent(1 * FRAMES, function(inst) PlaySound(inst, "blink") end),
            --TimeEvent(9 * FRAMES, function(inst) PlaySound(inst, "idle") end),
            --TimeEvent(18 * FRAMES, function(inst) PlaySound(inst, "idle") end),
            --TimeEvent(13 * FRAMES, function(inst) PlaySound(inst, "scratch") end),
            --TimeEvent(27 * FRAMES, function(inst) PlaySound(inst, "scratch") end),
            TimeEvent(30 * FRAMES, function(inst) PlaySound(inst, "jacob") end),
            --TimeEvent(41 * FRAMES, function(inst) PlaySound(inst, "scratch") end),
            --TimeEvent(59 * FRAMES, function(inst) PlaySound(inst, "blink") end),
        },
    },

    State{
        name = "spawn_pre",
        tags = { "idle", "open" },
        onenter = function(inst, update_while_paused)
            inst.sg.statemem.update_while_paused = update_while_paused
            PlayAnimation(inst, "pre_fx", nil, update_while_paused)
            inst.SoundEmitter:KillSound("portalidle")
            PlaySound(inst, "spawning_loop", "portalactivate")
            PlaySound(inst, "armswing")
            PlaySound(inst, "shake")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg.statemem.keepactivatesound = true
                inst.sg:GoToState("spawn_loop", inst.sg.statemem.update_while_paused)
            end),
        },

        timeline =
        {
            TimeEvent(11 * FRAMES, function(inst) PlaySound(inst, "blink") end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.keepactivatesound then
                inst.SoundEmitter:KillSound("portalactivate")
            end
        end,
    },

    State{
        name = "spawn_loop",
        tags = { "busy", "open" },
        onenter = function(inst, update_while_paused)
            inst.sg.statemem.update_while_paused = update_while_paused
            PlayAnimation(inst, "fx", nil, update_while_paused)
            PlaySound(inst, "idle_loop", "portalidle")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("spawn_pst", inst.sg.statemem.update_while_paused)
            end),
        },

        timeline =
        {
            TimeEvent(55 * FRAMES, function(inst) PlaySound(inst, "open") end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("portalactivate")
        end,
    },

    State{
        name = "spawn_pst",
        tags = { "busy" },
        onenter = function(inst, update_while_paused)
            PlayAnimation(inst, "pst_fx", nil, update_while_paused)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                PlaySound(inst, "blink")
                inst.sg:GoToState("idle")
            end),
        },

        timeline =
        {
            TimeEvent(12 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(22 * FRAMES, function(inst) PlaySound(inst, "armswing") end),
        },
    },

    --For construction portals
    State{
        name = "placeconstruction",
        tags = { "idle" },
        onenter = function(inst)
            PlayAnimation(inst, "place")
            PlaySound(inst, "place")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "constructed",
        tags = { "busy", "construction" },
        onenter = function(inst, phase)
            PlayAnimation(inst, "bounce")
            PlaySound(inst, "shake")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "constructionphase2",
        tags = { "busy", "construction" },
        onenter = function(inst)
            PlayAnimation(inst, "shatterfx1")
            inst.AnimState:Show("stage1")
            inst.AnimState:Show("stage2")
            inst.AnimState:Hide("stage3")
            inst.AnimState:Show("hidestage3")
            PlaySound(inst, "transmute_pre")
            inst.sg.mem.constructionphase = 2
        end,

        timeline =
        {
            TimeEvent(12 * FRAMES, function(inst) PlaySound(inst, "transmute") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            inst.AnimState:Hide("stage1")
        end,
    },

    State{
        name = "constructionphase3",
        tags = { "busy", "construction" },
        onenter = function(inst)
            PlayAnimation(inst, "shatterfx2")
            inst.AnimState:Hide("stage1")
            inst.AnimState:Show("stage2")
            inst.AnimState:Show("stage3")
            inst.AnimState:Show("hidestage3")
            PlaySound(inst, "transmute_pre")
            inst.sg.mem.constructionphase = 3
            inst.sounds.vines = nil
        end,

        timeline =
        {
            TimeEvent(12 * FRAMES, function(inst) PlaySound(inst, "transmute") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            inst.AnimState:Hide("stage2")
            inst.AnimState:Hide("hidestage3")
        end,
    },

    State{
        name = "constructionphase4",
        tags = { "busy", "construction" },
        onenter = function(inst)
            PlayAnimation(inst, "final_reveal")
            inst.AnimState:Hide("stage1")
            inst.AnimState:Hide("stage2")
            inst.AnimState:Show("stage3")
            inst.AnimState:Hide("hidestage3")
            inst:AddTag("NOCLICK")
            PlaySound(inst, "place")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                SpawnPrefab("multiplayer_portal_moonrock").Transform:SetPosition(inst.Transform:GetWorldPosition())
                inst:Remove()
            end),
        },

        onexit = function(inst)
            --Should NOT happen!
            for i = 1, 3 do
                if i == inst.sg.mem.constructionphase then
                    inst.AnimState:Show("stage"..tostring(i))
                else
                    inst.AnimState:Hide("stage"..tostring(i))
                end
            end
            if inst.sg.mem.constructionphase == 3 then
                inst.AnimState:Hide("hidestage3")
            else
                inst.AnimState:Show("hidestage3")
            end
            inst:RemoveTag("NOCLICK")
        end,
    },
}

return StateGraph("multiplayer_portal", states, {}, "idle")
