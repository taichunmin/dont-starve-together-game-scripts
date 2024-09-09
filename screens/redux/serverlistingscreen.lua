local Screen = require "widgets/screen"
local Grid = require "widgets/grid"
local HeaderTabs = require "widgets/redux/headertabs"
local InputDialogScreen = require "screens/inputdialog"
local PopupDialogScreen = require "screens/redux/popupdialog"
local TextListPopup = require "screens/redux/textlistpopup"
local PlaystylePicker = require "widgets/redux/playstylepicker"
local TEMPLATES = require "widgets/redux/templates"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local ScrollableList = require "widgets/scrollablelist"
local ViewCustomizationModalScreen = require "screens/redux/viewcustomizationmodalscreen"
local ViewPlayersModalScreen = require "screens/viewplayersmodalscreen"
local OnlineStatus = require "widgets/onlinestatus"

local Levels = require("map/levels")

require("constants")
require("util")

local SHOW_PINGS = not IsRail()

local column_offsets_x_pos = -100
local column_offsets_y_pos = 303
local column_offsets ={
	PLAYSTYLE = -65,
    NAME = -45,
    DETAILS = 450, --435 is the minimum
    PLAYERS = 615,
    PING = 669,
}
if not SHOW_PINGS then
    column_offsets.PLAYERS = 667
end
local server_list_width = 800

local dev_color = WEBCOLOURS.PLUM
local mismatch_color = WEBCOLOURS.KHAKI
local beta_color = WEBCOLOURS.SANDYBROWN
local offline_color = UICOLOURS.SLATE
local normal_color = UICOLOURS.IVORY
local hidden_color = UICOLOURS.IVORY_70
local normal_list_item_bg_tint = { 1,1,1,0.5 }

local FONT_SIZE = 35
if JapaneseOnPS4() then
    FONT_SIZE = 35 * 0.75
end

local STRING_MAX_LENGTH = 254 -- http://tools.ietf.org/html/rfc5321#section-4.5.3.1

local function BuildPlaystyleDefs()
	local playstyles = {}

	playstyles[PLAYSTYLE_ANY] = {
		name = STRINGS.UI.PLAYSTYLE_ANY,
	}

	for i, playstyle_id in ipairs(Levels.GetPlaystyles()) do
		playstyles[playstyle_id] = Levels.GetPlaystyleDef(playstyle_id)
	end

	return playstyles
end

local function GetBetaInfoId(tags)
	tags = string.lower(tags)
	for i,beta_info in ipairs(BETA_INFO) do
		if string.find(tags, beta_info.SERVERTAG, 1, true) ~= nil then
			return i
		end
	end

	return 0
end

local function ShouldAllowSave(filters, forced_settings)
    -- Don't save when using forced settings because that probably clobbers
    -- some useful player data.
    if forced_settings then
        return false
    end
    for i,filter in ipairs(filters) do
        if filter.is_forced then
            return false
        end
    end
    return true
end

local ServerListingScreen = Class(Screen, function(self, prev_screen, filters, cb, offlineMode, session_mapping, forced_settings, event_id)
    Screen._ctor(self, "ServerListingScreen")

	ServerPreferences:ClearProfanityFilteredServers()

	self.event_id = event_id or ""

	self.playstyle_defs = BuildPlaystyleDefs()

    self.should_save = ShouldAllowSave(filters, forced_settings)
    self.forced_settings = forced_settings or {}

    self.server_playstyle = {}

    -- Query all data related to user sessions
    self.session_mapping = session_mapping

    self.cb = cb
    self.offlinemode = offlineMode

    self.tickperiod = 0.5
    self.task = nil

    self.unjoinable_servers = 0

    self.letterbox = self:AddChild(TEMPLATES.old.ForegroundLetterbox())

    self.root = self:AddChild(TEMPLATES.ScreenRoot("scaleroot"))
    self.bg = self.root:AddChild(TEMPLATES.PlainBackground())
    self.heading = self.root:AddChild(TEMPLATES.ScreenTitle(STRINGS.UI.MAINSCREEN.BROWSE))
    local x,y = self.heading:GetPosition():Get()
    self.heading:SetPosition(x+10,y) -- move out of way of window curly

    self.view_online = true

    local nav_col = -RESOLUTION_X*.415
    local left_col = -RESOLUTION_X*.047
    local right_col = RESOLUTION_X*.40 - 62

    self.content_root = self.root:AddChild(Widget("content_root"))
    self.content_root:SetPosition(0,7)

    local details_height = 555
    self:MakeDetailPanel(right_col, details_height)

    self:MakeMenuButtons(left_col, right_col, nav_col) --put in this before self.server_list is added so that hover text is on top of the buttons.

    self.server_list = self.content_root:AddChild(Widget("server_list"))
    self.server_list:SetPosition(left_col,0)

    local server_list_x = -server_list_width * 0.2 - left_col
    self.server_list_frame = self.server_list:AddChild(TEMPLATES.RectangleWindow(server_list_width, 555))
    self.server_list_frame:SetPosition(server_list_x,1)
    self.server_list_frame.top:Hide() -- top crown would be behind our title.
    self.server_list_frame.bottom:Hide() -- bottom crown would be behind our sort.
    local r,g,b = unpack(UICOLOURS.BROWN_MEDIUM)
    self.server_list_frame:SetBackgroundTint(r,g,b,0.6)

    self.server_list_titles = self.server_list:AddChild(Widget("server_list_titles"))
    self.server_list_titles:SetPosition(column_offsets_x_pos, column_offsets_y_pos)

    self.server_list_footer = self.server_list:AddChild(Widget("server_list_footer"))
    self.server_list_footer:SetPosition(column_offsets_x_pos, -column_offsets_y_pos)

    self.playstyle_overlay = self.server_list:AddChild(PlaystylePicker(STRINGS.UI.SERVERLISTINGSCREEN.PLAYSTYLE_TITLE, STRINGS.UI.SERVERLISTINGSCREEN.PLAYSTYLE_ANY_DESC))
    self.playstyle_overlay:SetCallback(function(playstyle)
        self:SetServerPlaystyle(playstyle)
    end)
    self.playstyle_overlay:SetPosition(column_offsets_x_pos, 180)

    self.grid_root = self.server_list_frame:InsertWidget(Widget("grid root"))
    self.grid_root:SetPosition(-server_list_width/2 + 55,0)

    self:_MakeServerListHeader()

    self.sort_column = nil

    self.selected_index_actual = -1 -- unfiltered index
    self.selected_server = nil
    self.viewed_servers = {}
    self.servers = {}
    self.filters = {}
    self.sessions = {}

    self.grid_root.server_list_rows = self.grid_root:AddChild(Widget("server_list_rows"))
    self:MakeServerListWidgets()

    local function GetCentreFocus()
        return self:CurrentCenterFocus()
    end

    local function GetRightFocus()
        return self:CurrentRightFocus()
    end

    local function GetBottomFocus()
        return self.sorting_spinner
    end


    self:MakeFiltersPanel(filters, details_height)

    self.onlinestatus = self.root:AddChild(OnlineStatus())

    self:UpdateServerInformation(false)
    self:ToggleShowFilters()
    self:SetServerPlaystyle(self:_GetServerPlaystyle())

    if self.offlinemode then
        assert(not self.forced_settings.online)
        self.connection_spinner.spinner:SetSelected("LAN")
    else
        self.connection_spinner.spinner:SetSelected("online")
    end
    self.connection_spinner.spinner:Changed()

    self:SetSort(Profile:GetValue("serverlistingsort") or "RELEVANCE")
    self:RefreshView(false)


    self.sorting_spinner:SetFocusChangeDir(MOVE_UP, GetCentreFocus)
    self.sorting_spinner:SetFocusChangeDir(MOVE_DOWN, GetCentreFocus)
    self.sorting_spinner:SetFocusChangeDir(MOVE_RIGHT, GetRightFocus)

    self.servers_scroll_list:SetFocusChangeDir(MOVE_DOWN, GetBottomFocus)
    self.servers_scroll_list:SetFocusChangeDir(MOVE_RIGHT, GetRightFocus)

    self.filters_scroll_list:SetFocusChangeDir(MOVE_LEFT, GetCentreFocus)

    self.server_details_additional:SetFocusChangeDir(MOVE_LEFT, GetCentreFocus)

    self.playstyle_overlay:SetFocusChangeDir(MOVE_RIGHT, GetRightFocus)

    self.default_focus = GetBottomFocus()
end)

function ServerListingScreen:_SetTab(tab)
    if tab == "LAN" then
        self.view_online = false
        self:SearchForServers()
        self.server_playstyle.button:Select()
        self.server_playstyle.button:SetText(STRINGS.UI.PLAYSTYLE_ANY)
    elseif tab == "online" then
        self.view_online = true
        self:SearchForServers()
        self.server_playstyle.button:Unselect()
        if self.server_playstyle.id ~= nil then
            self.server_playstyle.button:SetText(self.playstyle_defs[self.server_playstyle.id].name)
        end
    end
    self:ShowPlaystylePicker()
end

function ServerListingScreen:_GetServerPlaystyle()
    if self.forced_settings.playstyle then
        return self.forced_settings.playstyle
    end
    return Profile:GetValue("browser_playstyle")
end

function ServerListingScreen:SetServerPlaystyle(playstyle_id)
    self.server_playstyle.id = playstyle_id

    if playstyle_id ~= nil then
        self.title:SetString(string.format(STRINGS.UI.SERVERLISTINGSCREEN.SERVER_LIST_TITLE_PLAYSTYLE, self.playstyle_defs[playstyle_id].name))
        self.server_playstyle.button:SetText(self.playstyle_defs[playstyle_id].name)
        self.playstyle_overlay:SetSelected(playstyle_id)
    end

    if self.should_save then
        Profile:SetValue("browser_playstyle", playstyle_id)
    end

    self:ShowPlaystylePicker()

    self:DoFiltering()
end

function ServerListingScreen:ShowPlaystylePicker()
    if self.view_online then
        if self.server_playstyle.id == nil then
            self.playstyle_overlay:Show()
            self.grid_root:Hide()
            self.server_list_titles:Hide()
            self.title:SetString(STRINGS.UI.SERVERLISTINGSCREEN.SERVER_LIST_TITLE)
            self.server_playstyle.button:Select()
        else
            self.playstyle_overlay:Hide()
            self.grid_root:Show()
            self.server_list_titles:Show()
            --server_playstyle:Show()
            self.title:SetString(string.format(STRINGS.UI.SERVERLISTINGSCREEN.SERVER_LIST_TITLE_PLAYSTYLE, self.playstyle_defs[self.server_playstyle.id].name))
            self.server_playstyle.button:Unselect()
        end
    else
        self.playstyle_overlay:Hide()
        self.grid_root:Show()
        self.server_list_titles:Show()
        --self.server_playstyle:Hide()
        self.title:SetString(STRINGS.UI.SERVERLISTINGSCREEN.SERVER_LIST_TITLE)
    end

    if self:CurrentRightFocus() ~= nil then
        self:CurrentRightFocus():SetFocus()
    elseif self:CurrentCenterFocus() ~= nil then
        self:CurrentCenterFocus():SetFocus()
    end
end


function ServerListingScreen:UpdateServerInformation( show )
    if show then
        if self.filters_shown then
            self:ToggleShowFilters(true)
        end
        self.details_tab:Show()
        if self.selected_server ~= nil then
            self.server_details_additional:Show()-- self.detail_scroll_list:Show()
        end
    else
        if self.filters_shown then
            self.details_tab:Hide()
        end
        self.server_details_additional:Hide()-- self.detail_scroll_list:Hide()
    end
end

function ServerListingScreen:ToggleShowFilters(forcehide)
    if not self.filters_shown and not forcehide then
        self.filters_shown = true
        self:UpdateServerInformation( false )
        self.filters_header:SelectButton(1)
        if TheInput:ControllerAttached() and self.server_details_additional.focus then--self.detail_scroll_list.focus then
            self.filters_scroll_list:SetFocus()
        end
        self.filters_scroll_list:Show()
        self.server_details_additional:Hide()--self.detail_scroll_list:Hide()
    else
        self.filters_scroll_list:Hide()
        if self.selected_server ~= nil then
            self.server_details_additional:Show()--self.detail_scroll_list:Show()
        end
        if TheInput:ControllerAttached() and self.filters_scroll_list.focus then
            self.server_details_additional:SetFocus()--self.detail_scroll_list:SetFocus()
        end
        self.filters_shown = false
        self.filters_header:SelectButton(2)
        self:UpdateServerInformation( true )
    end
end

function ServerListingScreen:OnBecomeActive()
    ServerListingScreen._base.OnBecomeActive(self)
    self:Enable()

    self:StartPeriodicRefreshTask()
end

function ServerListingScreen:OnBecomeInactive()
    ServerListingScreen._base.OnBecomeInactive(self)

    self:StopPeriodicRefreshTask()
end

function ServerListingScreen:OnDestroy()
    --self.prev_screen:TransferPortalOwnership(self, self.prev_screen)
    self._base.OnDestroy(self)
end

