local Widget = require "widgets/widget"
local Image = require "widgets/image"

local QuagmireTileBG = Class(Widget, function(self, atlas, tileim, sepim)
    Widget._ctor(self, "TileBG")

    self.atlas = atlas
    self.sepim = sepim

    self.seps = nil
end)

function QuagmireTileBG:SetNumTiles(numtiles)
    self:KillAllChildren()

    self.seps = {}
    if self.sepim and numtiles > 1 then
        for k = 1, numtiles-1 do
            self.seps[k] = self:AddChild(Image(self.atlas, self.sepim))
        end
    end
end

return QuagmireTileBG
