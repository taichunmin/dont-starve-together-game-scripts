-- For shortcut purposes, but if needed there's a HexToRGB function in util.lua, as well as a
-- RGBToPercentColor and a HexToPercentColor one
SKIN_RARITY_COLORS =
{
	Common			= { 0.718, 0.824, 0.851, 1 }, -- B7D2D9 - a common item (eg t-shirt, plain gloves)
	Classy			= { 0.255, 0.314, 0.471, 1 }, -- 415078 - an uncommon item (eg dress shoes, checkered trousers)
	Spiffy			= { 0.408, 0.271, 0.486, 1 }, -- 68457C - a rare item (eg Trenchcoat)
	Distinguished	= { 0.729, 0.455, 0.647, 1 }, -- BA74A5 - a very rare item (eg Tuxedo)
	Elegant			= { 0.741, 0.275, 0.275, 1 }, -- BD4646 - an extremely rare item (eg rabbit pack, GoH base skins)

	HeirloomElegant	= { 0.933, 0.365, 0.251, 1 }, -- EE5D40
	Character		= { 0.718, 0.824, 0.851, 1 }, -- B7D2D9 - a character
	Timeless		= { 0.424, 0.757, 0.482, 1 }, -- 6CC17B - not used
	Loyal			= { 0.635, 0.769, 0.435, 1 }, -- A2C46F - a one-time giveaway (eg mini monument)
	ProofOfPurchase = { 0.000, 0.478, 0.302, 1 }, -- 007A4D
	Reward			= { 0.910, 0.592, 0.118, 1 }, -- E8971E - a set bonus reward
	Event			= { 0.957, 0.769, 0.188, 1 }, -- F4C430 - an event item

	Lustrous		= { 1.000, 1.000, 0.298, 1 }, -- FFFF4C - rarity modifier
	-- #40E0D0 reserved skin colour
}
--Share colours
SKIN_RARITY_COLORS.Complimentary = SKIN_RARITY_COLORS.Common
SKIN_RARITY_COLORS.HeirloomClassy = SKIN_RARITY_COLORS.HeirloomElegant
SKIN_RARITY_COLORS.HeirloomSpiffy = SKIN_RARITY_COLORS.HeirloomElegant
SKIN_RARITY_COLORS.HeirloomDistinguished = SKIN_RARITY_COLORS.HeirloomElegant

DEFAULT_SKIN_COLOR = SKIN_RARITY_COLORS["Common"]

SKIN_DEBUGGING = false

local SKIN_AFFINITY_INFO = require("skin_affinity_info")

EVENT_ICONS =
{
	event_forge = {"LAVA"},
	event_ice = {"ICE", "WINTER"},
	event_yotv = {"VARG"},
	event_quagmire = {"VICTORIAN"},
	event_hallowed = {"HALLOWED"},
	event_yule = {"YULE"}
}

local function GetSpecialItemCategories()
	-- We build this in a function because these symbols don't exist when this
	-- file is first loaded.
	return
	{
		MISC_ITEMS,
		CLOTHING,
		EMOTE_ITEMS,
		EMOJI_ITEMS,
		BEEFALO_CLOTHING,
	}
end
local function GetAllItemCategories()
	return { Prefabs, unpack(GetSpecialItemCategories()) }
end

-- for use in sort functions
-- return true if rarity1 should go first in the list
RARITY_ORDER =
{
	ProofOfPurchase = 1,
	Timeless = 2,
	Loyal = 3,
	Reward = 4,
	Event = 5,
	Character = 6,
	HeirloomElegant = 7,
	HeirloomDistinguished = 8,
	HeirloomSpiffy = 9,
	HeirloomClassy = 10,
	Elegant = 11,
	Distinguished = 12,
	Spiffy = 13,
	Classy = 14,
	Common = 15,
	Complimentary = 16
}

function CompareReleaseGroup(item_key_a, item_key_b)
    local release_group_a = GetReleaseGroup(item_key_a)
    local release_group_b = GetReleaseGroup(item_key_b)
	return release_group_a > release_group_b
end

function CompareRarities(item_key_a, item_key_b)
	local rarity1 = GetRarityForItem(item_key_a)
	local rarity2 = GetRarityForItem(item_key_b)

	return RARITY_ORDER[rarity1] < RARITY_ORDER[rarity2]
end

function GetNextRarity(rarity)
	--just used by the tradescreen
	local rarities = {Common = "Classy",
					  Classy = "Spiffy",
					  Spiffy = "Distinguished",
					  Distinguished = "Elegant",
					 }

	return rarities[rarity] or ""
end

function IsHeirloomRarity( rarity )
	if rarity == "HeirloomElegant" or rarity == "HeirloomDistinguished" or rarity == "HeirloomSpiffy" or rarity == "HeirloomClassy" then
		return true
	end
	return false
end


function GetFrameSymbolForRarity( rarity )
	if IsHeirloomRarity(rarity) then
		return "heirloom"
	end
	if rarity == "Complimentary" then
		return "common"
	end
	return string.lower( rarity )
end


function GetBuildForItem(name)
	local skin_data = GetSkinData(name)
	if skin_data.build_name_override ~= nil then
		return skin_data.build_name_override
	end

	return name
