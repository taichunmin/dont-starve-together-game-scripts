local function onenabled(self, enabled)
    --V2C: Recommended to explicitly add tag to prefab pristine state
    if enabled then
        self.inst:AddTag("crewmember")
    else
        self.inst:RemoveTag("crewmember")
    end
end

local CrewMember = Class(function(self, inst)
    self.inst = inst

    self.enabled = true
    self.max_velocity = 4
    self.max_target_dsq = TUNING.CREWMEMBER_TARGET_DSQ
    self.force = 1

    --self.leavecrewfn = nil

    --self.boat = nil
    self._on_boat_removed = function() self.boat = nil end
end,
nil,
{
    enabled = onenabled,
})


function CrewMember:OnRemoveFromEntity()
    self.inst:RemoveTag("crewmember")
end

function CrewMember:Shouldrow()
    local boat = self.inst:GetCurrentPlatform()
    if not boat or not self.boat or boat ~= self.inst.components.crewmember.boat then
        -- If we're not on our stored boat, don't try to row.
        return nil
    end

    boat = self.boat
    local boat_boatcrew = boat.components.boatcrew or boat.components.boatracecrew
    if not boat_boatcrew or (not boat_boatcrew.target and not boat_boatcrew.heading) then
        -- There's no direction set for the boat
        return nil
    end

    if boat_boatcrew.status == "assault" and
            boat_boatcrew.target and
            boat_boatcrew.target:IsValid() and
            boat:GetDistanceSqToInst(boat_boatcrew.target) < self.max_target_dsq then
        -- The boat is close enough to its assault target
        return nil
    else
        return true
    end
end

function CrewMember:SetBoat(boat)
    if self.boat then
        self.inst:RemoveEventCallback("onremove", self._on_boat_removed, self.boat)
    end

    self.boat = boat

    if boat then
        self.inst:ListenForEvent("onremove", self._on_boat_removed, boat)
    end
end

function CrewMember:GetBoat()
    return self.boat
end

function CrewMember:Leave()
    if self.boat then
        self.boat.components.boatcrew:RemoveMember(self.inst)
	end
end

function CrewMember:OnLeftCrew()
    if self.leavecrewfn then
        self.leavecrewfn(self.inst)
    end
end

function CrewMember:Enable(enabled)
    if not enabled and self.boat ~= nil then
        self.boat.components.boatcrew:RemoveMember(self.inst)
    end
    self.enabled = enabled
end

function CrewMember:Row()
    if not self.boat then return end

    local boat = self.boat
    if not boat then return end

    local boat_boatcrew = boat.components.boatcrew or boat.components.boatracecrew
    if not boat_boatcrew then return end

    local boat_physics = boat.components.boatphysics
    if not boat_physics then return end
    local boat_physics_x, boat_physics_z = boat_physics.velocity_x, boat_physics.velocity_z
    local boat_boatcrew_target = boat_boatcrew.target

    local can_stop = false
    if boat_boatcrew_target then
        local target_boat_physics = boat_boatcrew_target.components and boat_boatcrew_target.components.boatphysics or nil
        if target_boat_physics then
            local target_vector = Vector3(target_boat_physics.velocity_x, 0, target_boat_physics.velocity_z)
            local local_vector = Vector3(boat_physics_x, 0, boat_physics_z)

            local combo = target_vector + local_vector

            if combo:LengthSq() <= local_vector:LengthSq() then
                can_stop = true
            end
        end
    end

    local direction = "toward"
    if boat_boatcrew.status == "retreat" then

        local allthere = true
        for member in pairs(boat_boatcrew.members) do
            if member:GetCurrentPlatform() ~= self.inst.components.crewmember.boat then
                allthere = false
                break
            end
        end
        if allthere then
            direction = "away"
        end

    elseif boat_boatcrew_target and
        ((boat_boatcrew_target.IsValid and boat_boatcrew_target:IsValid() and boat:GetDistanceSqToInst(boat_boatcrew_target) < self.max_target_dsq) or 
            (not boat_boatcrew_target.IsValid and boat:GetDistanceSqToPoint(boat_boatcrew_target) < self.max_target_dsq)) 
            and can_stop then
        direction = "stop"

    end

    local row_direction_x, row_direction_z
    if direction == "stop" then
        row_direction_x, row_direction_z = VecUtil_Normalize(-boat_physics_x, -boat_physics_z)
    else
        -- GetHeadingNormal should already be normalized
        row_direction_x, row_direction_z = boat_boatcrew:GetHeadingNormal()
        if not row_direction_x or not row_direction_z then
            local pos = boat:GetPosition()
            local doer_x, _, doer_z = self.inst.Transform:GetWorldPosition()
            row_direction_x, row_direction_z = VecUtil_Normalize(pos.x - doer_x, pos.z - doer_z)
        end

        if direction == "away" then
            row_direction_x = -row_direction_x
            row_direction_z = -row_direction_z
        end
    end

    boat_physics:ApplyRowForce(row_direction_x, row_direction_z, self.force, boat_boatcrew.status == "delivery" and self.max_velocity*.65 or self.max_velocity)

	boat:PushEvent("rowed", self.inst)
end

function CrewMember:GetDebugString()
    return string.format("herd:%s %s", tostring(self.boat), (not self.enabled and "disabled") or "")
end

return CrewMember
