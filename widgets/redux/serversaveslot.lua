local ServerCreationScreen = require "screens/redux/servercreationscreen"
local PopupDialogScreen = require "screens/redux/popupdialog"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local TEMPLATES = require "widgets/redux/templates"
local ManageServerSlotScreen = require "screens/redux/manageserverslotscreen"

local intention_images = {
    [INTENTIONS.SOCIAL] = "playstyle_social.tex",
    [INTENTIONS.COOPERATIVE] = "playstyle_coop.tex",
    [INTENTIONS.COMPETITIVE] = "playstyle_competitive.tex",
    [INTENTIONS.MADNESS] = "playstyle_madness.tex",
}

local intention_options = {
    [INTENTIONS.SOCIAL] = STRINGS.UI.INTENTION.SOCIAL,
    [INTENTIONS.COOPERATIVE] = STRINGS.UI.INTENTION.COOPERATIVE,
    [INTENTIONS.COMPETITIVE] = STRINGS.UI.INTENTION.COMPETITIVE,
    [INTENTIONS.MADNESS] = STRINGS.UI.INTENTION.MADNESS,
}

local privacy_images = {
    [PRIVACY_TYPE.PUBLIC] = "public.tex",
    [PRIVACY_TYPE.FRIENDS] = "friend.tex",
    [PRIVACY_TYPE.CLAN] = "clan.tex",
    [PRIVACY_TYPE.LOCAL] = "local.tex",
}

local privacy_options = {
    [PRIVACY_TYPE.PUBLIC] = STRINGS.UI.SERVERCREATIONSCREEN.PRIVACY.PUBLIC,
    [PRIVACY_TYPE.FRIENDS] = STRINGS.UI.SERVERCREATIONSCREEN.PRIVACY.FRIENDS,
    [PRIVACY_TYPE.CLAN] = STRINGS.UI.SERVERCREATIONSCREEN.PRIVACY.CLAN,
    [PRIVACY_TYPE.LOCAL] = STRINGS.UI.SERVERCREATIONSCREEN.PRIVACY.LOCAL,
}

local default_portrait_atlas = "images/saveslot_portraits.xml"
local default_avatar = "unknown.tex"
local servericons_atlas = "images/servericons.xml"

