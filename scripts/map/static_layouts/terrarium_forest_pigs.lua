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
      width = 5,
      height = 5,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        7, 7, 7, 7, 7,
        7, 7, 7, 7, 7,
        7, 7, 7, 7, 7,
        7, 7, 7, 7, 7,
        7, 7, 7, 7, 7
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
          type = "terrariumchest",
          shape = "rectangle",
          x = 158,
          y = 160,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["scenario"] = "chest_terrarium_pigs"
          }
        },
        {
          name = "",
          type = "pigtorch",
          shape = "rectangle",
          x = 211,
          y = 107,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pigtorch",
          shape = "rectangle",
          x = 106,
          y = 108,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pigtorch",
          shape = "rectangle",
          x = 108,
          y = 211,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pigtorch",
          shape = "rectangle",
          x = 210,
          y = 212,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush2",
          shape = "rectangle",
          x = 145,
          y = 126,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush2",
          shape = "rectangle",
          x = 194,
          y = 160,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush2",
          shape = "rectangle",
          x = 123,
          y = 157,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush2",
          shape = "rectangle",
          x = 178,
          y = 190,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush2",
          shape = "rectangle",
          x = 178,
          y = 125,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush2",
          shape = "rectangle",
          x = 140,
          y = 189,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 267,
          y = 180,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 249,
          y = 296,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 92,
          y = 24,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 36,
          y = 141,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "flower",
          shape = "rectangle",
          x = 44,
          y = 291,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "flower",
          shape = "rectangle",
          x = 185,
          y = 37,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 292,
          y = 35,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
