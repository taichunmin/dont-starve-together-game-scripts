local assets =
{
    Asset("ANIM", "anim/fused_shadeling.zip"),
}

local prefabs =
{
    "fused_shadeling_bomb",
    "fused_shadeling_quickfuse_bomb",
    "fused_shadeling_spawn_fx",
    "horrorfuel",
}

local brain = require("brains/fused_shadelingbrain")

local function CalcSanityAura(inst, observer)
    return (inst.components.combat:HasTarget() and (
                (inst.components.combat:TargetIs(observer) and -TUNING.SANITYAURA_LARGE)
            or -TUNING.SANITYAURA_MED)
        ) or 0
end

SetSharedLootTable("fused_shadeling",
{
    {"horrorfuel", 1.00},
    {"horrorfuel", 1.00},
    {"horrorfuel", 0.75},
    {"horrorfuel", 0.50},
})

----
local function keep_target(inst, current_target)
    local range_test_point = inst.components.knownlocations:GetLocation("spawnpoint") or inst:GetPosition()
    local target_x, target_y, target_z = current_target.Transform:GetWorldPosition()

    local aggro_rangesq = (TUNING.FUSED_SHADELING_AGGRO_RANGE * TUNING.FUSED_SHADELING_AGGRO_RANGE)
    return distsq(range_test_point.x, range_test_point.z, target_x, target_z) < aggro_rangesq
end

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "INLIMBO", "shadow_aligned" }
local RETARGET_ONEOF_TAGS = { "character", "monster" }
local function try_retarget(inst)
    local target = inst.components.combat.target
    if target then
        local range = inst.components.combat:GetAttackRange()
        local my_x, my_y, my_z = inst.Transform:GetWorldPosition()
        if target:GetDistanceSqToPoint(my_x, my_y, my_z) < (range * range) then
            return
        end
    end

    local target_source = (inst.components.entitytracker:GetEntity("portal") or inst)
    return FindEntity(target_source,
        TUNING.FUSED_SHADELING_AGGRO_RANGE,
        function(guy) return inst.components.combat:CanTarget(guy) end,
        RETARGET_MUST_TAGS,
        RETARGET_CANT_TAGS,
        RETARGET_ONEOF_TAGS)
end

----
local function OnSpawnedBy(inst, portal, delay)
    if portal ~= nil then
        inst.components.entitytracker:TrackEntity("portal", portal)
        inst:ListenForEvent("onremove", inst._on_portal_removed, portal)
    end

    inst.sg:GoToState("spawn_delay", delay or FRAMES)
end

----
local function on_timer_done(inst, data)
    if data.name == "initialize" then
        inst.components.knownlocations:RememberLocation("spawnpoint", inst:GetPosition())
    end
end

----
local function on_attacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
end

----
local function remove_character_physics(inst)
    local physics = inst.Physics
    physics:ClearCollisionMask()
    physics:CollidesWith(COLLISION.WORLD)
    physics:CollidesWith(COLLISION.GIANTS)
end

local function reset_character_physics(inst)
    local physics = inst.Physics
    physics:ClearCollisionMask()
    physics:CollidesWith(COLLISION.WORLD)
    physics:CollidesWith(COLLISION.OBSTACLES)
    physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    physics:CollidesWith(COLLISION.CHARACTERS)
    physics:CollidesWith(COLLISION.GIANTS)
end

----

local function on_load_post_pass(inst)
	local portal = inst.components.entitytracker:GetEntity("portal")

	if portal ~= nil then
        inst:ListenForEvent("onremove", inst._on_portal_removed, portal)
    else
        inst._on_portal_removed()
	end
end

----
local MIN_TRANSPARENCY = 0.4
local function CLIENT_CalculateSanityTransparencyForPlayer(inst, player)
    local player_sanity_replica = player.replica.sanity
    return (not player_sanity_replica and MIN_TRANSPARENCY) or
        math.clamp(1 - player_sanity_replica:GetPercent(), MIN_TRANSPARENCY, 1.0)