end

-- Get the bigportrait UIAnim assets loaded by the prefab. Many prefabs don't have this info (only necessary to animate a bigportrait like when you get one in a mysterybox).
function GetBigPortraitAnimForItem(item_key)
	if Prefabs[item_key] ~= nil then
		if Prefabs[item_key].share_bigportrait_name ~= nil then
			return GetBigPortraitAnimForItem(Prefabs[item_key].share_bigportrait_name)
		else
			return Prefabs[item_key].bigportrait_anim
		end
	end

	return nil
end

function GetPortraitNameForItem(item_key)
	if IsDefaultCharacterSkin(item_key) then
		return item_key
	else
		local skin_data = GetSkinData(item_key)
		return skin_data.share_bigportrait_name or GetBuildForItem(item_key)
	end
end


function GetPackCollection(item_key)
	local output_items = GetPurchasePackOutputItems(item_key)
	local collection = nil
    for _,item in pairs(output_items) do
        local data = GetSkinData(item)
        for _,skin_tag in pairs(data.skin_tags) do
            if STRINGS.SKIN_TAG_CATEGORIES.COLLECTION[skin_tag] ~= nil then
				if collection == nil then
					collection = STRINGS.SKIN_TAG_CATEGORIES.COLLECTION[skin_tag]
				end
				if collection ~= STRINGS.SKIN_TAG_CATEGORIES.COLLECTION[skin_tag] then
					return nil --if there's more than one collection, return none
				end
            end
        end
	end
	return collection
end

function GetPackTotalItems(item_key)
    local output_items = GetPurchasePackOutputItems(item_key)
    return #output_items
end

function _IsPackInsideOther( pack_a, pack_b )
	local a_items = GetPurchasePackOutputItems(pack_a)
	local b_items = GetPurchasePackOutputItems(pack_b)

	for _,item in ipairs( a_items ) do
		if not table.contains( b_items, item ) then
			return false
		end
	end
	return true
end

function GetFeaturedPacks()

	local iap_defs = TheItems:GetIAPDefs()
	local highest_group = 0

	local iaps = {}

	for _,iap in ipairs(iap_defs) do
		local item_type = iap.item_type

		if IsPackFeatured(item_type) then
			if highest_group == 0 then
				highest_group = GetReleaseGroup(item_type)
				table.insert(iaps, item_type)
			else

				local group = GetReleaseGroup(item_type)
				if group >= highest_group then
					if group > highest_group then
						iaps = {}
					end

					highest_group = group
					table.insert(iaps, item_type)
				end
			end
		end
	end

	return iaps
end

local memoized_sub_packs = {}
function _GetSubPacks(item_key)
	if memoized_sub_packs[item_key] then
		return memoized_sub_packs[item_key]
	end

    local sub_packs = {}
	local output_items = GetPurchasePackOutputItems(item_key)
	local pack_count = #output_items

	--Build a table of items to their pack, use the smallest pack size to indicate which pack an item belongs to
	--If this is too slow, we could cache it in the pipeline, or on download of the iap
	local item_to_packinfo = {}
	local iap_defs = TheItems:GetIAPDefs()
	for _,iap in ipairs(iap_defs) do
		local iap_output_items = GetPurchasePackOutputItems(iap.item_type)
		local pack_count = #iap_output_items
		for _,item in ipairs(iap_output_items) do
			if item_to_packinfo[item] == nil then
				item_to_packinfo[item] = { pack = iap.item_type, pack_count = pack_count }
			else
				if item_to_packinfo[item].pack_count > #iap_output_items then
					item_to_packinfo[item].pack = iap.item_type
					item_to_packinfo[item].pack_count = pack_count
				end
			end
		end
	end

	for _,item in pairs(output_items) do
		if item_to_packinfo[item].pack ~= item_key then
			sub_packs[item_to_packinfo[item].pack] = true
		end
	end

	--Ugh, packs such as pack_character_wormwood, which have a unique item, plus one other, have one sub pack, which makes us think it's a bundle, but it's not really...
	if GetTableSize(sub_packs) == 1 then
		sub_packs = {}
	end

	--Now coalesce sub packs into the the largest sub packs to avoid overlap
	for sub_pack_a,_ in pairs( sub_packs ) do
		for sub_pack_b,_ in pairs( sub_packs ) do
			if sub_pack_a ~= sub_pack_b then
				if _IsPackInsideOther( sub_pack_a, sub_pack_b ) then
					sub_packs[sub_pack_a] = nil
					break
				end
			end
		end
	end
	
	memoized_sub_packs[item_key] = sub_packs

	return sub_packs
end

function IsItemInAnyPack(item_key)
	local iap_defs = TheItems:GetIAPDefs()
	for _,iap in ipairs(iap_defs) do
		local output_items = GetPurchasePackOutputItems(iap.item_type)
		for _,pack_item in pairs(output_items) do
			if pack_item == item_key then
				return true
			end
		end
	end
	return false
end


function GetPackTotalSets(item_key)
	if item_key == "pack_starter_2019" then --don't show invalid skin sets because Wurt conufuses it
		return 0
	end

    local sub_packs = _GetSubPacks(item_key)

    local count = 0
    for pack,_ in pairs(sub_packs) do
        count = count + 1
    end
    return count
