local USE_SETTINGS_FILE = PLATFORM ~= "PS4" and PLATFORM ~= "NACL"

local PlayerProfile = Class(function(self)
    self.persistdata =
    {
        -- TODO: Some of this data should be synced across computers
        -- so will need to be stored on a server somewhere
        -- (In particular, collection_name, character_skins, and most_recent_item_skins)
        unlocked_worldgen = {},
        render_quality = RENDER_QUALITY.DEFAULT,
        -- Controlls should be a seperate file
        controls = {},
        starts = 0,
        saw_display_adjustment_popup = false,
        device_caps_a = 0,
        device_caps_b = 20,
        customizationpresets = {},
        collection_name = nil,
        saw_new_user_popup = false,
        saw_new_host_picker = false,
        install_id = os.time(),
		play_instance = 0,
		favorite_mods = {},
        --characterskins = {} --legacy variable, don't use it.
    }

    --we should migrate the non-gameplay stuff to a separate file, so that we can save them whenever we want

    if not USE_SETTINGS_FILE then
        self.persistdata.volume_ambient = 7
        self.persistdata.volume_sfx = 7
        self.persistdata.volume_music = 7
		self.persistdata.volume_muteonfocuslost = false
        self.persistdata.HUDSize = 5
        self.persistdata.CraftingMenuSize = 5
        self.persistdata.CraftingMenuNumPinPages = 3
        self.persistdata.craftingmenusensitivity = 12
        self.persistdata.inventorysensitivity = 16
		self.persistdata.minimapzoomsensitivity = 15
        self.persistdata.boathopdelay = 8
        self.persistdata.screenflash = 1
        self.persistdata.vibration = true
        self.persistdata.showpassword = false
        self.persistdata.movementprediction = true
        self.persistdata.wathgrithrfont = true
		self.persistdata.InvertCameraRotation = false
        self.persistdata.screenshake = true
        self.persistdata.warneddifficultyrog = false
        self.persistdata.controller_popup = false
        self.persistdata.warn_mods_enabled = true
        self.persistdata.texture_streaming = true
		self.persistdata.threaded_renderer = true
		self.persistdata.bloom = true
		self.persistdata.distortion = true
		self.persistdata.distortion_modifier = 1
		self.persistdata.dynamic_tree_shadows = true
		self.persistdata.autopause = true
		self.persistdata.consoleautopause = true
		self.persistdata.loadingtips = 1
		self.persistdata.hide_pause_underlay = false
        self.persistdata.profanityfilter_chat = true
		self.persistdata.usezipfilefornormalsaves = false
		self.persistdata.defaultcloudsaves = false
		self.persistdata.scrapbookhuddisplay = true
    end

    self.dirty = true
end)

function PlayerProfile:Reset()
    self.persistdata.unlocked_worldgen = {}
    self.persistdata.saw_display_adjustment_popup = false
    self.persistdata.device_caps_a = 0
    self.persistdata.device_caps_b = 20
    self.persistdata.customizationpresets = {}
    self.persistdata.saw_new_user_popup = false
    self.persistdata.saw_new_host_picker = false
    self.persistdata.install_id = os.time()
	self.persistdata.play_instance = 0
	self.persistdata.favorite_mods = {}

    if not USE_SETTINGS_FILE then
        self.persistdata.volume_ambient = 7
        self.persistdata.volume_sfx = 7
        self.persistdata.volume_music = 7
		self.persistdata.volume_muteonfocuslost = false
        self.persistdata.HUDSize = 5
        self.persistdata.CraftingMenuSize = 5
        self.persistdata.CraftingMenuNumPinPages = 3
        self.persistdata.craftingmenusensitivity = 12
        self.persistdata.inventorysensitivity = 16
		self.persistdata.minimapzoomsensitivity = 15
        self.persistdata.boathopdelay = 8
        self.persistdata.screenflash = 1
        self.persistdata.vibration = true
        self.persistdata.showpassword = false
        self.persistdata.movementprediction = true
        self.persistdata.wathgrithrfont = true
		self.persistdata.InvertCameraRotation = false
        self.persistdata.screenshake = true
        self.persistdata.warneddifficultyrog = false
        self.persistdata.controller_popup = false
        self.persistdata.warn_mods_enabled = true
        self.persistdata.texture_streaming = true
		self.persistdata.threaded_renderer = true
		self.persistdata.bloom = true
		self.persistdata.distortion = true
		self.persistdata.distortion_modifier = 1
		self.persistdata.dynamic_tree_shadows = true
		self.persistdata.autopause = true
		self.persistdata.consoleautopause = true
		self.persistdata.loadingtips = 1
		self.persistdata.hide_pause_underlay = false
		self.persistdata.usezipfilefornormalsaves = false
		self.persistdata.defaultcloudsaves = true
		self.persistdata.scrapbookhuddisplay = true
    end

    --self.persistdata.starts = 0 -- save starts?
    self.dirty = true
    self:Save()
end

function PlayerProfile:SoftReset()
    self.persistdata.unlocked_worldgen = {}
    self.persistdata.saw_display_adjustment_popup = false
    self.persistdata.device_caps_a = 0
    self.persistdata.device_caps_b = 20
    self.persistdata.customizationpresets = {}
    self.persistdata.saw_new_user_popup = false
    self.persistdata.saw_new_host_picker = false
    self.persistdata.install_id = os.time()
	self.persistdata.play_instance = 0
	self.persistdata.favorite_mods = {}

    if not USE_SETTINGS_FILE then
        self.persistdata.volume_ambient = 7
        self.persistdata.volume_sfx = 7
        self.persistdata.volume_music = 7
		self.persistdata.volume_muteonfocuslost = false
        self.persistdata.HUDSize = 5
        self.persistdata.CraftingMenuSize = 5
        self.persistdata.CraftingMenuNumPinPages = 3
        self.persistdata.craftingmenusensitivity = 12
        self.persistdata.inventorysensitivity = 16
		self.persistdata.minimapzoomsensitivity = 15
        self.persistdata.boathopdelay = 8
        self.persistdata.screenflash = 1
        self.persistdata.vibration = true
        self.persistdata.showpassword = false
        self.persistdata.movementprediction = true
        self.persistdata.wathgrithrfont = true
		self.persistdata.InvertCameraRotation = false
        self.persistdata.screenshake = true
        self.persistdata.warneddifficultyrog = false
        self.persistdata.controller_popup = false
        self.persistdata.warn_mods_enabled = true
        self.persistdata.scrapbookhuddisplay = true
    end
    -- and apply these values
    local str = json.encode(self.persistdata)
    self:Set(str, nil)
end

function PlayerProfile:GetSkins()
	local owned_skins = {}

	for prefab, skins in pairs(PREFAB_SKINS) do
		local skins = self:GetSkinsForPrefab(prefab)
		owned_skins = JoinArrays(owned_skins, skins)
	end

	return owned_skins
end

function PlayerProfile:GetSkinsForPrefab(prefab)
	local owned_skins = {}
	table.insert(owned_skins, prefab.."_none") --everyone always has access to the nothing option

	local skins = PREFAB_SKINS[prefab]
	if skins ~= nil then
		for k,v in pairs(skins) do
			if TheInventory:CheckOwnership(v) then
				if v ~= "backpack_mushy" then
					table.insert(owned_skins, v)
				end
			end
		end
	end
	return owned_skins
end

function PlayerProfile:GetClothingOptionsForType(type)
	local owned_clothing = {}
	table.insert(owned_clothing, "") --everyone always has access to the nothing option

	for clothing_name,data in pairs(CLOTHING) do
		if data.type == type and TheInventory:CheckOwnership(clothing_name) then
			table.insert(owned_clothing, clothing_name)
		end
	end
	return owned_clothing
end

-- Store the player's last selection so we can preselecting the right character
-- for the player.
function PlayerProfile:GetLastSelectedCharacter()
    local character = self.persistdata.last_selected_character
    if not table.contains(DST_CHARACTERLIST, character) then
        character = DST_CHARACTERLIST[1]
	end

	if not IsCharacterOwned( character ) then
		character = "wilson"
	end

    return character
