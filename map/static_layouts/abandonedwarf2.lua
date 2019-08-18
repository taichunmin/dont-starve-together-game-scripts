return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 10,
  height = 10,
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
      width = 10,
      height = 10,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 17, 17, 17, 17, 17, 17, 0, 0,
        0, 17, 17, 9, 9, 17, 9, 17, 17, 0,
        17, 17, 9, 9, 17, 17, 9, 9, 17, 17,
        17, 9, 9, 9, 9, 9, 9, 9, 9, 17,
        17, 17, 17, 9, 9, 9, 9, 9, 17, 17,
        17, 9, 9, 9, 9, 9, 9, 17, 17, 0,
        17, 9, 9, 9, 9, 9, 9, 9, 17, 17,
        17, 17, 9, 9, 9, 9, 9, 9, 17, 17,
        0, 17, 17, 9, 17, 9, 9, 17, 17, 0,
        0, 0, 17, 17, 17, 17, 17, 17, 0, 0
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
          type = "miniflare",
          shape = "rectangle",
          x = 321,
          y = 304,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "miniflare",
          shape = "rectangle",
          x = 460,
          y = 429,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
