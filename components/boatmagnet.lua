local BoatMagnet = Class(function(self, inst)
    self.inst = inst
	--self.boat = nil
    --self.beacon = nil
    --self.magnet_guid = nil
    --self.pair_tags = nil

    self.canpairwithfn = function(beacon)
        return beacon ~= nil
            and beacon.components.boatmagnetbeacon ~= nil
            and beacon.components.boatmagnetbeacon:PairedMagnet() == nil
    end

    self.ClearEverything = function()
        if self._setup_boat_task then
            self._setup_boat_task:Cancel()
            self._setup_boat_task = nil
        end
        self:SetBoat(nil)
        self:UnpairWithBeacon()
    end

    --self.onpairedwithbeaconfn = nil
    --self.onunpairedwithbeaconfn = nil

    --self.beaconturnedonfn = nil
    self.OnBeaconTurnedOn = function()
        if self.beaconturnedonfn then
            self.beaconturnedonfn(self.inst, self.beacon)
        end
    end

    --self.beaconturnedofffn = nil
    self.OnBeaconTurnedOff = function()
        if self.beaconturnedofffn then
            self.beaconturnedofffn(self.inst, self.beacon)
        end
    end

    self.OnInventoryBeaconLoaded = function(_, data)
        if data and data.guid == self.prev_guid then
            self:PairWithBeacon(data.inst)
        end
    end

    self._setup_boat_task = self.inst:DoTaskInTime(0, function()
        self:SetBoat(self.inst:GetCurrentPlatform())
        self._setup_boat_task = nil
    end)
end)

function BoatMagnet:OnSave()
    local data = {
        magnet_guid = self.inst.GUID,
    }
    return data
end

function BoatMagnet:OnLoad(data)
    if not data then
        return
    end

    -- NOTES(JBK): 'prev_guid' is for beta worlds that might have this old vague name.
    self.magnet_guid = data.magnet_guid or data.prev_guid
end

function BoatMagnet:OnRemoveFromEntity()
    if self._setup_boat_task then
        self._setup_boat_task:Cancel()
        self._setup_boat_task = nil
    end
    self:UnpairWithBeacon() -- Handles event listeners.
end

function BoatMagnet:OnRemoveEntity()
    self:ClearEverything()
end

function BoatMagnet:SetBoat(boat)
    if boat == self.boat then return end

    if self.boat then
        self.boat.components.boatphysics:RemoveMagnet(self)
        self.inst:RemoveEventCallback("onremove", self.ClearEverything, self.boat)
        self.inst:RemoveEventCallback("death", self.ClearEverything, self.boat)
    end

    self.boat = boat

    if boat then
        boat.components.boatphysics:AddMagnet(self)
        self.inst:ListenForEvent("onremove", self.ClearEverything, boat)
        self.inst:ListenForEvent("death", self.ClearEverything, boat)
    end
end

function BoatMagnet:IsActivated()
    return self.beacon ~= nil
end

function BoatMagnet:PairedBeacon()
    return self.beacon
end

function BoatMagnet:IsBeaconOnSameBoat(beacon)
    return beacon ~= nil
        and beacon.components.boatmagnetbeacon ~= nil
        and beacon.components.boatmagnetbeacon:GetBoat() == self.boat
end

local BEACON_MUST_TAGS = { "boatmagnetbeacon" }
function BoatMagnet:FindNearestBeacon()
    -- Pair with the closest beacon in range
    local pair_tags = self.pair_tags or BEACON_MUST_TAGS
    local nearestbeacon = FindClosestEntity(self.inst, TUNING.BOAT.BOAT_MAGNET.PAIR_RADIUS, true, pair_tags, nil, nil, self.canpairwithfn)
    return (nearestbeacon ~= nil
            and nearestbeacon.components.boatmagnetbeacon ~= nil
            and nearestbeacon.components.boatmagnetbeacon:PairedMagnet() == nil
            and nearestbeacon)
        or nil
end