end

function PlayerProfile:SetLastSelectedCharacter(character)
    -- Only track official characters since we show this character a
    -- lot in the frontend.
    if table.contains(DST_CHARACTERLIST, character) then
        self.persistdata.last_selected_character = character
    end
end

function PlayerProfile:GetSkinPresetForCharacter(character, preset_index)
	if not self.persistdata.skin_presets then
		self.persistdata.skin_presets = {}
	end

	if not self.persistdata.skin_presets[character] then
        self.persistdata.skin_presets[character] = {}
	end

    --Do skins validation to ensure that the saved skins aren't available anymore
    --ValidateItemsLocal(character, self.persistdata.skin_presets[character][preset_index])

    -- Never return internal data to prevent accidental profile modification.
    -- Modify via Set functions.
	return shallowcopy(self.persistdata.skin_presets[character][preset_index]) or {}
end

function PlayerProfile:SetSkinPresetForCharacter(character, preset_index, skin_list)
	if not self.persistdata.skin_presets then
		self.persistdata.skin_presets = {}
	end

	if not self.persistdata.skin_presets[character] then
		self.persistdata.skin_presets[character] = {}
	end

	self.dirty = true
	self.persistdata.skin_presets[character][preset_index] = shallowcopy(skin_list)

	self:Save()
end

function PlayerProfile:GetSkinsForCharacter(character)
	if not self.persistdata.character_skins then
		self.persistdata.character_skins = {}
	end

	if not self.persistdata.character_skins[character] then
        if self.persistdata.characterskins ~= nil and self.persistdata.characterskins[character] ~= nil then
            print("Read back legacy skins data from profile for character", character)
		    self.persistdata.character_skins[character] = self.persistdata.characterskins[character][self.persistdata.characterskins[character].last_base]
            --strip out old "" legacy items
            if self.persistdata.character_skins[character] ~= nil then
                for k,v in pairs(self.persistdata.character_skins[character]) do
                    if v == "" then
                        self.persistdata.character_skins[character][k] = nil
                    end
                end
            else
                self.persistdata.character_skins[character] = { base = character.."_none" }
            end
        else
		    self.persistdata.character_skins[character] = { base = character.."_none" }
        end
	end

    --Do skins validation to ensure that the saved skins aren't available anymore
    ValidateItemsLocal(character, self.persistdata.character_skins[character])

    -- Never return internal data to prevent accidental profile modification.
    -- Modify via Set functions.
	return shallowcopy(self.persistdata.character_skins[character]) or {}
end

function PlayerProfile:SetSkinsForCharacter(character, skinList)
	if not self.persistdata.character_skins then
		self.persistdata.character_skins = {}
	end

	if not self.persistdata.character_skins[character] then
		self.persistdata.character_skins[character] = {}
	end

	self.dirty = true
	self.persistdata.character_skins[character] = shallowcopy(skinList)

	self:Save()
end

function PlayerProfile:SetCustomizationItemState(customization_type, item_key, is_active)
    assert(is_active ~= nil, "Always pass all arguments!")
	if not self.persistdata.customization_items then
		self.persistdata.customization_items = {}
	end

	if not self.persistdata.customization_items[customization_type] then
		self.persistdata.customization_items[customization_type] = {}
	end

	self.dirty = true
    if is_active then
        self.persistdata.customization_items[customization_type].last_item_key = item_key
    elseif self.persistdata.customization_items[customization_type].last_item_key == item_key then
        self.persistdata.customization_items[customization_type].last_item_key = nil
    end
	self.persistdata.customization_items[customization_type][item_key] = is_active or nil

	self:Save()
end

function PlayerProfile:GetCustomizationItemState(customization_type, item_key)
	if not self.persistdata.customization_items then
		return
	end

	if not self.persistdata.customization_items[customization_type] then
		return
	end

    return self.persistdata.customization_items[customization_type][item_key]
end

-- Table of all stored customization items for the type. Keys in returned table
-- match item_key passed to SetCustomizationItemState.
function PlayerProfile:GetCustomizationItemsForType(customization_type)
	if not self.persistdata.customization_items then
		return {}
	end

	if not self.persistdata.customization_items[customization_type] then
        return {}
    end

	local customization_item_keys = shallowcopy(self.persistdata.customization_items[customization_type])
    customization_item_keys.last_item_key = nil
	return customization_item_keys
end


-- Table of all stored customization types.
function PlayerProfile:GetStoredCustomizationItemTypes()
	if not self.persistdata.customization_items then
		return {}
	end

	return table.getkeys(self.persistdata.customization_items)
end


function PlayerProfile:SetItemSortMode(sort_mode)
    self.persistdata.item_explorer_sort_mode = sort_mode
	self:Save()
end

function PlayerProfile:GetItemSortMode()
    return self.persistdata.item_explorer_sort_mode
end

function PlayerProfile:SetServerSortMode(sort_mode)
    self.persistdata.save_explorer_sort_mode = sort_mode
	self:Save()
end

function PlayerProfile:GetServerSortMode()
    return self.persistdata.save_explorer_sort_mode
end

-- Filters that determine which customization items are displayed in the collection.
function PlayerProfile:SetCustomizationFilterState(customize_screen, customize_filter, filter_state)
	if not self.persistdata.customization_filters then
        self.persistdata.customization_filters = {}
    end

	if not self.persistdata.customization_filters[customize_screen] then
        self.persistdata.customization_filters[customize_screen] = {}
    end

	self.persistdata.customization_filters[customize_screen][customize_filter] = filter_state
end

function PlayerProfile:GetCustomizationFilterState(customize_screen, customize_filter)
	if not self.persistdata.customization_filters then
		return
	end

	if not self.persistdata.customization_filters[customize_screen] then
		return
	end

	return self.persistdata.customization_filters[customize_screen][customize_filter]
end


function PlayerProfile:SetCollectionTimestamp(time)
	self.persistdata.collection_timestamp = time

	self:Save()
end

function PlayerProfile:GetCollectionTimestamp()
	return self.persistdata.collection_timestamp or -10000
end

function PlayerProfile:SetShopHash(_hash)
	self.persistdata.purchase_screen_hash = _hash

	self:Save()
end

function PlayerProfile:GetShopHash()
	return self.persistdata.purchase_screen_hash or 0
end

function PlayerProfile:SetRecipeTimestamp(recipe, time)
	self.persistdata.recipe_timestamps = self.persistdata.recipe_timestamps or {}

	self.persistdata.recipe_timestamps[recipe] = time
	self:Save()
end

function PlayerProfile:GetRecipeTimestamp(recipe)
	if self.persistdata.recipe_timestamps then
		return self.persistdata.recipe_timestamps[recipe] or -10000
	else
		return -10000
	end
end

-- may return nil
function PlayerProfile:GetLastUsedSkinForItem(item)
	if not self.persistdata.most_recent_item_skins then
		self.persistdata.most_recent_item_skins = {}
	--else
		--print("Most recent item skins is ", self.persistdata.most_recent_item_skins)
	end

	local skin = self.persistdata.most_recent_item_skins[item]
	return skin
end

function PlayerProfile:SetLastUsedSkinForItem(item, skin)
	if not self.persistdata.most_recent_item_skins then
		self.persistdata.most_recent_item_skins = {}
	end

	self.persistdata.most_recent_item_skins[item] = skin

	self:Save()
end

function PlayerProfile:SetCollectionName(name)
	self.persistdata.collection_name = name

	self:Save()
end

function PlayerProfile:GetCollectionName()
	if self.persistdata.collection_name then
		return self.persistdata.collection_name
	end

	return nil
end

function PlayerProfile:SetModFavorited(modname, favorite)
	self.persistdata.favorite_mods[modname] = favorite or nil
end

function PlayerProfile:IsModFavorited(modname)
	return self.persistdata.favorite_mods[modname] or false
end

function PlayerProfile:SetValue(name, value)
    self.dirty = true
    self.persistdata[name] = value
end

