-- List of locks
LOCKS_ARRAY =
{
	"NONE",
	"PIGGIFTS",
	"TREES",
	"SPIDERDENS",
	"ROCKS",
	"FARM",
	"MEAT",
	"BEEHIVE",
	"KILLERBEES",
	"PIGKING",
	"MONSTERS_DEFEATED",
	"HARD_MONSTERS_DEFEATED",
	"SPIDERS_DEFEATED",
	"BASIC_COMBAT",
	"ADVANCED_COMBAT",
	"ONLYTIER1",
	"TIER0",
	"TIER1",
	"TIER2",
	"TIER3",
	"TIER4",
	"TIER5",
	"TIER6",
    "ANYTIER",
    "INNERTIER",
    "OUTERTIER",
	"LIGHT",
	"FUNGUS",
	"CAVE",
	"LABYRINTH",
	"WILDS",
	"RUINS",
	"SACRED",
	"BADLANDS",
	"HOUNDS",
	--"ADVANCED_COMBAT",

    "ENTRANCE_INNER",
    "ENTRANCE_OUTER",

	"MUSHROOM",
	"RABBIT",
	"PASSAGE",
    "AREA",
	"CAVERN",
	"SINKHOLE",
	"BATS",

	"EASY",
	"MEDIUM",
	"HARD",

	"BLUE",
	"RED",
	"GREEN",

	"MOONMUSH",
	"ARCHIVE",

	"QUAGMIRE_GATEWAY",
	"QUAGMIRE_PARK_L1",
	"QUAGMIRE_FOOD_L1",
	"QUAGMIRE_TRIBE",
	"QUAGMIRE_GIANT",

	"ISLAND_TIER1",
	"ISLAND_TIER2",
	"ISLAND_TIER3",
	"ISLAND_TIER4",
}

LOCKS = {}
for i,v in ipairs(LOCKS_ARRAY) do
	assert(LOCKS[v] == nil, "Lock "..v.." is defined twice!")
	LOCKS[v] = i
end

-- List of keys
KEYS_ARRAY =
{
	"NONE",
	"PICKAXE",
	"AXE",
	"GRASS",
	"STONE",
	"WOOD",
	"MEAT",
	"PIGS",
	"FIRE",
	"POOP",
	"WOOL",
	"FARM",
	"HONEY",
	"GOLD",
	"BEEHAT",
	"TRINKETS",
	"HARD_WALRUS",
	"HARD_SPIDERS",
	"HARD_HOUNDS",
	"HARD_MERMS",
	"HARD_TENTACLES",
	"WALRUS",
	"SPIDERS",
	"HOUNDS",
	"MERMS",
	"GEARS",
	"CHESSMEN",
	"TENTACLES",
	"TIER0",
	"TIER1",
	"TIER2",
	"TIER3",
	"TIER4",
	"TIER5",
	"TIER6",
	"LIGHT",
	"FUNGUS",
	"CAVE",
	"LABYRINTH",
	"WILDS",
	"RUINS",
	"SACRED",
	"BADLANDS",

    "ENTRANCE_INNER",
    "ENTRANCE_OUTER",

	"MUSHROOM",
	"RABBIT",
	"PASSAGE",
    "AREA",
	"CAVERN",
	"SINKHOLE",
	"BATS",

	"EASY",
	"MEDIUM",
	"HARD",

	"BLUE",
	"RED",
	"GREEN",

	"MOONMUSH",
	"ARCHIVE",

	"QUAGMIRE_GATEWAY",
	"QUAGMIRE_PARK_L1",
	"QUAGMIRE_FOOD_L1",
	"QUAGMIRE_TRIBE",
	"QUAGMIRE_GIANT",

	"ISLAND_TIER1",
	"ISLAND_TIER2",
	"ISLAND_TIER3",
	"ISLAND_TIER4",
}
KEYS = {}
for i,v in ipairs(KEYS_ARRAY) do
	assert(KEYS[v] == nil, "Key "..v.." is defined twice!")
	KEYS[v] = i
