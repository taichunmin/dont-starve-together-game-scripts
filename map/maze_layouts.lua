require("constants")

local StaticLayout = require("map/static_layout")

local ruins_areas = 
{
	rubble = function(area) return nil end,
	debris = function(area) return PickSomeWithDups( 0.25 * area
	, {"rocks"}) end,
}

local function GetLayoutsForType( name, sub_dir, params )
	sub_dir = "map/static_layouts/" .. (sub_dir or "rooms") .. "/"
	params = params or {}
	local layouts = 
		{
			["SINGLE_NORTH"] = 	StaticLayout.Get(sub_dir..name.."/one",	{
				force_rotation = LAYOUT_ROTATION.NORTH,
				fill_mask = params.fill_mask}),
			["SINGLE_EAST"] = 	StaticLayout.Get(sub_dir..name.."/one",	{
				force_rotation = LAYOUT_ROTATION.EAST,
				fill_mask = params.fill_mask}),
			["L_NORTH"] = 		StaticLayout.Get(sub_dir..name.."/two", {
				force_rotation = LAYOUT_ROTATION.NORTH,
				fill_mask = params.fill_mask}),
			["SINGLE_SOUTH"] = 	StaticLayout.Get(sub_dir..name.."/one",	{
				force_rotation = LAYOUT_ROTATION.SOUTH,
				fill_mask = params.fill_mask}),
			["TUNNEL_NS"] = 	StaticLayout.Get(sub_dir..name.."/long", {
				force_rotation = LAYOUT_ROTATION.NORTH,
				fill_mask = params.fill_mask}),
			["L_EAST"] = 		StaticLayout.Get(sub_dir..name.."/two",	{
				force_rotation = LAYOUT_ROTATION.EAST,
				fill_mask = params.fill_mask}),
			["THREE_WAY_N"] = 	StaticLayout.Get(sub_dir..name.."/three", {
				force_rotation = LAYOUT_ROTATION.NORTH,
				fill_mask = params.fill_mask}),
			["SINGLE_WEST"] = 	StaticLayout.Get(sub_dir..name.."/one",	{
				force_rotation = LAYOUT_ROTATION.WEST,
				fill_mask = params.fill_mask}),
			["L_WEST"] = 		StaticLayout.Get(sub_dir..name.."/two",	{
				force_rotation = LAYOUT_ROTATION.WEST,
				fill_mask = params.fill_mask}),
			["TUNNEL_EW"] = 	StaticLayout.Get(sub_dir..name.."/long", {
				force_rotation = LAYOUT_ROTATION.EAST,
				fill_mask = params.fill_mask}),
			["THREE_WAY_W"] = 	StaticLayout.Get(sub_dir..name.."/three", {
				force_rotation = LAYOUT_ROTATION.WEST,
				fill_mask = params.fill_mask}),
			["L_SOUTH"] = 		StaticLayout.Get(sub_dir..name.."/two",	{
				force_rotation = LAYOUT_ROTATION.SOUTH,
				fill_mask = params.fill_mask}),
			["THREE_WAY_S"] = 	StaticLayout.Get(sub_dir..name.."/three", {
				force_rotation = LAYOUT_ROTATION.SOUTH,
				fill_mask = params.fill_mask}),
			["THREE_WAY_E"] = 	StaticLayout.Get(sub_dir..name.."/three", {
				force_rotation = LAYOUT_ROTATION.EAST,
				fill_mask = params.fill_mask}),
			["FOUR_WAY"] = 		StaticLayout.Get(sub_dir..name.."/four", {
				force_rotation = LAYOUT_ROTATION.NORTH,
				fill_mask = params.fill_mask}),
		}

    for k,v in pairs(layouts) do
        v.start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED
        v.fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED
        v.areas = ruins_areas
    end
	return layouts
end

local function GetSpecialLayoutsForType( layout_dir, name, sub_dir )
	local path = "map/static_layouts/" .. (sub_dir or "rooms") .. "/" .. layout_dir .. "/" .. name
	local layouts = 
		{
			["SINGLE_NORTH"] = 	StaticLayout.Get(path,	{
				force_rotation = LAYOUT_ROTATION.NORTH}),
			["SINGLE_EAST"] = 	StaticLayout.Get(path,	{
				force_rotation = LAYOUT_ROTATION.EAST}),
			["SINGLE_SOUTH"] = 	StaticLayout.Get(path,	{
				force_rotation = LAYOUT_ROTATION.SOUTH}),
			["SINGLE_WEST"] = 	StaticLayout.Get(path,	{
				force_rotation = LAYOUT_ROTATION.WEST}),
		}

    for k,v in pairs(layouts) do
        v.start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED
        v.fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED
        v.areas = ruins_areas
    end
	return layouts
end


return {
		Layouts = GetLayoutsForType("room"),
		AllLayouts = {
			["default"] = GetLayoutsForType("room"), 
			["hallway"] = GetLayoutsForType("hallway"), 
			["hallway_armoury"] = GetLayoutsForType("hallway_armoury"), 
			["hallway_residential"] = GetLayoutsForType("hallway_residential"), 
			["hallway_residential_two"] = GetLayoutsForType("hallway_residential_two"),
			--["hallway_shop"] = GetLayoutsForType("hallway_shop"), 
			-- ["default"] = GetLayoutsForType("room_shop"), 
			["room_armoury"] = GetLayoutsForType("room_armoury"), 
			["room_armoury_two"] = GetLayoutsForType("room_armoury_two"),
			["room_residential"] = GetLayoutsForType("room_residential"), 
			["room_residential_two"] = GetLayoutsForType("room_residential_two"),
			["room_open"] = GetLayoutsForType("room_open"),
			["pit_hallway_armoury"] = GetLayoutsForType("pit_hallway_armoury"),
			["pit_room_armoury"] = GetLayoutsForType("pit_room_armoury"),
			["pit_room_armoury_two"] = GetLayoutsForType("pit_room_armoury_two"),
			["atrium_hallway"] = GetLayoutsForType("atrium_hallway"),
			["atrium_hallway_two"] = GetLayoutsForType("atrium_hallway_two"),
			["atrium_hallway_three"] = GetLayoutsForType("atrium_hallway_three"),
			["atrium_end"] = GetSpecialLayoutsForType("atrium_end", "atrium_end"),
			["atrium_start"] = GetSpecialLayoutsForType("atrium_start", "atrium_start"),
		},
	}
