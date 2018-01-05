require "mods"
require "playerdeaths"
require "playerhistory"
require "saveindex"
require "map/extents"
require "perfutil"
require "maputil"
require "constants"
require "knownerrors"

require "usercommands"
require "builtinusercommands"
require "emotes"

local EquipSlot = require("equipslotutil")
local GroundTiles = require("worldtiledefs")
local Stats = require("stats")

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
local PauseScreen = require "screens/pausescreen"

Print (VERBOSITY.DEBUG, "[Loading frontend assets]")

local screen_fade_time = .25

local start_game_time = nil

LOADED_CHARACTER = nil

TheSim:SetRenderPassDefaultEffect( RENDERPASS.BLOOM, "shaders/anim_bloom.ksh" )
TheSim:SetErosionTexture( "images/erosion.tex" )

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
	if global_loading_widget then 
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
	if LOAD_UPFRONT_MODE then
        ModManager:RegisterPrefabs()
        return
    end

	ShowLoading()

	assert(asset_set)
	Settings.current_asset_set = asset_set
    Settings.current_world_asset = savedata ~= nil and savedata.map.prefab or nil

	RECIPE_PREFABS = {}
	for k,v in pairs(AllRecipes) do
		table.insert(RECIPE_PREFABS, v.name)
		if v.placer then
			table.insert(RECIPE_PREFABS, v.placer)
		end
	end
	local load_frontend = Settings.reset_action == nil
	local in_backend = Settings.last_reset_action ~= nil
	local in_frontend = not in_backend

	KeepAlive()

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
                TheSim:UnloadPrefabs(SPECIAL_EVENT_BACKEND_PREFABS)
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
            TheSim:LoadPrefabs(SPECIAL_EVENT_BACKEND_PREFABS)
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
}

POPULATING = false
local function PopulateWorld(savedata, profile)
    POPULATING = true
    TheSystemService:SetStalling(true)
    Print(VERBOSITY.DEBUG, "PopulateWorld")
    Print(VERBOSITY.DEBUG, "[Instantiating objects...]")
    if savedata ~= nil then
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
            if LOADED_CHARACTER ~= nil then
                for i, v in ipairs(LOADED_CHARACTER) do
                    oldloaded[v] = true
                end
            end
            LOADED_CHARACTER = GetActiveCharacterList()
            local newchars = {}
            for i, v in ipairs(LOADED_CHARACTER) do
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
            if next(unloadchars) ~= nil then
                TheSim:UnloadPrefabs(unloadchars)
            end
            if next(newchars) ~= nil then
                TheSim:LoadPrefabs(newchars)
            end
        end

        --this was spawned by the level file. kinda lame - we should just do everything from in here.
        world.Map:SetSize(savedata.map.width, savedata.map.height)
        world.Map:SetFromString(savedata.map.tiles)
        world.Map:ResetVisited()
        if savedata.map.prefab == "cave" then
            world.Map:SetPhysicsWallDistance(0.75)--0) -- TEMP for STREAM
            TheFrontEnd:GetGraphicsOptions():DisableStencil()
            TheFrontEnd:GetGraphicsOptions():DisableLightMapComponent()
            -- TheFrontEnd:GetGraphicsOptions():EnableStencil()
            -- TheFrontEnd:GetGraphicsOptions():EnableLightMapComponent()
            world.Map:Finalize(1)
        else
            world.Map:SetPhysicsWallDistance(0)--0.75)
            TheFrontEnd:GetGraphicsOptions():DisableStencil()
            TheFrontEnd:GetGraphicsOptions():DisableLightMapComponent()
            world.Map:Finalize(0)
        end

        if savedata.map.nav then
            print("Loading Nav Grid")
            world.Map:SetNavSize(savedata.map.width, savedata.map.height)
            world.Map:SetNavFromString(savedata.map.nav)
         else
            print("No Nav Grid")
        end

        world.hideminimap = savedata.map.hideminimap
        world.topology = savedata.map.topology
        world.generated = savedata.map.generated
        world.meta = savedata.meta
        assert(savedata.map.topology.ids, "[MALFORMED SAVE DATA] Map missing topology information. This save file is too old, and is missing neccessary information.")

        for i=#savedata.map.topology.ids,1, -1 do
            local name = savedata.map.topology.ids[i]
            if string.find(name, "LOOP_BLANK_SUB") ~= nil then
                table.remove(savedata.map.topology.ids, i)
                table.remove(savedata.map.topology.nodes, i)
                for eid=#savedata.map.topology.edges,1,-1 do
                    if savedata.map.topology.edges[eid].n1 == i or savedata.map.topology.edges[eid].n2 == i then
                        table.remove(savedata.map.topology.edges, eid)
                    end
                end
            end
        end

        for i,node in ipairs(world.topology.nodes) do
            local story = world.topology.ids[i]
            -- guard for old saves
            local story_depth = nil
            if world.topology.story_depths then
                story_depth = world.topology.story_depths[i]
            end
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

            local gamemode = TheNet:GetServerGameMode()
			world:PushEvent("ms_setspawnmode", GetSpawnMode( gamemode ) )
			world:PushEvent("ms_setworldresettime", GetResetTime( gamemode ) )
            world:PushEvent("ms_enableresourcerenewal", GetHasResourceRenewal( gamemode ) )

            --V2C: forward to MOD game mode server configuration HERE
        end

        -- Force overrides for ambient
        local tuning_override = require("tuning_override")
        tuning_override.areaambientdefault(savedata.map.prefab)

		ApplySpecialEvent(world.topology.overrides and world.topology.overrides.specialevent or nil)

        -- Check for map overrides
        if world.topology.overrides ~= nil and GetTableSize(world.topology.overrides) > 0 then
            for override,value in pairs(world.topology.overrides) do
                if tuning_override[override] ~= nil then
                    print("OVERRIDE: setting",override,"to",value)
                    tuning_override[override](value)
                end
            end

            -- Clear out one time overrides
            local onetime = {"season_start", "autumn", "winter", "spring", "summer", "frograin", "wildfires", "prefabswaps_start", "rock_ice"}
            for i,override in ipairs(onetime) do
                if world.topology.overrides[override] ~= nil then
                    print("removing onetime override",override)
                    world.topology.overrides[override] = nil
                end
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
	local debugdrawmap = CreateEntity()
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

