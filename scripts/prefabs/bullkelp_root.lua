require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/bullkelp.zip"),
    Asset("ANIM", "anim/swap_bullkelproot.zip"),
    Asset("INV_IMAGE", "kullkelp_root"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_bullkelproot", "swap_whip")
    owner.AnimState:OverrideSymbol("whipline", "swap_bullkelproot", "whipline")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function onattack(inst, attacker, target)
	inst.components.perishable:ReducePercent(math.random()*TUNING.BULLKELP_ROOT_USE_VAR + TUNING.BULLKELP_ROOT_USE)

	local spoilage = inst.components.perishable:GetPercent()
	local chance = spoilage <= 0 and 1.0
					or spoilage < 0.02 and 0.3
					or spoilage < 0.5 and 0.1
					or 0

	if chance > 0 and math.random() <= chance then
		local x, y, z = inst.Transform:GetWorldPosition()
		local x1, y1, z1 = target.Transform:GetWorldPosition()
		local angle = -math.atan2(z1 - z, x1 - x)
		local snap = SpawnPrefab("impact")
		snap.Transform:SetPosition(x1, y1, z1)
		snap.Transform:SetRotation(angle * RADIANS)

        if target.SoundEmitter ~= nil then
            target.SoundEmitter:PlaySound("dontstarve/common/whip_small")
        end

		inst:DoTaskInTime(0, inst.Remove)
	end

end

local function ondeploy(inst, pt, deployer)
    local plant = SpawnPrefab("bullkelp_plant")
    if plant ~= nil then
        plant.Transform:SetPosition(pt:Get())
        inst.components.stackable:Get():Remove()
        --plant.components.pickable:OnTransplant() -- bullkelp does not suffer from transplant sickness
		plant.components.pickable:MakeEmpty()
        if deployer ~= nil and deployer.SoundEmitter ~= nil then
            deployer.SoundEmitter:PlaySound("dontstarve/common/plant")
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("bullkelp")
    inst.AnimState:SetBuild("bullkelp")
    inst.AnimState:PlayAnimation("dropped")

    MakeInventoryFloatable(inst)

    inst:AddTag("whip")
	inst:AddTag("show_spoilage")
    inst:AddTag("deployedplant")

    inst.entity:SetPristine()

    inst.scrapbook_anim = "dropped"

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.BULLKELP_ROOT_DAMAGE)
    inst.components.weapon:SetRange(TUNING.BULLKELP_ROOT_RANGE)
    inst.components.weapon:SetOnAttack(onattack)

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy
    inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.MEDIUM)
    inst.components.deployable:SetDeployMode(DEPLOYMODE.WATER)

    MakeMediumBurnable(inst, TUNING.LARGE_BURNTIME)
    MakeSmallPropagator(inst)

    MakeHauntableLaunchAndIgnite(inst)

    ---------------------
    return inst
end

return Prefab("bullkelp_root", fn, assets),
		MakePlacer("bullkelp_root_placer", "bullkelp", "bullkelp", "preview", false, false, false, nil, nil, nil, nil, 2)
