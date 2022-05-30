-- Override the package.path in luaconf.h because it is impossible to find
package.path = "scripts\\?.lua;scriptlibs\\?.lua"
package.assetpath = {}
table.insert(package.assetpath, {path = ""})

function SetWorldGenSeed(seed)
	if seed == nil then
		seed = tonumber(tostring(os.time()):reverse():sub(1,6))
	end

	math.randomseed(seed)
	math.random()

	return seed
end


--local BAD_CONNECT = 219000 --
--SEED = 1568654163 -- Force roads test level 3
SEED = SetWorldGenSeed(SEED)

--print ("worldgen_main.lua MAIN = 1")

WORLDGEN_MAIN = 1
POT_GENERATION = false

--install our crazy loader! MUST BE HERE FOR NACL
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
			return result
		end
        errmsg = errmsg.."\n\tno file '"..filename.."' (checked with custom loader)"
    end
  	return errmsg
end
table.insert(package.loaders, 2, loadfn)

local basedir = "./"
--patch this function because NACL has no fopen
if TheSim then
    basedir = "scripts/"
    function loadfile(filename)
        return kleiloadlua(filename)
    end
end


function IsConsole()
	return (PLATFORM == "PS4") or (PLATFORM == "XBONE")
end

function IsNotConsole()
	return not IsConsole()
end

function IsPS4()
	return (PLATFORM == "PS4")
end

function IsXB1()
	return (PLATFORM == "XBONE")
end

function IsSteam()
	return PLATFORM == "WIN32_STEAM" or PLATFORM == "LINUX_STEAM" or PLATFORM == "OSX_STEAM"
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

require("stacktrace")

require("simutil")

require("strict")
require("debugprint")

-- add our print loggers
AddPrintLogger(function(...) WorldSim:LuaPrint(...) end)

require("debugtools")
require("json")
require("vector3")
require("class")
require("util")
require("ocean_util")
require("dlcsupport_worldgen")
require("constants")
require("tuning")
require("strings")
require("dlcsupport_strings")
require("prefabs")
require("profiler")
require("dumper")
local savefileupgrades = require("savefileupgrades")

require("mods")
require("modindex")

local tasks = require("map/tasks")
local levels = require("map/levels")
local rooms = require("map/rooms")
local tasksets = require("map/tasksets")
local forest_map = require("map/forest_map")
local startlocations = require("map/startlocations")
local PrefabSwaps = require("prefabswaps")

local moddata = json.decode(GEN_MODDATA)
if moddata then
	KnownModIndex:RestoreCachedSaveData(moddata.index)
	ModManager:LoadMods(true)
end


print ("running worldgen_main.lua\n")
SEED = SetWorldGenSeed(SEED)
print ("SEED = ", SEED)

local basedir = "./"

local last_tick_seen = -1





------TIME FUNCTIONS

function GetTickTime()
    return 0
end

function GetTime()
    return 0
end

function GetStaticTime()
    return 0
end

function GetTick()
    return 0
end

function GetStaticTick()
    return 0
end

function GetTimeReal()
    return getrealtime()
end

---SCRIPTING
local Scripts = {}

function LoadScript(filename)
    if not Scripts[filename] then
        local scriptfn = loadfile("scripts/" .. filename)
        Scripts[filename] = scriptfn()
    end
    return Scripts[filename]
end


function RunScript(filename)
    local fn = LoadScript(filename)
    if fn then
        fn()
    end
end

function GetDebugString()
    return tostring(scheduler)
end


function PROFILE_world_gen(debug)
	require("profiler")
	local profiler = newProfiler("time", 100000)
	profiler:start()

	local strdata = LoadParametersAndGenerate(debug)

	profiler:stop()
	local outfile = io.open( "profile.txt", "w+" )
	profiler:report(outfile)
	outfile:close()
	local tmp = {}

	profiler:lua_report(tmp)
	require("debugtools")
	dumptable(profiler)

	return strdata
end

function ShowDebug(savedata)
	local item_table = { }

	for id, locs in pairs(savedata.ents) do
		for i, pos in ipairs(locs) do
			local misc = -1
			if string.find(id, "wormhole") ~= nil then
				if pos.data and pos.data.teleporter and pos.data.teleporter.target then
					misc = pos.data.teleporter.target - 2300000
				end
			end
			table.insert(item_table, {id, pos.x/TILE_SCALE + savedata.map.width/2.0, pos.z/TILE_SCALE + savedata.map.height/2.0, misc})
		end
	end

	WorldSim:ShowDebugItems(item_table)
