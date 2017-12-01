local ChatSidebar = require "widgets/redux/chatsidebar"
local WxpLobbyPanel = require "widgets/redux/wxplobbypanel"
local MvpWidget = require "widgets/mvploadingwidget"
local OnlineStatus = require "widgets/onlinestatus"
local Screen = require "widgets/screen"
local Text = require "widgets/text"
local Widget = require "widgets/widget"
local LoadoutSelect = require "widgets/redux/loadoutselect"
local CharacterButton = require "widgets/redux/characterbutton"
local CharacterSelect = require "widgets/redux/characterselect"
local WaitingForPlayers = require "widgets/waitingforplayers"
local PopupDialogScreen = require "screens/redux/popupdialog"

local TEMPLATES = require "widgets/redux/templates"


require("util")
require("networking")
require("stringutil")

local DEBUG_MODE = BRANCH == "dev"

local REFRESH_INTERVAL = .25

local function StartGame(this)
    if this.startbutton then
        this.startbutton:Disable()
    end

    if this.cb then
		local skins = this.currentskins
        this.cb(this.character_for_game, skins.base, skins.body, skins.hand, skins.legs, skins.feet) --parameters are base_prefab, skin_base, clothing_body, clothing_hand, then clothing_legs
    end
end

local LobbyPanel = Class(Widget, function(self, panel_name)
    Widget._ctor(self, panel_name)
end)

local ServerLockedPanel = Class(Widget, function(self, owner)
    LobbyPanel._ctor(self, "ServerLockedPanel")
    self.title = ""
    
    function self:OnGainFocus()
		owner.active = false
		owner:Disable()

		TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.LOBBYSCREEN.SERVER_SHUTDOWN_TITLE, STRINGS.UI.LOBBYSCREEN.SERVER_SHUTDOWN_BODY, {{text=STRINGS.UI.LOBBYSCREEN.DISCONNECT, cb = function() DoRestart(true) end}}))
	end
end)

local WxpPanel = Class(LobbyPanel, function(self, owner)
    LobbyPanel._ctor(self, "WxpPanel")

	local outcome = Settings.match_results ~= nil and Settings.match_results.outcome or {}

	self.title = outcome.won and STRINGS.UI.WXPLOBBYPANEL.TITLE_VICTORY or STRINGS.UI.WXPLOBBYPANEL.TITLE_DEFEAT
	self.next_button_title = Settings.match_results.wxp_data == nil and STRINGS.UI.WXPLOBBYPANEL.CONTINUE or STRINGS.UI.WXPLOBBYPANEL.SKIP

	local show_mvp_cards = Settings.match_results.mvp_cards ~= nil
	if show_mvp_cards then
		self.mvp_widget = self:AddChild(MvpWidget())
		self.mvp_widget:PopulateData()
		self.mvp_widget:SetScale(.55)
		self.mvp_widget:SetPosition(0, 75)
	end
	
	self.wxp = self:AddChild(WxpLobbyPanel(owner.profile, function() owner.next_button:SetText(STRINGS.UI.WXPLOBBYPANEL.CONTINUE) end))
    self.wxp:SetPosition(0, show_mvp_cards and -145 or 70)

	if outcome.time ~= nil then
		local match_time = self:AddChild(Text(CHATFONT, 18, subfmt(STRINGS.UI.WXPLOBBYPANEL.MATCH_TIME, {time = str_seconds(outcome.time)})))
		match_time:SetPosition(-250, 285)
		match_time:SetColour(UICOLOURS.GOLD)
		match_time:SetRegionSize(400, 20)
		match_time:SetHAlign(ANCHOR_LEFT)
	end		
	if outcome.total_deaths ~= nil then
		local text = outcome.total_deaths == 0 and STRINGS.UI.WXPLOBBYPANEL.NO_DEATHS or subfmt(STRINGS.UI.WXPLOBBYPANEL.DEATHS, {deaths = outcome.total_deaths})
		local deaths = self:AddChild(Text(CHATFONT, 18, text))
		deaths:SetPosition(-250, 265)
		deaths:SetColour(UICOLOURS.GOLD)
		deaths:SetRegionSize(400, 20)
		deaths:SetHAlign(ANCHOR_LEFT)
	end
	
	if not TheNet:IsOnlineMode() then
		self.wxp:Hide()
		self.mvp_widget:SetPosition(0, 0)
	end

	function self:OnUpdate(dt)
		self.wxp:OnUpdate(dt)
	end

	function self:OnControl(control, down)
		if Widget.OnControl(self, control, down) then return true end

        if TheInput:ControllerAttached() and (not down) and (control == CONTROL_PAUSE or control == CONTROL_ACCEPT) then
			owner.next_button:onclick()
			return true
        end
	end

	function self:GetHelpText()
	    local controller_id = TheInput:GetControllerID()
		return TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. "  " .. owner.next_button.text:GetString() .. "  "
	end

	function self:OnNextButton()
		if self.wxp:IsAnimating() then
			self.wxp:SkipAnimation()
			return false
		end
		
		return true
	end

end)