local function OnPlayerActivated(world)
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
        world:DoTaskInTime(0, SendResumeRequestToServer, delay - 1)
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
        TheFrontEnd:ClearScreens()
        TheFrontEnd:SetFadeLevel(1)
        TheMixer:PopMix("normal")
        SetPause(true)
        SendResumeRequestToServer(world, 2)
    end
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
	--assert(savedata.map.topology.story_depths, "Topology story_depths are missing from savedata on load")
	assert(savedata.map.topology.colours, "Topology colours are missing from savedata on load")
	assert(savedata.map.topology.edges, "Topology edges are missing from savedata on load")
	assert(savedata.map.topology.nodes, "Topology nodes are missing from savedata on load")
	assert(savedata.map.topology.level_type, "Topology level type is missing from savedata on load")
	assert(savedata.map.topology.overrides, "Topology overrides is missing from savedata on load")

    -- #deleteme: gjans: New data added to worldgen 2015/06/23, uncomment this assert in September or something
	--assert(savedata.map.generated, "Original generation data missing from savedata on load")
	--assert(savedata.map.generated.densities, "Generated prefab densities missing from savedata on load")

	assert(savedata.ents, "Entities missing from savedata on load")

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

	-- Generate a server friendly version of the map
    if TheNet:GetIsServer() then
    	-- todo markl
		-- Make it so the paths used here come directly from the engine
		
		-- Setup appropriate folders for saving session data
		TheNet:BeginSession(savedata.meta.session_identifier)
		
   		local ent_ref = savedata.ents
        local snapshot_ref = savedata.snapshot
		-- local node_ref = savedata.nodes
		savedata.ents = {}
        savedata.snapshot = nil
		local COMPRESSED = true

		local data = DataDumper(savedata, nil, COMPRESSED)
        local server_file = "server_temp"..DEFAULT_SERVER_SAVE_FILE
		print("saving to "..server_file)
		local insz, outsz = TheSim:SetPersistentString(server_file, data, COMPRESSED, nil)
		savedata.ents = ent_ref
        savedata.snapshot = snapshot_ref
	end

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
	
	if PLATFORM == "PS4" then
	    if not TheSystemService:HasFocus() or not TheInputProxy:IsAnyInputDeviceConnected() then
	        TheFrontEnd:PushScreen(PauseScreen())
	    end
	end
	
	TheNet:DoneLoadingMap( )
	    
	if TheNet:GetIsServer() then
	    NotifyLoadingState( LoadingStates.DoneLoading )
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
		assert(savedata, "DoLoadWorld: Savedata is NIL on load")
		assert(GetTableSize(savedata)>0, "DoLoadWorld: Savedata is empty on load")

        UpgradeSaveFile(savedata)
        LoadAssets("BACKEND", savedata)
		DoInitGame(savedata, Profile)
	end
	SaveGameIndex:GetSaveDataFile(file, onload)
end

local function DoLoadWorld(saveslot)
	local function onload(savedata)
		assert(savedata, "DoLoadWorld: Savedata is NIL on load")
		assert(GetTableSize(savedata)>0, "DoLoadWorld: Savedata is empty on load")

        UpgradeSaveFile(savedata)
        LoadAssets("BACKEND", savedata)
		DoInitGame(savedata, Profile)
	end
	SaveGameIndex:GetSaveData(saveslot, onload)
