local assets =
{
    Asset("ANIM", "anim/mastupgrade_lamp.zip"),
}

local yotd_assets =
{
    Asset("ANIM", "anim/yotd_mastupgrade_lamp.zip"),
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

local function OnEntityReplicated(inst)
    local parent = inst.entity:GetParent()

    if parent ~= nil and parent:HasTag("mast") then
        if parent.highlightchildren ~= nil then
            table.insert(parent.highlightchildren, inst)
        else
            parent.highlightchildren = { inst }
        end
    end
end

local function CLIENT_OnRemoveEntity(inst)
    local parent = inst.entity:GetParent()

    if parent ~= nil and parent.highlightchildren ~= nil then
        table.removearrayvalue(parent.highlightchildren, inst)
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

    inst.scrapbook_anim = "full"
    inst.scrapbook_specialinfo = "MASTUPGRADELAMP"

    inst:AddTag("NOCLICK")
    inst:AddTag("DECOR")

    inst.scrapbook_inspectonseen = true

    inst.OnRemoveEntity = CLIENT_OnRemoveEntity

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = OnEntityReplicated
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

    inst.scrapbook_animoffsety = 65

    inst:AddComponent("tradable")

    inst:AddComponent("inspectable")

    local inventoryitem = inst:AddComponent("inventoryitem")
    inventoryitem:SetSinks(false)

    local upgrader = inst:AddComponent("upgrader")
    upgrader.upgradetype = UPGRADETYPES.MAST
    upgrader.upgradevalue = 1

    MakeHauntableLaunchAndSmash(inst)

    return inst
end

local function yotd_fn()
    local inst = fn()

    inst.AnimState:SetBuild("yotd_mastupgrade_lamp")

    return inst
end

local function yotd_itemfn()
    local inst = itemfn()

    inst.AnimState:SetBuild("yotd_mastupgrade_lamp")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.upgrade_override = "mastupgrade_lamp_yotd"

    return inst
end

return Prefab("mastupgrade_lamp_item", itemfn, assets, prefabs),
    Prefab("mastupgrade_lamp", fn, assets),

    Prefab("mastupgrade_lamp_item_yotd", yotd_itemfn, yotd_assets, prefabs),
    Prefab("mastupgrade_lamp_yotd", yotd_fn, yotd_assets, prefabs)