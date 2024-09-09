
local function onupgradetype(self, newtype, oldtype)
	if self:CanUpgrade() then
		if oldtype then
			self.inst:RemoveTag(oldtype.."_upgradeable")
		end
		if newtype then
			self.inst:AddTag(newtype.."_upgradeable")
		end
	end
end

local function onstage(self)
	if self:CanUpgrade() then
		self.inst:AddTag(self.upgradetype.."_upgradeable")
	else
		self.inst:RemoveTag(self.upgradetype.."_upgradeable")
	end
end

local Upgradeable = Class(function(self,inst)
	self.inst = inst
	self.onstageadvancefn = nil
	self.onupgradefn = nil
	self.upgradetype = UPGRADETYPES.DEFAULT

	self.stage = 1
	self.numstages = 3
	self.upgradesperstage = 5
	self.numupgrades = 0
end,
nil,
{
	upgradetype = onupgradetype,
	stage = onstage,
	numstages = onstage,
})

function Upgradeable:SetOnUpgradeFn(fn)
	self.onupgradefn = fn
end

function Upgradeable:SetCanUpgradeFn(fn)
	self.canupgradefn = fn
end

function Upgradeable:GetStage()
	return self.stage
end

function Upgradeable:SetStage(num)
	self.stage = num
end

function Upgradeable:AdvanceStage()
	self.stage = self.stage + 1
	self.numupgrades = 0

	if self.onstageadvancefn then
		return self.onstageadvancefn(self.inst)
	end
end

function Upgradeable:CanUpgrade()
	local not_at_max = self.stage and self.numstages and self.stage < self.numstages

	if self.canupgradefn then
		local can_upgrade, reason = self.canupgradefn(self.inst)
		if can_upgrade then
			return can_upgrade and not_at_max
		end

		return false, reason
	end

	return not_at_max
end

function Upgradeable:Upgrade(obj, upgrade_performer)
	self.numupgrades = self.numupgrades + obj.components.upgrader.upgradevalue

	if obj.components.stackable then
		obj.components.stackable:Get(1):Remove()
	else
		obj:Remove()
	end

	if self.onupgradefn then
		self.onupgradefn(self.inst, upgrade_performer, obj)
	end

	if self.numupgrades >= self.upgradesperstage then
		self:AdvanceStage()
	end

	return true
end

function Upgradeable:OnSave()
	local data = {}
	data.numupgrades = self.numupgrades
	data.stage = self.stage
	return data
end

function Upgradeable:OnLoad(data)
	self.numupgrades = data.numupgrades
	self.stage = data.stage
end

return Upgradeable