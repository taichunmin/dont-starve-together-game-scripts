local function onteamtype(self, team, oldteam)
    if oldteam ~= nil then
        self.inst:RemoveTag("teamleader_"..oldteam)
    end
    if team ~= nil then
        self.inst:AddTag("teamleader_"..team)
		self.teamleadersearchtags = {"teamleader_"..team}
		self.teamsearchtags = {"team_"..team}
    else
		self.teamleadersearchtags = nil
		self.teamsearchtags = nil
    end
end

local TeamLeader = Class(function(self, inst )

	self.inst = inst
	self.team_type = "monster"
	self.min_team_size = 3
	self.max_team_size = 6
	self.team = {}
	self.threat = nil
	self.searchradius = 50
	self.theta = 0
	self.thetaincrement = 1
	self.radius = 5
	self.reverse = false
	self.timebetweenattacks = 3
	self.attackinterval = 3
	self.inst:StartUpdatingComponent(self)
	self.lifetime = 0
    self.attack_grp_size = nil
    self.chk_state = true

	self.maxchasetime = 30
	self.chasetime = 0
end,
nil,
{
    team_type = onteamtype,
})

function TeamLeader:GetTeamSize()
	local count = 0
	for teammember in pairs(self.team) do
		if not teammember:HasTag("teamleader_"..self.team_type) then
			count = count + 1
		end
	end
	return count
end

function TeamLeader:SetUp(target, first_member)
    self:SetNewThreat(target)
    local teamattacker = first_member.components.teamattacker
    if teamattacker then
        self.team_type = teamattacker.team_type
        self:NewTeammate(first_member)
    end
end

local function teamleader_sort(t1, t2)
	return t1.components.teamleader.lifetime > t2.components.teamleader.lifetime
end
function TeamLeader:OrganizeTeams()
	local teams = nil
	local x,y,z = self.inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x,y,z, self.searchradius, self.teamleadersearchtags)
	for _, potential_member in pairs(ents) do
		if potential_member.components.teamleader and potential_member.components.teamleader.threat == self.threat then
			teams = teams or {}
			table.insert(teams, potential_member)
		end
	end

	if not teams then return end

	table.sort(teams, teamleader_sort)

	if teams[1] ~= self.inst then return end

	local radius = 5
	local reverse = false
	local thetaincrement = 1
	local maxteam = 6

	for _, v in pairs(teams) do
		local teamleader = v.components.teamleader
		teamleader.radius = radius
		teamleader.reverse = reverse
		teamleader.thetaincrement = thetaincrement
		teamleader.max_team_size = maxteam
		radius = radius + 5
		reverse = not reverse
		thetaincrement = thetaincrement * 0.6
		maxteam = maxteam + 6
	end
end

function TeamLeader:IsTeamFull()
	return (self.team ~= nil) and (self:GetTeamSize() >= self.max_team_size)
end

function TeamLeader:ValidMember(member)
	return member:IsValid()
		and not member:IsInLimbo()
		and member.components.combat ~= nil
		and not (member.components.health ~= nil and member.components.health:IsDead())
		and not member.components.teamattacker.inteam
		and member:HasTag("team_"..self.team_type)
end

function TeamLeader:DisbandTeam()
    local team = shallowcopy(self.team)

	for member in pairs(team) do
		self:OnLostTeammate(member)
	end
	self.threat = nil
	self.team = {}
	self.inst:Remove()
end

function TeamLeader:TeamSizeControl()
	if self:GetTeamSize() > self.max_team_size then
		local teamcount = 0
		local team = shallowcopy(self.team)
		for member in pairs(team) do
			teamcount = teamcount + 1
			if teamcount > self.max_team_size then
				self:OnLostTeammate(member)
			end
		end
	end
end

function TeamLeader:NewTeammate(member)
	if self:ValidMember(member) then
		member.deathfn = function() self:OnLostTeammate(member) end
		member.attackedfn = function() self:BroadcastDistress(member) end
		member.attackedotherfn = function()
			self.chasetime = 0
			member.components.combat:DropTarget()
			member.components.teamattacker.orders = ORDERS.HOLD
		end

		self.team[member] = member
		self.inst:ListenForEvent("death", member.deathfn, member)
		self.inst:ListenForEvent("attacked", member.attackedfn, member)
		self.inst:ListenForEvent("onattackother", member.attackedotherfn, member)
		self.inst:ListenForEvent("onremove", member.deathfn, member)
		self.inst:ListenForEvent("onenterlimbo", member.deathfn, member)
		member.components.teamattacker.teamleader = self
		member.components.teamattacker.inteam = true
	end
end

function TeamLeader:BroadcastDistress(member)
	member = member or self.inst

	if member:IsValid() then
		local x,y,z = member.Transform:GetWorldPosition()
		local potential_teammembers = TheSim:FindEntities(x,y,z, self.searchradius, self.teamsearchtags)
		for _, potential_teammember in pairs(potential_teammembers) do
			if potential_teammember ~= member and self:ValidMember(potential_teammember) then
				self:NewTeammate(potential_teammember)
			end
		end
	end
