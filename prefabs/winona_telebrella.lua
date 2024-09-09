local assets =
{
	Asset("ANIM", "anim/winona_telebrella.zip"),
}

local prefabs =
{
	"winona_battery_sparks",
	"winona_telebrella_swap_fx",
}

local PHYSICS_RADIUS = 0.5

local function RefreshAttunedSkills(inst, owner)
	local enabled = owner.components.skilltreeupdater ~= nil and owner.components.skilltreeupdater:IsActivated("winona_wagstaff_2")
	inst.swapfx:SetLedEnabled(enabled)
	inst.swapfx2:SetLedEnabled(enabled)
end

local function SetFxOwner(inst, owner)
	if inst.swapfx then
		inst.swapfx:Remove()
		inst.swapfx2:Remove()
		inst.swapfx = nil
		inst.swapfx2 = nil
	end
	if owner then
		inst.swapfx = SpawnPrefab("winona_telebrella_swap_fx")
		inst.swapfx.entity:SetParent(owner.entity)
		inst.swapfx.Follower:FollowSymbol(owner.GUID, "swap_object", nil, nil, nil, true, nil, 0, 19)
		inst.swapfx.components.highlightchild:SetOwner(owner)

		inst.swapfx2 = SpawnPrefab("winona_telebrella_swap_fx")
		inst.swapfx2.entity:SetParent(owner.entity)
		inst.swapfx2.Follower:FollowSymbol(owner.GUID, "swap_object", nil, nil, nil, true, nil, 19)
		inst.swapfx2.components.highlightchild:SetOwner(owner)
		inst.swapfx2.AnimState:PlayAnimation("swap20")

		if owner.components.colouradder then
			owner.components.colouradder:AttachChild(inst.swapfx)
			owner.components.colouradder:AttachChild(inst.swapfx2)
		end
		if not (owner.components.skilltreeupdater and owner.components.skilltreeupdater:IsActivated("winona_wagstaff_2")) then
			inst.swapfx:SetLedEnabled(false)
			inst.swapfx2:SetLedEnabled(false)
		end
		inst.swapfx:ListenForEvent("onactivateskill_server", inst._onskillrefresh, owner)
		inst.swapfx:ListenForEvent("ondeactivateskill_server", inst._onskillrefresh, owner)
	end
end

local function OnEquip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "winona_telebrella", "swap_winona_telebrella")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")

	owner.DynamicShadow:SetSize(2.2, 1.4)
	SetFxOwner(inst, owner)

	inst.components.fueled:StartConsuming()
end

local function OnUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")

	owner.DynamicShadow:SetSize(1.3, 0.6)
	SetFxOwner(inst, nil)

	inst.components.fueled:StopConsuming()
end

local function OnEquipToModel(inst, owner, from_ground)
	inst.components.fueled:StopConsuming()
end

local function OnDepleted(inst)
	if inst.components.equippable then
		if inst.components.equippable:IsEquipped() then
			local owner = inst.components.inventoryitem.owner
			if owner and owner.components.inventory then
				local item = owner.components.inventory:Unequip(inst.components.equippable.equipslot)
				if item then
					owner.components.inventory:GiveItem(item, nil, owner:GetPosition())
				end
			end
		end
		inst:RemoveComponent("equippable")
	end
end

local function OnSectionChanged(newsection, oldsection, inst)
	if oldsection == 0 then
		if inst.components.equippable == nil then
			inst:AddComponent("equippable")
			inst.components.equippable:SetOnEquip(OnEquip)
			inst.components.equippable:SetOnUnequip(OnUnequip)
			inst.components.equippable:SetOnEquipToModel(OnEquipToModel)
		end
	elseif newsection == 0 and inst.components.equippable then
		if inst.components.equippable:IsEquipped() then
			local owner = inst.components.inventoryitem.owner
			if owner and owner.components.inventory then
				local item = owner.components.inventory:Unequip(inst.components.equippable.equipslot)
				if item then
					owner.components.inventory:GiveItem(item, nil, owner:GetPosition())
				end
			end
		end
		inst:RemoveComponent("equippable")
	end
end

