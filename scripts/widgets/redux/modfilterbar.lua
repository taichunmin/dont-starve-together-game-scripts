-- Display a filter bar for the item explorer
--
-- We should probably replace this with Menu.
local Widget = require "widgets/widget"

local TEMPLATES = require "widgets/redux/templates"

local ModFilterBar = Class(Widget, function(self, modstab, filter_category)
    Widget._ctor(self, "ModFilterBar")

    self.modstab = modstab
    self.filter_category = filter_category

    self.filters = {}
    self.filter_btns = {}
end)

-- Instead of giving focus to modstab or ModFilterBar, give it to this function.
function ModFilterBar:BuildFocusFinder()
    return function()
        -- If we have no items to display, then we can't push focus to the
        -- modstab since it will contain nothing to focus.
        if self.modstab.mods_scroll_list and #self.modstab.mods_scroll_list.items > 0 then
            return self.modstab.mods_scroll_list
        else
            return self
        end
    end
end

function ModFilterBar:RefreshFilterState()
    self.no_refresh_modstab = true --we don't want to refresh the modstab multiple times when setting the filter states and sort type. We're do one manual refresh once we're done updating
    for i,filter in ipairs(self.filter_btns) do
        local state = Profile:GetCustomizationFilterState(self.filter_category, filter.btnid)
        filter.widget:SetFilterState(state)
    end
    self.no_refresh_modstab = nil

    self.modstab:RefreshModFilter(self:_ConstructFilter())
end

function ModFilterBar:AddModTypeFilter(text_fmt, workshop_tex, local_tex, all_tex, id, workshopfilterfn, localfilterfn)
    local btn = TEMPLATES.IconButton("images/button_icons2.xml", all_tex)
    btn:SetScale(0.9)
    btn.SetFilterState = function(_, state)
        if state == "workshop" then
            btn:SetHoverText( subfmt(text_fmt, { mode = not IsRail() and STRINGS.UI.MODSSCREEN.WORKSHOP_FILTER or STRINGS.UI.MODSSCREEN.WORKSHOP_FILTER_RAIL }) )
            btn.icon:SetTexture("images/button_icons2.xml", workshop_tex )
            self.filters[id] = workshopfilterfn
        elseif state == "local" then
            btn:SetHoverText( subfmt(text_fmt, { mode = STRINGS.UI.MODSSCREEN.LOCAL_FILTER }) )
            btn.icon:SetTexture("images/button_icons2.xml", local_tex )
            self.filters[id] = localfilterfn
        else
            btn:SetHoverText( subfmt(text_fmt, { mode = STRINGS.UI.MODSSCREEN.ALL_FILTER }) )
            btn.icon:SetTexture("images/button_icons2.xml", all_tex )
            self.filters[id] = nil
        end
        if not self.no_refresh_modstab then
            self.modstab:RefreshModFilter(self:_ConstructFilter())
        end
    end

    local function onclick()
        local new_state = (self.filters[id] == workshopfilterfn and "local") or (self.filters[id] == localfilterfn and "all") or "workshop"
        btn:SetFilterState(new_state)
        Profile:SetCustomizationFilterState(self.filter_category, id, new_state)
    end
    btn:SetOnClick(onclick)

    table.insert(self.filter_btns, {btnid=id, widget=btn})

    self:_UpdatePositions()

    return btn
end

function ModFilterBar:AddModStatusFilter(text_fmt, enabled_tex, disabled_tex, both_tex, id, enabledfilterfn, disabledfilterfn)
    local btn = TEMPLATES.IconButton("images/button_icons2.xml", both_tex)
    btn:SetScale(0.9)
    btn.SetFilterState = function(_, state)
        if state == "enabled" then
            btn:SetHoverText( subfmt(text_fmt, { mode = STRINGS.UI.MODSSCREEN.ENABLED_FILTER }) )
            btn.icon:SetTexture("images/button_icons2.xml", enabled_tex )
            self.filters[id] = enabledfilterfn
        elseif state == "disabled" then
            btn:SetHoverText( subfmt(text_fmt, { mode = STRINGS.UI.MODSSCREEN.DISABLED_FILTER }) )
            btn.icon:SetTexture("images/button_icons2.xml", disabled_tex )
            self.filters[id] = disabledfilterfn
        else
            btn:SetHoverText( subfmt(text_fmt, { mode = STRINGS.UI.MODSSCREEN.ENABLEDDISABLED_FILTER }) )
            btn.icon:SetTexture("images/button_icons2.xml", both_tex )
            self.filters[id] = nil
        end
        if not self.no_refresh_modstab then
            self.modstab:RefreshModFilter(self:_ConstructFilter())
        end
    end

    local function onclick()
        local new_state = (self.filters[id] == enabledfilterfn and "disabled") or (self.filters[id] == disabledfilterfn and "both") or "enabled"
        btn:SetFilterState(new_state)
        Profile:SetCustomizationFilterState(self.filter_category, id, new_state)
    end
    btn:SetOnClick(onclick)

    table.insert(self.filter_btns, {btnid=id, widget=btn})

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

