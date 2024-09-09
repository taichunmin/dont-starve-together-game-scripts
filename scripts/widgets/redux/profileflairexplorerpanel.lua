-- Yup, this is almost the same as PortraitBackgroundExplorerPanel.
local ItemExplorer = require "widgets/redux/itemexplorer"
local FilterBar = require "widgets/redux/filterbar"
local PlayerAvatarPortrait = require "widgets/redux/playeravatarportrait"
local Widget = require "widgets/widget"

local TEMPLATES = require "widgets/redux/templates"

require("dlcsupport")
require("misc_items")
require("util")

local ITEM_TYPE = "profileflair"
local WIDGET_WIDTH = 90
local WIDGET_HEIGHT = 90


local ProfileFlairExplorerPanel = Class(Widget, function(self, owner, user_profile)
    Widget._ctor(self, "ProfileFlairExplorerPanel")
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

function ProfileFlairExplorerPanel:_DoFocusHookups()
    self.heroselector:SetFocusChangeDir(MOVE_RIGHT, self.filter_bar:BuildFocusFinder())
    self.picker:SetFocusChangeDir(MOVE_LEFT, self.heroselector)
    self.picker.header.focus_forward = self.filter_bar
end

function ProfileFlairExplorerPanel:_GetCurrentCharacter()
    return self.heroselector:GetSelectedData().name
end

function ProfileFlairExplorerPanel:_GetCurrentBackground()
    local bg,_ = next(self.picker:GetSelectedItems())
    return bg
end

function ProfileFlairExplorerPanel:OnChangedCharacter(selected)
    self:_RefreshPreview()
end

function ProfileFlairExplorerPanel:OnShow()
    ProfileFlairExplorerPanel._base.OnShow(self)
    self.heroselector:LoadLastSelectedFromProfile()
    self.filter_bar:RefreshFilterState()
    self:_RefreshPreview()
end

function ProfileFlairExplorerPanel:_RefreshPreview()
    self.puppet:SetBackground(GetMostRecentlySelectedItem(self.user_profile, "playerportrait"))
    if self.picker then -- called during init when setting up puppet
        -- Apply the new background in case the character change modified it.
        self:_SetProfileFlair(self:_GetCurrentBackground())
    end
end

function ProfileFlairExplorerPanel:OnClickedItem(item_data, is_selected)
    if is_selected or not item_data.is_owned then
        --selecting the item or previewing an item
        self:_SetProfileFlair(item_data.item_key)
    else
        --deselecting an item
        self:_SetProfileFlair(nil)
    end

end

function ProfileFlairExplorerPanel:_SetProfileFlair(item_key)
    self.puppet:SetRank(item_key, wxputils.GetActiveLevel())
end

function ProfileFlairExplorerPanel:_BuildItemExplorer()
    local title_text = STRINGS.UI.COLLECTIONSCREEN.PROFILEFLAIR
    local list_options = {
        scroll_context = {
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

function ProfileFlairExplorerPanel:OnUpdate(dt)
    self.puppet:EmoteUpdate(dt)
end

return ProfileFlairExplorerPanel
