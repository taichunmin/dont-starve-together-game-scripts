

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("backpack", inst.build, "backpack")
    owner.AnimState:OverrideSymbol("swap_body", inst.build, "swap_body")
    inst.components.fueled:StartConsuming()
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("backpack")
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst.components.fueled:StopConsuming()
end

local function onequiptomodel(inst)
    inst.components.fueled:StopConsuming()
end

local function common_fn(build_bank, insulation)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank(build_bank)
    inst.AnimState:SetBuild(build_bank)
    inst.AnimState:PlayAnimation("anim")

    MakeInventoryPhysics(inst)

    --inst.foleysound = "dontstarve/movement/foley/trunksuit"

    MakeInventoryFloatable(inst, "med", nil, 0.6)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.build = build_bank

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel)

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.USAGE
    inst.components.fueled:InitializeFuelLevel(TUNING.CARNIVAL_VEST_PERISHTIME)
    inst.components.fueled:SetDepletedFn(inst.Remove)

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(insulation)
    inst.components.insulator:SetSummer()

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    MakeHauntableLaunch(inst)

    return inst
end

local function MakeVest(prefabname, build_bank, insulation)
	local function fn()
		return common_fn(build_bank, insulation)
	end

	local assets =
	{
		Asset("ANIM", "anim/"..build_bank..".zip"),
	}
	return Prefab(prefabname, fn, assets, prefabs)
end

return MakeVest("carnival_vest_a", "carnival_vest_a", TUNING.INSULATION_MED),
		MakeVest("carnival_vest_b", "carnival_vest_b", TUNING.INSULATION_LARGE),
		MakeVest("carnival_vest_c", "carnival_vest_c", TUNING.INSULATION_LARGE)