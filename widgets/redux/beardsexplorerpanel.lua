local ItemExplorer = require "widgets/redux/itemexplorer"
local FilterBar = require "widgets/redux/filterbar"
local Puppet = require "widgets/skinspuppet"
local Widget = require "widgets/widget"

local TEMPLATES = require "widgets/redux/templates"

require("dlcsupport")
require("emote_items")
require("util")

local ITEM_TYPE = "beard"
local WIDGET_WIDTH = 90
local WIDGET_HEIGHT = 90

local BeardsExplorerPanel = Class(Widget, function(self, owner, user_profile)
    Widget._ctor(self, "BeardsExplorerPanel")
    self.owner = owner
    self.user_profile = user_profile

    self.character = "wilson"

    self.puppet_root = self:AddChild(Widget("puppet_root"))
    self.puppet_root:SetPosition(-160, -210)

    self.puppet = self.puppet_root:AddChild(Puppet())
    self.puppet:SetPosition(0, 50)
    self.puppet:SetScale(4)
    self.puppet:SetClickable(false)

    local len_data = {
        {
            text = STRINGS.UI.BEARDSCREEN.BEARD_NAMES[1],
            colour = nil,
            image = nil,
            data = { len = 1 },
        },
        {
            text = STRINGS.UI.BEARDSCREEN.BEARD_NAMES[2],
            colour = nil,
            image = nil,
            data = { len = 2 },
        },
        {
            text = STRINGS.UI.BEARDSCREEN.BEARD_NAMES[3],
            colour = nil,
            image = nil,
            data = { len = 3 },
        }
    }
    self.beard_len_selector = self.puppet_root:AddChild(TEMPLATES.StandardSpinner(len_data, 250))
    self.beard_len_selector:SetOnChangedFn(function(selected, old)
        self.puppet:SetBeardLength(selected.len)
    end)
    self.puppet:SetBeardLength(1)

    self.picker = self:AddChild(self:_BuildItemExplorer())
    self.picker:SetPosition(310, 140)

    self.filter_bar = self:AddChild(FilterBar(self.picker, "collectionscreen"))
    self.picker.header:AddChild( self.filter_bar:AddFilter(STRINGS.UI.WARDROBESCREEN.OWNED_FILTER_FMT, "owned_filter_on.tex", "owned_filter_off.tex", "lockedFilter", GetLockedSkinFilter()) )
    self.picker.header:AddChild( self.filter_bar:AddFilter(STRINGS.UI.WARDROBESCREEN.WEAVEABLE_FILTER_FMT, "weave_filter_on.tex", "weave_filter_off.tex", "weaveableFilter", GetWeaveableSkinFilter()) )
    self.picker.header:AddChild( self.filter_bar:AddSorter() )
    self.picker.header:AddChild( self.filter_bar:AddSearch() )

    self:_DoFocusHookups()
    self.focus_forward = self.beard_len_selector

    self:StartUpdating()
end)

function BeardsExplorerPanel:_DoFocusHookups()
    self.beard_len_selector:SetFocusChangeDir(MOVE_RIGHT, self.filter_bar:BuildFocusFinder())
    self.picker:SetFocusChangeDir(MOVE_LEFT, self.beard_len_selector)
    self.picker.header.focus_forward = self.filter_bar
end

function BeardsExplorerPanel:OnShow()
    BeardsExplorerPanel._base.OnShow(self)
    self.filter_bar:RefreshFilterState()
end

function BeardsExplorerPanel:OnClickedItem(item_data, is_selected)
    if item_data.item_key ~= "beard_default1" then
        self.character = item_data.item_key:sub(1,string.find(item_data.item_key, "_")-1)
    end

    local clothing = self.user_profile:GetSkinsForCharacter(self.character)
    self.puppet:SetSkins(self.character, clothing.base, clothing, true, "normalSkin")
    self.puppet:SetBeard(item_data.item_key)
end


function BeardsExplorerPanel:_BuildItemExplorer()
    local title_text = STRINGS.UI.COLLECTIONSCREEN.BEARD
    local list_options = {
        scroll_context = {
            owner = self.owner,
            input_receivers = { self },
            user_profile = self.user_profile,
        },
        widget_width = WIDGET_WIDTH,
        widget_height = WIDGET_HEIGHT,
        num_visible_rows = 3,
        num_columns = 5,
        scrollbar_offset = 20,
    }
    return ItemExplorer(title_text, ITEM_TYPE, MISC_ITEMS, list_options)
end

function BeardsExplorerPanel:OnUpdate(dt)
    self.puppet:EmoteUpdate(dt)
end

return BeardsExplorerPanel
