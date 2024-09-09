local events =
{

}

local states =
{
    State{
        name = "place",
        onenter = function(inst)
            inst.SoundEmitter:PlaySound(inst.sounds.place)
            inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/large",nil,.3)
            inst.AnimState:PlayAnimation("place")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.components.health and inst.components.health:IsDead() then
                    -- NOTES(JBK): Boats can take damage during the building phase and we want to keep this to not have bullets shatter on an indestructible boat.
                    inst.sg:GoToState("ready_to_snap")
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "idle",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_full", true)
        end,

        events =
        {
            EventHandler("death", function(inst) inst.sg:GoToState("ready_to_snap") end),
        },
    },

    State{
        name = "ready_to_snap",
        onenter = function(inst)
            -- Keep this in sync with InstantlyBreakBoat.
            local ents = inst.components.walkableplatform:GetEntitiesOnPlatform()
            for ent in pairs(ents) do    
                ent:PushEvent("abandon_ship")
            end

            inst.sg:SetTimeout(0.75)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("snapping")
        end,
    },

    State{
        name = "snapping",
        onenter = function(inst)
            if inst.boat_crackle then
                local fx_boat_crackle = SpawnPrefab(inst.boat_crackle)
                fx_boat_crackle.Transform:SetPosition(inst.Transform:GetWorldPosition())
            end
            inst.AnimState:PlayAnimation("crack")
            inst.sg:SetTimeout(1)

            -- Keep this in sync with InstantlyBreakBoat.
            for k in pairs(inst.components.walkableplatform:GetPlayersOnPlatform()) do
                k:PushEvent("onpresink")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("popping") end),
        },

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)
                if inst.sounds.creak then inst.SoundEmitter:PlaySoundWithParams(inst.sounds.creak) end
                if inst.leaky then inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/fountain_small_LP", "small_leak") end
            end),
            TimeEvent(2 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySoundWithParams(inst.sounds.damage,{intensity= .1})
            end),
            TimeEvent(17 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySoundWithParams(inst.sounds.damage,{intensity= .2})
            end),
            TimeEvent(32* FRAMES, function(inst)
                inst.SoundEmitter:PlaySoundWithParams(inst.sounds.damage,{intensity= .3})
            end),
            TimeEvent(39* FRAMES, function(inst)
                inst.SoundEmitter:PlaySoundWithParams(inst.sounds.damage,{intensity= .3})
            end),
            TimeEvent(39* FRAMES, function(inst)
                if inst.sounds.creak then inst.SoundEmitter:PlaySoundWithParams(inst.sounds.creak) end
            end),
            TimeEvent(51 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySoundWithParams(inst.sounds.damage,{intensity= .4})
            end),
            TimeEvent(58 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySoundWithParams(inst.sounds.damage,{intensity= .4})
            end),
            TimeEvent(60 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySoundWithParams(inst.sounds.damage,{intensity= .5})
            end),
            TimeEvent(71 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySoundWithParams(inst.sounds.damage,{intensity= .5})
            end),
            TimeEvent(75 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySoundWithParams(inst.sounds.damage, {intensity= .6})
            end),
            TimeEvent(82 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySoundWithParams(inst.sounds.damage, {intensity= .6})
            end),
        },
    },

    State{
        name = "popping",
        tags = {"popping"},
        onenter = function(inst)
            -- Keep this in sync with InstantlyBreakBoat.
            inst:sinkloot()
            if inst.postsinkfn then
                inst:postsinkfn()
            end
            inst:Remove()
        end,
    },
}

return StateGraph("boat", states, events, "idle")
