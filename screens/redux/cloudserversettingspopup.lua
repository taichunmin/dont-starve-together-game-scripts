-- A dialog to spin up cloud servers.
--
-- Cloud servers must be nonpvp, dedicated, nonlocal, online, and multiplayer.
local IntentionPicker = require "widgets/redux/intentionpicker"
local NewHostPicker = require "widgets/newhostpicker"
local PopupDialogScreen = require "screens/redux/popupdialog"
local RadioButtons = require "widgets/radiobuttons"
local Screen = require "widgets/screen"
local ScrollableList = require "widgets/scrollablelist"
local Widget = require "widgets/widget"
local HostCloudServerPopup = require "screens/redux/hostcloudserverpopup"

local TEMPLATES = require "widgets/redux/templates"

require("constants")
require("util")

local wide_label_width = 120 -- width of the label on the wide fields
local wide_input_width = 315 -- width of the input box on the wide fields
local wide_field_nudge = -30
local narrow_label_width = 220 -- width of the label on the narrow fields
local narrow_input_width = 150 -- width of th input/spinner on the narrow fields
local narrow_field_nudge = -50
local label_height = 40
local space_between = 5
local font_size = 25
if JapaneseOnPS4() then
    font_size = 25 * 0.75
end

local STRING_MAX_LENGTH = 254 -- http://tools.ietf.org/html/rfc5321#section-4.5.3.1
local SERVER_NAME_MAX_LENGTH = 80

local privacy_options = {
    {text=STRINGS.UI.SERVERCREATIONSCREEN.PRIVACY.PUBLIC,    data=PRIVACY_TYPE.PUBLIC},
    -- Friends-only is tied to the host and isn't available for cloud servers.
    -- e.g. The user requesting the server is not guaranteed to even be on the server.
    --{text=STRINGS.UI.SERVERCREATIONSCREEN.PRIVACY.FRIENDS,   data=PRIVACY_TYPE.FRIENDS},
}
if PLATFORM ~= "WIN32_RAIL" then
    table.insert( privacy_options, {text=STRINGS.UI.SERVERCREATIONSCREEN.PRIVACY.CLAN, data=PRIVACY_TYPE.CLAN} )
end
local privacy_buttons = {
    width = 140,
    height = label_height,
    font = NEWFONT,
    font_size = font_size,
    image_scale = 0.7,
    atlas = "images/global_redux.xml",
    on_image = "radiobutton_gold_on.tex",
    off_image = "radiobutton_gold_off.tex",
    normal_colour = UICOLOURS.GOLD,
    hover_colour = UICOLOURS.HIGHLIGHT_GOLD,
    selected_colour = UICOLOURS.GOLD,
    disabled_colour = GREY,
}

local function GetNextTextbox(self, current)
    local found = nil
    for i, v in ipairs(self.scroll_list.items) do
        if v.textbox ~= nil then
            if found ~= nil then
                if v.textbox:IsVisible() then
                    return v.textbox
                end
            elseif v.textbox == current then
                found = i
            end
        end
    end
    if found == nil then
        return
    end
    for i, v in ipairs(self.scroll_list.items) do
        if i == found then
            return
        elseif v.textbox ~= nil and v.textbox:IsVisible() then
            return v.textbox
        end
    end
end

