require("stategraphs/commonstates")



local actionhandlers =
{
    --ActionHandler(ACTIONS.HAMMER, "attack"),
}

local events =
{
    EventHandler("ck_loadcannon", function(inst, data)
        if not inst.components.health:IsDead() then
            inst.sg:GoToState("load")
        end
    end),

    EventHandler("ck_shootcannon", function(inst, data)
        if not inst.components.health:IsDead() then
            inst.sg:GoToState("shoot")
        end
    end),

    EventHandler("ck_spawn", function(inst, data)
        if not inst.components.health:IsDead() then
            inst.sg:GoToState("spawn")
        end
    end),

    EventHandler("ck_breach", function(inst, data)
        if not inst.components.health:IsDead() then
            inst.sg:GoToState("breach_pre")
        end
    end),

    EventHandler("attacked", function(inst)
        if not inst.components.health:IsDead() and (inst.sg:HasStateTag("caninterrupt") or not inst.sg:HasStateTag("busy")) then
            if inst.sg:HasStateTag("breach") then
                inst.sg:GoToState("breach_pst")
            else
                inst.sg:GoToState("hit", inst.sg:HasStateTag("loaded"))
            end
        end
    end),

    EventHandler("death", function(inst)
        if inst.sg:HasStateTag("breach") then
            inst.sg:GoToState("breach_pst")
        else
            inst.sg:GoToState("death")
        end
    end),
}

local states =
{
    State {
        name = "idle",
        tags = { "idle" },

        onenter = function(inst, loaded)
            inst.sg:AddStateTag(loaded and "loaded" or "empty")

            local anim = loaded and "idle_loaded" or "idle_empty"

            if not inst.AnimState:IsCurrentAnimation(anim) then
                inst.AnimState:PlayAnimation(anim, true)
            end

            if not loaded then
                inst:TestForReload()
            end

            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())

            inst.sg.statemem.loaded = loaded
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", inst.sg.statemem.loaded)
        end,
    },

    State{
        name = "spawn",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("spawn")
            inst.SoundEmitter:PlaySound("meta4/mortars/spawn")

            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", false)
        end,
    },

    State{
        name = "hit",
        tags = { "busy", "hit" },

        onenter = function(inst, loaded)
            inst.sg:AddStateTag(loaded and "loaded" or "empty")

            inst.AnimState:PlayAnimation(loaded and "hit_loaded" or "hit_empty")

            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())

            inst.sg.statemem.loaded = loaded
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", inst.sg.statemem.loaded)
        end,
    },

    State{
        name = "load",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("loading_loop")

            inst.SoundEmitter:PlaySound("meta4/mortars/loading")
            
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "shoot",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("shoot")
            inst.SoundEmitter:PlaySound("meta4/mortars/shoot")
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", false)
        end,
    },

    State{
        name = "breach_pre",
        tags = {"busy", "breach"},

        onenter = function(inst, pushanim)
            local platform = inst:GetBoatIntersectingPhysics()

            if platform ~= nil then
                ShakeAllCamerasOnPlatform(CAMERASHAKE.VERTICAL, .5, .03, 1, platform)
            end

            inst.AnimState:PlayAnimation("breach_pre")

            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("breach")
        end,
    },

    State{
        name = "breach",
        tags = {"idle", "breach"},

        onenter = function(inst, pushanim)
            inst.AnimState:PlayAnimation("breach_loop", true)

            inst.sg:SetTimeout(2+math.random())
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("breach_thrust")
        end,

        onupdate = function(inst,dt)
            local platform = inst:GetBoatIntersectingPhysics()

            if platform == nil then
                inst.sg:GoToState("breach_spawn")
            end
        end,
    },

    State{
        name = "breach_thrust",
        tags = {"busy", "breach"},

        onenter = function(inst, pushanim)
            inst.AnimState:PlayAnimation("breach_thrust")
            inst.SoundEmitter:PlaySound("meta4/mortars/breach_thrust")
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        onupdate = function(inst,dt)
            local platform = inst:GetBoatIntersectingPhysics()

            if platform == nil then
                inst.sg:GoToState("breach_spawn")
            end
        end,

        timeline=
        {
            TimeEvent(8*FRAMES, function(inst)
                local platform = inst:GetBoatIntersectingPhysics()

                if platform ~= nil and platform.components.health ~= nil and not platform.components.health:IsDead() then
                    SpawnPrefab("fx_dock_crackle").Transform:SetPosition(inst.Transform:GetWorldPosition())

                    platform.components.health:DoDelta(-TUNING.CRABKING_CANNONTOWER_HULL_SMASH_DAMAGE)

                    ShakeAllCamerasOnPlatform(CAMERASHAKE.SIDE, .5, .03, .75, platform)
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("breach")
        end,
    },

    State{
        name = "breach_pst",
        tags = {"busy"},

        onenter = function(inst, pushanim)
            inst.AnimState:PlayAnimation("breach_pst")

            inst.persists = false

            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        timeline=
        {
            TimeEvent(16*FRAMES, function(inst)
                local boat = inst:GetBoatIntersectingPhysics()

                if boat ~= nil then
                    boat:PushEvent("spawnnewboatleak", { pt = inst:GetPosition(), leak_size = "med_leak", playsoundfx = true })
                end
            end),
        },

        ontimeout = function(inst)
            inst:Remove()
        end,

        onexit = function(inst)
            inst:Remove()
        end,
    },

    State{
        name = "breach_spawn",
        tags = {"busy"},

        onenter = function(inst, pushanim)
            if inst.components.floater ~= nil then
                inst.components.floater:OnLandedServer()
            end

            inst.AnimState:PlayAnimation("breach_spawn")

            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", false)
        end,
    },

    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("break")

            inst.components.lootdropper:DropLoot()

            if inst.components.floater ~= nil then
                inst.components.floater:OnNoLongerLandedServer()
            end

            RemovePhysicsColliders(inst)

            local x, y, z = inst.Transform:GetWorldPosition()

            SpawnPrefab("rock_break_fx").Transform:SetPosition(x, 0, z)

            local mob = SpawnPrefab("crabking_mob")
            mob.Transform:SetPosition(x, 0, z)
            mob.sg:GoToState("break")

            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        ontimeout = function(inst)
            inst:Remove()
        end,

        onexit = function(inst)
            inst:Remove()
        end,
    },
}

return StateGraph("crabking_cannontower", states, events, "breach_spawn", actionhandlers)