end

local memoized_is_a_bundle = {}
function IsPackABundle(item_key)	
	if memoized_is_a_bundle[item_key] then
		local value = memoized_is_a_bundle[item_key]
		return (value > 0), value
	end

    local sub_packs = _GetSubPacks(item_key)
    local value = 0

	local iap_defs = TheItems:GetIAPDefs()
	for _,iap in pairs(iap_defs) do
		if sub_packs[iap.item_type] then
			if iap.virtual_currency_cost ~= nil then
				value = value + iap.virtual_currency_cost
			elseif IsSteam() then
				value = value + iap.cents
			elseif IsRail() then
				value = value + tonumber(iap.rail_price)
			else
				print("Error!!! Figure out iap for this platform.")
			end
		end
	end
	
	memoized_is_a_bundle[item_key] = value
    return (value > 0), value
end

function GetPriceFromIAPDef( iap_def, sale_active )
	if iap_def.iap_type == IAP_TYPE_VIRTUAL then
		if sale_active then
			return iap_def.virtual_currency_sale_cost
		else
			return iap_def.virtual_currency_cost
		end
	elseif IsSteam() then
		if sale_active then
			return iap_def.sale_cents
		else
			return iap_def.cents
		end
	elseif IsRail() then
		if sale_active then
			return iap_def.rail_sale_price
		else
			return iap_def.rail_price
		end
	end
end

function BuildPriceStr( value, iap_def, sale_active )
	if type(value) ~= "number" then
		value = GetPriceFromIAPDef( value, sale_active )
	end

	if iap_def.iap_type == IAP_TYPE_VIRTUAL then
		return string.format( "%0.0f %s", value, STRINGS.UI.PURCHASEPACKSCREEN.VIRTUAL_CURRENCY_SHORT )
	elseif IsSteam() then
		local currency_code = iap_def.currency_code
		if currency_code == "JPY" or
			currency_code == "IDR" or
			currency_code == "VND" or
			currency_code == "KRW" or
			currency_code == "UAH" or
			currency_code == "CNY" or
			currency_code == "INR" or
			currency_code == "CLP" or
			currency_code == "COP" or
			currency_code == "TWD" or
			currency_code == "KZT" or
			currency_code == "CRC" or
			currency_code == "UYU" then

			return string.format( "%s %0.0f", currency_code, value / 100 )
		else

			return string.format( "%s %1.2f", currency_code, value / 100 )
		end
	elseif IsRail() then
		return tostring(value) .. " RMB"
	else
		print("Error!!! Figure out the pricing for the new platform.")
	end
end

function IsSaleActive( iap_def )
	local sale_active = false

	local sale_duration = iap_def.sale_end - os.time()
	if sale_duration > 0 and iap_def.sale_percent > 0 then
		sale_active = true
	end

	return sale_active, sale_duration
end

function GetPackSavings(iap_def, total_value, sale_active )
    if IsSteam() then
        return math.floor(100 * (1 - (GetPriceFromIAPDef(iap_def, sale_active) / total_value)))
    elseif IsRail() then
        return math.floor(100 * (1 - (tonumber(GetPriceFromIAPDef(iap_def, sale_active)) / total_value)))
    else
        print("Error!!! Figure out iap for this platform.")
    end
end

function IsPackClothingOnly(item_key)
	local output_items = GetPurchasePackOutputItems(item_key)

	for _,item in pairs(output_items) do
		local item_data = GetSkinData(item)

		if item_data.type ~= "base" and
		item_data.type ~= "body" and
		item_data.type ~= "hand" and
		item_data.type ~= "legs" and
		item_data.type ~= "feet" then
			return false
		end
	end

	return true
end

function IsPackBelongingsOnly(item_key)
	local output_items = GetPurchasePackOutputItems(item_key)

	for _,item in pairs(output_items) do
		local item_data = GetSkinData(item)

		if item_data.type ~= "item" then
			return false
		end
	end

	return true
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

function GetReleaseGroup(item_key)
    local data = GetSkinData(item_key)
    return data.release_group or 999
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

function OwnsSkinPack(item_key)
	if IsPurchasePackCurrency(item_key) then
		return false
	end
	for _,v in pairs(GetPurchasePackOutputItems(item_key)) do
		if not TheInventory:CheckOwnership(v) then
			return false
		end
	end

	return true
end

function IsPurchasePackCurrency(item_key)
	if MISC_ITEMS[item_key] and MISC_ITEMS[item_key].output_klei_currency_cost then
		return true
	else
		return false
	end
end

function GetPurchasePackCurrencyOutput(item_key)
    return MISC_ITEMS[item_key] and MISC_ITEMS[item_key].output_klei_currency_cost or nil
end

function GetPurchasePackDisplayItems(item_key)
    return MISC_ITEMS[item_key] and MISC_ITEMS[item_key].display_items or {}
end

function GetPurchasePackOutputItems(item_key)
    return MISC_ITEMS[item_key] and MISC_ITEMS[item_key].output_items or {}
end


