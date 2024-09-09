local KitcoonDen = Class(function(self, inst)
    self.inst = inst

	self.kitcoons = {}
	self.num_kitcoons = 0
	--self.OnAddKitcoon = nil
	--self.OnRemoveKitcoon = nil

	self.onremove_kitcoon = function(kitcoon) 
		if self.kitcoons[kitcoon] ~= nil then
			self.kitcoons[kitcoon] = nil 
			self.num_kitcoons = self.num_kitcoons - 1
			self.inst:RemoveEventCallback("onremove", self.onremove_kitcoon, kitcoon) 
			if self.OnRemoveKitcoon ~= nil then
				self.OnRemoveKitcoon(self.inst, kitcoon)
			end
		end
	end

end)

function KitcoonDen:OnRemoveFromEntity()
	for _, v in pairs(self.kitcoons) do
		self.onremove_kitcoon(v)
	end
end

function KitcoonDen:AddKitcoon(kitcoon, doer)
	if self.kitcoons[kitcoon] == nil then
		self.kitcoons[kitcoon] = kitcoon
		self.num_kitcoons = self.num_kitcoons + 1
		self.inst:ListenForEvent("onremove", self.onremove_kitcoon, kitcoon)
		if self.OnAddKitcoon ~= nil then
			self.OnAddKitcoon(self.inst, kitcoon, doer)
		end
	end
end

function KitcoonDen:RemoveKitcoon(kitcoon)
	self.onremove_kitcoon(kitcoon)
end

function KitcoonDen:RemoveAllKitcoons()
	for _, v in pairs(self.kitcoons) do
		self.onremove_kitcoon(v)
	end
end

function KitcoonDen:GetDebugString()
    return "Count:" .. self.num_kitcoons
end

return KitcoonDen
