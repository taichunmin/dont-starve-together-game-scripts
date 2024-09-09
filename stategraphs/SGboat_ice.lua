local events =
{

}

local function do_boat_crackle(inst)
    if not inst.boat_crackle then return end

    local fx_boat_crackle = SpawnPrefab(inst.boat_crackle)
    local radius = math.sqrt(math.random()) * inst.components.walkableplatform.platform_radius
    local angle = math.random() * TWOPI
    local offset_vector = Vector3(math.cos(angle) * radius, 0, math.sin(angle) * radius)
    fx_boat_crackle.Transform:SetPosition((inst:GetPosition() + offset_vector):Get())
end

local states =
{
    State{
        name = "place",
        onenter = function(inst)
            inst.SoundEmitter:PlaySound(inst.sounds.place)
            inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/large", nil, .3)
            inst.AnimState:PlayAnimation("place")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                -- NOTES(JBK): Boats can take damage during the building phase,
                -- and we want to keep this to not have bullets shatter on an indestructible boat.
                local next_state = (inst.components.health:IsDead() and "ready_to_snap")
                    or "idle"
                inst.sg:GoToState(next_state)
            end),
        },
    },

    State{
        name = "idle",
        onenter = function(inst)
            inst.sg.statemem.idle_level = inst:GetIdleLevel()
            inst.AnimState:PlayAnimation("idle"..inst.sg.statemem.idle_level)
        end,

        events =
        {
            EventHandler("healthdelta", function(inst)
                local previous_idle_level = inst.sg.statemem.idle_level
                local new_idle_level = inst:GetIdleLevel()
                if previous_idle_level ~= new_idle_level then
                    inst.sg.statemem.idle_level = new_idle_level
                    inst.AnimState:PlayAnimation("cracked"..(new_idle_level - 1))
                    inst.AnimState:PushAnimation("idle"..new_idle_level)
                end
            end),
            EventHandler("death", function(inst)
                inst.sg:GoToState("ready_to_snap")
            end),
        },
    },

    State{
        name = "ready_to_snap",
		tags = { "dead" },
        onenter = function(inst)
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
		tags = { "dead" },
        onenter = function(inst)
            if inst.boat_crackle then
                local fx_boat_crackle = SpawnPrefab(inst.boat_crackle)
                fx_boat_crackle.Transform:SetPosition(inst.Transform:GetWorldPosition())
            end
            inst.AnimState:PlayAnimation("idle3")

            local players_on_platform = inst.components.walkableplatform:GetPlayersOnPlatform()
            for player_on_platform in pairs(players_on_platform) do
                player_on_platform:PushEvent("onpresink")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("popping")
            end),
        },

        timeline =
        {
            FrameEvent(0, function(inst)
                if inst.sounds.creak then
                    inst.SoundEmitter:PlaySoundWithParams(inst.sounds.creak)
                end
                if inst.leaky then
                    inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/fountain_small_LP", "small_leak")
                end
            end),
            FrameEvent(2, function(inst)
                inst.SoundEmitter:PlaySoundWithParams(inst.sounds.damage,{intensity= .1})
                do_boat_crackle(inst)
            end),
            FrameEvent(17, function(inst)
                inst.SoundEmitter:PlaySoundWithParams(inst.sounds.damage,{intensity= .2})
                do_boat_crackle(inst)
            end),
            FrameEvent(32, function(inst)
                inst.SoundEmitter:PlaySoundWithParams(inst.sounds.damage,{intensity= .3})
                do_boat_crackle(inst)
            end),
            FrameEvent(39, function(inst)
                inst.SoundEmitter:PlaySoundWithParams(inst.sounds.damage,{intensity= .3})
                if inst.sounds.creak then
                    inst.SoundEmitter:PlaySoundWithParams(inst.sounds.creak)
                end
                do_boat_crackle(inst)
            end),
            FrameEvent(51, function(inst)
                inst.SoundEmitter:PlaySoundWithParams(inst.sounds.damage,{intensity= .4})
                do_boat_crackle(inst)
            end),
            FrameEvent(58, function(inst)
                inst.SoundEmitter:PlaySoundWithParams(inst.sounds.damage,{intensity= .4})
                do_boat_crackle(inst)
            end),
            FrameEvent(60, function(inst)
                inst.SoundEmitter:PlaySoundWithParams(inst.sounds.damage,{intensity= .5})
                do_boat_crackle(inst)
            end),
            FrameEvent(71, function(inst)
                inst.SoundEmitter:PlaySoundWithParams(inst.sounds.damage,{intensity= .5})
                do_boat_crackle(inst)
            end),
            FrameEvent(75, function(inst)
                inst.SoundEmitter:PlaySoundWithParams(inst.sounds.damage, {intensity= .6})
                do_boat_crackle(inst)
            end),
            FrameEvent(82, function(inst)
                inst.SoundEmitter:PlaySoundWithParams(inst.sounds.damage, {intensity= .6})
                do_boat_crackle(inst)
            end),
        },
    },

    State{
        name = "popping",
        onenter = function(inst)
            inst:sinkloot()
            if inst.postsinkfn then
                inst:postsinkfn()
            end
            inst:Remove()
        end,
    },
}

return StateGraph("boat_ice", states, events, "idle")
