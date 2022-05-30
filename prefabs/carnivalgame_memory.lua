
local CARNIVALGAME_COMMON = require "prefabs/carnivalgame_common"

local assets =
{
    Asset("ANIM", "anim/carnivalgame_memory_card.zip"),
    Asset("ANIM", "anim/carnivalgame_memory_station.zip"),
    Asset("ANIM", "anim/carnivalgame_memory_floor.zip"),
    Asset("SCRIPT", "scripts/prefabs/carnivalgame_common.lua"),
}

local kit_assets =
{
    Asset("ANIM", "anim/carnivalgame_memory_station.zip"),
}

local prefabs =
{
	"carnivalgame_memory_card",
	"carnival_prizeticket",
}

local CARD_POINTS = {}
local function create_card_points()
	table.insert(CARD_POINTS, Vector3( 0, 0, 5))
	table.insert(CARD_POINTS, Vector3( 3, 0, 1.5))
	table.insert(CARD_POINTS, Vector3(-3, 0, 1.5))
	table.insert(CARD_POINTS, Vector3( 3, 0, 4.5))
	table.insert(CARD_POINTS, Vector3(-3, 0, 4.5))

	table.insert(CARD_POINTS, Vector3(1.5, 0, 3))
	table.insert(CARD_POINTS, Vector3(-1.5, 0, 3))

	table.insert(CARD_POINTS, Vector3(4.5, 0, 3))
	table.insert(CARD_POINTS, Vector3(-4.5, 0, 3))
end
create_card_points()


local function CreateFloor(parent)
	local inst = CreateEntity()

	--[[Non-networked entity]]
	inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst:AddTag("CLASSIFIED")
	inst:AddTag("NOCLICK")
	inst:AddTag("DECOR")

	inst.AnimState:SetBank("carnivalgame_memory_floor")
	inst.AnimState:SetBuild("carnivalgame_memory_floor")
	inst.AnimState:PlayAnimation("idle")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(-2)

	inst.entity:SetParent(parent.entity)
	if parent.components.placer ~= nil then
		parent.components.placer:LinkEntity(inst, 0.25)
	end

	inst:ListenForEvent("onbuilt", function() inst.AnimState:PlayAnimation("place") inst.AnimState:PushAnimation("idle", false) end, parent)

	return inst
end

local function OnBuilt(inst, data)
	local rot = data ~= nil and data.rot or 0
	inst.Transform:SetRotation(rot)

    local x, y, z = inst.Transform:GetWorldPosition()
    for i, v in ipairs(CARD_POINTS) do
        local card = inst.components.objectspawner:SpawnObject("carnivalgame_memory_card")
		local _x, _z = VecUtil_RotateDir(v.x, v.z, -rot*DEGREES)
        card.Transform:SetPosition(x + _x, 0, z + _z)
		card.sg:GoToState("place")
    end

	inst.AnimState:PlayAnimation("place", false)
	inst.AnimState:PushAnimation("idle_off", false)

	--inst.SoundEmitter:PlaySound("place")
end

local function card_turnon(card)
	card:PushEvent("carnivalgame_turnon")
end

local function OnActivateGame(inst)
	inst.AnimState:PlayAnimation("turn_on")
	inst.AnimState:ClearOverrideSymbol("carnivalgame_ms_number")

	--inst.SoundEmitter:PlaySound("turn_on")
	inst:DoTaskInTime(26*FRAMES, function(i) i.SoundEmitter:PlaySound("summerevent/carnival_games/memory/LP", "loop") end)

	inst._picked_cards = {}

	for i, card in ipairs(inst.components.objectspawner.objects) do
		card:DoTaskInTime(math.random() * 0.5, card_turnon)
		card._shouldturnoff = false
		card.components.activatable.inactive = false
	end
end

