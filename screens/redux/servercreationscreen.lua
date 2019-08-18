local BanTab = require "widgets/redux/bantab"
local WorldCustomizationTab = require "widgets/redux/worldcustomizationtab"
local HeaderTabs = require "widgets/redux/headertabs"
local LaunchingServerPopup = require "screens/redux/launchingserverpopup"
local ModsTab = require "widgets/redux/modstab"
local OnlineStatus = require "widgets/onlinestatus"
local PopupDialogScreen = require "screens/redux/popupdialog"
local Screen = require "widgets/screen"
local ServerSettingsTab = require "widgets/redux/serversettingstab"
local SnapshotTab = require "widgets/redux/snapshottab"
local Subscreener = require "screens/redux/subscreener"
local TEMPLATES = require "widgets/redux/templates"
local TextListPopup = require "screens/redux/textlistpopup"
local Widget = require "widgets/widget"

require("constants")
require("tuning")


local num_rows = 9
local row_height = 60
local dialog_size_x = 830
local dialog_size_y = row_height*(num_rows + 0.25)

local bottom_button_y = -310

local ServerCreationScreen = Class(Screen, function(self, prev_screen)
    Screen._ctor(self, "ServerCreationScreen")

    -- Defer accessing this table until screen creation to give mods a chance.
    -- Still not awesome, but mostly we require location indexes at this point
    -- and these names are just for tab labels. We only support worlds with 2
    -- locations through the UI.
	self.current_level_locations = SERVER_LEVEL_LOCATIONS
    self.default_world_location = SERVER_LEVEL_LOCATIONS[1]

    TheSim:PauseFileExistsAsync(true)

    self.root = self:AddChild(TEMPLATES.ScreenRoot())
    self.bg = self.root:AddChild(TEMPLATES.PlainBackground())
    self.onlinestatus = self.bg:AddChild(OnlineStatus())

    self.detail_panel_frame_parent = self.root:AddChild(Widget("detail_frame"))
    self.detail_panel_frame_parent:SetPosition(140, 0)
    self.detail_panel_frame = self.detail_panel_frame_parent:AddChild(TEMPLATES.RectangleWindow(dialog_size_x, dialog_size_y))
    local r,g,b = unpack(UICOLOURS.BROWN_DARK)
    self.detail_panel_frame:SetBackgroundTint(r,g,b,0.6)
    self.detail_panel_frame.top:Hide() -- top crown would cover our tabs.

    self.RoG = false

    self.dirty = false

    self.saveslot = -1

    self.title = self.root:AddChild(TEMPLATES.ScreenTitle(STRINGS.UI.SERVERCREATIONSCREEN.HOST_GAME, ""))
    -- Prevent clipping into dialog
    self.title.small:SetPosition(-65, -35)
    self.title.small:SetRegionSize(270, 50)
    self.tooltip = self.root:AddChild(TEMPLATES.ScreenTooltip())

    self.detail_panel = self.detail_panel_frame:InsertWidget( Widget("detail_panel") )
    self.server_buttons = self.detail_panel_frame:AddChild(Widget("server_buttons"))

    self.slot_character_cache = {}
    self.slot_day_cache = {}

    self:RefreshNavButtons()

    self:MakeButtons()

    self:MakeBansPanel()

    -- the top tabs are subscreens (not the left menu!)
    local tabs = {
        settings = self:MakeSettingsTab(),
    }
    for i,location in ipairs(SERVER_LEVEL_LOCATIONS) do
        -- Avoid using location for worldgen so mods can modified
        -- SERVER_LEVEL_LOCATIONS (which should be handled inside
        -- WorldCustomizationTab).
        tabs[location] = self:MakeWorldTab(i)
    end
    tabs.mods     = self:MakeModsTab()
    tabs.snapshot = self:MakeSnapshotTab()

    self.tabscreener = Subscreener(self,
        self._BuildTabMenu,
        tabs
        )


    self.default_focus = self.menu

    self:_DoFocusHookups()

    local startingsaveslot = SaveGameIndex:GetLastUsedSlot()
    if startingsaveslot < 1 or
        startingsaveslot > NUM_SAVE_SLOTS or
        SaveGameIndex:IsSlotEmpty(startingsaveslot) then
        --find first empty slot
        --if we have no empty slots and no last slot used, pick the first slot
        startingsaveslot = 1
        for k = 1, NUM_SAVE_SLOTS do
            if SaveGameIndex:IsSlotEmpty(k) then
                startingsaveslot = k
                break
            end
        end
    end

    self:OnClickSlot(startingsaveslot, true) --This also sets the tab to be server settings when "true" is passed
end)

function ServerCreationScreen:GetContentHeight()
    return dialog_size_y
end

function ServerCreationScreen:OnBecomeActive()
    ServerCreationScreen._base.OnBecomeActive(self)
    self:Enable()
    self.mods_tab:OnBecomeActive()
    if self.last_focus then self.last_focus:SetFocus() end
end

function ServerCreationScreen:OnBecomeInactive()
    ServerCreationScreen._base.OnBecomeInactive(self)
end

function ServerCreationScreen:OnDestroy()
    --self.onlinestatus:Kill()
    --self.prev_screen:TransferPortalOwnership(self, self.prev_screen)
    self.mods_tab:OnDestroy()
    self._base.OnDestroy(self)
end

function ServerCreationScreen:ClearSlotCache(slotnum)
    self.slot_character_cache[slotnum] = nil
    self.slot_day_cache[slotnum] = nil
end

function ServerCreationScreen:UpdateTitle(slotnum, fromTextEntered)
    assert(self.save_slots[slotnum])
    -- Can't use maxwidth because SetRegionSize was called.
    self.title.small:SetTruncatedString(self.server_settings_tab:GetServerName(), nil, 27, true)

    if not fromTextEntered then
        self:_UpdateMenuButton(slotnum)
    end

    -- may also want to update the string used on the nav button...