end

function TeamLeader:OnLostTeammate(member)
	if member and member:IsValid() then
		self.inst:RemoveEventCallback("death", member.deathfn, member)
		self.inst:RemoveEventCallback("attacked", member.attackedfn, member)
		self.inst:RemoveEventCallback("onattackother", member.attackedotherfn, member)
		self.inst:RemoveEventCallback("onremove", member.deathfn, member)
		self.team[member] = nil
		member.components.teamattacker.teamleader = nil
		member.components.teamattacker.order = nil
		member.components.teamattacker.inteam = false
		member.components.combat.target = nil
	end
end

function TeamLeader:CanAttack()
	return self:GetTeamSize() >= self.min_team_size
end

function TeamLeader:CenterLeader()
	local updatedPos = nil
	local validMembers = 0
	for member in pairs(self.team) do
		updatedPos = (updatedPos or Vector3(0,0,0)) + member:GetPosition()
        validMembers = validMembers + 1
    end

    if updatedPos then
        updatedPos = updatedPos / validMembers
        self.inst.Transform:SetPosition(updatedPos:Get())
	end
end

function TeamLeader:GetFormationPositions()
    local target, theta = self.threat, self.theta
    local radius
    local pt = target:GetPosition()
    local steps = self:GetTeamSize()
	local step_decrement = (TWOPI / steps)

    for member in pairs(self.team) do
        radius = self.radius - ((member.components.teamattacker.orders == ORDERS.WARN and 1) or 0)

        local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))
        member.components.teamattacker.formationpos = pt + offset
        theta = theta - step_decrement
    end
end

function TeamLeader:GiveOrders(order, num)
	local temp = {}

	for member in pairs(self.team) do
		member.components.teamattacker.orders = nil
		table.insert(temp, member)
	end

	num = math.min(num, #temp)

	local successfulorders = 0
	while successfulorders < num do
		local attempt = temp[math.random(#temp)]
		if attempt.components.teamattacker.orders == nil then
			attempt.components.teamattacker.orders = order
			successfulorders = successfulorders + 1
		end
	end

	for member in pairs(self.team) do
		member.components.teamattacker.orders = member.components.teamattacker.orders or ORDERS.HOLD
	end
end

function TeamLeader:GiveOrdersToAllWithOrder(order, oldorder)
	for member in pairs(self.team) do
		if member.components.teamattacker.orders == oldorder then
			member.components.teamattacker.orders = order
		end
	end
end

function TeamLeader:AllInState(state)
    for member in pairs(self.team) do
        if not (self.chk_state
				and (member:HasTag("frozen")
					or (member.components.burnable ~= nil
						and member.components.burnable:IsBurning())
					)
				) and
            not (member.components.teamattacker.orders == nil
				or member.components.teamattacker.orders == state) then
            return false
        end
    end
    return true
end

function TeamLeader:IsTeamEmpty()
    return next(self.team) == nil
end

function TeamLeader:SetNewThreat(threat)
	self.threat = threat
	self.inst:ListenForEvent("onremove", function()
		self:DisbandTeam()
		self.threat = nil
	end, self.threat) --The threat has died
end

function TeamLeader:GetTheta(dt)
	local direction = (self.reverse and -1) or 1
	return self.theta + (direction * dt * self.thetaincrement)
end

function TeamLeader:SetAttackGrpSize(val)
    self.attack_grp_size = val
end

function TeamLeader:NumberToAttack()
	return (type(self.attack_grp_size) == "function" and self.attack_grp_size())
		or (type(self.attack_grp_size) == "number" and self.attack_grp_size)
		or (math.random() > 0.25 and 1)
		or 2
end

function TeamLeader:ManageChase(dt)
	self.chasetime = self.chasetime + dt
	if self.chasetime > self.maxchasetime then
		self:DisbandTeam()
	end
end

function TeamLeader:ValidateTeam()
    local team = shallowcopy(self.team)
	for member in pairs(team) do
		if not member:IsValid() then
			self:OnLostTeammate(member)
		end
	end
end

function TeamLeader:OnUpdate(dt)
	self:ManageChase(dt)
	self:CenterLeader()
	self.lifetime = self.lifetime + dt
	self:OrganizeTeams()
	self:TeamSizeControl()

	-- Is there a target, and is the team strong enough?
	if self.threat ~= nil and self:CanAttack() then
		--Spin the formation!
		self.theta = self:GetTheta(dt)

		self:GetFormationPositions()

		if self:AllInState(ORDERS.HOLD) then
			self.timebetweenattacks = self.timebetweenattacks - dt

			if self.timebetweenattacks <= 0 then
				self.timebetweenattacks = self.attackinterval
				self:GiveOrders(ORDERS.WARN, self:NumberToAttack())
				self.inst:DoTaskInTime(0.5, function() self:GiveOrdersToAllWithOrder(ORDERS.ATTACK, ORDERS.WARN) end)
			end
		end
	end

	if not self.threat or self:IsTeamEmpty() then
		self:DisbandTeam()
	end
end

return TeamLeader
