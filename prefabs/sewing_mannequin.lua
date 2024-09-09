require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/sewing_mannequin.zip"),

    Asset("MINIMAP_IMAGE", "sewing_mannequin"),
}

local prefabs =
{
    "collapse_big",
}

--------------------------------------------------------------------------------
local function should_accept_item(inst, item, doer)
    return item.components.equippable ~= nil
        and (item.components.equippable.equipslot == EQUIPSLOTS.HANDS
            or item.components.equippable.equipslot == EQUIPSLOTS.HEAD
            or item.components.equippable.equipslot == EQUIPSLOTS.BODY),
        "GENERIC"
end

local function on_get_item(inst, giver, item)
    local equipslot = item.components.equippable.equipslot

    local current = inst.components.inventory:GetEquippedItem(equipslot)
    if current ~= nil then
        inst.components.inventory:DropItem(current, true, true)
    end

    inst.components.inventory:Equip(item)
end

--------------------------------------------------------------------------------
local function onhammered(inst)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.SoundEmitter:PlaySound("stageplay_set/mannequin/hit")
        inst.AnimState:PushAnimation("idle", false)

        inst.components.inventory:DropEverything(true)
    end
end

--------------------------------------------------------------------------------
local function has_any_equipment(inst)
    return inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil
        or inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) ~= nil
        or inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY) ~= nil
end

local function CanSwap(inst, doer)
    -- We can perform a swap if either of our head/body slots are filled,
    -- or either of the doer's are filled.
    return has_any_equipment(inst)
        or (doer.components.inventory ~= nil and has_any_equipment(doer))
end

local function become_inactive(inst)
    inst.components.activatable.inactive = true
end

local function OnActivate(inst, doer)
    inst:DoTaskInTime(5*FRAMES, become_inactive)

    if CanSwap(inst, doer) then
        local handswap_success = inst.components.inventory:SwapEquipment(doer, EQUIPSLOTS.HANDS)
        local headswap_success = inst.components.inventory:SwapEquipment(doer, EQUIPSLOTS.HEAD)
        local bodyswap_success = inst.components.inventory:SwapEquipment(doer, EQUIPSLOTS.BODY)

        if (handswap_success or headswap_success or bodyswap_success) then
            inst.AnimState:PlayAnimation("swap")
            inst.SoundEmitter:PlaySound("stageplay_set/mannequin/swap")
            inst.AnimState:PushAnimation("idle", false)

            return true
        else
            return false, "MANNEQUIN_EQUIPSWAPFAILED"
        end
    else
        -- This should be exceedingly rare because we shouldn't have been activatable
        -- if we didn't have anything to swap.
        return false
    end
end

--------------------------------------------------------------------------------
local function mannequin_onburnt(inst)
    if inst.components.trader ~= nil then
        inst:RemoveComponent("trader")
    end
    if inst.components.activatable ~= nil then
        inst:RemoveComponent("activatable")
    end
    if inst.components.inventory ~= nil then
        inst.components.inventory:DropEverything()
    end
    DefaultBurntStructureFn(inst)
end

--------------------------------------------------------------------------------
local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.SoundEmitter:PlaySound("stageplay_set/mannequin/place")
    inst.AnimState:PushAnimation("idle", false)
end

--------------------------------------------------------------------------------
local function onequipped(inst, data)
    inst.SoundEmitter:PlaySound("stageplay_set/mannequin/swap")
end

--------------------------------------------------------------------------------
local function onacting(inst, data)
    inst.AnimState:PlayAnimation("swap")
    inst.AnimState:PushAnimation("idle", false)
end

--------------------------------------------------------------------------------
local function ontalk(inst, data)
    inst.SoundEmitter:PlaySound("stageplay_set/mannequin/speaking")
end

--------------------------------------------------------------------------------
local function onsave(inst, data)
    if (inst.components.burnable ~= nil and inst.components.burnable:IsBurning())
            or inst:HasTag("burnt") then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil then
        if data.burnt then
            inst.components.burnable.onburnt(inst)
        end
    end
end

--------------------------------------------------------------------------------
local function get_activate_verb()
    return "EQUIPMENTSWAP"
end

local TALKER_COLOUR = Vector3(122/255, 123/255, 123/255)
local TALKER_OFFSET = Vector3(0, -400, 0)
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst:AddTag("structure")
    inst:AddTag("equipmentmodel")
	inst:AddTag("rotatableobject")

    -- stageactor (from stageactor component) added to pristine state for optimization
    inst:AddTag("stageactor")

	inst:SetDeploySmartRadius(0.75) --recipe min_spacing/2

    inst.DynamicShadow:SetSize(1.3, 0.6)

    inst.MiniMapEntity:SetIcon("sewing_mannequin.png")

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("sewing_mannequin")
    inst.AnimState:SetBuild("sewing_mannequin")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:Hide("ARM_carry")
    inst.AnimState:Hide("LANTERN_OVERLAY")

    inst.GetActivateVerb = get_activate_verb

    -------------------------------------------------------
    inst:AddComponent("talker")
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.colour = TALKER_COLOUR
    inst.components.talker.offset = TALKER_OFFSET

    inst.scrapbook_specialinfo = "SEWINGMANNEQUIN"

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_hide = { "ARM_carry", "LANTERN_OVERLAY" }
    inst.scrapbook_facing  = FACING_DOWN

    -------------------------------------------------------
    inst:AddComponent("inspectable")

    -------------------------------------------------------
    inst:AddComponent("lootdropper")

    -------------------------------------------------------
    inst:AddComponent("stageactor")

    -------------------------------------------------------
    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = 0

    -------------------------------------------------------
    local trader = inst:AddComponent("trader")
    trader:SetAbleToAcceptTest(should_accept_item)
    trader.onaccept = on_get_item
    trader.deleteitemonaccept = false
    trader.acceptnontradable = true

    -------------------------------------------------------
    local workable = inst:AddComponent("workable")
    workable:SetWorkAction(ACTIONS.HAMMER)
    workable:SetWorkLeft(6)
    workable:SetOnFinishCallback(onhammered)
    workable:SetOnWorkCallback(onhit)

    -------------------------------------------------------
    local activatable = inst:AddComponent("activatable")
    activatable.OnActivate = OnActivate
    activatable.quickaction = true

    -------------------------------------------------------
    inst:AddComponent("savedrotation")
    inst.components.savedrotation.dodelayedpostpassapply = true

    -------------------------------------------------------
	inst:AddComponent("colouradder")
	inst:AddComponent("bloomer")

    -------------------------------------------------------
    local burnable = MakeMediumBurnable(inst, nil, nil, true)
    burnable:SetOnBurntFn(mannequin_onburnt)
    MakeMediumPropagator(inst)

    -------------------------------------------------------
    MakeHauntable(inst)

    -------------------------------------------------------
    inst:ListenForEvent("onbuilt", onbuilt)
    inst:ListenForEvent("equip", onequipped)
    inst:ListenForEvent("acting", onacting)
    inst:ListenForEvent("ontalk", ontalk)

    -------------------------------------------------------
    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("sewing_mannequin", fn, assets, prefabs),
    MakePlacer("sewing_mannequin_placer", "sewing_mannequin", "sewing_mannequin", "placer", nil, nil, nil, nil, 12.5)
