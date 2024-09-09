require("stategraphs/commonstates")

local EXPLODE_MUST_TAGS = { "absorbpoison" }

local function PlayFlapSound(inst)
    inst.SoundEmitter:PlaySound("dontstarve/birds/wingflap_cage")
end

local function CheckRecovery(inst)
    return TheWorld.components.birdspawner ~= nil
        and TheWorld.components.toadstoolspawner == nil
end

local function TransformCanary(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local rot = inst.Transform:GetRotation()
    local burning = inst.components.burnable ~= nil and inst.components.burnable:IsBurning()
    inst:Remove()
    local canary = SpawnPrefab("canary")
    canary.Transform:SetPosition(x, y, z)
    canary.Transform:SetRotation(rot)
    if burning and canary.components.burnable ~= nil then
        canary.components.burnable:Ignite(true)
    end
end

local events =
{
    CommonHandlers.OnFreeze(),
    EventHandler("attacked", function(inst)
        if not (inst.components.health:IsDead() or inst.sg:HasStateTag("noattack") or inst.sg:HasStateTag("nohit")) then
            inst.sg:GoToState("hit")
        end
    end),
    EventHandler("death", function(inst)
        if not inst.sg:HasStateTag("nodeath") then
            inst.sg:GoToState("death")
        end
    end),
}

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("struggle_idle_pre")
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, PlayFlapSound),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle_loop")
                end
            end),
        },
    },

    State{
        name = "idle_loop",
        tags = { "idle", "canrotate" },

        onenter = function(inst, loops)
            inst.AnimState:PlayAnimation("struggle_idle_loop1")
            inst.sg.statemem.loops = loops or 0
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, PlayFlapSound),
            TimeEvent(13 * FRAMES, PlayFlapSound),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if CheckRecovery(inst) then
                        inst.sg:GoToState("recover_pre")
                    elseif math.random(2) <= inst.sg.statemem.loops then
                        inst.sg:GoToState("explode_pre")
                    else
                        inst.sg:GoToState("idle_loop", inst.sg.statemem.loops + 1)
                    end
                end
            end),
        },
    },

    State{
        name = "dropped",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            if y > .2 then
                inst.DynamicShadow:Enable(false)
            end
            inst.Transform:SetRotation(math.random(360))
            inst.AnimState:PlayAnimation("struggle_idle_pre")
        end,

        onupdate = function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            if y <= .2 then
                inst.DynamicShadow:Enable(true)
            end
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, PlayFlapSound),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle_loop")
                end
            end),
        },

        onexit = function(inst)
            inst.DynamicShadow:Enable(true)
        end,
    },

    State{
        name = "hit",
        tags = { "busy" },

        onenter = function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            if y > 1 then
                inst.sg:GoToState("fall")
                return
            end
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit")
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
        name = "fall",
        tags = { "busy" },

        onenter = function(inst)
            inst.DynamicShadow:Enable(false)
            inst.AnimState:PlayAnimation("fall_loop", true)
        end,

        onupdate = function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            if y <= .2 then
                inst.Physics:Stop()
                inst.Physics:Teleport(x, 0, z)
                inst.sg:GoToState("hit")
            end
        end,

        onexit = function(inst)
            inst.DynamicShadow:Enable(true)
        end,
    },

    State{
        name = "death",
        tags = { "busy", "nopickup" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("death")
            RemovePhysicsColliders(inst)
            inst.components.inventoryitem.canbepickedup = false
            inst.components.lootdropper:DropLoot(inst:GetPosition())
        end,
    },

    State{
        name = "explode_pre",
        tags = { "busy", "nofreeze", "noattack", "nopickup" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("struggle_idle_loop1")
            inst.AnimState:PushAnimation("struggle_idle_pst", false)
            inst.components.inventoryitem.canbepickedup = false
            inst:AddTag("NOCLICK")
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, PlayFlapSound),
            TimeEvent(13 * FRAMES, PlayFlapSound),
            TimeEvent(19 * FRAMES, PlayFlapSound),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.explode = true
                    inst.sg:GoToState("explode")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.explode then
                inst.components.inventoryitem.canbepickedup = true
                inst:RemoveTag("NOCLICK")
            end
        end,
    },

    State{
        name = "explode",
        tags = { "busy", "nofreeze", "noattack", "nopickup", "nodeath" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("struggle_explode")
        end,

        timeline =
        {
            TimeEvent(27 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/canary/death")
            end),
            TimeEvent(48 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/balloon_pop")
            end),
            TimeEvent(52 * FRAMES, function(inst)
                inst.DynamicShadow:Enable(false)
                RemovePhysicsColliders(inst)
                inst.persists = false

                local pos = inst:GetPosition()
                pos.y = 1
                local numloot = math.random(2)
                for i = 1, numloot do
                    inst.components.lootdropper:SpawnLootPrefab("feather_canary", pos)
                end

                for i, v in ipairs(TheSim:FindEntities(pos.x, 0, pos.z, 3, EXPLODE_MUST_TAGS)) do
                    v:PushEvent("poisonburst", { source = inst })
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:Remove()
                end
            end),
        },
    },

    State{
        name = "recover_pre",
        tags = { "idle" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("struggle_idle_pst")
        end,

        timeline =
        {
            TimeEvent(3 * FRAMES, PlayFlapSound),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("recover")
                end
            end),
        },
    },

    State{
        name = "recover",
        tags = { "idle" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("struggle_recovery")
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, PlayFlapSound),
            TimeEvent(12 * FRAMES, PlayFlapSound),
            TimeEvent(17 * FRAMES, function(inst)
                inst.sg:GoToState("recover_transform")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    TransformCanary(inst)
                end
            end),
        },
    },

    State{
        name = "recover_transform",
        tags = { "busy", "nofreeze", "nopickup", "nohit" },

        onenter = function(inst)
            if not inst.AnimState:IsCurrentAnimation("struggle_recovery") then
                inst.AnimState:PlayAnimation("struggle_recovery")
				inst.AnimState:SetFrame(17)
            end

            inst.components.inventoryitem.canbepickedup = false
            inst.persists = false

            local numloot = 4 + math.random(2)
            for i = 1, numloot do
                inst.components.lootdropper:SpawnLootPrefab("feather_canary")
            end
        end,

        timeline =
        {
            TimeEvent(0, PlayFlapSound),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    TransformCanary(inst)
                end
            end),
        },
    },
}

CommonStates.AddFrozenStates(states)

return StateGraph("canarypoisoned", states, events, "idle_loop")
