require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/portable_blender.zip"),
}

local prefabs =
{
    "collapse_small",
    "ash",
    "portableblender_item",
}

local prefabs_item =
{
    "portableblender",
}

local function ChangeToItem(inst)
    local item = SpawnPrefab("portableblender_item")
    item.Transform:SetPosition(inst.Transform:GetWorldPosition())
    item.AnimState:PlayAnimation("collapse")
    item.SoundEmitter:PlaySound("dontstarve/common/together/portable/blender/collapse")
end

local function onhammered(inst)--, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end

    if inst:HasTag("burnt") then
        inst.components.lootdropper:SpawnLootPrefab("ash")
        local fx = SpawnPrefab("collapse_small")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx:SetMaterial("metal")
    else
        ChangeToItem(inst)
    end

    inst:Remove()
end

local function onhit(inst)--, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        if inst.components.prototyper.on then
            inst.AnimState:PushAnimation("proximity_loop", true)
        else
            inst.AnimState:PushAnimation("idle", false)
        end
        inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_close")
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

local function OnDismantle(inst)--, doer)
    ChangeToItem(inst)
    inst:Remove()
end

local function OnBurnt(inst)
    DefaultBurntStructureFn(inst)
    RemovePhysicsColliders(inst)
    SpawnPrefab("ash").Transform:SetPosition(inst.Transform:GetWorldPosition())
    if inst.components.workable ~= nil then
        inst:RemoveComponent("workable")
    end
    if inst.components.portablestructure ~= nil then
        inst:RemoveComponent("portablestructure")
    end
    inst.persists = false
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:ListenForEvent("animover", ErodeAway)
    inst.AnimState:PlayAnimation("burnt_collapse")
end

local function onturnon(inst)
    if not inst:HasTag("burnt") then
        if inst.AnimState:IsCurrentAnimation("idle") then
            inst.AnimState:PlayAnimation("proximity_loop", true)
        else
            inst.AnimState:PushAnimation("proximity_loop", true)
        end
        inst.SoundEmitter:PlaySound("dontstarve/common/together/portable/blender/proximity_LP", "loop")
    end
end

local function onturnoff(inst)
    if not inst:HasTag("burnt") then
        inst.SoundEmitter:KillSound("loop")
        inst.AnimState:PushAnimation("idle", false)
    end
end

local function onactivate(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("use")
        if inst.components.prototyper.on then
            inst.AnimState:PushAnimation("proximity_loop", true)
        else
            inst.AnimState:PushAnimation("idle", false)
        end
        inst.SoundEmitter:PlaySound("dontstarve/common/together/portable/blender/use")
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT] / 2) --item deployspacing/2
    inst:SetPhysicsRadiusOverride(.5)
    MakeObstaclePhysics(inst, inst.physicsradiusoverride)

    inst.MiniMapEntity:SetIcon("portableblender.png")

    inst:AddTag("structure")
    inst:AddTag("mastercookware")

    inst.AnimState:SetBank("portable_blender")
    inst.AnimState:SetBuild("portable_blender")
    inst.AnimState:PlayAnimation("idle")

    inst:SetPrefabNameOverride("portableblender_item")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("portablestructure")
    inst.components.portablestructure:SetOnDismantleFn(OnDismantle)

    inst:AddComponent("prototyper")
    inst.components.prototyper.restrictedtag = "professionalchef"
    inst.components.prototyper.onturnon = onturnon
    inst.components.prototyper.onturnoff = onturnoff
    inst.components.prototyper.onactivate = onactivate
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.FOODPROCESSING

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(2)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    MakeMediumBurnable(inst, nil, nil, true)
    MakeSmallPropagator(inst)
    inst.components.burnable:SetFXLevel(2)
    inst.components.burnable:SetOnBurntFn(OnBurnt)

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

---------------------------------------------------------------
---------------- Inventory Portable Blender -------------------
---------------------------------------------------------------

local function ondeploy(inst, pt, deployer)
    local blender = SpawnPrefab("portableblender")
    if blender ~= nil then
        blender.Physics:SetCollides(false)
        blender.Physics:Teleport(pt.x, 0, pt.z)
        blender.Physics:SetCollides(true)
        blender.AnimState:PlayAnimation("place")
        blender.AnimState:PushAnimation("idle", false)
        blender.SoundEmitter:PlaySound("dontstarve/common/together/portable/blender/place")
        inst:Remove()
        PreventCharacterCollisionsWithPlacedObjects(blender)
    end
end

local function on_start_float(inst)
    inst.AnimState:HideSymbol("shadow_ground")
end

local function on_stop_float(inst)
    inst.AnimState:ShowSymbol("shadow_ground")
end

local function itemfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("portable_blender")
    inst.AnimState:SetBuild("portable_blender")
    inst.AnimState:PlayAnimation("idle_ground")

    inst:AddTag("portableitem")

    MakeInventoryFloatable(inst, nil, 0.05, 0.7)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_anim = "idle_ground"

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("deployable")
    inst.components.deployable.restrictedtag = "masterchef"
    inst.components.deployable.ondeploy = ondeploy
    --inst.components.deployable:SetDeployMode(DEPLOYMODE.ANYWHERE)
    --inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.NONE)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    MakeMediumBurnable(inst)
    MakeSmallPropagator(inst)

    inst:ListenForEvent("floater_startfloating", on_start_float)
    inst:ListenForEvent("floater_stopfloating", on_stop_float)

    return inst
end

return Prefab("portableblender", fn, assets, prefabs),
    MakePlacer("portableblender_item_placer", "portable_blender", "portable_blender", "idle"),
    Prefab("portableblender_item", itemfn, assets, prefabs_item)
