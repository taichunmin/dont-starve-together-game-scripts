return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 15,
  height = 15,
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
      width = 15,
      height = 15,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 18, 18, 18, 18, 18, 18, 18, 0, 0,
        0, 0, 0, 0, 18, 18, 18, 44, 44, 44, 44, 44, 18, 18, 18,
        0, 0, 18, 18, 18, 44, 44, 44, 44, 44, 44, 44, 44, 44, 18,
        0, 0, 18, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 18,
        0, 18, 18, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 18,
        18, 18, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 18,
        18, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 18,
        18, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 18,
        18, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 18,
        18, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 18,
        18, 18, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 18,
        0, 18, 18, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 18,
        0, 0, 18, 18, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 18,
        0, 0, 0, 18, 18, 18, 44, 44, 44, 44, 44, 44, 44, 18, 18,
        0, 0, 0, 0, 0, 18, 18, 18, 18, 18, 18, 18, 18, 18, 0
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
          type = "watertree_pillar",
          shape = "rectangle",
          x = 664,
          y = 605,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "watertree_pillar",
          shape = "rectangle",
          x = 360,
          y = 405,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "",
          shape = "rectangle",
          x = 580,
          y = 649,
          width = 293,
          height = 225,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "",
          shape = "rectangle",
          x = 324,
          y = 524,
          width = 236,
          height = 288,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "",
          shape = "rectangle",
          x = 132,
          y = 325,
          width = 175,
          height = 363,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "",
          shape = "rectangle",
          x = 389,
          y = 135,
          width = 177,
          height = 369,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "",
          shape = "rectangle",
          x = 589,
          y = 144,
          width = 292,
          height = 224,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "",
          shape = "rectangle",
          x = 580,
          y = 392,
          width = 309,
          height = 172,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