function PlayerProfile:GetValue(name)
	return self.persistdata[name]
end

function PlayerProfile:SetVolume(ambient, sfx, music)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("audio", "volume_ambient", tostring(math.floor(ambient)))
		TheSim:SetSetting("audio", "volume_sfx", tostring(math.floor(sfx)))
		TheSim:SetSetting("audio", "volume_music", tostring(math.floor(music)))
	else
	    self:SetValue("volume_ambient", ambient)
	    self:SetValue("volume_sfx", sfx)
	    self:SetValue("volume_music", music)
	    self.dirty = true
	end
end

function PlayerProfile:SetMuteOnFocusLost(value)
	if USE_SETTINGS_FILE then
		TheSim:SetSetting("audio", "volume_muteonfocuslost", tostring(value))
	else
		self:SetValue("volume_muteonfocuslost", value)
		self.dirty = true
	end
end

function PlayerProfile:SetScreenFlash(value)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("graphics", "screenflash", tostring(value))
	else
		self:SetValue("screenflash", value)
		self.dirty = true
	end
end
function PlayerProfile:GetScreenFlash()
 	if USE_SETTINGS_FILE then
		return tonumber(TheSim:GetSetting("graphics", "screenflash") or 1)
	else
		return tonumber(self:GetValue("screenflash") or 1)
	end
end

function PlayerProfile:SetBloomEnabled(enabled)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("graphics", "bloom", tostring(enabled))
	else
		self:SetValue("bloom", enabled)
		self.dirty = true
	end
end

function PlayerProfile:GetBloomEnabled()
 	if USE_SETTINGS_FILE then
		return TheSim:GetSetting("graphics", "bloom") ~= "false"
	else
		return self:GetValue("bloom") ~= false
	end
end

function PlayerProfile:SetHUDSize(size)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("graphics", "HUDSize", tostring(size))
	else
		self:SetValue("HUDSize", size)
		self.dirty = true
	end
end

function PlayerProfile:GetHUDSize()
 	if USE_SETTINGS_FILE then
		return TheSim:GetSetting("graphics", "HUDSize") or 5
	else
		return self:GetValue("HUDSize") or 5
	end
end

function PlayerProfile:SetCraftingMenuSize(size)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("graphics", "CraftingMenuSize", tostring(size))
	else
		self:SetValue("CraftingMenuSize", size)
		self.dirty = true
	end
end

function PlayerProfile:GetCraftingMenuSize()
 	if USE_SETTINGS_FILE then
		return TheSim:GetSetting("graphics", "CraftingMenuSize") or 5
	else
		return self:GetValue("CraftingMenuSize") or 5
	end
end

function PlayerProfile:SetCraftingMenuNumPinPages(size)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("misc", "CraftingMenuNumPinPages", tostring(size))
	else
		self:SetValue("CraftingMenuNumPinPages", size)
		self.dirty = true
	end
end

function PlayerProfile:GetCraftingNumPinnedPages()
 	if USE_SETTINGS_FILE then
		return tonumber(TheSim:GetSetting("misc", "CraftingMenuNumPinPages") or 3)
	else
		return tonumber(self:GetValue("CraftingMenuNumPinPages") or 3)
	end
end

function PlayerProfile:GetScrapbookHudDisplay()
 	if USE_SETTINGS_FILE then
		return TheSim:GetSetting("misc", "scrapbookhuddisplay") ~= "false"
	else
		return self:GetValue("scrapbookhuddisplay") ~= false
	end
end

function PlayerProfile:SetScrapbookHudDisplay(enabled)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("misc", "scrapbookhuddisplay", tostring(enabled))
	else
		self:SetValue("scrapbookhuddisplay", enabled)
		self.dirty = true
	end
end

function PlayerProfile:GetPOIDisplay()
 	if USE_SETTINGS_FILE then
		return TheSim:GetSetting("misc", "poidisplay") ~= "false"
	else
		return self:GetValue("poidisplay") ~= false
	end
end

function PlayerProfile:SetPOIDisplay(enabled)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("misc", "poidisplay", tostring(enabled))
	else
		self:SetValue("poidisplay", enabled)
		self.dirty = true
	end
end

function PlayerProfile:GetScrapbookColumnsSetting()
	return tonumber(self:GetValue("scrapbookcolumnssetting") or 3)
end

function PlayerProfile:SetScrapbookColumnsSetting(setting)
	self:SetValue("scrapbookcolumnssetting", setting)
	self.dirty = true
	self:Save()
end

function PlayerProfile:SetCraftingMenuSensitivity(sensitivity)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("misc", "craftingmenusensitivity", tostring(sensitivity))
	else
		self:SetValue("craftingmenusensitivity", sensitivity)
		self.dirty = true
	end
end

function PlayerProfile:GetCraftingMenuSensitivity()
 	if USE_SETTINGS_FILE then
		return tonumber(TheSim:GetSetting("misc", "craftingmenusensitivity") or 12)
	else
		return tonumber(self:GetValue("craftingmenusensitivity") or 12)
	end
end

function PlayerProfile:SetInventorySensitivity(sensitivity)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("misc", "inventorysensitivity", tostring(sensitivity))
	else
		self:SetValue("inventorysensitivity", sensitivity)
		self.dirty = true
	end
end

function PlayerProfile:GetInventorySensitivity()
 	if USE_SETTINGS_FILE then
		return tonumber(TheSim:GetSetting("misc", "inventorysensitivity") or 16)
	else
		return tonumber(self:GetValue("inventorysensitivity") or 16)
	end
end

function PlayerProfile:SetMiniMapZoomSensitivity(sensitivity)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("misc", "minimapzoomsensitivity", tostring(sensitivity))
	else
		self:SetValue("minimapzoomsensitivity", sensitivity)
		self.dirty = true
	end
end

function PlayerProfile:GetMiniMapZoomSensitivity()
 	if USE_SETTINGS_FILE then
		return tonumber(TheSim:GetSetting("misc", "minimapzoomsensitivity") or 15)
	else
		return tonumber(self:GetValue("minimapzoomsensitivity") or 15)
	end
end

function PlayerProfile:GetBoatHopDelay()
 	if USE_SETTINGS_FILE then
		return tonumber(TheSim:GetSetting("misc", "boathopdelay") or 8)
	else
		return tonumber(self:GetValue("boathopdelay") or 8)
	end
end

function PlayerProfile:SetBoatHopDelay(delay)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("misc", "boathopdelay", tostring(delay))
	else
		self:SetValue("boathopdelay", delay)
		self.dirty = true
	end
    if ThePlayer then
        ThePlayer:SynchronizeOneClientAuthoritativeSetting(CLIENTAUTHORITATIVESETTINGS.PLATFORMHOPDELAY, Profile:GetBoatHopDelay())
    end
end

function PlayerProfile:SetDistortionEnabled(enabled)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("graphics", "distortion", tostring(enabled))
	else
		self:SetValue("distortion", enabled)
		self.dirty = true
	end
end

function PlayerProfile:GetDistortionEnabled()
 	if USE_SETTINGS_FILE then
		return TheSim:GetSetting("graphics", "distortion") ~= "false"
	else
		return self:GetValue("distortion") ~= false
	end
end

function PlayerProfile:SetDistortionModifier(modifier)
	if USE_SETTINGS_FILE then
	   TheSim:SetSetting("graphics", "distortion_modifier", tostring(modifier))
   else
	   self:SetValue("distortion_modifier", modifier)
	   self.dirty = true
   end
end

function PlayerProfile:GetDistortionModifier()
	if USE_SETTINGS_FILE then
	   return tonumber(TheSim:GetSetting("graphics", "distortion_modifier") or 0.75)
   else
	   return tonumber(self:GetValue("distortion_modifier") or 0.75)
   end
end

function PlayerProfile:SetScreenShakeEnabled(enabled)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("graphics", "screenshake", tostring(enabled))
	else
		self:SetValue("screenshake", enabled)
		self.dirty = true
	end
end

