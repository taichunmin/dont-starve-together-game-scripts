require("stategraphs/commonstates")

local SWOOP_LOOP_TARGET_CANT_TAGS = {"INLIMBO", "fx", "malbatross", "boat"}
local SWOOP_LOOP_TARGET_ONEOF_TAGS = {"tree", "mast", "_health"}

local actionhandlers =
{
    ActionHandler(ACTIONS.HAMMER, "attack"),
    ActionHandler(ACTIONS.GOHOME, "taunt"),
    ActionHandler(ACTIONS.EAT, "eat_dive"),
}

local SHAKE_DIST = 40

local function swoopcollision(inst)
    inst.Physics:ClearCollisionMask()
end

local function resetcollision(inst)
    inst.Physics:CollidesWith((TheWorld.has_ocean and COLLISION.GROUND) or COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.FLYERS)
end


local function spawnripple(inst)
    if not TheWorld.Map:IsVisualGroundAtPoint(inst.Transform:GetWorldPosition()) then
        inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/ripple")
        SpawnPrefab("boss_ripple_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
    end
end

local function spawnsplash(inst, size, pos)
    local splashpos = Vector3(inst.Transform:GetWorldPosition())
    if pos then
        splashpos = pos
    end
    if not TheWorld.Map:IsVisualGroundAtPoint(splashpos.x,splashpos.y,splashpos.z) and not TheWorld.Map:GetPlatformAtPoint(splashpos.x,splashpos.z) then
        local prefab = "splash_green_large"
        if size == "med" then
            prefab = "splash_green"
        end
        local fx = SpawnPrefab("splash_green_large")
        fx.Transform:SetPosition(splashpos.x,splashpos.y,splashpos.z)
     --   if scale then
          --  fx.Transform:SetScale(scale,scale,scale)
       -- end
    end
end

local function spawnwave(inst, time)
    inst.spawnwaves(inst, 12, 360, 4, nil, 2, time or 2, nil, true)
end

local ATTACK_WAVE_SPEED = 5
local ATTACK_WAVE_IDLE_TIME = 1.5
local ANGLE_OFFSET = 35*DEGREES
local function SpawnMalbatrossAttackWaves(inst)
    local position = inst:GetPosition()
    local angle = inst:GetRotation() + (math.random()*20 - 10)

    local angle_rads = angle*DEGREES
    local offset_direction1 = Vector3(math.cos(angle_rads), 0, -math.sin(angle_rads)):Normalize()

    local point = position + (offset_direction1 * 3.5)
    local platform = TheWorld.Map:GetPlatformAtPoint(point.x,point.y,point.z)
    if platform then
        local theta = inst.Transform:GetRotation() * DEGREES
        local offset = Vector3(math.cos( theta ), 0, -math.sin( theta ))

        platform.components.boatphysics:ApplyForce(offset.x, offset.z, TUNING.MALBATROSS_BOAT_PUSH)

        if platform.components.hullhealth then
            platform.components.health:DoDelta(-TUNING.MALBATROSS_BOAT_DAMAGE)
        end
    elseif not TheWorld.Map:IsVisualGroundAtPoint(point.x,point.y,point.z) then
        spawnsplash(inst, "med", point)

        SpawnAttackWave(position + offset_direction1, angle, {ATTACK_WAVE_SPEED, 0, 0}, nil, ATTACK_WAVE_IDLE_TIME, true)

        local offset_direction2 = Vector3(math.cos(angle_rads + ANGLE_OFFSET), 0, -math.sin(angle_rads + ANGLE_OFFSET)):Normalize()*3
        SpawnAttackWave(position + offset_direction2, angle, {ATTACK_WAVE_SPEED, 0, -1}, nil, ATTACK_WAVE_IDLE_TIME, true)

        local offset_direction3 = Vector3(math.cos(angle_rads - ANGLE_OFFSET), 0, -math.sin(angle_rads - ANGLE_OFFSET)):Normalize()*3
        SpawnAttackWave(position + offset_direction3, angle, {ATTACK_WAVE_SPEED, 0, 1}, nil, ATTACK_WAVE_IDLE_TIME, true)
    end
end

local events =
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnSleepEx(),
    CommonHandlers.OnWakeEx(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttacked(),

    EventHandler("depart", function(inst, data)
        if not inst.components.health:IsDead() and (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("hit")) then
            inst.sg:GoToState("depart")
        end
    end),

    EventHandler("dosplash", function(inst, data)
        if not inst.components.health:IsDead() and not inst.components.freezable:IsFrozen() and not inst.components.sleeper:IsAsleep() then
            if not TheWorld.Map:IsVisualGroundAtPoint(inst.Transform:GetWorldPosition()) and not inst:GetCurrentPlatform() then
                inst.readytodive = nil
                inst.sg:GoToState("combatdive")
            end
        end
    end),
    EventHandler("doswoop", function(inst, data)
        if not inst.components.health:IsDead() and not inst.components.freezable:IsFrozen() and not inst.components.sleeper:IsAsleep() then
            inst:DoTaskInTime((math.random()*6) + 10, function(inst) inst.readytoswoop = true end)
            inst.sg:GoToState("swoop_pre", data.target or inst.components.combat.target)
        end
    end),
    EventHandler("death", function(inst, data)
        if TheWorld.Map:IsVisualGroundAtPoint(inst.Transform:GetWorldPosition()) or inst:GetCurrentPlatform() then
            inst.sg:GoToState("death", data)
        else
            inst.sg:GoToState("death_ocean", data)
        end
    end),

    EventHandler("doattack", function(inst, data)
        if inst.components.health ~= nil and not inst.components.health:IsDead()
            and (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("hit")) then
            inst.sg:GoToState("attack")
        end
    end),
}

local function go_to_idle(inst)
    inst.sg:GoToState("idle")
end

local function swoop_over_shoal(inst)
    local feedingshoal = inst.components.entitytracker:GetEntity("feedingshoal")
    if feedingshoal then
        inst.sg:GoToState("swoop_pre", feedingshoal)
    else
        inst.sg:GoToState("idle")
    end
end

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, pushanim)
            inst.components.locomotor:StopMoving()

                --pushanim could be bool or string?
                if pushanim then
                    if type(pushanim) == "string" then
                        inst.AnimState:PlayAnimation(pushanim)
                    end
                    inst.AnimState:PushAnimation("idle_loop")
                else
                    inst.AnimState:PlayAnimation("idle_loop")
                end
        --    end
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, spawnripple),
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/flap") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.sg.mem.ate_all_the_fish then
                    inst.sg.mem.ate_all_the_fish = nil
                    inst.sg:GoToState("depart")
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "arrive",
        tags = {"busy", "noattack", "nosleep", "swoop", "flight"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("spawn")
        end,

        timeline =
        {
            TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/whoosh") end),
            TimeEvent(14 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("noattack")
                inst.sg:RemoveStateTag("nosleep")
            end),
            TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/flap") end),
            TimeEvent(27*FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/flap") end),
        },

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "depart",
        tags = {"busy", "nosleep", "swoop", "flight"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.components.combat:DropTarget()
            inst.AnimState:PlayAnimation("despawn")
        end,

        timeline =
        {
            TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/flap") end),
            TimeEvent(30*FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/flap") end),
            TimeEvent(32 * FRAMES, function(inst)
                inst.sg:AddStateTag("noattack")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst:Relocate()
            end),
        },
    },

    State{
        name = "eat_dive",
        tags = { "busy", "nosleep", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()

            local ba = inst:GetBufferedAction()
            inst.sg.statemem.fish_target = (ba ~= nil and ba.target) or nil

            inst:AddTag("scarytooceanprey")
            inst.AnimState:PlayAnimation("dive")
        end,

        onexit = function(inst)
            inst:RemoveTag("scarytooceanprey")
        end,

        timeline =
        {
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/flap") end),
            TimeEvent(19*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/boss")
                spawnsplash(inst)
                spawnwave(inst, 1)
                inst.DynamicShadow:Enable(false)
                inst.sg:AddStateTag("noattack")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                local got_fish = false
                if math.random() < TUNING.MALBATROSS_EATSUCCESS_CHANCE then
                    local fish = inst.sg.statemem.fish_target
                    if fish and fish:IsValid() then
                        got_fish = true
                    end
                end

                if got_fish then
                    inst.sg:GoToState("eatfish", inst.sg.statemem.fish_target)
                else
                    inst.sg:GoToState("nofish")
                end
            end),
        },
    },

    State{
        name = "nofish",
        tags = { "busy", "nosleep", "noattack" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("nofish")

            -- Avoid immediately re-diving for fish, but on a shorter timespan than when we eat successfully.
            inst.components.timer:StartTimer("satiated", GetRandomMinMax(TUNING.MALBATROSS_MISSFISH_TIME.MIN, TUNING.MALBATROSS_MISSFISH_TIME.MAX))

            inst:AddTag("scarytooceanprey")

            inst:ClearBufferedAction()
        end,

        onexit = function(inst)
            inst:RemoveTag("scarytooceanprey")
        end,

        timeline =
        {
            TimeEvent(1 * FRAMES, function(inst)
                spawnsplash(inst)
                inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/jump_boss")
                inst.DynamicShadow:Enable(true)
            end),
            TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/whoosh") end),
            TimeEvent(4*FRAMES, function(inst) inst.sg:RemoveStateTag("noattack") end),
        },

        events =
        {
            EventHandler("animover", swoop_over_shoal),
        },
    },

    State{
        name = "eatfish",
        tags = { "busy", "nosleep", "noattack" },

        onenter = function(inst, fish_to_eat)
            -- NOTE: we assume we were given a valid fish to eat; validity should be tested before entering this state.
            inst.Physics:Teleport(fish_to_eat.Transform:GetWorldPosition())
            inst.AnimState:PlayAnimation("eatfish")
            inst.components.timer:StartTimer("satiated", GetRandomMinMax(TUNING.MALBATROSS_NOTHUNGRY_TIME.MIN, TUNING.MALBATROSS_NOTHUNGRY_TIME.MAX))

            local fish_to_eat_build = fish_to_eat.AnimState:GetBuild()
            inst.AnimState:OverrideSymbol("shoal_body", fish_to_eat_build, "shoal_body")
            inst.AnimState:OverrideSymbol("shoal_fin", fish_to_eat_build, "shoal_fin")
            inst.AnimState:OverrideSymbol("shoal_head", fish_to_eat_build, "shoal_head")

            fish_to_eat:Remove()

            inst:AddTag("scarytooceanprey")

            inst:ClearBufferedAction()
        end,

        onexit = function(inst)
            inst:RemoveTag("scarytooceanprey")
            inst.AnimState:ClearOverrideSymbol("shoal_body")
            inst.AnimState:ClearOverrideSymbol("shoal_fin")
            inst.AnimState:ClearOverrideSymbol("shoal_head")

            local feedingshoal = inst.components.entitytracker:GetEntity("feedingshoal")
            if feedingshoal and (feedingshoal.components.childspawner and feedingshoal.components.childspawner:CountChildrenOutside() <= 0) then
                inst.sg.mem.ate_all_the_fish = true
            end
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst)
                spawnsplash(inst)
                inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/jump_boss")
                inst.DynamicShadow:Enable(true)
            end),
            TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/whoosh") end),
            TimeEvent(4*FRAMES, function(inst) inst.sg:RemoveStateTag("noattack") end),
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/eat") end),
            TimeEvent(40*FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/beak") end),
        },

        events =
        {
            EventHandler("animover", swoop_over_shoal),
        },
    },

    State{
        name = "gohome",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst:ClearBufferedAction()
            inst.components.knownlocations:RememberLocation("home", nil)
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/taunt") end),
            TimeEvent(16 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/taunt_howl") end),
        },

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "taunt",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")

            if inst.bufferedaction and inst.bufferedaction.action == ACTIONS.GOHOME then
                inst:PerformBufferedAction()
            end
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/taunt") end),
            TimeEvent(8 * FRAMES, spawnripple),
        },

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "death_ocean",
        tags = { "busy" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("death_ocean")
            inst.AnimState:PushAnimation("death_ocean_idle")
            RemovePhysicsColliders(inst)
        end,

        timeline =
        {

            TimeEvent(4 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/death") end),
            TimeEvent(33 * FRAMES, function(inst) inst.spawnfeather(inst,0.4) end),
            TimeEvent(34 * FRAMES, function(inst)
                if math.random() < 0.3 then
                    inst.spawnfeather(inst,0.4)
                end
            end),
            TimeEvent(35 * FRAMES, function(inst) inst.spawnfeather(inst,0.45) end),
            TimeEvent(36 * FRAMES, function(inst)
                if math.random() < 0.3 then
                    inst.spawnfeather(inst,0.4)
                end
            end),
            TimeEvent(38 * FRAMES, function(inst) inst.spawnfeather(inst,0.45) end),
            TimeEvent(39 * FRAMES, function(inst)
                if inst.feathers < 24 then
                    for i=1,24-inst.feathers do
                        inst.spawnfeather(inst,0.45)
                    end
                end
            end),
            TimeEvent(42 * FRAMES, function(inst)
                spawnsplash(inst)
                spawnwave(inst)
                inst.components.lootdropper:DropLoot(inst:GetPosition())
                inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/boss")
            end),

        },
    },

    State{
        name = "swoop_pre",
        tags = {"busy", "canrotate", "swoop"},

        onenter = function(inst, target)
            inst.Physics:Stop()

            inst.sg.statemem.target = target

            inst.AnimState:PlayAnimation("swoop_pre")
        end,

        onupdate = function(inst)
            local target = inst.sg.statemem.target
            if not inst.sg.statemem.stopsteering and target and target:IsValid() then
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end
        end,

        timeline =
        {
            TimeEvent(6 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/eat") end),
            TimeEvent(8 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/swoop_pre") end),
            TimeEvent(11 * FRAMES, function(inst) inst.sg.statemem.stopsteering = true end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("swoop_loop") end),
        },
    },

    State{
        name = "swoop_loop",
        tags = {"busy", "swoop"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("swoop_loop", true)
            inst.Physics:SetMotorVelOverride(15,0,0)
            inst.sg:SetTimeout(1)
            inst.sg.statemem.collisiontime = 0

            inst.components.combat:EnableAreaDamage(false)
        end,

        onupdate = function(inst, dt)
            if inst.sg.statemem.collisiontime <= 0 then
                local x,y,z = inst.Transform:GetWorldPosition()
                local ents = TheSim:FindEntities(x, y, z, 2, nil, SWOOP_LOOP_TARGET_CANT_TAGS, SWOOP_LOOP_TARGET_ONEOF_TAGS)
                for i,ent in ipairs(ents) do
                    inst.oncollide(inst,ent)
                end

                spawnripple(inst)

                inst.sg.statemem.collisiontime = 3/30
            end
            inst.sg.statemem.collisiontime = inst.sg.statemem.collisiontime - dt
        end,

        timeline =
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/swoop") end),
        },

        onexit = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            inst.Physics:ClearMotorVelOverride()
            inst.components.locomotor:Stop()

            inst.components.combat:EnableAreaDamage(true)
        end,

        ontimeout=function(inst)
            inst.sg:GoToState("swoop_pst")
        end,
    },

    State{
        name = "swoop_pst",
        tags = {"busy", "swoop"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("swoop_pst")
        end,

        timeline=
        {
            TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/flap") end),
            TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/flap") end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("taunt") end),
        },
    },

    State{
        name = "wavesplash",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            if target then
                inst:ForceFacePoint(Vector3(target.Transform:GetWorldPosition()))
            end
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("atk")
            inst.components.combat:StartAttack()
            inst.sg.statemem.target = target
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)
                inst.sg:AddStateTag("longattack")
                inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/attack_call")
            end),
            TimeEvent(13 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/attack_swipe_water") end),

            TimeEvent(29 * FRAMES, function(inst)
                inst.components.combat:DoAttack(inst.sg.statemem.target)

                SpawnMalbatrossAttackWaves(inst)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("taunt") end)
        },
    },

    State{
        name = "combatdive",
        tags = { "busy", "nosleep", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()

            inst:AddTag("scarytooceanprey")
            inst.AnimState:PlayAnimation("dive")
        end,

        onexit = function(inst)
            inst:RemoveTag("scarytooceanprey")
        end,

        timeline =
        {
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/flap") end),
            TimeEvent(19 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/large")
                spawnsplash(inst)
                spawnwave(inst, 1)
                inst.DynamicShadow:Enable(false)
                inst.sg:AddStateTag("noattack")
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("combatdive_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:SetTimeout(2)
            end)
        },
    },

    State{
        name = "combatdive_pst",
        tags = { "busy", "nosleep", "noattack" },

        onenter = function(inst)
            if inst.components.combat and inst.components.combat.target then
                -- reposition away from target
                local pt = Vector3(inst.Transform:GetWorldPosition())
                local angle = inst:GetAngleToPoint(Vector3(inst.components.combat.target.Transform:GetWorldPosition())) + 180
                local offset = FindSwimmableOffset(pt, angle * DEGREES, 12, 16, true) or
                               FindSwimmableOffset(pt, angle * DEGREES, 8, 16, true) or
                               FindSwimmableOffset(pt, angle * DEGREES, 4, 16, true) or
                               Vector3(0,0,0)
                inst.Transform:SetPosition(pt.x +offset.x,pt.y,pt.z+offset.z)
            end

            inst.AnimState:PlayAnimation("nofish")
        end,

        onexit = function(inst)
            inst.staredown = true
        end,

        timeline =
        {
            TimeEvent(1 * FRAMES, function(inst)
             inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/jump_large")
                spawnsplash(inst)
                spawnwave(inst, 1)
                inst.DynamicShadow:Enable(true)
            end),

            TimeEvent(4*FRAMES, function(inst) inst.sg:RemoveStateTag("noattack") end),
        },

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "alert",
        tags = { "idle", "canrotate", "alert" },

        onenter = function(inst, pushanim)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("idle_loop")
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, spawnripple),
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/flap") end),
        },

        events=
        {
            EventHandler("animover", function(inst)
                local target = nil
                if inst.components.combat and inst.components.combat.target then
                    target = inst.components.combat.target
                end
                if math.random() < 0.2 then
                    inst.sg:GoToState("taunt")
                elseif not inst.components.timer:TimerExists("splashdelay") and target then
                    inst.components.timer:StartTimer("splashdelay", math.random()*2 +8)
                    inst.sg:GoToState("wavesplash",target)
                else
                    inst.sg:GoToState("alert")
                end
            end),
        },
    },
}

CommonStates.AddWalkStates(states,
{
    starttimeline =
    {
        TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/flap") end),
        TimeEvent(9 * FRAMES, spawnripple),
    },
    walktimeline =
    {
        TimeEvent(33 * FRAMES, spawnripple),
        TimeEvent(37*FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/flap") end),
    },
    endtimeline =
    {

    },
})

CommonStates.AddCombatStates(states,
{
    hittimeline =
    {
        TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/hit") end),
    },
    attacktimeline =
    {
        TimeEvent(0 * FRAMES, function(inst)
            inst.sg:AddStateTag("longattack")
            inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/attack_call")
        end),
        TimeEvent(13 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/attack_swipe_water") end),

        TimeEvent(29 * FRAMES, function(inst)
            inst.components.combat:DoAttack(inst.sg.statemem.target)

            SpawnMalbatrossAttackWaves(inst)
        end),
    },
    deathtimeline =
    {
        TimeEvent(1 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/flap") end),
        TimeEvent(4 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/death") end),
        TimeEvent(33 * FRAMES, function(inst) inst.spawnfeather(inst,0.4) end),
        TimeEvent(34 * FRAMES, function(inst)
            if math.random() < 0.3 then
                inst.spawnfeather(inst, 0.4)
            end
        end),
        TimeEvent(35 * FRAMES, function(inst) inst.spawnfeather(inst,0.45) end),
        TimeEvent(36 * FRAMES, function(inst)
            if math.random() < 0.3 then
                inst.spawnfeather(inst, 0.4)
            end
        end),
        TimeEvent(38 * FRAMES, function(inst) inst.spawnfeather(inst,0.45) end),
        TimeEvent(39 * FRAMES, function(inst)
                if inst.feathers < 24 then
                    for i=1,24-inst.feathers do
                        inst.spawnfeather(inst,0.45)
                    end
                end
            end),
        TimeEvent(44 * FRAMES, function(inst) ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, 2, inst, SHAKE_DIST) end),
		TimeEvent(44 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound") end),
    },
})

local function land_without_floater(creature)
    creature:RemoveTag("flying")
    if creature.Physics ~= nil then
        creature.Physics:CollidesWith(COLLISION.LIMITS)
        creature.Physics:ClearCollidesWith(COLLISION.FLYERS)
    end
end

local function raise_without_floater(creature)
    creature:AddTag("flying")
    if creature.Physics ~= nil then
        creature.Physics:ClearCollidesWith(COLLISION.LIMITS)
        creature.Physics:CollidesWith(COLLISION.FLYERS)
    end
end

CommonStates.AddSleepExStates(states,
{
    starttimeline =
    {
        TimeEvent(1 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/jump_boss") end),
        TimeEvent(35 * FRAMES, function(inst)
            land_without_floater(inst)
            if not inst:IsOnPassablePoint() then
                inst.AnimState:PlayAnimation("sleep_ocean_pre")
                inst.AnimState:SetTime(36*FRAMES)
            end
        end),
    },
    waketimeline =
    {
        TimeEvent(28 * FRAMES, spawnripple),
        TimeEvent(44 * FRAMES, raise_without_floater),
    },
},
{
    onsleeping = function(inst)
        land_without_floater(inst)
        if not inst:IsOnPassablePoint() then
            inst.AnimState:PlayAnimation("sleep_ocean_loop")
        end
    end,
    onexitsleeping = raise_without_floater,
    onwake = function(inst)
        land_without_floater(inst)
        if not inst:IsOnPassablePoint() then
            inst.AnimState:PlayAnimation("sleep_ocean_pst")
        end
    end,
    onexitwake = raise_without_floater,
})

CommonStates.AddFrozenStates(states, LandFlyingCreature, RaiseFlyingCreature)

return StateGraph("malbatross", states, events, "idle", actionhandlers)

