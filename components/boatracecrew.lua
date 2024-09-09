local function _OnUpdate(inst)
    if inst.components.boatracecrew then
        inst.components.boatracecrew:OnUpdate()
    end
end

local BoatRaceCrew = Class(function(self, inst)
    self.inst = inst

    self.members = {}
    --self.membertag = nil
    --self.captain = nil

    --self.heading = nil
    --self.target = nil

    --self.status = nil

    self._update_task = self.inst:DoPeriodicTask(2.0, _OnUpdate)

    --self.on_member_added = nil
    --self.on_member_removed = nil
    --self.on_crew_empty = nil
    self._on_member_killed = function(member) self:RemoveMember(member) end

    self._on_captain_removed = function(_) self.captain = nil end

    self._on_target_removed = function(_) self.target = nil end
end)

--
function BoatRaceCrew:SetTarget(target)
    if self.target then
        self.inst:RemoveEventCallback("onremove", self._on_target_removed, self.target)
    end
    self.target = target
    if target then
        self.inst:ListenForEvent("onremove", self._on_target_removed, target)
    end
end

-- Adding & Removing Crew Members
function BoatRaceCrew:AddMemberListeners(member)
    self.inst:ListenForEvent("onremove", self._on_member_killed, member)
    self.inst:ListenForEvent("death", self._on_member_killed, member)
    self.inst:ListenForEvent("teleported", self._on_member_killed, member)
end

function BoatRaceCrew:RemoveMemberListeners(member)
    self.inst:RemoveEventCallback("onremove", self._on_member_killed, member)
    self.inst:RemoveEventCallback("death", self._on_member_killed, member)
	self.inst:RemoveEventCallback("teleported", self._on_member_killed, member)
end

function BoatRaceCrew:SetCaptain(captain)
    if self.captain then
        self.captain:RemoveEventCallback("onremove", self._on_captain_removed)
    end
    self.captain = captain
    if captain then
        captain:ListenForEvent("onremove", self._on_captain_removed)
    end
end

function BoatRaceCrew:AddMember(new_member, is_captain)
    if not self.members[new_member] then
        self.members[new_member] = true

        self:AddMemberListeners(new_member)

        if new_member.components.crewmember then
            new_member.components.crewmember:SetBoat(self.inst)
        end

        if self.on_member_added then
            self.on_member_added(self.inst, new_member)
        end
    end

    if is_captain then
        self:SetCaptain(new_member)
    end
end

function BoatRaceCrew:RemoveMember(member)
    if not self.members[member] then return end

    local crewmember = member.components.crewmember
    if crewmember then
        crewmember:OnLeftCrew()
    end

    if self.on_member_removed then
        self.on_member_removed(self.inst, member)
    end

    self:RemoveMemberListeners(member)

    if crewmember then
        crewmember:SetBoat(nil)
    end
    self.members[member] = nil

    if self.on_crew_empty and GetTableSize(self.members) == 0 then
        self.on_crew_empty(self.inst)
    end
end

function BoatRaceCrew:OnUpdate()
    self.status = "assault"
end

--
function BoatRaceCrew:GetHeadingNormal()
    if self.target then
        local boat_position = self.inst:GetPosition()
        local target_position = self.target:GetPosition()
        local normalized_heading = (target_position - boat_position):GetNormalized()
        return normalized_heading.x, normalized_heading.z
    else
        return nil
    end
end

--
function BoatRaceCrew:OnRemoveFromEntity()
    if self._update_task then
        self._update_task:Cancel()
        self._update_task = nil
    end

    for member in pairs(self.members) do
        self:RemoveMemberListeners(member)
    end
end

function BoatRaceCrew:OnRemoveEntity()
    for member in pairs(self.members) do
        self:RemoveMember(member)
    end
end

--
function BoatRaceCrew:OnSave()
    local data = {}

    for member in pairs(self.members) do
        data.members = data.members or {}
        table.insert(data.members, member.GUID)
    end

    return data, data.members
end

function BoatRaceCrew:LoadPostPass(newents, data)
    if not data.members then
        return
    end

    for _, member_GUID in pairs(data.members) do
        local member_data = newents[member_GUID]
        if member_data then
            self:AddMember(member_data.entity)
        end
    end
end

return BoatRaceCrew