local function SetLedEnabled(inst, enabled)
	if enabled then
		inst.AnimState:OverrideSymbol("led_off", "winona_telebrella", "led_on")
		inst.AnimState:SetSymbolBloom("led_off")
		inst.AnimState:SetSymbolLightOverride("led_off", 0.5)
		inst.AnimState:SetSymbolLightOverride("antenna", 0.3)
		inst.AnimState:SetSymbolLightOverride("canopy_closed", 0.06)
	else
		inst.AnimState:ClearOverrideSymbol("led_off")
		inst.AnimState:ClearSymbolBloom("led_off")
		inst.AnimState:SetSymbolLightOverride("led_off", 0)
		inst.AnimState:SetSymbolLightOverride("antenna", 0)
		inst.AnimState:SetSymbolLightOverride("canopy_closed", 0)
	end
end

local function OnUpdateChargingFuel(inst)
	if inst.components.fueled:IsFull() then
		inst.components.fueled:StopConsuming()
	end
end

local function SetCharging(inst, powered, duration)
	if not powered then
		if inst._powertask then
			inst._powertask:Cancel()
			inst._powertask = nil
			inst.components.fueled:StopConsuming()
			inst.components.fueled.rate = 1
			inst.components.fueled:SetUpdateFn(nil)
			inst.components.powerload:SetLoad(0)
			SetLedEnabled(inst, false)
		end
	else
		local waspowered = inst._powertask ~= nil
		local remaining = waspowered and GetTaskRemaining(inst._powertask) or 0
		if duration > remaining then
			if inst._powertask then
				inst._powertask:Cancel()
			end
			inst._powertask = inst:DoTaskInTime(duration, SetCharging, false)
			if not waspowered then
				inst.components.fueled.rate = TUNING.WINONA_TELEBRELLA_RECHARGE_RATE * (inst._quickcharge and TUNING.SKILLS.WINONA.QUICKCHARGE_MULT or 1)
				inst.components.fueled:SetUpdateFn(OnUpdateChargingFuel)
				inst.components.fueled:StartConsuming()
				inst.components.powerload:SetLoad(TUNING.WINONA_TELEBRELLA_POWER_LOAD_CHARGING)
				SetLedEnabled(inst, true)
			end
		end
	end
end

local function OnPutInInventory(inst, owner)
	if inst._inittask then
		inst._inittask:Cancel()
		inst._inittask = nil
	end
	inst._landed_owner = nil
	inst._owner = owner
	inst._quickcharge = false
	inst.components.circuitnode:Disconnect()
end

local function OnDropped(inst)
	if inst._owner then
		if inst._owner.components.skilltreeupdater and
			inst._owner.components.skilltreeupdater:IsActivated("winona_gadget_recharge") and
			not (inst._owner.components.health and inst._owner.components.health:IsDead() or inst._owner:HasTag("playerghost"))
		then
			inst._quickcharge = true
		end
		inst._landed_owner = inst._owner
		inst._owner = nil
	end

	if inst.components.inventoryitem.is_landed then
		inst.components.circuitnode:ConnectTo("engineeringbattery")
		if inst._landed_owner then
			inst.components.circuitnode:ForEachNode(function(inst, node)
				node:OnUsedIndirectly(inst._landed_owner)
			end)
			inst._landed_owner = nil
		end
	else
		inst.components.circuitnode:Disconnect()
	end
end

local function OnNoLongerLanded(inst)
	inst.components.circuitnode:Disconnect()
end

local function OnLanded(inst)
	if not (inst.components.circuitnode:IsEnabled() or inst.components.inventoryitem:IsHeld()) then
		inst.components.circuitnode:ConnectTo("engineeringbattery")
		if inst._landed_owner and inst._landed_owner:IsValid() then
			inst.components.circuitnode:ForEachNode(function(inst, node)
				node:OnUsedIndirectly(inst._landed_owner)
			end)
		end
	end
	inst._landed_owner = nil
end

local function OnSave(inst, data)
	data.power = inst._powertask and math.ceil(GetTaskRemaining(inst._powertask) * 1000) or nil

	--skilltree
	data.quickcharge = inst._quickcharge or nil
end

local function OnLoad(inst, data)--, newents)
	if inst._inittask then
		inst._inittask:Cancel()
		inst._inittask = nil
	end

	--skilltree
	inst._quickcharge = data and data.quickcharge or false

	if data and data.power then
		inst:AddBatteryPower(math.max(2 * FRAMES, data.power / 1000))
	else
		SetCharging(inst, false)
	end
	--Enable connections, but leave the initial connection to batteries' OnPostLoad
	inst.components.circuitnode:ConnectTo(nil)
end

local function OnInit(inst)
	inst._inittask = nil
	inst.components.circuitnode:ConnectTo("engineeringbattery")
