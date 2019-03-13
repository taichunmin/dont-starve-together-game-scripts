local Image = require "widgets/image"
local ItemExplorer = require "widgets/redux/itemexplorer"
local FilterBar = require "widgets/redux/filterbar"
local Widget = require "widgets/widget"

require("misc_items")
require("skinsutils")
require("util")

local ITEM_TYPE = "loading"
local WIDGET_HEIGHT = 90
local WIDGET_WIDTH = WIDGET_HEIGHT

local DEFAULT_PREVIEW_ATLAS = "images/bg_spiral.xml"
local DEFAULT_PREVIEW_TEX = "bg_spiral.tex"
local PREVIEW_HEIGHT = 320
local PREVIEW_WIDTH = PREVIEW_HEIGHT * 16/9


local LoadersExplorerPanel = Class(Widget, function(self, owner, user_profile)
    Widget._ctor(self, "LoadersExplorerPanel")
    self.owner = owner
    self.user_profile = user_profile

    self.preview_root = self:AddChild(Widget("preview_root"))
    self.preview_root:SetPosition(-10, 140)

    -- Default: fallback to spiral if there's no last selection.
    self.preview = self.preview_root:AddChild(Image(DEFAULT_PREVIEW_ATLAS, DEFAULT_PREVIEW_TEX))
    self.preview:SetSize(PREVIEW_WIDTH, PREVIEW_HEIGHT)

    self.picker = self:AddChild(self:_BuildItemExplorer())
    self.picker:SetPosition(445, 5)

    self.picker:RepositionFooter(self.preview_root, -PREVIEW_HEIGHT/2 - 30, PREVIEW_WIDTH)

    self.filter_bar = self:AddChild(FilterBar(self.picker, "collectionscreen"))
    self.picker.header:AddChild( self.filter_bar:AddFilter(STRINGS.UI.WARDROBESCREEN.OWNED_FILTER_FMT, "owned_filter_on.tex", "owned_filter_off.tex", "lockedFilter", GetLockedSkinFilter()) )
    self.picker.header:AddChild( self.filter_bar:AddFilter(STRINGS.UI.WARDROBESCREEN.WEAVEABLE_FILTER_FMT, "weave_filter_on.tex", "weave_filter_off.tex", "weaveableFilter", GetWeaveableSkinFilter()) )
    self.picker.header:AddChild( self.filter_bar:AddSorter() )

    self:_DoFocusHookups()
    self.focus_forward = self.filter_bar:BuildFocusFinder()
end)

function LoadersExplorerPanel:_DoFocusHookups()
    self.picker.header.focus_forward = self.filter_bar
end

function LoadersExplorerPanel:_GetCurrentLoaders()
    return table.getkeys(self.picker:GetSelectedItems())
end

function LoadersExplorerPanel:OnClickedItem(item_data, is_selected)
    self.preview:SetTexture(GetLoaderAtlasAndTex(item_data.item_key))
    self.preview:SetSize(PREVIEW_WIDTH, PREVIEW_HEIGHT)
end

function LoadersExplorerPanel:OnShow()
    LoadersExplorerPanel._base.OnShow(self)
    self.filter_bar:RefreshFilterState()
end

function LoadersExplorerPanel:_BuildItemExplorer()
    local title_text = STRINGS.UI.COLLECTIONSCREEN.LOADERS
    local list_options = {
        scroll_context = {
            owner = self.owner,
            input_receivers = { self },
            user_profile = self.user_profile,
            selection_type = "multi",
        },
        widget_width = WIDGET_WIDTH,
        widget_height = WIDGET_HEIGHT,
        num_visible_rows = 6,
        num_columns = 3,
        scrollbar_offset = 20,
    }
    return ItemExplorer(title_text, ITEM_TYPE, MISC_ITEMS, list_options)
end

return LoadersExplorerPanel
