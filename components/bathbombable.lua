
local function on_can_be_bathbombed(self, enabled)
	if enabled then
        self.inst:AddTag("bathbombable")
	else
        self.inst:RemoveTag("bathbombable")
	end
end

local BathBombable = Class(function(self, inst)
    self.inst = inst

    self.onbathbombedfn = nil
	self.can_be_bathbombed = true
	self.is_bathbombed = false
end,
nil,
{
	can_be_bathbombed = on_can_be_bathbombed,
})

function BathBombable:OnRemoveFromEntity()
    self.inst:RemoveTag("bathbombable")
end

function BathBombable:SetOnBathBombedFn(new_fn)
    self.onbathbombedfn = new_fn
end

function BathBombable:OnBathBombed(item, doer)
	self.is_bathbombed = true
	self.can_be_bathbombed = false

    if self.onbathbombedfn ~= nil then
        self.onbathbombedfn(self.inst, item, doer)
    end
end

function BathBombable:DisableBathBombing()
	self.is_bathbombed = false
    self.can_be_bathbombed = false
end

function BathBombable:Reset()
	self.is_bathbombed = false
    self.can_be_bathbombed = true
end

return BathBombable
