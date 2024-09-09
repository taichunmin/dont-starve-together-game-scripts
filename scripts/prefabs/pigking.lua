local assets =
{
    Asset("ANIM", "anim/pig_king.zip"),
    Asset("SOUND", "sound/pig.fsb"),
    Asset("ANIM", "anim/pig_king_elite_build.zip"),
}

local prefabs =
{
    "goldnugget",
    "pigelite1",
    "pigelite2",
    "pigelite3",
    "pigelite4",
    "propsign",
    "pig_token",
    "lucky_goldnugget",
    "redpouch_yotp",
	"pig_coin",
}

for i = 1, NUM_HALLOWEENCANDY do
    table.insert(prefabs, "halloweencandy_"..i)
end

--------------------------------------------------------------------------

local MINIGAME_ITEM = "goldnugget"

local function OnCameraFocusDirty(inst)
    if inst._camerafocus:value() then
        TheFocalPoint.components.focalpoint:StartFocusSource(inst, nil, nil, 8, 15, 2)
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

--------------------------------------------------------------------------

local function launchitem(item, angle)
    local speed = math.random() * 4 + 2
    angle = (angle + math.random() * 60 - 30) * DEGREES
    item.Physics:SetVel(speed * math.cos(angle), math.random() * 2 + 8, speed * math.sin(angle))
end

local function ontradeforgold(inst, item, giver)
    AwardPlayerAchievement("pigking_trader", giver)

    local x, y, z = inst.Transform:GetWorldPosition()
    y = 4.5

    local angle
    if giver ~= nil and giver:IsValid() then
        angle = 180 - giver:GetAngleToPoint(x, 0, z)
    else
        local down = TheCamera:GetDownVec()
        angle = math.atan2(down.z, down.x) / DEGREES
        giver = nil
    end

    for k = 1, item.components.tradable.goldvalue do
        local nug = SpawnPrefab("goldnugget")
        nug.Transform:SetPosition(x, y, z)
        launchitem(nug, angle)
    end

    if item.components.tradable.tradefor ~= nil then
        for _, v in pairs(item.components.tradable.tradefor) do
            local item = SpawnPrefab(v)
            if item ~= nil then
                item.Transform:SetPosition(x, y, z)
                launchitem(item, angle)
            end
        end
    end

    if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
        -- pick out up to 3 types of candies to throw out
        local candytypes = { math.random(NUM_HALLOWEENCANDY), math.random(NUM_HALLOWEENCANDY), math.random(NUM_HALLOWEENCANDY) }
        local numcandies = (item.components.tradable.halloweencandyvalue or 1) + math.random(2) + 2

        -- only people in costumes get a good amount of candy!
        if giver ~= nil and giver.components.skinner ~= nil then
            for _, item in pairs(giver.components.skinner:GetClothing()) do
                if DoesItemHaveTag(item, "COSTUME") or DoesItemHaveTag(item, "HALLOWED") then
                    numcandies = numcandies + math.random(4) + 2
                    break
                end
            end
        end

        for k = 1, numcandies do
            local candy = SpawnPrefab("halloweencandy_"..GetRandomItem(candytypes))
            candy.Transform:SetPosition(x, y, z)
            launchitem(candy, angle)
        end
    end
end

local function OnIsNight(inst, isnight)
    if isnight then
        inst.sg.mem.sleeping = true
        if inst.sg:HasStateTag("idle") and not inst:IsMinigameActive() then
            inst.sg:GoToState("sleep")
        end
    else
        inst.sg.mem.sleeping = false
        if inst.sg:HasStateTag("sleeping") then
            inst.sg:GoToState("wake")
        end
    end
end

--------------------------------------------------------------------------

local DEPLOY_BLOCKER_RADIUS = 4 -- this is 4 due to "birdblocker" hardcoding its radius
local DEPLOY_BLOCKER_SPACING = 5 -- so the diagonals overlay

