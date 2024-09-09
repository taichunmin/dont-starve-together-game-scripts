local assets =
{
	Asset("ANIM", "anim/winona_holoitems.zip"),
}

local ANIM_STATE =
{
	NONE = 0,
	DROPPED = 1,
	KILLED = 2,
}

local function CreateAnim(bank, build, anim, erodeparam)
	local inst = CreateEntity()

	inst:AddTag("NOBLOCK")
	inst:AddTag("client_forward_action_target") --use client_forward_target for spacebar action
	--[[Non-networked entity]]
	--inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst.AnimState:SetBank(bank or "winona_holoitems")
	inst.AnimState:SetBuild(build or "winona_holoitems")
	inst.AnimState:PlayAnimation(anim)
	inst.AnimState:SetErosionParams(0, erodeparam or -0.15, -1.0) -- Default values for projectedeffects setup below.

	local projectedeffects = inst:AddComponent("projectedeffects")
	projectedeffects:SetDecayTime(2)
	projectedeffects:SetConstructTime(1)
	projectedeffects:SetCutoffHeight(erodeparam or -0.15)
	projectedeffects:SetIntensity(-1.0)
	projectedeffects:SetOnDecayCallback(inst.Remove)
	projectedeffects:MakeOpaque()

	return inst
end

local function InitClientAnim(inst)
	if inst._anim == nil then
		inst._anim = CreateAnim(inst._BANK, inst._BUILD, inst._ANIM, inst._ERODEPARAM)
		inst._anim.entity:SetParent(inst.entity)
		inst._anim.client_forward_target = inst --locally forward mouseover and controller interaction target to our classified parent
		inst.highlightchildren = { inst._anim }
	end
end

local function KillClientAnim(inst, instant)
	if inst._anim then
		if instant then
			inst._anim:Remove()
		else
			inst._anim:RemoveTag("client_forward_action_target")
			inst._anim:AddTag("FX")
			inst._anim:AddTag("NOCLICK")
			inst._anim.entity:SetCanSleep(false)
			inst._anim.entity:SetParent(nil)
			inst._anim.Transform:SetPosition(inst.Transform:GetWorldPosition())
			inst._anim.components.projectedeffects:Decay()
			inst._anim.client_forward_target = nil
		end
		inst._anim = nil
		inst.highlightchildren = nil
	end
end

local function OnAnimState_Client(inst)
	local state = inst._animstate:value()
	if state == ANIM_STATE.DROPPED then
		InitClientAnim(inst)
	elseif state == ANIM_STATE.KILLED then
		KillClientAnim(inst, false)
	else--if state == ANIM_STATE.NONE then
		KillClientAnim(inst, true)
	end
end

local function SetItemClassifiedOwner(inst, owner)
	if inst._inittask then
		inst._inittask:Cancel()
		inst._inittask = nil
		inst._owner = owner
		if not inst.components.inventoryitem:IsHeld() then
			inst.Network:SetClassifiedTarget(owner)
		end
		if owner.HUD then
			OnAnimState_Client(inst)
		end
	end
end

local function OnPutInInventory(inst, owner)
	inst._animstate:set(ANIM_STATE.NONE)
	if owner.HUD then
		OnAnimState_Client(inst)
	end
	if inst._onremoveowner then
		inst:RemoveEventCallback("onremove", inst._onremoveowner, inst._owner)
		inst._onremoveowner = nil
	end
	inst:SetItemClassifiedOwner(owner) --won't overwrite if already set
	if inst._killtask then
		inst._killtask:Cancel()
		inst._killtask = nil
	end
end

local function KillItem(inst)
	inst._killtask = nil
	inst._animstate:set(ANIM_STATE.KILLED)
	if inst._owner and inst._owner.HUD then
		OnAnimState_Client(inst)
	end
	inst.persists = false
	inst:AddTag("NOCLICK")
	inst:DoTaskInTime(0.5, inst.Remove)
end

