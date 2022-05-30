local Image = require "widgets/image"
local Menu = require "widgets/menu"
local Screen = require "widgets/screen"
local TEMPLATES = require "widgets/redux/templates"
local Text = require "widgets/text"
local Widget = require "widgets/widget"


-- This is mostly copied from TEMPLATES.CurlyWindow
local function AddTextToDialog(w, sizeX, sizeY, title_text, bottom_buttons, button_spacing, body_text)
    if title_text then
        w.title = w.top:AddChild(Text(TITLEFONT, 45, title_text, UICOLOURS.BLACK))
        w.title:SetPosition(0, -40)
        w.title:SetRegionSize(600, 50)
        w.title:SetHAlign(ANCHOR_MIDDLE)
        if JapaneseOnPS4() then
            w.title:SetSize(40)
        end
    end

    if bottom_buttons then
        -- If plain text widgets are passed in, then Menu will use this style.
        -- Otherwise, the style is ignored. Use appropriate style for the
        -- amount of space for buttons. Different styles require different
        -- spacing.
        local style = "carny_long"
        if button_spacing == nil then
            -- 1,2,3,4 buttons can be big at 170,340,510,680 widths.
            local space_per_button = sizeX / #bottom_buttons
            local has_space_for_big_buttons = space_per_button > 169
            if has_space_for_big_buttons then
                style = "carny_xlong"
                button_spacing = 320
            else
                button_spacing = 230
            end
        end
        local button_height = 50
        local button_area_width = button_spacing / 2 * #bottom_buttons
        local is_tight_bottom_fit = button_area_width > sizeX * 2/3
        if is_tight_bottom_fit then
            button_height = 60
        end

        -- Does text need to be smaller than 30 for JapaneseOnPS4()?
        w.actions = w.bottom:AddChild(Menu(bottom_buttons, button_spacing, true, style, nil, 30))
        w.actions:SetPosition(-(button_spacing*(#bottom_buttons-1))/2, button_height)

        --~ w.focus_forward = w.actions
    end

    if body_text then
        w.body = w:AddChild(Text(BUTTONFONT, 60, body_text, UICOLOURS.BLACK))
        w.body:EnableWordWrap(true)
        w.body:SetPosition(0, 20)
        local height_reduction = 0
        if bottom_buttons then
            height_reduction = 30
        end
        w.body:SetRegionSize(sizeX - 100, sizeY - 100 - height_reduction)
        w.body:SetVAlign(ANCHOR_MIDDLE)
    end
end

local WoodenSignPopup = Class(Screen, function(self, title_text, body_text, bottom_buttons)
	Screen._ctor(self, "WoodenSignPopup")

    self.black = self:AddChild(TEMPLATES.BackgroundTint())
    self.proot = self:AddChild(TEMPLATES.ScreenRoot())

    self.bg = self.proot:AddChild(Image("images/tradescreen_redux.xml", "woodenboard.tex"))

    local sizeX,sizeY = self.bg:GetSize()
    local button_spacing = nil

    self.dialog = self.proot:AddChild(Widget("dialog"))
    self.dialog.top = self.dialog:AddChild(Widget("top"))
    self.dialog.top:SetPosition(0,200)
    self.dialog.bottom = self.dialog:AddChild(Widget("bottom"))
    self.dialog.bottom:SetPosition(0,-210)
    AddTextToDialog(self.dialog, sizeX, sizeY, title_text, bottom_buttons, button_spacing, body_text)

	self.buttons = bottom_buttons or {}

	self.default_focus = self.dialog.actions
end)



function WoodenSignPopup:OnControl(control, down)
    if WoodenSignPopup._base.OnControl(self,control, down) then return true end

    if control == CONTROL_CANCEL and not down then
        if #self.buttons > 1 and self.buttons[#self.buttons] then
            self.buttons[#self.buttons].cb()
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
            return true
        end
    end
end


function WoodenSignPopup:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	local t = {}
	if #self.buttons > 1 and self.buttons[#self.buttons] then
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
    end
	return table.concat(t, "  ")
end

return WoodenSignPopup
