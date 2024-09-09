require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/pigshrine.zip"),
}

local prefabs =
{
    "collapse_small",
    "mudpuddle_splash",
    "ash",
    "meat",
    "cookedmeat",
    "meat_dried",
    "spoiled_food",
    "charcoal",
}

local function OnBurnt(inst)
    DefaultBurntStructureFn(inst)
    if inst.offering ~= nil then
        inst:RemoveEventCallback("onremove", inst._onofferingremoved, inst.offering)
        inst:RemoveEventCallback("perished", inst._onofferingperished, inst.offering)
        inst.offering:Remove()
        inst.offering = nil
        inst.components.lootdropper:SpawnLootPrefab("charcoal")
    end
    inst.AnimState:Hide("meat")
    if inst.components.trader ~= nil then
        inst:RemoveComponent("trader")
    end
end

local function MakePrototyper(inst)
    if inst.components.trader ~= nil then
        inst:RemoveComponent("trader")
    end

    if inst.components.prototyper == nil then
        inst:AddComponent("prototyper")
        inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.PIGSHRINE
    end
end

local function DropOffering(inst, worker)
    if inst.offering ~= nil then
        inst:RemoveEventCallback("onremove", inst._onofferingremoved, inst.offering)
        inst:RemoveEventCallback("perished", inst._onofferingperished, inst.offering)
        inst:RemoveChild(inst.offering)
        inst.offering:ReturnToScene()
        if worker ~= nil then
            LaunchAt(inst.offering, inst, worker, 1, 0.6, .6)
        else
            inst.components.lootdropper:FlingItem(inst.offering, inst:GetPosition())
        end
        inst.offering = nil
    end
end

local function SetOffering(inst, offering, loading)
    if offering == inst.offering then
        return
    end

    DropOffering(inst) --Shouldn't happen, but w/e (just in case!?)

    inst.offering = offering
    inst:ListenForEvent("onremove", inst._onofferingremoved, offering)
    inst:ListenForEvent("perished", inst._onofferingperished, offering)
    inst:AddChild(offering)
    offering:RemoveFromScene()
    offering.Transform:SetPosition(0, 0, 0)

    if offering.prefab == "meat" then
        inst.AnimState:ClearOverrideSymbol("meat")
    elseif offering.prefab == "meat_dried" then
        inst.AnimState:OverrideSymbol("meat", "pigshrine", "meat_jerky")
    elseif offering.prefab == "cookedmeat" then
        inst.AnimState:OverrideSymbol("meat", "pigshrine", "meat_cooked")
    end
    inst.AnimState:Show("meat")

    if not loading then
        inst.SoundEmitter:PlaySound("dontstarve/common/plant")
        inst.AnimState:PlayAnimation("use")
        inst.AnimState:PushAnimation("idle", false)
    end

    MakePrototyper(inst)
end

local function ongivenitem(inst, giver, item)
    SetOffering(inst, item, false)
end

local function abletoaccepttest(inst, item)
    return item.prefab == "meat"
        or item.prefab == "meat_dried"
        or item.prefab == "cookedmeat"
end

local function MakeEmpty(inst)
    if inst.offering ~= nil then
        inst:RemoveEventCallback("onremove", inst._onofferingremoved, inst.offering)
        inst:RemoveEventCallback("perished", inst._onofferingperished, inst.offering)
        inst.offering:Remove()
        inst.offering = nil
    end

    inst.AnimState:Hide("meat")

    if inst.components.prototyper ~= nil then
        inst:RemoveComponent("prototyper")
    end

    if inst.components.trader == nil then
        inst:AddComponent("trader")
        inst.components.trader:SetAbleToAcceptTest(abletoaccepttest)
        inst.components.trader.acceptnontradable = true
        inst.components.trader.deleteitemonaccept = false
        inst.components.trader.onaccept = ongivenitem
    end
end

