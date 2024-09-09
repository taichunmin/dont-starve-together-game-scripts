local UIAnim = require "widgets/uianim"
local easing = require "easing"

local BatOver = Class(UIAnim, function(self, owner)
    self.owner = owner
    UIAnim._ctor(self)

    self:SetClickable(false)

    self:SetHAnchor(ANCHOR_MIDDLE)
    self:SetVAnchor(ANCHOR_TOP)

    self:GetAnimState():SetBank("bat_tree_fx")
    self:GetAnimState():SetBuild("bat_tree_fx")
    self:GetAnimState():AnimateWhilePaused(false)
    self:Hide()

    self.scrnw = nil
    self.scrnh = nil
    self.soundlevel = 0
    self.sounddelay = 0
    self.inst:ListenForEvent("animover", function()
        self:Hide()
        self:StopUpdating()
    end)
    if owner ~= nil then
        self.inst:ListenForEvent("batspooked", function(owner) self:TriggerBats() end, owner)
    end
end)

function BatOver:TriggerBats()
    self.soundlevel = 1
    self.sounddelay = 0
    self:UpdateScale()
    self:StartUpdating()
    self:Show()
    self:GetAnimState():PlayAnimation(self.scrnw <= self.scrnh and "overlay_tall" or "overlay")
end

function BatOver:UpdateScale()
    local scrnh
    self.scrnw, scrnh = TheSim:GetScreenSize()
    if self.scrnh ~= scrnh then
        self.scrnh = scrnh
        local scale = scrnh / RESOLUTION_Y
        self:SetScale(scale, scale)
    end
end

function BatOver:OnUpdate(dt)
    if TheNet:IsServerPaused() then return end

    self:UpdateScale()

    if self.sounddelay > dt then
        self.sounddelay = self.sounddelay - dt
    elseif self.soundlevel > 0 then
        local volume = easing.outQuad(math.min(.75, self.soundlevel), 0, 1, .75)
        TheFocalPoint.SoundEmitter:PlaySound("dontstarve/creatures/bat/flap", nil, volume)
        if self.soundlevel > .05 then
            self.soundlevel = self.soundlevel - .05
            self.sounddelay = math.random(3, 4) * FRAMES
        else
            self.soundlevel = 0
            self.sounddelay = 0
        end
    end
end

return BatOver
