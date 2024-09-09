require "playerdeaths"
require "playerhistory"
require "serverpreferences"
require "util/profanityfilter"
require "saveindex"
require "shardsaveindex"
require "shardindex"
require "custompresets"
require "map/extents"
require "perfutil"
require "maputil"
require "constants"
require "knownerrors"

require "usercommands"
require "builtinusercommands"
require "emotes"

require "consolescreensettings"

require "map/ocean_gen" -- for retrofitting the ocean tiles


local EquipSlot = require("equipslotutil")
local GroundTiles = require("worldtiledefs")
local Stats = require("stats")
local WorldSettings_Overrides = require("worldsettings_overrides")

if PLATFORM == "WIN32_RAIL" then
	TheSim:SetMemInfoTrackingInterval(5*60)
end

-- globals
chestfunctions = require("scenarios/chestfunctions")

local DEBUG_MODE = BRANCH == "dev"
local LOAD_UPFRONT_MODE = PLATFORM == "PS4"

local MainScreen = nil
if PLATFORM == "PS4" then
	MainScreen = require "screens/mainscreen_ps4"
elseif not TheNet:IsDedicated() then
	MainScreen = require "screens/redux/mainscreen"
end

global_loading_widget = nil
LoadingWidget = require "widgets/redux/loadingwidget"
global_loading_widget = LoadingWidget(Settings.load_screen_image)
global_loading_widget:SetHAnchor(ANCHOR_LEFT)
global_loading_widget:SetVAnchor(ANCHOR_BOTTOM)
global_loading_widget:SetScaleMode(SCALEMODE_PROPORTIONAL)

known_error_key = nil
global_error_widget = nil
ScriptErrorWidget = require "widgets/scripterrorwidget"
function SetGlobalErrorWidget(...)
    if global_error_widget == nil then -- only first error!
        global_error_widget = ScriptErrorWidget(...)
    end
end

cancel_tip = nil
if not TheNet:IsDedicated() then
    CancelTip = require "widgets/canceltipwidget"
    cancel_tip = CancelTip()
    cancel_tip:SetHAnchor(ANCHOR_MIDDLE)
    cancel_tip:SetVAnchor(ANCHOR_TOP)
end

local WorldGenScreen = require "screens/worldgenscreen"
local PauseScreen = require "screens/redux/pausescreen"

Print (VERBOSITY.DEBUG, "[Loading frontend assets]")

local screen_fade_time = .25

local start_game_time = nil

TheSim:SetRenderPassDefaultEffect( RENDERPASS.BLOOM, "shaders/anim_bloom.ksh" )
TheSim:SetErosionTexture( "images/erosion.tex" )
TheSim:SetHoloTexture( "images/erosion_holo.tex" )

function RecordEventAchievementProgressForAllPlayers(achievement, data)
	if TheWorld ~= nil and TheWorld.components.eventachievementtracker ~= nil then
		for _, v in ipairs(AllPlayers) do
			TheWorld.components.eventachievementtracker:RecordProgress(achievement, v, data)
		end
	end
end

function RecordEventAchievementProgress(achievement, src, data)
	if TheWorld ~= nil and TheWorld.components.eventachievementtracker ~= nil then
		TheWorld.components.eventachievementtracker:RecordProgress(achievement, src, data)
	end
end

function RecordEventAchievementSharedProgress(achievement, data)
	if TheWorld ~= nil and TheWorld.components.eventachievementtracker ~= nil then
		TheWorld.components.eventachievementtracker:RecordSharedProgress(achievement, data)
	end
end


function ForceAuthenticationDialog()
	if not InGamePlay() then
		local active_screen = TheFrontEnd:GetActiveScreen()
		if active_screen ~= nil and active_screen.name == "MainScreen" then
			active_screen:OnLoginButton(false)
		elseif MainScreen then
			local main_screen = MainScreen(Profile)
			TheFrontEnd:ShowScreen( main_screen )
			main_screen:OnLoginButton(false)
		end
	end
end

--this is suuuuuper placeholdery. We need to think about how to handle all of the different types of updates for this
local function DoAgeWorld()
	for k,v in pairs(Ents) do

		--send things to their homes
		if v.components.homeseeker and v.components.homeseeker.home then

			if v.components.homeseeker.home.components.childspawner then
				v.components.homeseeker.home.components.childspawner:GoHome(v)
			end

			if v.components.homeseeker.home.components.spawner then
				v.components.homeseeker.home.components.spawner:GoHome(v)
			end
		end

	end
end

local function KeepAlive()
	if global_loading_widget then
		global_loading_widget:ShowNextFrame()
		if cancel_tip then
			cancel_tip:ShowNextFrame()
		end
		TheSim:RenderOneFrame()
		global_loading_widget:ShowNextFrame()
		if cancel_tip then
			cancel_tip:ShowNextFrame()
		end
	end
end

function ShowLoading()
	if global_loading_widget and not TheNet:IsDedicated() then
		global_loading_widget:SetEnabled(true)
	end
end

function ShowCancelTip()
	if cancel_tip then
		cancel_tip:SetEnabled(true)
	end
end

function HideCancelTip()
	if cancel_tip then
		cancel_tip:SetEnabled(false)
	end
end

