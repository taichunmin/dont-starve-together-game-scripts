require "util"
local TechTree = require("techtree")

local IS_BETA = BRANCH == "staging" --or BRANCH == "dev"

PI = 3.14159
PI2 = PI*2
DEGREES = PI/180
RADIANS = 180/PI
FRAMES = 1/30
TILE_SCALE = 4

RESOLUTION_X = 1280
RESOLUTION_Y = 720

MAX_FE_SCALE = 3 --Default if you don't call SetMaxPropUpscale
MAX_HUD_SCALE = 1.25

FACING_RIGHT = 0
FACING_UP = 1
FACING_LEFT = 2
FACING_DOWN = 3
FACING_UPRIGHT = 4
FACING_UPLEFT = 5
FACING_DOWNRIGHT = 6
FACING_DOWNLEFT = 7
FACING_NONE = 8

-- Careful inserting into here. You will have to update game\render\RenderLayer.h
LAYER_BACKDROP = 0
LAYER_BELOW_OCEAN = 1
LAYER_BELOW_GROUND = 2
LAYER_GROUND = 3
LAYER_BACKGROUND = 4
LAYER_WORLD_BACKGROUND = 5
LAYER_WORLD = 6
-- client-only layers go below here --
LAYER_WORLD_DEBUG = 7
LAYER_FRONTEND = 8
LAYER_FRONTEND_DEBUG = 9

LAYER_WIP_BELOW_OCEAN = 2 --1

-- From SortKeyConsts in scenegraphnode.h
FINALOFFSET_MIN = -7
FINALOFFSET_MAX = 7

SORTORDER_MIN = -3
SORTORDER_MAX = 3

ANCHOR_MIDDLE = 0
ANCHOR_LEFT = 1
ANCHOR_RIGHT = 2
ANCHOR_TOP = 1
ANCHOR_BOTTOM = 2

SCALEMODE_NONE = 0
SCALEMODE_FILLSCREEN = 1 --stretch art to fit/fill window
SCALEMODE_PROPORTIONAL = 2 --preserve aspect ratio (picks the smaller of horizontal/vertical scale)
SCALEMODE_FIXEDPROPORTIONAL = 3 --same as SCALEMODE_FIXEDSCREEN_NONDYNAMIC, except for safe area on consoles
SCALEMODE_FIXEDSCREEN_NONDYNAMIC = 4 --scale same amount as window scaling from 1280x720

PHYSICS_TYPE_ANIMATION_CONTROLLED = 0
PHYSICS_TYPE_PHYSICS_CONTROLLED = 1


MOVE_UP = 1
MOVE_DOWN = 2
MOVE_LEFT = 3
MOVE_RIGHT = 4

NUM_CRAFTING_RECIPES = 10

--push priorities
STATIC_PRIORITY = 10000

-- Controls:
-- Must match the Control enum in DontStarveInputHandler.h
-- Must match STRINGS.UI.CONTROLSSCREEN.CONTROLS

-- player action controls
CONTROL_PRIMARY = 0
CONTROL_SECONDARY = 1
CONTROL_ATTACK = 2
CONTROL_INSPECT = 3
CONTROL_ACTION = 4

-- player movement controls
CONTROL_MOVE_UP = 5  -- left joystick up
CONTROL_MOVE_DOWN = 6 -- left joystick down
CONTROL_MOVE_LEFT = 7 -- left joystick left
CONTROL_MOVE_RIGHT = 8 -- left joystick right

-- view controls
CONTROL_ZOOM_IN = 9      -- left trigger
CONTROL_ZOOM_OUT = 10    -- right trigger
CONTROL_ROTATE_LEFT = 11  -- left shoulder
CONTROL_ROTATE_RIGHT = 12 -- right shoulder


-- player movement controls
CONTROL_PAUSE = 13  -- start
CONTROL_MAP = 14
CONTROL_INV_1 = 15
CONTROL_INV_2 = 16
CONTROL_INV_3 = 17
CONTROL_INV_4 = 18
CONTROL_INV_5 = 19
CONTROL_INV_6 = 20
CONTROL_INV_7 = 21
CONTROL_INV_8 = 22
CONTROL_INV_9 = 23
CONTROL_INV_10 = 24

CONTROL_FOCUS_UP = 25  -- d-pad up
CONTROL_FOCUS_DOWN = 26  -- d-pad down
CONTROL_FOCUS_LEFT = 27 -- d-pad left
CONTROL_FOCUS_RIGHT = 28 -- d-pad right

CONTROL_ACCEPT = 29  -- A
CONTROL_CANCEL = 30 -- B
CONTROL_SCROLLBACK = 31  -- left shoulder
CONTROL_SCROLLFWD = 32   -- right shoulder

CONTROL_PREVVALUE = 33
CONTROL_NEXTVALUE = 34

CONTROL_SPLITSTACK = 35
CONTROL_TRADEITEM = 36
CONTROL_TRADESTACK = 37
CONTROL_FORCE_INSPECT = 38
CONTROL_FORCE_ATTACK = 39
CONTROL_FORCE_TRADE = 40
CONTROL_FORCE_STACK = 41

CONTROL_OPEN_DEBUG_CONSOLE = 42
CONTROL_TOGGLE_LOG = 43
CONTROL_TOGGLE_DEBUGRENDER = 44

CONTROL_OPEN_INVENTORY = 45  -- right trigger
CONTROL_OPEN_CRAFTING = 46   -- left trigger
CONTROL_INVENTORY_LEFT = 47 -- right joystick left
CONTROL_INVENTORY_RIGHT = 48 -- right joystick right
CONTROL_INVENTORY_UP = 49 --  right joystick up
CONTROL_INVENTORY_DOWN = 50 -- right joystick down
CONTROL_INVENTORY_EXAMINE = 51 -- d-pad up
CONTROL_INVENTORY_USEONSELF = 52 -- d-pad right
CONTROL_INVENTORY_USEONSCENE = 53 -- d-pad left
CONTROL_INVENTORY_DROP = 54 -- d-pad down
CONTROL_PUTSTACK = 55
CONTROL_CONTROLLER_ATTACK = 56 -- X on xbox controller
CONTROL_CONTROLLER_ACTION = 57 -- A
CONTROL_CONTROLLER_ALTACTION = 58 -- B
CONTROL_USE_ITEM_ON_ITEM = 59

CONTROL_MAP_ZOOM_IN = 60
CONTROL_MAP_ZOOM_OUT = 61

CONTROL_OPEN_DEBUG_MENU = 70 --62 steam deck is 70

CONTROL_TOGGLE_SAY = 63
CONTROL_TOGGLE_WHISPER = 64
CONTROL_TOGGLE_SLASH_COMMAND = 65
CONTROL_TOGGLE_PLAYER_STATUS = 66
CONTROL_SHOW_PLAYER_STATUS = 67

CONTROL_MENU_MISC_1 = 68  -- X
CONTROL_MENU_MISC_2 = 69  -- Y
CONTROL_MENU_MISC_3 = 70  -- L
CONTROL_MENU_MISC_4 = 71  -- R

CONTROL_INSPECT_SELF = 72 -- Keyboard self inspect [I]

CONTROL_SERVER_PAUSE = 73

CONTROL_CRAFTING_MODIFIER = 74		-- this + CONTROL_OPEN_CRAFTING to open with the search box ready to type in
CONTROL_CRAFTING_PINLEFT = 75
CONTROL_CRAFTING_PINRIGHT = 76

CONTROL_INV_11 = 77 -- Sequence ordering difference but makes backwards compatability easier.
CONTROL_INV_12 = 78
CONTROL_INV_13 = 79
CONTROL_INV_14 = 80
CONTROL_INV_15 = 81

CONTROL_CUSTOM_START = 100

XBOX_CONTROLLER_ID = 17

-- controller targetting er... controls
CONTROL_TARGET_MODIFIER = CONTROL_MENU_MISC_2
CONTROL_TARGET_LOCK = CONTROL_MENU_MISC_2
CONTROL_TARGET_CYCLE_BACK = CONTROL_ROTATE_LEFT
CONTROL_TARGET_CYCLE_FORWARD = CONTROL_ROTATE_RIGHT

KEY_TAB = 9
KEY_KP_0			= 256
KEY_KP_1			= 257
KEY_KP_2			= 258
KEY_KP_3			= 259
KEY_KP_4			= 260
KEY_KP_5			= 261
KEY_KP_6			= 262
KEY_KP_7			= 263
KEY_KP_8			= 264
KEY_KP_9			= 265
KEY_KP_PERIOD		= 266
KEY_KP_DIVIDE		= 267
KEY_KP_MULTIPLY		= 268
KEY_KP_MINUS		= 269
KEY_KP_PLUS			= 270
KEY_KP_ENTER		= 271
KEY_KP_EQUALS		= 272
KEY_MINUS = 45
KEY_EQUALS = 61
KEY_SPACE = 32
KEY_ENTER = 13
KEY_ESCAPE = 27
KEY_HOME = 278
KEY_INSERT = 277
KEY_DELETE = 127
KEY_END    = 279
KEY_PAUSE = 19
KEY_PRINT = 316
KEY_CAPSLOCK = 301
KEY_SCROLLOCK = 302
KEY_RSHIFT = 303 -- use KEY_SHIFT instead
KEY_LSHIFT = 304 -- use KEY_SHIFT instead
KEY_RCTRL = 305 -- use KEY_CTRL instead
KEY_LCTRL = 306 -- use KEY_CTRL instead
KEY_RALT = 307 -- use KEY_ALT instead
KEY_LALT = 308 -- use KEY_ALT instead
KEY_LSUPER = 311
KEY_RSUPER = 312
KEY_ALT = 400
KEY_CTRL = 401
KEY_SHIFT = 402
KEY_BACKSPACE = 8
KEY_PERIOD = 46
KEY_SLASH = 47
KEY_SEMICOLON = 59
KEY_LEFTBRACKET	= 91
KEY_BACKSLASH	= 92
KEY_RIGHTBRACKET= 93
KEY_TILDE = 96
KEY_A = 97
KEY_B = 98
KEY_C = 99
KEY_D = 100
KEY_E = 101
KEY_F = 102
KEY_G = 103
KEY_H = 104
KEY_I = 105
KEY_J = 106
KEY_K = 107
KEY_L = 108
KEY_M = 109
KEY_N = 110
KEY_O = 111
KEY_P = 112
KEY_Q = 113
KEY_R = 114
KEY_S = 115
KEY_T = 116
KEY_U = 117
KEY_V = 118
KEY_W = 119
KEY_X = 120
KEY_Y = 121
KEY_Z = 122
KEY_F1 = 282
KEY_F2 = 283
KEY_F3 = 284
KEY_F4 = 285
KEY_F5 = 286
KEY_F6 = 287
KEY_F7 = 288
KEY_F8 = 289
KEY_F9 = 290
KEY_F10 = 291
KEY_F11 = 292
KEY_F12 = 293

KEY_UP			= 273
KEY_DOWN		= 274
KEY_RIGHT		= 275
KEY_LEFT		= 276
KEY_PAGEUP		= 280
KEY_PAGEDOWN	= 281

