require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/wargshrine.zip"),
    Asset("ANIM", "anim/swap_torch.zip"),
    Asset("ANIM", "anim/ash.zip"),
}

local prefabs =
{
    "collapse_small",
}

local function ShowFlame(inst, torch)
    if inst.fires == nil then
        inst.fires = {}

        for i, fx_prefab in ipairs(torch:GetSkinName() == nil and { "torchfire" } or SKIN_FX_PREFAB[torch:GetSkinName()] or {}) do
            local fx = SpawnPrefab(fx_prefab)
            fx.entity:SetParent(inst.entity)
            fx.entity:AddFollower()
            fx.Follower:FollowSymbol(inst.GUID, "swap_torch", 0, fx.fx_offset, 0)
            fx:AttachLightTo(inst)

            table.insert(inst.fires, fx)
        end
    end
end

local function HideFlame(inst, dosound)
    if inst.fires ~= nil then
        for i, fx in ipairs(inst.fires) do
            fx:Remove()
        end
        inst.fires = nil
        if dosound then
            inst.SoundEmitter:PlaySound("dontstarve/common/fireOut")
        end
    end
end

local function OnErodeTorch(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local fx = CreateEntity()

    fx:AddTag("FX")
    --[[Non-networked entity]]
    fx.entity:SetCanSleep(false)
    fx.persists = false

    fx.entity:AddTransform()
    fx.entity:AddAnimState()

    fx.Transform:SetPosition(x, y + 1, z)
    fx.Transform:SetRotation(inst.Transform:GetRotation())

    fx.AnimState:SetBank("ashes")
    fx.AnimState:SetBuild("ash")
    fx.AnimState:PlayAnimation("disappear")
    fx.AnimState:SetMultColour(.4, .4, .4, 1)
	fx.AnimState:SetFrame(13)

    fx:ListenForEvent("animover", fx.Remove)
end

local function ErodeTorch(inst)
    inst._erodetorch:push()
    if not TheNet:IsDedicated() then
        OnErodeTorch(inst)
    end
end

local function OnBurnt(inst)
    DefaultBurntStructureFn(inst)
    if inst.torch ~= nil then
        inst:RemoveEventCallback("onremove", inst._ontorchremoved, inst.torch)
        inst.torch:Remove()
        inst.torch = nil
        ErodeTorch(inst)
        TheWorld:PushEvent("wargshrinedeactivated", inst)
    end
    HideFlame(inst, false)
    inst.AnimState:Hide("swap_torch")
    inst.AnimState:Hide("fx")
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
        inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.WARGSHRINE
    end
end

local function DropTorch(inst, worker)
    if inst.torch ~= nil then
        inst:RemoveEventCallback("onremove", inst._ontorchremoved, inst.torch)
        inst.torch.components.burnable:Extinguish()
        inst:RemoveChild(inst.torch)
        inst.torch:ReturnToScene()
        if worker ~= nil then
            LaunchAt(inst.torch, inst, worker, 1, 1.2, .4)
        else
            inst.components.lootdropper:FlingItem(inst.torch, inst:GetPosition())
        end
        if inst.torch.SetFuelRateMult ~= nil then
            inst.torch:SetFuelRateMult(1)
        end
        inst.torch = nil
        TheWorld:PushEvent("wargshrinedeactivated", inst)
    end
end

local function SetTorch(inst, torch, loading)
    if torch == inst.torch then
        return
    end

    DropTorch(inst) --Shouldn't happen, but w/e (just in case!?)

    inst.torch = torch
    inst:ListenForEvent("onremove", inst._ontorchremoved, torch)
    inst:AddChild(torch)
    torch:RemoveFromScene()
    torch.Transform:SetPosition(0, 0, 0)
    TheWorld:PushEvent("wargshrineactivated", inst)

    local skin_build = torch:GetSkinBuild()
    if skin_build ~= nil then
        inst.AnimState:OverrideItemSkinSymbol("swap_torch", skin_build, "swap_torch", torch.GUID, "swap_torch")
    else
        inst.AnimState:OverrideSymbol("swap_torch", "swap_torch", "swap_torch")
    end
    inst.AnimState:Show("swap_torch")
    inst.AnimState:Show("fx")
    ShowFlame(inst, torch)

    if not loading then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/torch_swing")
    end

    if inst.components.burnable ~= nil then
        inst.components.burnable.canlight = false
    end
    MakePrototyper(inst)

    if torch.SetFuelRateMult ~= nil then
        torch:SetFuelRateMult(TUNING.TORCH_SHRINE_FUEL_RATE_MULT)
    end
    torch.components.burnable:Ignite()
end

local function ongivenitem(inst, giver, item)
    SetTorch(inst, item, false)
end

local function abletoaccepttest(inst, item)
    return item.prefab == "torch"
end

local function MakeEmpty(inst)
    if inst.torch ~= nil then
        inst:RemoveEventCallback("onremove", inst._ontorchremoved, inst.torch)
        inst.torch:Remove()
        inst.torch = nil
        ErodeTorch(inst)
        TheWorld:PushEvent("wargshrinedeactivated", inst)
    end

    HideFlame(inst, inst.components.burnable == nil or not inst.components.burnable:IsBurning())
    inst.AnimState:Hide("swap_torch")
    inst.AnimState:Hide("fx")

    if inst.components.burnable ~= nil then
        inst.components.burnable.canlight = true
    end

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
    inst.AnimState:PushAnimation("idle")
    inst.SoundEmitter:PlaySound("dontstarve/common/together/perd_shrine_place")
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    HideFlame(inst, true)
    inst.components.lootdropper:DropLoot()
    DropTorch(inst, worker)
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    DropTorch(inst, worker)
    MakeEmpty(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle")
    end
end

local function onsave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    elseif inst.torch ~= nil then
        data.torch = inst.torch:GetSaveRecord()
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    elseif data ~= nil and data.torch ~= nil then
        SetTorch(inst, SpawnSaveRecord(data.torch), true)
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

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(0.9) --recipe min_spacing/2
    MakeObstaclePhysics(inst, .4)

    inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon("wargshrine.png")

    inst.AnimState:SetBank("wargshrine")
    inst.AnimState:SetBuild("wargshrine")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("structure")
    inst:AddTag("wargshrine")

    --prototyper (from prototyper component) added to pristine state for optimization
    inst:AddTag("prototyper")

    MakeSnowCoveredPristine(inst)

    inst._erodetorch = net_event(inst.GUID, "wargshrine._erodetorch")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("wargshrine._erodetorch", OnErodeTorch)

        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    MakePrototyper(inst)
    inst:ListenForEvent("onbuilt", onbuilt)

    inst:AddComponent("lootdropper")
    inst.torch = nil

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

    inst._ontorchremoved = function() MakeEmpty(inst) end

    inst.OnSave = onsave
    inst.OnLoad = onload

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:ListenForEvent("ondeconstructstructure", DropTorch)

    return inst
end

return Prefab("wargshrine", fn, assets, prefabs),
    MakePlacer("wargshrine_placer", "wargshrine", "wargshrine", "idle",
        nil, nil, nil, nil, nil, nil,
        function(inst)
            inst.AnimState:Hide("swap_torch")
            inst.AnimState:Hide("fx")
        end)
