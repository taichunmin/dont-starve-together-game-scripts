--[[
Add this component to items that need a targetting reticule
during use with a controller. Creation of the reticule is handled by
playercontroller.lua equip and unequip events.
--]]

local Reticule = Class(function(self, inst)
    self.inst = inst
    self.targetpos = nil
    self.ease = false
    self.smoothing = 6.66
    self.targetfn = nil
    self.mousetargetfn = nil
    self.updatepositionfn = nil
    self.reticuleprefab = "reticule"
    self.reticule = nil
    self.validcolour = { 204 / 255, 131 / 255, 57 / 255, .3 }
    self.invalidcolour = { 1, 0, 0, .3 }
    self.currentcolour = self.invalidcolour
    self.mouseenabled = false
    self.followhandler = nil
    self.fadealpha = 1
    self.blipalpha = 1
    self.pingprefab = nil
    self._oncameraupdate = function(dt) self:OnCameraUpdate(dt) end
end)

function Reticule:CreateReticule()
    if self.reticule == nil then
        self.reticule = SpawnPrefab(self.reticuleprefab)
        if self.reticule == nil then
            return
        end
    end

    if self.mouseenabled and not TheInput:ControllerAttached() then
        if self.followhandler == nil then
            self.followhandler = TheInput:AddMoveHandler(function(x, y)
                local x1, y1, z1 = TheSim:ProjectScreenPos(x, y)
                local pos = x1 ~= nil and y1 ~= nil and z1 ~= nil and Vector3(x1, y1, z1) or nil
                if self.mousetargetfn ~= nil then
                    self.targetpos = self.mousetargetfn(self.inst, pos)
                else
                    self.targetpos = pos
                end
                self:UpdatePosition()
            end)
        end
        local pos = TheInput:GetWorldPosition()
        if self.mousetargetfn ~= nil then
            self.targetpos = self.mousetargetfn(self.inst, pos)
        else
            self.targetpos = pos
        end
        self.fadealpha = 1
    else
        if self.followhandler ~= nil then
            self.followhandler:Remove()
            self.followhandler = nil
        end
        if self.targetfn ~= nil then
            self.targetpos = self.targetfn(self.inst)
        end
        self.fadealpha = 1
    end

    self.currentcolour = self.invalidcolour
    self.blipalpha = 1
    self.inst:StopUpdatingComponent(self)
    self:UpdatePosition()
    TheCamera:AddListener(self, self._oncameraupdate)
end

function Reticule:DestroyReticule()
    if self.reticule ~= nil then
        self.reticule:Remove()
        self.reticule = nil
    end
    if self.followhandler ~= nil then
        self.followhandler:Remove()
        self.followhandler = nil
    end
    self.fadealpha = 1
    self.blipalpha = 1
    self.inst:StopUpdatingComponent(self)
    TheCamera:RemoveListener(self, self._oncameraupdate)
end

function Reticule:PingReticuleAt(pos)
    if self.pingprefab ~= nil and pos ~= nil then
        local ping = SpawnPrefab(self.pingprefab)
        if ping ~= nil then
            ping.AnimState:SetMultColour(unpack(self.validcolour))
            ping.AnimState:SetAddColour(.2, .2, .2, 0)
            if self.updatepositionfn ~= nil then
                self.updatepositionfn(self.inst, pos, ping)
            else
                ping.Transform:SetPosition(pos.x, 0, pos.z)
            end
        end
    end
end

function Reticule:Blip()
    if self.reticule ~= nil then
        self.blipalpha = 0
        self.inst:StartUpdatingComponent(self)
        self:UpdateColour()
    end
end

function Reticule:OnUpdate(dt)

    self.blipalpha = self.blipalpha + dt * 5
    if self.blipalpha >= 1 then
        self.blipalpha = 1
        self.inst:StopUpdatingComponent(self)
    end
    if self.reticule then
        self:UpdateColour()
    end

end

function Reticule:UpdateColour()
    local a = self.targetpos ~= nil and self.fadealpha * self.blipalpha or self.blipalpha
    self.reticule.AnimState:SetMultColour(self.currentcolour[1] * a, self.currentcolour[2] * a, self.currentcolour[3] * a, self.currentcolour[4] * a)
end

function Reticule:UpdatePosition(dt)
    if self.targetpos ~= nil then
        local x, y, z = self.targetpos:Get()
        if  self.ispassableatallpoints or
            ( self.inst.components.aoetargeting ~= nil and self.inst.components.aoetargeting.alwaysvalid or
            (TheWorld.Map:IsPassableAtPoint(x, y, z) and not TheWorld.Map:IsGroundTargetBlocked(self.targetpos)) ) then
            self.currentcolour = self.validcolour
            self.reticule.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        else
            self.currentcolour = self.invalidcolour
            self.reticule.AnimState:ClearBloomEffectHandle()
        end

        if self.ease and dt ~= nil then
            local x0, y0, z0 = self.reticule.Transform:GetWorldPosition()
            x = Lerp(x0, x, dt * self.smoothing)
            z = Lerp(z0, z, dt * self.smoothing)
        end
        if self.updatepositionfn ~= nil then
            self.updatepositionfn(self.inst, Vector3(x, 0, z), self.reticule, self.ease, self.smoothing, dt)
        else
            self.reticule.Transform:SetPosition(x, 0, z)
        end
    end
    self:UpdateColour()
end

function Reticule:OnCameraUpdate(dt)
    if self.followhandler ~= nil then
        self.fadealpha = TheInput:GetHUDEntityUnderMouse() ~= nil and math.max(.3, self.fadealpha - .2) or math.min(1, self.fadealpha + .2)
        local pos = TheInput:GetWorldPosition()
        if self.mousetargetfn ~= nil then
            self.targetpos = self.mousetargetfn(self.inst, pos)
        else
            self.targetpos = pos
        end
        self:UpdatePosition(nil)
    elseif self.targetfn ~= nil then
        self.targetpos = self.targetfn(self.inst)
        self:UpdatePosition(dt) --always update for dt easing
    end
end

function Reticule:ShouldHide()
	return self.shouldhidefn ~= nil and self.shouldhidefn(self.inst) or false
end

Reticule.OnRemoveFromEntity = Reticule.DestroyReticule
Reticule.OnRemoveEntity = Reticule.DestroyReticule

return Reticule
