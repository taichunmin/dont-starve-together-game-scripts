local assets =
{
    Asset("ANIM", "anim/minifan.zip"),
    Asset("ANIM", "anim/swap_minifan.zip"),
    Asset("SOUND", "sound/common.fsb"),
}

local prefabs =
{
    "fan_wheel",
}

local function onremove(inst)
    if inst._wheel ~= nil then
        inst._wheel:Remove()
        inst._wheel = nil
    end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_minifan", "swap_minifan")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    if inst._wheel ~= nil then
        inst._wheel:Remove()
    end
    inst._wheel = SpawnPrefab("fan_wheel")
    inst._wheel.entity:SetParent(owner.entity)
    inst._wheel:ListenForEvent("onremove", onremove, inst)

    if inst._owner ~= nil then
        inst:RemoveEventCallback("locomote", inst._onlocomote, inst._owner)
    end
    inst._owner = owner
    inst:ListenForEvent("locomote", inst._onlocomote, owner)
end

local function onunequip(inst, owner)
    if inst._wheel ~= nil then
        inst._wheel:StartUnequipping(inst)
        inst._wheel = nil
    end

    if inst._owner ~= nil then
        inst:RemoveEventCallback("locomote", inst._onlocomote, inst._owner)
        inst._owner = nil
    end

    if inst.components.fueled ~= nil then
        inst.components.fueled:StopConsuming()
    end

    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function onequiptomodel(inst, owner, from_ground)
    if inst.components.fueled ~= nil then
        inst.components.fueled:StopConsuming()
    end
end

local function ondepleted(inst)
    if inst.components.inventoryitem ~= nil and inst.components.inventoryitem:IsHeld() then
        inst.components.inventoryitem.owner:PushEvent("itemranout", {
            prefab = inst.prefab,
            equipslot = inst.components.equippable.equipslot,
            announce = "ANNOUNCE_FAN_OUT",
        })
    end

    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("minifan")
    inst.AnimState:SetBuild("minifan")
    inst.AnimState:PlayAnimation("idle")

    --HASHEATER (from heater component) added to pristine state for optimization
    inst:AddTag("HASHEATER")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    MakeInventoryFloatable(inst, "med", 0.05, 0.75)

    inst.scrapbook_subcat = "tool"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.MINIFAN_DAMAGE)

    -----------------------------------

    inst:AddComponent("inventoryitem")

    -----------------------------------

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel)

    -----------------------------------

    inst:AddComponent("heater")
    inst.components.heater:SetThermics(false, true)
    inst.components.heater.equippedheat = TUNING.MINIFAN_COOLER

    -----------------------------------

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)
    inst.components.insulator:SetSummer()

    -----------------------------------

    inst:AddComponent("inspectable")

    -----------------------------------

    inst:AddComponent("fueled")
    inst.components.fueled:InitializeFuelLevel(TUNING.MINIFAN_FUEL)
    inst.components.fueled:SetDepletedFn(ondepleted)
    inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FULL_FUELED_CONSUMPTION)

    MakeHauntableLaunch(inst)

    inst._onlocomote = function(owner)
        if owner.components.locomotor.wantstomoveforward then
            if not inst.components.fueled.consuming then
                inst.components.fueled:StartConsuming()
                inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)
                inst.components.heater:SetThermics(false, true)
                inst._wheel:SetSpinning(true)
            end
        elseif inst.components.fueled.consuming then
            inst.components.fueled:StopConsuming()
            inst.components.insulator:SetInsulation(0)
            inst.components.heater:SetThermics(false, false)
            inst._wheel:SetSpinning(false)
        end
    end

    return inst
end

return Prefab("minifan", fn, assets, prefabs)