end

function ServerCreationScreen:_UpdateMenuButton(slotnum)
    assert(self.save_slots[slotnum])
    local character_atlas = nil
    local character = nil
    if self.save_slots[slotnum].character and not self.save_slots[slotnum].isempty then
        character_atlas = self.save_slots[slotnum].character_atlas
        character = self.save_slots[slotnum].character 
    end
    self.save_slots[slotnum]:SetCharacter(character_atlas, character)

    if SaveGameIndex:IsSlotEmpty(slotnum) then
        self.slot_day_cache[slotnum] = STRINGS.UI.SERVERCREATIONSCREEN.SERVERDAY_NEW
    elseif self.slot_day_cache[slotnum] == nil then
        local session_id = SaveGameIndex:GetSlotSession(slotnum)
        if session_id ~= nil then
            local day = 1
            local season = nil
            local function onreadworldfile(success, str)
                if success and str ~= nil and #str > 0 then
                    local success, savedata = RunInSandbox(str)
                    if success and savedata ~= nil and GetTableSize(savedata) > 0 then
                        local worlddata = savedata.world_network ~= nil and savedata.world_network.persistdata or nil
                        if worlddata ~= nil then
                            if worlddata.clock ~= nil then
                                day = (worlddata.clock.cycles or 0) + 1
                            end

                            if worlddata.seasons ~= nil and worlddata.seasons.season ~= nil then
                                season = STRINGS.UI.SERVERLISTINGSCREEN.SEASONS[string.upper(worlddata.seasons.season)]
                                if season ~= nil and
                                    worlddata.seasons.elapseddaysinseason ~= nil and
                                    worlddata.seasons.remainingdaysinseason ~= nil then
                                    if worlddata.seasons.remainingdaysinseason * 3 <= worlddata.seasons.elapseddaysinseason then
                                        season = STRINGS.UI.SERVERLISTINGSCREEN.LATE_SEASON_1..season..STRINGS.UI.SERVERLISTINGSCREEN.LATE_SEASON_2
                                    elseif worlddata.seasons.elapseddaysinseason * 3 <= worlddata.seasons.remainingdaysinseason then
                                        season = STRINGS.UI.SERVERLISTINGSCREEN.EARLY_SEASON_1..season..STRINGS.UI.SERVERLISTINGSCREEN.EARLY_SEASON_2
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if SaveGameIndex:IsSlotMultiLevel(slotnum) or SaveGameIndex:GetSlotServerData(slotnum).use_cluster_path then
                local file = TheNet:GetWorldSessionFileInClusterSlot(slotnum, "Master", session_id)
                if file ~= nil then
                    TheSim:GetPersistentStringInClusterSlot(slotnum, "Master", file, onreadworldfile)
                end
            else
                local file = TheNet:GetWorldSessionFile(session_id)
                if file ~= nil then
                    TheSim:GetPersistentString(file, onreadworldfile)
                end
            end
            
            local day_text = ""
            if season ~= nil then
                day_text = subfmt(STRINGS.UI.SERVERCREATIONSCREEN.SERVERDAY_SEASON_V2, {day_count = day, season = season} )
            else
                day_text = subfmt(STRINGS.UI.SERVERCREATIONSCREEN.SERVERDAY_V2, {day_count = day} )
            end

            self.slot_day_cache[slotnum] = day_text
        else
            self.slot_day_cache[slotnum] = STRINGS.UI.SERVERCREATIONSCREEN.SERVERDAY_NEW
        end
    end

    self.save_slots[slotnum]:SetSecondaryText(self.slot_day_cache[slotnum])
end

function ServerCreationScreen:UpdateModeSpinner(slotnum)
    self.server_settings_tab:UpdateModeSpinner(slotnum)
end

function ServerCreationScreen:GetGameMode()
	return self.server_settings_tab:GetGameMode()
end

function ServerCreationScreen:UpdateTabs(slotnum, prevslot, fromDelete)
    self.server_settings_tab:SavePrevSlot(prevslot) --needs to happen before mods_tab:SetSaveSlot so that we don't lose the current game mode selection when the next slot's mods are applied

	self:SetLevelLocations(nil)

    self.mods_tab:SetSaveSlot(slotnum, fromDelete) --needs to happen before server_settings_tab:UpdateDetails
    
    self.server_settings_tab:UpdateDetails(slotnum, prevslot, fromDelete)

    for i,tab in ipairs(self.world_tabs) do
        tab:UpdateSlot(slotnum, prevslot, fromDelete)
    end

    self.snapshot_tab:SetSaveSlot(slotnum, prevslot, fromDelete)

    self:UpdateButtons(slotnum)
end

function ServerCreationScreen:UpdateButtons(slotnum)
    -- No save data
    if not slotnum or (slotnum < 0 or SaveGameIndex:IsSlotEmpty(slotnum)) then
        if self.delete_button then self.delete_button:Disable() end
        if self.create_button then self.create_button.text:SetString(STRINGS.UI.SERVERCREATIONSCREEN.CREATE) end
    else -- Save data
        if self.delete_button then self.delete_button:Enable() end
        if self.create_button then self.create_button.text:SetString(STRINGS.UI.SERVERCREATIONSCREEN.RESUME) end
    end
    self.tabscreener.buttons.mods:SetText(STRINGS.UI.MAINSCREEN.MODS.." ("..self.mods_tab:GetNumberOfModsEnabled()..")")
end

