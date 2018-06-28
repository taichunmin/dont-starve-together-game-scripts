-- For shortcut purposes, but if needed there's a HexToRGB function in util.lua, as well as a
-- RGBToPercentColor and a HexToPercentColor one
SKIN_RARITY_COLORS =
{
	Common			= { 0.718, 0.824, 0.851, 1 }, -- B7D2D9 - a common item (eg t-shirt, plain gloves)
	Classy			= { 0.255, 0.314, 0.471, 1 }, -- 415078 - an uncommon item (eg dress shoes, checkered trousers)
	Spiffy			= { 0.408, 0.271, 0.486, 1 }, -- 68457C - a rare item (eg Trenchcoat)
	Distinguished	= { 0.729, 0.455, 0.647, 1 }, -- BA74A5 - a very rare item (eg Tuxedo)
	Elegant			= { 0.741, 0.275, 0.275, 1 }, -- BD4646 - an extremely rare item (eg rabbit pack, GoH base skins)
	Timeless		= { 0.424, 0.757, 0.482, 1 }, -- 6CC17B - not used
	Loyal			= { 0.635, 0.769, 0.435, 1 }, -- A2C46F - a one-time giveaway (eg mini monument)
	ProofOfPurchase = { 0.000, 0.478, 0.302, 1 }, -- 007A4D
	Reward			= { 0.910, 0.592, 0.118, 1 }, -- E8971E - a set bonus reward
	Event			= { 0.957, 0.769, 0.188, 1 }, -- F4C430 - an event item
	
	Lustrous		= { 1.000, 1.000, 0.298, 1 }, -- FFFF4C - rarity modifier
	-- #40E0D0 reserved skin colour
}
DEFAULT_SKIN_COLOR = SKIN_RARITY_COLORS["Common"]

EVENT_ICONS = 
{
	event_forge = "LAVA",
	event_ice = "ICE",
	event_yotv = "VARG",
	event_quagmire = "VICTORIAN",
}

-- Also update GetBuildForItem!
local function GetSpecialItemCategories()
	-- We build this in a function because these symbols don't exist when this
	-- file is first loaded.
	return
	{
		MISC_ITEMS,
		CLOTHING,
		EMOTE_ITEMS,
		EMOJI_ITEMS,
	}
end
local function GetAllItemCategories()
	return { Prefabs, unpack(GetSpecialItemCategories()) }
end

--[[
Common #B7D2D9
Classy #415078
Spiffy #68457C
Distinguished #BA74A5
Elegant #BD4646
Timeless #6CC17B
Loyal #A2C46F
ProofOfPurchase #007A4D
Reward #E8971E
Event #F4C430
#40E0D0 reserved skin colour
]]

-- for use in sort functions
-- return true if rarity1 should go first in the list
local rarity_order =
{
	ProofOfPurchase = 1,
	Timeless = 2,
	Loyal = 3,
	Reward = 4,
	Event = 5,
	Elegant = 6,
	Distinguished = 7,
	Spiffy = 8,
	Classy = 9,
	Common = 10
}

function CompareReleaseGroup(a, b)
	return (a.release_group or 999) > (b.release_group or 999)
end

function CompareRarities(a, b)
	local rarity1 = type(a) == "string" and a or a.rarity
	local rarity2 = type(b) == "string" and b or b.rarity

	return rarity_order[rarity1 or "Common"] < rarity_order[rarity2 or "Common"] --look into removing this by always populating the rarity field for item data
end

function GetNextRarity(rarity)
	--just used by the tradescreen
	local rarities = {Common = "Classy",
					  Classy = "Spiffy",
					  Spiffy = "Distinguished",
					  Distinguished = "Elegant",
					  Elegant = "Event",
					  Event = "Reward",
					  Reward = "Loyal",
					  Loyal = "Timeless",
					  Timeless = "ProofOfPurchase"
					 }

	return rarities[rarity] or nil
end

function GetBuildForItem(name)
	for i,item_category in ipairs(GetSpecialItemCategories()) do
		if item_category[name] then
			return name
		end
	end

	if Prefabs[name] ~= nil then
		return Prefabs[name].build_name
	end

	return name
end

-- Get the bigportrait UIAnim assets loaded by the prefab. Many prefabs don't
-- have this info (only necessary to animate a bigportrait like when you get
-- one in a mysterybox).
function GetBigPortraitForItem(item_key)
	if Prefabs[item_key] ~= nil then
		return Prefabs[item_key].bigportrait
	end

	return nil
end

function IsPackFeatured(item_key)
    local pack_data = GetSkinData(item_key)
    return pack_data.featured_pack
end

function IsPackGiftable(item_key)
    local pack_data = GetSkinData(item_key)
    return pack_data.steam_dlc_id ~= nil
end

