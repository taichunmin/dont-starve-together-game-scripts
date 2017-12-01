require("constants")
local StaticLayout = require("map/static_layout")


local Rare = {
	["skeleton_dapper"] = StaticLayout.Get("map/static_layouts/skeleton_dapper"),

--------------------------------------------------------------------------------
-- Prebuilt bases
--------------------------------------------------------------------------------
	["skeleton_researchlab1"] = StaticLayout.Get("map/static_layouts/skeleton_researchlab1"),
	["skeleton_researchlab2"] = StaticLayout.Get("map/static_layouts/skeleton_researchlab2"),
	["skeleton_researchlab3"] = StaticLayout.Get("map/static_layouts/skeleton_researchlab3"),
}

local Forest = {
	["skeleton_lumberjack"] = StaticLayout.Get("map/static_layouts/skeleton_lumberjack"),
	["skeleton_trapper"] = StaticLayout.Get("map/static_layouts/skeleton_trapper"),
}

local Grasslands = {
	["skeleton_entomologist"] = StaticLayout.Get("map/static_layouts/skeleton_entomologist"),
	["skeleton_farmer"] = StaticLayout.Get("map/static_layouts/skeleton_farmer"),

-- Point of no interest
	["grass_spots"] = StaticLayout.Get("map/static_layouts/grass_spots"),
}

local Dirt = {
	["skeleton_miner_dirt"] = StaticLayout.Get("map/static_layouts/skeleton_miner_dirt"), 		-- Protected by leifs
}

local Swamp = {
	["skeleton_hunter_swamp"] = StaticLayout.Get("map/static_layouts/skeleton_hunter_swamp"),	-- Protected by tentcles
}

local Rocky = {
	["skeleton_miner"] = StaticLayout.Get("map/static_layouts/skeleton_miner"),
}

local Savanna = {
	["skeleton_camper"] = StaticLayout.Get("map/static_layouts/skeleton_camper"),
	["skeleton_hunter"] = StaticLayout.Get("map/static_layouts/skeleton_hunter"),
}

local BlueFungal = {
    ["skeleton_mushjack"] = StaticLayout.Get("map/static_layouts/skeleton_mushjack", {
        areas = {
            stumps = function() return { "mushtree_tall_stump", "mushtree_tall_stump", "mushtree_tall_stump",  } end,
        },
    }),
}

local RedFungal = {
    ["skeleton_mushjack"] = StaticLayout.Get("map/static_layouts/skeleton_mushjack", {
        areas = {
            stumps = function() return { "mushtree_medium_stump", "mushtree_medium_stump", "mushtree_medium_stump",  } end,
        },
    }),
}

local GreenFungal = {
    ["skeleton_mushjack"] = StaticLayout.Get("map/static_layouts/skeleton_mushjack", {
        areas = {
            stumps = function() return { "mushtree_small_stump", "mushtree_small_stump", "mushtree_small_stump",  } end,
        },
    }),
}

local Underrock = {
	["skeleton_miner"] = StaticLayout.Get("map/static_layouts/skeleton_miner"),
}

local Cave = {
	["skeleton_miner"] = StaticLayout.Get("map/static_layouts/skeleton_miner"),
	["skeleton_batfight"] = StaticLayout.Get("map/static_layouts/skeleton_batfight"),
}

local Mud = {
	["skeleton_lightfarmer"] = StaticLayout.Get("map/static_layouts/skeleton_lightfarmer"),
}

local Sinkhole = {
	["skeleton_lumberjack"] = StaticLayout.Get("map/static_layouts/skeleton_lumberjack"),
	["skeleton_entomologist"] = StaticLayout.Get("map/static_layouts/skeleton_entomologist"),
	["skeleton_farmer"] = StaticLayout.Get("map/static_layouts/skeleton_farmer"),
}

local Any = {
--------------------------------------------------------------------------------
-- Professions
--------------------------------------------------------------------------------
	["skeleton_wizard_ice"] = StaticLayout.Get("map/static_layouts/skeleton_wizard_ice"),
	["skeleton_wizard_fire"] = StaticLayout.Get("map/static_layouts/skeleton_wizard_fire"),
	["skeleton_warrior"] = StaticLayout.Get("map/static_layouts/skeleton_warrior"),
	["skeleton_construction"] = StaticLayout.Get("map/static_layouts/skeleton_construction"),
	["skeleton_fisher"] = StaticLayout.Get("map/static_layouts/skeleton_fisher"),
	["skeleton_graverobber"] = StaticLayout.Get("map.static_layouts/skeleton_graverobber"),
	["skeleton_night_hunter"] = StaticLayout.Get("map/static_layouts/skeleton_night_hunter"),
	["skeleton_summer"] = StaticLayout.Get("map/static_layouts/skeleton_summer"),
	["skeleton_rain_coat"] = StaticLayout.Get("map/static_layouts/skeleton_rain_coat"),
}

-- TODO: Add winter/summer, nighttime/dusk/day filters
local Winter = {
	["skeleton_winter_easy"] = StaticLayout.Get("map/static_layouts/skeleton_winter_easy"),
	["skeleton_winter_medium"] = StaticLayout.Get("map/static_layouts/skeleton_winter_medium"),
	["skeleton_winter_hard"] = StaticLayout.Get("map/static_layouts/skeleton_winter_hard"),
}

local SandboxModePointsofInterest = {
	["Rare"] = Rare,
	["Any"] = Any,
	--["Winter"] = Winter,
	[GROUND.ROCKY] = Rocky,
	[GROUND.DIRT] = Dirt,
	[GROUND.SAVANNA] = Savanna,
	[GROUND.GRASS] = Grasslands,
	[GROUND.FOREST] = Forest,
	[GROUND.MARSH] = Swamp,
	[GROUND.FUNGUS] = BlueFungal,
	[GROUND.FUNGUSRED] = RedFungal,
	[GROUND.FUNGUSGREEN] = GreenFungal,
	[GROUND.UNDERROCK] = Underrock,
	[GROUND.CAVE] = Cave,
	[GROUND.MUD] = Mud,
	[GROUND.SINKHOLE] = Sinkhole,
}


local layouts = {}
for k,area in pairs(SandboxModePointsofInterest) do
	if GetTableSize(area) >0 then
		for name, layout in pairs(area) do
			layouts[name] = layout
		end
	end
end

return {Sandbox = SandboxModePointsofInterest, Layouts = layouts}
