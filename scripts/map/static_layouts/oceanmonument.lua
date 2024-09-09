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
      width = 8,
      height = 8,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        26, 26, 26, 26, 26, 26, 26, 26,
        26, 26, 26, 19, 19, 26, 26, 26,
        26, 26, 19, 19, 19, 19, 26, 26,
        26, 19, 19, 19, 19, 19, 19, 26,
        26, 19, 19, 19, 19, 19, 19, 26,
        26, 26, 19, 19, 19, 19, 26, 26,
        26, 26, 26, 19, 19, 26, 26, 26,
        26, 26, 26, 26, 26, 26, 26, 26
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
          type = "sunkenchest",
          shape = "rectangle",
          x = 246,
          y = 246,
          width = 19,
          height = 19,
          visible = true,
          properties = {
            ["scenario"] = "sunkenchest_oceanmonument"
          }
        },
        {
          name = "",
          type = "seastack",
          shape = "rectangle",
          x = 297,
          y = 352,
          width = 10,
          height = 10,
          visible = true,
          properties = {
            ["data.stackid"] = "1"
          }
        },
        {
          name = "",
          type = "seastack",
          shape = "rectangle",
          x = 213,
          y = 353,
          width = 10,
          height = 10,
          visible = true,
          properties = {
            ["data.stackid"] = "4"
          }
        },
        {
          name = "",
          type = "seastack",
          shape = "rectangle",
          x = 153,
          y = 294,
          width = 10,
          height = 10,
          visible = true,
          properties = {
            ["data.stackid"] = "1"
          }
        },
        {
          name = "",
          type = "seastack",
          shape = "rectangle",
          x = 152,
          y = 210,
          width = 10,
          height = 10,
          visible = true,
          properties = {
            ["data.stackid"] = "4"
          }
        },
        {
          name = "",
          type = "seastack",
          shape = "rectangle",
          x = 211,
          y = 150,
          width = 10,
          height = 10,
          visible = true,
          properties = {
            ["data.stackid"] = "1"
          }
        },
        {
          name = "",
          type = "seastack",
          shape = "rectangle",
          x = 295,
          y = 149,
          width = 10,
          height = 10,
          visible = true,
          properties = {
            ["data.stackid"] = "4"
          }
        },
        {
          name = "",
          type = "seastack",
          shape = "rectangle",
          x = 355,
          y = 208,
          width = 10,
          height = 10,
          visible = true,
          properties = {
            ["data.stackid"] = "1"
          }
        },
        {
          name = "",
          type = "seastack",
          shape = "rectangle",
          x = 356,
          y = 292,
          width = 10,
          height = 10,
          visible = true,
          properties = {
            ["data.stackid"] = "4"
          }
        }
      }
    }
  }
}
