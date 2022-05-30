local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ScrollableList = require "widgets/scrollablelist"
local RadioButtons = require "widgets/radiobuttons"
local NewHostPicker = require "widgets/redux/newhostpicker"
local IntentionPicker = require "widgets/redux/intentionpicker"
local PopupDialogScreen = require "screens/redux/popupdialog"
local TEMPLATES = require "widgets/redux/templates"

local wide_label_width = 200 -- width of the label on the wide fields
local wide_input_width = 315 -- width of the input box on the wide fields
local wide_field_nudge = -55
local narrow_label_width = 220 -- width of the label on the narrow fields
local narrow_input_width = 280 -- width of th input/spinner on the narrow fields
local picker_x_offset = 0
local picker_y_offset = 230

local narrow_field_nudge = -50
local label_height = 40
local space_between = 5
local font_size = 25

local STRING_MAX_LENGTH = 254 -- http://tools.ietf.org/html/rfc5321#section-4.5.3.1
local SERVER_NAME_MAX_LENGTH = 80

local privacy_options = {
    {text=STRINGS.UI.SERVERCREATIONSCREEN.PRIVACY.PUBLIC,    data=PRIVACY_TYPE.PUBLIC},
    {text=STRINGS.UI.SERVERCREATIONSCREEN.PRIVACY.FRIENDS,   data=PRIVACY_TYPE.FRIENDS},
    {text=STRINGS.UI.SERVERCREATIONSCREEN.PRIVACY.LOCAL,     data=PRIVACY_TYPE.LOCAL},
}
if not IsRail() and IsNotConsole() then
    table.insert( privacy_options, {text=STRINGS.UI.SERVERCREATIONSCREEN.PRIVACY.CLAN, data=PRIVACY_TYPE.CLAN} )
