local Vanish_on_sleep = Class(function(self, inst)
	self.inst = inst
	--self.vanishfn = nil
	--self.vanish_task = nil
end)

local function DoVanish(inst, self)
	self:vanish()
end

function Vanish_on_sleep:OnEntitySleep()
	if self.vanish_task == nil then
		self.vanish_task = self.inst:DoTaskInTime(10, DoVanish, self)
	end
end

function Vanish_on_sleep:OnEntityWake()
	if self.vanish_task ~= nil then
		self.vanish_task:Cancel()
		self.vanish_task = nil
	end
end

--same thing: just cancelling task
Vanish_on_sleep.OnRemoveFromEntity = Vanish_on_sleep.OnEntityWake

function Vanish_on_sleep:vanish()
	if self.vanishfn then
		self.vanishfn(self.inst)
	end
	self.inst:Remove()
end

return Vanish_on_sleep
