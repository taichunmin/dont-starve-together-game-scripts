local function _OnUpdate(inst, self)
    self:OnUpdate()
end

local function AddMemberListeners(self, member)
    self.inst:ListenForEvent("onremove", self._onmemberkilled, member)
    self.inst:ListenForEvent("death", self._onmemberkilled, member)
	self.inst:ListenForEvent("teleported", self._onmemberkilled, member)
end

local function RemoveMemberListeners(self, member)
    self.inst:RemoveEventCallback("onremove", self._onmemberkilled, member)
    self.inst:RemoveEventCallback("death", self._onmemberkilled, member)
	self.inst:RemoveEventCallback("teleported", self._onmemberkilled, member)
end

local Boatcrew = Class(function(self, inst)
    self.inst = inst
    self.members = {}
    self.membercount = 0
    self.membertag = nil
    self.loot_per_member = TUNING.BOATCREW_LOOT_PER_MEMBER
    self.captain = nil

    self.tinkertargets = {}

    self.gatherrange = nil
    self.updaterange = nil

    self.addmember = nil
    self.removemember = nil

    self.heading = nil
    self.target = nil
    self.flee = nil

    self.status = "hunting"
    self.task = self.inst:DoPeriodicTask(2, _OnUpdate, nil, self)
    self.inst:ListenForEvent("onremove", function()
        if TheWorld.components.piratespawner then
            TheWorld.components.piratespawner:RemoveShipData(self.inst)
        end
    end)
    self._onmemberkilled = function(member) self:RemoveMember(member) end
end)

function Boatcrew:TestForLootToSteal()
    local has_loot = false
    for member in pairs(self.members) do
        if member ~= self.captain and not member.nothingtosteal then
            has_loot = true
            break
        end
    end
    return has_loot
end

function Boatcrew:TestForVictory()
    if self:CountPirateLoot() > (self:CountCrew()*self.loot_per_member) then
        return true
    else
        for member in pairs(self.members) do
            if member.victory then
                return true
            end
        end
    end
end

