-- Override the package.path in luaconf.h because it is impossible to find
package.path = "scripts\\?.lua;scriptlibs\\?.lua"
package.assetpath = {}
table.insert(package.assetpath, {path = ""})

math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))
math.random()

function IsConsole()
	return PLATFORM == "PS4" or PLATFORM == "XBONE" or PLATFORM == "SWITCH"
end

function IsNotConsole()
	return not IsConsole()
end

function IsPS4()
	return PLATFORM == "PS4"
end

function IsXB1()
	return PLATFORM == "XBONE"
end

function IsSteam()
	return PLATFORM == "WIN32_STEAM" or PLATFORM == "LINUX_STEAM" or PLATFORM == "OSX_STEAM"
end

function IsWin32()
	return PLATFORM == "WIN32_STEAM" or PLATFORM == "WIN32_RAIL"
end

function IsLinux()
	return PLATFORM == "LINUX_STEAM"
end

function IsRail()
	return PLATFORM == "WIN32_RAIL"
end

function IsSteamDeck()
	return IS_STEAM_DECK
end

--defines
MAIN = 1
ENCODE_SAVES = BRANCH ~= "dev"
CHEATS_ENABLED = CONFIGURATION ~= "PRODUCTION"
CAN_USE_DBUI = CHEATS_ENABLED and PLATFORM == "WIN32_STEAM"
SOUNDDEBUG_ENABLED = false
SOUNDDEBUGUI_ENABLED = false
WORLDSTATEDEBUG_ENABLED = false
--DEBUG_MENU_ENABLED = true
DEBUG_MENU_ENABLED = BRANCH == "dev" or (IsConsole() and CONFIGURATION ~= "PRODUCTION")
METRICS_ENABLED = true
TESTING_NETWORK = 1
AUTOSPAWN_MASTER_SECONDARY = false
DEBUGRENDER_ENABLED = true
SHOWLOG_ENABLED = true
POT_GENERATION = false

-- Networking related configuration
DEFAULT_JOIN_IP				= "127.0.0.1"
DISABLE_MOD_WARNING			= false
DEFAULT_SERVER_SAVE_FILE    = "/server_save"

RELOADING = false

--debug.setmetatable(nil, {__index = function() return nil end})  -- Makes  foo.bar.blat.um  return nil if table item not present   See Dave F or Brook for details

ExecutingLongUpdate = false

DEBUGGER_ENABLED = TheSim:ShouldInitDebugger() and IsNotConsole() and CONFIGURATION ~= "PRODUCTION" and not TheNet:IsDedicated()
if DEBUGGER_ENABLED then
	Debuggee = require 'debuggee'
end

-- Testing and viewing skins on a more close level.
if CAN_USE_DBUI then
    require("dbui_no_package/debug_skins_data/hooks").Hooks("init")
end

local servers =
{
	release = "http://dontstarve-release.appspot.com",
	dev = "http://dontstarve-dev.appspot.com",
	--staging = "http://dontstarve-staging.appspot.com",
    --staging is now the live preview branch
    staging = "http://dontstarve-release.appspot.com",
}
GAME_SERVER = servers[BRANCH]


TheSim:SetReverbPreset("default")

if PLATFORM == "NACL" then
	VisitURL = function(url, notrack)
		if notrack then
			TheSim:SendJSMessage("VisitURLNoTrack:"..url)
		else
			TheSim:SendJSMessage("VisitURL:"..url)
		end
	end
end

--used for A/B testing and preview features. Gets serialized into and out of save games
GameplayOptions =
{
}

RequiredFilesForReload = {}