end
local privacy_buttons = {
    width = 155,
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

local privacy_width = #privacy_options * 160
local max_width = 800
--~ assert(max_width > privacy_width)
--~ assert(max_width > wide_label_width + wide_input_width)
--~ assert(max_width > narrow_label_width + narrow_input_width)

local ServerSettingsTab = Class(Widget, function(self, servercreationscreen)
    Widget._ctor(self, "ServerSettingsTab")

    self.servercreationscreen = servercreationscreen

    self.server_settings_page = self:AddChild(Widget("server_settings_page"))

    --do this here to prevent loops on load
    local ServerSaveSlot = require "widgets/redux/serversaveslot"
    self.serverslot = self:AddChild(ServerSaveSlot(servercreationscreen.server_slot_screen, true))
    self.serverslot:SetPosition(0, 295)

    self.intentions_overlay = self:AddChild(IntentionPicker( STRINGS.UI.SERVERCREATIONSCREEN.INTENTION_TITLE, STRINGS.UI.SERVERCREATIONSCREEN.INTENTION_DESC))
    self.intentions_overlay:SetCallback(function(intention)
        self:SetServerIntention(intention)
        self.servercreationscreen:MakeDirty()
    end)
    self.intentions_overlay:SetPosition(picker_x_offset, picker_y_offset)

    self.server_intention = TEMPLATES.LabelButton(
        function(data)
            self:SetServerIntention(nil)
            self.servercreationscreen:MakeDirty()
        end,
        STRINGS.UI.SERVERCREATIONSCREEN.INTENTION_LABEL, "", wide_label_width, wide_input_width, label_height, space_between, NEWFONT, font_size, narrow_field_nudge)

    self.server_name = TEMPLATES.LabelTextbox(STRINGS.UI.SERVERCREATIONSCREEN.SERVERNAME, TheNet:GetDefaultServerName(), wide_label_width, wide_input_width, label_height, space_between, NEWFONT, font_size, wide_field_nudge)
    self.server_name.textbox:SetTextLengthLimit( SERVER_NAME_MAX_LENGTH )
    self.server_name.textbox.OnTextInputted = function()
        self:UpdateSlot()
        self.servercreationscreen:MakeDirty()
    end

    self.server_desc = TEMPLATES.LabelTextbox(STRINGS.UI.SERVERCREATIONSCREEN.SERVERDESC, nil, wide_label_width, wide_input_width, label_height, space_between, NEWFONT, font_size, wide_field_nudge)
    self.server_desc.textbox:SetTextLengthLimit( STRING_MAX_LENGTH )
    self.server_desc.textbox.OnTextInputted = function()
        self:UpdateSlot()
        self.servercreationscreen:MakeDirty()
    end

    self.server_pw = TEMPLATES.LabelTextbox(STRINGS.UI.SERVERCREATIONSCREEN.SERVERPASSWORD, nil, wide_label_width, wide_input_width, label_height, space_between, NEWFONT, font_size, wide_field_nudge)
    self.server_pw.textbox:SetTextLengthLimit( STRING_MAX_LENGTH )
    if not Profile:GetShowPasswordEnabled() then
        self.server_pw.textbox:SetPassword(true)
    end
    self.server_pw.textbox.OnTextInputted = function() self.servercreationscreen:MakeDirty() end

    self.server_name.textbox:SetOnTabGoToTextEditWidget(function()
        if self.server_desc.textbox:IsVisible() then
            return self.server_desc.textbox
        elseif self.server_pw.textbox:IsVisible() then
            return self.server_pw.textbox
        else
            return nil
        end
    end)
    self.server_desc.textbox:SetOnTabGoToTextEditWidget(function()
        if self.server_pw.textbox:IsVisible() then
            return self.server_pw.textbox
        elseif self.server_name.textbox:IsVisible() then
            return self.server_name.textbox
        else
            return nil
        end
    end)
    self.server_pw.textbox:SetOnTabGoToTextEditWidget(function()
        if self.server_name.textbox:IsVisible() then
            return self.server_name.textbox
        elseif self.server_desc.textbox:IsVisible() then
            return self.server_desc.textbox
        else
            return nil
        end
    end)

    self.privacy_type = Widget("Privacy Group")
    self.privacy_type.buttons = self.privacy_type:AddChild(RadioButtons(privacy_options, privacy_width, 50, privacy_buttons, true))
    self.privacy_type.buttons:SetOnChangedFn(function(data)
        self:DisplayClanControls(data == PRIVACY_TYPE.CLAN)
        self:UpdateSlot()
        self.servercreationscreen:MakeDirty()
    end)
    self.privacy_type.focus_forward = self.privacy_type.buttons

    self.clan_id = TEMPLATES.LabelTextbox(STRINGS.UI.SERVERCREATIONSCREEN.CLANID, nil, narrow_label_width, narrow_input_width, label_height, space_between, NEWFONT, font_size, narrow_field_nudge)
    self.clan_id.textbox:SetTextLengthLimit( 12 )
    self.clan_id.textbox:SetCharacterFilter( "0123456789" )
    self.clan_id.textbox.OnTextInputted = function() self.servercreationscreen:MakeDirty() end

    local clan_only_options = {
        { text = STRINGS.UI.SERVERCREATIONSCREEN.NO, data = false },
        { text = STRINGS.UI.SERVERCREATIONSCREEN.YES, data = true }
    }
    self.clan_only = TEMPLATES.LabelSpinner(STRINGS.UI.SERVERCREATIONSCREEN.CLANONLY, clan_only_options, narrow_label_width, narrow_input_width, label_height, space_between, NEWFONT, font_size, narrow_field_nudge)
    self.clan_only.spinner:SetOnChangedFn(function() self.servercreationscreen:MakeDirty() end)

    local clan_admin_options = {
        { text = STRINGS.UI.SERVERCREATIONSCREEN.NO, data = false },
        { text = STRINGS.UI.SERVERCREATIONSCREEN.YES, data = true }
    }
    self.clan_admins = TEMPLATES.LabelSpinner(STRINGS.UI.SERVERCREATIONSCREEN.CLANADMIN, clan_admin_options, narrow_label_width, narrow_input_width, label_height, space_between, NEWFONT, font_size, narrow_field_nudge)
    self.clan_admins.spinner:SetOnChangedFn(function() self.servercreationscreen:MakeDirty() end)

    self.game_mode = TEMPLATES.LabelSpinner(STRINGS.UI.SERVERCREATIONSCREEN.GAMEMODE, GetGameModesSpinnerData(ModManager:GetEnabledServerModNames()), narrow_label_width, narrow_input_width, label_height, space_between, NEWFONT, font_size, narrow_field_nudge)
    self.game_mode.spinner:SetOnChangedFn(function(selected, old)
        self.servercreationscreen:OnChangeGameMode(selected)
    end)

    self.game_mode.info_button = self.game_mode:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "info.tex", "", false, false, function()
            local mode_title = GetGameModeString( self.game_mode.spinner:GetSelectedData() )
            if mode_title == "" then
                mode_title = STRINGS.UI.GAMEMODES.UNKNOWN
            end
            local mode_body = GetGameModeDescriptionString( self.game_mode.spinner:GetSelectedData() )
            if mode_body == "" then
                mode_body = STRINGS.UI.GAMEMODES.UNKNOWN_DESCRIPTION
            end
            local info_dialog = PopupDialogScreen(
                    mode_title,
                    mode_body,
                    {{ text = STRINGS.UI.SERVERLISTINGSCREEN.OK, cb = function() TheFrontEnd:PopScreen() end }},
                    nil,
                    "big"
            )
            local pos = info_dialog.dialog.body:GetPosition()
            info_dialog.dialog.body:SetPosition(pos.x, pos.y + 30)
			info_dialog.dialog.body:SetSize(24)
			TheFrontEnd:PushScreen(info_dialog)
        end))
    self.game_mode.info_button:SetPosition(0, -2)
    self.game_mode.info_button:SetScale(.4)
    self.game_mode.info_button:SetFocusChangeDir(MOVE_LEFT, self.game_mode.spinner)
    self.game_mode.spinner:SetFocusChangeDir(MOVE_RIGHT, self.game_mode.info_button)

    local numplayer_options = {}
    for i = 1, TUNING.MAX_SERVER_SIZE do
        table.insert(numplayer_options,{text=i, data=i})
    end
    self.max_players = TEMPLATES.LabelSpinner(STRINGS.UI.SERVERCREATIONSCREEN.MAXPLAYERS, numplayer_options, narrow_label_width, narrow_input_width, label_height, space_between, NEWFONT, font_size, narrow_field_nudge)
    self.max_players.spinner:SetSelected(TheNet:GetDefaultMaxPlayers())
    self.max_players.spinner:SetOnChangedFn(function(selected, old)
        if (selected > 1) ~= (old > 1) then
            self:RefreshPrivacyButtons()
            self:RefreshIntentionsButton()
        end
        self.servercreationscreen:MakeDirty()
    end)

    local pvp_options = {
        { text = STRINGS.UI.SERVERCREATIONSCREEN.OFF, data = false },
        { text = STRINGS.UI.SERVERCREATIONSCREEN.ON, data = true }
    }
    self.pvp = TEMPLATES.LabelSpinner(STRINGS.UI.SERVERCREATIONSCREEN.PVP, pvp_options, narrow_label_width, narrow_input_width, label_height, space_between, NEWFONT, font_size, narrow_field_nudge)
    self.pvp.spinner:SetOnChangedFn(function()
        self:UpdateSlot()
        self.servercreationscreen:MakeDirty()
    end)

    local savetype_options = {
        { text = STRINGS.UI.SERVERCREATIONSCREEN.SAVE_TYPE_LOCAL, data = false },
        { text = STRINGS.UI.SERVERCREATIONSCREEN.SAVE_TYPE_CLOUD, data = true  }
    }
    self.savetype_mode = TEMPLATES.LabelSpinner(STRINGS.UI.SERVERCREATIONSCREEN.SAVE_TYPE, savetype_options, narrow_label_width, narrow_input_width, label_height, space_between, NEWFONT, font_size, narrow_field_nudge)
    self.savetype_mode.spinner:SetOnChangedFn(function(data)
        self:UpdateSaveType(data)
        self:UpdateSlot()
        self.servercreationscreen:MakeDirty()
    end)
    self:SetCanEditSaveTypeWidgets(false)

    local online_options = {
        { text = STRINGS.UI.SERVERLISTINGSCREEN.ONLINE, data = true },
        { text = STRINGS.UI.SERVERLISTINGSCREEN.OFFLINE, data = false  }
    }
    self.online_mode = TEMPLATES.LabelSpinner(STRINGS.UI.SERVERCREATIONSCREEN.ONLINE_MODE, online_options, narrow_label_width, narrow_input_width, label_height, space_between, NEWFONT, font_size, narrow_field_nudge)
    self.online_mode.spinner:SetOnChangedFn(function(data)
        self:SetOnlineWidgets(data)
        self:UpdateSlot()
        self.servercreationscreen:MakeDirty()
    end)
    self.online_mode.spinner:Disable() -- This is not user configurable

    self.page_widgets =
    {
        self.server_name,
        self.server_desc,
        self.server_intention,
        self.privacy_type,
        self.game_mode,
        --self.clan_id,
        --self.clan_only,
        --self.clan_admins,
        self.pvp,
        self.max_players,
        self.server_pw,
        self.savetype_mode,
        self.online_mode,
    }
    self.clan_widgets =
    {
        self.clan_id,
        self.clan_only,
        self.clan_admins,
    }

    for i,v in ipairs(self.page_widgets) do
        v.line = v:AddChild(TEMPLATES.ListItemBackground(max_width, label_height + 7))
        v.line:MoveToBack()
    end

    for i,v in ipairs(self.clan_widgets) do
        v.line = v:AddChild(TEMPLATES.ListItemBackground(max_width - 50, label_height))
        v.line:MoveToBack()
        v:Hide()
    end

    local num_visible_rows = 10.5--math.floor(servercreationscreen:GetContentHeight() / label_height)
    self.scroll_list = self.server_settings_page:AddChild(ScrollableList(self.page_widgets, 340, label_height * num_visible_rows, label_height - 5, 10, nil, nil, nil, nil, nil, 10, nil, nil, "GOLD"))
    self.scroll_list:SetPosition(170, 20)
    self.scroll_list:Hide()
    self.scroll_list.scroll_bar_container:SetPosition(80, 0)

    self:DisplayClanControls(false) --this needs to be called to ensure that the self.clan_widgets belong to part of the hierarchy

    self.default_focus = self.scroll_list
    self.focus_forward = self.scroll_list

    --Internal data
    self.encode_user_path = true
    self.use_legacy_session_path = false
