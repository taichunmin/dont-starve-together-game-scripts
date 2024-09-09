
local CARNIVALGAME_COMMON = require "prefabs/carnivalgame_common"
local easing = require("easing")

local assets =
{
    Asset("ANIM", "anim/carnivalgame_wheelspin_station.zip"),
    Asset("ANIM", "anim/carnivalgame_wheelspin_floor.zip"),
    Asset("SCRIPT", "scripts/prefabs/carnivalgame_common.lua"),
}

local kit_assets =
{
    Asset("ANIM", "anim/carnivalgame_wheelspin_station.zip"),
}

local prefabs =
{
	"carnival_prizeticket",
	"carnivalgame_wheelspin_hand_inner",
	"carnivalgame_wheelspin_hand_outer",
}

local prizes = { 14, 1, 4, 2, 6, 2, 4, 1 }
local MAX_SPIN_SPEED = 10

local function CreateFloorPart(parent, bank, anim, deploy_anim, offset, rot)
	local inst = CreateEntity()

	--[[Non-networked entity]]
	inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst:AddTag("CLASSIFIED")
	inst:AddTag("NOCLICK")
	inst:AddTag("DECOR")
	inst:AddTag("carnivalgame_part")

	inst.AnimState:SetBank(bank)
	inst.AnimState:SetBuild(bank)
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(-2)

	inst.AnimState:PlayAnimation(anim)

	inst.entity:SetParent(parent.entity)

	if parent.components.placer ~= nil then
		parent.components.placer:LinkEntity(inst, 0.25)
	end

	if offset ~= nil then
		inst.Transform:SetPosition(offset:Get())
	end
	if rot ~= nil then
		inst.Transform:SetRotation(rot)
	end

	inst:ListenForEvent("onbuilt", function() 
		inst.AnimState:PlayAnimation(deploy_anim) 
		inst.AnimState:PushAnimation(anim, false) 
	end, parent)

	return inst
end

local function CreateFlooring(parent)
	CreateFloorPart(parent, "carnivalgame_wheelspin_floor", "idle", "place")
end

local function OnBuilt(inst)
	inst.AnimState:PlayAnimation("place", false)
	inst.AnimState:PushAnimation("idle_off", true)
	inst.SoundEmitter:PlaySound("summerevent2022/carnivalgame_wheelspin/place")
end

local function OnActivateGame(inst)
	inst.AnimState:PlayAnimation("turn_on", false)
	inst.AnimState:PushAnimation("idle_on", true)
	inst.SoundEmitter:PlaySound("summerevent2022/carnivalgame_wheelspin/turn_on")
end

local SLOWDOWN_TIME = 3.2

