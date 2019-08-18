local assets =
{
    Asset("ANIM", "anim/oar.zip"),
    Asset("ANIM", "anim/oar_driftwood.zip"),
    Asset("ANIM", "anim/swap_oar.zip"),
    Asset("ANIM", "anim/swap_oar_driftwood.zip"),
}

local prefabs =
{
    
}

local function onequip(inst, owner, swap_build)
    owner.AnimState:OverrideSymbol("swap_object", swap_build, swap_build)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function onfiniteusesfinished(inst)
    if inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner ~= nil then
        inst.components.inventoryitem.owner:PushEvent("toolbroke", { tool = inst })
    end

    inst:Remove()
end

local function fn(data, build, swap_build)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst:AddTag("allow_action_on_impassable")

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(build)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "small", nil, 0.68)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst:AddComponent("oar")
    inst.components.oar.force = data.FORCE
    inst:AddComponent("inspectable")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(data.DAMAGE)
    inst.components.weapon.attackwear = data.ATTACKWEAR


    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(function(inst, owner) onequip(inst, owner, swap_build) end)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)

    -- NOTE: if driftwood changes fuel tuning, the driftwood oar should as well!
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(data.USES)
    inst.components.finiteuses:SetUses(data.USES)
    inst.components.finiteuses:SetOnFinished(onfiniteusesfinished)
    inst.components.finiteuses:SetConsumption(ACTIONS.ROW, 1)
    inst.components.finiteuses:SetConsumption(ACTIONS.ROW_FAIL, 25)

    MakeHauntableLaunch(inst)

    return inst
end

local function oar()
    return fn(TUNING.BOAT.OARS.BASIC, "oar", "swap_oar")
end

local function driftwood_oar()
    return fn(TUNING.BOAT.OARS.DRIFTWOOD, "oar_driftwood", "swap_oar_driftwood")
end

return  Prefab("oar", oar, assets, prefabs),
        Prefab("oar_driftwood", driftwood_oar, assets, prefabs)
