local assets =
{
	Asset("ANIM", "anim/armor_dreadstone.zip"),
}

local function OnBlocked(owner)
	owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_dreadstone")
end

local function GetSetBonusEquip(inst, owner)
	local hat = owner.components.inventory ~= nil and owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) or nil
	return hat ~= nil and hat.prefab == "dreadstonehat" and hat or nil
end

local function DoRegen(inst, owner)
	if owner.components.sanity ~= nil and owner.components.sanity:IsInsanityMode() then
		local setbonus = inst.components.setbonus ~= nil and inst.components.setbonus:IsEnabled(EQUIPMENTSETNAMES.DREADSTONE) and TUNING.ARMOR_DREADSTONE_REGEN_SETBONUS or 1
		local rate = 1 / Lerp(1 / TUNING.ARMOR_DREADSTONE_REGEN_MAXRATE, 1 / TUNING.ARMOR_DREADSTONE_REGEN_MINRATE, owner.components.sanity:GetPercent())
		inst.components.armor:Repair(inst.components.armor.maxcondition * rate * setbonus)
	end
	if not inst.components.armor:IsDamaged() then
		inst.regentask:Cancel()
		inst.regentask = nil
	end
end

local function StartRegen(inst, owner)
	if inst.regentask == nil then
		inst.regentask = inst:DoPeriodicTask(TUNING.ARMOR_DREADSTONE_REGEN_PERIOD, DoRegen, nil, owner)
	end
end

local function StopRegen(inst)
	if inst.regentask ~= nil then
		inst.regentask:Cancel()
		inst.regentask = nil
	end
end

local function onequip(inst, owner)
	local skin_build = inst:GetSkinBuild()
	if skin_build ~= nil then
		owner:PushEvent("equipskinneditem", inst:GetSkinName())
		owner.AnimState:OverrideItemSkinSymbol("swap_body", skin_build, "swap_body", inst.GUID, "armor_dreadstone")
	else
		owner.AnimState:OverrideSymbol("swap_body", "armor_dreadstone", "swap_body")
	end

	inst:ListenForEvent("blocked", OnBlocked, owner)

	if owner.components.sanity ~= nil and inst.components.armor:IsDamaged() then
		StartRegen(inst, owner)
	else
		StopRegen(inst)
	end
end

local function onunequip(inst, owner)
	owner.AnimState:ClearOverrideSymbol("swap_body")
	inst:RemoveEventCallback("blocked", OnBlocked, owner)

	local skin_build = inst:GetSkinBuild()
	if skin_build ~= nil then
		owner:PushEvent("unequipskinneditem", inst:GetSkinName())
	end

	StopRegen(inst)
end

local function OnTakeDamage(inst, amount)
	if inst.regentask == nil and inst.components.equippable:IsEquipped() then
		local owner = inst.components.inventoryitem.owner
		if owner ~= nil and owner.components.sanity ~= nil then
			StartRegen(inst, owner)
		end
	end
end

local function CalcDapperness(inst, owner)
	local insanity = owner.components.sanity ~= nil and owner.components.sanity:IsInsanityMode()
	local other = GetSetBonusEquip(inst, owner)
	if other ~= nil then
		return (insanity and (inst.regentask ~= nil or other.regentask ~= nil) and TUNING.CRAZINESS_MED or 0) * 0.5
	end
	return insanity and inst.regentask ~= nil and TUNING.CRAZINESS_MED or 0
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("armor_dreadstone")
	inst.AnimState:SetBuild("armor_dreadstone")
	inst.AnimState:PlayAnimation("anim")

	inst:AddTag("dreadstone")
	inst:AddTag("shadow_item")

	--shadowlevel (from shadowlevel component) added to pristine state for optimization
	inst:AddTag("shadowlevel")

	inst.foleysound = "dontstarve/movement/foley/dreadstonearmour"

	local swap_data = { bank = "armor_dreadstone", anim = "anim" }
	MakeInventoryFloatable(inst, "small", 0.2, 0.80, nil, nil, swap_data)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")

	inst:AddComponent("armor")
	inst.components.armor:InitCondition(TUNING.ARMORDREADSTONE, TUNING.ARMORDREADSTONE_ABSORPTION)
	inst.components.armor.ontakedamage = OnTakeDamage

	inst:AddComponent("planardefense")
	inst.components.planardefense:SetBaseDefense(TUNING.ARMORDREADSTONE_PLANAR_DEF)

	inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.BODY
	inst.components.equippable.dapperfn = CalcDapperness
	inst.components.equippable.is_magic_dapperness = true
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)

	inst:AddComponent("damagetyperesist")
	inst.components.damagetyperesist:AddResist("shadow_aligned", inst, TUNING.ARMORDREADSTONE_SHADOW_RESIST)

	inst:AddComponent("shadowlevel")
	inst.components.shadowlevel:SetDefaultLevel(TUNING.ARMORDREADSTONE_SHADOW_LEVEL)

	local setbonus = inst:AddComponent("setbonus")
	setbonus:SetSetName(EQUIPMENTSETNAMES.DREADSTONE)

	MakeHauntableLaunch(inst)

	return inst
end

return Prefab("armordreadstone", fn, assets)