function DoesPackHaveBelongings(pack_key)
    local output_items = GetPurchasePackOutputItems(pack_key)
    for _,output_item in pairs(output_items) do
        if GetTypeForItem(output_item) == "item" then
            return true
        end
    end
    return false
end

function DoesPackHaveItem(pack_key, item_key)
    local output_items = GetPurchasePackOutputItems(pack_key)
    for _,output_item in pairs(output_items) do
        if item_key == output_item then
            return true
        end
    end
    return false
end

function DoesPackHaveACharacter(pack_key)
    local output_items = GetPurchasePackOutputItems(pack_key)
	for _,output_item in pairs(output_items) do
		if IsDefaultCharacterSkin( output_item ) then
            return true
        end
    end
    return false
end

function DoesPackHaveSkinsForCharacter(pack_key, character)
    local output_items = GetPurchasePackOutputItems(pack_key)
    for _,output_item in pairs(output_items) do
        if table.contains(SKIN_AFFINITY_INFO[character], output_item) then
            return true
        end
    end
    return false
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
	for k,tags in pairs(EVENT_ICONS) do
	    for _,tag in pairs(tags) do
		    if DoesItemHaveTag( item, tag ) then
			    return k
		    end
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
			granted_skin_data = GetSkinData(skin_data.granted_items[2])
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

function IsUserCommerceAllowedOnItemData(item_data)
    if item_data.is_dlc_owned and item_data.owned_count == 1 then
        return false
    end
    return IsUserCommerceAllowedOnItemType(item_data.item_key)
end

function IsUserCommerceAllowedOnItemType(item_key)
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

function GetCharacterRequiredForItem(item_type)
	local data = GetSkinData(item_type)
	if not data.is_restricted and data.type == "base" then --ignore is_restricted as they'd block themselves from being weaved, ooops :)
		return data.base_prefab
	end
	print("Unexpected item_type passed to GetCharacterRequiredForItem", item_type)
end

function IsUserCommerceBuyRestrictedDueType(item_type)
	local data = GetSkinData(item_type)
	if data.rarity_modifier == nil then
		return true
	end
	return false
end

function IsUserCommerceBuyRestrictedDueToOwnership(item_type)
	local data = GetSkinData(item_type)
	if not data.is_restricted and data.type == "base" then --ignore is_restricted as they'd block themselves from being weaved, ooops :)
		if not IsCharacterOwned(data.base_prefab) then
			return true
		end
	end
	return false
end

function IsPackRestrictedDueToOwnership(item_type)
	local pack_includes_character = {}
	for _,v in pairs(GetPurchasePackOutputItems(item_type)) do
		local data = GetSkinData(v)
		if data.is_restricted then
			pack_includes_character[data.base_prefab] = true
		end
	end
	for _,v in pairs(GetPurchasePackOutputItems(item_type)) do
		local data = GetSkinData(v)
		if data.type == "base" and pack_includes_character[data.base_prefab] == nil and not IsCharacterOwned(data.base_prefab) then
			local pack_data = GetSkinData(item_type)
			if pack_data.warning_only_on_restricted then
				return "warning", data.base_prefab
			else
				return "error", data.base_prefab
			end
		end
	end
	return ""
end

function IsUserCommerceBuyAllowedOnItem(item_type)
	if IsUserCommerceBuyRestrictedDueToOwnership(item_type) then
		return false
	end

    local num_owned = TheInventory:GetOwnedItemCountForCommerce(item_type)
	return num_owned == 0 and TheItems:GetBarterBuyPrice(item_type) ~= 0
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


function DoesItemHaveTag(item, tag)
	local tags = nil
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

	if tags ~= nil then
		for _,item_tag in pairs(tags) do
			if item_tag == tag then
				return true
			end
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

local function _ItemStringRedirect(item)
    if string.sub( item, -8 ) == "_builder" then
		item = string.sub( item, 1, -9 )
	end
    if string.sub( item, -8) == "default1" then
        item = "none"
    end
    return item
end
function GetSkinName(item)
	if SKIN_DEBUGGING then
		return item
	else
		return STRINGS.SKIN_NAMES[_ItemStringRedirect(item)] or STRINGS.SKIN_NAMES["missing"]
	end
end

function GetSkinDescription(item)
    item = _ItemStringRedirect(item)
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
    return GetSkinName(item_key)..item_key
end

-- Compare two keys from an item table for sorting purposes. Requires the item table they come from (i.e., MISC_ITEMS) since that data is not always contained within items.
--
-- Useful for showing all extant items (no duplicates).
function CompareItemDataForSortByRelease(item_key_a, item_key_b)
    if item_key_a == item_key_b then
        return false
    elseif IsDefaultSkin(item_key_a) and not IsDefaultSkin(item_key_b) then
        return true
    elseif not IsDefaultSkin(item_key_a) and IsDefaultSkin(item_key_b) then
        return false
    elseif GetReleaseGroup(item_key_a) ~= GetReleaseGroup(item_key_b) then
        return CompareReleaseGroup(item_key_a, item_key_b)
    elseif GetRarityForItem(item_key_a) ~= GetRarityForItem(item_key_b) then
		return CompareRarities(item_key_a, item_key_b)
	else
        return GetLexicalSortLiteral(item_key_a) < GetLexicalSortLiteral(item_key_b)
    end