end

--------------------------------------------------------------------------

local function CanActivate(inst, doer)
	if not (doer.components.skilltreeupdater and doer.components.skilltreeupdater:IsActivated("winona_wagstaff_2")) then
		return false, "NOSKILL"
	end
	return true
end

local function CheckDestination(inst, dest, doer)
	return dest.IsPowered ~= nil and dest:IsPowered()
end

local function OnStartTeleport(inst, doer)
	inst.components.fueled:StopConsuming()
end

local function OnTeleported(inst, doer, success)--, target, items, from_x, from_Z)
	local amt = inst.components.fueled.currentfuel
	if amt > 0.00001 then
		amt = math.min(TUNING.WINONA_TELEBRELLA_TELEPORT_FUEL, amt - 0.00001)
		inst.components.fueled:DoDelta(-amt)
	end
end

local function OnStopTeleport(inst, doer, success)
	if inst.components.fueled.currentfuel < 0.000011 then
		inst.components.fueled:DoDelta(-1)
	else
		inst.components.fueled:StartConsuming()
	end
end

--------------------------------------------------------------------------

local function GetStatus(inst, viewer)
	local status = (inst._powertask and "CHARGING")
		or (inst.components.circuitnode:IsConnected() and inst.components.fueled:IsFull() and "CHARGED")
		or (inst.components.fueled:IsEmpty() and "OFF")
		or nil

    if status == nil and viewer ~= nil and viewer:HasTag("handyperson") then
        local skilltreeupdater = viewer.components.skilltreeupdater
        if skilltreeupdater == nil or not skilltreeupdater:IsActivated("winona_wagstaff_2") then
            return "MISSINGSKILL"
        end
    end

    return status
end

local function AddBatteryPower(inst, power)
	if inst.components.fueled:IsFull() then
		SetCharging(inst, false)
	else
		SetCharging(inst, true, power)
	end
end

local function OnUpdateSparks(inst)
	if inst._flash > 0 then
		local k = inst._flash * inst._flash
		inst.components.colouradder:PushColour("wiresparks", .3 * k, .3 * k, 0, 0)
		inst._flash = inst._flash - .15
	else
		inst.components.colouradder:PopColour("wiresparks")
		inst._flash = nil
		inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateSparks)
	end
end

local function DoWireSparks(inst)
	inst.SoundEmitter:PlaySound("dontstarve/common/together/spot_light/electricity", nil, .5)
	SpawnPrefab("winona_battery_sparks").entity:AddFollower():FollowSymbol(inst.GUID, "wire", 0, 0, 0)
	if inst.components.updatelooper then
		if inst._flash == nil then
			inst.components.updatelooper:AddOnUpdateFn(OnUpdateSparks)
		end
		inst._flash = 1
		OnUpdateSparks(inst)
	end
end

local function NotifyCircuitChanged(inst, node)
	node:PushEvent("engineeringcircuitchanged")
end

local function OnCircuitChanged(inst)
	--Notify other connected batteries
	inst.components.circuitnode:ForEachNode(NotifyCircuitChanged)
end

local function OnConnectCircuit(inst)--, node)
	if not inst._wired then
		inst._wired = true
		inst.AnimState:ClearOverrideSymbol("wire")
		if not POPULATING then
			DoWireSparks(inst)
		end
	end
	OnCircuitChanged(inst)
end