local function BuildTagsStringHosting(self, worldoptions)
    if TheNet:IsDedicated() then
        --Should be impossible to reach here right?
        --Dedicated servers don't start through this screen
        return
    end

    --V2C: ughh... well at least try to keep this in sync with
    --     networking.lua UpdateServerTagsString()

    local tagsTable = {}

    table.insert(tagsTable, GetGameModeTag(self.server_settings_tab:GetGameMode()))

    if self.server_settings_tab:GetPVP() then
        table.insert(tagsTable, STRINGS.TAGS.PVP)
    end

    if self.server_settings_tab:GetPrivacyType() == PRIVACY_TYPE.FRIENDS then
        table.insert(tagsTable, STRINGS.TAGS.FRIENDSONLY)
    elseif self.server_settings_tab:GetPrivacyType() == PRIVACY_TYPE.CLAN then
        table.insert(tagsTable, STRINGS.TAGS.CLAN)
    elseif self.server_settings_tab:GetPrivacyType() == PRIVACY_TYPE.LOCAL then
        table.insert(tagsTable, STRINGS.TAGS.LOCAL)
    end

    local worlddata = worldoptions[1]
    if worlddata ~= nil and worlddata.location ~= nil then
        local locationtag = STRINGS.TAGS.LOCATION[string.upper(worlddata.location)]
        if locationtag ~= nil then
            table.insert(tagsTable, locationtag)
        end
    end

    return BuildTagsStringCommon(tagsTable)
end

function ServerCreationScreen:DeleteSlot(slot, cb)
    local menu_items = 
    {
        -- ENTER
        {
            text=STRINGS.UI.SERVERCREATIONSCREEN.DELETE, 
            cb = function()
                TheFrontEnd:PopScreen()

                SaveGameIndex:DeleteSlot(slot, function() 
                    self:RefreshNavButtons()
                    self:UpdateTabs(slot, nil, true)
                end)

                self:ClearSlotCache(slot)
                self:OnClickSlot(self.saveslot, true)
                self:Enable()
            end
        },
        -- ESC
        {
            text=STRINGS.UI.SERVERCREATIONSCREEN.CANCEL, 
            cb = function() 
                TheFrontEnd:PopScreen() 
            end
        },
    }

    self.last_focus = TheFrontEnd:GetFocusWidget()
    TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.SERVERCREATIONSCREEN.DELETE.." "..STRINGS.UI.SERVERCREATIONSCREEN.SLOT.." "..slot, STRINGS.UI.SERVERCREATIONSCREEN.SURE, menu_items ) )
end

