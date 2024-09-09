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
        34, 0
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
          type = "hotspring",
          shape = "rectangle",
          x = 40,
          y = 36,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.isbathbombed"] = "true"
          }
        },
        {
          name = "",
          type = "skeleton",
          shape = "rectangle",
          x = 77,
          y = 16,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.anim"] = "4"
          }
        },
        {
          name = "",
          type = "moon_tree_tall",
          shape = "rectangle",
          x = 18,
          y = 77,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "bathbomb",
          shape = "rectangle",
          x = 71,
          y = 40,
          width = 19,
          height = 20,
          visible = true,
          properties = {
            ["data.perishable.paused"] = "true"
          }
        },
        {
          name = "",
          type = "moon_tree_short",
          shape = "rectangle",
          x = 38,
          y = 115,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