end

function CompareItemDataForSortByName(item_key_a, item_key_b)
    if item_key_a == item_key_b then
        return false
    elseif IsDefaultSkin(item_key_a) and not IsDefaultSkin(item_key_b) then
        return true
    elseif not IsDefaultSkin(item_key_a) and IsDefaultSkin(item_key_b) then
        return false
    else
        return GetLexicalSortLiteral(item_key_a) < GetLexicalSortLiteral(item_key_b)
    end
end

function CompareItemDataForSortByRarity(item_key_a, item_key_b)
    if item_key_a == item_key_b then
        return false
    elseif IsDefaultSkin(item_key_a) and not IsDefaultSkin(item_key_b) then
        return true
    elseif not IsDefaultSkin(item_key_a) and IsDefaultSkin(item_key_b) then
        return false
    elseif GetRarityForItem(item_key_a) ~= GetRarityForItem(item_key_b) then
		return CompareRarities(item_key_a, item_key_b)
	else
        return GetLexicalSortLiteral(item_key_a) < GetLexicalSortLiteral(item_key_b)
    end
end

function CompareItemDataForSortByCount(item_key_a, item_key_b, item_counts)
	local count_a = item_counts[item_key_a] or 0
	local count_b = item_counts[item_key_b] or 0

	if item_key_a == item_key_b then
        return false
    elseif IsDefaultSkin(item_key_a) and not IsDefaultSkin(item_key_b) then
        return true
    elseif not IsDefaultSkin(item_key_a) and IsDefaultSkin(item_key_b) then
        return false
    elseif count_a ~= count_b then
		return count_a >= count_b
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
function GetInventorySkinsList( do_sort )

    local skins_list = {}

	local templist = TheInventory:GetFullInventory()
    for _,v in ipairs(templist) do
		local type, item = GetTypeForItem(v.item_type)
		local rarity = GetRarityForItem(item)

		local data = {}
		data.type = type
		data.item = item
		data.rarity = rarity
		data.timestamp = v.modified_time
		data.item_id = v.item_id

		table.insert(skins_list, data)
	end

	if do_sort then
		table.sort(skins_list, function(a,b)
			return CompareItemDataForSortByRarity( a.item, b.item )
		end)
	end

    return skins_list
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

function WillUnravelBreakRestrictedCharacter(item_type)
	local item_counts = GetOwnedItemCounts()
    if item_counts[item_type] == 1 and IsDefaultCharacterSkin( item_type ) then
		local data = GetSkinData( item_type )
		if data.is_restricted then
			return true
		end
	end
	return false
end

function HasHeirloomItem(herocharacter)
	for _,item_key in ipairs(SKIN_AFFINITY_INFO[herocharacter] or {}) do
		local rarity = GetRarityForItem(item_key)
		if IsHeirloomRarity(rarity) then
			return true
		end
	end
	return false
end

function GetSkinCollectionCompletionForHero(herocharacter)
	assert(herocharacter)
	--we'll use the shared build name instead of the item_key
	local bonus = HasHeirloomItem(herocharacter)
	local owned_items = {}
	local need_items = {}

    for i,item_key in ipairs(SKIN_AFFINITY_INFO[herocharacter] or {}) do
		if ShouldDisplayItemInCollection(item_key) then
			local build = GetBuildForItem(item_key)
			if TheInventory:CheckOwnership(item_key) then
				owned_items[build] = true
				need_items[build] = nil
			else
				bonus = false
				if owned_items[build] == nil then
					need_items[build] = true
				end
			end
		end
	end

    return GetTableSize(owned_items), GetTableSize(need_items), bonus
end

function GetNullFilter()
    local function NullFilter(item_key)
        return true
    end
    return NullFilter
end

function GetAffinityFilterForHero(herocharacter)
    local function AffinityFilter(item_key)
        if IsDefaultSkin(item_key) then
            return true
        end

        return table.contains(SKIN_AFFINITY_INFO[herocharacter], item_key)
    end
    return AffinityFilter
end

function GetLockedSkinFilter()
    local function LockedFilter(item_key)
        return IsDefaultSkin(item_key) or TheInventory:CheckOwnership(item_key)
    end
    return LockedFilter
end

function GetWeaveableSkinFilter()
    local function WeaveableFilter(item_key)
        return TheItems:GetBarterBuyPrice(item_key) ~= 0
    end
    return WeaveableFilter
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

function IsRestrictedCharacter( prefab )
	local data = GetSkinData(prefab.."_none")
	return data.is_restricted
end

function IsCharacterOwned( prefab )
	return IsDefaultSkinOwned(prefab.."_none")
end

function IsDefaultSkinOwned( item_key )
    if IsDefaultCharacterSkin( item_key ) then
		local data = GetSkinData(item_key)
		if data.is_restricted then
            return TheInventory:CheckOwnership(item_key)
        end
        return true
    end
    return IsDefaultClothing( item_key ) or IsDefaultBeefClothing( item_key ) or IsDefaultMisc( item_key ) --all default clothing is owned.
end

function IsDefaultSkin( item_key )
    return IsDefaultClothing( item_key ) or IsDefaultBeefClothing( item_key ) or IsDefaultCharacterSkin( item_key )
