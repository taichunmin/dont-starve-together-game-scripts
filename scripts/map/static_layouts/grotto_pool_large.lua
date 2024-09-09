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
      width = 2,
      height = 2,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        43, 43,
        43, 43
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS_DEBUG",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {}
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
          type = "grotto_pool_big",
          shape = "rectangle",
          x = 60,
          y = 58,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "cavelightmoon_small",
          shape = "rectangle",
          x = 67,
          y = 66,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
