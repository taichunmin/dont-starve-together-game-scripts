return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 3,
  height = 3,
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
      width = 3,
      height = 3,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        7, 7, 7,
        7, 7, 7,
        7, 7, 7
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
          type = "skeleton",
          shape = "rectangle",
          x = 141,
          y = 87,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "spiderden",
          shape = "rectangle",
          x = 50,
          y = 143,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.growable.stage"] = "2"
          }
        },
        {
          name = "",
          type = "log",
          shape = "rectangle",
          x = 143,
          y = 134,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "terrariumchest",
          shape = "rectangle",
          x = 91,
          y = 94,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["scenario"] = "chest_terrarium"
          }
        },
        {
          name = "",
          type = "log",
          shape = "rectangle",
          x = 133,
          y = 119,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "axe",
          shape = "rectangle",
          x = 148,
          y = 101,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pond",
          shape = "rectangle",
          x = 107,
          y = 25,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "log",
          shape = "rectangle",
          x = 117,
          y = 141,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "log",
          shape = "rectangle",
          x = 141,
          y = 153,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 165,
          y = 31,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