end

function CheckMapSaveData(savedata)
    print("Checking map...")

    assert(savedata.map, "Map missing from savedata on generate")
    assert(savedata.map.prefab, "Map prefab missing from savedata on generate")
    assert(savedata.map.tiles, "Map tiles missing from savedata on generate")
    assert(savedata.map.width, "Map width missing from savedata on generate")
    assert(savedata.map.height, "Map height missing from savedata on generate")
    assert(savedata.map.topology, "Map topology missing from savedata on generate")

    assert(savedata.ents, "Entities missing from savedata on generate")
end

local function GetRandomFromLayouts( layouts )
	local area_keys = {}
	for k,v in pairs(layouts) do
		table.insert(area_keys, k)
	end
	local area_idx =  math.random(#area_keys)
	local area = area_keys[area_idx]
	local target = nil
	if (area == "Rare" and math.random()<0.98) or GetTableSize(layouts[area]) <1 then
		table.remove(area_keys, area_idx)
		area = area_keys[math.random(#area_keys)]
	end

	if GetTableSize(layouts[area]) <1 then
		return nil
	end

	target = {target_area=area, choice=GetRandomKey(layouts[area])}

	return target
end

local function GetAreasForChoice(area, task_set)
	local areas = {}

	for i, t in ipairs(task_set) do
		local task = tasks.GetTaskByName(t.id, tasks.taskdefinitions)
		if area == "Any" or area == "Rare" or area == task.room_bg then
			table.insert(areas, t.id)
		end
	end
	if #areas ==0 then
		return nil
	end
	return areas
end

local function AddSingleSetPeice(level, choicefile)
	local choices = require(choicefile)
	assert(choices.Sandbox)
	local chosen = GetRandomFromLayouts(choices.Sandbox)
	if chosen ~= nil then
		if level.set_pieces == nil then
			level.set_pieces = {}
		end

		local areas = GetAreasForChoice(chosen.target_area, level:GetTasksForLevelSetPieces())
		if areas then
			local num_peices = 1
			if level.set_pieces[chosen.choice] ~= nil then
				num_peices = level.set_pieces[chosen.choice].count + 1
			end
			level.set_pieces[chosen.choice] = {count = num_peices, tasks=areas}
		end
	end
end

local function AddSetPeices(level)

	local boons_override = "default"
	local touchstone_override = "default"
	local traps_override = "default"
	local poi_override = "default"
	local protected_override = "default"

    if level.overrides ~= nil and
        level.overrides ~= nil then

        if level.overrides.boons ~= nil then
            boons_override = level.overrides.boons
        end
        if level.overrides.touchstone ~= nil then
            touchstone_override = level.overrides.touchstone
        end
        if level.overrides.traps ~= nil then
            traps_override = level.overrides.traps
        end
        if level.overrides.poi ~= nil then
            poi_override = level.overrides.poi
        end
        if level.overrides.protected ~= nil then
            protected_override = level.overrides.protected
        end
    end

    if traps_override ~= "never" then
        AddSingleSetPeice(level, "map/traps")
    end
    if poi_override ~= "never" then
        AddSingleSetPeice(level, "map/pointsofinterest")
    end
    if protected_override ~= "never" then
        AddSingleSetPeice(level, "map/protected_resources")
    end

	if touchstone_override ~= "default" and level.set_pieces ~= nil and
								level.set_pieces["ResurrectionStone"] ~= nil then

		if touchstone_override == "never" then
			level.set_pieces["ResurrectionStone"] = nil
		else
			level.set_pieces["ResurrectionStone"].count = math.ceil(level.set_pieces["ResurrectionStone"].count*forest_map.MULTIPLY[touchstone_override])
		end
	end

	if boons_override ~= "never" then

		-- Quick hack to get the boons in
		for idx=1, math.random(math.floor(3*forest_map.MULTIPLY[boons_override]), math.ceil(8*forest_map.MULTIPLY[boons_override])) do
			AddSingleSetPeice(level, "map/boons")
		end
	end

end


function GenerateNew(debug, world_gen_data)

    print("Generating world with these parameters:")
    print("level_type", tostring(world_gen_data.level_type))
    print("level_data:")
    dumptable(world_gen_data.level_data)

    assert(world_gen_data.level_data ~= nil, "Must provide complete level data to worldgen.")
    local level = Level(world_gen_data.level_data) -- we always generate the first level defined in the data

    print(string.format("\n#######\n#\n# Generating %s Mode Level\n#\n#######\n", world_gen_data.level_type))

    assert(level.location ~= nil, "Level must specify a location!")
    local prefab = level.location

    PrefabSwaps.SelectPrefabSwaps(prefab, level.overrides)
    --[[
    --debugging
    PrefabSwaps.SelectPrefabSwaps(prefab, level.overrides, {
        ["berries"] = "juicy berries",
    })
    ]]

    level:ChooseTasks()
    AddSetPeices(level)
    level:ChooseSetPieces()

    local choose_tasks = level:GetTasksForLevel()

    if debug == true then
        choose_tasks = tasks.oneofeverything
    end
    --print ("Generating new world","forest", max_map_width, max_map_height, choose_tasks)

    local savedata = nil

    local max_map_width = 1024 -- 1024--256
    local max_map_height = 1024 -- 1024--256

    local try = 1
    local maxtries = 5

    while savedata == nil do
        savedata = forest_map.Generate(prefab, max_map_width, max_map_height, choose_tasks, level, world_gen_data.level_type)

        if savedata == nil then
            if try >= maxtries then
                print("An error occured during world and we give up! [was ",try," of ",maxtries,"]")
                return nil
            else
                print("An error occured during world gen we will retry! [was ",try," of ",maxtries,"]")
            end
            try = try + 1

            --assert(try <= maxtries, "Maximum world gen retries reached!")
            collectgarbage("collect")
            WorldSim:ResetAll()
        elseif GEN_PARAMETERS == "" or world_gen_data.show_debug == true then
            ShowDebug(savedata)
        end
    end


    savedata.map.prefab = prefab
    savedata.map.topology.level_type = world_gen_data.level_type
    savedata.map.topology.override_triggers = level.override_triggers or nil
    savedata.map.override_level_string = level.override_level_string or false
    savedata.map.name = level.name or "ERROR"
    savedata.map.hideminimap = level.hideminimap or false

    --Record mod information
    ModManager:SetModRecords(savedata.mods or {})
    savedata.mods = ModManager:GetModRecords()



	if APP_VERSION == nil then
		APP_VERSION = "DEV_UNKNOWN"
	end

	if APP_BUILD_DATE == nil then
		APP_BUILD_DATE = "DEV_UNKNOWN"
	end

	if APP_BUILD_TIME == nil then
		APP_BUILD_TIME = "DEV_UNKNOWN"
	end

	savedata.meta = {
						build_version = APP_VERSION,
						build_date = APP_BUILD_DATE,
						build_time = APP_BUILD_TIME,
						seed = SEED,
						level_id = level.id,
						session_identifier = WorldSim:GenerateSessionIdentifier(),
                        generated_on_saveversion = savefileupgrades.VERSION,
                        saveversion = savefileupgrades.VERSION,
					}

	CheckMapSaveData(savedata)

	-- Clear out scaffolding :)
	-- for i=#savedata.map.topology.ids,1, -1 do
	-- 	local name = savedata.map.topology.ids[i]
	-- 	if string.find(name, "LOOP_BLANK_SUB") ~= nil  then
	-- 		table.remove(savedata.map.topology.ids, i)
	-- 		table.remove(savedata.map.topology.nodes, i)
	-- 		for eid=#savedata.map.topology.edges,1,-1 do
	-- 			if savedata.map.topology.edges[eid].n1 == i or savedata.map.topology.edges[eid].n2 == i then
	-- 				table.remove(savedata.map.topology.edges, eid)
	-- 			end
	-- 		end
	-- 	end
	-- end

	print("Generation complete")

    local PRETTY_PRINT = BRANCH == "dev"
	local savedata_entities = savedata.ents
	savedata.ents = nil

    local data = {}
    for key,value in pairs(savedata) do    
        data[key] = DataDumper(value, nil, not PRETTY_PRINT)
    end

	--special handling for the entities table; contents are dumped per entity rather than 
	--dumping the whole entities table at once as is done for the other parts of the save data
	data.ents = {}
	for key, value in pairs(savedata_entities) do
		if key ~= "" then
			data.ents[key] = DataDumper(value, nil, not PRETTY_PRINT)
		end
	end

	return data
end

local function LoadParametersAndGenerate(debug)

    local world_gen_data = nil
    assert(GEN_PARAMETERS ~= nil, "Parameters were not provided to worldgen!")
    world_gen_data = json.decode(GEN_PARAMETERS)

    SetDLCEnabled(world_gen_data.DLCEnabled)

    return GenerateNew(debug, world_gen_data)
end

return LoadParametersAndGenerate(false)
