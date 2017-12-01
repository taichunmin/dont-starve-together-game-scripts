local assets =
{
    Asset("ANIM", "anim/cave_hole.zip"),
}

local prefabs =
{
    "small_puff",
}

local loot =
{
    greengem = 0.1,
    yellowgem = 0.4,
    orangegem = 0.4,
    purplegem = 0.4,
    thulecite = 1.0,
    thulecite_pieces = 1.0,
    nightmare_timepiece = 0.1,
}

local loot_stacksize =
{
    thulecite           = function() return math.random(3) end,
    thulecite_pieces    = function() return 4 + math.random(3) end,
}

for k, _ in pairs(loot) do
    table.insert(prefabs, k)
end

local function SetObjectInHole(inst, obj)
    obj.Physics:SetActive(false)
    obj:AddTag("outofreach")
    inst:ListenForEvent("onremove", inst._onremoveobj, obj)
    inst:ListenForEvent("onpickup", inst._onpickupobj, obj)
end

local function tryspawn(inst)
    if inst.allowspawn and #inst.components.objectspawner.objects <= 0 then
        local lootobj = inst.components.objectspawner:SpawnObject(weighted_random_choice(loot))

        if loot_stacksize[lootobj.prefab] ~= nil and lootobj.components.stackable ~= nil then
            local stacksize = loot_stacksize[lootobj.prefab]()
            lootobj.components.stackable:SetStackSize(stacksize)
        end

        local x, y, z = inst.Transform:GetWorldPosition()
        lootobj.Physics:Teleport(x, y, z)

        if not inst:IsAsleep() then
            SpawnPrefab("small_puff").Transform:SetPosition(x, y, z)
        end
    end

    inst.allowspawn = false
end

local function OnSave(inst, data)
    data.allowspawn = inst.allowspawn
end

local function OnLoad(inst, data)
    if data ~= nil then
        inst.allowspawn = data.allowspawn
    end
end

local function CreateSurfaceAnim()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("DECOR")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.persists = false

    inst.AnimState:SetBank("cave_hole")
    inst.AnimState:SetBuild("cave_hole")
    inst.AnimState:Hide("hole")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(2)

    inst.Transform:SetEightFaced()

    return inst
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst:AddTag("groundhole")
    inst:AddTag("blocker")

    inst.entity:AddPhysics()
    inst.Physics:SetMass(0)
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
    inst.Physics:SetCylinder(2.75, 6)

    inst.AnimState:SetBank("cave_hole")
    inst.AnimState:SetBuild("cave_hole")
    inst.AnimState:Hide("surface")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(2)

    inst.MiniMapEntity:SetIcon("cave_hole.png")

    inst.Transform:SetEightFaced()

    inst:SetDeployExtraSpacing(5)

    --NOTE: Shadows are on WORLD_BACKGROUND sort order 1
    --      Hole goes above to hide shadows
    --      Surface goes below to reveal shadows
    --Dedicated server does not need to spawn the local animation
    if not TheNet:IsDedicated() then
        CreateSurfaceAnim().entity:SetParent(inst.entity)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("objectspawner")
    inst.components.objectspawner.onnewobjectfn = SetObjectInHole

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst.allowspawn = true
    inst:DoTaskInTime(0, tryspawn)

    inst:ListenForEvent("resetruins", function()
        inst.allowspawn = true
        inst:DoTaskInTime(math.random() * .75, tryspawn)
    end, TheWorld)

    inst._onremoveobj = function(obj)
        table.removearrayvalue(inst.components.objectspawner.objects, obj)
    end

    inst._onpickupobj = function(obj)
        obj.Physics:SetActive(true)
        obj:RemoveTag("outofreach")
        inst._onremoveobj(obj)
        inst:RemoveEventCallback("onremove", inst._onremoveobj, obj)
        inst:RemoveEventCallback("onpickup", inst._onpickupobj, obj)
    end

    return inst
end

return Prefab("cave_hole", fn, assets, prefabs)
