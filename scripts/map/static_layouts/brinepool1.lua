return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 14,
  height = 14,
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
      width = 14,
      height = 14,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 20, 20, 20, 20, 20, 20, 0, 0, 0,
        0, 0, 0, 20, 20, 20, 20, 20, 20, 20, 20, 20, 0, 0,
        0, 0, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 0,
        0, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 0,
        0, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 0, 0,
        0, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 0, 0, 0,
        0, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 0, 0, 0,
        0, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 0, 0, 0,
        0, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 0, 0, 0,
        0, 0, 20, 20, 20, 20, 20, 20, 20, 20, 0, 0, 0, 0,
        0, 0, 0, 20, 20, 20, 20, 20, 20, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 20, 20, 20, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
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
          type = "saltstack_area",
          shape = "rectangle",
          x = 215,
          y = 276,
          width = 75,
          height = 53,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "saltstack_area",
          shape = "rectangle",
          x = 486,
          y = 279,
          width = 95,
          height = 28,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "saltstack_area",
          shape = "rectangle",
          x = 211,
          y = 545,
          width = 86,
          height = 80,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "saltstack_area",
          shape = "rectangle",
          x = 379,
          y = 425,
          width = 47,
          height = 81,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "saltstack_area",
          shape = "rectangle",
          x = 342,
          y = 223,
          width = 82,
          height = 136,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "saltstack_area",
          shape = "rectangle",
          x = 473,
          y = 570,
          width = 43,
          height = 72,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "saltstack_area",
          shape = "rectangle",
          x = 496,
          y = 345,
          width = 55,
          height = 59,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "saltstack_area",
          shape = "rectangle",
          x = 354,
          y = 548,
          width = 57,
          height = 110,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "saltstack_area",
          shape = "rectangle",
          x = 152,
          y = 363,
          width = 74,
          height = 126,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "saltstack_area",
          shape = "rectangle",
          x = 500,
          y = 180,
          width = 88,
          height = 67,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "cookiecutter_spawner",
          shape = "rectangle",
          x = 327,
          y = 520,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "saltstack_area",
          shape = "rectangle",
          x = 283,
          y = 398,
          width = 47,
          height = 81,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "cookiecutter_spawner",
          shape = "rectangle",
          x = 466,
          y = 317,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
