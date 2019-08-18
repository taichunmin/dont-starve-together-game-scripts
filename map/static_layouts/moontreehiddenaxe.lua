return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 2,
  height = 2,
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
      width = 2,
      height = 2,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        34, 34,
        34, 34
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
          type = "moon_tree_normal",
          shape = "rectangle",
          x = 27,
          y = 97,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "moon_tree_tall",
          shape = "rectangle",
          x = 63,
          y = 104,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "moon_tree_normal",
          shape = "rectangle",
          x = 105,
          y = 58,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "moon_tree_tall",
          shape = "rectangle",
          x = 98,
          y = 19,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "moon_tree_tall",
          shape = "rectangle",
          x = 27,
          y = 21,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "moonglassaxe",
          shape = "rectangle",
          x = 66,
          y = 63,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "moon_tree_short",
          shape = "rectangle",
          x = 63,
          y = 33,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "moon_tree_normal",
          shape = "rectangle",
          x = 21,
          y = 58,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "moon_tree_normal",
          shape = "rectangle",
          x = 99,
          y = 90,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
