local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Spinner = require "widgets/spinner"
local NumericSpinner = require "widgets/numericspinner"
local TextEdit = require "widgets/textedit"
local ScrollableList = require "widgets/scrollablelist"
local RadioButtons = require "widgets/radiobuttons"
local NewHostPicker = require "widgets/newhostpicker"
local IntentionPicker = require "widgets/intentionpicker"
local PopupDialogScreen = require "screens/popupdialog"
local TEMPLATES = require "widgets/templates"

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
    font_size = 25 * 0.75;
end
local textbox_font_ratio = .8

local STRING_MAX_LENGTH = 254 -- http://tools.ietf.org/html/rfc5321#section-4.5.3.1
local SERVER_NAME_MAX_LENGTH = 80

local privacy_options = {
    {text=STRINGS.UI.SERVERCREATIONSCREEN.PRIVACY.PUBLIC,    data=PRIVACY_TYPE.PUBLIC},
    {text=STRINGS.UI.SERVERCREATIONSCREEN.PRIVACY.FRIENDS,   data=PRIVACY_TYPE.FRIENDS},
    {text=STRINGS.UI.SERVERCREATIONSCREEN.PRIVACY.LOCAL,     data=PRIVACY_TYPE.LOCAL},
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
    atlas = "images/ui.xml",
    on_image = "radiobutton_on.tex",
    off_image = "radiobutton_off.tex",
}

