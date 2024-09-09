require("prefabutil")

local assets =
{
	Asset("ANIM", "anim/winona_teleport_pad.zip"),
	Asset("ANIM", "anim/winona_teleport_pad_placement.zip"),
	Asset("ANIM", "anim/winona_battery_placement.zip"),
	Asset("ANIM", "anim/sparks.zip"),
}

local assets_item =
{
	Asset("ANIM", "anim/winona_teleport_pad.zip"),
}

local prefabs =
{
	"winona_battery_sparks",
	"collapse_small",
	"winona_teleport_pad_item",
}

local prefabs_item =
{
	"winona_teleport_pad",
}

local d = 2.25 / SQRT2
local BEACON_OFFSET = Vector3(-d, 0, -d)
d = 2.2 / SQRT2
local REDWIRE_OFFSET = Vector3(-d, 0, d)
local BLUEWIRE_OFFSET = Vector3(d, 0, -d)
d = nil

--------------------------------------------------------------------------

local PLACER_SCALE = 1.5

local function OnUpdatePlacerHelper(helperinst)
	if not helperinst.placerinst:IsValid() then
		helperinst.components.updatelooper:RemoveOnUpdateFn(OnUpdatePlacerHelper)
		helperinst.AnimState:SetAddColour(0, 0, 0, 0)
	else
		local range = TUNING.WINONA_BATTERY_RANGE - TUNING.WINONA_TELEPORT_PAD_FOOTPRINT
		local hx, hy, hz = helperinst.Transform:GetWorldPosition()
		local px, py, pz = helperinst.placerinst.Transform:GetWorldPosition()
		--<= match circuitnode FindEntities range tests
		if distsq(hx, hz, px, pz) <= range * range and TheWorld.Map:GetPlatformAtPoint(hx, hz) == TheWorld.Map:GetPlatformAtPoint(px, pz) then
			helperinst.AnimState:SetAddColour(helperinst.placerinst.AnimState:GetAddColour())
		else
			helperinst.AnimState:SetAddColour(0, 0, 0, 0)
		end
	end
end

local function CreatePlacerBatteryRing()
	local inst = CreateEntity()

	--[[Non-networked entity]]
	inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst:AddTag("CLASSIFIED")
	inst:AddTag("NOCLICK")
	inst:AddTag("placer")

	inst.AnimState:SetBank("winona_teleport_pad_placement")
	inst.AnimState:SetBuild("winona_teleport_pad_placement")
	inst.AnimState:PlayAnimation("idle")
	inst.AnimState:SetMultColour(0x6e/255, 0x60/255, 0x45/255, 1)
	inst.AnimState:SetLightOverride(1)
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(1)
	inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

	return inst
end

local function OnEnableHelper(inst, enabled, recipename, placerinst)
	if enabled then
		if inst.helper == nil and inst:HasTag("HAMMER_workable") and not inst:HasTag("burnt") then
			inst.helper = CreatePlacerBatteryRing()
			inst.helper.entity:SetParent(inst.entity)
			if placerinst and (
				placerinst.prefab == "winona_battery_low_item_placer" or
				placerinst.prefab == "winona_battery_high_item_placer" or
				recipename == "winona_battery_low" or
				recipename == "winona_battery_high"
			) then
				inst.helper:AddComponent("updatelooper")
				inst.helper.components.updatelooper:AddOnUpdateFn(OnUpdatePlacerHelper)
				inst.helper.placerinst = placerinst
				OnUpdatePlacerHelper(inst.helper)
			end
		end
	elseif inst.helper ~= nil then
		inst.helper:Remove()
		inst.helper = nil
	end
end

local function OnStartHelper(inst)--, recipename, placerinst)
	if inst.AnimState:IsCurrentAnimation("pad_deploy") then
		inst.components.deployhelper:StopHelper()
	end
end

--------------------------------------------------------------------------

local function OnLedDirty(inst)
	if inst._led:value() then
		inst._beacon.AnimState:OverrideSymbol("beacon_off", "winona_teleport_pad", "beacon_on")
		inst._beacon.AnimState:SetSymbolBloom("beacon_off")
		inst._beacon.AnimState:SetSymbolLightOverride("beacon_off", 0.5)
		inst._beacon.AnimState:SetLightOverride(0.1)
	else
		inst._beacon.AnimState:ClearOverrideSymbol("beacon_off")
		inst._beacon.AnimState:ClearSymbolBloom("beacon_off")
		inst._beacon.AnimState:SetSymbolLightOverride("beacon_off", 0)
		inst._beacon.AnimState:SetLightOverride(0)
	end