local ServerSaveSlot = Class(Widget, function(self, serverslotscreen, isservercreationscreen)
    Widget._ctor(self, "ServerSaveSlot")

    self.serverslotscreen = serverslotscreen
    self.isservercreationscreen = isservercreationscreen

    self.onclick = function()
        if not self.slot or not ShardSaveGameIndex:IsSlotEmpty(self.slot) then
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
            self.last_focus_widget = TheFrontEnd:GetFocusWidget()
            self:HideHoverText()
            TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()
                TheFrontEnd:PushScreen(ServerCreationScreen(self.serverslotscreen, self.slot))
                self:HideHoverText()
                TheFrontEnd:Fade(FADE_IN, SCREEN_FADE_TIME, function() self:HideHoverText() end)
            end)
        end
	end

    self.root = self:AddChild(Widget("root"))

    local frame_scale = 0.835
    local offset = -20
    if isservercreationscreen or TheInput:ControllerAttached() or IsConsole() then
        frame_scale = 0.8
        offset = 0
    end

	self.frame = self.root:AddChild(Image("images/frontend_redux.xml", "achievement_backing.tex"))
	self.frame:SetScale(frame_scale, 0.9)
	self.frame_focused = self.root:AddChild(Image("images/frontend_redux.xml", "achievement_backing_hover.tex"))
	self.frame_focused:SetScale(frame_scale, 0.9)
	self.frame_focused:Hide()

    self.server_name = self.root:AddChild(Text(HEADERFONT, 22, "", UICOLOURS.HIGHLIGHT_GOLD))

    self.server_desc = self.root:AddChild(Text(CHATFONT, 20, "", UICOLOURS.GREY))

    self.character_portrait = self.root:AddChild(Widget("character_portrait"))
    self.character_portrait.SetCharacter = function(self, character_atlas, character)
        if character_atlas and character then
            self.title_portrait:SetTexture(character_atlas, character..".tex")
        else
            self.title_portrait:SetTexture(default_portrait_atlas, default_avatar)
        end
    end
	self.character_portrait.title_portrait_bg = self.character_portrait:AddChild(Image(default_portrait_atlas, "background.tex"))
	self.character_portrait.title_portrait_bg:SetScale(.6, .6, 1)
	self.character_portrait.title_portrait_bg:SetPosition(-360 + offset, 0)
	self.character_portrait.title_portrait_bg:SetClickable(false)
	self.character_portrait.title_portrait = self.character_portrait.title_portrait_bg:AddChild(Image())
    self.character_portrait.title_portrait:SetClickable(false)

    self.day_and_season = self.root:AddChild(Text(CHATFONT, 19, "", UICOLOURS.GREY))
	self.day_and_season:SetPosition(155 + offset, 15)
    self.day_and_season:SetRegionSize(250, 40)

    self.preset = self.root:AddChild(Text(CHATFONT, 19, "", UICOLOURS.GREY))
    self.preset:SetPosition(155 + offset, -15)
    self.preset:SetRegionSize(250, 40)

    local setting_icon_s = .10
    local setting_image_s = .8

    self.privacy = self.root:AddChild(TEMPLATES.ServerDetailIcon(servericons_atlas, privacy_images[PRIVACY_TYPE.PUBLIC], "brown", privacy_options[PRIVACY_TYPE.PUBLIC]))
    self.privacy:SetScale(setting_icon_s)
    self.privacy.bg:SetScale(1)
    self.privacy.img:SetScale(setting_image_s)

    self.intention = self.root:AddChild(TEMPLATES.ServerDetailIcon(servericons_atlas, intention_images[INTENTIONS.SOCIAL], "brown", intention_options[INTENTIONS.SOCIAL]))
    self.intention:SetScale(setting_icon_s)
    self.intention.bg:SetScale(1)
    self.intention.img:SetScale(setting_image_s)

    self.pvp = self.root:AddChild(TEMPLATES.ServerDetailIcon(servericons_atlas, "pvp.tex", "brown", STRINGS.UI.SERVERLISTINGSCREEN.PVP_ICON_HOVER))
    self.pvp:SetScale(setting_icon_s)
    self.pvp.bg:SetScale(1)
    self.pvp.img:SetScale(setting_image_s)
    self.pvp:Hide()

    self.mods = self.root:AddChild(TEMPLATES.ServerDetailIcon(servericons_atlas, "mods.tex", "brown", STRINGS.UI.SERVERLISTINGSCREEN.MODS_ICON_HOVER))
    self.mods:SetScale(setting_icon_s)
    self.mods.bg:SetScale(1)
    self.mods.img:SetScale(setting_image_s)
    self.mods:Hide()

    self.cloud = self.root:AddChild(TEMPLATES.ServerDetailIcon(servericons_atlas, "cloud.tex", "brown", STRINGS.UI.SERVERLISTINGSCREEN.CLOUD_SAVE_HOVER))
    self.cloud:SetScale(setting_icon_s)
    self.cloud.bg:SetScale(1)
    self.cloud.img:SetScale(setting_image_s)
    self.cloud:Hide()

    self.offline = self.root:AddChild(Text(NEWFONT, 25, STRINGS.UI.SERVERCREATIONSCREEN.OFFLINE_WORLD))
    self.offline:SetColour(unpack(PLAYERCOLOURS.RED))
    self.offline:SetPosition(340 + offset, -20)
    self.offline:SetRegionSize(100, 40)
    self.offline:SetHAlign(ANCHOR_RIGHT)
    self.offline:Hide()

    self.manageslot = self.root:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "mods.tex", STRINGS.UI.SERVERCREATIONSCREEN.MANAGE_SLOT, false, false, function() self:OnManageButton() end))
    self.manageslot:SetScale(0.6)
    self.manageslot:SetPosition(395, 0)

    if isservercreationscreen or TheInput:ControllerAttached() or IsConsole() then
        self.manageslot:Hide()
    end

    self:SetSaveSlot(-1)
end)

function ServerSaveSlot:HideHoverText()
    self.privacy:OnLoseFocus()
    self.intention:OnLoseFocus()
    self.pvp:OnLoseFocus()
    self.mods:OnLoseFocus()
    self.cloud:OnLoseFocus()
    self.manageslot:OnLoseFocus()
end

function ServerSaveSlot:OnGainFocus()
    if self.isservercreationscreen then return end
    if not self:IsEnabled() then return end
    ServerSaveSlot._base.OnGainFocus(self)
    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
    self.frame_focused:Show()
end

function ServerSaveSlot:OnLoseFocus()
    if self.isservercreationscreen then return end
    if not self:IsEnabled() then return end
    ServerSaveSlot._base.OnLoseFocus(self)
    self.frame_focused:Hide()
end

