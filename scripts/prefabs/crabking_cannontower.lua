local easing = require("easing")

local assets =
{
    Asset("ANIM", "anim/crab_king_mortar.zip"),
    Asset("ANIM", "anim/crabking_mob.zip"),
    Asset("ANIM", "anim/pond_splash_fx.zip"),
    Asset("ANIM", "anim/boat_leak_build.zip"),

    Asset("ANIM", "anim/cannonball_rock_lvl2_build.zip"),
    Asset("ANIM", "anim/cannonball_rock_lvl3_build.zip"),

    Asset("MINIMAP_IMAGE", "crabking_cannontower"),
}

local prefabs =
{
    "rock_break_fx",
    "mortarball",

    "rocks",
    "barnacle",
    "kelp",
    "cannonball_rock_item",
}

------------------------------------------------------------------------------------------------------------------------------------

SetSharedLootTable("ck_cannontower",
{
    {"rocks",                1.00},
    {"rocks",                1.00},
    {"rocks",                0.50},
    {"rocks",                0.50},
    {"kelp",                 0.75},
    {"barnacle",             0.75},
    {"cannonball_rock_item", 0.75},
})

------------------------------------------------------------------------------------------------------------------------------------

local COLLISION_DAMAGE_SCALE = 0.5

local function OnCollide(inst, data)
    local boat_physics = data.other.components.boatphysics
    if boat_physics ~= nil then

        local mult = 1
        if inst.yellowgemcount >= 11 then
            mult = 0.3
        elseif inst.yellowgemcount > 7 then
            mult = 0.6
        elseif inst.yellowgemcount > 4 then
            mult = 0.8
        end

        local hit_velocity = math.floor(math.abs(boat_physics:GetVelocity() * data.hit_dot_velocity) * COLLISION_DAMAGE_SCALE / boat_physics.max_velocity + 0.5)
        local damage = hit_velocity * TUNING.CRABKING_CANNONTOWER_HEALTH * mult
        inst.components.health:DoDelta(-damage)
    end
end

------------------------------------------------------------------------------------------------------------------------------------

local BOATS_MUST_TAGS = { "boat" }
local TARGET_ONEOF_TAGS = { "smallcreature", "largecreature", "animal", "monster", "character" }
local TARGETS_CANT_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO", "noattack", "crabking_ally" }

local FIND_BOAT_DIST = 18
local FIND_TARGET_DIST = 12

------------------------------------------------------------------------------------------------------------------------------------

local function GetShootTargetPosition(inst, target)
    local x, y, z = target.Transform:GetWorldPosition()

    local radius = math.random() * 6
    local theta = PI2 * math.random()

    local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))

    return Vector3(x + offset.x, 0, z + offset.z)
end

local function LaunchProjectile(inst, target, projectile)
    local targetpos = inst:GetShootTargetPosition(target)

    local x, y, z = inst.AnimState:GetSymbolPosition("cannonball_rock02", 0, 0, 0)

    local projectile = SpawnPrefab(projectile or "mortarball")

    if projectile.components.complexprojectile == nil then
        projectile:AddComponent("complexprojectile")
    end

    local dx = targetpos.x - x
    local dz = targetpos.z - z
    local rangesq = dx * dx + dz * dz
    local maxrange = TUNING.FIRE_DETECTOR_RANGE
    local speed = easing.linear(rangesq, 15, 3, maxrange * maxrange)

    projectile.Transform:SetPosition(x, y + 0.3, z)

    projectile.components.complexprojectile:SetHorizontalSpeed(speed)
    projectile.components.complexprojectile:SetGravity(-25)
    projectile.components.complexprojectile:Launch(targetpos, inst)
    projectile.redgemcount = inst.redgemcount

    local damage = TUNING.CRABKING_MORTAR_DAMAGE + (inst.redgemcount and inst.redgemcount*TUNING.CRABKING_MORTAR_DAMAGE_BONUS or 0)
    if inst.redgemcount >= 11 then
        damage = damage + TUNING.CRABKING_MORTAR_MAXGEM_DAMAGE_BONUS
    end
    projectile:setdamage(damage)

    if inst.redgemcount ~= nil then
        local scale = (inst.redgemcount > 7 and 1.3) or (inst.redgemcount < 5 and 0.65) or nil

        if scale ~= nil then
            projectile.AnimState:SetScale(scale, scale)
        end
    end

    return projectile
end

------------------------------------------------------------------------------------------------------------------------------------

local function StartReloadTask(inst, time)
    if inst.reloadtask ~= nil then
        inst.reloadtask:Cancel()
    end

    inst.reloadtask = inst:DoTaskInTime(time, inst.TryShootCannon)
end

local function DoShootCannon(inst, ent)
    inst:LaunchProjectile(ent)

    inst:PushEvent("ck_shootcannon")

    if inst.reloadtask ~= nil then
        inst.reloadtask:Cancel()
        inst.reloadtask = nil
    end

    inst:TestForReload()
end

