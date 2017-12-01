require("components/deployhelper")

local Placer = Class(function(self, inst)
    self.inst = inst

    self.can_build = false
    self.mouse_blocked = false
    self.testfn = nil
    self.radius = 1
    self.selected_pos = nil
    self.onupdatetransform = nil
    self.oncanbuild = nil
    self.oncannotbuild = nil
    self.linked = {}
end)

function Placer:SetBuilder(builder, recipe, invobject)
    self.builder = builder
    self.recipe = recipe
    self.invobject = invobject
    self.inst:StartUpdatingComponent(self)
end

function Placer:LinkEntity(ent)
    table.insert(self.linked, ent)
end

function Placer:GetDeployAction()
    if self.invobject ~= nil then
        self.selected_pos = self.inst:GetPosition()
        local action = BufferedAction(self.builder, nil, ACTIONS.DEPLOY, self.invobject, self.selected_pos, nil, nil, nil, self.inst.Transform:GetRotation())
        table.insert(action.onsuccess, function() self.selected_pos = nil end)
        return action
    end
end

function Placer:OnUpdate(dt)
    if ThePlayer == nil then
        return
    elseif not TheInput:ControllerAttached() then
        local pt = self.selected_pos or TheInput:GetWorldPosition()
        if self.snap_to_tile then
            self.inst.Transform:SetPosition(TheWorld.Map:GetTileCenterPoint(pt:Get()))
        elseif self.snap_to_meters then
            self.inst.Transform:SetPosition(math.floor(pt.x) + .5, 0, math.floor(pt.z) + .5)
        else
            self.inst.Transform:SetPosition(pt:Get())
        end
    elseif self.snap_to_tile then
        --Using an offset in this causes a bug in the terraformer functionality while using a controller.
        self.inst.Transform:SetPosition(TheWorld.Map:GetTileCenterPoint(ThePlayer.entity:LocalToWorldSpace(0, 0, 0)))
    elseif self.snap_to_meters then
        local x, y, z = ThePlayer.entity:LocalToWorldSpace(1, 0, 0)
        self.inst.Transform:SetPosition(math.floor(x) + .5, 0, math.floor(z) + .5)
    elseif self.onground then
        --V2C: this will keep ground orientation accurate and smooth,
        --     but unfortunately position will be choppy compared to parenting
        self.inst.Transform:SetPosition(ThePlayer.entity:LocalToWorldSpace(1, 0, 0))
    elseif self.inst.parent == nil then
        ThePlayer:AddChild(self.inst)
        self.inst.Transform:SetPosition(1, 0, 0)
    end

    if self.fixedcameraoffset ~= nil then
        local rot = self.fixedcameraoffset - TheCamera:GetHeading() -- rotate against the camera
        self.inst.Transform:SetRotation(rot)
        for i, v in ipairs(self.linked) do
            v.Transform:SetRotation(rot)
        end
    end

    if self.onupdatetransform ~= nil then
        self.onupdatetransform(self.inst)
    end

    if self.testfn ~= nil then
        self.can_build, self.mouse_blocked = self.testfn(self.inst:GetPosition(), self.inst:GetRotation())
    else
        self.can_build = true
        self.mouse_blocked = false
    end

    local x, y, z = self.inst.Transform:GetWorldPosition()
    TriggerDeployHelpers(x, y, z, 64)

    if self.can_build then
        if self.oncanbuild ~= nil then
            self.oncanbuild(self.inst, self.mouse_blocked)
            return
        end

        if self.mouse_blocked then
            self.inst:Hide()
            for i, v in ipairs(self.linked) do
                v:Hide()
            end
        else
            self.inst.AnimState:SetAddColour(.25, .75, .25, 0)
            self.inst:Show()
            for i, v in ipairs(self.linked) do
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
            for i, v in ipairs(self.linked) do
                v:Hide()
            end
        else
            self.inst.AnimState:SetAddColour(.75, .25, .25, 0)
            self.inst:Show()
            for i, v in ipairs(self.linked) do
                v.AnimState:SetAddColour(.75, .25, .25, 0)
                v:Show()
            end
        end
    end
end

return Placer