function PlayerProfile:IsScreenShakeEnabled()
 	if USE_SETTINGS_FILE then
 		if TheSim:GetSetting("graphics", "screenshake") ~= nil then
			return TheSim:GetSetting("graphics", "screenshake") == "true"
		else
			return true -- Default to true this value hasn't been created yet
		end
	else
		if self:GetValue("screenshake") ~= nil then
			return self:GetValue("screenshake")
		else
			return true -- Default to true this value hasn't been created yet
		end
	end
end

function PlayerProfile:SetWathgrithrFontEnabled(enabled)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("misc", "wathgrithrfont", tostring(enabled))
	else
		self:SetValue("wathgrithrfont", enabled)
		self.dirty = true
	end
end

function PlayerProfile:IsWathgrithrFontEnabled()
 	if USE_SETTINGS_FILE then
 		if TheSim:GetSetting("misc", "wathgrithrfont") ~= nil then
			return TheSim:GetSetting("misc", "wathgrithrfont") == "true"
		else
			return true -- Default to true this value hasn't been created yet
		end
	else
		if self:GetValue("wathgrithrfont") ~= nil then
			return self:GetValue("wathgrithrfont")
		else
			return true -- Default to true this value hasn't been created yet
		end
	end
end

function PlayerProfile:SetInvertCameraRotation(enabled) -- console only
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("misc", "InvertCameraRotation", tostring(enabled))
	else
		self:SetValue("InvertCameraRotation", enabled)
		self.dirty = true
	end
end

function PlayerProfile:GetInvertCameraRotation() -- console only
	-- default to false
    if USE_SETTINGS_FILE then
		return TheSim:GetSetting("misc", "InvertCameraRotation") == "true"
    else
		return self:GetValue("InvertCameraRotation") == true
    end
end

function PlayerProfile:SetBoatCameraEnabled(enabled)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("misc", "boatcamera", tostring(enabled))
	else
		self:SetValue("boatcamera", enabled)
		self.dirty = true
	end
end

function PlayerProfile:IsBoatCameraEnabled()
 	if USE_SETTINGS_FILE then
 		if TheSim:GetSetting("misc", "boatcamera") ~= nil then
			return TheSim:GetSetting("misc", "boatcamera") == "true"
		else
			return true -- Default to true this value hasn't been created yet
		end
	else
		if self:GetValue("boatcamera") ~= nil then
			return self:GetValue("boatcamera")
		else
			return true -- Default to true this value hasn't been created yet
		end
	end
end

function PlayerProfile:SetCampfireStoryCameraEnabled(enabled)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("misc", "campfirestorycamera", tostring(enabled))
	else
		self:SetValue("campfirestorycamera", enabled)
		self.dirty = true
	end
end

function PlayerProfile:IsCampfireStoryCameraEnabled()
	-- Default to true if this value hasn't been created yet

 	if USE_SETTINGS_FILE then
 		return TheSim:GetSetting("misc", "campfirestorycamera") ~= "false"
	else
		return self:GetValue("campfirestorycamera") ~= false
	end
end

function PlayerProfile:SetMinimapZoomCursorEnabled(enabled)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("misc", "minimapzoomcursor", tostring(enabled))
	else
		self:SetValue("minimapzoomcursor", enabled)
		self.dirty = true
	end
end

function PlayerProfile:IsMinimapZoomCursorFollowing()
	-- Default to true if this value hasn't been created yet
 	if USE_SETTINGS_FILE then
 		return TheSim:GetSetting("misc", "minimapzoomcursor") ~= "false"
	else
		return self:GetValue("minimapzoomcursor") ~= false
	end
end

function PlayerProfile:SetHaveWarnedDifficultyRoG()
	if USE_SETTINGS_FILE then
		TheSim:SetSetting("misc", "warneddifficultyrog", "true")
	else
		self:SetValue("warneddifficultyrog", true)
		self.dirty = true
	end
end

function PlayerProfile:HaveWarnedDifficultyRoG()
	if USE_SETTINGS_FILE then
		return TheSim:GetSetting("misc", "warneddifficultyrog") == "true"
	else
		return self:GetValue("warneddifficultyrog")
	end
end

function PlayerProfile:SetVibrationEnabled(enabled)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("misc", "vibration", tostring(enabled))
	else
		self:SetValue("vibration", enabled)
		self.dirty = true
	end
end

function PlayerProfile:GetVibrationEnabled()
 	if USE_SETTINGS_FILE then
		return TheSim:GetSetting("misc", "vibration") == "true"
	else
		return self:GetValue("vibration")
	end
end

function PlayerProfile:SetShowPasswordEnabled(enabled)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("misc", "showpassword", tostring(enabled))
	else
		self:SetValue("showpassword", enabled)
		self.dirty = true
	end
end

function PlayerProfile:GetShowPasswordEnabled()
 	if USE_SETTINGS_FILE then
		return TheSim:GetSetting("misc", "showpassword") == "true"
	else
		return self:GetValue("showpassword")
	end
end

function PlayerProfile:SetMovementPredictionEnabled(enabled)
    if USE_SETTINGS_FILE then
        TheSim:SetSetting("misc", "movementprediction", tostring(enabled))
    else
        self:SetValue("movementprediction", enabled)
        self.dirty = true
    end
end

function PlayerProfile:SetTextureStreamingEnabled(enabled)
    if USE_SETTINGS_FILE then
        TheSim:SetSetting("misc", "texture_streaming", tostring(enabled))
    else
        self:SetValue("texturestreaming", enabled)
        self.dirty = true
    end
end

function PlayerProfile:SetThreadedRenderEnabled(enabled)
    if USE_SETTINGS_FILE then
        TheSim:SetSetting("misc", "use_threaded_renderer", tostring(enabled))
    else
        self:SetValue("threaded_renderer", enabled)
        self.dirty = true
    end
end

function PlayerProfile:SetDynamicTreeShadowsEnabled(enabled)
    if USE_SETTINGS_FILE then
        TheSim:SetSetting("misc", "dynamic_tree_shadows", tostring(enabled))
    else
        self:SetValue("dynamic_tree_shadows", enabled)
        self.dirty = true
    end
end

function PlayerProfile:SetAutopauseEnabled(enabled)
    if USE_SETTINGS_FILE then
        TheSim:SetSetting("misc", "autopause", tostring(enabled))
    else
        self:SetValue("autopause", enabled)
        self.dirty = true
    end
end

function PlayerProfile:SetConsoleAutopauseEnabled(enabled)
    if USE_SETTINGS_FILE then
        TheSim:SetSetting("misc", "consoleautopause", tostring(enabled))
    else
        self:SetValue("consoleautopause", enabled)
        self.dirty = true
    end
end

function PlayerProfile:SetCraftingAutopauseEnabled(enabled)
    if USE_SETTINGS_FILE then
        TheSim:SetSetting("misc", "craftingautopause", tostring(enabled))
    else
        self:SetValue("craftingautopause", enabled)
        self.dirty = true
    end
end

function PlayerProfile:GetCraftingAutopauseEnabled()
	-- Default to false if this value hasn't been created yet

    if USE_SETTINGS_FILE then
		return TheSim:GetSetting("misc", "craftingautopause") == "true"
    else
		return self:GetValue("craftingautopause") == true
    end
end

function PlayerProfile:SetCraftingMenuBufferedBuildAutoClose(enabled)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("misc", "craftingmenu_bufferedbuild_autoclose", tostring(enabled))
	else
		self:SetValue("craftingmenu_bufferedbuild_autoclose", enabled)
		self.dirty = true
	end
end

function PlayerProfile:GetCraftingMenuBufferedBuildAutoClose()
    -- default to true
    if USE_SETTINGS_FILE then
        return TheSim:GetSetting("misc", "craftingmenu_bufferedbuild_autoclose") ~= "false" 
    else
        return self:GetValue("craftingmenu_bufferedbuild_autoclose") ~= false
    end
end

function PlayerProfile:SetCraftingHintAllRecipesEnabled(enabled)
    if USE_SETTINGS_FILE then
        TheSim:SetSetting("misc", "craftinghintallrecipes", tostring(enabled))
    else
        self:SetValue("craftinghintallrecipes", enabled)
        self.dirty = true
    end