local function do_victory_for_crewmember(_, member)
    if member and member:IsValid() then
        member.victory = true
        local string_index = math.random(1, #STRINGS["MONKEY_BATTLECRY_VICTORY_CHEER"])
        member:PushEvent("cheer", { say=STRINGS["MONKEY_BATTLECRY_VICTORY_CHEER"][string_index] })
    end
end

function Boatcrew:CrewCheer()
    for member in pairs(self.members) do
        if not member.victory then
            self.inst:DoTaskInTime((math.random()*0.4)+0.2, do_victory_for_crewmember, member)
        end
    end
end

function Boatcrew:CountPirateLoot()
    local loot = 0
    for member in pairs(self.members) do
        for _, slot_item in pairs(member.components.inventory.itemslots) do
            if not slot_item:HasTag("personal_possession") then
                loot = loot + (slot_item.components.stackable and slot_item.components.stackable.stacksize or 1)
            end
        end
    end
    return loot
end

function Boatcrew:CountCrew()
    return GetTableSize(self.members)
end

function Boatcrew:OnRemoveFromEntity()
    self.task:Cancel()
    for member in pairs(self.members) do
        RemoveMemberListeners(self, member)
    end
end

function Boatcrew:OnRemoveEntity()
    for member in pairs(self.members) do
        self:RemoveMember(member)
    end
end

function Boatcrew:SetMemberTag(tag)
    self.membertag = tag
    self.membersearchtags = (tag ~= nil and { "crewmember", tag }) or nil
end

function Boatcrew:areAllCrewOnBoat()
    for member in pairs(self.members) do
        if member:GetCurrentPlatform() ~= member.components.crewmember.boat then
            return false
        end
    end
    return true
end

function Boatcrew:GetHeadingNormal()
    local pt = nil
    local boatpt = self.inst:GetPosition()
    local x, _, z = nil,nil,nil

    -- target can be a Vector3 or a prefab
    if self.target then

        if self.target.GetPosition then
            pt = self.target:GetPosition()
        else
            pt = self.target
        end
        
        if self.status == "retreat" and self:areAllCrewOnBoat() then
            local heading = self.inst:GetAngleToPoint(pt.x, 0, pt.z) * DEGREES
            pt = boatpt + Vector3(math.cos(heading), 0, -math.sin(heading))
            pt.y = 0
        elseif self.target.components and self.target.components.boatphysics then
            local scaler = Remap(distsq(pt.x, pt.z, boatpt.x, boatpt.z), 0, 100, 0, 1)
            pt.x  = pt.x + (self.target.components.boatphysics.velocity_x * scaler)
            pt.z  = pt.z + (self.target.components.boatphysics.velocity_z * scaler)
        end

    elseif self.heading then
        local heading = self.heading * DEGREES
        pt = boatpt + Vector3(math.cos(heading), 0, -math.sin(heading))
        pt.y = 0
    end
    
    if pt ~= nil then
         return VecUtil_Normalize(pt.x - boatpt.x, pt.z - boatpt.z)
    end
end

function Boatcrew:SetHeading(heading)
    self.heading = heading
end

function Boatcrew:SetTarget(target)
    self.target = target
end

function Boatcrew:SetUpdateRange(range)
    self.updaterange = range
end

function Boatcrew:SetAddMemberFn(fn)
    self.addmember = fn
end

function Boatcrew:SetRemoveMemberFn(fn)
    self.removemember = fn
end

local function removecaptain(captain)
    local bc = captain.components.crewmember.boat and captain.components.crewmember.boat.components.boatcrew or nil
    if bc then
        TheWorld.components.piratespawner:RemoveShipData(bc.inst)
        bc.inst:RemoveComponent("vanish_on_sleep")
        bc.inst:RemoveComponent("boatcrew")
    end
end

function Boatcrew:SetCaptain(captain)
    if self.captain then
        self.captain:RemoveEventCallback("onremove", removecaptain)
    end
    self.captain = captain
    if captain then
        captain:ListenForEvent("onremove", removecaptain)
    end
end

function Boatcrew:AddMember(inst, setcaptain)
    if not self.members[inst] then
        self.membercount = self.membercount + 1
        self.members[inst] = true

        AddMemberListeners(self, inst)

        if inst.components.crewmember ~= nil then
            inst.components.crewmember:SetBoat(self.inst)
        end
        if self.addmember ~= nil then
            self.addmember(self.inst, inst)
        end
    end
    if setcaptain then
        self:SetCaptain(inst)
    end
end

function Boatcrew:RemoveMember(inst)
    if self.members[inst] then

        local crewmember = inst.components.crewmember
        if crewmember then
            crewmember:OnLeftCrew()
        end

        if self.removemember then
            self.removemember(self.inst, inst)
        end

        RemoveMemberListeners(self, inst)

        if crewmember then
            crewmember:SetBoat(nil)
        end
        self.membercount = self.membercount - 1
        self.members[inst] = nil

        if self.membercount < 1 then
			inst:RemoveComponent("vanish_on_sleep")
            inst:RemoveComponent("boatcrew")
        end
    end
end

function Boatcrew:checktinkertarget(target)
    if self.tinkertargets[target.GUID] ~= nil then
        return true
    end
end

function Boatcrew:reserveinkertarget(target)
    self.tinkertargets[target.GUID] = true
end

function Boatcrew:removeinkertarget(target)
    if self.tinkertargets[target.GUID] ~= nil then
        self.tinkertargets[target.GUID] = nil
    end
end

function Boatcrew:IsCrewOnDeck()
    for member,bool in pairs(self.members) do
        if member:GetCurrentPlatform() ~= self.inst then
            return false
        end
    end
    return true
end

function Boatcrew:OnUpdate()
    if self.status == "delivery" then
        -- just deliver
    elseif self.target and (self:TestForLootToSteal() ~= true or self:TestForVictory() or self.flee ) then 
        self.status = "retreat"
    elseif self.target then
        self.status = "assault"
    else
        self.status = "hunting"
    end
end

function Boatcrew:OnSave()
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

function Boatcrew:LoadPostPass(newents, savedata)
    if savedata.members ~= nil then
        for k, v in pairs(savedata.members) do
            local member = newents[v]
            if member ~= nil then
                self:AddMember(member.entity)
            end
        end
    end
end

return Boatcrew
