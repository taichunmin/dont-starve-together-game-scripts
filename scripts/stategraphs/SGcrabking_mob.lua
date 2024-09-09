require("stategraphs/commonstates")

------------------------------------------------------------------------------------------------------------------------------------

local AOE_RANGE_PADDING = 3
local AOE_TARGET_MUSTHAVE_TAGS = { "_combat" }
local AOE_TARGET_CANT_TAGS = { "crabking_ally", "INLIMBO", "notarget", "noattack", "flight", "invisible", "playerghost" }

local function AOEAttack(inst, dist, radius, targets)
    inst.components.combat.ignorehitrange = true

    local x, y, z = inst.Transform:GetWorldPosition()
    local cos_theta, sin_theta

    if dist ~= 0 then
        local theta = inst.Transform:GetRotation() * DEGREES
        cos_theta = math.cos(theta)
        sin_theta = math.sin(theta)

        x = x + dist * cos_theta
        z = z - dist * sin_theta
    end

    for i, v in ipairs(TheSim:FindEntities(x, y, z, radius + AOE_RANGE_PADDING, AOE_TARGET_MUSTHAVE_TAGS, AOE_TARGET_CANT_TAGS)) do
        if v ~= inst and
            not (targets and targets[v]) and
            v:IsValid() and not v:IsInLimbo() and
            not (v.components.health and v.components.health:IsDead())
        then
            local range = radius + v:GetPhysicsRadius(0)
            local x1, y1, z1 = v.Transform:GetWorldPosition()
            local dx = x1 - x
            local dz = z1 - z

            if dx * dx + dz * dz < range * range and inst.components.combat:CanTarget(v) then
                inst.components.combat:DoAttack(v)

                if targets then
                    targets[v] = true
                end
            end
        end
    end

    inst.components.combat.ignorehitrange = false
end

------------------------------------------------------------------------------------------------------------------------------------

local actionhandlers =
{
    ActionHandler(ACTIONS.ABANDON, "dive"),
}

------------------------------------------------------------------------------------------------------------------------------------

local events =
{
    CommonHandlers.OnHop(),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),

    EventHandler("onsink", function(inst, data)
        if (inst.components.health == nil or not inst.components.health:IsDead()) and not inst.sg:HasStateTag("drowning") and (inst.components.drownable ~= nil and inst.components.drownable:ShouldDrown()) then
            inst.sg:GoToState("dive_pst_water", data)
        end
    end),

    EventHandler("attacked", function(inst)
        if not inst.components.health:IsDead() then
            if not inst.sg:HasAnyStateTag("attack", "moving") then
                inst.sg:GoToState("hit")
            end
        end
    end),

    EventHandler("doattack", function(inst, data)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            -- Target CAN go invalid because SG events are buffered.
            if inst:HasTag("largecreature") then
                inst.sg:GoToState(
                    data.target:IsValid()
                    and not inst:IsNear(data.target, TUNING.CRABKING_MOB_MELEE_RANGE)
                    and "spin_attack"
                    or "attack",
                    data.target
                )
            else
                inst.sg:GoToState("attack", data.target)
            end
        end
    end),

    EventHandler("locomote", function(inst)
        if not inst.sg:HasStateTag("busy") then
            local is_moving = inst.sg:HasStateTag("moving")
            local wants_to_move = inst.components.locomotor:WantsToMoveForward()
            if not inst.sg:HasStateTag("attack") and is_moving ~= wants_to_move then
                if wants_to_move then
                    inst.sg:GoToState("premoving")
                else
                    inst.sg:GoToState("idle")
                end
            end
        end
    end),

    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
}

------------------------------------------------------------------------------------------------------------------------------------

local function PlaySound(inst, event)
    inst:PlaySound(event)
end

local function OnAnimOver(state)
    return {
        EventHandler("animover", function(inst) inst.sg:GoToState(state) end),
    }
end

local WALK_SOUND_NAME = "footstepsound"

------------------------------------------------------------------------------------------------------------------------------------

