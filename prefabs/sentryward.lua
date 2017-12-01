require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/sentryward.zip"),
}

local prefabs =
{
    "collapse_small",
    "globalmapicon",
}

local function onhammered(inst)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit_full")
        inst.AnimState:PushAnimation("idle_full_loop")
    end
end

local function onbuilt(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/sentryward_craft")
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle_full_loop")
end

local function onburnt(inst)
    inst.components.maprevealer:Stop()
    if inst.icon ~= nil then
        inst.icon:Remove()
        inst.icon = nil
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

local function init(inst)
    if inst.icon == nil and not inst:HasTag("burnt") then
        inst.icon = SpawnPrefab("globalmapicon")
        inst.icon.MiniMapEntity:SetIsFogRevealer(true)
        inst.icon:TrackEntity(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("sentryward.png")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetDrawOverFogOfWar(true)

    MakeObstaclePhysics(inst, .1)

    inst.AnimState:SetBank("sentryward")
    inst.AnimState:SetBuild("sentryward")
    inst.AnimState:PlayAnimation("idle_full_loop", true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst:AddTag("structure")

    --maprevealer (from maprevealer component) added to pristine state for optimization
    inst:AddTag("maprevealer")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:SetTime(math.random() * 1.8)

    -----------------------
    MakeSmallBurnable(inst, nil, nil, true)
    inst:ListenForEvent("burntup", onburnt)

    MakeSmallPropagator(inst)
    MakeHauntableWork(inst)

    -------------------------
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    -----------------------------

    inst:AddComponent("inspectable")

    inst:AddComponent("maprevealer")

    inst:ListenForEvent("onbuilt", onbuilt)
    inst.OnSave = onsave
    inst.OnLoad = onload

    inst:DoTaskInTime(0, init)

    return inst
end

return Prefab("sentryward", fn, assets, prefabs),
    MakePlacer("sentryward_placer", "sentryward", "sentryward", "idle_full")
