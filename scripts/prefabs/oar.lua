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

local monkey_assets =
{
    Asset("ANIM", "anim/oar_monkey.zip"),
    Asset("ANIM", "anim/swap_oar_monkey.zip"),
}

local yotd_assets =
{
    Asset("ANIM", "anim/yotd_oar.zip"),
    --Asset("ANIM", "anim/swap_yotd_oar.zip"),
}

local function onequip(inst, owner, swap_build, swap_symbol)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, swap_build, inst.GUID, swap_symbol or swap_build)
    else
        owner.AnimState:OverrideSymbol("swap_object", swap_build, swap_symbol or swap_build)
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

    inst.scrapbook_specialinfo = "PADDLE"

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

    --
    inst:AddComponent("inventoryitem")

    --
    local oar = inst:AddComponent("oar")
    oar.force = data.FORCE
    oar.max_velocity = data.MAX_VELOCITY

    --
    inst:AddComponent("inspectable")

    if is_waterproof then
        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(0)
    end

    --
    local weapon = inst:AddComponent("weapon")
    weapon:SetDamage(data.DAMAGE)
    weapon.attackwear = data.ATTACKWEAR

    --
    local equippable = inst:AddComponent("equippable")
    equippable:SetOnEquip(function(inst, owner) onequip(inst, owner, swap_build) end)
    equippable:SetOnUnequip(onunequip)

    --
    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)

	if fuel_value ~= nil then
		local fuel = inst:AddComponent("fuel")
		fuel.fuelvalue = fuel_value
	end

    local finiteuses = inst:AddComponent("finiteuses")
    finiteuses:SetMaxUses(data.USES)
    finiteuses:SetUses(data.USES)
    finiteuses:SetOnFinished(onfiniteusesfinished)
    finiteuses:SetConsumption(ACTIONS.ROW, 1)
    finiteuses:SetConsumption(ACTIONS.ROW_CONTROLLER, 1)
    finiteuses:SetConsumption(ACTIONS.ROW_FAIL, data.ROW_FAIL_WEAR)
    finiteuses.modifyuseconsumption = function(uses, action, doer, target)
        if (action == ACTIONS.ROW or action == ACTIONS.ROW_FAIL or action == ACTIONS.ROW_CONTROLLER)
                and doer:HasTag("master_crewman") then
            uses = uses * TUNING.MASTER_CREWMAN_MULT.OAR_CONSUMPTION
        end
        return uses
    end

    MakeHauntableLaunch(inst)

    return inst
end

local function oar()
    return fn(TUNING.BOAT.OARS.BASIC, "oar", "swap_oar", TUNING.MED_FUEL, true)
end

local function driftwood_oar()
    return fn(TUNING.BOAT.OARS.DRIFTWOOD, "oar_driftwood", "swap_oar_driftwood", TUNING.MED_FUEL, true, true)
end

local function malbatrossbeak()
    return fn(TUNING.BOAT.OARS.MALBATROSS, "malbatross_beak", "swap_malbatross_beak", nil, nil)
end

local function monkey_oar()
    return fn(TUNING.BOAT.OARS.MONKEY, "oar_monkey", "swap_oar_monkey", TUNING.MED_FUEL, true)
end

local function yotd_oar()
    local swap_build = "yotd_oar"

    local inst = fn(TUNING.BOAT.OARS.DRIFTWOOD, "yotd_oar", swap_build, TUNING.MED_FUEL, true, true)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.equippable:SetOnEquip(function(i, owner) onequip(i, owner, swap_build, "swap_oar") end)

    return inst
end

return  Prefab("oar", oar, wood_assets),
        Prefab("oar_driftwood", driftwood_oar, driftwood_assets),
        Prefab("malbatross_beak", malbatrossbeak, beak_assets),
        Prefab("oar_monkey", monkey_oar, monkey_assets),
        Prefab("yotd_oar", yotd_oar, yotd_assets)