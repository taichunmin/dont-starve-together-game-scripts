local CloudServerSettingsPopup = require "screens/redux/cloudserversettingspopup"
local OnlineStatus = require "widgets/onlinestatus"
local PlayerSummaryScreen = require "screens/redux/playersummaryscreen"
local QuickJoinScreen = require "screens/redux/quickjoinscreen"
local Screen = require "widgets/screen"
local ServerListingScreen = require "screens/redux/serverlistingscreen"
local PopupDialogScreen = require "screens/redux/popupdialog"
local AchievementsPanel = require "widgets/redux/achievementspanel"

local TEMPLATES = require("widgets/redux/templates")

require("constants")

local FestivalEventScreen = Class(Screen, function(self, prev_screen, session_data)
	Screen._ctor(self, "FestivalEventScreen")

    self.session_data = session_data

    self:DoInit()

	self.default_focus = self.menu
	self.menu:SetFocus()
end)

function FestivalEventScreen:DoInit()
    self.root = self:AddChild(TEMPLATES.ScreenRoot())
    self.fg = self:AddChild(TEMPLATES.ReduxForeground())
    self.bg = self.root:AddChild(TEMPLATES.BoarriorBackground())
    self.bg_anim = self.root:AddChild(TEMPLATES.BoarriorAnim())
    self.title = self.root:AddChild(TEMPLATES.ScreenTitle(STRINGS.UI.FESTIVALEVENTSCREEN.TITLE[string.upper(WORLD_FESTIVAL_EVENT)]))

    self.achievements = self.root:AddChild(AchievementsPanel(self.user_profile, WORLD_FESTIVAL_EVENT))
    self.achievements:SetPosition(120,-60)

    self.onlinestatus = self.root:AddChild(OnlineStatus(true))
    self.userprogress = self.root:AddChild(TEMPLATES.UserProgress(function()
        self:StopMusic()
        self:_FadeToScreen(PlayerSummaryScreen, {Profile})
    end))

    self.menu = self.root:AddChild(self:_MakeMenu())
	self.menu.reverse = true

    if not TheInput:ControllerAttached() then
        self.back_button = self.root:AddChild(TEMPLATES.BackButton(
                function()
                    self:StopMusic()
                    TheFrontEnd:FadeBack()
                end
            ))
    end
end

function FestivalEventScreen:_MakeMenu()
    self.tooltip = self.root:AddChild(TEMPLATES.ScreenTooltip())
	
    local button_quickmatch = TEMPLATES.MenuButton(STRINGS.UI.FESTIVALEVENTSCREEN.QUICKMATCH, function() self:OnQuickmatchButton() end, STRINGS.UI.FESTIVALEVENTSCREEN.TOOLTIP_QUICKMATCH, self.tooltip)
    local button_host       = TEMPLATES.MenuButton(STRINGS.UI.FESTIVALEVENTSCREEN.HOST,       function() self:OnHostButton() end,       STRINGS.UI.FESTIVALEVENTSCREEN.TOOLTIP_HOST,       self.tooltip)
    local button_browse     = TEMPLATES.MenuButton(STRINGS.UI.FESTIVALEVENTSCREEN.BROWSE,     function() self:OnBrowseButton() end,     STRINGS.UI.FESTIVALEVENTSCREEN.TOOLTIP_BROWSE,     self.tooltip)

    local menu_items = {
        {widget = button_browse    },
        {widget = button_host      },
        {widget = button_quickmatch},
    }

    return self.root:AddChild(TEMPLATES.StandardMenu(menu_items, 38, nil, nil, true))
end

local function CalcQuickJoinServerScoreForEvent(server)
	-- Return the score for the server.
	-- Highest scored servers will have the highest priority
	-- Return -1 to reject the server

	if BRANCH == "dev" and server.name == "Release test server" then
		return 10
	end

	if (not server.has_password)										-- not passworded
		and server.current_players < server.max_players						-- not full
		and server.allow_new_players										-- the match has not started
		and (server.ping ~= nil and server.ping >= 0 and server.ping < 300)	-- filter out bad pings
	then
		local score = 0
		if server._has_character_on_server then		score = score + 100		end
		if server.friend_playing then				score = score + 4		end
		if server.belongs_to_clan then				score = score + 2		end

		score = score + server.current_players * 1.5
		score = score + (
                (server.ping < 50 and 8) or
                (server.ping < 100 and 5) or
                (server.ping < 150 and 2) or
                0
            )

		return score
	end

	return -1