end

local function SetLedEnabled(inst, enabled)
	inst._led:set(enabled)
	if not TheNet:IsDedicated() then
		OnLedDirty(inst)
	end
end

--------------------------------------------------------------------------

local function NotifyCircuitChanged(inst, node)
	node:PushEvent("engineeringcircuitchanged")
end

local function OnCircuitChanged(inst)
	--Notify other connected batteries
	inst.components.circuitnode:ForEachNode(NotifyCircuitChanged)
end

local function IsPowered(inst)
	return inst._powertask
end

local function SetPowered(inst, powered, duration)
	if not powered then
		if inst._powertask then
			inst._powertask:Cancel()
			inst._powertask = nil
		end
		SetLedEnabled(inst, false)
	else
		local waspowered = inst._powertask ~= nil
		local remaining = waspowered and GetTaskRemaining(inst._powertask) or 0
		if duration > remaining then
			if inst._powertask then
				inst._powertask:Cancel()
			end
			inst._powertask = inst:DoTaskInTime(duration, SetPowered, false)
			if not waspowered then
				SetLedEnabled(inst, true)
			end
		end
	end
end

--------------------------------------------------------------------------

local function SyncAnims(inst, anim, frame)
	local pushidle
	if anim == "pad_deploy" then
		inst._beacon.AnimState:PlayAnimation("beacon_deploy")
		inst._redwire.AnimState:PlayAnimation("wire_red_deploy")
		inst._bluewire.AnimState:PlayAnimation("wire_blue_deploy")
		pushidle = true
	elseif anim == "pad_hit" then
		inst._beacon.AnimState:PlayAnimation("beacon_hit")
		inst._redwire.AnimState:PlayAnimation("wire_red_hit")
		inst._bluewire.AnimState:PlayAnimation("wire_blue_hit")
		pushidle = true
	elseif anim == "pad_collapse_empty" then
		inst._beacon.AnimState:PlayAnimation("beacon_collapse")
		inst._redwire.AnimState:PlayAnimation("wire_red_collapse")
		inst._bluewire.AnimState:PlayAnimation("wire_blue_collapse")
	elseif anim == "pad_destroyed_empty" then
		inst._beacon.AnimState:PlayAnimation("beacon_hit")
		inst._redwire.AnimState:PlayAnimation("wire_red_hit")
		inst._bluewire.AnimState:PlayAnimation("wire_blue_hit")
		frame = 0
		ErodeAway(inst._beacon, 1)
		ErodeAway(inst._redwire, 1)
		ErodeAway(inst._bluewire, 1)
	elseif anim == "burnt" then
		inst._beacon.AnimState:PlayAnimation("beacon_burnt")
		inst._redwire.AnimState:PlayAnimation("wire_burnt")
		inst._bluewire.AnimState:PlayAnimation("wire_burnt")
		frame = 0
	else
		inst._beacon.AnimState:PlayAnimation("beacon_idle")
		inst._redwire.AnimState:PlayAnimation("wire_red")
		inst._bluewire.AnimState:PlayAnimation("wire_blue")
		frame = 0
	end

	if frame > 0 then
		inst._beacon.AnimState:SetFrame(frame)
		inst._redwire.AnimState:SetFrame(frame)
		inst._bluewire.AnimState:SetFrame(frame)
	end

	if pushidle then
		inst._beacon.AnimState:PushAnimation("beacon_idle", false)
		inst._redwire.AnimState:PushAnimation("wire_red", false)
		inst._bluewire.AnimState:PushAnimation("wire_blue", false)
	end
end

--V2C: -using PostUpdate because AnimState hasn't updated yet when OnSyncAnimsDirty is triggered
--     -NOTE: cannot remove PostUpdateFn during PostUpdate
local SYNC_ANIMS = { "pad_deploy", "pad_hit", "pad_collapse_empty", "pad_destroyed_empty", "burnt" }
local function PostUpdateSyncAnims(inst)
	if inst._updatingsyncanims then
		inst._updatingsyncanims = false

		for i, v in ipairs(SYNC_ANIMS) do
			if inst.AnimState:IsCurrentAnimation(v) then
				SyncAnims(inst, v, inst.AnimState:GetCurrentAnimationFrame())
				return
			end
		end
		SyncAnims(inst, nil, nil)
	end
