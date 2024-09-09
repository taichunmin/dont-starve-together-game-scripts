local function onenabled(self, enabled)
    if enabled then
        self.inst:AddTag("carnivalgame_canfeed")
    else
        self.inst:RemoveTag("carnivalgame_canfeed")
    end
end

local CarnivalGameFeedable = Class(function(self, inst)
    self.inst = inst

    self.enabled = false

	self.OnFeed = nil
end,
nil,
{
    enabled = onenabled,
})

function CarnivalGameFeedable:DoFeed(doer, item)
    if self.OnFeed ~= nil then
        return self.OnFeed(self.inst, doer, item)
    end
	return false
end

return CarnivalGameFeedable