function ServerSaveSlot:SetSaveSlot(slot, server_data)
    local justupdate = slot == self.slot
    self.slot = slot
    if not slot or ShardSaveGameIndex:IsSlotEmpty(slot) and not server_data then
        self.root:Hide()
        return
    else
        self.root:Show()
    end

    server_data = server_data or ShardSaveGameIndex:GetSlotServerData(self.slot)

    self.server_name:SetTruncatedString(server_data.name or "", 360, nil, true)
    local w, h = self.server_name:GetRegionSize()
    self.server_name:SetPosition(w/2 - 295, 15)

    self.server_desc:SetTruncatedString(server_data.description or "", 360, nil, true)
	w, h = self.server_desc:GetRegionSize()
	self.server_desc:SetPosition(w/2 - 295, -15)

    if not justupdate then
        local character_atlas, character = self.serverslotscreen:GetCharacterPortrait(self.slot)
        self.character_portrait:SetCharacter(character_atlas, character)

        self.day_and_season:SetString(self.serverslotscreen:GetDayAndSeasonText(self.slot))

        self.preset:SetString(self.serverslotscreen:GetPresetText(self.slot))
    end

    if not server_data.online_mode then
        self.offline:Show()
    else
        self.offline:Hide()
    end

    local setting_icon_x = 360
    if self.isservercreationscreen or TheInput:ControllerAttached() or IsConsole() then
        setting_icon_x = 375
    end
    local setting_icon_y = 18

    if self.slot > CLOUD_SAVES_SAVE_OFFSET then
        self.cloud:Show()
        self.cloud:SetPosition(setting_icon_x, setting_icon_y)
        setting_icon_x = setting_icon_x - 28
    else
        self.cloud:Hide()
    end

    --doing this in reverse order so that we can have them left aligned
    if not IsTableEmpty(ShardSaveGameIndex:GetSlotEnabledServerMods(self.slot)) then
        self.mods:Show()
        self.mods:SetPosition(setting_icon_x, setting_icon_y)
        setting_icon_x = setting_icon_x - 28
    else
        self.mods:Hide()
    end

    if server_data.pvp then
        self.pvp:Show()
        self.pvp:SetPosition(setting_icon_x, setting_icon_y)
        setting_icon_x = setting_icon_x - 28
    else
        self.pvp:Hide()
    end

    self.intention.img:SetTexture(servericons_atlas, intention_images[server_data.intention or INTENTIONS.SOCIAL])
    self.intention:SetHoverText(intention_options[server_data.intention or INTENTIONS.SOCIAL])
    self.intention:SetPosition(setting_icon_x, setting_icon_y)
    setting_icon_x = setting_icon_x - 28

    self.privacy.img:SetTexture(servericons_atlas, privacy_images[server_data.privacy_type or PRIVACY_TYPE.PUBLIC])
    self.privacy:SetHoverText(privacy_options[server_data.privacy_type or PRIVACY_TYPE.PUBLIC])
    self.privacy:SetPosition(setting_icon_x, setting_icon_y)
end

function ServerSaveSlot:OnManageButton()
    assert(IsNotConsole())

    TheFrontEnd:PushScreen(ManageServerSlotScreen(self.slot, function(slot) self:OnDeleteButton(slot) end, function(force) self.serverslotscreen:UpdateSaveFiles(force) end))
end

function ServerSaveSlot:OnDeleteButton(slot)
    slot = slot or self.slot

    local dialog_items = {
        { text=STRINGS.UI.SERVERCREATIONSCREEN.DELETE, cb = function()
            ShardSaveGameIndex:DeleteSlot(slot, function()
                self.serverslotscreen:ClearSlotCache(slot)
                self.serverslotscreen:UpdateSaveFiles()
                TheFrontEnd:PopScreen()
                --Pop the screen a second time for the manage slot screen.
                TheFrontEnd:PopScreen()
            end)
        end },
        { text=STRINGS.UI.SERVERCREATIONSCREEN.CANCEL, cb = function() TheFrontEnd:PopScreen() end },
    }
    TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.SERVERCREATIONSCREEN.DELETE_SLOT, STRINGS.UI.SERVERCREATIONSCREEN.SURE, dialog_items ) )
end

function ServerSaveSlot:OnControl(control, down)
    if self.isservercreationscreen then return true end
	if ServerSaveSlot._base.OnControl(self, control, down) then return true end

	if not down then
		if control == CONTROL_ACCEPT then
			self:onclick()
            return true
		elseif control == CONTROL_MAP then
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
            if IsConsole() then
                self:OnDeleteButton()
            else
                self:OnManageButton()
            end
            return true
		end
	end
end

function ServerSaveSlot:GetHelpText()
	local t = {}
	local controller_id = TheInput:GetControllerID()

	table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.HELP.SELECT)
    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MAP) .. " " .. (IsConsole() and STRINGS.UI.SERVERCREATIONSCREEN.DELETE_SLOT or STRINGS.UI.SERVERCREATIONSCREEN.MANAGE_SLOT))

	return table.concat(t, "  ")
end

return ServerSaveSlot