local Screen = require "widgets/screen"
local TEMPLATES = require "widgets/redux/templates"

local GenericWaitingPopup = Class(Screen, function(self, name, title_text, additional_buttons, forbid_cancel)
    -- Need the child's widget name because we use it to distinguish behavior
    -- for different popups!
	Screen._ctor(self, name)

    self.black = self:AddChild(TEMPLATES.BackgroundTint())
	self.proot = self:AddChild(TEMPLATES.ScreenRoot())

	self.forbid_cancel = forbid_cancel

    local buttons = additional_buttons or {}
    if not self.forbid_cancel then
        table.insert(buttons, {
                text=STRINGS.UI.NOAUTHENTICATIONSCREEN.CANCELBUTTON,
                cb = function() 
                    self:OnCancel()            
                end
            })
    end
	self.dialog = self.proot:AddChild(TEMPLATES.CurlyWindow(470, 100, title_text, buttons, nil, "."))

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
    self:Disable()
    TheFrontEnd:PopScreen()
end

function GenericWaitingPopup:Close()
    self:OnCancel()
end

return GenericWaitingPopup