local function CreateBuildingBlocker()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
--[[
    -- hack for debug rendering
    inst.entity:AddPhysics()
    inst.Physics:SetMass(0)
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GIANTS)
    inst.Physics:SetCylinder(DEPLOY_BLOCKER_RADIUS, 1)
]]
    inst:AddTag("NOCLICK")
    inst:AddTag("birdblocker")
    inst:AddTag("antlion_sinkhole_blocker")

    inst:SetDeployExtraSpacing(DEPLOY_BLOCKER_RADIUS)

    return inst
end

local function RemoveBuildingBlockers(inst)
    if inst._blockers ~= nil then
        for i, v in ipairs(inst._blockers) do
            v:Remove()
        end
        inst._blockers = nil
    end
end

local function AddBuildingBlockers(inst)
    if inst._blockers == nil then
        inst._blockers = {}
        local x0, y0, z0 = inst.Transform:GetWorldPosition()
        local cells_across = 3
        for x = -cells_across, cells_across do
            for z = -cells_across, cells_across do
                local blocker = CreateBuildingBlocker()
                blocker.Transform:SetPosition(x0 + x*DEPLOY_BLOCKER_SPACING, 0, z0 + z*DEPLOY_BLOCKER_SPACING)
                table.insert(inst._blockers, blocker)
            end
        end
    end
end

local function OnBlockBuildingDirty(inst)
    if inst._blockbuilding:value() then
        AddBuildingBlockers(inst)
    else
        RemoveBuildingBlockers(inst)
    end
end

--------------------------------------------------------------------------

local function PushMusic(inst)
    if ThePlayer ~= nil and ThePlayer:IsNear(inst, 30) then
        ThePlayer:PushEvent("triggeredevent", { name = "pigking" })
    end
end

local function OnMusicDirty(inst)
    --Dedicated server does not need to trigger music
    if not TheNet:IsDedicated() then
        if inst._musictask ~= nil then
            inst._musictask:Cancel()
        end
        inst._musictask = inst._music:value() and inst:DoPeriodicTask(1, PushMusic, 0) or nil
    end
end

local function StartMusic(inst)
    if not inst._music:value() then
        inst._music:set(true)
        OnMusicDirty(inst)
    end
end

local function StopMusic(inst)
    if inst._music:value() then
        inst._music:set(false)
        OnMusicDirty(inst)
    end
end

--------------------------------------------------------------------------

local function RestoreObelisks(inst)
	if inst.locked_obelisks ~= nil then
		for _, obelisk in ipairs(inst.locked_obelisks) do
			obelisk:ConcealForMinigame(false)
		end
		inst.locked_obelisks = nil
	end
end

local function OnDeactivateMinigame(inst)
	inst.components.trader:Enable()
	TheWorld:PushEvent("unpausehounded", { source = inst })

    inst._blockbuilding:set(false)
    OnBlockBuildingDirty(inst)
end

local SANITYROCKS_TAGS = {"sanityrock", "insanityrock"}
local function OnActivateMinigame(inst)
    inst.components.trader:Disable()
	TheWorld:PushEvent("pausehounded", { source = inst })

	local x, y, z = inst.Transform:GetWorldPosition()
	inst.locked_obelisks = TheSim:FindEntities(x, y, z, TUNING.PIG_MINIGAME_ARENA_RADIUS, nil, nil, SANITYROCKS_TAGS) -- musttags, canttags, mustoneoftags
	for _, obelisk in ipairs(inst.locked_obelisks) do
		obelisk:ConcealForMinigame(true)
	end

    inst._blockbuilding:set(true)
    OnBlockBuildingDirty(inst)
end

local BLOCKING_ONEOF_OBJECTS = {"fire", "structure", "minigameitem", "CHOP_workable", "HAMMER_workable", "MINE_workable"}
local BLOCKING_CANT_OBJECTS = {"INLIMBO"}
local function IsAreaClearForMinigame(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, TUNING.PIG_MINIGAME_ARENA_RADIUS, nil, BLOCKING_CANT_OBJECTS, BLOCKING_ONEOF_OBJECTS) -- musttags, canttags, mustoneoftags
	for _, ent in ipairs(ents) do
		if ent.prefab ~= "pigking" and ent.prefab ~= "insanityrock" and ent.prefab ~= "sanityrock" then
			return false
		end
	end
	return true
end

