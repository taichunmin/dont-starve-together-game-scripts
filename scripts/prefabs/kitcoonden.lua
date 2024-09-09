require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/kitcoonden.zip"),
}

local prefabs =
{
	"kitcoonden_kit_placer",
}

for k, _ in pairs(TUNING.KITCOON_HIDEANDSEEK_NOT_YOT_REWARDS) do
	table.insert(prefabs, k)
end

-------------------------------------------------------------------------------
local function onhammered(inst)
    local ipos = inst:GetPosition()

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(ipos:Get())
    fx:SetMaterial("wood")

    inst.components.lootdropper:DropLoot(ipos)

    inst:Remove()
end

local function onhit(inst)
    inst.AnimState:PlayAnimation("hit", false)
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("yotc_2022_2/common/den/place")

	local x, y, z = inst.Transform:GetWorldPosition()
	local kitcoons = TheSim:FindEntities(x, y, z, TUNING.KITCOON_NEAR_DEN_DIST, {"kitcoon"})
	for _, kitcoon in ipairs(kitcoons) do
		if kitcoon.components.follower.leader == nil then
			inst.components.kitcoonden:AddKitcoon(kitcoon)
		end
	end

end

local function OnPlayerApproached(inst, player)
	player:AddTag("near_kitcoonden")
end

local function OnPlayerLeft(inst, player)
	player:RemoveTag("near_kitcoonden")
end

local function onremoved(inst)
	for player, v in pairs(inst.components.playerprox.closeplayers) do
		if player:IsValid() then
			OnPlayerLeft(inst, player)
		end
	end
end

local function OnAddKitcoon(inst, kitcoon, doer)
	kitcoon.components.follower:SetLeader(nil)
	kitcoon.components.entitytracker:TrackEntity("home", inst)
	if kitcoon.components.sleeper ~= nil then
		kitcoon.components.sleeper:WakeUp()
	end

	if not inst.components.hideandseekgame:IsActive() then
		inst.components.activatable.inactive = true
	end

	if IsSpecialEventActive(SPECIAL_EVENTS.YOT_CATCOON) then
		if inst.components.kitcoonden.num_kitcoons == NUM_BASIC_KITCOONS then
			local data = {kitcoons = {}}
			TheWorld:PushEvent("ms_collect_uniquekitcoons", data)
			if #data.kitcoons == 0 then
				local uniquekitcoon = SpawnPrefab("kitcoon_yot")
				uniquekitcoon.Transform:SetPosition(inst.Transform:GetWorldPosition())
				uniquekitcoon.components.hideandseekhider.hiding_spot = inst
				uniquekitcoon.components.hideandseekhider:Found(doer)
			end
		end
	end
end

local function OnRemoveKitcoon(inst, kitcoon)
	if kitcoon:IsValid() then
		kitcoon.components.entitytracker:ForgetEntity("home", inst)
	end
	
	if inst.components.kitcoonden.num_kitcoons == 0 then
		inst.components.activatable.inactive = false
	end
end

local function OnBurnt(inst)
	DefaultBurntStructureFn(inst)

	inst:RemoveTag("kitcoonden")
	inst.components.activatable.inactive = false


	inst:DoTaskInTime(0, function() 
		inst.components.hideandseekgame:Abort()
		inst.components.kitcoonden:RemoveAllKitcoons() 
		inst.components.activatable.inactive = false
	end)
end

-------------- Minigame code -------------- 

local HIDINGSPOT_NO_TAGS = {"fire", "wall", "INLIMBO", "no_hideandseek", "locomotor"}
local HIDINGSPOT_TAGS = {"pickable", "structure", "plant"}

local function GiveRedPouch(tosser, target, num_lucky_goldnugget, toss_far)
	local loots =  {SpawnPrefab("lucky_goldnugget")}
	for i = 2, num_lucky_goldnugget do
		table.insert(loots, SpawnPrefab("lucky_goldnugget"))
	end

	local redpouch = SpawnPrefab("redpouch_yot_catcoon")
	redpouch.components.unwrappable:WrapItems(loots)
	for _, v in ipairs(loots) do
		v:Remove()
	end

	LaunchAt(redpouch, tosser, target, toss_far and 1 or .5, .6, .6)
