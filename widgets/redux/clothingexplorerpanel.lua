local ItemExplorer = require "widgets/redux/itemexplorer"
local FilterBar = require "widgets/redux/filterbar"
local Widget = require "widgets/widget"

require("clothing")
require("util")

local WIDGET_WIDTH = 90
local WIDGET_HEIGHT = 90


local ClothingExplorerPanel = Class(Widget, function(self, owner, user_profile, item_type, activity_checker_fn, activity_writer_fn)
    Widget._ctor(self, "ClothingExplorerPanel")
    self.owner = owner
    self.user_profile = user_profile
    self.item_type = item_type
    self.activity_checker_fn = activity_checker_fn
    self.activity_writer_fn = activity_writer_fn

    self.picker = self:AddChild(self:_BuildItemExplorer())
    self.picker:SetPosition(310, 130)

    self.filter_bar = self:AddChild(FilterBar(self.picker, "wardrobescreen"))
    self.filter_btn = self.picker.header:AddChild( self.filter_bar:AddFilter(STRINGS.UI.WARDROBESCREEN.SHOW_HERO_CLOTHING, STRINGS.UI.WARDROBESCREEN.SHOW_ALL_CLOTHING, "heroFilter", GetAffinityFilterForHero(self.owner.currentcharacter)) )
    self.picker.header:AddChild( self.filter_bar:AddFilter(STRINGS.UI.WARDROBESCREEN.SHOW_UNOWNED_CLOTHING, STRINGS.UI.WARDROBESCREEN.SHOW_UNOWNEDANDOWNED_CLOTHING, "lockedFilter", GetLockedSkinFilter()) )
    if self.item_type == "base" then
        self.filter_bar:HideFilter("heroFilter")
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
    -- Handle writing from OnClickedItem to ensure we can differentiate
    -- deselected items and items that were unselected due to another item
    -- being selected.
    self.activity_writer_fn(item_data)
end

function ClothingExplorerPanel:OnShow()
    ClothingExplorerPanel._base.OnShow(self)
    self.filter_bar:RefreshFilterState()
end

function ClothingExplorerPanel:_BuildItemExplorer()
    local title_text = "" -- filter_btn instead of text
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
    if self.item_type == "base" then
        item_table = GetCharacterSkinBases(self.owner.currentcharacter)
    end
    return ItemExplorer(title_text, self.item_type, item_table, list_options)
end

function ClothingExplorerPanel:RefreshInventory()
    -- Ensure we apply the current filter state to new data. We could use
    -- picker:RefreshItems() but we'd lose our current filter state and the
    -- button might not match the current state.
    self.filter_bar:RefreshFilterState()
end

return ClothingExplorerPanel
