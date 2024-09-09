local SpDamageUtil = require("components/spdamageutil")

local assets =
{
    Asset("ANIM", "anim/fused_shadeling_bomb.zip"),
}

local prefabs =
{
    "fused_shadeling_bomb_death_fx",
    "fused_shadeling_bomb_scorch",
    "round_puff_fx_sm",
}

local GROW_TIME = 2 * 35 * FRAMES

----
local function ball_start_growing(inst)
    inst.AnimState:PlayAnimation("ball_grow")
end

local function ball_explode(inst)
    inst.AnimState:PlayAnimation("explode")
end

local function make_ball()
    local inst = CreateEntity("fused_shadeling_bomb_ball")

    inst:AddTag("FX")

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()

    inst.AnimState:SetBank("fused_shadeling_bomb")
    inst.AnimState:SetBuild("fused_shadeling_bomb")
    inst.AnimState:SetDeltaTimeMultiplier(0.5)
    inst.AnimState:PlayAnimation("ball_idle", true)

    inst.StartGrowing = ball_start_growing
    inst.Explode = ball_explode

    return inst
end

local function do_ball_grow(inst)
    if inst._ball then
        inst._ball:StartGrowing()
        inst._ball:DoTaskInTime(GROW_TIME - FRAMES, inst._ball.Explode)
    end
end

----
local SPAWN_DELAY_TIMERNAME = "spawn_delay"
local FINISH_SPAWN_TIMERNAME = "finish_spawn"
local EXPLOSION_TIMERNAME = "start_explosion"
local START_GROW_TIMERNAME = "start_ball_growing"
local CHASE_TICK_TIMERNAME = "chase_tick"
local CHASE_TICK_RATE = 0.3

local SIZE_UP_TIMERNAME = "do_sizeup"
local FULL_SIZE = 1.35
local SIZE_UP_BY_TICK = (FULL_SIZE - 1.0) / 20

local EXPLODE_RANGE = 3.0
local INSIDE_CHASE_RANGE = (EXPLODE_RANGE / 4)
local INSIDE_CHASE_RANGESQ = (INSIDE_CHASE_RANGE * INSIDE_CHASE_RANGE)

----
local function on_spawn_finished(inst)
    local timer = inst.components.timer
    timer:ResumeTimer(CHASE_TICK_TIMERNAME)
    timer:StartTimer(EXPLOSION_TIMERNAME, TUNING.FUSED_SHADELING_BOMB_EXPLOSION_TIME)
    timer:StartTimer(START_GROW_TIMERNAME, TUNING.FUSED_SHADELING_BOMB_EXPLOSION_TIME - GROW_TIME)
end

local function on_spawn_delay_finished(inst)
    inst.sg:GoToState("spawn")
end

local function on_target_set(inst, target)
    if target then
        inst.components.entitytracker:ForgetEntity("target")
        inst.components.entitytracker:TrackEntity("target", target)
    end
end

----
local EXPLODE_HIT_MUST_TAGS = {"_combat"}
local EXPLODE_HIT_CANT_TAGS = {"shadow_aligned", "DECOR", "INLIMBO", "NOCLICK", "FX", "playerghost"}
local function do_explosion_effect(inst, ix, iy, iz)
    if not ix then
        ix, iy, iz = inst.Transform:GetWorldPosition()
    end
    SpawnPrefab("fused_shadeling_bomb_death_fx").Transform:SetPosition(ix, iy, iz)

    local exploded_entities = TheSim:FindEntities(ix, iy, iz, EXPLODE_RANGE, EXPLODE_HIT_MUST_TAGS, EXPLODE_HIT_CANT_TAGS)
    for _, exploded_entity in ipairs(exploded_entities) do
        exploded_entity.components.combat:GetAttacked(inst, TUNING.FUSED_SHADELING_BOMB_EXPLOSION_DAMAGE, nil, nil, {planar = TUNING.FUSED_SHADELING_BOMB_EXPLOSION_PLANARDAMAGE})
    end
    SpawnPrefab("fused_shadeling_bomb_scorch").Transform:SetPosition(ix, iy, iz)
end

local function do_quickfuse_bomb_toss(inst, ix, iy, iz, angle)
    local quickfuse_bomb = SpawnPrefab("fused_shadeling_quickfuse_bomb")
    quickfuse_bomb.Transform:SetPosition(ix, iy, iz)

    angle = angle or TWOPI * math.random()
    local speed = 4 + math.random()
    quickfuse_bomb.Physics:Teleport(ix, 0.1, iz)
    quickfuse_bomb.Physics:SetVel(
        speed * math.cos(angle),
        8 + 2 * math.random(),
        speed * math.sin(angle))
end