end

function PlayerProfile:GetCraftingHintAllRecipesEnabled()
	-- Default to false if this value hasn't been created yet

    if USE_SETTINGS_FILE then
		return TheSim:GetSetting("misc", "craftinghintallrecipes") == "true"
    else
		return self:GetValue("craftinghintallrecipes") == true
    end
end

function PlayerProfile:SetLoadingTipsOption(setting)
	if USE_SETTINGS_FILE then
        TheSim:SetSetting("misc", "loadingtips", tostring(setting))
    else
        self:SetValue("loadingtips", setting)
        self.dirty = true
    end
end

function PlayerProfile:SetDefaultCloudSaves(enabled)
    if USE_SETTINGS_FILE then
        TheSim:SetSetting("misc", "defaultcloudsaves", tostring(enabled))
    else
        self:SetValue("defaultcloudsaves", enabled)
        self.dirty = true
    end
end

function PlayerProfile:SetUseZipFileForNormalSaves(enabled)
    if USE_SETTINGS_FILE then
        TheSim:SetSetting("misc", "usezipfilefornormalsaves", tostring(enabled))
    else
        self:SetValue("usezipfilefornormalsaves", enabled)
        self.dirty = true
    end
end

function PlayerProfile:SetHidePauseUnderlay(hide)
    if USE_SETTINGS_FILE then
        TheSim:SetSetting("misc", "hide_pause_underlay", tostring(hide))
    else
        self:SetValue("hide_pause_underlay", hide)
        self.dirty = true
    end
end

function PlayerProfile:GetMovementPredictionEnabled()
    -- an undefined movementprediction is considered to be enabled
    if USE_SETTINGS_FILE then
        return TheSim:GetSetting("misc", "movementprediction") ~= "false"
    else
        return self:GetValue("movementprediction") ~= false
    end
end

function PlayerProfile:SetProfanityFilterServerNamesEanbled(enabled)
    if USE_SETTINGS_FILE then
        TheSim:SetSetting("misc", "profanityfilterservernames", tostring(enabled))
    else
        self:SetValue("profanityfilterservernames", enabled)
        self.dirty = true
    end
end

function PlayerProfile:GetProfanityFilterServerNamesEnabled()
    -- an undefined setting is considered to be enabled
    if USE_SETTINGS_FILE then
        return TheSim:GetSetting("misc", "profanityfilterservernames") ~= "false"
    else
        return self:GetValue("profanityfilterservernames") ~= false
    end
end

function PlayerProfile:SetProfanityFilterChatEanbled(enabled)
    if USE_SETTINGS_FILE then
        TheSim:SetSetting("misc", "profanityfilter_chat", tostring(enabled))
    else
        self:SetValue("profanityfilter_chat", enabled)
        self.dirty = true
    end
end

function PlayerProfile:GetProfanityFilterChatEnabled()
    -- an undefined setting is considered to be enabled
    if USE_SETTINGS_FILE then
        return TheSim:GetSetting("misc", "profanityfilter_chat") ~= "false"
    else
        return self:GetValue("profanityfilter_chat") ~= false
    end
end

function PlayerProfile:SetAutoSubscribeModsEnabled(enabled)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("misc", "autosubscribemods", tostring(enabled))
	else
		self:SetValue("autosubscribemods", enabled)
		self.dirty = true
	end
end

function PlayerProfile:GetAutoSubscribeModsEnabled()
 	if USE_SETTINGS_FILE then
		return TheSim:GetSetting("misc", "autosubscribemods") == "true"
	else
		return self:GetValue("autosubscribemods")
	end
end

function PlayerProfile:SetAutoLoginEnabled(enabled)
	if USE_SETTINGS_FILE then
	   TheSim:SetSetting("misc", "autologin", tostring(enabled))
   else
	   self:SetValue("autologin", enabled)
	   self.dirty = true
   end
end

function PlayerProfile:GetAutoLoginEnabled()
	if USE_SETTINGS_FILE then
		local autologin = TheSim:GetSetting("misc", "autologin")
		if autologin == nil then
			return true
		end
		return autologin == "true"
	else
		return GetValueOrDefault( self.persistdata.autologin, true )
	end
end

function PlayerProfile:SetNPCChatLevel(level)
    if USE_SETTINGS_FILE then
        TheSim:SetSetting("misc", "npcchat", tostring(level))
    else
        self:SetValue("npcchat", level)
        self.dirty = true
    end
end

function PlayerProfile:GetNPCChatLevel()
    if USE_SETTINGS_FILE then
        local npcchat = TheSim:GetSetting("misc", "npcchat")
		return (npcchat ~= nil and tonumber(npcchat)) or CHATPRIORITIES.LOW
    else
        return GetValueOrDefault(self.persistdata.npcchat, CHATPRIORITIES.LOW)
    end
end

function PlayerProfile:GetNPCChatEnabled()
    if USE_SETTINGS_FILE then
        local npcchat = TheSim:GetSetting("misc", "npcchat")
		return (npcchat == nil or npcchat ~= "0")
    else
		local npcchat = GetValueOrDefault(self.persistdata.npcchat, CHATPRIORITIES.LOW)
        return npcchat > 0
    end
end

function PlayerProfile:SetAnimatedHeadsEnabled(enabled)
	if USE_SETTINGS_FILE then
	   TheSim:SetSetting("misc", "animatedheads", tostring(enabled))
   else
	   self:SetValue("animatedheads", enabled)
	   self.dirty = true
   end
end

function PlayerProfile:GetAnimatedHeadsEnabled()
	if USE_SETTINGS_FILE then
		local animatedheads = TheSim:GetSetting("misc", "animatedheads")
		if animatedheads == nil then
			return true
		end
		return animatedheads == "true"
	else
		return GetValueOrDefault( self.persistdata.animatedheads, true )
	end
end

function PlayerProfile:SetAutoCavesEnabled(enabled)
	if USE_SETTINGS_FILE then
	   TheSim:SetSetting("misc", "autocaves", tostring(enabled))
   else
	   self:SetValue("autocaves", enabled)
	   self.dirty = true
   end
end

function PlayerProfile:GetAutoCavesEnabled()
	if USE_SETTINGS_FILE then
		return TheSim:GetSetting("misc", "autocaves") == "true"
	else
		return GetValueOrDefault( self.persistdata.autocaves, false )
	end
end

function PlayerProfile:SetCavesStateRemembered()
	if USE_SETTINGS_FILE then
	   TheSim:SetSetting("misc", "cavesstateremembered", "true")
    else
	   self:SetValue("cavesstateremembered", true)
	   self.dirty = true
    end
end

function PlayerProfile:GetCavesStateRemembered()
	if USE_SETTINGS_FILE then
		return TheSim:GetSetting("misc", "cavesstateremembered") == "true"
	else
		return GetValueOrDefault( self.persistdata.cavesstateremembered, false )
	end
end


function PlayerProfile:SetModsWarning(enabled)
	if USE_SETTINGS_FILE then
	   TheSim:SetSetting("misc", "modswarning", tostring(enabled))
   else
	   self:SetValue("modswarning", enabled)
	   self.dirty = true
   end
end

function PlayerProfile:GetModsWarning()
	if USE_SETTINGS_FILE then
		return TheSim:GetSetting("misc", "modswarning") ~= "false"
	else
		return GetValueOrDefault( self.persistdata.modswarning, true )
	end
end

function PlayerProfile:SetPresetMode(mode)
	if USE_SETTINGS_FILE then
	   TheSim:SetSetting("misc", "presetmode", mode)
   else
	   self:SetValue("presetmode", mode)
	   self.dirty = true
   end
end

function PlayerProfile:GetPresetMode()
	if USE_SETTINGS_FILE then
		return TheSim:GetSetting("misc", "presetmode") or "combined"
	else
		return GetValueOrDefault( self.persistdata.presetmode, "combined" )
	end
end

