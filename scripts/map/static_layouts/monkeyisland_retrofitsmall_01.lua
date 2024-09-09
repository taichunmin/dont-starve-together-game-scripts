return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 26,
  height = 26,
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
      width = 26,
      height = 26,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 0, 0, 0, 0,
        0, 0, 0, 18, 18, 18, 18, 18, 45, 45, 45, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 0, 0, 0,
        0, 0, 18, 18, 18, 18, 45, 45, 45, 18, 18, 18, 18, 18, 18, 45, 45, 45, 18, 18, 45, 18, 18, 18, 0, 0,
        0, 18, 18, 18, 18, 18, 18, 18, 45, 18, 18, 45, 45, 45, 18, 45, 18, 18, 18, 18, 45, 18, 18, 18, 18, 0,
        18, 18, 18, 18, 18, 18, 18, 18, 45, 18, 18, 18, 18, 45, 18, 45, 18, 18, 45, 45, 45, 45, 18, 18, 18, 18,
        18, 18, 18, 18, 45, 45, 18, 18, 45, 45, 45, 45, 17, 45, 17, 45, 17, 18, 45, 18, 18, 45, 18, 18, 18, 18,
        18, 18, 18, 18, 45, 18, 18, 18, 18, 17, 17, 46, 46, 46, 46, 46, 17, 17, 45, 18, 18, 45, 18, 18, 18, 18,
        18, 18, 18, 18, 45, 18, 45, 45, 45, 45, 46, 46, 46, 46, 46, 46, 46, 45, 45, 45, 45, 45, 18, 18, 18, 18,
        18, 18, 18, 45, 45, 45, 45, 17, 17, 46, 46, 46, 46, 46, 46, 46, 46, 46, 45, 17, 18, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 45, 17, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 17, 18, 45, 45, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 18, 17, 46, 45, 45, 45, 46, 46, 46, 45, 45, 45, 46, 45, 18, 45, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 45, 45, 45, 46, 45, 45, 45, 46, 46, 46, 45, 45, 45, 46, 45, 18, 45, 18, 18, 18, 18,
        18, 45, 45, 18, 45, 45, 18, 17, 46, 45, 45, 45, 46, 46, 46, 45, 45, 45, 46, 17, 18, 45, 18, 18, 18, 18,
        18, 45, 45, 45, 45, 18, 45, 17, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 45, 45, 45, 45, 45, 45, 18,
        18, 18, 18, 18, 45, 18, 45, 45, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 17, 18, 18, 45, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 45, 17, 17, 46, 46, 46, 46, 46, 46, 46, 46, 46, 45, 45, 18, 18, 45, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 45, 18, 45, 45, 46, 46, 46, 46, 46, 46, 46, 17, 17, 45, 45, 18, 45, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 18, 18, 18, 17, 17, 46, 46, 46, 46, 46, 17, 17, 18, 18, 45, 45, 45, 45, 18, 18,
        0, 18, 18, 18, 18, 18, 18, 18, 18, 18, 17, 45, 46, 45, 46, 45, 17, 18, 18, 18, 18, 18, 18, 18, 18, 0,
        0, 0, 18, 18, 18, 18, 18, 18, 18, 18, 17, 45, 46, 45, 46, 45, 17, 18, 18, 18, 18, 18, 18, 18, 0, 0,
        0, 0, 0, 18, 18, 18, 18, 18, 18, 18, 17, 45, 46, 45, 46, 45, 17, 18, 18, 18, 18, 18, 18, 0, 0, 0,
        0, 0, 0, 0, 18, 18, 18, 18, 18, 18, 17, 45, 17, 45, 17, 45, 17, 18, 18, 18, 18, 18, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 18, 18, 18, 18, 18, 17, 45, 17, 45, 17, 45, 17, 18, 18, 18, 18, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 18, 18, 18, 18, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 0, 0, 0, 0, 0, 0
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
          x = 659,
          y = 849,
          width = 19,
          height = 23,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "boat_pirate",
          shape = "rectangle",
          x = 1144,
          y = 1295,
          width = 19,
          height = 19,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1147,
          y = 1299,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "boat_pirate",
          shape = "rectangle",
          x = 1114,
          y = 1479,
          width = 19,
          height = 19,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1117,
          y = 1483,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "boat_pirate",
          shape = "rectangle",
          x = 591,
          y = 1402,
          width = 19,
          height = 19,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 594,
          y = 1406,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 860,
          y = 1490,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 530,
          y = 1069,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1439,
          y = 1120,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1524,
          y = 976,
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
          y = 805,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1363,
          y = 420,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1187,
          y = 483,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 847,
          y = 352,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 544,
          y = 218,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 408,
          y = 603,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 92,
          y = 928,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 404,
          y = 990,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "boat_cannon",
          shape = "rectangle",
          x = 1505,
          y = 1251,
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
          x = 1431,
          y = 739,
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
          x = 1312,
          y = 292,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "55"
          }
        },
        {
          name = "",
          type = "boat_cannon",
          shape = "rectangle",
          x = 782,
          y = 345,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "90"
          }
        },
        {
          name = "",
          type = "boat_cannon",
          shape = "rectangle",
          x = 291,
          y = 477,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "90"
          }
        },
        {
          name = "",
          type = "boat_cannon",
          shape = "rectangle",
          x = 412,
          y = 1125,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "180"
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
          x = 736,
          y = 1313,
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
          x = 738,
          y = 1379,
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
          y = 1442,
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
          x = 738,
          y = 1499,
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
          x = 733,
          y = 1570,
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
          x = 866,
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
          x = 863,
          y = 1375,
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
          x = 865,
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
          x = 865,
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
          x = 867,
          y = 1567,
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
          y = 1313,
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
          x = 993,
          y = 1375,
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
          x = 992,
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
          x = 993,
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
          x = 608,
          y = 799,
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
          x = 608,
          y = 862,
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
          x = 609,
          y = 926,
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
          x = 671,
          y = 801,
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
          x = 669,
          y = 864,
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
          x = 670,
          y = 928,
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
          x = 735,
          y = 798,
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
          x = 737,
          y = 860,
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
          y = 925,
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
          y = 798,
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
          x = 994,
          y = 861,
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
          x = 995,
          y = 926,
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
          y = 800,
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
          x = 1054,
          y = 860,
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
          y = 926,
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
          x = 1116,
          y = 799,
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
          x = 1122,
          y = 862,
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
          x = 1119,
          y = 926,
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
          x = 608,
          y = 1185,
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
          x = 544,
          y = 1184,
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
          x = 479,
          y = 1058,
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
          x = 477,
          y = 865,
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
          x = 544,
          y = 608,
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
          x = 606,
          y = 609,
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
          x = 671,
          y = 484,
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
          x = 739,
          y = 479,
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
          x = 866,
          y = 477,
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
          x = 993,
          y = 477,
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
          x = 1120,
          y = 605,
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
          x = 1182,
          y = 611,
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
          y = 670,
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
          x = 1247,
          y = 798,
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
          x = 1247,
          y = 863,
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
          x = 1248,
          y = 992,
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
          x = 1245,
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
          x = 1182,
          y = 1121,
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
          x = 1311,
          y = 1184,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1313,
          y = 1246,
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
          y = 1246,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1441,
          y = 1246,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1506,
          y = 1244,
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
          y = 1184,
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
          y = 1120,
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
          x = 1435,
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
          x = 1503,
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
          x = 1569,
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
          x = 1311,
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
          x = 1379,
          y = 862,
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
          x = 1375,
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
          x = 1437,
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
          x = 1248,
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
          x = 1312,
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
          x = 1374,
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
          x = 1376,
          y = 540,
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
          y = 483,
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
          x = 1310,
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
          x = 1310,
          y = 352,
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
          x = 1244,
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
          x = 1184,
          y = 418,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1187,
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
          x = 1185,
          y = 543,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 988,
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
          x = 993,
          y = 355,
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
          y = 287,
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
          y = 291,
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
          y = 289,
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
          x = 864,
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
          x = 799,
          y = 353,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 733,
          y = 353,
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
          x = 543,
          y = 474,
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
          y = 420,
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
          x = 541,
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
          x = 544,
          y = 219,
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
          y = 224,
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
          y = 224,
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
          y = 284,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 412,
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
          x = 480,
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
          x = 410,
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
          x = 415,
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
          x = 414,
          y = 731,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 350,
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
          x = 285,
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
          x = 224,
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
          x = 287,
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
          x = 288,
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
          x = 287,
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
          x = 347,
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
          x = 417,
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
          x = 417,
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
          x = 417,
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
          x = 413,
          y = 1185,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 417,
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
          x = 351,
          y = 864,
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
          y = 930,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 283,
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
          x = 286,
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
          x = 289,
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
          x = 222,
          y = 994,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 157,
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
          x = 159,
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
          x = 93,
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
          x = 97,
          y = 991,
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
          x = 998,
          y = 560,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 769,
          y = 695,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 730,
          y = 533,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 714,
          y = 818,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 708,
          y = 927,
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
          x = 643,
          y = 800,
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
          x = 591,
          y = 784,
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
          x = 599,
          y = 899,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 1197,
          y = 893,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 913,
          y = 1271,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 784,
          y = 997,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 810,
          y = 1241,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 596,
          y = 1055,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 1025,
          y = 1158,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 987,
          y = 791,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 527,
          y = 797,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 673,
          y = 1188,
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
          x = 1018,
          y = 1452,
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
          y = 1531,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 961,
          y = 1576,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 891,
          y = 1487,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 763,
          y = 1489,
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
          y = 1593,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 704,
          y = 1435,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 705,
          y = 1362,
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
          y = 1203,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1334,
          y = 1269,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1477,
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
          x = 1528,
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
          x = 1412,
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
          x = 1463,
          y = 1106,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1592,
          y = 994,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1560,
          y = 962,
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
          y = 899,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1347,
          y = 796,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1352,
          y = 712,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1416,
          y = 759,
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
          x = 1401,
          y = 582,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1348,
          y = 499,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1317,
          y = 437,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1209,
          y = 500,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1280,
          y = 581,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1287,
          y = 366,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1302,
          y = 259,
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
          y = 392,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1122,
          y = 305,
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
          y = 260,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 982,
          y = 262,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 965,
          y = 326,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1016,
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
          x = 716,
          y = 326,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 752,
          y = 372,
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
          y = 405,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 652,
          y = 198,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 520,
          y = 196,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 437,
          y = 306,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 568,
          y = 304,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 517,
          y = 372,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 568,
          y = 437,
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
          y = 455,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 375,
          y = 501,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 259,
          y = 507,
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
          y = 536,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 230,
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
          x = 376,
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
          x = 440,
          y = 753,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 424,
          y = 578,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 451,
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
          x = 350,
          y = 950,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 350,
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
          x = 311,
          y = 1013,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 183,
          y = 938,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 142,
          y = 898,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 72,
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
          x = 223,
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
          x = 440,
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
          x = 388,
          y = 1192,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 388,
          y = 1045,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 439,
          y = 1008,
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
          x = 816,
          y = 736,
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
          x = 864,
          y = 624,
          width = 19,
          height = 23,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeypillar",
          shape = "rectangle",
          x = 976,
          y = 672,
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
          x = 912,
          y = 512,
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
          x = 752,
          y = 576,
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
          x = 1485,
          y = 991,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 1296,
          y = 1199,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 1389,
          y = 491,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 976,
          y = 291,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 468,
          y = 287,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 111,
          y = 986,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 274,
          y = 537,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 420,
          y = 1186,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut_area",
          shape = "rectangle",
          x = 966,
          y = 774,
          width = 240,
          height = 176,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut_area",
          shape = "rectangle",
          x = 722,
          y = 1293,
          width = 286,
          height = 164,
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
          x = 587,
          y = 648,
          width = 219,
          height = 113,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_prefabs",
          shape = "rectangle",
          x = 708,
          y = 1151,
          width = 312,
          height = 124,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_prefabs",
          shape = "rectangle",
          x = 586,
          y = 967,
          width = 559,
          height = 175,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_prefabs",
          shape = "rectangle",
          x = 774,
          y = 772,
          width = 180,
          height = 181,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
