local AccountItemFrame = require "widgets/redux/accountitemframe"
local Image = require "widgets/image"
local ItemExplorer = require "widgets/redux/itemexplorer"
local FilterBar = require "widgets/redux/filterbar"
local Text = require "widgets/text"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"


-- In the future, we may have several item types, but for now we're only items.
local ITEM_TYPE = "item"

local GameItemExplorerPanel = Class(Widget, function(self, owner, profile)
	Widget._ctor(self, "GameItemExplorerPanel")
    self.owner = owner
	self.user_profile = profile

	self:DoInit()

    self.filter_bar = self:AddChild(FilterBar(self.picker, "collectionscreen"))
    self.picker.header:AddChild( self.filter_bar:AddFilter(STRINGS.UI.WARDROBESCREEN.OWNED_FILTER_FMT, "owned_filter_on.tex", "owned_filter_off.tex", "lockedFilter", GetLockedSkinFilter()) )
    self.picker.header:AddChild( self.filter_bar:AddFilter(STRINGS.UI.WARDROBESCREEN.WEAVEABLE_FILTER_FMT, "weave_filter_on.tex", "weave_filter_off.tex", "weaveableFilter", GetWeaveableSkinFilter()) )
    self.picker.header:AddChild( self.filter_bar:AddSorter() )
    self.picker.header:AddChild( self.filter_bar:AddSearch() )

    self:_DoFocusHookups()
    self.focus_forward = self.filter_bar:BuildFocusFinder()
end)

function GameItemExplorerPanel:_DoFocusHookups()
    self.picker.header.focus_forward = self.filter_bar
end

function GameItemExplorerPanel:DoInit()
	--~ TheInputProxy:SetCursorVisible(true)

    self.fixed_root = self:AddChild(TEMPLATES.ScreenRoot())
    self:BuildInventoryList()
    self:BuildDetailsPanel()
end

-- Update the details panel when an item is clicked
function GameItemExplorerPanel:OnClickedItem(item_data, is_selected)
    local type, item_type = GetTypeForItem(item_data.item_key)
	--print( "GameItemExplorerPanel:OnClickedItem", type, item_type )

	if type == nil or item_type == nil then
		return
	end

	self.current_item_type = item_type

    self.details_panel:Show()

	if type == "base"  then
		self.details_panel.shadow:SetScale(.4)
	elseif type == "body" then
		self.details_panel.shadow:SetScale(.55)
	else
		if type == "item" then
			self.details_panel.shadow:SetScale(.7)
		else
			self.details_panel.shadow:SetScale(.6)
		end
	end

	self.details_panel.image:SetItem(item_type)

    self.details_panel.usable_on:SetString(GetSkinUsableOnString(item_type))

	self.details_panel:Show()
end

function GameItemExplorerPanel:BuildDetailsPanel()
	self.details_panel = self.fixed_root:AddChild(Widget("details-widget"))
    self.details_panel:SetPosition(-160, -0, 0)

    self.details_panel.image_root = self.details_panel:AddChild(Widget("image-root"))
	self.details_panel.image_root:SetPosition(0, 50)

	self.details_panel.image = self.details_panel.image_root:AddChild(AccountItemFrame())
	self.details_panel.image:HideFrame()
	self.details_panel.image:GetAnimState():PlayAnimation("icon")
	self.details_panel.image:SetScale(1.65)

    self.details_panel.shadow = self.details_panel.image_root:AddChild(Image("images/frontend.xml", "char_shadow.tex"))
	self.details_panel.shadow:SetPosition(0, -85)
	self.details_panel.shadow:SetScale(.8)


    self.details_panel.text_root = self.details_panel:AddChild(Widget("text-root"))
    self.details_panel.text_root:SetPosition(0, -165)

	self.details_panel.usable_on = self.details_panel.text_root:AddChild(Text(CHATFONT, 25, "lorem ipsum dolor sit amet", UICOLOURS.WHITE))
    self.details_panel.usable_on:SetRegionSize(350, 100)
    self.details_panel.usable_on:EnableWordWrap(true)
    self.details_panel.usable_on:SetVAlign(ANCHOR_TOP)
end

function GameItemExplorerPanel:OnShow()
    GameItemExplorerPanel._base.OnShow(self)
    self.filter_bar:RefreshFilterState()
end

function GameItemExplorerPanel:BuildInventoryList()
    self.picker = self:AddChild(self:_BuildItemExplorer())
    self.picker:SetPosition(310, 140)
    self.picker.clearSelectionCB = function()
        self.details_panel:Hide()
    end
	self.scroll_list = self.picker.scroll_list

	self.list_widgets = self.scroll_list:GetListWidgets()
end

local WIDGET_SIZE = 90
function GameItemExplorerPanel:_BuildItemExplorer()
    local title_text = STRINGS.UI.COLLECTIONSCREEN.GAMEITEM
    local list_options = {
        scroll_context = {
            screen = self,
            owner = self.owner,
            input_receivers = { self },
            user_profile = self.user_profile,
        },
        widget_width = WIDGET_SIZE,
        widget_height = WIDGET_SIZE,
        num_visible_rows = 3,
        num_columns = 5,
        scrollbar_offset = 20,
    }
    return ItemExplorer(title_text, ITEM_TYPE, GetAllGameplayItems, list_options)
end

return GameItemExplorerPanel
