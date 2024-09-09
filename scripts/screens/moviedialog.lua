local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Video = require "widgets/video"

local MovieDialog = Class(Screen, function(self, movie_path, callback, do_fadeback)
    Screen._ctor(self, "MovieDialog")

    self.cb = callback
	self.do_fadeback = do_fadeback

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

	--if AUTOPLAY_SOAK then
	--	self.soaktask = self.inst:DoTaskInTime(5,
	--	function()
	--        self:Cancel()
	--	end)
	--end
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
		if self.do_fadeback then
			TheFrontEnd:FadeBack()
		else
	        TheFrontEnd:PopScreen()
		end
        if self.cb ~= nil then
            self.cb()
        end
    end
end

function MovieDialog:OnControl(control, down)
    if MovieDialog._base.OnControl(self, control, down) then
        return true
    elseif down and (control == CONTROL_MENU_START or control == CONTROL_ACCEPT) then
        self:Cancel()
        return true
    end
end

function MovieDialog:Cancel()
    self.cancelled = true
    if self.video ~= nil and not self.video:IsDone() then
        self.video:Stop()
    end
end

return MovieDialog
