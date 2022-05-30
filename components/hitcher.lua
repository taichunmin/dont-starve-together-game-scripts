local function onhitched(self)
    if self.canbehitched then
        self.inst:AddTag("hitcher")
    else
        self.inst:RemoveTag("hitcher")
    end
end

local function onlocked(self)
    if self.locked then
        self.inst:AddTag("hitcher_locked")
    else
        self.inst:RemoveTag("hitcher_locked")
    end
end

local Hitcher = Class(function(self, inst)
	self.inst = inst
	self.hitched = nil
	self.canbehitched = true
	self.locked = false
end,
nil,
{
    canbehitched = onhitched,
    locked = onlocked,
})

function Hitcher:GetHitched()
	return self.hitched
end

function Hitcher:SetHitched( target )
	self.canbehitched = false
	self.hitched = target

	if target.components.hitchable then
		target.components.hitchable:SetHitched( self.inst )
	end
	--self.hitched:AddTag("hitched")
	if self.hitchedfn then
		self.hitchedfn(self.inst, self.hitched)
	end
end

function Hitcher:Unhitch()
	self.canbehitched = true
	--self.hitched:RemoveTag("hitched")
	local oldtarget = self.hitched
	if self.hitched and not self.hitched.components.hitchable.canbehitched then
		self.hitched.components.hitchable:Unhitch()
	end
	if self.unhitchfn then
		self.unhitchfn(self.inst,oldtarget)
	end
	self.hitched = nil
	self.inst:PushEvent("unhitched")
end

function Hitcher:Lock(setting)
	self.locked = setting
end

function Hitcher:OnSave()
	local data = {}
	return data
end

function Hitcher:OnLoad(data)

end

return Hitcher