--install our crazy loader!
--ManifestManager:AddFileToModManifest(manifest_name, filename)
--manifest_name should be the foldername that your mod resides in IE workshop-xxxxxxxxx if your mod is a workshop mod, or the foldername of the mod if its a local mod.
--given the path ../mods/workshop-xxxxxxxxx/somefolder/somefile.lua manifest_name should be workshop-xxxxxxxxx and filename should be somefolder/somefile.lua
--you shouldn't ever need this unless your writing lua files to your mod directory, which isn't usually done.
local manifest_paths = {}
local loadfn = function(modulename)
    local errmsg = ""
    local modulepath = string.gsub(modulename, "[%.\\]", "/")
    for path in string.gmatch(package.path, "([^;]+)") do
		local pathdata = manifest_paths[path]
		if not pathdata then
			pathdata = {}
			local manifest, matches = string.gsub(path, MODS_ROOT.."([^\\]+)\\scripts\\%?%.lua", "%1", 1)
			if matches == 1 then
				pathdata.manifest = manifest
			end
			manifest_paths[path] = pathdata
		end
        local filename = string.gsub(string.gsub(path, "%?", modulepath), "\\", "/")
		local result = kleiloadlua(filename, pathdata.manifest, "scripts/"..modulepath..".lua")
		if result then
			local filetime = TheSim:GetFileModificationTime(filename)
			RequiredFilesForReload[filename] = filetime
			return result
		end
        errmsg = errmsg.."\n\tno file '"..filename.."' (checked with custom loader)"
    end
  	return errmsg
end
table.insert(package.loaders, 2, loadfn)

--patch this function because NACL has no fopen
if TheSim then
    function loadfile(filename)
        filename = string.gsub(filename, ".lua", "")
        filename = string.gsub(filename, "scripts/", "")
        return loadfn(filename)
    end
end

--if PLATFORM == "NACL" then
--    package.loaders[2] = nil
--end

--if not TheNet:GetIsClient() then
--	require("mobdebug").start()
--end

require("strict")
require("debugprint")
-- add our print loggers
AddPrintLogger(function(...) TheSim:LuaPrint(...) end)

require("config")

require("vector3")
require("mainfunctions")
require("preloadsounds")

require("mods")
require("json")
require("tuning")

Profile = require("playerprofile")() --profile needs to be loaded before language
Profile:Load( nil, true ) --true to indicate minimal load required for language.lua to read the profile.
LOC = require("languages/loc")
require("languages/language")
require("strings")

--Apply a baseline set of translations so that lua in the boot flow can access the correct strings, after the mods are loaded, main.lua will run this again
--Ideally we wouldn't need to do this, but stuff like maps/levels/forest loads in the boot flow and it caches strings before they've been translated.
--Doing an early translate here is less risky than changing all the cases of early string access. Downside is that it doesn't address the issue for mod transations.
TranslateStringTable( STRINGS )

require("stringutil")
require("dlcsupport_strings")
require("constants")
require("class")
require("util")
require("vecutil")
require("vec3util")
require("datagrid")
require("ocean_util")
require("actions")
require("debugtools")
require("simutil")
require("scheduler")
require("stategraph")
require("behaviourtree")
require("prefabs")
require("tiledefs")
require("tilegroups")
require("falloffdefs")
require("groundcreepdefs")
require("prefabskin")
require("entityscript")
require("profiler")
require("recipes")
require("brain")
require("emitters")
require("dumper")
require("input")
require("upsell")
require("stats")
require("frontend")
require("netvars")
require("networking")
require("networkclientrpc")
require("shardnetworking")
require("fileutil")
require("prefablist")
require("standardcomponents")
require("update")
require("fonts")
require("physics")
require("modindex")
require("mathutil")
require("components/lootdropper")
require("reload")
require("saveindex") -- Added by Altgames for Android focus lost handling
require("shardsaveindex")
require("shardindex")
require("custompresets")
require("gamemodes")
require("skinsutils")
require("wxputils")
require("klump")
require("popupmanager")
require("chathistory")
require("componentutil")
require("skins_defs_data")

if TheConfig:IsEnabled("force_netbookmode") then
	TheSim:SetNetbookMode(true)
end


print("Running main.lua\n")

TheSystemService:SetStalling(true)

VERBOSITY_LEVEL = VERBOSITY.ERROR
if CONFIGURATION ~= "PRODUCTION" then
	VERBOSITY_LEVEL = VERBOSITY.DEBUG
end

-- uncomment this line to override
VERBOSITY_LEVEL = VERBOSITY.WARNING

--instantiate the mixer
local Mixer = require("mixer")
TheMixer = Mixer.Mixer()
require("mixes")
TheMixer:PushMix("start")