end

function IsPrefabSkinned( prefab )
	return PREFAB_SKINS[prefab] ~= nil
end

function IsDefaultCharacterSkin( item_key )
    return string.sub( item_key, -5 ) == "_none"
end

function IsDefaultClothing( item_key )
    return item_key ~= nil and item_key ~= "" and CLOTHING[item_key] ~= nil and CLOTHING[item_key].is_default
end

function IsDefaultBeefClothing( item_key )
    return item_key ~= nil and item_key ~= "" and BEEFALO_CLOTHING[item_key] ~= nil and BEEFALO_CLOTHING[item_key].is_default
end

function IsDefaultMisc( item_key )
    return item_key ~= nil and item_key ~= "" and MISC_ITEMS[item_key] ~= nil and MISC_ITEMS[item_key].is_default
end

-- Returns a table similar to MISC_ITEMS, but with character heads (skin bases).
function GetCharacterSkinBases(hero)
    local matches = {}
    local skins = PREFAB_SKINS[hero]
    if skins ~= nil then
        for i,item_key in ipairs(skins) do
            if not IsGameplayItem(item_key) then
                matches[item_key] = Prefabs[item_key]
            end
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

function IsValidClothing( name )
	return name ~= nil and name ~= "" and CLOTHING[name] ~= nil and not CLOTHING[name].is_default
end

function IsValidBeefaloClothing( name )
	return name ~= nil and name ~= "" and BEEFALO_CLOTHING[name] ~= nil and not BEEFALO_CLOTHING[name].is_default
end

function ValidatePreviewItems(currentcharacter, preview_skins, filter)
    for key,item_key in pairs(preview_skins) do
        if key ~= "base" and not IsValidClothing(preview_skins[key]) and not IsValidBeefaloClothing(preview_skins[key]) then
            preview_skins[key] = nil
        end
    end
end

function ValidateItemsLocal(currentcharacter, selected_skins)
    for key,item_key in pairs(selected_skins) do
        if not TheInventory:CheckOwnership(selected_skins[key])
            or (key ~= "base" and not IsValidClothing(selected_skins[key]))  and not IsValidBeefaloClothing(selected_skins[key])
            then
            selected_skins[key] = nil
        end
    end
    --[[if not selected_skins.base
        or selected_skins.base == currentcharacter
        or selected_skins.base == ""
        then
        selected_skins.base = currentcharacter.."_none"
    end]]
end

function ValidateItemsInProfile(user_profile)
    if TheInventory:HasDownloadedInventory() then
        -- We know whether they own something.
        for i,item_type in ipairs(user_profile:GetStoredCustomizationItemTypes()) do
            for item_key,is_active in pairs(user_profile:GetCustomizationItemsForType(item_type)) do
                if not TheInventory:CheckOwnership(item_key) then
                    -- A user who sells/trades an item on the marketplace needs to have it locally revoked.
                    user_profile:SetCustomizationItemState(item_type, item_key, false)
                end
            end
        end
    end
end

-- We must cache vanity items before they can be used (caching pushes to c-code which pushes to server).
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
    for _,item_key in ipairs(active_cosmetics) do
        if GetTypeForItem(item_key) == item_type then
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

function GetNextOwnedSkin(prefab, cur_skin)
	local new_skin = nil
	local skin_list = PREFAB_SKINS[prefab]
	if skin_list ~= nil then
		local found = 0
		if cur_skin ~= nil then
			for i = 1, #skin_list do
				if skin_list[i] == cur_skin then
					found = i
					break
				end
			end
		end
		for i = found + 1, #skin_list do
			if TheInventory:CheckOwnership(skin_list[i]) then
				new_skin = skin_list[i]
				break
			end
		end
	end
	return new_skin
end

function GetPrevOwnedSkin(prefab, cur_skin)
	local new_skin = nil
	local skin_list = PREFAB_SKINS[prefab]
	if skin_list ~= nil then
		local found = #skin_list + 1
		if cur_skin ~= nil then
			for i = #skin_list, 1, -1 do
				if skin_list[i] == cur_skin then
					found = i
					break
				end
			end
		end
		for i = found - 1, 1, -1 do
			if TheInventory:CheckOwnership(skin_list[i]) then
				new_skin = skin_list[i]
				break
			end
		end
	end
	return new_skin
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
function GetLoaderAtlasAndTex(item_key)
    local atlas, tex = GetOneAtlasPerImage_tex(LOADER_ATLAS_FMT, item_key)
    if softresolvefilepath(atlas) then
        return atlas, tex
    else
        -- The selected loader doesn't exist! Use a simple spiral instead of crashing.
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




--Dail Gift Bonus
local dailyGiftType = nil --to test daily gift popup, put a item type into this string
function SetDailyGiftItem(item_type)
	dailyGiftType = item_type
end
function IsDailyGiftItemPending()
	return dailyGiftType ~= nil
end
function GetDailyGiftItem()
	local ret = dailyGiftType
	dailyGiftType = nil
	return ret
end




function IsSkinDLCEntitlementReceived(entitlement)
	return Profile:IsEntitlementReceived(entitlement)
