local UIAnim = require("widgets/uianim")

local InspectaclesOver = Class(UIAnim, function(self, owner)
    self.owner = owner
    UIAnim._ctor(self)

    self:SetClickable(false)

    self:SetHAnchor(ANCHOR_MIDDLE)
    self:SetVAnchor(ANCHOR_MIDDLE)
    self:SetScaleMode(SCALEMODE_FIXEDSCREEN_NONDYNAMIC)

    local animstate = self:GetAnimState()
    animstate:SetBank("inspectacles_over")
    animstate:SetBuild("inspectacles_over")
    animstate:PlayAnimation("over_idle", true)

    self.tx, self.tz = 0, 0
    self.pinger = self:AddChild(UIAnim())
    self.pinger:SetHAnchor(ANCHOR_LEFT)
    self.pinger:SetVAnchor(ANCHOR_BOTTOM)
    self.pinger:GetAnimState():SetBank("winona_inspectacles_fx")
    self.pinger:GetAnimState():SetBuild("winona_inspectacles_fx")
    self.pinger:GetAnimState():AnimateWhilePaused(false)
    self.pinger:SetClickable(false)
    self.pinger:Hide()

    self:Hide()

    self.inst:ListenForEvent("inspectaclesvision", function(owner, data)
        self:Toggle(data.enabled)
    end, owner)
    self.inst:ListenForEvent("inspectaclesping", function(owner, data)
        self.tx, self.tz = data.tx, data.tz
        local x, y, z = owner.Transform:GetWorldPosition()
        local dx, dz = x - self.tx, z - self.tz
        local dsq = dx * dx + dz * dz
        if dsq > PLAYER_CAMERA_SEE_DISTANCE_SQ * 0.5 then -- Bias the vision to have more HUD pings over correctness of vision.
            if self.pingtask == nil then
                self:StartPing()
            end
        else
            if self.pingtask ~= nil then
                self:StopPing()
            end
        end
    end, owner)

    if owner ~= nil and owner.components.playervision ~= nil and owner.components.playervision:HasInspectaclesVision() then
        self:Toggle(true)
    end
    self.BUFFEROVERRIDES = false

    self.PingerStop = function(pinger)
        self:StopPing()
    end
end)

function InspectaclesOver:Toggle(show)
    if show and not self.shown then
        self:Enable()
    elseif not show and self.shown then
        self:Disable()
    end
    self.shown = show
end

function InspectaclesOver:Enable()
    if self.hidetask ~= nil then
        self.hidetask:Cancel()
        self.hidetask = nil
    end
    self:Show()

    local animstate = self:GetAnimState()
    animstate:PlayAnimation("over_pre")
    animstate:PushAnimation("over_idle", true)
	TheFrontEnd:GetSound():PlaySound("meta4/wires_minigame/inspectacles/overlay_activate")
end

function InspectaclesOver:Disable()
    local animstate = self:GetAnimState()
    animstate:PlayAnimation("over_pst")
	TheFrontEnd:GetSound():PlaySound("meta4/wires_minigame/inspectacles/overlay_deactivate")

    local duration = self.inst.AnimState:GetCurrentAnimationLength() + FRAMES
    if self.hidetask ~= nil then
        self.hidetask:Cancel()
        self.hidetask = nil
    end
    self.hidetask = self.inst:DoTaskInTime(duration, function(inst) self:Hide() end)

    self:StopPing()
end



function InspectaclesOver:StartPing()
    if self.pingtask ~= nil then
        self.pingtask:Cancel()
        self.pingtask = nil
    end
    self:StartUpdating()
    self:OnUpdate()
    self.pinger:Show()
    self.pinger:GetAnimState():PlayAnimation("radar")
    TheFrontEnd:GetSound():PlaySound("meta4/hologram_device/ping")
    local duration = self.pinger.inst.AnimState:GetCurrentAnimationLength() + FRAMES
    self.pingtask = self.pinger.inst:DoTaskInTime(duration, self.PingerStop)
end

function InspectaclesOver:StopPing()
    if self.pingtask ~= nil then
        self.pingtask:Cancel()
        self.pingtask = nil
    end
    self.pinger:Hide()
    self:StopUpdating()
    self.tx, self.tz = nil, nil
end

function InspectaclesOver:OnUpdate(dt)
    local x, y, angle = GetIndicatorLocationAndAngle(self.owner, self.tx, self.tz, 0, 0, self.BUFFEROVERRIDES)
    local sw, sh = TheSim:GetScreenSize()
    local angletocenter = math.atan2(y - sh * .5, x - sw * .5)
    local scale = self.pinger:GetScale()
    local r = 150
    x, y = x + r * math.cos(angletocenter) * scale.x, y + r * math.sin(angletocenter) * scale.y
    self.pinger:SetRotation(angle - 45)
    self.pinger:SetPosition(x, y)
end

return InspectaclesOver
