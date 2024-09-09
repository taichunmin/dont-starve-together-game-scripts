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
          x = 45,
          y = 77,
          width = 44,
          height = 23,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "kelp_area",
          shape = "rectangle",
          x = 179,
          y = 42,
          width = 25,
          height = 50,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "kelp_area",
          shape = "rectangle",
          x = 51,
          y = 146,
          width = 18,
          height = 55,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "kelp_area",
          shape = "rectangle",
          x = 106,
          y = 153,
          width = 21,
          height = 30,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "kelp_area",
          shape = "rectangle",
          x = 130,
          y = 28,
          width = 15,
          height = 59,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "kelp_area",
          shape = "rectangle",
          x = 156,
          y = 189,
          width = 54,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "kelp_area",
          shape = "rectangle",
          x = 146,
          y = 136,
          width = 54,
          height = 16,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
