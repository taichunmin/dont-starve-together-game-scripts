local WorldSettingsTab = require "widgets/redux/worldsettings/worldsettingstab"
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
local Text = require "widgets/text"

local KitcoonPuppet = require "widgets/kitcoonpuppet"
local Levels = require("map/levels")

require("constants")
require("tuning")


local num_rows = 9
local row_height = 60
local dialog_size_x = 1000
local dialog_size_y = row_height*(num_rows + 0.25)

local ServerCreationScreen = Class(Screen, function(self, prev_screen, save_slot)
    Screen._ctor(self, "ServerCreationScreen")

    -- Defer accessing this table until screen creation to give mods a chance.
    -- Still not awesome, but mostly we require location indexes at this point
    -- and these names are just for tab labels. We only support worlds with 2
    -- locations through the UI.

    self.server_slot_screen = prev_screen

	self.current_level_locations = SERVER_LEVEL_LOCATIONS
    self.default_world_location = SERVER_LEVEL_LOCATIONS[1]

    TheSim:PauseFileExistsAsync(true)

    self.save_slot = save_slot

	self.letterbox = self:AddChild(TEMPLATES.old.ForegroundLetterbox())

    self.root = self:AddChild(TEMPLATES.ScreenRoot())
    self.bg = self.root:AddChild(TEMPLATES.PlainBackground())
    self.onlinestatus = self.bg:AddChild(OnlineStatus())

    self.detail_panel_frame_parent = self.root:AddChild(Widget("detail_frame"))
    self.detail_panel_frame_parent:SetPosition(0, -10)
    self.detail_panel_frame = self.detail_panel_frame_parent:AddChild(TEMPLATES.RectangleWindow(dialog_size_x, dialog_size_y))
    local r,g,b = unpack(UICOLOURS.BROWN_DARK)
    self.detail_panel_frame:SetBackgroundTint(r,g,b,0.6)
    self.detail_panel_frame.top:Hide() -- top crown would cover our tabs.

	self.mods_enabled = IsNotConsole()

    self.dirty = false


    self.title = self.root:AddChild(TEMPLATES.ScreenTitle(STRINGS.UI.SERVERCREATIONSCREEN.HOST_GAME))

    self.kit_puppet = self.root:AddChild(KitcoonPuppet( Profile, nil, {
        {x = -450, y = 220,},
        {x = 470, y = 255,},
        {x = -415, y = -255,},
    } ))

    self.detail_panel = self.detail_panel_frame:InsertWidget( Widget("detail_panel") )

    self:MakeButtons()

    -- the top tabs are subscreens (not the left menu!)
    local tabs = {
        settings = self:MakeSettingsTab(),
    }
    for i,location in ipairs(SERVER_LEVEL_LOCATIONS) do
        -- Avoid using location for worldgen so mods can modified
        -- SERVER_LEVEL_LOCATIONS (which should be handled inside
        -- WorldSettingsTab).
        tabs[location] = self:MakeWorldTab(i)
    end
	if self.mods_enabled then
		tabs.mods     = self:MakeModsTab()
	end
    tabs.snapshot = self:MakeSnapshotTab()

    self.tabscreener = Subscreener(self,
        self._BuildTabMenu,
        tabs
        )

    local function overrideTabFocusHookups(selection)
        local to_menu,to_subscreen = MOVE_LEFT, MOVE_RIGHT
        if self.tabscreener.menu.horizontal then
            to_menu,to_subscreen = MOVE_UP, MOVE_DOWN
        end

        local current_sub_screen = self.tabscreener.sub_screens[selection]
        self.tabscreener.menu:SetFocusChangeDir(to_subscreen, current_sub_screen)
        current_sub_screen:SetFocusChangeDir(to_menu, nil)
    end

    self.tabscreener:SetPostMenuSelectionAction(overrideTabFocusHookups)

    self:_DoFocusHookups()

    self:SetDataOnTabs()
    self:SetTab("settings")

    self:MakeClean() --we're done setting the data, so make sure we're clean.

    self.focus_handler = self:AddChild(Widget("FocusHandler"))
    self.focus_handler.focus_forward = self.tabscreener:GetActiveSubscreenFn()

    self.default_focus = self.focus_handler
end)

function ServerCreationScreen:UpdatePresetMode(mode)
    for i, tab in ipairs(self.world_tabs) do
        tab:SetPresetMode(mode)
    end
end

function ServerCreationScreen:OnNewGamePresetPicked(preset_id)

	self.world_tabs[1]:OnCombinedPresetButton(preset_id)
end