end
function SetSkinDLCEntitlementReceived(entitlement)
	Profile:SetEntitlementReceived(entitlement)
end


local newSkinDLCEntitlements = {} --to test DLC gifting popup, put a pack item type in this table
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
        local display_items = GetPurchasePackDisplayItems(pack_type)
        if display_items ~= nil then
		    local options = {
			    allow_cancel = false,
			    box_build = GetBoxBuildForItem(pack_type),
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
			    local box_popup = ItemBoxOpenerPopup(options, function(success_cb) success_cb(display_items) end, function() MakeSkinDLCPopup(_cb) end)
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


function DisplayCharacterUnownedPopup(character, skins_subscreener)
	local PopupDialogScreen = require "screens/redux/popupdialog"
	local body_str = subfmt(STRINGS.UI.LOBBYSCREEN.UNOWNED_CHARACTER_BODY, {character = STRINGS.CHARACTER_NAMES[character] })
    local unowned_popup = PopupDialogScreen(STRINGS.UI.LOBBYSCREEN.UNOWNED_CHARACTER_TITLE, body_str,
    {
        --Note(Peter): this is atrocious, but I don't see a better way to talk to the screen panel way down. Maybe implement a UI event system?
        {text=STRINGS.UI.BARTERSCREEN.COMMERCE_BUY, cb = function()
            TheFrontEnd:PopScreen()
            skins_subscreener.sub_screens["base"].picker:DoCommerceForDefaultItem(character.."_none")
        end},
        {text=STRINGS.UI.LOBBYSCREEN.VISIT_SHOP, cb = function()
            TheFrontEnd:PopScreen()
            skins_subscreener.sub_screens["base"].picker:DoShopForDefaultItem(character.."_none")
        end},
        {text=STRINGS.UI.POPUPDIALOG.OK, cb = function()
            TheFrontEnd:PopScreen()
        end},
    })
    TheFrontEnd:PushScreen(unowned_popup)
end

function DisplayInventoryFailedPopup( screen )
	if not screen.leave_from_fail and not TheInventory:HasDownloadedInventory() then
		local PopupDialogScreen = require "screens/redux/popupdialog"
		local GenericWaitingPopup = require "screens/redux/genericwaitingpopup"

		local unowned_popup = PopupDialogScreen(STRINGS.UI.PLAYERSUMMARYSCREEN.FAILED_INVENTORY_TITLE, STRINGS.UI.PLAYERSUMMARYSCREEN.FAILED_INVENTORY_BODY,
		{
			{text=STRINGS.UI.PLAYERSUMMARYSCREEN.FAILED_INVENTORY_YES, cb = function()

                screen.leave_from_fail = true
                TheFrontEnd:PopScreen() --pop the failed dialog

                screen.items_get_popup = GenericWaitingPopup("GetAllItemsPopup", STRINGS.UI.PLAYERSUMMARYSCREEN.GET_INVENTORY, nil, true, function()
                    screen.poll_task:Cancel()
                    screen.poll_task = nil
                end )
                TheFrontEnd:PushScreen(screen.items_get_popup)

                screen.poll_task = scheduler:ExecutePeriodic( 1, function()
                    if not TheInventory:IsDownloadingInventory() then
                        screen.items_get_popup:Close()
                    end
                end, nil, 0, "poll_inv_state", screen )

                TheInventory:StartGetAllItems()

                screen.leave_from_fail = false

			end},
			{text=STRINGS.UI.PLAYERSUMMARYSCREEN.FAILED_INVENTORY_NO, cb = function()

                screen.leave_from_fail = true
                TheFrontEnd:PopScreen()
				screen:Close()

			end},
		})
		TheFrontEnd:PushScreen(unowned_popup)
    end
end

local ghost_preview_y_offset = -25
local ghost_preview_scale = 0.75
local skintypesbycharacter = nil

function GetSkinModes(character)
	if skintypesbycharacter == nil then
		skintypesbycharacter = {
			woodie = {
				{ type = "normal_skin", play_emotes = true },								{ type = "ghost_skin", anim_bank = "ghost", idle_anim = "idle", scale = ghost_preview_scale, offset = { 0, ghost_preview_y_offset } },
				{ type = "werebeaver_skin", anim_bank = "werebeaver", scale = 0.82 },		{ type = "ghost_werebeaver_skin", anim_bank = "ghost", idle_anim = "idle", scale = ghost_preview_scale, offset = { 0, ghost_preview_y_offset } },
				{ type = "weregoose_skin",  anim_bank = "weregoose", scale = 0.82 },		{ type = "ghost_weregoose_skin", anim_bank = "ghost", idle_anim = "idle", scale = ghost_preview_scale, offset = { 0, ghost_preview_y_offset } },
				{ type = "weremoose_skin", anim_bank = "weremoose", scale = 0.82 },			{ type = "ghost_weremoose_skin", anim_bank = "ghost", idle_anim = "idle", scale = ghost_preview_scale, offset = { 0, ghost_preview_y_offset } }
			},

			wolfgang = {
				{ type = "normal_skin", play_emotes = true },
				{ type = "wimpy_skin", play_emotes = true , scale = 0.9 },
				{ type = "mighty_skin", play_emotes = true , scale = 1.25 },
				{ type = "ghost_skin", anim_bank = "ghost", idle_anim = "idle", scale = ghost_preview_scale, offset = { 0, ghost_preview_y_offset } }
			},

			wormwood = {
				{ type = "normal_skin", play_emotes = true },
				{ type = "stage_2", play_emotes = true },
				{ type = "stage_3", play_emotes = true },
				{ type = "stage_4", play_emotes = true },
				{ type = "ghost_skin", anim_bank = "ghost", idle_anim = "idle", scale = ghost_preview_scale, offset = { 0, ghost_preview_y_offset } }
			},

			wurt = {
				{ type = "normal_skin", play_emotes = true },
				{ type = "powerup", play_emotes = true },
				{ type = "ghost_skin", anim_bank = "ghost", idle_anim = "idle", scale = ghost_preview_scale, offset = { 0, ghost_preview_y_offset } }
			},

			wanda = {
				{ type = "normal_skin", play_emotes = true },
				{ type = "young_skin", play_emotes = true },
				{ type = "old_skin", play_emotes = true },
				{ type = "ghost_skin", anim_bank = "ghost", idle_anim = "idle", scale = ghost_preview_scale, offset = { 0, ghost_preview_y_offset } }
			},

			default = {
				{ type = "normal_skin", play_emotes = true },
				{ type = "ghost_skin", anim_bank = "ghost", idle_anim = "idle", scale = ghost_preview_scale, offset = { 0, ghost_preview_y_offset } }
			}
		}
	end
	return skintypesbycharacter[character] or skintypesbycharacter.default
end

function GetPlayerBadgeData(character, ghost, state_1, state_2, state_3 )
	if character == "wormwood" then
		if ghost then
			return "ghost", "idle", "ghost_skin", .15, -55
		else
			if state_1 then
				return "wilson", "idle_loop_ui", "stage_2", .23, -50
			elseif state_2 then
				return "wilson", "idle_loop_ui", "stage_3", .23, -50
			elseif state_3 then
				return "wilson", "idle_loop_ui", "stage_4", .23, -50
			else
				return "wilson", "idle_loop_ui", "normal_skin", .23, -50
			end
		end
	elseif character == "woodie" then
		if ghost then
			if state_1 then
				return "ghost", "idle", "ghost_werebeaver_skin", .15, -55
			elseif state_2 then
				return "ghost", "idle", "ghost_weremoose_skin", .15, -55
			elseif state_3 then
				return "ghost", "idle", "ghost_weregoose_skin", .15, -55
			else
				return "ghost", "idle", "ghost_skin", .15, -55
			end
		else
			if state_1 then
				return "werebeaver", "idle_loop", "werebeaver_skin", .15, -28
			elseif state_2 then
				return "weremoose", "idle_loop", "weremoose_skin", .11, -40
			elseif state_3 then
				return "weregoose", "idle_loop", "weregoose_skin", .17, -24
			else
				return "wilson", "idle_loop_ui", "normal_skin", .23, -50
			end
		end
	else
		if ghost then
			return "ghost", "idle", "ghost_skin", .15, -55
		else
			return "wilson", "idle_loop_ui", "normal_skin", .23, -50
		end
	end
end

function GetSkinModeFromBuild(player)
	--this relies on builds not being shared across states
	local build = player.AnimState:GetBuild()

	if PREFAB_SKINS[player.prefab] == nil then return nil end

	for _,skin in pairs(PREFAB_SKINS[player.prefab]) do
		local skindata = GetSkinData(skin)
		for skintype,skinbuild in pairs(skindata.skins) do
			if build == skinbuild then
				 return skintype
			end
		end
	end

	return nil
end


function GetBoxPopupLayoutDetails( num_item_types )
	local columns = 3
	local resize_root = nil
	local resize_root_small = nil
	local resize_root_small_higher = nil

	-- Decide how many columns there should be
	if num_item_types == 1 then
		columns = 1
	elseif num_item_types == 2 or num_item_types == 4 then
		columns = 2
	elseif num_item_types == 3 or num_item_types == 6 then
		columns = 3
	elseif num_item_types == 7 or num_item_types == 8 then
		columns = 4
	elseif num_item_types == 5 or num_item_types == 10 or num_item_types == 9 then
		columns = 5
	elseif num_item_types == 13 then
		columns = 5
		resize_root = true
	elseif num_item_types == 12 or num_item_types == 11 then
		columns = 6
	elseif num_item_types == 16 or num_item_types == 17 or num_item_types == 18 then
		columns = 6
		resize_root = true
	elseif num_item_types == 19 then
		columns = 7
		resize_root = true
	elseif num_item_types == 22 or num_item_types == 24 then
		columns = 8
		resize_root_small = true
	elseif num_item_types == 31 or num_item_types == 35 then
		columns = 9
		resize_root_small = true
	elseif num_item_types == 38 then
		columns = 10
		resize_root_small = true
	elseif num_item_types == 41 then
		columns = 10
		resize_root_small_higher = true
	else
		columns = 10
		resize_root_small_higher = true
		print("Warning: Found an unexpected number of items in a box.", num_item_types)
	end
	return columns, resize_root, resize_root_small, resize_root_small_higher
end