KEY_0 = 48
KEY_1 = 49
KEY_2 = 50
KEY_3 = 51
KEY_4 = 52
KEY_5 = 53
KEY_6 = 54
KEY_7 = 55
KEY_8 = 56
KEY_9 = 57

-- DO NOT use these for gameplay!
MOUSEBUTTON_LEFT = 1000
MOUSEBUTTON_RIGHT = 1001
MOUSEBUTTON_MIDDLE = 1002
MOUSEBUTTON_SCROLLUP = 1003
MOUSEBUTTON_SCROLLDOWN = 1004


GESTURE_ZOOM_IN = 900
GESTURE_ZOOM_OUT = 901
GESTURE_ROTATE_LEFT = 902
GESTURE_ROTATE_RIGHT = 903
GESTURE_MAX = 904

SCREEN_FLASH_SCALING =
{
	0.9, -- default
	0.6, -- dim
	0.3, -- dimmest
}

BACKEND_PREFABS = { "forest", "cave", "lavaarena", "quagmire" }
FRONTEND_PREFABS = { "frontend" }
RECIPE_PREFABS = {}
--Defined below:
-- SPECIAL_EVENT_GLOBAL_PREFABS
-- SPECIAL_EVENT_BACKEND_PREFABS
-- SPECIAL_EVENT_FRONTEND_PREFABS
-- FESTIVAL_EVENT_GLOBAL_PREFABS
-- FESTIVAL_EVENT_BACKEND_PREFABS
-- FESTIVAL_EVENT_FRONTEND_PREFABS

FADE_OUT = false
FADE_IN = true

--Legacy table, not for DST
MAIN_CHARACTERLIST =
{
    "wilson", "willow", "wolfgang", "wendy", "wx78", "wickerbottom", "woodie", "wes", "waxwell",
}

--Legacy table, not for DST
ROG_CHARACTERLIST =
{
    "wathgrithr", "webber",
}

--When adding new characters with alternate states, be sure to update skinsutils.lua function GetSkinModes.
DST_CHARACTERLIST =
{
    "wilson",
    "willow",
    "wolfgang",
    "wendy",
    "wx78",
    "wickerbottom",
    "woodie",
    "wes",
    "waxwell",
    "wathgrithr",
    "webber",
    "winona",
    "warly",
    --DLC chars:
    "wortox",
    "wormwood",
    "wurt",
    "walter",
    "wanda",
}

CHARACTER_VIDEOS =
{
	wilson = {"https://bit.ly/3w9VYcN"},
	willow = {"https://bit.ly/3rFOkU3"},
	wendy = {"https://bit.ly/3fI3PbR"},
	wolfgang = {"https://klei.gg/33A9mNx"},
	wx78 = {"https://klei.gg/3F9qqc1"},
--	wickerbottom = {},
	wes = {"https://bit.ly/2QLFpn4"},
	waxwell = {"https://bit.ly/3rF0UD0"},
	woodie = {"https://bit.ly/3sHhUK1"},
	wathgrithr = {"https://bit.ly/3rC8YV6"},
	webber = {"https://klei.gg/3zXJrLt"},
	winona = {"https://bit.ly/3fB6LHb"},
    wortox = {"https://bit.ly/3cBQ10g"},
    wormwood = {"https://bit.ly/3cBilQq"},
    warly = {"https://bit.ly/39vp0tG"},
    wurt = {"https://bit.ly/2QVJup1"},
	walter = {"https://bit.ly/31Ajrpj"},
	wanda = {"https://klei.gg/dst-wanda-short"},
}


require("prefabskins")
require("clothing")
require("beefalo_clothing")
require("misc_items")
require("emote_items")
require("item_blacklist")

CLOTHING.body_default1 =
{
    type = "body",
    skin_tags = {},
    is_default = true,
    release_group = 999,
}
CLOTHING.hand_default1 =
{
    type = "hand",
    skin_tags = {},
    is_default = true,
    release_group = 999,
}
CLOTHING.legs_default1 =
{
    type = "legs",
    skin_tags = {},
    is_default = true,
    release_group = 999,
}
CLOTHING.feet_default1 =
{
    type = "feet",
    skin_tags = {},
    is_default = true,
    release_group = 999,
}
MISC_ITEMS.beard_default1 =
{
    type = "beard",
    skin_tags = {},
    is_default = true,
    release_group = 999,
}



BEEFALO_CLOTHING.beef_body_default1 =
{
    type = "beef_body",
    skin_tags = {},
    is_default = true,
    release_group = 999,
}
BEEFALO_CLOTHING.beef_horn_default1 =
{
    type = "beef_horn",
    skin_tags = {},
    is_default = true,
    release_group = 999,
}
BEEFALO_CLOTHING.beef_head_default1 =
{
    type = "beef_head",
    skin_tags = {},
    is_default = true,
    release_group = 999,
}
BEEFALO_CLOTHING.beef_feet_default1 =
{
    type = "beef_feet",
    skin_tags = {},
    is_default = true,
    release_group = 999,
}
BEEFALO_CLOTHING.beef_tail_default1 =
{
    type = "beef_tail",
    skin_tags = {},
    is_default = true,
    release_group = 999,
}


MAINSCREEN_TOOL_LIST =
{
    "swap_axe", "swap_spear", "swap_pickaxe", "swap_shovel", "swap_staffs", "swap_cane", "swap_fishingrod", "swap_hammer", "swap_batbat", "swap_ham_bat",
}


MAINSCREEN_TORSO_LIST =
{
    "", "", "", "", "armor_wood", "armor_sweatervest", "torso_amulets", "armor_trunkvest_winter", "armor_ruins", "torso_dragonfly", "torso_hawaiian"
}


MAINSCREEN_HAT_LIST =
{
    "", "", "", "", "hat_top", "hat_beefalo", "hat_football", "hat_winter", "hat_spider", "hat_catcoon", "hat_mole", "hat_ice", "hat_watermelon"
}


MODCHARACTERLIST =
{
    -- this gets populated by mods
}

MODCHARACTEREXCEPTIONS_DST =
{
    -- this also gets populated by mods
}

CHARACTER_GENDERS =
{
    FEMALE =
    {
        "willow",
        "wendy",
        "wickerbottom",
        "wathgrithr",
        "winona",
        "wurt",
        "wanda",
    },
    MALE =
    {
        "wilson",
        "woodie",
        "waxwell",
        "wolfgang",
        "wes",
        "webber",
        "warly",
        "wortox",
        "wormwood",
        "walter",
    },
    ROBOT =
    {
        "wx78",
        "pyro",
    },
    NEUTRAL = {}, --empty, for modders to add to
    PLURAL = {}, --empty, for modders to add to
}

MODCHARACTERMODES = {} --empty, for modders to add to

MAXITEMSLOTS = 15

EQUIPSLOTS =
{
    HANDS = "hands",
    HEAD = "head",
    BODY = "body",
}

ITEMTAG =
{
    FOOD = "food",
    MEAT = "meat",
    WEAPON = "weapon",
    TOOL = "tool",
    TREASURE = "treasure",
    FUEL = "fuel",
    FIRE = "fire",
    STACKABLE = "stackable",
    FX = "FX",
}

OCEAN_DEPTH =
{
    SHALLOW = 1,
    NORMAL = 2,
    DEEP = 3,
    VERY_DEEP = 4,
}

-- See map_painter.h
-- PUBLIC USE SPACE FOR MODS is 70 to 89 -- Mods using values outside of this range may find themselfs conflicting with future official content
GROUND =
{
	INVALID = 255,
    IMPASSABLE = 1,

    ROAD = 2,
    ROCKY = 3,
    DIRT = 4,
	SAVANNA = 5,
	GRASS = 6,
	FOREST = 7,
	MARSH = 8,
	WEB = 9,
	WOODFLOOR = 10,
	CARPET = 11,
	CHECKER = 12,

	-- CAVES
	CAVE = 13,
	FUNGUS = 14,
	SINKHOLE = 15,
    UNDERROCK = 16,
    MUD = 17,
    BRICK = 18,
    BRICK_GLOW = 19,
    TILES = 20,
    TILES_GLOW = 21,
    TRIM = 22,
    TRIM_GLOW = 23,
	FUNGUSRED = 24,
	FUNGUSGREEN = 25,

	--EXPANDED FLOOR TILES
	DECIDUOUS = 30,
	DESERT_DIRT = 31,
	SCALE = 32,

	LAVAARENA_FLOOR = 33,
	LAVAARENA_TRIM = 34,

	QUAGMIRE_PEATFOREST = 35,
	QUAGMIRE_PARKFIELD = 36,
	QUAGMIRE_PARKSTONE = 37,
	QUAGMIRE_GATEWAY = 38,
	QUAGMIRE_SOIL = 39,
	QUAGMIRE_CITYSTONE = 41,

	PEBBLEBEACH = 42,
	METEOR = 43,
    SHELLBEACH = 44,

    ARCHIVE = 45,
    FUNGUSMOON = 46,

    FARMING_SOIL = 47,

	-- PUBLIC USE SPACE FOR MODS is 70 to 109 --

    --NOISE -- from 110 to 127 -- TODO: move noise tile range to > 255
	FUNGUSMOON_NOISE = 120,
	METEORMINE_NOISE = 121,
	METEORCOAST_NOISE = 122,
    DIRT_NOISE = 123,
	ABYSS_NOISE = 124,
	GROUND_NOISE = 125,
	CAVE_NOISE = 126,
	FUNGUS_NOISE = 127,

	UNDERGROUND = 128, -- todo: incrase this to OCEAN_START once WALL_X have been removed

	WALL_ROCKY = 151,
	WALL_DIRT = 152,
	WALL_MARSH = 153,
	WALL_CAVE = 154,
	WALL_FUNGUS = 155,
	WALL_SINKHOLE = 156,
	WALL_MUD = 157,
	WALL_TOP = 158,
	WALL_WOOD = 159,
	WALL_HUNESTONE = 160,
	WALL_HUNESTONE_GLOW = 161,
	WALL_STONEEYE = 162,
	WALL_STONEEYE_GLOW = 163,

	FAKE_GROUND = 200, -- todo: change to 254 and retrofit maps

	-- OCEAN TILES [201, 247]
	OCEAN_START = 201, -- enum for checking if tile is ocean water

	-- KLEI OCEAN TILES [201, 230]
	OCEAN_COASTAL = 201,
	OCEAN_COASTAL_SHORE = 202,
	OCEAN_SWELL = 203,
	OCEAN_ROUGH = 204,
	OCEAN_BRINEPOOL = 205,
	OCEAN_BRINEPOOL_SHORE = 206,
	OCEAN_HAZARDOUS = 207,
    OCEAN_WATERLOG = 208, 

	-- MODS OCEAN TILES [231, 247]  <--PUBLIC USE SPACE FOR MODS --

	OCEAN_END = 247, -- enum for checking if tile is ocean water

--	STILL_WATER_SHALLOW = 130,
--	STILL_WATER_DEEP = 131,
--	MOVING_WATER_SHALLOW = 132,
--	MOVING_WATER_DEEP = 133,
--	SALT_WATER_SHALLOW = 134,
--	SALT_WATER_DEEP = 135,
}

