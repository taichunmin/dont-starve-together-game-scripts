local function TrackOther(self, other)
    self.others[other] = true
    self.inst:ListenForEvent("ms_leavesquad_"..self.squad, self._onotherleft, other)
    self.inst:ListenForEvent("onremove", self._onotherleft, other)
end

local function StopTrackingOther(self, other)
    self.others[other] = nil
    self.inst:RemoveEventCallback("ms_leavesquad_"..self.squad, self._onotherleft, other)
    self.inst:RemoveEventCallback("onremove", self._onotherleft, other)
end

local SquadMember = Class(function(self, inst)
    self.inst = inst
    self.squad = ""
    self.others = {}
    self._onotherjoined = function(src, other)
        TrackOther(self, other)
        TrackOther(other.components.squadmember, self.inst)
    end
    self._onotherleft = function(other)
        StopTrackingOther(self, other)
    end
end)

function SquadMember:IsInSquad()
    return self.squad:len() > 0
end

function SquadMember:GetSquadName()
    return self.squad
end

function SquadMember:GetOtherMembers()
    return self.others
end

function SquadMember:JoinSquad(squadname)
    squadname = squadname or ""
    if self.squad ~= squadname then
        self:LeaveSquad()
        self.squad = squadname
        TheWorld:PushEvent("ms_joinsquad_"..squadname, self.inst)
        self.inst:ListenForEvent("ms_joinsquad_"..squadname, self._onotherjoined, TheWorld)
    end
end

function SquadMember:LeaveSquad()
    if self.squad ~= nil then
        local k = next(self.others)
        while k ~= nil do
            StopTrackingOther(self, k)
            k = next(self.others)
        end
        local squad = self.squad
        self.squad = nil
        self.inst:PushEvent("ms_leavesquad_"..squad)
    end
end

function SquadMember:GetDebugString()
    if self:IsInSquad() then
        local str = "<"..self.squad..">"
        for k, v in pairs(self.others) do
            str = str.."\n  "..tostring(k)
        end
        return str
    end
end

SquadMember.OnRemoveFromEntity = SquadMember.LeaveSquad

return SquadMember
