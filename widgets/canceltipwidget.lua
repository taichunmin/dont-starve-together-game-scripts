local Widget = require "widgets/widget"
local Text = require "widgets/text"

local CancelTipWidget = Class(Widget, function(self)
	Widget._ctor(self, "CancelTipWidget")
	self.global_widget = true
	self.initialized = false
	self.forceShowNextFrame = false
	self.is_enabled = false
    self:Hide()
	self:StartUpdating()
end)

function CancelTipWidget:SetEnabled(enabled)
    self.is_enabled = enabled
	if enabled then
		self.initialized = false
    	self:Show()
	else
		self:Hide()
		self.is_enabled = false
        self:Hide()
        self:StopUpdating()
	end
end

function CancelTipWidget:ShowNextFrame()
	self.forceShowNextFrame = true
end

function CancelTipWidget:KeepAlive( auto_increment )

	local just_initialized = false
	if self.initialized == false then
		local local_cancel_tip_widget = self:AddChild(Text(UIFONT, 33))
		local_cancel_tip_widget:SetPosition(0, -50)
		local_cancel_tip_widget:SetColour(1,1,1,0)
		local_cancel_tip_widget:SetHAlign(ANCHOR_LEFT)
		local_cancel_tip_widget:SetVAlign(ANCHOR_BOTTOM)
		local controller_id = TheInput:GetControllerID()
		if controller_id ==  0 then
			local_cancel_tip_widget:SetString(STRINGS.UI.NOTIFICATION.PRESS_KB..TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL)..STRINGS.UI.NOTIFICATION.DISCONNECT_KB)
		else
			local_cancel_tip_widget:SetString(STRINGS.UI.NOTIFICATION.PRESS_CONTROLLER..TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL)..STRINGS.UI.NOTIFICATION.DISCONNECT_CONTROLLER)
		end

		self.cancel_tip_widget = local_cancel_tip_widget
		self.cached_fade_level = 0.0
		self.initialized = true

		just_initialized = true
	end

	if self.initialized then
	    if self.is_enabled then
		    if TheFrontEnd and auto_increment == false then
			    self.cached_fade_level = TheFrontEnd:GetFadeLevel()
		    else
			    self.cached_fade_level = 1.0
		    end

		    self.cancel_tip_widget:SetColour(1,1,1,self.cached_fade_level*self.cached_fade_level)

		    if 0.01 > self.cached_fade_level then
		        self.is_enabled = false
		        self:Hide()
		        self:StopUpdating()
		    end
		end
	end
end

function CancelTipWidget:OnUpdate()
	self:KeepAlive(self.forceShowNextFrame)
	self.forceShowNextFrame = false
end

return CancelTipWidget