function BoatMagnet:PairWithBeacon(beacon)
    if not beacon or not beacon.components.boatmagnetbeacon then
        return
    end

    self.beacon = beacon
    beacon.components.boatmagnetbeacon:PairWithMagnet(self.inst)

    self.inst:ListenForEvent("onremove", self.UnpairWithBeacon, beacon)
    self.inst:ListenForEvent("death", self.UnpairWithBeacon, beacon)
    self.inst:ListenForEvent("onturnon", self.OnBeaconTurnedOn, beacon)
    self.inst:ListenForEvent("onturnoff", self.OnBeaconTurnedOff, beacon)

    self.inst:StartUpdatingComponent(self)

    if self.onpairedwithbeaconfn then
        self.onpairedwithbeaconfn(self.inst, beacon)
    end

    self.inst:AddTag("paired")
end

function BoatMagnet:UnpairWithBeacon()
    if not self.beacon then
        return
    end

    self.inst:RemoveEventCallback("onremove", self.UnpairWithBeacon, self.beacon)
    self.inst:RemoveEventCallback("death", self.UnpairWithBeacon, self.beacon)
    self.inst:RemoveEventCallback("onturnon", self.OnBeaconTurnedOn, self.beacon)
    self.inst:RemoveEventCallback("onturnoff", self.OnBeaconTurnedOff, self.beacon)

    if self.beacon:IsValid() and self.beacon.components.boatmagnetbeacon then
        self.beacon.components.boatmagnetbeacon:UnpairWithMagnet()
    end

    self.beacon = nil

    self.inst:StopUpdatingComponent(self)

    if self.onunpairedwithbeaconfn then
        self.onunpairedwithbeaconfn(self.inst)
    end

    self.inst:RemoveTag("paired")
end

function BoatMagnet:GetFollowTarget()
    if not self.beacon then
        return nil
    end

    local beacon_boatmagnetbeacon = self.beacon.components.boatmagnetbeacon
    if not beacon_boatmagnetbeacon then
        return nil
    end

    return beacon_boatmagnetbeacon:GetBoat() or
        (beacon_boatmagnetbeacon:IsPickedUp() and beacon_boatmagnetbeacon.inst.entity:GetParent())
        or self.beacon
end

function BoatMagnet:CalcMaxVelocity()
    if not self.boat or not self.beacon
            or not self.beacon.components.boatmagnetbeacon
            or self.beacon.components.boatmagnetbeacon:IsTurnedOff() then
        return 0
    end

    local followtarget = self:GetFollowTarget()
    if not followtarget then
        return 0
    end

    -- Beyond a set distance, apply an exponential rate for catch-up speed, otherwise match the speed of the beacon its following
    local direction, distance = self:CalcMagnetDirection()

    local beaconboat = self.beacon.components.boatmagnetbeacon:GetBoat()

    local beaconspeed = (beaconboat == nil and followtarget.components.locomotor ~= nil and math.min(followtarget.components.locomotor:GetRunSpeed(), TUNING.BOAT.MAX_VELOCITY))
                        or (beaconboat ~= nil and math.min(beaconboat.components.boatphysics:GetVelocity(), TUNING.BOAT.MAX_FORCE_VELOCITY))
                        or 0

    local mindistance = (self.boat.components.hull ~= nil and self.boat.components.hull:GetRadius()) or 1
    if beaconboat and beaconboat.components.hull then
        mindistance = mindistance + beaconboat.components.hull:GetRadius()
    end

    -- If the beacon boat is turning, reduce max speed to prevent too much drifting while turning
    local magnetboatdirection = self.boat.components.boatphysics:GetMoveDirection()
    local magnetdir_x, magnetdir_z = VecUtil_NormalizeNoNaN(magnetboatdirection.x, magnetboatdirection.z)

    local beaconboatdirection = (beaconboat == nil and followtarget.components.locomotor and Vector3(followtarget.Physics:GetVelocity()))
                            or (beaconboat ~= nil and beaconboat.components.boatphysics:GetMoveDirection())
                            or Vector3(0, 0, 0)
    local beacondir_x, beacondir_z = VecUtil_NormalizeNoNaN(beaconboatdirection.x, beaconboatdirection.z)

    local boatspeed = self.boat.components.boatphysics:GetVelocity()

    local turnspeedmodifier = (boatspeed > 0 and beaconspeed > 0 and math.max(VecUtil_Dot(magnetdir_x, magnetdir_z, beacondir_x, beacondir_z), 0)) or 1
    local maxdistance = TUNING.BOAT.BOAT_MAGNET.MAX_DISTANCE / 2

    if distance > mindistance then
        local base = math.pow(TUNING.BOAT.BOAT_MAGNET.MAX_VELOCITY + TUNING.BOAT.BOAT_MAGNET.CATCH_UP_SPEED, 1 / maxdistance)
        local maxspeed = beaconspeed + (math.pow(base, distance - mindistance) - 1) * turnspeedmodifier
        return math.min(maxspeed, TUNING.BOAT.BOAT_MAGNET.MAX_VELOCITY + TUNING.BOAT.BOAT_MAGNET.CATCH_UP_SPEED)
    else
        local maxspeed = beaconspeed * turnspeedmodifier
        return math.min(maxspeed, TUNING.BOAT.BOAT_MAGNET.MAX_VELOCITY)
    end
