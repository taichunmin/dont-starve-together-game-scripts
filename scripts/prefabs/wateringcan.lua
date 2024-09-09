local fueltype = FUELTYPE.BURNABLE

local MOISTURE_ON_BURNT_MULTIPLIER = 0.1

local function OnDeplete(inst)
    inst.components.finiteuses:Use(1)
end

local function OnEquip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_"..inst.prefab, inst.GUID, "swap_"..inst.prefab)
    else
        owner.AnimState:OverrideSymbol("swap_object", "swap_"..inst.prefab, "swap_"..inst.prefab)
    end
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function OnFill(inst, from_object)
    if from_object ~= nil
        and from_object.components.watersource ~= nil
        and from_object.components.watersource.override_fill_uses ~= nil then

        inst.components.finiteuses:SetUses(math.min(inst.components.finiteuses.total, inst.components.finiteuses:GetUses() + from_object.components.watersource.override_fill_uses))
    else
        inst.components.finiteuses:SetPercent(1)
    end
    inst.SoundEmitter:PlaySound("turnoftides/common/together/water/emerge/small")
    return true
end

local function MakeFuel(inst)
    if inst.components.fuel == nil then
        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL
        inst.components.fuel.fueltype = fueltype
    end
end

local function RemoveFuel(inst)
    if inst.components.fuel ~= nil then
        inst:RemoveComponent("fuel")
    end
end

local function onpercentusedchanged(inst, data)
    if data.percent <= 0 then
        MakeFuel(inst)
    else
        RemoveFuel(inst)
    end
end

local function onburnt(inst)
    local amount = math.ceil(inst.components.finiteuses:GetUses() * inst.components.wateryprotection.addwetness * MOISTURE_ON_BURNT_MULTIPLIER)
    if amount > 0 then
        local x, y, z = inst.Transform:GetWorldPosition()
        TheWorld.components.farming_manager:AddSoilMoistureAtPoint(x, 0, z, amount)
    end
end

local function onuse(inst)
	if inst.components.finiteuses ~= nil then
		inst.components.finiteuses:Use()
	end
end

local function displaynamefn(inst)
    return not inst:HasTag("usesdepleted") and STRINGS.NAMES[string.upper(inst.prefab).."_NOT_EMPTY"] or nil
end

local function getstatus(inst, viewer)
	return inst:HasTag("usesdepleted") and "EMPTY" or nil
end

local function OnSave(inst, data)
    -- Normally finiteuses handles its own saving, but it doesn't
    -- work properly for items that don't start at 100% uses.
    data.uses = inst.components.finiteuses.current
end

local function OnLoad(inst, data)
    if data ~= nil and data.uses ~= nil then
        inst.components.finiteuses:SetUses(data.uses)
    end
end

local function MakeWateringCan(name, uses, water_amount)
    local assets =
    {
        Asset("ANIM", "anim/"..name..".zip"),
        Asset("ANIM", "anim/swap_"..name..".zip"),
    }

    local prefabs =
    {
        "gridplacer",
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.Transform:SetTwoFaced()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle")

        MakeInventoryFloatable(inst, "small", 0.1, 1)

		inst:AddTag("wateringcan")

        inst.displaynamefn = displaynamefn

        inst.scrapbook_specialinfo = "WATERINGCAN"
        inst.scrapbook_subcat = "tool"

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = getstatus

        inst:AddComponent("inventoryitem")

	    inst:AddComponent("wateryprotection")
		inst.components.wateryprotection.extinguishheatpercent = TUNING.WATERINGCAN_EXTINGUISH_HEAT_PERCENT
		inst.components.wateryprotection.temperaturereduction = TUNING.WATERINGCAN_TEMP_REDUCTION
		inst.components.wateryprotection.witherprotectiontime = TUNING.WATERINGCAN_PROTECTION_TIME
		inst.components.wateryprotection.addwetness = water_amount
		inst.components.wateryprotection.protection_dist = TUNING.WATERINGCAN_PROTECTION_DIST
		inst.components.wateryprotection:AddIgnoreTag("player")
		inst.components.wateryprotection.onspreadprotectionfn = onuse

        inst:AddComponent("fillable")
        inst.components.fillable.overrideonfillfn = OnFill
        inst.components.fillable.showoceanaction = true
        inst.components.fillable.acceptsoceanwater = false
        inst.components.fillable.oceanwatererrorreason = "UNSUITABLE_FOR_PLANTS"

        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(uses)
        inst.components.finiteuses:SetUses(0)

        MakeFuel(inst)

        inst:AddComponent("equippable")
        inst.components.equippable:SetOnEquip(OnEquip)
        inst.components.equippable:SetOnUnequip(OnUnequip)

        inst:AddComponent("weapon")
        inst.components.weapon:SetDamage(TUNING.UNARMED_DAMAGE)
        inst.components.weapon.attackwearmultipliers:SetModifier(inst, 0)

        MakeSmallBurnable(inst)
        MakeSmallPropagator(inst)
        MakeHauntableLaunch(inst)

        inst:ListenForEvent("percentusedchange", onpercentusedchanged)
        inst:ListenForEvent("onburnt", onburnt)

        inst.OnSave = OnSave
        inst.OnLoad = OnLoad

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

return MakeWateringCan("wateringcan", TUNING.WATERINGCAN_USES, TUNING.WATERINGCAN_WATER_AMOUNT),
    MakeWateringCan("premiumwateringcan", TUNING.PREMIUMWATERINGCAN_USES, TUNING.PREMIUMWATERINGCAN_WATER_AMOUNT)