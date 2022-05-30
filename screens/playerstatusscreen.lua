require "util"
local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local PlayerBadge = require "widgets/playerbadge"
local ScrollableList = require "widgets/scrollablelist"
local UserCommandPickerScreen = require "screens/redux/usercommandpickerscreen"

local UserCommands = require "usercommands"

local TEMPLATES = require("widgets/redux/templates")

local BAN_ENABLED = true

local list_spacing = 82.5

local PERF_HOST_SCALE = { 1, 1, 1 }
local PERF_HOST_UNKNOWN = "host_indicator.tex"
local PERF_HOST_LEVELS =
{
    "host_indicator3.tex", --GOOD
    "host_indicator2.tex", --OK
    "host_indicator1.tex", --BAD
}

local PERF_CLIENT_SCALE = { .9, .9, .9 }
local PERF_CLIENT_UNKNOWN = "performance_indicator.tex"
local PERF_CLIENT_LEVELS =
{
    "performance_indicator3.tex", --GOOD
    "performance_indicator2.tex", --OK
    "performance_indicator1.tex", --BAD
}

local VOICE_MUTE_COLOUR = { 242 / 255, 99 / 255, 99 / 255, 255 / 255 }
local VOICE_ACTIVE_COLOUR = { 99 / 255, 242 / 255, 99 / 255, 255 / 255 }
local VOICE_IDLE_COLOUR = { 1, 1, 1, 1 }

local REFRESH_INTERVAL = .5

local PlayerStatusScreen = Class(Screen, function(self, owner)
    Screen._ctor(self, "PlayerStatusScreen")
    self.owner = owner
    self.time_to_refresh = REFRESH_INTERVAL
    self.usercommandpickerscreen = nil
    self.show_player_badge = not TheFrontEnd:GetIsOfflineMode() and TheNet:IsOnlineMode()
end)

function PlayerStatusScreen:OnBecomeActive()
    PlayerStatusScreen._base.OnBecomeActive(self)
    self:DoInit()
    self.time_to_refresh = REFRESH_INTERVAL
    self.scroll_list:SetFocus()

    SetAutopaused(true)
end

function PlayerStatusScreen:OnBecomeInactive()
    if self.scroll_list ~= nil then
        for i, v in ipairs(self.player_widgets) do
            v.mute.image.inst:DisableMute()
        end
    end

    SetAutopaused(false)

    PlayerStatusScreen._base.OnBecomeInactive(self)
end

function PlayerStatusScreen:OnDestroy()
    --Overridden so we do part of Widget:Kill() but keeps the screen around hidden
    self:ClearFocus()
    self:StopFollowMouse()
    self:Hide()

    if self.onclosefn ~= nil then
        self.onclosefn()
    end
end

function PlayerStatusScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.CLOSE)

    if self.server_group ~= "" then
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2) .. " " .. STRINGS.UI.HELP.VIEWGROUP)
    end

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_1) .. " " .. STRINGS.UI.SERVERLISTINGSCREEN.TOGGLE_SERVER_NAME)

    return table.concat(t, "  ")
end

function PlayerStatusScreen:OnControl(control, down)
    if not self:IsVisible() then
        return false
    elseif PlayerStatusScreen._base.OnControl(self, control, down) then
        return true
    elseif control == CONTROL_OPEN_DEBUG_MENU then
        --jcheng: don't allow debug menu stuff going on right now
        return true
    elseif not down then
        if control == CONTROL_SHOW_PLAYER_STATUS
			or (control == CONTROL_TOGGLE_PLAYER_STATUS and not TheInput:IsControlPressed(CONTROL_SHOW_PLAYER_STATUS))
			or (self.click_to_close and (control == CONTROL_PAUSE or control == CONTROL_CANCEL))
             then
            self:Close()
            return true
        elseif control == CONTROL_MENU_MISC_2 and self.server_group ~= "" then
            TheNet:ViewNetProfile(self.server_group)
            return true
        elseif control == CONTROL_MENU_MISC_1 then
			ServerPreferences:ToggleNameAndDescriptionFilter()
			self:RefreshServerName()
            return true
        end
    end
end

function PlayerStatusScreen:OnRawKey(key, down)
    if not self:IsVisible() then
        return false
    elseif PlayerStatusScreen._base.OnRawKey(self, key, down) then
        return true
    end
    return not down
end

function PlayerStatusScreen:Close()
    TheInput:EnableDebugToggle(true)
    TheFrontEnd:PopScreen(self)
end