end

function BoatMagnet:CalcMagnetDirection()
    local followtarget = self:GetFollowTarget()
    if not followtarget then
        return Vector3(0, 0, 0)
    end

    -- Calculate distance between magnet & beacon.
    -- If we're carrying a beacon but walking on a boat, use the boat's position instead
    local boatpos = self.boat:GetPosition()
    local targetpos = followtarget:GetPosition()
    local vel_x, vel_z = VecUtil_NormalizeNoNaN(VecUtil_Sub(targetpos.x, targetpos.z, boatpos.x, boatpos.z))

    local direction = Vector3(vel_x, 0, vel_z)
    local distance = VecUtil_Dist(targetpos.x, targetpos.z, boatpos.x, boatpos.z)

    return direction, distance
end

function BoatMagnet:CalcMagnetForce()
    if not self.beacon or not self.boat then
        return 0
    end

    local beacon = self.beacon.components.boatmagnetbeacon
    local boatphysics = self.boat.components.boatphysics
    if not beacon or beacon:IsTurnedOff() or not boatphysics then
        return 0
    end

    -- If on a boat, follow the boat, otherwise follow the entity that's carrying the beacon in their inventory
    local followtarget = self:GetFollowTarget()
    if not followtarget then
        return 0
    end

    local direction, distance  = self:CalcMagnetDirection()

    -- Calcuate the minimum distance a magnet can reach the beacon so boats don't ram into one another
    local mindistance = 1

    local self_hull = self.boat.components.hull
    if self_hull then
        mindistance = mindistance + (self_hull:GetRadius() or 0)
    else
        local beaconboat = beacon:GetBoat()
        local beaconboat_hull = (beaconboat and beaconboat.components.hull) or nil
        if beaconboat_hull then
            mindistance = mindistance + (beaconboat_hull:GetRadius() or 0)
        end
    end

    return (distance > mindistance and TUNING.BOAT.BOAT_MAGNET.MAGNET_FORCE) or 0
end

function BoatMagnet:OnUpdate(dt)
    if not self.boat or not self.beacon then
        return
    end

    local beacon_boatmagnetbeacon = self.beacon.components.boatmagnetbeacon
    if not beacon_boatmagnetbeacon then
        return
    end

    local beaconboat = beacon_boatmagnetbeacon:GetBoat()
    local boat_is_beaconboat = (self.boat == beaconboat)

    -- Handle if the beacon is being carried on the same boat as the magnet
    if boat_is_beaconboat then
        self.inst:PushEvent("boatmagnet_pull_stop")
        return
    elseif not boat_is_beaconboat and not beacon_boatmagnetbeacon:IsTurnedOff() then
        self.inst:PushEvent("boatmagnet_pull_start")
    end

    local followtarget = self:GetFollowTarget()
    if not followtarget then
        self:UnpairWithBeacon()
        return
    end

    local direction, distance = self:CalcMagnetDirection()

    -- Disengage if we're too far from the beacon
    if distance > TUNING.BOAT.BOAT_MAGNET.MAX_DISTANCE then
        self:UnpairWithBeacon()
        return
    end

    -- Rotate to face the target it's following. If on the same boat, set rotation to zero.
    self.inst.Transform:SetRotation(
        (not boat_is_beaconboat and -VecUtil_GetAngleInDegrees(direction.x, direction.z))
        or 0
    )
end

--
function BoatMagnet:GetDebugString()
    return (self.beacon ~= nil and tostring(self.beacon)) or ""
end

return BoatMagnet
