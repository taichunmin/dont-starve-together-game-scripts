-- Tabs that go on top of a window/dialog.
local Menu = require "widgets/menu"
local Widget = require "widgets/widget"

require("util")

local button_spacing = 160
local text_size = 30
local menu_style = "tabs"

local function ActivateButton(btn)
    btn:Select()
    btn:MoveToFront()
end
local function WrapCallbacks(header, menuitems)
    for i,entry in ipairs(menuitems) do
        local old_cb = entry.cb
        entry.cb = function(...)
            header.menu:UnselectAll()
            ActivateButton(header.menu.items[i])
            old_cb(...)
        end
    end
    return menuitems
end

-- only menuitems is required
local HeaderTabs = Class(Widget, function(self, menuitems, wrap_focus)
    Widget._ctor(self, "HeaderTabs")

    if IsConsole() then
        button_spacing = 180
        text_size = 20
    end

    self.menu = self:AddChild(Menu(WrapCallbacks(self, menuitems), button_spacing, true, menu_style, wrap_focus, text_size))
    self.menu:SetPosition(-(button_spacing*(#menuitems-1))/2, 0)
    self:SelectButton(1)

    self.focus_forward = self.menu
end)

function HeaderTabs:SelectButton(index)
    self.menu:UnselectAll()
    self.selected_index = circular_index_number(#self.menu.items, index)
    ActivateButton(self.menu.items[self.selected_index])
end

return HeaderTabs
