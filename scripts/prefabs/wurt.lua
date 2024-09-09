local MakePlayerCharacter = require("prefabs/player_common")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("ANIM", "anim/wurt_peruse.zip"),
    Asset("ANIM", "anim/wurt_mount_peruse.zip"),
    Asset("SOUND", "sound/wurt.fsb"),
    Asset("ANIM", "anim/player_idles_wurt.zip"),
    Asset("SCRIPT", "scripts/prefabs/skilltree_wurt.lua"),
}

local prefabs =
{
	"wurt_tentacle_warning",

    "wurt_water_splash_1",
    "wurt_water_splash_2",
    "wurt_water_splash_3",
    "merm_shadow",
    "mermguard_shadow",
    "merm_lunar",
    "mermguard_lunar",
}

local buff_prefabs =
{
    "wurt_shadow_merm_planar_fx",
    "wurt_lunar_merm_planar_fx",
}

local fxassets = 
{
    Asset("ANIM", "anim/merm_shadow_fx.zip"),
    Asset("ANIM", "anim/merm_lunar_fx.zip"),
}

local WURT_PATHFINDER_TILES = {
    WORLD_TILES.MARSH,
    WORLD_TILES.SHADOW_MARSH,
    WORLD_TILES.LUNAR_MARSH,
}

local function RemovePathFinderSkill(inst)
    if inst.pathfindertask ~= nil then
        inst.pathfindertask:Cancel()
        inst.pathfindertask = nil
    end

    for player in pairs(inst.pathfinder_players) do
        inst.pathfinder_players[player] = nil
        player.wurt_pathfinders[inst.GUID] = nil

        if not next(player.wurt_pathfinders) then
            player.wurt_pathfinders = nil
            
            if player:IsValid() and player.components.locomotor ~= nil then
                for _, tile in ipairs(WURT_PATHFINDER_TILES) do
                    player.components.locomotor:SetFasterOnGroundTile(tile, false)
                end
            end
        end
    end
end

