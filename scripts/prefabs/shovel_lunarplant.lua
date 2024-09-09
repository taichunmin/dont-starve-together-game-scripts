local assets =
{
	Asset("ANIM", "anim/shovel_lunarplant.zip"),
}

local prefabs =
{
	"lunarplanttentacle",
}

local function SetBuffEnabled(inst, enabled)
	if enabled then
		if not inst._bonusenabled then
			inst._bonusenabled = true
			if inst.components.weapon ~= nil then
				inst.components.weapon:SetDamage(inst.base_damage * TUNING.WEAPONS_LUNARPLANT_SETBONUS_DAMAGE_MULT)
			end
			inst.components.planardamage:AddBonus(inst, TUNING.WEAPONS_LUNARPLANT_SETBONUS_PLANAR_DAMAGE, "setbonus")
		end
	elseif inst._bonusenabled then
		inst._bonusenabled = nil
		if inst.components.weapon ~= nil then
			inst.components.weapon:SetDamage(inst.base_damage)
		end
		inst.components.planardamage:RemoveBonus(inst, "setbonus")
	end
end

local function SetBuffOwner(inst, owner)
	if inst._owner ~= owner then
		if inst._owner ~= nil then
			inst:RemoveEventCallback("equip", inst._onownerequip, inst._owner)
			inst:RemoveEventCallback("unequip", inst._onownerunequip, inst._owner)
			inst._onownerequip = nil
			inst._onownerunequip = nil
			SetBuffEnabled(inst, false)
		end
		inst._owner = owner
		if owner ~= nil then
			inst._onownerequip = function(owner, data)
				if data ~= nil then
					if data.item ~= nil and data.item.prefab == "lunarplanthat" then
						SetBuffEnabled(inst, true)
					elseif data.eslot == EQUIPSLOTS.HEAD then
						SetBuffEnabled(inst, false)
					end
				end
			end
			inst._onownerunequip  = function(owner, data)
				if data ~= nil and data.eslot == EQUIPSLOTS.HEAD then
					SetBuffEnabled(inst, false)
				end
			end
			inst:ListenForEvent("equip", inst._onownerequip, owner)
			inst:ListenForEvent("unequip", inst._onownerunequip, owner)

			local hat = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
			if hat ~= nil and hat.prefab == "lunarplanthat" then
				SetBuffEnabled(inst, true)
			end
		end
	end
end

local function onequip(inst, owner)
	local skin_build = inst:GetSkinBuild()
	if skin_build ~= nil then
		owner:PushEvent("equipskinneditem", inst:GetSkinName())
		owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_shovel_lunarplant", inst.GUID, "shovel_lunarplant")
	else
		owner.AnimState:OverrideSymbol("swap_object", "shovel_lunarplant", "swap_shovel_lunarplant")
	end
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
	SetBuffOwner(inst, owner)
end

local function onunequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
	local skin_build = inst:GetSkinBuild()
	if skin_build ~= nil then
		owner:PushEvent("unequipskinneditem", inst:GetSkinName())
	end
	SetBuffOwner(inst, nil)
end

local function SetupComponents(inst)
	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)

	inst:AddComponent("tool")
	inst.components.tool:SetAction(ACTIONS.DIG)
	inst:AddInherentAction(ACTIONS.TILL)
	inst:AddComponent("farmtiller")

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(inst._bonusenabled and inst.base_damage * TUNING.WEAPONS_LUNARPLANT_SETBONUS_DAMAGE_MULT or inst.base_damage)
end

local function DisableComponents(inst)
	inst:RemoveComponent("equippable")
	inst:RemoveComponent("tool")
	inst:RemoveInherentAction(ACTIONS.TILL)
	inst:RemoveComponent("farmtiller")
	inst:RemoveComponent("weapon")
end

local FLOAT_SCALE_BROKEN = { 0.9, 0.72, 0.9 }
local FLOAT_SCALE = { 0.8, 0.4, 0.8 }

local function OnIsBrokenDirty(inst)
	if inst.isbroken:value() then
		inst.components.floater:SetSize("small")
		inst.components.floater:SetVerticalOffset(0.12)
		inst.components.floater:SetScale(FLOAT_SCALE_BROKEN)
	else
		inst.components.floater:SetSize("med")
		inst.components.floater:SetVerticalOffset(0.05)
		inst.components.floater:SetScale(FLOAT_SCALE)
	end
end

local SWAP_DATA_BROKEN = { sym_build = "shovel_lunarplant", sym_name = "swap_shovel_BROKEN_FORGEDITEM_float", bank = "shovel_lunarplant", anim = "broken" }
local SWAP_DATA = { sym_build = "shovel_lunarplant", sym_name = "swap_shovel_lunarplant" }

local function SetIsBroken(inst, isbroken)
	if isbroken then
		inst.components.floater:SetBankSwapOnFloat(true, 6, SWAP_DATA_BROKEN)
	else
		inst.components.floater:SetBankSwapOnFloat(true, 7, SWAP_DATA)
	end
	inst.isbroken:set(isbroken)
	OnIsBrokenDirty(inst)
end

local function OnBroken(inst)
	if inst.components.equippable ~= nil then
		DisableComponents(inst)
		inst.AnimState:PlayAnimation("broken")
		SetIsBroken(inst, true)
		inst:AddTag("broken")
		inst.components.inspectable.nameoverride = "BROKEN_FORGEDITEM"
	end
end

local function OnRepaired(inst)
	if inst.components.equippable == nil then
		SetupComponents(inst)
		inst.AnimState:PlayAnimation("idle")
		SetIsBroken(inst, false)
		inst:RemoveTag("broken")
		inst.components.inspectable.nameoverride = nil
	end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("shovel_lunarplant")
	inst.AnimState:SetBuild("shovel_lunarplant")
	inst.AnimState:PlayAnimation("idle")

	inst:AddTag("show_broken_ui")

	--tool (from tool component) added to pristine state for optimization
	inst:AddTag("tool")

	--weapon (from weapon component) added to pristine state for optimization
	inst:AddTag("weapon")

	inst:AddComponent("floater")
	inst.isbroken = net_bool(inst.GUID, "shovel_lunarplant.isbroken", "isbrokendirty")
	SetIsBroken(inst, false)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		inst:ListenForEvent("isbrokendirty", OnIsBrokenDirty)

		return inst
	end

	-------
	local finiteuses = inst:AddComponent("finiteuses")
	finiteuses:SetMaxUses(TUNING.SHOVEL_LUNARPLANT_USES)
	finiteuses:SetUses(TUNING.SHOVEL_LUNARPLANT_USES)
	finiteuses:SetConsumption(ACTIONS.DIG, 1)
	finiteuses:SetConsumption(ACTIONS.TILL, 1)

	-------
	inst.base_damage = TUNING.SHOVEL_LUNARPLANT_DAMAGE

	local planardamage = inst:AddComponent("planardamage")
	planardamage:SetBaseDamage(TUNING.SHOVEL_LUNARPLANT_PLANAR_DAMAGE)

	local damagetypebonus = inst:AddComponent("damagetypebonus")
	damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.WEAPONS_LUNARPLANT_VS_SHADOW_BONUS)

	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")

	SetupComponents(inst)

	inst:AddComponent("lunarplant_tentacle_weapon")

	MakeForgeRepairable(inst, FORGEMATERIALS.LUNARPLANT, OnBroken, OnRepaired)
	MakeHauntableLaunch(inst)

	return inst
end

return Prefab("shovel_lunarplant", fn, assets, prefabs)