-- deprecated ground types
GROUND.OCEAN_REEF = GROUND.OCEAN_BRINEPOOL
GROUND.OCEAN_REEF_SHORE = GROUND.OCEAN_BRINEPOOL_SHORE

---------------------------------------------------------
SPECIAL_EVENTS =
{
    NONE = "none",
    HALLOWED_NIGHTS = "hallowed_nights",
    WINTERS_FEAST = "winters_feast",
	CARNIVAL = "crow_carnival",
    YOTG = "year_of_the_gobbler",
    YOTV = "year_of_the_varg",
    YOTP = "year_of_the_pig",
    YOTC = "year_of_the_carrat",
    YOTB = "year_of_the_beefalo",
    YOT_CATCOON = "year_of_the_catcoon",
}
WORLD_SPECIAL_EVENT = SPECIAL_EVENTS.NONE
--WORLD_SPECIAL_EVENT = IS_BETA and SPECIAL_EVENTS.YOT_CATCOON or SPECIAL_EVENTS.NONE
WORLD_EXTRA_EVENTS = {}

FESTIVAL_EVENTS =
{
    NONE = "none",
    LAVAARENA = "lavaarena",
    QUAGMIRE = "quagmire",
}
WORLD_FESTIVAL_EVENT = FESTIVAL_EVENTS.NONE
PREVIOUS_FESTIVAL_EVENTS = { FESTIVAL_EVENTS.LAVAARENA, FESTIVAL_EVENTS.QUAGMIRE } --deprecated, use PREVIOUS_FESTIVAL_EVENTS_ORDER
PREVIOUS_FESTIVAL_EVENTS_ORDER =
{
    { id = FESTIVAL_EVENTS.LAVAARENA, season = 2 },
    { id = FESTIVAL_EVENTS.QUAGMIRE, season = 1 },
    { id = FESTIVAL_EVENTS.LAVAARENA, season = 1 },
}

IS_YEAR_OF_THE_SPECIAL_EVENTS =
{
    [SPECIAL_EVENTS.YOTG] = true,
    [SPECIAL_EVENTS.YOTV] = true,
    [SPECIAL_EVENTS.YOTP] = true,
    [SPECIAL_EVENTS.YOTC] = true,
    [SPECIAL_EVENTS.YOTB] = true,
	[SPECIAL_EVENTS.YOT_CATCOON] = true,
}


---------------------------------------------------------
-- Reminder: update event_deps.lua
SPECIAL_EVENT_GLOBAL_PREFABS = { WORLD_SPECIAL_EVENT.."_event_global" }
SPECIAL_EVENT_BACKEND_PREFABS = { WORLD_SPECIAL_EVENT.."_event_backend" }
SPECIAL_EVENT_FRONTEND_PREFABS = { WORLD_SPECIAL_EVENT.."_event_frontend" }

FESTIVAL_EVENT_GLOBAL_PREFABS = { WORLD_FESTIVAL_EVENT.."_fest_global" }
FESTIVAL_EVENT_BACKEND_PREFABS = { WORLD_FESTIVAL_EVENT.."_fest_backend" }
FESTIVAL_EVENT_FRONTEND_PREFABS = { WORLD_FESTIVAL_EVENT.."_fest_frontend" }


---------------------------------------------------------
--Used in preloadsounds.lua
---------------------------------------------------------
-- Reminder: update asset dependencies in frontend.lua --
---------------------------------------------------------
SPECIAL_EVENT_MUSIC =
{
    --winter's feast carol
    [SPECIAL_EVENTS.WINTERS_FEAST] =
    {
  --      bank = "music_frontend_winters_feast.fsb",
  --      sound = "dontstarve/music/music_FE_WF",
        bank = "music_frontend.fsb",
        sound = "dontstarve/music/music_FE_wolfgang",
    },

    --year of the gobbler
    [SPECIAL_EVENTS.YOTG] =
    {
        bank = "music_frontend_yotg.fsb",
        sound = "dontstarve/music/music_FE_yotg",
    },

    --year of the varg
    [SPECIAL_EVENTS.YOTV] =
    {
        bank = "music_frontend_yotg.fsb",
        sound = "dontstarve/music/music_FE_yotg",
    },

    --year of the pig
    [SPECIAL_EVENTS.YOTP] =
    {
        bank = "music_frontend_yotg.fsb",
        sound = "dontstarve/music/music_FE_yotg",
    },

    --year of the carrat
    [SPECIAL_EVENTS.YOTC] =
    {
        bank = "music_frontend_yotc.fsb",
        sound = "dontstarve/music/music_FE_yotc",
    },

    --year of the beefalo
    [SPECIAL_EVENTS.YOTB] =
    {
        bank = "music_frontend_yotb.fsb",
        sound = "yotb_2021/music/FE",
    },

    [SPECIAL_EVENTS.YOT_CATCOON] =
    {
        bank = "music_frontend_yotg.fsb",
        sound = "dontstarve/music/music_FE_yotg",
    },

	-- crow carnival
    [SPECIAL_EVENTS.CARNIVAL] =
    {
        bank = "music_frontend.fsb",
        sound = "dontstarve/music/music_FE_summerevent",
    },
}

FESTIVAL_EVENT_MUSIC =
{
    --the forge
    [FESTIVAL_EVENTS.LAVAARENA] =
    {
        bank = "lava_arena.fsb",
        sound = "dontstarve/music/lava_arena/FE_1_2",
    },
    --the gorge
    [FESTIVAL_EVENTS.QUAGMIRE] =
    {
        bank = "quagmire.fsb",
        sound = "dontstarve/quagmire/music/FE",
    },
}


---------------------------------------------------------
local SPECIAL_EVENT_SKIN_TAGS =
{
    [SPECIAL_EVENTS.HALLOWED_NIGHTS] = "COSTUME",
}

local FESTIVAL_EVENT_SKIN_TAGS =
{
}

local FESTIVAL_EVENT_INFO =
{
    --the forge
    [FESTIVAL_EVENTS.LAVAARENA] =
    {
        GAME_MODE = "lavaarena",
        SERVER_NAME = "LavaArena",
        FEMUSIC = "dontstarve/music/lava_arena/FE2",
		STATS_FILE_PREFIX = "forge_stats",
        LATEST_SEASON = 2,
    },
    --the gorge
    [FESTIVAL_EVENTS.QUAGMIRE] =
    {
        GAME_MODE = "quagmire",
        SERVER_NAME = "Quagmire",
        FEMUSIC = nil, --no special FE music for the festival event screen
		STATS_FILE_PREFIX = "thegorge_stats",
        LATEST_SEASON = 1,
    },
}


---------------------------------------------------------
-- Refers to holiday-specific events.
function IsSpecialEventActive(event)
    return WORLD_SPECIAL_EVENT == event or WORLD_EXTRA_EVENTS[event] == true
end

function IsAnySpecialEventActive()
    return WORLD_SPECIAL_EVENT ~= SPECIAL_EVENTS.NONE or not IsTableEmpty(WORLD_EXTRA_EVENTS)
end

function GetActiveSpecialEventCount()
    return (WORLD_SPECIAL_EVENT ~= SPECIAL_EVENTS.NONE and 1 or 0) + GetTableSize(WORLD_EXTRA_EVENTS)
end

function GetFirstActiveSpecialEvent()
    if WORLD_SPECIAL_EVENT ~= SPECIAL_EVENTS.NONE then
        return WORLD_SPECIAL_EVENT
    end
    return next(WORLD_EXTRA_EVENTS), nil --, nil prevents the value from getting returned by next
end

function GetAllActiveEvents(special_event, extra_events)
    local all_events = {}
    if special_event then
        all_events[special_event] = true
    end
    for event in pairs(extra_events or {}) do
        all_events[event] = true
    end
    all_events[SPECIAL_EVENTS.NONE] = nil
    return all_events
end

---------------------------------------------------------
-- Checks if any of the "Year of the <creature>" events are active
function IsAny_YearOfThe_EventActive()
	if IS_YEAR_OF_THE_SPECIAL_EVENTS[WORLD_SPECIAL_EVENT] then
        return true
    end
    for special_event in pairs(WORLD_EXTRA_EVENTS) do
        if IS_YEAR_OF_THE_SPECIAL_EVENTS[special_event] then
            return true
        end
    end
    return false
end

function GetSpecialEventSkinTag()
    return SPECIAL_EVENT_SKIN_TAGS[WORLD_SPECIAL_EVENT]
end

---------------------------------------------------------
-- Refers to intermittent scheduled events.
function IsFestivalEventActive(event)
    return WORLD_FESTIVAL_EVENT == event
end

function IsPreviousFestivalEvent(event)
    for _,prev_event in ipairs(PREVIOUS_FESTIVAL_EVENTS_ORDER) do
        if prev_event.id == event then
            return true
        end
    end
    return false
end

function IsAnyFestivalEventActive()
    return WORLD_FESTIVAL_EVENT ~= FESTIVAL_EVENTS.NONE
end

function GetFestivalEventSkinTag()
    return FESTIVAL_EVENT_SKIN_TAGS[WORLD_FESTIVAL_EVENT]
end

function GetFestivalEventInfo()
    return FESTIVAL_EVENT_INFO[WORLD_FESTIVAL_EVENT]
end

function GetFestivalEventSeasons(festival)
    return FESTIVAL_EVENT_INFO[festival] ~= nil and FESTIVAL_EVENT_INFO[festival].LATEST_SEASON or 0
end

-- Used by C side. Do NOT rename without editing simulation.cpp
function GetActiveFestivalEventServerName()
    local festival = IsAnyFestivalEventActive() and WORLD_FESTIVAL_EVENT
    return GetFestivalEventServerName( festival, GetFestivalEventSeasons(festival) )
end

-- Used by C side. Do NOT rename without editing simulation.cpp
function GetActiveFestivalProductName()
	return FESTIVAL_EVENT_INFO[WORLD_FESTIVAL_EVENT] ~= nil and FESTIVAL_EVENT_INFO[WORLD_FESTIVAL_EVENT].SERVER_NAME or ""
end

function GetFestivalEventServerName(festival, season)
    if season == 1 then
        return FESTIVAL_EVENT_INFO[festival] ~= nil and FESTIVAL_EVENT_INFO[festival].SERVER_NAME or ""
    else
        return FESTIVAL_EVENT_INFO[festival] ~= nil and (string.format( "%s_s%d", FESTIVAL_EVENT_INFO[festival].SERVER_NAME, season )) or ""
    end
end

function GetActiveFestivalEventStatsFilePrefix()
    local festival = IsAnyFestivalEventActive() and WORLD_FESTIVAL_EVENT
    return FESTIVAL_EVENT_INFO[festival] ~= nil and FESTIVAL_EVENT_INFO[festival].STATS_FILE_PREFIX or "stats"
end

function GetActiveFestivalEventAchievementStrings()
    --Note, this requires the festival name to have the same spelling at the name in the STRINGS.UI.ACHIEVEMENTS string table
    local festival = IsAnyFestivalEventActive() and WORLD_FESTIVAL_EVENT
    return STRINGS.UI.ACHIEVEMENTS[festival:upper()]
