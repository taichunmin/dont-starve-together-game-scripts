require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/cartography_desk.zip"),
}

local prefabs =
{
    "collapse_small",
}

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

local function onhit(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        if inst.components.prototyper.on then
            inst.AnimState:PushAnimation("proximity_loop", true)
        else
            inst.AnimState:PushAnimation("idle", false)
        end
    end
end

local function onturnoff(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PushAnimation("idle", false)
    end
end

local function onsave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function onturnon(inst)
    if not inst:HasTag("burnt") then
        if inst.AnimState:IsCurrentAnimation("proximity_loop") or
            inst.AnimState:IsCurrentAnimation("place") then
            --NOTE: push again even if already playing, in case an idle was also pushed
            inst.AnimState:PushAnimation("proximity_loop", true)
        else
            inst.AnimState:PlayAnimation("proximity_loop", true)
        end
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/winter_meter_craft")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(1) --recipe min_spacing/2
    MakeObstaclePhysics(inst, .4)

    inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon("cartographydesk.png")

    inst.AnimState:SetBank("cartography_desk")
    inst.AnimState:SetBuild("cartography_desk")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("structure")

    -- added to pristine state for optimization
    inst:AddTag("prototyper")
	inst:AddTag("papereraser")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")
	inst:AddComponent("papereraser")

    inst:AddComponent("prototyper")
    inst.components.prototyper.onturnon = onturnon
    inst.components.prototyper.onturnoff = onturnoff
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.CARTOGRAPHYDESK

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    MakeSnowCovered(inst)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:ListenForEvent("onbuilt", onbuilt)

    MakeLargeBurnable(inst, nil, nil, true)
    MakeLargePropagator(inst)

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("cartographydesk", fn, assets, prefabs),
    MakePlacer("cartographydesk_placer", "cartography_desk", "cartography_desk", "idle")