local AREACLEAR_IGNORE_PLAYERS = {"player"}
local AREACLEAR_CHECK_FOR_HOSTILES = {"hostile", "monster"}
local AREACLEAR_COMBAT = {"_combat"}
local function IsAreaSafeForMinigame(inst, giver)
    local hounded = TheWorld.components.hounded
    if hounded ~= nil and (hounded:GetWarning() or hounded:GetAttacking()) then
        return false
    end
    local burnable = giver.components.burnable
    if burnable ~= nil and (burnable:IsBurning() or burnable:IsSmoldering()) then
        return false
    end

	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, TUNING.PIG_MINIGAME_ARENA_RADIUS * 2, nil, AREACLEAR_IGNORE_PLAYERS, AREACLEAR_CHECK_FOR_HOSTILES) -- musttags, canttags, mustoneoftags
	if #ents > 0 then
		return false
	end

	local ents = TheSim:FindEntities(x, y, z, TUNING.PIG_MINIGAME_ARENA_RADIUS * 2, nil, nil, AREACLEAR_COMBAT) -- musttags, canttags, mustoneoftags
	for _, ent in ipairs(ents) do
		if ent.components.combat:HasTarget() then
			return false
		end
	end

	return true
end

--------------------------------------------------------------------------

local function OnRestoreItemPhysics(item)
    item.Physics:CollidesWith(COLLISION.OBSTACLES)
end

local function LaunchGameItem(inst, item, angle, minorspeedvariance)
    local x, y, z = inst.Transform:GetWorldPosition()
    local spd = 3.5 + math.random() * (minorspeedvariance and 1 or 3.5)
    item.Physics:ClearCollisionMask()
    item.Physics:CollidesWith(COLLISION.WORLD)
    item.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    item.Physics:Teleport(x, 2.5, z)
    item.Physics:SetVel(math.cos(angle) * spd, 11.5, math.sin(angle) * spd)
    item:DoTaskInTime(.6, OnRestoreItemPhysics)
    item:PushEvent("knockbackdropped", { owner = inst, knocker = inst, delayinteraction = .75, delayplayerinteraction = .5 })

    --#WARNING: you probably don't want this last part if you copy pasta this function!--
    if item.components.burnable ~= nil then
        inst:ListenForEvent("onignite", function()
            for k, v in pairs(inst._minigame_elites) do
                k:SetCheatFlag()
            end
        end, item)
    end
    -------------------------------------------------------------------------------------
end