local function OnIgnite(inst)
    if inst.offering ~= nil then
        inst.components.lootdropper:SpawnLootPrefab("charcoal")
    end
    MakeEmpty(inst)
    inst.components.trader:Disable()
    DefaultBurnFn(inst)
end

local function OnExtinguish(inst)
    if inst.components.trader ~= nil then
        inst.components.trader:Enable()
    end
    DefaultExtinguishFn(inst)
end

local function onbuilt(inst)
    --Make empty when first built.
    --Pristine state is not empty.
    MakeEmpty(inst)

    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/pig_shrine/place")

    SpawnPrefab("mudpuddle_splash").Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    DropOffering(inst, worker)
    local x, y, z = inst.Transform:GetWorldPosition()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(x, y, z)
    fx:SetMaterial("wood")
    SpawnPrefab("mudpuddle_splash").Transform:SetPosition(x, y, z)

    inst:Remove()
end

local function onhit(inst, worker, workleft)
    DropOffering(inst, worker)
    MakeEmpty(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle", false)

        if workleft > 0 then
            SpawnPrefab("mudpuddle_splash").Transform:SetPosition(inst.Transform:GetWorldPosition())
        end
    end
end

local function OnOfferingPerished(inst)
    if inst.offering ~= nil then
        MakeEmpty(inst)
        local rot = SpawnPrefab("spoiled_food")
        rot.Transform:SetPosition(inst.Transform:GetWorldPosition())
        LaunchAt(rot, inst, nil, .5, 0.6, .6)
    end
end

local function onsave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    elseif inst.offering ~= nil then
        data.offering = inst.offering:GetSaveRecord()
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    elseif data ~= nil and data.offering ~= nil then
        SetOffering(inst, SpawnSaveRecord(data.offering), true)
    else
        MakeEmpty(inst)
    end
end

local function GetStatus(inst)
    --return BURNT here otherwise EMPTY will always have priority over BURNT
    return (inst:HasTag("burnt") and "BURNT")
        or (inst.components.trader ~= nil and "EMPTY")
        or nil
end

local function CreateMud()
    local inst = CreateEntity()

    inst:AddTag("DECOR") --"FX" will catch mouseover
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("pigshrine")
    inst.AnimState:SetBuild("pigshrine")
    inst.AnimState:PlayAnimation("ripple_fx", true)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(2)

    return inst
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(1.6) --recipe min_spacing/2
    MakeObstaclePhysics(inst, .6)

    inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon("pigshrine.png")

    inst.AnimState:SetBank("pigshrine")
    inst.AnimState:SetBuild("pigshrine")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("structure")
    inst:AddTag("pigshrine")

    --prototyper (from prototyper component) added to pristine state for optimization
    inst:AddTag("prototyper")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheNet:IsDedicated() then
        CreateMud().entity:SetParent(inst.entity)

        if not TheWorld.ismastersim then
            return inst
        end
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    MakePrototyper(inst)
    inst:ListenForEvent("onbuilt", onbuilt)

    inst:AddComponent("lootdropper")
    inst.offering = nil

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    MakeSnowCovered(inst)

    MakeMediumBurnable(inst, nil, nil, true)
    MakeMediumPropagator(inst)
    inst.components.burnable:SetOnBurntFn(OnBurnt)
    inst.components.burnable:SetOnIgniteFn(OnIgnite)
    inst.components.burnable:SetOnExtinguishFn(OnExtinguish)

    inst._onofferingremoved = function() MakeEmpty(inst) end
    inst._onofferingperished = function() OnOfferingPerished(inst) end

    inst.OnSave = onsave
    inst.OnLoad = onload

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:ListenForEvent("ondeconstructstructure", DropOffering)

    return inst
end

return Prefab("pigshrine", fn, assets, prefabs),
    MakePlacer("pigshrine_placer", "pigshrine", "pigshrine", "idle",
        nil, nil, nil, nil, nil, nil,
        function(inst)
            inst.AnimState:Hide("meat")
        end)
