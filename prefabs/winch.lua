require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/boat_winch.zip"),
}

local prefabs =
{
    "collapse_small",
}

sounds =
{
	place = "hookline_2/common/boat_winch/place",

	reel_slow = "hookline_2/common/boat_winch/raise_LP",
	reel_fast = "hookline_2/common/boat_winch/lower_LP",

	claw_hit_bottom = "turnoftides/common/together/boat/anchor/ocean_hit",
	claw_hit_item = "turnoftides/common/together/boat/anchor/ocean_hit_statue",

	pull_pst = "hookline_2/common/boat_winch/pull_pst",
	drop_ground_pre = "hookline_2/common/boat_winch/drop_ground_pre",
	drop_ground_pst = "hookline_2/common/boat_winch/drop_ground_pst",
	drop_water_pre = "hookline_2/common/boat_winch/drop_water_pre",
}

local CLAW_CATCHING_RADIUS = 2.5
local CLAW_CATCHING_ALMOST_SUCCESS_THRESHOLD = 2

local RAISE_CLAW_DELAY_SUCCESS = 0.45
local RAISE_CLAW_DELAY_FAILURE = 0.3

-- Depth tested against from the winch component is clamped to never go below
-- this value, ensuring that lowering the claw always takes at least a certain
-- amount of time. This prevents the pre-lower anim from getting cut off at
-- shallow water without having to reduce the actual lowering speed.
local PERCEIVED_DEPTH_MINIMUM = 2.8

local function GetHeldItem(inst)
	return inst.components.inventory ~= nil and inst.components.inventory:GetItemInSlot(1) or nil
end

local function dropitems(inst)
	local item = GetHeldItem(inst)
	if item ~= nil then
		inst.components.inventory:DropItem(item)
		if not inst:HasTag("takeshelfitem") and inst:GetCurrentPlatform() ~= nil then
			item:PushEvent("onsink")
		end

		return item
	end
end

local function on_hammered(inst, hammerer)
    inst.components.lootdropper:DropLoot()
	dropitems(inst)

    local collapse_fx = SpawnPrefab("collapse_small")
    collapse_fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    collapse_fx:SetMaterial("wood")

	local boat = inst:GetCurrentPlatform()
	if boat ~= nil then
		boat:PushEvent("spawnnewboatleak", { pt = inst:GetPosition(), leak_size = "med_leak", playsoundfx = true })
	end

    inst:Remove()
end

local function onhit(inst)
    inst:PushEvent("workinghit")
end

local CLAW_TARGET_MUST_TAGS = {"underwater_salvageable"}
local function raise_claw(inst, delay)
	delay = delay or 0

	if inst._raise_claw_task ~= nil then
		inst._raise_claw_task:Cancel()
	end

	inst._raise_claw_task = inst:DoTaskInTime(delay, function()
		if GetHeldItem(inst) == nil and FindEntity(inst, CLAW_CATCHING_RADIUS + CLAW_CATCHING_ALMOST_SUCCESS_THRESHOLD, nil, CLAW_TARGET_MUST_TAGS) ~= nil then
			if inst._most_recent_interacting_player ~= nil and inst._most_recent_interacting_player:IsValid() and inst._most_recent_interacting_player.components.talker ~= nil and
				inst._most_recent_interacting_player:GetCurrentPlatform() == inst:GetCurrentPlatform() then

				inst._most_recent_interacting_player.components.talker:Say(GetString(inst._most_recent_interacting_player, "ANNOUNCE_WINCH_CLAW_MISS"))
			end
		end

		inst.components.winch:StartRaising()
	end)
end

local function turn_off_boat_drag(inst)
	if inst._boat_drag_task ~= nil then
		inst._boat_drag_task:Cancel()
		inst._boat_drag_task = nil
	end

	local boat = inst:GetCurrentPlatform()
	if boat ~= nil and boat.components.boatphysics ~= nil then
		boat.components.boatphysics:RemoveBoatDrag(inst)
	end
end

local function turn_on_boat_drag(inst, boat, duration)
	boat = boat
	if boat == nil then
		return nil
	end

	if boat.components.boatphysics ~= nil then
		boat.components.boatphysics:AddBoatDrag(inst)
	end

	if inst._boat_drag_task ~= nil then
		inst._boat_drag_task:Cancel()
	end
	if duration ~= nil then
		inst._boat_drag_task = inst:DoTaskInTime(duration, turn_off_boat_drag)
	end