end)

function ServerSettingsTab:RefreshPrivacyButtons()
    if self.online_mode.spinner:GetSelectedData() == false or
        self.max_players.spinner:GetSelectedData() <= 1 then
        self._cached_privacy_setting = self.privacy_type.buttons:GetSelectedData()
        self.privacy_type.buttons:DisableAllButtons()
        self.privacy_type.buttons:EnableButton(PRIVACY_TYPE.LOCAL)
        self.privacy_type.buttons:SetSelected(PRIVACY_TYPE.LOCAL)
    else
        self.privacy_type.buttons:EnableAllButtons()
        if self._cached_privacy_setting ~= nil then
            self.privacy_type.buttons:SetSelected(self._cached_privacy_setting)
        end
    end
end

function ServerSettingsTab:RefreshIntentionsButton()
    if self.max_players.spinner:GetSelectedData() <= 1 then
        self.server_intention.button:SetText(STRINGS.UI.SERVERCREATIONSCREEN.NEWHOST_TYPE.ALONE)
        self.server_intention.button:Disable()
    else
        self.server_intention.button:SetText(self.server_intention.button.data ~= nil and STRINGS.UI.INTENTION[string.upper(self.server_intention.button.data)] or "")
        self.server_intention.button:Enable()
    end
end

function ServerSettingsTab:SetOnlineWidgets(online)
    if online ~= nil then
        self.online_mode.spinner:SetSelected(online)
    end
    self:RefreshPrivacyButtons()