local states =
{
    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("death")


            inst.Physics:Stop()

            RemovePhysicsColliders(inst)

            inst:PlaySound("death_vocal")
            inst:PlaySound("death_fx")

            inst.components.lootdropper:DropLoot()
        end,
    },

    State{
        name = "premoving",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk_pre")
        end,

        events = OnAnimOver("moving"),
    },

    State{
        name = "moving",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PushAnimation("walk_loop")

            if not inst.SoundEmitter:PlayingSound(WALK_SOUND_NAME) then
                inst:PlaySound("walk", WALK_SOUND_NAME)
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.keepmoving = true
                    inst.sg:GoToState("moving")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.keepmoving then
                inst.SoundEmitter:KillSound(WALK_SOUND_NAME)
            end
        end,
    },

    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst, start_anim)
            if math.random() < 0.3 then
                inst.sg:SetTimeout(math.random()*2 + 2)
            end

            inst.components.locomotor:Stop()

            if start_anim then
                inst.AnimState:PlayAnimation(start_anim)
                inst.AnimState:PushAnimation("idle", true)
            else
                inst.AnimState:PlayAnimation("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("taunt")
        end,
    },

    State{
        name = "taunt",
        tags = {"busy"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("taunt")
        end,
        timeline=
        {
            FrameEvent(14, function(inst)  inst:PlaySound("taunt_fx_f14") end),
        },
        events = OnAnimOver("idle"),
    },

    State{
        name = "attack",
        tags = {"attack", "busy"},

        onenter = function(inst, target)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("atk1")
            inst:PlaySound("atk_vocal")


            inst.components.combat:StartAttack()
            inst.sg.statemem.target = target
        end,

        timeline=
        {
            FrameEvent(18, function(inst)
                inst:PlaySound("f18_atk_fx")
                inst.components.combat:DoAttack(inst.sg.statemem.target)
            end),
        },

        events = OnAnimOver("idle"),
    },

    State{
        name = "spin_attack",
        tags = {"attack", "busy", "spinning", "jumping"},

        onenter = function(inst, target)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)

            inst.AnimState:PlayAnimation("atk_pre")

            inst.components.combat:StartAttack()

            inst:ForceFacePoint(target.Transform:GetWorldPosition())

            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        onexit = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            inst.Physics:ClearMotorVelOverride()
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("spin_attack_loop")
        end,
    },

    State{
        name = "spin_attack_loop",
        tags = {"attack", "canrotate", "busy", "spinning", "jumping"},

        onenter = function(inst, targets)
            inst.sg:SetTimeout(0.7)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)
            inst.Physics:SetMotorVelOverride(8,0,0)
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk_loop",true)

            inst.SoundEmitter:PlaySound("meta4/crabcritter/atk2_spin_lp","spin")

            inst.sg.statemem.targets = targets or {}
        end,

        onupdate = function(inst, dt)
            AOEAttack(inst, -0.4, 2.5, inst.sg.statemem.targets)
        end,

        onexit = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            inst.Physics:ClearMotorVelOverride()
            inst.SoundEmitter:KillSound("spin")
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("spin_attack_pst")
        end,
    },

    State{
        name = "spin_attack_pst",
        tags = {"attack", "canrotate", "busy", "spinning"},

        onenter = function(inst, target)
            inst.AnimState:PlayAnimation("atk_pst")
        end,

        events = OnAnimOver("taunt"),
    },

    State{
        name = "hit",

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("hit")
            inst:PlaySound("hit_vocal")
            inst:PlaySound("hit")
        end,

        events = OnAnimOver("idle"),
    },

    State{
        name = "break",
        tags = { "busy", "nosleep", "nofreeze", "noattack" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("break")
            inst.Physics:Stop()
        end,

        events=
        {
            EventHandler("animover", function(inst)
                local is_ocean = TheWorld.Map:IsOceanAtPoint(inst.Transform:GetWorldPosition())

                inst.sg:GoToState(is_ocean and "break_water" or "break_land")
            end ),
        },
    },

    State{
        name = "break_water",
        tags = { "busy", "nosleep", "nofreeze", "noattack" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("break_water")

            inst:PlaySound("break_water_vocal")

            inst.persists = false

            SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())

            if inst.DynamicShadow ~= nil then
                inst.DynamicShadow:Enable(false)
            end
        end,

        timeline =
        {
            TimeEvent(22*FRAMES, function(inst)
                inst:PlaySound("break_water_fx_f22")
            end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst:Remove() end),
        },
    },

    State{
        name = "break_land",
        tags = { "busy" },

        onenter = function(inst)
            inst:PlaySound("break_land_vocal")
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("break_land")
        end,

        timeline =
        {
            TimeEvent(22*FRAMES, function(inst)
                inst:PlaySound("break_land_fx_f22")
            end),
        },

        events = OnAnimOver("idle"),
    },

    State{
        name = "dive",
        tags = {"busy", "nomorph", "nosleep", "nofreeze", "noattack"},

        onenter = function(inst)
            local platform = inst:GetCurrentPlatform()
            if platform ~= nil then
                local pt = inst:GetPosition()
                local angle = platform:GetAngleToPoint(pt)
                inst.Transform:SetRotation(angle)
            end

            inst:PlaySound("dive_vocal")
            inst:PlaySound("dive_fx")

            inst.AnimState:PlayAnimation("dive")
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)
        end,

        timeline =
        {
            TimeEvent(10*FRAMES, function(inst)
                inst.sg.statemem.collisionmask = inst.Physics:GetCollisionMask()

                inst.Physics:SetCollisionMask(COLLISION.GROUND)

                if not TheWorld.ismastersim then
                    inst.Physics:SetLocalCollisionMask(COLLISION.GROUND)
                end

                inst.Physics:SetMotorVelOverride(5 - inst.Transform:GetScale(), 0, 0)
            end),

            TimeEvent(30*FRAMES, function(inst)
                inst.Physics:Stop()
                SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())
            end),
        },

        onexit = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)

            inst.Physics:ClearMotorVelOverride()
            inst.Physics:ClearLocalCollisionMask()

            if inst.sg.statemem.collisionmask ~= nil then
                inst.Physics:SetCollisionMask(inst.sg.statemem.collisionmask)
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                local x, y, z = inst.Transform:GetWorldPosition()
                local on_land = TheWorld.Map:IsVisualGroundAtPoint(x, y, z) or inst:GetCurrentPlatform()

                inst.sg:GoToState(on_land and "dive_pst_land" or "dive_pst_water")
            end),
        },
    },

    State{
        name = "dive_pst_land",
        tags = {"busy"},

        onenter = function(inst)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end

            inst.AnimState:PlayAnimation("dive_pst_land")
        end,

        events = OnAnimOver("idle"),
    },

    State{
        name = "dive_pst_water",
        tags = { "busy", "nopredict", "nomorph", "drowning", "nointerrupt", "nowake" },

        onenter = function(inst, data)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("dive_pst_water")

            inst.persists = false

            SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())

            if inst.DynamicShadow ~= nil then
                inst.DynamicShadow:Enable(false)
            end
        end,

        events=
        {
            EventHandler("animover", function(inst) inst:Remove() end),
        },
    },

    -- NOTES(DiogoW): Used by boat hop states.
    State{
        name = "sink",
        tags = { "busy", "nopredict", "nomorph", "drowning", "nointerrupt", "nowake" },

        onenter = function(inst)
            inst.sg:GoToState("dive_pst_water")
        end,
    }
}

CommonStates.AddSleepStates(states,
{
    starttimeline = {
        SoundFrameEvent(0, "meta4/crabcritter/sleep_pre_vocal"),
        SoundFrameEvent(14, "meta4/crabcritter/sleep_pre_fx_f14"),



    },
    sleeptimeline ={
        SoundFrameEvent(35, "meta4/crabcritter/sleep_lp_vocal"),
    },
    waketimeline = {
        SoundFrameEvent(0, "meta4/crabcritter/sleep_pst_vocal"),
        SoundFrameEvent(8, "meta4/crabcritter/sleep_pst_fx_f8"),
    },
})

CommonStates.AddFrozenStates(states)
CommonStates.AddHopStates(states, true, { pre = "boat_jump_pre", loop = "boat_jump_loop", pst = "boat_jump_pst"})

return StateGraph("crabking_mob", states, events, "idle", actionhandlers)
