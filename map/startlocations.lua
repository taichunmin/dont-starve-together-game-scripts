
local startlocations = {}
local modstartlocations = {}

--------------------------------------------------------------------
-- Module functions
--------------------------------------------------------------------

local function GetGenStartLocations(world)
    local ret = {}
    for k,v in pairs(startlocations) do
        if world == nil or v.location == world then
            table.insert(ret, {text = v.name, data = k})
        end
    end
    for mod,locations in pairs(modstartlocations) do
        for k,v in pairs(locations) do
            if world == nil or v.location == world then
                table.insert(ret, {text = v.name, data = k})
            end
        end
    end

    -- Because this is used by frontend, we have to give some kind of value for display.
    if next(ret) == nil then
        local v = startlocations['default']
        table.insert(ret, {text=v.name, data='default'})
    end

    return ret
end

local function GetStartLocation(name)
    for mod,locations in pairs(modstartlocations) do
        if locations[name] ~= nil then
            return deepcopy(locations[name])
        end
    end
    return deepcopy(startlocations[name])
end

local function ClearModData(mod)
    if mod == nil then
        modstartlocations = {}
    else
        modstartlocations[mod] = nil
    end
end

------------------------------------------------------------------
-- GLOBAL functions
------------------------------------------------------------------

local function RefreshWorldTabs()
	if not rawget(_G, "TheFrontEnd") then return end
	--HACK probably need a better way to update the world tabs when the customize data changes
	local servercreationscreen
    for _, screen_in_stack in pairs(TheFrontEnd.screenstack) do
        if screen_in_stack.name == "ServerCreationScreen" then
			servercreationscreen = screen_in_stack
			break
        end
	end
    if servercreationscreen then
		for k, v in pairs(servercreationscreen.world_tabs) do
			v:RefreshOptionItems()
        end
    end
end

function AddStartLocation(name, data)
    if ModManager.currentlyloadingmod ~= nil then
        AddModStartLocation(ModManager.currentlyloadingmod, name, data)
        return
    end
    assert(GetStartLocation(name) == nil, string.format("Tried adding a start location '%s' but one already exists!", name))
    startlocations[name] = data
end

function AddModStartLocation(mod, name, data)
    if GetStartLocation(name) ~= nil then
        moderror(string.format("Tried adding a start location '%s' but one already exists!", name))
        return
    end
    if modstartlocations[mod] == nil then modstartlocations[mod] = {} end
    modstartlocations[mod][name] = data
    RefreshWorldTabs()
end

------------------------------------------------------------------
-- Load the data
------------------------------------------------------------------

AddStartLocation("default", {
    name = STRINGS.UI.SANDBOXMENU.DEFAULTSTART,
    location = "forest",
    start_setpeice = "DefaultStart",
    start_node = "Clearing",
})

AddStartLocation("plus", {
    name = STRINGS.UI.SANDBOXMENU.PLUSSTART,
    location = "forest",
    start_setpeice = "DefaultPlusStart",
    start_node = {"DeepForest", "Forest", "SpiderForest", "Plain", "Rocky", "Marsh"},
})

AddStartLocation("darkness", {
    name = STRINGS.UI.SANDBOXMENU.DARKSTART,
    location = "forest",
    start_setpeice = "DarknessStart",
    start_node = {"DeepForest", "Forest"},
})

AddStartLocation("caves", {
    name = STRINGS.UI.SANDBOXMENU.CAVESTART,
    location = "cave",
    start_setpeice = "CaveStart",
    start_node = {
        "RabbitArea",
        "RabbitTown",
        "RabbitSinkhole",
        "SpiderIncursion",
        "SinkholeForest",
        "SinkholeCopses",
        "SinkholeOasis",
        "GrasslandSinkhole",
        "GreenMushSinkhole",
        "GreenMushRabbits",
    },
})

AddStartLocation("lavaarena", {
    name = STRINGS.UI.SANDBOXMENU.DEFAULTSTART,
    location = "lavaarena",
    start_setpeice = "LavaArenaLayout",
    start_node = "Blank",
})

AddStartLocation("quagmire_startlocation", {
    name = STRINGS.UI.SANDBOXMENU.DEFAULTSTART,
    location = "quagmire",
    start_setpeice = "Quagmire_Kitchen",
    start_node = "Blank",
})

------------------------------------------------------------------
-- Export functions
------------------------------------------------------------------

return {
    GetGenStartLocations = GetGenStartLocations,
    GetStartLocation = GetStartLocation,
    ClearModData = ClearModData,
}