function ServerCreationScreen:SetSecondaryLevel(levelsetting)
    if levelsetting then
        self.world_tabs[2]:AddMultiLevel()
        self.world_tabs[2]:Refresh()
    end
end

function ServerCreationScreen:UpdatePlaystyle(settings_overrides)
	local playstyle = Levels.CalcPlaystyleForSettings(settings_overrides) --self.world_tabs[1].settings_widget:CollectOptions()

	self.server_settings_tab:SetPlaystyle(playstyle)
	self.world_tabs[1]:RefreshPlaystyleIndicator(playstyle)
end

function ServerCreationScreen:GetContentHeight()
    return dialog_size_y
end

function ServerCreationScreen:OnBecomeActive()
    ServerCreationScreen._base.OnBecomeActive(self)
    self:Enable()
	if self.mods_enabled then
		self.mods_tab:OnBecomeActive()
	end
    if self.last_focus then self.last_focus:SetFocus() end

    if self.kit_puppet then
        self.kit_puppet:Enable()
    end
end

function ServerCreationScreen:OnBecomeInactive()
    ServerCreationScreen._base.OnBecomeInactive(self)
    if self.mods_enabled then
        self.mods_tab:OnBecomeInactive()
    end

    if self.kit_puppet then
        self.kit_puppet:Disable()
    end
end

function ServerCreationScreen:OnDestroy()
	if self.mods_enabled then
		self.mods_tab:OnDestroy()
	end
    self._base.OnDestroy(self)
end

function ServerCreationScreen:UpdateModeSpinner(slot)
    self.server_settings_tab:UpdateModeSpinner(slot)
end

function ServerCreationScreen:GetGameMode()
	return self.server_settings_tab:GetGameMode()
end

function ServerCreationScreen:UpdateSaveSlot(new_save_slot)
    self.save_slot = new_save_slot

	if self.mods_enabled then
        self.mods_tab:UpdateSaveSlot(self.save_slot) --needs to happen before server_settings_tab:SetDataForSlot
    end

    self.server_settings_tab:UpdateSaveSlot(self.save_slot)

    for i,tab in ipairs(self.world_tabs) do
        tab:UpdateSaveSlot(self.save_slot)
    end

    self.snapshot_tab:UpdateSaveSlot(self.save_slot)
end

function ServerCreationScreen:SetDataOnTabs()
	if self.mods_enabled then
        self.mods_tab:SetDataForSlot(self.save_slot) --needs to happen before server_settings_tab:SetDataForSlot
    end

	self:SetLevelLocations(nil)

    self.server_settings_tab:SetDataForSlot(self.save_slot)

    for i,tab in ipairs(self.world_tabs) do
        tab:SetDataForSlot(self.save_slot)
    end

    self.snapshot_tab:SetDataForSlot(self.save_slot)

    self:UpdateButtons(self.save_slot)
end

function ServerCreationScreen:CanResume()
    return not ShardSaveGameIndex:IsSlotEmpty(self.save_slot)
end

function ServerCreationScreen:UpdateButtons(slot)

    if self:CanResume() then
        -- Save data
        if self.create_button then self.create_button.text:SetString(STRINGS.UI.SERVERCREATIONSCREEN.RESUME) end
    else
        -- No save data
        if self.create_button then self.create_button.text:SetString(STRINGS.UI.SERVERCREATIONSCREEN.CREATE) end
    end

    if self.mods_enabled then
        self.tabscreener.buttons.mods:SetText(STRINGS.UI.MAINSCREEN.MODS.." ("..self.mods_tab:GetNumberOfModsEnabled()..")")
    end
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

