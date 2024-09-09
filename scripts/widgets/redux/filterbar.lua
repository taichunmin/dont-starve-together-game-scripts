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

local modes = {
    [1] = {name = "SORT_RELEASE", image = "sort_release.tex",},
    [2] = {name = "SORT_NAME", image = "sort_name.tex",},
    [3] = {name = "SORT_RARITY", image = "sort_rarity.tex",},
    [4] = {name = "SORT_COUNT", image = "sort_count.tex",},
}
local MAX_MODES = #modes

local function GetInfoForModeName(name)
    for index, data in ipairs(modes) do
        if data.name == name then
            return index, data
        end
    end
end

function FilterBar:AddSorter()

    local btn = TEMPLATES.IconButton("images/button_icons.xml", modes[1].image)
    btn:SetScale(0.9)
    btn.SetSortType = function(_,sort_mode)

        btn:SetHoverText( subfmt(STRINGS.UI.WARDROBESCREEN.SORT_MODE_FMT, { mode = STRINGS.UI.WARDROBESCREEN[sort_mode] }) )
        local index, data = GetInfoForModeName(sort_mode)
        btn.icon:SetTexture("images/button_icons.xml", data.image)

        if not self.no_refresh_picker then
            self.picker:RefreshItems(self:_ConstructFilter())
        end
    end
    local function onclick()
        local sort_mode = Profile:GetItemSortMode() or "SORT_RELEASE"

        local index, data = GetInfoForModeName(sort_mode)
        index = index + 1
        if index > MAX_MODES then
            index = 1
        end
        sort_mode = modes[index].name

        Profile:SetItemSortMode(sort_mode)
        btn:SetSortType(sort_mode)
    end
    btn:SetOnClick(onclick)

    self.sort_btn = btn

    self:_UpdatePositions()

    return btn
end

local search_match = function( search, str )
    search = search:gsub(" ", "")
    str = str:gsub(" ", "")

    --Simple find in strings for multi word search
    if string.find( str, search, 1, true ) ~= nil then
        return true
    end
    local sub_len = string.len(search)

    if sub_len > 3 then
        if do_search_subwords( search, str, sub_len, 1 ) then return true end

        --Try again with 1 fewer character
        if do_search_subwords( search, str, sub_len - 1, 1 ) then return true end
    end

    return false
end

function FilterBar:AddSearch( thin )
    self.thin_mode = thin

    local searchbox = Widget("search")
    local box_size = 145
    if self.thin_mode then
        box_size = 120
    end
    local box_height = 40
    searchbox.textbox_root = searchbox:AddChild(TEMPLATES.StandardSingleLineTextEntry(nil, box_size, box_height))
    searchbox.textbox = searchbox.textbox_root.textbox
    searchbox.textbox:SetTextLengthLimit(16)
    searchbox.textbox:SetForceEdit(true)
    searchbox.textbox:EnableWordWrap(false)
    searchbox.textbox:EnableScrollEditWindow(true)
    searchbox.textbox:SetHelpTextEdit("")
    searchbox.textbox:SetHelpTextApply(STRINGS.UI.WARDROBESCREEN.SEARCH)
    searchbox.textbox:SetTextPrompt(STRINGS.UI.WARDROBESCREEN.SEARCH, UICOLOURS.GREY)
    searchbox.textbox.prompt:SetHAlign(ANCHOR_MIDDLE)
    searchbox.textbox.OnTextEntered = function()
        if self.search_delay then
            self.search_delay:Cancel()
            self.search_delay = nil
        end

        if not self.no_refresh_picker then
            self.picker:RefreshItems(self:_ConstructFilter())
        end
        if IsNotConsole() then
            searchbox.textbox:SetEditing(true)
        end
        self.entered_string = searchbox.textbox:GetString() --just used for filter on input below, so we can avoid triggering a second refresh
    end
    searchbox.textbox.OnTextInputted = function()
        if self.search_delay then
            self.search_delay:Cancel()
            self.search_delay = nil
        end

        if self.entered_string ~= searchbox.textbox:GetString() then
            self.search_delay = self.inst:DoTaskInTime(0.25, function()
                searchbox.textbox:OnTextEntered()
            end)
        end
    end


    self.filters["SEARCH"] = function(item_key)
        local search_str = TrimString(string.upper(searchbox.textbox:GetString()))
        if search_str == "" then
            --Early out
            return true
        end

        if search_match( search_str, string.upper(GetSkinName(item_key)) ) then
            return true
        end

        local base_prefab = GetSkinData(item_key).base_prefab
        if base_prefab ~= nil then
            if search_match( search_str, string.upper(STRINGS.NAMES[string.upper(base_prefab)]) ) then
                return true
            end
        end

        local collection_name = GetItemCollectionName(item_key)
        if collection_name ~= nil then
            if search_match( search_str, string.upper(collection_name) ) then
                return true
            end
        end

        return false
    end

     -- If searchbox ends up focused, highlight the textbox so we can tell something is focused.
    searchbox:SetOnGainFocus( function() searchbox.textbox:OnGainFocus() end )
    searchbox:SetOnLoseFocus( function() searchbox.textbox:OnLoseFocus() end )

    searchbox.focus_forward = searchbox.textbox

    self.search_box = searchbox

    self:_UpdatePositions()

    return searchbox
end

function FilterBar:HideFilter(id)
    for _,v in ipairs(self.filter_btns) do
        if v.btnid==id then
            v.widget:Hide()
            break
        end
    end

    self:_UpdatePositions()
end

function FilterBar:ShowFilter(id)
    for _,v in ipairs(self.filter_btns) do
        if v.btnid==id then
            v.widget:Show()
            break
        end
    end
    self:_UpdatePositions()
end

function FilterBar:_UpdatePositions()
    local width,_ = self.picker.scroll_list:GetScrollRegionSize()

    local squeeze = 0
    if self.thin_mode then
        squeeze = 12
    end

    local x_offset = 10

    local first_btn = nil
    local prev_btn = nil
    local num_btns = 0
    for a,v in ipairs(self.filter_btns) do
        if v.widget:IsVisible() then
            v.widget:SetPosition( x_offset + -width/2 + v.widget.size_x/2 + num_btns*v.widget.size_x - num_btns*squeeze, 3)
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
        self.sort_btn:SetPosition( x_offset + -width/2 + self.sort_btn.size_x/2 + num_btns*self.sort_btn.size_x - num_btns*squeeze, 3)
        num_btns = num_btns + 1
        if prev_btn then
            prev_btn:SetFocusChangeDir(MOVE_RIGHT, self.sort_btn)
            self.sort_btn:SetFocusChangeDir(MOVE_LEFT, prev_btn)
        end

        prev_btn = self.sort_btn
    end

    if self.search_box and prev_btn then
        local search_width = 80
        if self.thin_mode then
            search_width = 23
        end
        self.search_box:SetPosition( x_offset + -width/2 + num_btns*self.sort_btn.size_x + search_width, 4)

        prev_btn:SetFocusChangeDir(MOVE_RIGHT, self.search_box)
        self.search_box:SetFocusChangeDir(MOVE_LEFT, prev_btn)
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
