return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 5,
  height = 5,
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
      width = 5,
      height = 5,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        4, 12, 4, 12, 4,
        12, 12, 12, 12, 12,
        4, 12, 12, 12, 4,
        12, 12, 12, 12, 12,
        4, 12, 4, 12, 4
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
          type = "tree_area",
          shape = "rectangle",
          x = 61,
          y = 65,
          width = 29,
          height = 29,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "tree_area",
          shape = "rectangle",
          x = 182,
          y = 52,
          width = 36,
          height = 34,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "tree_area",
          shape = "rectangle",
          x = 110,
          y = 247,
          width = 28,
          height = 26,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "tree_area",
          shape = "rectangle",
          x = 59,
          y = 144,
          width = 18,
          height = 68,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "tree_area",
          shape = "rectangle",
          x = 124,
          y = 171,
          width = 61,
          height = 33,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "tree_area",
          shape = "rectangle",
          x = 195,
          y = 238,
          width = 20,
          height = 24,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "tree_area",
          shape = "rectangle",
          x = 205,
          y = 122,
          width = 37,
          height = 19,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "tree_area",
          shape = "rectangle",
          x = 118,
          y = 53,
          width = 23,
          height = 69,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "tree_area",
          shape = "rectangle",
          x = 221,
          y = 185,
          width = 42,
          height = 23,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "moon_tree_petal_worldgen",
          shape = "rectangle",
          x = 169,
          y = 132,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "moon_tree_petal_worldgen",
          shape = "rectangle",
          x = 258,
          y = 247,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