local CharacterSelectPanel = Class(LobbyPanel, function(self, owner)
    LobbyPanel._ctor(self, "CharacterSelectPanel")

	self.title = STRINGS.UI.LOBBYSCREEN.SELECTION_TITLE

    local function OnCharacterClick(hero)
        owner.next_button:onclick()
    end

    self.character_scroll_list = self:AddChild(CharacterSelect(self,
            CharacterButton,
            125,
            nil, -- use default gameplay descriptions
            nil,
            nil,
            OnCharacterClick,
            {"random"}
        ))
	if TheNet:GetServerGameMode() == "lavaarena" then
	    self:SetPosition(300, 170)
	else
	    self:SetPosition(300, 100)
	end
    
    self.focus_forward = self.character_scroll_list
    
    function self:OnGainFocus()
		if owner.lobbycharacter ~= nil then
			self.character_scroll_list:RefocusCharacter(owner.lobbycharacter)
		end
    end

	function self:OnControl(control, down)
		if Widget.OnControl(self, control, down) then return true end

		if TheInput:ControllerAttached() then
			if down and control == CONTROL_MENU_MISC_2 then
				OnCharacterClick("random")
				TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
				return true
			elseif (not down) and control == CONTROL_PAUSE then
				OnCharacterClick(self.character_scroll_list.selectedportrait.currentcharacter)
				return true
			end
		end
	end

	function self:OnNextButton()
		owner.lobbycharacter = self.character_scroll_list.selectedportrait.currentcharacter or "random"
		return true
	end

	function self:GetHelpText()
	    local controller_id = TheInput:GetControllerID()
		local t = {}
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2) .. "  " .. STRINGS.UI.LOBBYSCREEN.RANDOMCHAR)
	    return table.concat(t, "  ")
	end
end)

local LoadoutPanel = Class(LobbyPanel, function(self, owner)
    LobbyPanel._ctor(self, "LoadoutPanel")

    self:SetPosition(-160, 0)

	self.title = STRINGS.UI.COLLECTIONSCREEN.SKINS
	self.next_button_title = GetGameModeProperty("lobbywaitforallplayers") and STRINGS.UI.LOBBYSCREEN.READY or STRINGS.UI.LOBBYSCREEN.START

	self.loadout = self:AddChild(LoadoutSelect(owner.profile))
    self.loadout:SelectPortrait(owner.lobbycharacter)
    self.loadout:StartLoadout()

    self.focus_forward = self.loadout

	function self:OnUpdate(dt)
		self.loadout:OnUpdate(dt)
	end

	function self:OnControl(control, down)
		if Widget.OnControl(self, control, down) then return true end

		if TheInput:ControllerAttached() then
			if (not down) and control == CONTROL_PAUSE then
				owner.next_button:onclick()
				return true
			end
		end
	end

	function self:GetHelpText()
	    local controller_id = TheInput:GetControllerID()
		local t = {}
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_PAUSE) .. "  " .. self.next_button_title)
	    return table.concat(t, "  ")
	end

	function self:OnNextButton()
        self.loadout.dressup:OnClose()
		owner.currentskins = self.loadout.dressup:GetSkinsForGameStart()
		owner.character_for_game = self.loadout.dressup.currentcharacter

		if GetGameModeProperty("lobbywaitforallplayers") then
			if owner.lobbycharacter == "random" then
				TheNet:SendLobbyCharacterRequestToServer("random")
			else
				local skins = owner.currentskins
				TheNet:SendLobbyCharacterRequestToServer(owner.lobbycharacter, skins.base, skins.body, skins.hand, skins.legs, skins.feet)
			end
			return true
		else
			StartGame(owner)
			return false
		end
	end
