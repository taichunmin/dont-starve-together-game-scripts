require "stategraphs/commonstates"

local PHYSICS_RADIUS = .3
local DAMAGE_RADIUS_PADDING = .5

local function EmergeLaunch(inst, launcher, basespeed, startheight, startradius)
    local x0, y0, z0 = launcher.Transform:GetWorldPosition()
    local x1, y1, z1 = inst.Transform:GetWorldPosition()
    local dx, dz = x1 - x0, z1 - z0
    local dsq = dx * dx + dz * dz
    local angle
    if dsq > 0 then
        local dist = math.sqrt(dsq)
        angle = math.atan2(dz / dist, dx / dist) + (math.random() * 20 - 10) * DEGREES
    else
        angle = TWOPI * math.random()
    end
    local sina, cosa = math.sin(angle), math.cos(angle)
    local speed = basespeed + math.random()
    inst.Physics:Teleport(x0 + startradius * cosa, startheight, z0 + startradius * sina)
    inst.Physics:SetVel(cosa * speed, speed * 5 + math.random() * 2, sina * speed)
end

local COLLAPSIBLE_WORK_ACTIONS =
{
    CHOP = true,
    DIG = true,
    HAMMER = true,
    MINE = true,
}
local COLLAPSIBLE_TAGS = { "_combat", "pickable", "NPC_workable" }
for k, v in pairs(COLLAPSIBLE_WORK_ACTIONS) do
    table.insert(COLLAPSIBLE_TAGS, k.."_workable")
end
local NON_COLLAPSIBLE_TAGS = { "fossil", "flying", "shadow", "ghost", "locomotor", "FX", "NOCLICK", "DECOR", "INLIMBO" }
local TOSS_MUST_TAGS = { "_inventoryitem" }
local TOSS_CANT_TAGS = { "locomotor", "INLIMBO" }

local function DoDamage(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, 0, z, PHYSICS_RADIUS + DAMAGE_RADIUS_PADDING, nil, NON_COLLAPSIBLE_TAGS, COLLAPSIBLE_TAGS)
    for i, v in ipairs(ents) do
        if v:IsValid() then
            local dist = PHYSICS_RADIUS + v:GetPhysicsRadius(DAMAGE_RADIUS_PADDING)
            if v:GetDistanceSqToPoint(x, 0, z) < dist * dist then
                local isworkable = false
                if v.components.workable ~= nil then
                    local work_action = v.components.workable:GetWorkAction()
                    --V2C: nil action for NPC_workable (e.g. campfires)
                    --     allow digging spawners (e.g. rabbithole)
                    isworkable = (
                        (work_action == nil and v:HasTag("NPC_workable")) or
                        (v.components.workable:CanBeWorked() and work_action ~= nil and COLLAPSIBLE_WORK_ACTIONS[work_action.id])
                    )
                end
                if isworkable then
                    v.components.workable:Destroy(inst)
                    if v:IsValid() and v:HasTag("stump") then
                        v:Remove()
                    end
                elseif v.components.pickable ~= nil
                    and v.components.pickable:CanBePicked()
                    and not v:HasTag("intense") then
					v.components.pickable:Pick(inst)
                elseif v.components.combat ~= nil
                    and v.components.health ~= nil
                    and not v.components.health:IsDead()
                    and v.components.locomotor == nil
                    and not inst:HasTag("epic") then
                    v.components.health:Kill()
                end
            end
        end
    end

    local totoss = TheSim:FindEntities(x, 0, z, PHYSICS_RADIUS + DAMAGE_RADIUS_PADDING, TOSS_MUST_TAGS, TOSS_CANT_TAGS)
    for i, v in ipairs(totoss) do
        if v.components.mine ~= nil then
            v.components.mine:Deactivate()
        end
        if not v.components.inventoryitem.nobounce and v.Physics ~= nil and v.Physics:IsActive() then
            local dist = PHYSICS_RADIUS + v:GetPhysicsRadius(0)
            if v:GetDistanceSqToPoint(x, 0, z) < dist * dist then
                EmergeLaunch(v, inst, .4, .1, PHYSICS_RADIUS + v:GetPhysicsRadius(0))
            end
        end
    end
