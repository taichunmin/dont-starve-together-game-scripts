-- An object with this component can be configured alongside 'boatrace_proximitybeacon's
-- to identify when the beacons are in range of the checker.
local BoatRace_ProximityChecker = Class(function(self, inst)
    self.inst = inst

    self.inst:AddTag("boatrace_proximitychecker")

    self.proximity_check_must_flags = {"boatrace_proximitybeacon"}
    self.range = TUNING.BOATRACE_DEFAULT_PROXIMITY

    -- An object has to be within our proximity for this long to officially be "detected"
    -- and send a message.
    self.found_delay = 1.5

    self.stored_beacons = {}
    self._per_update_found_beacons = {} -- Store this on the object to avoid creating a table each update.

    --self.on_found_beacon = nil
end)

function BoatRace_ProximityChecker:OnRemoveFromEntity()
    self.inst:RemoveTag("boatrace_proximitychecker")
end

-- Bake our "onupdate" into a separate function so we don't have to run it every frame.
local function OnUpdateProximity(inst)
    local self = inst.components.boatrace_proximitychecker
    local ix, iy, iz = inst.Transform:GetWorldPosition()

    local nearby_beacons = TheSim:FindEntities(ix, iy, iz, self.range, self.proximity_check_must_flags)
    if #nearby_beacons > 0 then
        local beacon_found_time
        local current_time = GetTime()
        for _, nearby_beacon in pairs(nearby_beacons) do
            self._per_update_found_beacons[nearby_beacon] = true

            beacon_found_time = self.stored_beacons[nearby_beacon]
            if not beacon_found_time then
                self.stored_beacons[nearby_beacon] = current_time
            elseif (beacon_found_time + self.found_delay) > current_time then
                self.stored_beacons[nearby_beacon] = current_time + (20 * TUNING.TOTAL_DAY_TIME)
                nearby_beacon:PushEvent("found_by_boatrace_checker", inst)
                if self.on_found_beacon then
                    self.on_found_beacon(inst, nearby_beacon)
                end
            end
        end
    end

    -- Clear out any beacons that we were storing, but did not find in this iteration.
    for beacon in pairs(self.stored_beacons) do
        if not self._per_update_found_beacons[beacon] then
            self.stored_beacons[beacon] = nil
        end
    end

    -- Clear out the "temporary" table for our next update, but keep the table itself alive.
    for beacon in pairs(self._per_update_found_beacons) do
        self._per_update_found_beacons[beacon] = nil
    end
end

function BoatRace_ProximityChecker:OnStartRace()
    if not self._race_update_task then
        self._race_update_task = self.inst:DoPeriodicTask(5*FRAMES, OnUpdateProximity)
    end
end

function BoatRace_ProximityChecker:OnFinishRace()
    if self._race_update_task then
        self._race_update_task:Cancel()
        self._race_update_task = nil
    end

    for beacon in pairs(self.stored_beacons) do
        self.stored_beacons[beacon] = nil
    end
    for beacon in pairs(self._per_update_found_beacons) do
        self._per_update_found_beacons[beacon] = nil
    end
end

return BoatRace_ProximityChecker