require("map/task")
require("map/lockandkey")
require("map/terrain")

SIZE_VARIATION = 3


local taskdefinitions = {}
local modtaskdefinitions = {}

------------------------------------------------------------------
-- Module functions
------------------------------------------------------------------

local function GetAllTaskNames()
    local ret = {}
    for i,task in ipairs(taskdefinitions) do
        table.insert(ret, task.id)
    end
    for mod, tasks in pairs(modtaskdefinitions) do
        for i,task in ipairs(tasks) do
            table.insert(ret, task.id)
        end
    end
    return ret
end

local function GetTaskByName(name)
    for i,task in ipairs(taskdefinitions) do
        if task.id == name then
            return task
        end
    end
    for mod, tasks in pairs(modtaskdefinitions) do
        for i,task in ipairs(tasks) do
            if task.id == name then
                return task
            end
        end
    end

    return nil
end

local function ClearModData(mod)
    if mod ~= nil then
        modtaskdefinitions[mod] = nil
    else
        modtaskdefinitions = {}
    end
end

------------------------------------------------------------------
-- GLOBAL functions
------------------------------------------------------------------

function AddTask(name, data)
    assert(GetTaskByName(name) == nil, "Tried adding a task '"..name.."' but it already exists!")
    table.insert(taskdefinitions, Task(name, data))
end

function AddModTask(mod, name, data)
    if GetTaskByName(name) ~= nil then
        moderror(string.format("Tried adding a task called '%s' but that already exists!\n\t\tMaybe try extending and modifying that task using AddTaskPreInit instead?", name))
        return
    end

    if modtaskdefinitions[mod] == nil then modtaskdefinitions[mod] = {} end
    table.insert(modtaskdefinitions[mod], Task(name, data))
end


------------------------------------------------------------------
-- Load the data
------------------------------------------------------------------

-- A set of tasks to be performed
local everything_sample2 = {
	Task("One of everything", {
		locks=LOCKS.NONE,
		keys_given=KEYS.PICKAXE,
		room_choices={
			["DenseRocks"] = 1,
			["DenseForest"] = 1,
			["SpiderCon"] = 3,
			["Forest"] = 1,
		 },
		room_bg=WORLD_TILES.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0,a=1}
	})
}
local everything_sample = {
	Task("One of everything", {
		locks=LOCKS.NONE,
		keys_given=KEYS.PICKAXE,
		room_choices={
			["Graveyard"] = 1,
			["BeefalowPlain"] = 1,
			["SpiderVillage"] = 1,
			["PigKingdom"] = 1,
			["PigVillage"] = 1,
			["MandrakeHome"] = 1,
			["BeeClearing"] = 1,
			["DenseRocks"] = 1,
			["DenseForest"] = 1,
			["Rockpile"] = 1,
			["Woodpile"] = 1,
			["Trapfield"] = 1,
			["Minefield"] = 1,
			["SpiderCon"] = 1,
			["Forest"] = 1,
			["Rocky"] = 1,
			["BarePlain"] = 1,
			["Plain"] = 1,
			["Marsh"] = 1,
			["DeepForest"] = 1,
			["Clearing"] = 1,
			["BurntForest"] = 1,
		},
		room_bg=WORLD_TILES.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0,a=1}
	})
}

require("map/tasks/maxwell")
require("map/tasks/island_hopping")

require("map/tasks/forest")
require("map/tasks/moonisland_tasks")
require("map/tasks/caves")
require("map/tasks/ruins")
require("map/tasks/DLCtasks")
require("map/tasks/lavaarena")
require("map/tasks/quagmire")

------------------------------------------------------------------------------------------------------------------------
-- TEST TASKS
------------------------------------------------------------------------------------------------------------------------

AddTask("TEST_TASK", {
		locks=LOCKS.NONE,
		keys_given=KEYS.LIGHT,
		room_choices={
			["BGCaveRoom"] = 1,
		},
		room_bg=WORLD_TILES.SINKHOLE,
		background_room="BGSinkholeRoom",
		colour={r=1,g=0.7,b=1,a=1},
	})

AddTask("TEST_TASK1", {
		locks=LOCKS.LIGHT,
		keys_given=KEYS.CAVE,
		room_choices={
			["CaveRoom"] = 3,
			["BatCaveRoom"] = 1,
		},
		room_bg=WORLD_TILES.CAVE,
		background_room="BGCaveRoom",
		colour={r=1,g=0.6,b=1,a=1},
	})
AddTask("TEST_EMPTY", {
		locks=LOCKS.NONE,
		keys_given=KEYS.NONE,
		room_choices = {
			["Clearing"] = 1,
		},
		room_bg = WORLD_TILES.FOREST,
		background_room = "Clearing",
		colour = { r = 1, g = 1, b = 1, a = 1 },
	})

------------------------------------------------------------------
-- Export functions
------------------------------------------------------------------

return {
    oneofeverything = everything_sample,
    GetAllTaskNames = GetAllTaskNames,
    GetTaskByName = GetTaskByName,
    ClearModData = ClearModData,
}