local function calc_score(angle)
	angle = angle - math.floor(angle)

	local cell_arc = 1 / #prizes
	local cell = math.floor((angle + 0.5*cell_arc) * #prizes) + 1
	if cell > #prizes then
		cell = 1
	end

	--print("Hand Score:", prizes[cell] or 0, cell, angle, ((angle + 0.5*cell_arc) * #prizes) + 1, math.floor((angle + 0.5*cell_arc) * #prizes) + 1) 

	return prizes[cell] or 1
end

local function StartSlowdown(inst)
	if inst._inactive_timeout ~= nil then
		inst._inactive_timeout:Cancel()
		inst._inactive_timeout = nil

		local hand_inner_delay_time = (0.75 + math.random() * 1.5)
		local hand_outer_delay_time = (0.75 + math.random() * 1.5)

		inst._hand_inner_state.slowdown_task = inst:DoTaskInTime(hand_inner_delay_time, function(_, state)
			state.slowdown_task = nil
			state.end_angle:set_local(0)
			state.end_angle:set(3 + math.random()) -- it will take SLOWDOWN_TIME seconds to reach this %angle

			inst._minigame_score = inst._minigame_score + calc_score(state.end_angle:value())

			inst.SoundEmitter:KillSound("loop_inner")
			inst.SoundEmitter:PlaySound("summerevent2022/carnivalgame_wheelspin/spinning_inner_slowdown")
		end, inst._hand_inner_state)

		inst._hand_outer_state.slowdown_task = inst:DoTaskInTime(hand_outer_delay_time, function(_, state)
			state.slowdown_task = nil
			state.end_angle:set_local(0)
			state.end_angle:set(3 + math.random()) -- it will take SLOWDOWN_TIME seconds to reach this %angle

			inst._minigame_score = inst._minigame_score + calc_score(state.end_angle:value())

			inst.SoundEmitter:KillSound("loop_outer")
		    inst.SoundEmitter:PlaySound("summerevent2022/carnivalgame_wheelspin/spinning_outer_slowdown")
		end, inst._hand_outer_state)

		-- recalculate the end time 
		inst.minigame_endtime = GetTime() + SLOWDOWN_TIME + math.max(hand_inner_delay_time, hand_outer_delay_time) + 0.5
		inst.components.minigame:RecordExcitement()
	end
end

local function OnStartPlaying(inst)
	inst.components.activatable.inactive = true
	inst._game_playing:set(true)

	inst._inactive_timeout = inst:DoTaskInTime(TUNING.CARNIVALGAME_WHEELSPIN_INACTIVE_TIMEOUT, StartSlowdown)

	inst.SoundEmitter:PlaySound("summerevent2022/carnivalgame_wheelspin/spinning_inner", "loop_inner")
	inst.SoundEmitter:PlaySound("summerevent2022/carnivalgame_wheelspin/spinning_outer", "loop_outer")
end

local function OnUpdateGame(inst)
	inst.components.minigame:RecordExcitement()
end

local function OnStopPlaying(inst)
	inst.components.activatable.inactive = false
	inst._game_playing:set(false)

	if inst._inactive_timeout ~= nil then
		inst._inactive_timeout:Cancel()
		inst._inactive_timeout = nil
	end

	return 0.5
end

local function spawnticket(inst)
	inst.components.lootdropper:SpawnLootPrefab("carnival_prizeticket")
	inst:ActivateRandomCannon()
end

local function SpawnRewards(inst)
	inst.AnimState:PlayAnimation("spawn_rewards", true)

	inst.SoundEmitter:KillSound("loop_inner")
	inst.SoundEmitter:KillSound("loop_outer")
	inst.SoundEmitter:PlaySound("summerevent2022/carnivalgame_wheelspin/spawn_rewards_lp", "rewards_loop")

	for i = 1, inst._minigame_score do
		inst:DoTaskInTime(0.25 * i, spawnticket)
	end

	return 0.25 + 0.25 * inst._minigame_score
end

local function OnDeactivateGame(inst)
	inst._game_playing:set(false)
	
	if inst._hand_inner_state.slowdown_task ~= nil then
		inst._hand_inner_state.slowdown_task:Cancel()
		inst._hand_inner_state.slowdown_task = nil
	end
	inst._hand_inner_state.end_angle:set_local(0)

	if inst._hand_outer_state.slowdown_task ~= nil then
		inst._hand_outer_state.slowdown_task:Cancel()
		inst._hand_outer_state.slowdown_task = nil
	end
	inst._hand_outer_state.end_angle:set_local(0)

	if inst._inactive_timeout ~= nil then
		inst._inactive_timeout:Cancel()
		inst._inactive_timeout = nil
	end

	inst.AnimState:PushAnimation("turn_off", false)
	inst.AnimState:PushAnimation("idle_off", true)

	inst.SoundEmitter:KillSound("loop_inner")
	inst.SoundEmitter:KillSound("loop_outer")
	inst.SoundEmitter:PlaySound("summerevent2022/carnivalgame_wheelspin/spawn_rewards_pst")

	inst:DoTaskInTime(5*FRAMES, function(i) i.SoundEmitter:KillSound("rewards_loop") end)
	inst:DoTaskInTime(10*FRAMES, function(i) i.SoundEmitter:PlaySound("summerevent/carnival_games/herding_station/turn_off") end)
end

local function RemoveGameItems(inst)

end

local function OnRemoveGame(inst)

end

local function station_OnPress(inst, doer)
	if inst.components.minigame:GetIsPlaying() then 
		StartSlowdown(inst)
	end

	return true
end

function GetActivateVerb(inst)
	return "WHEELSPIN_STOP"
end

local function client_slowdown_hand_fn(hand, station)
	local t = GetTime() - hand._start_time

	if t >= SLOWDOWN_TIME then
		hand.slowdown_task:Cancel()
		hand.slowdown_task = nil
		hand.AnimState:SetTime(hand._end_animtime)
	else
		local angle = easing.outQuad(t, 0, hand._end_animtime - hand._start_animtime, SLOWDOWN_TIME)
		hand.AnimState:SetTime(hand._start_animtime + angle)
	end

end

local function client_update_hand(inst, hand, _end_angle)
	local end_angle = _end_angle:value()


	if end_angle > 0 then
		hand.AnimState:Pause()
		hand._start_animtime = hand.AnimState:GetCurrentAnimationTime() + FRAMES*0.5
		hand._end_animtime = (end_angle * hand.AnimState:GetCurrentAnimationLength())
		hand._start_time = GetTime()

		--print("client_update_hand", end_angle, hand._start_animtime, hand._end_animtime, hand._start_time, hand.AnimState:GetCurrentAnimationTime(), hand.AnimState:GetCurrentAnimationLength())

		hand.slowdown_task = hand:DoPeriodicTask(0, client_slowdown_hand_fn, 0, inst)
		client_slowdown_hand_fn(hand, inst)
	end
end

local function client_game_playing_changed(inst)
	local playing = inst._game_playing:value()

	if playing then
		inst._hand_inner.AnimState:Resume()
		inst._hand_outer.AnimState:Resume()
	else
		inst._hand_inner.AnimState:Pause()
		inst._hand_outer.AnimState:Pause()
	end
end

local function station_common_postinit(inst)
	inst.MiniMapEntity:SetIcon("carnivalgame_wheelspin_station.png")

	inst.AnimState:SetBank("carnivalgame_wheelspin_station")
	inst.AnimState:SetBuild("carnivalgame_wheelspin_station")
	inst.AnimState:PlayAnimation("idle_off")

	inst.GetActivateVerb = GetActivateVerb

	inst._camerafocus_dist_min = nil
	inst._camerafocus_dist_max = nil

    inst.highlightchildren = {}

    inst._hand_inner_state = { end_angle = net_float(inst.GUID, "_hand_inner_state.end_angle", "_hand_inner_state_end_angle") }
    inst._hand_outer_state = { end_angle = net_float(inst.GUID, "_hand_outer_state.end_angle", "_hand_outer_state_end_angle") }

	inst._game_playing = net_bool(inst.GUID, "carnivalgame_wheelspin._game_playing", "carnivalgame_wheelspin_game_playing") -- 0 = placing, 1 = idle, 2 = spinning

	if not TheNet:IsDedicated() then
		inst._hand_inner = SpawnPrefab("carnivalgame_wheelspin_hand_inner")
		inst._hand_inner.entity:SetParent(inst.entity)
		inst._hand_inner.entity:AddFollower()
		inst._hand_inner.Follower:FollowSymbol(inst.GUID, "spinner_root", 0, 0, 0)
		inst:ListenForEvent("onremove", function() table.removearrayvalue(inst.highlightchildren, inst._hand_inner) inst._hand_inner = nil end, inst._hand_inner)
		table.insert(inst.highlightchildren, inst._hand_inner)

		inst._hand_outer = SpawnPrefab("carnivalgame_wheelspin_hand_outer")
		inst._hand_outer.entity:SetParent(inst.entity)
		inst._hand_outer.entity:AddFollower()
		inst._hand_outer.Follower:FollowSymbol(inst.GUID, "spinner_root", 0, 0, 0)
		inst:ListenForEvent("onremove", function()table.removearrayvalue(inst.highlightchildren, inst._hand_outer)  inst._hand_outer = nil end, inst._hand_outer)
		table.insert(inst.highlightchildren, inst._hand_outer)


		inst:ListenForEvent("_hand_inner_state_end_angle", function(i) client_update_hand(i, i._hand_inner, i._hand_inner_state.end_angle) end)
		inst:ListenForEvent("_hand_outer_state_end_angle", function(i) client_update_hand(i, i._hand_outer, i._hand_outer_state.end_angle) end)
		inst:ListenForEvent("carnivalgame_wheelspin_game_playing", client_game_playing_changed)

		CreateFlooring(inst, true)
	end
end

local function station_master_postinit(inst)
	inst:AddComponent("activatable")
	inst.components.activatable.OnActivate = station_OnPress
	inst.components.activatable.inactive = false
    inst.components.activatable.quickaction = true

	inst.components.minigame._spectator_rewards_score = 15

	inst.components.minigame.spectator_dist =		TUNING.CARNIVALGAME_WHEELSPIN_ARENA_RADIUS + 6
	inst.components.minigame.participator_dist =	TUNING.CARNIVALGAME_WHEELSPIN_ARENA_RADIUS + 6
	inst.components.minigame.watchdist_min =		TUNING.CARNIVALGAME_WHEELSPIN_ARENA_RADIUS + 0
	inst.components.minigame.watchdist_target =		TUNING.CARNIVALGAME_WHEELSPIN_ARENA_RADIUS + 1
	inst.components.minigame.watchdist_max =		TUNING.CARNIVALGAME_WHEELSPIN_ARENA_RADIUS + 3

	-- template carnival game setup
	--inst._game_duration = 5
	inst._turnon_time = 0.75
	inst._spawn_rewards_delay = 1
	inst.lightdelay_turnon = 5 * FRAMES
	inst.lightdelay_turnoff = 6 * FRAMES

	inst.OnActivateGame = OnActivateGame
	inst.OnStartPlaying = OnStartPlaying
	inst.OnUpdateGame = OnUpdateGame
	inst.OnStopPlaying = OnStopPlaying
	inst.SpawnRewards = SpawnRewards
	inst.OnDeactivateGame = OnDeactivateGame
	inst.RemoveGameItems = RemoveGameItems
	inst.OnRemoveGame = OnRemoveGame

	inst:ListenForEvent("onbuilt", OnBuilt)
end

local function station_fn()
	return CARNIVALGAME_COMMON.CarnivalStationFn(station_common_postinit, station_master_postinit)
end

local CARNIVALGAMEPART_TAG = {"carnivalgame_part"}
local deployable_data =
{
	deploymode = DEPLOYMODE.CUSTOM,
	custom_candeploy_fn = function(inst, pt, mouseover, deployer)
		local x, y, z = pt:Get()
		return TheWorld.Map:CanDeployAtPoint(pt, inst, mouseover) and TheWorld.Map:IsAboveGroundAtPoint(x, y, z, false) and TheSim:CountEntities(x, y, z, 4.25, CARNIVALGAMEPART_TAG) == 0
	end,
}

local function hand_inner_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst.AnimState:SetBank("carnivalgame_wheelspin_station")
	inst.AnimState:SetBuild("carnivalgame_wheelspin_station")
	inst.AnimState:PlayAnimation("spin", true)
	inst.AnimState:SetFinalOffset(1)
	inst.AnimState:SetDeltaTimeMultiplier(MAX_SPIN_SPEED)
	inst.AnimState:Pause()


	inst:AddTag("NOCLICK")
	inst:AddTag("DECOR")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.persists = false

    return inst
end

local function hand_outer_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst.AnimState:SetBank("carnivalgame_wheelspin_station")
	inst.AnimState:SetBuild("carnivalgame_wheelspin_station")
	inst.AnimState:PlayAnimation("spin2", true)
	inst.AnimState:SetDeltaTimeMultiplier(MAX_SPIN_SPEED)
	inst.AnimState:Pause()
	
	inst:AddTag("NOCLICK")
	inst:AddTag("DECOR")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.persists = false

    return inst
end

return Prefab("carnivalgame_wheelspin_station", station_fn, assets, prefabs),
		Prefab("carnivalgame_wheelspin_hand_inner", hand_inner_fn),
		Prefab("carnivalgame_wheelspin_hand_outer", hand_outer_fn),
		MakeDeployableKitItem("carnivalgame_wheelspin_kit", "carnivalgame_wheelspin_station", "carnivalgame_wheelspin_station", "carnivalgame_wheelspin_station", "kit_item", kit_assets, {size = "med", scale = 0.77}, nil, {fuelvalue = TUNING.MED_FUEL}, deployable_data),
		MakePlacer("carnivalgame_wheelspin_kit_placer", "carnivalgame_wheelspin_station", "carnivalgame_wheelspin_station", "placer", nil, nil, nil, nil, 90, nil, CreateFlooring)
