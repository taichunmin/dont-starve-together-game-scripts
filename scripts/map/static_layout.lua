require "util"

local PrefabSwaps = require("prefabswaps")

local ParseNestedKey -- must define it first so we can recurse
ParseNestedKey = function(obj, key, value)
	if #key == 1 then
		obj[key[1]] = value
		return
	else
		local key_head = key[1]
		if key_head == nil then
			return
		end

		local key_tail = {}
		for i,k in ipairs(key) do
			if i > 1 then table.insert(key_tail, k) end
		end
		if obj[key_head] == nil then
			obj[key_head] = {}
		end
		ParseNestedKey(obj[key_head], key_tail, value)
	end
end

local function ConvertStaticLayoutToLayout(layoutsrc, additionalProps)
	local staticlayout = require(layoutsrc)

	local layout = additionalProps or {}

	-- add stuff
	layout.type = LAYOUT.STATIC
	layout.scale = 1
	layout.layout_file = layoutsrc

	-- See \tools\tiled\dont_starve\tiles.png for tiles
	layout.ground_types = {
							--Translates tile type index from constants.lua into tiled tileset.
							--Order they appear here is the order they will be used in tiled.
							WORLD_TILES.IMPASSABLE,				WORLD_TILES.ROAD,				WORLD_TILES.ROCKY,			WORLD_TILES.DIRT,				WORLD_TILES.SAVANNA,		WORLD_TILES.GRASS,				WORLD_TILES.FOREST,			        WORLD_TILES.MARSH,
							WORLD_TILES.WOODFLOOR,				WORLD_TILES.CARPET,				WORLD_TILES.CHECKER,		WORLD_TILES.CAVE,				WORLD_TILES.FUNGUS,			WORLD_TILES.SINKHOLE,			WORLD_TILES.QUAGMIRE_GATEWAY,		WORLD_TILES.QUAGMIRE_SOIL,
							WORLD_TILES.OCEAN_COASTAL_SHORE,	WORLD_TILES.OCEAN_COASTAL,		WORLD_TILES.OCEAN_ROUGH,	WORLD_TILES.OCEAN_BRINEPOOL, 	WORLD_TILES.UNDERROCK,		WORLD_TILES.MUD,				WORLD_TILES.QUAGMIRE_PEATFOREST,	WORLD_TILES.IMPASSABLE,
							WORLD_TILES.BRICK,					WORLD_TILES.OCEAN_SWELL,		WORLD_TILES.TILES,			WORLD_TILES.OCEAN_HAZARDOUS,	WORLD_TILES.TRIM,			WORLD_TILES.IMPASSABLE,			WORLD_TILES.QUAGMIRE_PARKSTONE,	    WORLD_TILES.QUAGMIRE_PARKFIELD,
							WORLD_TILES.PEBBLEBEACH,			WORLD_TILES.METEOR,				WORLD_TILES.FUNGUSRED,		WORLD_TILES.FUNGUSGREEN,		WORLD_TILES.FAKE_GROUND,	WORLD_TILES.LAVAARENA_FLOOR,	WORLD_TILES.LAVAARENA_TRIM,         WORLD_TILES.QUAGMIRE_CITYSTONE,
							WORLD_TILES.SHELLBEACH,          	WORLD_TILES.ARCHIVE,            WORLD_TILES.FUNGUSMOON,     WORLD_TILES.OCEAN_WATERLOG,		WORLD_TILES.MONKEY_DOCK, 	WORLD_TILES.MONKEY_GROUND,		WORLD_TILES.MOSAIC_GREY,			WORLD_TILES.MOSAIC_RED,
							WORLD_TILES.MOSAIC_BLUE,			WORLD_TILES.CARPET2
						}
	layout.ground = {}

	-- so we can support both 16 wide grids and 64 wide grids from tiled
	local tilefactor = math.ceil(64/staticlayout.tilewidth)

	-- See \tools\tiled\dont_starve\objecttypes.xml for objects
	layout.layout = {}

	for layer_idx, layer in ipairs(staticlayout.layers) do
		if layer.type == "tilelayer" and layer.name == "BG_TILES" then
			local val_per_row = layer.width * (tilefactor-1)
			local i = val_per_row

			while i < #layer.data do
				local data = {}
				local j = 1
				while j <= layer.width and i+j <= #layer.data do
					table.insert(data, layer.data[i+j])
					j = j + tilefactor
				end
				table.insert(layout.ground, data)
				i = i + val_per_row + layer.width
			end
		elseif layer.type == "objectgroup" and string.find(layer.name, "FG_OBJECTS") then
			for obj_idx, obj in ipairs(layer.objects) do
                if not PrefabSwaps.IsPrefabInactive(obj.type) then
                    local prefab = PrefabSwaps.ResolvePrefabProxy(obj.type)

    				if layout.layout[prefab] == nil then
    					layout.layout[prefab] = {}
    				end

    				-- TODO: Check the object properties for other options to substitute here
    				local x = obj.x+obj.width/2
    				x = x/64.0-(staticlayout.width/tilefactor)/2
    				local y = obj.y+obj.height/2
    				y = y/64.0-(staticlayout.height/tilefactor)/2

    				local width = obj.width/64.0
    				local height = obj.height/64.0

    				local properties = {}
    				if obj.properties then
    					for k,v in pairs(obj.properties) do
    						local keys = k:split(".")
    						local number_v = tonumber(v)
    						if v == "true" or v == "false" then
    							ParseNestedKey(properties,keys, v == "true")
    						else
    							ParseNestedKey(properties,keys,number_v or v)
    						end
    					end

    					--print("Static Layout Properties for ", layoutsrc)
    					--dumptable(properties,1,10)

    				end

    				table.insert(layout.layout[prefab], {x=x, y=y, properties=properties, width=width, height=height})
                end
			end

			if layout.initfn then
				layout.initfn(layout.layout)
			end
		end
	end

	return layout
end

return {Get = ConvertStaticLayoutToLayout}