end)

local WaitingPanel = Class(LobbyPanel, function(self, owner, profile)
    LobbyPanel._ctor(self, "WaitingPanel")

	self.title = STRINGS.UI.LOBBYSCREEN.WAITING_FOR_PLAYERS_TITLE

	self.waiting_for_players = self:AddChild(WaitingForPlayers(self, TheNet:GetServerMaxPlayers()))
	self.waiting_for_players:Refresh(true)
    self.focus_forward = self.waiting_for_players

	function self:OnUpdate(dt)
		if self.on_character_rest_cb then
			self.on_character_rest_cb(self)
		end

		self.waiting_for_players:Refresh()
	end

	function self:OnBackButton()
		local client_obj = TheNet:GetClientTableForUser(TheNet:GetUserID())
		if client_obj == nil or client_obj.lobbycharacter == nil or client_obj.lobbycharacter == "" then
			self.on_character_rest_cb = nil
			owner.back_button:Enable()
		    if not TheInput:ControllerAttached() then
				owner.back_button:Show()
			end
			return true
		end

		if not self.pending_reset_character_request then
			self.pending_reset_character_request = true
			owner:Disable()
			TheNet:SendLobbyCharacterRequestToServer("")
			self.on_character_rest_cb = function() owner.back_button:onclick() end
		end
		owner.back_button:Disable()
		owner.back_button:Hide()
		return false
	end
end)