function PlayerProfile:SetIntegratedBackpack(enabled)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("misc", "integratedbackpack", tostring(enabled))
	else
		self:SetValue("integratedbackpack", enabled)
		self.dirty = true
	end
end

function PlayerProfile:GetIntegratedBackpack()
 	if USE_SETTINGS_FILE then
		return TheSim:GetSetting("misc", "integratedbackpack") == "true"
	else
		return self:GetValue("integratedbackpack")
	end
end


function PlayerProfile:GetTextureStreamingEnabled()
 	if USE_SETTINGS_FILE then
		return TheSim:GetSetting("misc", "texture_streaming") == "true"
	else
		return self:GetValue("texturestreaming")
	end
end

function PlayerProfile:GetThreadedRenderEnabled()
    if USE_SETTINGS_FILE then
		return TheSim:GetSetting("misc", "use_threaded_renderer") == "true"
    else
		return self:GetValue("threaded_renderer")
    end
end

function PlayerProfile:GetDynamicTreeShadowsEnabled()
    if USE_SETTINGS_FILE then
		return TheSim:GetSetting("misc", "dynamic_tree_shadows") ~= "false"
    else
		return self:GetValue("dynamic_tree_shadows") ~= false
    end
end

function PlayerProfile:GetAutopauseEnabled()
    if USE_SETTINGS_FILE then
		return TheSim:GetSetting("misc", "autopause") ~= "false"
    else
		return self:GetValue("autopause") ~= false
    end
end

function PlayerProfile:GetConsoleAutopauseEnabled()
    if USE_SETTINGS_FILE then
		return TheSim:GetSetting("misc", "consoleautopause") ~= "false"
    else
		return self:GetValue("consoleautopause") ~= false
    end
end

function PlayerProfile:GetLoadingTipsOption()
	if TheNet:IsDedicated() then
		return LOADING_SCREEN_TIP_OPTIONS.NONE
	end

    if USE_SETTINGS_FILE then
		local option = TheSim:GetSetting("misc", "loadingtips") or 1
		return tonumber(option)
    else
		local option = self:GetValue("loadingtips") or 1
		return tonumber(option)
    end
end

function PlayerProfile:GetUseZipFileForNormalSaves()
    if USE_SETTINGS_FILE then
		return TheSim:GetSetting("misc", "usezipfilefornormalsaves") == "true"
    else
		return self:GetValue("usezipfilefornormalsaves") == true
    end
end

function PlayerProfile:GetDefaultCloudSaves()
    if USE_SETTINGS_FILE then
		return TheSim:GetSetting("misc", "defaultcloudsaves") == "true"
    else
		return self:GetValue("defaultcloudsaves") == true
    end
end

function PlayerProfile:GetHidePauseUnderlay()
    if USE_SETTINGS_FILE then
		return TheSim:GetSetting("misc", "hide_pause_underlay") == "true"
    else
		return self:GetValue("hide_pause_underlay") == true
    end
end

-- "enter_tab", "disabled", "tab", "enter", "mouseonly"
function PlayerProfile:GetConsoleAutocompleteMode()
 	if USE_SETTINGS_FILE then
		return TheSim:GetSetting("misc", "console_autocomplete") or "enter_tab"
	else
		return "enter_tab"
	end
end

-- "enter_tab", "disabled", "tab", "enter", "mouseonly"
function PlayerProfile:GetChatAutocompleteMode()
 	if USE_SETTINGS_FILE then
		return TheSim:GetSetting("misc", "chat_autocomplete") or "enter_tab"
	else
		return "enter_tab"
	end
end

-- gjans: Added this upgrade path 28/03/2016
local function UpgradeProfilePresets(presets_string)
    local didupgrade = false
    local savefileupgrades = require "savefileupgrades"

    if presets_string ~= nil and type(presets_string) == "string" then
        local success, presets = RunInSandbox(presets_string)
        if success then
            for i,preset in ipairs(presets) do
                if preset.version == nil or preset.version == 1 then
                    -- note: this upgrades the presets table in-place, to handle custom presets referencing other custom presets without infinite recursion ~gjans
                    presets[i] = savefileupgrades.utilities.UpgradeUserPresetFromV1toV2(preset, presets)
                    didupgrade = true
                end

                if preset.version == 2 then
                    presets[i] = savefileupgrades.utilities.UpgradeUserPresetFromV2toV3(preset, presets)
                    didupgrade = true
				end

                if preset.version == 3 then
                    presets[i] = savefileupgrades.utilities.UpgradeUserPresetFromV3toV4(preset, presets)
                    didupgrade = true
				end
            end

            if didupgrade then
                local data = DataDumper(presets, nil, false)
                return data
            end
        end
    end
    return nil
end

function PlayerProfile:GetWorldCustomizationPresets()
    local presets_string = self:GetValue("customizationpresets")

    if presets_string ~= nil and type(presets_string) == "string" then
        local success, presets = RunInSandbox(presets_string)
        if success then
            return presets
        else
            return {}
        end
    else
        return {}
    end
end

function PlayerProfile:AddWorldCustomizationPreset(preset, index)
    local presets = self:GetWorldCustomizationPresets()

    if index then
        presets[index] = preset
    else
        table.insert(presets, preset)
    end
    local data = DataDumper(presets, nil, false)

    self:SetValue("customizationpresets", data)
    self.dirty = true
end

function PlayerProfile:GetSavedFilters()
	local filters_string = self:GetValue("serverfilters")

	if filters_string ~= nil and type(filters_string) == "string" then
		local success, filters = RunInSandbox(filters_string)
		if success then
			return filters
		else
			return {}
		end
	else
		return {}
	end
end

function PlayerProfile:SaveFilters(filters)
	local data = DataDumper(filters, nil, false)

	self:SetValue("serverfilters", data)
	self.dirty = true
	self:Save()
end

function PlayerProfile:GetVolume()
 	if USE_SETTINGS_FILE then
		local amb = TheSim:GetSetting("audio", "volume_ambient")
        amb = tonumber(amb) or 10
		local sfx = TheSim:GetSetting("audio", "volume_sfx")
        sfx = tonumber(sfx) or 10
		local music = TheSim:GetSetting("audio", "volume_music")
        music = tonumber(music) or 10

		return amb, sfx, music
	else
    	return self.persistdata.volume_ambient or 10, self.persistdata.volume_sfx or 10, self.persistdata.volume_music or 10
	end
end

function PlayerProfile:GetMuteOnFocusLost()
	if USE_SETTINGS_FILE then
		return TheSim:GetSetting("audio", "volume_muteonfocuslost") == "true"
	else
		return GetValueOrDefault(self.persistdata.volume_muteonfocuslost, false)
	end
end


function PlayerProfile:SetRenderQuality(quality)
	self:SetValue("render_quality", quality)
	self.dirty = true
end

function PlayerProfile:GetRenderQuality()
	return self:GetValue("render_quality")
end

-- read only
function PlayerProfile:GetInstallID()
    return self:GetValue("install_id")
end

function PlayerProfile:GetPlayInstance()
    local stashed = TheSim:GetStashedPlayInstance()
    if stashed == -1 then
        stashed = self:GetValue("play_instance")
        TheSim:StashPlayInstance(stashed)
        self:SetValue("play_instance", stashed + 1)
        -- need to write this out right away, specifically because this should increment on crashes
        self:Save()
    end
    return stashed
end

----------------------------

function PlayerProfile:IsWorldGenUnlocked(area, item)
	if self.persistdata.unlocked_worldgen == nil then
		return false
	end

	if self.persistdata.unlocked_worldgen[area] == nil then
		return false
	end

    if item == nil or self.persistdata.unlocked_worldgen[area][item] then
        return true
    end

    return false
end

function PlayerProfile:UnlockWorldGen(area, item)
	if self.persistdata.unlocked_worldgen == nil then
		self.persistdata.unlocked_worldgen = {}
	end

	if self.persistdata.unlocked_worldgen[area] == nil then
		self.persistdata.unlocked_worldgen[area] = {}
	end

    self.persistdata.unlocked_worldgen[area][item] = true
    self.dirty = true
end

