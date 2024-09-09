require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/ice_box.zip"),
    Asset("ANIM", "anim/ui_chest_3x3.zip"),
}

local prefabs =
{
    "collapse_small",
}

local function onopen(inst)
    inst.AnimState:PlayAnimation("open")
    inst.SoundEmitter:PlaySound("dontstarve/common/icebox_open")
end

local function onclose(inst)
    inst.AnimState:PlayAnimation("close")
    inst.SoundEmitter:PlaySound("dontstarve/common/icebox_close")
end

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    inst.components.container:DropEverything()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("hit")
    inst.components.container:DropEverything()
    inst.AnimState:PushAnimation("closed", false)
    inst.components.container:Close()
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("closed", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/icebox_craft")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(0.75) --recipe min_spacing/2

    inst.MiniMapEntity:SetIcon("icebox.png")

    inst:AddTag("fridge")
    inst:AddTag("structure")

    inst.AnimState:SetBank("icebox")
    inst.AnimState:SetBuild("ice_box")
    inst.AnimState:PlayAnimation("closed")

    inst.SoundEmitter:PlaySound("dontstarve/common/ice_box_LP", "idlesound")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("icebox")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true


    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(2)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:ListenForEvent("onbuilt", onbuilt)
    MakeSnowCovered(inst)

    AddHauntableDropItemOrWork(inst)

    return inst
end

return Prefab("icebox", fn, assets, prefabs),
    MakePlacer("icebox_placer", "icebox", "ice_box", "closed")