local function PathFinderScanForPlayers(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local players = FindPlayersInRange(x, 0, z, TUNING.WURT_PATHFINDER_RANGE, true)

    for _, player in ipairs(players) do
        if not player:HasTag("merm") then
            inst.pathfinder_players[player] = true

            if player.wurt_pathfinders == nil then
                player.wurt_pathfinders = {}

                for _, tile in ipairs(WURT_PATHFINDER_TILES) do
                    player.components.locomotor:SetFasterOnGroundTile(tile, true)
                end
            end

            if player.wurt_pathfinders[inst.GUID] == nil then
                player.wurt_pathfinders[inst.GUID] = true
            end
        end
    end

    for player in pairs(inst.pathfinder_players) do
        if not table.contains(players, player) then
            inst.pathfinder_players[player] = nil
            player.wurt_pathfinders[inst.GUID] = nil

            if not next(player.wurt_pathfinders) then
                player.wurt_pathfinders = nil
                
                if player:IsValid() and player.components.locomotor ~= nil then
                    for _, tile in ipairs(WURT_PATHFINDER_TILES) do
                        player.components.locomotor:SetFasterOnGroundTile(tile, false)
                    end
                end
            end
        end
    end
end

local function RefreshPathFinderSkill(inst)
    local enabled = inst.components.skilltreeupdater ~= nil and inst.components.skilltreeupdater:IsActivated("wurt_pathfinder")

    if enabled then
        if inst.pathfindertask == nil then
            inst.pathfindertask = inst:DoPeriodicTask(1, inst.PathFinderScanForPlayers)
        end
    else
        inst:RemovePathFinderSkill()
    end
end

local start_inv = {}
for mode, starting_item_lists in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
	start_inv[string.lower(mode)] = starting_item_lists.WURT
end
prefabs = FlattenTree({ prefabs, start_inv }, true)

local function UpdateStats(inst, maxhealth, maxhunger, maxsanity)

    local current_health = inst.health_percent or inst.components.health:GetPercent()
    inst.health_percent = nil

    local current_hunger = inst.hunger_percent or inst.components.hunger:GetPercent()
    inst.hunger_percent = nil

    local current_sanity = inst.sanity_percent or inst.components.sanity:GetPercent()
    inst.sanity_percent = nil

    inst.components.health:SetMaxHealth(maxhealth)
    inst.components.hunger:SetMax(maxhunger)
    inst.components.sanity:SetMax(maxsanity)

    inst.components.health:SetPercent(current_health)
    inst.components.hunger:SetPercent(current_hunger)
    inst.components.sanity:SetPercent(current_sanity)
end

local function RoyalUpgrade(inst, silent)
    if inst._wurtloadtask ~= nil then
        inst._wurtloadtask:Cancel()
        inst._wurtloadtask = nil
    end
    inst.overrideskinmode = "powerup"
    inst.overrideskinmodebuild = "wurt_stage2"

    UpdateStats(inst, TUNING.WURT_HEALTH_KINGBONUS, TUNING.WURT_HUNGER_KINGBONUS, TUNING.WURT_SANITY_KINGBONUS)

    if not silent and not inst.royal then
        inst.royal = true
        inst.components.talker:Say(GetString(inst, "ANNOUNCE_KINGCREATED"))
        inst.sg:PushEvent("powerup_wurt")
        inst.SoundEmitter:PlaySound("dontstarve/characters/wurt/transform_to")
    end
end

local function RoyalDowngrade(inst, silent)
    if inst._wurtloadtask ~= nil then
        inst._wurtloadtask:Cancel()
        inst._wurtloadtask = nil
    end
    inst.overrideskinmode = nil
    inst.overrideskinmodebuild = nil

    UpdateStats(inst, TUNING.WURT_HEALTH, TUNING.WURT_HUNGER, TUNING.WURT_SANITY)

    if not silent and inst.royal then
        inst.royal = nil
        inst.components.talker:Say(GetString(inst, "ANNOUNCE_KINGDESTROYED"))
        inst.sg:PushEvent("powerdown_wurt")
        inst.SoundEmitter:PlaySound("dontstarve/characters/wurt/transform_from")
    end
end

-- Merm King quest upgrades
local TRIDENT_BUFF_NAME, TRIDENT_BUFF_PREFAB = "mermkingtridentbuff", "mermking_buff_trident"
local function TryRoyalUpgradeTrident(inst, silent)
    if not inst.components.skilltreeupdater:IsActivated("wurt_mermkingtrident")
            or not TheWorld.components.mermkingmanager
            or not TheWorld.components.mermkingmanager:HasTridentAnywhere() then
        return
    end
    inst:AddDebuff(TRIDENT_BUFF_NAME, TRIDENT_BUFF_PREFAB)

    if inst.components.leader then
        for follower in pairs(inst.components.leader.followers) do
            if follower.ismerm then
                follower:AddDebuff(TRIDENT_BUFF_NAME, TRIDENT_BUFF_PREFAB)
            end
        end
    end
end
local function TryRoyalDowngradeTrident(inst, silent)
    inst:RemoveDebuff(TRIDENT_BUFF_NAME)

    if inst.components.leader then
        for follower in pairs(inst.components.leader.followers) do
            follower:RemoveDebuff(TRIDENT_BUFF_NAME)
        end
    end
end

local CROWN_BUFF_NAME, CROWN_BUFF_PREFAB = "mermkingcrownbuff", "mermking_buff_crown"
local function TryRoyalUpgradeCrown(inst, silent)
    if not inst.components.skilltreeupdater:IsActivated("wurt_mermkingcrown")
            or not TheWorld.components.mermkingmanager
            or not TheWorld.components.mermkingmanager:HasCrownAnywhere() then
        return
    end
    inst:AddDebuff(CROWN_BUFF_NAME, CROWN_BUFF_PREFAB)

    if inst.components.leader then
        for follower in pairs(inst.components.leader.followers) do
            if follower.ismerm then
                follower:AddDebuff(CROWN_BUFF_NAME, CROWN_BUFF_PREFAB)
            end
        end
    end
end
local function TryRoyalDowngradeCrown(inst, silent)
    inst:RemoveDebuff(CROWN_BUFF_NAME)

    if inst.components.leader then
        for follower in pairs(inst.components.leader.followers) do
            follower:RemoveDebuff(CROWN_BUFF_NAME)
        end
    end
end

local PAULDRON_BUFF_NAME, PAULDRON_BUFF_PREFAB = "mermkingpauldronbuff", "mermking_buff_pauldron"
local function TryRoyalUpgradePauldron(inst, silent)
    if not inst.components.skilltreeupdater:IsActivated("wurt_mermkingshoulders")
            or not TheWorld.components.mermkingmanager
            or not TheWorld.components.mermkingmanager:HasPauldronAnywhere() then
        return
    end
    inst:AddDebuff(PAULDRON_BUFF_NAME, PAULDRON_BUFF_PREFAB)

    if inst.components.leader then
        for follower in pairs(inst.components.leader.followers) do
            if follower.ismerm then
                follower:AddDebuff(PAULDRON_BUFF_NAME, PAULDRON_BUFF_PREFAB)
            end
        end
    end
end
local function TryRoyalDowngradePauldron(inst, silent)
    inst:RemoveDebuff(PAULDRON_BUFF_NAME)

    if inst.components.leader then
        for follower in pairs(inst.components.leader.followers) do
            follower:RemoveDebuff(PAULDRON_BUFF_NAME)
        end
    end
end

local function additional_OnFollowerRemoved(inst, follower)
    if follower.ismerm then
        -- RemoveDebuff has checks built in if the buff isn't there!
        follower:RemoveDebuff(TRIDENT_BUFF_NAME)
        follower:RemoveDebuff(CROWN_BUFF_NAME)
        follower:RemoveDebuff(PAULDRON_BUFF_NAME)
    end

    if follower.ismerm and inst.components.skilltreeupdater ~= nil and inst.components.skilltreeupdater:IsActivated("wurt_shadow_allegiance_1") then
        follower.old_leader = inst

        follower:ListenForEvent("onremove", function() follower.old_leader = nil end, inst)
    end
end

local function additional_OnFollowerAdded(inst, follower)
    if follower.ismerm then
        local mermkingmanager = TheWorld.components.mermkingmanager
        if not mermkingmanager then return end

        local skilltreeupdater = inst.components.skilltreeupdater
        if skilltreeupdater:IsActivated("wurt_mermkingtrident") and mermkingmanager:HasTridentAnywhere() then
            follower:AddDebuff(TRIDENT_BUFF_NAME, TRIDENT_BUFF_PREFAB)
        end
        if skilltreeupdater:IsActivated("wurt_mermkingcrown") and mermkingmanager:HasCrownAnywhere() then
            follower:AddDebuff(CROWN_BUFF_NAME, CROWN_BUFF_PREFAB)
        end
        if skilltreeupdater:IsActivated("wurt_mermkingshoulders") and mermkingmanager:HasPauldronAnywhere() then
            follower:AddDebuff(PAULDRON_BUFF_NAME, PAULDRON_BUFF_PREFAB)
        end
    end
end

--
local function reset_active_warnings(inst)
    for _, warning in pairs(inst._active_warnings) do
        if warning:IsValid() then
            warning:Remove()
        end
    end
    inst._active_warnings = {}
end

local WARNING_MUST_TAGS = {"tentacle", "invisible"}
local function UpdateTentacleWarnings(inst)
	local disable = (inst.replica.inventory ~= nil and not inst.replica.inventory:IsVisible())

	if not disable then
		local old_warnings = {}
		for tentacle, warning in pairs(inst._active_warnings) do
			old_warnings[tentacle] = warning
		end

		local x, y, z = inst.Transform:GetWorldPosition()
		local warn_dist = 15
		local tentacles = TheSim:FindEntities(x, y, z, warn_dist, WARNING_MUST_TAGS)
		for _, tentacle in ipairs(tentacles) do
			if not IsEntityDead(tentacle, true) then
				if inst._active_warnings[tentacle] == nil then
					local fx = SpawnPrefab("wurt_tentacle_warning")
					fx.entity:SetParent(tentacle.entity)
					inst._active_warnings[tentacle] = fx
				else
					old_warnings[tentacle] = nil
				end
			end
		end

		for tentacle, warning in pairs(old_warnings) do
			inst._active_warnings[tentacle] = nil
			if warning:IsValid() then
				ErodeAway(warning, 0.5)
			end
		end
	elseif next(inst._active_warnings) ~= nil then
		reset_active_warnings(inst)
	end
end

local function DisableTentacleWarning(inst)
	if inst.tentacle_warning_task ~= nil then
		inst.tentacle_warning_task:Cancel()
		inst.tentacle_warning_task = nil
	end

    reset_active_warnings(inst)
end

local function EnableTentacleWarning(inst)
	if inst.player_classified ~= nil then
		inst:ListenForEvent("playerdeactivated", DisableTentacleWarning)
        inst.tentacle_warning_task = inst.tentacle_warning_task or inst:DoPeriodicTask(0.1, UpdateTentacleWarnings)
	else
	    inst:RemoveEventCallback("playeractivated", EnableTentacleWarning)
	end
end

local function FishPreserverRate(inst, item)
	return (item ~= nil and item:HasTag("fish")) and TUNING.WURT_FISH_PRESERVER_RATE or nil
end

local function OnSave(inst, data)
    data.health_percent = inst.health_percent or inst.components.health:GetPercent()
    data.sanity_percent = inst.sanity_percent or inst.components.sanity:GetPercent()
    data.hunger_percent = inst.hunger_percent or inst.components.hunger:GetPercent()
end

local function OnPreLoad(inst, data)
    if data then
        if data.health_percent then
            inst.health_percent = data.health_percent
        end

        if data.sanity_percent then
            inst.sanity_percent = data.sanity_percent
        end

        if data.hunger_percent then
            inst.hunger_percent = data.hunger_percent
        end
    end
end

local WURT_HOSTILITY_TAGS = {"hostile", "pig"}
local WURT_NONHOSTILITY_TAGS = {"merm", "manrabbit", "frog"}
local function CLIENT_Wurt_HostileTest(inst, target)
    return (target.HostileToPlayerTest ~= nil and target:HostileToPlayerTest(inst))
        or (target:HasAnyTag(WURT_HOSTILITY_TAGS) and not target:HasAnyTag(WURT_NONHOSTILITY_TAGS))
end

local function common_postinit(inst)
    inst:AddTag("playermerm")
    inst:AddTag("merm")
    inst:AddTag("mermguard")
    inst:AddTag("mermfluent")
    inst:AddTag("merm_builder")
    inst:AddTag("wet")
    inst:AddTag("stronggrip")

    inst.customidleanim = "idle_wurt"

    inst.AnimState:AddOverrideBuild("wurt_peruse")
    inst.AnimState:SetHatOffset(0, 20) -- This is not networked.

    if TheNet:GetServerGameMode() == "lavaarena" then
        --do nothing
    elseif TheNet:GetServerGameMode() == "quagmire" then
        inst:AddTag("quagmire_shopper")
    else
		if not TheNet:IsDedicated() then
			inst._active_warnings = {}
			inst:ListenForEvent("playeractivated", EnableTentacleWarning)
		end
	end

    --reader (from reader component) added to pristine state for optimization
    inst:AddTag("reader")

    --aspiring_bookworm (from reader component) added to pristine state for optimization
    inst:AddTag("aspiring_bookworm")

    inst.HostileTest = CLIENT_Wurt_HostileTest
end

local function IsNonPlayerMerm(this)
    return this:HasTag("merm") and not this:HasTag("player")
end

local MAX_TARGET_SHARES = 8
local SHARE_TARGET_DIST = 20

local function OnAttacked(inst, data)
    local attacker = data and data.attacker
    if attacker and inst.components.combat:CanTarget(attacker) then
        inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, IsNonPlayerMerm, MAX_TARGET_SHARES)
    end