local Stats = require("stats")


Prefabs = {}
Ents = {}
AwakeEnts = {}
UpdatingEnts = {}
NewUpdatingEnts = {}
StopUpdatingEnts = {}
StaticUpdatingEnts = {}
NewStaticUpdatingEnts = {}

StopUpdatingComponents = {}

WallUpdatingEnts = {}
NewWallUpdatingEnts = {}
num_updating_ents = 0
NumEnts = 0

prefabs = nil -- this is here so mods dont crash because one of our prefab scripts missed the local and a number of mods were erroneously abusing it

TheGlobalInstance = nil

global("TheCamera")
TheCamera = nil
global("ShadowManager")
ShadowManager = nil
global("RoadManager")
RoadManager = nil
global("EnvelopeManager")
EnvelopeManager = nil
global("PostProcessor")
PostProcessor = nil

global("FontManager")
FontManager = nil
global("MapLayerManager")
MapLayerManager = nil
global("Roads")
Roads = nil
global("TheFrontEnd")
TheFrontEnd = nil
global("TheWorld")
TheWorld = nil
global("TheFocalPoint")
TheFocalPoint = nil
global("ThePlayer")
ThePlayer = nil
global("AllPlayers")
AllPlayers = {}
global("SERVER_TERMINATION_TIMER")
SERVER_TERMINATION_TIMER = -1
global("EventAchievements")
EventAchievements = nil
global("TheRecipeBook")
TheRecipeBook = nil
global("TheCookbook")
TheCookbook = nil
global("ThePlantRegistry")
ThePlantRegistry = nil
global("TheSkillTree")
TheSkillTree = nil
global("TheGenericKV")
TheGenericKV = nil
global("TheScrapbookPartitions")
TheScrapbookPartitions = nil
global("TheCraftingMenuProfile")
TheCraftingMenuProfile = nil
global("Lavaarena_CommunityProgression")
Lavaarena_CommunityProgression = nil
global("TheLoadingTips")
TheLoadingTips = nil
global("SaveGameIndex")
SaveGameIndex = nil
global("ShardGameIndex")
ShardGameIndex = nil
global("ShardSaveGameIndex")
ShardSaveGameIndex = nil
global("CustomPresetManager")
CustomPresetManager = nil
global("HashesMessageState")
HashesMessageState = nil
global("LastUIRoot")
LastUIRoot = nil
global("IsIntegrityChecking")
IsIntegrityChecking = nil
require("globalvariableoverrides")

--world setup
require("map/levels")
require("map/tasks")
require("map/rooms")
require("map/tasksets")
require("map/startlocations")

inGamePlay = false

