local wood_assets =
{
    Asset("ANIM", "anim/oar.zip"),
    Asset("ANIM", "anim/swap_oar.zip"),
}

local driftwood_assets =
{
    Asset("ANIM", "anim/oar_driftwood.zip"),
    Asset("ANIM", "anim/swap_oar_driftwood.zip"),
}

local beak_assets =
{
    Asset("ANIM", "anim/malbatross_beak.zip"),
    Asset("ANIM", "anim/swap_malbatross_beak.zip"),
}

local function onequip(inst, owner, swap_build)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, swap_build, inst.GUID, swap_build)
    else
        owner.AnimState:OverrideSymbol("swap_object", swap_build, swap_build)
    end

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

local function fn(data, build, swap_build, fuel_value, is_wooden, is_waterproof)
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

    if is_waterproof then
        inst:AddTag("waterproofer")
    end

    MakeInventoryFloatable(inst, "small", nil, 0.68)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	if is_wooden then
		inst:AddComponent("edible")
		inst.components.edible.foodtype = FOODTYPE.WOOD
		inst.components.edible.healthvalue = 0
		inst.components.edible.hungervalue = 0
	end

    inst:AddComponent("inventoryitem")
    inst:AddComponent("oar")
    inst.components.oar.force = data.FORCE
    inst.components.oar.max_velocity = data.MAX_VELOCITY
    inst:AddComponent("inspectable")

    if is_waterproof then
        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(0)
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(data.DAMAGE)
    inst.components.weapon.attackwear = data.ATTACKWEAR


    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(function(inst, owner) onequip(inst, owner, swap_build) end)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)

	if fuel_value ~= nil then
		inst:AddComponent("fuel")
		inst.components.fuel.fuelvalue = fuel_value
	end

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(data.USES)
    inst.components.finiteuses:SetUses(data.USES)
    inst.components.finiteuses:SetOnFinished(onfiniteusesfinished)
    inst.components.finiteuses:SetConsumption(ACTIONS.ROW, 1)
    inst.components.finiteuses:SetConsumption(ACTIONS.ROW_CONTROLLER, 1)
    inst.components.finiteuses:SetConsumption(ACTIONS.ROW_FAIL, data.ROW_FAIL_WEAR)

    MakeHauntableLaunch(inst)

    return inst
end

local function oar()
    return fn(TUNING.BOAT.OARS.BASIC, "oar", "swap_oar", TUNING.MED_FUEL, true)
end

local function driftwood_oar()
    return  fn(TUNING.BOAT.OARS.DRIFTWOOD, "oar_driftwood", "swap_oar_driftwood", TUNING.MED_FUEL, true, true)
end

local function malbatrossbeak()
    return fn(TUNING.BOAT.OARS.MALBATROSS, "malbatross_beak", "swap_malbatross_beak", nil, nil)
end

return  Prefab("oar", oar, wood_assets),
        Prefab("oar_driftwood", driftwood_oar, driftwood_assets),
        Prefab("malbatross_beak", malbatrossbeak, beak_assets)