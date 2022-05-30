local HomeSeeker = Class(function(self, inst)
    self.inst = inst
    self.removecomponent = true
    self.onhomeremoved = function(home)
        if self.home == home then
            self:SetHome(nil)
            if self.removecomponent then
                self.inst:RemoveComponent("homeseeker")
            end
        end
    end
end)

function HomeSeeker:HasHome()
    return self.home ~= nil and self.home:IsValid() and not (self.home.components.burnable ~= nil and self.home.components.burnable:IsBurning())
end

function HomeSeeker:GetDebugString()
    return string.format("home: %s", tostring(self.home))
end

function HomeSeeker:GetHome()
    if self.home ~= nil and self.home:IsValid() then
        return self.home
    end
    return nil
end

function HomeSeeker:SetHome(home)
    if self.home ~= nil then
        self.inst:RemoveEventCallback("onremove", self.onhomeremoved, self.home)
    end
    self.home = home
    if home ~= nil then
        self.inst:ListenForEvent("onremove", self.onhomeremoved, home)
    end
end

function HomeSeeker:GoHome(shouldrun)
    if self.home ~= nil and self.home:IsValid() then
        local bufferedaction = BufferedAction(self.inst, self.home, ACTIONS.GOHOME)
        if self.inst.components.locomotor ~= nil then
            self.inst.components.locomotor:PushAction(bufferedaction, shouldrun)
        else
            self.inst:PushBufferedAction(bufferedaction)
        end
    end
end

function HomeSeeker:GetHomePos()
    return self.home ~= nil and self.home:IsValid() and self.home:GetPosition() or nil
end

function HomeSeeker:GetHomeDirectTravelTime() -- The time it would take the entity to walk home behaving as if the path were directly to the home was clear.
    if self.home ~= nil and self.home:IsValid() then
        local x1, _, z1 = self.inst.Transform:GetWorldPosition()
        local x2, _, z2 = self.home.Transform:GetWorldPosition()
        local dist = VecUtil_Dist(x1, z2, x2, z2)
        local speed = TUNING.WILSON_WALK_SPEED
        if self.inst.components.locomotor then
            speed = math.max(speed, self.inst.components.locomotor:GetWalkSpeed())
        end
        return dist / speed
    end
    return nil
end

return HomeSeeker
