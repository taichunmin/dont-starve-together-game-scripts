local assets =
{
    Asset("ANIM", "anim/marsh_bush.zip"),
    --Asset("MINIMAP_IMAGE", "thorns_marsh"),
}

local erode_assets =
{
    Asset("ANIM", "anim/ash.zip"),
}

local prefabs =
{
    "twigs",
    "dug_marsh_bush",
}

local burnt_prefabs =
{
    "ash",
    "burnt_marsh_bush_erode",
}

local function ontransplantfn(inst)
    inst.components.pickable:MakeEmpty()
end

local function dig_up(inst, chopper)
    if inst.components.pickable ~= nil and inst.components.pickable:CanBePicked() then
        inst.components.lootdropper:SpawnLootPrefab("twigs")
    end
    inst.components.lootdropper:SpawnLootPrefab("dug_marsh_bush")
    inst:Remove()
end

local function onpickedfn(inst, picker)
    inst.AnimState:PlayAnimation("picking")
    inst.AnimState:PushAnimation("picked", false)
    if picker ~= nil and picker.components.combat ~= nil and not (picker.components.inventory ~= nil and picker.components.inventory:EquipHasTag("bramble_resistant")) then
        picker.components.combat:GetAttacked(inst, TUNING.MARSHBUSH_DAMAGE)
        picker:PushEvent("thorns")
    end
end

local function onregenfn(inst)
    inst.AnimState:PlayAnimation("grow")
    inst.AnimState:PushAnimation("idle", true)
end

local function makeemptyfn(inst)
    inst.AnimState:PlayAnimation("idle_dead")
end

local function DropAsh(inst, pos)
    if inst.components.lootdropper == nil then
        inst:AddComponent("lootdropper")
    end
    inst.components.lootdropper:SpawnLootPrefab("ash", pos)
end

local function OnActivateBurnt(inst)
    local pos = inst:GetPosition()
    inst:DoTaskInTime(.25 + math.random() * .05, DropAsh, pos)
    inst:AddTag("NOCLICK")
    inst.persists = false
    ErodeAway(inst)
    SpawnPrefab("burnt_marsh_bush_erode").Transform:SetPosition(pos:Get())
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("marsh_bush")
    inst.AnimState:SetBank("marsh_bush")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("plant")
    inst:AddTag("thorny")
	inst:AddTag("silviculture") -- for silviculture book

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:SetTime(math.random()*2)

    local color = 0.5 + math.random() * 0.5
    inst.AnimState:SetMultColour(color, color, color, 1)

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/harvest_sticks"

    inst.components.pickable:SetUp("twigs", TUNING.MARSHBUSH_REGROW_TIME)
    inst.components.pickable.onregenfn = onregenfn
    inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.makeemptyfn = makeemptyfn
    inst.components.pickable.ontransplantfn = ontransplantfn

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(dig_up)
    inst.components.workable:SetWorkLeft(1)

    inst:AddComponent("inspectable")

    MakeLargeBurnable(inst)
    MakeMediumPropagator(inst)
    MakeHauntableIgnite(inst)

    return inst
end

local function GetVerb()
    return "TOUCH"
end

local function burnt_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("marsh_bush")
    inst.AnimState:SetBank("marsh_bush")
    inst.AnimState:PlayAnimation("burnt")

    inst:AddTag("plant")
    inst:AddTag("thorny")
    inst:AddTag("burnt")

    inst.GetActivateVerb = GetVerb

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    local color = 0.5 + math.random() * 0.5
    inst.AnimState:SetMultColour(color, color, color, 1)

    inst:AddComponent("inspectable")
    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:AddComponent("activatable")
    inst.components.activatable.quickaction = true
    inst.components.activatable.OnActivate = OnActivateBurnt

    return inst
end

local function PlayErodeAnim(proxy)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    inst.Transform:SetFromProxy(proxy.GUID)

    inst.AnimState:SetBank("ashes")
    inst.AnimState:SetBuild("ash")
    inst.AnimState:PlayAnimation("disappear")
    inst.AnimState:SetMultColour(.4, .4, .4, 1)
    inst.AnimState:SetTime(13 * FRAMES)

    inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble", nil, .2)

    inst:ListenForEvent("animover", inst.Remove)
end

local function burnt_erode_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst.Transform:SetTwoFaced()

    inst:AddTag("FX")

    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
        --Delay one frame so that we are positioned properly before starting the effect
        --or in case we are about to be removed
        inst:DoTaskInTime(0, PlayErodeAnim)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.Transform:SetRotation(math.random(360))

    inst.persists = false
    inst:DoTaskInTime(.5, inst.Remove)

    return inst
end

return Prefab("marsh_bush", fn, assets, prefabs),
    Prefab("burnt_marsh_bush", burnt_fn, assets, burnt_prefabs),
    Prefab("burnt_marsh_bush_erode", burnt_erode_fn, erode_assets)
