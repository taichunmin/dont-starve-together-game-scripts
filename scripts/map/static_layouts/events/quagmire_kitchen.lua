return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 50,
  height = 50,
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
      width = 50,
      height = 50,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 23, 23, 23, 23, 23, 0, 0, 23, 23, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 23, 23, 23, 23, 23, 23, 0, 0, 0, 0, 0, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 23, 23, 23, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 23, 23, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 23, 23, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 23, 0, 0, 0, 0, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 23, 0, 0, 0, 23, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 0, 0, 0, 0, 0, 0, 0, 23, 0, 0, 23, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 32, 32, 32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 0, 0, 0, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 0, 0, 0, 0, 0, 32, 32, 32, 32, 32, 31, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 0, 0, 0, 0, 23, 15, 15, 15, 15, 15, 15, 23, 15, 23, 0, 0, 0, 0, 0, 32, 32, 32, 32, 31, 32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 0, 0, 0, 23, 15, 15, 2, 2, 15, 15, 15, 15, 15, 15, 23, 23, 23, 23, 32, 32, 31, 32, 32, 31, 32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 23, 15, 15, 23, 15, 15, 15, 15, 2, 15, 2, 2, 15, 15, 15, 15, 15, 32, 32, 32, 32, 31, 31, 31, 31, 32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 23, 15, 23, 15, 15, 15, 15, 2, 2, 2, 2, 15, 15, 15, 40, 40, 31, 31, 31, 31, 31, 32, 32, 31, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 2, 2, 2, 2, 15, 15, 15, 15, 15, 15, 32, 32, 32, 32, 31, 32, 32, 32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 23, 15, 15, 15, 15, 15, 15, 2, 15, 15, 2, 2, 2, 2, 15, 15, 15, 15, 32, 32, 32, 32, 31, 31, 32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 23, 15, 15, 23, 23, 15, 16, 15, 15, 15, 15, 2, 15, 15, 2, 15, 15, 0, 0, 0, 0, 0, 32, 32, 31, 32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 23, 23, 15, 23, 15, 15, 15, 16, 15, 15, 15, 2, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 32, 32, 32, 32, 32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 23, 0, 23, 23, 23, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 16, 15, 15, 15, 15, 0, 0, 0, 0, 32, 32, 32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 23, 23, 23, 23, 23, 23, 15, 15, 15, 15, 15, 15, 15, 16, 16, 15, 15, 16, 15, 2, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 23, 23, 23, 23, 23, 15, 23, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 2, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 40, 40, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 23, 23, 23, 23, 23, 23, 23, 23, 23, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 2, 15, 40, 0, 0, 0, 40, 40, 0, 40, 40, 40, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 15, 15, 15, 23, 15, 15, 15, 15, 15, 15, 15, 2, 40, 40, 0, 40, 40, 40, 40, 2, 40, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 15, 23, 15, 15, 15, 15, 15, 15, 0, 40, 40, 2, 40, 40, 2, 40, 40, 40, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 40, 40, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 23, 23, 23, 23, 23, 23, 23, 23, 23, 0, 23, 23, 23, 23, 23, 23, 15, 15, 15, 15, 15, 15, 0, 0, 0, 40, 40, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 23, 23, 23, 23, 23, 23, 23, 23, 0, 0, 0, 23, 23, 23, 15, 15, 15, 15, 0, 15, 15, 15, 0, 0, 0, 40, 40, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 23, 23, 23, 23, 23, 23, 23, 23, 0, 0, 0, 0, 0, 0, 23, 0, 15, 15, 0, 0, 15, 0, 0, 0, 0, 0, 40, 2, 40, 40, 40, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 23, 23, 23, 23, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 40, 40, 40, 2, 40, 0, 40, 40, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 23, 23, 23, 23, 0, 0, 0, 0, 23, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 40, 40, 40, 2, 2, 40, 40, 0, 0, 40, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 23, 23, 23, 23, 0, 0, 0, 23, 23, 23, 23, 23, 0, 0, 23, 0, 0, 0, 0, 40, 40, 40, 2, 2, 2, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 0, 0, 0, 40, 40, 2, 2, 2, 2, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 23, 23, 23, 23, 23, 23, 23, 23, 23, 40, 40, 23, 40, 40, 23, 23, 23, 0, 0, 0, 40, 40, 2, 2, 2, 40, 40, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 23, 23, 23, 23, 23, 23, 23, 40, 40, 40, 40, 40, 40, 23, 16, 23, 0, 0, 0, 40, 40, 2, 2, 2, 40, 40, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 23, 23, 23, 23, 23, 40, 40, 40, 40, 40, 40, 40, 40, 23, 23, 23, 0, 0, 0, 40, 40, 2, 40, 40, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 23, 23, 23, 23, 40, 40, 40, 40, 40, 40, 40, 40, 40, 23, 23, 23, 0, 0, 40, 40, 40, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 23, 23, 23, 23, 23, 40, 40, 40, 40, 40, 40, 40, 40, 23, 23, 23, 0, 0, 0, 40, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 23, 23, 23, 23, 23, 40, 40, 40, 40, 40, 40, 40, 23, 23, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 23, 23, 23, 23, 23, 40, 40, 40, 40, 40, 40, 23, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 23, 23, 23, 23, 23, 23, 40, 40, 40, 23, 23, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 23, 23, 23, 23, 23, 40, 40, 23, 23, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 23, 23, 23, 23, 23, 23, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 23, 23, 23, 23, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
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
          type = "spawnpoint_master",
          shape = "rectangle",
          x = 1342,
          y = 1215,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_portal",
          shape = "rectangle",
          x = 1342,
          y = 1215,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_altar",
          shape = "rectangle",
          x = 1408,
          y = 1152,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_safe",
          shape = "rectangle",
          x = 1703,
          y = 2410,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_safe",
          shape = "rectangle",
          x = 2107,
          y = 1801,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_safe",
          shape = "rectangle",
          x = 1685,
          y = 2392,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "extinguished",
          type = "firepit",
          shape = "rectangle",
          x = 1247,
          y = 1442,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.fueled.fuel"] = "0",
            ["skinname"] = "firepit_victorian"
          }
        },
        {
          name = "extinguished",
          type = "firepit",
          shape = "rectangle",
          x = 1506,
          y = 1379,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.fueled.fuel"] = "0",
            ["skinname"] = "firepit_victorian"
          }
        },
        {
          name = "",
          type = "quagmire_goatmum",
          shape = "rectangle",
          x = 1216,
          y = 1250,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "rabbit",
          shape = "rectangle",
          x = 1374,
          y = 1740,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "rabbit",
          shape = "rectangle",
          x = 1176,
          y = 1690,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "rabbit",
          shape = "rectangle",
          x = 1265,
          y = 1742,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_trader_merm",
          shape = "rectangle",
          x = 1337,
          y = 822,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_mealingstone",
          shape = "rectangle",
          x = 2201,
          y = 1894,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "extinguished",
          type = "firepit",
          shape = "rectangle",
          x = 1180,
          y = 1057,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.fueled.fuel"] = "0",
            ["skinname"] = "firepit_victorian"
          }
        },
        {
          name = "",
          type = "quagmire_hoe",
          shape = "rectangle",
          x = 1414,
          y = 1461,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "extinguished",
          type = "firepit",
          shape = "rectangle",
          x = 1119,
          y = 1311,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.fueled.fuel"] = "0",
            ["skinname"] = "firepit_victorian"
          }
        },
        {
          name = "",
          type = "axe",
          shape = "rectangle",
          x = 1174,
          y = 1459,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["skinname"] = "axe_victorian"
          }
        },
        {
          name = "",
          type = "log",
          shape = "rectangle",
          x = 1173,
          y = 1483,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "log",
          shape = "rectangle",
          x = 1193,
          y = 1477,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "unlocked empty safe",
          type = "quagmire_safe",
          shape = "rectangle",
          x = 1124,
          y = 1394,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.isunlocked"] = "true"
          }
        },
        {
          name = "",
          type = "quagmire_merm_cart1",
          shape = "rectangle",
          x = 1289,
          y = 799,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "rabbit",
          shape = "rectangle",
          x = 641,
          y = 923,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_altar_statue2",
          shape = "rectangle",
          x = 1385,
          y = 1344,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "151.5"
          }
        },
        {
          name = "",
          type = "quagmire_altar_statue2",
          shape = "rectangle",
          x = 1215,
          y = 1174,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "-77"
          }
        },
        {
          name = "",
          type = "quagmire_altar_queen",
          shape = "rectangle",
          x = 1467,
          y = 1093,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "-135"
          }
        },
        {
          name = "",
          type = "quagmire_altar_statue1",
          shape = "rectangle",
          x = 1426,
          y = 1272,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "151.5"
          }
        },
        {
          name = "",
          type = "quagmire_altar_statue1",
          shape = "rectangle",
          x = 1287,
          y = 1134,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "-77"
          }
        },
        {
          name = "",
          type = "quagmire_lamp_short",
          shape = "rectangle",
          x = 1477,
          y = 1165,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "-45"
          }
        },
        {
          name = "",
          type = "quagmire_lamp_short",
          shape = "rectangle",
          x = 1395,
          y = 1086,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "-45"
          }
        },
        {
          name = "",
          type = "quagmire_altar_bollard",
          shape = "rectangle",
          x = 1332,
          y = 1036,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "-45"
          }
        },
        {
          name = "",
          type = "quagmire_altar_bollard",
          shape = "rectangle",
          x = 1375,
          y = 1036,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "-45"
          }
        },
        {
          name = "",
          type = "quagmire_altar_bollard",
          shape = "rectangle",
          x = 1419,
          y = 1035,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "-45"
          }
        },
        {
          name = "",
          type = "quagmire_altar_bollard",
          shape = "rectangle",
          x = 1461,
          y = 1036,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "-45"
          }
        },
        {
          name = "",
          type = "quagmire_altar_ivy",
          shape = "rectangle",
          x = 1357,
          y = 1013,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_altar_ivy",
          shape = "rectangle",
          x = 1395,
          y = 1013,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_altar_ivy",
          shape = "rectangle",
          x = 1442,
          y = 1011,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_altar_bollard",
          shape = "rectangle",
          x = 1523,
          y = 1101,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "-45"
          }
        },
        {
          name = "",
          type = "quagmire_altar_bollard",
          shape = "rectangle",
          x = 1524,
          y = 1142,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "-45"
          }
        },
        {
          name = "",
          type = "quagmire_altar_bollard",
          shape = "rectangle",
          x = 1523,
          y = 1182,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "-45"
          }
        },
        {
          name = "",
          type = "quagmire_altar_bollard",
          shape = "rectangle",
          x = 1523,
          y = 1220,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "-45"
          }
        },
        {
          name = "",
          type = "quagmire_altar_ivy",
          shape = "rectangle",
          x = 1545,
          y = 1121,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_altar_ivy",
          shape = "rectangle",
          x = 1545,
          y = 1167,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_altar_ivy",
          shape = "rectangle",
          x = 1545,
          y = 1205,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_altar_bollard",
          shape = "rectangle",
          x = 1377,
          y = 1394,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "-45"
          }
        },
        {
          name = "",
          type = "quagmire_altar_bollard",
          shape = "rectangle",
          x = 1408,
          y = 1395,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "-45"
          }
        },
        {
          name = "",
          type = "quagmire_altar_bollard",
          shape = "rectangle",
          x = 1441,
          y = 1395,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "-45"
          }
        },
        {
          name = "",
          type = "quagmire_altar_bollard",
          shape = "rectangle",
          x = 1162,
          y = 1183,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "-45"
          }
        },
        {
          name = "",
          type = "quagmire_altar_bollard",
          shape = "rectangle",
          x = 1164,
          y = 1152,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "-45"
          }
        },
        {
          name = "",
          type = "quagmire_altar_bollard",
          shape = "rectangle",
          x = 1163,
          y = 1118,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "-45"
          }
        }
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS_BERRIES_SAPLINGS",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 1645,
          y = 748,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_beefalo",
          shape = "rectangle",
          x = 700,
          y = 1057,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 1036,
          y = 1079,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush2",
          shape = "rectangle",
          x = 700,
          y = 955,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush2",
          shape = "rectangle",
          x = 758,
          y = 871,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 632,
          y = 1134,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 807,
          y = 1212,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush2",
          shape = "rectangle",
          x = 616,
          y = 1015,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush2",
          shape = "rectangle",
          x = 672,
          y = 853,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 1088,
          y = 983,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 910,
          y = 1123,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush2",
          shape = "rectangle",
          x = 672,
          y = 1045,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush2",
          shape = "rectangle",
          x = 856,
          y = 1096,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 1706,
          y = 807,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 746,
          y = 949,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 591,
          y = 905,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 1623,
          y = 811,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush2",
          shape = "rectangle",
          x = 1478,
          y = 2018,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_beefalo",
          shape = "rectangle",
          x = 1428,
          y = 1920,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 1483,
          y = 1942,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_beefalo",
          shape = "rectangle",
          x = 1503,
          y = 1890,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_beefalo",
          shape = "rectangle",
          x = 1435,
          y = 2000,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_beefalo",
          shape = "rectangle",
          x = 1193,
          y = 2036,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_beefalo",
          shape = "rectangle",
          x = 1295,
          y = 1955,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush2",
          shape = "rectangle",
          x = 1423,
          y = 2086,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush2",
          shape = "rectangle",
          x = 1411,
          y = 2045,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush2",
          shape = "rectangle",
          x = 1165,
          y = 2088,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush2",
          shape = "rectangle",
          x = 1251,
          y = 2101,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 1176,
          y = 1956,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 1256,
          y = 2036,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS_PARK_TREES",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "quagmire_spotspice_shrub",
          shape = "rectangle",
          x = 2155,
          y = 1192,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_spotspice_shrub",
          shape = "rectangle",
          x = 2197,
          y = 1191,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_spotspice_shrub",
          shape = "rectangle",
          x = 2200,
          y = 1239,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_spotspice_shrub",
          shape = "rectangle",
          x = 2155,
          y = 1238,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_spotspice_shrub",
          shape = "rectangle",
          x = 2032,
          y = 1427,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_spotspice_shrub",
          shape = "rectangle",
          x = 2010,
          y = 907,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_spotspice_shrub",
          shape = "rectangle",
          x = 2181,
          y = 950,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_spotspice_shrub",
          shape = "rectangle",
          x = 2311,
          y = 820,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_spotspice_shrub",
          shape = "rectangle",
          x = 2257,
          y = 1387,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_sugarwoodtree",
          shape = "rectangle",
          x = 2013,
          y = 1309,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_sugarwoodtree",
          shape = "rectangle",
          x = 2077,
          y = 992,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_sugarwoodtree",
          shape = "rectangle",
          x = 2130,
          y = 929,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_sugarwoodtree",
          shape = "rectangle",
          x = 2161,
          y = 1048,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_sugarwoodtree",
          shape = "rectangle",
          x = 2213,
          y = 871,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_sugarwoodtree",
          shape = "rectangle",
          x = 2394,
          y = 851,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_sugarwoodtree",
          shape = "rectangle",
          x = 2404,
          y = 959,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_spotspice_shrub",
          shape = "rectangle",
          x = 2353,
          y = 1006,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_sugarwoodtree",
          shape = "rectangle",
          x = 2369,
          y = 1048,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_sugarwoodtree",
          shape = "rectangle",
          x = 2344,
          y = 1193,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_sugarwoodtree",
          shape = "rectangle",
          x = 2258,
          y = 1287,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_sugarwoodtree",
          shape = "rectangle",
          x = 2232,
          y = 1324,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_sugarwoodtree",
          shape = "rectangle",
          x = 2214,
          y = 1473,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_sugarwoodtree",
          shape = "rectangle",
          x = 2273,
          y = 1428,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_sugarwoodtree",
          shape = "rectangle",
          x = 2136,
          y = 1456,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_sugarwoodtree",
          shape = "rectangle",
          x = 2041,
          y = 1500,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_sugarwoodtree",
          shape = "rectangle",
          x = 1933,
          y = 1431,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 1944,
          y = 1328,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_sugarwoodtree",
          shape = "rectangle",
          x = 2014,
          y = 1063,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_fern",
          shape = "rectangle",
          x = 1949,
          y = 1459,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_fern",
          shape = "rectangle",
          x = 2039,
          y = 1383,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_fern",
          shape = "rectangle",
          x = 2195,
          y = 1041,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_fern",
          shape = "rectangle",
          x = 2203,
          y = 978,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_fern",
          shape = "rectangle",
          x = 2118,
          y = 962,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_fern",
          shape = "rectangle",
          x = 2388,
          y = 1020,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_fern",
          shape = "rectangle",
          x = 2417,
          y = 1078,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_fern",
          shape = "rectangle",
          x = 2260,
          y = 801,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_fern",
          shape = "rectangle",
          x = 2187,
          y = 844,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_fern",
          shape = "rectangle",
          x = 2262,
          y = 901,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_fern",
          shape = "rectangle",
          x = 2042,
          y = 931,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_fern",
          shape = "rectangle",
          x = 2083,
          y = 1489,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_fern",
          shape = "rectangle",
          x = 2002,
          y = 1430,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_sugarwoodtree_normal",
          shape = "rectangle",
          x = 1959,
          y = 1122,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_sugarwoodtree_normal",
          shape = "rectangle",
          x = 1961,
          y = 1250,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_sugarwoodtree_normal",
          shape = "rectangle",
          x = 2012,
          y = 1122,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_sugarwoodtree_normal",
          shape = "rectangle",
          x = 2016,
          y = 1250,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_sugarwoodtree",
          shape = "rectangle",
          x = 2388,
          y = 1110,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_sugarwoodtree_normal",
          shape = "rectangle",
          x = 1907,
          y = 1251,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_sugarwoodtree_normal",
          shape = "rectangle",
          x = 1905,
          y = 1123,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_spotspice_shrub",
          shape = "rectangle",
          x = 2423,
          y = 999,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_spotspice_shrub",
          shape = "rectangle",
          x = 2347,
          y = 1244,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_spotspice_shrub",
          shape = "rectangle",
          x = 1997,
          y = 1086,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 1758,
          y = 1064,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 2004,
          y = 1012,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_spotspice_shrub",
          shape = "rectangle",
          x = 1870,
          y = 1316,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_fern",
          shape = "rectangle",
          x = 1791,
          y = 1241,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_fern",
          shape = "rectangle",
          x = 1791,
          y = 1331,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_fern",
          shape = "rectangle",
          x = 1855,
          y = 1241,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_fern",
          shape = "rectangle",
          x = 1891,
          y = 1278,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS_PARK_SAPLINGS",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "quagmire_spotspice_shrub",
          shape = "rectangle",
          x = 1967,
          y = 1282,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 2163,
          y = 992,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 2179,
          y = 910,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 2341,
          y = 866,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 2423,
          y = 1126,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 2311,
          y = 1266,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 2215,
          y = 1394,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 2171,
          y = 1500,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_fern",
          shape = "rectangle",
          x = 1857,
          y = 1127,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 1758,
          y = 1032,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS_PARK_DECORE",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "quagmire_lamp_post",
          shape = "rectangle",
          x = 2177,
          y = 1216,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_lamp_post",
          shape = "rectangle",
          x = 1828,
          y = 1304,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_park_urn",
          shape = "rectangle",
          x = 2081,
          y = 1060,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "-90"
          }
        },
        {
          name = "",
          type = "quagmire_lamp_post",
          shape = "rectangle",
          x = 1828,
          y = 1056,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_park_angel",
          shape = "rectangle",
          x = 2367,
          y = 959,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "quagmire_parkspike_row",
          shape = "rectangle",
          x = 1786,
          y = 1254,
          width = 12,
          height = 100,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "quagmire_parkspike_row",
          shape = "rectangle",
          x = 1876,
          y = 1208,
          width = 9,
          height = 52,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "quagmire_parkspike_row",
          shape = "rectangle",
          x = 1797,
          y = 1254,
          width = 71,
          height = 10,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_fern",
          shape = "rectangle",
          x = 1792,
          y = 1128,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_fern",
          shape = "rectangle",
          x = 1816,
          y = 1127,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_parkspike_row",
          shape = "rectangle",
          x = 1786,
          y = 1021,
          width = 12,
          height = 100,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "quagmire_parkspike_row",
          shape = "rectangle",
          x = 1797,
          y = 1114,
          width = 71,
          height = 10,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_parkspike_row",
          shape = "rectangle",
          x = 1876,
          y = 1114,
          width = 9,
          height = 52,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 1760,
          y = 1096,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 1762,
          y = 1271,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 1763,
          y = 1303,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 1762,
          y = 1334,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_park_angel",
          shape = "rectangle",
          x = 2110,
          y = 1026,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "-90"
          }
        },
        {
          name = "",
          type = "quagmire_park_angel",
          shape = "rectangle",
          x = 2051,
          y = 1026,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "-90"
          }
        },
        {
          name = "",
          type = "quagmire_park_angel",
          shape = "rectangle",
          x = 2305,
          y = 897,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "-45"
          }
        },
        {
          name = "",
          type = "quagmire_park_angel2",
          shape = "rectangle",
          x = 2367,
          y = 897,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "-135"
          }
        },
        {
          name = "",
          type = "quagmire_park_urn",
          shape = "rectangle",
          x = 2336,
          y = 929,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "-135"
          }
        },
        {
          name = "",
          type = "quagmire_park_obelisk",
          shape = "rectangle",
          x = 2273,
          y = 1184,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_park_urn",
          shape = "rectangle",
          x = 2144,
          y = 1368,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "90"
          }
        },
        {
          name = "",
          type = "quagmire_park_angel",
          shape = "rectangle",
          x = 2174,
          y = 1406,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "90"
          }
        },
        {
          name = "",
          type = "quagmire_park_angel",
          shape = "rectangle",
          x = 2114,
          y = 1405,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "90"
          }
        },
        {
          name = "",
          type = "quagmire_lamp_post",
          shape = "rectangle",
          x = 2350,
          y = 1118,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_merm_cart2",
          shape = "rectangle",
          x = 2333,
          y = 1079,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_trader_merm2",
          shape = "rectangle",
          x = 2303,
          y = 1103,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "180"
          }
        },
        {
          name = "",
          type = "rabbit",
          shape = "rectangle",
          x = 2303,
          y = 1215,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "rabbit",
          shape = "rectangle",
          x = 2245,
          y = 951,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "rabbit",
          shape = "rectangle",
          x = 2393,
          y = 893,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "rabbit",
          shape = "rectangle",
          x = 2183,
          y = 1447,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_fern",
          shape = "rectangle",
          x = 1834,
          y = 1242,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "tomato",
          type = "minisign",
          shape = "rectangle",
          x = 2328,
          y = 1103,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.drawable.image"] = "quagmire_tomato"
          }
        },
        {
          name = "garlic",
          type = "minisign",
          shape = "rectangle",
          x = 2327,
          y = 1124,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.drawable.image"] = "quagmire_garlic"
          }
        },
        {
          name = "carrot",
          type = "minisign_drawn",
          shape = "rectangle",
          x = 998,
          y = 1448,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.drawable.image"] = "carrot"
          }
        },
        {
          name = "onion",
          type = "minisign_drawn",
          shape = "rectangle",
          x = 1455,
          y = 1497,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.drawable.image"] = "quagmire_onion"
          }
        },
        {
          name = "turnip",
          type = "minisign_drawn",
          shape = "rectangle",
          x = 1197,
          y = 1574,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.drawable.image"] = "quagmire_turnip"
          }
        },
        {
          name = "wheat",
          type = "minisign_drawn",
          shape = "rectangle",
          x = 295,
          y = 2123,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.drawable.image"] = "quagmire_wheat"
          }
        }
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS_PARK_GATE",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "right door",
          type = "quagmire_park_gate",
          shape = "rectangle",
          x = 1876,
          y = 1192,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.swingright"] = "true"
          }
        },
        {
          name = "",
          type = "quagmire_park_gate",
          shape = "rectangle",
          x = 1876,
          y = 1176,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS_FOREST_OTHERS",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "quagmire_mushroomstump",
          shape = "rectangle",
          x = 347,
          y = 1751,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_mushroomstump",
          shape = "rectangle",
          x = 325,
          y = 2183,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_mushroomstump",
          shape = "rectangle",
          x = 232,
          y = 1961,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 475,
          y = 1603,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 384,
          y = 1917,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 455,
          y = 1908,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 607,
          y = 1729,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 871,
          y = 1927,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 809,
          y = 1667,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 1131,
          y = 1973,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 1051,
          y = 2032,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 801,
          y = 1377,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS_FOREST_TREES",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 593,
          y = 1385,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 679,
          y = 1325,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 743,
          y = 1455,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 787,
          y = 1617,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 999,
          y = 1725,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 1083,
          y = 1933,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 1043,
          y = 1968,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 1059,
          y = 2108,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 987,
          y = 2015,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 995,
          y = 1959,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 928,
          y = 2005,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 953,
          y = 1912,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 960,
          y = 1821,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 1005,
          y = 1872,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 911,
          y = 1767,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 836,
          y = 1748,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 893,
          y = 1828,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 872,
          y = 1876,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 899,
          y = 1956,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 860,
          y = 2016,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 815,
          y = 1955,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 821,
          y = 1884,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 769,
          y = 1831,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 800,
          y = 1769,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 768,
          y = 1700,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 717,
          y = 1688,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 661,
          y = 1624,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 677,
          y = 1561,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 648,
          y = 1511,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 605,
          y = 1445,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 548,
          y = 1451,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 555,
          y = 1515,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 603,
          y = 1593,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 600,
          y = 1668,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 529,
          y = 1740,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 507,
          y = 1639,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 563,
          y = 1680,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 481,
          y = 1716,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 521,
          y = 1680,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 524,
          y = 1608,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 529,
          y = 1555,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 455,
          y = 1561,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 425,
          y = 1612,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 379,
          y = 1720,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 448,
          y = 1648,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 433,
          y = 1736,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 377,
          y = 1768,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 291,
          y = 1700,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 267,
          y = 1804,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 337,
          y = 1699,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 312,
          y = 1745,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 339,
          y = 1815,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 272,
          y = 1860,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 205,
          y = 1889,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 205,
          y = 1947,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 227,
          y = 1991,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 269,
          y = 1960,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 245,
          y = 1895,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 313,
          y = 2005,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 275,
          y = 2085,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 171,
          y = 2095,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 135,
          y = 2032,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 248,
          y = 2137,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 315,
          y = 2120,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 331,
          y = 1961,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 299,
          y = 1907,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 357,
          y = 1865,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 392,
          y = 1819,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 439,
          y = 1789,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 479,
          y = 1775,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 397,
          y = 1979,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 479,
          y = 1968,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 500,
          y = 1856,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 469,
          y = 1815,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 549,
          y = 1808,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 567,
          y = 1900,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 635,
          y = 1816,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 672,
          y = 1748,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 692,
          y = 1841,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 652,
          y = 1925,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 615,
          y = 1868,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 609,
          y = 1961,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 580,
          y = 2037,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 497,
          y = 2097,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 541,
          y = 1989,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 543,
          y = 1939,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 432,
          y = 2056,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 371,
          y = 2093,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 337,
          y = 2031,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 404,
          y = 2023,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 419,
          y = 2141,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 372,
          y = 2215,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 268,
          y = 2356,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 328,
          y = 2389,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 400,
          y = 2320,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 460,
          y = 2416,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 465,
          y = 2285,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 359,
          y = 2271,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 292,
          y = 2216,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 459,
          y = 2209,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 568,
          y = 2352,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 467,
          y = 2533,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 373,
          y = 2457,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 349,
          y = 2163,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 289,
          y = 2177,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 345,
          y = 2221,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 301,
          y = 2277,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 341,
          y = 2333,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 400,
          y = 2279,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 484,
          y = 2248,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 420,
          y = 2216,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 493,
          y = 2164,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 461,
          y = 2124,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 555,
          y = 2161,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 412,
          y = 2095,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 317,
          y = 2079,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 360,
          y = 2131,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 283,
          y = 2136,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 267,
          y = 2261,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 367,
          y = 1995,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 427,
          y = 1835,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 412,
          y = 1757,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 429,
          y = 1684,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 309,
          y = 1851,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 247,
          y = 1935,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 143,
          y = 1909,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 629,
          y = 2097,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 576,
          y = 2105,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 543,
          y = 2075,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 693,
          y = 1975,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 203,
          y = 2039,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 396,
          y = 1528,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 361,
          y = 1581,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS_ROCKY_OTHERS",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "quagmire_pebblecrab",
          shape = "rectangle",
          x = 2166,
          y = 2091,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "quagmire_pebblecrab",
          shape = "rectangle",
          x = 1955,
          y = 2401,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "quagmire_pebblecrab",
          shape = "rectangle",
          x = 1796,
          y = 1858,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "quagmire_pebblecrab",
          shape = "rectangle",
          x = 2081,
          y = 1743,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "quagmire_pebblecrab",
          shape = "rectangle",
          x = 1573,
          y = 2223,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "quagmire_pebblecrab",
          shape = "rectangle",
          x = 1921,
          y = 1880,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "quagmire_pebblecrab",
          shape = "rectangle",
          x = 1593,
          y = 2425,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "quagmire_pebblecrab",
          shape = "rectangle",
          x = 2233,
          y = 2207,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "quagmire_pebblecrab",
          shape = "rectangle",
          x = 1961,
          y = 2533,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "quagmire_pond_salt",
          shape = "rectangle",
          x = 1525,
          y = 2306,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "quagmire_pond_salt",
          shape = "rectangle",
          x = 2011,
          y = 2429,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "quagmire_pond_salt",
          shape = "rectangle",
          x = 2048,
          y = 1698,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 1597,
          y = 2325,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "quagmire_goatkid",
          shape = "rectangle",
          x = 2103,
          y = 1948,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 1809,
          y = 2281,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 2207,
          y = 2120,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 2320,
          y = 2012,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 2333,
          y = 2032,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 2198,
          y = 1774,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 1926,
          y = 2420,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 2205,
          y = 2005,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 2407,
          y = 1667,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 2267,
          y = 1713,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 1624,
          y = 2330,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 1948,
          y = 2458,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 2308,
          y = 1818,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 2097,
          y = 2028,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 2354,
          y = 1827,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 2328,
          y = 1800,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 2188,
          y = 2022,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "minisign",
          shape = "rectangle",
          x = 2182,
          y = 1867,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.drawable.image"] = "quagmire_flour"
          }
        },
        {
          name = "",
          type = "minisign",
          shape = "rectangle",
          x = 1713,
          y = 2384,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.drawable.image"] = "quagmire_coin2"
          }
        },
        {
          name = "",
          type = "minisign",
          shape = "rectangle",
          x = 2228,
          y = 1907,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.drawable.image"] = "quagmire_salt"
          }
        },
        {
          name = "",
          type = "minisign",
          shape = "rectangle",
          x = 2229,
          y = 1866,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.drawable.image"] = "quagmire_spotspice_ground"
          }
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 2217,
          y = 2030,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 1709,
          y = 2398,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 1678,
          y = 2410,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 1749,
          y = 2518,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 1965,
          y = 1900,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 1952,
          y = 1884,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 1741,
          y = 2624,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 1643,
          y = 2581,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "135"
          }
        },
        {
          name = "extinguished",
          type = "firepit",
          shape = "rectangle",
          x = 2410,
          y = 1620,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.fueled.fuel"] = "0",
            ["skinname"] = "firepit_victorian"
          }
        }
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS_ROCKY_RUBBLE",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "quagmire_rubble_carriage",
          shape = "rectangle",
          x = 1615,
          y = 2305,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_rubble_roof",
          shape = "rectangle",
          x = 1821,
          y = 2401,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_rubble_empty",
          shape = "rectangle",
          x = 1695,
          y = 2402,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_rubble_empty",
          shape = "rectangle",
          x = 2207,
          y = 2015,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_rubble_clocktower",
          shape = "rectangle",
          x = 2340,
          y = 2017,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_rubble_empty",
          shape = "rectangle",
          x = 2207,
          y = 1890,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_rubble_carriage",
          shape = "rectangle",
          x = 2094,
          y = 1819,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_lamp_post",
          shape = "rectangle",
          x = 1674,
          y = 2484,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_lamp_post",
          shape = "rectangle",
          x = 1952,
          y = 1809,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_lamp_post",
          shape = "rectangle",
          x = 1728,
          y = 1854,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_lamp_post",
          shape = "rectangle",
          x = 2123,
          y = 2100,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_rubble_bike",
          shape = "rectangle",
          x = 2376,
          y = 1630,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_rubble_chimney2",
          shape = "rectangle",
          x = 2080,
          y = 2013,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_rubble_roof",
          shape = "rectangle",
          x = 2085,
          y = 1882,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_rubble_empty",
          shape = "rectangle",
          x = 2335,
          y = 1823,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_rubble_chimney",
          shape = "rectangle",
          x = 2206,
          y = 1757,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_rubble_pubdoor",
          shape = "rectangle",
          x = 2207,
          y = 2144,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_rubble_cathedral",
          shape = "rectangle",
          x = 1760,
          y = 2528,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_rubble_clock",
          shape = "rectangle",
          x = 1693,
          y = 2268,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_rubble_chimney",
          shape = "rectangle",
          x = 1822,
          y = 2266,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_lamp_post",
          shape = "rectangle",
          x = 1787,
          y = 1800,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_rubble_house",
          shape = "rectangle",
          x = 1956,
          y = 2013,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_rubble_empty",
          shape = "rectangle",
          x = 1955,
          y = 1891,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_lamp_post",
          shape = "rectangle",
          x = 2300,
          y = 1923,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_lamp_post",
          shape = "rectangle",
          x = 1907,
          y = 2165,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_lamp_post",
          shape = "rectangle",
          x = 1844,
          y = 2483,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS_SWAMPIG_VILLAGE",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "quagmire_swampigelder",
          shape = "rectangle",
          x = 956,
          y = 2591,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_swampig_house",
          shape = "rectangle",
          x = 767,
          y = 2559,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_swampig_house",
          shape = "rectangle",
          x = 1089,
          y = 2429,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_swampig_house",
          shape = "rectangle",
          x = 1223,
          y = 2612,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_swampig_house_rubble",
          shape = "rectangle",
          x = 955,
          y = 2881,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_swampig_house_rubble",
          shape = "rectangle",
          x = 875,
          y = 2723,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "pickable",
          type = "quagmire_potato_planted",
          shape = "rectangle",
          x = 1254,
          y = 2440,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.worldgen_planted"] = "true"
          }
        },
        {
          name = "",
          type = "quagmire_evergreen_stump",
          shape = "rectangle",
          x = 1308,
          y = 2623,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_stump",
          shape = "rectangle",
          x = 1334,
          y = 2703,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_stump",
          shape = "rectangle",
          x = 1333,
          y = 2525,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_stump",
          shape = "rectangle",
          x = 1236,
          y = 2711,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_stump",
          shape = "rectangle",
          x = 1270,
          y = 2835,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_stump",
          shape = "rectangle",
          x = 1373,
          y = 2772,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_stump",
          shape = "rectangle",
          x = 1195,
          y = 2909,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_stump",
          shape = "rectangle",
          x = 1146,
          y = 2867,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_stump",
          shape = "rectangle",
          x = 982,
          y = 2997,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_stump",
          shape = "rectangle",
          x = 783,
          y = 3099,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_stump",
          shape = "rectangle",
          x = 732,
          y = 2981,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_stump",
          shape = "rectangle",
          x = 652,
          y = 2854,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_stump",
          shape = "rectangle",
          x = 580,
          y = 2745,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_stump",
          shape = "rectangle",
          x = 666,
          y = 2526,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_stump",
          shape = "rectangle",
          x = 738,
          y = 2448,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_stump",
          shape = "rectangle",
          x = 802,
          y = 2351,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_stump",
          shape = "rectangle",
          x = 928,
          y = 2258,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_stump",
          shape = "rectangle",
          x = 984,
          y = 2392,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_stump",
          shape = "rectangle",
          x = 1138,
          y = 2322,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_stump",
          shape = "rectangle",
          x = 1182,
          y = 2400,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_mushroomstump",
          shape = "rectangle",
          x = 733,
          y = 2680,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "pickable",
          type = "quagmire_potato_planted",
          shape = "rectangle",
          x = 1230,
          y = 2450,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.worldgen_planted"] = "true"
          }
        },
        {
          name = "rotten",
          type = "quagmire_potato_planted",
          shape = "rectangle",
          x = 1269,
          y = 2464,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "pickable",
          type = "quagmire_potato_planted",
          shape = "rectangle",
          x = 1225,
          y = 2484,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.worldgen_planted"] = "true"
          }
        },
        {
          name = "pickable",
          type = "quagmire_potato_planted",
          shape = "rectangle",
          x = 1272,
          y = 2490,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.worldgen_planted"] = "true"
          }
        },
        {
          name = "rotten",
          type = "quagmire_potato_planted",
          shape = "rectangle",
          x = 1241,
          y = 2473,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_swampig_house_rubble",
          shape = "rectangle",
          x = 900,
          y = 2422,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_swampig_house_rubble",
          shape = "rectangle",
          x = 1165,
          y = 2763,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_swampig_house",
          shape = "rectangle",
          x = 1022,
          y = 2819,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_swampig",
          shape = "rectangle",
          x = 1123,
          y = 2579,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_swampig",
          shape = "rectangle",
          x = 919,
          y = 2622,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_swampig",
          shape = "rectangle",
          x = 1003,
          y = 2754,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_swampig",
          shape = "rectangle",
          x = 1108,
          y = 2787,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_stump",
          shape = "rectangle",
          x = 876,
          y = 3027,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_stump",
          shape = "rectangle",
          x = 555,
          y = 2570,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_stump",
          shape = "rectangle",
          x = 452,
          y = 2474,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_stump",
          shape = "rectangle",
          x = 612,
          y = 2434,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_stump",
          shape = "rectangle",
          x = 813,
          y = 2188,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "minisign",
          shape = "rectangle",
          x = 1251,
          y = 2492,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.drawable.image"] = "quagmire_potato"
          }
        },
        {
          name = "",
          type = "quagmire_campfire",
          shape = "rectangle",
          x = 1027,
          y = 2653,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS_MERMS_STRUCTURES",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "quagmire_lamp_post",
          shape = "rectangle",
          x = 1396,
          y = 691,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_lamp_post",
          shape = "rectangle",
          x = 1162,
          y = 688,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 2073,
          y = 419,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 2051,
          y = 371,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 2024,
          y = 340,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 2132,
          y = 345,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 2238,
          y = 380,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 2168,
          y = 379,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 2222,
          y = 324,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 2258,
          y = 301,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 2261,
          y = 252,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 2176,
          y = 282,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 2129,
          y = 243,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 2091,
          y = 296,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 2130,
          y = 289,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 2076,
          y = 272,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 1943,
          y = 270,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 2003,
          y = 293,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 2213,
          y = 248,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 1851,
          y = 262,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 1894,
          y = 297,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 1832,
          y = 326,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 1610,
          y = 273,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 1778,
          y = 360,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 1633,
          y = 212,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 1681,
          y = 197,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 1849,
          y = 370,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 2301,
          y = 316,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen",
          shape = "rectangle",
          x = 1987,
          y = 379,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 1748,
          y = 382,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 2107,
          y = 446,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 2206,
          y = 387,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 1664,
          y = 259,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 1535,
          y = 347,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 1589,
          y = 450,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 1679,
          y = 411,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 1216,
          y = 681,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 1176,
          y = 631,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 1241,
          y = 479,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 1398,
          y = 639,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 1237,
          y = 592,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_small",
          shape = "rectangle",
          x = 1195,
          y = 590,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_small",
          shape = "rectangle",
          x = 1154,
          y = 611,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_small",
          shape = "rectangle",
          x = 1403,
          y = 583,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_small",
          shape = "rectangle",
          x = 1350,
          y = 619,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_small",
          shape = "rectangle",
          x = 1274,
          y = 518,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_small",
          shape = "rectangle",
          x = 1305,
          y = 461,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_small",
          shape = "rectangle",
          x = 1479,
          y = 499,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_small",
          shape = "rectangle",
          x = 1365,
          y = 404,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_small",
          shape = "rectangle",
          x = 1636,
          y = 442,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_small",
          shape = "rectangle",
          x = 1718,
          y = 422,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_small",
          shape = "rectangle",
          x = 1259,
          y = 703,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "quagmire_evergreen_small",
          shape = "rectangle",
          x = 1341,
          y = 766,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