local function TryShootCannon(inst)
    if not inst.sg:HasStateTag("loaded") then
        if inst.reloadtask == nil then
            inst:StartReloadTask(1)
        end

        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local target_position = nil

    local boat = FindEntity(inst, FIND_BOAT_DIST, nil, BOATS_MUST_TAGS)

    if boat ~= nil then
        return inst:DoShootCannon(boat)
    end

    local ents = TheSim:FindEntities(x, 0, z, FIND_TARGET_DIST, nil, TARGETS_CANT_TAGS, TARGET_ONEOF_TAGS)

    if ents ~= nil and #ents > 0 then
        for i, ent in ipairs(ents) do
            if ent:HasTag("player") then
                return inst:DoShootCannon(ent)
            end

            local leader = ent.components.follower ~= nil and ent.components.follower:GetLeader() or nil

            if leader ~= nil and leader:HasTag("player") then
                return inst:DoShootCannon(ent)
            end
        end
    end

    inst:StartReloadTask(2)
end

local function TestForReload(inst)
    if inst.reloadtask ~= nil then
        return
    end

    if inst.sg:HasStateTag("empty") then
        inst:PushEvent("ck_loadcannon")

        inst:StartReloadTask(6+math.random()*4)

    else
        inst:DoTaskInTime(1, inst.TestForReload)
    end
end

------------------------------------------------------------------------------------------------------------------------------------

local function OnSink(inst)
    inst.components.floater:OnLandedServer()
end

------------------------------------------------------------------------------------------------------------------------------------

local function OnSave(inst, data)
    data.redgemcount = inst.redgemcount
    data.yellowgemcount = inst.yellowgemcount
end

local function OnLoad(inst, data)
    inst.redgemcount = data ~= nil and data.redgemcount or nil
    inst.yellowgemcount = data ~= nil and data.yellowgemcount or nil

    inst:UpdateMortarArt()
end

------------------------------------------------------------------------------------------------------------------------------------

local function onhit(inst)    
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_stone")
end

local function UpdateMortarArt(inst)
    if inst.redgemcount ~= nil and inst.redgemcount > 4 then
        inst.AnimState:AddOverrideBuild(inst.redgemcount > 7 and "cannonball_rock_lvl3_build" or "cannonball_rock_lvl2_build")
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("crabking_cannontower.png")

    inst:SetPhysicsRadiusOverride(2.35)

    MakeWaterObstaclePhysics(inst, 0.80, 2, 0.75)

    inst:AddTag("cannontower")
    inst:AddTag("hostile")
    inst:AddTag("crabking_ally")
    inst:AddTag("soulless")
    inst:AddTag("lunar_aligned")
    inst:AddTag("ignorewalkableplatformdrowning")

    inst.AnimState:SetBank("crab_king_mortar")
    inst.AnimState:SetBuild("crab_king_mortar")
    inst.AnimState:PlayAnimation("idle_empty")

    inst.AnimState:AddOverrideBuild("crabking_mob")
    inst.AnimState:AddOverrideBuild("cannonball_rock")
    inst.AnimState:AddOverrideBuild("pond_splash_fx")
    inst.AnimState:OverrideSymbol("leak_part", "boat_leak_build", "leak_part")

    MakeInventoryFloatable(inst, "large", 0.1, {0.7, 0.65, 0.7})
    inst.components.floater.bob_percent = 0

    local land_time = (POPULATING and math.random()*5*FRAMES) or 0

    inst:DoTaskInTime(land_time, function(inst)
        inst.components.floater:OnLandedServer()
    end)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_anim = "idle_empty"

    inst.StartReloadTask = StartReloadTask
    inst.TryShootCannon = TryShootCannon
    inst.DoShootCannon = DoShootCannon
    inst.TestForReload = TestForReload
    inst.GetShootTargetPosition = GetShootTargetPosition
    inst.LaunchProjectile = LaunchProjectile

    inst._OnCollide = OnCollide
    inst._OnSink = OnSink

    inst:AddComponent("inspectable")

    local lootdropper = inst:AddComponent("lootdropper")
    lootdropper:SetChanceLootTable("ck_cannontower")
    lootdropper.max_speed = 2
    lootdropper.min_speed = 0.3
    lootdropper.y_speed = 14
    lootdropper.y_speed_variance = 4
    lootdropper.spawn_loot_inside_prefab = true

    inst:AddComponent("combat")
    inst.components.combat.noimpactsound = true
    inst.components.combat:SetHurtSound("meta4/mortars/impact_small")
    inst.components.combat.onhitfn = onhit


    inst:AddComponent("health")
    inst.components.health.nofadeout = true
    inst.components.health.save_maxhealth = true
    inst.components.health.canheal = false
    inst.components.health:SetMaxHealth(TUNING.CRABKING_CANNONTOWER_HEALTH)

    inst:ListenForEvent("on_collide", inst._OnCollide)
    inst:ListenForEvent("onsink", inst._OnSink)

    inst:SetStateGraph("SGcrabking_cannontower")

    inst.UpdateMortarArt = UpdateMortarArt

    inst:DoTaskInTime(0, inst.UpdateMortarArt)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("crabking_cannontower", fn, assets, prefabs)