function PlayerProfile:GetUnlockedWorldGen()
    return self.persistdata.unlocked_worldgen
end

----------------------------

function PlayerProfile:GetSaveName()
    return BRANCH ~= "dev" and "profile" or ("profile_"..BRANCH)
end

function PlayerProfile:Save(callback)
    Print( VERBOSITY.DEBUG, "SAVING" )
    if self.dirty then
        local str = json.encode(self.persistdata)
        SavePersistentString(self:GetSaveName(), str, ENCODE_SAVES, callback)
    elseif callback ~= nil then
        callback(true)
    end
end

function PlayerProfile:Load(callback, minimal_load)
    TheSim:GetPersistentString(self:GetSaveName(),
        function(load_success, str)
            self:Set(str, callback, minimal_load)
        end, false)
end

local function GetValueOrDefault( value, default )
	if value ~= nil then
		return value
	else
		return default
	end
end

function PlayerProfile:Set(str, callback, minimal_load)
    if str == nil or string.len(str) <= 0 then
        if callback ~= nil then
            --These are purposely inside the if to prevent infinite recursion
            self:SoftReset()
            self:GetPlayInstance() --force stashing play instance
            callback(false)
        end
    else
        self.dirty = false

        self.persistdata = TrackedAssert("TheSim:GetPersistentString profile",  json.decode, str)

        if self.persistdata.saw_display_adjustment_popup == nil then
            self.persistdata.saw_display_adjustment_popup = false
        end

        if self.persistdata.saw_new_user_popup == nil then
            self.persistdata.saw_new_user_popup = false
        end

        if self.persistdata.saw_new_host_picker == nil then
            self.persistdata.saw_new_host_picker = false
        end

		if self.persistdata.autosave == nil then
		    self.persistdata.autosave = true
		end

        if self.persistdata.install_id == nil then
            self.persistdata.install_id = os.time()
        end

        if self.persistdata.play_instance == nil then
            self.persistdata.play_instance = 0
		end

		if self.persistdata.favorite_mods == nil then
			self.persistdata.favorite_mods = {}
		end

 	    if USE_SETTINGS_FILE then
			-- Copy over old settings
			if self.persistdata.volume_ambient ~= nil and self.persistdata.volume_sfx ~= nil and self.persistdata.volume_music ~= nil then
				print("Copying audio settings from profile to settings.ini")

				self:SetVolume(self.persistdata.volume_ambient, self.persistdata.volume_sfx, self.persistdata.volume_music)
				self.persistdata.volume_ambient = nil
				self.persistdata.volume_sfx = nil
				self.persistdata.volume_music = nil
				self.dirty = true
			end
		else
		    if self.persistdata.volume_ambient == nil and self.persistdata.volume_sfx == nil and self.persistdata.volume_music == nil then
                self.persistdata.volume_ambient = 7
                self.persistdata.volume_sfx = 7
                self.persistdata.volume_music = 7
				self.persistdata.volume_muteonfocuslost = false
                self.persistdata.HUDSize = 5
                self.persistdata.CraftingMenuSize = 5
                self.persistdata.CraftingMenuNumPinPages = 3
				self.persistdata.craftingmenusensitivity = 12
				self.persistdata.inventorysensitivity = 16
				self.persistdata.minimapzoomsensitivity = 15
                self.persistdata.boathopdelay = 8
                self.persistdata.vibration = true
                self.persistdata.showpassword = false
                self.persistdata.movementprediction = true
                self.persistdata.scrapbookhuddisplay = true
		    end
		end

        if minimal_load then
            assert(callback == nil)
            return
        end


		local amb, sfx, music = self:GetVolume()
		Print(VERBOSITY.DEBUG, "volumes", amb, sfx, music )

		TheMixer:SetLevel("set_sfx", sfx / 10)
		TheMixer:SetLevel("set_ambience", amb / 10)
		TheMixer:SetLevel("set_music", music / 10)

		TheInputProxy:EnableVibration(self:GetVibrationEnabled())

		if TheFrontEnd then
			local bloom_enabled = GetValueOrDefault( self.persistdata.bloom, true )
			local distortion_modifier = GetValueOrDefault( self.persistdata.distortion_modifier, 0.75 )

 	        if USE_SETTINGS_FILE then
				-- Copy over old settings
				if self.persistdata.bloom ~= nil and self.persistdata.distortion ~= nil and self.persistdata.HUDSize ~= nil then
					print("Copying render settings from profile to settings.ini")

					self:SetBloomEnabled(bloom_enabled)
					self:SetDistortionEnabled(distortion_modifier>0)
					self:SetDistortionModifier(distortion_modifier)
					self:SetHUDSize(self.persistdata.HUDSize)
					self.persistdata.bloom = nil
					self.persistdata.distortion = nil
					self.persistdata.HUDSize = nil
					self.dirty = true
				else
					bloom_enabled = self:GetBloomEnabled()
					distortion_modifier = self:GetDistortionModifier()
				end
			end
			print("bloom_enabled",bloom_enabled)
			PostProcessor:SetBloomEnabled( bloom_enabled )
			PostProcessor:SetDistortionEnabled( distortion_modifier>0 )

			EnableShadeRenderer( self:GetDynamicTreeShadowsEnabled() )
		end

		-- old save data will not have the controls section so create it
		if nil == self.persistdata.controls then
		    self.persistdata.controls = {}
		end

	    for idx,entry in pairs(self.persistdata.controls) do
	        local enabled = true
			if entry.enabled == nil then
				enabled = false
			else
				enabled = entry.enabled
			end
	        TheInputProxy:LoadControls(entry.guid, entry.data, enabled)
	    end

		if nil == self.persistdata.device_caps_a then
            self.persistdata.device_caps_a = 0
            self.persistdata.device_caps_b = 20
		end

        local upgraded = UpgradeProfilePresets(self.persistdata.customizationpresets)
        if upgraded ~= nil then
            self.persistdata.customizationpresets = upgraded
            self.dirty = true
        end

        self.persistdata.device_caps_a, self.persistdata.device_caps_b = TheSim:UpdateDeviceCaps(self.persistdata.device_caps_a, self.persistdata.device_caps_b)
        self.dirty = true

        if callback ~= nil then
            --purposely inside the if (see above)
            self:GetPlayInstance() --force stashing play instance
            callback(true)
        end
    end
end

function PlayerProfile:SetDirty(dirty)
    self.dirty = dirty
end

function PlayerProfile:GetControls(guid)
    local controls = nil
    local enabled = false
    for idx, entry in pairs(self.persistdata.controls) do
        if entry.guid == guid then
            controls = entry.data
            enabled = entry.enabled
        end
    end
    return controls, enabled
end

function PlayerProfile:SetControls(guid, data, enabled)
	-- check if this device is already in the list and update if found
	local found = false
    for idx, entry in pairs(self.persistdata.controls) do
        if entry.guid == guid then
            entry.data = data
            entry.enabled = enabled
            found = true
        end
    end

    -- not an existing device so add it
    if not found then
        table.insert(self.persistdata.controls, {["guid"]=guid, ["data"]=data, ["enabled"] = enabled})
    end

    self.dirty = true
end

function PlayerProfile:SawDisplayAdjustmentPopup()
    return self.persistdata.saw_display_adjustment_popup
end

function PlayerProfile:ShowedDisplayAdjustmentPopup()
    self.persistdata.saw_display_adjustment_popup = true
	self.dirty = true
end

function PlayerProfile:SawControllerPopup()
    local sawPopup
 	if USE_SETTINGS_FILE then
		sawPopup = (TheSim:GetSetting("misc", "controller_popup") == "true")
	else
		sawPopup = GetValueOrDefault(self.persistdata.controller_popup, false)
	end

	return sawPopup
end

function PlayerProfile:ShowedControllerPopup()
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("misc", "controller_popup", tostring(true))
	else
		self:SetValue("controller_popup", true)
		self.dirty = true
	end
end