function GetPackGiftDLCID(item_key)
    local pack_data = GetSkinData(item_key)
    return pack_data.steam_dlc_id
end


function GetPurchaseDisplayForItem(item_key)
	local pack_data = GetSkinData(item_key)
	if pack_data.display_atlas ~= nil and pack_data.display_tex ~= nil then
		return { pack_data.display_atlas, pack_data.display_tex }
	end
	
	return nil
end

function GetBoxBuildForItem(item_key)
	local pack_data = GetSkinData(item_key)
	if pack_data.box_build ~= nil and pack_data.box_build ~= nil then
		return pack_data.box_build
	end
	return "box_build undefined"
end

function IsClothingItem(name)
	if CLOTHING[name] then 
		return true
	end
	return false
end

-- Skins for items you use in game.
function IsGameplayItem(name)
    -- When oddment are released we may need to add them here.
    return GetTypeForItem(name) == "item"
end

function IsItemId(name)
	for i,item_category in ipairs(GetAllItemCategories()) do
		if item_category[name] then
			return true
		end
	end
	return false
end

function IsItemMarketable(item)
	local skin_data = GetSkinData(item)
	return skin_data.marketable
end

function GetSkinData(item)
	local skin_data = {}
	for i,item_category in ipairs(GetAllItemCategories()) do
		skin_data = item_category[item]
		if skin_data then
			return skin_data
		end
	end
	return {}
end

function GetColorForItem(item)
	local skin_data = GetSkinData(item)
	return SKIN_RARITY_COLORS[skin_data.rarity] or DEFAULT_SKIN_COLOR
end

function GetModifiedRarityStringForItem( item )
	if GetRarityModifierForItem(item) ~= nil then
		if STRINGS.UI.RARITY[GetRarityModifierForItem(item)] == nil then
			print("Error! Unknown rarity modifier. Needs to be defined in strings.lua.", GetRarityModifierForItem(item) )
		end
		return (STRINGS.UI.RARITY[GetRarityModifierForItem(item)] or "") .. STRINGS.UI.RARITY[GetRarityForItem(item)]
	else
		return STRINGS.UI.RARITY[GetRarityForItem(item)]
	end
end

function GetRarityModifierForItem(item)
	local skin_data = GetSkinData(item)
	local rarity_modifier = skin_data.rarity_modifier
	return rarity_modifier
end

function GetRarityForItem(item)
	local skin_data = GetSkinData(item)
	local rarity = skin_data.rarity
	
	if not rarity then 
		rarity = "Common"
	end
	
	return rarity
end

function GetEventIconForItem(item)
	local skin_data = GetSkinData(item)
	for k,v in pairs(EVENT_ICONS) do
		if DoesItemHaveTag( item, v ) then
			return k
		end
	end

	return nil
end

function GetSkinUsableOnString(item_type, popup_txt)
	local skin_data = GetSkinData(item_type)
	
	local skin_str = GetSkinName(item_type)
	
	local usable_on_str = ""
	if skin_data ~= nil and skin_data.base_prefab ~= nil then
		if skin_data.granted_items == nil then
			local item_str = STRINGS.NAMES[string.upper(skin_data.base_prefab)]
			usable_on_str = subfmt(popup_txt and STRINGS.UI.SKINSSCREEN.USABLE_ON_POPUP or STRINGS.UI.SKINSSCREEN.USABLE_ON, { skin = skin_str, item = item_str })
		else
			local item1_str = STRINGS.NAMES[string.upper(skin_data.base_prefab)]
			local item2_str = nil
			local item3_str = nil
			
			local granted_skin_data = GetSkinData(skin_data.granted_items[1])
			if granted_skin_data ~= nil and granted_skin_data.base_prefab ~= nil then
				item2_str = STRINGS.NAMES[string.upper(granted_skin_data.base_prefab)]	
			end
			local granted_skin_data = GetSkinData(skin_data.granted_items[2])
			if granted_skin_data ~= nil and granted_skin_data.base_prefab ~= nil then
				item3_str = STRINGS.NAMES[string.upper(granted_skin_data.base_prefab)]	
			end
			
			if item3_str == nil then
				usable_on_str = subfmt(popup_txt and STRINGS.UI.SKINSSCREEN.USABLE_ON_MULTIPLE_POPUP or STRINGS.UI.SKINSSCREEN.USABLE_ON_MULTIPLE, { skin = skin_str, item1 = item1_str, item2 = item2_str })
			else
				usable_on_str = subfmt(popup_txt and STRINGS.UI.SKINSSCREEN.USABLE_ON_MULTIPLE_3_POPUP or STRINGS.UI.SKINSSCREEN.USABLE_ON_MULTIPLE_3, { skin = skin_str, item1 = item1_str, item2 = item2_str, item3 = item3_str })
			end
		end
	end
	
	return usable_on_str