end

----
local sounds =
{
    death = "daywalker/leech/die",
    attack = "daywalker/leech/vocalization",
    taunt = "daywalker/leech/vocalization",
    taunt2 = "daywalker/leech/fall_off",
    appear = "daywalker/leech/fall_off",
    disappear = "daywalker/leech/fall_off",
    hit = "daywalker/leech/die",
    jump_pre = "daywalker/leech/leap",
    walk = "daywalker/leech/walk",
    bomb_spawn = "wes/common/foley/balloon_vest",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 10, 1.2)

    inst.Transform:SetSixFaced()

    inst.DynamicShadow:SetSize(2.0, 1.25)

    inst:AddTag("hostile")
    inst:AddTag("monster")
    inst:AddTag("notraptrigger")
    inst:AddTag("shadow")
    inst:AddTag("shadow_aligned")

    inst.AnimState:SetBank("fused_shadeling")
    inst.AnimState:SetBuild("fused_shadeling")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetSymbolLightOverride("red_art", 1.0)

    if not TheNet:IsDedicated() then
        local transparentonsanity_cmp = inst:AddComponent("transparentonsanity")
        transparentonsanity_cmp.most_alpha = 1.0
        transparentonsanity_cmp.calc_percent_fn = CLIENT_CalculateSanityTransparencyForPlayer
        transparentonsanity_cmp:ForceUpdate()
    end

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.sounds = sounds

    inst.OnSpawnedBy = OnSpawnedBy

    --
    inst._RemoveCharacterPhysics = remove_character_physics
    inst._ResetCharacterPhysics = reset_character_physics

    --
    local sanityaura = inst:AddComponent("sanityaura")
    sanityaura.aurafn = CalcSanityAura

    --
    local combat = inst:AddComponent("combat")
    combat:SetAttackPeriod(TUNING.FUSED_SHADELING_ATTACK_PERIOD)
    combat:SetDefaultDamage(TUNING.FUSED_SHADELING_DAMAGE)
    combat:SetRange(TUNING.FUSED_SHADELING_ATTACK_RANGE)
    combat:SetKeepTargetFunction(keep_target)
    combat:SetRetargetFunction(3, try_retarget)

    --
    inst:AddComponent("entitytracker")

    --
    local health = inst:AddComponent("health")
    health:SetMaxHealth(TUNING.FUSED_SHADELING_HEALTH)
    health.nofadeout = true

    --
    inst:AddComponent("inspectable")

    --
    inst:AddComponent("knownlocations")

    --
    local locomotor = inst:AddComponent("locomotor")
    locomotor.runspeed = TUNING.SHADOW_LEECH_RUNSPEED
    locomotor:SetTriggersCreep(false)
    locomotor.pathcaps = { ignorecreep = true }

    --
    local lootdropper = inst:AddComponent("lootdropper")
    lootdropper:SetChanceLootTable("fused_shadeling")

    --
    inst:AddComponent("planarentity")

    --
    local planardamage = inst:AddComponent("planardamage")
    planardamage:SetBaseDamage(TUNING.FUSED_SHADELING_PLANAR_DAMAGE)

    --
    local timer = inst:AddComponent("timer")
    timer:StartTimer("initialize", 0)

    --

    inst.OnLoadPostPass = on_load_post_pass

    --
    inst:SetStateGraph("SGfused_shadeling")
    inst:SetBrain(brain)

    --
    inst:ListenForEvent("timerdone", on_timer_done)
    inst:ListenForEvent("attacked", on_attacked)

    --
    inst._on_portal_removed = function(portal)
        if inst:IsAsleep() then
            inst:Remove()
        else
            inst:PushEvent("do_despawn")
        end
    end

    return inst
end

return Prefab("fused_shadeling", fn, assets, prefabs)