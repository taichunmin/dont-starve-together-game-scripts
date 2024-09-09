local MermKingManager = Class(function(self, inst)
    self.inst = inst
    self.main_throne = nil
    self.thrones = {}

    self.king = nil
    self.king_dying = false

    self.candidates = {}
    self.candidate_transforming = nil

    self.inst:ListenForEvent("oncandidatekingarrived", function(inst, data)
		if data then
			if not self:IsCandidate(data.candidate) then
				return
			end

			local throne = self:GetThrone(data.candidate)
			if not throne then
				return
			end

			self:CreateMermKing(data.candidate, throne)
		end
	end)

    self.inst:ListenForEvent("onthronebuilt", function(inst, data)
		if data and data.throne then
			table.insert(self.thrones, data.throne)
			self:FindMermCandidate(data.throne)
		end
	end)

    self.inst:ListenForEvent("onthronedestroyed", function(inst, data)
		if data and data.throne then
			self:OnThroneDestroyed(data.throne)
		end
	end)
end)

local function OnKingDeath(inst, data)
	local mermkingmanager = TheWorld.components.mermkingmanager
	mermkingmanager.king.persists = false
	mermkingmanager.king_dying = true
end

local function OnKingRemoval(inst, data)
	local mermkingmanager = TheWorld.components.mermkingmanager

	mermkingmanager.inst:RemoveEventCallback("onremove", OnKingRemoval, mermkingmanager.king)
	mermkingmanager.inst:RemoveEventCallback("death", OnKingDeath, mermkingmanager.king)

	TheWorld:PushEvent("onmermkingdestroyed", {throne = mermkingmanager.main_throne})

	table.insert(mermkingmanager.thrones, mermkingmanager.main_throne)

	mermkingmanager.main_throne = nil
	mermkingmanager.king = nil
	mermkingmanager.king_dying = false

	for _, throne in pairs(mermkingmanager.thrones) do
		if mermkingmanager:IsThroneValid(throne) then
			mermkingmanager:FindMermCandidate(throne)
		end
	end
end

local function OnCandidateRemoved(inst, data)
	local manager = TheWorld.components.mermkingmanager
	local throne = manager:GetThrone(inst)

	if manager.candidate_transforming == inst then
		manager.candidate_transforming = nil
	end

	manager.inst:RemoveEventCallback("death", OnCandidateRemoved, inst)
	manager.inst:RemoveEventCallback("onremove", OnCandidateRemoved, inst)

	manager.candidates[throne] = nil

	if manager:IsThroneValid(throne) then
		manager:FindMermCandidate(throne)
	end
end

function MermKingManager:OnThroneDestroyed(throne)
	local removal_index = nil
	for index, throne_instance in ipairs(self.thrones) do
		if throne == throne_instance then
			removal_index = index
			break
		end
	end

	if removal_index ~= nil then
		table.remove(self.thrones, removal_index)
	end

	local candidate = self.candidates[throne]
	if candidate ~= nil then
		if self:IsCandidateAtThrone(candidate, throne) then
			candidate:PushEvent("getup")
		end

		candidate.components.inspectable.nameoverride = nil
        candidate:RemoveTag("mermprince")
		self.inst:RemoveEventCallback("death", OnCandidateRemoved, candidate)
        self.inst:RemoveEventCallback("onremove", OnCandidateRemoved, candidate)
		self.candidates[throne] = nil
	end

	if throne == self:GetMainThrone() then
		self.main_throne = nil
		-- This should only happen with the deconstruction staff
		if self.king ~= nil and self.king:IsValid()
				and self.king.components.health ~= nil
				and not self.king.components.health:IsDead() then
			self.king.components.health:Kill()
		end
	end
end

