local events =
{
}

local function PlayHitFX(inst)
    if inst.sg.mem.bumpertype ~= nil then
        local hitfx = SpawnPrefab("boat_bumper_hit_" .. inst.sg.mem.bumpertype)
        hitfx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    end
end

local idle_on_animover = {
    EventHandler("animover", function(inst)
        inst.sg:GoToState("idle", inst.sg.mem.nextstateindex)
    end),
}

local states =
{
    State{
        name = "idle",
        tags = { "idle" },

        onenter = function(inst, state)
            inst.AnimState:PlayAnimation("idle_" .. (state or 1), true)
        end,
    },

    State{
        name = "place",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("place")
        end,

        events = idle_on_animover,
    },

    State{
        name = "hit",
        tags = { "busy" },

        onenter = function(inst, data)
            local stateindex = data and data.index or 1

            inst.AnimState:PlayAnimation("hit_" .. stateindex)

            PlayHitFX(inst)
            inst.sg.mem.nextstateindex = stateindex
        end,

        events = idle_on_animover,
    },

    State{
        name = "changegrade",
        tags = { "busy" },

        onenter = function(inst, data)
            local stateindex = data and (data.isupgrade and data.index or data.newindex) or 2
            local animtoplay = data and data.isupgrade and "upgrade_" or "downgrade_"

            inst.AnimState:PlayAnimation(animtoplay .. stateindex - 1)

            if not data.isupgrade then
                PlayHitFX(inst)
            end

            inst.sg.mem.nextstateindex = data and data.newindex or 1

            inst.sg.statemem.isupgrade = data ~= nil and data.isupgrade

            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        timeline = {
            FrameEvent(6, function(inst)
                if inst.sg.statemem.isupgrade then
                    inst.AnimState:PlayAnimation("upgrade_" .. inst.sg.mem.nextstateindex)
                    inst.AnimState:SetFrame(7)
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle", inst.sg.mem.nextstateindex)
        end
    },

    State{
        name = "death",
        tags = { "busy", "dead" },

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("downgrade_3")

            inst.persists = false
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst:Remove()
            end),
        },
    },
}

return StateGraph("boatbumper", states, events, "idle")
