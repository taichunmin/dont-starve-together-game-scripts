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
        0, 0, 0, 0, 0, 0, 0, 0, 0, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 18, 18, 18, 18, 18, 18, 18, 18, 18, 45, 45, 45, 45, 45, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 18, 18, 18, 18, 18, 45, 45, 45, 45, 45, 45, 18, 18, 18, 45, 45, 45, 18, 18, 45, 45, 45, 45, 18, 18, 18, 18, 18, 0, 0, 0, 0,
        0, 0, 0, 18, 18, 18, 18, 18, 18, 18, 45, 18, 18, 18, 45, 18, 18, 18, 18, 45, 45, 18, 18, 18, 18, 45, 45, 18, 18, 18, 18, 18, 18, 0, 0, 0,
        0, 0, 18, 18, 18, 18, 18, 18, 18, 18, 45, 18, 18, 18, 45, 18, 18, 18, 18, 18, 18, 18, 18, 45, 45, 45, 45, 18, 18, 18, 18, 18, 18, 18, 0, 0,
        0, 18, 18, 18, 18, 18, 18, 18, 18, 18, 45, 18, 18, 18, 45, 45, 18, 18, 18, 18, 18, 18, 18, 45, 18, 45, 45, 18, 18, 18, 18, 18, 18, 18, 18, 0,
        18, 18, 18, 18, 18, 18, 18, 18, 18, 45, 45, 18, 18, 18, 18, 45, 45, 18, 45, 45, 45, 18, 18, 45, 18, 45, 45, 18, 18, 18, 18, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 18, 45, 18, 18, 18, 18, 18, 45, 45, 45, 18, 18, 18, 18, 45, 18, 45, 45, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 18, 45, 18, 18, 18, 18, 18, 18, 18, 45, 45, 45, 18, 45, 45, 18, 45, 45, 45, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 18, 45, 18, 18, 18, 18, 45, 45, 45, 45, 18, 18, 18, 45, 18, 18, 45, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 18, 45, 18, 45, 18, 18, 18, 18, 18, 45, 18, 18, 18, 45, 45, 45, 45, 18, 18, 18, 18, 18, 45, 18, 18, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 18, 45, 18, 45, 45, 45, 45, 18, 18, 45, 45, 45, 45, 45, 18, 18, 18, 18, 18, 18, 18, 18, 45, 18, 18, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 18, 45, 18, 45, 18, 18, 45, 18, 18, 45, 45, 17, 45, 17, 17, 17, 18, 18, 18, 45, 45, 45, 45, 18, 18, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 45, 45, 45, 45, 18, 18, 45, 18, 17, 17, 46, 46, 46, 46, 46, 17, 17, 18, 18, 18, 45, 18, 18, 18, 18, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 18, 18, 18, 45, 18, 45, 45, 45, 45, 46, 46, 46, 46, 46, 46, 46, 45, 17, 45, 18, 45, 18, 18, 18, 18, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 18, 18, 18, 45, 18, 18, 17, 17, 46, 46, 46, 46, 46, 46, 46, 46, 46, 45, 45, 18, 45, 45, 45, 18, 18, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 18, 18, 18, 45, 18, 18, 17, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 17, 18, 45, 18, 18, 18, 18, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 45, 45, 45, 45, 45, 45, 18, 17, 46, 45, 45, 45, 46, 46, 46, 45, 45, 45, 46, 17, 45, 45, 18, 18, 18, 18, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 18, 18, 18, 45, 45, 45, 45, 46, 45, 45, 45, 46, 46, 46, 45, 45, 45, 46, 17, 45, 45, 45, 45, 45, 18, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 18, 18, 45, 45, 45, 45, 45, 46, 45, 45, 45, 46, 46, 46, 45, 45, 45, 46, 17, 18, 45, 18, 18, 18, 18, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 18, 18, 45, 18, 18, 18, 45, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 17, 18, 45, 18, 18, 18, 18, 18, 18, 18, 18, 0,
        0, 18, 18, 18, 18, 18, 18, 18, 45, 45, 18, 18, 17, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 45, 45, 45, 18, 18, 18, 18, 18, 18, 18, 0, 0,
        0, 0, 18, 18, 18, 18, 18, 18, 18, 45, 18, 18, 17, 17, 46, 46, 46, 46, 46, 46, 46, 46, 46, 45, 17, 18, 18, 18, 18, 18, 18, 18, 18, 0, 0, 0,
        0, 0, 0, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 17, 17, 46, 46, 46, 46, 46, 46, 46, 17, 45, 45, 45, 45, 18, 18, 18, 18, 18, 0, 0, 0, 0,
        0, 0, 0, 0, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 17, 17, 46, 46, 46, 46, 46, 17, 17, 18, 18, 18, 45, 18, 18, 18, 18, 0, 0, 0, 0, 0,
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
          x = 882,
          y = 1979,
          width = 19,
          height = 19,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 885,
          y = 1983,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "boat_pirate",
          shape = "rectangle",
          x = 1443,
          y = 1933,
          width = 19,
          height = 19,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1446,
          y = 1937,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "boat_pirate",
          shape = "rectangle",
          x = 908,
          y = 2195,
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
          y = 2199,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1186,
          y = 2171,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1379,
          y = 1512,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 992,
          y = 1814,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1176,
          y = 1730,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1585,
          y = 1818,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1686,
          y = 1473,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1827,
          y = 1116,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1441,
          y = 795,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1261,
          y = 969,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1076,
          y = 844,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 989,
          y = 1114,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 806,
          y = 1169,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 486,
          y = 1104,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 583,
          y = 1352,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 624,
          y = 1513,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "boat_cannon",
          shape = "rectangle",
          x = 610,
          y = 1763,
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
          x = 352,
          y = 1437,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "180"
          }
        },
        {
          name = "",
          type = "boat_cannon",
          shape = "rectangle",
          x = 478,
          y = 797,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "110"
          }
        },
        {
          name = "",
          type = "boat_cannon",
          shape = "rectangle",
          x = 796,
          y = 919,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "110"
          }
        },
        {
          name = "",
          type = "boat_cannon",
          shape = "rectangle",
          x = 1166,
          y = 404,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "95"
          }
        },
        {
          name = "",
          type = "boat_cannon",
          shape = "rectangle",
          x = 1667,
          y = 506,
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
          x = 1570,
          y = 861,
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
          x = 1836,
          y = 1070,
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
          x = 1872,
          y = 1519,
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
          x = 1699,
          y = 1891,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "300"
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
          y = 1631,
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
          x = 801,
          y = 1569,
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
          x = 799,
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
          x = 864,
          y = 1248,
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
          x = 925,
          y = 1243,
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
          x = 996,
          y = 1123,
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
          x = 1061,
          y = 1120,
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
          x = 1188,
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
          x = 1441,
          y = 1248,
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
          x = 1508,
          y = 1306,
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
          x = 1569,
          y = 1309,
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
          x = 1570,
          y = 1696,
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
          x = 1504,
          y = 1763,
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
          x = 1504,
          y = 1822,
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
          x = 605,
          y = 1754,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 609,
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
          x = 543,
          y = 1694,
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
          y = 1634,
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
          x = 606,
          y = 1567,
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
          y = 1564,
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
          x = 736,
          y = 1499,
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
          x = 608,
          y = 1500,
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
          x = 606,
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
          x = 541,
          y = 1436,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 476,
          y = 1436,
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
          y = 1436,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 353,
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
          x = 608,
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
          x = 605,
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
          x = 608,
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
          x = 605,
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
          x = 542,
          y = 1183,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 478,
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
          x = 416,
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
          x = 478,
          y = 1059,
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
          y = 998,
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
          x = 608,
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
          x = 607,
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
          x = 669,
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
          x = 735,
          y = 1051,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 802,
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
          x = 797,
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
          x = 799,
          y = 1182,
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
          x = 735,
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
          x = 1246,
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
          x = 1185,
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
          x = 1117,
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
          x = 1052,
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
          x = 989,
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
          x = 991,
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
          x = 992,
          y = 926,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 928,
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
          x = 864,
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
          x = 798,
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
          x = 991,
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
          x = 1057,
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
          x = 1121,
          y = 861,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 993,
          y = 794,
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
          y = 794,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 863,
          y = 798,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 992,
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
          x = 1055,
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
          x = 991,
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
          x = 926,
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
          x = 1185,
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
          x = 1311,
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
          x = 1311,
          y = 796,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1312,
          y = 861,
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
          x = 1247,
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
          x = 1249,
          y = 991,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1312,
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
          x = 1374,
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
          x = 1438,
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
          x = 1439,
          y = 926,
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
          y = 865,
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
          y = 802,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1502,
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
          x = 1564,
          y = 865,
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
          x = 1823,
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
          x = 1823,
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
          x = 1762,
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
          x = 1694,
          y = 1116,
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
          y = 1182,
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
          x = 1696,
          y = 1310,
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
          x = 1822,
          y = 1310,
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
          x = 1696,
          y = 1438,
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
          x = 1887,
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
          x = 1823,
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
          x = 1761,
          y = 1500,
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
          x = 1697,
          y = 1570,
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
          x = 1697,
          y = 1697,
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
          x = 1566,
          y = 1824,
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
          y = 1824,
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
          y = 1824,
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
          x = 1566,
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
          x = 1631,
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
          x = 481,
          y = 926,
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
          y = 861,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 481,
          y = 799,
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
          x = 670,
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
          x = 670,
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
          x = 670,
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
          x = 673,
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
          x = 671,
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
          x = 606,
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
          x = 735,
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
          x = 799,
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
          x = 865,
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
          x = 927,
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
          x = 928,
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
          x = 927,
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
          x = 927,
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
          x = 991,
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
          x = 1055,
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
          x = 1121,
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
          x = 1182,
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
          x = 1183,
          y = 479,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1247,
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
          x = 1311,
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
          x = 1248,
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
          x = 1309,
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
          x = 1503,
          y = 802,
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
          y = 738,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1502,
          y = 674,
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
          x = 1565,
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
          x = 1632,
          y = 608,
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
          y = 674,
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
          x = 1695,
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
          x = 1694,
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
          x = 1695,
          y = 609,
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
          x = 1695,
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
          x = 1631,
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
          x = 1631,
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
          x = 1566,
          y = 479,
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
          y = 483,
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
          x = 1311,
          y = 1166,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 1045,
          y = 1195,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 959,
          y = 1340,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 1040,
          y = 1458,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 1052,
          y = 1530,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.debris_id"] = "1"
          }
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 966,
          y = 1446,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.debris_id"] = "2"
          }
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 1011,
          y = 1601,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.debris_id"] = "3"
          }
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 922,
          y = 1571,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 1409,
          y = 1720,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 1102,
          y = 1973,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 1180,
          y = 1472,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 1218,
          y = 2065,
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
          x = 1362,
          y = 1827,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 1321,
          y = 1438,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 846,
          y = 1629,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 925,
          y = 1765,
          width = 0,
          height = 0,
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
          x = 1338,
          y = 1977,
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
          y = 2092,
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
          x = 1211,
          y = 2127,
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
          x = 1024,
          y = 2075,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1024,
          y = 1960,
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
          x = 582,
          y = 1774,
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
          y = 1698,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 516,
          y = 1657,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 516,
          y = 1584,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 554,
          y = 1542,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 397,
          y = 1459,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 333,
          y = 1459,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 534,
          y = 1413,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 654,
          y = 1413,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 760,
          y = 1478,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 631,
          y = 1327,
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
          y = 1187,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 391,
          y = 1157,
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
          y = 779,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 504,
          y = 1043,
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
          y = 882,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 478,
          y = 964,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 582,
          y = 973,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 630,
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
          x = 707,
          y = 1028,
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
          y = 1032,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 773,
          y = 1176,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 823,
          y = 1110,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 713,
          y = 1266,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 774,
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
          x = 874,
          y = 1221,
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
          x = 967,
          y = 1035,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1015,
          y = 1010,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 943,
          y = 948,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 813,
          y = 946,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 774,
          y = 900,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1080,
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
          x = 1092,
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
          x = 838,
          y = 774,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 886,
          y = 820,
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
          y = 756,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 902,
          y = 690,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1005,
          y = 646,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1080,
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
          x = 1160,
          y = 709,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1336,
          y = 730,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1284,
          y = 801,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1335,
          y = 882,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1220,
          y = 841,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1220,
          y = 949,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1273,
          y = 1068,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1147,
          y = 1027,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1381,
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
          x = 1413,
          y = 792,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1574,
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
          x = 1542,
          y = 1229,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1636,
          y = 1138,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1640,
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
          x = 1845,
          y = 1030,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1797,
          y = 997,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1835,
          y = 1140,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1719,
          y = 1160,
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
          x = 1831,
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
          x = 1722,
          y = 1419,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1621,
          y = 1412,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1612,
          y = 1524,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1768,
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
          x = 1910,
          y = 1513,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1860,
          y = 1474,
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
          y = 1586,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1719,
          y = 1702,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1497,
          y = 1847,
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
          y = 1860,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1681,
          y = 1908,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1720,
          y = 1862,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1719,
          y = 1807,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1657,
          y = 1795,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1548,
          y = 1795,
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
          y = 604,
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
          y = 547,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 608,
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
          x = 582,
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
          x = 760,
          y = 502,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 902,
          y = 438,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 952,
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
          x = 1034,
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
          x = 1094,
          y = 387,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1136,
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
          x = 1258,
          y = 566,
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
          y = 564,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1337,
          y = 471,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1566,
          y = 450,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1479,
          y = 498,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1685,
          y = 451,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1722,
          y = 609,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1721,
          y = 690,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1641,
          y = 755,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1525,
          y = 582,
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
          x = 1805,
          y = 1491,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 1656,
          y = 1825,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 1815,
          y = 1009,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 1649,
          y = 621,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 1208,
          y = 472,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 469,
          y = 932,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 437,
          y = 1429,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 593,
          y = 1715,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut_area",
          shape = "rectangle",
          x = 1286,
          y = 1412,
          width = 240,
          height = 176,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut_area",
          shape = "rectangle",
          x = 1042,
          y = 1931,
          width = 286,
          height = 164,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 931,
          y = 687,
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
          y = 1286,
          width = 219,
          height = 113,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_prefabs",
          shape = "rectangle",
          x = 906,
          y = 1605,
          width = 559,
          height = 175,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_prefabs",
          shape = "rectangle",
          x = 1028,
          y = 1789,
          width = 312,
          height = 124,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_prefabs",
          shape = "rectangle",
          x = 1094,
          y = 1410,
          width = 180,
          height = 181,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
