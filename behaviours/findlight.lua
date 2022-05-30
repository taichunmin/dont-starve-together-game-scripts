local CHECK_INTERVAL = 5
local FOLLOW_CHECK_INTERVAL = 1

FindLight = Class(BehaviourNode, function(self, inst, see_dist, safe_dist)
    BehaviourNode._ctor(self, "FindLight")
    self.inst = inst
    self.targ = nil
    self.see_dist = see_dist
    self.safe_dist = safe_dist
    self.lastchecktime = 0
    self.lastfollowchecktime = 0
end)

function FindLight:DBString()
    return string.format("Stay near light %s", tostring(self.targ))
end

function FindLight:Visit()
    if self.status == READY then
        self:PickTarget()
        self.status = RUNNING
    end

    if self.status == RUNNING then
        if GetTime() - self.lastchecktime > CHECK_INTERVAL then
            self:PickTarget()
        end

        if GetTime() - self.lastfollowchecktime > FOLLOW_CHECK_INTERVAL then
            self.lastfollowchecktime = GetTime()
            if not (self.targ ~= nil and self.targ:IsValid() and self.targ:HasTag("lightsource")) then
                self.status = FAILED
            else
                local actual_safe_dist = FunctionOrValue(self.safe_dist, self.inst, self.targ) or 5
                if self.inst:IsNear(self.targ, actual_safe_dist) then
                    self.status = SUCCESS
                    self.inst.components.locomotor:Stop()
                else
                    self.inst.components.locomotor:GoToPoint(self.inst:GetPositionAdjacentTo(self.targ, actual_safe_dist * 0.98), nil, true)
                end
            end
        end
    end
end

local LIGHTS_TAGS = {"lightsource"}
function FindLight:PickTarget()
    self.targ = GetClosestInstWithTag(LIGHTS_TAGS, self.inst, self.see_dist)
    self.lastchecktime = GetTime()
end
