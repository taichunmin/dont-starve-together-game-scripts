require("components/deployhelper")

local Placer = Class(function(self, inst)
    self.inst = inst

    self.can_build = false
    self.mouse_blocked = nil
    self.testfn = nil
    self.radius = 1
    self.selected_pos = nil
    self.onupdatetransform = nil
    self.oncanbuild = nil
    self.oncannotbuild = nil
    self.onfailedplacement = nil
    self.linked = {}
    self.offset = 1

	self.hide_inv_icon = true

    self.override_build_point_fn = nil
    self.override_testfn = nil

    self.BOAT_MUST_TAGS = { "boat" } --probably don't want static, but still cached per placer at least
end)

function Placer:OnRemoveEntity()
    if self.builder ~= nil and self.hide_inv_icon then
        self.builder:PushEvent("onplacerhidden")
    end
end

Placer.OnRemoveFromEntity = Placer.OnRemoveEntity

function Placer:SetBuilder(builder, recipe, invobject)
    self.builder = builder
    self.recipe = recipe
    self.invobject = invobject
    self.inst:StartWallUpdatingComponent(self)
end

function Placer:LinkEntity(ent, lightoverride)
    table.insert(self.linked, ent)
	if lightoverride == nil or lightoverride > 0 then
		ent.AnimState:SetLightOverride(lightoverride or 1)
	end
end

function Placer:GetDeployAction()
    if self.invobject ~= nil then
        self.selected_pos = self.inst:GetPosition()
        local action = BufferedAction(self.builder, nil, ACTIONS.DEPLOY, self.invobject, self.selected_pos, nil, nil, nil, self.inst.Transform:GetRotation())
        table.insert(action.onsuccess, function() self.selected_pos = nil end)
        return action
    end
end

function Placer:TestCanBuild() -- NOTES(JBK): This component assumes the self.inst is at the location to test.
    local can_build, mouse_blocked
    if self.override_testfn ~= nil then
        can_build, mouse_blocked = self.override_testfn(self.inst)
    elseif self.testfn ~= nil then
        can_build, mouse_blocked = self.testfn(self.inst:GetPosition(), self.inst:GetRotation())
    else
        can_build = true
        mouse_blocked = false
    end
    return can_build, mouse_blocked
end

function Placer:OnUpdate(dt)
    local rotating_from_boat_center
    local hide_if_cannot_build

    if ThePlayer == nil then
        return
    elseif not TheInput:ControllerAttached() then
        local pt = self.selected_pos or TheInput:GetWorldPosition()
        if self.snap_to_tile then
            self.inst.Transform:SetPosition(TheWorld.Map:GetTileCenterPoint(pt:Get()))
        elseif self.snap_to_meters then
            self.inst.Transform:SetPosition(math.floor(pt.x) + .5, 0, math.floor(pt.z) + .5)
		elseif self.snaptogrid then
			self.inst.Transform:SetPosition(math.floor(pt.x + .5), 0, math.floor(pt.z + .5))
        elseif self.snap_to_boat_edge then
            local boats = TheSim:FindEntities(pt.x, 0, pt.z, TUNING.MAX_WALKABLE_PLATFORM_RADIUS, self.BOAT_MUST_TAGS)
            local boat = GetClosest(self.inst, boats)

            if boat then
                SnapToBoatEdge(self.inst, boat, pt)
                if self.inst:GetDistanceSqToPoint(pt) > 1 then
                    hide_if_cannot_build = true
                end
            else
                self.inst.Transform:SetPosition(pt:Get())
                hide_if_cannot_build = true
            end
        else
            self.inst.Transform:SetPosition(pt:Get())
        end

        -- Set the placer's rotation to point away from the boat's center point
        if self.rotate_from_boat_center then
            local boat = TheWorld.Map:GetPlatformAtPoint(pt.x, pt.z)
            if boat ~= nil then
                local angle = GetAngleFromBoat(boat, pt.x, pt.z) / DEGREES
                self.inst.Transform:SetRotation(-angle)
                rotating_from_boat_center = true
            end
        end
    elseif self.snap_to_tile then
        --Using an offset in this causes a bug in the terraformer functionality while using a controller.
        self.inst.Transform:SetPosition(TheWorld.Map:GetTileCenterPoint(ThePlayer.entity:LocalToWorldSpace(0, 0, 0)))
    elseif self.snap_to_meters then
        local x, y, z = ThePlayer.entity:LocalToWorldSpace(self.offset, 0, 0)
        self.inst.Transform:SetPosition(math.floor(x) + .5, 0, math.floor(z) + .5)
	elseif self.snaptogrid then
		local x, y, z = ThePlayer.entity:LocalToWorldSpace(self.offset, 0, 0)
		self.inst.Transform:SetPosition(math.floor(x + .5), 0, math.floor(z + .5))
    elseif self.snap_to_boat_edge then
        local x, y, z = ThePlayer.entity:LocalToWorldSpace(self.offset, 0, 0)
        local boat = ThePlayer:GetCurrentPlatform()
        if boat and boat:HasTag("boat") then
            SnapToBoatEdge(self.inst, boat, Vector3(x, 0, z))
        else
            self.inst.Transform:SetPosition(x, 0, z)
        end
    elseif self.onground then
        --V2C: this will keep ground orientation accurate and smooth,
        --     but unfortunately position will be choppy compared to parenting
        --V2C: switched to WallUpdate, so should be smooth now
        local x, y, z = ThePlayer.entity:LocalToWorldSpace(self.offset, 0, 0)
        self.inst.Transform:SetPosition(x, y, z)
        if self.controllergroundoverridefn then
            self.controllergroundoverridefn(self, ThePlayer, x, y, z)
        end
    elseif self.inst.parent == nil then