local CloudServerSettingsPopup = Class(Screen, function(self, prev_screen, user_profile, forced_settings, dirty_cb)
    Screen._ctor(self, "CloudServerSettingsPopup")

    self.forced_settings = forced_settings or {}

    self.dirty_cb = dirty_cb or function(server_settings) end

    self.root = self:AddChild(TEMPLATES.ScreenRoot())
    self.tint = self.root:AddChild(TEMPLATES.BackgroundTint())

    self.item_height = 35
    self.item_padding = 10
    self.hidden_height = (self.item_height + self.item_padding) * GetTableSize(self.forced_settings)
    self.list_height = 300 - self.hidden_height
    self.buttons_height = 40
    self.dialog_width = 450
    self.dialog_height = self.list_height + self.buttons_height + 2 * self.item_padding

    local menu_buttons = {
        {
            cb = function() if self:ValidateSettings() then self:Hide() TheFrontEnd:PushScreen(HostCloudServerPopup(self:GetServerName(), self:GetServerDescription(), self:GetPassword(), self:GetClanInfo())) end end,
            text = STRINGS.UI.CLOUDSERVERCREATIONSCREEN.CREATE,
        },
        {
            cb = function() TheFrontEnd:PopScreen() end,
            text = STRINGS.UI.SERVERCREATIONSCREEN.CANCEL,
        },
    }
    self.dialog = self.root:AddChild(TEMPLATES.CurlyWindow(self.dialog_width, self.dialog_height, STRINGS.UI.CLOUDSERVERCREATIONSCREEN.TITLE, menu_buttons))
    self.server_settings_page = self.dialog:AddChild(Widget("server_settings_page"))
    self.server_settings_page:SetPosition(110, self.buttons_height - 2)

    self.intentions_overlay = self.root:AddChild(IntentionPicker( STRINGS.UI.SERVERCREATIONSCREEN.INTENTION_TITLE, STRINGS.UI.SERVERCREATIONSCREEN.INTENTION_DESC))
    self.intentions_overlay:SetCallback(function(intention)
        self:SetServerIntention(intention)
        self.dirty_cb(self)
    end)
    self.intentions_overlay:SetPosition(0, 190)
    self.intentions_overlay.bg = self.intentions_overlay:AddChild(TEMPLATES.RectangleWindow(650,450))
    self.intentions_overlay.bg:MoveToBack()
    self.intentions_overlay.bg:SetPosition(0,-170)
    local r,g,b = unpack(UICOLOURS.BROWN_DARK)
    self.intentions_overlay.bg:SetBackgroundTint(r,g,b,1) -- Must be opaque because we look like a popup over text behind.

    if self.forced_settings.server_intention == nil then
        self.server_intention = TEMPLATES.LabelButton(
            function(data)
                self:SetServerIntention(nil)
                self.dirty_cb(self)
            end,
            STRINGS.UI.SERVERCREATIONSCREEN.INTENTION_LABEL, "", narrow_label_width, narrow_input_width, label_height, space_between, NEWFONT, font_size, narrow_field_nudge)
    end

    self.server_name = TEMPLATES.LabelTextbox(STRINGS.UI.SERVERCREATIONSCREEN.SERVERNAME, "", wide_label_width, wide_input_width, label_height, space_between, NEWFONT, font_size, wide_field_nudge)
    self.server_name.textbox:SetTextLengthLimit( SERVER_NAME_MAX_LENGTH )
    self.server_name.textbox.OnTextInputted = function()
        self.dirty_cb(self)
    end

    self.server_desc = TEMPLATES.LabelTextbox(STRINGS.UI.SERVERCREATIONSCREEN.SERVERDESC, nil, wide_label_width, wide_input_width, label_height, space_between, NEWFONT, font_size, wide_field_nudge)
    self.server_desc.textbox:SetTextLengthLimit( STRING_MAX_LENGTH )
    self.server_desc.textbox.OnTextInputted = function() self.dirty_cb(self) end

    self.server_pw = TEMPLATES.LabelTextbox(STRINGS.UI.SERVERCREATIONSCREEN.SERVERPASSWORD, nil, wide_label_width, wide_input_width, label_height, space_between, NEWFONT, font_size, wide_field_nudge)
    self.server_pw.textbox:SetTextLengthLimit( STRING_MAX_LENGTH )
    if not Profile:GetShowPasswordEnabled() then
        self.server_pw.textbox:SetPassword(true)
    end
    self.server_pw.textbox.OnTextInputted = function() self.dirty_cb(self) end

    self.server_name.textbox:SetOnTabGoToTextEditWidget(function() return GetNextTextbox(self, self.server_name.textbox) end)
    self.server_desc.textbox:SetOnTabGoToTextEditWidget(function() return GetNextTextbox(self, self.server_desc.textbox) end)
    self.server_pw.textbox:SetOnTabGoToTextEditWidget(function() return GetNextTextbox(self, self.server_pw.textbox) end)

	local include_privacy_options = PLATFORM == "WIN32_STEAM" or PLATFORM == "LINUX_STEAM" or PLATFORM == "OSX_STEAM"

    if self.forced_settings.privacy_type == nil then
        self.privacy_type = Widget("Privacy Group")
        self.privacy_type.buttons = self.privacy_type:AddChild(RadioButtons(privacy_options, 450, 50, privacy_buttons, true))
        self.privacy_type.buttons:SetPosition(-190,0)
        self.privacy_type.buttons:SetOnChangedFn(function(data)
            self:DisplayClanControls(data == PRIVACY_TYPE.CLAN)
            self.dirty_cb(self)
        end)
        self.privacy_type.focus_forward = self.privacy_type.buttons

        if not include_privacy_options then
			self.privacy_type.buttons:Hide()
		end
    end

	self.clan_id = TEMPLATES.LabelTextbox(STRINGS.UI.SERVERCREATIONSCREEN.CLANID, nil, narrow_label_width, narrow_input_width, label_height, space_between, NEWFONT, font_size, narrow_field_nudge)
	self.clan_id.textbox:SetTextLengthLimit( 12 )
	self.clan_id.textbox:SetCharacterFilter( "0123456789" )
	self.clan_id.textbox.OnTextInputted = function() self.dirty_cb(self) end

	self.clan_id.textbox:SetOnTabGoToTextEditWidget(function() return GetNextTextbox(self, self.clan_id.textbox) end)

	local clan_only_options = {
		{ text = STRINGS.UI.SERVERCREATIONSCREEN.NO, data = false },
		{ text = STRINGS.UI.SERVERCREATIONSCREEN.YES, data = true }
	}
	self.clan_only = TEMPLATES.LabelSpinner(STRINGS.UI.SERVERCREATIONSCREEN.CLANONLY, clan_only_options, narrow_label_width, narrow_input_width, label_height, space_between, NEWFONT, font_size, narrow_field_nudge)
	self.clan_only.spinner:SetOnChangedFn(function() self.dirty_cb(self) end)

	--[[local clan_admin_options = {
		{ text = STRINGS.UI.SERVERCREATIONSCREEN.NO, data = false },
		{ text = STRINGS.UI.SERVERCREATIONSCREEN.YES, data = true }
	}
	self.clan_admins = TEMPLATES.LabelSpinner(STRINGS.UI.SERVERCREATIONSCREEN.CLANADMIN, clan_admin_options, narrow_label_width, narrow_input_width, label_height, space_between, NEWFONT, font_size, narrow_field_nudge)
	self.clan_admins.spinner:SetOnChangedFn(function() self.dirty_cb(self) end)]]

    if self.forced_settings.game_mode == nil then
        self.game_mode = TEMPLATES.LabelSpinner(STRINGS.UI.SERVERCREATIONSCREEN.GAMEMODE, GetGameModesSpinnerData(ModManager:GetEnabledServerModNames()), narrow_label_width, narrow_input_width, label_height, space_between, NEWFONT, font_size, narrow_field_nudge)
        self.game_mode.spinner:SetOnChangedFn(function(selected, old)
            self.dirty_cb(self)
        end)

        self.game_mode.info_button = self.game_mode:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "info.tex", nil, false, false, function()
            local mode_title = GetGameModeString( self.game_mode.spinner:GetSelectedData() )
            if mode_title == "" then
                mode_title = STRINGS.UI.GAMEMODES.UNKNOWN
            end
            local mode_body = GetGameModeDescriptionString( self.game_mode.spinner:GetSelectedData() )
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
        self.game_mode.info_button:SetPosition(160, -2)
        self.game_mode.info_button:SetScale(.4)
        self.game_mode.info_button:SetFocusChangeDir(MOVE_LEFT, self.game_mode.spinner)
        self.game_mode.spinner:SetFocusChangeDir(MOVE_RIGHT, self.game_mode.info_button)
    end

    if self.forced_settings.max_players == nil then
        local numplayer_options = {}
        for i = 2, TUNING.MAX_SERVER_SIZE do
            table.insert(numplayer_options,{text=i, data=i})
        end
        self.max_players = TEMPLATES.LabelSpinner(STRINGS.UI.SERVERCREATIONSCREEN.MAXPLAYERS, numplayer_options, narrow_label_width, narrow_input_width, label_height, space_between, NEWFONT, font_size, narrow_field_nudge)
        self.max_players.spinner:SetSelected(TheNet:GetDefaultMaxPlayers())
        self.max_players.spinner:SetOnChangedFn(function(selected, old)
            self.dirty_cb(self)
        end)
    end

    -- We don't create all widgets but want to order them here how they'll be
    -- seen in the widget, so some funkiness follows.
    self.page_widgets = {}
    local function AddIfValid(w)
        if w then
            table.insert(self.page_widgets, w)
        end
    end
    AddIfValid(self.server_intention)
    AddIfValid(self.server_name)
    AddIfValid(self.server_desc)
    if include_privacy_options then
		AddIfValid(self.privacy_type)
	end
    AddIfValid(self.game_mode)
    AddIfValid(self.max_players)
    AddIfValid(self.server_pw)

    self.clan_widgets =
    {
        self.clan_id,
        self.clan_only,
        --self.clan_admins,
    }

    self.scroll_list = self.server_settings_page:AddChild(ScrollableList(self.page_widgets, 260, self.list_height + self.item_padding, self.item_height, self.item_padding))
    self.scroll_list:Hide()

    self.scroll_list:SetFocusChangeDir(MOVE_DOWN, self.dialog.actions)
    self.dialog.actions:SetFocusChangeDir(MOVE_UP, self.scroll_list)

    self.default_focus = self.scroll_list
    self.focus_forward = self.scroll_list

    --Internal data
    self.encode_user_path = true
    self.use_legacy_session_path = nil

    -- Skip the intention picker if forced.
    self:SetServerIntention(self.forced_settings.server_intention)

    -- Ensure widgets are updated to a valid state.
    self:DisplayClanControls(self:GetPrivacyType() == PRIVACY_TYPE.CLAN)
end)

