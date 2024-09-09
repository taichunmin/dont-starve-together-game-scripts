local ItemExplorer = require "widgets/redux/itemexplorer"
local FilterBar = require "widgets/redux/filterbar"
local Widget = require "widgets/widget"

require("clothing")
require("util")

local WIDGET_WIDTH = 90
local WIDGET_HEIGHT = 90


local ClothingExplorerPanel = Class(Widget, function(self, owner, user_profile, item_type, activity_checker_fn, activity_writer_fn, filter_options)
    Widget._ctor(self, "ClothingExplorerPanel")
    self.owner = owner
    self.user_profile = user_profile
    self.item_type = item_type
    self.activity_checker_fn = activity_checker_fn
    self.activity_writer_fn = activity_writer_fn

    self.yotb_filter = filter_options and filter_options.yotb_filter or nil

    self.picker = self:AddChild(self:_BuildItemExplorer())
    self.picker:SetPosition(310, 130)

    self.filter_bar = self:AddChild(FilterBar(self.picker, "wardrobescreen"))
    local hero_filter = GetAffinityFilterForHero(self.owner.currentcharacter)
    if filter_options ~= nil and filter_options.ignore_hero then
        hero_filter = GetNullFilter()
    end

    if not filter_options or not filter_options.ignore_survivor then
        self.picker.header:AddChild( self.filter_bar:AddFilter(STRINGS.UI.WARDROBESCREEN.SURVIVOR_FILTER_FMT, "survivor_filter_on.tex", "survivor_filter_off.tex", "heroFilter", hero_filter) )
    end
    self.picker.header:AddChild( self.filter_bar:AddFilter(STRINGS.UI.WARDROBESCREEN.OWNED_FILTER_FMT, "owned_filter_on.tex", "owned_filter_off.tex", "lockedFilter", GetLockedSkinFilter()) )
    self.picker.header:AddChild( self.filter_bar:AddFilter(STRINGS.UI.WARDROBESCREEN.WEAVEABLE_FILTER_FMT, "weave_filter_on.tex", "weave_filter_off.tex", "weaveableFilter", GetWeaveableSkinFilter()) )
    self.picker.header:AddChild( self.filter_bar:AddSorter() )
    if self.item_type == "base" or (filter_options ~= nil and filter_options.ignore_hero) or self.yotb_filter  then
        self.filter_bar:HideFilter("heroFilter")
        self.picker.header:AddChild( self.filter_bar:AddSearch( ) )
    else
        self.picker.header:AddChild( self.filter_bar:AddSearch( true ) )
    end

    self:_DoFocusHookups()
    self.focus_forward = self.filter_bar:BuildFocusFinder()
end)

function ClothingExplorerPanel:_DoFocusHookups()
    self.picker.header.focus_forward = self.filter_bar
end

function ClothingExplorerPanel:_GetCurrentClothing()
    local current,_ = next(self.picker:GetSelectedItems())
    return current
end

function ClothingExplorerPanel:OnClickedItem(item_data, is_selected)
    -- Handle writing from OnClickedItem to ensure we can differentiate deselected items and items that were unselected due to another item being selected.
    self.activity_writer_fn(item_data)
end

function ClothingExplorerPanel:OnShow()
    ClothingExplorerPanel._base.OnShow(self)
    self.filter_bar:RefreshFilterState()
end

function ClothingExplorerPanel:_BuildItemExplorer()
    local list_options = {
        scroll_context = {
            owner = self.owner,
            input_receivers = { self },
            user_profile = self.user_profile,
            selection_type = "single",
        },
        widget_width = WIDGET_WIDTH,
        widget_height = WIDGET_HEIGHT,
        num_visible_rows = 3,
        num_columns = 5,
        scrollbar_offset = 20,
        activity_checker_fn = self.activity_checker_fn,
        activity_writer_fn = function() end, -- ignore writes and use OnClickedItem instead
    }

    local item_table = CLOTHING
    if self.owner.currentcharacter == "beefalo" then
        item_table = BEEFALO_CLOTHING
    end
    if self.item_type == "base" then
        item_table = GetCharacterSkinBases(self.owner.currentcharacter)
    end

    return ItemExplorer("", self.item_type, item_table, list_options, self.yotb_filter)
end


function ClothingExplorerPanel:ClearSelection()
    self.picker:ClearSelection()
end

function ClothingExplorerPanel:RefreshInventory()
    -- Ensure we apply the current filter state to new data. We could use picker:RefreshItems() but we'd lose our current filter state and the button might not match the current state.
    self.filter_bar:RefreshFilterState()
end

return ClothingExplorerPanel