end

function IsUserCommerceAllowedOnItem(item_key)
	if TheInventory:CheckOwnership(item_key) then
		return IsUserCommerceSellAllowedOnItem(item_key)
	else
		return IsUserCommerceBuyAllowedOnItem(item_key)
	end
end

function IsUserCommerceSellAllowedOnItem(item_type)
	local num_owned = TheInventory:GetOwnedItemCountForCommerce(item_type)
    return num_owned > 0 and TheItems:GetBarterSellPrice(item_type) ~= 0
end

function IsUserCommerceBuyAllowedOnItem(item_type)
    local num_owned = TheInventory:GetOwnedItemCountForCommerce(item_type)
	return num_owned == 0 and TheItems:GetBarterBuyPrice(item_type) ~= 0	
end

function GetIsDLCOwned(item_type)
    if GetRarityForItem(item_type) == "Event" or GetRarityForItem(item_type) == "Reward" then
        return false
    end
	return TheInventory:GetIsDLCOwned(item_type)
end
	
function GetTypeForItem(item)

	local itemName = string.lower(item) -- they come back from the server in caps
	local type = "unknown"

	--print("Getting type for ", itemName)

	for i,item_category in ipairs(GetAllItemCategories()) do
		if item_category[itemName] then
			type = item_category[itemName].type
			break
		end
	end

	return type, itemName
end

function GetSortCategoryForItem(item)
	for i,item_category in ipairs(GetSpecialItemCategories()) do
		if item_category[item] then
			return item_category[item].type
		end
	end

	local skinsData = Prefabs[item]
    if skinsData then
        return skinsData.base_prefab
    end
    -- Likely cause: Player's inventory contained an unreleased item. Should
    -- only happen in dev branch. (Also possible someone forgot to update
    -- GetSpecialItemCategories().)
    local DEBUG_MODE = BRANCH == "dev"
    assert(DEBUG_MODE, "Unknown item: ".. item)
    return ""
end


function DoesItemHaveTag(item, tag)
	local tags = {}
	if CLOTHING[item] then 
		tags = CLOTHING[item].skin_tags
	elseif MISC_ITEMS[item] then 
		tags = MISC_ITEMS[item].skin_tags
	elseif EMOTE_ITEMS[item] then 
		tags = EMOTE_ITEMS[item].skin_tags
	else
		if Prefabs[item] ~= nil then
			tags = Prefabs[item].skin_tags
		end
	end

	for _,item_tag in pairs(tags) do
		if item_tag == tag then
			return true
		end
	end
	
	return false
end

--Note(Peter): do we actually want to do this here, or actually provide the json tags from the pipeline?
--[[function GetTagFromType(type)
	if type == "body" or type == "hand" or type == "legs" or type == "feet" then
		return string.upper("CLOTHING_" .. type)
	elseif type == "base" then
		return "CHARACTER"
	elseif type == "emote" then
		return "EMOTE"
	elseif type == "emoji" then
		return "EMOJI"
	elseif type == "item" then
		return nil --what tags are on item type things
	elseif type == "oddment" then
		return "ODDMENT"
	elseif type == "loading" then
		return "LOADING"
	elseif type == "playerportrait" then
		return "PLAYERPORTRAIT"
	elseif type == "profileflair" then
		return "PROFILEFLAIR"
	else
		return string.upper("MISC_" .. type)
	end
end
function GetTypeFromTag(tag)
	if string.find(tag, "CLOTHING_") then
		return string.lower( string.gsub(tag, "CLOTHING_", "") )
	elseif string.find(tag, "CHARACTER") then
		return "base"
	else
		return nil --What do we want to do about colour and misc tags?
	end
end]]

--[[function GetColourFromColourTag(c) --UNTESTED!!!
	local s = string.lower(c)
	return s:sub(1,1):upper()..s:sub(2)
end]]

function GetSkinName(item)
	if string.sub( item, -8 ) == "_builder" then
		item = string.sub( item, 1, -9 )
	end
    if string.sub( item, -4) == "none" then
        item = "none"
    end
    if string.sub( item, -8) == "default1" then
        item = "none"
    end
	local nameStr = STRINGS.SKIN_NAMES[item] or STRINGS.NAMES[string.upper(item)] or STRINGS.SKIN_NAMES["missing"]
	local alt = STRINGS.SKIN_NAMES[item.."_alt"]
	if alt then 
		nameStr = GetRandomItem({nameStr, alt})
	end

	return nameStr
end

function GetSkinDescription(item)
	return STRINGS.SKIN_DESCRIPTIONS[item] or STRINGS.SKIN_DESCRIPTIONS["missing"]
end

