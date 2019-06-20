-- Display a filter bar for the item explorer
--
-- We should probably replace this with Menu.
local Widget = require "widgets/widget"

local TEMPLATES = require "widgets/redux/templates"

require("skinsutils")

local function GetTextScale()
	-- the Russian text is just too darn long
	local lang = LOC.GetLanguage()
	local scale = 20
	if (LANGUAGE.RUSSIAN == lang) or (LANGUAGE.PORTUGUESE_BR == lang) then
		scale = 16
	elseif (LANGUAGE.SPANISH == lang) or (LANGUAGE.SPANISH_LA == lang) then
		scale = 14
	end

	return  scale
end

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
    self.no_refresh_picker = true --we don't want to refresh the picker multiple times when setting the filter states and sort type. We're do one manual refresh once we're done updating
        for i,filter in ipairs(self.filter_btns) do
            local state = Profile:GetCustomizationFilterState(self.filter_category, filter.btnid)   
            filter.widget:SetFilterState(state)
        end

        if self.sort_btn then
            local sort_mode = Profile:GetItemSortMode() or "SORT_RELEASE"
            self.sort_btn:SetSortType(sort_mode)
        end
    self.no_refresh_picker = nil

    self.picker:RefreshItems(self:_ConstructFilter())
end

function FilterBar:AddFilter(text_fmt, on_tex, off_tex, id, filterfn)
    local btn = TEMPLATES.IconButton("images/button_icons.xml", on_tex)
    btn:SetScale(0.9)
    btn.SetFilterState = function(_, should_enable)
        if should_enable then
            btn:SetHoverText( subfmt(text_fmt, { mode = STRINGS.UI.WARDROBESCREEN.FILTER_ON }) )
            btn.icon:SetTexture("images/button_icons.xml", on_tex )
            self.filters[id] = filterfn
        else
            btn:SetHoverText( subfmt(text_fmt, { mode = STRINGS.UI.WARDROBESCREEN.FILTER_OFF }) )
            btn.icon:SetTexture("images/button_icons.xml", off_tex )
            self.filters[id] = nil
        end
        if not self.no_refresh_picker then
            self.picker:RefreshItems(self:_ConstructFilter())
        end
    end

    local function onclick()
        local was_off = self.filters[id] == nil
        btn:SetFilterState(was_off)
        Profile:SetCustomizationFilterState(self.filter_category, id, was_off)
    end
    btn:SetOnClick(onclick)

    table.insert(self.filter_btns, {btnid=id, widget=btn})

    self:_UpdatePositions()

    return btn
end

function FilterBar:AddSorter()

    local modes = {
        SORT_RELEASE = "sort_release.tex",
        SORT_NAME = "sort_name.tex",
        SORT_RARITY = "sort_rarity.tex",
        SORT_COUNT = "sort_count.tex",
    }

    local btn = TEMPLATES.IconButton("images/button_icons.xml", modes["SORT_RELEASE"])
    btn:SetScale(0.9)
    btn.SetSortType = function(_,sort_mode)

        btn:SetHoverText( subfmt(STRINGS.UI.WARDROBESCREEN.SORT_MODE_FMT, { mode = STRINGS.UI.WARDROBESCREEN[sort_mode] }) )
        btn.icon:SetTexture("images/button_icons.xml", modes[sort_mode] )
        
        if not self.no_refresh_picker then
            self.picker:RefreshItems(self:_ConstructFilter())
        end
    end
    local function onclick()
        local sort_mode = Profile:GetItemSortMode() or "SORT_RELEASE"

        sort_mode = next(modes, sort_mode)
        if sort_mode == nil then
            sort_mode = "SORT_RELEASE"
        end
        
        Profile:SetItemSortMode(sort_mode)
        btn:SetSortType(sort_mode)
    end
    btn:SetOnClick(onclick)

    self.sort_btn = btn

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

    local x_offset = 10

    local first_btn = nil
    local prev_btn = nil
    local num_btns = 0
    for a,v in ipairs(self.filter_btns) do
        if v.widget:IsVisible() then
            v.widget:SetPosition( x_offset + -width/2 + v.widget.size_x/2 + num_btns*v.widget.size_x, 3)
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

    --Sort button now
    if self.sort_btn then
        self.sort_btn:SetPosition( x_offset + -width/2 + self.sort_btn.size_x/2 + num_btns*self.sort_btn.size_x, 3
        )
        if prev_btn then
            prev_btn:SetFocusChangeDir(MOVE_RIGHT, self.sort_btn)
            self.sort_btn:SetFocusChangeDir(MOVE_LEFT, prev_btn)
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