local ServerSettingsTab = Class(Widget, function(self, slotdata, servercreationscreen)
    Widget._ctor(self, "ServerSettingsTab")

    self.slotdata = slotdata or {}

    self.servercreationscreen = servercreationscreen

    self.server_settings_page = self:AddChild(Widget("server_settings_page"))

    self.left_line = self.server_settings_page:AddChild(Image("images/ui.xml", "line_vertical_5.tex"))
    self.left_line:SetScale(1, .6)
    self.left_line:SetPosition(-530, 5, 0)

    self.intentions_overlay = self:AddChild(IntentionPicker( STRINGS.UI.SERVERCREATIONSCREEN.INTENTION_TITLE, STRINGS.UI.SERVERCREATIONSCREEN.INTENTION_DESC))
    self.intentions_overlay:SetCallback(function(intention)
        self:SetServerIntention(intention)
        self.servercreationscreen:MakeDirty()
    end)
    self.intentions_overlay:SetPosition(-115, 180)

    self.server_intention = TEMPLATES.LabelButton(STRINGS.UI.SERVERCREATIONSCREEN.INTENTION_LABEL, "", narrow_label_width, narrow_input_width, label_height, space_between, NEWFONT, font_size, narrow_field_nudge)
    self.server_intention.button._onclickfn = function(data)
        self:SetServerIntention(nil)
        self.servercreationscreen:MakeDirty()
    end
    self.server_intention.button:SetOnClick(self.server_intention.button._onclickfn)

    self.server_name = TEMPLATES.LabelTextbox(STRINGS.UI.SERVERCREATIONSCREEN.SERVERNAME, TheNet:GetDefaultServerName(), wide_label_width, wide_input_width, label_height, space_between, NEWFONT, font_size, wide_field_nudge)
    self.server_name.textbox:SetTextLengthLimit( SERVER_NAME_MAX_LENGTH )
    self.server_name.textbox.OnTextInputted = function()
        self.servercreationscreen:UpdateTitle(self.servercreationscreen.saveslot, true)
        self.servercreationscreen:MakeDirty()
    end

    self.server_desc = TEMPLATES.LabelTextbox(STRINGS.UI.SERVERCREATIONSCREEN.SERVERDESC, nil, wide_label_width, wide_input_width, label_height, space_between, NEWFONT, font_size, wide_field_nudge)
    self.server_desc.textbox:SetTextLengthLimit( STRING_MAX_LENGTH )
    self.server_desc.textbox.OnTextInputted = function() self.servercreationscreen:MakeDirty() end

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
    self.privacy_type.buttons = self.privacy_type:AddChild(RadioButtons(privacy_options, #privacy_options * 145, 50, privacy_buttons, true))
    self.privacy_type.buttons:SetOnChangedFn(function(data)
        self:DisplayClanControls(data == PRIVACY_TYPE.CLAN)
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
		self.servercreationscreen.world_tab:OnChangeGameMode(selected)
		self.servercreationscreen:MakeDirty()
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
            TheFrontEnd:PushScreen(PopupDialogScreen(
                    mode_title,
                    mode_body,
                    {{ text = STRINGS.UI.SERVERLISTINGSCREEN.OK, cb = function() TheFrontEnd:PopScreen() end }}))
        end))
    self.game_mode.info_button:SetPosition(160, -2)
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
    self.pvp.spinner:SetOnChangedFn(function() self.servercreationscreen:MakeDirty() end)

    local online_options = {
        { text = STRINGS.UI.SERVERLISTINGSCREEN.ONLINE, data = true },
        { text = STRINGS.UI.SERVERLISTINGSCREEN.OFFLINE, data = false  }
    }
    self.online_mode = TEMPLATES.LabelSpinner(STRINGS.UI.SERVERCREATIONSCREEN.ONLINE_MODE, online_options, narrow_label_width, narrow_input_width, label_height, space_between, NEWFONT, font_size, narrow_field_nudge)
    self.online_mode.spinner:SetOnChangedFn(function(data)
        self:SetOnlineWidgets(data)
        self.servercreationscreen:MakeDirty()
    end)
    self.online_mode.spinner:Disable() -- This is not user configurable

    self.page_widgets =
    {
        self.server_intention,
        self.server_name,
        self.server_desc,
        self.privacy_type,
        self.game_mode,
        --self.clan_id,
        --self.clan_only,
        --self.clan_admins,
        self.pvp,
        self.max_players,
        self.server_pw,
        self.online_mode,
    }
    self.clan_widgets =
    {
        self.clan_id,
        self.clan_only,
        self.clan_admins,
    }

    for i,v in ipairs(self.page_widgets) do
        v.line = v:AddChild(Image("images/ui.xml", "single_option_bg.tex"))
        v.line:SetScale(1.2, .85)
        v.line:MoveToBack()
    end

    for i,v in ipairs(self.clan_widgets) do
        v.line = v:AddChild(Image("images/ui.xml", "single_option_bg.tex"))
        v.line:SetScale(1.0, .85)
        v.line:MoveToBack()
        v:Hide()
    end

    self.scroll_list = self.server_settings_page:AddChild(ScrollableList(self.page_widgets, 340, 360, 35, 10))
    self.scroll_list:SetPosition(20,0)

    self.scroll_list:Hide()

    self.default_focus = self.scroll_list
    self.focus_forward = self.scroll_list

    --Internal data
    self.encode_user_path = true
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
        self.server_intention.button:SetOnClick(nil)
        self.server_intention.button.scale_on_focus = false
        self.server_intention.button.move_on_click = false
        self.server_intention.button:SetTextures("images/ui.xml", "single_option_bg_large_grey.tex", "single_option_bg_large_gold.tex", "single_option_bg_large_grey.tex", "single_option_bg_large_gold.tex", "single_option_bg_large_grey.tex", { 1, 1 }, { 0, 0 })
        self.server_intention.button:ForceImageSize(narrow_input_width, label_height * .9)
        self.server_intention.button:SetTextColour(unpack(GREY))
        self.server_intention.button:SetTextFocusColour(unpack(GREY))
    else
        self.server_intention.button:SetText(self.server_intention.button.data ~= nil and STRINGS.UI.INTENTION[string.upper(self.server_intention.button.data)] or "")
        self.server_intention.button:SetOnClick(self.server_intention.button._onclickfn)
        self.server_intention.button.scale_on_focus = true
        self.server_intention.button.move_on_click = true
        self.server_intention.button:SetTextures("images/ui.xml", "in-window_button_sm_idle.tex", "in-window_button_sm_hl.tex", "in-window_button_sm_disabled.tex", "in-window_button_sm_hl_noshadow.tex", "in-window_button_sm_disabled.tex", { 1, 1 }, { 0, 0 })
        self.server_intention.button:ForceImageSize(narrow_input_width, label_height)
        self.server_intention.button:SetTextColour(0, 0, 0, 1)
        self.server_intention.button:SetTextFocusColour(0, 0, 0, 1)
    end
end

function ServerSettingsTab:SetOnlineWidgets(online)
    if online ~= nil then
        self.online_mode.spinner:SetSelected(online)
    end
    self:RefreshPrivacyButtons()
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
    else
        self.scroll_list:RemoveItem(self.clan_id)
        self.scroll_list:RemoveItem(self.clan_only)
        self.scroll_list:RemoveItem(self.clan_admins)
        self:AddChild(self.clan_id)
        self:AddChild(self.clan_only)
        self:AddChild(self.clan_admins)
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

function ServerSettingsTab:UpdateModeSpinner(slotnum)
    local selected = self.game_mode.spinner:GetSelectedData()
    self.game_mode.spinner:SetOptions( GetGameModesSpinnerData( ModManager:GetEnabledServerModNames() ) )
    self.game_mode.spinner:SetSelected(selected)
end

function ServerSettingsTab:SavePrevSlot(prevslot)
	if prevslot and prevslot > 0 then
		-- remember what was typed/set
		self.slotdata[prevslot] = self:GetServerData()
	end
end

function ServerSettingsTab:SetServerIntention(intention)
    self.server_intention.button.data = intention

    self:RefreshIntentionsButton()

    if intention ~= nil then
        self.intentions_overlay:SetSelected(intention)
    end

    self:ShowServerIntention(self.server_intention.button.data == nil)
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
                    self.servercreationscreen:MakeDirty()
                end)
            end)
        end
    elseif self.newhost_overlay ~= nil then
        self.newhost_overlay:Kill()
        self.newhost_overlay = nil
    end
end

