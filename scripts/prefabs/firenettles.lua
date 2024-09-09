local assets =
{
    Asset("ANIM", "anim/firenettles.zip"),
}

local prefabs =
{
	"firenettle_toxin",
}

local function oneaten(inst, eater)
	if not eater:HasTag("plantkin") then
        eater:AddDebuff("firenettle_toxin", "firenettle_toxin")
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("firenettles")
    inst.AnimState:SetBuild("firenettles")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "med", 0.0, 0.7)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("tradable")
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = -TUNING.HEALING_SMALL
    inst.components.edible.hungervalue = 0
    inst.components.edible.sanityvalue = -TUNING.SANITY_TINY
    inst.components.edible.foodtype = FOODTYPE.VEGGIE
    inst.components.edible:SetOnEatenFn(oneaten)

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)

    MakeHauntableLaunchAndPerish(inst)

    return inst
end


local function DoT_OnTick(inst, target)
	if target.components.talker ~= nil and target.components.health ~= nil and not target.components.health:IsDead() and target:HasTag("idle") then
		target.components.talker:Say(GetString(target, "ANNOUNCE_FIRENETTLE_TOXIN"))
	end
end

local function buff_OnAttached(inst, target)
	inst.entity:SetParent(target.entity)
	inst.Transform:SetPosition(0, 0, 0)

    inst:ListenForEvent("death", function()
        inst.components.debuff:Stop()
    end, target)

	if target.components.temperature ~= nil then
		target.components.temperature:SetModifier("firenettle_toxin", TUNING.FIRE_NETTLE_TOXIN_TEMP_MODIFIER)
	end

    inst:DoPeriodicTask(10, DoT_OnTick, 5, target)

end

local function buff_OnDetached(inst, target)
	if target ~= nil and target:IsValid() and target.components.temperature ~= nil then
		target.components.temperature:RemoveModifier("firenettle_toxin")

		if target.components.talker ~= nil and target.components.health ~= nil and not target.components.health:IsDead() then
			target.components.talker:Say(GetString(target, "ANNOUNCE_FIRENETTLE_TOXIN_DONE"))
		end
	end
    inst:Remove()
end

local function expire(inst)
	if inst.components.debuff ~= nil then
		inst.components.debuff:Stop()
	end
end

local function buff_OnExtended(inst)
	if inst.task ~= nil then
		inst.task:Cancel()
	end
	inst.task = inst:DoTaskInTime(TUNING.FIRE_NETTLE_TOXIN_DURATION, expire)
end

local function OnSave(inst, data)
	if inst.task ~= nil then
		data.remaining = GetTaskRemaining(inst.task)
	end
end

local function OnLoad(inst, data)
	if data ~= nil and data.remaining then
		if inst.task ~= nil then
			inst.task:Cancel()
		end
		inst.task = inst:DoTaskInTime(data.remaining, expire)
	end
end

local function debuff_fn(anim)
	local inst = CreateEntity()

    if not TheWorld.ismastersim then
        --Not meant for client!
        inst:DoTaskInTime(0, inst.Remove)

        return inst
    end

    inst.entity:AddTransform()

    --[[Non-networked entity]]
    --inst.entity:SetCanSleep(false)
    inst.entity:Hide()

    inst:AddTag("CLASSIFIED")

	inst:AddComponent("debuff")
	inst.components.debuff:SetAttachedFn(buff_OnAttached)
	inst.components.debuff:SetDetachedFn(buff_OnDetached)
	inst.components.debuff:SetExtendedFn(buff_OnExtended)
	inst.components.debuff.keepondespawn = true

	buff_OnExtended(inst)

	inst.OnSave = OnSave
	inst.OnLoad = OnLoad

	return inst
end


return Prefab("firenettles", fn, assets, prefabs),
	Prefab("firenettle_toxin", debuff_fn, assets)
