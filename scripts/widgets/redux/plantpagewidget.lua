local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"

--base class for all plant pages, anything in this class is expected to be in all the pages.
--note for modders: you don't have to use this base class, but your expected to implement all the functionality of this widget if you chose not to use this.
local PlantPageWidget = Class(Widget, function(self, name, plantspage, data)
    Widget._ctor(self, name)
    self.plantspage = plantspage
    self.data = data

    self.root = self:AddChild(Widget("root"))

    if not (TheInput:ControllerAttached() or IsConsole()) then
        self.back_button = self.root:AddChild(TEMPLATES.BackButton(function()
            self.plantspage:ClosePageWidget()
        end, nil, nil, 0.8))
        self.back_button:SetPosition(-396, -218)
        self.back_button:SetTextures("images/plantregistry.xml", "turnarrow_icon.tex", "turnarrow_icon_over.tex")
        self.back_button:SetFont(HEADERFONT)
        self.back_button:SetDisabledFont(HEADERFONT)

        --reset text with the new font
        self.back_button:SetText(STRINGS.UI.SERVERLISTINGSCREEN.BACK, true)
    end
end)

function PlantPageWidget:OnControl(control, down)
    if PlantPageWidget._base.OnControl(self, control, down) then return true end
    --back button when this has focus goes back a page instead of back a screen
    if not down and control == CONTROL_CANCEL then
        self.plantspage:ClosePageWidget()
        return true
    end
end

function PlantPageWidget:HasExclusiveHelpText()
    return true
end

function PlantPageWidget:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

    return table.concat(t, "  ")
end

--mods should override this if they provide a custom backdrop.
function PlantPageWidget:HideBackdrop()
    return false
end

return PlantPageWidget