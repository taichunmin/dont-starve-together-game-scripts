
local taskgrouplist = {}
local modtaskgrouplist = {}

------------------------------------------------------------------
-- Module functions
------------------------------------------------------------------

local function GetGenTasks(id)
    for mod, list in pairs(modtaskgrouplist) do
        if list[id] ~= nil then
            return deepcopy(list[id])
        end
    end

    return deepcopy(taskgrouplist[id])
end

local function GetGenTaskLists(world)
    local ret = {}
    for k,v in pairs(taskgrouplist) do
        if not v.hideinfrontend and world == nil or v.location == world then
            table.insert(ret, {text = v.name, data = k})
        end
    end
    for mod,list in pairs(modtaskgrouplist) do
        for k,v in pairs(list) do
            if not v.hideinfrontend and world == nil or v.location == world then
                table.insert(ret, {text = v.name, data = k})
            end
        end
    end

    -- Because this is used by frontend, we have to give some kind of value for display.
    if next(ret) == nil then
        local v = taskgrouplist['default']
        table.insert(ret, {text=v.name, data='default'})
    end

    return ret
end

local function ClearModData(mod)
    if mod ~= nil then
        modtaskgrouplist[mod] = nil
    else
        modtaskgrouplist = {}
    end
end

------------------------------------------------------------------
-- GLOBAL functions
------------------------------------------------------------------

function AddTaskSet(id, data)
    assert(taskgrouplist[id] == nil, "Tried adding task set '"..id.."' twice!")
    data.location = data.location or "forest"
    taskgrouplist[id] = data
    print("  taskgrouplist:", id, data.name)
end

function AddModTaskSet(mod, id, data)
    if GetGenTasks(id) ~= nil then
        moderror(string.format("Tried adding a Task Set with id '%s' but one already exists!\n\t\tThis task will not be added.", id))
        return
    end

    if modtaskgrouplist[mod] == nil then modtaskgrouplist[mod] = {} end
    data.location = data.location or "forest"
    modtaskgrouplist[mod][id] = data
end

------------------------------------------------------------------
-- Load the data
------------------------------------------------------------------

require("map/tasksets/forest")
require("map/tasksets/caves")
require("map/tasksets/lavaarena")
require("map/tasksets/quagmire")

------------------------------------------------------------------
-- Export functions
------------------------------------------------------------------

return {
    GetGenTasks = GetGenTasks,
    GetGenTaskLists = GetGenTaskLists,
    ClearModData = ClearModData,
}