end

local function CheckIfKitcoonsCanPlay(inst)
	for k, _ in pairs(inst.components.kitcoonden.kitcoons) do
		if k.components.hideandseekhider == nil or not k.components.hideandseekhider:CanPlayHideAndSeek() then
			return false
		end
	end

	return true
end

local function OnActivate(inst, doer)
	if inst.components.kitcoonden.num_kitcoons < TUNING.KITCOONDEN_HIDEANDSEEK_MIN_KITCOONS then
		inst.components.activatable.inactive = true
		return false, "KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDERS"
	elseif not CheckIfKitcoonsCanPlay(inst) then
		inst.components.activatable.inactive = true
		return false, "KITCOON_HIDEANDSEEK_ONE_GAME_PER_DAY"
	end

	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, inst.components.hideandseekgame.hiding_range, nil, HIDINGSPOT_NO_TAGS, HIDINGSPOT_TAGS)

	local hiding_spots = {}
	local far_enough = false
	local min_dist_sq = TUNING.KITCOONDEN_HIDEANDSEEK_HIDING_RADIUS_MIN_SQ
	for _, ent in ipairs(ents) do
		if not far_enough and ent:GetDistanceSqToPoint(x, y, z) > min_dist_sq then
			far_enough = true
		end

		if far_enough and inst.persists and inst.components.hideandseekhidingspot == nil then
			local hiding_x, hiding_y, hiding_z = ent.Transform:GetWorldPosition()
			if TheWorld.Map:IsPassableAtPoint(hiding_x, hiding_y, hiding_z, false, true) then
				table.insert(hiding_spots, ent)
			end
		end
	end

	if #hiding_spots < inst.components.kitcoonden.num_kitcoons * 5 then
		inst.components.activatable.inactive = true
		return false, "KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDING_SPOTS"
	end

	shuffleArray(hiding_spots)
	local hiding_spot_index = 1
	for _, kitcoon in pairs(inst.components.kitcoonden.kitcoons) do
		local hiding_spot = hiding_spots[hiding_spot_index]

        local hiding_time = kitcoon.components.hideandseekhider.gohide_timeout + (math.random(10) * FRAMES)
		if kitcoon.components.hideandseekhider:GoHide(hiding_spot, hiding_time) then
			inst.components.hideandseekgame:RegisterHidingSpot(hiding_spot)
		end

		hiding_spot_index = hiding_spot_index + 1
	end

	inst.components.hideandseekgame:AddSeeker(doer, true)

	inst.components.timer:StartTimer("hideandseekover", TUNING.KITCOONDEN_HIDEANDSEEK_TIME_LIMIT)
	inst.components.timer:StartTimer("hideandseekwarning", TUNING.KITCOONDEN_HIDEANDSEEK_TIME_LIMIT - 10)
end

local function kitcoons_hidden_cb(seeker)
    if seeker.components.talker ~= nil then
        seeker.components.talker:Say(GetString(seeker, "ANNOUNCE_KITCOON_HIDEANDSEEK_START"))
    end
end

local function OnAddSeeker(inst, seeker, started_game)
    if started_game then
        seeker:PushEvent("hideandseek_start", {timeout = TUNING.KITCOON_HIDEANDSEEK_HIDETIMEOUT + 1})

        seeker:DoTaskInTime(TUNING.KITCOON_HIDEANDSEEK_HIDETIMEOUT + 1, kitcoons_hidden_cb)
    else
        if seeker.components.talker ~= nil then
            seeker.components.talker:Say(GetString(seeker, "ANNOUNCE_KITCOON_HIDEANDSEEK_JOIN"))
        end
    end
end

