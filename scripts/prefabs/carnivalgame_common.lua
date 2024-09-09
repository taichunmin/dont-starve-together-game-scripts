
-- functions to implement:
-- OnActivateGame		-- the game was turned on (given a token). Set up any objects that need to be used for the game. This is the "IsIntro" state on the minigame component
-- OnStartPlaying		-- the game has been turned on and everything is ready for the player to start playing
-- OnUpdateGame			-- do stuff while the game is active. Or skip this and hand some internal state that is activated in OnStartPlaying, eg, a DoPeriodicTask or DoTaskInTime
-- OnStopPlaying		-- deativate any props in the game (items will be removed via RemoveGameItems). This is the "IsOutro" state on the minigame component. Return value is delay in seconds before SpawnRewards is called
-- SpawnRewards			-- toss out the rewards. Return value is delay in seconds before OnDeactivateGame is called
-- OnDeactivateGame		-- play the turn off anim on the station now that the rewards have been tossed out
-- RemoveGameItems		-- delete any temperary items created by the game
-- OnRemoveGame			-- remove any of the game's child props (the ones that are visible while the game is turned off, probably spawned in the OnBuilt handler)

-- variables:
-- _game_duration = 10 -- TUNING.CARNIVALGAME_FEEDCHICKS_GAME_DURATION

local function OnCameraFocusDirty(inst)
    if inst._camerafocus:value() then
        TheFocalPoint.components.focalpoint:StartFocusSource(inst, nil, nil, inst._camerafocus_dist_min, inst._camerafocus_dist_max, 0)
    else
        TheFocalPoint.components.focalpoint:StopFocusSource(inst)
    end
end

local function EnableCameraFocus(inst, enable)
    if enable ~= inst._camerafocus:value() then
        inst._camerafocus:set(enable)
        if not TheNet:IsDedicated() then
            OnCameraFocusDirty(inst)
        end
    end
end

local function onhammered(inst, worker)
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")

    inst.components.lootdropper:DropLoot()

    inst:Remove()
end

local function onhit(inst, worker)
	if inst._minigametask == nil then
		inst.AnimState:PlayAnimation("hit")
		inst.AnimState:PushAnimation("idle_off", false)
	end
end

local function ShutdownGame(inst)
	inst.components.minigame:Deactivate()
end

local function DoSpawnRewards(inst)
	local rewards_duration = inst:SpawnRewards(inst)
	inst._minigametask = inst:DoTaskInTime(rewards_duration, ShutdownGame)
end

local function FlagGameComplete(inst)
	inst._minigametask:Cancel()

	inst.components.minigame:SetIsOutro()

	inst:RemoveGameItems()

	local spawn_rewards_delay = inst:OnStopPlaying()

    inst._minigametask = inst:DoTaskInTime(spawn_rewards_delay, DoSpawnRewards)
end

local function UpdateGameFn(inst)
	if GetTime() > inst.minigame_endtime then
		FlagGameComplete(inst)
		return
	end

	inst:OnUpdateGame()
end

local function StartPlayingGame(inst)
	inst.minigame_endtime = GetTime() + inst._game_duration
	inst.components.minigame:SetIsPlaying()
	inst.components.minigame:RecordExcitement()

	inst:OnStartPlaying()

	inst._minigametask = inst:DoPeriodicTask(0.1, UpdateGameFn)
end

local function enable_light(inst, turn_on)
	if inst:IsValid() then -- this has to be done to handle destroying the game
		inst.Light:Enable(turn_on)
	end
end

local function OnActivateMinigame(inst)
	inst.components.trader:Disable()
	inst.components.minigame:SetIsIntro()
	if inst._camerafocus_dist_min ~= nil then
		EnableCameraFocus(inst, true)
	end
	TheWorld:PushEvent("pausehounded", { source = inst })

	inst:RemoveGameItems()
	inst:OnActivateGame()

	if inst.lightdelay_turnon ~= nil then
		inst:DoTaskInTime(inst.lightdelay_turnon, enable_light, true)
	end

    if inst._minigametask == nil then
        inst._minigame_score = 0
        inst._minigametask = inst:DoTaskInTime(inst._turnon_time, StartPlayingGame)
	end
end

local function OnDeactivateMinigame(inst)
	inst.components.trader:Enable()
	EnableCameraFocus(inst, false)
	TheWorld:PushEvent("unpausehounded", { source = inst })

	if inst.lightdelay_turnoff ~= nil then
		inst:DoTaskInTime(inst.lightdelay_turnoff, enable_light, false)
	end

	inst._minigame_score = 0

	if inst._minigametask ~= nil then
		inst._minigametask:Cancel()
		inst._minigametask = nil
	end

	inst:RemoveGameItems()
	inst:OnDeactivateGame()
