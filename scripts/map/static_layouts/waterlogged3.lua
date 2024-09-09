return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 20,
  height = 20,
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
      width = 20,
      height = 20,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 18, 18, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 18, 18, 18, 44, 18, 18, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 18, 44, 44, 44, 44, 44, 44, 18, 18, 18, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 18, 44, 44, 44, 44, 44, 44, 44, 44, 18, 18, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 18, 18, 44, 44, 44, 44, 44, 44, 44, 44, 18, 18, 0, 0, 0, 0,
        0, 0, 0, 0, 18, 18, 44, 44, 44, 44, 44, 44, 44, 44, 44, 18, 18, 0, 0, 0,
        0, 0, 0, 0, 18, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 18, 18, 0, 0,
        0, 0, 0, 0, 18, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 18, 0, 0,
        0, 0, 0, 0, 18, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 18, 0, 0,
        0, 0, 0, 18, 18, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 18, 18, 0,
        0, 0, 18, 18, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 18, 0,
        0, 0, 18, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 18, 0,
        0, 18, 18, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 18, 0,
        18, 18, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 18, 18, 0,
        18, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 18, 0, 0,
        18, 18, 18, 18, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 18, 18, 0, 0,
        0, 0, 0, 18, 18, 18, 44, 44, 44, 44, 44, 44, 44, 44, 18, 18, 18, 0, 0, 0,
        0, 0, 0, 0, 0, 18, 18, 18, 18, 44, 44, 44, 18, 18, 18, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 18, 18, 18, 18, 18, 0, 0, 0, 0, 0, 0, 0
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
          x = 599,
          y = 864,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "watertree_pillar",
          shape = "rectangle",
          x = 737,
          y = 547,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "treearea",
          shape = "rectangle",
          x = 788,
          y = 529,
          width = 277,
          height = 287,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "treearea",
          shape = "rectangle",
          x = 707,
          y = 847,
          width = 307,
          height = 227,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "treearea",
          shape = "rectangle",
          x = 392,
          y = 905,
          width = 301,
          height = 231,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "treearea",
          shape = "rectangle",
          x = 579,
          y = 564,
          width = 198,
          height = 269,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "treearea",
          shape = "rectangle",
          x = 336,
          y = 643,
          width = 231,
          height = 247,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "treearea",
          shape = "rectangle",
          x = 396,
          y = 264,
          width = 175,
          height = 361,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "treearea",
          shape = "rectangle",
          x = 584,
          y = 261,
          width = 237,
          height = 240,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "",
          shape = "rectangle",
          x = 1540,
          y = 308,
          width = 4,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