local function tchelper(first, rest)
  return first:upper()..rest:lower()
end

function ServerListingScreen:Join(warnedOffline, warnedLanguage, warnedPaused)
    if self.selected_server ~= nil then
		local beta = GetBetaInfoId(self.selected_server.tags)
        if BRANCH == "release" and beta > 0 then
			local beta_info = BETA_INFO[beta]
            local beta_popup = PopupDialogScreen(STRINGS.UI.NETWORKDISCONNECT.TITLE[beta_info.VERSION_MISMATCH_STRING], STRINGS.UI.NETWORKDISCONNECT.BODY[beta_info.VERSION_MISMATCH_STRING],
                                {
                                    {text=STRINGS.UI.MODSSCREEN.MODLINK_MOREINFO, cb = function()
                                        VisitURL(beta_info.URL)
                                        TheFrontEnd:PopScreen()
                                    end},
                                    {text=STRINGS.UI.SERVERLISTINGSCREEN.CANCEL, cb = function()
                                        TheFrontEnd:PopScreen()
                                    end},
                                })
            self.last_focus = TheFrontEnd:GetFocusWidget()
            TheFrontEnd:PushScreen(beta_popup)
        elseif not warnedOffline and self.selected_server.offline then
            local confirm_offline_popup = PopupDialogScreen(STRINGS.UI.SERVERLISTINGSCREEN.OFFLINEWARNINGTITLE, STRINGS.UI.SERVERLISTINGSCREEN.OFFLINEMODEBODYJOIN,
                                {
                                    {text=STRINGS.UI.SERVERLISTINGSCREEN.OK, cb = function()
                                        -- If player is okay with offline mode, go ahead
                                        TheFrontEnd:PopScreen()
                                        self:Join(true)
                                    end},
                                    {text=STRINGS.UI.SERVERLISTINGSCREEN.CANCEL, cb = function()
                                        TheFrontEnd:PopScreen()
                                    end}
                                })
            self.last_focus = TheFrontEnd:GetFocusWidget()
            TheFrontEnd:PushScreen(confirm_offline_popup)
        elseif IsConsole() and not warnedLanguage and self.view_online and self.event_id == "" and self.selected_server.tags:split(",")[1] ~= STRINGS.PRETRANSLATED.LANGUAGES[LOC.GetLanguage()]:lower() then
            local confirm_language_popup = PopupDialogScreen(STRINGS.UI.SERVERLISTINGSCREEN.SERVER_LANGUAGE_WARNING_TITLE, STRINGS.UI.SERVERLISTINGSCREEN.SERVER_LANGUAGE_WARNING_BODY,
                                {
                                    {text=STRINGS.UI.SERVERLISTINGSCREEN.OK, cb = function()
                                        -- If player is okay with offline mode, go ahead
                                        TheFrontEnd:PopScreen()
                                        self:Join(true, true)
                                    end},
                                    {text=STRINGS.UI.SERVERLISTINGSCREEN.CANCEL, cb = function()
                                        TheFrontEnd:PopScreen()
                                    end}
                                })
            self.last_focus = TheFrontEnd:GetFocusWidget()
            TheFrontEnd:PushScreen(confirm_language_popup)
        elseif not warnedPaused and self.selected_server.serverpaused then
            local confirm_paused_popup = PopupDialogScreen(STRINGS.UI.SERVERLISTINGSCREEN.PAUSEDWARNING_TITLE, STRINGS.UI.SERVERLISTINGSCREEN.PAUSEDWARNING_BODY,
                                {
                                    {text=STRINGS.UI.SERVERLISTINGSCREEN.OK, cb = function()
                                        -- If player is okay with offline mode, go ahead
                                        TheFrontEnd:PopScreen()
                                        self:Join(true, true, true)
                                    end},
                                    {text=STRINGS.UI.SERVERLISTINGSCREEN.CANCEL, cb = function()
                                        TheFrontEnd:PopScreen()
                                    end}
                                })
            self.last_focus = TheFrontEnd:GetFocusWidget()
            TheFrontEnd:PushScreen(confirm_paused_popup)
        else
            local filters = {}
            for i, v in ipairs(self.filters) do
                if v.spinner ~= nil then
                    table.insert(filters, {name=v.name, data=v.spinner:GetSelectedData()})
                elseif v.textbox then
                    table.insert(filters, {name="search", data=v.textbox:GetString()})
                end
            end
            if self.should_save then
                Profile:SetValue("serverlistingsort", self.sorting_spinner.spinner:GetSelectedData())
                Profile:SaveFilters(filters)
            end
			ServerPreferences:RefreshLastSeen(self.servers)
            JoinServer( self.selected_server )
        end
    else
        assert(false, "Invalid server selection")
    end
end

