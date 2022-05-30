local assets =
{
    Asset("ANIM", "anim/nightmaregrowth.zip"),
}

local prefabs =
{
    "nightmaregrowth_crack",
}

local spawner_prefabs =
{
    "nightmaregrowth",
    "collapse_small",
}

local SPAWN_DELAY = 2.5
local SPAWN_DELAY_VARIANCE = 3

local DESTROY_ON_GROW_TAGS = { "structure", "tree", "boulder" }
local DESTROY_RADIUS = 4

local GROW_SOUND_DELAY = 9*FRAMES

local function SpawnCrack(inst)
    local x, y, z = inst.Transform:GetWorldPosition()

    local ents = TheSim:FindEntities(x, y, z, 4, nil, nil, DESTROY_ON_GROW_TAGS)
    for i, v in ipairs(ents) do
        if v:IsValid() and v.components.workable ~= nil and v.components.workable:CanBeWorked() then
            SpawnPrefab("collapse_small").Transform:SetPosition(v.Transform:GetWorldPosition())
            v.components.workable:Destroy(inst)
        end
    end

    if inst._crack == nil or not inst._crack:IsValid() then
        inst._crack = SpawnPrefab("nightmaregrowth_crack")
        inst._crack.Transform:SetPosition(x, y, z)

        if inst._crack_rotation ~= nil then
            inst._crack.Transform:SetRotation(inst._crack_rotation)
            inst._crack_rotation = nil
        end
    end
end

local function PlayGrowSound(inst)
    inst.SoundEmitter:PlaySound("grotto/common/nightmare_growth/grow")
end

local function grow(inst)
    inst.AnimState:PlayAnimation("grow")
    inst.AnimState:PushAnimation("idle", false)

    SpawnCrack(inst)

    inst._crack.AnimState:PlayAnimation("crack")
    inst._crack.AnimState:PushAnimation("crack_idle", false)

    inst.SoundEmitter:PlaySound("grotto/common/nightmare_growth/crack")
    inst:DoTaskInTime(GROW_SOUND_DELAY, PlayGrowSound)
end

local function OnRemove(inst)
    if inst._crack ~= nil and inst._crack:IsValid() then
        inst._crack:Remove()
    end
end

local function OnSave(inst, data)
    if inst._crack ~= nil and inst._crack:IsValid() then
        data.crack_rotation = inst._crack.Transform:GetRotation()
    end
end

local function OnLoad(inst, data)
    if data ~= nil and data.crack_rotation ~= nil then
        inst._crack_rotation = data.crack_rotation
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("nightmaregrowth")
    inst.AnimState:SetBank("nightmaregrowth")
    inst.AnimState:PlayAnimation("idle")

    inst.MiniMapEntity:SetIcon("nightmaregrowth.png")

    MakeObstaclePhysics(inst, 1.1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -- inst._crack = nil
    -- inst._crack_rotation = nil

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_SUPERHUGE

    inst:AddComponent("inspectable")

    inst.growfn = grow

    inst:DoTaskInTime(0, SpawnCrack)

    inst:ListenForEvent("onremove", OnRemove)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

local function crackfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("nightmaregrowth")
    inst.AnimState:SetBuild("nightmaregrowth")
    inst.AnimState:PlayAnimation("crack_idle", false)

    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("DECOR")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.Transform:SetRotation(math.random() * 360)

    return inst
end

local function spawnnightmaregrowth(inst)
    local obj = SpawnPrefab("nightmaregrowth")
    obj.Transform:SetPosition(inst.Transform:GetWorldPosition())
    obj:growfn()

    ShakeAllCameras(CAMERASHAKE.VERTICAL, .9, .02, .18, obj, 12)

    inst:Remove()
end

local function SpawnerOnLoad(inst, data)
    SpawnPrefab("nightmaregrowth").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end

local function spawner_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:DoTaskInTime(SPAWN_DELAY + math.random() * SPAWN_DELAY_VARIANCE, spawnnightmaregrowth)

    inst.OnLoad = SpawnerOnLoad

    return inst
end

local function retrofit_spawner_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	TheWorld:PushEvent("ms_register_retrofitted_grotterwar_spawnpoint", {inst = inst})

    return inst
end

local function retrofit_home_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	TheWorld:PushEvent("ms_register_retrofitted_grotterwar_homepoint", {inst = inst})

    return inst
end

return Prefab("nightmaregrowth", fn, assets, prefabs),
    Prefab("nightmaregrowth_crack", crackfn),
    Prefab("nightmaregrowth_spawner", spawner_fn, nil, spawner_prefabs),
    Prefab("retrofitted_grotterwar_spawnpoint", retrofit_spawner_fn, nil, spawner_prefabs),
    Prefab("retrofitted_grotterwar_homepoint", retrofit_home_fn, nil, spawner_prefabs)
