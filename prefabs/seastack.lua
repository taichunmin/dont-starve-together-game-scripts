local assets =
{
    Asset("ANIM", "anim/water_rock_01.zip"),
    Asset("MINIMAP_IMAGE", "seastack"),
}

local prefabs =
{
    "rock_break_fx",
    "waterplant_baby",
    "waterplant_destroy",
}

SetSharedLootTable( 'seastack',
{
    {'rocks',  1.00},
    {'rocks',  1.00},
    {'rocks',  1.00},
    {'rocks',  1.00},
})

local function updateart(inst)
    local workleft = inst.components.workable.workleft
    inst.AnimState:PlayAnimation(
        (workleft > 6 and inst.stackid.."_full") or
        (workleft > 3 and inst.has_medium_state and inst.stackid.."_med") or inst.stackid.."_low"
    )
end

local function OnWork(inst, worker, workleft)
    if workleft <= 0 then
        TheWorld:PushEvent("CHEVO_seastack_mined", {target=inst,doer=worker})
        local pt = inst:GetPosition()
        SpawnPrefab("rock_break_fx").Transform:SetPosition(pt:Get())

        local loot_dropper = inst.components.lootdropper

        inst:SetPhysicsRadiusOverride(nil)

        loot_dropper:DropLoot(pt)

        inst:Remove()
    else
        updateart(inst)
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

local function onsave(inst, data)
    data.stackid = inst.stackid
end

local NUM_STACK_TYPES = 5
local function onload(inst, data)
    inst.stackid = (data and data.stackid) or inst.stackid or math.random(NUM_STACK_TYPES)
    updateart(inst)
end

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

    MakeInventoryFloatable(inst, "med", 0.1, {1.1, 0.9, 1.1})
    inst.components.floater.bob_percent = 0

    local land_time = (POPULATING and math.random()*5*FRAMES) or 0
    inst:DoTaskInTime(land_time, function(inst)
        inst.components.floater:OnLandedServer()
    end)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('seastack')
    inst.components.lootdropper.max_speed = 2
    inst.components.lootdropper.min_speed = 0.3
    inst.components.lootdropper.y_speed = 14
    inst.components.lootdropper.y_speed_variance = 4
    inst.components.lootdropper.spawn_loot_inside_prefab = true

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.SEASTACK_MINE)
    inst.components.workable:SetOnWorkCallback(OnWork)
    inst.components.workable.savestate = true

    inst:AddComponent("inspectable")

    inst:AddComponent("upgradeable")
    inst.components.upgradeable.upgradetype = UPGRADETYPES.WATERPLANT
    inst.components.upgradeable.onupgradefn = on_upgraded

    MakeHauntableWork(inst)

    inst:ListenForEvent("on_collide", OnCollide)

    if not POPULATING then
        inst.stackid = math.random(NUM_STACK_TYPES)
        updateart(inst)
    end

    --------SaveLoad
    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

local function spawnerfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("CLASSIFIED")

    return inst
end

return Prefab("seastack", fn, assets, prefabs),
       Prefab("seastack_spawner_swell", spawnerfn, assets, prefabs),
       Prefab("seastack_spawner_rough", spawnerfn, assets, prefabs)