function MermKingManager:CreateMermKing(candidate, throne)
	candidate.components.inventory:DropEverything()
    self.inst:RemoveEventCallback("onremove", OnCandidateRemoved, candidate)
	self.inst:RemoveEventCallback("death", OnCandidateRemoved, candidate)

	self.king = ReplacePrefab(candidate, "mermking")
	self.king:PushEvent("oncreated")

	self.inst:ListenForEvent("onremove", OnKingRemoval, self.king)
	self.inst:ListenForEvent("death", OnKingDeath, self.king)

	self.main_throne = throne
	for i, potential_throne in ipairs(self.thrones) do
		if potential_throne == throne then
			table.remove(self.thrones, i)
			break
		end
	end

	for _, potential_candidate in pairs(self.candidates) do
		if potential_candidate.components.mermcandidate then
			potential_candidate.components.mermcandidate:ResetCalories()
			self.inst:RemoveEventCallback("onremove", OnCandidateRemoved, potential_candidate)
			self.inst:RemoveEventCallback("death", OnCandidateRemoved, potential_candidate)
		end
	end
	self.candidates = {}
	self.candidate_transforming = nil

    TheWorld:PushEvent("onmermkingcreated", {king = self.king, throne = self:GetMainThrone()})
end

local MERMCANDIDATE_MUST_TAGS = {"merm"}
local MERMCANDIDATE_CANT_TAGS = {"player", "mermking", "mermguard"}
function MermKingManager:FindMermCandidate(throne)
	-- Why are we finding a candidate if we already have a king?
	if self:HasKingLocal() then
		return
	end

	if throne then
		local merm_candidate = FindEntity(throne, 50,
			function(ent)
				return ent.components.health and not ent.components.health:IsDead() and not self:IsCandidate(ent)
			end,
		MERMCANDIDATE_MUST_TAGS, MERMCANDIDATE_CANT_TAGS)

	    if merm_candidate then
	        self:ShouldGoToThrone(merm_candidate, throne)
	    end
	end
end

function MermKingManager:ShouldGoToThrone(merm, throne)
	if throne ~= nil and not merm:HasTag("shadowminion") and self:IsThroneValid(throne) then
		if not self:GetKing() then
			if not self:GetCandidate(throne) then
				self.candidates[throne] = merm
				merm.components.inspectable.nameoverride = "MERM_PRINCE"
				merm:AddTag("mermprince")
				self.inst:ListenForEvent("onremove", OnCandidateRemoved, merm)
				self.inst:ListenForEvent("death", OnCandidateRemoved, merm)
				return true
			elseif self:IsThroneCandidate(merm, throne) then
				return true
			end
		end
	end

	return false
end

function MermKingManager:IsCandidateAtThrone(candidate, throne)
	return throne ~= nil and throne:IsNear(candidate, 0.5)
end

function MermKingManager:ShouldTransform(merm)
	local throne = self:GetThrone(merm)

	local should_transform = merm ~= nil
			and throne ~= nil
			and self:IsCandidateAtThrone(merm, throne)
			and merm.components.mermcandidate:ShouldTransform()
			and (self.candidate_transforming == nil or self.candidate_transforming == merm)

	if should_transform then
		self.candidate_transforming = self.candidate_transforming or merm
		return true
	else
		return false
	end
end


function MermKingManager:IsThroneValid(throne)
    return throne ~= nil
        and throne:IsValid()
        and not (throne.components.burnable ~= nil and throne.components.burnable:IsBurning())
        and not throne:HasTag("burnt")
end

function MermKingManager:GetKing()
	return self.king
end

function MermKingManager:GetCandidate(throne)
	return self.candidates[throne]
end

function MermKingManager:IsThroneCandidate(merm, throne)
	return self.candidates[throne] == merm
end

function MermKingManager:IsCandidate(merm)
	for _, candidate in pairs(self.candidates) do
		if candidate == merm then
			return true
		end
	end

	return false
end

function MermKingManager:GetThrone(merm)
	for throne, candidate in pairs(self.candidates) do
		if candidate == merm then
			return throne
		end
	end

	return nil
end

function MermKingManager:GetMainThrone()
	return self.main_throne
end

function MermKingManager:IsThrone(throne)
	if self:GetMainThrone() and self:GetMainThrone() == throne then
		return true
	end

	for _, potential_throne in ipairs(self.thrones) do
		if potential_throne == throne then
			return true
		end
	end

	return false
end


function MermKingManager:HasKingLocal() -- NOTES(JBK): The local version. Used for local world tapestry management only.
    return self.king ~= nil and self.king:IsValid()
        and self.king.components.health ~= nil
        and not self.king.components.health:IsDead()
end