function PlayerProfile:ShouldWarnModsEnabled()
    if USE_SETTINGS_FILE then
 		if TheSim:GetSetting("misc", "warn_mods_enabled") ~= nil then
			return TheSim:GetSetting("misc", "warn_mods_enabled") == "true"
		else
			return true -- Default to true this value hasn't been created yet
		end
	else
		if self:GetValue("warn_mods_enabled") ~= nil then
			return self:GetValue("warn_mods_enabled")
		else
			return true -- Default to true this value hasn't been created yet
		end
	end
end

function PlayerProfile:SetWarnModsEnabled(do_warning)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("misc", "warn_mods_enabled", tostring(do_warning))
	else
		self:SetValue("warn_mods_enabled", do_warning)
		self.dirty = true
	end
end

local function _EntitlementKey(entitlement)
    return TheNet:GetItemsBranch() .. TheNet:GetUserID().."entitlement_"..entitlement
end

function PlayerProfile:IsEntitlementReceived(entitlement)
	if self:GetValue(_EntitlementKey(entitlement)) ~= nil then
		return self:GetValue(_EntitlementKey(entitlement))
	else
		return false
	end
end

function PlayerProfile:SetEntitlementReceived(entitlement)
	self:SetValue(_EntitlementKey(entitlement), true)
	self.dirty = true
    self:Save()
end

function PlayerProfile:SawNewUserPopup()
    return self.persistdata.saw_new_user_popup
end

function PlayerProfile:ShowedNewUserPopup()
    if not self.persistdata.saw_new_user_popup then
        self.persistdata.saw_new_user_popup = true
        self.dirty = true
    end
end

function PlayerProfile:SawNewHostPicker()
    return self.persistdata.saw_new_host_picker
end

function PlayerProfile:ShowedNewHostPicker()
    if not self.persistdata.saw_new_host_picker then
        self.persistdata.saw_new_host_picker = true
        self.dirty = true
    end
end

function PlayerProfile:SaveKlumpCipher(file, cipher)
    if IsConsole() then
        --do nothing on console for Klump ciphers
        return
    end

	if not self.persistdata.klump_ciphers then
		self.persistdata.klump_ciphers = {}
	end

    if self.persistdata.klump_ciphers[file] == cipher then
        --we've already saved the cipher for this klump, no need to save it again
        return
    end

    if self.persistdata.klump_ciphers[file] ~= nil then
        print("ERROR: New klump cipher detected for file:", file)
        print("old cipher", self.persistdata.klump_ciphers[file])
        print("new cipher", cipher)
    end

	self.dirty = true
	self.persistdata.klump_ciphers[file] = cipher

	self:Save()
end

function PlayerProfile:GetKlumpCipher(file)
    if IsConsole() then
        print("~~~ERROR~~~ GetKlumpCipher should never be called on console")
        return ""
    end

	if not self.persistdata.klump_ciphers then
		return nil
	end

	return self.persistdata.klump_ciphers[file]
end

function PlayerProfile:GetRedbirdGameHighScore(score_version)
	if self:GetValue("redbird_game_high_score"..score_version) ~= nil then
		return self:GetValue("redbird_game_high_score"..score_version)
	end
	return 0
end

function PlayerProfile:SetRedbirdGameHighScore(score, score_version)
	self:SetValue("redbird_game_high_score"..score_version, score)
	self.dirty = true
    self:Save()
end

function PlayerProfile:GetSnowbirdGameHighScore(score_version)
	if self:GetValue("snowbird_game_high_score"..score_version) ~= nil then
		return self:GetValue("snowbird_game_high_score"..score_version)
	end
	return 0
end

function PlayerProfile:SetSnowbirdGameHighScore(score, score_version)
	self:SetValue("snowbird_game_high_score"..score_version, score)
	self.dirty = true
    self:Save()
end

function PlayerProfile:GetCrowGameHighScore(score_version)
	if self:GetValue("crow_game_high_score"..score_version) ~= nil then
		return self:GetValue("crow_game_high_score"..score_version)
	end
	return 0
end

function PlayerProfile:SetCrowGameHighScore(score, score_version)
	self:SetValue("crow_game_high_score"..score_version, score)
	self.dirty = true
    self:Save()
end


function PlayerProfile:GetKitSize()
	if self:GetValue("kit_size") ~= nil then
		return self:GetValue("kit_size")
	end
	return 0
end
function PlayerProfile:SetKitSize(size)
	self:SetValue("kit_size", size)
	self.dirty = true
    self:Save()
end

function PlayerProfile:GetKitBuild()
	if self:GetValue("kit_build") ~= nil then
		return self:GetValue("kit_build")
	end
	return ""
end
function PlayerProfile:SetKitBuild(build)
	self:SetValue("kit_build", build)
	self.dirty = true
    self:Save()
end

function PlayerProfile:GetKitLastTime()
	if self:GetValue("kit_last_time") ~= nil then
		return self:GetValue("kit_last_time")
	end
	return 0
end
function PlayerProfile:SetKitLastTime(last_time)
	self:SetValue("kit_last_time", last_time)
	self.dirty = true
    self:Save()
end

function PlayerProfile:GetKitHunger()
	if self:GetValue("kit_hunger") ~= nil then
		return self:GetValue("kit_hunger")
	end
	return 0
end
function PlayerProfile:SetKitHunger(hunger)
	self:SetValue("kit_hunger", hunger)
	self.dirty = true
    self:Save()
end

function PlayerProfile:GetKitHappiness()
	if self:GetValue("kit_happiness") ~= nil then
		return self:GetValue("kit_happiness")
	end
	return 0
end
function PlayerProfile:SetKitHappiness(happiness)
	self:SetValue("kit_happiness", happiness)
	self.dirty = true
    self:Save()
end

function PlayerProfile:GetKitBirthTime()
	if self:GetValue("kit_birth") ~= nil then
		return self:GetValue("kit_birth")
	end
	return 0
end
function PlayerProfile:SetKitBirthTime(birth_time)
	self:SetValue("kit_birth", birth_time)
	self.dirty = true
    self:Save()
end

function PlayerProfile:GetKitName()
	if self:GetValue("kit_name") ~= nil then
		return self:GetValue("kit_name")
	end
	return ""
end
function PlayerProfile:SetKitName(name)
	self:SetValue("kit_name", name)
	self.dirty = true
    self:Save()
end

function PlayerProfile:GetKitPoops()
	if self:GetValue("kit_poops") ~= nil then
		return self:GetValue("kit_poops")
	end
	return 0
end
function PlayerProfile:SetKitPoops(poops)
	self:SetValue("kit_poops", poops)
	self.dirty = true
    self:Save()
end

function PlayerProfile:GetKitAbandonedMessage()
	if self:GetValue("kit_abandoned_message") ~= nil then
		return self:GetValue("kit_abandoned_message")
	end
	return false
end
function PlayerProfile:SetKitAbandonedMessage(abandoned)
	self:SetValue("kit_abandoned_message", abandoned)
	self.dirty = true
    self:Save()
end

function PlayerProfile:GetKitIsHibernating()
	if self:GetValue("kit_hibernating") ~= nil then
		return self:GetValue("kit_hibernating")
	end
	return false
end
function PlayerProfile:SetKitIsHibernating(hibernating)
	self:SetValue("kit_hibernating", hibernating)
	self.dirty = true
    self:Save()
end

function PlayerProfile:GetKitHibernationStart()
	if self:GetValue("kit_hibernation_start_time") ~= nil then
		return self:GetValue("kit_hibernation_start_time")
	end
	return 0
end
function PlayerProfile:SetKitHibernationStart(time)
	self:SetValue("kit_hibernation_start_time", time)
	self.dirty = true
    self:Save()
end






function PlayerProfile:GetLanguageID()
	if self:GetValue("language_id") ~= nil then
		return self:GetValue("language_id")
	elseif IsConsole() then
		return TheSystemService:GetLanguage()
	else
		return LANGUAGE.ENGLISH
	end
end

function PlayerProfile:SetLanguageID(language_id, cb)
	self:SetValue("language_id", language_id)
	self.dirty = true
    self:Save(cb)
end

return PlayerProfile
