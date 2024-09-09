local assets =
{
	Asset("ANIM", "anim/staff_lunarplant.zip"),
}

local prefabs =
{
	"brilliance_projectile_fx",
	"staff_lunarplant_fx",
}

local function SetFxOwner(inst, owner)
	if inst._fxowner ~= nil and inst._fxowner.components.colouradder ~= nil then
		inst._fxowner.components.colouradder:DetachChild(inst.fx)
	end
	inst._fxowner = owner
	if owner ~= nil then
		inst.fx.entity:SetParent(owner.entity)
		inst.fx.Follower:FollowSymbol(owner.GUID, "swap_object", nil, nil, nil, true)
		inst.fx.components.highlightchild:SetOwner(owner)
		if owner.components.colouradder ~= nil then
			owner.components.colouradder:AttachChild(inst.fx)
		end
	else
		inst.fx.entity:SetParent(inst.entity)
		--For floating
		inst.fx.Follower:FollowSymbol(inst.GUID, "swap_spear", nil, nil, nil, true)
		inst.fx.components.highlightchild:SetOwner(inst)
	end
end

local function PushIdleLoop(inst)
	if inst.components.finiteuses:GetUses() > 0 then
		inst.AnimState:PushAnimation("idle")
	end
end

local function OnStopFloating(inst)
	if inst.components.finiteuses:GetUses() > 0 then
		inst.fx.AnimState:SetFrame(0)
		inst:DoTaskInTime(0, PushIdleLoop) --#V2C: #HACK restore the looping anim, timing issues
	end
end

local function onequip(inst, owner)
	local skin_build = inst:GetSkinBuild()
	if skin_build ~= nil then
		owner:PushEvent("equipskinneditem", inst:GetSkinName())
		owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_staff_lunarplant", inst.GUID, "staff_lunarplant")
	else
		owner.AnimState:OverrideSymbol("swap_object", "staff_lunarplant", "swap_staff_lunarplant")
	end
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
	SetFxOwner(inst, owner)
end

local function onunequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
	local skin_build = inst:GetSkinBuild()
	if skin_build ~= nil then
		owner:PushEvent("unequipskinneditem", inst:GetSkinName())
	end
	SetFxOwner(inst, nil)
end

local function OnAttack(inst, attacker, target, skipsanity)
	if inst.skin_sound then
		attacker.SoundEmitter:PlaySound(inst.skin_sound)
	end

	if not target:IsValid() then
		--target killed or removed in combat damage phase
		return
	end

	if target.components.sleeper ~= nil and target.components.sleeper:IsAsleep() then
		target.components.sleeper:WakeUp()
	end
	if target.components.combat ~= nil then
		target.components.combat:SuggestTarget(attacker)
	end
	target:PushEvent("attacked", { attacker = attacker, damage = 0, weapon = inst })
end

local function SetupComponents(inst)
	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(0)
	inst.components.weapon:SetRange(8, 10)
	inst.components.weapon:SetOnAttack(OnAttack)
	inst.components.weapon:SetProjectile("brilliance_projectile_fx")
end

local function DisableComponents(inst)
	inst:RemoveComponent("equippable")
	inst:RemoveComponent("weapon")
end

local FLOAT_SCALE_BROKEN = { 0.7, 0.5, 0.7 }
local FLOAT_SCALE = { 0.9, 0.6, 0.9 }

local function OnIsBrokenDirty(inst)
	if inst.isbroken:value() then
		inst.components.floater:SetSize("med")
		inst.components.floater:SetVerticalOffset(0.15)
		inst.components.floater:SetScale(FLOAT_SCALE_BROKEN)
	else
		inst.components.floater:SetSize("med")
		inst.components.floater:SetVerticalOffset(0.1)
		inst.components.floater:SetScale(FLOAT_SCALE)
	end
end

local SWAP_DATA_BROKEN = { sym_build = "staff_lunarplant", sym_name = "swap_staff_BROKEN_FORGEDITEM_float", bank = "staff_lunarplant", anim = "broken" }
local SWAP_DATA = { sym_build = "staff_lunarplant", sym_name = "swap_staff_lunarplant" }