end

local function OnSyncAnimsDirty(inst)
	if inst:HasTag("burnt") then
		if inst._updatingsyncanims ~= nil then
			inst._updatingsyncanims = nil
			inst.components.updatelooper:RemovePostUpdateFn(PostUpdateSyncAnims)
		end
		SyncAnims(inst, "burnt", nil)
	elseif inst._syncanims:value() then
		if inst._updatingsyncanims == nil then
			inst.components.updatelooper:AddPostUpdateFn(PostUpdateSyncAnims)
		end
		inst._updatingsyncanims = true
	else
		if inst._updatingsyncanims ~= nil then
			inst._updatingsyncanims = nil
			inst.components.updatelooper:RemovePostUpdateFn(PostUpdateSyncAnims)
		end
		SyncAnims(inst, nil, nil)
	end
end

local function PushSyncAnims(inst, anim)
	if not TheNet:IsDedicated() then
		SyncAnims(inst, anim, 0)
	end
	inst._syncanims:set_local(true)
	inst._syncanims:set(true)
end

local function OnBuilt2(inst, doer)
	inst:RemoveTag("NOCLICK")
	if not inst:HasTag("burnt") then
		inst.components.circuitnode:ConnectTo("engineeringbattery")
		if doer and doer:IsValid() then
			inst.components.circuitnode:ForEachNode(function(inst, node)
				node:OnUsedIndirectly(doer)
			end)
		end
	end
end

local function DoBuiltOrDeployed(inst, doer)
	if inst._inittask then
		inst._inittask:Cancel()
		inst._inittask = nil
	end
	inst.components.circuitnode:Disconnect()
	inst:AddTag("NOCLICK")
	SetPowered(inst, false)

	inst.AnimState:PlayAnimation("pad_deploy")
	inst.AnimState:PushAnimation("pad_idle", false)
	inst.SoundEmitter:PlaySound("meta4/winona_teleumbrella/telepad_deploy")
	inst:DoTaskInTime(8 * FRAMES, OnBuilt2, doer)

	PushSyncAnims(inst, "pad_deploy")
end

local function OnAnimOver(inst)
	inst._syncanims:set_local(false)
end

--------------------------------------------------------------------------

local function OnCollapse2(item)
	item._collapsetask:Cancel()
	item._collapsetask = nil
	item.components.inventoryitem:SetOnPutInInventoryFn(nil)
	item.Transform:SetNoFaced()
	item.AnimState:SetOrientation(ANIM_ORIENTATION.BillBoard)
	item.AnimState:SetLayer(LAYER_WORLD)
	item.AnimState:SetSortOrder(0)
	item.AnimState:PlayAnimation("pad_collapse_pst")
	item.AnimState:PushAnimation("idle_ground", false)
end

local function ChangeToItem(inst)
	local item = SpawnPrefab("winona_teleport_pad_item")
	item.Transform:SetPosition(inst.Transform:GetWorldPosition())
	item.Transform:SetRotation(inst.Transform:GetRotation())
	item.Transform:SetEightFaced()
	item.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	item.AnimState:SetLayer(LAYER_BACKGROUND)
	item.AnimState:SetSortOrder(2)
	item.AnimState:PlayAnimation("pad_collapse")
	item._collapsetask = item:DoTaskInTime(6 * FRAMES, OnCollapse2) --anim actually has 8 frames, acting as a mini-lag anim for clients
	item.components.inventoryitem:SetOnPutInInventoryFn(OnCollapse2)

	item.SoundEmitter:PlaySound("meta4/winona_teleumbrella/telepad_collapse")

	if inst._wired:value() then
		item.SoundEmitter:PlaySound("dontstarve/common/together/spot_light/electricity", nil, .5)
		SpawnPrefab("winona_battery_sparks").Transform:SetPosition(inst.Transform:GetWorldPosition())
	end
end

local function OnWorked(inst)
	inst.AnimState:PlayAnimation("pad_hit")
	inst.AnimState:PushAnimation("pad_idle", false)
	inst.SoundEmitter:PlaySound("dontstarve/common/together/catapult/hit")

	PushSyncAnims(inst, "pad_hit")
end

