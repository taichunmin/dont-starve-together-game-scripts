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
							GROUND.IMPASSABLE,			GROUND.ROAD,				GROUND.ROCKY,			GROUND.DIRT,			GROUND.SAVANNA,		GROUND.GRASS,				GROUND.FOREST,			        GROUND.MARSH,
							GROUND.WOODFLOOR,			GROUND.CARPET,				GROUND.CHECKER,			GROUND.CAVE,			GROUND.FUNGUS,		GROUND.SINKHOLE,			GROUND.QUAGMIRE_GATEWAY,		GROUND.QUAGMIRE_SOIL,
							GROUND.OCEAN_COASTAL_SHORE,	GROUND.OCEAN_COASTAL,		GROUND.OCEAN_ROUGH,		GROUND.OCEAN_BRINEPOOL, GROUND.UNDERROCK,	GROUND.MUD,					GROUND.QUAGMIRE_PEATFOREST,		GROUND.IMPASSABLE,
							GROUND.BRICK,				GROUND.OCEAN_SWELL,			GROUND.TILES,			GROUND.OCEAN_HAZARDOUS,	GROUND.TRIM,		GROUND.IMPASSABLE,			GROUND.QUAGMIRE_PARKSTONE,	    GROUND.QUAGMIRE_PARKFIELD,
							GROUND.PEBBLEBEACH,			GROUND.METEOR,				GROUND.FUNGUSRED,		GROUND.FUNGUSGREEN,		GROUND.FAKE_GROUND,	GROUND.LAVAARENA_FLOOR,		GROUND.LAVAARENA_TRIM,          GROUND.QUAGMIRE_CITYSTONE,
							GROUND.SHELLBEACH,          GROUND.ARCHIVE,             GROUND.FUNGUSMOON,      GROUND.OCEAN_WATERLOG,
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
