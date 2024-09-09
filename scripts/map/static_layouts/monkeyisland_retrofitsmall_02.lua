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
        0, 0, 0, 0, 0, 18, 18, 18, 18, 18, 18, 45, 18, 18, 18, 18, 18, 18, 18, 18, 18, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 18, 18, 18, 18, 18, 18, 45, 45, 45, 45, 45, 45, 45, 45, 18, 18, 18, 18, 0, 0, 0, 0,
        0, 0, 0, 18, 18, 18, 18, 18, 45, 45, 45, 45, 18, 18, 45, 18, 18, 45, 18, 18, 18, 18, 18, 0, 0, 0,
        0, 0, 18, 18, 18, 18, 18, 18, 18, 45, 45, 45, 18, 18, 18, 18, 18, 45, 45, 45, 45, 18, 18, 18, 0, 0,
        0, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 45, 18, 45, 18, 18, 18, 18, 18, 45, 45, 18, 18, 18, 18, 0,
        18, 18, 18, 18, 18, 18, 45, 45, 18, 18, 18, 45, 45, 45, 45, 18, 18, 18, 18, 18, 45, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 45, 45, 45, 45, 17, 17, 45, 17, 17, 17, 17, 45, 45, 45, 45, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 18, 18, 45, 45, 45, 46, 46, 46, 46, 46, 17, 45, 45, 18, 18, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 18, 18, 17, 17, 46, 46, 46, 46, 46, 46, 46, 45, 45, 18, 18, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 45, 45, 45, 17, 46, 46, 46, 46, 46, 46, 46, 46, 46, 17, 17, 45, 45, 45, 45, 18, 18,
        18, 18, 18, 18, 45, 45, 45, 45, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 17, 45, 18, 45, 45, 18, 18,
        18, 18, 18, 18, 18, 45, 45, 17, 46, 45, 45, 45, 46, 46, 46, 45, 45, 45, 46, 45, 45, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 45, 45, 17, 46, 45, 45, 45, 46, 46, 46, 45, 45, 45, 46, 17, 18, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 45, 45, 17, 46, 45, 45, 45, 46, 46, 46, 45, 45, 45, 46, 17, 45, 45, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 45, 45, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 45, 45, 45, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 18, 17, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 45, 18, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 45, 45, 45, 45, 45, 46, 46, 46, 46, 46, 46, 46, 46, 46, 17, 17, 18, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 45, 45, 18, 17, 17, 46, 46, 46, 46, 46, 46, 46, 45, 45, 45, 45, 18, 18, 18, 18, 18,
        18, 18, 18, 18, 18, 18, 18, 18, 18, 17, 17, 46, 46, 46, 46, 46, 17, 17, 18, 45, 45, 18, 18, 18, 18, 18,
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
          x = 1269,
          y = 1357,
          width = 19,
          height = 19,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1272,
          y = 1361,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "boat_pirate",
          shape = "rectangle",
          x = 513,
          y = 1255,
          width = 19,
          height = 19,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 516,
          y = 1259,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "boat_pirate",
          shape = "rectangle",
          x = 585,
          y = 1475,
          width = 19,
          height = 19,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 588,
          y = 1479,
          width = 11,
          height = 11,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 740,
          y = 1564,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1042,
          y = 796,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 524,
          y = 903,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1332,
          y = 1229,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1327,
          y = 942,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1452,
          y = 750,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 1138,
          y = 230,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 946,
          y = 179,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 626,
          y = 302,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pirate_flag_pole",
          shape = "rectangle",
          x = 396,
          y = 905,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "boat_cannon",
          shape = "rectangle",
          x = 733,
          y = 84,
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
          x = 280,
          y = 735,
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
          x = 306,
          y = 1120,
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
          x = 1390,
          y = 957,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "0"
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
          x = 545,
          y = 1122,
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
          x = 482,
          y = 1119,
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
          y = 991,
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
          y = 735,
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
          x = 480,
          y = 664,
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
          y = 546,
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
          y = 541,
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
          y = 478,
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
          x = 1117,
          y = 547,
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
          x = 1180,
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
          x = 1248,
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
          x = 1246,
          y = 993,
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
          x = 1183,
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
          x = 1119,
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
          x = 1248,
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
          x = 1310,
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
          x = 1245,
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
          x = 1311,
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
          x = 1376,
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
          x = 1376,
          y = 923,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1307,
          y = 922,
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
          y = 797,
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
          x = 1309,
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
          x = 1372,
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
          x = 1439,
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
          x = 1500,
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
          x = 1507,
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
          x = 1437,
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
          x = 1180,
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
          x = 1184,
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
          x = 1116,
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
          x = 1248,
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
          x = 1311,
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
          x = 1308,
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
          x = 1305,
          y = 349,
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
          x = 1243,
          y = 282,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 1306,
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
          x = 1182,
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
          x = 1117,
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
          x = 1120,
          y = 158,
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
          y = 162,
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
          y = 164,
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
          y = 162,
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
          x = 864,
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
          x = 798,
          y = 158,
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
          y = 96,
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
          y = 159,
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
          y = 222,
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
          y = 221,
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
          y = 223,
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
          x = 734,
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
          x = 669,
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
          x = 605,
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
          x = 736,
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
          x = 734,
          y = 414,
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
          y = 412,
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
          y = 414,
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
          x = 863,
          y = 349,
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
          x = 543,
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
          x = 546,
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
          x = 478,
          y = 477,
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
          y = 414,
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
          x = 416,
          y = 477,
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
          x = 350,
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
          x = 285,
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
          x = 350,
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
          x = 414,
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
          x = 418,
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
          x = 351,
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
          x = 351,
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
          x = 416,
          y = 867,
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
          x = 414,
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
          x = 414,
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
          x = 414,
          y = 1122,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_tile_registrator",
          shape = "rectangle",
          x = 348,
          y = 1117,
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
          x = 351,
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
          x = 414,
          y = 1180,
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
          x = 1101,
          y = 716,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 632,
          y = 677,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 827,
          y = 538,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 664,
          y = 795,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_portal_debris",
          shape = "rectangle",
          x = 634,
          y = 933,
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
          x = 775,
          y = 872,
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
          x = 745,
          y = 952,
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
          x = 619,
          y = 851,
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
          x = 962,
          y = 1352,
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
          x = 753,
          y = 1360,
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
          x = 1052,
          y = 873,
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
          y = 1337,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
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
          x = 871,
          y = 1594,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 832,
          y = 1530,
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
          x = 384,
          y = 1206,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 326,
          y = 1173,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 264,
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
          x = 409,
          y = 1091,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 492,
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
          x = 399,
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
          x = 357,
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
          x = 326,
          y = 910,
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
          y = 823,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 260,
          y = 758,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 286,
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
          x = 372,
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
          x = 498,
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
          x = 440,
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
          x = 388,
          y = 432,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 395,
          y = 388,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 544,
          y = 452,
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
          y = 468,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 578,
          y = 565,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 889,
          y = 351,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 930,
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
          x = 953,
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
          x = 734,
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
          x = 710,
          y = 331,
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
          x = 760,
          y = 243,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 593,
          y = 309,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 533,
          y = 243,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 565,
          y = 195,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 670,
          y = 131,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 761,
          y = 92,
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
          y = 67,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 851,
          y = 130,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 953,
          y = 221,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 993,
          y = 130,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1052,
          y = 131,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1078,
          y = 181,
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
          y = 244,
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
          x = 1337,
          y = 307,
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
          x = 1337,
          y = 417,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1251,
          y = 452,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1325,
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
          x = 1092,
          y = 473,
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
          x = 1285,
          y = 647,
          width = 5,
          height = 5,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "dock_woodposts",
          shape = "rectangle",
          x = 1367,
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
          x = 1432,
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
          x = 1525,
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
          x = 1503,
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
          x = 1376,
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
          x = 1402,
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
          x = 1301,
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
          x = 1323,
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
          x = 1321,
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
          x = 1219,
          y = 1257,
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
          x = 881,
          y = 1440,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 845,
          y = 1331,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 360,
          y = 697,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 347,
          y = 801,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 428,
          y = 426,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 630,
          y = 213,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 708,
          y = 266,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 1305,
          y = 298,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut",
          shape = "rectangle",
          x = 1516,
          y = 692,
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
          y = 776,
          width = 240,
          height = 176,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyhut_area",
          shape = "rectangle",
          x = 710,
          y = 1287,
          width = 305,
          height = 173,
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
          x = 586,
          y = 966,
          width = 559,
          height = 175,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_prefabs",
          shape = "rectangle",
          x = 775,
          y = 772,
          width = 180,
          height = 183,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_prefabs",
          shape = "rectangle",
          x = 709,
          y = 1154,
          width = 309,
          height = 120,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "monkeyisland_prefabs",
          shape = "rectangle",
          x = 582,
          y = 646,
          width = 226,
          height = 117,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