function ModFilterBar:AddSearch()
    local searchbox = Widget("search")
    local box_size = 240
    local box_height = 40
    searchbox.textbox_root = searchbox:AddChild(TEMPLATES.StandardSingleLineTextEntry(nil, box_size, box_height))
    searchbox.textbox = searchbox.textbox_root.textbox
    searchbox.textbox:SetTextLengthLimit(50)
    searchbox.textbox:SetForceEdit(true)
    searchbox.textbox:EnableWordWrap(false)
    searchbox.textbox:EnableScrollEditWindow(true)
    searchbox.textbox:SetHelpTextEdit("")
    searchbox.textbox:SetHelpTextApply(STRINGS.UI.MODSSCREEN.SEARCH)
    searchbox.textbox:SetTextPrompt(STRINGS.UI.MODSSCREEN.SEARCH, UICOLOURS.GREY)
    searchbox.textbox.prompt:SetHAlign(ANCHOR_MIDDLE)
    searchbox.textbox.OnTextInputted = function()
        if not self.no_refresh_modstab then
            self.modstab:RefreshModFilter(self:_ConstructFilter())
        end
    end

    self.filters["SEARCH"] = function(modname)
        local fancyname = KnownModIndex:GetModFancyName(modname)

        local search_str = TrimString(string.upper(searchbox.textbox:GetString()))
        if search_str == "" then
            --Early out
            return true
        end

        if search_match(search_str, string.upper(modname)) or search_match(search_str, string.upper(fancyname)) then
            return true
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

function ModFilterBar:HideFilter(id)
    for _,v in ipairs(self.filter_btns) do
        if v.btnid==id then
            if v.widget:IsVisible() then
                v.widget:Hide()
                self:_UpdatePositions()
            end
            return
        end
    end
end

function ModFilterBar:ShowFilter(id)
    for _,v in ipairs(self.filter_btns) do
        if v.btnid==id then
            if not v.widget:IsVisible() then
                v.widget:Show()
                self:_UpdatePositions()
            end
            return
        end
    end
end

function ModFilterBar:_UpdatePositions()
    local width,_ = self.modstab.mods_scroll_list:GetScrollRegionSize()

    local squeeze = 0

    local x_offset = 10

    local first_btn = nil
    local prev_btn = nil
    local num_btns = 0
    for a,v in ipairs(self.filter_btns) do
    	--we don't care about the parent's visibility for this.
        if v.widget.shown then
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

    if self.search_box then
        local search_width = 130
        if num_btns == 2 then
            search_width = 90
            self.search_box.textbox_root.textbox_bg:ScaleToSize(175, 40)
            self.search_box.textbox:SetRegionSize(175-30, 40)
        elseif num_btns == 1 then
            self.search_box.textbox_root.textbox_bg:ScaleToSize(240, 40)
            self.search_box.textbox:SetRegionSize(240-30, 40)
        elseif num_btns == 0 then
            search_width = 165
            self.search_box.textbox_root.textbox_bg:ScaleToSize(315, 40)
            self.search_box.textbox:SetRegionSize(315-30, 40)
        end
        local size_x = prev_btn and prev_btn.size_x or 0
        self.search_box:SetPosition( x_offset + -width/2 + num_btns*size_x + search_width, 4)

        if prev_btn then
            prev_btn:SetFocusChangeDir(MOVE_RIGHT, self.search_box)
            self.search_box:SetFocusChangeDir(MOVE_LEFT, prev_btn)
        end
    end

    self.focus_forward = first_btn or self.search_box
end

function ModFilterBar:_ConstructFilter()
    local function isfiltervisible(id)
        for _,v in ipairs(self.filter_btns) do
            if v.btnid==id then
                return v.widget:IsVisible()
            end
        end
        return true
    end
    local filter = function(item_key)
        for id, fn in pairs(self.filters) do
            if isfiltervisible(id) and not fn(item_key) then
                return false
            end
        end

        return true
    end

    return filter
end

return ModFilterBar