local function ModSafeStartup()

	-- If we failed to boot last time, disable all mods
	-- Otherwise, set a flag file to test for boot success.

	--Ensure we have a fresh filesystem
	TheSim:ClearFileSystemAliases()

	---PREFABS AND ENTITY INSTANTIATION

	ModManager:LoadMods()

	-- Apply translations
	TranslateStringTable( STRINGS )

	-- Register every standard prefab with the engine

    -- This one needs to be active from the get-go.
    -- event_deps is also needed for event specific globals.
    local async_batch_validation = RUN_GLOBAL_INIT
    LoadPrefabFile("prefabs/global", async_batch_validation)
    LoadPrefabFile("prefabs/event_deps", async_batch_validation)
    LoadAchievements("achievements.lua")
    EventAchievements = require("eventachievements")()
    EventAchievements:LoadAchievementsForEvent(require("lavaarena_achievements"))
    EventAchievements:LoadAchievementsForEvent(require("quagmire_achievements"))
    EventAchievements:LoadAchievementsForEvent(require("lavaarena_achievement_quest_defs"))
	TheRecipeBook = require("quagmire_recipebook")()
	TheRecipeBook:Load()
	TheCookbook = require("cookbookdata")()
	TheCookbook:Load()
	ThePlantRegistry = require("plantregistrydata")()
	ThePlantRegistry:Load()
	ThePlantRegistry.save_enabled = true
    TheSkillTree = require("skilltreedata")()
    TheSkillTree:Load()
    TheSkillTree.save_enabled = true
    TheGenericKV = require("generickv")
    TheGenericKV:Load()
    TheGenericKV.save_enabled = true
    TheScrapbookPartitions = require("scrapbookpartitions")()
    TheScrapbookPartitions:Load()
    TheScrapbookPartitions.save_enabled = true
	TheCraftingMenuProfile = require("craftingmenuprofile")()
	TheCraftingMenuProfile:Load()
	Lavaarena_CommunityProgression = require("lavaarena_communityprogression")()
	Lavaarena_CommunityProgression:Load()

	if TheLoadingTips == nil then
		TheLoadingTips = require("loadingtipsdata")()
		TheLoadingTips:Load()
	end

    local FollowCamera = require("cameras/followcamera")
    TheCamera = FollowCamera()

	--- GLOBAL ENTITY ---
    --[[Non-networked entity]]
    TheGlobalInstance = CreateEntity("TheGlobalInstance")
    TheGlobalInstance.entity:AddTransform()
    TheGlobalInstance.entity:SetCanSleep(false)
    TheGlobalInstance.persists = false
    TheGlobalInstance:AddTag("CLASSIFIED")

	if RUN_GLOBAL_INIT then
		GlobalInit()
	end

	ShadowManager = TheGlobalInstance.entity:AddShadowManager()
	ShadowManager:SetTexture( "images/shadow.tex" )
	RoadManager = TheGlobalInstance.entity:AddRoadManager()
	EnvelopeManager = TheGlobalInstance.entity:AddEnvelopeManager()

	PostProcessor = TheGlobalInstance.entity:AddPostProcessor()
	require("postprocesseffects")
	if not TheNet:IsDedicated() then
		BuildColourCubeShader()
		BuildZoomBlurShader()
		BuildBloomShader()
		BuildDistortShader()
		BuildLunacyShader()
		BuildMoonPulseShader()
		BuildMoonPulseGradingShader()
		BuildModShaders()
		SortAndEnableShaders()
	end

	require("shadeeffects")

	FontManager = TheGlobalInstance.entity:AddFontManager()
	MapLayerManager = TheGlobalInstance.entity:AddMapLayerManager()

	--intentionally STATIC, this can be called from anywhere to globally update the max radius used for physics waker calculations.
	PhysicsWaker.SetMaxPhysicsRadius(MAX_PHYSICS_RADIUS)

    -- I think we've got everything we need by now...
   	if IsNotConsole() then
		if TheSim:GetNumLaunches() == 1 then
			Stats.RecordGameStartStats()
		end
	end
end

SetInstanceParameters(json_settings)

if Settings.reset_action == RESET_ACTION.JOIN_SERVER then
	Settings.current_asset_set = Settings.last_asset_set
	ChatHistory:JoinServer()
end

local load_frontend_reset_action = Settings.reset_action == nil or Settings.reset_action == RESET_ACTION.LOAD_FRONTEND

if Settings.memoizedFilePaths ~= nil then
	if not load_frontend_reset_action then
		SetMemoizedFilePaths(Settings.memoizedFilePaths)
	end
	Settings.memoizedFilePaths = nil
end

if Settings.chatHistory ~= nil then
	if not load_frontend_reset_action then
		ChatHistory:SetChatHistory(Settings.chatHistory)
	end
	Settings.chatHistory = nil
end

if Settings.loaded_mods ~= nil then
	if load_frontend_reset_action then
    	ModManager:UnloadPrefabsFromData(Settings.loaded_mods)
	end
    Settings.loaded_mods = nil
end

if not MODS_ENABLED then
	-- No mods in nacl, and the below functions are async in nacl
	-- so they break because Main returns before ModSafeStartup has run.
	ModSafeStartup()
else
	KnownModIndex:Load(function()
		KnownModIndex:BeginStartupSequence(function()
			ModSafeStartup()
		end)
	end)
end

require "stacktrace"
require "debughelpers"

require "consolecommands"

--debug key init
if CHEATS_ENABLED then
    require "debugcommands"
    require "debugkeys"
end

TheSystemService:SetStalling(false)