function ServerCreationScreen:Create(warnedOffline, warnedDisabledMods, warnedOutOfDateMods)
    local function onCreate()
        self.server_settings_tab:SetEditingTextboxes(false)

        local serverdata = self.server_settings_tab:GetServerData()
        local worldoptions = {}
        local copyoptions = {}
        local Customize = require("map/customize")
        local masteroptions = Customize.GetMasterOptions()
        for i,tab in ipairs(self.world_tabs) do
            worldoptions[i] = tab:CollectOptions()

            if worldoptions[i] ~= nil then
                if i == 1 then
                    if worldoptions[1].overrides then
                        for override, value in pairs(worldoptions[1].overrides) do
                            if masteroptions[override] then
                                copyoptions[override] = value
                            end
                        end
                    end
                else
                    if worldoptions[i].overrides == nil then
                        worldoptions[i].overrides = {}
                    end
                    for override, value in pairs(copyoptions) do
                        worldoptions[i].overrides[override] = value
                    end
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
		if self.mods_enabled then
			self.mods_tab:Apply()
        else
            ShardSaveGameIndex:Save()
		end

        -- Fill serverInfo object
        local cluster_info = {}

        local mod_data = DataDumper(ShardSaveGameIndex:GetSlotEnabledServerMods(self.save_slot), nil, false)
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

        local function onsaved()
            self:Disable()

            local is_multi_level = world2datastring ~= ""
            local encode_user_path = serverdata.encode_user_path == true
            local use_legacy_session_path = serverdata.use_legacy_session_path == true
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
						if IsSteam() then
	                        OnNetworkDisconnect("ID_DST_DEDICATED_SERVER_STARTUP_FAILED", false, false, {help_button = {text=STRINGS.UI.MAINSCREEN.GETHELP, cb = function() VisitURL("https://support.klei.com/hc/en-us/articles/4407489414548") end}})
						else
	                        OnNetworkDisconnect("ID_DST_DEDICATED_SERVER_STARTUP_FAILED", false, false)
						end
                        TheSystemService:StopDedicatedServers()
                    end)

                TheFrontEnd:PushScreen(launchingServerPopup)
            end

            local save_to_cloud = self.save_slot > CLOUD_SAVES_SAVE_OFFSET
            local use_zip_format = Profile:GetUseZipFileForNormalSaves()

            -- Note: StartDedicatedServers launches both dedicated and non-dedicated servers... ~gjans
            if not TheSystemService:StartDedicatedServers(self.save_slot, is_multi_level, cluster_info, encode_user_path, use_legacy_session_path, save_to_cloud, use_zip_format) then
                if launchingServerPopup ~= nil then
                    launchingServerPopup:SetErrorStartingServers()
                end
                self:Enable()
            elseif not is_multi_level then
                -- Collect the tags we want and set the tags string now that we have our mods enabled
                local function onsaved()
                    ShardSaveGameIndex.slot_cache[self.save_slot] = nil
                    assert(ShardSaveGameIndex:GetShardIndex(self.save_slot, "Master"), "failed to save shardindex.")

					TheNet:SetServerPlaystyle(serverdata.playstyle or PLAYSTYLE_DEFAULT)
                    TheNet:SetServerTags(BuildTagsStringHosting(self, worldoptions))
                    DoLoadingPortal(function()
                        StartNextInstance({ reset_action = RESET_ACTION.LOAD_SLOT, save_slot = self.save_slot })
                    end)
                end
                local masterShardGameIndex = ShardSaveGameIndex:GetShardIndex(self.save_slot, "Master", true)
                local defaultserverdata = GetDefaultServerData()
                defaultserverdata.encode_user_path = encode_user_path
                defaultserverdata.use_legacy_session_path = use_legacy_session_path
                masterShardGameIndex:SetServerShardData(nil, defaultserverdata, onsaved)
            end
        end

        if ShardSaveGameIndex:IsSlotEmpty(self.save_slot) then
            local starts = Profile:GetValue("starts") or 0
            Profile:SetValue("starts", starts + 1)
            Profile:Save(onsaved)
        else
            onsaved()
        end

        --V2C: NO MORE CODE HERE!
        --     onsaved callback may trigger StartNextInstance!
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
    if not warnedOutOfDateMods and self.mods_enabled then
        outofdatemods = self.mods_tab:GetOutOfDateEnabledMods()
    end

    -- Warn if they're starting an offline game that it will always be offline
    if warnedOffline ~= true and not self.server_settings_tab:GetOnlineMode() then
        local offline_mode_body = ""
        if not ShardSaveGameIndex:IsSlotEmpty(self.save_slot) then
            offline_mode_body = TheInventory:HasSupportForOfflineSkins() and STRINGS.UI.SERVERCREATIONSCREEN.OFFLINEMODEBODYRESUME_CANSKIN or STRINGS.UI.SERVERCREATIONSCREEN.OFFLINEMODEBODYRESUME
        else
            offline_mode_body = TheInventory:HasSupportForOfflineSkins() and STRINGS.UI.SERVERCREATIONSCREEN.OFFLINEMODEBODYCREATE_CANSKIN or STRINGS.UI.SERVERCREATIONSCREEN.OFFLINEMODEBODYCREATE
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
        local body = STRINGS.UI.SERVERCREATIONSCREEN.ONLINEONLYBODY
        if IsRail() then
            body = STRINGS.UI.SERVERCREATIONSCREEN.ONLINEONLYBODY_RAIL
		elseif IsConsole() then
			body = STRINGS.UI.SERVERCREATIONSCREEN.ONLINEONLYBODY_PS4
        end
        local online_only_popup = PopupDialogScreen(STRINGS.UI.SERVERCREATIONSCREEN.ONLINEONYTITLE, body,
                            {
                                {text=STRINGS.UI.SERVERCREATIONSCREEN.OK, cb = function()
                                    TheFrontEnd:PopScreen()
                                end}
                            })
        self.last_focus = TheFrontEnd:GetFocusWidget()
        TheFrontEnd:PushScreen(online_only_popup)
    -- Can't start a game with mods whose dependencies aren't installed
    elseif not KnownModIndex:GetModDependenciesEnabled() then
        local dependent_mods_popup = PopupDialogScreen(STRINGS.UI.MODSSCREEN.REQUIRED_MODS_DOWNLOADING_TITLE,
            STRINGS.UI.MODSSCREEN.REQUIRED_MODS_DOWNLOADING,
            {
                {text=STRINGS.UI.SERVERCREATIONSCREEN.OK, cb = function()
                    TheFrontEnd:PopScreen()
                end}
            })
        self.last_focus = TheFrontEnd:GetFocusWidget()
        TheFrontEnd:PushScreen(dependent_mods_popup)
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

    local savedmods = ShardSaveGameIndex:GetSlotEnabledServerMods(self.save_slot)
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
        --Zachary: hover_overlay is much larger to account for the scale of its(ImageButton) parent
        item.widget.hover_overlay:SetSize(260,68)
        item.widget.hover_overlay:SetPosition(-90,0)
        item.widget.bg:ScaleToSize(140,68)
        item.widget.bg:SetPosition(-55,0)
        item.widget.text:SetRegionSize(140,40)
        item.widget.text:SetPosition(-55,0)
        item.widget.text_shadow:SetRegionSize(140,40)
        item.widget.text_shadow:SetPosition(-55,0)
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
    selectedmodmenu:SetPosition(280, -250)