function ServerCreationScreen:Create(warnedOffline, warnedDisabledMods, warnedOutOfDateMods)
    local function onCreate()
        -- Check that the player has selected a spot
        if self.saveslot < 1 or self.saveslot > NUM_SAVE_SLOTS then
            -- If not, look for the first empty one
            local emptySlot = nil
            for k = 1, NUM_SAVE_SLOTS do
                if SaveGameIndex:IsSlotEmpty(k) then
                    emptySlot = k
                    break
                end
            end

            -- If we found an empty slot, make that our save slot and call Create() again
            if emptySlot ~= nil then
                self.saveslot = emptySlot
                self.default_focus = self.save_slots[emptySlot] or self.save_slots[1]
                self:Create()
            else -- Otherwise, show dialog informing that they must either load a game or delete a game
                self.last_focus = TheFrontEnd:GetFocusWidget()
                TheFrontEnd:PushScreen(
                    PopupDialogScreen(
                        STRINGS.UI.SERVERCREATIONSCREEN.FULLSLOTSTITLE,
                        STRINGS.UI.SERVERCREATIONSCREEN.FULLSLOTSBODY,
                        {
                            {
                                text = STRINGS.UI.SERVERCREATIONSCREEN.OK,
                                cb = function() TheFrontEnd:PopScreen() end,
                            },
                        }
                    )
                )
            end
        else
            self.server_settings_tab:SetEditingTextboxes(false)

            local serverdata = self.server_settings_tab:GetServerData()
            local worldoptions = {}
            local specialeventoverride = nil
            for i,tab in ipairs(self.world_tabs) do
                worldoptions[i] = tab:CollectOptions()

                --V2C: copy special event override from master to slaves
                if worldoptions[i] ~= nil then
                    if i == 1 then
                        if worldoptions[1].overrides ~= nil then
                            specialeventoverride = worldoptions[1].overrides.specialevent
                            if specialeventoverride == "default" then
                                specialeventoverride = nil
                            end
                        end
                    elseif specialeventoverride ~= nil then
                        if worldoptions[i].overrides == nil then
                            worldoptions[i].overrides = {}
                        end
                        worldoptions[i].overrides.specialevent = specialeventoverride
                    end
                end
            end

            local world1datastring = ""
            if worldoptions[1] ~= nil then
                local world1data = worldoptions[1]
                world1datastring = DataDumper(world1data, nil, false)
            end

            local world2datastring = ""
            if worldoptions[2] ~= nil then
                local world2data = worldoptions[2]
                world2datastring = DataDumper(world2data, nil, false)
            end

            -- Apply the mod settings
            self.mods_tab:Apply()

            -- Fill serverInfo object
            local cluster_info = {}

            local mod_data = DataDumper(SaveGameIndex:GetEnabledMods(self.saveslot), nil, false)
            --print("V v v v v v v v v v v v v v v v")
            --print(mod_data)
            --print("^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^")
            cluster_info.mods_config                             = mod_data
            cluster_info.world1gen                               = world1datastring
            cluster_info.world2gen                               = world2datastring
            cluster_info.friends_only                            = serverdata.privacy_type == PRIVACY_TYPE.FRIENDS

            cluster_info.settings                                = {}
            cluster_info.settings.NETWORK                        = {}
            cluster_info.settings.NETWORK.cluster_name           = serverdata.name
            cluster_info.settings.NETWORK.cluster_password       = serverdata.password
            cluster_info.settings.NETWORK.cluster_description    = serverdata.description
            cluster_info.settings.NETWORK.lan_only_cluster       = tostring(serverdata.privacy_type == PRIVACY_TYPE.LOCAL)
            cluster_info.settings.NETWORK.cluster_intention      = serverdata.intention
            cluster_info.settings.NETWORK.offline_cluster        = tostring(not serverdata.online_mode)
            cluster_info.settings.NETWORK.cluster_language       = LOC.GetLocaleCode()

            cluster_info.settings.GAMEPLAY                       = {}
            cluster_info.settings.GAMEPLAY.game_mode             = serverdata.game_mode
            cluster_info.settings.GAMEPLAY.pvp                   = tostring(serverdata.pvp)

			local gamemode_max_players = GetGameModeMaxPlayers(serverdata.game_mode)
			cluster_info.settings.GAMEPLAY.max_players           = tostring(gamemode_max_players ~= nil and math.min(serverdata.max_players, gamemode_max_players) or serverdata.max_players)

            if serverdata.privacy_type == PRIVACY_TYPE.CLAN then
                cluster_info.settings.STEAM                      = {}
                cluster_info.settings.STEAM.steam_group_only     = tostring(serverdata.clan.only)
                cluster_info.settings.STEAM.steam_group_id       = tostring(serverdata.clan.id)
                cluster_info.settings.STEAM.steam_group_admins   = tostring(serverdata.clan.admin)
            end

            local is_slot_empty = SaveGameIndex:IsSlotEmpty(self.saveslot)

            local function onsaved()
                if is_slot_empty then
                    self:ClearSlotCache(self.saveslot)
                    self:RefreshNavButtons()
                    self:OnClickSlot(self.saveslot)
                end

                self:Disable()

                local is_multi_level = SaveGameIndex:IsSlotMultiLevel(self.saveslot)
                local encode_user_path = serverdata.encode_user_path == true
                local use_cluster_path = serverdata.use_cluster_path == true
                local launchingServerPopup = nil

                if is_multi_level then
                    ShowLoading()
                    launchingServerPopup = LaunchingServerPopup({}, 
                        function()
                            local start_worked = TheNet:StartClient(DEFAULT_JOIN_IP, 10999, -1, serverdata.password)
                            if start_worked then
                                DisableAllDLC()
                            end
                        end,
                        function()
                            OnNetworkDisconnect("ID_DST_DEDICATED_SERVER_STARTUP_FAILED", false, false)
                            TheSystemService:StopDedicatedServers()
                        end)

                    TheFrontEnd:PushScreen(launchingServerPopup)
                end

                -- Note: StartDedicatedServers launches both dedicated and non-dedicated servers... ~gjans
                if not TheSystemService:StartDedicatedServers(self.saveslot, is_multi_level, cluster_info, encode_user_path, use_cluster_path) then
                    if launchingServerPopup ~= nil then
                        launchingServerPopup:SetErrorStartingServers()
                    end
                    self:Enable()
                elseif not is_multi_level then
                    -- Collect the tags we want and set the tags string now that we have our mods enabled
                    TheNet:SetServerTags(BuildTagsStringHosting(self, worldoptions))
                    DoLoadingPortal(function()
                        StartNextInstance({ reset_action = RESET_ACTION.LOAD_SLOT, save_slot = self.saveslot })
                    end)
                end
            end

            if is_slot_empty then
                local starts = Profile:GetValue("starts") or 0
                Profile:SetValue("starts", starts + 1)
                Profile:Save(function() SaveGameIndex:StartSurvivalMode(self.saveslot, worldoptions, serverdata, onsaved) end)
            else
                SaveGameIndex:UpdateServerData(self.saveslot, serverdata, onsaved)
            end

            --V2C: NO MORE CODE HERE!
            --     onsaved callback may trigger StartNextInstance!
        end
    end

    local function BuildOptionalModLink(mod_name)
        if PLATFORM == "WIN32_STEAM" or PLATFORM == "LINUX_STEAM" or PLATFORM == "OSX_STEAM" then
            local link_fn, is_generic_url = ModManager:GetLinkForMod(mod_name)
            if is_generic_url then
                return nil
            else
                return link_fn
            end
        else
            return nil
        end
    end
    local function BuildModList(mod_ids)
        local mods = {}
        for i,v in ipairs(mod_ids) do
            table.insert(mods, {
                    text = KnownModIndex:GetModFancyName(v) or v,
                    -- Adding onclick with the idea that if you have a ton of
                    -- mods, you'd want to be able to jump to information about
                    -- the problem ones.
                    onclick = BuildOptionalModLink(v),
                })
        end
        return mods
    end

    if not self:ValidateSettings() then
        -- popups are handled inside validate
        return
    end

    -- Build the list of mods that are newly disabled for this slot
    local disabledmods = {}
    if not warnedDisabledMods then
        disabledmods = self:CheckForDisabledMods()
    end

    -- Build the lost of mods that are enabled and also out of date
    local outofdatemods = {}
    if not warnedOutOfDateMods then
        outofdatemods = self.mods_tab:GetOutOfDateEnabledMods()
    end

    -- Warn if they're starting an offline game that it will always be offline
    if warnedOffline ~= true and not self.server_settings_tab:GetOnlineMode() then
        local offline_mode_body = ""
        if not SaveGameIndex:IsSlotEmpty(self.saveslot) then
            offline_mode_body = STRINGS.UI.SERVERCREATIONSCREEN.OFFLINEMODEBODYRESUME
        else
            offline_mode_body = STRINGS.UI.SERVERCREATIONSCREEN.OFFLINEMODEBODYCREATE
        end

        local confirm_offline_popup = PopupDialogScreen(STRINGS.UI.SERVERCREATIONSCREEN.OFFLINEMODETITLE, offline_mode_body,
                            {
                                {text=STRINGS.UI.SERVERCREATIONSCREEN.OK, cb = function()
                                    -- If player is okay with offline mode, go ahead
                                    TheFrontEnd:PopScreen()
                                    self:Create(true)
                                end},
                                {text=STRINGS.UI.SERVERCREATIONSCREEN.CANCEL, cb = function()
                                    TheFrontEnd:PopScreen() 
                                end}
                            },
                            nil,
                            "big")
        self.last_focus = TheFrontEnd:GetFocusWidget()
        TheFrontEnd:PushScreen(confirm_offline_popup)

    -- Can't start an online game if we're offline
    elseif self.server_settings_tab:GetOnlineMode() and (not TheNet:IsOnlineMode() or TheFrontEnd:GetIsOfflineMode()) then
        local online_only_popup = PopupDialogScreen(STRINGS.UI.SERVERCREATIONSCREEN.ONLINEONYTITLE, STRINGS.UI.SERVERCREATIONSCREEN.ONLINEONLYBODY,
                            {
                                {text=STRINGS.UI.SERVERCREATIONSCREEN.OK, cb = function()
                                    TheFrontEnd:PopScreen() 
                                end}
                            })
        self.last_focus = TheFrontEnd:GetFocusWidget()
        TheFrontEnd:PushScreen(online_only_popup)

    -- Warn if starting a server with mods disabled that were previously enabled on that server
    elseif warnedDisabledMods ~= true and #disabledmods > 0 then
        self.last_focus = TheFrontEnd:GetFocusWidget()
        TheFrontEnd:PushScreen(TextListPopup(BuildModList(disabledmods),
                            STRINGS.UI.SERVERCREATIONSCREEN.MODSDISABLEDWARNINGTITLE,
                            STRINGS.UI.SERVERCREATIONSCREEN.MODSDISABLEDWARNINGBODY, 
                            {
                                {text=STRINGS.UI.SERVERCREATIONSCREEN.CONTINUE, 
                                cb = function()
                                    TheFrontEnd:PopScreen()
                                    self:Create(true, true)
                                end,
                                controller_control=CONTROL_MENU_MISC_1},
                            }))

    -- Warn if starting a server with mods enabled that are currently out of date
    elseif warnedOutOfDateMods ~= true and #outofdatemods > 0 then
        self.last_focus = TheFrontEnd:GetFocusWidget()
        local warning = TextListPopup(BuildModList(outofdatemods),
                            STRINGS.UI.SERVERCREATIONSCREEN.MODSOUTOFDATEWARNINGTITLE,
                            STRINGS.UI.SERVERCREATIONSCREEN.MODSOUTOFDATEWARNINGBODY,
                            {
                                {text=STRINGS.UI.SERVERCREATIONSCREEN.CONTINUE,
                                cb = function()
                                    TheFrontEnd:PopScreen()
                                    self:Create(true, true, true)
                                end,
                                controller_control=CONTROL_MENU_MISC_1},
                                {text=STRINGS.UI.MODSSCREEN.UPDATEALL,
                                cb = function()
                                    TheFrontEnd:PopScreen()
                                    self.mods_tab:UpdateAllButton(true)
                                    self:SetTab("mods")
                                end,
                                controller_control=CONTROL_MENU_MISC_2},
                            })
        TheFrontEnd:PushScreen(warning)

    -- We passed all our checks, go ahead and create
    else
        onCreate()
    end
