return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 4,
  height = 4,
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
      width = 4,
      height = 4,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, 0
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
          type = "kelp_area",
          shape = "rectangle",
          x = 25,
          y = 41,
          width = 44,
          height = 23,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "kelp_area",
          shape = "rectangle",
          x = 131,
          y = 45,
          width = 25,
          height = 50,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "kelp_area",
          shape = "rectangle",
          x = 37,
          y = 106,
          width = 18,
          height = 55,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "kelp_area",
          shape = "rectangle",
          x = 75,
          y = 125,
          width = 21,
          height = 30,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "kelp_area",
          shape = "rectangle",
          x = 96,
          y = 32,
          width = 15,
          height = 59,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "driftwood_log",
          shape = "rectangle",
          x = 143,
          y = 182,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "kelp_area",
          shape = "rectangle",
          x = 123,
          y = 140,
          width = 54,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "kelp_area",
          shape = "rectangle",
          x = 200,
          y = 30,
          width = 25,
          height = 50,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "kelp_area",
          shape = "rectangle",
          x = 206,
          y = 111,
          width = 25,
          height = 50,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "kelp_area",
          shape = "rectangle",
          x = 36,
          y = 188,
          width = 79,
          height = 30,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "kelp_area",
          shape = "rectangle",
          x = 170,
          y = 176,
          width = 19,
          height = 28,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "kelp_area",
          shape = "rectangle",
          x = 115,
          y = 108,
          width = 54,
          height = 16,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