local LobbyScreen = Class(Screen, function(self, profile, cb)
    Screen._ctor(self, "LobbyScreen")
    self.profile = profile
    self.issoundplaying = false

    if cb ~= nil then
        self.cb = function(char, skin_base, clothing_body, clothing_hand, clothing_legs, clothing_feet)
            self:StopLobbyMusic()
            cb(char, skin_base, clothing_body, clothing_hand, clothing_legs, clothing_feet)
        end
    end

--	Settings.match_results.mvp_cards = json.decode('[{"user":{"name":"ScqTTFyott","prefab":"wickerbottom","userid":"FU_229530977","base":"wickerbottom_none","colour":[0.80392156862745,0.30980392156863,0.22352941176471,1]},"beststat":["kills2",234]},{"user":{"name":"Scott","prefab":"wilson","userid":"FU_229530977","base":"wilson_none","colour":[0.80392156862745,0.30980392156863,0.22352941176471,1]},"beststat":["damagetaken2",546]},{"user":{"name":"Scott","prefab":"wes","userid":"FU_229530977","base":"wes_none","colour":[0.80392156862745,0.30980392156863,0.22352941176471,1]},"beststat":["blowdarts",5203]},{"user":{"name":"ThisIsAVeryLongName","prefab":"wolfgang","userid":"FU_229530977","base":"wolfgang_none","colour":[0.80392156862745,0.30980392156863,0.22352941176471,1]},"beststat":["standards",65]},{"user":{"name":"Scott","prefab":"waxwell","userid":"FU_229530977","base":"waxwell_none","colour":[0.80392156862745,0.30980392156863,0.22352941176471,1]},"beststat":["damagetaken",87]},{"user":{"name":"Scott","prefab":"webber","userid":"FU_229530977","base":"webber_none","colour":[0.80392156862745,0.30980392156863,0.22352941176471,1]},"beststat":["aggroheld",34]}]')
--	Settings.match_results.wxp_data = {}
--	Settings.match_results.wxp_data[TheNet:GetUserID()] = { new_xp = 7998, match_xp = 5998+500, earned_boxes = 2, details = {{desc="DAILY_FIRST_WIN", val=2000}, {desc="WIN", val=1000}, {desc="DURATION", val=500}, {desc="webber_victory", val=1000}, {desc="webber_merciless", val=500}, {desc="webber_darts", val=500}, {desc="nodeaths_self", val=1000}, {desc="nodeaths_team", val=3000}, {desc="nodeaths_uniqueteam", val=5500}, {desc="wintime_30", val=1500}, {desc="wintime_25", val=3500}, {desc="wintime_20", val=5500}} }
--	Settings.match_results.outcome = {won = true, round = 5, time = 333, total_deaths = 23}

    self.lobbycharacter = nil
	self.character_for_game = nil
    self.currentskins = nil
    self.time_to_refresh = REFRESH_INTERVAL
    self.current_panel_index = 0

    self.root = self:AddChild(TEMPLATES.ScreenRoot("screenroot"))
    self.fg = self:AddChild(TEMPLATES.ReduxForeground())
    self.root:AddChild(TEMPLATES.LeftSideBarBackground())	

    self.panel_root = self.root:AddChild(Widget("panel_root"))
	self.panel_root:SetPosition(160, 0)
	self.default_focus = self.panel_root

    if DEBUG_MODE then
        self.onlinestatus = self.root:AddChild(OnlineStatus())
    end

	self.panels = {}
	
	if GetGameModeProperty("lobbywaitforallplayers") then
		if (Settings.match_results.wxp_data ~= nil and Settings.match_results.wxp_data[TheNet:GetUserID()] ~= nil) or Settings.match_results.mvp_cards then
			table.insert(self.panels, {panelfn = WxpPanel})
		end

		local server_shutting_down = TheWorld ~= nil and TheWorld.net ~= nil and TheWorld.net.components.worldcharacterselectlobby ~= nil and TheWorld.net.components.worldcharacterselectlobby:IsServerLockedForShutdown()
		if server_shutting_down then
			table.insert(self.panels, {panelfn = ServerLockedPanel})
		else
			table.insert(self.panels, {panelfn = CharacterSelectPanel})
			table.insert(self.panels, {panelfn = LoadoutPanel})
			table.insert(self.panels, {panelfn = WaitingPanel})
		end
	else 
		table.insert(self.panels, {panelfn = CharacterSelectPanel})
		table.insert(self.panels, {panelfn = LoadoutPanel})
	end
	
    self.panel_title = self.root:AddChild(TEMPLATES.ScreenTitle_BesideLeftSideBar( "" ))
	
	self.back_button = self.root:AddChild(TEMPLATES.BackButton_BesideLeftSidebar(function() if self.panel.OnBackButton == nil or self.panel:OnBackButton() then self.back_button._onclick_goback() end end, "", nil))
	self.next_button = self.root:AddChild(TEMPLATES.StandardButton(function() if self.panel.OnNextButton == nil or self.panel:OnNextButton() then self:ToNextPanel(1) end end, "", {200, 50}))
	self.next_button:SetPosition(500, self.back_button:GetPosition().y - 5)
    if TheInput:ControllerAttached() then
		self.back_button:Hide()
		self.next_button:Hide()
	end
	
    self.chat_sidebar = self.root:AddChild(ChatSidebar())

	self:ToNextPanel(1)
	
	self.inst:ListenForEvent("lobbyplayerspawndelay", function(world, data) 
			if data and data.active then
				self.back_button:Disable()
				self.back_button:Hide()
				if data.time == 0 then
					StartGame(self)
				end
			end
		end, TheWorld)
		
		
	-- dump the player stats on all the clients
	-- TODO: Move this somewhere better
	if not TheNet:IsDedicated() then
		local player_stats = Settings.match_results.player_stats or TheFrontEnd.match_results.player_stats
		if player_stats ~= nil then
			local str = "\ngamemode,"..player_stats.gametype
			str = str .."\nsession," .. player_stats.session
			str = str .."\nclient_date," .. os.date("%c")
			
			local outcome = Settings.match_results.outcome or TheFrontEnd.match_results.outcome
			if outcome ~= nil then
				str = str .. "\nwon," .. (outcome.won and "true" or "false") 
				str = str .. "\nround," .. tostring(outcome.round)
				str = str .. "\ntime," .. tostring(math.floor(outcome.time))
			end
			
			str = str .. "\nfields"
			for _, v in ipairs(player_stats.fields) do
				str = str .. "," .. v
			end
			
			for _, player in ipairs(player_stats.data) do
				str = str .. "\nuser"
				for _, v in ipairs(player) do
					str = str .. "," .. v
				end
			end
			print(str)

			str = str .. "\nendofmatch"

			print("Logging Match Statistics")
			local stats_file = "forge_stats/forge_stats_" .. string.gsub(os.date("%x"), "/", "-") .. ".csv"
			TheSim:GetPersistentString(stats_file, function(load_success, old_str) 
				if old_str ~= nil then
					str = str .. "\n" .. old_str
				end
				TheSim:SetPersistentString(stats_file, str, false, function() print("Done Logging Match Statistics") end)
			end)
			
		end
	end
end)