function CloudServerSettingsPopup:OnBecomeActive()
    CloudServerSettingsPopup._base.OnBecomeActive(self)
    self:Show()
    local focus = self:GetDeepestFocus()
    if focus.textbox ~= nil then
        focus.textbox:SetEditing(true)
    end
end

function CloudServerSettingsPopup:RefreshPrivacyButtons()
	self.privacy_type.buttons:EnableAllButtons()
	if self._cached_privacy_setting ~= nil then
		self.privacy_type.buttons:SetSelected(self._cached_privacy_setting)
	end
end

function CloudServerSettingsPopup:RefreshIntentionsButton()
    self.server_intention.button:SetText(self.server_intention.button.data ~= nil and STRINGS.UI.INTENTION[string.upper(self.server_intention.button.data)] or "")
end

function CloudServerSettingsPopup:DisplayClanControls(show)
    -- These controls don't get cleaned up properly unless they have a parent, so we shuffle them between the scroll list and ourselves.
	if show then
		local expand_height = 2 * (self.item_height + self.item_padding)
		self.dialog:SetSize(self.dialog_width, self.dialog_height + expand_height)
		self.scroll_list.height = self.list_height + expand_height + self.item_padding
		self:RemoveChild(self.clan_id)
		self:RemoveChild(self.clan_only)
		--self:RemoveChild(self.clan_admins)
		local nextrow = nil
		for i, v in ipairs(self.page_widgets) do
			if v == self.privacy_type then
				i, nextrow = next(self.page_widgets, i)
			end
		end
		self.scroll_list:AddItem(self.clan_id, nextrow)
		self.scroll_list:AddItem(self.clan_only, nextrow)
		--self.scroll_list:AddItem(self.clan_admins, nextrow)
		self.clan_id:SetFocus()
		self.clan_id.textbox:SetEditing(true)
	else
		self.dialog:SetSize(self.dialog_width, self.dialog_height)
		self.scroll_list.height = self.list_height + self.item_padding
		self.scroll_list:RemoveItem(self.clan_id)
		self.scroll_list:RemoveItem(self.clan_only)
		--self.scroll_list:RemoveItem(self.clan_admins)
		self:AddChild(self.clan_id)
		self:AddChild(self.clan_only)
		--self:AddChild(self.clan_admins)
		self.clan_id:Hide()
		self.clan_only:Hide()
		--self.clan_admins:Hide()
	end
