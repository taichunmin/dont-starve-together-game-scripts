local MakePlayerCharacter = require("prefabs/player_common")
local SourceModifierList = require("util/sourcemodifierlist")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("ANIM", "anim/player_idles_walter.zip"),
    Asset("SOUND", "sound/walter.fsb"),
}

local prefabs =
{
    "wobybig",
    "wobysmall",
	"walter_campfire_story_proxy",
    "portabletent",
    "portabletent_item",
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.WALTER
end

prefabs = FlattenTree({ prefabs, start_inv }, true)

local function StoryTellingDone(inst, story)
	if inst._story_proxy ~= nil and inst._story_proxy:IsValid() then
		inst._story_proxy:Remove()
		inst._story_proxy = nil
	end
end

local function StoryToTellFn(inst, story_prop)
	if not TheWorld.state.isnight then
		return "NOT_NIGHT"
	end

	local fueled = story_prop ~= nil and story_prop.components.fueled or nil
	if fueled ~= nil and story_prop:HasTag("campfire") then
		if fueled:IsEmpty() then
			return "NO_FIRE"
		end

		local campfire_stories = STRINGS.STORYTELLER.WALTER["CAMPFIRE"]
		if campfire_stories ~= nil then
			if inst._story_proxy ~= nil then
				inst._story_proxy:Remove()
				inst._story_proxy = nil
			end
			inst._story_proxy = SpawnPrefab("walter_campfire_story_proxy")
			inst._story_proxy:Setup(inst, story_prop)

			local story_id = GetRandomKey(campfire_stories)
			return { style = "CAMPFIRE", id = story_id, lines = campfire_stories[story_id].lines }
		end
	end

	return nil
end

local function OnHealthDelta(inst, data)
    if data.amount < 0 then
        inst.components.sanity:DoDelta(data.amount * ((data ~= nil and data.overtime) and TUNING.WALTER_SANITY_DAMAGE_OVERTIME_RATE or TUNING.WALTER_SANITY_DAMAGE_RATE) * inst._sanity_damage_protection:Get())
    end
end

local function startsong(inst)
	inst:RemoveEventCallback("animqueueover", startsong)
	if inst.AnimState:AnimDone() then
		inst:PushEvent("singsong", {sound = "dontstarve/characters/walter/song", lines = STRINGS.SONGS.WALTER_GLOMMER_GUTS.lines})
	end
end

local function oneat(inst, food)
	if food ~= nil and food:IsValid() and (food.prefab == "glommerfuel" or food:HasTag("tallbirdegg")) then
        inst:ListenForEvent("animqueueover", startsong)
	end
end

local REQUIRED_TREE_TAGS = { "tree" }
local EXCLUDE_TREE_TAGS = { "burnt", "stump", "fire" }

local function UpdateTreeSanityGain(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local num_trees = #TheSim:FindEntities(x, y, z, TUNING.WALTER_TREE_SANITY_RADIUS, REQUIRED_TREE_TAGS, EXCLUDE_TREE_TAGS)
    inst._tree_sanity_gain = num_trees >= TUNING.WALTER_TREE_SANITY_THRESHOLD and TUNING.WALTER_TREE_SANITY_BONUS or 0
end

local function CustomSanityFn(inst, dt)
    local health_drain = (1 - inst.components.health:GetPercentWithPenalty()) * TUNING.WALTER_SANITY_HEALTH_DRAIN * inst._sanity_damage_protection:Get()

    return inst._tree_sanity_gain - health_drain
end

local function SpawnWoby(inst)
    local player_check_distance = 40
    local attempts = 0

    local max_attempts = 30
    local x, y, z = inst.Transform:GetWorldPosition()

    local woby = SpawnPrefab(TUNING.WALTER_STARTING_WOBY)
	inst.woby = woby
	woby:LinkToPlayer(inst)
    inst:ListenForEvent("onremove", inst._woby_onremove, woby)

    while true do
        local offset = FindWalkableOffset(inst:GetPosition(), math.random() * PI, player_check_distance + 1, 10)

        if offset then
            local spawn_x = x + offset.x
            local spawn_z = z + offset.z

            if attempts >= max_attempts then
                woby.Transform:SetPosition(spawn_x, y, spawn_z)
                break
            elseif not IsAnyPlayerInRange(spawn_x, 0, spawn_z, player_check_distance) then
                woby.Transform:SetPosition(spawn_x, y, spawn_z)
                break
            else
                attempts = attempts + 1
            end
        elseif attempts >= max_attempts then
            woby.Transform:SetPosition(x, y, z)
            break
        else
            attempts = attempts + 1
        end
    end

    return woby
end

local function ResetOrStartWobyBuckTimer(inst)
	if inst.components.timer:TimerExists("wobybuck") then
		inst.components.timer:SetTimeLeft("wobybuck", TUNING.WALTER_WOBYBUCK_DECAY_TIME)
	else
		inst.components.timer:StartTimer("wobybuck", TUNING.WALTER_WOBYBUCK_DECAY_TIME)
	end
end

local function OnTimerDone(inst, data)
	if data and data.name == "wobybuck" then
		inst._wobybuck_damage = 0
	end
end

local function OnAttacked(inst, data)
    if inst.components.rider:IsRiding() then
        local mount = inst.components.rider:GetMount()
        if mount:HasTag("woby") then
			local damage = data and data.damage or TUNING.WALTER_WOBYBUCK_DAMAGE_MAX * 0.5 -- Fallback in case of mods.
			inst._wobybuck_damage = inst._wobybuck_damage + damage
			if inst._wobybuck_damage >= TUNING.WALTER_WOBYBUCK_DAMAGE_MAX then
				inst.components.timer:StopTimer("wobybuck")
				inst._wobybuck_damage = 0
				mount.components.rideable:Buck()
			else
				ResetOrStartWobyBuckTimer(inst)
			end
        end
    end
end

local function OnWobyTransformed(inst, woby)
	if inst.woby ~= nil then
		inst:RemoveEventCallback("onremove", inst._woby_onremove, inst.woby)
	end

	inst.woby = woby
	inst:ListenForEvent("onremove", inst._woby_onremove, woby)
end

local function OnWobyRemoved(inst)
	inst.woby = nil
	inst._replacewobytask = inst:DoTaskInTime(1, function(i) i._replacewobytask = nil if i.woby == nil then SpawnWoby(i) end end)
end

local function OnRemoveEntity(inst)
	-- hack to remove pets when spawned due to session state reconstruction for autosave snapshots
	if inst.woby ~= nil and inst.woby.spawntime == GetTime() then
		inst:RemoveEventCallback("onremove", inst._woby_onremove, inst.woby)
		inst.woby:Remove()
	end

	if inst._story_proxy ~= nil and inst._story_proxy:IsValid() then
		inst._story_proxy:Remove()
	end
end

local function OnDespawn(inst)
    if inst.woby ~= nil then
		inst.woby:OnPlayerLinkDespawn()
        inst.woby:PushEvent("player_despawn")
    end
end

local function OnReroll(inst)
    if inst.woby ~= nil then
		inst.woby:OnPlayerLinkDespawn(true)
    end
end

local function OnSave(inst, data)
	data.woby = inst.woby ~= nil and inst.woby:GetSaveRecord() or nil
	data.buckdamage = inst._wobybuck_damage > 0 and inst._wobybuck_damage or nil
end

local function OnLoad(inst, data)
	if data ~= nil then
		if data.woby ~= nil then
			inst._woby_spawntask:Cancel()
			inst._woby_spawntask = nil

			local woby = SpawnSaveRecord(data.woby)
			inst.woby = woby
			if woby ~= nil then
				if inst.migrationpets ~= nil then
					table.insert(inst.migrationpets, woby)
				end
				woby:LinkToPlayer(inst)

				woby.AnimState:SetMultColour(0,0,0,1)
				woby.components.colourtweener:StartTween({1,1,1,1}, 19*FRAMES)
				local fx = SpawnPrefab(woby.spawnfx)
				fx.entity:SetParent(woby.entity)

				inst:ListenForEvent("onremove", inst._woby_onremove, woby)
			end
		end
		inst._wobybuck_damage = data.buckdamage or 0
	end
end

local function GetEquippableDapperness(owner, equippable)
	if equippable.is_magic_dapperness then
		return equippable:GetDapperness(owner, owner.components.sanity.no_moisture_penalty)
	end

	return 0
end

local function common_postinit(inst)
    inst:AddTag("expertchef")
    inst:AddTag("pebblemaker")
    inst:AddTag("pinetreepioneer")
    inst:AddTag("allergictobees")
    inst:AddTag("slingshot_sharpshooter")
    inst:AddTag("efficient_sleeper")
    inst:AddTag("dogrider")
    inst:AddTag("nowormholesanityloss")
	inst:AddTag("storyteller") -- for storyteller component

    inst.customidleanim = "idle_walter"

    if TheNet:GetServerGameMode() == "lavaarena" then
        --do nothing
    elseif TheNet:GetServerGameMode() == "quagmire" then
        inst:AddTag("quagmire_shopper")
    end
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    inst.components.health:SetMaxHealth(TUNING.WALTER_HEALTH)
    inst.components.hunger:SetMax(TUNING.WALTER_HUNGER)
    inst.components.sanity:SetMax(TUNING.WALTER_SANITY)

    inst.components.sanity.custom_rate_fn = CustomSanityFn
    inst.components.sanity:SetNegativeAuraImmunity(true)
    inst.components.sanity:SetPlayerGhostImmunity(true)
    inst.components.sanity:SetLightDrainImmune(true)
	inst.components.sanity.get_equippable_dappernessfn = GetEquippableDapperness
	inst.components.sanity.only_magic_dapperness = true

    inst.components.foodaffinity:AddPrefabAffinity("trailmix", TUNING.AFFINITY_15_CALORIES_SMALL)

	inst.components.eater:SetOnEatFn(oneat)

    inst.components.sleepingbaguser:SetHungerBonusMult(TUNING.EFFICIENT_SLEEP_HUNGER_MULT)

	inst.components.petleash:SetMaxPets(0) -- walter can only have Woby as a pet

	inst:AddComponent("storyteller")
	inst.components.storyteller:SetStoryToTellFn(StoryToTellFn)
	inst.components.storyteller:SetOnStoryOverFn(StoryTellingDone)

	inst:ListenForEvent("healthdelta", OnHealthDelta)
    inst:ListenForEvent("attacked", OnAttacked)

	inst._sanity_damage_protection = SourceModifierList(inst)

	inst._tree_sanity_gain = 0
	inst._update_tree_sanity_task = inst:DoPeriodicTask(TUNING.WALTER_TREE_SANITY_UPDATE_TIME, UpdateTreeSanityGain)

	inst._wobybuck_damage = 0
	inst:ListenForEvent("timerdone", OnTimerDone)

	inst._woby_spawntask = inst:DoTaskInTime(0, function(i) i._woby_spawntask = nil SpawnWoby(i) end)
	inst._woby_onremove = function(woby) OnWobyRemoved(inst) end

	inst.OnWobyTransformed = OnWobyTransformed

	inst.OnSave = OnSave
	inst.OnLoad = OnLoad
    inst.OnDespawn = OnDespawn
    inst:ListenForEvent("ms_playerreroll", OnReroll)
	inst:ListenForEvent("onremove", OnRemoveEntity)

end

-------------------------------------------------------------------------------

local function CampfireStory_OnNotNight(inst, isnight)
	if not isnight and inst.storyteller ~= nil and inst.storyteller:IsValid() and inst.storyteller.components.storyteller ~= nil then
		inst.storyteller.components.storyteller:AbortStory(GetString(inst.storyteller, "ANNOUNCE_STORYTELLING_ABORT_NOT_NIGHT"))
	end
end

local function CampfireStory_CheckFire(inst, data)
	if data ~= nil and data.newsection == 0 and inst.storyteller:IsValid() and inst.components.storyteller ~= nil then
		inst.storyteller.components.storyteller:AbortStory(GetString(inst.storyteller, "ANNOUNCE_STORYTELLING_ABORT_FIREWENTOUT"))
	end
end

local function CampfireStory_aurafallofffn(inst, observer, distsq)
	return 1
end

local function CampfireStory_ActiveFn(params, parent, best_dist_sq)
	local pan_gain, heading_gain, distance_gain = TheCamera:GetGains()
	TheCamera:SetGains(1.5, heading_gain, distance_gain)
    TheCamera:SetDistance(18)
end

local function SetupCampfireStory(inst, storyteller, prop)
	inst.entity:SetParent(prop.entity)

	inst.storyteller = storyteller

	inst:ListenForEvent("onfueldsectionchanged", function(i, data) CampfireStory_CheckFire(inst, data) end, prop)
end

local function walter_campfire_story_proxy_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("NOBLOCK")

	if Profile:IsCampfireStoryCameraEnabled() then
		TheFocalPoint.components.focalpoint:StartFocusSource(inst, nil, nil, 3, 4, -1, { ActiveFn = CampfireStory_ActiveFn })
	end

    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("sanityaura")
	inst.components.sanityaura.max_distsq = 16 -- radius of 4
    inst.components.sanityaura.aura = TUNING.SANITYAURA_SMALL_TINY
	inst.components.sanityaura.fallofffn = CampfireStory_aurafallofffn

	---
	inst:WatchWorldState("isnight", CampfireStory_OnNotNight)

	inst.Setup = SetupCampfireStory

	return inst
end

return MakePlayerCharacter("walter", prefabs, assets, common_postinit, master_postinit),
	Prefab("walter_campfire_story_proxy", walter_campfire_story_proxy_fn)