end

function FestivalEventScreen:OnQuickmatchButton()
    TheFrontEnd:PushScreen(QuickJoinScreen(self, false, self.session_data, 
		GetFestivalEventInfo().GAME_MODE,
		CalcQuickJoinServerScoreForEvent,
		function() self:OnHostButton() end,
		function() self:OnBrowseButton() end))
end
function FestivalEventScreen:OnHostButton()
    local forced_settings = {
                server_intention = INTENTIONS.COOPERATIVE,
                max_players = 6,
                game_mode = GetFestivalEventInfo().GAME_MODE,
    }
    TheFrontEnd:PushScreen(CloudServerSettingsPopup(self, self.user_profile, forced_settings))
end
function FestivalEventScreen:OnBrowseButton()
    local filter_settings = {
        { is_forced = true, name = "ISDEDICATED",  data = true },
        { is_forced = true, name = "GAMEMODE",     data = "ANY" },
        { is_forced = true, name = "HASPVP",       data = false },
        { is_forced = true, name = "ISEMPTY",      data = false },
        { is_forced = true, name = "SEASON",       data = "ANY" },
        { is_forced = true, name = "MODSENABLED",  data = false },
    }
    local forced_settings = {
        intention = "any",
        online = true,
        isempty = false, --non-nil forced isempty will exclude from total count as well
    }
    local cb = nil
    local is_offline = false
    self:_FadeToScreen(ServerListingScreen, {filter_settings, cb, is_offline, self.session_data, forced_settings, GetFestivalEventInfo().GAME_MODE})
end
function FestivalEventScreen:_FadeToScreen(screen_type, data)
    self.last_focus_widget = TheFrontEnd:GetFocusWidget()
    self.menu:Disable()
    self.leaving = true

    TheFrontEnd:FadeToScreen( self, function() return screen_type(self.user_profile, unpack(data)) end, nil )
end

local function OnStartMusic(inst, self, music)
    self.musictask = nil
    self.musicstarted = true
    TheFrontEnd:GetSound():PlaySound(music, "FEMusic")
end

function FestivalEventScreen:StartMusic()
    if not self.musicstarted and self.musictask == nil then
        local music = GetFestivalEventInfo().FEMUSIC
        if music ~= nil then
            self.musictask = self.inst:DoTaskInTime(1.25, OnStartMusic, self, music)
        end
    end
end

function FestivalEventScreen:StopMusic()
    if self.musicstarted then
        self.musicstarted = false
        TheFrontEnd:GetSound():KillSound("FEMusic")
    elseif self.musictask ~= nil then
        self.musictask:Cancel()
        self.musictask = nil
    end
end

function FestivalEventScreen:OnBecomeActive()
	if self.popup_backout then
		return
	end
	
    FestivalEventScreen._base.OnBecomeActive(self)

    if not self.shown then
        self:Show()
    end

	self.menu:RestoreFocusTo(self.last_focus_widget)

    self:StartMusic()

    self.leaving = nil

	if TheFrontEnd:GetIsOfflineMode() or not TheNet:IsOnlineMode() then
		TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_TITLE, STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_BODY, 
			{
				{text=STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_LOGIN, cb = function()
						SimReset()
					end},
				{text=STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_BACK, cb = function()
					    self.popup_backout = true
						self:StopMusic()
						TheFrontEnd:FadeBack(nil, nil, function() TheFrontEnd:PopScreen() end)
					end},
			}))
	end
end

function FestivalEventScreen:OnControl(control, down)
    if FestivalEventScreen._base.OnControl(self, control, down) then return true end

    if not down and control == CONTROL_CANCEL then
        self:StopMusic()
        TheFrontEnd:FadeBack()
        return true
    end

	if down then
        if control == CONTROL_SCROLLBACK then
            if self.achievements.grid:Scroll(-.66) then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover")
            end
            return true
        elseif control == CONTROL_SCROLLFWD then
            if self.achievements.grid:Scroll(.66) then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover")
            end
            return true
        end
    end
end

function FestivalEventScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

	if not self.achievements.grid.focus and self.achievements.grid:CanScroll() then
	    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_SCROLLBACK) .. "/" .. TheInput:GetLocalizedControl(controller_id, CONTROL_SCROLLFWD) .. " " .. STRINGS.UI.HELP.SCROLL)
	end

    return table.concat(t, "  ")
end


return FestivalEventScreen