end

function CloudServerSettingsPopup:OnControl(control, down)
    if CloudServerSettingsPopup._base.OnControl(self, control, down) then return true end

    -- Force these damn things to gobble controls if they're editing (stupid missing focus/hover distinction)
    if self.server_name.textbox and (self.server_name.textbox.editing or (self.server_name.focus and control == CONTROL_ACCEPT)) then
        self.server_name.textbox:OnControl(control, down)
        return true
    elseif self.server_pw.textbox and (self.server_pw.textbox.editing or (self.server_pw.focus and control == CONTROL_ACCEPT)) then
        self.server_pw.textbox:OnControl(control, down)
        return true
    elseif self.server_desc.textbox and (self.server_desc.textbox.editing or (self.server_desc.focus and control == CONTROL_ACCEPT)) then
        self.server_desc.textbox:OnControl(control, down)
        return true
    elseif not down and control == CONTROL_CANCEL then
        TheFrontEnd:PopScreen()
        return true
    end
end

function CloudServerSettingsPopup:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.SERVERCREATIONSCREEN.CANCEL)

    return table.concat(t, "  ")
end

function CloudServerSettingsPopup:SetServerIntention(intention)
    assert(self.forced_settings.server_intention == nil or self.forced_settings.server_intention == intention)

    if self.server_intention then
        self.server_intention.button.data = intention

        self:RefreshIntentionsButton()
    end

    if intention ~= nil then
        self.intentions_overlay:SetSelected(intention)
    end

    self:ShowServerIntention(intention == nil)
