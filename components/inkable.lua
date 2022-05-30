local Inkable = Class(function(self, inst)
    self.inst = inst
    self.inked = nil
    self.inktime = 0
end)

function Inkable:Ink()
	self.inktime = 2

	self.inked = true
	self.inst.player_classified.inked:push()
    --self.inst.SoundEmitter:PlaySound("hookline/creatures/squid/ink")
    self.inst:StartUpdatingComponent(self)
    self.inst:AddDebuff("squid_ink_player_fx", "squid_ink_player_fx")
end

function Inkable:OnUpdate(dt)
	self.inktime = self.inktime - dt
	if self.inktime <= 0 then
		--remove fx
		self.inked = nil
		self.inst:PushEvent("deinked")
		self.inst:RemoveDebuff("squid_ink_player_fx")
		self.inst:StopUpdatingComponent(self)
	end
end

return Inkable