end

local CLAW_CATCH_MUST_TAGS = {"winchtarget"}
local function OnFullyLowered(inst)
	local boat = inst:GetCurrentPlatform()

	local salvaged_item = nil
	if GetHeldItem(inst) == nil then
		if boat ~= nil then
			local salvageable = FindEntity(inst, CLAW_CATCHING_RADIUS, nil, CLAW_CATCH_MUST_TAGS, nil)
			if salvageable ~= nil then
				salvaged_item = salvageable.components.winchtarget:Salvage()
				
				if salvaged_item ~= nil then
					inst.components.inventory:GiveItem(salvaged_item)
					salvaged_item:PushEvent("on_salvaged")

					turn_on_boat_drag(inst, boat, TUNING.BOAT_WINCH.BOAT_DRAG_DURATION)
				end

				salvageable:Remove()			
			end
		end

		if salvaged_item ~= nil then
			raise_claw(inst, RAISE_CLAW_DELAY_SUCCESS)
		else
			raise_claw(inst, RAISE_CLAW_DELAY_FAILURE)
		end
	else
		raise_claw(inst)
	end

	if boat then
		if salvaged_item ~= nil then
			inst.SoundEmitter:PlaySound(inst.sounds.claw_hit_item)
			ShakeAllCamerasOnPlatform(CAMERASHAKE.VERTICAL, 0.3, 0.015, 0.5, boat)
		else
			inst.SoundEmitter:PlaySound(inst.sounds.claw_hit_bottom)
			ShakeAllCamerasOnPlatform(CAMERASHAKE.VERTICAL, 0.1, 0.01, 0.1, boat)
		end
	end
end

local function OnLoweringUpdate(inst)
	local salvageable = FindEntity(inst, CLAW_CATCHING_RADIUS, nil, CLAW_CATCH_MUST_TAGS, nil)
	if salvageable ~= nil then
		local depth = salvageable.components.winchtarget.depth

		if depth > 0 and inst.components.winch.line_length >= depth then
			local salvaged_item = salvageable.components.winchtarget:Salvage()
				
			if salvaged_item ~= nil then
				inst.components.inventory:GiveItem(salvaged_item)
				salvaged_item:PushEvent("on_salvaged")
			end

			salvageable:Remove()

			ShakeAllCamerasOnPlatform(CAMERASHAKE.VERTICAL, 0.2, 0.015, 0.07, inst:GetCurrentPlatform())

			inst.components.winch:StartRaising()
		end
	end
end

local function OnFullyRaised(inst)
	if GetHeldItem(inst) ~= nil then
		inst.components.winch.winch_ready = false
		inst.components.shelf.cantakeitem = true

		inst.components.activatable.inactive = false
	else
		inst.components.winch.winch_ready = true
		inst.components.shelf.cantakeitem = false

		inst.components.activatable.inactive = true
	end
end

local function OnStartLowering(inst)
	inst.components.winch.winch_ready = false

	inst._winch_update_task = inst:DoPeriodicTask(FRAMES, OnLoweringUpdate)
end

local function OnStartRaising(inst)
	inst.components.winch:SetRaisingSpeedMultiplier(GetHeldItem(inst) == nil and TUNING.BOAT_WINCH.RAISING_SPEED_FAST or TUNING.BOAT_WINCH.RAISING_SPEED_SLOW)

	if inst._winch_update_task ~= nil then
		inst._winch_update_task:Cancel()
		inst._winch_update_task = nil
	end
end

local function GetCurrentWinchDepth(inst)
	local tile = TheWorld.Map:GetTileAtPoint(inst.Transform:GetWorldPosition())
	if tile then
		local depthcategory = GetTileInfo(tile).ocean_depth
		return math.max(depthcategory and TUNING.ANCHOR_DEPTH_TIMES[depthcategory] or 0, PERCEIVED_DEPTH_MINIMUM)
	end
	return 0
end

local function MakeEmpty(inst)
	inst.components.shelf.cantakeitem = false

	if inst.components.winch ~= nil then
		inst.components.winch.winch_ready = true
	end

	if inst.components.activatable ~= nil then
		inst.components.activatable.inactive = true
	end

	inst.AnimState:ClearOverrideSymbol("swap_body")
