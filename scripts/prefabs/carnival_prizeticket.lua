local assets =
{
    Asset("ANIM", "anim/carnival_prizeticket.zip"),
	Asset("INV_IMAGE", "carnival_prizeticket_smallstack"),
	Asset("INV_IMAGE", "carnival_prizeticket_largestack"),
}

local prefabs =
{
}

local MERGE_NO_TAGS = {"INLIMBO"}

local function MergeStacks(inst)
	local function CanMergeTestFn(item)
		return item.prefab == inst.prefab
				and item.skinname == inst.skinname
				and (item.components.inventoryitem ~= nil and item.components.inventoryitem.is_landed)
				and (item.components.stackable ~= nil and (item.components.stackable:RoomLeft() >= inst.components.stackable:StackSize()))
	end

	local item = FindEntity(inst, 1, function(item) return CanMergeTestFn(item) end, nil, MERGE_NO_TAGS)
	if item ~= nil then
		item.components.stackable:Put(inst)
	end
end

local function TryMergeStacks(inst)
	inst:DoTaskInTime(.1, MergeStacks)
end

local function GetAnimStateForStackSize(inst, stacksize)
	return stacksize == 1 and ""
			or stacksize > 5 and "_largestack"
			or "_smallstack"
end

local function OnStackSizeChanged(inst, data)
	if data ~= nil then
		local cur_state = GetAnimStateForStackSize(inst, data.oldstacksize)
		local new_state = GetAnimStateForStackSize(inst, data.stacksize)
		if data.stacksize > 1 and not POPULATING then
			inst.AnimState:PlayAnimation("jostle"..new_state)
			inst.AnimState:PushAnimation("idle"..new_state, false)
		else
			inst.AnimState:PlayAnimation("idle"..new_state)
		end

		if inst.components.inventoryitem.imagename ~= "carnival_prizeticket"..new_state then
			inst.components.inventoryitem:ChangeImageName("carnival_prizeticket"..new_state)
		end
	end
end

local function GetStatus(inst)
	return "GENERIC" .. GetAnimStateForStackSize(inst, inst.replica.stackable:StackSize())
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("carnival_prizeticket")
    inst.AnimState:SetBuild("carnival_prizeticket")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("cattoy")

    MakeInventoryFloatable(inst, "med", nil, 0.68)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")

    inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_TINYITEM

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.TINY_FUEL

    MakeSmallBurnable(inst, TUNING.TINY_BURNTIME)
    MakeSmallPropagator(inst)

    MakeHauntableLaunch(inst)

	inst:ListenForEvent("on_landed", TryMergeStacks)
    inst:ListenForEvent("stacksizechange", OnStackSizeChanged)

    return inst
end

return Prefab("carnival_prizeticket", fn, assets)
