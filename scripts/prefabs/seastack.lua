local easing = require("easing")

------------------------------------------------------------------------------------------------------------------------------------

local assets =
{
    Asset("ANIM", "anim/water_rock_01.zip"),
    Asset("MINIMAP_IMAGE", "seastack"),
    Asset("MINIMAP_IMAGE", "seastack_painted"),
}

local prefabs =
{
    "rock_break_fx",
    "waterplant_baby",
    "waterplant_destroy",
}

------------------------------------------------------------------------------------------------------------------------------------

SetSharedLootTable("seastack",
{
    {"rocks",  1.00},
    {"rocks",  1.00},
    {"rocks",  1.00},
    {"rocks",  1.00},
})

local COLLISION_DAMAGE_SCALE = 0.5

local NUM_STACK_TYPES = 5

------------------------------------------------------------------------------------------------------------------------------------

local function UpdateArt(inst)
    local workleft = inst.components.workable.workleft

    inst.AnimState:PlayAnimation(
        (workleft > 6 and inst.stackid.."_full") or
        (workleft > 3 and inst.has_medium_state and inst.stackid.."_med") or
        inst.stackid.."_low"
    )
end

local function OnWork(inst, worker, workleft)
    if workleft > 0 then
        inst:UpdateArt()

        return
    end

    SpawnPrefab("rock_break_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
    TheWorld:PushEvent("CHEVO_seastack_mined", { target = inst, doer = worker }) -- Unused event?

    inst:SetPhysicsRadiusOverride(nil)

    inst.components.lootdropper:DropLoot()
    inst:Remove()
end

local function OnUpgraded(inst, doer)
    local x, y, z = inst.Transform:GetWorldPosition()

    local baby = SpawnPrefab("waterplant_baby")
    baby.Transform:SetPosition(x, 0, z)

    if baby.WaitForRebirth ~= nil then
        baby:WaitForRebirth()
    end

    if doer ~= nil then
        TheWorld:PushEvent("itemplanted", { doer = doer, pos = Vector3(x, 0, z)})
    end

    SpawnPrefab("waterplant_destroy").Transform:SetPosition(x, 0, z)

    inst:Remove()

    return baby -- Mods.
end

local function OnCollide(inst, data)
    local boat_physics = data.other.components.boatphysics

    if boat_physics ~= nil then
        local hit_velocity = math.floor(math.abs(boat_physics:GetVelocity() * data.hit_dot_velocity) * COLLISION_DAMAGE_SCALE / boat_physics.max_velocity + 0.5)

        inst.components.workable:WorkedBy(data.other, hit_velocity * TUNING.SEASTACK_MINE)
    end
end

------------------------------------------------------------------------------------------------------------------------------------

local function OnSave(inst, data)
    data.stackid = inst.stackid
    data.tinted  = inst.tinted
end

local function OnLoad(inst, data)
    if data == nil or data.tinted == nil then
        inst:DoTaskInTime(0, inst.TestForPowderMonkeyTint)

    elseif data.tinted ~= nil then
        inst.tinted = data.tinted
    end

    if inst.tinted then
        inst.AnimState:Show(math.random() > 0.5 and "paint_A" or "paint_B")
        inst.MiniMapEntity:SetIcon("seastack_painted.png")
    end

    inst.stackid = (data and data.stackid) or inst.stackid or math.random(NUM_STACK_TYPES)

    inst:UpdateArt()
end

------------------------------------------------------------------------------------------------------------------------------------

local MONKEYQUEEN = nil -- Cached ent.

local function TestForPowderMonkeyTint(inst)
    if MONKEYQUEEN == nil or not MONKEYQUEEN:IsValid() then
        MONKEYQUEEN = TheSim:FindFirstEntityWithTag("monkeyqueen")
    end

    if MONKEYQUEEN == nil or not MONKEYQUEEN:IsValid() then
        inst.tinted = false

        return
    end

    local dist_island = inst:GetDistanceSqToInst(MONKEYQUEEN)

    if dist_island > TUNING.POWDER_MONKEY_TERRITORY_TINTED_SEASTACK_RADIUS_SQ then
        inst.tinted = false

        return
    end

    inst.tinted = math.random() <= easing.linear(
        dist_island,
        TUNING.POWDER_MONKEY_TERRITORY_TINTED_SEASTACK_CHANCE.max,
        TUNING.POWDER_MONKEY_TERRITORY_TINTED_SEASTACK_CHANCE.min - TUNING.POWDER_MONKEY_TERRITORY_TINTED_SEASTACK_CHANCE.max,
        TUNING.POWDER_MONKEY_TERRITORY_TINTED_SEASTACK_RADIUS_SQ
    )

    if inst.tinted then
        inst.AnimState:Show(math.random() > 0.5 and "paint_A" or "paint_B")
        inst.MiniMapEntity:SetIcon("seastack_painted.png")
    end
end

------------------------------------------------------------------------------------------------------------------------------------

local function CLIENT_ForceFloaterUpdate(inst)
    inst.components.floater:OnLandedServer()
end

local SCRAPBOOK_HIDE_SYMBOL = { "paint_A", "paint_B"}

------------------------------------------------------------------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("seastack.png")

    inst:SetPhysicsRadiusOverride(2.35)

    MakeWaterObstaclePhysics(inst, 0.80, 2, 0.75)

    inst:AddTag("ignorewalkableplatforms")
    inst:AddTag("seastack")

    inst.AnimState:SetBank("water_rock01")
    inst.AnimState:SetBuild("water_rock_01")
    inst.AnimState:PlayAnimation("1_full")

    inst.AnimState:Hide("paint_A")
    inst.AnimState:Hide("paint_B")

    MakeInventoryFloatable(inst, "med", 0.1, {1.1, 0.9, 1.1})
    inst.components.floater:SetIsObstacle()
    inst.components.floater.bob_percent = 0

    local land_time = POPULATING and (math.random() * 5 * FRAMES) or 0
    inst:DoTaskInTime(land_time, CLIENT_ForceFloaterUpdate)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_anim = "1_full"
    inst.scrapbook_hide = SCRAPBOOK_HIDE_SYMBOL

    inst.TestForPowderMonkeyTint = TestForPowderMonkeyTint
    inst.UpdateArt = UpdateArt
    inst._OnCollide = OnCollide

    inst:AddComponent("inspectable")

    local lootdropper = inst:AddComponent("lootdropper")
    lootdropper:SetChanceLootTable("seastack")
    lootdropper.max_speed = 2
    lootdropper.min_speed = 0.3
    lootdropper.y_speed = 14
    lootdropper.y_speed_variance = 4
    lootdropper.spawn_loot_inside_prefab = true

    local workable = inst:AddComponent("workable")
    workable:SetWorkAction(ACTIONS.MINE)
    workable:SetWorkLeft(TUNING.SEASTACK_MINE)
    workable:SetOnWorkCallback(OnWork)
    workable.savestate = true

    local upgradeable = inst:AddComponent("upgradeable")
    upgradeable.upgradetype = UPGRADETYPES.WATERPLANT
    upgradeable.onupgradefn = OnUpgraded

    inst:ListenForEvent("on_collide", inst._OnCollide)

    -- For console spawning.
    if not POPULATING then
        inst.stackid = math.random(NUM_STACK_TYPES)
        inst:UpdateArt()
    end

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    MakeHauntableWork(inst)

    return inst
end

local function spawnerfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("CLASSIFIED")

    return inst
end

return
    Prefab("seastack",               fn,        assets, prefabs),
    Prefab("seastack_spawner_swell", spawnerfn, assets, prefabs),
    Prefab("seastack_spawner_rough", spawnerfn, assets, prefabs)