local function OnHidingSpotFound(inst, finder, hiding_spot)
	if finder ~= nil then
		if IsSpecialEventActive(SPECIAL_EVENTS.YOT_CATCOON) then
			GiveRedPouch(hiding_spot, finder, 1)
		end

		if finder.components.hideandseeker == nil then
			finder:AddComponent("hideandseeker")
			finder.components.hideandseeker:SetGame(inst)
		end

		if finder.components.talker ~= nil then
			local num_remaining = inst.components.hideandseekgame:GetNumHiding()
			if num_remaining == 0 then
				finder.components.talker:Say(GetString(finder, "ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE"))
				finder:RemoveComponent("hideandseeker")

				for seeker, _ in pairs(inst.components.hideandseekgame.seekers) do
					if seeker.components.talker ~= nil then
						seeker.components.talker:Say(subfmt(GetString(seeker, "ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE_TEAM"), {name = finder.name}))
						seeker:RemoveComponent("hideandseeker")
					end
				end
			else
				finder.components.talker:Say(GetString(finder, num_remaining > 1 and "ANNOUNCE_KITCOON_HIDANDSEEK_FOUND" or "ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_ONE_MORE"))
			end
		end
	end
end

local function OnHideAndSeekOver(inst)
	if inst.components.kitcoonden.num_kitcoons > 0 then
		inst.components.activatable.inactive = true
	end

	inst.components.timer:StopTimer("hideandseekover")
	inst.components.timer:StopTimer("hideandseekwarning")

	local num_hiders_found = inst.components.hideandseekgame:GetNumFound()

	if IsSpecialEventActive(SPECIAL_EVENTS.YOT_CATCOON) and num_hiders_found > 0 then
		local num_seekers = inst.components.hideandseekgame:GetNumSeekers()

		local prizes_per_player = {}
		if num_seekers == 1 then
			if num_hiders_found == 0 then
				table.insert(prizes_per_player, 1)
			elseif num_hiders_found <= 4 then
				table.insert(prizes_per_player, 1)
				table.insert(prizes_per_player, 1)
			elseif num_hiders_found <= 8 then
				table.insert(prizes_per_player, 4)
			else
				table.insert(prizes_per_player, 4)
				table.insert(prizes_per_player, 4)
			end
		else
			if num_hiders_found <= 4 then
				table.insert(prizes_per_player, 1)
			elseif num_hiders_found <= 8 then
				table.insert(prizes_per_player, 1)
				table.insert(prizes_per_player, 1)
			else
				table.insert(prizes_per_player, 4)
			end
		end

		for seeker, _ in pairs(inst.components.hideandseekgame.seekers) do
			for _, prize_size in ipairs(prizes_per_player) do
				GiveRedPouch(inst, seeker, prize_size, true)
			end
		end
	else
		local num_prizes = 1 + math.ceil(num_hiders_found / 2)
		local loots = weighted_random_choices(TUNING.KITCOON_HIDEANDSEEK_NOT_YOT_REWARDS, num_prizes)

		for i = 1, #loots do
			inst.components.lootdropper:SpawnLootPrefab(loots[i])
		end
	end

end

local function ontimerdone(inst, data)
	if data ~= nil then
		if data.name == "hideandseekover" then
			inst.components.hideandseekgame:Abort()

		elseif data.name == "hideandseekwarning" then
			for seeker, _ in pairs(inst.components.hideandseekgame.seekers) do
				if seeker.components.talker ~= nil then
					seeker.components.talker:Say(GetString(seeker, "ANNOUNCE_KITCOON_HIDANDSEEK_TIME_ALMOST_UP"))
				end
			end
		end
	end
end

-------------------------------------------------------------------------------
local function OverrideActivateVerb(inst, doer)
	return STRINGS.ACTIONS.ACTIVATE.HIDEANDSEEK
end

local function OnSave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function OnLoad(inst, data)
	if data ~= nil then
        if data.burnt and not inst:HasTag("burnt") then
            OnBurnt(inst)
        end
	end
end

