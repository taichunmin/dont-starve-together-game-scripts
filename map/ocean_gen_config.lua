
local watergen =
{

	--waterline/ground fill
	depthShallow = 2,
	depthMed = 0,
	fillDepth = 4, --increasing this too much will make things slower
	fillOffset = 8,

	--square fill
	shallowRadius = 4,
	mediumRadius = 0,

	ocean_prefill_setpieces_min_land_dist = 5, -- min distance between land and this set piece, should be no less than shallowRadius or the squarefill will stomp the set piece

	--noise Google 'Perlin noise' to see what is making, they are like cloud textures
	--one noise map is made for coral and another for all other water
	noise_octave_water = 6,
	noise_octave_coral = 4,
	noise_octave_grave = 4,
	noise_persistence_water = 0.5,
	noise_persistance_coral = 0.5,
	noise_persistance_grave = 0.5,
	--high scale means more, smaller 'patches'
	noise_scale_water = 3,
	noise_scale_coral = 6,
	noise_scale_grave = 18,
	--noise maps will make values 0.0-1.0
	init_level_coral = 0.65, --greater then this = coral - increase to lower coral
	init_level_medium = 0.55, --greater than this = medium, increase for less medium
	init_level_grave = 0.65, --greater then this = shipgraves - increase to lower shipgraves

	--after everything above is done it will take that and blend it

	--blend
	kernelSize = 15,
	sigma = 3.0,

	--before blurring a grayscale image is made setting pixels from tiles using these values
	--1.0 = white, 0.0 = black
	ellevels =
	{
		--'elevation' levels
		{GROUND.OCEAN_BRINEPOOL, 1.0},
--		{GROUND.PEBBLEBEACH, 1.0},
--		{GROUND.METEOR, 1.0},
--		{GROUND.MANGROVE, 1.0},
--		{GROUND.JUNGLE, 1.0},
--		{GROUND.BEACH, 1.0},
--		{GROUND.MAGMAFIELD, 1.0},
--		{GROUND.TIDALMARSH, 1.0},
--		{GROUND.MEADOW, 1.0},
		{GROUND.OCEAN_COASTAL, 0.9}, --was .6 when I started
		{GROUND.OCEAN_SWELL, 0.4}, --.4 when I started
		{GROUND.OCEAN_ROUGH, 0.0},
		{GROUND.OCEAN_HAZARDOUS, 0.0},
		{GROUND.IMPASSABLE, 0.0}
	},

	--when blur is done every tile should be 0.0-1.0
	final_level_shallow = 0.45, --greater than this = shallow, .4
	final_level_medium = 0.05, -- greater than this = medium, otherwise deep, was .0004
	--final_level_coral = 0.2, --if water blur is greater than final_level_shallow and coral blur is greater than this = coral
	--final_level_mangrove = 0.2,
	--final_level_grave = 0.2,
}

return watergen