local function onhitchable(self)
    if self.canbehitched then
    	self.inst:RemoveTag("hitched")
    else
    	self.inst:AddTag("hitched")
    end
end

local Hitchable = Class(function(self, inst)
	self.inst = inst
	self.hitched = nil
	self.canbehitched = true
end,
nil,
{
    canbehitched = onhitchable,
})

function onnewtarget(inst)
	inst.components.hitchable:Unhitch()
end

function Hitchable:SetHitched( target )
	self.inst.SoundEmitter:PlaySound("yotb_2021/common/hitching_post/hitching")
	self.inst:ListenForEvent("newcombattarget",onnewtarget)
	self.canbehitched = false
	self.hitched = target

end

function Hitchable:Unhitch()
	self.inst.SoundEmitter:PlaySound("yotb_2021/common/hitching_post/unhitching")
	self.inst:RemoveEventCallback("newcombattarget",onnewtarget)
	self.canbehitched = true
	if self.hitched and not self.hitched.components.canbehitched then
		self.hitched.components.hitcher:Unhitch()
	end
	self.hitched = nil
end

function Hitchable:GetHitch()
	return self.hitched
end

function Hitchable:OnSave()
	local data = {}
	return data
end

function Hitchable:OnLoad(data)

end

return Hitchable