--        ThePlayer:AddChild(self.inst)
--        self.inst.Transform:SetPosition(self.offset, 0, 0) -- this will cause the object to be rotated to face the same direction as the player, which is not what we want, rotate the camera if you want to rotate the object
        local x, y, z = ThePlayer.entity:LocalToWorldSpace(self.offset, 0, 0)
        self.inst.Transform:SetPosition(x, y, z)

        -- Set the placer's rotation to point away from the boat's center point
        if self.rotate_from_boat_center then
            local boat = TheWorld.Map:GetPlatformAtPoint(x, z)
            if boat ~= nil then
                local angle = GetAngleFromBoat(boat, x, z) / DEGREES
                self.inst.Transform:SetRotation(-angle)
                rotating_from_boat_center = true
            end
        end
    end

    if self.fixedcameraoffset ~= nil and not rotating_from_boat_center then
        local rot = self.fixedcameraoffset - TheCamera:GetHeading() -- rotate against the camera
        local offset = self.rotationoffset ~= nil and self.rotationoffset or 0
        self.inst.Transform:SetRotation(rot + offset)
    end

    if self.onupdatetransform ~= nil then
        self.onupdatetransform(self.inst)
    end

	local was_mouse_blocked = self.mouse_blocked

    self.can_build, self.mouse_blocked = self:TestCanBuild()

    if hide_if_cannot_build and not self.can_build then
        self.mouse_blocked = true
    end

    if self.builder ~= nil and was_mouse_blocked ~= self.mouse_blocked and self.hide_inv_icon then
		self.builder:PushEvent(self.mouse_blocked and "onplacerhidden" or "onplacershown")
	end

	local x, y, z = self.inst.Transform:GetWorldPosition()
    TriggerDeployHelpers(x, y, z, 64, self.recipe, self.inst)

    if self.can_build then
        if self.oncanbuild ~= nil then
            self.oncanbuild(self.inst, self.mouse_blocked)
            return
        end

        if self.mouse_blocked then
            self.inst:Hide()
            for _, v in ipairs(self.linked) do
                v:Hide()
            end
        else
            self.inst.AnimState:SetAddColour(.25, .75, .25, 0)
            self.inst:Show()
            for _, v in ipairs(self.linked) do
                v.AnimState:SetAddColour(.25, .75, .25, 0)
                v:Show()
            end
        end
    else
        if self.oncannotbuild ~= nil then
            self.oncannotbuild(self.inst, self.mouse_blocked)
            return
        end

        if self.mouse_blocked then
            self.inst:Hide()
            for _, v in ipairs(self.linked) do
                v:Hide()
            end
        else
            self.inst.AnimState:SetAddColour(.75, .25, .25, 0)
            self.inst:Show()
            for _, v in ipairs(self.linked) do
                v.AnimState:SetAddColour(.75, .25, .25, 0)
                v:Show()
            end
        end
    end
end

--V2C: support old mods that were overwriting OnUpdate
function Placer:OnWallUpdate(dt)
    self:OnUpdate(dt)
end

return Placer