end

local function no_holes(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end
local function OnAttackOther(inst, data)
    local victim = data.target
    if not victim then return end

    if inst.components.skilltreeupdater:IsActivated("wurt_shadow_allegiance_2") and math.random() > TUNING.WURT_TERRAFORMING_SHADOW_PROCCHANCE then
        local tile_type = inst:GetCurrentTileType()
        if tile_type == WORLD_TILES.SHADOW_MARSH then
            local pt = victim:GetPosition()
            local offset = FindWalkableOffset(pt, math.random() * TWOPI, 2, 3, false, true, no_holes, false, true)
            if offset ~= nil then
                inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_1")
                inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_2")
                local tentacle = SpawnPrefab("shadowtentacle")
                if tentacle ~= nil then
                    tentacle.owner = inst
                    tentacle.Transform:SetPosition(pt.x + offset.x, 0, pt.z + offset.z)
                    tentacle.components.combat:SetTarget(victim)
                end
            end
        end
    end
end

-------------------------------------------------------------------------------------------------------------

local NUM_SPLASH_FX = 3

local function RedirectDamageToMoisture(inst, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
    if ignore_absorb or amount >= 0 or overtime or afflicter == nil then
        return amount
    end

    local moisture = inst.components.moisture:GetMoisture()

    local level = moisture > 0 and inst.components.skilltreeupdater:CountSkillTag("wetness_defense") or 0

    if level <= 0 then
        return amount
    end

    local rate = TUNING.SKILLS.WURT.WETNESS_MOISTURE_ABSORBTION[level]
    local absorbtion = math.min(-amount, moisture / rate)

    inst.components.moisture:DoDelta(-absorbtion * rate)

    ---- FX -----

    local max_absorbtion = TUNING.MAX_WETNESS / rate
    local fx_size = math.ceil(Lerp(0, NUM_SPLASH_FX, absorbtion / max_absorbtion))

    local fx = SpawnPrefab("wurt_water_splash_"..fx_size)

    if fx ~= nil then
        inst:AddChild(fx)
    end

    --------------

    --print(string.format("Trading %2.2f moisture for %2.2f life! Took %2.2f damage. Original damage was %2.2f.", absorbtion * rate, absorbtion, amount + absorbtion, amount))

    return amount + absorbtion
end

local function OnRespawnedFromGhost(inst)
    inst:RemoveEventCallback("ms_respawnedfromghost", inst._onrespawnedfromghost)
    inst._onrespawnedfromghost = nil

    inst:RefreshWetnessSkills()
end

local function OnAllegianceMarshTile(inst, ontile)
    if inst.components.moisture == nil then
        return
    end

    if ontile then
        inst.components.moisture:AddRateBonus(inst, TUNING.SKILLS.WURT.ALLEGIANCE_MARSHTILE_MOISTURE_RATE, "marsh_wetness")
    else
        inst.components.moisture:RemoveRateBonus(inst, "marsh_wetness")
    end
end

local function OnWetnessChanged(inst, data)
    local percent = inst.components.moisture:GetMoisturePercent()
    local skilltreeupdater = inst.components.skilltreeupdater

    local valid = percent > 0 

    local sanity     = valid and skilltreeupdater:CountSkillTag("wetness_sanity" ) or 0
    local healing    = valid and skilltreeupdater:CountSkillTag("wetness_healing") or 0
    local absorbtion = valid and skilltreeupdater:CountSkillTag("wetness_defense") or 0

    if sanity > 0 then
        inst.components.sanity.externalmodifiers:SetModifier(inst, TUNING.SKILLS.WURT.WETNESS_SANITY_DAPPERNESS[sanity] * percent, "wetness_skill")
    else
        inst.components.sanity.externalmodifiers:RemoveModifier(inst, "wetness_skill")
    end

    if healing > 0 then
        local tuning = TUNING.SKILLS.WURT.WETNESS_MOISTURE_HEALING[healing]
        inst.components.health:AddRegenSource(inst, tuning.amount * RoundToNearest(percent, .1), tuning.period, "wetness_skill")
    else
        inst.components.health:RemoveRegenSource(inst, "wetness_skill")
    end

    if absorbtion > 0 then
        inst.components.health.deltamodifierfn = RedirectDamageToMoisture
    else
        inst.components.health.deltamodifierfn = nil
    end
end

local function RefreshWetnessSkills(inst)
    local is_dead = inst:HasTag("playerghost") or inst.components.health:IsDead()

    if inst._onrespawnedfromghost == nil and is_dead then
        inst._onrespawnedfromghost = OnRespawnedFromGhost

        inst:ListenForEvent("ms_respawnedfromghost", inst._onrespawnedfromghost)
    end

    local skilltreeupdater = inst.components.skilltreeupdater

    if not is_dead and skilltreeupdater ~= nil and skilltreeupdater:CountSkillTag("amphibian") > 0 then
        if inst._onmoisturedelta == nil then
            inst._onmoisturedelta = OnWetnessChanged

            inst:ListenForEvent("moisturedelta",  inst._onmoisturedelta    )
            inst:ListenForEvent("ms_becameghost", inst.RefreshWetnessSkills)

            inst._onmoisturedelta(inst)
        end

    elseif inst._onmoisturedelta ~= nil then
        inst:RemoveEventCallback("moisturedelta",  inst._onmoisturedelta    )
        inst:RemoveEventCallback("ms_becameghost", inst.RefreshWetnessSkills)

        inst._onmoisturedelta(inst)

        inst._onmoisturedelta = nil
    end

    local areaaware = inst.components.areaaware

    if areaaware == nil then
        return
    end

    -- The WORLD_TILES.LUNAR_MARSH watcher has already been started by all players.
    if not is_dead and skilltreeupdater:HasSkillTag("marsh_wetness") then
        if inst._onallegiancemarshtile == nil then
            inst._onallegiancemarshtile = OnAllegianceMarshTile
            inst.components.areaaware:StartWatchingTile(WORLD_TILES.SHADOW_MARSH)

            inst:ListenForEvent("on_LUNAR_MARSH_tile",  inst._onallegiancemarshtile)
            inst:ListenForEvent("on_SHADOW_MARSH_tile", inst._onallegiancemarshtile)

            inst.components.areaaware:_ForceUpdate() -- Test for effects.
        end

    elseif inst._onallegiancemarshtile ~= nil then
        inst.components.areaaware:StopWatchingTile(WORLD_TILES.SHADOW_MARSH)

        inst:RemoveEventCallback("on_LUNAR_MARSH_tile",  inst._onallegiancemarshtile)
        inst:RemoveEventCallback("on_SHADOW_MARSH_tile", inst._onallegiancemarshtile)

        inst._onallegiancemarshtile(inst, false) -- Remove effects.

        inst._onallegiancemarshtile = nil
    end
end

--
local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    inst.RefreshWetnessSkills = RefreshWetnessSkills
    inst.RemovePathFinderSkill = RemovePathFinderSkill

    inst.OnDespawn = inst.RemovePathFinderSkill

    inst:AddComponent("reader")
    inst.components.reader:SetAspiringBookworm(true)

	inst.components.sanity.no_moisture_penalty = true

    -- Keep in sync with merm + mermking (minus bonuses for TUNING balancing)!
    local foodaffinity = inst.components.foodaffinity
    foodaffinity:AddFoodtypeAffinity(FOODTYPE.VEGGIE,    1.33)
    foodaffinity:AddPrefabAffinity  ("kelp",             1.33) -- prevents the negative stats, otherwise foodtypeaffinity would have suffice
    foodaffinity:AddPrefabAffinity  ("kelp_cooked",      1.33) -- prevents the negative stats, otherwise foodtypeaffinity would have suffice
    foodaffinity:AddPrefabAffinity  ("boatpatch_kelp",   1.33) -- prevents the negative stats, otherwise foodtypeaffinity would have suffice
    foodaffinity:AddPrefabAffinity  ("durian",           1.93) -- veggi bonus + 15
    foodaffinity:AddPrefabAffinity  ("durian_cooked",    1.93) -- veggi bonus + 15

    local itemaffinity = inst:AddComponent("itemaffinity")
    itemaffinity:AddAffinity("hutch_fishbowl", nil, TUNING.DAPPERNESS_MED, 1)
    itemaffinity:AddAffinity(nil, "fish", TUNING.DAPPERNESS_MED, 1)
    itemaffinity:AddAffinity(nil, "fishmeat", -TUNING.DAPPERNESS_MED_LARGE, 2)
    itemaffinity:AddAffinity(nil, "spoiled_fish", -TUNING.DAPPERNESS_MED_LARGE, 2)

	inst:AddComponent("preserver")
	inst.components.preserver:SetPerishRateMultiplier(FishPreserverRate)

    if inst.components.eater ~= nil then
        inst.components.eater:SetDiet({ FOODGROUP.VEGETARIAN }, { FOODGROUP.VEGETARIAN })
    end

    for _, tile in ipairs(WURT_PATHFINDER_TILES) do
       inst.components.locomotor:SetFasterOnGroundTile(tile, true)
    end

    inst.components.builder.mashturfcrafting_bonus = 2

    inst.additional_OnFollowerRemoved = additional_OnFollowerRemoved
    inst.additional_OnFollowerAdded = additional_OnFollowerAdded

    inst:ListenForEvent("onmermkingcreated_anywhere", function() RoyalUpgrade(inst) end, TheWorld)
    inst:ListenForEvent("onmermkingdestroyed_anywhere", function() RoyalDowngrade(inst) end, TheWorld)
    inst:ListenForEvent("onmermkingtridentadded_anywhere", function() TryRoyalUpgradeTrident(inst) end, TheWorld)
    inst:ListenForEvent("onmermkingtridentremoved_anywhere", function() TryRoyalDowngradeTrident(inst) end, TheWorld)
    inst:ListenForEvent("onmermkingcrownadded_anywhere", function() TryRoyalUpgradeCrown(inst) end, TheWorld)
    inst:ListenForEvent("onmermkingcrownremoved_anywhere", function() TryRoyalDowngradeCrown(inst) end, TheWorld)
    inst:ListenForEvent("onmermkingpauldronadded_anywhere", function() TryRoyalUpgradePauldron(inst) end, TheWorld)
    inst:ListenForEvent("onmermkingpauldronremoved_anywhere", function() TryRoyalDowngradePauldron(inst) end, TheWorld)

    inst:ListenForEvent("onattackother", OnAttackOther)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("ms_playerreroll", inst.RemovePathFinderSkill)

    inst.OnSave = OnSave
    inst.OnPreLoad = OnPreLoad

    inst.pathfinder_players = {}
    inst.PathFinderScanForPlayers = PathFinderScanForPlayers
    inst.RefreshPathFinderSkill = RefreshPathFinderSkill

    inst.TryTridentUpgrade = TryRoyalUpgradeTrident
    inst.TryTridentDowngrade = TryRoyalDowngradeTrident
    inst.TryCrownUpgrade = TryRoyalUpgradeCrown
    inst.TryCrownDowngrade = TryRoyalDowngradeCrown
    inst.TryPauldronUpgrade = TryRoyalUpgradePauldron
    inst.TryPauldronDowngrade = TryRoyalDowngradePauldron

    inst._wurtloadtask = inst:DoTaskInTime(0, (TheWorld.components.mermkingmanager ~= nil
            and TheWorld.components.mermkingmanager:HasKingAnywhere()
            and RoyalUpgrade)
        or RoyalDowngrade
    )
end


local function OnAttached(inst, target)
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0) --in case of loading
    inst:ListenForEvent("death", function()
        inst.components.debuff:Stop()
    end, target)

    inst.components.timer:StartTimer("expire", TUNING.WURT_PLANAR_TIME_BUFF_LASTS)

    if target ~= nil and target:IsValid() and target.components.combat ~= nil then
        target.components.planardamage:SetBaseDamage(TUNING.WURT_PLANAR_BUFF_DAMAGE)
        target.components.combat:SetDefaultDamage(target:MermDamageCalculator())

        if target:HasTag("shadowminion") then
            local fx = SpawnPrefab("wurt_shadow_merm_planar_fx")
            fx.SoundEmitter:PlaySound("meta4/shadow_merm/buff_idle", "loop")

            inst.bufffx = fx
            fx.AnimState:PlayAnimation("buff_pre")
            fx.AnimState:PushAnimation("buff_idle")
            fx.entity:SetParent(target.entity)
            target.planarbuffed:set(true)

        elseif target:HasTag("lunarminion") then
            local fx = SpawnPrefab("wurt_lunar_merm_planar_fx")
            inst.bufffx = fx
            fx.entity:SetParent(target.entity)
            target:updateeyebuild()
            target.planarbuffed:set(true)
            target.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
            
            target.SoundEmitter:PlaySound("meta4/lunar_merm/buff")
        end
    end
end

local function OnDetached(inst, target)
    if target ~= nil and target:IsValid() and target.components.combat ~= nil then
        target.components.planardamage:SetBaseDamage(0)
        target.components.combat:SetDefaultDamage(target:MermDamageCalculator())
    end
    if target:HasTag("shadowminion") then
        if inst.bufffx and inst.bufffx:IsValid() then
            local fx = inst.bufffx
            fx.SoundEmitter:KillSound("loop")
            fx.AnimState:PlayAnimation("buff_pst")
            fx.SoundEmitter:PlaySound("meta4/shadow_merm/buff_pst")
            fx:ListenForEvent("animover", function() fx:Remove() end)
        end

        target.planarbuffed:set(false)

    elseif target:HasTag("lunarminion") then
        target:updateeyebuild()
        target.planarbuffed:set(false)
        target.AnimState:ClearBloomEffectHandle()

        local fx = SpawnPrefab("wurt_lunar_merm_planar_fx")
        fx.AnimState:PlayAnimation("pst")
        fx:ListenForEvent("animover", function() fx:Remove() end)
        fx.entity:SetParent(target.entity)
    end
    inst.bufffx = nil
    inst:Remove()
end

local function OnExtendedBuff(inst)
    if inst.bufftask ~= nil then
        inst.bufftask:Cancel()
        inst.bufftask = inst:DoTaskInTime(TUNING.WURT_PLANAR_TIME_BUFF_LASTS, OnKillBuff)
    end
end

local function bufffn()
    local inst = CreateEntity()

    if not TheWorld.ismastersim then
        --Not meant for client!
        inst:DoTaskInTime(0, inst.Remove)
        return inst
    end

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst.persists = false

    inst:AddTag("CLASSIFIED")

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", function() inst.components.debuff:Stop() end)

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(OnDetached)
    inst.components.debuff:SetExtendedFn(OnExtendedBuff)
    inst.components.debuff.keepondespawn = true

    return inst
end

local function shadowbufffn_fx()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddFollower()
    inst.entity:AddSoundEmitter()

    inst:AddTag("FX")

    inst.AnimState:SetBank("merm_shadow_fx")
    inst.AnimState:SetBuild("merm_shadow_fx")
    inst.AnimState:PlayAnimation("buff_idle",true)

    inst.AnimState:SetSymbolLightOverride("horror_fx", 1)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function lunarbufffn_fx()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddFollower()

    inst:AddTag("FX")

    inst.AnimState:SetBank("lunar_fx")
    inst.AnimState:SetBuild("merm_lunar_fx")
    inst.AnimState:PlayAnimation("pre")

    inst.AnimState:SetSymbolLightOverride("lunar_fx", 1)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("animover", function() inst:Remove() end)

    inst.persists = false

    return inst
end

return MakePlayerCharacter("wurt", prefabs, assets, common_postinit, master_postinit),
    Prefab("wurt_merm_planar", bufffn, nil, buff_prefabs),
    Prefab("wurt_shadow_merm_planar_fx", shadowbufffn_fx, fxassets),
    Prefab("wurt_lunar_merm_planar_fx", lunarbufffn_fx, fxassets)