local function OnWorkFinished(inst)
	if inst.components.burnable then
		if inst.components.burnable:IsBurning() then
			inst.components.burnable:Extinguish()
		end
		inst.components.burnable.canlight = false
	end
	inst.components.lootdropper:DropLoot()

	if inst:IsAsleep() then
		inst:Remove()
		return
	end

	local fx = SpawnPrefab("collapse_small")
	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	fx:SetMaterial("wood")

	if inst._inittask then
		inst._inittask:Cancel()
		inst._inittask = nil
	end
	inst.components.circuitnode:Disconnect()
	inst.components.powerload:SetLoad(0)
	inst.components.workable:SetWorkable(false)
	inst:AddTag("NOCLICK")
	inst.persists = false
	SetPowered(inst, false)

	inst.OnEntitySleep = inst.Remove
	inst:DoTaskInTime(1, inst.Remove)
	inst.AnimState:PlayAnimation("pad_destroyed_empty")
	PushSyncAnims(inst, "pad_destroyed_empty")
end

local function OnWorkedBurnt(inst)
	inst.components.lootdropper:DropLoot()
	local fx = SpawnPrefab("collapse_small")
	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	fx:SetMaterial("wood")
	inst:Remove()
end

local function OnBurnt(inst)
	DefaultBurntStructureFn(inst)

	SetPowered(inst, false)

	inst:RemoveComponent("portablestructure")

	inst.components.workable:SetOnWorkCallback(nil)
	inst.components.workable:SetOnFinishCallback(OnWorkedBurnt)

	if inst._inittask then
		inst._inittask:Cancel()
		inst._inittask = nil
	end
	inst.components.circuitnode:Disconnect()
	inst.components.powerload:SetLoad(0)

	PushSyncAnims(inst, "burnt")
end

local function OnDismantle(inst)--, doer)
	ChangeToItem(inst)

	if inst:IsAsleep() then
		inst:Remove()
		return
	end

	if inst._inittask then
		inst._inittask:Cancel()
		inst._inittask = nil
	end
	inst.components.circuitnode:Disconnect()
	inst.components.powerload:SetLoad(0)
	inst.components.workable:SetWorkable(false)
	inst:AddTag("NOCLICK")
	if inst.components.burnable then
		if inst.components.burnable:IsBurning() then
			inst.components.burnable:Extinguish()
		end
		inst.components.burnable.canlight = false
	end
	inst.persists = false
	SetPowered(inst, false)

	inst.OnEntitySleep = inst.Remove
	inst:ListenForEvent("animover", inst.Remove)
	inst.AnimState:PlayAnimation("pad_collapse_empty")
	PushSyncAnims(inst, "pad_collapse_empty")
end

--------------------------------------------------------------------------

local function GetStatus(inst, viewer)
	local status = (inst:HasTag("burnt") and "BURNT")
		or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning() and "BURNING")
		or (not inst:IsPowered() and "OFF")
		or nil

    if status == nil and viewer ~= nil and viewer:HasTag("handyperson") then
        local skilltreeupdater = viewer.components.skilltreeupdater
        if skilltreeupdater == nil or not skilltreeupdater:IsActivated("winona_wagstaff_2") then
            return "MISSINGSKILL"
        end
    end

    return status
end

local function GetStatus_item(inst, viewer)
    if viewer ~= nil and viewer:HasTag("handyperson") then
        local skilltreeupdater = viewer.components.skilltreeupdater
        if skilltreeupdater == nil or not skilltreeupdater:IsActivated("winona_wagstaff_2") then
            return "MISSINGSKILL"
        end
    end

    return nil
end

local function AddBatteryPower(inst, power)
	SetPowered(inst, true, power)
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

local function OnWiredDirty(inst)
	if inst._redwire then
		inst._redwire:SetWireVisible(inst._wired:value())
	end
	if inst._bluewire then
		inst._bluewire:SetWireVisible(inst._wired:value())
	end
	if not POPULATING then
		if inst._redwire then
			inst._redwire:DoWireSparks()
		end
		if inst._bluewire then
			inst._bluewire:DoWireSparks()
		end
		if TheWorld.ismastersim then		
			inst.SoundEmitter:PlaySound("dontstarve/common/together/spot_light/electricity", nil, .5)
			if not inst:HasTag("burnt") then
				if inst._flash == nil then
					inst.components.updatelooper:AddOnUpdateFn(OnUpdateSparks)
				end
				inst._flash = 1
				OnUpdateSparks(inst)
			end
		end
	end
