local assets =
{
    Asset("ANIM", "anim/quagmire_park_fence.zip"),
}

local function InitializePathFinding(inst)
    if inst._pfpos == nil then
        inst._pfpos = inst:GetPosition()
        TheWorld.Pathfinder:AddWall(inst._pfpos:Get())
    end
end

local function OnRemoveEntity(inst)
    TheWorld.Pathfinder:RemoveWall(inst._pfpos:Get())
    inst._pfpos = nil
end

local function fn(anim)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("quagmire_park_fence")
    inst.AnimState:SetBuild("quagmire_park_fence")
    inst.AnimState:PlayAnimation(anim)

    MakeObstaclePhysics(inst, .2)

    inst.entity:SetPristine()
    inst.OnRemoveEntity = OnRemoveEntity

    inst:SetPrefabNameOverride("quagmire_parkspike")

    inst:DoTaskInTime(0, InitializePathFinding)

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    return inst
end

local function tallfn()
    return fn("idle")
end

local function shortfn()
    return fn("idle_short")
end

return Prefab("quagmire_parkspike", tallfn, assets),
    Prefab("quagmire_parkspike_short", shortfn, assets)