end

function ServerCreationScreen:ValidateSettings()
    self.last_focus = TheFrontEnd:GetFocusWidget()
    if not self.server_settings_tab:VerifyValidNewHostType() then
        TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.SERVERCREATIONSCREEN.INVALIDNEWHOST_TITLE, STRINGS.UI.SERVERCREATIONSCREEN.INVALIDNEWHOST_BODY,
                    {{text=STRINGS.UI.CUSTOMIZATIONSCREEN.OKAY, cb = function() TheFrontEnd:PopScreen() self:SetTab("settings") end}}))
        return false
    elseif not self.server_settings_tab:VerifyValidServerIntention() then
        TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.SERVERCREATIONSCREEN.INVALIDINTENTIONSETTINGS_TITLE, STRINGS.UI.SERVERCREATIONSCREEN.INVALIDINTENTIONSETTINGS_BODY,
                    {{text=STRINGS.UI.CUSTOMIZATIONSCREEN.OKAY, cb = function() TheFrontEnd:PopScreen() self:SetTab("settings") end}}))
        return false
    elseif not self.server_settings_tab:VerifyValidServerName() then
        TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.SERVERCREATIONSCREEN.INVALIDSERVERNAME_TITLE, STRINGS.UI.SERVERCREATIONSCREEN.INVALIDSERVERNAME_BODY,
                    {{text=STRINGS.UI.CUSTOMIZATIONSCREEN.OKAY, cb = function() TheFrontEnd:PopScreen() self:SetTab("settings") end}}))
        return false
    elseif not self.server_settings_tab:VerifyValidClanSettings() then
        TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.SERVERCREATIONSCREEN.INVALIDCLANSETTINGS_TITLE, STRINGS.UI.SERVERCREATIONSCREEN.INVALIDCLANSETTINGS_BODY,
                    {{text=STRINGS.UI.CUSTOMIZATIONSCREEN.OKAY, cb = function() TheFrontEnd:PopScreen() self:SetTab("settings") end}}))
        return false
    elseif not self.server_settings_tab:VerifyValidPassword() then
        TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.SERVERCREATIONSCREEN.INVALIDPASSWORD_TITLE, STRINGS.UI.SERVERCREATIONSCREEN.INVALIDPASSWORD_BODY,
                    {{text=STRINGS.UI.CUSTOMIZATIONSCREEN.OKAY, cb = function() TheFrontEnd:PopScreen() self:SetTab("settings") end}}))
        return false
    -- Check if our season settings are valid (i.e. at least one season has a duration)
    elseif not self:_VerifyValidSeasonSettings() then
        TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.CUSTOMIZATIONSCREEN.INVALIDSEASONCOMBO_TITLE, STRINGS.UI.CUSTOMIZATIONSCREEN.INVALIDSEASONCOMBO_BODY,
                    {{text=STRINGS.UI.CUSTOMIZATIONSCREEN.OKAY, cb = function() TheFrontEnd:PopScreen() self:SetTab(self.default_world_location) end}}))
        return false
    end

    return true