local function OnDisconnectCircuit(inst)--, node)
	if inst.components.circuitnode:IsConnected() then
		OnCircuitChanged(inst)
	elseif inst._wired then
		inst._wired = nil
		--This will remove mouseover as well (rather than just :Hide("wire"))
		inst.AnimState:OverrideSymbol("wire", "winona_storage_robot", "dummy")
		DoWireSparks(inst)
		SetCharging(inst, false)
	end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("winona_telebrella")
	inst.AnimState:SetBuild("winona_telebrella")
	inst.AnimState:PlayAnimation("idle")
	--This will remove mouseover as well (rather than just :Hide("wire"))
	inst.AnimState:OverrideSymbol("wire", "winona_telebrella", "dummy")

	inst:AddTag("nopunch")
	inst:AddTag("umbrella")
	inst:AddTag("metal")
	inst:AddTag("engineering")
	inst:AddTag("engineeringbatterypowered")

	--waterproofer (from waterproofer component) added to pristine state for optimization
	inst:AddTag("waterproofer")

	MakeInventoryFloatable(inst, "large")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.components.floater:SetScale({ .75, 0.6, -0.5 })
	inst.components.floater:SetBankSwapOnFloat(true, -23, { sym_name = "swap_winona_telebrella_float", sym_build = "winona_telebrella" })

	inst:AddComponent("updatelooper")
	inst:AddComponent("colouradder")

	inst:AddComponent("tradable")

	inst:AddComponent("waterproofer")
	inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALLMED)

	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = GetStatus

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
	inst.components.inventoryitem:SetOnDroppedFn(OnDropped)

	MakeHauntableLaunch(inst)

	inst:AddComponent("remoteteleporter")
	inst.components.remoteteleporter:SetCanActivateFn(CanActivate)
	inst.components.remoteteleporter:SetCheckDestinationFn(CheckDestination)
	inst.components.remoteteleporter:SetOnStartTeleportFn(OnStartTeleport)
	inst.components.remoteteleporter:SetOnTeleportedFn(OnTeleported)
	inst.components.remoteteleporter:SetOnStopTeleportFn(OnStopTeleport)
    inst.components.remoteteleporter:SetItemTeleportRadius(1.84)

	inst:AddComponent("circuitnode")
	inst.components.circuitnode:SetRange(TUNING.WINONA_BATTERY_RANGE)
	inst.components.circuitnode:SetFootprint(0)
	inst.components.circuitnode:SetOnConnectFn(OnConnectCircuit)
	inst.components.circuitnode:SetOnDisconnectFn(OnDisconnectCircuit)
	inst.components.circuitnode.connectsacrossplatforms = false
	inst.components.circuitnode.rangeincludesfootprint = false

	inst:AddComponent("powerload")
	inst.components.powerload:SetLoad(0)

	inst:ListenForEvent("engineeringcircuitchanged", OnCircuitChanged)
	inst:ListenForEvent("on_no_longer_landed", OnNoLongerLanded)
	inst:ListenForEvent("on_landed", OnLanded)

	inst:AddComponent("fueled")
	inst.components.fueled.fueltype = FUELTYPE.MAGIC
	inst.components.fueled.rate = 1
	inst.components.fueled:SetSectionCallback(OnSectionChanged)	
	inst.components.fueled:InitializeFuelLevel(TUNING.WINONA_TELEBRELLA_MAX_FUEL_TIME) --last, since triggers section callback

	inst.AddBatteryPower = AddBatteryPower
	inst.OnSave = OnSave
	inst.OnLoad = OnLoad

	--skilltree
	inst._quickcharge = false
	inst._onskillrefresh = function(owner) RefreshAttunedSkills(inst, owner) end

	inst._wired = nil
	inst._inittask = inst:DoTaskInTime(0, OnInit)

	return inst
end

local function FX_SetLedEnabled(inst, enabled)
	if enabled then
		inst.AnimState:ClearOverrideSymbol("led_on")
		inst.AnimState:SetSymbolBloom("led_on")
		inst.AnimState:SetSymbolLightOverride("led_on", 0.5)
		inst.AnimState:SetSymbolLightOverride("antenna", 0.3)
		inst.AnimState:SetSymbolLightOverride("canopy_open_front", 0.08)
	else
		inst.AnimState:OverrideSymbol("led_on", "winona_telebrella", "led_off")
		inst.AnimState:ClearSymbolBloom("led_on")
		inst.AnimState:SetSymbolLightOverride("led_on", 0)
		inst.AnimState:SetSymbolLightOverride("antenna", 0)
		inst.AnimState:SetSymbolLightOverride("canopy_open_front", 0)
	end
end

local function fxfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()
	inst.entity:AddNetwork()

	inst:AddTag("FX")

	inst.AnimState:SetBank("winona_telebrella")
	inst.AnimState:SetBuild("winona_telebrella")
	inst.AnimState:PlayAnimation("swap1")
	inst.AnimState:SetSymbolBloom("led_on")
	inst.AnimState:SetSymbolLightOverride("led_on", 0.5)
	inst.AnimState:SetSymbolLightOverride("antenna", 0.3)
	inst.AnimState:SetSymbolLightOverride("canopy_open_front", 0.08)

	inst:AddComponent("highlightchild")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("colouradder")

	inst.SetLedEnabled = FX_SetLedEnabled

	inst.persists = false

	return inst
end

return Prefab("winona_telebrella", fn, assets, prefabs),
	Prefab("winona_telebrella_swap_fx", fxfn, assets)
