local assets =
{
	Asset("ANIM", "anim/flowers.zip"),
}

local function OnEntitySleep(inst)
	if inst._sleeptask then
		inst._sleeptask:Cancel()
	end
	inst._sleeptask = inst:DoTaskInTime(2, inst.Remove)
end

local function OnEntityWake(inst)
	if inst._sleeptask then
		inst._sleeptask:Cancel()
		inst._sleeptask = nil
	end
end

local function OnPutInInventory(inst, owner)
	if not (inst.persists or inst.AnimState:AnimDone()) then
		inst.persists = true
		if inst._soundtask then
			inst._soundtask:Cancel()
			inst._soundtask = nil
		end
		inst:RemoveEventCallback("animover", ErodeAway)
		inst.AnimState:PlayAnimation("rose")
		inst.OnEntitySleep = nil
		inst.OnEntityWake = nil
		OnEntityWake(inst)
	end
end

local function DoFallShatterSound(inst)
	inst._soundtask = nil
	inst.SoundEmitter:PlaySound("meta4/charlie_residue/rose_fall_shatter")
end

local function OnDropped(inst)
	inst.persists = false
	inst.AnimState:PlayAnimation("rose_shatter")
	if inst._soundtask == nil then
		inst._soundtask = inst:DoTaskInTime(0, DoFallShatterSound)
	end
	inst:ListenForEvent("animover", ErodeAway)
	inst.OnEntitySleep = OnEntitySleep
	inst.OnEntityWake = OnEntityWake
	if inst:IsAsleep() then
		OnEntitySleep(inst)
	end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("flowers")
	inst.AnimState:SetBuild("flowers")
	inst.AnimState:PlayAnimation("rose")

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
	inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
	inst.components.inventoryitem.canonlygoinpocket = true
	inst.components.inventoryitem.canbepickedup = false
	inst.components.inventoryitem.nobounce = true

	inst:AddComponent("fuel")
	inst.components.fuel.fuelvalue = TUNING.TINY_FUEL

	OnDropped(inst)

	return inst
end

return Prefab("charlierose", fn, assets)