end

local function OnConnectCircuit(inst)--, node)
	if not inst._wired:value() then
		inst._wired:set(true)
		OnWiredDirty(inst)
	end
	OnCircuitChanged(inst)
end

local function OnDisconnectCircuit(inst)--, node)
	if inst.components.circuitnode:IsConnected() then
		OnCircuitChanged(inst)
	elseif inst._wired:value() then
		inst._wired:set(false)
		OnWiredDirty(inst)
		SetPowered(inst, false)
	end
end

--------------------------------------------------------------------------

local function OnSave(inst, data)
	if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
		data.burnt = true
	else
		data.power = inst._powertask ~= nil and math.ceil(GetTaskRemaining(inst._powertask) * 1000) or nil
	end
end

local function OnLoad(inst, data)
	if inst._inittask then
		inst._inittask:Cancel()
		inst._inittask = nil
	end
	if data and data.burnt then
		inst.components.burnable.onburnt(inst)
	else
		if data and data.power then
			AddBatteryPower(inst, math.max(2 * FRAMES, data.power / 1000))
		end
		--Enable connections, but leave the initial connection to batteries' OnPostLoad
		inst.components.circuitnode:ConnectTo(nil)
	end
end

local function OnInit(inst)
	inst._inittask = nil
	inst.components.circuitnode:ConnectTo("engineeringbattery")
end

--------------------------------------------------------------------------

local function OnColourChanged(inst, r, g, b, a)
	for i, v in ipairs(inst.highlightchildren) do
		v.AnimState:SetAddColour(r, g, b, a)
	end
end

local function CreateBeacon()
	local inst = CreateEntity()

	--[[Non-networked entity]]
	inst.entity:SetCanSleep(TheWorld.ismastersim)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst:AddTag("FX")

	inst.Transform:SetEightFaced()

	inst.AnimState:SetBank("winona_teleport_pad")
	inst.AnimState:SetBuild("winona_teleport_pad")
	inst.AnimState:PlayAnimation("beacon_idle")

	return inst	
end

local function SetWireVisible(inst, visible)
	if visible then
		inst.AnimState:ClearOverrideSymbol("wire_"..inst._colour)
	else
		--This will remove mouseover as well (rather than just :Hide("wire"))
		inst.AnimState:OverrideSymbol("wire_"..inst._colour, "winona_teleport_pad", "dummy")
	end
end

local function DoWireSparks(inst)
	local fx = CreateEntity()

	--[[Non-networked entity]]
	fx.entity:SetCanSleep(false)
	fx.persists = false

	fx.entity:AddTransform()
	fx.entity:AddAnimState()
	fx.entity:AddFollower()

	fx:AddTag("FX")
	fx:AddTag("NOCLICK")

	fx.AnimState:SetBank("sparks")
	fx.AnimState:SetBuild("sparks")
	fx.AnimState:PlayAnimation("sparks_"..tostring(math.random(3)))
	fx.AnimState:SetAddColour(1, 1, 0, 0)
	fx.AnimState:SetLightOverride(0.3)

	fx:ListenForEvent("animover", fx.Remove)

	fx.Follower:FollowSymbol(inst.GUID, "wire_"..inst._colour)
end

local function CreateWire(colour)
	local inst = CreateEntity()

	--[[Non-networked entity]]
	inst.entity:SetCanSleep(TheWorld.ismastersim)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst:AddTag("FX")

	inst.Transform:SetEightFaced()

	inst.AnimState:SetBank("winona_teleport_pad")
	inst.AnimState:SetBuild("winona_teleport_pad")
	inst.AnimState:PlayAnimation("wire_"..colour)

	inst._colour = colour
	inst.SetWireVisible = SetWireVisible
	inst.DoWireSparks = DoWireSparks

	inst:SetWireVisible(false)

	return inst	
end

--------------------------------------------------------------------------