local function SetIsBroken(inst, isbroken)
	if isbroken then
		inst.components.floater:SetBankSwapOnFloat(true, -5, SWAP_DATA_BROKEN)
		if inst.fx ~= nil then
			inst.fx:Hide()
		end
	else
		inst.components.floater:SetBankSwapOnFloat(true, -13, SWAP_DATA)
		if inst.fx ~= nil then
			inst.fx:Show()
		end
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
		inst.fx.AnimState:SetFrame(0)
		inst.AnimState:PlayAnimation("idle", true)
		SetIsBroken(inst, false)
		inst:RemoveTag("broken")
		inst.components.inspectable.nameoverride = nil
	end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("staff_lunarplant")
	inst.AnimState:SetBuild("staff_lunarplant")
	inst.AnimState:PlayAnimation("idle", true)
	inst.AnimState:SetSymbolBloom("pb_energy_loop")
	inst.AnimState:SetSymbolBloom("stone")
	inst.AnimState:SetSymbolLightOverride("pb_energy_loop01", .5)
	inst.AnimState:SetSymbolLightOverride("pb_ray", .5)
	inst.AnimState:SetSymbolLightOverride("stone", .5)
	inst.AnimState:SetSymbolLightOverride("glow", .25)
	inst.AnimState:SetLightOverride(.1)

	inst:AddTag("rangedweapon")
	inst:AddTag("magicweapon")
	inst:AddTag("show_broken_ui")

	--weapon (from weapon component) added to pristine state for optimization
	inst:AddTag("weapon")

	inst.projectiledelay = FRAMES

	inst:AddComponent("floater")
	inst.isbroken = net_bool(inst.GUID, "staff_lunarplant.isbroken", "isbrokendirty")
	SetIsBroken(inst, false)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		inst:ListenForEvent("isbrokendirty", OnIsBrokenDirty)

		return inst
	end

	local frame = math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1
	inst.AnimState:SetFrame(frame)
	inst.fx = SpawnPrefab("staff_lunarplant_fx")
	inst.fx.AnimState:SetFrame(frame)
	SetFxOwner(inst, nil)
	inst:ListenForEvent("floater_stopfloating", OnStopFloating)

	-------
	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(TUNING.STAFF_LUNARPLANT_USES)
	inst.components.finiteuses:SetUses(TUNING.STAFF_LUNARPLANT_USES)

	inst:AddComponent("planardamage")
	inst.components.planardamage:SetBaseDamage(TUNING.STAFF_LUNARPLANT_PLANAR_DAMAGE)

	inst:AddComponent("damagetypebonus")
	inst.components.damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.STAFF_LUNARPLANT_VS_SHADOW_BONUS)

	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")

	SetupComponents(inst)

	local setbonus = inst:AddComponent("setbonus")
	setbonus:SetSetName(EQUIPMENTSETNAMES.LUNARPLANT)

	MakeForgeRepairable(inst, FORGEMATERIALS.LUNARPLANT, OnBroken, OnRepaired)
	MakeHauntableLaunch(inst)

	inst.noplanarhitfx = true

	return inst
end

local function fxfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()
	inst.entity:AddNetwork()

	inst:AddTag("FX")

	inst.AnimState:SetBank("staff_lunarplant")
	inst.AnimState:SetBuild("staff_lunarplant")
	inst.AnimState:PlayAnimation("swap_loop", true)
	inst.AnimState:SetSymbolBloom("pb_energy_loop")
	inst.AnimState:SetSymbolBloom("stone")
	inst.AnimState:SetSymbolLightOverride("pb_energy_loop01", .5)
	inst.AnimState:SetSymbolLightOverride("pb_ray", .5)
	inst.AnimState:SetSymbolLightOverride("stone", .5)
	inst.AnimState:SetSymbolLightOverride("glow", .25)
	inst.AnimState:SetLightOverride(.1)

	inst:AddComponent("highlightchild")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("colouradder")

	inst.persists = false

	return inst
end

return Prefab("staff_lunarplant", fn, assets, prefabs),
	Prefab("staff_lunarplant_fx", fxfn, assets)