end

local function UpdateGameMusic(inst)
	if ThePlayer ~= nil and ThePlayer:IsValid() and ThePlayer:IsNear(inst, TUNING.CARNIVAL_THEME_MUSIC_RANGE) then
		ThePlayer:PushEvent("playcarnivalmusic", not inst:HasTag("trader"))
	end
end

local function OnEntityWake(inst)
	if not TheNet:IsDedicated() then
		inst._musiccheck = inst:DoPeriodicTask(1, UpdateGameMusic)
	end
end

local function OnEntitySleep(inst)
	if inst._musiccheck ~= nil then
		inst._musiccheck:Cancel()
		inst._musiccheck = nil
	end

	ShutdownGame(inst)
end

local function Trader_AbleToAcceptTest(inst, item, giver)
	if item.prefab == "carnival_gametoken" then
		return true
	end
	return false, "CARNIVALGAME_INVALID_ITEM"
end

local function OnAcceptItem(inst, doer)
    inst.components.minigame:Activate()
	return true
end

local function IsMinigameActive(inst)
    return inst._minigametask ~= nil
end

local FIND_CHAIN_MUST_TAGS = {"carnivalcannon", "inactive"}
local function ActivateRandomCannon(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	local cannons = TheSim:FindEntities(x, y, z, 12, FIND_CHAIN_MUST_TAGS)
	if #cannons > 0 then
		cannons[math.random(#cannons)]:FireCannon()
	end
end

local function ScorePoints(inst, doer, points)
	inst._minigame_score = inst._minigame_score + (points or 1)
	inst.components.minigame:RecordExcitement()
	ActivateRandomCannon(inst)
end

local function GetStatus(inst)
	return IsMinigameActive(inst) and "PLAYING" or nil
end

local function OnRemoveEntity(inst)
	ShutdownGame(inst)
	inst:OnRemoveGame()
end

local function carnival_station_fn(common_postinit, master_postinit)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT] / 2) --match kit item
	MakeObstaclePhysics(inst, .5)

    inst.Light:Enable(false)
    inst.Light:SetRadius(5)
    inst.Light:SetIntensity(0.55)
    inst.Light:SetFalloff(1.3)
    inst.Light:SetColour(251/255, 240/255, 218/255)

	inst:AddTag("structure")
	inst:AddTag("birdblocker")
	inst:AddTag("carnivalgame_part")

	MakeSnowCoveredPristine(inst)

    inst._camerafocus = net_bool(inst.GUID, "pigking._camerafocus", "camerafocusdirty")
	inst._camerafocus_dist_min = TUNING.CARNIVALGAME_CAMERA_FOCUS_MIN
	inst._camerafocus_dist_max = TUNING.CARNIVALGAME_CAMERA_FOCUS_MAX

	common_postinit(inst)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        inst:ListenForEvent("camerafocusdirty", OnCameraFocusDirty)
		inst._musiccheck = inst:DoPeriodicTask(1, UpdateGameMusic)

		return inst
	end

	inst._turnon_time = 1.5
	inst._game_duration = TUNING.CARNIVALGAME_DURATION
	inst._minigame_score = 0

    inst:AddComponent("savedrotation")

	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = GetStatus

	inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(Trader_AbleToAcceptTest)
    inst.components.trader.onaccept = OnAcceptItem

	inst:AddComponent("minigame")
	inst.components.minigame.gametype = "carnivalgame"
	inst.components.minigame:SetOnActivatedFn(OnActivateMinigame)
	inst.components.minigame:SetOnDeactivatedFn(OnDeactivateMinigame)


	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(3)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	MakeHauntableWork(inst)

	inst:AddComponent("lootdropper")

	MakeSnowCovered(inst)

	inst.OnEntityWake = OnEntityWake
	inst.OnEntitySleep = OnEntitySleep
    inst.OnRemoveEntity = OnRemoveEntity

	inst.ScorePoints = ScorePoints
	inst.ActivateRandomCannon = ActivateRandomCannon

	inst.FlagGameComplete = FlagGameComplete

	master_postinit(inst)

    return inst
end

local function CreateGameBlocker(parent, x, z)
	local inst = SpawnPrefab("carnivalgame_placementblocker")

	inst.entity:SetParent(parent.entity)
	inst.Transform:SetPosition(x, 0, z)

	--	inst:DoTaskInTime(0, function() SpawnPrefab("flint").Transform:SetPosition(inst.Transform:GetWorldPosition()) end)

	return inst
end

return
{
	CarnivalStationFn = carnival_station_fn,
	CreateGameBlocker = CreateGameBlocker,
}