function GetSkinInvIconName(item)
    local image_name = item

    if image_name == "" then
        image_name = "default"
    else 
        if string.sub( image_name, -8 ) == "_builder" then
            image_name = string.sub( image_name, 1, -9 )
        end
        image_name = string.gsub(image_name, "_none", "")
    end

    return image_name
end



----------------------------------------------------
--local widgets_to_update, widgets_per_row, row_height = create_widgets_fn()
-- DEPRECATED: Use TEMPLATES.ScrollingGrid instead!
function SkinGridListConstructor(context, parent, scroll_list)
	local ItemImage = require "widgets/itemimage"
    local screen = context.screen
	local NUM_ROWS = 5
	local NUM_COLUMNS = 4
	local SPACING = 85
	
	local widgets = {}
	
	local x_offset = (NUM_COLUMNS/2) * SPACING + SPACING/2
	local y_offset = (NUM_ROWS/2) * SPACING - 15
	
	for y = 1,NUM_ROWS do
		for x = 1,NUM_COLUMNS do
			local index = ((y-1) * NUM_COLUMNS) + x
			
			local itemimage = parent:AddChild(ItemImage(screen, "", "", 0, 0, nil ))
			itemimage.clickFn = function(type, item, item_id) 
				screen:OnItemSelect(type, item, item_id, itemimage)
			end

			itemimage.ongainfocusfn = function()
                scroll_list:OnWidgetFocus(itemimage)
            end
		
			itemimage:SetPosition( x * SPACING - x_offset, -y * SPACING + y_offset, 0)
		
			widgets[index] = itemimage
			
			if x > 1 then 
				itemimage:SetFocusChangeDir(MOVE_LEFT, widgets[index-1])
				widgets[index-1]:SetFocusChangeDir(MOVE_RIGHT, itemimage)
			end
			if y > 1 then 
				itemimage:SetFocusChangeDir(MOVE_UP, widgets[index-NUM_COLUMNS])
				widgets[index-NUM_COLUMNS]:SetFocusChangeDir(MOVE_DOWN, itemimage)
			end
		end
	end
	
	--if disable_selecting then
		for _,item_image in pairs(widgets) do
			item_image:DisableSelecting()
		end
	--end
	-- Send focus somewhere that does something with it.
    parent.focus_forward = widgets[1]
	
	return widgets, NUM_COLUMNS, SPACING, NUM_ROWS-2, 0.35
end

-- DEPRECATED: Use ItemImage.ApplyDataToWidget instead!
function UpdateSkinGrid(context, list_widget, data, data_index)
    local screen = context.screen
	if data ~= nil then
        -- data.item is actually the item_key!
		list_widget:SetItem(data.type, data.item, data.item_id, data.timestamp)

		if not list_widget.disable_selecting then
			list_widget:Unselect() --unselect everything when the data is updated
			if list_widget.focus then --but maintain focus on the widget
				list_widget:Embiggen()
			end
		end

		list_widget:Show()

		if screen.show_hover_text then
			local hover_text = GetModifiedRarityStringForItem(data.item) .. "\n" .. GetSkinName(data.item)
			list_widget:SetHoverText( hover_text, { font = NEWFONT_OUTLINE, offset_x = 0, offset_y = 60, colour = {1,1,1,1}})
			if list_widget.focus then --make sure we force the hover text to appear on the default focused item
				list_widget:OnGainFocus()
			end
		end
	else
		list_widget:SetItem(nil, nil, nil)
		list_widget:Unselect()
		if list_widget.focus then --maintain focus on the widget
			list_widget:Embiggen()
		end
		if screen.show_hover_text then
			list_widget:ClearHoverText()
		end
	end
end

local function GetLexicalSortLiteral(item_key)
    return GetSortCategoryForItem(item_key)..GetSkinName(item_key)..item_key
end

-- Compare two keys from an item table for sorting purposes. Requires the item
-- table they come from (i.e., MISC_ITEMS) since that data is not always
-- contained within items.
--
-- Useful for showing all extant items (no duplicates).
function CompareItemDataForSort(item_key_a, item_key_b, item_table)
    if item_key_a == item_key_b then 
        return false
    elseif item_table[item_key_a].release_group ~= item_table[item_key_b].release_group then 
    
        return CompareReleaseGroup(item_table[item_key_a], item_table[item_key_b])
    elseif item_table[item_key_a].rarity ~= item_table[item_key_b].rarity then
	
		return CompareRarities(item_table[item_key_a], item_table[item_key_b])
	else
        return GetLexicalSortLiteral(item_key_a) < GetLexicalSortLiteral(item_key_b) 
    end
end

function GetInventoryTimestamp()
	local templist = TheInventory:GetFullInventory()
	local timestamp = 0
	for _,v in ipairs(templist) do
		if v.modified_time > timestamp then
			timestamp = v.modified_time
		end
	end
	return timestamp
end