function MermKingManager:HasKingAnywhere() -- NOTES(JBK): Sharded version.
    if self:HasKingLocal() then -- Local copy check first.
        return true
    end

    local shard_mermkingwatcher = TheWorld.shard.components.shard_mermkingwatcher or nil
    return (shard_mermkingwatcher ~= nil and shard_mermkingwatcher:HasMermKing())
        or false
end
function MermKingManager:HasKing() -- NOTES(JBK): Deprecated function stub for mods do not use for game logic.
    return self:HasKingAnywhere()
end

-- Merm King quest items
function MermKingManager:HasTridentLocal()
    return self:HasKingLocal() and self.king:HasTrident()
end
function MermKingManager:HasTridentAnywhere()
    if self:HasTridentLocal() then return true end

    local shard_mermkingwatcher = TheWorld.shard.components.shard_mermkingwatcher or nil
    return (shard_mermkingwatcher ~= nil and shard_mermkingwatcher:HasTrident())
        or false
end

function MermKingManager:HasCrownLocal()
    return self:HasKingLocal() and self.king:HasCrown()
end
function MermKingManager:HasCrownAnywhere()
    if self:HasCrownLocal() then return true end

    local shard_mermkingwatcher = TheWorld.shard.components.shard_mermkingwatcher or nil
    return (shard_mermkingwatcher ~= nil and shard_mermkingwatcher:HasCrown())
        or false
end

function MermKingManager:HasPauldronLocal()
    return self:HasKingLocal() and self.king:HasPauldron()
end
function MermKingManager:HasPauldronAnywhere()
    if self:HasPauldronLocal() then return true end

    local shard_mermkingwatcher = TheWorld.shard.components.shard_mermkingwatcher or nil
    return (shard_mermkingwatcher ~= nil and shard_mermkingwatcher:HasPauldron())
        or false
end

--
function MermKingManager:OnSave()
	local data = {}
	local ents = {}

	if next(self.candidates) ~= nil then
		for k,v in pairs(self.candidates) do
			table.insert(ents, k.GUID)
			table.insert(ents, v.GUID)
		end
	end

	if self.king and not self.king_dying then
		data.king = self.king.GUID
		table.insert(ents, self.king.GUID)
	end

	if self.candidate_transforming then
		data.candidate_transforming = self.candidate_transforming.GUID
		table.insert(ents, self.candidate_transforming.GUID)
	end

	local main_throne = self:GetMainThrone()
	if #self.thrones > 0 then
		data.thrones = {}

		for _,v in ipairs(self.thrones) do
			table.insert(data.thrones, v.GUID)
			table.insert(ents, v.GUID)
		end

		if self.king_dying then
			table.insert(data.thrones, main_throne.GUID)
			table.insert(ents, main_throne.GUID)
		end
	end

	if main_throne and not self.king_dying then
		data.throne = main_throne.GUID
		table.insert(ents, main_throne.GUID)
	end

	return data, ents
end

function MermKingManager:LoadPostPass(newents, savedata)
	if savedata.throne and newents[savedata.throne] ~= nil then
		self.main_throne = newents[savedata.throne].entity
	end

	if savedata.candidates then
		for k,v in pairs(savedata.candidates) do
			local throne = newents[k].entity
			local candidate = newents[v].entity

			self.candidates[throne] = candidate

			candidate.components.inspectable.nameoverride = "MERM_PRINCE"
            candidate:AddTag("mermprince")
            self.inst:ListenForEvent("onremove", OnCandidateRemoved, candidate)
			self.inst:ListenForEvent("death", OnCandidateRemoved, candidate)
		end
	end

	if savedata.king and newents[savedata.king] ~= nil then
		self.king = newents[savedata.king].entity
		self.inst:ListenForEvent("onremove", OnKingRemoval, self.king)
		self.inst:ListenForEvent("death", OnKingDeath, self.king)
		TheWorld:PushEvent("onmermkingcreated", {king = self.king, throne = self:GetMainThrone()})
	end

	if savedata.candidate_transforming and newents[savedata.candidate_transforming] ~= nil then
		self.candidate_transforming = newents[savedata.candidate_transforming].entity
	end

	if savedata.thrones then
		for _, v in ipairs(savedata.thrones) do
            if newents[v] ~= nil then
                table.insert(self.thrones, newents[v].entity)
            end
		end
	end
end

return MermKingManager