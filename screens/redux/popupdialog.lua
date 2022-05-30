local Screen = require "widgets/screen"
local Text = require "widgets/text"
local Image = require "widgets/image"
local TEMPLATES = require "widgets/redux/templates"


local STYLES =
{
    -- This is a pretty terrible light theme.
    light = {
        bgconstructor = function(root, title, buttons, button_spacing, longness, body_text)
            local dialog = root:AddChild(TEMPLATES.CurlyWindow(600, longness.height, title, buttons, button_spacing, body_text))
            dialog.fill = dialog:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tiny.tex"))
            dialog.fill:SetSize(600, longness.height - 40)
            dialog.fill:SetPosition(0, 20)
            dialog.body:MoveToFront()
            return dialog
        end,
        text = {font=CHATFONT, size=28, colour=BLACK},
    },
    dark = {
        bgconstructor = function(root, title, buttons, button_spacing, longness, body_text)
            return root:AddChild(TEMPLATES.CurlyWindow(600, longness.height, title, buttons, button_spacing, body_text))
        end,
        text = {font=CHATFONT, size=28, colour=WHITE},
    },
    dark_wide = {
        bgconstructor = function(root, title, buttons, button_spacing, longness, body_text)
            return root:AddChild(TEMPLATES.CurlyWindow(750, longness.height, title, buttons, button_spacing, body_text))
        end,
        text = {font=CHATFONT, size=28, colour=WHITE},
    },
}

local LENGTHS =
{
    small = {
        height = 150,
    },
    medium = {
        height = 200,
    },
    big = {
        height = 250,
    },
	bigger = {
        height = 300,
	},
}

-- buttons and all following arguments are optional.
local PopupDialogScreen = Class(Screen, function(self, title, text, buttons, spacing_override, longness, style)
	Screen._ctor(self, "PopupDialogScreen")

    self.longness = LENGTHS[longness or "small"]
    assert(self.longness)
    self.style = STYLES[style or "dark"]
    assert(self.style)

    self.black = self:AddChild(TEMPLATES.BackgroundTint())

    self.proot = self:AddChild(TEMPLATES.ScreenRoot())
    self.dialog = self.style.bgconstructor(self.proot, title, buttons, spacing_override, self.longness, text)

	-- We don't have a body if `text` was nil.
    if self.dialog.body then
        self.dialog.body:SetColour(self.style.text.colour)
    end

	self.buttons = buttons or {}
    self.oncontrol_fn, self.gethelptext_fn = TEMPLATES.ControllerFunctionsFromButtons(self.buttons)

	self.default_focus = self.dialog
end)

function PopupDialogScreen:OnControl(control, down)
    if PopupDialogScreen._base.OnControl(self,control, down) then return true end

    return self.oncontrol_fn(control, down)
end


function PopupDialogScreen:Close()
	TheFrontEnd:PopScreen(self)
end

function PopupDialogScreen:GetHelpText()
    return self.gethelptext_fn()
end

return PopupDialogScreen
