local states=
{

    State{
        name = "gnash_pre",
        tags = {"gnash"},
        onenter = function(inst, data)
            if data and data.push ~= nil and data.skippre ~= nil then
                if inst.monster and data.skippre == false then
                    if data.push then
                        inst.AnimState:PushAnimation(inst.anims.swayaggropre, false)
                    else
                        inst.AnimState:PlayAnimation(inst.anims.swayaggropre, false)
                    end
                elseif inst.monster then
                    inst.sg:GoToState("gnash")
                else
                    inst.sg:GoToState("empty")
                end
            else
                if inst.monster then
                    inst.sg:GoToState("gnash")
                else
                    inst.sg:GoToState("empty")
                end
            end
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("gnash") end),
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("gnash") end),
        }
    },

    State{
        name = "gnash",
        tags = {"gnash"},
        onenter = function(inst, push)
            if inst.monster then
                inst.AnimState:PushAnimation(inst.anims.swayaggro, false)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/deciduous/angry")
            else
                inst.sg:GoToState("empty")
            end
        end,

        events=
        {
            EventHandler("animqueueover", function(inst)
                if inst.monster then
                    inst.sg:GoToState("gnash_pst")
                else
                    inst.sg:GoToState("empty")
                end
            end)
        }
    },

    State{
        name = "gnash_pst",
        tags = {},
        onenter = function(inst, push)
            if inst.monster then
                inst.AnimState:PushAnimation(inst.anims.swayaggropst, false)
            else
                inst.sg:GoToState("empty")
            end
        end,

        events=
        {
            EventHandler("animqueueover", function(inst)
                if inst.monster then
                    if math.random() <= .4 then
                        inst.sg:GoToState("gnash_pre", {push=false, skippre=false})
                    else
                        inst.sg:GoToState("gnash_idle")
                    end
                else
                    inst.sg:GoToState("empty")
                end
            end)
        }
    },

    State{
        name = "chop_pst",
        tags = {},
        onenter = function(inst, push)
            if inst.monster then
                inst.AnimState:PushAnimation("chop_pst_tall_monster", false)
            else
                inst.sg:GoToState("empty")
            end
        end,

        events=
        {
            EventHandler("animqueueover", function(inst)
                if inst.monster then
                    if math.random() <= .6 then
                        inst.sg:GoToState("gnash_pre", {push=false, skippre=false})
                    else
                        inst.sg:GoToState("gnash_idle")
                    end
                else
                    inst.sg:GoToState("empty")
                end
            end)
        }
    },

    State{
        name = "gnash_idle",
        tags = {"idle"},
        onenter = function(inst)
            if inst.monster then
                if math.random() < .4 then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/deciduous/rustle")
                end
                inst.AnimState:PushAnimation(inst.anims.swayaggroloop, false)
            else
                inst.sg:GoToState("empty")
            end
        end,

        events=
        {
            EventHandler("animqueueover", function(inst)
                if inst.monster then
                    if inst.components.deciduoustreeupdater and not inst.components.deciduoustreeupdater.monster_target and not inst.components.deciduoustreeupdater.last_monster_target then
                        inst.sg:GoToState("gnash_idle")
                    else
                        inst.sg:GoToState("gnash_pre", {push=false, skippre=false})
                    end
                else
                    inst.sg:GoToState("empty")
                end
            end),
        },
    },

    State{
        name = "burning_pre",
        tags = {"busy", "burning"},
        onenter = function(inst)
            inst.AnimState:PushAnimation("sway_agro_pre", false)
        end,
        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("burning") end),
        }
    },

    State{
        name = "burning",
        tags = {"busy", "burning"},
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/deciduous/hurt_fire")
            inst.AnimState:PlayAnimation("sway_loop_agro", false)
        end,
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("burning_pst") end),
        }
    },

    State{
        name = "burning_pst",
        tags = {"busy", "burning"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("sway_agro_pst", false)
        end,
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("burning_pre") end),
        }
    },

	State{
        name = "empty",
        onenter = function()
        end,
    },
}


return StateGraph("deciduoustree", states, {}, "empty")