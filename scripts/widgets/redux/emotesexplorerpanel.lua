local ItemExplorer = require "widgets/redux/itemexplorer"
local FilterBar = require "widgets/redux/filterbar"
local Puppet = require "widgets/skinspuppet"
local Widget = require "widgets/widget"

local TEMPLATES = require "widgets/redux/templates"

require("dlcsupport")
require("emote_items")
require("util")

local ITEM_TYPE = "emote"
local WIDGET_WIDTH = 90
local WIDGET_HEIGHT = 90

local EmotesExplorerPanel = Class(Widget, function(self, owner, user_profile)
    Widget._ctor(self, "EmotesExplorerPanel")
    self.owner = owner
    self.user_profile = user_profile


    self.puppet_root = self:AddChild(Widget("puppet_root"))
    self.puppet_root:SetPosition(-160, -210)

    self.puppet = self.puppet_root:AddChild(Puppet())
    self.puppet:SetPosition(0, 50)
    self.puppet:SetScale(4)
    self.puppet:SetClickable(false)
    self.puppet.enable_idle_emotes = false

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

function EmotesExplorerPanel:_DoFocusHookups()
    self.heroselector:SetFocusChangeDir(MOVE_RIGHT, self.filter_bar:BuildFocusFinder())
    self.picker:SetFocusChangeDir(MOVE_LEFT, self.heroselector)
    self.picker.header.focus_forward = self.filter_bar
end

function EmotesExplorerPanel:_GetCurrentCharacter()
    return self.heroselector:GetSelectedData()
end

function EmotesExplorerPanel:_GetCurrentEmotes()
    return table.getkeys(self.picker:GetSelectedItems())
end

function EmotesExplorerPanel:OnChangedCharacter(selected)
end

function EmotesExplorerPanel:OnShow()
    EmotesExplorerPanel._base.OnShow(self)
    self.heroselector:LoadLastSelectedFromProfile()
    self.filter_bar:RefreshFilterState()
end

function EmotesExplorerPanel:OnClickedItem(item_data, is_selected)
    self.puppet:DoEmote(EMOTE_ITEMS[item_data.item_key].data.anim, EMOTE_ITEMS[item_data.item_key].data.loop, true)
end


function EmotesExplorerPanel:_BuildItemExplorer()
    local title_text = STRINGS.UI.COLLECTIONSCREEN.EMOTE
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
    return ItemExplorer(title_text, ITEM_TYPE, EMOTE_ITEMS, list_options)
end

function EmotesExplorerPanel:OnUpdate(dt)
    self.puppet:EmoteUpdate(dt)
end

return EmotesExplorerPanel