local function LoadAssets(asset_set, savedata)
    LoadAccessibleKlumpFiles()

	if LOAD_UPFRONT_MODE then
        ModManager:RegisterPrefabs()
        return
    end

	ShowLoading()

	assert(asset_set)
	Settings.current_asset_set = asset_set
    Settings.current_world_asset = savedata ~= nil and savedata.map.prefab or nil

	local savedata_overrides = savedata and savedata.map.topology and savedata.map.topology.overrides or nil

    Settings.current_world_specialevent = savedata and (savedata_overrides and savedata_overrides.specialevent ~= "default" and savedata_overrides.specialevent or WORLD_SPECIAL_EVENT) or nil
	Settings.current_world_extraevents = {}

	local last_world_allevents = GetAllActiveEvents(Settings.last_world_specialevent, Settings.last_world_extraevents)
	local current_world_allevents = GetAllActiveEvents(Settings.current_world_specialevent, Settings.current_world_extraevents)

	RECIPE_PREFABS = {}
	for k,v in pairs(AllRecipes) do
		table.insert(RECIPE_PREFABS, v.product)
		if v.placer then
			table.insert(RECIPE_PREFABS, v.placer)
		end
	end
	local load_frontend = Settings.reset_action == nil
	local in_backend = Settings.last_reset_action ~= nil
	local in_frontend = not in_backend

	KeepAlive()

    if Settings.loaded_characters ~= nil then
        print("\tUnload characters")
        TheSim:UnloadPrefabs(Settings.loaded_characters)
        Settings.loaded_characters = nil
    end

	if Settings.current_asset_set == "FRONTEND" then
		if Settings.last_asset_set == "FRONTEND" then
			print("\tFE assets already loaded")
			for i,file in ipairs(PREFABFILES) do -- required from prefablist.lua
				LoadPrefabFile("prefabs/"..file)
			end
			ModManager:RegisterPrefabs()
		else
			if Settings.last_asset_set ~= nil then
				print("\tUnload BE")
				TheSim:UnloadPrefabs(RECIPE_PREFABS)
                --V2C: Replaced by Settings.last_world_asset
                --TheSim:UnloadPrefabs(BACKEND_PREFABS)

				for special_event in pairs(last_world_allevents) do
					TheSim:UnloadPrefabs({ special_event.."_event_backend" })
				end
                TheSim:UnloadPrefabs(FESTIVAL_EVENT_BACKEND_PREFABS)
                if Settings.last_world_asset ~= nil then
                    TheSim:UnloadPrefabs({ Settings.last_world_asset })
                end
                if DEBUG_MODE and CONFIGURATION ~= "PRODUCTION" and PLATFORM == "WIN32_STEAM" then
                    TheSim:UnloadPrefabs({ "audio_test_prefab" })
                end
				print("\tUnload BE done")
			else
				--print("No assets to unload because we have no previous asset set ")
			end
			KeepAlive()
			TheSystemService:SetStalling(true)
			TheSim:UnregisterAllPrefabs()

			RegisterAllDLC()

			local async_batch_validation = Settings.last_asset_set == nil
			for i,file in ipairs(PREFABFILES) do -- required from prefablist.lua
				LoadPrefabFile("prefabs/"..file, async_batch_validation)
			end

			ModManager:RegisterPrefabs()
			TheSystemService:SetStalling(false)
			KeepAlive()

			print("\tLoad FE")
			TheSystemService:SetStalling(true)
			TheSim:LoadPrefabs(FRONTEND_PREFABS)
            TheSim:LoadPrefabs(SPECIAL_EVENT_FRONTEND_PREFABS)
            TheSim:LoadPrefabs(FESTIVAL_EVENT_FRONTEND_PREFABS)

			TheSystemService:SetStalling(false)

			if async_batch_validation then
				TheSim:StartFileExistsAsync()
			end
			print("\tLoad FE: done")
		end
	else
		if Settings.last_asset_set == "BACKEND" then
			print("\tBE assets already loaded")
			RegisterAllDLC()
			for i,file in ipairs(PREFABFILES) do -- required from prefablist.lua
				LoadPrefabFile("prefabs/"..file)
			end
            if DEBUG_MODE and CONFIGURATION ~= "PRODUCTION" and PLATFORM == "WIN32_STEAM" then
                LoadPrefabFile("prefabs/audio_test_prefab")
            end

			for special_event in pairs(current_world_allevents) do
				if not last_world_allevents[special_event] then
					TheSim:LoadPrefabs({ special_event.."_event_backend" })
				end
			end

			for special_event in pairs(last_world_allevents) do
				if not current_world_allevents[special_event] then
					TheSim:UnloadPrefabs({ special_event.."_event_backend" })
				end
			end

            if Settings.last_world_asset ~= Settings.current_world_asset then
				if Settings.current_world_asset then
					TheSim:LoadPrefabs({ Settings.current_world_asset })
				end
				if Settings.last_world_asset then
					TheSim:UnloadPrefabs({ Settings.last_world_asset })
				end
            end

			ModManager:RegisterPrefabs()
		else
			print("\tUnload FE")
			TheSim:UnloadPrefabs(FRONTEND_PREFABS)
            TheSim:UnloadPrefabs(SPECIAL_EVENT_FRONTEND_PREFABS)
            TheSim:UnloadPrefabs(FESTIVAL_EVENT_FRONTEND_PREFABS)
			print("\tUnload FE done")
			KeepAlive()

			TheSystemService:SetStalling(true)
			TheSim:UnregisterAllPrefabs()
			RegisterAllDLC()
			for i,file in ipairs(PREFABFILES) do -- required from prefablist.lua
				LoadPrefabFile("prefabs/"..file)
			end
            if DEBUG_MODE and CONFIGURATION ~= "PRODUCTION" and PLATFORM == "WIN32_STEAM" then
                LoadPrefabFile("prefabs/audio_test_prefab")
            end
			InitAllDLC()
			ModManager:RegisterPrefabs()
			TheSystemService:SetStalling(false)
			KeepAlive()

			print("\tLOAD BE")
			TheSystemService:SetStalling(true)
            --V2C: Replaced by Settings.current_world_asset
            --TheSim:LoadPrefabs(BACKEND_PREFABS)


			for special_event in pairs(current_world_allevents) do
				TheSim:LoadPrefabs({ special_event.."_event_backend" })
			end

            TheSim:LoadPrefabs(FESTIVAL_EVENT_BACKEND_PREFABS)
            if Settings.current_world_asset ~= nil then
                TheSim:LoadPrefabs({ Settings.current_world_asset })
            end
            if DEBUG_MODE and CONFIGURATION ~= "PRODUCTION" and PLATFORM == "WIN32_STEAM" then
                TheSim:LoadPrefabs({ "audio_test_prefab" })
            end
			TheSystemService:SetStalling(false)
			KeepAlive()
			TheSystemService:SetStalling(true)
			TheSim:LoadPrefabs(RECIPE_PREFABS)
			TheSystemService:SetStalling(false)
			print("\tLOAD BE: done")
			KeepAlive()
		end
	end

	Settings.last_asset_set = Settings.current_asset_set
    Settings.last_world_asset = Settings.current_world_asset
    Settings.last_world_specialevent = Settings.current_world_specialevent
	Settings.last_world_extraevents = Settings.current_world_extraevents
end

function GetTimePlaying()
    return start_game_time ~= nil and GetTime() - start_game_time or 0
end

local replace =
{
    ["farmplot"] = "slow_farmplot",
    ["farmplot2"] = "fast_farmplot",
    ["farmplot3"] = "fast_farmplot",
    ["sinkhole"] = "cave_entrance",
    ["cave_stairs"] = "cave_entrance",
    --["feather"] = "feather_crow", -- NOTES(JBK): This rename is so old no world around today should need this fixup. Leaving a comment here in case someone comes knocking later.
}

local function TryGetGemCoreTileData(savedata)
	local old_ground
	local function LoadGemCoreTileData(load_success, str)
		if load_success and #str > 0 then
			local GemCoreTileData = loadstring(str)()

			local idx = TheNet:GetCurrentSnapshot()
			while idx > 1 do
				if GemCoreTileData[idx] ~= nil then
					old_ground = GemCoreTileData[idx]
					break
				end
				idx = idx - 1
			end
		end
	end

	local path = "session/"..savedata.meta.session_identifier.."/GemCoreTileData"
	if not TheNet:IsDedicated() and not ShardGameIndex:GetServerData().use_legacy_session_path then
		TheSim:GetPersistentStringInClusterSlot(ShardGameIndex:GetSlot(), "Master", path, LoadGemCoreTileData)
    else
		TheSim:GetPersistentString(path, LoadGemCoreTileData)
    end

	return old_ground
