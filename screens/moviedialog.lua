local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Video = require "widgets/video"

local MovieDialog = Class(Screen, function(self, movie_path, callback)
    Screen._ctor(self, "MovieDialog")

    self.cb = callback

    self.fixed_root = self:AddChild(Widget("root"))
    self.fixed_root:SetVAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetHAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.dark_card = self.fixed_root:AddChild(Image("images/global.xml", "square.tex"))
    self.dark_card:SetVRegPoint(ANCHOR_MIDDLE)
    self.dark_card:SetHRegPoint(ANCHOR_MIDDLE)
    self.dark_card:SetVAnchor(ANCHOR_MIDDLE)
    self.dark_card:SetHAnchor(ANCHOR_MIDDLE)
    self.dark_card:SetTint(0,0,0,1)
    self.dark_card:SetScaleMode(SCALEMODE_FILLSCREEN)

    self.video = self.fixed_root:AddChild(Video("video"))
    self.video:Load( movie_path )
    self.video:SetSize( RESOLUTION_X, RESOLUTION_Y )
    self.video:Play()

    self.end_delay = 2
end)

function MovieDialog:OnUpdate(dt)
    if self.video ~= nil then
        if not self.video:IsDone() then
            return
        end
        self.video:Kill()
        self.video = nil
    end

    if not self.cancelled and self.end_delay > dt then
        self.end_delay = self.end_delay - dt
    else
        TheFrontEnd:PopScreen()
        if self.cb ~= nil then
            self.cb()
        end
    end
end

function MovieDialog:OnControl(control, down)
    if MovieDialog._base.OnControl(self, control, down) then
        return true
    elseif down and control == CONTROL_PAUSE then
        self.cancelled = true
        if self.video ~= nil and not self.video:IsDone() then
            self.video:Stop()
        end
        return true
    end
end

return MovieDialog