end

local function OnActivate(inst, doer)
	if inst:GetCurrentPlatform() ~= nil then
		inst.components.winch:StartLowering()
	else
		inst.components.activatable.inactive = true
		inst:PushEvent("claw_interact_ground")
	end

	inst._most_recent_interacting_player = doer

	return true
end

local function CanActivate(inst, doer)
	return inst:HasTag("winch_ready")
end

local function onitemget(inst, data, no_CHEVO_event)
	local item = data.item
	inst.components.shelf:PutItemOnShelf(item)

	if item.components.symbolswapdata ~= nil then
		if item.components.symbolswapdata.is_skinned then
			inst.AnimState:OverrideItemSkinSymbol("swap_body", item.components.symbolswapdata.build, item.components.symbolswapdata.symbol, item.GUID, "swap_cavein_boulder" ) --default should never be used
		else
			inst.AnimState:OverrideSymbol("swap_body", item.components.symbolswapdata.build, item.components.symbolswapdata.symbol)
		end
	end

	if not no_CHEVO_event then
		inst:DoTaskInTime(0,function() TheWorld:PushEvent("CHEVO_heavyobject_winched",{target=inst,doer=nil}) end)
	end
end

local function onitemlose(inst, data)
	MakeEmpty(inst)
end

local function onburnt(inst)
	dropitems(inst)

	if inst._raise_claw_task ~= nil then
		inst._raise_claw_task:Cancel()
		inst._raise_claw_task = nil
	end

	inst:RemoveComponent("winch")
	inst:RemoveComponent("activatable")
	inst:RemoveComponent("shelf")

    inst.SoundEmitter:KillSound("mooring")
	inst.sg:Stop()
end

local function onbuilt(inst)
    inst.SoundEmitter:PlaySound(inst.sounds.place)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle")
end

local function getstatus(inst)
	return GetHeldItem(inst) ~= nil and
		(inst:HasTag("takeshelfitem") and "HOLDING_ITEM" or "RETRIEVING_ITEM")
		or "GENERIC"
end

local function OnHaunt(inst, haunter)
	if not (inst:HasTag("burnt") or inst:HasTag("fire")) and inst:HasTag("winch_ready") and GetHeldItem(inst) == nil
		and inst.components.activatable:CanActivate()
		and math.random() < TUNING.HAUNT_CHANCE_HALF then

		inst.components.activatable:DoActivate(haunter)
	end
end

local function load_object_action_filter(inst, doer, heavy_item)
	return inst:HasTag("inactive")
		and not inst:HasTag("takeshelfitem")
		and not inst:HasTag("burnt")
		and not inst:HasTag("lowered_ground")
		and not inst:HasTag("fire")
		and not inst:HasTag("burnt")
end

local function OnUseHeavy(inst, doer, heavy_item)
	if heavy_item == nil then
		return
	end

	doer.components.inventory:RemoveItem(heavy_item)
	inst.components.inventory:GiveItem(heavy_item)

	OnFullyRaised(inst)

	return true
end

local function Unload(inst)
	if inst.components.shelf.cantakeitem then
		inst.components.shelf.cantakeitem = false

		inst:DoTaskInTime(14*FRAMES, function()
			inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/medium")
			local item = dropitems(inst)

            -- Items without a submersible component should just work when dropped.
			if (item ~= nil and item.components.submersible ~= nil) and inst:GetCurrentPlatform() ~= nil then
				item.components.submersible.force_no_repositioning = true
				local x, _, z = inst.Transform:GetWorldPosition()
				item.components.submersible:MakeSunken(x, z, true, true)
			end
		end)

		inst.AnimState:PlayAnimation("unload", false)
		inst.AnimState:PushAnimation("idle", false)

		return true
	else
		return false
	end
end

local function OnSave(inst, data)
	if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
		data.burnt = true
	elseif inst.sg:HasStateTag("lowered_ground") then
		data.lowered_ground = true
	end
end

local function OnLoad(inst, data)
	if data ~= nil then
		if data.burnt then
			inst.components.burnable.onburnt(inst)
			inst:PushEvent("onburnt")
		elseif data.lowered_ground then
			inst.sg:GoToState("lowered_ground")
		end
	end
end

