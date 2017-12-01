local ItemExplorer = require "widgets/redux/itemexplorer"
local FilterBar = require "widgets/redux/filterbar"
local Widget = require "widgets/widget"

require("dlcsupport")
require("emoji_items")
require("util")

local ITEM_TYPE = "emoji"

local WIDGET_WIDTH = 90
local WIDGET_HEIGHT = 90

local EmojiExplorerPanel = Class(Widget, function(self, owner, user_profile)
    Widget._ctor(self, "EmojiExplorerPanel")
    self.owner = owner
    self.user_profile = user_profile

    self.picker = self:AddChild(self:_BuildItemExplorer())
    self.picker:SetPosition(130, 140)

    self.filterBar = FilterBar(self.picker)
    self.picker.header:AddChild( self.filterBar:AddFilter(STRINGS.UI.WARDROBESCREEN.SHOW_UNOWNED_CLOTHING, STRINGS.UI.WARDROBESCREEN.SHOW_UNOWNEDANDOWNED_CLOTHING, "lockedFilter", GetLockedSkinFilter()) )

    self:_DoFocusHookups()
    self.focus_forward = self.picker
end)

function EmojiExplorerPanel:_DoFocusHookups()
    self.picker.header.focus_forward = self.filterBar
end

function EmojiExplorerPanel:_GetCurrentCharacter()
    return self.heroselector:GetSelectedData()
end

function EmojiExplorerPanel:_GetCurrentEmoji()
    return table.getkeys(self.picker:GetSelectedItems())
end

function EmojiExplorerPanel:OnChangedCharacter(selected)
end

function EmojiExplorerPanel:OnClickedItem(item_data, is_selected)
end

function EmojiExplorerPanel:OnShow()
    EmojiExplorerPanel._base.OnShow(self)
    self.picker:RefreshItems()
end

function EmojiExplorerPanel:_BuildItemExplorer()
    local title_text = STRINGS.UI.COLLECTIONSCREEN.EMOJI
    local list_options = {
        scroll_context = {
            owner = self.owner,
            input_receivers = { self },
            user_profile = self.user_profile,
        },
        widget_width = WIDGET_WIDTH,
        widget_height = WIDGET_HEIGHT,
        num_visible_rows = 3,
        num_columns = 9,
        scrollbar_offset = 20,
    }
    return ItemExplorer(title_text, ITEM_TYPE, EMOJI_ITEMS, list_options)
end

return EmojiExplorerPanel
