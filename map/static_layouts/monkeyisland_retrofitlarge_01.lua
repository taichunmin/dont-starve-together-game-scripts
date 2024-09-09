return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 36,
  height = 36,
  tilewidth = 64,
  tileheight = 64,
  properties = {},
  tilesets = {
    {
      name = "ground",
      firstgid = 1,
      filename = "../../../../tools/tiled/dont_starve/ground.tsx",
      tilewidth = 64,
      tileheight = 64,
      spacing = 0,
      margin = 0,
      image = "../../../../tools/tiled/dont_starve/tiles.png",
      imagewidth = 512,
      imageheight = 512,
      properties = {},
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "BG_TILES",
      x = 0,
      y = 0,
      width = 36,
      height = 36,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 18, 18, 18, 18, 18, 18, 45, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 18, 18, 18, 18, 18, 18, 18, 45, 45, 45, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 18, 18, 18, 18, 18, 18, 18, 18, 45, 45, 45, 18, 18, 18, 18, 18, 18, 18, 45, 18, 18, 18, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 18, 18, 18, 18, 18, 18, 18, 18, 18, 45, 18, 18, 18, 18, 18, 18, 18, 18, 18, 45, 45, 18, 18, 18, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 18, 18, 18, 18, 18, 18, 18, 18, 18, 45, 45, 45, 45, 45, 18, 18, 18, 18, 18, 18, 18, 45, 18, 18, 18, 18, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 18, 18, 18, 18, 18, 18, 45, 18, 18, 18, 18, 18, 18, 18, 45, 18, 18, 45, 18, 18, 18, 18, 45, 45, 18, 18, 18, 18, 0, 0, 0, 0,
        0, 0, 0, 18, 18, 18, 18, 18, 18, 45, 45, 45, 18, 18, 18, 18, 18, 18, 45, 45, 45, 45, 18, 18, 18, 18, 45, 45, 45, 18, 18, 18, 18, 0, 0, 0,
        0, 0, 18, 18, 18, 18, 18, 18, 45, 45, 45, 45, 45, 18, 18, 18, 18, 18, 18, 45, 18, 18, 18, 18, 18, 18, 18, 18, 45, 18, 18, 18, 18, 18, 0, 0,
        0, 18, 18, 18, 18, 18, 18, 18, 18, 45, 45, 45, 18, 18, 18, 45, 45, 45, 18, 45, 18, 18, 45, 45, 45, 45, 18, 18, 45, 18, 18, 18, 18, 18, 18, 0,
        18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 45, 18, 18, 18, 18, 18, 18, 45, 45, 45, 18, 18, 45, 18, 18, 45, 45, 45, 45, 45, 45, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 45, 18, 18, 18, 18, 18, 18, 45, 18, 18, 18, 18, 45, 18, 18, 18, 45, 18, 18, 18, 18, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 45, 18, 18, 18, 45, 45, 45, 45, 18, 18, 18, 45, 45, 45, 18, 18, 45, 45, 18, 18, 18, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 45, 18, 18, 18, 18, 18, 45, 18, 18, 18, 18, 45, 18, 18, 18, 18, 45, 45, 18, 18, 18, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 45, 45, 45, 18, 18, 45, 18, 18, 18, 18, 18, 45, 45, 18, 45, 18, 45, 18, 18, 45, 45, 45, 45, 45, 45, 18, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 45, 45, 45, 18, 18, 45, 45, 18, 18, 18, 18, 45, 45, 45, 45, 45, 45, 18, 18, 45, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 18, 45, 45, 18, 18, 45, 18, 18, 18, 17, 17, 17, 45, 45, 17, 17, 18, 18, 45, 18, 18, 18, 18, 18, 45, 45, 45, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 18, 18, 45, 45, 45, 45, 45, 45, 45, 17, 46, 46, 46, 46, 46, 45, 17, 45, 45, 18, 18, 18, 18, 18, 45, 18, 45, 45, 18, 18,
        18, 18, 18, 18, 45, 18, 18, 18, 45, 18, 18, 18, 18, 17, 45, 46, 46, 46, 46, 46, 46, 46, 45, 45, 18, 18, 18, 18, 18, 18, 45, 18, 45, 45, 18, 18,
        18, 18, 18, 18, 45, 18, 18, 18, 45, 45, 45, 18, 17, 17, 46, 46, 46, 46, 46, 46, 46, 46, 46, 17, 17, 18, 18, 45, 18, 18, 45, 45, 45, 45, 18, 18,
        18, 18, 18, 45, 45, 18, 18, 18, 18, 18, 45, 18, 17, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 45, 45, 18, 45, 18, 18, 45, 45, 45, 18, 18, 18,
        18, 18, 18, 45, 45, 45, 18, 18, 18, 45, 45, 45, 17, 46, 45, 45, 45, 46, 46, 46, 45, 45, 45, 46, 17, 45, 45, 45, 18, 18, 45, 45, 45, 18, 18, 18,
        18, 18, 18, 45, 45, 45, 45, 45, 45, 45, 45, 18, 17, 46, 45, 45, 45, 46, 46, 46, 45, 45, 45, 46, 17, 45, 18, 45, 45, 45, 45, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 18, 18, 18, 45, 18, 18, 17, 46, 45, 45, 45, 46, 46, 46, 45, 45, 45, 46, 17, 45, 18, 45, 18, 18, 45, 45, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 17, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 17, 18, 18, 45, 18, 18, 18, 45, 18, 18, 18, 0,
        0, 18, 18, 18, 18, 18, 18, 18, 45, 45, 45, 45, 45, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 45, 45, 45, 45, 45, 18, 18, 18, 18, 18, 0, 0,
        0, 0, 18, 18, 18, 18, 18, 18, 18, 18, 45, 45, 17, 17, 46, 46, 46, 46, 46, 46, 46, 46, 46, 17, 17, 18, 45, 18, 18, 18, 18, 18, 18, 0, 0, 0,
        0, 0, 0, 18, 18, 18, 18, 18, 18, 18, 18, 45, 18, 18, 17, 46, 46, 46, 46, 46, 46, 46, 17, 18, 18, 18, 45, 18, 18, 18, 18, 18, 0, 0, 0, 0,
        0, 0, 0, 0, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 17, 17, 46, 46, 46, 46, 46, 17, 17, 18, 18, 18, 45, 45, 45, 18, 18, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 17, 45, 46, 45, 46, 45, 17, 18, 18, 18, 18, 18, 18, 18, 18, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 18, 18, 18, 18, 18, 18, 18, 18, 17, 45, 46, 45, 46, 45, 17, 18, 18, 18, 18, 18, 18, 18, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 18, 18, 18, 18, 18, 18, 18, 17, 45, 46, 45, 46, 45, 17, 18, 18, 18, 18, 18, 18, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 18, 18, 18, 18, 18, 18, 17, 45, 17, 45, 17, 45, 17, 18, 18, 18, 18, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 18, 18, 18, 18, 18, 17, 45, 17, 45, 17, 45, 17, 18, 18, 18, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 18, 18, 18, 18, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "monkeyisland_portal",
          shape = "rectangle",
          x = 979,
          y = 1489,
          width = 19,
          height = 23,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "boat_pirate",
          shape = "rectangle",
          x = 800,
          y = 1932,
          width = 19,
          height = 19,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 803,
          y = 1936,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "boat_pirate",
          shape = "rectangle",
          x = 1427,
          y = 2040,
          width = 19,
          height = 19,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1430,
          y = 2044,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "boat",
          shape = "rectangle",
          x = 908,
          y = 2152,
          width = 19,
          height = 19,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 911,
          y = 2156,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1185,
          y = 2013,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 882,
          y = 1708,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "boat_cannon",
          shape = "rectangle",
          x = 541,
          y = 1692,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "270"
          }
        },
        {
          name = "",
          type = "boat_cannon",
          shape = "rectangle",
          x = 349,
          y = 991,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "270"
          }
        },
        {
          name = "",
          type = "boat_cannon",
          shape = "rectangle",
          x = 673,
          y = 865,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "300"
          }
        },
        {
          name = "",
          type = "boat_cannon",
          shape = "rectangle",
          x = 545,
          y = 605,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "330"
          }
        },
        {
          name = "",
          type = "boat_cannon",
          shape = "rectangle",
          x = 1102,
          y = 218,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "0"
          }
        },
        {
          name = "",
          type = "boat_cannon",
          shape = "rectangle",
          x = 1824,
          y = 605,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "45"
          }
        },
        {
          name = "",
          type = "boat_cannon",
          shape = "rectangle",
          x = 1889,
          y = 994,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "100"
          }
        },
        {
          name = "",
          type = "boat_cannon",
          shape = "rectangle",
          x = 2075,
          y = 1122,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "75"
          }
        },
        {
          name = "",
          type = "boat_cannon",
          shape = "rectangle",
          x = 1824,
          y = 1887,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "125"
          }
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 711,
          y = 1707,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 668,
          y = 1495,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 744,
          y = 1167,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 968,
          y = 857,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1245,
          y = 981,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1316,
          y = 553,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1691,
          y = 717,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1491,
          y = 667,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1562,
          y = 988,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1736,
          y = 1413,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1993,
          y = 1447,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1836,
          y = 1697,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1679,
          y = 1889,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "boat_cannon",
          shape = "rectangle",
          x = 226,
          y = 1443,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "270"
          }
        }
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS_DOCKREGISTRATORS",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1056,
          y = 1953,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1058,
          y = 2019,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1056,
          y = 2082,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1058,
          y = 2139,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1053,
          y = 2210,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1186,
          y = 1949,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1183,
          y = 2015,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1185,
          y = 2080,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1185,
          y = 2144,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1187,
          y = 2207,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1311,
          y = 1953,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1313,
          y = 2015,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1311,
          y = 2081,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1312,
          y = 2144,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1313,
          y = 2205,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 928,
          y = 1439,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 928,
          y = 1502,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 929,
          y = 1566,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 991,
          y = 1441,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 989,
          y = 1504,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 990,
          y = 1568,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1055,
          y = 1438,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1057,
          y = 1500,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1056,
          y = 1565,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1311,
          y = 1438,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1314,
          y = 1501,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1315,
          y = 1566,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1377,
          y = 1440,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1374,
          y = 1500,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1376,
          y = 1566,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1436,
          y = 1439,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1442,
          y = 1502,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1439,
          y = 1566,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 802,
          y = 1693,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 928,
          y = 1244,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1183,
          y = 1117,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1249,
          y = 1116,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1371,
          y = 1183,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1439,
          y = 1246,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1568,
          y = 1371,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1567,
          y = 1694,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.undertile"] = "OCEAN_COASTAL_SHORE"
          }
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 736,
          y = 1692,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 673,
          y = 1693,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 605,
          y = 1693,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 544,
          y = 1692,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 672,
          y = 1757,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 736,
          y = 1756,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 736,
          y = 1822,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 606,
          y = 1503,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 674,
          y = 1502,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 607,
          y = 1437,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 670,
          y = 1437,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 735,
          y = 1439,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 671,
          y = 1379,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 543,
          y = 1305,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 608,
          y = 1308,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 671,
          y = 1307,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 542,
          y = 1247,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 540,
          y = 1181,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 611,
          y = 1179,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 672,
          y = 1181,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 735,
          y = 1178,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 799,
          y = 1179,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 861,
          y = 1178,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 931,
          y = 1180,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 479,
          y = 1118,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 544,
          y = 1119,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 738,
          y = 1118,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 479,
          y = 1053,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 671,
          y = 1054,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 735,
          y = 1054,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 479,
          y = 992,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 672,
          y = 988,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 673,
          y = 928,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 671,
          y = 863,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1055,
          y = 1053,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1118,
          y = 1054,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1186,
          y = 1053,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1246,
          y = 1052,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1314,
          y = 1054,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1375,
          y = 1053,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1056,
          y = 986,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1119,
          y = 987,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1248,
          y = 990,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1379,
          y = 989,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1055,
          y = 925,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1376,
          y = 925,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 926,
          y = 863,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 989,
          y = 860,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1056,
          y = 859,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1121,
          y = 856,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1373,
          y = 860,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1440,
          y = 860,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1504,
          y = 859,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1118,
          y = 800,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1440,
          y = 800,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1117,
          y = 735,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1177,
          y = 735,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1248,
          y = 733,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 990,
          y = 667,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1058,
          y = 671,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1120,
          y = 670,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1245,
          y = 670,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1246,
          y = 605,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1248,
          y = 541,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1309,
          y = 539,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1374,
          y = 542,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1377,
          y = 471,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1183,
          y = 538,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1182,
          y = 478,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1183,
          y = 413,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1439,
          y = 673,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1438,
          y = 736,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1503,
          y = 672,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1566,
          y = 673,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1634,
          y = 669,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1825,
          y = 605,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1825,
          y = 672,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1825,
          y = 734,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1760,
          y = 733,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1695,
          y = 734,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1628,
          y = 730,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1700,
          y = 800,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1699,
          y = 863,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1758,
          y = 863,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1695,
          y = 927,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1760,
          y = 931,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1567,
          y = 993,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1626,
          y = 993,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1695,
          y = 993,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1758,
          y = 992,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1823,
          y = 993,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1885,
          y = 990,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1566,
          y = 1057,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1568,
          y = 1118,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1566,
          y = 1180,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1501,
          y = 1181,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1505,
          y = 1248,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1629,
          y = 1377,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1759,
          y = 1312,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1759,
          y = 1374,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1629,
          y = 1439,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1696,
          y = 1440,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1757,
          y = 1439,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1630,
          y = 1504,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1631,
          y = 1566,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1757,
          y = 1503,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1759,
          y = 1565,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1819,
          y = 1501,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1885,
          y = 1502,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1950,
          y = 1503,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1949,
          y = 1435,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1950,
          y = 1376,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 2014,
          y = 1375,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 2078,
          y = 1380,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 2079,
          y = 1441,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 2015,
          y = 1437,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1950,
          y = 1565,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 2014,
          y = 1566,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 2015,
          y = 1633,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1757,
          y = 1630,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1630,
          y = 1695,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1695,
          y = 1693,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1756,
          y = 1692,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1823,
          y = 1695,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1692,
          y = 1757,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1693,
          y = 1823,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1695,
          y = 1888,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1757,
          y = 1884,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1821,
          y = 1883,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1887,
          y = 737,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1952,
          y = 739,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1824,
          y = 545,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1756,
          y = 544,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1694,
          y = 546,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1758,
          y = 482,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1695,
          y = 480,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1696,
          y = 415,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1697,
          y = 354,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1632,
          y = 354,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1632,
          y = 288,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1119,
          y = 417,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1056,
          y = 416,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 991,
          y = 416,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 926,
          y = 416,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 991,
          y = 351,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 991,
          y = 286,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1054,
          y = 290,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1117,
          y = 290,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1121,
          y = 225,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1055,
          y = 229,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 991,
          y = 226,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 991,
          y = 161,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 669,
          y = 481,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 735,
          y = 549,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 671,
          y = 547,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 606,
          y = 547,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 541,
          y = 610,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 605,
          y = 610,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 670,
          y = 610,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 735,
          y = 607,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 800,
          y = 606,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 607,
          y = 675,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 669,
          y = 672,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 736,
          y = 670,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 670,
          y = 739,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 670,
          y = 801,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 415,
          y = 992,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 349,
          y = 995,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 349,
          y = 1056,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 414,
          y = 1055,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 606,
          y = 1569,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 542,
          y = 1508,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 480,
          y = 1505,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 414,
          y = 1505,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 352,
          y = 1505,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 351,
          y = 1441,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 286,
          y = 1441,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 284,
          y = 1377,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 285,
          y = 1314,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 288,
          y = 1250,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 223,
          y = 1375,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 223,
          y = 1440,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 222,
          y = 1505,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 290,
          y = 1506,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1951,
          y = 1121,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 2015,
          y = 1123,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 2078,
          y = 1121,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 2079,
          y = 1186,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 2144,
          y = 1186,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 2141,
          y = 1250,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 2080,
          y = 1249,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 2143,
          y = 1312,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 2079,
          y = 1313,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 2016,
          y = 1312,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1948,
          y = 1311,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1950,
          y = 1250,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1950,
          y = 1185,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS_PORTALDEBRIS",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 1455,
          y = 1269,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 969,
          y = 1287,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 1145,
          y = 1173,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 1069,
          y = 1461,
          width = 19,
          height = 23,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 1053,
          y = 1568,
          width = 19,
          height = 23,
          visible = true,
          properties = {
            ["data.debris_id"] = "1"
          }
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 1006,
          y = 1405,
          width = 19,
          height = 23,
          visible = true,
          properties = {
            ["data.debris_id"] = "2"
          }
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 886,
          y = 1460,
          width = 19,
          height = 23,
          visible = true,
          properties = {
            ["data.debris_id"] = "3"
          }
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 919,
          y = 1552,
          width = 19,
          height = 23,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 1514,
          y = 1634,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 1254,
          y = 2060,
          width = 19,
          height = 23,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 1175,
          y = 1529,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 1099,
          y = 1972,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 1209,
          y = 1655,
          width = 19,
          height = 23,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 1296,
          y = 1843,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 1352,
          y = 1426,
          width = 19,
          height = 23,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 848,
          y = 1364,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 968,
          y = 1743,
          width = 19,
          height = 23,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS_DOCKPOSTS",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1339,
          y = 2171,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1281,
          y = 2216,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1191,
          y = 2234,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1152,
          y = 2170,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1083,
          y = 2129,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1077,
          y = 2233,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1023,
          y = 2216,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 759,
          y = 1842,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 710,
          y = 1796,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 526,
          y = 1715,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 574,
          y = 1668,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 702,
          y = 1668,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 693,
          y = 1520,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 629,
          y = 1522,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 757,
          y = 1418,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 581,
          y = 1416,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 632,
          y = 1282,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 519,
          y = 1332,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 518,
          y = 1154,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 502,
          y = 1076,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 502,
          y = 1015,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 452,
          y = 965,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 641,
          y = 1204,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 637,
          y = 1155,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 708,
          y = 1092,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 644,
          y = 1021,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 696,
          y = 947,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 646,
          y = 837,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 826,
          y = 1156,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 771,
          y = 1204,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1156,
          y = 1094,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1091,
          y = 1077,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1027,
          y = 1026,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 963,
          y = 884,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 901,
          y = 883,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 925,
          y = 836,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1082,
          y = 836,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1143,
          y = 885,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1154,
          y = 754,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1094,
          y = 707,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1019,
          y = 691,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 975,
          y = 645,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1129,
          y = 966,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1222,
          y = 983,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1271,
          y = 1015,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1338,
          y = 1077,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1399,
          y = 1015,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1350,
          y = 963,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1365,
          y = 838,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1495,
          y = 885,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1519,
          y = 835,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1414,
          y = 769,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1468,
          y = 644,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1534,
          y = 694,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1597,
          y = 643,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1800,
          y = 597,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1836,
          y = 757,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1729,
          y = 708,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1718,
          y = 803,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1670,
          y = 845,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1783,
          y = 838,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1783,
          y = 934,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1888,
          y = 965,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1911,
          y = 1012,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1669,
          y = 1014,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1541,
          y = 982,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1591,
          y = 1143,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1647,
          y = 1349,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1605,
          y = 1499,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1653,
          y = 1589,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1668,
          y = 1461,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1783,
          y = 1285,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1784,
          y = 1348,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1888,
          y = 1476,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1941,
          y = 1590,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 2017,
          y = 1539,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 2011,
          y = 1652,
          width = 6,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 2102,
          y = 1457,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 2090,
          y = 1347,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1924,
          y = 1364,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1783,
          y = 1590,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1815,
          y = 1668,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1838,
          y = 1717,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1672,
          y = 1668,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1670,
          y = 1782,
          width = 5,
          height = 4,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1717,
          y = 1797,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1668,
          y = 1858,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1783,
          y = 1909,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1848,
          y = 1872,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1206,
          y = 420,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1158,
          y = 453,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1311,
          y = 516,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1398,
          y = 482,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1270,
          y = 627,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 2166,
          y = 1268,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 2142,
          y = 1156,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 2088,
          y = 1095,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1962,
          y = 1092,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1925,
          y = 1199,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1742,
          y = 563,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1674,
          y = 514,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1771,
          y = 454,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1686,
          y = 323,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1654,
          y = 283,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1604,
          y = 332,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1049,
          y = 436,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 904,
          y = 418,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 966,
          y = 333,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 967,
          y = 227,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1008,
          y = 134,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1040,
          y = 202,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1142,
          y = 210,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1143,
          y = 286,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 586,
          y = 519,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 757,
          y = 518,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 822,
          y = 626,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 524,
          y = 626,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 666,
          y = 456,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 607,
          y = 691,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 728,
          y = 692,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 462,
          y = 1477,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 225,
          y = 1525,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 343,
          y = 1526,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 312,
          y = 1386,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 313,
          y = 1289,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 261,
          y = 1223,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 198,
          y = 1348,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS_MONKEYSTUFF",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "monkeypillar",
          shape = "rectangle",
          x = 1136,
          y = 1376,
          width = 19,
          height = 23,
          visible = true,
          properties = {
            ["data.pillar_id"] = "2"
          }
        },
        {
          name = "",
          type = "monkeyqueen",
          shape = "rectangle",
          x = 1184,
          y = 1264,
          width = 19,
          height = 23,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeypillar",
          shape = "rectangle",
          x = 1296,
          y = 1312,
          width = 19,
          height = 23,
          visible = true,
          properties = {
            ["data.pillar_id"] = "4"
          }
        },
        {
          name = "",
          type = "monkeypillar",
          shape = "rectangle",
          x = 1232,
          y = 1152,
          width = 19,
          height = 23,
          visible = true,
          properties = {
            ["data.pillar_id"] = "1"
          }
        },
        {
          name = "",
          type = "monkeypillar",
          shape = "rectangle",
          x = 1072,
          y = 1216,
          width = 19,
          height = 23,
          visible = true,
          properties = {
            ["data.pillar_id"] = "3"
          }
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 246,
          y = 1394,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 463,
          y = 1052,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 671,
          y = 600,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 1080,
          y = 280,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 1459,
          y = 672,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 1744,
          y = 498,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 1755,
          y = 940,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 2128,
          y = 1200,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 1741,
          y = 1874,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut_area",
          shape = "rectangle",
          x = 1042,
          y = 1934,
          width = 286,
          height = 164,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut_area",
          shape = "rectangle",
          x = 1286,
          y = 1415,
          width = 240,
          height = 176,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 595,
          y = 1676,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS_PLANTS",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "monkeyisland_prefabs",
          shape = "rectangle",
          x = 907,
          y = 1289,
          width = 219,
          height = 113,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_prefabs",
          shape = "rectangle",
          x = 1028,
          y = 1792,
          width = 312,
          height = 124,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_prefabs",
          shape = "rectangle",
          x = 906,
          y = 1608,
          width = 559,
          height = 175,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_prefabs",
          shape = "rectangle",
          x = 1094,
          y = 1413,
          width = 180,
          height = 181,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