end

-- To enable/disable the tournament, change the return value of Server_IsTournamentActive()
function Server_IsTournamentActive()
	-- for internal server use only
	return false
end

function Client_IsTournamentActive() -- ticket_name is optional
	return Server_IsTournamentActive() and IsSteam()
end

---------------------------------------------------------
--If changing this logic, remember to update preloadsounds.lua
--default:
--  bank = "music_frontend.fsb"
--  sound = "dontstarve/music/music_FE"
FE_MUSIC =
    (FESTIVAL_EVENT_MUSIC[WORLD_FESTIVAL_EVENT] ~= nil and FESTIVAL_EVENT_MUSIC[WORLD_FESTIVAL_EVENT].sound) or
    (SPECIAL_EVENT_MUSIC[WORLD_SPECIAL_EVENT] ~= nil and SPECIAL_EVENT_MUSIC[WORLD_SPECIAL_EVENT].sound) or
    --"dontstarve/music/music_FE"
    "dontstarve/music/music_FE_WX"
    --"dontstarve/music/music_moonstorm_FE"
    --"dontstarve/music/music_FE_webber"
    --"dontstarve/music/music_FE_wanda"
    --"terraria1/common/music_main_eot"

---------------------------------------------------------
NUM_HALLOWEENCANDY = 14
NUM_HALLOWEEN_ORNAMENTS = 6
NUM_WINTERFOOD = 9

SANITY_MODE_INSANITY = 0
SANITY_MODE_LUNACY = 1


TECH =
{
    NONE = TechTree.Create(),

    SCIENCE_ONE = { SCIENCE = 1 },
    SCIENCE_TWO = { SCIENCE = 2 },
    SCIENCE_THREE = { SCIENCE = 3 },
    -- Magic starts at level 2 so it's not teased from the start.
    MAGIC_TWO = { MAGIC = 2 },
    MAGIC_THREE = { MAGIC = 3 },

    ANCIENT_TWO = { ANCIENT = 2 },
    ANCIENT_THREE = { ANCIENT = 3 },
    ANCIENT_FOUR = { ANCIENT = 4 },

    CELESTIAL_ONE = { CELESTIAL = 1 },
    CELESTIAL_THREE = { CELESTIAL = 3 },

	MOON_ALTAR_TWO = { CELESTIAL = 3 }, -- deprecated, use CELESTIAL_THREE

    SHADOW_TWO = { SHADOW = 3 },

    CARTOGRAPHY_TWO = { CARTOGRAPHY = 2 },

    SEAFARING_ONE = { SEAFARING = 1 },
    SEAFARING_TWO = { SEAFARING = 2 },

    SCULPTING_ONE = { SCULPTING = 1 },
    SCULPTING_TWO = { SCULPTING = 2 },

    ORPHANAGE_ONE = { ORPHANAGE = 1 },
    PERDOFFERING_ONE = { PERDOFFERING = 1 },
    PERDOFFERING_THREE = { PERDOFFERING = 3 },
    WARGOFFERING_THREE = { WARGOFFERING = 3 },
    PIGOFFERING_THREE = { PIGOFFERING = 3 },
    CARRATOFFERING_THREE = { CARRATOFFERING = 3 },
    BEEFOFFERING_THREE = { BEEFOFFERING = 3 },
    CATCOONOFFERING_THREE = { CATCOONOFFERING = 3 },
    MADSCIENCE_ONE = { MADSCIENCE = 1 },
	CARNIVAL_PRIZESHOP_ONE = { CARNIVAL_PRIZESHOP = 1 },
	CARNIVAL_HOSTSHOP_ONE = { CARNIVAL_HOSTSHOP = 1 },
	CARNIVAL_HOSTSHOP_THREE = { CARNIVAL_HOSTSHOP = 3 },

    FOODPROCESSING_ONE = { FOODPROCESSING = 1 },
	FISHING_ONE = { FISHING = 1 },
	FISHING_TWO = { FISHING = 2 },

	HERMITCRABSHOP_ONE = { HERMITCRABSHOP = 1 },
	HERMITCRABSHOP_THREE = { HERMITCRABSHOP = 3 },
	HERMITCRABSHOP_FIVE = { HERMITCRABSHOP = 5 },
    HERMITCRABSHOP_SEVEN = { HERMITCRABSHOP = 7 },

    TURFCRAFTING_ONE = { TURFCRAFTING = 1 },
    TURFCRAFTING_TWO = { TURFCRAFTING = 2 },
	MASHTURFCRAFTING_TWO = { MASHTURFCRAFTING = 2},

	WINTERSFEASTCOOKING_ONE = { WINTERSFEASTCOOKING = 1 },

    HALLOWED_NIGHTS = { SCIENCE = 10 }, -- ApplySpecialEvent() will change this from lost to 0
    WINTERS_FEAST = { SCIENCE = 10 }, -- ApplySpecialEvent() will change this from lost to 0
    YOTG = { SCIENCE = 10 }, -- ApplySpecialEvent() will change this from lost to 0
    YOTV = { SCIENCE = 10 }, -- ApplySpecialEvent() will change this from lost to 0
    YOTP = { SCIENCE = 10 }, -- ApplySpecialEvent() will change this from lost to 0
    YOTC = { SCIENCE = 10 }, -- ApplySpecialEvent() will change this from lost to 0
    YOTB = { SCIENCE = 10 }, -- ApplySpecialEvent() will change this from lost to 0
    YOT_CATCOON = { SCIENCE = 10 }, -- ApplySpecialEvent() will change this from lost to 0

    LOST = { MAGIC = 10, SCIENCE = 10, ANCIENT = 10 },

    SPIDERCRAFT_ONE = { SPIDERCRAFT = 1 },

    ROBOTMODULECRAFT_ONE = { ROBOTMODULECRAFT = 1 },
}

-- See cell_data.h
NODE_TYPE =
{
    Default = 0,		-- Land can touch any other Default node in the task that is within range
    Blank = 1,			-- empty room with impassable ground
    Background = 2,
    Random = 3,
    Blocker = 4,		-- Adds 2 Blank nodes beside it
    Room = 5,			-- Land can only touch the room(s) it is connected to by the graph (adds impassable around its parameter with a single land bidge)
    BackgroundRoom = 6,
	SeparatedRoom = 7,	-- adds impassable around its entire parameter
}

-- See cell_data.h
NODE_INTERNAL_CONNECTION_TYPE =
{
    EdgeCentroid = 0,
    EdgeSite = 1,
    EdgeEdgeDirect = 2,
    EdgeEdgeLeft = 3,
    EdgeEdgeRight = 4,
    EdgeData = 5,
}

CA_SEED_MODE =
{
    SEED_RANDOM = 0,
    SEED_CENTROID = 1,
    SEED_SITE = 2,
    SEED_WALLS = 3,
}

-- See maze.h
MAZE_TYPE =
{
    MAZE_DFS_4WAY_META = 0,
    MAZE_DFS_4WAY = 1,
    MAZE_DFS_8WAY = 2,
    MAZE_GROWINGTREE_4WAY = 3,
    MAZE_GROWINGTREE_8WAY = 4,
    MAZE_GROWINGTREE_4WAY_INV = 5,
}

-- NORTH	1
-- EAST		2
-- SOUTH	4
-- WEST		8
--[[
Meta maze def:
5 room types:
4 way,	3 way,	2 way,	1 way,	L shape
	1,		4,		2,		4,		4
	15 tiles needed
--]]

MAZE_CELL_EXITS =
{
	NO_EXITS = 		0, -- Dont place a cell here.
	SINGLE_NORTH = 	1,
	SINGLE_EAST = 	2,
	L_NORTH = 		3,
	SINGLE_SOUTH = 	4,
	TUNNEL_NS = 	5,
	L_EAST = 		6,
	THREE_WAY_N = 	7,
	SINGLE_WEST = 	8,
	L_WEST = 		9,
	TUNNEL_EW =		10,
	THREE_WAY_W = 	11,
	L_SOUTH = 		12,
	THREE_WAY_S = 	13,
	THREE_WAY_E = 	14,
	FOUR_WAY = 		15,
}

MAZE_CELL_EXITS_INV =
{
	"SINGLE_NORTH",
	"SINGLE_EAST",
	"L_NORTH",
	"SINGLE_SOUTH",
	"TUNNEL_NS",
	"L_EAST",
	"THREE_WAY_N",
	"SINGLE_WEST",
	"L_WEST",
	"TUNNEL_EW",
	"THREE_WAY_W",
	"L_SOUTH" ,
	"THREE_WAY_S",
	"THREE_WAY_E",
	"FOUR_WAY",
}

LAYOUT =
{
	STATIC = 0,
	CIRCLE_EDGE = 1,
	CIRCLE_RANDOM = 2,
	GRID = 3,
	RECTANGLE_EDGE = 4,
	CIRCLE_FILLED = 5,
}

LAYOUT_POSITION =
{
	RANDOM = 0,
	CENTER = 1,
}

LAYOUT_ROTATION =
{
	NORTH = 0, 	-- 0 Degrees
	EAST = 1, 	-- 90 Degrees
	SOUTH = 2, 	-- 180 Degrees
	WEST = 3, 	-- 270 Degrees
}

PLACE_MASK =
{
	NORMAL = 0,
	IGNORE_IMPASSABLE = 1,
	IGNORE_BARREN = 2,
	IGNORE_IMPASSABLE_BARREN = 3,
	IGNORE_RESERVED = 4,
	IGNORE_IMPASSABLE_RESERVED = 5,
	IGNORE_BARREN_RESERVED = 6,
	IGNORE_IMPASSABLE_BARREN_RESERVED = 7,
}

-- keep up to date with MapSampleStyle in MapDefines.h
MAP_SAMPLE_STYLE =
{
	NINE_SAMPLE = 0,
	MARCHING_SQUARES = 1, -- Note to modders: this approach is still a prototype
}

--keep up to date with luabit.h
LUABIT =
{
    WIDTH8BIT = 1,
    WIDTH16BIT = 2,
    --WIDTH32BIT = 3, --if 1 or 2 isn't passed, its assumed to be 32 bit width
}


-- keep up to date with COLLISION_GROUP in simconstants.h
COLLISION =
{
    GROUND            = 32,
	BOAT_LIMITS       = 64,
	LAND_OCEAN_LIMITS = 128,             -- physics wall between water and land
    LIMITS            = 128 + 64,        -- BOAT_LIMITS + LAND_OCEAN_LIMITS
    WORLD             = 128 + 64 + 32,   -- BOAT_LIMITS + LAND_OCEAN_LIMITS + GROUND
    ITEMS             = 256,
    OBSTACLES         = 512,
    CHARACTERS        = 1024,
    FLYERS            = 2048,
    SANITY            = 4096,
    SMALLOBSTACLES    = 8192,	-- collide with characters but not giants
    GIANTS            = 16384,	-- collide with obstacles but not small obstacles
}

MAX_PHYSICS_RADIUS = 4 --boats are currently the largest.

BLENDMODE =
{
	Disabled = 0,
	AlphaBlended = 1,
	Additive = 2,
	Premultiplied = 3,
	InverseAlpha = 4,
	AlphaAdditive = 5,
	VFXTest = 6,
}