-- Sorted by rarity and name. Good for displaying duplicates.
function GetSortedSkinsList()
	local templist = TheInventory:GetFullInventory()
	local skins_list = {}
	local timestamp = 0

	local listoflists = 
	{
		oddment = {},
		emote = {},
		emoji = {},
		feet = {},
		hand = {},
		body = {},
		legs = {},
		base = {},
		item = {},
		misc = {},
		mysterybox = {},
		purchase = {},
		loading = {},
		playerportrait = {},
		profileflair = {},
		unknown = {},
	}

	for k,v in ipairs(templist) do
		local type, item = GetTypeForItem(v.item_type)
		local rarity = GetRarityForItem(item)

		--if type ~= "unknown" then

			local data = {}
			data.type = type
			data.item = item
			data.rarity = rarity
			data.timestamp = v.modified_time
			data.item_id = v.item_id
		
			if listoflists[type] == nil then
				print("Missing sorted skin list type ", type)
			else
				table.insert(listoflists[type], data)
			end
			
			if v.modified_time > timestamp then 
				timestamp = v.modified_time
			end
		--end
	end

	local compare = function(a, b) 
						if a.rarity == b.rarity then 
							if a.release_group == b.release_group then 
								if a.item == b.item then 
									return a.timestamp > b.timestamp
								else
									return GetLexicalSortLiteral(a.item) < GetLexicalSortLiteral(b.item)
								end
							else
								return CompareReleaseGroup(a,b)
							end
						else 
							return CompareRarities(a,b)
						end
					end

	for name,list in pairs(listoflists) do
		table.sort(list, compare)
	end

	-- These must be inserted sequentially to ensure a specific order. Don't
	-- trust lua table iteration order!
	skins_list = JoinArrays(skins_list, listoflists.oddment)
	skins_list = JoinArrays(skins_list, listoflists.emote)
	skins_list = JoinArrays(skins_list, listoflists.emoji)
	skins_list = JoinArrays(skins_list, listoflists.mysterybox)
	skins_list = JoinArrays(skins_list, listoflists.purchase)
	skins_list = JoinArrays(skins_list, listoflists.item)
	skins_list = JoinArrays(skins_list, listoflists.base)
	skins_list = JoinArrays(skins_list, listoflists.body)
	skins_list = JoinArrays(skins_list, listoflists.hand)
	skins_list = JoinArrays(skins_list, listoflists.legs)
	skins_list = JoinArrays(skins_list, listoflists.feet)
	skins_list = JoinArrays(skins_list, listoflists.loader)
	skins_list = JoinArrays(skins_list, listoflists.playerportrait)
	skins_list = JoinArrays(skins_list, listoflists.profileflair)
	skins_list = JoinArrays(skins_list, listoflists.misc)
	skins_list = JoinArrays(skins_list, listoflists.unknown)

	return skins_list, timestamp
end

--This function is very expensive, don't use it more than once per frame!!!
function GetOwnedItemCounts()
	local item_counts = {}
	local inventory_list = TheInventory:GetFullInventory()
	for i,inv_item in ipairs(inventory_list) do
		local key = inv_item.item_type
		if item_counts[key] then
			item_counts[key] = item_counts[key] + 1
 		else
			item_counts[key] = 1
		end
	end
	return item_counts
end


-- Get the item_id for the first item player owns matching the input key. Items
-- are fungible, so the first one is good enough.
function GetFirstOwnedItemId(item_key)
    local inventory_list = TheInventory:GetFullInventory()
	for k,v in ipairs(inventory_list) do
        if item_key == v.item_type and v.item_id ~= TEMP_ITEM_ID then
            return v.item_id
        end
    end
end


function CopySkinsList(list)
	local newList = {}
	for k, skin in ipairs(list) do 
		newList[k] = {}
		newList[k].type = skin.type
		newList[k].item = skin.item
		newList[k].item_id = skin.item_id
		newList[k].timestamp = skin.modified_time
	end

	return newList
end

-- These are the item collections (ie: "Shadow Collection")
function GetItemCollectionName(item_type)
    for k, v in pairs(STRINGS.SKIN_TAG_CATEGORIES.COLLECTION) do
        if DoesItemHaveTag( item_type, k ) then
            return v
        end
    end

    return nil
end

-- These are the item ensembles (ie: "Forge Set Ensemble")
local SKIN_SET_ITEMS = require("skin_set_info")
function IsItemInCollection(item_type)
	for bonus_item,input_sets in pairs(SKIN_SET_ITEMS) do
		if bonus_item == item_type then
			return true, bonus_item
		end
		for _,item_set in pairs(input_sets) do
			for _,input_item in pairs(item_set) do
				if input_item == item_type then
					return true, bonus_item
				end
			end
		end
	end
	return false, nil
