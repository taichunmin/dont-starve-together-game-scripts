local SourceModifierList = require "util/sourcemodifierlist"

local BirdAttractor = Class(function(self, inst)
    self.inst = inst

    -- This modifier is using multple keys, always call CalculateModifierFromKey() with "maxbirds", "mindelay" or "maxdelay"
    self.spawnmodifier = SourceModifierList(inst, 0, SourceModifierList.additive)
end)

function BirdAttractor:GetDebugString()
    local str = string.format("maxbirds:%d, mindelay:%d, maxdelay:%d", self.spawnmodifier:CalculateModifierFromKey("maxbirds"), self.spawnmodifier:CalculateModifierFromKey("mindelay"), self.spawnmodifier:CalculateModifierFromKey("maxdelay"))
    return str
end

return BirdAttractor
