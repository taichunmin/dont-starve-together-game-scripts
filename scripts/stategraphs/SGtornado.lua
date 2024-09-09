require("stategraphs/commonstates")

local events =
{
    EventHandler("locomote", function(inst)
        local is_moving = inst.sg:HasStateTag("moving")
        local is_running = inst.sg:HasStateTag("running")
        local is_idling = inst.sg:HasStateTag("idle")

        local should_move = inst.components.locomotor:WantsToMoveForward()
        local should_run = inst.components.locomotor:WantsToRun()
        if is_moving and not should_move then
            if is_running then
                inst.sg:GoToState("run_stop")
            else
                inst.sg:GoToState("walk_stop")
            end
        elseif (is_idling and should_move) or (is_moving and should_move and is_running ~= should_run) then
            if should_run then
                if inst.sg:HasStateTag("empty") then
                    inst.sg:GoToState("spawn")
                else
                    inst.sg:GoToState("run_start")
                end
            else
                inst.sg:GoToState("walk_start")
            end
        end
    end)
    -- EventHandler("locomote", function(inst)
    --     local is_moving = inst.sg:HasStateTag("moving")
    --     local is_idling = inst.sg:HasStateTag("idle")

    --     local should_move = inst.components.locomotor:WantsToMoveForward()
    --     if is_moving and not should_move then
    --         inst.sg:GoToState("walk_stop")
    --     elseif (is_idling and should_move) then
    --      if inst.sg:HasStateTag("empty") then
    --          inst.sg:GoToState("spawn")
    --      else
    --          inst.sg:GoToState("walk_start")
    --         end
    --     end
    -- end)
}

local WORK_ACTIONS =
{
    CHOP = true,
    DIG = true,
    HAMMER = true,
    MINE = true,
}
local TARGET_TAGS = { "_combat" }
for k, v in pairs(WORK_ACTIONS) do
    table.insert(TARGET_TAGS, k.."_workable")
end
local TARGET_IGNORE_TAGS = { "INLIMBO" }

local function destroystuff(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 3, nil, TARGET_IGNORE_TAGS, TARGET_TAGS)
    for i, v in ipairs(ents) do
        --stuff might become invalid as we work or damage during iteration
        if v ~= inst.WINDSTAFF_CASTER and v:IsValid() then
            if v.components.health ~= nil and
                not v.components.health:IsDead() and
                v.components.combat ~= nil and
                v.components.combat:CanBeAttacked() and
                (TheNet:GetPVPEnabled() or not (inst.WINDSTAFF_CASTER_ISPLAYER and v:HasTag("player"))) then
                local damage =
                    inst.WINDSTAFF_CASTER_ISPLAYER and
                    v:HasTag("player") and
                    TUNING.TORNADO_DAMAGE * TUNING.PVP_DAMAGE_MOD or
                    TUNING.TORNADO_DAMAGE
                v.components.combat:GetAttacked(inst, damage, nil, "wind")
                if v:IsValid() and
                    inst.WINDSTAFF_CASTER ~= nil and inst.WINDSTAFF_CASTER:IsValid() and
                    v.components.combat ~= nil and
                    not (v.components.health ~= nil and v.components.health:IsDead()) and
                    not (v.components.follower ~= nil and
                        v.components.follower.keepleaderonattacked and
                        v.components.follower:GetLeader() == inst.WINDSTAFF_CASTER) then
                    v.components.combat:SuggestTarget(inst.WINDSTAFF_CASTER)
                end
            elseif v.components.workable ~= nil and
                v.components.workable:CanBeWorked() and
                v.components.workable:GetWorkAction() and
                WORK_ACTIONS[v.components.workable:GetWorkAction().id] then
                SpawnPrefab("collapse_small").Transform:SetPosition(v.Transform:GetWorldPosition())
                v.components.workable:WorkedBy(inst, 2)
                --v.components.workable:Destroy(inst)
            end
        end
    end
end

local states =
{
    State{
        name = "empty",
        tags = {"idle", "empty"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("empty")
        end,
    },

    State{
        name = "idle",
        tags = {"idle"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PushAnimation("tornado_loop", false)
            destroystuff(inst)
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end)
        },
    },

    State{
        name = "spawn",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("tornado_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("walk")
            end)
        },
    },

    State{
        name = "despawn",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("tornado_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst:Remove()
            end)
        },
    },

    State{
        name = "walk_start",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.sg:GoToState("walk")
        end,
    },

    State{
        name = "walk",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            inst.AnimState:PushAnimation("tornado_loop", false)
            destroystuff(inst)
        end,

        timeline =
        {
            TimeEvent(5*FRAMES, destroystuff),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("walk")
            end)
        },
    },

    State{
        name = "walk_stop",
        tags = {"canrotate"},

        onenter = function(inst)
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "run_start",
        tags = {"moving", "running", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PushAnimation("tornado_loop", false)
        end,

        timeline =
        {
            TimeEvent(5*FRAMES, destroystuff),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("run")
            end),
        },
    },

    State{
        name = "run",
        tags = {"moving", "running", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PushAnimation("tornado_loop", false)
        end,

        timeline =
        {
            TimeEvent(5*FRAMES, destroystuff),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("run")
            end),
        },
    },

    State{
        name = "run_stop",
        tags = {"idle"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PushAnimation("tornado_loop", false)
        end,

        timeline =
        {
            TimeEvent(5*FRAMES, destroystuff),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
}

return StateGraph("tornado", states, events, "empty")