end

function ServerCreationScreen:ShowWorkshopDownloadingNotification()
	if self.workshop_indicator ~= nil then
		return
	end

	self.workshop_indicator = self.mods_tab:AddChild(Widget("workshop_indicator"))
    self.workshop_indicator:SetPosition(-520, -40)

	local text = self.workshop_indicator:AddChild(Text(BODYTEXTFONT, 18, STRINGS.UI.MODSSCREEN.DOWNLOADING_MODS, UICOLOURS.GOLD_UNIMPORTANT))
    text:SetPosition(0, -27)

	local image = self.workshop_indicator:AddChild(Image("images/avatars.xml", "loading_indicator.tex"))
	local function dorotate() image:RotateTo(0, -360, .75, dorotate) end
	dorotate()
	image:SetTint(unpack(UICOLOURS.GOLD_UNIMPORTANT))
end

function ServerCreationScreen:RemoveWorkshopDownloadingNotification()
	if self.workshop_indicator ~= nil then
		self.workshop_indicator:Kill()
		self.workshop_indicator = nil
	end
end

function ServerCreationScreen:DirtyFromMods(slot)
    self:UpdateModeSpinner(slot)
    self:UpdateButtons(slot)
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

function ServerCreationScreen:SaveChanges()
    if self:IsDirty() and self:CanResume() then
        local serverdata = self.server_settings_tab:GetServerData()
        ShardSaveGameIndex:SetSlotServerData(self.save_slot, serverdata)
        ShardSaveGameIndex:SetSlotEnabledServerMods(self.save_slot)

        for i, tab in ipairs(self.world_tabs) do
            local options = tab:CollectOptions()
            ShardSaveGameIndex:SetSlotGenOptions(self.save_slot, i == 1 and "Master" or "Caves", options)
        end
        ShardSaveGameIndex:Save()
        self:MakeClean()
    end
end

