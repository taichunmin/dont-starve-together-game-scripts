local WalkingPlankUser = Class(function(self, inst)
    self.inst = inst

    --self.current_plank = nil
    --self._plank_remove_event = nil
end)

function WalkingPlankUser:SetCurrentPlank(plank)
    if self._plank_remove_event ~= nil then
        self._plank_remove_event:Cancel()
        self._plank_remove_event = nil
    end

    if plank ~= nil then
        self._plank_remove_event = self.inst:ListenForEvent("onremove", function(i) self.current_plank = nil end, plank)
    end

    self.current_plank = plank
end

function WalkingPlankUser:Dismount()
    if self.current_plank ~= nil then
        self.current_plank.components.walkingplank:StopMounting()
        self.current_plank = nil
    end

    if self._plank_remove_event ~= nil then
        self._plank_remove_event:Cancel()
        self._plank_remove_event = nil
    end
end

return WalkingPlankUser
