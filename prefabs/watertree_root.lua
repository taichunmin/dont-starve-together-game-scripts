local assets =
{
    Asset("ANIM", "anim/watertree_root.zip"),
}

local prefabs =
{
    "driftwood_log",
    "twigs",
}

SetSharedLootTable( 'watertree_root',
{
    {'driftwood_log',  1.00},
    {'driftwood_log',  0.30},
    {'twigs',  0.30},    

})

local function updateart(inst)
    inst.AnimState:PlayAnimation("idle"..inst.artid, true)
end

local function chop_tree(inst, chopper, chopsleft, numchops)   

end

local function OnWork(inst, worker, workleft)
    if worker == nil or not worker:HasTag("playerghost") then
        inst.SoundEmitter:PlaySound(
            (worker == nil and "dontstarve/wilson/use_axe_tree")
            or (worker:HasTag("boat") and "waterlogged1/common/boat_wood_small_impact")
            or (worker:HasTag("beaver") and "dontstarve/characters/woodie/beaver_chop_tree")
            or "dontstarve/wilson/use_axe_tree"
        )
    end

   inst.AnimState:PlayAnimation("hit"..inst.artid)
   inst.AnimState:PushAnimation("idle"..inst.artid, true)

    if workleft <= 0 then
        local fx = SpawnPrefab("collapse_small")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        local loot_dropper = inst.components.lootdropper

        inst:SetPhysicsRadiusOverride(nil)
        local pt = inst:GetPosition()
        loot_dropper:DropLoot(pt)

        inst:Remove()
    end
end

local DAMAGE_SCALE = 0.5
local function OnCollide(inst, data)
    local boat_physics = data.other.components.boatphysics
    if boat_physics ~= nil then
        local hit_velocity = math.floor(math.abs(boat_physics:GetVelocity() * data.hit_dot_velocity) * DAMAGE_SCALE / boat_physics.max_velocity + 0.5)
        inst.components.workable:WorkedBy(data.other, hit_velocity * TUNING.EVERGREEN_CHOPS_SMALL)
    end
end

local function onsave(inst, data)
    data.artid = inst.artid
end

local NUM_ART_TYPES = 3
local function onload(inst, data)
    inst.artid = (data and data.artid) or inst.artid or math.random(NUM_ART_TYPES)
    updateart(inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:SetPhysicsRadiusOverride(2.35)

    MakeWaterObstaclePhysics(inst, 0.80, 2, 0.75)

    inst:AddTag("ignorewalkableplatforms")
    inst:AddTag("tree")

    inst.AnimState:SetBank("watertree_root")
    inst.AnimState:SetBuild("watertree_root")
    inst.AnimState:PlayAnimation("idle1",true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('watertree_root')
    inst.components.lootdropper.max_speed = 2
    inst.components.lootdropper.min_speed = 0.3
    inst.components.lootdropper.y_speed = 14
    inst.components.lootdropper.y_speed_variance = 4
    inst.components.lootdropper.spawn_loot_inside_prefab = true

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.CHOP)
    inst.components.workable:SetWorkLeft(TUNING.WATERTREE_ROOT_CHOPS)
    inst.components.workable:SetOnWorkCallback(OnWork)
    inst.components.workable.savestate = true

    inst:AddComponent("inspectable")

    MakeHauntableWork(inst)

    inst:ListenForEvent("on_collide", OnCollide)

    if not POPULATING then
        inst.artid = math.random(NUM_ART_TYPES)
        updateart(inst)
    end

    --------SaveLoad
    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("watertree_root", fn, assets, prefabs)