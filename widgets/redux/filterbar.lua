-- Display a filter bar for the item explorer
--
-- We should probably replace this with Menu.
local Text = require "widgets/text"
local Widget = require "widgets/widget"

local TEMPLATES = require "widgets/redux/templates"

require("skinsutils")

local FilterBar = Class(Widget, function(self, picker)
    Widget._ctor(self, "FilterBar")

    self.picker = picker

    self.filters = {}
    self.filter_btns = {}
end)

function FilterBar:AddFilter(ontext, offtext, id, filterfn)
    local btn = TEMPLATES.StandardButton(nil,
        "",
        {180, 45})

    local function onclick()
        if self.filters[id] == nil then
            self.filters[id] = filterfn
            btn:SetText(ontext)
        else
            self.filters[id] = nil
            btn:SetText(offtext)
        end
        self.picker:RefreshItems(self:_ConstructFilter())

    end
    btn:SetOnClick(onclick)
    btn:SetText(offtext)

    table.insert(self.filter_btns, {btnid=id, widget=btn})

    self:_UpdatePositions()

    return btn
end

function FilterBar:HideFilter(id)
    for _,v in ipairs(self.filter_btns) do
        if v.btnid==id then
            v.widget:Hide()
        end
    end

    self:_UpdatePositions()
end

function FilterBar:ShowFilter(id)
    for _,v in ipairs(self.filter_btns) do
        if v.btnid==id then
            v.widget:Show()
        end
    end
    self:_UpdatePositions()
end

function FilterBar:_UpdatePositions()
    local width,_ = self.picker.scroll_list:GetScrollRegionSize()

    local first_btn = nil
    local prev_btn = nil
    local num_btns = 0
    for _,v in ipairs(self.filter_btns) do
        if v.widget:IsVisible() then
            v.widget:SetPosition(-width/2 + v.widget.size_x/2 + num_btns*v.widget.size_x,0)
            num_btns = num_btns + 1

            if prev_btn then
                prev_btn:SetFocusChangeDir(MOVE_RIGHT, v.widget)
                v.widget:SetFocusChangeDir(MOVE_LEFT, prev_btn)
            else
                first_btn = v.widget
            end
            prev_btn = v.widget
        end
    end

    self.focus_forward = first_btn
end

function FilterBar:_ConstructFilter()
    local filter = function(item_key)
        for i,fn in pairs(self.filters) do
            if not fn(item_key) then
                return false
            end
        end

        return true
    end

    return filter
end

return FilterBar