end

local events =
{
    EventHandler("death", function(inst)
        if not inst.sg:HasStateTag("dead") then
            inst.sg:GoToState("death")
        end
    end),
    EventHandler("stalkerconsumed", function(inst)
        if not inst.sg:HasStateTag("dead") then
            inst.sg:GoToState("death", "eaten")
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
            if not inst.AnimState:IsCurrentAnimation("idle") then
                inst.AnimState:PlayAnimation("idle", true)
            end
        end,

        events =
        {
            EventHandler("locomote", function(inst)
                if inst.components.locomotor:WantsToMoveForward() then
                    inst.sg:GoToState("walk")
                end
            end),
        },
    },

    State{
        name = "walk",
        tags = { "moving", "canrotate" },

        onenter = function(inst)
            if inst.movestarttime ~= nil then
                inst.components.locomotor:StopMoving()
                inst.sg:SetTimeout(inst.movestarttime)
            else
                inst.components.locomotor:WalkForward()
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/minion/step")
                if inst.movestoptime ~= nil then
                    inst.sg:SetTimeout(inst.movestoptime)
                end
            end
            inst.AnimState:PlayAnimation("walk")
        end,

        ontimeout = function(inst)
            if inst.movestarttime ~= nil then
                inst.components.locomotor:WalkForward()
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/minion/step")
            else
                inst.components.locomotor:StopMoving()
            end
        end,

        events =
        {
            EventHandler("locomote", function(inst)
                if inst.components.locomotor:WantsToMoveForward() then
                    if inst.sg.statemem.stopped then
                        inst.sg.statemem.stopped = nil
                        inst.sg:RemoveStateTag("idle")
                        inst.sg:AddStateTag("moving")
                        inst.sg:AddStateTag("canrotate")
                    end
                elseif not inst.sg.statemem.stopped then
                    inst.sg.statemem.stopped = true
                    inst.sg:RemoveStateTag("moving")
                    inst.sg:RemoveStateTag("canrotate")
                    inst.sg:AddStateTag("idle")
                    inst.components.locomotor:StopMoving()
                end
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState(inst.sg.statemem.stopped and "idle" or "walk")
                end
            end),
        },
    },

    State{
        name = "emerge",
        tags = { "busy", "noattack" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("spawn")
            inst.DynamicShadow:Enable(false)
            inst.sg:SetTimeout(inst.emergeimmunetime)
        end,

        timeline =
        {
            TimeEvent(0, DoDamage),
        },

        ontimeout = function(inst)
            inst.sg.statemem.emerging = true
            inst.sg:GoToState("emerge2")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.emerging then
                inst.DynamicShadow:Enable(true)
            end
        end,
    },

    State{
        name = "emerge2",
        tags = { "busy" },

        onenter = function(inst)
            inst.sg:SetTimeout(inst.emergeshadowtime - inst.emergeimmunetime)
        end,

        ontimeout = function(inst)
            inst.DynamicShadow:Enable(true)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.DynamicShadow:Enable(true)
        end,
    },

    State{
        name = "death",
        tags = { "busy", "dead" },

        onenter = function(inst, anim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation(anim or "hit")
            inst.Physics:SetActive(false)
            inst:AddTag("NOCLICK")
            inst.persists = false
        end,

        timeline =
        {
            TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/minion/hit") end),
            TimeEvent(4 * FRAMES, function(inst)
                inst.DynamicShadow:Enable(false)
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

        onexit = function(inst)
            --should NOT reach here
            inst:RemoveTag("NOCLICK")
            inst.DynamicShadow:Enable(true)
            inst.Physics:SetActive(true)
        end,
    },
}

return StateGraph("stalker_minion", states, events, "idle")