local function DoNextRound(inst)
	inst._round_delay = nil

	inst._round_num = inst._round_num + 1
	shuffleArray(inst.components.objectspawner.objects)

	local num_cards_to_pick = math.min(5, math.ceil(inst._round_num / 2))
	if num_cards_to_pick > 1 then
		inst.AnimState:PlayAnimation("on_beginround")
		inst.AnimState:PushAnimation("idle_on")
		inst.AnimState:OverrideSymbol("carnivalgame_ms_number", "carnivalgame_memory_station", "carnivalgame_ms_number"..tostring(num_cards_to_pick))

		inst.SoundEmitter:PlaySound("summerevent/carnival_games/memory/begin_round")
	end

	for i, card in ipairs(inst.components.objectspawner.objects) do
		if i <= num_cards_to_pick then
			inst._picked_cards[card] = true
		end
		card:PushEvent("carnivalgame_memory_cardstartround", {isgood = i <= num_cards_to_pick})
		card.components.activatable.inactive = true
	end
end

local function DoEndOfRound(inst)
	if next(inst._picked_cards) ~= nil then
		return
	end

	for i, card in ipairs(inst.components.objectspawner.objects) do
		card:PushEvent("carnivalgame_endofround")
	end

	inst._round_delay = inst:DoTaskInTime(0.5, DoNextRound)
end

local function OnStartPlaying(inst)
	inst.AnimState:PushAnimation("idle_on", true)

	inst._round_num = 0
	DoNextRound(inst)
end

local function OnUpdateGame(inst)

end

local function RemoveGameItems(inst)
end

local function spawnticket(inst)
	inst.components.lootdropper:SpawnLootPrefab("carnival_prizeticket")
	inst:ActivateRandomCannon()
end

local function SpawnRewards(inst)
	for i = 1, inst._minigame_score do
		inst:DoTaskInTime(0.25 * i, spawnticket)
	end

	inst.AnimState:PlayAnimation("spawn_rewards", true)
	inst.SoundEmitter:PlaySound("summerevent/carnival_games/memory/spawn_rewards", "rewards_loop")

	return 0.25 * inst._minigame_score
end

local function OnStopPlaying(inst)
	inst.AnimState:PlayAnimation("spawn_rewards", true)

	inst.SoundEmitter:KillSound("loop")

	inst._picked_cards = {}

	local function turnoff_card(card)
		card:PushEvent("carnivalgame_turnoff")
	end

	for i, card in ipairs(inst.components.objectspawner.objects) do
		card._shouldturnoff = true
		card.components.activatable.inactive = false
		card:DoTaskInTime(math.random() * 0.25, turnoff_card)
	end

	return 1 -- delay before spawning rewards
end

local function OnDeactivateGame(inst)
	inst.AnimState:PlayAnimation("turn_off")

	inst.SoundEmitter:KillSound("rewards_loop")
	inst.SoundEmitter:PlaySound("summerevent/carnival_games/memory/spawn_rewards_endbell")

	for i, card in ipairs(inst.components.objectspawner.objects) do
		card.components.activatable.inactive = false
		card._shouldturnoff = true
	end

	for i, card in ipairs(inst.components.objectspawner.objects) do
		card.sg:GoToState("idle_off")
	end
end

local function NewObject(inst, obj)
	local function on_card_picked(card)
		if inst._picked_cards[card] then
			inst._picked_cards[card] = nil

			inst:ScorePoints(inst)

			DoEndOfRound(inst)
		else
			--inst:FlagGameComplete()
			-- game over
		end
	end

	--carnivalgame_memory_revealcard
    inst:ListenForEvent("carnivalgame_memory_cardrevealed", on_card_picked, obj)
end

local function OnRemoveGame(inst)
	for i, card in ipairs(inst.components.objectspawner.objects) do
        card:Remove()
    end
end

local function station_common_postinit(inst)
	inst.MiniMapEntity:SetIcon("carnivalgame_memory_station.png")

	inst.AnimState:SetBank("carnivalgame_memory_station")
	inst.AnimState:SetBuild("carnivalgame_memory_station")
	inst.AnimState:PlayAnimation("idle_off")

	if not TheNet:IsDedicated() then
		CreateFloor(inst)
	end
end