end
function IsItemIsReward(item_type)
	for bonus_item,_ in pairs(SKIN_SET_ITEMS) do
		if bonus_item == item_type then
			return true
		end
	end
	return false
end

function _BonusItemRewarded(bonus_item, item_counts)
	for _,item_set in pairs(SKIN_SET_ITEMS[bonus_item]) do
		local missing_item = false
		for _,input_item in pairs(item_set) do
			if (item_counts[input_item] or 0) == 0 then
				missing_item = true
			end
		end
		if not missing_item then
			return true
		end
	end
	return false
end
function WillUnravelBreakEnsemble(item_type)
	local in_collection, bonus_item = IsItemInCollection(item_type)
	
	if not in_collection then
		return false
	end
	
	local item_counts = GetOwnedItemCounts()
	if _BonusItemRewarded(bonus_item, item_counts) then
		item_counts[item_type] = (item_counts[item_type] or 1) - 1 --subtract one if it exists, otherwise 0
		return not _BonusItemRewarded(bonus_item, item_counts)
	end
	
	return false --not rewarded already
end



-- GetPackForItem only returns purchasable packs! We don't display historical
-- packs so if it's not for sale, it's not part of a pack. Pack information is
-- not the same as ensemble/sets.
local PURCHASE_INFO = require("skin_purchase_packs")
function GetPackForItem(item_key)
    local pack = PURCHASE_INFO.CONTENTS[item_key]
    if pack then
        local iap_defs = TheItems:GetIAPDefs()
        for i,iap in ipairs(iap_defs) do
            if iap.item_type == pack then
                return pack
            end
        end
    end
end

function OwnsSkinPack(item_key)
	for _,v in pairs(PURCHASE_INFO.PACKS[item_key]) do
		if not TheInventory:CheckOwnership(v) then
			return false
		end
	end

	return true
end

--[[function GetTotalItemCollectionCompletion()
    local num_owned = 0
    local num_need = 0
    for i,item_category in ipairs(GetAllItemCategories()) do
        for item_key,item_blob in pairs(item_category) do
            if TheInventory:CheckOwnership(item_key) then
                num_owned = num_owned + 1
            else
                num_need = num_need + 1
            end
        end
    end
    return num_owned, num_need
end]]

local SKIN_AFFINITY_INFO = require("skin_affinity_info")
function GetSkinCollectionCompletionForHero(herocharacter)
    assert(herocharacter)
    local num_owned = 0
    local num_need = 0
    for i,item_key in ipairs(SKIN_AFFINITY_INFO[herocharacter] or {}) do
		if ShouldDisplayItemInCollection(item_key) then
			if TheInventory:CheckOwnership(item_key) then
				num_owned = num_owned + 1
			else
				num_need = num_need + 1
			end
		end
    end
    return num_owned, num_need
end

function GetAffinityFilterForHero(herocharacter)
    local function AffinityFilter(item_key)
        return table.contains(SKIN_AFFINITY_INFO[herocharacter], item_key)
    end
    return AffinityFilter
end

function GetLockedSkinFilter()
    local function LockedFilter(item_key)
        return TheInventory:CheckOwnership(item_key)
    end
    return LockedFilter
end

function GetMysteryBoxCounts()
	local templist = TheInventory:GetFullInventory()
	
	local box_counts = {}
	for _,item_info in pairs(templist) do
		local item_type = item_info.item_type
		if GetTypeForItem(item_type) == "mysterybox" then
			if box_counts[item_type] == nil then
				box_counts[item_type] = 1
			else
				box_counts[item_type] = box_counts[item_type] + 1
			end			
		end
	end
		
	return box_counts
end

function GetTotalMysteryBoxCount()
	local templist = TheInventory:GetFullInventory()
	
	local box_count = 0
	for _,item_info in pairs(templist) do
		local item_type = item_info.item_type
		if GetTypeForItem(item_type) == "mysterybox" then
			box_count = box_count + 1
		end
	end
		
	return box_count
end

function GetMysteryBoxItemID(item_type)
	local templist = TheInventory:GetFullInventory()
	
	for _,item_info in pairs(templist) do
		if item_info.item_type == item_type then
			return item_info.item_id
		end
	end
	
	return 0
end


function CalculateShopHash()
	local shop_str = ""
	local unvalidated_iap_defs = TheItems:GetIAPDefs()
    local iap_defs = {}
    for _,iap in pairs(unvalidated_iap_defs) do
        -- Don't add items unless we have data/strings to describe them.
        if MISC_ITEMS[iap.item_type] then
            shop_str = shop_str .. iap.item_type
        end
    end
	return smallhash(shop_str)
end

function IsShopNew(user_profile)
	return user_profile:GetShopHash() ~= CalculateShopHash() and #(TheItems:GetIAPDefs()) > 0
