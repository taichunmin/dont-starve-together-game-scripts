local function OnRepaired(inst, target, doer)
	doer:PushEvent("repair")
end

local function MakeKit(name, material)
	local assets =
	{
		Asset("ANIM", "anim/"..name..".zip"),
	}

	local function fn()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddNetwork()

		MakeInventoryPhysics(inst)

		inst.AnimState:SetBank(name)
		inst.AnimState:SetBuild(name)
		inst.AnimState:PlayAnimation("idle")

		MakeInventoryFloatable(inst, "small", 0.2, { 1.4, 1, 1 })

		if name == "lunarplant_kit" then
			inst.scrapbook_specialinfo = "LUNARPLANTKIT"
		elseif name == "voidcloth_kit" then
			inst.scrapbook_specialinfo = "VOIDCLOTHKIT"
		end

		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			return inst
		end

	    inst:AddComponent("stackable")
	    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

		inst:AddComponent("forgerepair")
		inst.components.forgerepair:SetRepairMaterial(material)
		inst.components.forgerepair:SetOnRepaired(OnRepaired)

		inst:AddComponent("inspectable")
		inst:AddComponent("inventoryitem")

		MakeHauntableLaunch(inst)

		return inst
	end

	return Prefab(name, fn, assets)
end

return MakeKit("lunarplant_kit", FORGEMATERIALS.LUNARPLANT),
	MakeKit("voidcloth_kit", FORGEMATERIALS.VOIDCLOTH),
	MakeKit("wagpunkbits_kit", FORGEMATERIALS.WAGPUNKBITS)