end

function ServerSettingsTab:SetSaveTypeWidgets(is_cloud_save)
    if is_cloud_save ~= nil then
        self.savetype_mode.spinner:SetSelected(is_cloud_save)
    end
end

function ServerSettingsTab:SetCanEditSaveTypeWidgets(can_edit)
    if can_edit then
        self.savetype_mode.spinner:Enable()
    else
        self.savetype_mode.spinner:Disable()
    end
end

function ServerSettingsTab:UpdateSaveType(is_cloud_save)
    if (is_cloud_save and self.slot > CLOUD_SAVES_SAVE_OFFSET) or (not is_cloud_save and self.slot <= CLOUD_SAVES_SAVE_OFFSET) then
        return
    end
    self.servercreationscreen:UpdateSaveSlot(ShardSaveGameIndex:GetNextNewSlot(is_cloud_save and "cloud" or "local"))
end

function ServerSettingsTab:DisplayClanControls(show)
    -- These controls don't get cleaned up properly unless they have a parent, so we shuffle them between the scroll list and ourselves.
    if show then
        self:RemoveChild(self.clan_id)
        self:RemoveChild(self.clan_only)
        self:RemoveChild(self.clan_admins)
        self.scroll_list:AddItem(self.clan_id, self.game_mode)
        self.scroll_list:AddItem(self.clan_only, self.game_mode)
        self.scroll_list:AddItem(self.clan_admins, self.game_mode)
        self.clan_id:MoveToFront()
        self.clan_only:MoveToFront()
        self.clan_admins:MoveToFront()
        self.clan_id:Show()
        self.clan_only:Show()
        self.clan_admins:Show()
    else
        self.scroll_list:RemoveItem(self.clan_id)
        self.scroll_list:RemoveItem(self.clan_only)
        self.scroll_list:RemoveItem(self.clan_admins)
        self:AddChild(self.clan_id)
        self:AddChild(self.clan_only)
        self:AddChild(self.clan_admins)
        self.clan_id:MoveToBack()
        self.clan_only:MoveToBack()
        self.clan_admins:MoveToBack()
        self.clan_id:Hide()
        self.clan_only:Hide()
        self.clan_admins:Hide()
    end
