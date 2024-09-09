require("stategraphs/commonstates")

local events =
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnDeath(),

    EventHandler("doattack", function(inst, data)
        if not inst.sg:HasStateTag("busy") and not inst.components.health:IsDead() then
            inst.sg:GoToState("attack", data.target)
        end
    end),

    EventHandler("attacked", function(inst, data)
        if not (inst.sg:HasAnyStateTag("attack", "hit", "noattack", "jumping", "taunt") or
                inst.components.health:IsDead()) then
            inst.sg:GoToState("hit", data)
        end
    end),

    EventHandler("try_jump", function(inst, jump_position)
        if not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("jump_pre", jump_position)
        end
    end),

    EventHandler("do_despawn", function(inst)
        inst.persists = false
        inst.sg.mem.despawning = true
    end),
}

local function go_to_idle(inst)
    inst.sg:GoToState("idle")
end

local states =
{
    State {
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            if inst.sg.mem.despawning then
                inst.sg:GoToState("despawn_pre")
                return
            end

            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("idle")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State {
        name = "death",
        tags = {"busy", "noattack"},

        onenter = function(inst, data)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("death_pre")
            inst.AnimState:PushAnimation("death", false)
            inst.SoundEmitter:PlaySound(inst.sounds.death)

            inst:_RemoveCharacterPhysics(inst)

            inst.sg.statemem.killer = (data and data.afflicter) or nil
        end,

        timeline =
        {
            FrameEvent(12, function(inst)
                inst.persists = false

                local my_position = inst:GetPosition()

                local bomb = SpawnPrefab("fused_shadeling_bomb")
                bomb.Transform:SetPosition(my_position:Get())
                if inst.sg.statemem.killer and inst.sg.statemem.killer:IsValid() then
                    bomb:PushEvent("setexplosiontarget", inst.sg.statemem.killer)
                end

                inst.components.lootdropper:DropLoot(my_position)
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst:Remove()
            end),
        },
    },

    State {
        name = "jump_pre",
        tags = {"busy", "jumping"},

        onenter = function(inst, jump_target)
            if not jump_target then
                go_to_idle(inst)
                return
            end

            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("jump_pre")
            inst.SoundEmitter:PlaySound(inst.sounds.jump_pre)

            inst.components.timer:StartTimer("jump_cooldown", GetRandomWithVariance(1.0, 0.2)*TUNING.FUSED_SHADELING_JUMP_COOLDOWN)

            inst.Transform:SetRotation(inst:GetAngleToPoint(jump_target:Get()))
        end,

        timeline =
        {
            FrameEvent(12, function(inst)
                inst.sg.statemem.jumpspeed_set = true

                inst.components.locomotor:Stop()
                inst.components.locomotor:EnableGroundSpeedMultiplier(false)
                inst.Physics:SetMotorVelOverride(TUNING.FUSED_SHADELING_JUMPSPEED, 0, 0)

                inst:_RemoveCharacterPhysics(inst)
            end),
            FrameEvent(14, function(inst)
                inst.sg:AddStateTag("noattack")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("jump")
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.jumpspeed_set then
                inst.Physics:ClearMotorVelOverride()
                inst.components.locomotor:Stop()
                inst.components.locomotor:EnableGroundSpeedMultiplier(true)

                inst:_ResetCharacterPhysics()
            end
        end,
    },

    State {
        name = "jump",
        tags = {"busy", "jumping", "noattack"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)
            inst.Physics:SetMotorVelOverride(TUNING.FUSED_SHADELING_JUMPSPEED, 0, 0)

            inst:_RemoveCharacterPhysics(inst)

            inst.AnimState:PlayAnimation("jump")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("jump_pst")
            end),
        },

        onexit = function(inst)
            inst.Physics:ClearMotorVelOverride()
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)

            inst:_ResetCharacterPhysics()
        end,
    },

    State {
        name = "jump_pst",
        tags = {"busy", "jumping", "noattack"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)

            inst.sg.statemem.speed = TUNING.FUSED_SHADELING_JUMPSPEED
            inst.Physics:SetMotorVelOverride(TUNING.FUSED_SHADELING_JUMPSPEED, 0, 0)

            inst:_RemoveCharacterPhysics(inst)

            inst.AnimState:PlayAnimation("jump_pst")

            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() + 5*FRAMES)
        end,

        ontimeout = function(inst)
            if not inst.components.combat:TryAttack() then
                go_to_idle(inst)
            end
        end,

        onupdate = function(inst, dt)
            if not inst.sg.statemem.finished_jumping then
                inst.sg.statemem.speed = 0.75 * inst.sg.statemem.speed
                inst.Physics:SetMotorVelOverride(inst.sg.statemem.speed, 0, 0)
            end
        end,

        timeline =
        {
            FrameEvent(2, function(inst)
                inst.sg:RemoveStateTag("noattack")
            end),
            FrameEvent(3, function(inst)
                inst.sg.statemem.finished_jumping = true

                inst.Physics:ClearMotorVelOverride()
                inst.components.locomotor:Stop()
                inst.components.locomotor:EnableGroundSpeedMultiplier(true)

                inst:_ResetCharacterPhysics()
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.finished_jumping then
                inst.Physics:ClearMotorVelOverride()
                inst.components.locomotor:Stop()
                inst.components.locomotor:EnableGroundSpeedMultiplier(true)

                inst:_ResetCharacterPhysics()
            end
        end,
    },

    State {
        name = "spawn_delay",
        tags = { "busy", "noattack", "temp_invincible", "invisible" },

        onenter = function(inst, time)
            inst.components.locomotor:Stop()
            inst.Physics:SetActive(false)
            inst:Hide()
            inst:AddTag("NOCLICK")

            inst.sg:SetTimeout(time or FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("appear")
        end,

        onexit = function(inst)
            inst.Physics:SetActive(true)
            inst:Show()
            inst:RemoveTag("NOCLICK")
        end,
    },

    State {
        name = "attack",
        tags = {"attack", "busy"},

        onenter = function(inst, target)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("attack")

            inst.components.combat:StartAttack()

            inst.sg.statemem.target = target
        end,

        timeline = {
            FrameEvent(6, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.attack)
            end),
            FrameEvent(14, function(inst)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
            end),
        },

        events = {
            EventHandler("animover", go_to_idle),
        },
    },

    State {
        name = "hit",
        tags = {"busy", "hit"},

        onenter = function(inst, data)
            inst.components.locomotor:StopMoving()

            if (data and data.weapon and (data.weapon:HasTag("lighter") or data.weapon:HasTag("rangedlighter"))) then
                inst.sg.statemem.attacked_by_lighter = true
            end

            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound(inst.sounds.hit)
        end,

        timeline =
        {
            FrameEvent(13, function(inst)
                local attacked_by_lighter = inst.sg.statemem.attacked_by_lighter
                if attacked_by_lighter or (math.random() > 0.5) then
                    if attacked_by_lighter then
                        inst.components.combat:DropTarget()
                    end
                    inst.sg:GoToState("teleport_pre")
                end
            end),
        },

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State {
        name = "taunt",
        tags = {"taunt", "busy"},

        onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("taunt")

            local combat = inst.components.combat
            if combat and combat.target then
                inst:ForceFacePoint(combat.target.Transform:GetWorldPosition())
            end
        end,

        timeline =
        {
            FrameEvent(1, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.taunt)
            end),
            FrameEvent(14, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.taunt2)
            end),
            FrameEvent(21, function(inst)
                -- The taunt tag is what prevents us from transitioning to hit.
                -- Remove it early so that the shadeling can get hit out after
                -- its initial howl in the taunt.
                inst.sg:RemoveStateTag("taunt")
            end),
            FrameEvent(29, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.taunt2)
            end),
        },

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },
}

