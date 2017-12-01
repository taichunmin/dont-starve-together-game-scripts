local HomeSeeker = Class(function(self, inst)
    self.inst = inst
    self.onhomeremoved = function()
        self:SetHome(nil)
        self.inst:RemoveComponent("homeseeker")
    end
end)

function HomeSeeker:HasHome()
    return self.home ~= nil and self.home:IsValid() and not (self.home.components.burnable ~= nil and self.home.components.burnable:IsBurning())
end

function HomeSeeker:GetDebugString()
    return string.format("home: %s", tostring(self.home))
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

return HomeSeeker
