local ItemExplorer = require "widgets/redux/itemexplorer"
local FilterBar = require "widgets/redux/filterbar"
local PlayerAvatarPortrait = require "widgets/redux/playeravatarportrait"
local Widget = require "widgets/widget"

local TEMPLATES = require "widgets/redux/templates"

require("dlcsupport")
require("misc_items")
require("util")

local ITEM_TYPE = "playerportrait"
local WIDGET_WIDTH = 90
local WIDGET_HEIGHT = 90


local PortraitBackgroundExplorerPanel = Class(Widget, function(self, owner, user_profile)
    Widget._ctor(self, "PortraitBackgroundExplorerPanel")
    self.owner = owner
    self.user_profile = user_profile

    self.puppet_root = self:AddChild(Widget("puppet_root"))
    self.puppet_root:SetPosition(-160, -210)

    self.puppet = self.puppet_root:AddChild(PlayerAvatarPortrait())
    self.puppet:HideHoverText()
    self.puppet:SetScale(1.8)
    -- Positioning the puppet relative to the spinner to make it easy for
    -- spinners on different screens to line up.
    self.puppet:SetPosition(0, 250)

    self.heroselector = self.puppet_root:AddChild(TEMPLATES.CharacterSpinner(
            function(selected, old) self:OnChangedCharacter(selected) end,
            self.puppet,
            self.user_profile
        ))

    self.picker = self:AddChild(self:_BuildItemExplorer())
    self.picker:SetPosition(310, 140)

    self.filter_bar = self:AddChild(FilterBar(self.picker, "collectionscreen"))
    self.picker.header:AddChild( self.filter_bar:AddFilter(STRINGS.UI.WARDROBESCREEN.OWNED_FILTER_FMT, "owned_filter_on.tex", "owned_filter_off.tex", "lockedFilter", GetLockedSkinFilter()) )
    self.picker.header:AddChild( self.filter_bar:AddFilter(STRINGS.UI.WARDROBESCREEN.WEAVEABLE_FILTER_FMT, "weave_filter_on.tex", "weave_filter_off.tex", "weaveableFilter", GetWeaveableSkinFilter()) )
    self.picker.header:AddChild( self.filter_bar:AddSorter() )
    self.picker.header:AddChild( self.filter_bar:AddSearch() )

    self:_DoFocusHookups()
    self.focus_forward = self.heroselector

    self:StartUpdating()
end)

function PortraitBackgroundExplorerPanel:_DoFocusHookups()
    self.heroselector:SetFocusChangeDir(MOVE_RIGHT, self.filter_bar:BuildFocusFinder())
    self.picker:SetFocusChangeDir(MOVE_LEFT, self.heroselector)
    self.picker.header.focus_forward = self.filter_bar
end

function PortraitBackgroundExplorerPanel:_GetCurrentCharacter()
    return self.heroselector:GetSelectedData().name
end

function PortraitBackgroundExplorerPanel:_GetCurrentBackground()
    local bg,_ = next(self.picker:GetSelectedItems())
    return bg
end

function PortraitBackgroundExplorerPanel:OnChangedCharacter(selected)
    self:_RefreshPreview()
end

function PortraitBackgroundExplorerPanel:OnShow()
    PortraitBackgroundExplorerPanel._base.OnShow(self)
    self.heroselector:LoadLastSelectedFromProfile()
    self.filter_bar:RefreshFilterState()
    self:_RefreshPreview()
end

function PortraitBackgroundExplorerPanel:_RefreshPreview()
    self:_SetRank()
    if self.picker then -- called during init when setting up puppet
        -- Apply the new background in case the character change modified it.
        self.puppet:SetBackground(self:_GetCurrentBackground())
    end
end

function PortraitBackgroundExplorerPanel:OnClickedItem(item_data, is_selected)
    if is_selected or not item_data.is_owned then
        --selecting the item or previewing an item
        self.puppet:SetBackground(item_data.item_key)
    else
        --deselecting an item
        self.puppet:ClearBackground()
    end
end

function PortraitBackgroundExplorerPanel:_SetRank()
    self.puppet:SetRank(GetMostRecentlySelectedItem(self.user_profile, "profileflair"), wxputils.GetActiveLevel())
end

function PortraitBackgroundExplorerPanel:_BuildItemExplorer()
    local title_text = STRINGS.UI.COLLECTIONSCREEN.PORTRAITBACKGROUNDS
    local list_options = {
        scroll_context = {
            --~ screen = self,
            owner = self.owner,
            input_receivers = { self },
            user_profile = self.user_profile,
            selection_type = "single",
            selection_allow_nil = true,
        },
        widget_width = WIDGET_WIDTH,
        widget_height = WIDGET_HEIGHT,
        num_visible_rows = 3,
        num_columns = 5,
        scrollbar_offset = 20,
    }
    return ItemExplorer(title_text, ITEM_TYPE, MISC_ITEMS, list_options)
end

function PortraitBackgroundExplorerPanel:OnUpdate(dt)
    self.puppet:EmoteUpdate(dt)
end

return PortraitBackgroundExplorerPanel
