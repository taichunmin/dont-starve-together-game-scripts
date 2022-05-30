local assets =
{
    Asset("ANIM", "anim/mastupgrade_lamp.zip"),
}

local prefabs =
{
	"collapse_small",
}

local LAMP_LIGHT_OVERRIDE =1

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
        SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    end
end

local function mast_lamp_off(inst)
    inst.AnimState:SetLightOverride(0)
    inst.AnimState:PlayAnimation("off")
    inst.SoundEmitter:KillSound("lamp")
end

local function mast_lamp_on(inst)
    inst.AnimState:SetLightOverride(LAMP_LIGHT_OVERRIDE)
    inst.AnimState:PlayAnimation("full", true)
    inst.SoundEmitter:PlaySound("dangerous_sea/common/mast_item/lamp_LP","lamp")
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("full", true)
    inst.SoundEmitter:PlaySound("dangerous_sea/common/mast_item/place_lamp")
end

local function onremove(inst)-----------------------------------------------------------------------------
    if inst._mast ~= nil and inst._mast:IsValid() then
        inst._mast._lamp = nil
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("mastupgrade_lamp_item")
    inst.AnimState:SetBuild("mastupgrade_lamp")
    inst.AnimState:PlayAnimation("full")

    inst:AddTag("NOCLICK")
    inst:AddTag("DECOR")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    -- inst._mast = nil

    inst:AddComponent("lootdropper")

    inst:ListenForEvent("onbuilt", onbuilt)
    inst:ListenForEvent("onremove", onremove)

    inst:ListenForEvent("mast_burnt", mast_burnt)

    inst:ListenForEvent("mast_lamp_on", mast_lamp_on)
    inst:ListenForEvent("mast_lamp_off", mast_lamp_off)

    inst:ListenForEvent("ondeconstructstructure", ondeconstructstructure)

    return inst
end

local function itemfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("mastupgrade_lamp_item")
    inst.AnimState:SetBuild("mastupgrade_lamp")
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
    inst.components.upgrader.upgradevalue = 1

    MakeHauntableLaunchAndSmash(inst)

    return inst
end

return Prefab("mastupgrade_lamp_item", itemfn, assets, prefabs),
    Prefab("mastupgrade_lamp", fn, assets)