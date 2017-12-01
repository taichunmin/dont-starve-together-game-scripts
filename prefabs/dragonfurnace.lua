require "prefabutil"

local prefabs =
{
    "collapse_big",
}

local assets =
{
    Asset("ANIM", "anim/dragonfly_furnace.zip"),
    Asset("MINIMAP_IMAGE", "dragonfly_furnace"),
}

local function getstatus(inst)
    return "HIGH"
end

local function onworkfinished(inst)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function onworked(inst)
    if inst._task2 ~= nil then
        inst._task2:Cancel()
        inst._task2 = nil

        inst.SoundEmitter:PlaySound("dontstarve/common/together/dragonfly_furnace/fire_LP", "loop")

        if inst._task1 ~= nil then
            inst._task1:Cancel()
            inst._task1 = nil
        end
    end
    inst.AnimState:PlayAnimation("hi_hit")
    inst.AnimState:PushAnimation("hi")
end

local function BuiltTimeLine1(inst)
    inst._task1 = nil
    inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
end

local function BuiltTimeLine2(inst)
    inst._task2 = nil
    inst.SoundEmitter:PlaySound("dontstarve/common/together/dragonfly_furnace/light")
    inst.SoundEmitter:PlaySound("dontstarve/common/together/dragonfly_furnace/fire_LP", "loop")
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("hi_pre", false)
    inst.AnimState:PushAnimation("hi")
    inst.SoundEmitter:KillSound("loop")
    inst.SoundEmitter:PlaySound("dontstarve/common/together/dragonfly_furnace/place")
    if inst._task2 ~= nil then
        inst._task2:Cancel()
        if inst._task1 ~= nil then
            inst._task1:Cancel()
        end
    end
    inst._task1 = inst:DoTaskInTime(30 * FRAMES, BuiltTimeLine1)
    inst._task2 = inst:DoTaskInTime(40 * FRAMES, BuiltTimeLine2)
end

local function onsavesalad(inst, data)
    data.salad = true
end

local function makesalad(inst)
    inst.AnimState:SetMultColour(.1, 1, .1, 1)

    inst:AddComponent("named")
    inst.components.named:SetName("Salad Furnace")

    inst.OnSave = onsavesalad
end

local function onload(inst, data)
    if data ~= nil and data.salad then
        makesalad(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .5)

    inst.MiniMapEntity:SetIcon("dragonfly_furnace.png")

    inst.Light:Enable(true)
    inst.Light:SetRadius(1.0)
    inst.Light:SetFalloff(.9)
    inst.Light:SetIntensity(0.5)
    inst.Light:SetColour(235 / 255, 121 / 255, 12 / 255)

    inst.AnimState:SetBank("dragonfly_furnace")
    inst.AnimState:SetBuild("dragonfly_furnace")
    inst.AnimState:PlayAnimation("hi", true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetLightOverride(0.4)

    inst:AddTag("structure")
    inst:AddTag("wildfireprotected")

    --cooker (from cooker component) added to pristine state for optimization
    inst:AddTag("cooker")

    --HASHEATER (from heater component) added to pristine state for optimization
    inst:AddTag("HASHEATER")

    inst.SoundEmitter:PlaySound("dontstarve/common/together/dragonfly_furnace/fire_LP", "loop")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -----------------------
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(6)
    inst.components.workable:SetOnFinishCallback(onworkfinished)
    inst.components.workable:SetOnWorkCallback(onworked)

    -----------------------
    inst:AddComponent("cooker")
    inst:AddComponent("lootdropper")

    -----------------------
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    -----------------------
    inst:AddComponent("heater")
    inst.components.heater.heat = 115

    -----------------------
    MakeHauntableWork(inst)

    inst:ListenForEvent("onbuilt", onbuilt)
    inst.OnLoad = onload

    return inst
end

local function saladfurnacefn()
    local inst = fn()

    inst:SetPrefabName("dragonflyfurnace")

    if not TheWorld.ismastersim then
        return inst
    end

    makesalad(inst)

    return inst
end

return Prefab("dragonflyfurnace", fn, assets, prefabs),
       Prefab("saladfurnace", saladfurnacefn, assets, prefabs),
       MakePlacer("dragonflyfurnace_placer", "dragonfly_furnace", "dragonfly_furnace", "idle")
