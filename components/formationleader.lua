local function onformationtype(self, formation, oldformation)
    if oldformation ~= nil then
        self.inst:RemoveTag("formationleader_"..oldformation)
    end
    if formation ~= nil then
        self.inst:AddTag("formationleader_"..formation)
		self.formationleadersearchtags = {"formationleader_"..formation}
		self.formationsearchtags = {"formation_"..formation}
    else
		self.formationleadersearchtags = nil
		self.formationsearchtags = nil
    end
end

local function DefaultMakeOtherFormationsSecondary(inst, formations)
	local firstformation = inst.components.formationleader

	local radius = firstformation.radius
	local reverse = false
	local thetaincrement = firstformation.thetaincrement
	local maxformation = firstformation.max_formation_size

	for k, v in pairs(formations) do
		local leader = v.components.formationleader
		leader.radius = radius
		leader.reverse = reverse
		leader.thetaincrement = thetaincrement
		leader.max_formation_size = maxformation

		radius = radius + 5
		reverse = not reverse
		thetaincrement = thetaincrement * 0.6
		maxformation = maxformation + 6
	end
end

local FormationLeader = Class(function(self, inst)
	self.inst = inst

	self.formation_type = "monster"
	self.max_formation_size = 6
	self.formation = {}
	self.target = nil
	self.searchradius = 50
	self.theta = math.random() * 2 * PI
	self.thetaincrement = 1
	self.radius = 5
	self.reverse = false
	self.makeotherformationssecondaryfn = DefaultMakeOtherFormationsSecondary
	self.inst:StartUpdatingComponent(self)
	self.age = 0

	-- self.onupdatefn = nil
	-- self.ondisbandfn = nil
end,
nil,
{
	formation_type = onformationtype,
})

function FormationLeader:GetFormationSize()
	local count = 0
		for k,v in pairs(self.formation) do
			if v ~= nil and not v:HasTag("formationleader_"..self.formation_type) then
				count = count + 1
            end
		end
	return count
end

function FormationLeader:SetUp(target, first_member)
    self.target = target
    local formationfollower = first_member.components.formationfollower
    if formationfollower then
        self.formation_type = formationfollower.formation_type
        self:NewFormationMember(first_member)
    end
end

function FormationLeader:OrganizeFormations()
	local formations = {}
	local x,y,z = self.inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x,y,z, self.searchradius, self.formationleadersearchtags)

	for k,v in pairs(ents) do
		if v.components.formationleader and v.components.formationleader.target == self.target then
			table.insert(formations, v)
		end
	end

	local sort = function(w1, w2)
		if w1.components.formationleader.age > w2.components.formationleader.age then
			return true
		end
	end

	table.sort(formations, sort)

	if formations[1] ~= self.inst then return end

	if self.makeotherformationssecondaryfn ~= nil then
		self.makeotherformationssecondaryfn(self.inst, formations)
	end
end

function FormationLeader:IsFormationFull()
	if self.formation and self:GetFormationSize() >= self.max_formation_size then return true end
end

function FormationLeader:ValidMember(member)
    if member:IsValid() and not member:IsInLimbo() and
        member:HasTag("formation_"..self.formation_type) and
        -- member.components.combat and not
		not (member.components.health and member.components.health:IsDead()) and
		member.components.formationfollower.formationleader == nil then

		return true
	end
end

function FormationLeader:DisbandFormation()
	if self.ondisbandfn ~= nil then
		self.ondisbandfn(self.inst)
	end

    local formation = {}
	for k,v in pairs(self.formation) do
        formation[k]=v
    end

	for k,v in pairs(formation) do
		self:OnLostFormationMember(v)
	end
	self.target = nil
	self.formation = {}
	self.inst:Remove()
end

function FormationLeader:FormationSizeControl()
	if self:GetFormationSize() > self.max_formation_size then
		local formationcount = 0
        local formation = {}
		for k,v in pairs(self.formation) do
            formation[k]=v
        end
		for k,v in pairs(formation) do
			formationcount = formationcount + 1
			if formationcount > self.max_formation_size then
				self:OnLostFormationMember(v)
			end
		end
	end
end

function FormationLeader:NewFormationMember(member)
	if self:ValidMember(member) then
		if member.components.formationfollower.onenterformationfn ~= nil then
			member.components.formationfollower.onenterformationfn(member, self.inst)
		end

		member.deathfn = function() self:OnLostFormationMember(member) end

		self.formation[member] = member
		self.inst:ListenForEvent("death", member.deathfn, member)

		self.inst:ListenForEvent("onremove", member.deathfn, member)
		self.inst:ListenForEvent("onenterlimbo", member.deathfn, member)
		member.components.formationfollower.formationleader = self
		member.components.formationfollower.in_formation = true

		member.components.follower:SetLeader(self.target)
	end
end

function FormationLeader:OnLostFormationMember(member)
	if member and member:IsValid() then
		if member.components.formationfollower.onleaveformationfn ~= nil then
			member.components.formationfollower.onleaveformationfn(member, self.inst)
		end

		self.inst:RemoveEventCallback("death", member.deathfn, member)

		self.inst:RemoveEventCallback("onremove", member.deathfn, member)
		self.inst:RemoveEventCallback("onenterlimbo", member.deathfn, member)
		self.formation[member] = nil
		member.components.formationfollower.formationleader = nil

		member.components.formationfollower.in_formation = false
		member.components.combat.target = nil

		member.components.follower:StopFollowing()
	end
end

function FormationLeader:GetFormationPositions()
    local pt = Vector3(self.inst.Transform:GetWorldPosition())
    local theta = self.theta
    local radius = self.radius
    local steps = self:GetFormationSize()

    for k,v in pairs(self.formation) do
        radius = self.radius

        local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))
		v.components.formationfollower.formationpos = pt + offset

        theta = theta - (2 * PI/steps)
    end
end

function FormationLeader:IsFormationEmpty()
    return next(self.formation) == nil
end

function FormationLeader:GetTheta(dt)
	if self.reverse then
		return self.theta - (dt * self.thetaincrement)
	else
		return self.theta + (dt * self.thetaincrement)
	end
end

function FormationLeader:ValidateFormation()
    local formation = {}
	for k,v in pairs(self.formation) do
        formation[k]=v
    end
	for k,v in pairs(formation) do
		if not v:IsValid() then
			self:OnLostFormationMember(v)
		end
	end
end

function FormationLeader:OnUpdate(dt)
	self:ValidateFormation()
	if self.onupdatefn ~= nil then self.onupdatefn(self.inst) end
	self.age = self.age + dt
	self:OrganizeFormations()
	self:FormationSizeControl()

	if self.target and self.target:IsValid() then -- Is there a target?
		self.theta = self:GetTheta(dt) -- Spin the formation
		self:GetFormationPositions()
	end

	if self:IsFormationEmpty() or (self.target and not self.target:IsValid()) then
		self:DisbandFormation()
	end
end

return FormationLeader