end

local function DoGenerateWorld(saveslot)
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
			SaveGameIndex:OnGenerateNewWorld(saveslot, savedata, world_table.meta.session_identifier, onsaved)
		end
	end

    local world_gen_data =
    {
        level_type = GetLevelType(SaveGameIndex:GetGameMode(saveslot)),
        level_data = SaveGameIndex:GetSlotGenOptions(saveslot),
        profile_data = Profile.persistdata,
    }

    local hide_worldgen_screen = GetGameModeProperty("hide_worldgen_loading_screen") and (next(Settings.match_results) ~= nil)
	TheFrontEnd:PushScreen(WorldGenScreen(Profile, onComplete, world_gen_data, hide_worldgen_screen))
end

local function LoadSlot(slot)
    TheFrontEnd:ClearScreens()
    if SaveGameIndex:CheckWorldFile(slot) then
        --print("Load Slot: Has World")
        --LoadAssets("BACKEND")
        --V2C: Loading backend moved to after we know what world prefab we want
        DoLoadWorld(slot)
    else
        --print("Load Slot: Has no World")
        print("Load Slot: ... generating new world")
        DoGenerateWorld(slot)
    end
end

----------------LOAD THE PROFILE AND THE SAVE INDEX, AND START THE FRONTEND

local function DoResetAction()
	if LOAD_UPFRONT_MODE then
		print ("load recipes")

		RECIPE_PREFABS = {}
		for k,v in pairs(AllRecipes) do
			table.insert(RECIPE_PREFABS, v.name)
			if v.placer then
				table.insert(RECIPE_PREFABS, v.placer)
			end
		end		
			
		TheSim:LoadPrefabs(RECIPE_PREFABS)
		print ("load backend")
        --V2C: load ALL the BACKEND_PREFABS for all types of worlds
		TheSim:LoadPrefabs(BACKEND_PREFABS)
        TheSim:LoadPrefabs(SPECIAL_EVENT_BACKEND_PREFABS)
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
			SaveGameIndex:DeleteSlot(1, function()
				SaveGameIndex:StartSurvivalMode(1, nil, GetDefaultServerData(), function() 
					--print("Reset Action: DO_DEMO")
					DoGenerateWorld(1)
				end)
			end)
		elseif Settings.reset_action == RESET_ACTION.LOAD_SLOT then
			if SaveGameIndex:IsSlotEmpty(Settings.save_slot) then
				--print("Reset Action: LOAD_SLOT -- Re-generate world")
                SaveGameIndex:DeleteSlot(Settings.save_slot, function()
                    SaveGameIndex:StartSurvivalMode(
                        Settings.save_slot,
                        SaveGameIndex:GetSlotGenOptions(Settings.save_slot),
                        SaveGameIndex:GetSlotServerData(Settings.save_slot),
                        function()
                            DoGenerateWorld(Settings.save_slot)
                        end)
                end, true)
			else
				--print("Reset Action: LOAD_SLOT -- current save")
				LoadSlot(Settings.save_slot)
			end
		elseif Settings.reset_action == RESET_ACTION.LOAD_FILE then
			--LoadAssets("BACKEND")
            --V2C: Loading backend moved to after we know what world prefab we want
			DoLoadWorldFile(Settings.save_name)
		elseif Settings.reset_action == "printtextureinfo" then
			--print("Reset Action: printtextureinfo")
			DoGenerateWorld(1)
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
			SaveGameIndex:DeleteSlot(1,
				function()
					local function onsaved()
						SimReset({reset_action="printtextureinfo",save_slot=1})
					end
					SaveGameIndex:StartSurvivalMode(1, nil, GetDefaultServerData(), onsaved)
				end)
		else
			LoadAssets("FRONTEND")
			if MainScreen then
				TheFrontEnd:ShowScreen(MainScreen(Profile))
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
        for i = 1, SaveGameIndex:GetNumSlots() do
            local session = SaveGameIndex:GetSlotSession(i)
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

Profile = require("playerprofile")()
SaveGameIndex = SaveIndex()
Morgue = PlayerDeaths()
PlayerHistory = PlayerHistory()

Print(VERBOSITY.DEBUG, "[Loading Morgue]")
Morgue:Load( function(did_it_load) 
	--print("Morgue loaded....[",did_it_load,"]")
end )
PlayerHistory:Load( function() end )

Print(VERBOSITY.DEBUG, "[Loading profile and save index]")
Profile:Load( function() 
	SaveGameIndex:Load( OnFilesLoaded )
end )

--Online servers will call StartDedicatedServer after authentication
if TheNet:IsDedicated() and not TheNet:GetIsServer() and TheNet:IsDedicatedOfflineCluster() then
	StartDedicatedServer()
end

Stats.InitStats()