local function OnRemoteTeleportReceived(inst, data)
	local share = 0
	inst.components.circuitnode:ForEachNode(function(inst, node)
		if node.components.fueled and not node.components.fueled:IsEmpty() and not (node.IsOverloaded and node:IsOverloaded()) then
			share = share + 1
		end
	end)

	if share > 0 then
		local fuelscale = 1
		local shardscale = 1
		if data.from_x then
			local x, y, z = inst.Transform:GetWorldPosition()
			local k = math.min(1, math.sqrt(distsq(data.from_x, data.from_z, x, z)) / 1200)
			fuelscale = k * k
			shardscale = 1 - k
			shardscale = 1 - shardscale * shardscale * shardscale
		end

		local mincost = TUNING.WINONA_TELEPORT_PAD_POWER_COST_MIN
		local maxcost = TUNING.WINONA_TELEPORT_PAD_POWER_COST_MAX
		local cost = { fuel = Lerp(mincost.fuel, maxcost.fuel, fuelscale), shard = Lerp(mincost.shard, maxcost.shard, shardscale) }
		local doer = data and data.doer or nil
		inst.components.circuitnode:ForEachNode(function(inst, node)
			node:ConsumeBatteryAmount(cost, share, doer)
		end)
	end
end

--------------------------------------------------------------------------

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.LARGE] / 2)

	inst:AddTag("engineering")
	inst:AddTag("engineeringbatterypowered")
	inst:AddTag("structure")

	inst.Transform:SetEightFaced()

	inst.AnimState:SetBank("winona_teleport_pad")
	inst.AnimState:SetBuild("winona_teleport_pad")
	inst.AnimState:PlayAnimation("pad_idle")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3)

	inst.MiniMapEntity:SetIcon("winona_teleport_pad.png")

	inst._wired = net_bool(inst.GUID, "winona_teleport_pad._wired", "wireddirty")
	inst._syncanims = net_bool(inst.GUID, "winona_teleport_pad._syncanims", "syncanimsdirty")
	inst._led = net_bool(inst.GUID, "winona_teleport_pad._led", "leddirty")

	inst:AddComponent("updatelooper")
	inst:AddComponent("colouraddersync")

	--Dedicated server does not need deployhelper
	--Dedicated server does not need to spawn the local fx
	if not TheNet:IsDedicated() then
		inst:AddComponent("deployhelper")
		inst.components.deployhelper:AddRecipeFilter("winona_spotlight")
		inst.components.deployhelper:AddRecipeFilter("winona_catapult")
		inst.components.deployhelper:AddRecipeFilter("winona_battery_low")
		inst.components.deployhelper:AddRecipeFilter("winona_battery_high")
		inst.components.deployhelper:AddKeyFilter("winona_battery_engineering")
		inst.components.deployhelper.onenablehelper = OnEnableHelper
		inst.components.deployhelper.onstarthelper = OnStartHelper

		inst._beacon = CreateBeacon()
		inst._beacon.entity:SetParent(inst.entity)
		inst._beacon.Transform:SetPosition(BEACON_OFFSET:Get())
		inst._beacon.Transform:SetRotation(-45)

		inst._redwire = CreateWire("red")
		inst._redwire.entity:SetParent(inst.entity)
		inst._redwire.Transform:SetPosition(REDWIRE_OFFSET:Get())
		inst._redwire.Transform:SetRotation(-135)

		inst._bluewire = CreateWire("blue")
		inst._bluewire.entity:SetParent(inst.entity)
		inst._bluewire.Transform:SetPosition(BLUEWIRE_OFFSET:Get())
		inst._bluewire.Transform:SetRotation(45)

		inst.highlightchildren = { inst._beacon, inst._redwire, inst._bluewire }

		inst.components.colouraddersync:SetColourChangedFn(OnColourChanged)
	end

	--inst.scrapbook_specialinfo = "WINONASPOTLIGHT"

	inst:SetPrefabNameOverride("winona_teleport_pad_item")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		inst:ListenForEvent("wireddirty", OnWiredDirty)
		inst:ListenForEvent("syncanimsdirty", OnSyncAnimsDirty)
		inst:ListenForEvent("leddirty", OnLedDirty)

		return inst
	end

	inst:AddComponent("portablestructure")
	inst.components.portablestructure:SetOnDismantleFn(OnDismantle)

	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = GetStatus

	inst:AddComponent("colouradder")

	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnWorkCallback(OnWorked)
	inst.components.workable:SetOnFinishCallback(OnWorkFinished)

	inst:AddComponent("savedrotation")

	inst:AddComponent("circuitnode")
	inst.components.circuitnode:SetRange(TUNING.WINONA_BATTERY_RANGE - TUNING.WINONA_TELEPORT_PAD_FOOTPRINT + TUNING.WINONA_ENGINEERING_FOOTPRINT)
	inst.components.circuitnode:SetFootprint(TUNING.WINONA_TELEPORT_PAD_FOOTPRINT)
	inst.components.circuitnode:SetOnConnectFn(OnConnectCircuit)
	inst.components.circuitnode:SetOnDisconnectFn(OnDisconnectCircuit)
	inst.components.circuitnode.connectsacrossplatforms = false
	inst.components.circuitnode.rangeincludesfootprint = true

	inst:AddComponent("powerload")
	inst.components.powerload:SetLoad(TUNING.WINONA_TELEPORT_PAD_POWER_LOAD_IDLE, true)

	inst:ListenForEvent("engineeringcircuitchanged", OnCircuitChanged)
	inst:ListenForEvent("remoteteleportreceived", OnRemoteTeleportReceived)
	inst:ListenForEvent("animover", OnAnimOver)

	MakeHauntableWork(inst)
	MakeLargeBurnable(inst, 20, nil, true)
	MakeMediumPropagator(inst)
	inst.components.burnable:SetOnBurntFn(OnBurnt)

	inst.OnLoad = OnLoad
	inst.OnSave = OnSave
	inst.AddBatteryPower = AddBatteryPower
	inst.IsPowered = IsPowered

	inst._flash = nil
	inst._inittask = inst:DoTaskInTime(0, OnInit)
    TheWorld:PushEvent("ms_registerwinonateleportpad", inst)

	return inst