local function OnDropped(inst)
	inst._animstate:set(ANIM_STATE.DROPPED)
	if inst._owner then
		inst.Network:SetClassifiedTarget(inst._owner)
		if inst._owner.HUD then
			OnAnimState_Client(inst)
		end
		if inst._onremoveowner == nil then
			inst._onremoveowner = function() inst:Remove() end
			inst:ListenForEvent("onremove", inst._onremoveowner, inst._owner)
		end
	end
	if inst._killtask then
		inst._killtask:Cancel()
	end
	inst._killtask = inst:DoTaskInTime(10, KillItem)
end

local function MakeHoloItem(name, anim, bank, build, erodeparam, invimg, common_postinit, master_postinit)
	local overrideassets
	if build or invimg then
		overrideassets = {}
		if build then
			table.insert(overrideassets, Asset("ANIM", "anim/"..build..".zip"))
		end
		if invimg then
			table.insert(overrideassets, Asset("INV_IMAGE", invimg))
		end
	end

	local function fn()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddNetwork()

		inst:AddTag("CLASSIFIED")

		inst._BANK = bank
		inst._BUILD = build
		inst._ANIM = anim
		inst._ERODEPARAM = erodeparam

		MakeInventoryPhysics(inst)
		--MakeInventoryFloatable(inst)

		inst._animstate = net_tinybyte(inst.GUID, name.."._animstate", "animstatedirty")

		if common_postinit then
			common_postinit(inst)
		end

		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			inst:ListenForEvent("animstatedirty", OnAnimState_Client)

			return inst
		end

		inst:AddComponent("inspectable")

		inst:AddComponent("inventoryitem")
		if invimg then
			inst.components.inventoryitem:ChangeImageName(invimg)
		end
		inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
		inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
		inst.components.inventoryitem.canonlygoinpocket = true

		inst.Network:SetClassifiedTarget(inst)
		inst._inittask = inst:DoTaskInTime(0, inst.Remove)

		inst.SetItemClassifiedOwner = SetItemClassifiedOwner

		OnDropped(inst)

		if master_postinit then
			master_postinit(inst)
		end

		return inst
	end

	return Prefab(name, fn, overrideassets or assets)
end

--------------------------------------------------------------------------

local function parts_master_postinit(inst)
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM
end

--------------------------------------------------------------------------

local function holotele_OnRecipeScanned(inst, data)
	if inst.components.inventoryitem:IsHeld() then
		inst:Remove()
	else
		if inst._killtask then
			inst._killtask:Cancel()
		end
		KillItem(inst)
	end
end

local function holotelepad_common_postinit(inst)
	inst.SCANNABLE_RECIPENAME = "winona_teleport_pad_item"
end

local function holotelebrella_common_postinit(inst)
	inst.SCANNABLE_RECIPENAME = "winona_telebrella"
end

local function holotele_master_postinit(inst)
	inst:ListenForEvent("onrecipescanned", holotele_OnRecipeScanned)
end

--------------------------------------------------------------------------

local function recipescanner_OnScanned(inst, target, doer, recipe)
	doer:PushEvent("learnrecipe", { teacher = inst, recipe = recipe })
	inst:Remove()
end

local function recipescanner_common_postinit(inst)
	--recipescanner (from recipescanner component) added to pristine state for optimization
	inst:AddTag("recipescanner")
end

local function recipescanner_master_postinit(inst)
	inst:AddComponent("recipescanner")
	inst.components.recipescanner:SetOnScannedFn(recipescanner_OnScanned)
end

--------------------------------------------------------------------------

return MakeHoloItem("winona_machineparts_1", "idle1", nil, nil, nil, nil, nil, parts_master_postinit),
	MakeHoloItem("winona_machineparts_2", "idle2", nil, nil, nil, nil, nil, parts_master_postinit),
	MakeHoloItem("winona_holotelepad", "wag_pad", nil, nil, -0.25, nil, holotelepad_common_postinit, holotele_master_postinit),
	MakeHoloItem("winona_holotelebrella", "wag_brella", nil, nil, nil, nil, holotelebrella_common_postinit, holotele_master_postinit),
	MakeHoloItem("winona_recipescanner", "radio", "wagstaff_tools_all", "wagstaff_tools", -0.3, "wagstaff_tool_5", recipescanner_common_postinit, recipescanner_master_postinit)
