local assets =
{
    Asset("ANIM", "anim/boat_mast2_wip.zip"),
    Asset("MINIMAP_IMAGE", "mast"),
}

local prefabs =
{
    "boat_mast_sink_fx",
    "collapse_small",
}

----------------------------------------------------------------------------------------------------------------

local function OnHammered(inst, worker)
    inst.components.lootdropper:DropLoot()

    local sinking = worker ~= nil and worker:HasTag("boat") and not inst:HasTag("burnt")

    local fx = SpawnPrefab(sinking and "boat_mast_sink_fx" or "collapse_small")

    if fx ~= nil then
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())

        if not sinking then
            fx:SetMaterial("wood")
        end
    end

    inst:Remove()
end

local function OnHit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("broken_hit")
        inst.AnimState:PushAnimation("broken", false)
    end
end

----------------------------------------------------------------------------------------------------------------

local function OnBurnt(inst)
    DefaultBurntStructureFn(inst)

    if inst._rudder ~= nil then
        inst._rudder:Remove()
        inst._rudder = nil
    end
end

----------------------------------------------------------------------------------------------------------------

local function OnSave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    end
end

local function OnLoad(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

----------------------------------------------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .2)

    inst:AddTag("NOBLOCK")
    inst:AddTag("structure")
    inst:AddTag("mast")
    inst:AddTag("broken")

    inst.AnimState:SetBank("mast_01")
    inst.AnimState:SetBuild("boat_mast2_wip")
    inst.AnimState:PlayAnimation("broken")

    inst.MiniMapEntity:SetIcon("mast.png")

    inst:SetPrefabNameOverride("mast")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_facing  = FACING_DOWN

    inst._rudder = SpawnPrefab("rudder")
    inst._rudder.entity:SetParent(inst.entity)

    if inst.highlightchildren ~= nil then
        table.insert(inst.highlightchildren, inst._rudder)
    else
        inst.highlightchildren = { inst._rudder }
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    inst.components.workable:SetOnWorkCallback(OnHit)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    MakeLargeBurnable(inst, nil, nil, true)
    MakeLargePropagator(inst)

    inst.components.burnable:SetOnBurntFn(OnBurnt)

    return inst
end

----------------------------------------------------------------------------------------------------------------

return Prefab("mast_broken", fn, assets, prefabs)