end

function ServerCreationScreen:_VerifyValidSeasonSettings()
    for i,tab in ipairs(self.world_tabs) do
        if not tab:VerifyValidSeasonSettings() then
            return false
        end
    end
    return true
end

function ServerCreationScreen:CheckForDisabledMods()

    local function isModEnabled(mod, enabledmods)
        for _,modname in pairs(enabledmods) do
            if mod == modname then
                return true
            end
        end
        return false
    end

    local disabled = {}

    local savedmods = SaveGameIndex:GetEnabledMods(self.saveslot)
    local currentlyenabledmods = ModManager:GetEnabledServerModNames()

    for modname,_ in pairs(savedmods) do
        if not isModEnabled(modname, currentlyenabledmods) then
            table.insert(disabled, modname)
        end
    end

    return disabled
end

function ServerCreationScreen:OnChangeGameMode(selected_mode)
    for i,tab in ipairs(self.world_tabs) do
		tab:OnChangeGameMode(selected_mode)
    end

    self:MakeDirty()
end

function ServerCreationScreen:SetLevelLocations(level_locations)
	level_locations = level_locations or SERVER_LEVEL_LOCATIONS

	if self.current_level_locations ~= level_locations then
		self.current_level_locations = level_locations
		self.default_world_location = level_locations[1]

		for i, tab in ipairs(self.world_tabs) do
			tab:OnChangeLevelLocations(level_locations)
		end

		self:MakeDirty()
	end
end

function ServerCreationScreen:BuildModsMenu(menu_items, subscreener)
    -- We don't have enough for the full menu outline, so shrink it down.
    for i,item in ipairs(menu_items) do
        item.widget.hover_overlay:SetSize(260,68)
        item.widget.hover_overlay:SetPosition(-90,0)
    end
    -- Menu must share a parent with mods_tab (so menu is hidden along with
    -- tab), but passing ModsTab here doesn't work (nothing responds to
    -- clicks). Instead, we have mods_root that's only used for visibility and
    -- this menu.
    local menu = self.mods_root:AddChild(TEMPLATES.StandardMenu(menu_items, 38, nil, nil, true))
    menu:SetPosition(-444, 170)
    return menu
end

function ServerCreationScreen:RepositionModsButtonMenu(allmodsmenu, selectedmodmenu)
    allmodsmenu:SetPosition(-570, -250)
    selectedmodmenu:SetPosition(120, -250)
end

function ServerCreationScreen:DirtyFromMods(slotnum)
    self:UpdateModeSpinner(slotnum)
    self:UpdateButtons(slotnum)
    self:MakeDirty()
    for i,tab in ipairs(self.world_tabs) do
        tab:Refresh()
    end
end

function ServerCreationScreen:MakeDirty()
    self.dirty = true
end

function ServerCreationScreen:MakeClean()
    self.dirty = false
end

function ServerCreationScreen:IsDirty()
    return self.dirty
end

function ServerCreationScreen:Cancel()
    if self:IsDirty() then
        TheFrontEnd:PushScreen(
            PopupDialogScreen( STRINGS.UI.SERVERCREATIONSCREEN.CANCEL_TITLE, STRINGS.UI.SERVERCREATIONSCREEN.CANCEL_BODY,
              { 
                { 
                    text = STRINGS.UI.SERVERCREATIONSCREEN.OK, 
                    cb = function()
                        TheFrontEnd:PopScreen()
                        self:MakeClean()
                        self:Cancel()
                    end
                },
                
                { 
                    text = STRINGS.UI.SERVERCREATIONSCREEN.CANCEL, 
                    cb = function()
                        TheFrontEnd:PopScreen()                 
                    end
                }
              }
            )
        )       
    else
        self:Disable()
        self.server_settings_tab:SetEditingTextboxes(false)
        TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()
            self.mods_tab:Cancel()
            TheFrontEnd:PopScreen()
            TheFrontEnd:Fade(FADE_IN, SCREEN_FADE_TIME)
        end)
    end
end

function ServerCreationScreen:OnControl(control, down)
    if ServerCreationScreen._base.OnControl(self, control, down) then return true end

    if not down then
        if control == CONTROL_CANCEL then 
            self:Cancel()
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        else
            if control == CONTROL_OPEN_CRAFTING then
                self:SetTab(nil, -1)
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
            elseif control == CONTROL_OPEN_INVENTORY then
                self:SetTab(nil, 1)
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
            elseif self.saveslot < 0 or SaveGameIndex:IsSlotEmpty(self.saveslot) then
                if control == CONTROL_PAUSE and TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
                    self:Create()
                    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
                else
                    return false
                end
            else
                if control == CONTROL_MAP and TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
                    self:DeleteSlot(self.saveslot)
                    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
                elseif control == CONTROL_PAUSE and TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
                    self:Create()
                    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
                else
                    return false
                end
            end
        end

        return true
    end
end

function ServerCreationScreen:RefreshNavButtons()
    if self.save_slots == nil then

        self.save_slots = {}
        local menu_items = {}

        for i = 1, NUM_SAVE_SLOTS do
            local btn = self:MakeSaveSlotButton(i)
            table.insert(menu_items, { widget = btn })
            table.insert(self.save_slots, btn)
        end

        table.insert(menu_items, { widget = TEMPLATES.MenuButton(
                STRINGS.UI.SERVERCREATIONSCREEN.BANS,
                function()
                    self:_ShowContentPanel("bans")
                    self.menu.items[1]:Select() -- bans is the bottom (aka first) item
                end,
                STRINGS.UI.SERVERCREATIONSCREEN.TOOLTIP_BANS, 
                self.tooltip
            )})
        menu_items = table.reverse(menu_items)
        self.menu = self.root:AddChild(TEMPLATES.StandardMenu(menu_items, 65, nil, nil, true))
    end

    for i = 1, NUM_SAVE_SLOTS do
        self:_RefreshSlot(i)
    end
