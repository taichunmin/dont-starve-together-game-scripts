local MakePlayerCharacter = require("prefabs/player_common")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("ANIM", "anim/wurt_peruse.zip"),
    Asset("ANIM", "anim/wurt_mount_peruse.zip"),
    Asset("SOUND", "sound/wurt.fsb"),
    Asset("ANIM", "anim/player_idles_wurt.zip"),
}

local prefabs =
{
	"wurt_tentacle_warning",
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
	start_inv[string.lower(k)] = v.WURT
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

local WARNING_MUST_TAGS = {"tentacle", "invisible"}
local function UpdateTentacleWarnings(inst)
	local disable = (inst.replica.inventory ~= nil and not inst.replica.inventory:IsVisible())

	if not disable then
		local old_warnings = {}
		for t, w in pairs(inst._active_warnings) do
			old_warnings[t] = w
		end

		local x, y, z = inst.Transform:GetWorldPosition()
		local warn_dist = 15
		local tentacles = TheSim:FindEntities(x, y, z, warn_dist, WARNING_MUST_TAGS)
		for i, t in ipairs(tentacles) do
			local p1x, p1y, p1z = inst.Transform:GetWorldPosition()
			local p2x, p2y, p2z = t.Transform:GetWorldPosition()
			local dist = VecUtil_Length(p1x - p2x, p1z - p2z)

			if not IsEntityDead(t, true) then
				if inst._active_warnings[t] == nil then
					local fx = SpawnPrefab("wurt_tentacle_warning")
					fx.entity:SetParent(t.entity)
					inst._active_warnings[t] = fx
				else
					old_warnings[t] = nil
				end
			end
		end

		for t, w in pairs(old_warnings) do
			inst._active_warnings[t] = nil
			if w:IsValid() then
				ErodeAway(w, 0.5)
			end
		end
	elseif next(inst._active_warnings) ~= nil then
		for t, w in pairs(inst._active_warnings) do
			if w:IsValid() then
				w:Remove()
			end
		end
		inst._active_warnings = {}
	end
end

local function DisableTentacleWarning(inst)
	if inst.tentacle_warning_task ~= nil then
		inst.tentacle_warning_task:Cancel()
		inst.tentacle_warning_task = nil
	end

	for t, w in pairs(inst._active_warnings) do
		if w:IsValid() then
			w:Remove()
		end
	end
	inst._active_warnings = {}
end

local function EnableTentacleWarning(inst)
	if inst.player_classified ~= nil then
		inst:ListenForEvent("playerdeactivated", DisableTentacleWarning)
		if inst.tentacle_warning_task == nil then
			inst.tentacle_warning_task = inst:DoPeriodicTask(0.1, UpdateTentacleWarnings)
		end
	else
	    inst:RemoveEventCallback("playeractivated", EnableTentacleWarning)
	end
end

local function SetGhostMode(inst, isghost)
    if isghost then
		DisableTentacleWarning(inst)
        inst._SetGhostMode(inst, true)
    else
        inst._SetGhostMode(inst, false)
		EnableTentacleWarning(inst)
    end
end

local function FishPreserverRate(inst, item)
	return (item ~= nil and item:HasTag("fish")) and TUNING.WURT_FISH_PRESERVER_RATE or nil
end

-- PERUSE BOOKS
local function peruse_brimstone(inst)
    inst.components.sanity:DoDelta(-TUNING.SANITY_LARGE)
end
local function peruse_birds(inst)
    inst.components.sanity:DoDelta(TUNING.SANITY_HUGE)
end
local function peruse_tentacles(inst)
    inst.components.sanity:DoDelta(TUNING.SANITY_HUGE)
end
local function peruse_sleep(inst)
    inst.components.sanity:DoDelta(TUNING.SANITY_LARGE)
end
local function peruse_gardening(inst)
    inst.components.sanity:DoDelta(-TUNING.SANITY_LARGE)
end
local function peruse_horticulture(inst)
    inst.components.sanity:DoDelta(-TUNING.SANITY_LARGE)
end
local function peruse_silviculture(inst)
    inst.components.sanity:DoDelta(-TUNING.SANITY_LARGE)
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

local function CLIENT_Wurt_HostileTest(inst, target)
    return (target:HasTag("hostile") or target:HasTag("pig"))
        and not target:HasTag("merm") and not target:HasTag("manrabbit")
        and not target:HasTag("frog")
end

local function common_postinit(inst)
    inst:AddTag("playermerm")
    inst:AddTag("merm")
    inst:AddTag("mermguard")
    inst:AddTag("mermfluent")
    inst:AddTag("merm_builder")
    inst:AddTag("wet")
    inst:AddTag("stronggrip")
    inst:AddTag("aspiring_bookworm")

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

local function OnRepelMerm(doer, follower)
    if follower.DoDisapproval then
        follower:DoDisapproval()
    end
end

local function OnMurdered(inst, data)
    local victim = data.victim
    if inst.components.repellent and
        victim ~= nil  and victim:IsValid() and
        victim:HasTag("fish") and
        not inst.components.health:IsDead() then
        -- This act is not looked too highly upon.
        inst.components.repellent:Repel(inst)
    end
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    inst:AddComponent("reader")

	inst.components.sanity.no_moisture_penalty = true

    -- Keep in sync with merm + mermking (minus bonuses for TUNING balancing)!
    inst.components.foodaffinity:AddFoodtypeAffinity(FOODTYPE.VEGGIE, 1.33)
    inst.components.foodaffinity:AddPrefabAffinity  ("kelp",          1.33) -- prevents the negative stats, otherwise foodtypeaffinity would have suffice
    inst.components.foodaffinity:AddPrefabAffinity  ("kelp_cooked",   1.33) -- prevents the negative stats, otherwise foodtypeaffinity would have suffice
    inst.components.foodaffinity:AddPrefabAffinity  ("durian",        1.93) -- veggi bonus + 15
    inst.components.foodaffinity:AddPrefabAffinity  ("durian_cooked", 1.93) -- veggi bonus + 15

    inst:AddComponent("itemaffinity")
    inst.components.itemaffinity:AddAffinity("hutch_fishbowl", nil, TUNING.DAPPERNESS_MED, 1)
    inst.components.itemaffinity:AddAffinity(nil, "fish", TUNING.DAPPERNESS_MED, 1)
    inst.components.itemaffinity:AddAffinity(nil, "fishmeat", -TUNING.DAPPERNESS_MED_LARGE, 2)
    inst.components.itemaffinity:AddAffinity(nil, "spoiled_fish", -TUNING.DAPPERNESS_MED_LARGE, 2)

	inst:AddComponent("preserver")
	inst.components.preserver:SetPerishRateMultiplier(FishPreserverRate)

    inst:AddComponent("repellent")
    inst.components.repellent:AddRepelTag("merm")
    inst.components.repellent:AddIgnoreTag("mermking")
    inst.components.repellent:SetOnlyRepelsFollowers(true)
    inst.components.repellent:SetOnRepelFollowerFn(OnRepelMerm)

    if inst.components.eater ~= nil then
        inst.components.eater:SetDiet({ FOODGROUP.VEGETARIAN }, { FOODGROUP.VEGETARIAN })
    end

	inst.components.locomotor:SetFasterOnGroundTile(GROUND.MARSH, true)

    inst.components.builder.mashturfcrafting_bonus = 2

    inst:ListenForEvent("onmermkingcreated", function() RoyalUpgrade(inst) end, TheWorld)
    inst:ListenForEvent("onmermkingdestroyed", function() RoyalDowngrade(inst) end, TheWorld)
    inst:ListenForEvent("onattacked", OnAttacked)
    inst:ListenForEvent("murdered", OnMurdered)

    inst.peruse_brimstone = peruse_brimstone
    inst.peruse_birds = peruse_birds
    inst.peruse_tentacles = peruse_tentacles
    inst.peruse_sleep = peruse_sleep
    inst.peruse_gardening = peruse_gardening
	inst.peruse_horticulture = peruse_horticulture
	inst.peruse_silviculture = peruse_silviculture

    inst.OnSave = OnSave
    inst.OnPreLoad = OnPreLoad

    if TheWorld.components.mermkingmanager and TheWorld.components.mermkingmanager:HasKing() then
        inst:DoTaskInTime(0, function() RoyalUpgrade(inst) end)
    else
        inst:DoTaskInTime(0, function() RoyalDowngrade(inst) end)
    end
end

return MakePlayerCharacter("wurt", prefabs, assets, common_postinit, master_postinit)