return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 4,
  height = 4,
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
      width = 4,
      height = 4,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        20, 20, 20, 20,
        20, 20, 20, 20,
        20, 20, 20, 20,
        20, 20, 20, 20
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
          x = 88,
          y = 119,
          width = 102,
          height = 18,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "saltstack_area",
          shape = "rectangle",
          x = 46,
          y = 144,
          width = 28,
          height = 81,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "saltstack_area",
          shape = "rectangle",
          x = 58,
          y = 15,
          width = 57,
          height = 77,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "saltstack_area",
          shape = "rectangle",
          x = 102,
          y = 155,
          width = 55,
          height = 59,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "saltstack_area",
          shape = "rectangle",
          x = 161,
          y = 26,
          width = 64,
          height = 68,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "cookiecutter_spawner",
          shape = "rectangle",
          x = 132,
          y = 124,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