function ServerSettingsTab:UpdateDetails(slotnum, prevslot, fromDelete)
    self._cached_privacy_setting = nil

    self.game_mode.spinner:SetOptions( GetGameModesSpinnerData( ModManager:GetEnabledServerModNames() ) )

    -- No save data
    if slotnum < 0 or SaveGameIndex:IsSlotEmpty(slotnum) then
        -- no slot, so hide all the details and set all the text boxes back to their defaults
        if prevslot and prevslot > 0 then
            -- Duplicate prevslot's data into our new slot if it was also a blank slot
            if not fromDelete and SaveGameIndex:IsSlotEmpty(prevslot) then
                self.slotdata[slotnum] = deepcopy(self.slotdata[prevslot])
            end
        end

        -- Wipe the current slot if we're updating due to a delete
        if fromDelete then
            self.slotdata[slotnum] = {}
        end

        local pvp = false
        if self.slotdata[slotnum] ~= nil and self.slotdata[slotnum].pvp ~= nil then
            pvp = self.slotdata[slotnum].pvp
        end
        local online = TheNet:IsOnlineMode() and not TheFrontEnd:GetIsOfflineMode()

        self.game_mode.spinner:SetSelected(self.slotdata[slotnum] and self.slotdata[slotnum].game_mode or DEFAULT_GAME_MODE )
        self.pvp.spinner:SetSelected(pvp)
        self.max_players.spinner:SetSelected(self.slotdata[slotnum] and self.slotdata[slotnum].max_players or TUNING.MAX_SERVER_SIZE)
        self.server_name.textbox:SetString(self.slotdata[slotnum] and self.slotdata[slotnum].server_name or subfmt(STRINGS.UI.SERVERCREATIONSCREEN.NEWGAME_FMT, { name = TheNet:GetLocalUserName() }))
        self.server_pw.textbox:SetString(self.slotdata[slotnum] and self.slotdata[slotnum].server_pw or "")
        self.server_desc.textbox:SetString(self.slotdata[slotnum] and self.slotdata[slotnum].server_desc or "")
        self.privacy_type.buttons:SetSelected(self.slotdata[slotnum] and self.slotdata[slotnum].privacy_type or PRIVACY_TYPE.PUBLIC)
        self.encode_user_path = true

        self:SetServerIntention(self.slotdata[slotnum] and self.slotdata[slotnum].intention or nil)
        self:SetOnlineWidgets(online)

        self.game_mode.spinner:Enable()

    else -- Save data
        local server_data = SaveGameIndex:GetSlotServerData(slotnum)
        if server_data ~= nil then
            local pvp = false
            if self.slotdata[slotnum] ~= nil and self.slotdata[slotnum].pvp ~= nil then
                pvp = self.slotdata[slotnum].pvp
            else
                pvp = server_data.pvp
            end

            self.game_mode.spinner:SetSelected(self.slotdata[slotnum] and self.slotdata[slotnum].game_mode or (server_data.game_mode ~= nil and server_data.game_mode or DEFAULT_GAME_MODE ))
            self.pvp.spinner:SetSelected(pvp)

            self.max_players.spinner:SetSelected(self.slotdata[slotnum] and self.slotdata[slotnum].max_players or server_data.max_players)
            self.server_name.textbox:SetString(self.slotdata[slotnum] and self.slotdata[slotnum].name or server_data.name)
            self.server_pw.textbox:SetString(self.slotdata[slotnum] and self.slotdata[slotnum].password or server_data.password)
            self.server_desc.textbox:SetString(self.slotdata[slotnum] and self.slotdata[slotnum].description or server_data.description)
            self.privacy_type.buttons:SetSelected(self.slotdata[slotnum] and self.slotdata[slotnum].privacy_type or server_data.privacy_type)
            self.encode_user_path = (self.slotdata[slotnum] or server_data).encode_user_path == true

            if self.privacy_type.buttons:GetSelectedData() == PRIVACY_TYPE.CLAN then
                local claninfo = self.slotdata[slotnum] and self.slotdata[slotnum].clan or server_data.clan
                self.clan_id.textbox:SetString(claninfo and claninfo.id or "")
                self.clan_only.spinner:SetSelected(claninfo and claninfo.only or false)
                self.clan_admins.spinner:SetSelected(claninfo and claninfo.admins or false)
            end

            self:SetServerIntention(self.slotdata[slotnum] and self.slotdata[slotnum].intention or server_data.intention)
            self:SetOnlineWidgets(server_data.online_mode) -- always load from the server data
        else
            self.encode_user_path = true
            self:SetServerIntention(nil)
        end

		-- No editing online or game mode for servers that have already been created
        self.game_mode.spinner:Disable()
    end
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
    return self.use_cluster_path
end

function ServerSettingsTab:GetServerData()
    return {
        intention = self.server_intention.button.data,
        pvp = self:GetPVP(),
        game_mode = self:GetGameMode(),
        online_mode = self:GetOnlineMode(),
        encode_user_path = self:GetEncodeUserPath(),
        use_cluster_path = self:GetUseClusterPath(),
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

function ServerSettingsTab:SetEditingTextboxes(edit)
	self.server_name.textbox:SetEditing(edit)
	self.server_pw.textbox:SetEditing(edit)
	self.server_desc.textbox:SetEditing(edit)
    self.clan_id.textbox:SetEditing(edit)
end

return ServerSettingsTab