function ServerCreationScreen:Cancel()
    if self:IsDirty() and self:CanResume() then
        TheFrontEnd:PushScreen(
            PopupDialogScreen( STRINGS.UI.SERVERCREATIONSCREEN.CANCEL_TITLE, STRINGS.UI.SERVERCREATIONSCREEN.CANCEL_BODY,
            {
                {
                    text = STRINGS.UI.SERVERCREATIONSCREEN.SAVECHANGES,
                    cb = function()
                        TheFrontEnd:PopScreen()
                        self:SaveChanges()
                        self:Cancel()
                    end
                },
                {
                    text = STRINGS.UI.SERVERCREATIONSCREEN.DISCARDCHANGES,
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
            if control == CONTROL_MENU_L2 then
                self:SetTab(nil, -1)
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
            elseif control == CONTROL_MENU_R2 then
                self:SetTab(nil, 1)
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
            elseif self.save_slot < 0 or ShardSaveGameIndex:IsSlotEmpty(self.save_slot) then
                if control == CONTROL_MENU_START and TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
                    self:Create()
                    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
                else
                    return false
                end
            else
                if control == CONTROL_MENU_START and TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
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

function ServerCreationScreen:MakeSettingsTab()
    self.server_settings_tab = self.detail_panel:AddChild(ServerSettingsTab(self))
    self.server_settings_tab:SetPosition(0, -70)
    return self.server_settings_tab
end

function ServerCreationScreen:MakeWorldTab(location_index)
    self.world_tabs = self.world_tabs or {}
    self.world_tabs[location_index] = self.detail_panel:AddChild(WorldSettingsTab(location_index, self))
    self.world_tabs[location_index]:SetPosition(0,-40)
    return self.world_tabs[location_index]
end

function ServerCreationScreen:MakeModsTab()
    -- mods_root must exist before mods_tab! See BuildModsMenu.
    self.mods_root = self.detail_panel:AddChild(Widget("mods_root"))
    local settings = {
        is_configuring_server = true,
        details_width = 505,
        are_servermods_readonly = false,
    }
    self.mods_tab = self.mods_root:AddChild(ModsTab(self, settings))
    self.mods_tab:MoveToBack() -- behind mods menu
    self.mods_tab:SetPosition(10,0)

    self.mods_tab.tooltip:SetRegionSize(150,150)
    local x, y = self.mods_tab.tooltip.inst.UITransform:GetLocalPosition()
    self.mods_tab.tooltip:SetPosition(x + 25, y + 25)

    self.mods_root:SetPosition(70,0)
    self.mods_root.focus_forward = self.mods_tab
    return self.mods_root
end

function ServerCreationScreen:MakeSnapshotTab()
    local function cb()
        self.server_settings_tab:ClearCacheFlag()
        self.server_settings_tab:SetDataForSlot(self.save_slot)
    end

    self.snapshot_tab = self.detail_panel:AddChild(SnapshotTab(cb))
    return self.snapshot_tab
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
    if self.mods_enabled then
        table.insert(tabs, { key = "mods", text = STRINGS.UI.MAINSCREEN.MODS, })
    end
    table.insert(tabs, { key = "snapshot", text = STRINGS.UI.SERVERCREATIONSCREEN.SNAPSHOTS, })
    self.world_config_tabs = self.detail_panel_frame:AddChild(subscreener:MenuContainer(HeaderTabs, tabs))
    self.world_config_tabs:SetPosition(0, dialog_size_y/2 + 27)
    self.world_config_tabs:MoveToBack()

    -- Subscreener wants a Menu
    return self.world_config_tabs.menu
end

function ServerCreationScreen:MakeButtons()
    self.cancel_button = self.root:AddChild(TEMPLATES.BackButton(function() self:Cancel() end))
    self.cancel_button:SetPosition(-572, -325)

    self.create_button = self.root:AddChild(TEMPLATES.StandardButton( function() self:Create() end, STRINGS.UI.SERVERCREATIONSCREEN.CREATE))
    self.create_button:SetScale(.6)
    self.create_button:SetPosition(420, -325)

    if TheInput:ControllerAttached() then
        self.cancel_button:Hide()
        self.create_button:Hide()
    end
end

function ServerCreationScreen:_DoFocusHookups()
    -- This is for register focus change dir to return back to the current save slot
    self.detail_panel:SetFocusChangeDir(MOVE_DOWN, self.create_button)

    local toactivetab = self.tabscreener:GetActiveSubscreenFn()

    if self.cancel_button ~= nil then
        self.cancel_button:SetFocusChangeDir(MOVE_RIGHT, toactivetab)
        self.cancel_button:SetFocusChangeDir(MOVE_UP, toactivetab)
    end

    if self.create_button ~= nil then
        self.create_button:SetFocusChangeDir(MOVE_UP, function()
            for i, tab in ipairs(self.world_tabs) do
                if tab:IsVisible() then
                    if not tab.settings_root:IsVisible() then
                        return tab.focus_forward
                    end
                    return tab.activesettingswidget.last_focus
                end
            end
            return (self.mods_tab:IsVisible() and self.mods_tab.modlinkbutton) or
                toactivetab()
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

    self.tabscreener.sub_screens[tabName]:SetFocus()
end

function ServerCreationScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_L2).."/"..TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_R2).. " " .. STRINGS.UI.HELP.CHANGE_TAB)

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_START).." "..(self:CanResume() and STRINGS.UI.SERVERCREATIONSCREEN.RESUME or STRINGS.UI.SERVERCREATIONSCREEN.CREATE))

    return table.concat(t, "  ")
end

return ServerCreationScreen