local function OnLoadPostPass(inst, newents, data)
	if inst.components.hideandseekgame:IsActive() then
		inst.components.activatable.inactive = false
	end
end

local function getstatus(inst, viewer)
    return inst.components.timer:TimerExists("hideandseekwarning") and "PLAYING_HIDEANDSEEK"
			or inst.components.hideandseekgame:IsActive() and "PLAYING_HIDEANDSEEK_TIME_ALMOST_UP"
			or nil
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT] / 2) --match kit item
    MakeSmallObstaclePhysics(inst, .5)

    inst.MiniMapEntity:SetIcon("kitcoonden.png")

    inst.AnimState:SetBank("kitcoonden")
    inst.AnimState:SetBuild("kitcoonden")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("structure")
    inst:AddTag("kitcoonden")
    inst:AddTag("no_hideandseek")

    MakeSnowCoveredPristine(inst)

	inst.OverrideActivateVerb = OverrideActivateVerb

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -------------------
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    ---------------------
    inst:AddComponent("lootdropper")

    ---------------------
    MakeMediumBurnable(inst)
	inst.components.burnable:SetOnBurntFn(OnBurnt)

    MakeSmallPropagator(inst)

    ---------------------
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    ---------------------
    inst:AddComponent("kitcoonden")
	inst.components.kitcoonden.OnAddKitcoon = OnAddKitcoon
	inst.components.kitcoonden.OnRemoveKitcoon = OnRemoveKitcoon

    ---------------------
    -- for hide and seek game
	inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = OnActivate
    inst.components.activatable.inactive = false

    ---------------------
	inst:AddComponent("hideandseekgame")
	inst.components.hideandseekgame.OnHidingSpotFound = OnHidingSpotFound
	inst.components.hideandseekgame.OnHideAndSeekOver = OnHideAndSeekOver
	inst.components.hideandseekgame.OnAddSeeker = OnAddSeeker
	inst.components.hideandseekgame.hiding_range = TUNING.KITCOONDEN_HIDEANDSEEK_HIDING_RADIUS_MAX
	inst.components.hideandseekgame.hiding_range_toofar = TUNING.KITCOONDEN_HIDEANDSEEK_HIDING_RADIUS_MAX + 8
	inst.components.hideandseekgame.seeker_too_far_announce = "ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR"
	inst.components.hideandseekgame.seeker_too_far_return_announce = "ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR_RETURN"
	inst.components.hideandseekgame.gameaborted_announce = "ANNOUNCE_KITCOON_HIDANDSEEK_LOSEGAME"

    ---------------------
	inst:AddComponent("timer")
	inst:ListenForEvent("timerdone", ontimerdone)

    ---------------------
    inst:AddComponent("playerprox")
	inst.components.playerprox:SetTargetMode(inst.components.playerprox.TargetModes.AllPlayers)
    inst.components.playerprox:SetDist(TUNING.KITCOON_NEAR_DEN_DIST - 4,TUNING.KITCOON_NEAR_DEN_DIST - 1)
    inst.components.playerprox:SetOnPlayerNear(OnPlayerApproached)
    inst.components.playerprox:SetOnPlayerFar(OnPlayerLeft)
	inst.components.playerprox:SetPlayerAliveMode(inst.components.playerprox.AliveModes.AliveOnly)

    ---------------------
    MakeSnowCovered(inst)

    ---------------------
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
	inst.OnLoadPostPass = OnLoadPostPass

    ---------------------
    MakeHauntableWork(inst)

    ---------------------
    inst:ListenForEvent("onbuilt", onbuilt)
    inst:ListenForEvent("onremove", onremoved)

    return inst
end

return Prefab("kitcoonden", fn, assets, prefabs),
		MakeDeployableKitItem("kitcoonden_kit", "kitcoonden", "kitcoonden", "kitcoonden", "kit_item", assets, {size = "small", scale = 1.1}, nil, {fuelvalue = TUNING.SMALL_FUEL}),
		MakePlacer("kitcoonden_kit_placer", "kitcoonden", "kitcoonden", "placer")
