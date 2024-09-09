require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/wintertree.zip"),
    Asset("ANIM", "anim/wintertree_build.zip"),
}

local prefabs =
{
    "collapse_small",
}

local function onhammered(inst)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onplanted(inst, data)
    local pos = inst:GetPosition()
    inst:Remove()
    local tree = SpawnPrefab(data.seed.components.winter_treeseed.winter_tree)
    tree.Transform:SetPosition(pos:Get())
    tree.components.growable:StartGrowing()
    data.seed:Remove()
    TheWorld:PushEvent("itemplanted", { doer = data.doer, pos = pos }) --this event is pushed in other places too
end

local function onbuilt(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/wintertree_place")
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
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
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(1) --recipe min_spacing/2
    MakeObstaclePhysics(inst, 0.5)

    inst.AnimState:SetBank("wintertree")
    inst.AnimState:SetBuild("wintertree_build")
    inst.AnimState:PlayAnimation("idle")

    MakeSnowCoveredPristine(inst)

    inst:AddTag("winter_treestand")
    inst:AddTag("structure")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onhammered)

    ---------------------
    MakeMediumBurnable(inst, 20, nil, true)
    MakeMediumPropagator(inst)
    MakeHauntableWork(inst)
    MakeSnowCovered(inst)

    inst.OnSave = onsave
    inst.OnLoad = onload

    inst:ListenForEvent("onbuilt", onbuilt)
    inst:ListenForEvent("plantwintertreeseed", onplanted)

    return inst
end

return Prefab("winter_treestand", fn, assets, prefabs),
    MakePlacer("winter_treestand_placer", "wintertree", "wintertree_build", "idle")