end

function ServerSettingsTab:OnControl(control, down)
    if ServerSettingsTab._base.OnControl(self, control, down) then return true end


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
    end
end

function ServerSettingsTab:UpdateModeSpinner()
    local selected = self.game_mode.spinner:GetSelectedData()
    self.game_mode.spinner:SetOptions( GetGameModesSpinnerData( ModManager:GetEnabledServerModNames() ) )
    self.game_mode.spinner:SetSelected(selected)
end

function ServerSettingsTab:SetServerIntention(intention)
    self.server_intention.button.data = intention

    self:RefreshIntentionsButton()

    if intention ~= nil then
        self.intentions_overlay:SetSelected(intention)
    end

    self:ShowServerIntention(self.server_intention.button.data == nil)
    self:UpdateSlot()
end

function ServerSettingsTab:ShowServerIntention(show)
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

function ServerSettingsTab:ShowNewHostPicker(show)
    if show then
        if self.newhost_overlay == nil then
            self.newhost_overlay = self:AddChild(NewHostPicker())
            self.newhost_overlay:SetPosition(picker_x_offset, picker_y_offset)
            self.newhost_overlay:SetCallback(function(data)
                Profile:ShowedNewHostPicker()
                Profile:Save(function()
                    if data == "ALONE" then
                        self.max_players.spinner:SetSelected(1)
                        self:SetServerIntention(INTENTIONS.COOPERATIVE)
                        self:RefreshPrivacyButtons()
                    end
                    self:ShowServerIntention(self.server_intention.button.data == nil)
                    self.servercreationscreen:MakeDirty()
                end)
            end)
        end
    elseif self.newhost_overlay ~= nil then
        self.newhost_overlay:Kill()
        self.newhost_overlay = nil
    end
end

function ServerSettingsTab:ClearCacheFlag() --only to be called when the character/day has changed, like on a rollback, due to UpdateSlot being very slow reading the data
    self.serverslot:SetSaveSlot(-1)
    self.serverslot:SetSaveSlot(self.slot, self:GetServerData())
end

function ServerSettingsTab:UpdateSlot()
    self.serverslot:SetSaveSlot(self.slot, self:GetServerData())
end

function ServerSettingsTab:UpdateSaveSlot(slot)
    self.slot = slot
end