end

--------------------------------------------------------------------------

local function placer_postinit_fn(inst)
	--Add the decor
	--Also add the small battery range indicator

	local beacon = CreateBeacon()
	beacon.entity:SetParent(inst.entity)
	beacon.Transform:SetPosition(BEACON_OFFSET:Get())
	beacon.Transform:SetRotation(-45)
	inst.components.placer:LinkEntity(beacon)

	local redwire = CreateWire("red")
	redwire.entity:SetParent(inst.entity)
	redwire.Transform:SetPosition(REDWIRE_OFFSET:Get())
	redwire.Transform:SetRotation(-135)
	inst.components.placer:LinkEntity(redwire)

	local bluewire = CreateWire("blue")
	bluewire.entity:SetParent(inst.entity)
	bluewire.Transform:SetPosition(BLUEWIRE_OFFSET:Get())
	bluewire.Transform:SetRotation(45)
	inst.components.placer:LinkEntity(bluewire)

	local placer2 = CreatePlacerBatteryRing()
	placer2.entity:SetParent(inst.entity)
	inst.components.placer:LinkEntity(placer2)

	inst.deployhelper_key = "winona_battery_engineering"
	inst.engineering_footprint_override = TUNING.WINONA_TELEPORT_PAD_FOOTPRINT
end

--------------------------------------------------------------------------

local function OnDeploy(inst, pt, deployer, rot)
	local obj = SpawnPrefab("winona_teleport_pad")
	if obj then
		obj.Transform:SetPosition(pt.x, 0, pt.z)
		obj.Transform:SetRotation(rot)
		DoBuiltOrDeployed(obj, deployer)
	end
	inst:Remove()
end

local function itemfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("winona_teleport_pad")
	inst.AnimState:SetBuild("winona_teleport_pad")
	inst.AnimState:PlayAnimation("idle_ground")
	inst.scrapbook_anim = "idle_ground"

	inst:AddTag("portableitem")

	MakeInventoryFloatable(inst, "large", 0.37, { 0.56, 0.91, 1 })

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = GetStatus_item
	inst:AddComponent("inventoryitem")

	inst:AddComponent("deployable")
	inst.components.deployable.restrictedtag = "handyperson"
	inst.components.deployable.ondeploy = OnDeploy
	inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.LARGE)

	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HUANT_TINY)

	MakeMediumBurnable(inst)
	MakeMediumPropagator(inst)

	return inst
end

--------------------------------------------------------------------------

return Prefab("winona_teleport_pad", fn, assets, prefabs),
	MakePlacer("winona_teleport_pad_item_placer", "winona_teleport_pad", "winona_teleport_pad", "pad_idle", true, nil, nil, nil, 45, "eight", placer_postinit_fn),
	Prefab("winona_teleport_pad_item", itemfn, assets_item, prefabs_item)