end

function CloudServerSettingsPopup:ShowServerIntention(show)
    if show then
        if not Profile:SawNewHostPicker() then
            self:ShowNewHostPicker(true)
            self.intentions_overlay:Hide()
            self.default_focus = self.newhost_overlay
        else
            self:ShowNewHostPicker(false)
            self.intentions_overlay:Show()
            self.default_focus = self.intentions_overlay
        end
        self.scroll_list:Hide()
    else
        self:ShowNewHostPicker(false)
        self.intentions_overlay:Hide()
        self.scroll_list:Show()
        self.default_focus = self.scroll_list
    end

    self.focus_forward = self.default_focus
    if self.focus then
        self.default_focus:SetFocus()
    end
end

function CloudServerSettingsPopup:ShowNewHostPicker(show)
    if show then
        if self.newhost_overlay == nil then
            self.newhost_overlay = self:AddChild(NewHostPicker())
            self.newhost_overlay:SetPosition(-115, 180)
            self.newhost_overlay:SetCallback(function(data)
                Profile:ShowedNewHostPicker()
                Profile:Save(function()
                    if data == "ALONE" then
                        self.max_players.spinner:SetSelected(1)
                        self:SetServerIntention(INTENTIONS.COOPERATIVE)
                        self:RefreshPrivacyButtons()
                    end
                    self:ShowServerIntention(self.server_intention.button.data == nil)
                    self.dirty_cb(self)
                end)
            end)
        end
    elseif self.newhost_overlay ~= nil then
        self.newhost_overlay:Kill()
        self.newhost_overlay = nil
    end
end

function CloudServerSettingsPopup:UpdateDetails()
    self._cached_privacy_setting = nil

    self.game_mode.spinner:SetOptions( GetGameModesSpinnerData( ModManager:GetEnabledServerModNames() ) )

    -- No save data
    if true then

        local online = TheNet:IsOnlineMode() and not TheFrontEnd:GetIsOfflineMode()

        self.game_mode.spinner:SetSelected(DEFAULT_GAME_MODE)
        self.max_players.spinner:SetSelected(TUNING.MAX_SERVER_SIZE)
        self.server_name.textbox:SetString(subfmt(STRINGS.UI.SERVERCREATIONSCREEN.NEWGAME_FMT, { name = TheNet:GetLocalUserName() }))
        self.server_pw.textbox:SetString("")
        self.server_desc.textbox:SetString("")
        self.privacy_type.buttons:SetSelected(PRIVACY_TYPE.PUBLIC)
        self.encode_user_path = true
        self.use_legacy_session_path = nil

        self:SetServerIntention(nil)
        self:SetOnlineWidgets(online)

        self.game_mode.spinner:Enable()
    end
end

function CloudServerSettingsPopup:GetServerIntention()
    return self.forced_settings.server_intention or self.server_intention.button.data
end

function CloudServerSettingsPopup:GetServerName()
    return self.server_name.textbox:GetString()
end

function CloudServerSettingsPopup:GetServerDescription()
    return self.server_desc.textbox:GetString()
end

function CloudServerSettingsPopup:GetPassword()
    return self.server_pw.textbox:GetLineEditString()
end

function CloudServerSettingsPopup:GetGameMode()
    return self.forced_settings.game_mode or self.game_mode.spinner:GetSelectedData()
end

function CloudServerSettingsPopup:GetMaxPlayers()
    return self.forced_settings.max_players or self.max_players.spinner:GetSelectedData()
end

function CloudServerSettingsPopup:GetPVP()
    return false
end

function CloudServerSettingsPopup:GetPrivacyType()
    return self.forced_settings.privacy_type or self.privacy_type.buttons:GetSelectedData()
end

