local Screen = require "widgets/screen"
local TEMPLATES = require "widgets/redux/templates"

local GenericWaitingPopup = Class(Screen, function(self, name, title_text, additional_buttons, forbid_cancel, cancel_cb )
    -- Need the child's widget name because we use it to distinguish behavior
    -- for different popups!
	Screen._ctor(self, name)

    self.black = self:AddChild(TEMPLATES.BackgroundTint())
	self.proot = self:AddChild(TEMPLATES.ScreenRoot())

	self.forbid_cancel = forbid_cancel
	self.cancel_cb = cancel_cb

    local buttons = additional_buttons or {}
    if not TheInput:ControllerAttached() then
		if not self.forbid_cancel then
			table.insert(buttons, {
					text=STRINGS.UI.LOBBYSCREEN.CANCEL,
					cb = function()
						self:OnCancel()
					end
				})
		end
    end

	local width = 470
	self.dialog = self.proot:AddChild(TEMPLATES.CurlyWindow(470, 100, title_text, buttons, nil, "."))

	if self.dialog.title then
		self.dialog.title:SetRegionSize(width+50, 80)
		self.dialog.title:SetPosition(0, -50)
		self.dialog.title:EnableWordWrap(true)
	end

	self.buttons = buttons
	self.default_focus = self.dialog

	self.time = 0
	self.progress = 0
end)

function GenericWaitingPopup:OnUpdate( dt )
	self.time = self.time + dt
	if self.time > 0.75 then
	    self.progress = self.progress + 1
	    if self.progress > 5 then
	        self.progress = 1
	    end

	    local text = string.rep(".", self.progress)
        self.dialog.body:SetString(text)
	    self.time = 0
	end
end

function GenericWaitingPopup:OnControl(control, down)
    if GenericWaitingPopup._base.OnControl(self,control, down) then
        return true
    end

    if not self.forbid_cancel and control == CONTROL_CANCEL and not down then
        self:OnCancel()
    end
end

function GenericWaitingPopup:OnCancel()
	if self.cancel_cb ~= nil then
		self.cancel_cb()
	end
	self:Disable()
	TheFrontEnd:PopScreen()
end

function GenericWaitingPopup:Close()
    self:OnCancel()
end

function GenericWaitingPopup:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

	if not self.forbid_cancel then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.CANCEL)
	end

    return table.concat(t, "  ")
end

return GenericWaitingPopup
