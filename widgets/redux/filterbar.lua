-- Display a filter bar for the item explorer
--
-- We should probably replace this with Menu.
local Widget = require "widgets/widget"

local TEMPLATES = require "widgets/redux/templates"

require("skinsutils")

local FilterBar = Class(Widget, function(self, picker, filter_category)
    Widget._ctor(self, "FilterBar")

    self.picker = picker
    self.filter_category = filter_category

    self.filters = {}
    self.filter_btns = {}
end)

-- Instead of giving focus to picker or FilterBar, give it to this function.
function FilterBar:BuildFocusFinder()
    return function()
        -- If we have no items to display, then we can't push focus to the
        -- picker since it will contain nothing to focus.
        if self.picker.scroll_list and #self.picker.scroll_list.items > 0 then
            return self.picker 
        else
            return self
        end
    end
end

function FilterBar:RefreshFilterState()
    for i,filter in ipairs(self.filter_btns) do
        local state = Profile:GetCustomizationFilterState(self.filter_category, filter.btnid)   
        filter.widget:SetFilterState(state)
    end
end

function FilterBar:AddFilter(ontext, offtext, id, filterfn)
    local btn = TEMPLATES.StandardButton(nil,
        "",
        {180, 45})

    btn.SetFilterState = function(_, should_enable)
        if should_enable then
            self.filters[id] = filterfn
            btn:SetText(ontext)
        else
            self.filters[id] = nil
            btn:SetText(offtext)
        end
        self.picker:RefreshItems(self:_ConstructFilter())
    end
    local function onclick()
        local was_off = self.filters[id] == nil
        btn:SetFilterState(was_off)
        Profile:SetCustomizationFilterState(self.filter_category, id, was_off)
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
