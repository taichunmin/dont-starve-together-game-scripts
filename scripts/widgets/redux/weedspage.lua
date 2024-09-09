local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"

local WEED_DEFS = {}--require("prefabs/weed_defs").WEED_DEFS

local WeedsPage = Class(Widget, function(self, parent, ismodded)
    Widget._ctor(self, "WeedsPage")

end)

return WeedsPage