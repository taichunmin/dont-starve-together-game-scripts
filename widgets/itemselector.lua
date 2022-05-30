local Widget = require "widgets/widget"
local TrueScrollList = require "widgets/truescrolllist"
local Menu = require "widgets/menu"
local Text = require "widgets/text"

require "skinsutils"

local TEMPLATES = require "widgets/templates"

local DEBUG_MODE = BRANCH == "dev"

local NUM_ROWS = 4
local NUM_ITEMS_PER_ROW = 4

local ItemSelector = Class(Widget, function(self, parent, owner, profile)
    self.owner = owner
	self.parent = parent
    self.profile = profile
    Widget._ctor(self, "ItemSelector")

    self.root = self:AddChild(Widget("ItemSelectorRoot"))

    -- Title banner
    self.title_group = self.root:AddChild(Widget("Title"))
    self.title_group:SetPosition(25, 255)

    self.banner = self.title_group:AddChild(Image("images/tradescreen.xml", "banner0_small.tex"))
    self.banner:SetScale(.38)
    self.banner:SetPosition(-40, 27)
    self.title = self.title_group:AddChild(Text(BUTTONFONT, 35, STRINGS.UI.TRADESCREEN.SELECT_TITLE, BLACK))
    self.title:SetPosition(-35, 25)
    self.title:SetRotation(-17)

    self:BuildInventoryList()

    self.focus_forward = self.scroll_list
end)

function ItemSelector:Close()
	self:Kill()
end

function ItemSelector:BuildInventoryList()
	self.inventory_list = self.root:AddChild(Widget("container"))
	self.inventory_list:SetScale(.7)
    self.inventory_list:SetPosition( -18, 65)

	self.show_hover_text = true --shows the hover text on the paged list

	self.scroll_list = self.inventory_list:AddChild( TrueScrollList(
			{screen = self},
			SkinGridListConstructor,
			UpdateSkinGrid,
			-200, -150, 400, 300,
            20
		)
	)
	self.list_widgets = self.scroll_list:GetListWidgets()
end

function ItemSelector:UpdateData( selections, filters_list )
    self.full_skins_list = GetInventorySkinsList( true )
    self.skins_list = ApplyFilters( self.full_skins_list, filters_list )

	--Remove selected items from the list so we can't select them twice
	local k = 1
	while k <= #self.skins_list do
		local v = self.skins_list[k]
		local removed = false
		for _,v2 in pairs(selections) do -- Note: selections is not a contiguous array
    		if v.item_id == v2.item_id then
    			-- Remove this thing from the list, and skip the rest of the skins_list
    			table.remove(self.skins_list, k)
    			removed = true

    			break
    		end
    	end

    	if not removed then
    		k = k + 1
    	end
    end

	self.scroll_list:SetItemsData(self.skins_list)
end

function ItemSelector:EnableInput()
	for _,item_image in pairs( self.list_widgets ) do
		item_image:Enable()
	end
end

function ItemSelector:DisableInput()
	for _,item_image in pairs( self.list_widgets ) do
		item_image:Disable()
	end
end

-- OnItemSelect is called when an item in the list is clicked
function ItemSelector:OnItemSelect(type, item, item_id, itemimage)
	-- TODO: put this back if we stop removing the items from the list entirely
	--itemimage:PlaySpecialAnimation("off")

	--print("ItemSelector position", self:GetPosition(), self:GetWorldPosition())
	self.owner:StartAddSelectedItem( {type = type, item = item, item_id = item_id}, itemimage:GetWorldPosition())
end

-- This is the TOTAL number of items in the player's inventory, not the number shown in the filtered view.
function ItemSelector:NumItemsLikeThis(item_name)
	local count = 0

	for k,v in ipairs(self.full_skins_list) do
		if v.item == item_name then
			count = count + 1
		end
	end

	return count
end

function ItemSelector:GetNumFilteredItems()
	return #self.skins_list
end

return ItemSelector