local EXTRA_QUICKFUSE_BOMBS = 3
local EXTRA_QUICKFUSE_TIMEPERBOMB = 0.05
local function do_full_explode(inst)
    local ix, iy, iz = inst.Transform:GetWorldPosition()

    local initial_angle, angle_per_bomb = TWOPI * math.random(), TWOPI / EXTRA_QUICKFUSE_BOMBS
    for i = 1, EXTRA_QUICKFUSE_BOMBS do
        inst:DoTaskInTime((i - 1 + math.random()) * EXTRA_QUICKFUSE_TIMEPERBOMB,
            do_quickfuse_bomb_toss,
            ix, iy, iz,
            GetRandomWithVariance(initial_angle + i * angle_per_bomb, PI/6)
        )
    end
    inst:DoTaskInTime((EXTRA_QUICKFUSE_BOMBS + 1) * EXTRA_QUICKFUSE_TIMEPERBOMB, inst.Remove)

    do_explosion_effect(inst, ix, iy, iz)

    inst.persists = false
    inst:RemoveFromScene()
end

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "INLIMBO", "shadow_aligned", "FX", "DECOR", "noattack", "notarget", "NOCLICK", "playerghost" }
local RETARGET_ONEOF_TAGS = { "character", "monster" }
local function do_chase_tick(inst)
    local target = inst.components.entitytracker:GetEntity("target")
    if not target then
        -- Look for a new target.
        target = FindEntity(inst,
            TUNING.FUSED_SHADELING_AGGRO_RANGE,
            nil,
            RETARGET_MUST_TAGS,
            RETARGET_CANT_TAGS,
            RETARGET_ONEOF_TAGS)
        if target then
            inst.components.entitytracker:TrackEntity("target", target)
        end
    end

    local my_position = inst:GetPosition()
    local target_position = (target and target:GetPosition()) or (my_position + Vector3FromTheta(PI2*math.random(), 5))
    local test_radius = (target and target:GetPhysicsRadius(0.1)) or 0.1

    local dsq_to_target = distsq(target_position.x, target_position.z, my_position.x, my_position.z)
    if dsq_to_target > INSIDE_CHASE_RANGESQ then
        local vector_from_target = (my_position - target_position):Normalize()
        local stand_distance = math.max(INSIDE_CHASE_RANGE, test_radius)

        -- We want to go to where the target currently is at tick time, not chase them in a curved fashion.
        inst.components.locomotor:GoToPoint(target_position + (vector_from_target * stand_distance))
    end

    inst.components.timer:StartTimer(CHASE_TICK_TIMERNAME, CHASE_TICK_RATE)
end

local function on_timer_done(inst, data)
    if data.name == EXPLOSION_TIMERNAME then
        do_full_explode(inst)
    elseif data.name == CHASE_TICK_TIMERNAME then
        do_chase_tick(inst)
    elseif data.name == SPAWN_DELAY_TIMERNAME then
        on_spawn_delay_finished(inst)
    elseif data.name == FINISH_SPAWN_TIMERNAME then
        on_spawn_finished(inst)
    elseif data.name == START_GROW_TIMERNAME then
        inst._start_ball_growing:push()

        inst.SoundEmitter:PlaySound("rifts2/parasitic_shadeling/dreadmite_explode")
    elseif data.name == SIZE_UP_TIMERNAME then
        inst._current_scale = math.min(inst._current_scale + SIZE_UP_BY_TICK, FULL_SIZE)
        inst.AnimState:SetScale(inst._current_scale, inst._current_scale)
        if inst._current_scale < FULL_SIZE then
            inst.components.timer:StartTimer(SIZE_UP_TIMERNAME, FRAMES)
        end
    end
end

----
local function on_load_postpass(inst, data)
    local timer = inst.components.timer
    if timer:TimerExists(SPAWN_DELAY_TIMERNAME) then
        timer:SetTimeLeft(SPAWN_DELAY_TIMERNAME, 0)
    end
    if timer:TimerExists(FINISH_SPAWN_TIMERNAME) then
        timer:SetTimeLeft(FINISH_SPAWN_TIMERNAME, 0)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 10, 0.2)

    inst.Transform:SetFourFaced()

    inst.DynamicShadow:SetSize(1.1, 0.6)

    inst:AddTag("hostile")
    inst:AddTag("monster")
    inst:AddTag("notraptrigger")
    inst:AddTag("shadow")
    inst:AddTag("shadow_aligned")
	inst:AddTag("explosive")

    inst.AnimState:SetBank("fused_shadeling_bomb")
    inst.AnimState:SetBuild("fused_shadeling_bomb")
    inst.AnimState:PlayAnimation("idle_ground", true)
    inst.AnimState:Hide("RED")
    inst.scrapbook_anim = "idle_2"
    inst.scrapbook_weapondamage = TUNING.FUSED_SHADELING_BOMB_EXPLOSION_DAMAGE
    inst.scrapbook_planardamage = TUNING.FUSED_SHADELING_BOMB_EXPLOSION_PLANARDAMAGE

    inst._start_ball_growing = net_event(inst.GUID, "fused_shadeling_bomb._start_ball_growing")

    if not TheNet:IsDedicated() then
        inst._ball = make_ball()
        inst._ball.entity:SetParent(inst.entity)
        inst._ball.Follower:FollowSymbol(inst.GUID, "follow", nil, nil, nil, true)

        inst.highlightchildren = {inst._ball}

        inst:ListenForEvent("fused_shadeling_bomb._start_ball_growing", do_ball_grow)
    end

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst._current_scale = 1.0

    --
    inst:AddComponent("inspectable")

    --
    inst:AddComponent("entitytracker")

    --
    local locomotor = inst:AddComponent("locomotor")
    locomotor.walkspeed = TUNING.FUSED_SHADELING_BOMB_WALKSPEED
    locomotor:SetTriggersCreep(false)
    locomotor.pathcaps = { ignorecreep = true }

    --
    local timer = inst:AddComponent("timer")
    timer:StartTimer(CHASE_TICK_TIMERNAME, CHASE_TICK_RATE, true, FRAMES)
    timer:StartTimer(SPAWN_DELAY_TIMERNAME, 1.5 * (2 + math.random()))
    timer:StartTimer(SIZE_UP_TIMERNAME, FRAMES)

    --
    inst:ListenForEvent("setexplosiontarget", on_target_set)
    inst:ListenForEvent("timerdone", on_timer_done)

    --
    inst.OnLoadPostPass = on_load_postpass

    --
    inst:SetStateGraph("SGfused_shadeling_bomb")

    return inst