end

function IsAnyItemNew(user_profile)
	local collection_timestamp = user_profile and user_profile:GetCollectionTimestamp() or -10000
	return collection_timestamp < GetInventoryTimestamp()
end

function ShouldDisplayItemInCollection(item_type)
	if ITEM_DISPLAY_BLACKLIST[item_type] then
        return false
    end
	local rarity = GetRarityForItem(item_type)
	if rarity == "Event" or rarity == "ProofOfPurchase" or rarity == "Loyal" or rarity == "Timeless" then
		return TheInventory:CheckOwnership(item_type)
	end
    return true
end

local function IsDefaultCharacterSkin(item_key)
    return item_key:find("_none",-5,true) == nil
end

-- Returns a table similar to MISC_ITEMS, but with character heads (skin
-- bases).
function GetCharacterSkinBases(hero)
    local matches = {}
    local skins = PREFAB_SKINS[hero]
    for i,item_key in ipairs(skins) do
        -- We could allow default character skins (so you can pick them), but
        -- they're not currently account items. If we did that, we'd want the
        -- same for all vanity item types!
        if not IsGameplayItem(item_key) and IsDefaultCharacterSkin(item_key) then
            matches[item_key] = Prefabs[item_key]
        end
    end
    return matches
end

-- Returns a table similar to MISC_ITEMS, but with gameplay items
-- (items used in-game like item skins but not character skins).
function GetAllGameplayItems()
    local matches = {}
    for prefab,skins in pairs(PREFAB_SKINS) do
        for i,item_key in ipairs(skins) do
            if IsGameplayItem(item_key) then
                matches[item_key] = Prefabs[item_key]
            end
        end
    end
    
    return matches
end

function GetAllMiscItemsOfType(item_type)
    local matches = {}
    for item_key,item_blob in pairs(MISC_ITEMS) do
        if item_blob.type == item_type then
            matches[item_key] = item_blob
        end
    end
    return matches
end

function ValidateItemsInProfile(user_profile)
    if TheInventory:HasDownloadedInventory() then
        -- We know whether they own something.
        for i,item_type in ipairs(user_profile:GetStoredCustomizationItemTypes()) do
            for item_key,is_active in pairs(user_profile:GetCustomizationItemsForType(item_type)) do
                if not TheInventory:CheckOwnership(item_key) then
                    -- A user who sells/trades an item on the marketplace needs
                    -- to have it locally revoked.
                    user_profile:SetCustomizationItemState(item_type, item_key, false)
                end
            end
        end
    end
end

-- We must cache vanity items before they can be used (caching pushes to c-code
-- which pushes to server).
function CacheCurrentVanityItems(user_profile)
    local all_vanity = {}
    for i,item_type in ipairs({"playerportrait", "profileflair"}) do
        for item_key,is_active in pairs(user_profile:GetCustomizationItemsForType(item_type)) do
            if is_active then
                table.insert(all_vanity, item_key)
            end
        end
    end
    TheInventory:SetLocalVanityItems(all_vanity)
end

function GetRemotePlayerVanityItem(active_cosmetics, item_type)
    -- Instead of GetTypeForItem (which loops over everything), we get the
    -- types we want and find a match.
    local all_items_of_type = GetAllMiscItemsOfType(item_type)
    for i,item_key in ipairs(active_cosmetics) do
        if all_items_of_type[item_key] then
            return item_key
        end
    end
end

function GetSkinsDataFromClientTableData(data)
    local clothing =
    {
        body = data.body_skin,
        hand = data.hand_skin,
        legs = data.legs_skin,
        feet = data.feet_skin,
    }
    local playerportrait = GetRemotePlayerVanityItem(data.vanity or {}, "playerportrait")
    local profileflair = GetRemotePlayerVanityItem(data.vanity or {}, "profileflair")
    return data.base_skin, clothing, playerportrait, profileflair, data.eventlevel
end

function BuildListOfSelectedItems(user_profile, item_type)
    local all_image_keys = user_profile:GetCustomizationItemsForType(item_type)
    local image_keys = {}
    for item_key,is_active in pairs(all_image_keys) do
        if is_active and TheInventory:CheckOwnership(item_key) then
            table.insert(image_keys, item_key)
        end
    end
    table.sort(image_keys)
    return image_keys
end

function GetMostRecentlySelectedItem(user_profile, item_type)
    return user_profile:GetCustomizationItemState(item_type, "last_item_key")
end

local function GetOneAtlasPerImage_pkgref(atlas_fmt, item_key)
    return atlas_fmt:format(item_key, "xml"), atlas_fmt:format(item_key, "tex")
end

local function GetOneAtlasPerImage_tex(atlas_fmt, item_key, defaults)
    return atlas_fmt:format(item_key, "xml"), item_key ..".tex"
