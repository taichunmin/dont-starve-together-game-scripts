return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 6,
  height = 6,
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
      width = 6,
      height = 6,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        26, 26, 26, 26, 26, 26,
        26, 26, 26, 26, 26, 26,
        26, 26, 26, 26, 26, 26,
        26, 26, 26, 26, 26, 26,
        26, 26, 26, 26, 26, 26,
        26, 26, 26, 26, 26, 26
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
          type = "boat",
          shape = "ellipse",
          x = 128,
          y = 128,
          width = 128,
          height = 128,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.3"
          }
        },
        {
          name = "",
          type = "mast_area",
          shape = "rectangle",
          x = 192,
          y = 192,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "item_area1",
          shape = "rectangle",
          x = 215,
          y = 190,
          width = 17,
          height = 26,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "item_area2",
          shape = "rectangle",
          x = 181,
          y = 210,
          width = 24,
          height = 30,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "oceanfishingrod",
          shape = "rectangle",
          x = 166,
          y = 149,
          width = 15,
          height = 14,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "treasurechest",
          shape = "rectangle",
          x = 156,
          y = 212,
          width = 15,
          height = 14,
          visible = true,
          properties = {
            ["scenario"] = "chest_abandonedboat"
          }
        },
        {
          name = "",
          type = "tacklecontainer",
          shape = "rectangle",
          x = 217,
          y = 167,
          width = 15,
          height = 14,
          visible = true,
          properties = {
            ["scenario"] = "tacklecontainer_fishing"
          }
        },
        {
          name = "",
          type = "skeleton",
          shape = "rectangle",
          x = 195,
          y = 151,
          width = 14,
          height = 13,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "fishing_item_area",
          shape = "rectangle",
          x = 156,
          y = 174,
          width = 14,
          height = 13,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "seastack_area",
          shape = "rectangle",
          x = 91,
          y = 53,
          width = 199,
          height = 37,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "seastack_area",
          shape = "rectangle",
          x = 294,
          y = 112,
          width = 41,
          height = 156,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "seastack_area",
          shape = "rectangle",
          x = 48,
          y = 120,
          width = 36,
          height = 193,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "seastack_area",
          shape = "rectangle",
          x = 110,
          y = 294,
          width = 193,
          height = 36,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