local function station_master_postinit(inst)
	inst.components.minigame.spectator_dist =		TUNING.CARNIVALGAME_MEMORY_ARENA_RADIUS + 8
	inst.components.minigame.participator_dist =	TUNING.CARNIVALGAME_MEMORY_ARENA_RADIUS + 3
	inst.components.minigame.watchdist_min =		TUNING.CARNIVALGAME_MEMORY_ARENA_RADIUS + 0
	inst.components.minigame.watchdist_target =		TUNING.CARNIVALGAME_MEMORY_ARENA_RADIUS + 3
	inst.components.minigame.watchdist_max =		TUNING.CARNIVALGAME_MEMORY_ARENA_RADIUS + 6

    inst:AddComponent("objectspawner")
    inst.components.objectspawner.onnewobjectfn = NewObject

	-- template carnival game setup
	--inst._game_duration = 5
	inst._turnon_time = 1
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
	custom_candeploy_fn = function(inst, pt, mouseover, deployer, rot)
		local x, y, z = pt:Get()
		for i = 1, #CARD_POINTS do
			local _x, _y, _z = CARD_POINTS[i]:Get()
			local sin_rot = math.sin(-rot * DEGREES)
			local cos_rot = math.cos(-rot * DEGREES)
			if not TheWorld.Map:IsAboveGroundAtPoint(x + _x * cos_rot - _z * sin_rot, 0, z + _z * cos_rot + _x * sin_rot, false) or TheSim:CountEntities(x + _x * cos_rot - _z * sin_rot, 0, z + _z * cos_rot + _x * sin_rot, 4, CARNIVALGAMEPART_TAG) > 0 then
				return false
			end
		end

		return TheWorld.Map:CanDeployAtPoint(pt, inst, mouseover) and TheWorld.Map:IsAboveGroundAtPoint(x, y, z, false) and TheSim:CountEntities(x, y, z, 4, CARNIVALGAMEPART_TAG) == 0
	end,
}

local function createplacercard()
    local inst = CreateEntity()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

	inst.AnimState:SetBuild("carnivalgame_memory_card")
    inst.AnimState:SetBank("carnivalgame_memory_card")
    inst.AnimState:PlayAnimation("off")

    return inst
end

local function placerdecor(inst)
	for i = 1, #CARD_POINTS do
        local card = createplacercard()
        card.Transform:SetPosition(CARD_POINTS[i]:Get())
        card.entity:SetParent(inst.entity)
        inst.components.placer:LinkEntity(card)
	end

	CreateFloor(inst)
end

-------------------------------------------------------------------------------
local function card_OnPick(inst)
	inst:PushEvent("carnivalgame_memory_revealcard")
	return true
end

local function card_GetStatus(inst)
	return not inst._shouldturnoff and "PLAYING" or nil
end

local function GetActivateVerb()
    return "PICK"
end

local function displaynamefn_card(inst)
    return inst.AnimState:IsCurrentAnimation("off") and STRINGS.NAMES.CARNIVALGAME_MEMORY_CARD_OFF or STRINGS.NAMES.CARNIVALGAME_MEMORY_CARD
end

local function cardfn()
    local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst.AnimState:SetBuild("carnivalgame_memory_card")
    inst.AnimState:SetBank("carnivalgame_memory_card")
    inst.AnimState:PlayAnimation("off")

	MakeSnowCoveredPristine(inst)

	inst:SetPhysicsRadiusOverride(0.5)

	inst:AddTag("birdblocker")
	inst:AddTag("scarytoprey")
	inst:AddTag("carnivalgame_part")

	inst.GetActivateVerb = GetActivateVerb
	inst.displaynamefn = displaynamefn_card

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst._shouldturnoff = true

	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = card_GetStatus

	inst:AddComponent("activatable")
	inst.components.activatable.OnActivate = card_OnPick
	inst.components.activatable.inactive = false
	--inst.components.activatable.standingaction = false
    inst.components.activatable.quickaction = true

	MakeSnowCovered(inst)

    inst:SetStateGraph("SGcarnivalgame_memory_card")

    return inst
end


return Prefab("carnivalgame_memory_card", cardfn, assets),
		Prefab("carnivalgame_memory_station", station_fn, assets, prefabs),
		MakeDeployableKitItem("carnivalgame_memory_kit", "carnivalgame_memory_station", "carnivalgame_memory_station", "carnivalgame_memory_station", "kit_item", kit_assets, {size = "med", scale = 0.77}, nil, {fuelvalue = TUNING.LARGE_FUEL}, deployable_data),
		MakePlacer("carnivalgame_memory_kit_placer", "carnivalgame_memory_station", "carnivalgame_memory_station", "idle_off", nil, nil, nil, nil, 90, nil, placerdecor, 2)
