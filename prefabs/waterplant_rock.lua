local assets =
{
    Asset("ANIM", "anim/barnacle_plant.zip"),
    Asset("ANIM", "anim/barnacle_plant_colour_swaps.zip"),
}

local prefabs =
{
    "rocks",
    "waterplant_baby",
    "waterplant_destroy",
}

SetSharedLootTable( "waterplant_rock",
{
    {"rocks",  1.00},
    {"rocks",  1.00},
})

local function OnWork(inst, worker, workleft)
    if workleft <= 0 then
        local pt = inst:GetPosition()
        SpawnPrefab("rock_break_fx").Transform:SetPosition(pt:Get())

        local loot_dropper = inst.components.lootdropper

        inst:SetPhysicsRadiusOverride(nil)

        loot_dropper:DropLoot(pt)

        inst:Remove()
    end
end

local function on_upgraded(inst, upgrade_doer)
    local sx, sy, sz = inst.Transform:GetWorldPosition()

    local baby = SpawnPrefab("waterplant_baby")
    baby.Transform:SetPosition(sx, sy, sz)
    if baby.WaitForRebirth ~= nil then
        baby:WaitForRebirth()
    end

    local fx = SpawnPrefab("waterplant_destroy")
    fx.Transform:SetPosition(sx, sy, sz)

    if upgrade_doer ~= nil then
        TheWorld:PushEvent("itemplanted", {doer = upgrade_doer, pos = Vector3(sx, sy, sz)})
    end

    inst:Remove()
end

local DAMAGE_SCALE = 0.5
local function OnCollide(inst, data)
    local boat_physics = data.other.components.boatphysics
    if boat_physics ~= nil then
        local hit_velocity = math.floor(math.abs(boat_physics:GetVelocity() * data.hit_dot_velocity) * DAMAGE_SCALE / boat_physics.max_velocity + 0.5)
        inst.components.workable:WorkedBy(data.other, hit_velocity * TUNING.SEASTACK_MINE)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:SetPhysicsRadiusOverride(2.35)
    MakeWaterObstaclePhysics(inst, 0.80, 2, 0.75)

    inst.Transform:SetSixFaced()

    inst:AddTag("ignorewalkableplatforms")
    inst:AddTag("seastack")
    inst:AddTag("waterplant")       -- So that plants don't try to affect each other

    inst.AnimState:SetBank("barnacle_plant")
    inst.AnimState:SetBuild("barnacle_plant_colour_swaps")
    inst.AnimState:PlayAnimation("idle2", true)

    -- We want these to look like seastacks!
    inst:SetPrefabNameOverride("seastack")

    MakeInventoryFloatable(inst, "med", 0.1, {1.1, 0.9, 1.1})
    inst.components.floater.bob_percent = 0
    inst.components.floater.splash = false

    inst.AnimState:Hide("stage1")
    inst.AnimState:Hide("vines")
    inst.AnimState:Hide("bud1")
    inst.AnimState:Hide("bud2")
    inst.AnimState:Hide("bud3")

    inst.AnimState:Hide("stage2")
    inst.AnimState:Hide("top_bud")

    inst.AnimState:Hide("stage3")
    inst.AnimState:Hide("mouth")
    inst.AnimState:Hide("eye")
    inst.AnimState:Hide("flower_petal")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    local land_time = (POPULATING and math.random()*5*FRAMES) or 0
    inst:DoTaskInTime(land_time, function(inst)
        inst.components.floater:OnLandedServer()
    end)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("waterplant_rock")
    inst.components.lootdropper.max_speed = 2
    inst.components.lootdropper.min_speed = 0.3
    inst.components.lootdropper.y_speed = 14
    inst.components.lootdropper.y_speed_variance = 4
    inst.components.lootdropper.spawn_loot_inside_prefab = true

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.WATERPLANT_ROCK_WORKAMOUNT)
    inst.components.workable:SetOnWorkCallback(OnWork)
    inst.components.workable.savestate = true

    inst:AddComponent("inspectable")

    inst:AddComponent("upgradeable")
    inst.components.upgradeable.upgradetype = UPGRADETYPES.WATERPLANT
    inst.components.upgradeable.onupgradefn = on_upgraded

    MakeHauntableWork(inst)

    inst:ListenForEvent("on_collide", OnCollide)

    return inst
end

return Prefab("waterplant_rock", fn, assets, prefabs)