ANIM_ORIENTATION =
{
    BillBoard = 0,
    OnGround = 1,
    OnGroundFixed = 2,
}
ANIM_ORIENTATION.Default = ANIM_ORIENTATION.BillBoard

RECIPETABS =
{
    TOOLS =         { str = "TOOLS",        sort = 0,   icon = "tab_tool.tex" },
    LIGHT =         { str = "LIGHT",        sort = 1,   icon = "tab_light.tex" },
    SURVIVAL =      { str = "SURVIVAL",     sort = 2,   icon = "tab_trap.tex" },
    FARM =          { str = "FARM",         sort = 3,   icon = "tab_farm.tex" },
    SCIENCE =       { str = "SCIENCE",      sort = 4,   icon = "tab_science.tex" },
    WAR =           { str = "WAR",          sort = 5,   icon = "tab_fight.tex" },
    TOWN =          { str = "TOWN",         sort = 6,   icon = "tab_build.tex" },
    SEAFARING =     { str = "SEAFARING",    sort = 7,   icon = "tab_seafaring.tex" },
    REFINE =        { str = "REFINE",       sort = 8,   icon = "tab_refine.tex" },
    MAGIC =         { str = "MAGIC",        sort = 9,   icon = "tab_arcane.tex" },
    DRESS =         { str = "DRESS",        sort = 10,  icon = "tab_dress.tex" },

    --Crafting stations
    ANCIENT =				{ str = "ANCIENT",				sort = 100, icon = "tab_crafting_table.tex",	crafting_station = true },
    CELESTIAL =				{ str = "CELESTIAL",			sort = 100, icon = "tab_celestial.tex",			crafting_station = true },
    MOON_ALTAR =			{ str = "MOON_ALTAR",			sort = 100, icon = "tab_moonaltar.tex",			crafting_station = true }, -- deprecated, all recipes have been moved into CELESTIAL
    CARTOGRAPHY =			{ str = "CARTOGRAPHY",			sort = 100, icon = "tab_cartography.tex",		crafting_station = true },
    SCULPTING =				{ str = "SCULPTING",			sort = 100, icon = "tab_sculpt.tex",			crafting_station = true },
    ORPHANAGE =				{ str = "ORPHANAGE",			sort = 100, icon = "tab_orphanage.tex",			crafting_station = true },
    PERDOFFERING =			{ str = "PERDOFFERING",			sort = 100, icon = "tab_perd_offering.tex",		crafting_station = true },
    MADSCIENCE =			{ str = "MADSCIENCE",			sort = 100, icon = "tab_madscience_lab.tex",	crafting_station = true, manufacturing_station = true },
	CARNIVAL_PRIZESHOP =	{ str = "CARNIVAL_PRIZESHOP",	sort = 100, icon = "tab_prizebooth.tex",		crafting_station = true , shop = true, icon_atlas = "images/hud2.xml"},
	CARNIVAL_HOSTSHOP =		{ str = "CARNIVAL_HOSTSHOP",	sort = 100, icon = "tab_host.tex",				crafting_station = true , shop = true, icon_atlas = "images/hud2.xml"},
    FOODPROCESSING =		{ str = "FOODPROCESSING",		sort = 100, icon = "tab_foodprocessing.tex",	crafting_station = true },
	FISHING =				{ str = "FISHING",				sort = 100, icon = "tab_fishing.tex",			crafting_station = true },
	WINTERSFEASTCOOKING =	{ str = "WINTERSFEASTCOOKING",	sort = 100, icon = "tab_feast_oven.tex",		crafting_station = true },
    HERMITCRABSHOP =		{ str = "HERMITCRABSHOP",		sort = 100, icon = "tab_hermitcrab_shop.tex",	crafting_station = true, shop = true},
    TURFCRAFTING =		    { str = "TURFCRAFTING", 		sort = 100, icon = "tab_turfcrafting.tex",      crafting_station = true, icon_atlas = "images/hud2.xml" },
}

CUSTOM_RECIPETABS =
{
    BOOKS         = { str = "BOOKS",			sort = 999, icon = "tab_book.tex",          owner_tag = "bookbuilder"  },
    SHADOW        = { str = "SHADOW",			sort = 999, icon = "tab_shadow.tex",        owner_tag = "shadowmagic"  },
    ENGINEERING   = { str = "ENGINEERING",		sort = 999, icon = "tab_engineering.tex",   owner_tag = "handyperson"  },
	ELIXIRBREWING = { str = "ELIXIRBREWING",	sort = 999, icon = "tab_elixirbrewing.tex", owner_tag = "elixirbrewer" },
    BATTLESONGS   = { str = "BATTLESONGS",      sort = 999, icon = "tab_battlesongs.tex",   owner_tag = "battlesinger",    icon_atlas = "images/hud2.xml" },
    SPIDERCRAFT   = { str = "SPIDERCRAFT",      sort = 999, icon = "tab_spidercraft.tex",   owner_tag = "spiderwhisperer", icon_atlas = "images/hud2.xml" },
    NATURE        = { str = "NATURE",			sort = 999, icon = "tab_nature.tex",        owner_tag = "plantkin"     },
	SLINGSHOTAMMO =	{ str = "SLINGSHOTAMMO",	sort = 999, icon = "tab_slingshot.tex",	    owner_tag = "pebblemaker"  },
	BALLOONOMANCY = { str = "BALLOONOMANCY",	sort = 999, icon = "tab_balloonomancy.tex",	owner_tag = "balloonomancer",	icon_atlas = "images/hud2.xml" },
	CLOCKMAKER    =	{ str = "CLOCKMAKER",		sort = 999, icon = "tab_clockmaker.tex",	owner_tag = "clockmaker",		icon_atlas = "images/hud2.xml"},
    STRONGMAN     =	{ str = "STRONGMAN",		sort = 999, icon = "tab_strongman.tex",	    owner_tag = "strongman",		icon_atlas = "images/hud2.xml"},
}

QUAGMIRE_RECIPETABS =
{
    QUAGMIRE_MEALINGSTONE = { str = "QUAGMIRE_MEALINGSTONE", sort = 0, icon = "tab_quagmire_mealingstone.tex", icon_atlas = "images/quagmire_hud.xml", crafting_station = true },
    QUAGMIRE_TRADER_ELDER = { str = "QUAGMIRE_TRADER_ELDER", sort = 0, icon = "tab_quagmire_swampigelder.tex", icon_atlas = "images/quagmire_hud.xml", crafting_station = true, shop = true },
    QUAGMIRE_TRADER_MERM1 = { str = "QUAGMIRE_TRADER_MERM1", sort = 0, icon = "tab_quagmire_trader_merm1.tex", icon_atlas = "images/quagmire_hud.xml", crafting_station = true, shop = true },
    QUAGMIRE_TRADER_MERM2 = { str = "QUAGMIRE_TRADER_MERM2", sort = 0, icon = "tab_quagmire_trader_merm2.tex", icon_atlas = "images/quagmire_hud.xml", crafting_station = true, shop = true },
    QUAGMIRE_TRADER_MUM =   { str = "QUAGMIRE_TRADER_MUM",   sort = 0, icon = "tab_quagmire_trader_mum.tex",   icon_atlas = "images/quagmire_hud.xml", crafting_station = true, shop = true },
    QUAGMIRE_TRADER_KID =   { str = "QUAGMIRE_TRADER_KID",   sort = 0, icon = "tab_quagmire_trader_kid.tex",   icon_atlas = "images/quagmire_hud.xml", crafting_station = true, shop = true },
}

VERBOSITY =
{
	ERROR = 0,
	WARNING = 1,
	INFO = 2,
	DEBUG = 3,
}

RENDERPASS =
{
	Z = 0,
	BLOOM = 1,
	DEFAULT = 2,
}

NUM_TRINKETS = 46
HALLOWEDNIGHTS_TINKET_START = 32
HALLOWEDNIGHTS_TINKET_END = 46

SEASONS =
{
	AUTUMN = "autumn",
	WINTER = "winter",
	SPRING = "spring",
	SUMMER = "summer",
	CAVES = "caves",
}

LEVELCATEGORY = {
    LEVEL = "LEVEL",
    SETTINGS = "SETTINGS",
    COMBINED = "COMBINED",
    WORLDGEN = "WORLDGEN",
}

RENDER_QUALITY =
{
	LOW = 0,
	DEFAULT = 1,
	HIGH = 2,
}

ANIM_SORT_ORDER =
{
	OCEAN_UNDERWATER = 0,
	OCEAN_WAVES = 1,
	OCEAN_BOAT = 2,
	OCEAN_SKYSHADOWS = 3,
}

ANIM_SORT_ORDER_BELOW_GROUND =
{
    UNDERWATER = 0,
    BOAT_TRAIL = 1,
    BOAT_LIP = 2,
    UNUSED = 3,
}

ROAD_PARAMETERS =
{
	NUM_SUBDIVISIONS_PER_SEGMENT = 50,
	MIN_WIDTH = 2,
	MAX_WIDTH = 3,
	MIN_EDGE_WIDTH = 0.5,
	MAX_EDGE_WIDTH = 1,
	WIDTH_JITTER_SCALE=1,
}

local function RGB(r, g, b)
    return { r / 255, g / 255, b / 255, 1 }
end

BGCOLOURS =
{
	RED =          RGB(255, 89,  46 ),
	PURPLE =       RGB(184, 87,  198),
	YELLOW =       RGB(255, 196, 45 ),
	GREY =         RGB(75,  75,  75 ),
	HALF =         RGB(128, 128, 128 ),
	FULL =         RGB(255, 255, 255),
}

-- Standard html colours: https://en.wikipedia.org/wiki/Web_colors#X11_color_names
WEBCOLOURS =
{
    -- pinks
    PINK           = RGB(255, 192, 203),
    PALEVIOLETRED  = RGB(219, 112, 147),
    -- reds
    SALMON         = RGB(250, 128, 114),
    CRIMSON        = RGB(220, 20, 60),
    FIREBRICK      = RGB(178, 34, 34),
    DARKRED        = RGB(139, 0, 0),
    RED            = RGB(255, 0, 0),
    -- oranges
    TOMATO         = RGB(255, 99, 71),
    CORAL          = RGB(255, 127, 80),
    ORANGE         = RGB(255, 165, 0),
    -- yellows
    YELLOW         = RGB(255, 255, 0),
    KHAKI          = RGB(240, 230, 140),
    -- browns
    BISQUE         = RGB(255, 228, 196),
    BURLYWOOD      = RGB(222, 184, 135),
    TAN            = RGB(210, 180, 140),
    ROSYBROWN      = RGB(188, 143, 143),
    SANDYBROWN     = RGB(244, 164, 96),
    GOLDENROD      = RGB(218, 165, 32),
    PERU           = RGB(205, 133, 63),
    CHOCOLATE      = RGB(210, 105, 30),
    SADDLEBROWN    = RGB(139, 69, 19),
    BROWN          = RGB(165, 42, 42),
    -- greens
    GREEN          = RGB(0, 128, 0),
    SPRINGGREEN    = RGB( 0, 255, 127),
    -- cyans
    TURQUOISE      = RGB(64, 224, 208),
    TEAL           = RGB(0, 128, 128),
    -- blues
    LIGHTSKYBLUE   = RGB(135, 206, 250),
    CORNFLOWERBLUE = RGB(100, 149, 237),
    BLUE           = RGB(0, 0, 255),
    -- purples
    LAVENDER       = RGB(230, 230, 250),
    THISTLE        = RGB(216, 191, 216),
    PLUM           = RGB(221, 160, 221),
    MEDIUMPURPLE   = RGB(147, 112, 219),
    PURPLE         = RGB(128, 0, 128),
}