function LobbyScreen:OnBecomeActive()
    self._base.OnBecomeActive(self)
    self:StartLobbyMusic()
end

function LobbyScreen:OnDestroy()
    self:StopLobbyMusic()
    self._base.OnDestroy(self)
end

function LobbyScreen:StartLobbyMusic()
    if not self.issoundplaying then
        self.issoundplaying = true
        TheMixer:SetLevel("master", 1)
        TheMixer:PushMix("lobby")
        TheFrontEnd:GetSound():KillSound("FEMusic")
        TheFrontEnd:GetSound():KillSound("FEPortalSFX")
        TheFrontEnd:GetSound():PlaySound(GetGameModeProperty("override_lobby_music") or "dontstarve/together_FE/DST_theme_portaled", "PortalMusic")
        TheFrontEnd:GetSound():PlaySound("dontstarve/together_FE/portal_swirl", "PortalSFX")
    end
end

function LobbyScreen:StopLobbyMusic()
    if self.issoundplaying then
        self.issoundplaying = false
        TheFrontEnd:GetSound():KillSound("PortalMusic")
        TheFrontEnd:GetSound():KillSound("PortalSFX")
        TheMixer:PopMix("lobby")
    end
end

function LobbyScreen:ReceiveChatMessage(...)
    self.chat_sidebar:ReceiveChatMessage(...)
end

