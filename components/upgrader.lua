local function onupgradetype(self, newtype, oldtype)
	if oldtype then
		self.inst:RemoveTag(oldtype.."_upgrader")
	end
	if newtype then
		self.inst:AddTag(newtype.."_upgrader")
	end
end

local Upgrader = Class(function(self,inst)
	self.inst = inst

	self.upgradetype = UPGRADETYPES.DEFAULT
	self.upgradevalue = 1
end,
nil,
{
	upgradetype = onupgradetype,
})

function Upgrader:CanUpgrade(target, doer)
	if not self.upgradetype == target.components.upgradeable.upgradetype then
		return false
	end
	if not doer:HasTag(self.upgradetype.."_upgradeuser") then
		return false
	end
	return true
end

return Upgrader