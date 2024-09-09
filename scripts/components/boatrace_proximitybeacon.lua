-- An object with this component can be configured alongside a boatrace_proximitychecker
-- to identify when the beacon is in range of the checker.
local BoatRace_ProximityBeacon = Class(function(self, inst)
    self.inst = inst
    --self.boatrace_started_fn = nil
    --self.boatrace_finished_fn = nil

    self.inst:AddTag("boatrace_proximitybeacon")

    self._boatrace_started_callback = function(i, data)
        if self.boatrace_started_fn then
            self.boatrace_started_fn(i, data)
        end
    end
    self.inst:ListenForEvent("boatrace_start", self._boatrace_started_callback)

    self._boatrace_finished_callback = function(i, data)
        if self.boatrace_finished_fn then
            self.boatrace_finished_fn(i, data.start, data.winner)
        end
    end
    self.inst:ListenForEvent("boatrace_finish", self._boatrace_finished_callback)
end)

function BoatRace_ProximityBeacon:OnRemoveFromEntity()
    self.inst:RemoveTag("boatrace_proximitybeacon")

    self.inst:RemoveEventCallback("boatrace_start", self._boatrace_started_callback)
    self.inst:RemoveEventCallback("boatrace_finish", self._boatrace_finished_callback)
end

function BoatRace_ProximityBeacon:SetBoatraceStartedFn(fn)
    self.boatrace_started_fn = fn
end

function BoatRace_ProximityBeacon:SetBoatraceFinishedFn(fn)
    self.boatrace_finished_fn = fn
end

return BoatRace_ProximityBeacon