local function OnLoadPostPass(inst)
	if not inst:HasTag("burnt") then
		local item = GetHeldItem(inst)
		if item ~= nil then
			inst.components.shelf:PutItemOnShelf(item)

			if item.components.symbolswapdata ~= nil then
				if item.components.symbolswapdata.is_skinned then
					inst.AnimState:OverrideItemSkinSymbol("swap_body", item.components.symbolswapdata.build, item.components.symbolswapdata.symbol, item.GUID, "swap_cavein_boulder" ) --default should never be used
				else
					inst.AnimState:OverrideSymbol("swap_body", item.components.symbolswapdata.build, item.components.symbolswapdata.symbol)
				end
			end
		end

		if inst:GetCurrentPlatform() ~= nil then
			if inst.components.winch ~= nil then
				if inst.components.winch.is_static then
					if inst.components.winch.line_length > 0 then
						inst.components.winch:StartRaising()
					else
						inst.components.winch:FullyRaised()
					end
				else
					if inst.components.winch.is_raising then
						inst.components.winch:FullyRaised()
					else
						inst.components.winch:FullyLowered()
					end
				end
			end
		end

		inst.components.activatable.inactive = inst:HasTag("winch_ready") and not GetHeldItem(inst)
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

    inst.AnimState:SetBank("boat_winch")
	inst.AnimState:SetBuild("boat_winch")
	inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("structure")

	inst.use_heavy_obstacle_string_key = "LOAD_WINCH"
	inst.use_heavy_obstacle_action_filter = load_object_action_filter

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
	end

	-- inst._most_recent_interacting_player = nil
	-- inst._boat_drag_task = nil
	-- inst._winch_update_task = nil

	inst.sounds = sounds

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

	inst:AddComponent("winch")
	inst.components.winch:SetRaisingSpeedMultiplier(TUNING.BOAT_WINCH.RAISING_SPEED_FAST)
	inst.components.winch:SetLoweringSpeedMultiplier(TUNING.BOAT_WINCH.LOWERING_SPEED)
	inst.components.winch:SetOnFullyLoweredFn(OnFullyLowered)
	inst.components.winch:SetOnFullyRaisedFn(OnFullyRaised)
	inst.components.winch:SetOnStartRaisingFn(OnStartRaising)
	inst.components.winch:SetOnStartLoweringFn(OnStartLowering)
	inst.components.winch:SetOverrideGetCurrentDepthFn(GetCurrentWinchDepth)
	inst.components.winch:SetUnloadFn(Unload)

	inst:AddComponent("heavyobstacleusetarget")
	inst.components.heavyobstacleusetarget.on_use_fn = OnUseHeavy

	inst:AddComponent("activatable")
	inst.components.activatable.OnActivate = OnActivate
	inst.components.activatable.CanActivateFn = CanActivate
	inst.components.activatable.standingaction = true

	inst:AddComponent("boatdrag")
	inst.components.boatdrag.drag = TUNING.BOAT.ANCHOR.BASIC.ANCHOR_DRAG
	inst.components.boatdrag.max_velocity_mod = TUNING.BOAT.ANCHOR.BASIC.MAX_VELOCITY_MOD
	inst.components.boatdrag.sailforcemodifier = TUNING.BOAT.ANCHOR.BASIC.SAILFORCEDRAG

	inst:SetStateGraph("SGwinch")

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(on_hammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	inst:AddComponent("inventory")
	inst.components.inventory.ignorescangoincontainer = true
	inst.components.inventory.maxslots = 1

	inst:AddComponent("shelf")
	inst.components.shelf.cantakeitem = false

	inst:AddComponent("hauntable")
	inst.components.hauntable:SetOnHauntFn(OnHaunt)
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

	MakeLargeBurnable(inst, nil, nil, true)
	MakeMediumPropagator(inst)
	inst:ListenForEvent("onburnt", onburnt)

	inst:ListenForEvent("onbuilt", onbuilt)
	inst:ListenForEvent("ondeconstructstructure", dropitems)
	inst:ListenForEvent("onremove", dropitems)
	inst:ListenForEvent("itemget", onitemget)
	inst:ListenForEvent("itemlose", onitemlose)

	inst.OnSave = OnSave
	inst.OnLoad = OnLoad
	inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

return Prefab("winch", fn, assets, prefabs),
       MakePlacer("winch_placer", "boat_winch", "boat_winch", "placer")