end

-- Locks are unlocked if ANY key is provided.
-- However, ALL locks must be opened for a task to be unlocked.
LOCKS_KEYS =
{
	[LOCKS.NONE] =
	{},
	[LOCKS.HARD_MONSTERS_DEFEATED] =
	{
		KEYS.HARD_WALRUS,
		KEYS.HARD_SPIDERS,
		KEYS.HARD_HOUNDS,
		KEYS.HARD_MERMS,
		KEYS.HARD_TENTACLES,
		KEYS.CHESSMEN,
	},
	[LOCKS.MONSTERS_DEFEATED] =
	{
		KEYS.WALRUS,
		KEYS.SPIDERS,
		KEYS.HOUNDS,
		KEYS.MERMS,
		KEYS.TENTACLES,
		KEYS.CHESSMEN,
	},
	[LOCKS.SPIDERS_DEFEATED] =
	{
		KEYS.SPIDERS,
	},
	[LOCKS.BASIC_COMBAT] =
	{
		KEYS.AXE,
		KEYS.PIGS,
	},
	[LOCKS.ADVANCED_COMBAT] =
	{
		KEYS.GOLD,
		KEYS.HONEY,
	},
    [LOCKS.ROCKS] =
    {
    	KEYS.PICKAXE
    },
    [LOCKS.PIGGIFTS] =
    {
    	KEYS.MEAT,
    	KEYS.AXE,
    	KEYS.PICKAXE,
    },
    [LOCKS.TREES] =
    {
    	KEYS.AXE,
    	KEYS.FIRE,
    },
    [LOCKS.SPIDERDENS] =
    {
    	KEYS.PIGS,
    	KEYS.FIRE,
    	KEYS.AXE,
    	KEYS.PICKAXE,
    	KEYS.HONEY,
    },
    [LOCKS.BEEHIVE] =
    {
    	KEYS.AXE,
    },
    [LOCKS.FARM] =
    {
    	KEYS.POOP,
    },
    [LOCKS.MEAT] =
    {
    	KEYS.SPIDERS,
    	KEYS.PIGS,
    	KEYS.FARM,
    },
	[LOCKS.KILLERBEES] =
	{
		KEYS.BEEHAT,
	},
	[LOCKS.PIGKING] =
	{
		KEYS.TRINKETS,
	},
	[LOCKS.TREES] =
	{
		KEYS.AXE,
		KEYS.PIGS,
	},
	[LOCKS.ONLYTIER1] =
	{
		KEYS.TIER1,
	},
	[LOCKS.TIER0] =
	{
		KEYS.TIER0,
		KEYS.TIER1,
	},
	[LOCKS.TIER1] =
	{
		KEYS.TIER1,
		KEYS.TIER2,
	},
	[LOCKS.TIER2] =
	{
		KEYS.TIER2,
		KEYS.TIER3,
	},
	[LOCKS.TIER3] =
	{
		KEYS.TIER3,
		KEYS.TIER4,
	},
	[LOCKS.TIER4] =
	{
		KEYS.TIER4,
		KEYS.TIER5,
	},
	[LOCKS.TIER5] =
	{
		KEYS.TIER5,
		KEYS.TIER6,
	},
    [LOCKS.ANYTIER] =
    {
        KEYS.TIER1,
        KEYS.TIER2,
        KEYS.TIER3,
        KEYS.TIER4,
        KEYS.TIER5,
        KEYS.TIER6,
    },
    [LOCKS.INNERTIER] =
    {
        KEYS.TIER1,
        KEYS.TIER2,
        KEYS.TIER3,
    },
    [LOCKS.OUTERTIER] =
    {
        KEYS.TIER4,
        KEYS.TIER5,
        KEYS.TIER6,
    },
    [LOCKS.ENTRANCE_INNER] =
    {
        KEYS.ENTRANCE_INNER,
    },
    [LOCKS.ENTRANCE_OUTER] =
    {
        KEYS.ENTRANCE_OUTER,
    },

	[LOCKS.LIGHT] =
	{
		KEYS.LIGHT,
	},
	[LOCKS.CAVE] =
	{
		KEYS.CAVE,
	},
	[LOCKS.FUNGUS] =
	{
		KEYS.FUNGUS,
	},
	[LOCKS.LABYRINTH] =
	{
		KEYS.LABYRINTH,
	},
	[LOCKS.WILDS] =
	{
		KEYS.WILDS,
	},
	[LOCKS.RUINS] =
	{
		KEYS.RUINS
	},
	[LOCKS.SACRED] =
	{
		KEYS.SACRED
	},

	[LOCKS.MUSHROOM] =
	{
		KEYS.MUSHROOM
	},

	[LOCKS.RABBIT] =
	{
		KEYS.RABBIT
	},
	[LOCKS.SINKHOLE] =
	{
		KEYS.SINKHOLE
	},
	[LOCKS.BATS] =
	{
		KEYS.BATS
	},

	[LOCKS.PASSAGE] =
	{
		KEYS.PASSAGE
	},

	[LOCKS.AREA] =
	{
		KEYS.AREA
	},

	[LOCKS.CAVERN] =
	{
		KEYS.CAVERN
	},


	[LOCKS.EASY] =
	{
		KEYS.EASY
	},

	[LOCKS.MEDIUM] =
	{
		KEYS.MEDIUM
	},

	[LOCKS.HARD] =
	{
		KEYS.HARD
	},

	[LOCKS.BLUE] =
	{
		KEYS.BLUE
	},

	[LOCKS.RED] =
	{
		KEYS.RED
	},

	[LOCKS.GREEN] =
	{
		KEYS.GREEN
	},

	[LOCKS.QUAGMIRE_GATEWAY] =
	{
		KEYS.QUAGMIRE_GATEWAY,
	},

	[LOCKS.QUAGMIRE_PARK_L1] =
	{
		KEYS.QUAGMIRE_PARK_L1,
	},

	[LOCKS.QUAGMIRE_FOOD_L1] =
	{
		KEYS.QUAGMIRE_FOOD_L1,
	},

	[LOCKS.QUAGMIRE_TRIBE] =
	{
		KEYS.QUAGMIRE_TRIBE,
	},

	[LOCKS.QUAGMIRE_GIANT] =
	{
		KEYS.QUAGMIRE_GIANT,
	},

	[LOCKS.ISLAND_TIER1] =
	{
		KEYS.ISLAND_TIER1,
	},

	[LOCKS.ISLAND_TIER2] =
	{
		KEYS.ISLAND_TIER2,
	},

	[LOCKS.ISLAND_TIER3] =
	{
		KEYS.ISLAND_TIER3,
	},

	[LOCKS.ISLAND_TIER4] =
	{
		KEYS.ISLAND_TIER4,
	},

	[LOCKS.MOONMUSH] =
	{
		KEYS.MOONMUSH,
	},

	[LOCKS.ARCHIVE] =
	{
		KEYS.ARCHIVE,
	},
}


for lock,keyset in pairs(LOCKS_KEYS) do
	assert(lock ~= nil and lock == LOCKS[LOCKS_ARRAY[lock]], "A lock in the lock_keys is misnamed!")
	local count = 0
	for i,key in pairs(keyset) do
		assert(key ~= nil and key == KEYS[KEYS_ARRAY[key]], "A key in lock "..LOCKS_ARRAY[lock].." is misnamed!")
		count = count + 1
	end
	assert(#keyset == count, "There appears to be an incorrectly named key in locks_keys: "..LOCKS_ARRAY[lock])
	-- NOTE: This wil **NOT** catch it if the typo is in the last key in the list. ... But it's better than nothing...
end


--print("LOCKS")
--dumptable(LOCKS,1)
--print("KEYS")
--dumptable(KEYS,1)
--print("LOCKS_KEYS")
--dumptable(LOCKS_KEYS,1,1)
