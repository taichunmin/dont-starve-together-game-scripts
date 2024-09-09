local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Button = require "widgets/button"
local Image = require "widgets/image"

-- Deprecated (especially for TrueScrollList). Use an ImageButton for each
-- element instead.
local ListCursor = Class(Button, function(self, atlas, normal, focus, disabled)
    Button._ctor(self, "ListCursor")

    self.selectedimage = self:AddChild(Image("images/serverbrowser.xml", "textwidget.tex"))
    self.selectedimage:SetTint(1,1,1,0)
    self.selectedimage:SetScale(.98,.95)
    self.selectedimage:SetPosition(-2,-2)
    self.highlight = self:AddChild(Image("images/serverbrowser.xml", "textwidget_over.tex"))
    self.highlight:SetTint(1,1,1,0)
    self.scroll_list = nil
end)

function ListCursor:SetParentList(list)
    self.scroll_list = list
end

function ListCursor:OnGainFocus()
	ListCursor._base.OnGainFocus(self)

    self.highlight:SetTint(1,1,1,1)
end

function ListCursor:OnLoseFocus()
	ListCursor._base.OnLoseFocus(self)

    self.highlight:SetTint(1,1,1,0)
end

function ListCursor:OnControl(control, down)
    if Button._base.OnControl(self, control, down) then return true end

    if not self:IsEnabled() or not self.focus then return false end

    if control == CONTROL_ACCEPT then
        if down then
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
            self.down = true
			if self.whiledown then
				self:StartUpdating()
			end
            if self.ondown then
                self.ondown()
            end
        else
            if self.down then
                self.down = false
                if self.onclick then
                    self.onclick()
                end
				self:StopUpdating()
            end
        end

        return true
    end

    if self.scroll_list and (control == CONTROL_SCROLLBACK or control == CONTROL_SCROLLFWD) then
        return self.scroll_list:OnControl(control, down, true)
    end
end

function ListCursor:OnFocusMove(dir, down)
    if self.scroll_list then
        return self.scroll_list:OnFocusMove(dir, down)
    end
    return false
end

function ListCursor:SetSelected(selected)
    if selected then
        self.selected = true
        self.selectedimage:SetTint(1,1,1,.9)
    else
        self.selectedimage:SetTint(1,1,1,0)
        self.selected = false
    end
end

function ListCursor:GetSize()
    return self.image:GetSize()
end

function ListCursor:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    if self.scroll_list and self.scroll_list.scroll_bar and self.scroll_list.scroll_bar:IsVisible() then
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_SCROLLBACK, false, false).."/"..TheInput:GetLocalizedControl(controller_id, CONTROL_SCROLLFWD, false, false).. " " .. STRINGS.UI.HELP.SCROLL)
    end

    table.insert(t, TheInput:GetLocalizedControl(controller_id, self.control, false, false ) .. " " .. self.help_message)

    return table.concat(t, "  ")
end

return ListCursor