require "prefabutil"

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function DoCheckRain(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:SetPercent("meter", TheWorld.state.pop)
    end
end

local function StartCheckRain(inst)
    if inst.task == nil and not inst:HasTag("burnt") then
        inst.task = inst:DoPeriodicTask(1, DoCheckRain, 0)
    end
end

local function onhit(inst)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
    inst.AnimState:PlayAnimation("hit")
    --the global animover handler will restart the check task
end

local assets =
{
    Asset("ANIM", "anim/rain_meter.zip"),
}

local prefabs =
{
    "collapse_small",
}

local function onbuilt(inst)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
    inst.AnimState:PlayAnimation("place")
    inst.SoundEmitter:PlaySound("dontstarve/common/rain_meter_craft")
    --the global animover handler will restart the check task
end

local function makeburnt(inst)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .4)

    inst.MiniMapEntity:SetIcon("rainometer.png")

    inst.AnimState:SetBank("rain_meter")
    inst.AnimState:SetBuild("rain_meter")
    inst.AnimState:SetPercent("meter", 0)

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    MakeSnowCovered(inst)

    inst:ListenForEvent("onbuilt", onbuilt)
    inst:ListenForEvent("animover", StartCheckRain)

    StartCheckRain(inst)

    inst:AddTag("structure")
    MakeMediumBurnable(inst, nil, nil, true)
    MakeSmallPropagator(inst)
    inst.OnSave = onsave
    inst.OnLoad = onload
    inst:ListenForEvent("burntup", makeburnt)

    MakeHauntableWork(inst)

    return inst
end

return Prefab("rainometer", fn, assets, prefabs),
    MakePlacer("rainometer_placer", "rain_meter", "rain_meter", "idle")