local function FindNextPanelIndex(panels, cur, dir)
	cur = cur + dir
	while (cur > 0 and cur <= #panels and panels[cur].enabledfn ~= nil and not panels[cur]:enabledfn()) do
		cur = cur + dir
	end
	return cur
end

function LobbyScreen:ToNextPanel(dir)
	local prev_panel_index = self.current_panel_index
	self.current_panel_index = math.clamp(FindNextPanelIndex(self.panels, self.current_panel_index, dir), 1, #self.panels)

	if prev_panel_index ~= self.current_panel_index then
		self:Disable()
        local prev_penel = self.panel
        self.inst:DoTaskInTime(0, function()
			if prev_penel ~= nil then
				prev_penel:Kill()
			end

			self:Enable()
			self.panel:Show()
			self.panel:SetFocus()
		end)
		
		if self.panel ~= nil then
			self.panel:Disable()
			self.panel:Hide()
		end
		
		self.panel_root:ClearFocus()
		self.panel = self.panel_root:AddChild(self.panels[self.current_panel_index].panelfn(self))
		self.panel:Hide()

		self.panel_title:SetString(self.panel.title)
	
		if FindNextPanelIndex(self.panels, self.current_panel_index, -1) <= 0 then
			self.back_button._onclick_goback = function() self:DoConfirmQuit() end
			self.back_button:SetText(STRINGS.UI.LOBBYSCREEN.DISCONNECT, true)
		else
			self.back_button._onclick_goback = function() self:ToNextPanel(-1) end
			self.back_button:SetText(STRINGS.UI.LOBBYSCREEN.BACK, true)
		end

		if self.panel.next_button_title == nil then
			self.next_button:Hide()
		else
			self.next_button:SetText(self.panel.next_button_title)
			if TheInput:ControllerAttached() then
				self.next_button:Hide()
			else
				self.next_button:Show()
			end
		end		
		
		self.panel_root.focus_forward = self.panel
		self:DoFocusHookups()
	end
end

function LobbyScreen:OnFocusMove(dir, down)
    if self.chat_sidebar:IsChatting() then
        -- Don't allow focus moving when chatting because WASD moves focus.
        return true
    end
    return LobbyScreen._base.OnFocusMove(self, dir, down)
end

function LobbyScreen:OnControl(control, down)
	if not self.enabled then
		return false
	end
	
    if LobbyScreen._base.OnControl(self, control, down) then return true end

    if not down and control == CONTROL_CANCEL then
		self.back_button.onclick()
        return true 
    end

    return false
end

function LobbyScreen:DoFocusHookups()
	self.panel:SetFocusChangeDir(MOVE_LEFT, self.chat_sidebar.chatbox)
    self.chat_sidebar:SetFocusChangeDir(MOVE_RIGHT, self.panel)
    self.chat_sidebar:DoFocusHookups()
end

function LobbyScreen:DoConfirmQuit()
    self.active = false

    local function doquit()
        self.parent:Disable()
        DoRestart(true)
    end

    if TheNet:GetIsServer() then
        local confirm = PopupDialogScreen(STRINGS.UI.LOBBYSCREEN.HOSTQUITTITLE, STRINGS.UI.LOBBYSCREEN.HOSTQUITBODY, {{text=STRINGS.UI.LOBBYSCREEN.YES, cb = doquit},{text=STRINGS.UI.LOBBYSCREEN.NO, cb = function() TheFrontEnd:PopScreen() end}  })
        if JapaneseOnPS4() then
            confirm:SetTitleTextSize(40)
            confirm:SetButtonTextSize(30)
        end
        TheFrontEnd:PushScreen(confirm)
    else
        local confirm = PopupDialogScreen(STRINGS.UI.LOBBYSCREEN.CLIENTQUITTITLE, STRINGS.UI.LOBBYSCREEN.CLIENTQUITBODY, {{text=STRINGS.UI.LOBBYSCREEN.YES, cb = doquit},{text=STRINGS.UI.LOBBYSCREEN.NO, cb = function() TheFrontEnd:PopScreen() end}  })
        if JapaneseOnPS4() then
            confirm:SetTitleTextSize(40)
            confirm:SetButtonTextSize(30)
        end
        TheFrontEnd:PushScreen(confirm)
    end
end

function LobbyScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

	if self.back_button:IsEnabled() then
	    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. self.back_button.text:GetString())
	end

    return table.concat(t, "  ")
end

function LobbyScreen:OnUpdate(dt)
    if self.time_to_refresh > dt then
        self.time_to_refresh = self.time_to_refresh - dt
    else
        self.time_to_refresh = REFRESH_INTERVAL
        self.chat_sidebar:Refresh()
    end

	if self.panel ~= nil and self.panel.OnUpdate ~= nil then
		self.panel:OnUpdate(dt)
	end

end

return LobbyScreen