local PROP_MUST_TAGS = { "minigameitem", "propweapon" }
local PROP_CANT_TAGS = { "INLIMBO", "fire", "burnt" }
local function OnTossGameItems(inst)
    local items = {}
    local x, y, z = inst.Transform:GetWorldPosition()
    local numplayers = #FindPlayersInRange(x, y, z, 16, true)
    local mingold = math.min(6, 2 + math.floor(numplayers / 2))
    local numgold = math.random(mingold, mingold + 2)
    local numprops = 0
    if #TheSim:FindEntities(x, y, z, 12, PROP_MUST_TAGS, PROP_CANT_TAGS) < numplayers + 4 then
        local maxprops = 2 + math.floor(numplayers / 2)
        numprops = math.max(numgold > 2 and 1 or 2, math.random(maxprops - (maxprops > 2 and numgold > mingold and 2 or 1), maxprops))
        for i = 1, numprops do
            table.insert(items, "propsign")
        end
    elseif numgold < 3 then
        numgold = 3
    end
    for i = 1, numgold do
        table.insert(items, MINIGAME_ITEM)
    end
	inst._minigame_gold_tossed = inst._minigame_gold_tossed + numgold
    local angle = math.random() * TWOPI
    local delta = TWOPI / (numgold + numprops + 1) --purposely leave a random gap
    local variance = delta * .4
    while #items > 0 do
        local item = SpawnPrefab(table.remove(items, math.random(#items)))
        if item.OnCancelMinigame ~= nil then
            item:ListenForEvent("ms_cancelminigame", item.OnCancelMinigame, inst)
            item:ListenForEvent("onremove", item.OnCancelMinigame, inst)
        end
        LaunchGameItem(inst, item, GetRandomWithVariance(angle, variance))
        angle = angle + delta
    end
    if numgold > 0 then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")
    end
end

local function GetMinigameScore(inst)
	if inst._minigame_score == nil then
		local num_pig_gold = 0
		for pig, _ in pairs(inst._minigame_elites) do
			local has, count = pig.components.inventory:Has(MINIGAME_ITEM, 1)
			num_pig_gold = num_pig_gold + count
		end

		local player_gold_percent = inst._minigame_gold_tossed > 0 and (1 - num_pig_gold / inst._minigame_gold_tossed) or 0

		inst._minigame_score = player_gold_percent >= TUNING.PIG_MINIGAME_SCORE_GREAT and 4
							or player_gold_percent >= TUNING.PIG_MINIGAME_SCORE_GOOD and 3
							or player_gold_percent >= TUNING.PIG_MINIGAME_SCORE_BAD and 2
							or 1

		--print("Pigking Minigame: Pigs got "..tostring(num_pig_gold).."/"..tostring(inst._minigame_gold_tossed).." gold. Score: "..tostring(inst._minigame_score).." ("..tostring(math.floor(player_gold_percent*10000)/100).."%)")
	end

	return inst._minigame_score
end

local function LaunchRewards(inst, level, minigame_players)
	local x, y, z = inst.Transform:GetWorldPosition()

	local num_players = math.max(1, #minigame_players)

	local pouches = {}
	if IsSpecialEventActive(SPECIAL_EVENTS.YOTP) then
		local num_player_pouch_items = level >= 3 and 4 or 1
		local num_player_pounches = num_players * ((level == 4 or level == 2) and 2 or 1)

		for ip = 1, num_player_pounches do
			local items = {}
			for i = 1, num_player_pouch_items do
				table.insert(items, SpawnPrefab(MINIGAME_ITEM))
			end

			local pouch = SpawnPrefab("redpouch_yotp")
			pouch.Transform:SetPosition(x, 4.5, z)
			pouch.components.unwrappable:WrapItems(items)
			for i, v in ipairs(items) do
				v:Remove()
			end
			table.insert(pouches, pouch)
		end
	else
		local gold_per_player = 2 + (level * 2)
		for i = 1, gold_per_player do
			table.insert(pouches, SpawnPrefab(MINIGAME_ITEM))
		end

		local pig_coins_per_player = math.max(0, (level - 1) * 2)
		for i = 1, pig_coins_per_player do
			table.insert(pouches, SpawnPrefab("pig_coin"))
		end
	end

	-- Now Launch it
	for i, pouch in ipairs(pouches) do
	    local angle
		local target = minigame_players[((i-1) % num_players) + 1]
		if target ~= nil and target:IsValid() then
			angle = 180 - target:GetAngleToPoint(x, 0, z)
		else
			local down = TheCamera:GetDownVec()
			angle = math.atan2(down.z, down.x) / DEGREES
		end
        LaunchGameItem(inst, pouch, GetRandomWithVariance(angle, 25) * DEGREES, true)
	end
end

local function OnPickupCheat(inst, data)
    if data ~= nil and data.cheater ~= nil and data.item ~= nil and data.cheater:HasTag("player") and data.item:HasTag("minigameitem") then
        for k, v in pairs(inst._minigame_elites) do
            k:SetCheatFlag()
        end
    end
end

local function CancelGame(inst)
    if inst._minigametosstask ~= nil then
        inst._minigametosstask:Cancel()
        inst._minigametosstask = nil
    end
    if inst._minigametask ~= nil then
        inst._minigametask:Cancel()
        inst._minigametask = nil

        inst:PushEvent("ms_cancelminigame")

        inst.components.minigame:Deactivate()
        if next(inst._minigame_elites) == nil then
            EnableCameraFocus(inst, false)
        end
    end
    StopMusic(inst)
    inst:RemoveEventCallback("pickupcheat", OnPickupCheat)
end

local NUM_ROUNDS = 10
local ROUND_TIME = 6

local function GameComplete(inst)
	local minigame_players = {}
    for i, v in ipairs(AllPlayers) do
        if v.components.minigame_participator ~= nil and v.components.minigame_participator:GetMinigame() == inst then
            table.insert(minigame_players, v)
        end
    end

    CancelGame(inst)
    inst.sg:GoToState("cointoss")

    inst:DoTaskInTime(2 / 3, LaunchRewards, GetMinigameScore(inst), minigame_players)
end

local function CheckElitesPosing(inst)
    for k, v in pairs(inst._minigame_elites) do
        if not k.sg:HasStateTag("endpose") then
            return
        end
    end
    inst._minigametask:Cancel()
    inst._minigametask = inst:DoTaskInTime(1.5, GameComplete)
    StopMusic(inst)
end

local function GameCompleteFocus(inst)
    TheWorld:PushEvent("unpausehounded", { source = inst })
    inst:EnableCameraFocus(true)
    inst._minigametask = inst:DoPeriodicTask(.1, CheckElitesPosing)
end

local function FlagGameComplete(inst)
	inst.components.minigame:SetIsOutro()

    inst.sg:GoToState("unimpressed")
    for k, v in pairs(inst._minigame_elites) do
        k.flagmatchover = true
    end
    inst._minigametask = inst:DoTaskInTime(1, GameCompleteFocus)
end

local function DoGameRound(inst, roundsleft)
    inst.sg:GoToState("cointoss")
    if inst._minigametosstask ~= nil then
        inst._minigametosstask:Cancel()
    end
    inst._minigametosstask = inst:DoTaskInTime(2 / 3, OnTossGameItems)
    inst._minigametask =
        roundsleft > 1 and
        inst:DoTaskInTime(ROUND_TIME, DoGameRound, roundsleft - 1) or
        inst:DoTaskInTime(ROUND_TIME, FlagGameComplete)

	inst.components.minigame:SetIsPlaying()
	inst.components.minigame:RecordExcitement()
end

local function StartMinigame(inst)
    if inst._minigametask == nil then
		MINIGAME_ITEM = IsSpecialEventActive(SPECIAL_EVENTS.YOTP) and "lucky_goldnugget" or "goldnugget"

        inst._minigame_score = nil
        inst._minigame_gold_tossed = 0
        inst.components.minigame:Activate()
		inst.components.minigame:RecordExcitement()
        inst.sg:GoToState("intro")
        inst._minigametask = inst:DoTaskInTime(5, DoGameRound, NUM_ROUNDS)
        inst:ListenForEvent("pickupcheat", OnPickupCheat)
    end
    StartMusic(inst)
end

local function IsMinigameActive(inst)
    return inst._minigametask ~= nil
end

--------------------------------------------------------------------------

local function CanStartMinigame(inst, giver)
	if TheWorld.net ~= nil and TheWorld.net.components.clock ~= nil and TheWorld.net.components.clock:GetTimeUntilPhase("night") <= TUNING.PIG_MINIGAME_REQUIRED_TIME or inst.sg.mem.sleeping then
		return false, "PIGKINGGAME_TOOLATE"
	elseif not IsAreaClearForMinigame(inst) then
		return false, "PIGKINGGAME_MESSY"
	elseif not IsAreaSafeForMinigame(inst, giver) then
        return false, "PIGKINGGAME_DANGER"
	elseif next(inst._minigame_elites) ~= nil then
		return false
	end
	return true
end

local function OnGetItemFromPlayer(inst, giver, item)
    local is_event_item = IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) and item.components.tradable.halloweencandyvalue and item.components.tradable.halloweencandyvalue > 0

    if item.components.tradable.goldvalue > 0 or is_event_item then
        inst.sg:GoToState("cointoss")
        inst:DoTaskInTime(2 / 3, ontradeforgold, item, giver)
    elseif item.prefab == "pig_token" then
        StartMinigame(inst)
    end
end

local function OnRefuseItem(inst, giver, item)
    inst.sg:GoToState("unimpressed")
end

local function AbleToAcceptTest(inst, item, giver)
	if item.prefab == "pig_token" then
		local success, reason = CanStartMinigame(inst, giver)
		if not success then
			OnRefuseItem(inst, giver, item)
		end
		return success, reason
	end
	return true
end

local function AcceptTest(inst, item, giver)
    -- Wurt can still play the mini-game though
    if giver:HasTag("merm") and item.prefab ~= "pig_token" then
        return
    end

    local is_event_item = IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) and item.components.tradable.halloweencandyvalue and item.components.tradable.halloweencandyvalue > 0
    return item.components.tradable.goldvalue > 0 or is_event_item or item.prefab == "pig_token"
end

local function OnHaunt(inst, haunter)
    if inst.components.trader ~= nil and inst.components.trader.enabled then
        OnRefuseItem(inst)
        return true
    end
    return false
end

local function teletopos(inst)
	local pt = inst:GetPosition()
	local theta = math.random() * 360 * DEGREES
	local r = TUNING.PIG_MINIGAME_ARENA_RADIUS / 2
	r = r + r * math.sqrt(math.random())
	pt.x = pt.x + math.cos(theta) * r
	pt.z = pt.z + math.sin(theta) * r
	return pt
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 2, .5)

    inst.MiniMapEntity:SetIcon("pigking.png")
    inst.MiniMapEntity:SetPriority(1)

    inst.DynamicShadow:SetSize(10, 5)

    --inst.Transform:SetScale(1.5, 1.5, 1.5)

    inst.AnimState:SetBank("Pig_King")
    inst.AnimState:SetBuild("Pig_King")
    inst.AnimState:SetFinalOffset(1)

    if IsSpecialEventActive(SPECIAL_EVENTS.YOTP) then
        inst.AnimState:AddOverrideBuild("Pig_King_elite_build")
    end

    inst.AnimState:PlayAnimation("idle", true)

    --trader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")

    inst:AddTag("king")
    inst:AddTag("birdblocker")
    inst:AddTag("antlion_sinkhole_blocker")

    inst._music = net_bool(inst.GUID, "pigking._music", "musicdirty")
    inst._blockbuilding = net_bool(inst.GUID, "pigking._blockbuilding", "blockbuildingdirty")
    inst._camerafocus = net_bool(inst.GUID, "pigking._camerafocus", "camerafocusdirty")

    inst.OnRemoveEntity = RemoveBuildingBlockers

    if not TheNet:IsDedicated() then
        inst:AddComponent("pointofinterest")
        inst.components.pointofinterest:SetHeight(70)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("musicdirty", OnMusicDirty)
        inst:ListenForEvent("blockbuildingdirty", OnBlockBuildingDirty)
        inst:ListenForEvent("camerafocusdirty", OnCameraFocusDirty)

        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("trader")

    inst.components.trader:SetAbleToAcceptTest(AbleToAcceptTest)
    inst.components.trader:SetAcceptTest(AcceptTest)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem

    inst.TestGame = StartMinigame --TODO: remove me
    inst.CancelGame = CancelGame --TODO: remove me
    inst.EnableCameraFocus = EnableCameraFocus
    inst.IsMinigameActive = IsMinigameActive
    inst.GetMinigameScore = GetMinigameScore

    inst._minigame_elites = {}
    inst._onremoveelite = function(elite)
        inst._minigame_elites[elite] = nil
        if next(inst._minigame_elites) == nil then
            inst:EnableCameraFocus(false)
            RestoreObelisks(inst)
        end
    end

    inst:SetStateGraph("SGpigking")

    inst:WatchWorldState("isnight", OnIsNight)
    OnIsNight(inst, TheWorld.state.isnight)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

	inst:AddComponent("minigame")
	inst.components.minigame.gametype = "pigking_wrestling"
	inst.components.minigame:SetOnActivatedFn(OnActivateMinigame)
	inst.components.minigame:SetOnDeactivatedFn(OnDeactivateMinigame)
	inst.components.minigame.spectator_dist = TUNING.PIG_MINIGAME_ARENA_RADIUS + 20
	inst.components.minigame.participator_dist = TUNING.PIG_MINIGAME_ARENA_RADIUS + 15

	inst.teletopos = teletopos -- for purple staff teleporting

    return inst
end

--------------------------------------------------------------------------

return Prefab("pigking", fn, assets, prefabs)