end

----
local function death_fx_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("fused_shadeling_bomb")
    inst.AnimState:SetBuild("fused_shadeling_bomb")
    inst.AnimState:PlayAnimation("death_fx")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.SoundEmitter:PlaySound("rifts2/parasitic_shadeling/dreadmite_explode")

    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

----
local function do_quick_explode(inst)
    do_explosion_effect(inst)

    inst:Remove()
end

local QUICKFUSE_TIME = GROW_TIME * 0.5
local function quickfuse_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    local physics = MakeInventoryPhysics(inst, 10, 0.2)
    physics:SetFriction(0.3)

    inst:AddComponent("groundshadowhandler")
    inst.components.groundshadowhandler:SetSize(1.5, 1.0)

    inst.Transform:SetFourFaced()

    inst:AddTag("hostile")
    inst:AddTag("monster")
    inst:AddTag("notraptrigger")
    inst:AddTag("shadow")
    inst:AddTag("shadow_aligned")

    inst.AnimState:SetBank("fused_shadeling_bomb")
    inst.AnimState:SetBuild("fused_shadeling_bomb")
    inst.AnimState:PlayAnimation("ball_grow", true)

    inst:SetPrefabNameOverride("fused_shadeling_bomb")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    --
    inst:AddComponent("inspectable")

    --
    inst:DoTaskInTime(QUICKFUSE_TIME, do_quick_explode)

    --
    inst.persists = false

    return inst
end

----
local scorch_assets =
{
    Asset("ANIM", "anim/burntground.zip"),
}

local SCORCH_DELAY_FRAMES = 30
local SCORCH_FADE_FRAMES = 10

local function Scorch_OnFadeDirty(inst)
    --V2C: hack alert: using SetHightlightColour to achieve something like OverrideAddColour
    --     (that function does not exist), because we know this FX can never be highlighted!
    if inst._fade:value() > SCORCH_FADE_FRAMES + SCORCH_DELAY_FRAMES then
        local k = (inst._fade:value() - SCORCH_FADE_FRAMES - SCORCH_DELAY_FRAMES)
        inst.AnimState:OverrideMultColour(1, 1, 1, 1)
        inst.AnimState:SetHighlightColour(0, 0, k, 0)
    elseif inst._fade:value() >= SCORCH_FADE_FRAMES then
        inst.AnimState:OverrideMultColour(1, 1, 1, 1)
        inst.AnimState:SetHighlightColour()
    else
        local k = inst._fade:value() / SCORCH_FADE_FRAMES
        k = k * k
        inst.AnimState:OverrideMultColour(1, 1, 1, k)
        inst.AnimState:SetHighlightColour()
    end
end

local function Scorch_OnUpdateFade(inst)
    if inst._fade:value() > 1 then
        inst._fade:set_local(inst._fade:value() - 1)
        Scorch_OnFadeDirty(inst)
    elseif TheWorld.ismastersim then
        inst:Remove()
    elseif inst._fade:value() > 0 then
        inst._fade:set_local(0)
        inst.AnimState:OverrideMultColour(1, 1, 1, 0)
    end
end

local function scorchfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("burntground")
    inst.AnimState:SetBank("burntground")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")

    inst._fade = net_byte(inst.GUID, "fused_shadeling_bomb_scorch._fade", "fadedirty")
    inst._fade:set(SCORCH_DELAY_FRAMES + SCORCH_FADE_FRAMES)

    inst:DoPeriodicTask(0, Scorch_OnUpdateFade)
    Scorch_OnFadeDirty(inst)

    inst.Transform:SetScale(0.7, 0.7, 0.7)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        inst:ListenForEvent("fadedirty", Scorch_OnFadeDirty)

        return inst
    end

    inst.Transform:SetRotation(math.random() * 360)
    inst.persists = false

    return inst
end

return Prefab("fused_shadeling_bomb", fn, assets, prefabs),
    Prefab("fused_shadeling_bomb_death_fx", death_fx_fn, assets),
    Prefab("fused_shadeling_quickfuse_bomb", quickfuse_fn, assets),
    Prefab("fused_shadeling_bomb_scorch", scorchfn, scorch_assets)