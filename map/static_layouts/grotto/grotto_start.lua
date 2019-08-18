return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 8,
  height = 8,
  tilewidth = 64,
  tileheight = 64,
  properties = {},
  tilesets = {
    {
      name = "ground",
      firstgid = 1,
      filename = "../../../../../tools/tiled/dont_starve/ground.tsx",
      tilewidth = 64,
      tileheight = 64,
      spacing = 0,
      margin = 0,
      image = "../../../../../tools/tiled/dont_starve/tiles.png",
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
      width = 8,
      height = 8,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 12, 0, 0, 0, 12, 0, 0,
        12, 12, 12, 0, 12, 12, 0, 0,
        0, 12, 12, 0, 12, 0, 12, 12,
        0, 0, 12, 12, 12, 12, 0, 0,
        12, 0, 0, 12, 12, 12, 12, 0,
        12, 12, 12, 12, 12, 0, 12, 0,
        0, 0, 0, 0, 12, 0, 12, 12,
        0, 12, 12, 12, 0, 0, 0, 0
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS_DEBUG",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "cavelight_small",
          shape = "rectangle",
          x = 97,
          y = 435,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "cavelight",
          shape = "rectangle",
          x = 289,
          y = 253,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "cavelight_small",
          shape = "rectangle",
          x = 301,
          y = 457,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "cavelight_small",
          shape = "rectangle",
          x = 447,
          y = 345,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "cavelight_small",
          shape = "rectangle",
          x = 411,
          y = 51,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "multiplayer_portal",
          shape = "rectangle",
          x = 256,
          y = 265,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "spawnpoint_master",
          shape = "rectangle",
          x = 256,
          y = 265,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "cavelight",
          shape = "rectangle",
          x = 44,
          y = 152,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {}
    }
  }
}
