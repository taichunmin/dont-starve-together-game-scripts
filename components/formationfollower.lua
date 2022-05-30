local function onformationtype(self, formation, oldformation)
    if oldformation ~= nil then
        self.inst:RemoveTag("formation_"..oldformation)
    end
    if formation ~= nil then
        self.inst:AddTag("formation_"..formation)
		self.formationsearchtags = {"formationleader_"..formation}
    else
		self.formationsearchtags = nil
	end
end

local function onactive(self, active, oldactive)
	if active then
		if not oldactive then
			self.inst:StartUpdatingComponent(self)
		end
	elseif oldactive then
		self.inst:StopUpdatingComponent(self)
	end
end

local FormationFollower = Class(function(self, inst)
	self.inst = inst
	self.in_formation = false
	self.formationleader = nil
	self.formationpos = nil
	self.searchradius = 50
	self.leashdistance = 70
	self.inst:StartUpdatingComponent(self)
	self.formation_type = "monster"

	self.active = false
	--self.onupdatefn = nil

	-- These are called from formationleader
	--self.onleaveformationfn = nil
	--self.onenterformationfn = nil
end,
nil,
{
    formation_type = onformationtype,
})

function FormationFollower:GetDebugString()
	local str = string.format("In Formation %s, active: %s",
		tostring(self.in_formation), self.active and "true" or "false")
	return str
end

function FormationFollower:StartUpdating()
	self.inst:StartUpdatingComponent(self)
end

function FormationFollower:StopUpdating()
	self.inst:StopUpdatingComponent(self)
end

function FormationFollower:SearchForFormation(override_find_entities)
	local pt = self.inst:GetPosition()
	local ents = override_find_entities or TheSim:FindEntities(pt.x, pt.y, pt.z, self.searchradius, self.formationsearchtags)

	for k,v in pairs(ents) do
		if not v.components.formationleader:IsFormationFull() then
			v.components.formationleader:NewFormationMember(self.inst)
			return true
		end
    end
end

function FormationFollower:OnEntitySleep()
	if self.formationleader then
		self.formationleader:OnLostFormationMember(self.inst)
	end
	self.inst:StopUpdatingComponent(self)
end

function FormationFollower:OnEntityWake()
	-- Entity wakes up when put in inventory
	if self.inst.components.inventoryitem ~= nil and self.inst.components.inventoryitem:GetContainer() then
		return
	end

	self.inst:StartUpdatingComponent(self)
end

function FormationFollower:LeaveFormation()
	if self.formationleader then
		self.formationleader:OnLostFormationMember(self.inst)
	end
end

function FormationFollower:OnUpdate(dt)
	-- if not self.active or self.onupdatefn == nil then return end
	if self.onupdatefn == nil then return end

	if self.formationleader ~= nil and self.formationpos ~= nil then
		self.onupdatefn(self.inst, self.formationpos)
	end
end

return FormationFollower