CommonStates.AddWalkStates(states, nil, nil, nil, nil, {
    walkonenter = function(inst)
        inst.SoundEmitter:PlaySound(inst.sounds.walk, "walkloop")
    end,
    walkonexit = function(inst)
        inst.SoundEmitter:KillSound("walkloop")
    end,
})

local function teleport_test_fn(test_position)
    return (TheWorld.components.miasmamanager:GetMiasmaAtPoint(test_position:Get()) ~= nil)
end

local function do_teleport(inst)
    local iposition = inst:GetPosition()

    local miasmamanager = TheWorld.components.miasmamanager
    local test_miasma = (miasmamanager ~= nil) and miasmamanager:IsMiasmaActive()

    local initial_angle = TWOPI * math.random()
    local teleport_radius = 2 + (7 * math.sqrt(math.random()))
    local walked_teleport_offset
    if test_miasma then
        walked_teleport_offset = FindWalkableOffset(iposition, initial_angle, teleport_radius, nil, true, true, teleport_test_fn, false, false)
    end

    if not walked_teleport_offset then
        walked_teleport_offset = FindWalkableOffset(iposition, initial_angle, teleport_radius, nil, true, true, nil, false, false)
    end

    if walked_teleport_offset then
        inst.Physics:Teleport(iposition.x + walked_teleport_offset.x, 0, iposition.z + walked_teleport_offset.z)
    end
end
CommonStates.AddSimpleState(states, "teleport_pre", "disappear_pre", {"busy", "hit"}, "teleport")
CommonStates.AddSimpleState(states, "teleport", "disappear", {"busy", "hit"}, "appear",
{
    FrameEvent(7, function(inst)
        inst.sg:AddStateTag("noattack")
    end),
    FrameEvent(14, function(inst)
        local ix, iy, iz = inst.Transform:GetWorldPosition()
        local quickfuse_bomb = SpawnPrefab("fused_shadeling_quickfuse_bomb")

        local combat_target = inst.components.combat.target
        local angle = (combat_target and DEGREES * inst:GetAngleToPoint(combat_target.Transform:GetWorldPosition()))
            or (TWOPI * math.random())
        angle = GetRandomWithVariance(angle, PI/6)

        local speed = 2.5 + math.random()
        quickfuse_bomb.Physics:Teleport(ix, 0.1, iz)
        quickfuse_bomb.Physics:SetVel(speed * math.cos(angle), 12, -speed * math.sin(angle))

        quickfuse_bomb.SoundEmitter:PlaySound(inst.sounds.bomb_spawn)
    end),
},
{
    onenter = function(inst)
        inst.SoundEmitter:PlaySound(inst.sounds.disappear)
    end,
    onexit = function(inst)
        do_teleport(inst)
    end,
})

CommonStates.AddSimpleState(states, "appear", "spawn", {"busy", "noattack"}, "appear_pst",
{
    FrameEvent(4, function(inst)
        inst.sg:RemoveStateTag("noattack")
    end),
},
{
    onenter = function(inst)
        SpawnPrefab("fused_shadeling_spawn_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst.SoundEmitter:PlaySound(inst.sounds.appear)
    end,
})
CommonStates.AddSimpleState(states, "appear_pst", "spawn_pst", {"busy"})

CommonStates.AddSimpleState(states, "despawn_pre", "disappear_pre", {"busy"}, "despawn")
CommonStates.AddSimpleState(states, "despawn", "disappear", {"busy"}, "idle", nil,
{
    onexit = function(inst)
        inst:Remove()
    end,
})

return StateGraph("fused_shadeling", states, events, "idle")