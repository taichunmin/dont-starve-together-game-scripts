
local function oninactive(self, inactive)
    self.inst:AddOrRemoveTag("pocketwatch_inactive", inactive)
end

local PocketWatch = Class(function(self, inst)
    self.inst = inst

	self.inactive = true
end,
nil,
{
    inactive = oninactive,
})

function PocketWatch:OnRemoveFromEntity()
    self.inst:RemoveTag("pocketwatch_inactive")
end


function PocketWatch:CanCast(doer, target, pos)
	return self.inactive and (self.CanCastFn == nil or self.CanCastFn(self.inst, doer, target, pos))
end

function PocketWatch:CastSpell(doer, target, pos)
    if self.DoCastSpell ~= nil and self.inactive then
        local success, reason = self.DoCastSpell(self.inst, doer, target, pos)
        return success, reason
    else
        return false
    end
end

return PocketWatch
