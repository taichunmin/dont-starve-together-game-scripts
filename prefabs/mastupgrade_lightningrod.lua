require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/mastupgrade_lightningrod.zip"),
}

local prefabs =
{
    "mastupgrade_lightningrod_top",
    "mastupgrade_lightningrod_fx",
    "collapse_small",
}

local CHARGED_LIGHT_OVERRIDE = 0.75

local function ondeconstructstructure(inst, caster)
    local recipe = AllRecipes[inst.prefab]

    for i, v in ipairs(recipe.ingredients) do
        for n = 1, v.amount do
            inst._mast.components.lootdropper:SpawnLootPrefab(v.type)
        end
    end
end

local function mast_burnt(inst)
    if inst._mast ~= nil and inst._mast:IsValid() then
        inst.components.lootdropper:DropLoot(inst._mast:GetPosition())
        SpawnPrefab("collapse_small").Transform:SetPosition(inst._mast.Transform:GetWorldPosition())
    end
end

local function dozap(inst)
    if inst.zaptask ~= nil then
        inst.zaptask:Cancel()
    end

    inst.SoundEmitter:PlaySound("dontstarve/common/lightningrod")
    SpawnPrefab("mastupgrade_lightningrod_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())

    inst.zaptask = inst:DoTaskInTime(math.random(10, 40), dozap)
end

local ondaycomplete

local function discharge(inst)
    if inst.charged then
        inst:StopWatchingWorldState("cycles", ondaycomplete)

        inst.AnimState:ClearBloomEffectHandle()
        inst.AnimState:SetLightOverride(0)
        if inst._top ~= nil then
            inst._top.AnimState:ClearBloomEffectHandle()
            inst._top.AnimState:SetLightOverride(0)
        end

        inst.charged = false
        inst.chargeleft = nil
        inst.Light:Enable(false)
        if inst.zaptask ~= nil then
            inst.zaptask:Cancel()
            inst.zaptask = nil
        end
    end
end

local function ondaycomplete(inst)
    dozap(inst)
    if inst.chargeleft > 1 then
        inst.chargeleft = inst.chargeleft - 1
    else
        discharge(inst)
    end
end

local function setcharged(inst, charges)
    if not inst.charged then
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst.AnimState:SetLightOverride(CHARGED_LIGHT_OVERRIDE)
        if inst._top ~= nil then
            inst._top.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
            inst._top.AnimState:SetLightOverride(CHARGED_LIGHT_OVERRIDE)
        end

        inst.Light:Enable(true)
        inst:WatchWorldState("cycles", ondaycomplete)
        inst.charged = true
    end
    inst.chargeleft = math.max(inst.chargeleft or 0, charges)
    dozap(inst)
end

local function onlightning(inst)
    setcharged(inst, 3)
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place_base")
    inst.AnimState:PushAnimation("base")

    if inst._top ~= nil and inst._top:IsValid() then
        inst._top.AnimState:PlayAnimation("place_top")
        inst._top.AnimState:PushAnimation("top")
    end

    inst.SoundEmitter:PlaySound("dangerous_sea/common/mast_item/place_electric_rod")
end

local function onremove(inst)
    if inst._mast ~= nil and inst._mast:IsValid() then
        inst._mast._lightningrod = nil
    end

    if inst._top ~= nil and inst._top:IsValid() then
        inst._top:Remove()
    end
end

local function basefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Light:Enable(false)
    inst.Light:SetRadius(1.5)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.5)
    inst.Light:SetColour(235/255,121/255,12/255)

    inst:AddTag("lightningrod")
    inst:AddTag("DECOR")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("mastupgrade_lightningrod_item")
    inst.AnimState:SetBuild("mastupgrade_lightningrod")
    inst.AnimState:PlayAnimation("base")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst._setchargedfn = setcharged
    -- inst._top = nil
    -- inst._mast = nil

    inst:AddComponent("lootdropper")

    inst:ListenForEvent("mast_burnt", mast_burnt)

    inst:ListenForEvent("onbuilt", onbuilt)
    inst:ListenForEvent("lightningstrike", onlightning)
    inst:ListenForEvent("onremove", onremove)

    inst:ListenForEvent("ondeconstructstructure", ondeconstructstructure)

    -- inst.OnSave = OnSave
    -- inst.OnLoad = OnLoad

    return inst
end

local function topfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("NOCLICK")
    inst:AddTag("DECOR")

    inst.AnimState:SetBank("mastupgrade_lightningrod_item")
    inst.AnimState:SetBuild("mastupgrade_lightningrod")
    inst.AnimState:PlayAnimation("top")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function itemfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("mastupgrade_lightningrod_item")
    inst.AnimState:SetBuild("mastupgrade_lightningrod")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "med", nil, 0.68)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("tradable")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(false)

    inst:AddComponent("upgrader")
    inst.components.upgrader.upgradetype = UPGRADETYPES.MAST
    inst.components.upgrader.upgradevalue = 2

    MakeHauntableLaunchAndSmash(inst)

    return inst
end

return Prefab("mastupgrade_lightningrod_item", itemfn, assets, prefabs),
    Prefab("mastupgrade_lightningrod", basefn, assets, {"mastupgrade_lightningrod_top"}),
    Prefab("mastupgrade_lightningrod_top", topfn, assets)