end

POPULATING = false
local function PopulateWorld(savedata, profile)
    POPULATING = true
    TheSystemService:SetStalling(true)
    Print(VERBOSITY.DEBUG, "PopulateWorld")
    Print(VERBOSITY.DEBUG, "[Instantiating objects...]")
    if savedata ~= nil then
		local savedata_overrides = savedata.map.topology.overrides

		if savedata_overrides then
			ApplySpecialEvent(savedata_overrides.specialevent or "default")
			for k, event_name in pairs(SPECIAL_EVENTS) do
				if savedata_overrides[event_name] == "enabled" then
					ApplyExtraEvent(event_name)
				end
			end
		end

		if savedata.map.topology.overrides and not IsTableEmpty(savedata.map.topology.overrides) then
			for name, override in pairs(WorldSettings_Overrides.Pre) do
				local difficulty = savedata.map.topology.overrides[name]
				if difficulty and difficulty ~= "default" then
					print("OVERRIDE: setting", name, "to", difficulty)
				end
				override(difficulty or "default")
			end
		else
			--if we lack overrides, all values are defaulted, to guarantee everything is on default values.
			for name, override in pairs(WorldSettings_Overrides.Pre) do
				override("default")
			end
		end

        local world = SpawnPrefab(savedata.map.prefab)
        if DEBUG_MODE then
            -- Common error in development when switching branches.
            known_assert(world, "DEV_FAILED_TO_SPAWN_WORLD")
        end
        world.worldprefab = savedata.map.prefab
        assert(TheWorld == world)
        assert(ThePlayer == nil)

        if not LOAD_UPFRONT_MODE then
            local oldloaded = {}
            if Settings.loaded_characters ~= nil then
                for i, v in ipairs(Settings.loaded_characters) do
                    oldloaded[v] = true
                end
            end
            Settings.loaded_characters = GetActiveCharacterList()
            local newchars = {}
            for i, v in ipairs(Settings.loaded_characters) do
                if oldloaded[v] then
                    oldloaded[v] = nil
                else
                    table.insert(newchars, v)
                end
            end
            local unloadchars = {}
            for k, v in pairs(oldloaded) do
                table.insert(unloadchars, k)
            end
            if #unloadchars > 0 then
                print("Unloading "..tostring(#unloadchars).." old character(s)")
                TheSim:UnloadPrefabs(unloadchars)
            end
            if #newchars > 0 then
                print("Loading "..tostring(#newchars).." new character(s)")
                TheSim:LoadPrefabs(newchars)
            end
            print("Total "..tostring(#Settings.loaded_characters).." character(s) loaded")
        end

        world.has_ocean = savedata.map.has_ocean

		if world.components.oceancolor ~= nil then
			world.components.oceancolor:Initialize(world.has_ocean)
		end

        local map = world.Map

        if world.has_ocean then
            local tuning = TUNING.OCEAN_SHADER
            map:SetOceanEnabled(true)
			map:SetOceanTextureBlurParameters(tuning.TEXTURE_BLUR_PASS_SIZE, tuning.TEXTURE_BLUR_PASS_COUNT)
            map:SetOceanNoiseParameters0(tuning.NOISE[1].ANGLE, tuning.NOISE[1].SPEED, tuning.NOISE[1].SCALE, tuning.NOISE[1].FREQUENCY)
            map:SetOceanNoiseParameters1(tuning.NOISE[2].ANGLE, tuning.NOISE[2].SPEED, tuning.NOISE[2].SCALE, tuning.NOISE[2].FREQUENCY)
            map:SetOceanNoiseParameters2(tuning.NOISE[3].ANGLE, tuning.NOISE[3].SPEED, tuning.NOISE[3].SCALE, tuning.NOISE[3].FREQUENCY)

			local waterfall_tuning = TUNING.WATERFALL_SHADER.NOISE

			map:SetWaterfallFadeParameters(TUNING.WATERFALL_SHADER.FADE_COLOR[1] / 255, TUNING.WATERFALL_SHADER.FADE_COLOR[2] / 255, TUNING.WATERFALL_SHADER.FADE_COLOR[3] / 255, TUNING.WATERFALL_SHADER.FADE_START)
			map:SetWaterfallNoiseParameters0(waterfall_tuning[1].SCALE, waterfall_tuning[1].SPEED, waterfall_tuning[1].OPACITY, waterfall_tuning[1].FADE_START)
			map:SetWaterfallNoiseParameters1(waterfall_tuning[2].SCALE, waterfall_tuning[2].SPEED, waterfall_tuning[2].OPACITY, waterfall_tuning[2].FADE_START)

			local minimap_ocean_tuning = TUNING.OCEAN_MINIMAP_SHADER

			map:SetMinimapOceanEdgeColor0(minimap_ocean_tuning.EDGE_COLOR0[1] / 255, minimap_ocean_tuning.EDGE_COLOR0[2] / 255, minimap_ocean_tuning.EDGE_COLOR0[3] / 255)
			map:SetMinimapOceanEdgeParams0(minimap_ocean_tuning.EDGE_PARAMS0.THRESHOLD, minimap_ocean_tuning.EDGE_PARAMS0.HALF_THRESHOLD_RANGE)

			map:SetMinimapOceanEdgeColor1(minimap_ocean_tuning.EDGE_COLOR1[1] / 255, minimap_ocean_tuning.EDGE_COLOR1[2] / 255, minimap_ocean_tuning.EDGE_COLOR1[3] / 255)
			map:SetMinimapOceanEdgeParams1(minimap_ocean_tuning.EDGE_PARAMS1.THRESHOLD, minimap_ocean_tuning.EDGE_PARAMS1.HALF_THRESHOLD_RANGE)

			map:SetMinimapOceanEdgeShadowColor(minimap_ocean_tuning.EDGE_SHADOW_COLOR[1] / 255, minimap_ocean_tuning.EDGE_SHADOW_COLOR[2] / 255, minimap_ocean_tuning.EDGE_SHADOW_COLOR[3] / 255)
			map:SetMinimapOceanEdgeShadowParams(minimap_ocean_tuning.EDGE_SHADOW_PARAMS.THRESHOLD, minimap_ocean_tuning.EDGE_SHADOW_PARAMS.HALF_THRESHOLD_RANGE, minimap_ocean_tuning.EDGE_SHADOW_PARAMS.UV_OFFSET_X, minimap_ocean_tuning.EDGE_SHADOW_PARAMS.UV_OFFSET_Y)

			map:SetMinimapOceanEdgeFadeParams(minimap_ocean_tuning.EDGE_FADE_PARAMS.THRESHOLD, minimap_ocean_tuning.EDGE_FADE_PARAMS.HALF_THRESHOLD_RANGE, minimap_ocean_tuning.EDGE_FADE_PARAMS.MASK_INSET)

			map:SetMinimapOceanEdgeNoiseParams(minimap_ocean_tuning.EDGE_NOISE_PARAMS.UV_SCALE)

			map:SetMinimapOceanTextureBlurParameters(minimap_ocean_tuning.TEXTURE_BLUR_SIZE, minimap_ocean_tuning.TEXTURE_BLUR_PASS_COUNT, minimap_ocean_tuning.TEXTURE_ALPHA_BLUR_SIZE, minimap_ocean_tuning.TEXTURE_ALPHA_BLUR_PASS_COUNT)
			map:SetMinimapOceanMaskBlurParameters(minimap_ocean_tuning.MASK_BLUR_SIZE, minimap_ocean_tuning.MASK_BLUR_PASS_COUNT)
        end

        --this was spawned by the level file. kinda lame - we should just do everything from in here.
        map:SetSize(savedata.map.width, savedata.map.height)
		world:PushEvent("worldmapsetsize", { width = savedata.map.width, height = savedata.map.height, })
		if savedata.map.width > 1024 and savedata.map.height > 1024 then
			--increase this by as little as possible!
			--this number creates a series of small regions that is used to help cull out objects that aren't on screen.
			--the larger this number is, the larger those regions, and the more wasted time rendering objects that are offscreen.
			TheSim:UpdateRenderExtents(math.max(savedata.map.width, savedata.map.height) * TILE_SCALE)
		end

		if world.ismastersim then
			if not savedata.map.tiledata then
				map:SetFromStringLegacy(savedata.map.tiles)
			else
				map:SetFromString(savedata.map.tiles)
				map:SetMapDataFromString(savedata.map.tiledata)
			end

			local tile_id_conversion_map = {}
			if savedata.map.world_tile_map then
				local world_tile_map = savedata.map.world_tile_map
				for name, id in pairs(GetWorldTileMap()) do
					local previous_id = world_tile_map[name]
					if previous_id and previous_id ~= id then
						tile_id_conversion_map[previous_id] = id
					end
				end
			else
				--try and load GemCore's tile history if it exists, it will be more accurate than old_static_id
				local gemcore_old_ground = TryGetGemCoreTileData(savedata)
				if gemcore_old_ground then
					for name, id in pairs(GetWorldTileMap()) do
						local previous_id = gemcore_old_ground[name]
						if previous_id and previous_id ~= id then
							tile_id_conversion_map[previous_id] = id
						end
					end
				else
					for name, id in pairs(GetWorldTileMap()) do
						local tile_info = GetTileInfo(id)
						if tile_info and tile_info.old_static_id ~= nil and tile_info.old_static_id ~= id then
							tile_id_conversion_map[tile_info.old_static_id] = id
						end
					end
				end
			end
			map:DoDynamicTileConversion(tile_id_conversion_map)

			world.tile_id_conversion_map = tile_id_conversion_map
		elseif savedata.map.tiledata then
			map:SetMapDataFromString(savedata.map.tiledata)
		end

		map:SetNodeIdTileMapFromString(savedata.map.nodeidtilemap)
        map:ResetVisited()

		-- This happens after calling 'map:SetFromString' so that we can use the map API to read tile data instead of trying to read/write the save data tile stream
		-- no objects have been spawned, so modifying savedata.ents is the correct thing to do
		if world.ismastersim then
			local retrofiting = require("map/retrofit_savedata")
			retrofiting.DoRetrofitting(savedata, world.Map)

			require("worldentities").AddWorldEntities(savedata)
		end

		TheFrontEnd:GetGraphicsOptions():DisableStencil()
		TheFrontEnd:GetGraphicsOptions():DisableLightMapComponent()
		world:CreateTilePhysics()
		map:Finalize()

		if world.ismastersim then
			if savedata.map.nav then
				print("Loading Nav Grid")
				map:SetNavSize(savedata.map.width, savedata.map.height)
				map:SetNavFromString(savedata.map.nav)
			else
				print("No Nav Grid")
			end
		end

        world.hideminimap = savedata.map.hideminimap
        world.topology = savedata.map.topology
        world.generated = savedata.map.generated
        world.meta = savedata.meta
        assert(savedata.map.topology.ids, "[MALFORMED SAVE DATA] Map missing topology information. This save file is too old, and is missing neccessary information.")

		if savedata.meta ~= nil then
			print("World generated on build " .. tostring(savedata.meta.build_version) .. " with save version: " .. tostring(savedata.meta.generated_on_saveversion) .. ", using seed: " .. tostring(savedata.meta.seed))
		end

        for i,node in ipairs(world.topology.nodes) do
            local story = world.topology.ids[i]
            -- guard for old saves
            if story ~= "START" then
                story = string.sub(story, 1, string.find(story,":")-1)
            end

            if table.contains( node.tags, "Mist" ) then
                if node.area_emitter == nil then
                    if node.area == nil then
                        node.area = 1
                    end

                    if not TheNet:IsDedicated() then
                        local mist = SpawnPrefab("mist")
                        mist.Transform:SetPosition(node.cent[1], 0, node.cent[2])
                        mist.components.emitter.area_emitter = CreateAreaEmitter(node.poly, node.cent)

                        local ext = ResetextentsForPoly(node.poly)
                        mist.entity:SetAABB(ext.radius, 2)
                        mist.components.emitter.density_factor = math.ceil(node.area / 4) / 31
                        mist.components.emitter:Emit()
                    end
                end
            end

        end

        if savedata.map.persistdata ~= nil then
            world:SetPersistData(savedata.map.persistdata)
        end

        if world.ismastersim then
            SpawnPrefab(savedata.map.prefab.."_network")
            SpawnPrefab("shard_network")

            if savedata.world_network ~= nil and savedata.world_network.persistdata ~= nil then
                world.net:SetPersistData(savedata.world_network.persistdata)
            end
            if savedata.shard_network ~= nil and savedata.shard_network.persistdata ~= nil then
                world.shard:SetPersistData(savedata.shard_network.persistdata)
            end
        end

		WorldSettings_Overrides.areaambientdefault(savedata.map.prefab)

        -- Check for map overrides
		if world.topology.overrides ~= nil and GetTableSize(world.topology.overrides) > 0 then
			for name, override in pairs(WorldSettings_Overrides.Post) do
				local difficulty = world.topology.overrides[name]
				if difficulty and difficulty ~= "default" then
					print("OVERRIDE: setting", name, "to", difficulty)
				end
				override(difficulty or "default")
			end
		else
			--if we lack overrides, all values are defaulted, to guarantee everything is on default values.
			for name, override in pairs(WorldSettings_Overrides.Post) do
				override("default")
			end
		end

        --instantiate all the dudes
        local newents = {}
        for prefab, ents in pairs(savedata.ents) do
            prefab = replace[prefab] or prefab
            for i, v in ipairs(ents) do
                v.prefab = v.prefab or prefab -- prefab field is stripped out when entities are saved in global entity collections, so put it back
                SpawnSaveRecord(v, newents)
            end
        end
		if world.components.walkableplatformmanager then
			world.components.walkableplatformmanager:PostUpdate(0)
		end
        --post pass in neccessary to hook up references
        for k, v in pairs(newents) do
            v.entity:LoadPostPass(newents, v.data)
        end
        world:LoadPostPass(newents, savedata.map.persistdata)

		--Run scenario scripts
        for guid, ent in pairs(Ents) do
			if ent.components.scenariorunner then
				ent.components.scenariorunner:Run()
			end
		end

		--Record mod information
		ModManager:SetModRecords(savedata.mods or {})
        SetSuper(savedata.super)

        --Start checking if the server's mods are up to date
        ModManager:StartVersionChecking()
		ReconstructTopology(world.topology)
    else
        Print(VERBOSITY.ERROR, "[MALFORMED SAVE DATA] PopulateWorld complete")
        TheSystemService:SetStalling(false)
        POPULATING = false
        return
    end

	Print(VERBOSITY.DEBUG, "[FINISHED LOADING SAVED GAME] PopulateWorld complete")
	TheSystemService:SetStalling(false)
	POPULATING = false
end

local function DrawDebugGraph(graph)
	-- debug draw of new map gen
	local debugdrawmap = CreateEntity("DrawDebugGraph")
	local draw = debugdrawmap.entity:AddDebugRender()
	draw:SetZ(0.1)
	draw:SetRenderLoop(true)

	for idx,node in ipairs(graph.nodes) do
		local colour = graph.colours[node.c]

		for i =1, #node.poly-1 do
			draw:Line(node.poly[i][1], node.poly[i][2], node.poly[i+1][1], node.poly[i+1][2], colour.r, colour.g, colour.b, 255)
		end
		draw:Line(node.poly[1][1], node.poly[1][2], node.poly[#node.poly][1], node.poly[#node.poly][2], colour.r, colour.g, colour.b, 255)
		draw:Poly(node.cent[1], node.cent[2], colour.r, colour.g, colour.b, colour.a, node.poly)
		draw:String(graph.ids[idx].."("..node.cent[1]..","..node.cent[2]..")", 	node.cent[1], node.cent[2], node.ts)
	end

	draw:SetZ(0.15)

	for idx,edge in ipairs(graph.edges) do
		if edge.n1 ~= nil and edge.n2 ~= nil then
			local colour = graph.colours[edge.c]

			local n1 = graph.nodes[edge.n1]
			local n2 = graph.nodes[edge.n2]
			if n1 ~= nil and n2 ~= nil then
                draw:Line(n1.cent[1], n1.cent[2], n2.cent[1], n2.cent[2], colour.r, colour.g, colour.b, colour.a)
			end
		end
	end
end

--Called when clients receive loading state notification
--so that clients can properly handle resets differently
--from Wilderness or console command despawning.
function DeactivateWorld()
    if TheWorld ~= nil and not TheWorld.isdeactivated then
        TheWorld.isdeactivated = true
        DisableRPCSending()
        TheWorld:PushEvent("deactivateworld")
        TheMixer:PopMix("normal")
        SetPause(true)
    end
end

local function ActivateWorld()
    if TheWorld ~= nil and not TheWorld.isdeactivated then
        SetPause(false)
        TheMixer:SetLevel("master", 1)
        TheMixer:PushMix(GetGameModeProperty("override_normal_mix") or "normal")
    end
end

local function OnPlayerActivated(world, player)
	if player.isseamlessswaptarget then
		if player.prefab == "wonkey" then
			if TheGenericKV:GetKV("wonkey_played") then
				TheInventory:SetGenericKVValue( "wonkey_played", "played" )
			end
		end

		return
	end

    if not world.isdeactivated then
        start_game_time = GetTime()
        TheInput:CacheController()
        if ThePlayer ~= nil and
            ThePlayer.player_classified ~= nil and
            not ThePlayer.player_classified.isfadein:value() then
            --Stay faded out
            ActivateWorld()
        else
            TheFrontEnd:Fade(FADE_IN, 1, ActivateWorld, nil, nil, "white")
        end
    end
end

local function SendResumeRequestToServer(world, delay)
    if world.isdeactivated or world.net == nil then
        --world reset/regen/disconnect triggered
        return
    elseif delay > 0 then
        world:DoStaticTaskInTime(0, SendResumeRequestToServer, delay - 1)
    elseif not TheNet:IsDedicated() and ThePlayer == nil then
        TheNet:SendResumeRequestToServer(TheNet:GetUserID())
    else
        print("Failed to resume session after player deactivation.")
        --Error case that shouldn't be reached
        --Client will be stuck in a black screen in this case
        --assert or disconnect maybe?
    end
end

local function OnPlayerDeactivated(world, player)
    if not world.isdeactivated then
        TheInput:ClearCachedController()
		if not player.isseamlessswapsource then
			TheFrontEnd:ClearScreens()
			TheFrontEnd:SetFadeLevel(1)
			TheMixer:PopMix("normal")
			SetPause(true)
        	SendResumeRequestToServer(world, 2)
		end
    end
end

--Generate a server friendly version of the map
local server_file = "server_temp"..DEFAULT_SERVER_SAVE_FILE
local COMPRESS_SERVER_SAVE_FILE = true
local function WriteServerSaveTempFile(savedata)
    if not TheNet:GetIsServer() then
		return
	end
	-- Setup appropriate folders for saving session data
	TheNet:BeginSession(savedata.meta.session_identifier)

	local ent_ref = savedata.ents
	local snapshot_ref = savedata.snapshot
	local map_adj_ref = savedata.map.adj
	local map_generated_ref = savedata.map.generated
	local map_world_tile_map_ref = savedata.map.world_tile_map
	local map_persistdata_ref = savedata.map.persistdata
	local map_nav = savedata.map.nav
	local map_tiles = savedata.map.tiles
	local meta_seed = savedata.meta.seed
	local world_network_ref = savedata.world_network
	savedata.ents = {}
	savedata.snapshot = nil
	savedata.map.adj = nil
	savedata.map.generated = nil
	savedata.map.world_tile_map = nil
	savedata.map.persistdata = nil
	savedata.map.nav = nil
	savedata.map.tiles = ""
	savedata.meta.seed = ""
	savedata.world_network = nil

	print("saving to "..server_file)
	TheSim:SetPersistentString(server_file, DataDumper(savedata, nil, COMPRESS_SERVER_SAVE_FILE), COMPRESS_SERVER_SAVE_FILE, nil)

	savedata.ents = ent_ref
	savedata.snapshot = snapshot_ref
	savedata.map.adj = map_adj_ref
	savedata.map.generated = map_generated_ref
	savedata.map.world_tile_map = map_world_tile_map_ref
	savedata.map.persistdata = map_persistdata_ref
	savedata.map.nav = map_nav
	savedata.map.tiles = map_tiles
	savedata.meta.seed = meta_seed
	savedata.world_network = world_network_ref
end

--OK, we have our savedata and a profile. Instatiate everything and start the game!
local function DoInitGame(savedata, profile)
	local was_file_load = Settings.playeranim == "file_load"

	--print("DoInitGame", savedata, profile)
	TheFrontEnd:ClearScreens()

	assert(savedata.map, "Map missing from savedata on load")
	assert(savedata.map.prefab, "Map prefab missing from savedata on load")
	assert(savedata.map.tiles, "Map tiles missing from savedata on load")
	assert(savedata.map.width, "Map width missing from savedata on load")
	assert(savedata.map.height, "Map height missing from savedata on load")

	assert(savedata.map.topology, "Map topology missing from savedata on load")
	assert(savedata.map.topology.ids, "Topology entity ids are missing from savedata on load")
	assert(savedata.map.topology.colours, "Topology colours are missing from savedata on load")
	assert(savedata.map.topology.edges, "Topology edges are missing from savedata on load")
	assert(savedata.map.topology.nodes, "Topology nodes are missing from savedata on load")
	assert(savedata.map.topology.level_type, "Topology level type is missing from savedata on load")
	assert(savedata.map.topology.overrides, "Topology overrides is missing from savedata on load")

	assert(savedata.ents, "Entities missing from savedata on load")

	local options = ShardGameIndex:GetGenOptions()
	if options and options.overrides then
		for k, v in pairs(options.overrides) do
			savedata.map.topology.overrides[k] = v
		end
	end
	savedata.map.topology.overrides.original = nil

	local Levels = require("map/levels")
	ShardGameIndex:GetServerData().playstyle = Levels.CalcPlaystyleForSettings(savedata.map.topology.overrides)
	TheNet:SetServerPlaystyle(ShardGameIndex:GetServerData().playstyle)

	-- remove the LOOP_BLANK_SUB before we do anything else
	for i = #savedata.map.topology.ids, 1, -1 do
		local name = savedata.map.topology.ids[i]
		if string.find(name, "LOOP_BLANK_SUB") ~= nil then
			table.remove(savedata.map.topology.ids, i)
			table.remove(savedata.map.topology.nodes, i)
			for eid = #savedata.map.topology.edges, 1, -1 do
				if savedata.map.topology.edges[eid].n1 == i or savedata.map.topology.edges[eid].n2 == i then
					table.remove(savedata.map.topology.edges, eid)
				end
			end
		end
	end

	if savedata.map.roads then
		Roads = savedata.map.roads
		for k, road_data in pairs( savedata.map.roads ) do
			RoadManager:BeginRoad()
			local weight = road_data[1]

			if weight == 3 then
				for i = 2, #road_data do
					local ctrl_pt = road_data[i]
					RoadManager:AddControlPoint( ctrl_pt[1], ctrl_pt[2] )
				end

				for k, v in pairs( ROAD_STRIPS ) do
					RoadManager:SetStripEffect( v, "shaders/road.ksh" )
				end

				RoadManager:SetStripTextures( ROAD_STRIPS.EDGES,	resolvefilepath("images/roadedge.tex"),		resolvefilepath("images/roadnoise.tex") ,		resolvefilepath("images/roadnoise.tex") )
				RoadManager:SetStripTextures( ROAD_STRIPS.CENTER,	resolvefilepath("images/square.tex"),		resolvefilepath("images/roadnoise.tex") ,		resolvefilepath("images/roadnoise.tex") )
				RoadManager:SetStripTextures( ROAD_STRIPS.CORNERS,	resolvefilepath("images/roadcorner.tex"),	resolvefilepath("images/roadnoise.tex") ,		resolvefilepath("images/roadnoise.tex") )
				RoadManager:SetStripTextures( ROAD_STRIPS.ENDS,		resolvefilepath("images/roadendcap.tex"),	resolvefilepath("images/roadnoise.tex") ,		resolvefilepath("images/roadnoise.tex") )

				RoadManager:GenerateVB(
						ROAD_PARAMETERS.NUM_SUBDIVISIONS_PER_SEGMENT,
						ROAD_PARAMETERS.MIN_WIDTH, ROAD_PARAMETERS.MAX_WIDTH,
						ROAD_PARAMETERS.MIN_EDGE_WIDTH, ROAD_PARAMETERS.MAX_EDGE_WIDTH,
						ROAD_PARAMETERS.WIDTH_JITTER_SCALE, true )
			else
				for i = 2, #road_data do
					local ctrl_pt = road_data[i]
					RoadManager:AddControlPoint( ctrl_pt[1], ctrl_pt[2] )
				end

				for k, v in pairs( ROAD_STRIPS ) do
					RoadManager:SetStripEffect( v, "shaders/road.ksh" )
				end
				RoadManager:SetStripTextures( ROAD_STRIPS.EDGES,	resolvefilepath("images/roadedge.tex"),		resolvefilepath("images/pathnoise.tex") ,		resolvefilepath("images/mini_pathnoise.tex") )
				RoadManager:SetStripTextures( ROAD_STRIPS.CENTER,	resolvefilepath("images/square.tex"),		resolvefilepath("images/pathnoise.tex") ,		resolvefilepath("images/mini_pathnoise.tex") )
				RoadManager:SetStripTextures( ROAD_STRIPS.CORNERS,	resolvefilepath("images/roadcorner.tex"),	resolvefilepath("images/pathnoise.tex") ,		resolvefilepath("images/mini_pathnoise.tex") )
				RoadManager:SetStripTextures( ROAD_STRIPS.ENDS,		resolvefilepath("images/roadendcap.tex"),	resolvefilepath("images/pathnoise.tex"),		resolvefilepath("images/mini_pathnoise.tex")  )

				RoadManager:GenerateVB(
						ROAD_PARAMETERS.NUM_SUBDIVISIONS_PER_SEGMENT,
						0, 0,
						ROAD_PARAMETERS.MIN_EDGE_WIDTH*4, ROAD_PARAMETERS.MAX_EDGE_WIDTH*4,
						0, false )
			end
		end
		RoadManager:GenerateQuadTree()
	end

	WriteServerSaveTempFile(savedata)

    --some lame explicit loads
	Print(VERBOSITY.DEBUG, "DoInitGame Loading prefabs...")

	Print(VERBOSITY.DEBUG, "DoInitGame Adjusting audio...")
    TheMixer:SetLevel("master", 0)

	--apply the volumes

	Print(VERBOSITY.DEBUG, "DoInitGame Populating world...")

    TheFrontEnd:GetSound():KillSound("FEMusic") -- just in case...
    TheFrontEnd:GetSound():KillSound("FEPortalSFX")

    --All MODs should have finished adding equip slots and ground tiles by now
    EquipSlot.Initialize()
    GroundTiles.Initialize()

    PopulateWorld(savedata, profile)

    if true --[[ Profile.persistdata.debug_world  == 1]] then
    	if savedata.map.topology == nil then
    		Print(VERBOSITY.ERROR, "OI! Where is my topology info!")
    	else
    		DrawDebugGraph(savedata.map.topology)
     	end
    end

	if global_error_widget == nil then
	    --clear the player stats, so that it doesn't count items "acquired" from the save file
	    Stats.ClearProfileStats()

		Stats.RecordSessionStartStats()

	    --after starting everything up, give the mods additional environment variables
	    ModManager:SimPostInit( nil )
        TheWorld:PostInit()

        --restore autosave snapshots
        if TheNet:GetIsServer() then
            TheNet:TruncateSnapshots(savedata.meta.session_identifier)
            local players_to_restore = savedata.snapshot ~= nil and savedata.snapshot.players or nil
            local players_restored = nil
            if players_to_restore ~= nil then
                players_restored = {}
                for i, v in ipairs(players_to_restore) do
                    if not players_restored[v] then
                        RestoreSnapshotUserSession(savedata.meta.session_identifier, v)
                        players_restored[v] = true
                    end
                end
            end
            TheNet:IncrementSnapshot()
            if players_restored ~= nil then
                for i, v in ipairs(AllPlayers) do
                    if v.userid ~= nil and players_restored[v.userid] then
                        assert(players_restored[v.userid] == true)
                        players_restored[v.userid] = v
                    end
                end
                for k, v in pairs(players_restored) do
                    if v ~= true and v:IsValid() then
                        v:OnDespawn()
                        SerializeUserSession(v)
                        v:Remove()
                    end
                end
            end
        end

        SetPause(true, "InitGame")
        TheFrontEnd:SetFadeLevel(1)
        TheWorld:ListenForEvent("playeractivated", OnPlayerActivated)
        TheWorld:ListenForEvent("playerdeactivated", OnPlayerDeactivated)

	    if savedata.map.hideminimap ~= nil then
	        TheWorld.minimap:DoTaskInTime(0, function(inst) inst.MiniMap:ContinuouslyClearRevealedAreas(savedata.map.hideminimap) end)
	    end
	end

	--DoStartPause("Ready!")
	Print(VERBOSITY.DEBUG, "DoInitGame complete")

	if PRINT_TEXTURE_INFO then
		c_printtextureinfo( "texinfo.csv" )
		TheSim:Quit()
	end

	inGamePlay = true
	TheFrontEnd:SetFadeLevel(1)

	TheNet:DoneLoadingMap( )

	if TheNet:GetIsServer() then
	    NotifyLoadingState( LoadingStates.DoneLoading )
		ShardGameIndex:WriteTimeFile()
	end
end

local function UpgradeSaveFile(savedata)
    print("Save file is at version "..tostring(savedata.meta.saveversion))
    for i,upgrade in ipairs(require("savefileupgrades").upgrades) do
        if savedata.meta.saveversion == nil or savedata.meta.saveversion < upgrade.version then
            print("\tUpgrading to "..tostring(upgrade.version).."...")
            upgrade.fn(savedata)
            savedata.meta.saveversion = upgrade.version
        end
    end
end

------------------------THESE FUNCTIONS HANDLE STARTUP FLOW

local function DoLoadWorldFile(file)
	local function onload(savedata)
		assert(savedata, "DoLoadWorldFile: Savedata is NIL on load")
		assert(GetTableSize(savedata)>0, "DoLoadWorldFile: Savedata is empty on load")

        UpgradeSaveFile(savedata)
        LoadAssets("BACKEND", savedata)
		DoInitGame(savedata, Profile)
	end
	ShardGameIndex:GetSaveDataFile(file, onload)
end

local function DoLoadWorld()
	local function onload(savedata)
		assert(savedata, "DoLoadWorld: Savedata is NIL on load")
		assert(GetTableSize(savedata)>0, "DoLoadWorld: Savedata is empty on load")

        UpgradeSaveFile(savedata)
        LoadAssets("BACKEND", savedata)
		DoInitGame(savedata, Profile)
	end
	ShardGameIndex:GetSaveData(onload)
end

local function DoGenerateWorld()
	local function onComplete(savedata)
		assert(savedata, "DoGenerateWorld: Savedata is NIL on load")
		assert(#savedata>0, "DoGenerateWorld: Savedata is empty on load")

		local function onsaved()
			local success, world_table = RunInSandbox(savedata)
			if success then
				LoadAssets("BACKEND", world_table)
				DoInitGame(world_table, Profile)
			end
		end

		if string.match(savedata, "^error") then
			local success,e = RunInSandbox(savedata)
			print("Worldgen had an error, displaying...")
			DisplayError(e)
		else
			local success, world_table = RunInSandbox(savedata)

			--todo, if we add more values to this, turn this into a function thats called both here and mainfunctions.lua@SaveGame
			local metadata = {clock = {}, seasons = {}}
			if savedata and savedata.world_network and savedata.world_network.persistdata then
				metadata.clock = savedata.world_network.persistdata.clock
				metadata.seasons = savedata.world_network.persistdata.seasons
			end
			local PRETTY_PRINT = BRANCH == "dev"
			local metadataStr = DataDumper(metadata, nil, not PRETTY_PRINT)

			ShardGameIndex:OnGenerateNewWorld(savedata, metadataStr, world_table.meta.session_identifier, onsaved)
		end
	end

    local world_gen_data =
    {
        level_type = GetLevelType(ShardGameIndex:GetGameMode()),
        level_data = ShardGameIndex:GetGenOptions(),
        profile_data = Profile.persistdata,
    }

    local hide_worldgen_screen = GetGameModeProperty("hide_worldgen_loading_screen") and (next(Settings.match_results) ~= nil)
	TheFrontEnd:PushScreen(WorldGenScreen(Profile, onComplete, world_gen_data, hide_worldgen_screen))
end

local function LoadSlot()
    TheFrontEnd:ClearScreens()
    if ShardGameIndex:CheckWorldFile() then
        --print("Load Slot: Has World")
        --LoadAssets("BACKEND")
        --V2C: Loading backend moved to after we know what world prefab we want
        DoLoadWorld()
    else
        --print("Load Slot: Has no World")
        print("Load Slot: ... generating new world")
        DoGenerateWorld()
    end
end

function ShowDemoExpiredDialog()
	local DemoOverPopupDialogScreen = require "screens/demooverpopup"

	local popup = DemoOverPopupDialogScreen(RequestShutdown)
	TheFrontEnd:PushScreen(popup)
end

----------------LOAD THE PROFILE AND THE SAVE INDEX, AND START THE FRONTEND

local function DoResetAction()
	if LOAD_UPFRONT_MODE then
		print ("load recipes")

		RECIPE_PREFABS = {}
		for k,v in pairs(AllRecipes) do
			table.insert(RECIPE_PREFABS, v.product)
			if v.placer then
				table.insert(RECIPE_PREFABS, v.placer)
			end
		end

		TheSim:LoadPrefabs(RECIPE_PREFABS)
		print ("load backend")
        --V2C: load ALL the BACKEND_PREFABS for all types of worlds
		TheSim:LoadPrefabs(BACKEND_PREFABS)
        --V2C: load ALL the SPECIAL_EVENT_BACKEND_PREFABS, since game backend events can be overriden in world options
        for k, v in pairs(SPECIAL_EVENTS) do
            TheSim:LoadPrefabs({ v.."_event_backend" })
        end
        TheSim:LoadPrefabs(FESTIVAL_EVENT_BACKEND_PREFABS)
		print ("load frontend")
		TheSim:LoadPrefabs(FRONTEND_PREFABS)
        TheSim:LoadPrefabs(SPECIAL_EVENT_FRONTEND_PREFABS)
        TheSim:LoadPrefabs(FESTIVAL_EVENT_FRONTEND_PREFABS)
		print ("load characters")
		local chars = GetActiveCharacterList()
		TheSim:LoadPrefabs(chars)
	end

	if Settings.reset_action then
		if Settings.reset_action == RESET_ACTION.DO_DEMO then
			--print("Reset Action: DO_DEMO")
			ShardGameIndex:NewShardInSlot(1, "Master")
			ShardGameIndex:Delete(function()
				ShardGameIndex:SetServerShardData(
					nil,
					GetDefaultServerData(),
					function()
						DoGenerateWorld()
					end)
			end)
		elseif Settings.reset_action == RESET_ACTION.LOAD_SLOT then
			--ShardGameIndex already contains the contextual slot from Settings.save_slot
			if ShardGameIndex:IsEmpty() then
				--print("Reset Action: LOAD_SLOT -- Re-generate world")
                ShardGameIndex:Delete(function()
                    ShardGameIndex:SetServerShardData(
                        ShardGameIndex:GetGenOptions(),
                        ShardGameIndex:GetServerData(),
                        function()
                            DoGenerateWorld()
                        end)
                end, true)
			else
				--print("Reset Action: LOAD_SLOT -- current save")
				LoadSlot()
			end
		elseif Settings.reset_action == RESET_ACTION.LOAD_FILE then
			--LoadAssets("BACKEND")
            --V2C: Loading backend moved to after we know what world prefab we want
			DoLoadWorldFile(Settings.save_name)
		elseif Settings.reset_action == "printtextureinfo" then
			--print("Reset Action: printtextureinfo")
			DoGenerateWorld()
		elseif Settings.reset_action == RESET_ACTION.LOAD_FRONTEND then
			print("Reset Action: none, loading front end")
			LoadAssets("FRONTEND")
			if MainScreen then
				TheFrontEnd:ShowScreen(MainScreen(Profile))
			end
		elseif Settings.reset_action == RESET_ACTION.JOIN_SERVER then
            local start_worked = TheNet:StartClient( Settings.serverIp, Settings.serverPort, nil, Settings.serverPassword, Settings.serverNetId )
            if not start_worked then
                OnNetworkDisconnect("ID_DST_USER_CONNECTION_FAILED", true)
            end
        end
	else
		if PRINT_TEXTURE_INFO then
			ShardGameIndex:NewShardInSlot(1, "Master")
			ShardGameIndex:Delete(
				function()
					local function onsaved()
						SimReset({reset_action="printtextureinfo",save_slot=1})
					end
					ShardGameIndex:SetServerShardData(nil, GetDefaultServerData(), onsaved)
				end)
		else
			LoadAssets("FRONTEND")
			if MainScreen then
				TheFrontEnd:ShowScreen(MainScreen(Profile))
				if PLATFORM == "WIN32_RAIL" and TheSim:IsDemoExpired() then
					ShowDemoExpiredDialog()
				end
			end
		end
	end
end

local function OnUpdatePurchaseStateComplete()
	print("OnUpdatePurchaseStateComplete")
	--print( "[Settings]",Settings.character, Settings.savefile)

	if TheInput:ControllerAttached() then
		TheFrontEnd:StopTrackingMouse()
	end

	DoResetAction()
end

local function OnFilesLoaded()
    print("OnFilesLoaded()")
    if not (TheNet:IsDedicated() or TheNet:GetIsServer() or TheNet:GetIsClient()) then
        local host_sessions = {}
        for i, slot in ipairs(ShardSaveGameIndex:GetValidSlots()) do
            local session = ShardSaveGameIndex:GetSlotSession(slot, "Master")
            if session ~= nil then
                table.insert(host_sessions, session)
            end
        end
        TheNet:CleanupSessionCache(host_sessions)

        if #host_sessions > 0 then
            Profile:ShowedNewUserPopup()
            Profile:ShowedNewHostPicker()
            Profile:Save(function()
                UpdateGamePurchasedState(OnUpdatePurchaseStateComplete)
            end)
            return
        end
    end
    UpdateGamePurchasedState(OnUpdatePurchaseStateComplete)
end

SaveGameIndex = SaveIndex()
ShardSaveGameIndex = ShardSaveIndex()
ShardGameIndex = ShardIndex()
Morgue = PlayerDeaths()
PlayerHistory = PlayerHistory()
ServerPreferences = ServerPreferences()
ProfanityFilter = ProfanityFilter()
ConsoleScreenSettings = ConsoleScreenSettings()
CustomPresetManager = CustomPresets()
CustomPresetManager:Load()

Print(VERBOSITY.DEBUG, "[Loading Morgue]")
Morgue:Load( function(did_it_load)
	--print("Morgue loaded....[",did_it_load,"]")
end )
PlayerHistory:Load( function() end )
ServerPreferences:Load( function() end )
ProfanityFilter:AddDictionary("default", require("wordfilter"))

--Now let's setup debugging!!!
if DEBUGGER_ENABLED then
    local startResult, breakerType = Debuggee.start()
    print('Debuggee start ->', startResult, breakerType )
end

ConsoleScreenSettings:Load()

Print(VERBOSITY.DEBUG, "[Loading profile and save index]")
Profile:Load( function()
	SaveGameIndex:Load(function()
		ShardSaveGameIndex:Load(function()
			ShardGameIndex:Load( OnFilesLoaded )
		end)
	end)
end)

if not TheNet:IsDedicated() and (TheNet:GetIsClient() or TheNet:GetIsServer()) and not ChatHistory:HasHistory() then
	local user_table = TheNet:GetClientTableForUser(TheNet:GetUserID())

	if user_table then
		ChatHistory:AddJoinMessageToHistory(
			ChatTypes.Announcement,
			nil,
			string.format(STRINGS.UI.NOTIFICATION.JOINEDGAME, Networking_Announcement_GetDisplayName(TheNet:GetLocalUserName())),
			user_table.colour or WHITE,
			"join_game"
		)
	end
end

require "platformpostload" --Note(Peter): The location of this require is currently only dependent on being after the built in usercommands being loaded

--Online servers will call StartDedicatedServer after authentication
if TheNet:IsDedicated() and not TheNet:GetIsServer() and TheNet:IsDedicatedOfflineCluster() then
	StartDedicatedServer()
end

Stats.InitStats()
