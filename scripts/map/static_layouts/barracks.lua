return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 40,
  height = 40,
  tilewidth = 16,
  tileheight = 16,
  properties = {},
  tilesets = {
    {
      name = "tiles",
      firstgid = 1,
      tilewidth = 64,
      tileheight = 64,
      spacing = 0,
      margin = 0,
      image = "../../../../tools/tiled/dont_starve/tiles.png",
      imagewidth = 512,
      imageheight = 384,
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
      width = 40,
      height = 40,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1, 0, 0, 0, 1, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        29, 0, 0, 0, 1, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 1, 0, 0, 0, 29, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        29, 0, 0, 0, 1, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 1, 0, 0, 0, 29, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        29, 0, 0, 0, 1, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 1, 0, 0, 0, 29, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        29, 0, 0, 0, 1, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 1, 0, 0, 0, 29, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1, 0, 0, 0, 1, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0
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
          type = "wall_ruins",
          shape = "rectangle",
          x = 510,
          y = 414,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          name = "",
          type = "wall_ruins",
          shape = "rectangle",
          x = 510,
          y = 430,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".45"
          }
        },
        {
          name = "",
          type = "wall_ruins",
          shape = "rectangle",
          x = 510,
          y = 446,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".45"
          }
        },
        {
          name = "",
          type = "wall_ruins",
          shape = "rectangle",
          x = 127,
          y = 128,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".3"
          }
        },
        {
          name = "",
          type = "wall_ruins",
          shape = "rectangle",
          x = 143,
          y = 128,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".3"
          }
        },
        {
          name = "",
          type = "wall_ruins",
          shape = "rectangle",
          x = 159,
          y = 128,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".3"
          }
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 127,
          y = 206,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 127,
          y = 222,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 127,
          y = 238,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 127,
          y = 254,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 175,
          y = 128,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 191,
          y = 128,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 207,
          y = 128,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 223,
          y = 128,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_ruins",
          shape = "rectangle",
          x = 509,
          y = 159,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          name = "",
          type = "wall_ruins",
          shape = "rectangle",
          x = 509,
          y = 175,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".45"
          }
        },
        {
          name = "",
          type = "wall_ruins",
          shape = "rectangle",
          x = 509,
          y = 191,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".45"
          }
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 178,
          y = 511,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_ruins",
          shape = "rectangle",
          x = 162,
          y = 511,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".3"
          }
        },
        {
          name = "",
          type = "wall_ruins",
          shape = "rectangle",
          x = 146,
          y = 511,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".3"
          }
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 194,
          y = 511,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 404,
          y = 511,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 436,
          y = 511,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 452,
          y = 511,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 420,
          y = 511,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "chessjunk_spawner",
          shape = "rectangle",
          x = 256,
          y = 192,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "chessjunk_spawner",
          shape = "rectangle",
          x = 288,
          y = 400,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "chessjunk_spawner",
          shape = "rectangle",
          x = 160,
          y = 416,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "chessjunk_spawner",
          shape = "rectangle",
          x = 384,
          y = 384,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "chessjunk_spawner",
          shape = "rectangle",
          x = 352,
          y = 288,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "chessjunk_spawner",
          shape = "rectangle",
          x = 272,
          y = 480,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "rook_nightmare_spawner",
          shape = "rectangle",
          x = 208,
          y = 304,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "rook_nightmare_spawner",
          shape = "rectangle",
          x = 480,
          y = 368,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "bishop_nightmare_spawner",
          shape = "rectangle",
          x = 432,
          y = 176,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