end

local LOADER_ATLAS_FMT = "images/bg_loading_%s.%s"
function GetLoaderAtlasAndTexPkgref(item_key)
    return GetOneAtlasPerImage_pkgref(LOADER_ATLAS_FMT, item_key)
end
function GetLoaderAtlasAndTex(item_key)
    local atlas, tex = GetOneAtlasPerImage_tex(LOADER_ATLAS_FMT, item_key)
    if softresolvefilepath(atlas) then 
        return atlas, tex
    else
        -- The selected loader doesn't exist! Use a simple spiral instead of
        -- crashing.
        return "images/bg_spiral.xml", "bg_spiral.tex"
    end
end

function GetProfileFlairAtlasAndTex(item_key)
    local PROFILEFLAIR_ATLAS = "images/profileflair.xml"
    local PROFILEFLAIR_DEFAULT = "profileflair_none.tex"
    if item_key then
        return PROFILEFLAIR_ATLAS, item_key ..".tex", PROFILEFLAIR_DEFAULT
    else
        return PROFILEFLAIR_ATLAS, PROFILEFLAIR_DEFAULT
    end
end

local PLAYER_PORTRAIT_ATLAS_FMT = "images/playerportrait_%s.%s"
function GetPlayerPortraitAtlasAndTexPkgref(item_key)
    return GetOneAtlasPerImage_pkgref(PLAYER_PORTRAIT_ATLAS_FMT, item_key)
end
function GetPlayerPortraitAtlasAndTex(item_key)
    local DEFAULT_BACKGROUND = "playerportrait_bg_none"
    local atlas, tex = GetOneAtlasPerImage_tex(PLAYER_PORTRAIT_ATLAS_FMT, item_key or DEFAULT_BACKGROUND)
    if softresolvefilepath(atlas) then 
        return atlas, tex
    else
        -- item_key was nil or not a real file.
        return GetOneAtlasPerImage_tex(PLAYER_PORTRAIT_ATLAS_FMT, DEFAULT_BACKGROUND)
    end
end



function IsSkinDLCEntitlementReceived(entitlement)
	return Profile:IsEntitlementReceived(entitlement)
end
function SetSkinDLCEntitlementReceived(entitlement)
	Profile:SetEntitlementReceived(entitlement)
end

function SetSkinDLCEntitlementOwned(entitlement)
	if not Profile:IsEntitlementReceived(entitlement) then
		AddNewSkinDLCEntitlement(entitlement)
	end
	Profile:SetEntitlementReceived(entitlement)
end

local newSkinDLCEntitlements = {}
function AddNewSkinDLCEntitlement(entitlement)
	table.insert( newSkinDLCEntitlements, entitlement)
end
function HasNewSkinDLCEntitlements()
	return #newSkinDLCEntitlements > 0
end
function GetNewSkinDLCEntitlement()
	local entitlement = newSkinDLCEntitlements[#newSkinDLCEntitlements]
	table.remove( newSkinDLCEntitlements, #newSkinDLCEntitlements)
	return entitlement
end


function MakeSkinDLCPopup(_cb)
	local pack_type = GetNewSkinDLCEntitlement()

	if pack_type ~= nil then
		local PURCHASE_INFO = require("skin_purchase_packs")
		local display_items = PURCHASE_INFO.PACKS[pack_type]
        if display_items ~= nil then
		    local options = {
			    allow_cancel = false,
			    box_build = GetBoxBuildForItem(pack_type),
			    use_bigportraits = IsPackFeatured(pack_type),
		    }

		    if GetSkinData(pack_type).legacy_popup_category ~= nil then
			    local items = {}
			    for _,item in pairs(display_items) do
				    table.insert(items, { item = item, item_id = 0, gifttype = GetSkinData(pack_type).legacy_popup_category })
			    end

			    local ThankYouPopup = require "screens/thankyoupopup"
			    local thankyou_popup = ThankYouPopup(items, function() MakeSkinDLCPopup(_cb) end)
			    TheFrontEnd:PushScreen(thankyou_popup)
		    else
			    local ItemBoxOpenerPopup = require "screens/redux/itemboxopenerpopup"
			    local box_popup = ItemBoxOpenerPopup(nil, options, function(success_cb) success_cb(display_items) end, function() MakeSkinDLCPopup(_cb) end)
			    TheFrontEnd:PushScreen(box_popup)
		    end
        else
            --No items to display, likely bad data.
            print("Error: Unable to display skin dlc contents for", pack_type)
            MakeSkinDLCPopup(_cb)
        end
	else
		if TheFrontEnd:GetActiveScreen().FinishedFadeIn ~= nil then
			TheFrontEnd:GetActiveScreen():FinishedFadeIn()
		end

		if _cb ~= nil then
			_cb()
		end
	end
end