-- A limited palette of colours to match our world tones.
-- Don't reference these from code! The names don't match the colour.
PLAYERCOLOURS =
{
	BLUE =          RGB(149, 191, 242),
	--RED =           RGB(242, 99,  99 ), --RED redefined below
	YELLOW =        RGB(222, 222, 99 ),
	GREEN =         RGB(59,  222, 99 ),
	CORAL =         RGB(216, 60,  84 ),
	GRASS =         RGB(129, 168, 99 ),
	TEAL =          RGB(150, 206, 169),
	LAVENDER =      RGB(206, 145, 192),
	OTHERBLUE =     RGB(113, 125, 194),
	OTHERYELLOW =   RGB(205, 191, 121),
	FUSCHIA =       RGB(170, 85,  129),
	OTHERTEAL =     RGB(150, 201, 206),
	LIGHTORANGE =   RGB(206, 150, 100),
	ORANGE =        RGB(208, 120, 86 ),
	PURPLE =        RGB(125, 81,  156),

    --Colour theme to better match the world tones
    --(So these colour names don't match standard web colours).
    TOMATO =        RGB(205, 79,  57 ),
    TAN =           RGB(255, 165, 79 ),
    PLUM =          RGB(205, 150, 205),
    BURLYWOOD =     RGB(205, 170, 125),
    RED =           RGB(238, 99,  99 ),
    PERU =          RGB(205, 133, 63 ),
    DARKPLUM =      RGB(139, 102, 139),
    EGGSHELL =      RGB(252, 230, 201),
    SALMON =        RGB(255, 140, 105),
    CHOCOLATE =     RGB(255, 127, 36 ),
    VIOLETRED =     RGB(139, 71,  93 ),
    SANDYBROWN =    RGB(244, 164, 96 ),
    BROWN =         RGB(165, 42,  42 ),
    BISQUE =        RGB(205, 183, 158),
    PALEVIOLETRED = RGB(255, 130, 171),
    GOLDENROD =     RGB(255, 193, 37 ),
    ROSYBROWN =     RGB(255, 193, 193),
    LIGHTTHISTLE =  RGB(255, 225, 255),
    PINK =          RGB(255, 192, 203),
    LEMON =         RGB(255, 250, 205),
    FIREBRICK =     RGB(238, 44,  44 ),
    LIGHTGOLD =     RGB(255, 236, 139),
    MEDIUMPURPLE =  RGB(171, 130, 255),
    THISTLE =       RGB(205, 181, 205),
}
DEFAULT_PLAYER_COLOUR = RGB(153, 153, 153) -- GREY

SAY_COLOR =         RGB(255, 255, 255)
WHISPER_COLOR =     RGB(153, 153, 153)
TWITCH_COLOR  =     RGB(153, 153, 255)

WET_TEXT_COLOUR = RGB(149, 191, 242)
NORMAL_TEXT_COLOUR = RGB(255, 255, 255)

FRONTEND_PORTAL_COLOUR = {245/255, 232/255, 204/255, 255/255}
--FRONTEND_TREE_COLOUR = {208/255, 196/255, 187/255, 255/255} --V2C: baked into the art now
FRONTEND_CHARACTER_CLOSE_COLOUR = {235/255, 225/255, 212/255, 255/255}
FRONTEND_CHARACTER_FAR_COLOUR = {225/255, 216/255, 206/255, 255/255}
FRONTEND_SMOKE_COLOUR = {245/255, 232/255, 204/255, 153/255}
FRONTEND_TITLE_COLOUR = {235/255, 225/255, 212/255, 255/255}
PORTAL_TEXT_COLOUR = {243/255, 244/255, 243/255, 255/255}
FADE_WHITE_COLOUR = {237/255, 224/255, 189/255, 255/255}


CHARACTER_COLOURS =
{
    wilson       = WEBCOLOURS.ORANGE,
    willow       = WEBCOLOURS.TOMATO,
    wendy        = WEBCOLOURS.KHAKI,
    wolfgang     = WEBCOLOURS.LIGHTSKYBLUE,
    woodie       = WEBCOLOURS.SADDLEBROWN,
    wickerbottom = WEBCOLOURS.MEDIUMPURPLE,
    wx78         = WEBCOLOURS.PERU,
    wes          = WEBCOLOURS.TEAL,
    waxwell      = WEBCOLOURS.SALMON,
    wathgrithr   = WEBCOLOURS.OTHERBLUE,
    webber       = WEBCOLOURS.SPRINGGREEN,
    winona       = WEBCOLOURS.CRIMSON,
    warly        = WEBCOLOURS.RED, --TODO
    --DLC chars:
    wortox       = WEBCOLOURS.RED, --VITO do something here
    wormwood     = WEBCOLOURS.RED, --VITO do something here
    wurt         = WEBCOLOURS.RED, --VITO do something here
    walter       = WEBCOLOURS.RED, --VITO do something here
    wanda        = WEBCOLOURS.RED, --VITO do something here
    --
    default      = WEBCOLOURS.THISTLE,
}


ANNOUNCEMENT_ICONS =
{
    ["default"] =           { atlas = "images/button_icons.xml", texture = "announcement.tex" },
    ["afk_start"] =         { atlas = "images/button_icons.xml", texture = "AFKstart.tex" },
    ["afk_stop"] =          { atlas = "images/button_icons.xml", texture = "AFKstop.tex" },
    ["death"] =             { atlas = "images/button_icons.xml", texture = "death.tex" },
    ["resurrect"] =         { atlas = "images/button_icons.xml", texture = "resurrect.tex" },
    ["join_game"] =         { atlas = "images/button_icons.xml", texture = "join.tex" },
    ["leave_game"] =        { atlas = "images/button_icons.xml", texture = "leave.tex" },
    ["kicked_from_game"] =  { atlas = "images/button_icons.xml", texture = "kicked.tex" },
    ["banned_from_game"] =  { atlas = "images/button_icons.xml", texture = "banned.tex" },
    ["item_drop"] =         { atlas = "images/button_icons.xml", texture = "item_drop.tex" },
    ["vote"] =              { atlas = "images/button_icons.xml", texture = "vote.tex" },
    ["dice_roll"] =         { atlas = "images/button_icons.xml", texture = "diceroll.tex" },
    ["mod"] =               { atlas = "images/button_icons.xml", texture = "mod_announcement.tex" },
}

ROAD_STRIPS =
{
	CORNERS = 0,
	ENDS = 1,
	EDGES = 2,
	CENTER = 3,
}

WRAP_MODE =
{
	WRAP = 0,
	CLAMP = 1,
	MIRROR = 2,
	CLAMP_TO_EDGE = 3,
}

FILTER_MODE =
{
    POINT = 0,
	LINEAR = 1,
	ANISOTROPIC = 2,
    NONE = 3,
}

MIP_FILTER_MODE =
{
    NONE = 0,
    POINT = 1,
    LINEAR = 2,
}

SamplerEffectBase = {
    PostProcessSampler = 0,
    BloomSampler = 1,
    Shader = 2,
    Texture = 3,
    Smoke = 4,
}

SamplerSizes = {
    Relative = 0,
    Static = 1,
}

SamplerColourMode = {
    RGBA = 0,
    RGB = 1,
}

TexSamplers = {}
UniformVariables = {}
SamplerEffects = {}
PostProcessorEffects = {}

RESET_ACTION =
{
	LOAD_FRONTEND = 0,
	LOAD_SLOT = 1,
	LOAD_FILE = 2,
	DO_DEMO = 3,
    JOIN_SERVER = 4
}

ShadeTypes = {}

HUD_ATLAS = "images/hud.xml"
UI_ATLAS = "images/ui.xml"
CRAFTING_ATLAS = "images/crafting_menu.xml"
CRAFTING_ICONS_ATLAS = "images/crafting_menu_icons.xml"

SNOW_THRESH = .015

VIBRATION_CAMERA_SHAKE = 0
VIBRATION_BLOOD_FLASH = 1
VIBRATION_BLOOD_OVER = 2

NUM_SKIN_PRESET_SLOTS = 25

--Neither of these are used anymore, kept here only for mods.
NUM_SAVE_SLOTS = 5
NUM_DST_SAVE_SLOTS = NUM_SAVE_SLOTS

SAVELOAD =
{
    OPERATION =
    {
        PREPARE = 0,
        LOAD = 1,
        SAVE = 2,
        DELETE = 3,
        NONE = 4,
    },

    STATUS =
    {
        OK = 0,
        DAMAGED = 1,
        NOT_FOUND = 2,
        NO_SPACE = 3,
        FAILED = 4,
    },
}

--Extended for DST

MATERIALS =
{
    WOOD = "wood",
    STONE = "stone",
    HAY = "hay",
    THULECITE = "thulecite",
    GEM = "gem",
    GEARS = "gears",
    MOONROCK = "moonrock",
    ICE = "ice",
    SCULPTURE = "sculpture",
    FOSSIL = "fossil",
    MOON_ALTAR = "moon_altar",
}

UPGRADETYPES =
{
    DEFAULT = "default",
    SPIDER = "spider",
    WATERPLANT = "waterplant",
    MAST = "mast",
}

LOCKTYPE =
{
    DOOR = "door",
    MAXWELL = "maxwell",
}

FUELTYPE =
{
    BURNABLE = "BURNABLE",
    USAGE = "USAGE",
    MAGIC = "MAGIC", --V2C: use this one if u don't want there to be any associated fuel
    CAVE = "CAVE",
    NIGHTMARE = "NIGHTMARE",
    ONEMANBAND = "ONEMANBAND",
    PIGTORCH = "PIGTORCH",
    CHEMICAL = "CHEMICAL",
    WORMLIGHT = "WORMLIGHT",
}

OCCUPANTTYPE =
{
    BIRD = "bird",
}

FOODTYPE =
{
    GENERIC = "GENERIC",
    MEAT = "MEAT",
    VEGGIE = "VEGGIE",
    ELEMENTAL = "ELEMENTAL",
    GEARS = "GEARS",
    HORRIBLE = "HORRIBLE",
    INSECT = "INSECT",
    SEEDS = "SEEDS",
    BERRY = "BERRY", --hack for smallbird; berries are actually part of veggie
    RAW = "RAW", -- things which some animals can eat off the ground, but players need to cook
    BURNT = "BURNT", --For lavae.
    ROUGHAGE = "ROUGHAGE",
	WOOD = "WOOD",
    GOODIES = "GOODIES",
    MONSTER = "MONSTER", -- Added in for woby, uses the secondary foodype originally added for the berries
}

FOODGROUP =
{
    OMNI =
    {
        name = "OMNI",
        types =
        {
            FOODTYPE.MEAT,
            FOODTYPE.VEGGIE,
            FOODTYPE.INSECT,
            FOODTYPE.SEEDS,
            FOODTYPE.GENERIC,
            FOODTYPE.GOODIES,
        },
    },

    BERRIES_AND_SEEDS =
    {
        name = "BERRIES_AND_SEEDS",
        types =
        {
            FOODTYPE.SEEDS,
            FOODTYPE.BERRY,
        },
    },

    BEARGER =
    {
        name = "BEARGER",
        types =
        {
            FOODTYPE.MEAT,
            FOODTYPE.VEGGIE,
            FOODTYPE.BERRY,
            FOODTYPE.GENERIC,
        },
    },

    MOOSE =
    {
        name = "MOOSE",
        types =
        {
            FOODTYPE.MEAT,
            FOODTYPE.VEGGIE,
            FOODTYPE.SEEDS,
        },
    },

    VEGETARIAN =
    {
        name = "VEGETARIAN",
        types =
        {
            FOODTYPE.VEGGIE,
            FOODTYPE.SEEDS,
            FOODTYPE.GENERIC,
            FOODTYPE.GOODIES,
        },
    },
}

FARM_PLANT_STRESS = {
	NONE = 1,
	LOW = 2,
	MODERATE = 3,
	HIGH = 4,
}

CHARACTER_INGREDIENT =
{
    --NOTE: Value is used as key for NAME string and inventory image
    HEALTH = "decrease_health",
    MAX_HEALTH = "half_health",
    SANITY = "decrease_sanity",
    MAX_SANITY = "half_sanity",
	OLDAGE = "decrease_oldage",
}

--Character ingredient amounts must be multiples of 5
CHARACTER_INGREDIENT_SEG = 5

TECH_INGREDIENT =
{
    --NOTE: Value is used as key for NAME string and inventory image
    --NOTE: Must be name of the tech + "_material"
    SCULPTING = "sculpting_material",
}

-- IngredientMod must be one of the following values
INGREDIENT_MOD_LOOKUP =
{
    [0] = 0,
    [1] = 0.25,
    [2] = 0.5,
    [3] = 0.75,
    [4] = 1.0,
}
INGREDIENT_MOD = table.invert(INGREDIENT_MOD_LOOKUP)

CONTAINERTEST =
{
    NONE = 0,
    COOKING = 1,
    PERISHABLE_FOOD = 2,
    TELEPORTATO = 3,
}

TOOLACTIONS =
{
    CHOP = true,
    DIG = true,
    HAMMER = true,
    MINE = true,
    NET = true,
    PLAY = true,
    UNSADDLE = true,
	REACH_HIGH = true,
}

-- this is a net_tinybyte on inventoryitem_classified.deploymode
DEPLOYMODE =
{
    NONE = 0,
    DEFAULT = 1,
    ANYWHERE = 2,
    TURF = 3,
    PLANT = 4,
    WALL = 5,
    WATER = 6,
    MAST = 7,-- Keeping MAST around for mod support
    CUSTOM = 7,
}

BUILDMODE =
{
    NONE = 0,
    LAND = 1,
    WATER = 2
}

-- Max value of 7 (net_tinybyte)
DEPLOYSPACING =
{
    DEFAULT = 0,
    MEDIUM = 1,
    LESS = 2,
    NONE = 3,
	PLACER_DEFAULT = 4,
    LARGE = 5,
}

DEPLOYSPACING_RADIUS =
{
    [DEPLOYSPACING.DEFAULT] = 2,
    [DEPLOYSPACING.MEDIUM] = 1,
    [DEPLOYSPACING.LESS] = .75,
    [DEPLOYSPACING.NONE] = 0,
	[DEPLOYSPACING.PLACER_DEFAULT] = 3.2,
    [DEPLOYSPACING.LARGE] = 4.0,
}

TROPHYSCALE_TYPES =
{
    FISH = "fish",
    OVERSIZEDVEGGIES = "oversizedveggies",
}

NAUGHTY_VALUE =
{
    ["pigman"] = 3,
    ["babybeefalo"] = 6,
    ["teenbird"] = 2,
    ["smallbird"] = 6,
    ["beefalo"] = 4,
    ["deer"] = 4,
    ["crow"] = 1,
    ["robin"] = 2,
    ["robin_winter"] = 2,
    ["canary"] = 2,
    ["butterfly"] = 1,
    ["moonbutterfly"] = 1,
    ["rabbit"] = 1,
    ["mole"] = 1,
    ["tallbird"] = 2,
    ["bunnyman"] = 3,
    ["penguin"] = 2,
    ["glommer"] = 50, -- You've been bad!
    ["catcoon"] = 5,
    ["lightflier"] = 1,
    ["dustmoth"] = 4,
    ["friendlyfruitfly"] = 20,
}

DONT_STARVE_TOGETHER_APPID = 322330
DONT_STARVE_APPID = 219740
REIGN_OF_GIANTS_APPID = 282470

-- keeping this here in case someone wants to mod it in. It won't be a default part of the game (or even an option), but we've already done the work
-- and someone might be able to do something cool with it.
HUMAN_MEAT_ENABLED = false

SWIPE_FADE_TIME = .4
SCREEN_FADE_TIME = .2
-- Use TEMPLATES.BackButton instead of BACK_BUTTON_X/Y
BACK_BUTTON_X = 60
BACK_BUTTON_Y = 60
DOUBLE_CLICK_TIMEOUT = .5

GOLD = {202/255, 174/255, 118/255, 255/255}
GREY = {.57, .57, .57, 1}
BLACK = {.1, .1, .1, 1}
WHITE = {1, 1, 1, 1}
BROWN = {97/255, 73/255, 46/255, 255/255}
RED = {.7, .1, .1, 1}
DARKGREY = {.12, .12, .12, 1}

-- A coherent palette for UI elements
UICOLOURS = {
    GOLD_CLICKABLE = RGB(215, 210, 157), -- interactive text & menu
    GOLD_FOCUS = RGB(251, 193, 92), -- menu active item
    GOLD_SELECTED = RGB(245, 243, 222), -- titles and non-interactive important text
    GOLD_UNIMPORTANT = RGB(213, 213, 203), -- non-interactive non-important text
    HIGHLIGHT_GOLD = RGB(243, 217, 161),
    GOLD = GOLD,
    BROWN_MEDIUM = RGB(107, 84, 58),
    BROWN_DARK = RGB(80, 61, 39),
    BLUE = RGB(80, 143, 244),
    GREY = GREY,
    BLACK = BLACK,
    WHITE = WHITE,
    BRONZE = RGB(180, 116, 36, 1),
    EGGSHELL = RGB(252, 230, 201),
    IVORY = RGB(236, 232, 223, 1),
    IVORY_70 = RGB(165, 162, 156, 1),
    PURPLE = RGB(152, 86, 232, 1),
    RED = RGB(207, 61, 61, 1),
    SLATE = RGB(155, 170, 177, 1),
	SILVER = RGB(192, 192, 192, 1),
}

PLANTREGISTRYUICOLOURS = {
    LOCKEDBROWN = RGB(76, 50, 34, 1),
    UNLOCKEDBROWN = RGB(76, 50, 34, 1), --UICOLOURS.EGGSHELL,
}


MAX_CHAT_INPUT_LENGTH = 150
MAX_WRITEABLE_LENGTH = 200

--Bit flags, currently supports up to 8
--Server may use these for things that clients need to know about
--other clients whose player entities may or may not be available
--e.g. Stuff that shows on the scoreboard
-- NOTE: Keep this up to date with USERFLAGS::Enum in PlayerListingData.h
USERFLAGS =
{
    IS_GHOST			= 1,
    IS_AFK				= 2,
    CHARACTER_STATE_1	= 4,
    CHARACTER_STATE_2	= 8,
    IS_LOADING			= 16,
    CHARACTER_STATE_3   = 32,
    -- = 64,
    -- = 128,
}

--Camera shake modes
CAMERASHAKE =
{
    FULL = 0,
    SIDE = 1,
    VERTICAL = 2,
}

--Badge/meter arrow sizes
RATE_SCALE =
{
    NEUTRAL = 0,
    INCREASE_HIGH = 1,
    INCREASE_MED = 2,
    INCREASE_LOW = 3,
    DECREASE_HIGH = 4,
    DECREASE_MED = 5,
    DECREASE_LOW = 6,
}

-- Twitch status codes
TWITCH =
{
    UNDEFINED = -1,
    CHAT_CONNECTED = 0,
    CHAT_DISCONNECTED = 1,
    CHAT_CONNECT_FAILED = 2,
}

-- TeamAttacker orders
ORDERS =
{
    NONE = 0,
    HOLD = 1,
    WARN = 2,
    ATTACK = 3,
}

-- How does this creature apply stunlock to the player
PLAYERSTUNLOCK =
{
    ALWAYS = nil,--0,
    OFTEN = 1,
    SOMETIMES = 2,
    RARELY = 3,
    NEVER = 4,
}

-- Which wormhole?
WORMHOLETYPE =
{
    WORM = 0,
    TENTAPILLAR = 1,
}

-- Houndwarning level
HOUNDWARNINGTYPE =
{
    LVL1 = 0,
    LVL2 = 1,
    LVL3 = 2,
    LVL4 = 3,
    LVL1_WORM = 4,
    LVL2_WORM = 5,
    LVL3_WORM = 6,
    LVL4_WORM = 7,
}

-- Domestication tendencies
TENDENCY =
{
    DEFAULT = "DEFAULT",
    ORNERY = "ORNERY",
    RIDER = "RIDER",
    PUDGY = "PUDGY",
}

REMOTESHARDSTATE =
{
    OFFLINE = 0,
    READY = 1,
}

SHARDID =
{
    INVALID = "0",
    MASTER = "1"
}

-- Server pricacy options
PRIVACY_TYPE =
{
    PUBLIC = 0,
    FRIENDS = 1,
    LOCAL = 2,
    CLAN = 3,
}

INTENTIONS =
{
    SOCIAL = "social",
    COOPERATIVE = "cooperative",
    COMPETITIVE = "competitive",
    MADNESS = "madness",
    ANY = "any", -- for player use only, servers must have an intention
}

LEVELTYPE = {
    SURVIVAL = "SURVIVAL",
    CAVE = "CAVE",
    ADVENTURE = "ADVENTURE",
    LAVAARENA = "LAVAARENA",
    QUAGMIRE = "QUAGMIRE",
    TEST = "TEST",
    UNKNOWN = "UNKNOWN",
    CUSTOM = "CUSTOM",
    CUSTOMPRESET = "CUSTOMPRESET",
}

if BRANCH == "dev" then
    SERVER_LEVEL_LOCATIONS =
    {
        "forest",
        "cave",
    }
else
    SERVER_LEVEL_LOCATIONS =
    {
        "forest",
        "cave",
    }
end
assert(BRANCH == "dev" or SERVER_LEVEL_LOCATIONS[1] == "forest", "Invalid server start level location.")

EVENTSERVER_LEVEL_LOCATIONS =
{
	[LEVELTYPE.LAVAARENA] = { "lavaarena" },
	[LEVELTYPE.QUAGMIRE] = { "quagmire" },
}

DEFAULT_LOCATION = "forest"

SERVER_LEVEL_SHARDS =
{
    "Master",
    "Caves",
}

SERVER_LEVEL_CONFIGS =
{
	forest = {
		standalone = true,
	},
	cave = {
		standalone = false,
		shard_link = true,
	},
}

-- Mirrors constant from CloudSaves.h
CLOUD_SAVES_SAVE_OFFSET = 100000

COMMAND_PERMISSION = {
    ADMIN = "ADMIN", -- only admins see and can activate
    MODERATOR = "MODERATOR", -- only admins and mods can see and activate
    USER = "USER", -- anyone can see and do instantly. Mostly for local commands, or if a mod wants to offer accessible functionality
}

COMMAND_RESULT = {
    ALLOW = "ALLOW",
    DISABLED = "DISABLED", --cannot run it right now (not related to voting)
    VOTE = "VOTE",
    DENY = "DENY", --cannot start vote right now
    INVALID = "INVALID",
}

CARRAT_MUSIC_STATES = {
    NONE = 0,
    TRAINING = 1,
    RACE = 2,
}

LOCALPLAYER_MUSIC = {
    NONE = 0,
    WINTERS_FEAST = 1,
}

MAX_VOTE_OPTIONS = 6

USER_HISTORY_EXPIRY_TIME = 60*60*24*30 -- 30 days

-- Mirrors enum in SystemService.h
LANGUAGE =
{
    ENGLISH = 0,
    ENGLISH_UK = 1,
    FRENCH = 2,
    FRENCH_CA = 3,
    SPANISH = 4,
    SPANISH_LA = 5,
    GERMAN = 6,
    ITALIAN = 7,
    PORTUGUESE = 8,
    PORTUGUESE_BR = 9,
    DUTCH = 10,
    FINNISH = 11,
    SWEDISH = 12,
    DANISH = 13,
    NORWEGIAN = 14,
    POLISH = 15,
    RUSSIAN = 16,
    TURKISH = 17,
    ARABIC = 18,
    KOREAN = 19,
    JAPANESE = 20,
    CHINESE_T = 21,
    CHINESE_S = 22,
    CHINESE_S_RAIL = 23,
}

LANGUAGE_STEAMCODE_TO_ID =
{
    brazilian = LANGUAGE.PORTUGUESE_BR,
    bulgarian = nil,
    czech = nil,
    danish = LANGUAGE.DANISH,
    dutch = LANGUAGE.DUTCH,
    english = LANGUAGE.ENGLISH,
    finnish = LANGUAGE.FINNISH,
    french = LANGUAGE.FRENCH,
    german = LANGUAGE.GERMAN,
    greek = nil,
    hungarian = nil,
    italian = LANGUAGE.ITALIAN,
    japanese = LANGUAGE.JAPANESE,
    korean = LANGUAGE.KOREAN,
    norwegian = LANGUAGE.NORWEGIAN,
    polish = LANGUAGE.POLISH,
    portuguese = LANGUAGE.PORTUGUESE,
    romanian = nil,
    russian = LANGUAGE.RUSSIAN,
    schinese = LANGUAGE.CHINESE_S,
    spanish = LANGUAGE.SPANISH,
    swedish = LANGUAGE.SWEDISH,
    tchinese = LANGUAGE.CHINESE_T,
    thai = nil,
    turkish = LANGUAGE.TURKISH,
    ukrainian = nil,
}

QUAGMIRE_NUM_FOOD_PREFABS = 69
QUAGMIRE_NUM_SEEDS_PREFABS = 7
QUAGMIRE_USE_KLUMP = false

OCEAN_MAPWRAPPER_WARN_RANGE = 14
OCEAN_POPULATION_EDGE_DIST = 4
OCEAN_WATERFALL_MAX_DIST = 14

-- needs to be kept synchronized with InventoryProgress enum in InventoryManager.h
INVENTORY_PROGRESS =
{
	IDLE = 0,
	CHECK_SHOP = 1,
	CHECK_EVENT = 2,
	CHECK_DLC = 3,
	CHECK_DAILY_GIFT = 4,
	CHECK_KEYVALUESTORES = 5,
	CHECK_INVENTORY = 6,
}

CURRENT_BETA = 1 -- set to 0 if there is no beta. Note: release builds wont use this so only staging and dev really care
BETA_INFO =
{
    {
		NAME = "UPDATEBETA",
		SERVERTAG = "public_update_beta",
		VERSION_MISMATCH_STRING = "VERSION_MISMATCH_UPDATEBETA",
		URL = "https://forums.kleientertainment.com/forums/topic/106156-how-to-opt-in-to-return-of-them-beta-for-dont-starve-together/",
	},

    {
		NAME = "ROTBETA",
		SERVERTAG = "return_of_them_beta",
		VERSION_MISMATCH_STRING = "VERSION_MISMATCH_ROTBETA",
		URL = "https://forums.kleientertainment.com/forums/topic/106156-how-to-opt-in-to-return-of-them-beta-for-dont-starve-together/ ",
	},

    {
		NAME = "ANRBETA",
		SERVERTAG = "a_new_reign_beta",
		VERSION_MISMATCH_STRING = "VERSION_MISMATCH_ARNBETA",
		URL = "http://forums.kleientertainment.com/topic/69487-how-to-opt-in-to-a-new-reign-beta-for-dont-starve-together/",
	},

	-- THE GENERIC PUBLIC BETA INFO MUST BE LAST --
	-- This is added to all beta servers as a fallback
	{
		NAME = "PUBLIC_BETA",
		SERVERTAG = "public_beta",
		VERSION_MISMATCH_STRING = "VERSION_MISMATCH_PUBLIC_BETA",
		URL = "http://forums.kleientertainment.com/forum/66-dont-starve-together-general-discussion/",
	},
}
PUBLIC_BETA = #BETA_INFO

TEMP_ITEM_ID = "0"

--matches enum eIAPType
IAP_TYPE_REAL = 0
IAP_TYPE_VIRTUAL = 1

--matches enum ETextFilteringContext
TEXT_FILTER_CTX_UNKNOWN = 0
TEXT_FILTER_CTX_GAME = 1
TEXT_FILTER_CTX_CHAT = 2
TEXT_FILTER_CTX_NAME = 3
TEXT_FILTER_CTX_SERVERNAME = 0 -- not sure how we want to handle this


CHARACTER_BUTTON_OFFSET =
{
    wilson = -51,
    wendy = -45,
    waxwell = -45,
    wortox = -53,
    wormwood = -53,
    winona = -49,
    wurt = -45,
    webber = -45,
    wanda = -51,

    default = -47,
}

CHARACTER_BUTTON_SCALE =
{
    wurt = 0.24,

    default = 0.23,
}

YOTB_COSTUMES =
{
    WAR         = 1,
    DOLL        = 2,
    ROBOT       = 4,
    NATURE      = 8,
    FORMAL      = 16,
    VICTORIAN   = 32,
    ICE         = 64,
    FESTIVE     = 128,
    BEAST       = 256,
}

SKIN_TYPES_THAT_RECEIVE_CLOTHING =
{
    "normal_skin",
	"wimpy_skin",
    "mighty_skin",
	"stage_2",
    "stage_3",
    "stage_4",
	"young_skin",
	"old_skin",
	"powerup",
	"NO_BASE",
}

STORM_TYPES =
{
    NONE = 0,
    SANDSTORM = 1,
    MOONSTORM = 2,
}

LOADING_SCREEN_TIP_OPTIONS = 
{
    ALL = 1,
    TIPS_ONLY = 2,
    LORE_ONLY = 3,
    NONE = 4,
}

LOADING_SCREEN_TIP_CATEGORIES =
{
    CONTROLS = 1,
    SURVIVAL = 2,
    LORE = 3,
    LOADING_SCREEN = 4,
    OTHER = 5,
}

LOADING_SCREEN_TIP_ICONS =
{
    CONTROLS = { atlas = "images/loading_screen_icons.xml", icon = "icon_tooltips.tex" },
    SURVIVAL = { atlas = "images/loading_screen_icons.xml", icon = "icon_survival.tex" },
    LORE = { atlas = "images/loading_screen_icons.xml", icon = "icon_lore.tex" },
    LOADING_SCREEN = { atlas = "images/loading_screen_icons.xml", icon = "icon_lore.tex" },
    OTHER = { atlas = "images/loading_screen_icons.xml", icon = "icon_survival.tex" },
}

LOADING_SCREEN_TIP_CATEGORY_WEIGHTS_START =
{
    CONTROLS = 4,
    SURVIVAL = 3,
    LORE = 1,
    LOADING_SCREEN = 2,
    OTHER = 0,
}

LOADING_SCREEN_TIP_CATEGORY_WEIGHTS_END =
{
    CONTROLS = 0.5,
    SURVIVAL = 2,
    LORE = 4,
    LOADING_SCREEN = 3.5,
    OTHER = 0,
}

LOADING_SCREEN_CONTROL_TIP_KEYS =
{
    TIP_ATTACK = { attack = CONTROL_ATTACK },
    TIP_FORCE_ATTACK = { modifier = CONTROL_FORCE_ATTACK, attack = CONTROL_ATTACK },
    TIP_HOLD_INSPECT = { inspect = CONTROL_FORCE_INSPECT},
    TIP_HOLD_ACTION = { action = CONTROL_ACTION },
    TIP_HOLD_PRIMARY = { primary = CONTROL_ATTACK },
    TIP_HOLD_MOUSE = { primary = CONTROL_PRIMARY },
    TIP_HALF_STACK = { modifier = CONTROL_FORCE_STACK, primary = CONTROL_PRIMARY },
    TIP_DROP_ITEMS = { modifier = CONTROL_FORCE_TRADE, secondary = CONTROL_SECONDARY },
    TIP_ROTATE_CAMERA = { rotateleft = CONTROL_ROTATE_LEFT, rotateright = CONTROL_ROTATE_RIGHT },
    TIP_SHOW_MAP = { map = CONTROL_MAP },
    TIP_INSPECT_SELF = { inspectself = CONTROL_INSPECT_SELF },
    TIP_CHAT = { chat = CONTROL_TOGGLE_SAY, whisper = CONTROL_TOGGLE_WHISPER },
    TIP_PLAYER_STATUS = { playerstatus = CONTROL_SHOW_PLAYER_STATUS },
    TIP_INVENTORY_SLOTS = { inv_0 = CONTROL_INV_10, inv_9 = CONTROL_INV_9 },
}

-- When using a controller or on console, some control IDs are different than on non-console, but use the same tips.
LOADING_SCREEN_CONTROLLER_ID_LOOKUP =
{
    [CONTROL_ATTACK] = CONTROL_CONTROLLER_ATTACK,
    [CONTROL_ACTION] = CONTROL_CONTROLLER_ACTION,
    [CONTROL_FORCE_INSPECT] = CONTROL_INSPECT,
    [CONTROL_SHOW_PLAYER_STATUS] = CONTROL_MENU_MISC_4,
}