function ServerSettingsTab:SetDataForSlot(slot)
    self.slot = slot
    self._cached_privacy_setting = nil

    self.game_mode.spinner:SetOptions( GetGameModesSpinnerData( ModManager:GetEnabledServerModNames() ) )

    self:SetSaveTypeWidgets(slot > CLOUD_SAVES_SAVE_OFFSET)

    -- No save data
    if slot < 0 or ShardSaveGameIndex:IsSlotEmpty(slot) then
        local online = TheNet:IsOnlineMode() and not TheFrontEnd:GetIsOfflineMode()

        self.game_mode.spinner:SetSelected( DEFAULT_GAME_MODE )
        self.pvp.spinner:SetSelected(false)
        self.max_players.spinner:SetSelected(TUNING.MAX_SERVER_SIZE)
        self.server_name.textbox:SetString(subfmt(STRINGS.UI.SERVERCREATIONSCREEN.NEWGAME_FMT, { name = TheNet:GetLocalUserName() }))
        self.server_pw.textbox:SetString("")
        self.server_desc.textbox:SetString("")
        self.privacy_type.buttons:SetSelected(PRIVACY_TYPE.PUBLIC)
        self.encode_user_path = true
        self.use_legacy_session_path = false

        self:SetServerIntention(nil)
        self:SetOnlineWidgets(online)
        self:SetCanEditSaveTypeWidgets(true)

        self.game_mode.spinner:Enable()

    else -- Save data
        local server_data = ShardSaveGameIndex:GetSlotServerData(slot)
        if server_data ~= nil then
            self.game_mode.spinner:SetSelected(server_data.game_mode ~= nil and server_data.game_mode or DEFAULT_GAME_MODE )
            self.pvp.spinner:SetSelected(server_data.pvp)

            self.max_players.spinner:SetSelected(server_data.max_players)
            self.server_name.textbox:SetString(server_data.name)
            self.server_pw.textbox:SetString(server_data.password)
            self.server_desc.textbox:SetString(server_data.description)
            self.privacy_type.buttons:SetSelected(server_data.privacy_type)
            self.encode_user_path = server_data.encode_user_path == true
            self.use_legacy_session_path = server_data.use_legacy_session_path == true

            if self.privacy_type.buttons:GetSelectedData() == PRIVACY_TYPE.CLAN then
                local claninfo = server_data.clan
                self.clan_id.textbox:SetString(claninfo and claninfo.id or "")
                self.clan_only.spinner:SetSelected(claninfo and claninfo.only or false)
                self.clan_admins.spinner:SetSelected(claninfo and claninfo.admins or false)
            end

            self:SetServerIntention(server_data.intention)
            self:SetOnlineWidgets(server_data.online_mode) -- always load from the server data
            self:SetCanEditSaveTypeWidgets(false)
        else
            self.encode_user_path = true
            self.use_legacy_session_path = false
            self:SetServerIntention(nil)
        end

		-- No editing online or game mode for servers that have already been created
        self.game_mode.spinner:Disable()
    end

    self:UpdateSlot()
end

function ServerSettingsTab:GetServerIntention()
	return self.server_intention.button.data
end

function ServerSettingsTab:GetServerName()
	return self.server_name.textbox:GetString()
end

function ServerSettingsTab:GetServerDescription()
	return self.server_desc.textbox:GetString()
end

function ServerSettingsTab:GetPassword()
	return self.server_pw.textbox:GetLineEditString()
end

function ServerSettingsTab:GetGameMode()
	return self.game_mode.spinner:GetSelectedData()
end

function ServerSettingsTab:GetMaxPlayers()
	return self.max_players.spinner:GetSelectedData()
end

function ServerSettingsTab:GetPVP()
	return self.pvp.spinner:GetSelectedData()
end

function ServerSettingsTab:GetPrivacyType()
    return self.privacy_type.buttons:GetSelectedData()
end

function ServerSettingsTab:GetClanInfo()
    return {
        id = self.clan_id.textbox:GetString(),
        only = self.clan_only.spinner:GetSelectedData(),
        admin = self.clan_admins.spinner:GetSelectedData(),
    }
end

function ServerSettingsTab:GetOnlineMode()
	return self.online_mode.spinner:GetSelectedData()
end

function ServerSettingsTab:GetEncodeUserPath()
    return self.encode_user_path
end

function ServerSettingsTab:GetUseClusterPath()
    return not self.use_legacy_session_path
end

function ServerSettingsTab:GetUseLegacySessionPath()
    return self.use_legacy_session_path
end

function ServerSettingsTab:GetServerData()
    return {
        intention = self.server_intention.button.data,
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

function ServerSettingsTab:VerifyValidClanSettings()
    return self.privacy_type.buttons:GetSelectedData() ~= PRIVACY_TYPE.CLAN or TheNet:IsClanIDValid(self.clan_id.textbox:GetString())
end

function ServerSettingsTab:VerifyValidServerName()
    return self.server_name.textbox:GetString() ~= ""
end

function ServerSettingsTab:VerifyValidServerIntention()
    return self.server_intention.button.data ~= nil
end

function ServerSettingsTab:VerifyValidNewHostType()
    return Profile:SawNewHostPicker()
end

function ServerSettingsTab:VerifyValidPassword()
    local pw = self.server_pw.textbox:GetLineEditString()
    return pw == "" or pw:match("^%s*(.-%S)%s*$") == pw
end

function ServerSettingsTab:SetEditingTextboxes(edit)
    self.server_name.textbox:SetEditing(edit)
    self.server_pw.textbox:SetEditing(edit)
    self.server_desc.textbox:SetEditing(edit)
    self.clan_id.textbox:SetEditing(edit)
end

return ServerSettingsTab