end

function ServerCreationScreen:MakeSaveSlotButton(slotnum)
    local btn = TEMPLATES.PortraitIconMenuButton("", function() self:OnClickSlot(slotnum) end, "", self.tooltip)
    btn.slot = slotnum

    btn.UpdateButtonName = function(_)
        local isempty = SaveGameIndex:IsSlotEmpty(btn.slot)
        local isnoname = false
        local slotName
        if isempty then
            slotName = STRINGS.UI.SERVERCREATIONSCREEN.NEWGAME
        else
            slotName = SaveGameIndex:GetSlotServerData(btn.slot).name or ""
            if #slotName <= 0 then
                slotName = STRINGS.UI.SERVERCREATIONSCREEN.NONAMEGAME
                isnoname = true
            end
        end
        local truncate = not (isempty or isnoname)
        -- MenuButton uses SetRegionSize, so we cannot use SetTruncatedString
        -- (causes infinite loops).
        local can_support_truncation = false
        if truncate and can_support_truncation then
            btn:SetText("")
            btn.text:SetTruncatedString(slotName, 140, 28, true)
        else
            btn:SetText(slotName)
        end
    end
    return btn
end

function ServerCreationScreen:_RefreshSlot(slotnum)
    local btn = self.save_slots[slotnum]
    btn:UpdateButtonName()

    local isempty = SaveGameIndex:IsSlotEmpty(slotnum)
    if isempty then
        self.slot_character_cache[slotnum] = { character = "" }
    elseif self.slot_character_cache[slotnum] == nil then
        -- SaveGameIndex:LoadSlotCharacter is not cheap! Use it in FE only.
        -- V2C: This comment is here as a warning to future copy&pasters - __-"
        self.slot_character_cache[slotnum] = { character = SaveGameIndex:LoadSlotCharacter(slotnum) or "" }
    end

    local cache = self.slot_character_cache[slotnum]
    if cache.atlas == nil then
        cache.atlas = "images/saveslot_portraits"
        if not table.contains(DST_CHARACTERLIST, cache.character) then
            if table.contains(MODCHARACTERLIST, cache.character) then
                cache.atlas = cache.atlas.."/"..cache.character
            else
                cache.character = #cache.character > 0 and "mod" or "unknown"
            end
        end
        cache.atlas = cache.atlas..".xml"
    end

    btn.character_atlas = cache.atlas
    btn.character = cache.character
    btn.isempty = isempty

    self:_UpdateMenuButton(slotnum)

    return btn
end

function ServerCreationScreen:OnClickSlot(slotnum, goToSettings)
    self:_ShowContentPanel("slots")

    local lastslot = self.saveslot
    self.saveslot = slotnum
    local selected_slot = self.save_slots[slotnum] or self.save_slots[1]

    self.menu:UnselectAll()
    selected_slot:Select()
    self.default_focus = selected_slot

    local dirty = self:IsDirty()

    self:UpdateTabs(slotnum, lastslot)

    -- Don't allow changing tabs to dirty us. User couldn't possibly have
    -- changed anything yet (but our init code has).
    if not dirty and self:IsDirty() then
        self:MakeClean()
    end

    self:UpdateTitle(slotnum)

    if goToSettings then
        self:SetTab("settings")
    end
end

function ServerCreationScreen:MakeSettingsTab()
    self.server_settings_tab = self.detail_panel:AddChild(ServerSettingsTab({}, self))
    self.server_settings_tab:SetPosition(170,5)
    return self.server_settings_tab
end

function ServerCreationScreen:MakeWorldTab(location_index)
    self.world_tabs = self.world_tabs or {}
    self.world_tabs[location_index] = self.detail_panel:AddChild(WorldCustomizationTab(location_index, self))
    return self.world_tabs[location_index]
end

function ServerCreationScreen:MakeModsTab()
    -- mods_root must exist before mods_tab! See BuildModsMenu.
    self.mods_root = self.detail_panel:AddChild(Widget("mods_root"))
    local settings = {
        is_configuring_server = true,
        details_width = 360,
        are_servermods_readonly = false,
    }
    self.mods_tab = self.mods_root:AddChild(ModsTab(self, settings))
    self.mods_tab:MoveToBack() -- behind mods menu
    self.mods_tab:SetPosition(10,0)

    self.mods_root:SetPosition(140,0)
    self.mods_root.focus_forward = self.mods_tab
    return self.mods_root
end

function ServerCreationScreen:MakeSnapshotTab()
    local function cb()
        self:ClearSlotCache(self.saveslot)
        self:RefreshNavButtons()
        self:OnClickSlot(self.saveslot)
    end

    self.snapshot_tab = self.detail_panel:AddChild(SnapshotTab(cb))
    return self.snapshot_tab
end

function ServerCreationScreen:MakeBansPanel()
    self.bans_tab = self.root:AddChild(BanTab(self))
    self.bans_tab:SetPosition(260, 0)
    return self.bans_tab
end

-- Similar to SetTab, but for swapping between slots tabs and bans.
function ServerCreationScreen:_ShowContentPanel(destination)
    self.menu:UnselectAll()
    if destination == "slots" then
        self.bans_tab:Hide()
        self.detail_panel:Show()
        self.world_config_tabs:Show()
        self.server_buttons:Show()
    else
        self.bans_tab:Show()
        self.detail_panel:Hide()
        self.world_config_tabs:Hide()
        self.server_buttons:Hide()
    end
end

local function MakeImgButton(parent, xPos, yPos, text, onclick, style)
    if not parent or not xPos or not yPos or not text or not onclick or not style then return end

    local btn
    if style == "create" then
        btn = parent:AddChild(TEMPLATES.StandardButton(onclick, text))
        btn:SetScale(.6)
    elseif style == "delete" then
        btn = parent:AddChild(TEMPLATES.StandardButton(onclick, text, nil, {"images/button_icons.xml", "delete.tex"}))
        btn:SetScale(.6)
    end
    
    btn:SetPosition(xPos, yPos)
    btn:SetOnClick(onclick)

    return btn
