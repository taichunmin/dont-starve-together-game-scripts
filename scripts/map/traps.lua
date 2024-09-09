require("constants")
local StaticLayout = require("map/static_layout")

local Rare = {
	["Dev Graveyard"] = StaticLayout.Get("map/static_layouts/dev_graveyard"),
}

local Forest = {
	["Sleeping Spider"] = StaticLayout.Get("map/static_layouts/trap_sleepingspider"),
	--["Chilled Base"] = StaticLayout.Get("map/static_layouts/trap_winter"),
}

local Deciduous = {
}

local Grasslands = {
	--["Chilled Decid Base"] = StaticLayout.Get("map/static_layouts/trap_winter_deciduous"),
}

local Swamp = {
	["Rotted Base"] = StaticLayout.Get("map/static_layouts/trap_spoilfood"),
}

local Rocky = {
}

local Badlands = {
	--["Hot Base"] = StaticLayout.Get("map/static_layouts/trap_summer"),
}

local Savanna = {
	["Beefalo Farm"] = StaticLayout.Get("map/static_layouts/beefalo_farm"),
}

local Any = {
	["Ice Hounds"] = StaticLayout.Get("map/static_layouts/trap_icestaff"),
	["Fire Hounds"] = StaticLayout.Get("map/static_layouts/trap_firestaff"),
}

local SandboxModeTraps = {
	["Rare"] = Rare,
	["Any"] = Any,
	[WORLD_TILES.ROCKY] = Rocky,
	[WORLD_TILES.SAVANNA] = Savanna,
	[WORLD_TILES.GRASS] = Grasslands,
	[WORLD_TILES.FOREST] = Forest,
	[WORLD_TILES.MARSH] = Swamp,
	[WORLD_TILES.DIRT] = Badlands,
}

local layouts = {}
for k,area in pairs(SandboxModeTraps) do
	if GetTableSize(area) >0 then
		for name, layout in pairs(area) do
			layouts[name] = layout
		end
	end
end

return {Sandbox = SandboxModeTraps, Layouts = layouts}
