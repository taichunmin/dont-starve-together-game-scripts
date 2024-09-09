require("stategraphs/commonstates")

local actionhandlers =
{

}

local events =
{
    CommonHandlers.OnSleepEx(),
    CommonHandlers.OnWakeEx(),

    CommonHandlers.OnFreezeEx(),

    EventHandler("attacked", function(inst, data)
        if inst.components.health ~= nil and not inst.components.health:IsDead()
                and (not inst.sg:HasStateTag("busy") or
                    inst.sg:HasStateTag("caninterrupt") or
                    inst.sg:HasStateTag("frozen")) then
            if data ~= nil and data.weapon ~= nil and data.weapon:HasTag("hammer") then
                inst.sg:GoToState("stunned")
            else
                inst.sg:GoToState("hit")
            end
        end
    end),
    CommonHandlers.OnDeath(),

    CommonHandlers.OnLocomote(true, false),

    EventHandler("onhop", function(inst, data)
        if inst.components.health ~= nil and not inst.components.health:IsDead() and
                not (inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("jumping")) then
            if data ~= nil and data.hop_pos ~= nil then
                inst.sg:GoToState("hop", data.hop_pos)
            else
                inst.sg:GoToState("idle")
            end
        end
    end),

    EventHandler("stunbomb", function(inst)
        inst.sg:GoToState("stunned")
    end),
}

local function return_to_idle(inst)
    if inst.AnimState:AnimDone() then
        inst.sg:GoToState("idle")
    end
end

local states =
{
    State{
        name = "stunned",
        tags = {"busy", "stunned"},

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("hit")
            inst.AnimState:PushAnimation("stunned_loop", true)
            inst.sg:SetTimeout(GetRandomWithVariance(5, 2))

            inst.components.inventoryitem.canbepickedup = true
        end,

        timeline =
        {
            TimeEvent(0, function(inst)
                inst.SoundEmitter:PlaySound(inst._hit_sound)
            end),
        },

        onexit = function(inst)
            inst.components.inventoryitem.canbepickedup = false
        end,

        ontimeout = function(inst)
            inst.SoundEmitter:PlaySound("hookline_2/creatures/wobster/scared")
            return_to_idle(inst)
        end,
    },

    State{
        name = "hop",
        tags = { "autopredict", "busy", "doing", "jumping", "nointerrupt", "nomorph", "nosleep" },

        onenter = function(inst, hop_location)
            inst.components.locomotor:Stop()

            inst:ForceFacePoint(hop_location:Get())
            inst.AnimState:PlayAnimation("jump", false)
            inst.AnimState:PushAnimation("jump_loop", true)

            -- Extend the hop slightly, since it looks better.
            inst.sg.statemem.hop_location = hop_location + (hop_location - inst:GetPosition()):Normalize()

            inst:AddTag("ignorewalkableplatforms")
            inst.sg:SetTimeout(5)
        end,

        onupdate = function(inst, dt)
            local hop_target = inst.sg.statemem.hop_location
            local ix, iy, iz = inst.Transform:GetWorldPosition()
            local dx, dz = hop_target.x - ix, hop_target.z - iz
            local ddist = math.max(VecUtil_Length(dx, dz), 0.0001)

            local speed_dist = math.min(dt * 8, ddist)
            dx = speed_dist * dx / ddist
            dz = speed_dist * dz / ddist

            inst.Physics:TeleportOffset(dx, 0, dz)

            if ddist <= dt then
                if inst:IsOnOcean(false) then
                    inst:_enter_water()
                else
                    inst.sg:GoToState("hop_pst")
                end
            end
        end,

        ontimeout = function(inst)
            if inst:IsOnOcean(false) then
                inst:_enter_water()
            else
                inst.sg:GoToState("hop_pst")
            end
        end,

        onexit = function(inst)
            inst:RemoveTag("ignorewalkableplatforms")
        end,
    },

    State{
        name = "hop_pst",
        tags = { "autopredict", "busy", "doing", "jumping", "nointerrupt", "nomorph", "nosleep" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("jump_pst", false)
        end,

        events =
        {
            EventHandler("animover", return_to_idle),
        },
    },

    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("death")
            RemovePhysicsColliders(inst)
            if inst._fades_out then
                inst.components.lootdropper:DropLoot(inst:GetPosition())
            end
        end,

        timeline =
        {
            TimeEvent(0, function(inst)
                inst.SoundEmitter:PlaySound("hookline_2/creatures/wobster/death")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if not inst._fades_out then
                    -- NOTE: we assume there's only one loot prefab for anything specifying
                    -- not to fling loot.
                    local loot_prefab = inst.fish_def.loot[1]
                    SpawnPrefab(loot_prefab).Transform:SetPosition(inst.Transform:GetWorldPosition())
                    inst:Remove()
                end
            end),
        },

        onexit = function(inst)
            inst:Remove()
        end,
    },
}

CommonStates.AddSleepExStates(states)

CommonStates.AddFrozenStates(states)

CommonStates.AddHitState(states,
{
    TimeEvent(0, function(inst)
        inst.SoundEmitter:PlaySound(inst._hit_sound)
    end),
})

CommonStates.AddIdle(states, false, "idle")

local function play_run_step(inst)
    PlayFootstep(inst, 0.25)
end

CommonStates.AddRunStates(states,
{
    starttimeline =
    {
        TimeEvent(2*FRAMES, play_run_step),
    },
    runtimeline =
    {
        TimeEvent(4*FRAMES, play_run_step),
        TimeEvent(8*FRAMES, play_run_step),
    },
    endtimeline =
    {
        TimeEvent(2*FRAMES, play_run_step),
    },
})

return StateGraph("wobster_land", states, events, "idle", actionhandlers)