function ServerListingScreen:Report()
    local index = self.selected_index_actual
    local guid = self.servers[index] and self.servers[index].guid
    local servname = string.len(self.servers[index].name) > 18 and string.sub(self.servers[index].name,1,18).."..." or self.servers[index].name
    local report_dialog = InputDialogScreen( STRINGS.UI.SERVERLISTINGSCREEN.REPORTREASON.." ("..servname..")",
                                        {
                                            {
                                                text = STRINGS.UI.SERVERLISTINGSCREEN.OK,
                                                cb = function()
                                                    TheNet:ReportListing(guid, InputDialogScreen:GetText())
                                                    TheFrontEnd:PopScreen()
                                                end
                                            },
                                                                                        {
                                                text = STRINGS.UI.SERVERLISTINGSCREEN.CANCEL,
                                                cb = function()
                                                    TheFrontEnd:PopScreen()
                                                end
                                            },
                                        },
                                    true )
    report_dialog.edit_text.OnTextEntered = function()
        TheNet:ReportListing(guid, InputDialogScreen:GetText())
        TheFrontEnd:PopScreen()
    end
    report_dialog:SetValidChars([[ abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,[]@!()'*+-/?{}" ]]) --'
    TheFrontEnd:PushScreen(report_dialog)
    report_dialog.edit_text:OnControl(CONTROL_ACCEPT, false)
end

local function SetChecked( widget, label, check )
    if check then
        label:SetColour(UICOLOURS.GOLD)
        widget.off_image:Hide()
        widget.bg:Show()
        widget.img:Show()
    else
        label:SetColour(.4,.4,.4,1)
        widget.off_image:Show()
        widget.bg:Hide()
        widget.img:Hide()
    end
end

function ServerListingScreen:ViewServerMods()
    if self.selected_server ~= nil and self.selected_server.mods_enabled then
        local error_msg = nil
        local mods_list = nil
        if self.selected_server.mods_failed_deserialization then
            error_msg = STRINGS.UI.SERVERLISTINGSCREEN.MODS_HIDDEN_MISMATCH
        elseif IsTableEmpty(self.selected_server.mods_description) then
            error_msg = STRINGS.UI.SERVERLISTINGSCREEN.MODS_HIDDEN_LAN
        else
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
            mods_list = {}
            for i,mod in ipairs(self.selected_server.mods_description) do
                table.insert(mods_list, {
                        text = mod.modinfo_name,
                        onclick = BuildOptionalModLink(mod.mod_name),
                    })
            end
        end

        if error_msg then
            TheFrontEnd:PushScreen(PopupDialogScreen(
                    STRINGS.UI.SERVERLISTINGSCREEN.MODSTITLE,
                    error_msg,
                    {{ text = STRINGS.UI.SERVERLISTINGSCREEN.OK, cb = function() TheFrontEnd:PopScreen() end }}))
        else
            TheFrontEnd:PushScreen(TextListPopup(mods_list, STRINGS.UI.SERVERLISTINGSCREEN.MODSTITLE))
        end
    end
end

function ServerListingScreen:ViewServerTags()
    if self.selected_server ~= nil and self.selected_server.tags ~= nil then
        local tags = {}
        for i,v in ipairs(self.selected_server.tags:split(",")) do
            table.insert(tags, {
                    text = v,
            })
        end
        TheFrontEnd:PushScreen(TextListPopup(tags, STRINGS.UI.SERVERLISTINGSCREEN.TAGSTITLE))
    end
end

function ServerListingScreen:ViewServerGroup()
    if self.selected_server ~= nil and self.selected_server.clan_server then
        TheNet:ViewNetProfile(self.selected_server.net_group_id)
    end
end

function ServerListingScreen:ViewServerWorld()
    local worldgenoptions = self:ProcessServerWorldGenData()
    if worldgenoptions ~= nil then
        TheFrontEnd:PushScreen(ViewCustomizationModalScreen(worldgenoptions))
    end
end

function ServerListingScreen:ViewServerPlayers()
    local players = self:ProcessServerPlayersData()
    if type(players) =="table" then
        TheFrontEnd:PushScreen(ViewPlayersModalScreen(players, self.selected_server.max_players))
    end
end

function ServerListingScreen:OnToggleServerName()
	if self.selected_server ~= nil then
		ServerPreferences:ToggleNameAndDescriptionFilter(self.selected_server)

		self:RefreshView(true, true)
	end
end

function ServerListingScreen:ProcessServerGameData()
    if self.selected_server == nil then
        return
    elseif self.selected_server._processed_game_data == nil
        and self.selected_server.game_data ~= nil
        and #self.selected_server.game_data > 0 then
        local success, data = RunInSandboxSafeCatchInfiniteLoops(self.selected_server.game_data)
        if success and data ~= nil then
            self.selected_server._processed_game_data = data
        else
            self.selected_server._processed_game_data = false
        end
    end

    if self.selected_server._processed_game_data == false then
        return
    end
    return self.selected_server._processed_game_data
end

function ServerListingScreen:ProcessServerWorldGenData()
    if self.selected_server == nil then
        return
    elseif self.selected_server._processed_world_gen_data == nil
        and self.selected_server.world_gen_data ~= nil
        and #self.selected_server.world_gen_data > 0 then
        local success, data = RunInSandboxSafeCatchInfiniteLoops(self.selected_server.world_gen_data)
        if success and data ~= nil then
            if type(data) == "table" and type(data.str) == "string" then
                local count = 0
                for _ in pairs(data) do
                    count = count + 1
                    if count > 1 then break end
                end
                --make sure data.str is the only entry in the table
                if count == 1 then
                    local decoded_success, decoded_data = RunInSandboxSafeCatchInfiniteLoops(TheSim:DecodeAndUnzipString(data.str))
                    if decoded_success and decoded_data ~= nil then
                        data = decoded_data
                    else
                        data = false
                    end
                end
            end
            self.selected_server._processed_world_gen_data = data
        else
            self.selected_server._processed_world_gen_data = false
        end
    end

    if self.selected_server._processed_world_gen_data == false then
        return
    end
    return self.selected_server._processed_world_gen_data
end

function ServerListingScreen:ProcessServerPlayersData()
    if self.selected_server == nil then
        return
    elseif self.selected_server._processed_players_data == nil
        and self.selected_server.players_data ~= nil
        and #self.selected_server.players_data > 0 then
        local success, data = RunInSandboxSafeCatchInfiniteLoops(self.selected_server.players_data)
        if success and data ~= nil then
            for i, v in ipairs(data) do
                if table.typecheckedgetfield(v, "string", "colour") then
                    local colourstr = "00000"..v.colour
                    local r = (tonumber(colourstr:sub(-6, -5), 16) or 255) / 255
                    local g = (tonumber(colourstr:sub(-4, -3), 16) or 255) / 255
                    local b = (tonumber(colourstr:sub(-2), 16) or 255) / 255
                    v.colour = { r, g, b, 1 }
                end
            end
            self.selected_server._processed_players_data = data
        else
            self.selected_server._processed_players_data = false
        end
    end

    if self.selected_server._processed_players_data == false then
        return
    end
    return self.selected_server._processed_players_data
end

local function CompareTable(table_a, table_b)
    -- Basic validation
    if table_a==table_b then return true end

    -- Null check
    if table_a == nil or table_b == nil then return false end

    -- Validate type
    if type(table_a) ~= "table" then return false end

    -- Compare meta tables
    local meta_table_a = getmetatable(table_a)
    local meta_table_b = getmetatable(table_b)
    if not CompareTable(meta_table_a,meta_table_b) then return false end

    -- Compare nested tables
    for index,value_a in pairs(table_a) do
        local value_b = table_b[index]
        if not CompareTable(value_a,value_b) then return false end
    end
    for index,value_b in pairs(table_b) do
        local value_a = table_a[index]
        if not CompareTable(value_a,value_b) then return false end
    end

    return true
end

function ServerListingScreen:UpdateServerData(selected_index_actual)
    local sel_serv = TheNet:GetServerListingFromActualIndex(selected_index_actual)
    local hide_name = sel_serv and ServerPreferences:IsNameAndDescriptionHidden(sel_serv) or false
    if sel_serv and (CompareTable(sel_serv, self.selected_server) == false or self.details_hidden_name ~= hide_name) then
        self.selected_server = sel_serv
        self.selected_index_actual = selected_index_actual

		self.details_hidden_name = hide_name

        local filtered_name = ApplyLocalWordFilter(self.selected_server.name, TEXT_FILTER_CTX_SERVERNAME)
        self.details_servername:SetMultilineTruncatedString(
            hide_name and STRINGS.UI.SERVERLISTINGSCREEN.HIDDEN_NAME or filtered_name,
            self.details_servername._align.maxlines,
            self.details_servername._align.maxwidth,
            self.details_servername._align.maxchars,
            true
        )

        local filtered_desc = ApplyLocalWordFilter(self.selected_server.description, TEXT_FILTER_CTX_SERVERNAME)
        self.details_serverdesc:SetMultilineTruncatedString(
            hide_name and STRINGS.UI.SERVERLISTINGSCREEN.HIDDEN_DESCRIPTION or self.selected_server.has_details and (filtered_desc ~= "" and filtered_desc or STRINGS.UI.SERVERLISTINGSCREEN.NO_DESC) or STRINGS.UI.SERVERLISTINGSCREEN.DESC_LOADING,
            self.details_serverdesc._align.maxlines,
            self.details_serverdesc._align.maxwidth,
            self.details_serverdesc._align.maxchars,
            true
        )
        local w,h = self.details_serverdesc:GetRegionSize()
        self.details_serverdesc_bg:SetSize(self.details_serverdesc._align.maxwidth + 50, math.max(150, h + 25))

        self.game_mode_description.text:SetString( GetGameModeString( self.selected_server.mode ) )
        w,h = self.game_mode_description.text:GetRegionSize()
        self.game_mode_description.info_button:SetPosition(w/2 + 20, 1)
        if self.selected_server.mode ~= "" then
            self.game_mode_description.info_button:Unselect()
        else
            self.game_mode_description.info_button:Select()
        end

		if self.selected_server.kleiofficial then
			self.checkbox_dedicated_server.img:SetTexture("images/servericons.xml", "kleiofficial.tex")
			self.dedicated_server_description:SetString(STRINGS.UI.SERVERLISTINGSCREEN.DEDICATED_KLEI_ICON_HOVER)
		else
			self.checkbox_dedicated_server.img:SetTexture("images/servericons.xml", "dedicated.tex")
			self.dedicated_server_description:SetString(STRINGS.UI.SERVERLISTINGSCREEN.ISDEDICATED)
		end

        SetChecked( self.checkbox_dedicated_server, self.dedicated_server_description, self.selected_server.dedicated )
        SetChecked( self.checkbox_pvp, self.pvp_description, self.selected_server.pvp )
        SetChecked( self.checkbox_has_password, self.has_password_description, self.selected_server.has_password )

        if not self.selected_server.mods_enabled then
            self.viewmods_button:SetHoverText(STRINGS.UI.SERVERLISTINGSCREEN.NOMODS)
            self.viewmods_button:Select()
        elseif self.selected_server.offline then
            self.viewmods_button:SetHoverText(STRINGS.UI.SERVERLISTINGSCREEN.VIEWMODS_LAN)
            self.viewmods_button:Select()
        elseif self.selected_server.has_details then
            self.viewmods_button:SetHoverText(STRINGS.UI.SERVERLISTINGSCREEN.VIEWMODS)
            self.viewmods_button:Unselect()
        else
            self.viewmods_button:SetHoverText(STRINGS.UI.SERVERLISTINGSCREEN.MODS_LOADING)
            self.viewmods_button:Select()
        end

        if self.selected_server.tags ~= "" then
            self.viewtags_button:SetHoverText(STRINGS.UI.SERVERLISTINGSCREEN.VIEWTAGS)
            self.viewtags_button:Unselect()
        else
            --V2C: tags are always available in online tab without detailed info
            if self.selected_server.has_details or self.view_online then
                self.viewtags_button:SetHoverText(STRINGS.UI.SERVERLISTINGSCREEN.NOTAGS)
            else
                self.viewtags_button:SetHoverText(STRINGS.UI.SERVERLISTINGSCREEN.TAGS_LOADING)
            end
            self.viewtags_button:Select()
        end

        if self.selected_server.clan_server then
            self.viewgroup_button:SetHoverText(STRINGS.UI.SERVERLISTINGSCREEN.VIEWGROUP)
            self.viewgroup_button:Unselect()
        else
            --V2C: clan id is always available without detailed info
            --if self.selected_server.has_details then
                self.viewgroup_button:SetHoverText(STRINGS.UI.SERVERLISTINGSCREEN.GROUP_NONE)
            --else
            --    self.viewgroup_button:SetHoverText(STRINGS.UI.SERVERLISTINGSCREEN.GROUP_LOADING)
            --end
            self.viewgroup_button:Select()
        end

        local gamedata = self:ProcessServerGameData()
        local day = gamedata ~= nil and type(gamedata.day) == "number" and gamedata.day or STRINGS.UI.SERVERLISTINGSCREEN.UNKNOWN
        self.day_description.text:SetString(STRINGS.UI.SERVERLISTINGSCREEN.DAYDESC..day)

        local seasondesc = self.selected_server.season ~= nil and STRINGS.UI.SERVERLISTINGSCREEN.SEASONS[string.upper(self.selected_server.season)] or nil
        if seasondesc ~= nil and
            gamedata ~= nil and
            type(gamedata.daysleftinseason) == "number" and
            type(gamedata.dayselapsedinseason) == "number" then

            if gamedata.daysleftinseason * 3 <= gamedata.dayselapsedinseason then
                seasondesc = STRINGS.UI.SERVERLISTINGSCREEN.LATE_SEASON_1..seasondesc..STRINGS.UI.SERVERLISTINGSCREEN.LATE_SEASON_2
            elseif gamedata.dayselapsedinseason * 3 <= gamedata.daysleftinseason then
                seasondesc = STRINGS.UI.SERVERLISTINGSCREEN.EARLY_SEASON_1..seasondesc..STRINGS.UI.SERVERLISTINGSCREEN.EARLY_SEASON_2
            end
        end
        self.season_description.text:SetString(seasondesc or STRINGS.UI.SERVERLISTINGSCREEN.UNKNOWN_SEASON)

        local worldgenoptions = self:ProcessServerWorldGenData()
        if worldgenoptions ~= nil then
            self.viewworld_button:Unselect()
            self.viewworld_button:SetHoverText(STRINGS.UI.SERVERLISTINGSCREEN.VIEWWORLD)
        else
            self.viewworld_button:Select()
            self.viewworld_button:SetHoverText(self.selected_server.has_details and STRINGS.UI.SERVERLISTINGSCREEN.WORLD_UNKNOWN or STRINGS.UI.SERVERLISTINGSCREEN.WORLD_LOADING)
        end

        local players = self:ProcessServerPlayersData()
        if players ~= nil then
            self.viewplayers_button:Unselect()
            self.viewplayers_button:SetHoverText(STRINGS.UI.SERVERLISTINGSCREEN.VIEWPLAYERS)
        else
            self.viewplayers_button:Select()
            self.viewplayers_button:SetHoverText(self.selected_server.has_details and STRINGS.UI.SERVERLISTINGSCREEN.PLAYERS_UNKNOWN or STRINGS.UI.SERVERLISTINGSCREEN.PLAYERS_LOADING)
        end

        self.join_button:Enable()
    end
end

function ServerListingScreen:ServerSelected(unfiltered_index)
    if unfiltered_index and self.servers and self.servers[unfiltered_index] ~= nil then
        if self.selected_index_actual ~= unfiltered_index then
            self.selected_index_actual = unfiltered_index
            local server = self.servers[unfiltered_index]
            if string.len(server.row) > 0 then
                TheNet:DownloadServerDetails(server.row)
            end
        end
        self:UpdateServerData(self.selected_index_actual)
        self:UpdateServerInformation(true)
    else
        self:UpdateServerInformation(false)
        self.selected_server = nil
        self.selected_index_actual = -1
        self.details_servername:SetString(STRINGS.UI.SERVERLISTINGSCREEN.NOSERVERSELECTED)
        self.details_serverdesc:SetString("")
        self.join_button:Disable()
    end

    self:_GuaranteeSelectedServerHighlighted()
end

function ServerListingScreen:StartPeriodicRefreshTask()
    if self.task ~= nil then
        self.task:Cancel()
    end
    self.task = self.inst:DoPeriodicTask(self.tickperiod, function() self:RefreshView(false, true) end)
end

function ServerListingScreen:StopPeriodicRefreshTask()
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
end

function ServerListingScreen:SearchForServers()
    self:ServerSelected(nil)
    self.servers = {}
    self.viewed_servers = {}
    local num_servs = #self.servers-self.unjoinable_servers
    if num_servs < 0 then num_servs = 0 end
    self.servers_scroll_list:SetItemsData(self.viewed_servers)

    if num_servs == 0 then
        self.server_count:SetString("("..STRINGS.UI.SERVERLISTINGSCREEN.SEARCHING_SERVERS..")")
    else
        self.server_count:SetString( subfmt(STRINGS.UI.SERVERLISTINGSCREEN.SHOWING_FMT, { viewed = #self.viewed_servers, total = num_servs }) )
    end
    if self.view_online and self.offlinemode then
        self.server_count:SetString("("..STRINGS.UI.SERVERLISTINGSCREEN.NO_CONNECTION..")")
    elseif not self.view_online then
        self.server_count:SetString("("..STRINGS.UI.SERVERLISTINGSCREEN.LAN..")")
    end

    for i, v in ipairs(self.filters) do
        if v.name == "VERSIONCHECK" then
            TheNet:SetCheckVersionOnQuery(v.spinner:GetSelectedData())
        end
    end

    if self.view_online and not self.offlinemode then -- search LAN and online if online
        self.servers_scroll_list.focused_index = 1
        TheNet:SearchServers(self.event_id)
    else -- otherwise just LAN
        self.servers_scroll_list.focused_index = 1
        TheNet:SearchLANServers(self.offlinemode)
    end

    self:StartPeriodicRefreshTask()
    self:RefreshView(true)
end

function ServerListingScreen:OnStartClickServerInList(unfiltered_index)
    if self.servers
        and self.servers[unfiltered_index]
        and self.selected_index_actual ~= unfiltered_index
        then
        self.last_server_click_time = nil
    end
    self:ServerSelected(unfiltered_index)
end

function ServerListingScreen:OnFinishClickServerInList(unfiltered_index)
    if self.servers
        and self.servers[unfiltered_index] ~= nil
        and unfiltered_index == self.selected_index_actual
		and self.last_server_click_time ~= nil
        then
        -- If we're clicking on the same server as the last click, check for double-click Join
		if GetStaticTime() - self.last_server_click_time <= DOUBLE_CLICK_TIMEOUT then
			self:Join(false)
			return
		end
    end
    self.last_server_click_time = GetStaticTime()
end

function ServerListingScreen:RefreshView(skipPoll, keepScrollFocusPos)
    -- If we're fading, don't mess with stuff
    if TheFrontEnd:GetFadeLevel() > 0 then return end

    if TheNet:IsSearchingServers() then
        self.refresh_button:Disable()
        self.refresh_button:SetText(STRINGS.UI.SERVERLISTINGSCREEN.REFRESHING)
        --if self.lan_spinner then self.lan_spinner.spinner:Disable() end
    else
        self.refresh_button:Enable()
        self.refresh_button:SetText(STRINGS.UI.SERVERLISTINGSCREEN.REFRESH)
        local num_servs = #self.servers-self.unjoinable_servers
        if num_servs < 0 then num_servs = 0 end
        self.server_count:SetString( subfmt(STRINGS.UI.SERVERLISTINGSCREEN.SHOWING_FMT, { viewed = #self.viewed_servers, total = num_servs }) )
        if not self.view_online then
            self.server_count:SetString("("..STRINGS.UI.SERVERLISTINGSCREEN.LAN..")")
        end
    end

    if not skipPoll then
        if TheNet:GetServerListingReadDirty() == false then
            return
        end

        self.servers = TheNet:GetServerListings()

        self:DoFiltering(false, keepScrollFocusPos) -- This also calls DoSorting
    end

    self.servers_scroll_list:RefreshView()
    self:UpdateServerData( self.selected_index_actual )
end

function ServerListingScreen:SetRowColour(row_widget, colour)
    row_widget.NAME:SetColour(colour)
    row_widget.PLAYERS:SetColour(colour)
    if SHOW_PINGS then
        row_widget.PING:SetColour(colour)
    end
end

function ServerListingScreen:MakeServerListWidgets()
    local dialog_width = server_list_width + (60*2) -- nineslice sides are 60px each
    local row_width,row_height = dialog_width*0.9, 36 -- 60 height also works okay
    local detail_img_width = 26
    local can_fit_two_rows = (row_height / detail_img_width) > 2
    local function ScrollWidgetsCtor(context, i)
        local row = self.grid_root.server_list_rows:AddChild(Widget("server_list_row"))

        local font_size = math.floor(FONT_SIZE * .6)
        local y_offset = 0
        local y_offset_top = y_offset + 10
        if not can_fit_two_rows then
            y_offset_top = 0
        end

        -- The index within the filtered list
        row.display_index = -1
        -- The index within self.servers
        row.unfiltered_index = -1

        row:SetOnGainFocus(function() self.servers_scroll_list:OnWidgetFocus(row) end)

        local onclickdown = function() self:OnStartClickServerInList(row.unfiltered_index)  end
        local onclickup   = function() self:OnFinishClickServerInList(row.unfiltered_index) end
        row.cursor = row:AddChild(TEMPLATES.ListItemBackground(
                row_width,
                row_height,
                onclickup
            ))
        -- Positioning within a row is unfortunate. This one should probably be centred or offset by its width, but fixing that doesn't seem worth it.
        row.cursor:SetPosition( row_width/2-90, y_offset, 0)
        row.cursor:SetOnDown(onclickdown)
        row.cursor:Hide()
		row.cursor.AllowOnControlWhenSelected = true

        local playstyle = row:AddChild(Widget("playstyle_image"))
        playstyle:SetPosition(column_offsets.PLAYSTYLE, y_offset)
        playstyle.img = playstyle:AddChild(Image("images/servericons.xml", "playstyle_social.tex"))
        playstyle.img:ScaleToSize(row_height-10,row_height-10)
        playstyle:SetHoverText(".", {font = NEWFONT_OUTLINE, offset_x = 2, offset_y = -28, colour = {1,1,1,1}})
        row.PLAYSTYLE = playstyle

        row.NAME = row:AddChild(Text(CHATFONT, font_size))
        row.NAME:SetHAlign(ANCHOR_MIDDLE)
        row.NAME:SetString("")
        row.NAME._align =
        {
            maxwidth = 435,--420,
            maxchars = 55,
            x = column_offsets.NAME,
            y = y_offset_top,
        }
        row.NAME:SetPosition(row.NAME._align.x, row.NAME._align.y, 0)


        row.DETAILS = row:AddChild(Grid())
        if can_fit_two_rows then
            row.DETAILS:SetPosition(column_offsets.NAME+20,   -y_offset_top - 2)
        else
            row.DETAILS:SetPosition(column_offsets.DETAILS-40, y_offset_top)
        end
        local details_widgets = {}

        row.HAS_PASSWORD_ICON = TEMPLATES.ServerDetailIcon("images/servericons.xml", "password.tex", "rust", STRINGS.UI.SERVERLISTINGSCREEN.PASSWORD_ICON_HOVER, nil, {-1,0}, .08, .073)
        row.HAS_PASSWORD_ICON:Hide()
        table.insert(details_widgets, row.HAS_PASSWORD_ICON)

		row.DEDICATED_ICON = TEMPLATES.ServerDetailIcon("images/servericons.xml", "dedicated.tex", "brown", STRINGS.UI.SERVERLISTINGSCREEN.DEDICATED_ICON_HOVER, nil, nil, .08, .073)
		row.DEDICATED_ICON.overrides = {unofficial = {image = "dedicated.tex", hover = STRINGS.UI.SERVERLISTINGSCREEN.DEDICATED_ICON_HOVER}, official = {image = "kleiofficial.tex", hover = STRINGS.UI.SERVERLISTINGSCREEN.DEDICATED_KLEI_ICON_HOVER} }
        row.DEDICATED_ICON:Hide()
        table.insert(details_widgets, row.DEDICATED_ICON)

		row.PAUSED_ICON = TEMPLATES.ServerDetailIcon("images/servericons.xml", "paused.tex", "plum", STRINGS.UI.SERVERLISTINGSCREEN.PAUSED, nil, nil, .08, .073)
        row.PAUSED_ICON:Hide()
        table.insert(details_widgets, row.PAUSED_ICON)

        row.MODS_ENABLED_ICON = TEMPLATES.ServerDetailIcon("images/servericons.xml", "mods.tex", "orange", STRINGS.UI.SERVERLISTINGSCREEN.MODS_ICON_HOVER, nil, nil, .077, .077)
        row.MODS_ENABLED_ICON:Hide()
        table.insert(details_widgets, row.MODS_ENABLED_ICON)

        row.PVP_ICON = TEMPLATES.ServerDetailIcon("images/servericons.xml", "pvp.tex", "burnt", STRINGS.UI.SERVERLISTINGSCREEN.PVP_ICON_HOVER)
        row.PVP_ICON:Hide()
        table.insert(details_widgets, row.PVP_ICON)

        local bgColor = "yellow"--"beige"
        row.CHAR = TEMPLATES.ServerDetailIcon("images/saveslot_portraits.xml", "unknown.tex", bgColor, STRINGS.UI.SERVERLISTINGSCREEN.CHAR_AGE_1.."0"..STRINGS.UI.SERVERLISTINGSCREEN.CHAR_AGE_3, nil, nil, .21, .22)
        row.CHAR:Hide()
        table.insert(details_widgets, row.CHAR)

        row.FRIEND_ICON = TEMPLATES.ServerDetailIcon("images/servericons.xml", "friend.tex", "green", STRINGS.UI.SERVERLISTINGSCREEN.FRIEND_ICON_HOVER, nil, nil, .075, .08)
        row.FRIEND_ICON:Hide()
        table.insert(details_widgets, row.FRIEND_ICON)

        local clan_icon = Widget("clan_icon")
        row.CLAN_OTHER_ICON = clan_icon:AddChild(TEMPLATES.ServerDetailIcon("images/servericons.xml", "clan.tex", "beige", STRINGS.UI.SERVERLISTINGSCREEN.CLAN_OTHER_ICON_HOVER))
        row.CLAN_OTHER_ICON.img:SetTint(150/255, 150/255, 150/255, 255/255)
        row.CLAN_OTHER_ICON:Hide()

        row.CLAN_OPEN_ICON = clan_icon:AddChild(TEMPLATES.ServerDetailIcon("images/servericons.xml", "clan.tex", "orange", STRINGS.UI.SERVERLISTINGSCREEN.CLAN_OPEN_ICON_HOVER))
        row.CLAN_OPEN_ICON.img:SetTint(238/255, 238/255, 99/255, 255/255)
        row.CLAN_OPEN_ICON:Hide()

        row.CLAN_CLOSED_ICON = clan_icon:AddChild(TEMPLATES.ServerDetailIcon("images/servericons.xml", "clan.tex", "orange", STRINGS.UI.SERVERLISTINGSCREEN.CLAN_CLOSED_ICON_HOVER))
        row.CLAN_CLOSED_ICON.img:SetTint(238/255, 99/255, 99/255, 255/255)
        row.CLAN_CLOSED_ICON:Hide()
        table.insert(details_widgets, clan_icon)

        row.DETAILS:FillGrid(#details_widgets, detail_img_width, detail_img_width, details_widgets)

        local function CreateTextWithIcon(icon_tex, offset_x, hovertext)
            local w = Widget("players")
            w.count = w:AddChild(Text(CHATFONT, font_size))
            w.count:SetHAlign(ANCHOR_MIDDLE)
            w.count:SetRegionSize(60, 35)
            w.count:SetString("")
            w.icon = w:AddChild(Image("images/servericons.xml", icon_tex))
            w.icon:SetPosition(offset_x,0)
            w.icon:SetScale(0.075)
            w:SetHoverText(
                hovertext,
                {
                    font = NEWFONT_OUTLINE,
                    offset_x = 10,
                    offset_y = -28
                })
            w.SetText = function(_, text)
                w.count:SetString(text)
                if text then
                    w.icon:Show()
                else
                    w.icon:Hide()
                end
            end
            w.SetColour = function(_, colour)
                w.count:SetColour(colour)
                w.icon:SetTint(unpack(colour))
            end

            return w
        end

        row.PLAYERS = row:AddChild(CreateTextWithIcon("players.tex", 30, STRINGS.UI.SERVERLISTINGSCREEN.PLAYERS))
        row.PLAYERS:SetPosition(column_offsets.PLAYERS + 20, y_offset, 0)

        if SHOW_PINGS then
            row.PING = row:AddChild(CreateTextWithIcon("ping.tex", 25, STRINGS.UI.SERVERLISTINGSCREEN.PING))
            row.PING:SetPosition(column_offsets.PING + 20, y_offset, 0)
        end

        row.focus_forward = row.cursor

        return row
    end

    local function UpdateServerListWidget(context, widget, serverdata, index)
        if not widget then return end

		ServerPreferences:UpdateProfanityFilteredServer(serverdata)

        if not serverdata then
            widget.display_index = -1
            widget.PLAYSTYLE:Hide()
            widget.NAME:SetString("")
            widget.NAME:SetPosition(widget.NAME._align.x, widget.NAME._align.y, 0)
            widget.PLAYERS:SetText()
            if SHOW_PINGS then
                widget.PING:SetText()
            end
            widget.CHAR:Hide()
            widget.FRIEND_ICON:Hide()
            widget.CLAN_OTHER_ICON:Hide()
            widget.CLAN_OPEN_ICON:Hide()
            widget.CLAN_CLOSED_ICON:Hide()
            widget.HAS_PASSWORD_ICON:Hide()
            widget.DEDICATED_ICON:Hide()
            widget.PAUSED_ICON:Hide()
            widget.PVP_ICON:Hide()
            widget.MODS_ENABLED_ICON:Hide()
            widget.cursor:Hide()
            widget.cursor:Disable()
            widget:Disable()
        else
            widget:Enable()
            widget.cursor:Enable()

            local dev_server = serverdata.version == -1
            local version_check_failed = serverdata.version ~= tonumber(APP_VERSION)

            widget.display_index = index
            widget.unfiltered_index = serverdata.actualindex

            widget.version = serverdata.version
            widget.offline = serverdata.offline
            widget.serverpaused = serverdata.serverpaused
            widget.beta = GetBetaInfoId(serverdata.tags)

            if serverdata.actualindex == self.selected_index_actual then
                widget.cursor:Select()
            else
                widget.cursor:Unselect()
            end
            widget.cursor:Show()

			local playstyle_def = serverdata.playstyle ~= nil and serverdata.playstyle ~= "" and self.playstyle_defs[serverdata.playstyle] or nil
            if playstyle_def then
                widget.PLAYSTYLE:Show()
                widget.PLAYSTYLE.img:SetTexture(playstyle_def.smallimage.atlas, playstyle_def.smallimage.icon)
                widget.PLAYSTYLE:SetHoverText(playstyle_def.name)
            else
                widget.PLAYSTYLE:Hide()
            end

			local hide_name = ServerPreferences:IsNameAndDescriptionHidden(serverdata)
            local filtered_text = ApplyLocalWordFilter(serverdata.name, TEXT_FILTER_CTX_SERVERNAME)
            widget.NAME:SetTruncatedString(hide_name and STRINGS.UI.SERVERLISTINGSCREEN.HIDDEN_NAME_LISTING or filtered_text, widget.NAME._align.maxwidth, widget.NAME._align.maxchars, true)
            local w, h = widget.NAME:GetRegionSize()
            widget.NAME:SetPosition(widget.NAME._align.x + w * .5, widget.NAME._align.y, 0)

            self:ProcessPlayerData( serverdata.session )

            if self.sessions[serverdata.session] ~= nil and self.sessions[serverdata.session] ~= false then
                local playerdata = self.sessions[serverdata.session]
                local character = playerdata.prefab or ""
                local atlas = "images/saveslot_portraits"
                if not table.contains(DST_CHARACTERLIST, character) then
                    if table.contains(MODCHARACTERLIST, character) then
                        atlas = atlas.."/"..character
                    else
                        character = #character > 0 and "mod_small" or "unknown"
                    end
                end
                atlas = atlas..".xml"
                widget.CHAR.img:SetTexture(atlas, character..".tex")
                local age = playerdata.age or "???"
                widget.CHAR:SetHoverText(STRINGS.UI.SERVERLISTINGSCREEN.CHAR_AGE_1..age..(age == 1 and STRINGS.UI.SERVERLISTINGSCREEN.CHAR_AGE_2 or STRINGS.UI.SERVERLISTINGSCREEN.CHAR_AGE_3))
                widget.CHAR:Show()
            else
                widget.CHAR:Hide()
            end

            if serverdata.friend_playing then
                widget.FRIEND_ICON:Show()
            else
                widget.FRIEND_ICON:Hide()
            end

            if serverdata.clan_server then
                if serverdata.belongs_to_clan then
                    if serverdata.clan_only then
                        widget.CLAN_OTHER_ICON:Hide()
                        widget.CLAN_OPEN_ICON:Hide()
                        widget.CLAN_CLOSED_ICON:Show()
                    else
                        widget.CLAN_OTHER_ICON:Hide()
                        widget.CLAN_OPEN_ICON:Show()
                        widget.CLAN_CLOSED_ICON:Hide()
                    end
                else
                    widget.CLAN_OTHER_ICON:Show()
                    widget.CLAN_OPEN_ICON:Hide()
                    widget.CLAN_CLOSED_ICON:Hide()
                end
            else
                widget.CLAN_OTHER_ICON:Hide()
                widget.CLAN_OPEN_ICON:Hide()
                widget.CLAN_CLOSED_ICON:Hide()
            end
            if serverdata.has_password then
                widget.HAS_PASSWORD_ICON:Show()
            else
                widget.HAS_PASSWORD_ICON:Hide()
            end
            if serverdata.dedicated then
                widget.DEDICATED_ICON:Show()

				local overrides = widget.DEDICATED_ICON.overrides[serverdata.kleiofficial and "official" or "unofficial"]
				widget.DEDICATED_ICON.img:SetTexture(widget.DEDICATED_ICON.img.atlas, overrides.image)
				widget.DEDICATED_ICON:SetHoverText(overrides.hover)
            else
                widget.DEDICATED_ICON:Hide()
            end
            if serverdata.serverpaused then
                widget.PAUSED_ICON:Show()
            else
                widget.PAUSED_ICON:Hide()
            end
            if serverdata.pvp then
                widget.PVP_ICON:Show()
            else
                widget.PVP_ICON:Hide()
            end
            if serverdata.mods_enabled then
                widget.MODS_ENABLED_ICON:Show()
            else
                widget.MODS_ENABLED_ICON:Hide()
            end

            widget.PLAYERS:SetText(serverdata.current_players .. "/" .. serverdata.max_players)

            if SHOW_PINGS then
                widget.PING:SetText(serverdata.ping)
                if serverdata.ping < 0 then
                    widget.PING:SetText("???")
                end
            end

            if dev_server then
                self:SetRowColour(widget, dev_color)
            elseif hide_name then
                self:SetRowColour(widget, hidden_color)
            elseif version_check_failed then
                self:SetRowColour(widget, widget.beta > 0 and beta_color or mismatch_color)
			else
                self:SetRowColour(widget, serverdata.offline and offline_color or normal_color)
            end
        end
    end

    local listings_per_view = math.floor(540 / row_height)

    self.servers_scroll_list = self.grid_root:AddChild(TEMPLATES.ScrollingGrid(
            {},
            {
                context = {},
                widget_width  = dialog_width * 1.6, -- bigger than width because the widgets are accidentally offset to the left.
                widget_height = row_height,
                num_visible_rows = listings_per_view,
                num_columns      = 1,
                item_ctor_fn = ScrollWidgetsCtor,
                apply_fn     = UpdateServerListWidget,
                scrollbar_offset = 20,
                scrollbar_height_offset = -50,
                peek_percent = 0.55
            }
        ))

    self.grid_root.server_list_rows:MoveToFront()
end

function ServerListingScreen:_GuaranteeSelectedServerHighlighted()
    for i,row in ipairs(self.servers_scroll_list:GetListWidgets()) do
        if row.unfiltered_index == self.selected_index_actual then
            row.cursor:Select()
        else
            row.cursor:Unselect()
        end
    end
end

function ServerListingScreen:CycleColumnSort()
    local next_sort = nil
    if SHOW_PINGS then
        next_sort = {
            RELEVANCE = "PLAYERCOUNT",
            PLAYERCOUNT = "PING",
            PING = "SERVER_NAME_AZ",
            SERVER_NAME_AZ = "SERVER_NAME_ZA",
            SERVER_NAME_ZA = "RELEVANCE",
        }
    else
        next_sort = {
            RELEVANCE = "PLAYERCOUNT",
            PLAYERCOUNT = "SERVER_NAME_AZ",
            SERVER_NAME_AZ = "SERVER_NAME_ZA",
            SERVER_NAME_ZA = "RELEVANCE",
        }
    end

    self:SetSort(next_sort[self.sort_column] or "RELEVANCE")
    self.sorting_spinner:SetFocus()
end

function ServerListingScreen:SetSort(column)
    self.sorting_spinner.spinner:SetSelected(column)
    self.sorting_spinner.spinner:Changed()
end

function ServerListingScreen:DoSorting()
    -- This does the trick, but we might want more clever criteria for how a certain column gets ordered
    -- ("Server 5" < "Server 50" < "Server 6" is current result for Name)

    -- Does a have bestping over b?
    local function has_bestping(a,b)
        if a.ping < 0 and b.ping >= 0 then
            return false
        elseif a.ping >= 0 and b.ping < 0 then
            return true
        elseif a.ping == b.ping then
            return string.lower(a.name) < string.lower(b.name)
        else
            return a.ping < b.ping
        end
    end
    local function HasFriends(server)
        return server.friend_playing
    end
    local function HasClan(server)
        return server.belongs_to_clan
    end
    local function HasEmptySlot(server)
        return server.max_players > server.current_players
    end
    local function HasExistingCharacter(server)
        return self.sessions[server.session]
    end
    local function HasPlayers(server)
        return server.current_players > 0
    end
    local function IsUnlocked(server)
        return not server.has_password
    end
    local social_sort_fns = {
        -- first item is most important
        HasFriends,
        HasClan,
        HasEmptySlot,
        HasExistingCharacter,
        HasPlayers,
        IsUnlocked
    }
    local function has_bestsocial(a,b)
        for i,has_social_attribute in ipairs(social_sort_fns) do
            if has_social_attribute(a) and not has_social_attribute(b) then
                return true
            elseif not has_social_attribute(a) and has_social_attribute(b) then
                return false
            end
        end
        return nil
    end

    if self.viewed_servers then
        table.sort(self.viewed_servers, function(a,b)
            if self.sort_column == "SERVER_NAME_AZ" then
                return string.lower(a.name) < string.lower(b.name)
            elseif self.sort_column == "SERVER_NAME_ZA" then
                return string.lower(a.name) > string.lower(b.name)
            elseif self.sort_column == "RELEVANCE" then
                local social = has_bestsocial(a,b)
                if social ~= nil then
                    return social
                else
                    return has_bestping(a,b)
                end
            elseif self.sort_column == "PLAYERCOUNT" then
                return a.current_players > b.current_players
            else
                return has_bestping(a,b)
            end
        end)
        self:RefreshView(true)
    end
end

function ServerListingScreen:ProcessPlayerData(session)
    if self.sessions[session] == nil and self.session_mapping ~= nil then
        local data = self.session_mapping[session]
        if data ~= nil then
            if type(data) == "table" and data.session_data_processed then
                self.sessions[session] = data.data
            else
                local success, playerdata = RunInSandboxSafeCatchInfiniteLoops(data)
                self.sessions[session] = success and playerdata or false
                self.session_mapping[session] =
                {
                    session_data_processed = true,
                    data = self.sessions[session],
                }
            end
        end
    end
end

function ServerListingScreen:IsValidWithFilters(server)

    local function gameModeInvalid(serverMode, spinnerMode)
        if spinnerMode == "ANY" then
            return false
        elseif spinnerMode == "custom" then
            --The user is looking for any modded game mode
            return not GetIsModGameMode( serverMode )
        else
            --The user is looking for a specific game mode
            return serverMode ~= spinnerMode
        end
    end

    local function charInvalid(session, spinnerSelection)
        self:ProcessPlayerData( session )

        if self.sessions[session] ~= nil then
            local char = self.sessions[session]
            if spinnerSelection == true then
                return char == false
            else
                return char ~= false
            end
        elseif spinnerSelection == true then
            return true
        else
            return false
        end
    end

    if not server or type(server) ~= "table" then return false end

    -- Do checks for unjoinable servers first so the count is accurate.
    -- This means servers that you will never be able to join no matter
    -- what filters or settings you choose.

    -- Filter our friends only servers that are not our friend
    if server.friends_only and not server.friend then
        self.unjoinable_servers = self.unjoinable_servers + 1
        return false
    end

    -- Filter servers that we aren't allowed to join.
    if server.clan_only and not server.belongs_to_clan then
        self.unjoinable_servers = self.unjoinable_servers + 1
        return false
    end

    -- Filter out unjoinable servers, if we are online
    -- NOTE: steamroom is not available for dedicated servers
    -- NOTE: Any server with a steam id can be joinable via punchthrough even if you can't ping it directly
    -- NOTE: steamnat is now the flag to check
    if self.view_online and not server.steamnat and server.ping < 0 then
        self.unjoinable_servers = self.unjoinable_servers + 1
        return false
    end

    -- If we are in offline mode, don't show online mode servers
    if self.offlinemode and not server.offline then
        self.unjoinable_servers = self.unjoinable_servers + 1
        return false
    end

    -- Filter servers that are empty (or not empty if flag is true)
    -- NOTE: ISEMPTY spinner filter is checked again below, but this one increments unjoinable_servers
    if self.forced_settings.isempty ~= nil and (server.current_players <= 0) ~= self.forced_settings.isempty then
        self.unjoinable_servers = self.unjoinable_servers + 1
        return false
    end

    -- Filter servers that set an old deprecated intention type as a playstyle which results in invisible graphics.
    -- Mods sometimes use this field to extend onto the playstyles so this list should be very limited.
    if server.playstyle == "cooperative" then
        return false
    end

    -- Now do checks for servers you can potentially join, but are currently
    -- being filtered due to your settings.

    -- Hide version mismatched servers (except beta) on live builds
    -- We don't count this towards unjoinable because you probably could
    -- have joined them previously, and this keeps the count consistent.
    local version_mismatch = APP_VERSION ~= tostring(server.version)
    local beta_server = GetBetaInfoId(server.tags)
    local dev_build = BRANCH == "dev"

    if version_mismatch and not ((beta_server > 0) and BRANCH == "release") and not dev_build then
        return false
    end

    -- Filter servers that are only accepting players with existing characters in the world
    if not server.allow_new_players and charInvalid(server.session, true) then
        return false
    end

    -- Only show servers that match your playstyle
    -- But, don't filter this way if we've explicitly put in search terms
    -- Also, this only applies to the online tab
    local playstyle = self:_GetServerPlaystyle()
    if playstyle ~= PLAYSTYLE_ANY and self.view_online and #self.queryTokens == 0 then
        if playstyle == nil or playstyle ~= server.playstyle then
            return false
        end
    end

    -- Check spinner validation
    for i, v in ipairs(self.filters) do
        -- First check with the spinners
        if v.spinner ~= nil then
            if ((v.name == "HASPVP" and server.pvp ~= v.spinner:GetSelectedData() and v.spinner:GetSelectedData() ~= "ANY")
            or (v.name == "GAMEMODE" and v.spinner:GetSelectedData() ~= "ANY" and gameModeInvalid(server.mode, v.spinner:GetSelectedData()))
            or (v.name == "HASPASSWORD" and (v.spinner:GetSelectedData() ~= "ANY" and server.has_password ~= v.spinner:GetSelectedData()))
            or (v.name == "MINCURRPLAYERS" and v.spinner:GetSelectedData() ~= "ANY" and (server.current_players < v.spinner:GetSelectedData()))
            or (v.name == "MAXCURRPLAYERS" and v.spinner:GetSelectedData() ~= "ANY" and (server.current_players > v.spinner:GetSelectedData()))
            or (v.name == "MAXSERVERSIZE" and v.spinner:GetSelectedData() ~= "ANY" and server.max_players > v.spinner:GetSelectedData())
            or (v.name == "MINOPENSLOTS" and v.spinner:GetSelectedData() ~= "ANY" and server.max_players - server.current_players < v.spinner:GetSelectedData())
            or (v.name == "ISFULL" and (server.current_players >= server.max_players and v.spinner:GetSelectedData() == false))
            or (v.name == "ISEMPTY" and (server.current_players <= 0 and v.spinner:GetSelectedData() == false))
            or (v.name == "ISPAUSED" and v.spinner:GetSelectedData() and server.serverpaused)
            or (v.name == "FRIENDSONLY" and v.spinner:GetSelectedData() ~= "ANY" and v.spinner:GetSelectedData() ~= server.friend_playing )
            or (v.name == "CLANONLY" and v.spinner:GetSelectedData() ~= "ANY" and not server.belongs_to_clan )
            or (v.name == "CLANONLY" and v.spinner:GetSelectedData() == "PRIVATE" and not server.clan_only )
            or (v.name == "SEASON" and v.spinner:GetSelectedData() ~= "ANY" and v.spinner:GetSelectedData() ~= server.season )
            or (v.name == "VERSIONCHECK" and v.spinner:GetSelectedData() and version_mismatch )
            or (v.name == "ISDEDICATED" and v.spinner:GetSelectedData() ~= "ANY" and not((v.spinner:GetSelectedData() == "DEDICATED" and server.dedicated) or (v.spinner:GetSelectedData() == "OFFICIAL" and server.kleiofficial) or (v.spinner:GetSelectedData() == "HOSTED" and not server.dedicated)))
            or (v.name == "MODSENABLED" and v.spinner:GetSelectedData() ~= "ANY" and server.mods_enabled ~= v.spinner:GetSelectedData())
            or (v.name == "HASCHARACTER" and v.spinner:GetSelectedData() ~= "ANY" and charInvalid(server.session, v.spinner:GetSelectedData()))) then
                return false
            end
        end
    end

    -- Then check with the search box (but only if it hasn't already been invalidated)
    if #self.queryTokens > 0 then
        -- Then check if our servers' names and tags contain any of those tokens
        local searchMatch = true -- Assume match until we find a non-match
        for j,k in pairs(self.queryTokens) do
            if not string.find(string.lower(server.name), k, 1, true) and not string.find(string.lower(server.tags), k, 1, true) then
                searchMatch = false
                break
            end
        end

        if not searchMatch then
            return false
        end
    end

    return true
end

function ServerListingScreen:ResetFilters()
    for i, v in ipairs(self.filters) do
        if v.spinner ~= nil and not v.is_forced
            and v ~= self.connection_spinner -- online -> LAN causes full server reload
            then
            v.spinner:SetSelectedIndex(1)
            v.spinner:SetHasModification(false)
            if v.name == "GAMEMODE" then
                v.spinner:SetHoverText("")
            end
        end
    end
    self.searchbox.textbox:SetString("")
    self:DoFiltering()
end

function ServerListingScreen:DoFiltering(doneSearching, keepScrollFocusPos)
    if not self.filters then return end

    local function FindDisplayIndexForServer(unfiltered_index)
        for i, w in ipairs(self.viewed_servers) do
            if w.actualindex ~= -1 and w.actualindex == unfiltered_index then
                return i
            end
        end
        return -1
    end

    -- Remember what position our selected server is on screen
    local selected_display_index = FindDisplayIndexForServer(self.selected_index_actual)

    -- Reset the number of unjoinable servers
    self.unjoinable_servers = 0

    -- If there's a query, build the table of query tokens for checking against
    self.queryTokens = {}
    local query = self.searchbox.textbox:GetString()
    if query ~= "" then
        local startPos = 1
        local endPos = 1
        local token = ""
        if string.len(query) == 1 then
            table.insert(self.queryTokens, string.lower(query))
        else
            for i=1, string.len(query) do
                -- Separate search tokens by , (and make sure we grab the trailing token)
                if string.sub(query,i,i) == "," or i == string.len(query) then
                    endPos = i
                end
                if (endPos ~= startPos and endPos > startPos) or (endPos == string.len(query)) then
                    if endPos < string.len(query) or (endPos == string.len(query) and string.sub(query, endPos, endPos) == ",") then endPos = endPos - 1 end
                    token = string.sub(query, startPos, endPos) -- Grab the token
                    token = string.gsub(token, "^%s*(.-)%s*$", "%1") -- Get rid of whitespace on the ends
                    table.insert(self.queryTokens, string.lower(token))
                    startPos = endPos + 2 -- Increase startPos so we skip the comma for the next token
                end
            end
        end
    end

    -- Disable server playstyle button and change the title when we have query tokens
    if self.view_online and self.server_playstyle.id ~= nil then
        if #self.queryTokens > 0 then
            self.server_playstyle.button:Select()
            self.server_playstyle.button:SetText(STRINGS.UI.PLAYSTYLE_ANY)
            self.title:SetTruncatedString(STRINGS.UI.SERVERLISTINGSCREEN.SEARCH..": "..self.searchbox.textbox:GetString(), 350, 25, true)
        else
            self.server_playstyle.button:Unselect()
            self.server_playstyle.button:SetText(self.playstyle_defs[self.server_playstyle.id].name)
            self.title:SetString(string.format(STRINGS.UI.SERVERLISTINGSCREEN.SERVER_LIST_TITLE_PLAYSTYLE, self.playstyle_defs[self.server_playstyle.id].name))
        end
    end

    local filtered_servers = {}
    if self.servers and #self.servers > 0 then
        for i, v in ipairs(self.servers) do
            if self:IsValidWithFilters(v) then
                table.insert(filtered_servers,
                    {
                        name=v.name,
                        mode=v.mode,
                        has_password=v.has_password,
                        description=v.description,
                        mods_description=v.mods_description,
                        mods_failed_deserialization=v.mods_failed_deserialization,
                        dedicated=v.dedicated,
                        pvp=v.pvp,
                        current_players=v.current_players,
                        max_players=v.max_players,
                        ping=v.ping,
                        ip=v.ip,
                        port=v.port,
                        row=v.row,
                        version=v.version,
                        friend=v.friend,
                        friend_playing=v.friend_playing,
                        clan_server = v.clan_server,
                        clan_only = v.clan_only,
                        belongs_to_clan=v.belongs_to_clan,
                        lan_only = v.lan_only,
                        offline = v.offline,
                        net_group_id = v.net_group_id,
                        actualindex=i,
                        mods_enabled = v.mods_enabled,
                        tags = v.tags,
                        session = v.session,
                        has_details = v.has_details,
                        playstyle = v.playstyle,
                        allow_new_players = v.allow_new_players,
						kleiofficial = v.kleiofficial,
                        serverpaused = v.serverpaused,
                        -- data = v.data,
                    })
            end
        end

        if self.selected_server ~= nil and self:IsValidWithFilters(self.selected_server) == false then
            self:ServerSelected(nil)
        end
    end

    if CompareTable(self.viewed_servers, filtered_servers) and not doneSearching then
        return
    end
    self.viewed_servers = filtered_servers
    local num_servs = #self.servers-self.unjoinable_servers
    if num_servs < 0 then num_servs = 0 end
    if num_servs == 0 and not doneSearching then
        self.server_count:SetString("("..STRINGS.UI.SERVERLISTINGSCREEN.SEARCHING_SERVERS..")")
    else
        self.server_count:SetString( subfmt(STRINGS.UI.SERVERLISTINGSCREEN.SHOWING_FMT, { viewed = #self.viewed_servers, total = num_servs }) )
    end
    if not self.view_online then
        self.server_count:SetString("("..STRINGS.UI.SERVERLISTINGSCREEN.LAN..")")
    end
    self:DoSorting()

    local should_jump = selected_display_index > 0
    local first_index = self.servers_scroll_list:GetIndexOfFirstVisibleWidget()
    local distance_from_top = selected_display_index - first_index - 1

    self.servers_scroll_list:SetItemsData(self.viewed_servers)

    if should_jump then
        selected_display_index = FindDisplayIndexForServer(self.selected_index_actual)
        self.servers_scroll_list:ScrollToWidgetIndex(selected_display_index - distance_from_top)
    end
end

function ServerListingScreen:Cancel()
    TheNet:StopSearchingServers()
    self:Disable()
	ServerPreferences:RefreshLastSeen(self.servers)
    TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()
        local filters = {}
        for i, v in ipairs(self.filters) do
            if v.spinner ~= nil then
                table.insert(filters, {name=v.name, data=v.spinner:GetSelectedData()})
            elseif v.textbox then
                table.insert(filters, {name="search", data=v.textbox:GetString()})
            end
        end
		if self.should_save then
		    Profile:SaveFilters(filters)
			Profile:SetValue("serverlistingsort", self.sorting_spinner.spinner:GetSelectedData())
		end
        if self.cb then
            self.cb(filters)
        end
        TheFrontEnd:PopScreen()
        TheFrontEnd:Fade(FADE_IN, SCREEN_FADE_TIME)
    end)
end

local label_width = 140
local widget_width = 150
local height = 28
local spacing = 3
local total_width = label_width + widget_width + spacing
local bg_width = spacing + total_width + spacing + 10
local bg_height = height + 2


local function CreateButtonFilter( self, name, text, buttontext, onclick)

    local group = self.side_panel:AddChild(TEMPLATES.LabelButton(onclick, text, buttontext, label_width, widget_width, height*1.4, spacing, CHATFONT, 20))
    group.bg = group:AddChild(TEMPLATES.ListItemBackground(bg_width, bg_height))
    group.bg:MoveToBack()

    group.label:SetHAlign(ANCHOR_LEFT)

    group.name = name

    return group
end

local function CreateSpinnerFilter( self, name, text, spinnerOptions, numeric, onchanged )

    local group = nil
    if numeric then
        group = TEMPLATES.LabelNumericSpinner(text, spinnerOptions.min, spinnerOptions.max, label_width, widget_width, height, spacing, CHATFONT, 20)
    else
        group = TEMPLATES.LabelSpinner(text, spinnerOptions, label_width, widget_width, height, spacing, CHATFONT, 20)
    end
    self.side_panel:AddChild(group)
    group.bg = group:AddChild(TEMPLATES.ListItemBackground(bg_width, bg_height))
    group.bg:MoveToBack()

    group.label:SetHAlign(ANCHOR_LEFT)
    group.spinner:EnablePendingModificationBackground()
    group.spinner:SetOnChangedFn(
        function(...)
            self:DoFiltering()
            group.spinner:SetHasModification(group.spinner:GetSelectedIndex() ~= 1)
            if onchanged then
                onchanged(...)
            end
        end)

    group.name = name

    return group
end

function ServerListingScreen:MakeFiltersPanel(filter_data, details_height)
    local any_on_off = {{ text = STRINGS.UI.SERVERLISTINGSCREEN.ANY, data = "ANY" }, { text = STRINGS.UI.SERVERLISTINGSCREEN.ON, data = true }, { text = STRINGS.UI.SERVERLISTINGSCREEN.OFF, data = false }}
    local any_no_yes = {{ text = STRINGS.UI.SERVERLISTINGSCREEN.ANY, data = "ANY" }, { text = STRINGS.UI.SERVERLISTINGSCREEN.NO, data = false }, { text = STRINGS.UI.SERVERLISTINGSCREEN.YES, data = true }}
    local any_yes_no = {{ text = STRINGS.UI.SERVERLISTINGSCREEN.ANY, data = "ANY" }, { text = STRINGS.UI.SERVERLISTINGSCREEN.YES, data = true }, { text = STRINGS.UI.SERVERLISTINGSCREEN.NO, data = false }}
    local any_mine_private = {{ text = STRINGS.UI.SERVERLISTINGSCREEN.ANY, data = "ANY" }, { text = STRINGS.UI.SERVERLISTINGSCREEN.MINE, data = "MINE" }, { text = STRINGS.UI.SERVERLISTINGSCREEN.PRIVATE, data = "PRIVATE" }}
    local yes_no = {{ text = STRINGS.UI.SERVERLISTINGSCREEN.YES, data = true }, { text = STRINGS.UI.SERVERLISTINGSCREEN.NO, data = false }}
    local no_yes = {{ text = STRINGS.UI.SERVERLISTINGSCREEN.NO, data = false }, { text = STRINGS.UI.SERVERLISTINGSCREEN.YES, data = true }}
    local any_dedicated_hosted = {{ text = STRINGS.UI.SERVERLISTINGSCREEN.ANY, data = "ANY" }, { text = STRINGS.UI.SERVERLISTINGSCREEN.DEDICATED, data = "DEDICATED" }, { text = STRINGS.UI.SERVERLISTINGSCREEN.OFFICIAL, data = "OFFICIAL" }, { text = STRINGS.UI.SERVERLISTINGSCREEN.HOSTED, data = "HOSTED" }}

    local seasons = {{ text = STRINGS.UI.SERVERLISTINGSCREEN.ANY, data = "ANY" },
                    { text = STRINGS.UI.SERVERLISTINGSCREEN.SEASONS.AUTUMN, data = "autumn" },
                    { text = STRINGS.UI.SERVERLISTINGSCREEN.SEASONS.WINTER, data = "winter" },
                    { text = STRINGS.UI.SERVERLISTINGSCREEN.SEASONS.SPRING, data = "spring" },
                    { text = STRINGS.UI.SERVERLISTINGSCREEN.SEASONS.SUMMER, data = "summer" }}

    local game_modes = {{ text = STRINGS.UI.SERVERLISTINGSCREEN.ANY, data = "ANY" }}
    local m = GetGameModesSpinnerData()
    for i,v in ipairs(m) do
        table.insert( game_modes, { text = v.text, data = v.data} )
    end
    table.insert( game_modes, { text = STRINGS.UI.SERVERLISTINGSCREEN.CUSTOM, data = "custom" } )
    local player_slots = {{ text = STRINGS.UI.SERVERLISTINGSCREEN.ANY, data = "ANY" }}
    local i = TUNING.MAX_SERVER_SIZE
    while i > 0 do
        table.insert(player_slots,{text=i, data=i})
        i = i - 1
    end

    local reset_button_width = total_width
    local reset = self.side_panel:AddChild(TEMPLATES.StandardButton(
            function() self:ResetFilters() end,
            STRINGS.UI.SERVERLISTINGSCREEN.FILTER_RESET,
            {reset_button_width, 50},
            {"images/button_icons.xml", "undo.tex"}
        ))

    local search_width = 260
    local search_button_width = height + 5
    local searchparent = self.side_panel:AddChild(Widget("searchbox"))
    local searchbox = searchparent:AddChild(TEMPLATES.StandardSingleLineTextEntry("", search_width, height, CHATFONT, 20, STRINGS.UI.SERVERLISTINGSCREEN.SEARCH))
    -- Search box isn't like other filters. It's not aligned on the colon and
    -- should span the full column width. ScrollableList sets positions so we
    -- need this parent.
    searchbox:SetPosition(-(total_width/2)+search_width/2,0)
    searchbox.textbox:SetTextLengthLimit( STRING_MAX_LENGTH )
    searchbox.gobutton = searchparent:AddChild(TEMPLATES.StandardButton(
            function() self.searchbox.textbox:OnTextEntered() end,
            nil,
            {search_button_width, search_button_width},
            {"images/servericons.xml", "search.tex"}
        ))
    searchbox.gobutton:SetPosition(-(total_width/2)+search_width+spacing+(search_button_width/2), 0)
    searchbox.textbox.OnTextEntered = function() self:DoFiltering() end
    searchbox:SetOnGainFocus(function() self.searchbox.textbox:OnGainFocus() end)
    searchbox:SetOnLoseFocus(function() self.searchbox.textbox:OnLoseFocus() end)
    searchparent.focus_forward = searchbox

    self.searchbox = searchbox

    table.insert(self.filters, searchparent)
    self.connection_spinner = self:_MakeConnectionSpinner()
    if self.forced_settings.online then
        assert(self.view_online, "Who turned online off? It should already be on and now be unchangeable.")
        self.connection_spinner:Hide()
    else
        table.insert(self.filters, self.connection_spinner)
    end

    self.server_playstyle = CreateButtonFilter(self, nil, STRINGS.UI.SERVERLISTINGSCREEN.PLAYSTYLE_FILTER, nil, function(data)
        self:SetServerPlaystyle(nil)
        self.playstyle_overlay:SetFocus()
    end)

    if self.forced_settings.playstyle then
        self.server_playstyle:Hide()
    else
        table.insert(self.filters, self.server_playstyle)
    end
    table.insert(self.filters, CreateSpinnerFilter( self, "GAMEMODE", STRINGS.UI.SERVERLISTINGSCREEN.GAMEMODE, game_modes, false ))
    table.insert(self.filters, CreateSpinnerFilter( self, "SEASON", STRINGS.UI.SERVERLISTINGSCREEN.SEASONFILTER, seasons, false ))
    table.insert(self.filters, CreateSpinnerFilter( self, "HASPVP", STRINGS.UI.SERVERLISTINGSCREEN.HASPVP, any_on_off, false ))
    table.insert(self.filters, CreateSpinnerFilter( self, "MODSENABLED", STRINGS.UI.SERVERLISTINGSCREEN.MODSENABLED, any_no_yes, false ))
    table.insert(self.filters, CreateSpinnerFilter( self, "HASPASSWORD", STRINGS.UI.SERVERLISTINGSCREEN.HASPASSWORD, any_no_yes, false ))
    table.insert(self.filters, CreateSpinnerFilter( self, "ISDEDICATED", STRINGS.UI.SERVERLISTINGSCREEN.SERVERTYPE, any_dedicated_hosted, false ))
    table.insert(self.filters, CreateSpinnerFilter( self, "HASCHARACTER", STRINGS.UI.SERVERLISTINGSCREEN.HASCHARACTER, any_yes_no, false ))
    table.insert(self.filters, CreateSpinnerFilter( self, "FRIENDSONLY", STRINGS.UI.SERVERLISTINGSCREEN.FRIENDSONLY, any_yes_no, false ))
    if not IsRail() then
		table.insert(self.filters, CreateSpinnerFilter( self, "CLANONLY", STRINGS.UI.SERVERLISTINGSCREEN.CLANONLY, any_mine_private, false ))
	end
    -- table.insert(self.filters, CreateSpinnerFilter( "MINCURRPLAYERS", STRINGS.UI.SERVERLISTINGSCREEN.MINCURRPLAYERS, {min=0,max=4}, true ))
    -- table.insert(self.filters, CreateSpinnerFilter( self, "MAXCURRPLAYERS", STRINGS.UI.SERVERLISTINGSCREEN.MAXCURRPLAYERS, players, false ))--STRINGS.UI.SERVERLISTINGSCREEN.MAXCURRPLAYERS, {min=0,max=4}, true ))
    table.insert(self.filters, CreateSpinnerFilter( self, "ISFULL", STRINGS.UI.SERVERLISTINGSCREEN.ISFULL, yes_no, false ))
    table.insert(self.filters, CreateSpinnerFilter( self, "MINOPENSLOTS", STRINGS.UI.SERVERLISTINGSCREEN.MINOPENSLOTS, player_slots, false ))
    table.insert(self.filters, CreateSpinnerFilter( self, "ISEMPTY", STRINGS.UI.SERVERLISTINGSCREEN.ISEMPTY, yes_no, false ))
    table.insert(self.filters, CreateSpinnerFilter( self, "ISPAUSED", STRINGS.UI.SERVERLISTINGSCREEN.ISPAUSED, no_yes, false ))
    -- table.insert(self.filters, CreateSpinnerFilter( "MAXSERVERSIZE", STRINGS.UI.SERVERLISTINGSCREEN.MAXSERVERSIZE, {min=2,max=4}, true ))

    if BRANCH == "dev" then
        table.insert(self.filters, CreateSpinnerFilter( self, "VERSIONCHECK", STRINGS.UI.SERVERLISTINGSCREEN.VERSIONCHECK, no_yes, false ))
    else
        TheNet:SetCheckVersionOnQuery( true )
    end

    table.insert(self.filters, reset)

	local editable_filters = {}
    if filter_data ~= nil then
        for j, k in ipairs(self.filters) do
			local add = true
 			for i, v in ipairs(filter_data) do
                if v.name == k.name then
                    add = not v.is_forced
                    if v.data ~= nil then
                        k.spinner:SetSelected(v.data)
                    end
					break
				end
			end
			if add then
				table.insert(editable_filters, k)
			else
				k:Hide()
			end
		end
	else
		editable_filters = self.filters
	end

    local scroll_width = 230
    local scroll_height = details_height
    local item_height = height - 8
    local item_padding = math.min(12, (scroll_height - (item_height*#editable_filters)) / (#editable_filters-1))

    self.filters_scroll_list = self.side_panel:AddChild(ScrollableList(editable_filters, scroll_width, scroll_height, item_height, item_padding, nil, nil, 0))
    self.filters_scroll_list:SetPosition(115,0)
end

local function MakeImgButton(parent, xPos, yPos, text, onclick, style, image)

    local btn
    if not style or style == "large" then
        btn = parent:AddChild(TEMPLATES.StandardButton(onclick, text))
    elseif style == "icon" then
        btn = parent:AddChild(TEMPLATES.IconButton("images/button_icons.xml", image..".tex", text, false, false, onclick, {offset_y = 45}))
    elseif style == "icontext" then
        btn = parent:AddChild(TEMPLATES.StandardButton(onclick, text, {200, 60}, {"images/button_icons.xml", image..".tex"}))
    end

    btn:SetPosition(xPos, yPos)

    return btn
end

function ServerListingScreen:_MakeConnectionSpinner()
    local connection = {
        { text = STRINGS.UI.SERVERLISTINGSCREEN.ONLINE, data = "online" },
        { text = STRINGS.UI.SERVERLISTINGSCREEN.LAN,    data = "LAN" },
    }
    local group = CreateSpinnerFilter(self, "CONNECTION", STRINGS.UI.SERVERLISTINGSCREEN.CONNECTION, connection)
    -- Clobber standard onchangedfn: we're not just modifying filtering, but changing the data source.
    group.spinner:SetOnChangedFn(function(selected, old)
        if self.offlinemode and selected == "online" then
            TheFrontEnd:PushScreen(PopupDialogScreen(
                    STRINGS.UI.SERVERLISTINGSCREEN.OFFLINE_MODE_TITLE,
                    STRINGS.UI.SERVERLISTINGSCREEN.OFFLINE_MODE_BODY,
                {{ text = STRINGS.UI.SERVERLISTINGSCREEN.OK, cb = function() TheFrontEnd:PopScreen() end }}))
                group.spinner:SetSelected(old)
        else
            self:_SetTab(selected)
            group.spinner:SetHasModification(group.spinner:GetSelectedIndex() ~= 1)
        end
    end)

    return group
end

function ServerListingScreen:MakeMenuButtons(left_col, right_col, nav_col)
    local sorting_types = nil
    if SHOW_PINGS then
        sorting_types = {
            "RELEVANCE",
            "PLAYERCOUNT",
            "PING",
            "SERVER_NAME_AZ",
            "SERVER_NAME_ZA",
        }
    else
        sorting_types = {
            "RELEVANCE",
            "PLAYERCOUNT",
            "SERVER_NAME_AZ",
            "SERVER_NAME_ZA",
        }
    end
    
    local sorting_data = {}
    for i,sort_key in ipairs(sorting_types) do
        table.insert(sorting_data, {
                text = STRINGS.UI.SERVERLISTINGSCREEN.SORTING_TYPES[sort_key] or "",
                colour = nil,
                image = nil,
                data = sort_key, -- This data is what we'll receive in our callbacks.
            })
    end
    self.sorting_spinner = self.content_root:AddChild(
        TEMPLATES.LabelSpinner(
            STRINGS.UI.SERVERLISTINGSCREEN.SORT_BY,
            sorting_data,
            100,
            270,
            nil,
            0
        ))
    self.sorting_spinner:SetPosition(-185, -315)
    self.sorting_spinner.spinner:SetOnChangedFn(
        function(selected_name, old)
            self.sort_column = selected_name
            self:DoSorting()
        end)

    -- Need to init refresh to longer string to ensure proper placement of icon!
    self.refresh_button = MakeImgButton(self.content_root, 185, -315, STRINGS.UI.SERVERLISTINGSCREEN.REFRESHING, function() self:SearchForServers() end, "icontext", "refresh")
    self.join_button = MakeImgButton(self.side_panel, 0, -RESOLUTION_Y*.5 + BACK_BUTTON_Y - 15, STRINGS.UI.SERVERLISTINGSCREEN.JOIN, function() self:Join(false) end, "large")

    local function toggle_filter_fn() self:ToggleShowFilters() end
    local buttons = {
        {
            text = STRINGS.UI.SERVERLISTINGSCREEN.FILTERS,
            cb = toggle_filter_fn,
        },
        {
            text = STRINGS.UI.SERVERLISTINGSCREEN.SERVERDETAILS,
            cb = toggle_filter_fn,
        },
    }
    self.filters_header = self.side_panel:AddChild(HeaderTabs(buttons))
    self.filters_header:SetPosition(0, 300)
    self.filters_header:SetScale(0.8)
    self.filters_header:MoveToBack()

    self.refresh_button:Disable()
    self.refresh_button:SetText(STRINGS.UI.SERVERLISTINGSCREEN.REFRESHING)
    self.refresh_button:SetScale(0.75)
    self.join_button:Disable()

    self.details_shown = false
    self.filters_shown = false

    self.cancel_button = self.root:AddChild(TEMPLATES.BackButton(function() self:Cancel() end))

    if TheInput:ControllerAttached() then
        -- Refresh button is visible for controllers so they can tell if we're currently refreshing.
        -- self.refresh_button:Hide()
        self.join_button:Hide()
        self.cancel_button:Hide()
    else
        self.cancel_button:SetFocusChangeDir(MOVE_RIGHT, function() return self:CurrentCenterFocus() end, MOVE_RIGHT)
    end
end

function ServerListingScreen:MakeDetailPanel(right_col, details_height)
    self.side_panel = self.content_root:AddChild(Widget("side_panel"))
    self.side_panel:SetPosition(right_col,0)

    self.side_panelbg = self.side_panel:AddChild(TEMPLATES.RectangleWindow(250, details_height))
    self.side_panelbg.top:Hide() -- top crown would be behind our tabs.
    local r,g,b = unpack(UICOLOURS.BROWN_DARK)
    self.side_panelbg:SetBackgroundTint(r,g,b,0.6)

    self.details_tab = self.side_panel:AddChild(Widget("details_tab"))

    local detail_x = 0
    local width = 240
    local detail_y = 220

    -- Container for the majority of the details in this panel, so we can hide them
    self.server_details_additional = self.details_tab:AddChild(Widget("additionalservdetails"))
    self.server_details_additional:SetPosition(0,-30)
    self.server_details_additional:Hide()

    self.details_servername = self.details_tab:AddChild(Text(CHATFONT, 30))
    self.details_servername:SetHAlign(ANCHOR_MIDDLE)
    self.details_servername:SetVAlign(ANCHOR_TOP)
    self.details_servername:SetPosition(detail_x, detail_y, 0)
    self.details_servername:SetColour(UICOLOURS.GOLD_SELECTED)
    self.details_servername._align =
    {
        maxlines = 2,
        maxwidth = width,
        maxchars = 45,
    }
    self.details_servername:SetMultilineTruncatedString(STRINGS.UI.SERVERLISTINGSCREEN.NOSERVERSELECTED, 2, self.details_servername._align.maxwidth, self.details_servername._align.maxchars, true)

    detail_y = detail_y - 140
    self.details_serverdesc_bg = self.details_tab:AddChild(Image("images/ui.xml", "black.tex"))
    self.details_serverdesc_bg:SetPosition(detail_x, detail_y, 0)
    self.details_serverdesc_bg:SetTint(unpack(normal_list_item_bg_tint))
    self.details_serverdesc = self.details_tab:AddChild(Text(CHATFONT, 23))
    self.details_serverdesc:SetHAlign(ANCHOR_MIDDLE)
    self.details_serverdesc:SetVAlign(ANCHOR_TOP)
    self.details_serverdesc:SetPosition(detail_x, detail_y, 0)
    self.details_serverdesc:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
    self.details_serverdesc._align =
    {
        maxlines = 8,
        maxwidth = width,
        maxchars = 254,
    }
    self.details_serverdesc:SetString("")

    self.viewworld_button = MakeImgButton(self.details_tab, -56, 6, STRINGS.UI.SERVERLISTINGSCREEN.WORLD_UNKNOWN, function() self:ViewServerWorld() end, "icon", "world")
    self.viewworld_button:Select()

    self.viewmods_button = MakeImgButton(self.details_tab, 0, 6, STRINGS.UI.SERVERLISTINGSCREEN.NOMODS, function() self:ViewServerMods() end, "icon", "mods")
    self.viewmods_button:Select()

    self.viewtags_button = MakeImgButton(self.details_tab, 56, 6, STRINGS.UI.SERVERLISTINGSCREEN.NOTAGS, function() self:ViewServerTags() end, "icon", "tags")
    self.viewtags_button:Select()

    self.viewplayers_button = MakeImgButton(self.details_tab, -28, -46, STRINGS.UI.SERVERLISTINGSCREEN.PLAYERS_UNKNOWN, function() self:ViewServerPlayers() end, "icon", "view_players")
    self.viewplayers_button:Select()

    self.viewgroup_button = MakeImgButton(self.details_tab, 28, -46, STRINGS.UI.SERVERLISTINGSCREEN.GROUP_NONE, function() self:ViewServerGroup() end, "icon", "clan")
    self.viewgroup_button:Select()

    self.toggleservertext_button = MakeImgButton(self.details_tab, 28, -46, STRINGS.UI.SERVERLISTINGSCREEN.TOGGLE_SERVER_NAME, function() self:OnToggleServerName() end, "icon", "toggle_server_name")

	local button_scale = 0.8
    self.viewworld_button:SetScale(button_scale)
    self.viewgroup_button:SetScale(button_scale)
    self.viewplayers_button:SetScale(button_scale)
    self.viewmods_button:SetScale(button_scale)
    self.viewtags_button:SetScale(button_scale)
    self.toggleservertext_button:SetScale(button_scale)

    self.view_additional_details_btns = self.server_details_additional:AddChild(Grid())
    detail_y = detail_y - 55
    local detail_buttons = {
        self.viewmods_button,
        self.viewtags_button,
        self.viewworld_button,
        self.viewgroup_button,
        self.viewplayers_button,
        self.toggleservertext_button,
    }
    local button_width = 56 * button_scale
	local button_spacing = 6
    self.view_additional_details_btns:SetPosition(detail_x - ((#detail_buttons-1) * (button_width + button_spacing))/4 , detail_y - button_width/2)
    self.view_additional_details_btns:FillGrid(#detail_buttons/2, button_width + button_spacing, button_width, detail_buttons)

    self.server_details_additional.focus_forward = self.view_additional_details_btns
    self.view_additional_details_btns:SetFocusChangeDir(MOVE_LEFT, function() return self:CurrentCenterFocus() end, MOVE_LEFT)
    detail_y = detail_y - 65

    self.game_mode_description = self.server_details_additional:AddChild(Widget("gamemodedesc"))
    detail_y = detail_y - 48
    self.game_mode_description:SetPosition(detail_x, detail_y)
    self.game_mode_description.text = self.game_mode_description:AddChild(Text(CHATFONT, 20))
    self.game_mode_description.text:SetString(STRINGS.UI.SERVERLISTINGSCREEN.SURVIVAL)
    self.game_mode_description.text:SetPosition(-10,0)
    self.game_mode_description.text:SetHAlign(ANCHOR_MIDDLE)
    -- self.game_mode_description.text:SetRegionSize( 200, 50 )
    self.game_mode_description.text:SetString("???")
    self.game_mode_description.text:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
    self.game_mode_description.info_button = self.game_mode_description:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "info.tex", nil, false, false, function()
            local mode_title = GetGameModeString( self.selected_server.mode )
            if mode_title == "" then
                mode_title = STRINGS.UI.GAMEMODES.UNKNOWN
            end
            local mode_body = GetGameModeDescriptionString( self.selected_server.mode )
            if mode_body == "" then
                mode_body = STRINGS.UI.GAMEMODES.UNKNOWN_DESCRIPTION
            end
            TheFrontEnd:PushScreen(PopupDialogScreen(
                mode_title,
                mode_body,
                {{ text = STRINGS.UI.SERVERLISTINGSCREEN.OK, cb = function() TheFrontEnd:PopScreen() end }},
                nil,
                "big"
            ))
        end))
    -- info_button position is set in update
    self.game_mode_description.info_button:SetScale(.5)
    self.game_mode_description.info_button:SetFocusChangeDir(MOVE_UP, function() return self.viewworld_button end)
    self.view_additional_details_btns:SetFocusChangeDir(MOVE_DOWN, function() return self.game_mode_description.info_button end)

    local check_x = -80
    local label_x = 40

    self.season_description = self.server_details_additional:AddChild(Widget("seasondesc"))
    detail_y = detail_y - 30
    self.season_description:SetPosition(detail_x, detail_y)
    self.season_description.text = self.season_description:AddChild(Text(CHATFONT, 20))
    self.season_description.text:SetPosition(-10,0)
    self.season_description.text:SetHAlign(ANCHOR_MIDDLE)
    self.season_description.text:SetRegionSize( 400, 50 )
    self.season_description.text:SetString("???")
    self.season_description.text:SetColour(UICOLOURS.GOLD_UNIMPORTANT)

    self.day_description = self.server_details_additional:AddChild(Widget("daydesc"))
    detail_y = detail_y - 30
    self.day_description:SetPosition(detail_x, detail_y)
    self.day_description.text = self.day_description:AddChild(Text(CHATFONT, 20))
    self.day_description.text:SetPosition(-10,0)
    self.day_description.text:SetHAlign(ANCHOR_MIDDLE)
    self.day_description.text:SetRegionSize( 400, 50 )
    self.day_description.text:SetString("???")
    self.day_description.text:SetColour(UICOLOURS.GOLD_UNIMPORTANT)

    local has_password = self.server_details_additional:AddChild(Widget("pw"))
    detail_y = detail_y - 30
    has_password:SetPosition(detail_x, detail_y)
    self.checkbox_has_password = has_password:AddChild(TEMPLATES.ServerDetailIcon("images/servericons.xml", "password.tex", "rust", nil, nil, {-1,0}, .08, .073))
    self.checkbox_has_password:SetPosition(check_x, 0, 0)
    self.checkbox_has_password.off_image = self.checkbox_has_password:AddChild(Image("images/servericons.xml", "bg_grey.tex"))
    self.checkbox_has_password.off_image:SetTint(1,1,1,.7)
    self.checkbox_has_password.off_image:SetScale(.09)
    self.checkbox_has_password.off_image:Hide()
    self.has_password_description = has_password:AddChild(Text(CHATFONT, 20))
    self.has_password_description:SetPosition(label_x, 0, 0)
    self.has_password_description:SetString(STRINGS.UI.SERVERLISTINGSCREEN.HASPASSWORD_DETAIL)
    self.has_password_description:SetHAlign(ANCHOR_LEFT)
    self.has_password_description:SetRegionSize( 200, 50 )
    self.has_password_description:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
    SetChecked( self.checkbox_has_password, self.has_password_description, false )

    local dedicated_server = self.server_details_additional:AddChild(Widget("ded"))
    detail_y = detail_y - 26
    dedicated_server:SetPosition(detail_x, detail_y)
    self.checkbox_dedicated_server = dedicated_server:AddChild(TEMPLATES.ServerDetailIcon("images/servericons.xml", "dedicated.tex", "brown", nil, nil, nil, .08, .073))
    self.checkbox_dedicated_server:SetPosition(check_x, 0, 0)
    self.checkbox_dedicated_server.off_image = self.checkbox_dedicated_server:AddChild(Image("images/servericons.xml", "bg_grey.tex"))
    self.checkbox_dedicated_server.off_image:SetTint(1,1,1,.7)
    self.checkbox_dedicated_server.off_image:SetScale(.09)
    self.checkbox_dedicated_server.off_image:Hide()
    self.dedicated_server_description = dedicated_server:AddChild(Text(CHATFONT, 20))
    self.dedicated_server_description:SetPosition(label_x, 0, 0)
    self.dedicated_server_description:SetString(STRINGS.UI.SERVERLISTINGSCREEN.ISDEDICATED)
    self.dedicated_server_description:SetHAlign(ANCHOR_LEFT)
    self.dedicated_server_description:SetRegionSize( 200, 50 )
    self.dedicated_server_description:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
    SetChecked( self.checkbox_dedicated_server, self.dedicated_server_description, false )

    local pvp = self.server_details_additional:AddChild(Widget("pvp"))
    detail_y = detail_y - 26
    pvp:SetPosition(detail_x, detail_y)
    self.checkbox_pvp = pvp:AddChild(TEMPLATES.ServerDetailIcon("images/servericons.xml", "pvp.tex", "burnt"))
    self.checkbox_pvp:SetPosition(check_x, 0, 0)
    self.checkbox_pvp.off_image = self.checkbox_pvp:AddChild(Image("images/servericons.xml", "bg_grey.tex"))
    self.checkbox_pvp.off_image:SetTint(1,1,1,.7)
    self.checkbox_pvp.off_image:SetScale(.09)
    self.checkbox_pvp.off_image:Hide()
    self.pvp_description = pvp:AddChild(Text(CHATFONT, 20))
    self.pvp_description:SetPosition(label_x, 0, 0)
    self.pvp_description:SetString(STRINGS.UI.SERVERLISTINGSCREEN.HASPVP_DETAIL)
    self.pvp_description:SetHAlign(ANCHOR_LEFT)
    self.pvp_description:SetRegionSize( 200, 50 )
    self.pvp_description:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
    SetChecked( self.checkbox_pvp, self.pvp_description, false )
end

function ServerListingScreen:_MakeServerListHeader()
    self.title = self.server_list_titles:AddChild(Text(CHATFONT, 28, STRINGS.UI.SERVERLISTINGSCREEN.SERVER_LIST_TITLE))
    self.title:SetColour(UICOLOURS.GOLD_UNIMPORTANT)

    self.server_count = self.server_list_titles:AddChild(Text(CHATFONT, 25, "(0)"))
    self.server_count:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
    self.server_count:SetRegionSize(300,40)
    self.server_count:SetHAlign(ANCHOR_RIGHT)
    self.server_count:SetPosition(server_list_width/2 - 140, 0)
end

function ServerListingScreen:OnControl(control, down)
    if ServerListingScreen._base.OnControl(self, control, down) then return true end

    if self.searchbox and ((self.searchbox.textbox and self.searchbox.textbox.editing) or (self.searchbox.focus and control == CONTROL_ACCEPT)) then
        self.searchbox.textbox:OnControl(control, down)
        return true
    end

    if not down then
        if control == CONTROL_CANCEL then
            if TheFrontEnd:GetFadeLevel() > 0 then
                TheNet:Disconnect(false)
                HideCancelTip()
                TheFrontEnd:Fade(FADE_IN, SCREEN_FADE_TIME)
            else
                self:Cancel()
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
            end
        elseif control == CONTROL_MENU_START and self.selected_server and TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
            self:Join(false)
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        elseif control == CONTROL_MENU_L2 or control == CONTROL_MENU_R2 then
            self:ToggleShowFilters()
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        elseif control == CONTROL_MENU_MISC_2 and not TheNet:IsSearchingServers() then
            self:SearchForServers()
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        elseif control == CONTROL_MENU_MISC_1 then
            self:CycleColumnSort()
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        else
            return false
        end

        return true
    end
end

function ServerListingScreen:CurrentCenterFocus()
    if self.view_online and self.server_playstyle.id == nil then
        return self.playstyle_overlay
    else
        if #self.servers_scroll_list.items > 0 then
            return self.servers_scroll_list
        else
            return self.sorting_spinner
        end
    end
end

function ServerListingScreen:CurrentRightFocus()
    if self.filters_scroll_list and self.filters_scroll_list:IsVisible() then
        return self.filters_scroll_list
    elseif self.server_details_additional:IsVisible() then
        return self.view_additional_details_btns
    end
end

function ServerListingScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_L2).."/"..TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_R2).. " " .. STRINGS.UI.HELP.CHANGE_TAB)

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_1) .. " " .. STRINGS.UI.SERVERLISTINGSCREEN.CHANGE_SORT)

    if not TheNet:IsSearchingServers() then
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2) .. " " .. STRINGS.UI.SERVERLISTINGSCREEN.REFRESH)
    end

    if self.selected_server then
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_START) .. " " .. STRINGS.UI.SERVERLISTINGSCREEN.JOIN)
    end

    return table.concat(t, "  ")
end

function OnServerListingUpdated(row_id)
    local active_screen = TheFrontEnd:GetActiveScreen()
    if active_screen and tostring(active_screen) == "ServerListingScreen" and active_screen.selected_server
    and active_screen.selected_server.row and active_screen.selected_server.row == row_id and active_screen.selected_server.actualindex then
        active_screen.selected_server = TheNet:GetServerListingFromActualIndex( active_screen.selected_server.actualindex )
    end
end

return ServerListingScreen
