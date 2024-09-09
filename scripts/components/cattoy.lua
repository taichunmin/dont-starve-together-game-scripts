-- Consider adding the "cattoy" or "cattoyairborne" in conjunction with adding this component.
-- While this component can behave without them, some creatures use that tag to identify items to play with.

local CatToy = Class(function(self, inst)
    self.inst = inst
    self.onplay_fn = nil
end)

function CatToy:SetOnPlay(fn)
    self.onplay_fn = fn
end

function CatToy:Play(doer, is_airborne)
	if self.onplay_fn ~= nil then
		return self.onplay_fn(self.inst, doer, is_airborne)
	end
    return false
end

return CatToy
