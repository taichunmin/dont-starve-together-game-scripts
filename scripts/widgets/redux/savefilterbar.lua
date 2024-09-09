-- Display a filter bar for the item explorer
--We should probably replace this with Menu.
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"

local SERVER_NAME_MAX_LENGTH = 80

local SaveFilterBar = Class(Widget, function(self, serverslotscreen)
    Widget._ctor(self, "SaveFilterBar")

    self.serverslotscreen = serverslotscreen

    self.filters = {}
end)

-- Instead of giving focus to serverslotscreen or SaveFilterBar, give it to this function.
function SaveFilterBar:BuildFocusFinder()
    return function()
        -- If we have no items to display, then we can't push focus to the
        -- serverslotscreen since it will contain nothing to focus.
        if self.serverslotscreen.server_scroll_list and #self.serverslotscreen.server_scroll_list.items > 0 then
            return self.serverslotscreen.server_scroll_list
        else
            return self
        end
    end
end

function SaveFilterBar:RefreshFilterState()
    self.no_refresh_saves = true --we don't want to refresh the saves list multiple times when setting the filter states and sort type. We're do one manual refresh once we're done updating
    if self.sort_btn then
        local sort_mode = Profile:GetServerSortMode() or "SORT_LASTPLAYED"
        self.sort_btn:SetSortType(sort_mode)
    end
    self.no_refresh_saves = nil

    self.serverslotscreen:RefreshSaveFilter(self:_ConstructFilter())
end

function SaveFilterBar:AddSorter()
    local modes = {
        SORT_LASTPLAYED = "sort_lastplayed.tex",
        SORT_MOSTDAYS = "sort_mostdays.tex",
        SORT_DATECREATED = "sort_datecreated.tex"
    }

    local btn = TEMPLATES.IconButton("images/button_icons2.xml", modes["SORT_LASTPLAYED"])
    btn:SetScale(0.9)
    btn.SetSortType = function(_,sort_mode)

        btn:SetHoverText( subfmt(STRINGS.UI.SERVERCREATIONSCREEN.SORT_MODE_FMT, { mode = STRINGS.UI.SERVERCREATIONSCREEN[sort_mode] }) )
        btn.icon:SetTexture("images/button_icons2.xml", modes[sort_mode] )

        if not self.no_refresh_saves then
            self.serverslotscreen:RefreshSaveFilter(self:_ConstructFilter())
        end
    end
    local function onclick()
        local sort_mode = Profile:GetServerSortMode() or "SORT_LASTPLAYED"

        sort_mode = next(modes, sort_mode)
        if sort_mode == nil then
            sort_mode = "SORT_LASTPLAYED"
        end

        Profile:SetServerSortMode(sort_mode)
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

function SaveFilterBar:AddSearch()
    local searchbox = Widget("search")
    local box_size = 315
    local box_height = 40
    searchbox.textbox_root = searchbox:AddChild(TEMPLATES.StandardSingleLineTextEntry(nil, box_size, box_height))
    searchbox.textbox = searchbox.textbox_root.textbox
    searchbox.textbox:SetTextLengthLimit(SERVER_NAME_MAX_LENGTH)
    searchbox.textbox:SetForceEdit(true)
    searchbox.textbox:EnableWordWrap(false)
    searchbox.textbox:EnableScrollEditWindow(true)
    searchbox.textbox:SetHelpTextEdit("")
    searchbox.textbox:SetHelpTextApply(STRINGS.UI.SERVERCREATIONSCREEN.SEARCH)
    searchbox.textbox:SetTextPrompt(STRINGS.UI.SERVERCREATIONSCREEN.SEARCH, UICOLOURS.GREY)
    searchbox.textbox.prompt:SetHAlign(ANCHOR_MIDDLE)
    searchbox.textbox.OnTextInputted = function()
        self.serverslotscreen:RefreshSaveFilter(self:_ConstructFilter())
    end


    self.filters["SEARCH"] = function(slot, character)
        local search_str = TrimString(string.upper(searchbox.textbox:GetString()))
        if search_str == "" then
            --Early out
            return true
        end

        local serverdata = ShardSaveGameIndex:GetSlotServerData(slot)
        character = STRINGS.CHARACTER_NAMES[character] or character

        if search_match( search_str, string.upper(serverdata.name) ) or
            search_match( search_str, string.upper(character) ) or
            search_match( search_str, string.upper(serverdata.description) ) then
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

function SaveFilterBar:_UpdatePositions()
    local gap = 10
    if TheInput:ControllerAttached() or IsConsole() then
        gap = 30
    end

    --Sort button now
    if self.sort_btn then
        self.sort_btn:SetPosition(-(860/2) + self.sort_btn.size_x/2 + gap, 3)
    end

    if self.search_box then
        self.search_box:SetPosition(0, 4)

        if self.sort_btn then
            self.sort_btn:SetFocusChangeDir(MOVE_RIGHT, self.search_box)
            self.search_box:SetFocusChangeDir(MOVE_LEFT, self.sort_btn)
        end
    end

    self.focus_forward = self.search_box or self.sort_btn
end

function SaveFilterBar:_ConstructFilter()
    local filter = function(...)
        for i,fn in pairs(self.filters) do
            if not fn(...) then
                return false
            end
        end

        return true
    end

    return filter
end

return SaveFilterBar