function CloudServerSettingsPopup:GetClanInfo()
    --V2C: admin flag is ignored for cloud servers
	return {
		id = self.clan_id.textbox:GetString(),
		only = self.clan_only.spinner:GetSelectedData(),
		admin = false,--self.clan_admins.spinner:GetSelectedData(),
	}
end

function CloudServerSettingsPopup:GetOnlineMode()
    return true
end

function CloudServerSettingsPopup:GetEncodeUserPath()
    return self.encode_user_path
end

function CloudServerSettingsPopup:GetUseClusterPath()
    return not self.use_legacy_session_path
end

function CloudServerSettingsPopup:GetUseLegacySessionPath()
    return self.use_legacy_session_path
end

function CloudServerSettingsPopup:GetServerData()
    return {
        intention = self:GetServerIntention(),
        pvp = self:GetPVP(),
        game_mode = self:GetGameMode(),
        online_mode = self:GetOnlineMode(),
        encode_user_path = self:GetEncodeUserPath(),
        use_legacy_session_path = self:GetUseLegacySessionPath(),
        max_players = self:GetMaxPlayers(),
        name = self:GetServerName(),
        password = self:GetPassword(),
        description = self:GetServerDescription(),
        privacy_type = self:GetPrivacyType(),
        clan = self:GetClanInfo(),
    }
end

function CloudServerSettingsPopup:ValidateSettings()
    if not self:VerifyValidServerIntention() then
        self:Hide()
        TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.SERVERCREATIONSCREEN.INVALIDINTENTIONSETTINGS_TITLE, STRINGS.UI.SERVERCREATIONSCREEN.INVALIDINTENTIONSETTINGS_BODY,
                    {{text=STRINGS.UI.CUSTOMIZATIONSCREEN.OKAY, cb = function() TheFrontEnd:PopScreen() end}}))
        return false
    elseif not self:VerifyValidServerName() then
        self:Hide()
        TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.SERVERCREATIONSCREEN.INVALIDSERVERNAME_TITLE, STRINGS.UI.SERVERCREATIONSCREEN.INVALIDSERVERNAME_BODY,
                    {{text=STRINGS.UI.CUSTOMIZATIONSCREEN.OKAY, cb = function() TheFrontEnd:PopScreen() self.server_name:SetFocus() self.server_name.textbox:SetEditing(true) end}}))
        return false
    elseif not self:VerifyValidClanSettings() then
        self:Hide()
        TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.SERVERCREATIONSCREEN.INVALIDCLANSETTINGS_TITLE, STRINGS.UI.SERVERCREATIONSCREEN.INVALIDCLANSETTINGS_BODY,
                    {{text=STRINGS.UI.CUSTOMIZATIONSCREEN.OKAY, cb = function() TheFrontEnd:PopScreen() self.clan_id:SetFocus() self.clan_id.textbox:SetEditing(true) end}}))
        return false
    elseif not self:VerifyValidPassword() then
        self:Hide()
        TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.SERVERCREATIONSCREEN.INVALIDPASSWORD_TITLE, STRINGS.UI.SERVERCREATIONSCREEN.INVALIDPASSWORD_BODY,
                    {{text=STRINGS.UI.CUSTOMIZATIONSCREEN.OKAY, cb = function() TheFrontEnd:PopScreen() self.server_pw:SetFocus() self.server_pw.textbox:SetEditing(true) end}}))
        return false
    end

    return true
end

function CloudServerSettingsPopup:VerifyValidClanSettings()
    return self.privacy_type.buttons:GetSelectedData() ~= PRIVACY_TYPE.CLAN or TheNet:IsClanIDValid(self.clan_id.textbox:GetString())
end

function CloudServerSettingsPopup:VerifyValidServerName()
    return self.server_name.textbox:GetString() ~= ""
end

function CloudServerSettingsPopup:VerifyValidServerIntention()
    return self:GetServerIntention() ~= nil
end

function CloudServerSettingsPopup:VerifyValidPassword()
    local pw = self.server_pw.textbox:GetLineEditString()
    return pw == "" or pw:match("^%s*(.-%S)%s*$") == pw
end

function CloudServerSettingsPopup:SetEditingTextboxes(edit)
    self.server_name.textbox:SetEditing(edit)
    self.server_pw.textbox:SetEditing(edit)
    self.server_desc.textbox:SetEditing(edit)
    self.clan_id.textbox:SetEditing(edit)
end

return CloudServerSettingsPopup