function PlayerStatusScreen:OnUpdate(dt)
    if TheFrontEnd:GetFadeLevel() > 0 then
        self:Close()
    elseif self.time_to_refresh > dt then
        self.time_to_refresh = self.time_to_refresh - dt
    else
        self.time_to_refresh = REFRESH_INTERVAL

        local ClientObjs = TheNet:GetClientTable() or {}

        --rebuild if player count changed
        local needs_rebuild = #ClientObjs ~= self.numPlayers

        --rebuild if players changed even though count didn't change
        if not needs_rebuild and self.scroll_list ~= nil then
            for i, client in ipairs(ClientObjs) do
                local listitem = self.scroll_list.items[i]
                if listitem == nil or
                    client.userid ~= listitem.userid or
                    (client.performance ~= nil) ~= (listitem.performance ~= nil) then
                    needs_rebuild = true
                    break
                end
            end
        end

        if needs_rebuild then
            -- We've either added or removed a player
            -- Kill everything and re-init
            self:DoInit(ClientObjs)
        else
			if TheNet:GetServerGameMode() == "lavaarena" then
                self.serverstate:SetString(subfmt(STRINGS.UI.PLAYERSTATUSSCREEN.LAVAARENA_SERVER_MODE, {mode=GetGameModeString(TheNet:GetServerGameMode()), num = TheWorld.net.components.lavaarenaeventstate:GetCurrentRound()}))
            elseif self.serverstate and self.serverage and self.serverage ~= TheWorld.state.cycles + 1 then
                self.serverage = TheWorld.state.cycles + 1
                local modeStr = GetGameModeString(TheNet:GetServerGameMode()) ~= nil and GetGameModeString(TheNet:GetServerGameMode()).." - " or ""
                self.serverstate:SetString(modeStr.." "..STRINGS.UI.PLAYERSTATUSSCREEN.AGE_PREFIX..self.serverage)
            end

            if self.scroll_list ~= nil then
                for _,playerListing in ipairs(self.player_widgets) do
                    for _,client in ipairs(ClientObjs) do
                        if playerListing.userid == client.userid and playerListing.ishost == (client.performance ~= nil) then
                            playerListing.name:SetTruncatedString(self:GetDisplayName(client), playerListing.name._align.maxwidth, playerListing.name._align.maxchars, true)
                            local w, h = playerListing.name:GetRegionSize()
                            playerListing.name:SetPosition(playerListing.name._align.x + w * .5, 0, 0)

                            playerListing.characterBadge:Set(client.prefab or "", client.colour or DEFAULT_PLAYER_COLOUR, playerListing.ishost, client.userflags or 0, client.base_skin)

                            if playerListing.characterBadge:IsAFK() then
                                playerListing.age:SetString(STRINGS.UI.PLAYERSTATUSSCREEN.AFK)
                            else
                                playerListing.age:SetString(client.playerage ~= nil and client.playerage > 0 and (tostring(client.playerage)..(client.playerage == 1 and STRINGS.UI.PLAYERSTATUSSCREEN.AGE_DAY or STRINGS.UI.PLAYERSTATUSSCREEN.AGE_DAYS)) or "")
                            end

                            if client.performance ~= nil then
                                playerListing.perf:SetTexture("images/scoreboard.xml", PERF_HOST_LEVELS[math.min(client.performance + 1, #PERF_HOST_LEVELS)])
                            elseif client.netscore ~= nil then
                                playerListing.perf:SetTexture("images/scoreboard.xml", PERF_CLIENT_LEVELS[math.min(client.netscore + 1, #PERF_CLIENT_LEVELS)])
                            else
                                playerListing.perf:SetTexture("images/scoreboard.xml", PERF_CLIENT_UNKNOWN)
                            end

                            if playerListing.kick:IsVisible() then
                                local res = UserCommands.UserRunCommandResult("kick", self.owner, client.userid)
                                if res == COMMAND_RESULT.DENY or res == COMMAND_RESULT.DISABLED then
                                    playerListing.kick:Select()
                                else
                                    playerListing.kick:Unselect()
                                end
                            end

                            if playerListing.ban:IsVisible() then
                                local res = UserCommands.UserRunCommandResult("ban", self.owner, client.userid)
                                if res == COMMAND_RESULT.DENY or res == COMMAND_RESULT.DISABLED then
                                    playerListing.ban:Select()
                                else
                                    playerListing.ban:Unselect()
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

--For ease of overriding in mods
function PlayerStatusScreen:GetDisplayName(clientrecord)
    return clientrecord.name or ""
end

function PlayerStatusScreen:RefreshServerName()
    local serverNameStr = ServerPreferences:IsNameAndDescriptionHidden() and STRINGS.UI.SERVERLISTINGSCREEN.HIDDEN_NAME or TheNet:GetServerName()
    if serverNameStr == "" then
        self.servertitle:SetString(serverNameStr)
    elseif self.servermenunumbtns > 1 then
        self.servertitle:SetTruncatedString(serverNameStr, 550, 100, true)
    elseif self.servermenunumbtns > 0 then
        self.servertitle:SetTruncatedString(serverNameStr, 600, 110, true)
    else
        self.servertitle:SetTruncatedString(serverNameStr, 800, 145, true)
    end

    local serverDescStr = TheNet:GetServerDescription()
    if serverDescStr == "" then
        self.serverdesc:SetString(serverDescStr)
    else
		serverDescStr = ServerPreferences:IsNameAndDescriptionHidden() and STRINGS.UI.SERVERLISTINGSCREEN.HIDDEN_DESCRIPTION or serverDescStr
		if self.servermenunumbtns > 1 then
			self.serverdesc:SetTruncatedString(serverDescStr, 550, 175, true)
		elseif self.servermenunumbtns > 0 then
			self.serverdesc:SetTruncatedString(serverDescStr, 600, 190, true)
		else
			self.serverdesc:SetTruncatedString(serverDescStr, 800, 250, true)
		end
	end
end

function PlayerStatusScreen:DoInit(ClientObjs)

    TheInput:EnableDebugToggle(false)

    if not self.black then
        --darken everything behind the dialog
        --bleed outside the screen a bit, otherwise it may not cover
        --the edge of the screen perfectly when scaled to some sizes
        local bleeding = 4
        self.black = self:AddChild(ImageButton("images/global.xml", "square.tex"))
        self.black.image:SetVRegPoint(ANCHOR_MIDDLE)
        self.black.image:SetHRegPoint(ANCHOR_MIDDLE)
        self.black.image:SetVAnchor(ANCHOR_MIDDLE)
        self.black.image:SetHAnchor(ANCHOR_MIDDLE)
        self.black.image:SetScaleMode(SCALEMODE_FILLSCREEN)
        self.black.image:SetTint(0,0,0,0) -- invisible, but clickable!

	    self.black:SetHelpTextMessage("")
	    self.black:SetOnClick(function() if self.click_to_close then TheFrontEnd:PopScreen(self) end end)
		self.black:MoveToBack()
    end

    if not self.root then
        self.root = self:AddChild(Widget("ROOT"))
        self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
        self.root:SetHAnchor(ANCHOR_MIDDLE)
        self.root:SetVAnchor(ANCHOR_MIDDLE)
    end

    if not self.bg then
        self.bg = self.root:AddChild(Image( "images/scoreboard.xml", "scoreboard_frame.tex" ))
        self.bg:SetScale(.96,.9)
    end

    if not self.servertitle then
        self.servertitle = self.root:AddChild(Text(UIFONT,45))
        self.servertitle:SetColour(1,1,1,1)
    end

    if not self.serverstate then
        self.serverstate = self.root:AddChild(Text(UIFONT,30))
        self.serverstate:SetColour(1,1,1,1)
    end

	if TheNet:GetServerGameMode() == "lavaarena" then
		self.serverstate:SetString(subfmt(STRINGS.UI.PLAYERSTATUSSCREEN.LAVAARENA_SERVER_MODE, {mode=GetGameModeString(TheNet:GetServerGameMode()), num = TheWorld.net.components.lavaarenaeventstate:GetCurrentRound()}))
	else
		self.serverage = TheWorld.state.cycles + 1
		local modeStr = GetGameModeString(TheNet:GetServerGameMode()) ~= nil and GetGameModeString(TheNet:GetServerGameMode()).." - " or ""
		self.serverstate:SetString(modeStr.." "..STRINGS.UI.PLAYERSTATUSSCREEN.AGE_PREFIX..self.serverage)
	end

    self.servermenunumbtns = 0

    self.server_group = TheNet:GetServerClanID()
    if self.server_group ~= "" and not TheInput:ControllerAttached() then
        if self.viewgroup_button == nil then
            self.viewgroup_button = self.root:AddChild(ImageButton("images/scoreboard.xml", "clan_normal.tex", "clan_hover.tex", "clan.tex", "clan.tex", nil, { .4, .4 }, { 0, 0 }))
            self.viewgroup_button:SetOnClick(function() TheNet:ViewNetProfile(self.server_group) end)
            self.viewgroup_button:SetHoverText(STRINGS.UI.SERVERLISTINGSCREEN.VIEWGROUP, { font = NEWFONT_OUTLINE, offset_x = 0, offset_y = 38, colour = WHITE})
        end
        self.servermenunumbtns = self.servermenunumbtns + 1
    elseif self.viewgroup_button ~= nil then
        self.viewgroup_button:Kill()
        self.viewgroup_button = nil
    end

    if not TheInput:ControllerAttached() then
        if self.toggleservertext_button == nil then
            self.toggleservertext_button = self.root:AddChild(ImageButton("images/scoreboard.xml", "toggle_server_name_normal.tex", "toggle_server_name_hover.tex", "toggle_server_name.tex", "toggle_server_name.tex", nil, { .4, .4 }, { 0, 0 }))
            self.toggleservertext_button:SetHoverText(STRINGS.UI.SERVERLISTINGSCREEN.TOGGLE_SERVER_NAME, { font = NEWFONT_OUTLINE, offset_x = 0, offset_y = 38, colour = WHITE})
            self.toggleservertext_button:SetOnClick(function()
				ServerPreferences:ToggleNameAndDescriptionFilter()
				self:RefreshServerName()
            end)
		end
        self.servermenunumbtns = self.servermenunumbtns + 1
    elseif self.toggleservertext_button ~= nil then
        self.toggleservertext_button:Kill()
        self.toggleservertext_button = nil
    end

    if ClientObjs == nil then
        ClientObjs = TheNet:GetClientTable() or {}
    end
    self.numPlayers = #ClientObjs

    if not self.players_number then
        self.players_number = self.root:AddChild(Text(UIFONT, 25))
        self.players_number:SetPosition(318,170)
        self.players_number:SetRegionSize(100,30)
        self.players_number:SetHAlign(ANCHOR_RIGHT)
        self.players_number:SetColour(1,1,1,1)
    end
    self.players_number:SetString(tostring(not TheNet:GetServerIsClientHosted() and self.numPlayers - 1 or self.numPlayers).."/"..(TheNet:GetServerMaxPlayers() or "?"))

    if not self.serverdesc then
        self.serverdesc = self.root:AddChild(Text(UIFONT,30))
        self.serverdesc:SetColour(1,1,1,1)
    end

    if not self.divider then
        self.divider = self.root:AddChild(Image("images/scoreboard.xml", "white_line.tex"))
    end

    local servermenux = -329
    local servermenubtnoffs = 24
    if self.viewgroup_button ~= nil then
        self.viewgroup_button:SetPosition(servermenux - (self.servermenunumbtns > 1 and servermenubtnoffs or 0), 200)
    end

    if self.toggleservertext_button ~= nil then
        self.toggleservertext_button:SetPosition(servermenux + (self.servermenunumbtns > 1 and servermenubtnoffs or 0), 200)
    end

    if TheNet:GetServerDescription() == "" then
        self.servertitle:SetPosition(0,215)
        self.serverdesc:SetPosition(0,175)
        self.serverstate:SetPosition(0,175)
        self.divider:SetPosition(0,155)
    else
        self.servertitle:SetPosition(0,223)
        self.servertitle:SetSize(40)
        self.serverdesc:SetPosition(0,188)
        self.serverdesc:SetSize(23)
        self.serverstate:SetPosition(0,163)
        self.serverstate:SetSize(23)
        self.players_number:SetPosition(318,160)
        self.players_number:SetSize(20)
        self.divider:SetPosition(0,149)
    end

	self:RefreshServerName()

    if not self.servermods and TheNet:GetServerModsEnabled() then
        local modsStr = TheNet:GetServerModsDescription()
        self.servermods = self.root:AddChild(Text(UIFONT,25))
        self.servermods:SetPosition(20,-250,0)
        self.servermods:SetColour(1,1,1,1)
        self.servermods:SetTruncatedString(STRINGS.UI.PLAYERSTATUSSCREEN.MODSLISTPRE.." "..modsStr, 650, 146, true)

        self.bg:SetScale(.95,.95)
        self.bg:SetPosition(0,-10)
    end

    local function doButtonFocusHookups(playerListing)
        local buttons = {}
        if playerListing.viewprofile:IsVisible() then table.insert(buttons, playerListing.viewprofile) end
        if playerListing.mute:IsVisible() then table.insert(buttons, playerListing.mute) end
        if playerListing.kick:IsVisible() then table.insert(buttons, playerListing.kick) end
        if playerListing.ban:IsVisible() then table.insert(buttons, playerListing.ban) end
        if playerListing.useractions:IsVisible() then table.insert(buttons, playerListing.useractions) end

        local focusforwardset = false
        for i,button in ipairs(buttons) do
            if not focusforwardset then
                focusforwardset = true
                playerListing.focus_forward = button
            end
            if buttons[i-1] then
                button:SetFocusChangeDir(MOVE_LEFT, buttons[i-1])
            end
            if buttons[i+1] then
                button:SetFocusChangeDir(MOVE_RIGHT, buttons[i+1])
            end
        end
    end

    local function listingConstructor(i, parent)
        local playerListing =  parent:AddChild(Widget("playerListing"))

        playerListing.highlight = playerListing:AddChild(Image("images/scoreboard.xml", "row_goldoutline.tex"))
        playerListing.highlight:SetPosition(22, 5)
        playerListing.highlight:Hide()

        if self.show_player_badge then
            playerListing.profileFlair = playerListing:AddChild(TEMPLATES.RankBadge())
            playerListing.profileFlair:SetPosition(-388,-14,0)
            playerListing.profileFlair:SetScale(.6)
        end

        playerListing.characterBadge = nil
        playerListing.characterBadge = playerListing:AddChild(PlayerBadge("", DEFAULT_PLAYER_COLOUR, false, 0))
        playerListing.characterBadge:SetScale(.8)
        playerListing.characterBadge:SetPosition(-328,5,0)
        playerListing.characterBadge:Hide()

        playerListing.number = playerListing:AddChild(Text(UIFONT, 35))
        playerListing.number:SetPosition(-422,0,0)
        playerListing.number:SetHAlign(ANCHOR_MIDDLE)
        playerListing.number:SetColour(1,1,1,1)
        playerListing.number:Hide()

        playerListing.adminBadge = playerListing:AddChild(ImageButton("images/avatars.xml", "avatar_admin.tex", "avatar_admin.tex", "avatar_admin.tex", nil, nil, {1,1}, {0,0}))
        playerListing.adminBadge:Disable()
        playerListing.adminBadge:SetPosition(-355,-13,0)
        playerListing.adminBadge.image:SetScale(.3)
        playerListing.adminBadge.scale_on_focus = false
        playerListing.adminBadge:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.ADMIN, { font = NEWFONT_OUTLINE, offset_x = 0, offset_y = 30, colour = {1,1,1,1}})
        playerListing.adminBadge:Hide()

        playerListing.name = playerListing:AddChild(Text(UIFONT, 35, ""))
        playerListing.name._align = {
            maxwidth = 215,
            maxchars = 36,
            x = -286,
        }

        playerListing.age = playerListing:AddChild(Text(UIFONT, 35, ""))
        playerListing.age:SetPosition(-20,0,0)
        playerListing.age:SetHAlign(ANCHOR_MIDDLE)
		if TheNet:GetServerGameMode() == "lavaarena" then
			playerListing.age:Hide()
		end

        playerListing.viewprofile = playerListing:AddChild(ImageButton("images/scoreboard.xml", "addfriend.tex", "addfriend.tex", "addfriend.tex", "addfriend.tex", nil, {1,1}, {0,0}))
        playerListing.viewprofile:SetPosition(120,3,0)
        playerListing.viewprofile:SetNormalScale(0.39)
        playerListing.viewprofile:SetFocusScale(0.39*1.1)
        playerListing.viewprofile:SetFocusSound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
        playerListing.viewprofile:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.VIEWPROFILE, { font = NEWFONT_OUTLINE, offset_x = 0, offset_y = 30, colour = {1,1,1,1}})

        playerListing.mute = playerListing:AddChild(ImageButton("images/scoreboard.xml", "chat.tex", "chat.tex", "chat.tex", "chat.tex", nil, {1,1}, {0,0}))
        playerListing.mute:SetPosition(170,3,0)
        playerListing.mute:SetNormalScale(0.39)
        playerListing.mute:SetFocusScale(0.39*1.1)
        playerListing.mute:SetFocusSound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
        playerListing.mute:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.MUTE, { font = NEWFONT_OUTLINE, offset_x = 0, offset_y = 30, colour = {1,1,1,1}})
        playerListing.mute.image.inst.OnUpdateVoice = function(inst)
            inst.widget:SetTint(unpack(playerListing.userid ~= nil and TheNet:IsVoiceActive(playerListing.userid) and VOICE_ACTIVE_COLOUR or VOICE_IDLE_COLOUR))
        end
        playerListing.mute.image.inst.SetMuted = function(inst, muted)
            if muted then
                inst.widget:SetTint(unpack(VOICE_MUTE_COLOUR))
                if inst._task ~= nil then
                    inst._task:Cancel()
                    inst._task = nil
                end
            else
                inst:OnUpdateVoice()
                if inst._task == nil then
                    inst._task = inst:DoPeriodicTask(1, inst.OnUpdateVoice)
                end
            end
        end
        playerListing.mute.image.inst.DisableMute = function(inst)
            inst.widget:SetTint(unpack(VOICE_IDLE_COLOUR))
            if inst._task ~= nil then
                inst._task:Cancel()
                inst._task = nil
            end
        end

        playerListing.mute:SetOnClick(
            function()
                if playerListing.userid ~= nil then
                    playerListing.isMuted = not playerListing.isMuted
                    TheNet:SetPlayerMuted(playerListing.userid, playerListing.isMuted)
                    if playerListing.isMuted then
                        playerListing.mute.image_focus = "mute.tex"
                        playerListing.mute.image:SetTexture("images/scoreboard.xml", "mute.tex")
                        playerListing.mute:SetTextures("images/scoreboard.xml", "mute.tex")
                        playerListing.mute:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.UNMUTE)
                    else
                        playerListing.mute.image_focus = "chat.tex"
                        playerListing.mute.image:SetTexture("images/scoreboard.xml", "chat.tex")
                        playerListing.mute:SetTextures("images/scoreboard.xml", "chat.tex")
                        playerListing.mute:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.MUTE)
                    end
                    playerListing.mute.image.inst:SetMuted(playerListing.isMuted)
                end
            end)

        playerListing.mute.image.inst:DisableMute()

        playerListing.kick = playerListing:AddChild(ImageButton("images/scoreboard.xml", "kickout.tex", "kickout.tex", "kickout_disabled.tex", "kickout.tex", nil, {1,1}, {0,0}))
        playerListing.kick:SetNormalScale(0.39)
        playerListing.kick:SetFocusScale(0.39*1.1)
        playerListing.kick:SetFocusSound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
        playerListing.kick:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.KICK, { font = NEWFONT_OUTLINE, offset_x = 0, offset_y = 30, colour = {1,1,1,1}})
        local gainfocusfn = playerListing.kick.OnGainFocus
        playerListing.kick.OnGainFocus = function()
            gainfocusfn(playerListing.kick)
            --TODO gjans: same functionality for extended command list
            local commandresult = UserCommands.UserRunCommandResult("kick", self.owner, playerListing.userid)
            if commandresult == COMMAND_RESULT.ALLOW then
                playerListing.kick:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.KICK)
            elseif commandresult == COMMAND_RESULT.VOTE then
                -- TODO: This thing should be voter-unaware, that should be handled by the usercommands and just return an appropriate result
                playerListing.kick:SetHoverText(string.format(STRINGS.UI.PLAYERSTATUSSCREEN.VOTEHOVERFMT, STRINGS.UI.PLAYERSTATUSSCREEN.KICK))
            elseif commandresult == COMMAND_RESULT.DISABLED then
                --we know canstart is false, but we want the reason
                local canstart, reason = UserCommands.CanUserStartCommand("kick", self.owner, playerListing.userid)
                playerListing.kick:SetHoverText(reason ~= nil and STRINGS.UI.PLAYERSTATUSSCREEN.COMMANDCANNOTSTART[reason] or "")
            elseif commandresult == COMMAND_RESULT.DENY then
                local worldvoter = TheWorld.net ~= nil and TheWorld.net.components.worldvoter or nil
                local playervoter = self.owner.components.playervoter
                if worldvoter == nil or playervoter == nil or not worldvoter:IsEnabled() then
                    --technically we should never get here (expected COMMAND_RESULT.INVALID)
                elseif worldvoter:IsVoteActive() then
                    playerListing.kick:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.VOTEACTIVEHOVER)
                elseif playervoter:IsSquelched() then
                    playerListing.kick:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.VOTESQUELCHEDHOVER)
                else
                    --we know canstart is false, but we want the reason
                    local canstart, reason = UserCommands.CanUserStartVote("kick", self.owner, playerListing.userid)
                    playerListing.kick:SetHoverText(reason ~= nil and STRINGS.UI.PLAYERSTATUSSCREEN.VOTECANNOTSTART[reason] or "")
                end
            end -- INVALID hides the button.
        end
        playerListing.kick:SetOnClick( function()
            if playerListing.userid then
                TheFrontEnd:PopScreen()
                UserCommands.RunUserCommand("kick", {user=playerListing.userid}, self.owner)
            end
        end)

        playerListing.ban = playerListing:AddChild(ImageButton("images/scoreboard.xml", "banhammer.tex", "banhammer.tex", "banhammer.tex", "banhammer.tex", nil, {1,1}, {0,0}))
        playerListing.ban:SetPosition(220,3,0)
        playerListing.ban:SetNormalScale(0.39)
        playerListing.ban:SetFocusScale(0.39*1.1)
        playerListing.ban:SetFocusSound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
        playerListing.ban:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.BAN, { font = NEWFONT_OUTLINE, offset_x = 0, offset_y = 30, colour = {1,1,1,1}})
        playerListing.ban:SetOnClick( function()
            if playerListing.userid then
                TheFrontEnd:PopScreen()
                UserCommands.RunUserCommand("ban", {user=playerListing.userid}, self.owner)
            end
        end)

        playerListing.useractions = playerListing:AddChild(ImageButton("images/scoreboard.xml", "more_actions.tex", "more_actions.tex", "more_actions.tex", "more_actions.tex", nil, {1,1}, {0,0}))
        playerListing.useractions:SetPosition(220,3,0)
        playerListing.useractions:SetNormalScale(0.39)
        playerListing.useractions:SetFocusScale(0.39*1.1)
        playerListing.useractions:SetFocusSound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
        playerListing.useractions:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.USERACTIONS, { font = NEWFONT_OUTLINE, offset_x = 0, offset_y = 30, colour = {1,1,1,1}})
        playerListing.useractions:SetOnClick(function()
            TheFrontEnd:PopScreen()
            self:OpenUserCommandPickerScreen(playerListing.userid)
        end)

        playerListing.perf = playerListing:AddChild(Image("images/scoreboard.xml", PERF_CLIENT_UNKNOWN))
        playerListing.perf:SetPosition(295, 4, 0)
        playerListing.perf:SetScale(unpack(PERF_CLIENT_SCALE))

        playerListing.OnGainFocus = function()
            playerListing.highlight:Show()
        end
        playerListing.OnLoseFocus = function()
            playerListing.highlight:Hide()
        end

        return playerListing
    end

    local function UpdatePlayerListing(playerListing, client, i)

        if client == nil or GetTableSize(client) == 0 then
            playerListing:Hide()
            return
        end

        playerListing:Show()

        playerListing.displayName = self:GetDisplayName(client)

        playerListing.userid = client.userid

        if self.show_player_badge then
            if client.netid ~= nil then
                local _, _, _, profileflair, rank = GetSkinsDataFromClientTableData(client)
                playerListing.profileFlair:SetRank(profileflair, rank)
                playerListing.profileFlair:Show()
            else
                playerListing.profileFlair:Hide()
            end
        end

        playerListing.characterBadge:Set(client.prefab or "", client.colour or DEFAULT_PLAYER_COLOUR, client.performance ~= nil, client.userflags or 0, client.base_skin)
        playerListing.characterBadge:Show()

        if client.admin then
            playerListing.adminBadge:Show()
        else
            playerListing.adminBadge:Hide()
        end

        local visible_index = i
        if not TheNet:GetServerIsClientHosted() then
            playerListing.number:SetString(i-1)
            visible_index = i-1
            if i > 1 then
                playerListing.number:Show()
            else
                playerListing.number:Hide()
            end
        else
            playerListing.number:SetString(i)
        end

        playerListing.name:SetTruncatedString(playerListing.displayName, playerListing.name._align.maxwidth, playerListing.name._align.maxchars, true)
        local w, h = playerListing.name:GetRegionSize()
        playerListing.name:SetPosition(playerListing.name._align.x + w * .5, 0, 0)
        playerListing.name:SetColour(unpack(client.colour or DEFAULT_PLAYER_COLOUR))

        playerListing.age:SetString(client.playerage ~= nil and client.playerage > 0 and (tostring(client.playerage)..(client.playerage == 1 and STRINGS.UI.PLAYERSTATUSSCREEN.AGE_DAY or STRINGS.UI.PLAYERSTATUSSCREEN.AGE_DAYS)) or "")

        playerListing.ishost = client.performance ~= nil

        if client.performance ~= nil then
			local perf_id = math.min(client.performance + 1, #PERF_HOST_LEVELS)
            playerListing.perf:SetTexture("images/scoreboard.xml", PERF_HOST_LEVELS[perf_id])
            playerListing.perf:SetScale(unpack(PERF_HOST_SCALE))
            playerListing.perf:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.PERF_HOST_LEVELS[perf_id])
        else
            if client.netscore ~= nil then
				local perf_id = math.min(client.netscore + 1, #PERF_CLIENT_LEVELS)
                playerListing.perf:SetTexture("images/scoreboard.xml", PERF_CLIENT_LEVELS[perf_id])
				playerListing.perf:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.PERF_CLIENT_LEVELS[perf_id])
            else
                playerListing.perf:SetTexture("images/scoreboard.xml", PERF_CLIENT_UNKNOWN)
				playerListing.perf:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.PERF_CLIENT_LEVEL_UNKNOWN)
            end
            playerListing.perf:SetScale(unpack(PERF_CLIENT_SCALE))
        end

        local this_user_is_dedicated_server = client.performance ~= nil and not TheNet:GetServerIsClientHosted()

        playerListing.viewprofile:SetOnClick(
            function()
                TheFrontEnd:PopScreen()
                self.owner.HUD:TogglePlayerAvatarPopup(playerListing.displayName, client, true, true)
            end)

        local button_start = 50
        local button_x = button_start
        local button_x_offset = 42

        local can_kick = false
        local can_ban = false

        if not this_user_is_dedicated_server then
            playerListing.viewprofile:Show()
            playerListing.viewprofile:SetPosition(button_x,3,0)
            button_x = button_x + button_x_offset
            can_kick = UserCommands.CanUserAccessCommand("kick", self.owner, client.userid)
            can_ban = BAN_ENABLED and UserCommands.CanUserAccessCommand("ban", self.owner, client.userid)
        else
            playerListing.viewprofile:Hide()
        end

        playerListing.isMuted = client.muted == true
        if playerListing.isMuted then
            playerListing.mute.image_focus = "mute.tex"
            playerListing.mute.image:SetTexture("images/scoreboard.xml", "mute.tex")
            playerListing.mute:SetTextures("images/scoreboard.xml", "mute.tex")
            playerListing.mute:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.UNMUTE)
        else
            playerListing.mute.image_focus = "chat.tex"
            playerListing.mute.image:SetTexture("images/scoreboard.xml", "chat.tex")
            playerListing.mute:SetTextures("images/scoreboard.xml", "chat.tex")
            playerListing.mute:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.MUTE)
        end

        if client.userid ~= self.owner.userid and not this_user_is_dedicated_server then
            playerListing.mute:Show()
            playerListing.mute:SetPosition(button_x,3,0)
            button_x = button_x + button_x_offset
            playerListing.mute.image.inst:SetMuted(playerListing.isMuted)
        else
            playerListing.mute:Hide()
            playerListing.mute.image.inst:DisableMute()
        end

        if can_kick then
            playerListing.kick:Show()
            playerListing.kick:SetPosition(button_x,3,0)
            button_x = button_x + button_x_offset

            local res = UserCommands.UserRunCommandResult("kick", self.owner, client.userid)
            if res == COMMAND_RESULT.DENY or res == COMMAND_RESULT.DISABLED then
                playerListing.kick:Select()
            else
                playerListing.kick:Unselect()
            end
        else
            playerListing.kick:Hide()
        end

        if can_ban then
            playerListing.ban:Show()
            playerListing.ban:SetPosition(button_x,3,0)
            button_x = button_x + button_x_offset

            local res = UserCommands.UserRunCommandResult("ban", self.owner, client.userid)
            if res == COMMAND_RESULT.DENY or res == COMMAND_RESULT.DISABLED then
                playerListing.ban:Select()
            else
                playerListing.ban:Unselect()
            end
        else
            playerListing.ban:Hide()
        end

        if this_user_is_dedicated_server then
            playerListing.useractions:Hide()
        else
            --Check if we have any user actions other than kick or ban (they have their own buttons)
            playerListing.useractions:Hide()
            for i, v in ipairs(UserCommands.GetUserActions(self.owner, playerListing.userid)) do
                if v.commandname ~= "kick" and v.commandname ~= "ban" then
                    playerListing.useractions:SetPosition(button_start + button_x_offset * 4, 3, 0)
                    playerListing.useractions:Show()
                    break
                end
            end
        end

        doButtonFocusHookups(playerListing)
    end

    if not self.scroll_list then
        self.list_root = self.root:AddChild(Widget("list_root"))
        self.list_root:SetPosition(210, -35)

        self.row_root = self.root:AddChild(Widget("row_root"))
        self.row_root:SetPosition(210, -35)

        self.player_widgets = {}
        for i=1,6 do
            table.insert(self.player_widgets, listingConstructor(i, self.row_root))
            UpdatePlayerListing(self.player_widgets[i], ClientObjs[i] or {}, i)
        end

        self.scroll_list = self.list_root:AddChild(ScrollableList(ClientObjs, 380, 370, 60, 5, UpdatePlayerListing, self.player_widgets, nil, nil, nil, -15))
        self.scroll_list:LayOutStaticWidgets(-15)
        self.scroll_list:SetPosition(0,-10)

        self.focus_forward = self.scroll_list
        self.default_focus = self.scroll_list
    else
        self.scroll_list:SetList(ClientObjs)
    end

    if not self.bgs then
        self.bgs = {}
    end
    if #self.bgs > #ClientObjs then
        for i = #ClientObjs + 1, #self.bgs do
            table.remove(self.bgs):Kill()
        end
    else
        local maxbgs = math.min(self.scroll_list.widgets_per_view, #ClientObjs)
        if #self.bgs < maxbgs then
            for i = #self.bgs + 1, maxbgs do
                local bg = self.scroll_list:AddChild(Image("images/scoreboard.xml", "row.tex"))
                bg:SetTint(1, 1, 1, (i % 2) == 0 and .85 or .5)
                bg:SetPosition(-170, 165 - 65 * (i - 1))
                bg:MoveToBack()
                table.insert(self.bgs, bg)
            end
        end
    end
end

function PlayerStatusScreen:OpenUserCommandPickerScreen(targetuserid)
    if self.usercommandpickerscreen == nil then
        self.usercommandpickerscreen = UserCommandPickerScreen(self.owner, targetuserid, function() self.usercommandpickerscreen = nil end)
        TheFrontEnd:PushScreen(self.usercommandpickerscreen)
    end
end

function PlayerStatusScreen:IsUserCommandPickerScreenOpen()
    return self.usercommandpickerscreen ~= nil
end

function PlayerStatusScreen:CloseUserCommandPickerScreen()
    if self.usercommandpickerscreen ~= nil then
        TheFrontEnd:PopScreen(self.usercommandpickerscreen)
    end
end

return PlayerStatusScreen
