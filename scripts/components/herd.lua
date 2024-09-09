local function _OnUpdate(inst, self)
    self:OnUpdate()
end

local function AddMemberListeners(self, member)
    self.inst:ListenForEvent("onremove", self._onmemberkilled, member)
    self.inst:ListenForEvent("death", self._onmemberkilled, member)
end

local function RemoveMemberListeners(self, member)
    self.inst:RemoveEventCallback("onremove", self._onmemberkilled, member)
    self.inst:RemoveEventCallback("death", self._onmemberkilled, member)
end

local Herd = Class(function(self, inst)
    self.inst = inst
    self.maxsize = 12
    self.members = {}
    self.membercount = 0
    self.membertag = nil

    self.gatherrange = nil
    self.updaterange = nil
    --self.nomerging = false

    self.onempty = nil
    self.onfull = nil
    self.addmember = nil
    self.removemember = nil

    self.updatepos = true
    self.updateposincombat = false

    self.task = self.inst:DoPeriodicTask(math.random() * 2 + 6, _OnUpdate, nil, self) -- NOTES(JBK): Keep this smaller than herdmember sample rate! Search string: HERDSAMPLER823

    self._onmemberkilled = function(member) self:RemoveMember(member) end
end)

function Herd:OnRemoveFromEntity()
    self.task:Cancel()
    for k, v in pairs(self.members) do
        RemoveMemberListeners(self, k)
    end
end

function Herd:OnRemoveEntity()
    for k, v in pairs(self.members) do
        self:RemoveMember(k)
    end
end

function Herd:GetDebugString()
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, self.gatherrange, self.membersearchtags)
    local str = string.format("members:%d membercount:%d max:%d membertag:%s gatherrange:%.2f nearby_tagged:%d", GetTableSize(self.members), self.membercount, self.maxsize, self.membertag, self.gatherrange, ents and #ents or 0)
    return str
end

function Herd:SetMemberTag(tag)
    self.membertag = tag
	if tag == nil then
		self.membersearchtags = nil
	else
		self.membersearchtags = { "herdmember", tag }
	end
end

function Herd:SetGatherRange(range)
    self.gatherrange = range
end

function Herd:SetUpdateRange(range)
    self.updaterange = range
end

function Herd:SetMaxSize(size)
    self.maxsize = size
end

function Herd:SetOnEmptyFn(fn)
    self.onempty = fn
end

function Herd:SetOnFullFn(fn)
    self.onfull = fn
end

function Herd:SetAddMemberFn(fn)
    self.addmember = fn
end

function Herd:SetRemoveMemberFn(fn)
    self.removemember = fn
end


function Herd:IsFull()
    return self.membercount >= self.maxsize
end

function Herd:AddMember(inst)
    if not self.members[inst] then
        self.membercount = self.membercount + 1
        self.members[inst] = true

        --This really should never happen but if it does it's not the end of the world...
        --assert(self.membercount <= self.maxsize, "We've got too many beefalo!")

        AddMemberListeners(self, inst)

        if inst.components.knownlocations ~= nil then
            inst.components.knownlocations:RememberLocation("herd", self.inst:GetPosition())
        end
        if inst.components.herdmember ~= nil then
            inst.components.herdmember:SetHerd(self.inst)
        end
        if self.addmember ~= nil then
            self.addmember(self.inst, inst)
        end

        if self.onfull ~= nil and self.membercount == self.maxsize then
            self.onfull(self.inst)
        end
    end
end

function Herd:RemoveMember(inst)
    if self.members[inst] then

        if self.removemember ~= nil then
            self.removemember(self.inst, inst)
        end

        RemoveMemberListeners(self, inst)

        if inst.components.knownlocations ~= nil then
            inst.components.knownlocations:RememberLocation("herd", nil)
        end
        if inst.components.herdmember ~= nil then
            inst.components.herdmember:SetHerd(nil)
        end
        self.membercount = self.membercount - 1
        self.members[inst] = nil

        if self.onempty ~= nil and next(self.members) == nil then
            self.onempty(self.inst)
        end
    end
end

function Herd:GatherNearbyMembers()
    if self.gatherrange == nil or self:IsFull() then
        return
    end

    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, self.gatherrange, self.membersearchtags)

    for i, v in ipairs(ents) do
        if self.members[v] == nil and
            v.components.herdmember ~= nil and
            (v.components.knownlocations == nil or not v.components.knownlocations:GetLocation("herd")) and
            (v.components.health == nil or not v.components.health:IsDead()) then
            self:AddMember(v)
            if self:IsFull() then
                break
            end
        end
    end
end

local HERD_TAGS = { "herd" }
function Herd:MergeNearbyHerds()
    if self.nomerging or self.gatherrange == nil or self:IsFull() then
        return
    end

    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, self.gatherrange, HERD_TAGS)

    for i, v in ipairs(ents) do
        if v ~= self.inst and
            v.components.herd ~= nil and
            v.components.herd.membertag == self.membertag and
            v.components.herd.membercount < 4 and
            self.membercount + v.components.herd.membercount <= self.maxsize then
            for k2, v2 in pairs(v.components.herd.members) do
                self:AddMember(k2)
            end
            v:Remove()
        end
    end
end

function Herd:OnUpdate()
    self:GatherNearbyMembers()
    self:MergeNearbyHerds()
    if self.membercount > 0 then
        if self.updaterange ~= nil then
            local updatedPos = nil
            local validMembers = 0
            local toremove = {}
            for k, v in pairs(self.members) do
                if k.components.herdmember == nil
                    or (self.membertag ~= nil and not k:HasTag(self.membertag)) then
                    table.insert(toremove, k)
                elseif self.updatepos
                    and ((k.components.combat ~= nil and k.components.combat.target == nil) or self.updateposincombat)
                    and self.inst:IsNear(k, self.updaterange) then
                    updatedPos = updatedPos ~= nil and updatedPos + k:GetPosition() or k:GetPosition()
                    validMembers = validMembers + 1
                end
            end
            for i, v in ipairs(toremove) do
                self:RemoveMember(v)
            end

            local pos = Vector3(self.inst.Transform:GetWorldPosition())
            if self.updateposfn then
                if updatedPos then
                    updatedPos = Vector3(updatedPos.x / validMembers, 0, updatedPos.z / validMembers)
                end
                pos = self.updateposfn(self.inst, updatedPos)
            else
                if updatedPos ~= nil then
                    pos = Vector3(updatedPos.x / validMembers, 0, updatedPos.z / validMembers)

                end
            end
            self.inst.Transform:SetPosition(pos.x,pos.y,pos.z)
        end
        if self.membercount > 0 then
            local herdPos = self.inst:GetPosition()
            for k, v in pairs(self.members) do
                if k.components.knownlocations ~= nil then
                    k.components.knownlocations:RememberLocation("herd", herdPos)
                end
            end
        end
    end
end

function Herd:OnSave()
    local data = {}

    for k, v in pairs(self.members) do
        if data.members == nil then
            data.members = { k.GUID }
        else
            table.insert(data.members, k.GUID)
        end
    end

    return data, data.members
end

function Herd:LoadPostPass(newents, savedata)
    if savedata.members ~= nil then
        for k, v in pairs(savedata.members) do
            local member = newents[v]
            if member ~= nil then
                self:AddMember(member.entity)
            end
        end
    end
end

return Herd