end

function ServerCreationScreen:_BuildTabMenu(subscreener)
    local worldgen = {}
    local tabs = {
        { key = "settings", text = STRINGS.UI.SERVERCREATIONSCREEN.SERVERSETTINGS, },
    }
    for i,tab in ipairs(self.world_tabs) do
        local entry = tab:BuildMenuEntry()
        table.insert(tabs, entry)
        table.insert(worldgen, entry)
    end
    table.insert(tabs, { key = "mods",     text = STRINGS.UI.MAINSCREEN.MODS,                     })
    table.insert(tabs, { key = "snapshot", text = STRINGS.UI.SERVERCREATIONSCREEN.SNAPSHOTS,      })
    self.world_config_tabs = self.detail_panel_frame:AddChild(subscreener:MenuContainer(HeaderTabs, tabs))
    self.world_config_tabs:SetPosition(0, dialog_size_y/2 + 27)
    self.world_config_tabs:MoveToBack()

    subscreener.titles.settings = STRINGS.UI.SERVERCREATIONSCREEN.SERVERSETTINGS_LONG
    for i,entry in ipairs(worldgen) do
        subscreener.titles[entry.key] = subfmt(STRINGS.UI.SERVERCREATIONSCREEN.WORLD_LONG_FMT, {location = entry.text})
    end

    -- Subscreener wants a Menu
    return self.world_config_tabs.menu
end

function ServerCreationScreen:MakeButtons()
    self.cancel_button = self.root:AddChild(TEMPLATES.BackButton(function() self:Cancel() end))
    self.create_button = MakeImgButton(self.server_buttons, 325, bottom_button_y, STRINGS.UI.SERVERCREATIONSCREEN.CREATE, function() self:Create() end, "create")
    self.delete_button = MakeImgButton(self.server_buttons, -325, bottom_button_y, STRINGS.UI.SERVERCREATIONSCREEN.DELETE_SLOT, function() self:DeleteSlot(self.saveslot) end, "delete")
    if TheInput:ControllerAttached() then
        self.cancel_button:Hide()
        self.create_button:Hide()
        self.delete_button:Hide()
    end
end

function ServerCreationScreen:_DoFocusHookups()
    -- This is for register focus change dir to return back to the current save slot
    local getfocuscancelorsaveslot = function() return self.cancel_button ~= nil and self.cancel_button:IsVisible() and self.cancel_button or self.default_focus end

    self.detail_panel:SetFocusChangeDir(MOVE_LEFT, self.menu)
    self.detail_panel:SetFocusChangeDir(MOVE_DOWN, self.create_button)
    self.bans_tab:SetFocusChangeDir(MOVE_LEFT, self.menu)

    local toactivetab = function()
        if self.bans_tab:IsVisible() then
            return self.bans_tab
        else
            local fn = self.tabscreener:GetActiveSubscreenFn()
            return fn()
        end
    end
    self.menu:SetFocusChangeDir(MOVE_RIGHT, toactivetab)

    if self.cancel_button ~= nil then
        self.cancel_button:SetFocusChangeDir(MOVE_RIGHT, self.delete_button or toactivetab)
        self.cancel_button:SetFocusChangeDir(MOVE_UP, self.menu.items[1])
	    self.menu:SetFocusChangeDir(MOVE_DOWN, self.cancel_button)
    end

    if self.create_button ~= nil then
        self.create_button:SetFocusChangeDir(MOVE_UP, function()
            return (self.mods_tab:IsVisible() and self.mods_tab.modlinkbutton)
                or (self.bans_tab:IsVisible() and self.bans_tab.clear_button:IsVisible() and self.bans_tab.clear_button:IsEnabled() and self.bans_tab.clear_button)
                or toactivetab()
        end)
        self.create_button:SetFocusChangeDir(MOVE_LEFT, function()
            return self.delete_button
        end)
        self.delete_button:SetFocusChangeDir(MOVE_LEFT, function()
            return (self.mods_tab:IsVisible() and self.mods_tab.updateallbutton)
                or getfocuscancelorsaveslot()
        end)
        self.delete_button:SetFocusChangeDir(MOVE_RIGHT, function()
            return self.create_button
        end)
        self.delete_button:SetFocusChangeDir(MOVE_UP, function()
            return (self.mods_tab:IsVisible() and self.mods_tab.modlinkbutton)
                or (self.bans_tab:IsVisible() and self.bans_tab.clear_button:IsVisible() and self.bans_tab.clear_button:IsEnabled() and self.bans_tab.clear_button)
                or toactivetab()
        end)
    end
end

function ServerCreationScreen:SetTab(tabName, direction)
    if not tabName and not direction then return end

    if direction then
        tabName = self.tabscreener:GetKeyRelativeToCurrent(direction)
    end

    assert(tabName)
    self.tabscreener:OnMenuButtonSelected(tabName)
end

function ServerCreationScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

    if self.saveslot > 0 or not SaveGameIndex:IsSlotEmpty(self.saveslot) then
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MAP) .. " " .. STRINGS.UI.SERVERCREATIONSCREEN.DELETE_SLOT)
    end

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_OPEN_CRAFTING).."/"..TheInput:GetLocalizedControl(controller_id, CONTROL_OPEN_INVENTORY).. " " .. STRINGS.UI.HELP.CHANGE_TAB)

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_PAUSE).." "..(self.delete_button:IsEnabled() and STRINGS.UI.SERVERCREATIONSCREEN.RESUME or STRINGS.UI.SERVERCREATIONSCREEN.CREATE))

    return table.concat(t, "  ")
end

return ServerCreationScreen
