local Screen = require "widgets/screen"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
require "os"

local PopupDialogScreen = require "screens/redux/popupdialog"
local RedeemDialog = require "screens/redeemdialog"
local EmailSignupScreen = require "screens/emailsignupscreen"
local FestivalEventScreen = require "screens/redux/festivaleventscreen"
local MovieDialog = require "screens/moviedialog"
local CreditsScreen = require "screens/creditsscreen"
local ModsScreen = require "screens/redux/modsscreen"
local OptionsScreen = require "screens/redux/optionsscreen"
local PlayerSummaryScreen = require "screens/redux/playersummaryscreen"
local QuickJoinScreen = require "screens/redux/quickjoinscreen"
local ServerListingScreen = require "screens/redux/serverlistingscreen"
local ServerCreationScreen = require "screens/redux/servercreationscreen"


local TEMPLATES = require "widgets/redux/templates"

local OnlineStatus = require "widgets/onlinestatus"
local ThankYouPopup = require "screens/thankyoupopup"
local SkinGifts = require("skin_gifts")
local Stats = require("stats")




local SHOW_DST_DEBUG_HOST_JOIN = BRANCH == "dev"
local SHOW_MOTD = true
local SHOW_QUICKJOIN = false

if PLATFORM == "WIN32_RAIL" then
	SHOW_MOTD = false
end


local MultiplayerMainScreen = Class(Screen, function(self, prev_screen, profile, offline, session_data)
	Screen._ctor(self, "MultiplayerMainScreen")
    self.profile = profile
    self.offline = offline
    self.session_data = session_data
	self.log = true
    self.prev_screen = prev_screen
	self:DoInit()
	self.default_focus = self.menu
end)

function MultiplayerMainScreen:DoInit()
    self.fixed_root = self:AddChild(Widget("root"))
    self.fixed_root:SetVAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetHAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.fg = self:AddChild(TEMPLATES.ReduxForeground())

    if IsAnyFestivalEventActive() then
        self.bg = self.fixed_root:AddChild(TEMPLATES.BoarriorBackground())
        self.bg_anim = self.fixed_root:AddChild(TEMPLATES.BoarriorAnim())
        if not TheFrontEnd:GetIsOfflineMode() then
			self.userprogress = self.fixed_root:AddChild(TEMPLATES.UserProgress(function()
				self:OnPlayerSummaryButton()
			end))
		end
    else
        local anim = UIAnim()
        anim:GetAnimState():SetBuild("dst_menu")
        anim:GetAnimState():SetBank("dst_menu")
        anim:SetScale(0.7)
        anim:SetPosition(300, -10)
        anim.PlayOnLoop = function()
            anim:GetAnimState():PlayAnimation("loop", true)
        end
        anim:PlayOnLoop()

        self.bg_anim = self.fixed_root:AddChild(anim)
    end

	self.motd = self.fixed_root:AddChild(Widget("motd"))
    self.motd:SetPosition(-240, 230)

    self.motdbg = self.motd:AddChild(TEMPLATES.RectangleWindow(105,179,
        STRINGS.UI.MAINSCREEN.MOTDTITLE,
        nil,
        nil,
        STRINGS.UI.MAINSCREEN.MOTD
    ))
    self.motdbg:SetBackgroundTint(0,0,0,.85)
    self.motd.motdtitle = self.motdbg.title
    self.motd.motdtext = self.motdbg.body
    -- smaller font is more subtle
    self.motd.motdtitle:SetSize(34)
    self.motd.motdtext:SetSize(20)

	self.motd.motdimage = self.motd:AddChild(ImageButton( "images/global.xml", "square.tex" ))
    self.motd.motdimage:SetScale(.7)
    self.motd.motdimage.scale_on_focus = false -- show focus on motd.button
    self.motd.motdimage:Hide()    
	self.motd.motdimage:SetOnClick(
		function()
			self.motd.button.onclick()
		end)

    self.motd.button = self.motd:AddChild(ImageButton("images/global_redux.xml",
            "button_carny_long_normal.tex",
            "button_carny_long_hover.tex",
            "button_carny_long_disabled.tex",
            "button_carny_long_down.tex"
        ))
    self.motd.button:SetPosition(0,-103)
    self.motd.button:SetScale(.45)
    self.motd.button:SetText(STRINGS.UI.MAINSCREEN.MOTDBUTTON)
    self.motd.button:SetOnClick( function() VisitURL("http://store.kleientertainment.com/") end )

    self.motd.focus_forward = self.motd.button


	local gainfocusfn_img = self.motd.motdimage.OnGainFocus
    local losefocusfn_img = self.motd.motdimage.OnLoseFocus
    
    self.motd.motdimage.OnGainFocus =
		function()
    		gainfocusfn_img(self.motd.motdimage)
    		self.motd.button.image:SetTexture(self.motd.button.atlas, self.motd.button.image_focus)
		end
	self.motd.motdimage.OnLoseFocus =
		function()
    		losefocusfn_img(self.motd.motdimage)
			if not self.motd.button.focus then
    			self.motd.button.image:SetTexture(self.motd.button.atlas, self.motd.button.image_normal)
    		end
		end

    self.motd.button.OnGainFocus =
		function()
    		self.motd.button._base.OnGainFocus(self.motd.button)
    		self.motd.button.image:SetTexture(self.motd.button.atlas, self.motd.button.image_focus)
		end
	self.motd.button.OnLoseFocus =
		function()
    		self.motd.button._base.OnLoseFocus(self.motd.button)
			if not self.motd.motdimage.focus then
    			self.motd.button.image:SetTexture(self.motd.button.atlas, self.motd.button.image_normal)
    		end
		end
	
	
	self.fixed_root:AddChild(Widget("left"))
    
    self.title = self.fixed_root:AddChild(Image("images/frontscreen.xml", "title.tex"))
    self.title:SetScale(.32)
    self.title:SetPosition( -RESOLUTION_X/2 + 160, 220)
    self.title:SetTint(unpack(FRONTEND_TITLE_COLOUR))

	local updatename_x = -RESOLUTION_X * .5 + 170
	local updatename_y = -RESOLUTION_Y * .5 + 55

    self.updatename = self.fixed_root:AddChild(Text(NEWFONT, 21))
    self.updatename:SetPosition( updatename_x, updatename_y )
    self.updatename:SetColour(1,1,1,1)
    self.updatename:SetHAlign(ANCHOR_LEFT)
    self.updatename:SetRegionSize(200,45)
    local suffix = ""
    if BRANCH == "dev" then
		suffix = " (internal v"..APP_VERSION..")"
    elseif BRANCH == "staging" then
		suffix = " (preview v"..APP_VERSION..")"
    else
        suffix = " (v"..APP_VERSION..")"
    end
    self.updatename:SetString(STRINGS.UI.MAINSCREEN.DST_UPDATENAME .. suffix)
    
    self:MakeMainMenu()
	self:MakeSubMenu()

    self.onlinestatus = self.fixed_root:AddChild(OnlineStatus( true ))

	self:UpdateMOTD()
    ----------------------------------------------------------

	self.filter_settings = nil

    --focus moving
    self.motd:SetFocusChangeDir(MOVE_LEFT, self.menu, -1)
    self.motd:SetFocusChangeDir(MOVE_DOWN, self.submenu)
    self.motd:SetFocusChangeDir(MOVE_RIGHT, self.submenu)
    if SHOW_MOTD then
        self.menu:SetFocusChangeDir(MOVE_RIGHT, self.motd)
        self.submenu:SetFocusChangeDir(MOVE_LEFT, self.motd)
        self.submenu:SetFocusChangeDir(MOVE_UP, self.motd)
    else
        self.menu:SetFocusChangeDir(MOVE_RIGHT, self.submenu)
        self.submenu:SetFocusChangeDir(MOVE_LEFT, self.menu)
        self.submenu:SetFocusChangeDir(MOVE_UP, self.menu)
    end
    if self.debug_menu then 
        self.motd:SetFocusChangeDir(MOVE_RIGHT, self.debug_menu, -1)
        self.debug_menu:SetFocusChangeDir(MOVE_LEFT, self.motd)
        self.debug_menu:SetFocusChangeDir(MOVE_RIGHT, self.submenu)
    end


    self.menu:SetFocus(#self.menu.items)

    --V2C: This is so the first time we become active will trigger OnShow to UpdatePuppets
    self:Hide()
end

function MultiplayerMainScreen:OnShow()
    self._base.OnShow(self)
end

function MultiplayerMainScreen:OnHide()
    self._base.OnHide(self)
end

function MultiplayerMainScreen:OnDestroy()
    self:OnHide()
    self._base.OnDestroy(self)
end

function MultiplayerMainScreen:OnRawKey(key, down)
end

function MultiplayerMainScreen:_FadeToScreen(screen_ctor, data)
    self.last_focus_widget = TheFrontEnd:GetFocusWidget()
    self.menu:Disable()
    self.leaving = true --Note(Peter): what is this even used for?!?

    TheFrontEnd:FadeToScreen( self, function() return screen_ctor(self, unpack(data)) end, nil )
end

--------------------------------------------------------------------------------
--V2C: Currently only FestivalEventScreen transitions use these music helpers

function MultiplayerMainScreen:StopMusic()
    local festival = GetFestivalEventInfo()
    if festival and festival.FEMUSIC ~= nil then
        if not self.musicstopped then
            self.musicstopped = true
            TheFrontEnd:GetSound():KillSound("FEMusic")
            TheFrontEnd:GetSound():KillSound("FEPortalSFX")
        elseif self.musictask ~= nil then
            self.musictask:Cancel()
            self.musictask = nil
        end
    end
end

local function OnStartMusic(inst, self)
    self.musictask = nil
    self.musicstopped = false
    TheFrontEnd:GetSound():PlaySound(FE_MUSIC, "FEMusic")
    TheFrontEnd:GetSound():PlaySound("dontstarve/together_FE/portal_idle_vines", "FEPortalSFX")
end

function MultiplayerMainScreen:StartMusic()
    TheFrontEnd:GetSound():SetParameter("FEMusic", "fade", 0)
    if self.musicstopped and self.musictask == nil then
        self.musictask = self.inst:DoTaskInTime(1.25, OnStartMusic, self)
    end
end

--------------------------------------------------------------------------------
function MultiplayerMainScreen:_GoToFestfivalEventScreen(fadeout_cb)
	self:StopMusic()
	
	self.last_focus_widget = TheFrontEnd:GetFocusWidget()
    self.menu:Disable()
    self.leaving = true --Note(Peter): what is this even used for?!?

    TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()
		if fadeout_cb ~= nil then
			fadeout_cb()
		end
        TheFrontEnd:PushScreen(FestivalEventScreen(self, self.session_data))
        TheFrontEnd:Fade(FADE_IN, SCREEN_FADE_TIME)
        self:Hide()
    end)
end

function MultiplayerMainScreen:OnFestivalEventButton()
    if TheFrontEnd:GetIsOfflineMode() or not TheNet:IsOnlineMode() then
        TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_TITLE, STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_BODY, 
            {
                {text=STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_LOGIN, cb = function()
                        SimReset()
                    end},
                {text=STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_BACK, cb=function() TheFrontEnd:PopScreen() end },
            }))
    else
		if AreAnyModsEnabled() and not KnownModIndex:GetIsSpecialEventModWarningDisabled() then
			TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.FESTIVALEVENTSCREEN.MODS_POPUP_TITLE, STRINGS.UI.FESTIVALEVENTSCREEN.MODS_POPUP_BODY, 
				{
					{text=STRINGS.UI.FESTIVALEVENTSCREEN.MODS_POPUP_DISABLE_MODS, cb = function()
							self:Disable()
                            KnownModIndex:DisableAllMods()
                            ForceAssetReset()
                            KnownModIndex:SetDisableSpecialEventModWarning()
                            KnownModIndex:Save(function()
                                SimReset()
                            end)
						end},
					{text=STRINGS.UI.FESTIVALEVENTSCREEN.MODS_POPUP_CONTINUE, cb=function() 
						    KnownModIndex:SetDisableSpecialEventModWarning()
                            KnownModIndex:Save(function()
								self:_GoToFestfivalEventScreen(function() TheFrontEnd:PopScreen() end)
							end)
						end},
					{text=STRINGS.UI.FESTIVALEVENTSCREEN.MODS_POPUP_CANCEL, cb=function() 
								TheFrontEnd:PopScreen()
						end},
				}))
		else
			self:_GoToFestfivalEventScreen()
		end
    
	end
end

function MultiplayerMainScreen:OnCreateServerButton()
    self:_GoToOnlineScreen(ServerCreationScreen, {})
end

function MultiplayerMainScreen:_GoToOnlineScreen(screen_ctor, data)
    self.last_focus_widget = TheFrontEnd:GetFocusWidget()
    self.menu:Disable()
    self.leaving = true --Note(Peter): what is this even used for?!?
    TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()
        Profile:ShowedNewUserPopup()
        Profile:Save(function()
            TheFrontEnd:PushScreen(screen_ctor(self, unpack(data)))
            TheFrontEnd:Fade(FADE_IN, SCREEN_FADE_TIME)
            self:Hide()
        end)
    end)
end

function MultiplayerMainScreen:OnBrowseServersButton()
    if self:CheckNewUser(self.OnBrowseServersButton, STRINGS.UI.MAINSCREEN.NEWUSER_NO) then
        return
    end

    local function cb(filters)
	    self.filter_settings = filters
	    Profile:SaveFilters(self.filter_settings)
    end

	if not self.filter_settings then
		self.filter_settings = Profile:GetSavedFilters()
	end

    if self.filter_settings and #self.filter_settings > 0 then
        for i,v in pairs(self.filter_settings) do
			if v.name == "SHOWLAN" then
				v.data = self.offline
			end
		end
    else
        self.filter_settings = {}
        table.insert(self.filter_settings, {name = "SHOWLAN", data=self.offline} )   
    end

    self:_GoToOnlineScreen(ServerListingScreen, { self.filter_settings, cb, self.offline, self.session_data })
end

function MultiplayerMainScreen:OnPlayerSummaryButton()

    if TheFrontEnd:GetIsOfflineMode() or not TheNet:IsOnlineMode() then
        TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MAINSCREEN.OFFLINE, STRINGS.UI.MAINSCREEN.ITEMCOLLECTION_DISABLE, 
            {
                {text=STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_LOGIN, cb = function()
                        SimReset()
                    end},
                {text=STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_BACK, cb=function() TheFrontEnd:PopScreen() end },
            }))
    else
        self:StopMusic()
        self:_FadeToScreen(PlayerSummaryScreen, {Profile})
    end
end


function MultiplayerMainScreen:OnQuickJoinServersButton()
    if self:CheckNewUser(self.OnQuickJoinServersButton, STRINGS.UI.MAINSCREEN.NEWUSER_NO_QUICKJOIN) then
        return
    end

    self.last_focus_widget = TheFrontEnd:GetFocusWidget()
    self.menu:Disable()
    self.leaving = true

    -- QuickJoin is a popup, so don't fade to it.
    TheFrontEnd:PushScreen(QuickJoinScreen(self, self.offline, self.session_data, 
		"",
		CalcQuickJoinServerScore,
		function() self:OnCreateServerButton() end,
		function() self:OnBrowseServersButton() end))
end


function MultiplayerMainScreen:Settings()
    self:_FadeToScreen(OptionsScreen, {})
end

function MultiplayerMainScreen:OnModsButton()
    self:_FadeToScreen(ModsScreen, {})
end


-- SUBSCREENS
function MultiplayerMainScreen:EmailSignup()
    self.last_focus_widget = TheFrontEnd:GetFocusWidget()
	TheFrontEnd:PushScreen(EmailSignupScreen())
end

function MultiplayerMainScreen:Forums()
	VisitURL("http://forums.kleientertainment.com/forum/73-dont-starve-together-beta/")
end
 
function MultiplayerMainScreen:Quit()
    self.last_focus_widget = TheFrontEnd:GetFocusWidget()
    TheFrontEnd:PushScreen(PopupDialogScreen(
            STRINGS.UI.MAINSCREEN.ASKQUIT,
            STRINGS.UI.MAINSCREEN.ASKQUITDESC,
            {
                { text=STRINGS.UI.MAINSCREEN.YES, cb = function() RequestShutdown() end },
                { text=STRINGS.UI.MAINSCREEN.NO, cb = function() TheFrontEnd:PopScreen() end },
            }
        ))
end


local function OnMovieDone()
    TheFrontEnd:GetSound():PlaySound(FE_MUSIC, "FEMusic")
    TheFrontEnd:GetSound():SetParameter("FEMusic", "fade", 0)
    TheFrontEnd:GetSound():PlaySound("dontstarve/together_FE/portal_idle_vines", "FEPortalSFX")
    TheFrontEnd:Fade(FADE_IN, 2)
end

function MultiplayerMainScreen:OnMovieButton()
    self.last_focus_widget = TheFrontEnd:GetFocusWidget()
    TheFrontEnd:GetSound():KillSound("FEMusic")
    TheFrontEnd:GetSound():KillSound("FEPortalSFX")
    self.menu:Disable()
    if self.debug_menu ~= nil then
        self.debug_menu:Disable()
    end
    
	TheFrontEnd:FadeToScreen( self, function() return MovieDialog("movies/intro.ogv", OnMovieDone) end, nil )
end

function MultiplayerMainScreen:OnCreditsButton()
    self.last_focus_widget = TheFrontEnd:GetFocusWidget()
	TheFrontEnd:GetSound():KillSound("FEMusic")
    TheFrontEnd:GetSound():KillSound("FEPortalSFX")
	self.menu:Disable()
    if self.debug_menu then self.debug_menu:Disable() end
    
	TheFrontEnd:FadeToScreen( self, function() return CreditsScreen() end, nil )
end

function MultiplayerMainScreen:OnRedeemButton()
	self.last_focus_widget = TheFrontEnd:GetFocusWidget()
	TheFrontEnd:PushScreen(RedeemDialog())
end

function MultiplayerMainScreen:OnHostButton()
    SaveGameIndex:LoadServerEnabledModsFromSlot()
    KnownModIndex:Save()
    local start_in_online_mode = false
    local slot = SaveGameIndex:GetCurrentSaveSlot()
    if TheNet:StartServer(start_in_online_mode, slot, SaveGameIndex:GetSlotServerData(slot)) then
        DisableAllDLC()
        StartNextInstance({ reset_action = RESET_ACTION.LOAD_SLOT, save_slot = slot })
    end
end

function MultiplayerMainScreen:OnJoinButton()
	local start_worked = TheNet:StartClient(DEFAULT_JOIN_IP)
	if start_worked then
        DisableAllDLC()
	end
	ShowLoading()
end

function MultiplayerMainScreen:MakeMainMenu()
    -- There's no Back on main menu, so menu and tooltip positions are shifted.
    self.menu_root = self.fixed_root:AddChild(Widget("menu_root"))
    self.menu_root:SetPosition(0,-50)

    self.tooltip = self.menu_root:AddChild(TEMPLATES.ScreenTooltip())

    local function MakeMainMenuButton(text, onclick, tooltip_text, tooltip_widget)
        local btn = TEMPLATES.MenuButton(text, onclick, tooltip_text, tooltip_widget)

        -- Inject our updatename_root handlers to move the game's version number in place.
        local old_ongainfocus = btn.ongainfocus
        btn.ongainfocus = function()
            old_ongainfocus()
        end
        local old_onlosefocus = btn.onlosefocus
        btn.onlosefocus = function()
            old_onlosefocus()
        end

        return btn
    end
	
    local browse_button  = MakeMainMenuButton(STRINGS.UI.MAINSCREEN.BROWSE,    function() self:OnBrowseServersButton() end, STRINGS.UI.MAINSCREEN.TOOLTIP_BROWSE, self.tooltip)
    local host_button    = MakeMainMenuButton(STRINGS.UI.MAINSCREEN.CREATE,    function() self:OnCreateServerButton() end,  STRINGS.UI.MAINSCREEN.TOOLTIP_HOST, self.tooltip)
    local summary_button = MakeMainMenuButton(STRINGS.UI.PLAYERSUMMARYSCREEN.TITLE, function() self:OnPlayerSummaryButton() end, STRINGS.UI.MAINSCREEN.TOOLTIP_PLAYERSUMMARY, self.tooltip)
    local options_button = MakeMainMenuButton(STRINGS.UI.MAINSCREEN.OPTIONS,   function() self:Settings() end,              STRINGS.UI.MAINSCREEN.TOOLTIP_OPTIONS, self.tooltip)
    local quit_button    = MakeMainMenuButton(STRINGS.UI.MAINSCREEN.QUIT,      function() self:Quit() end,                  STRINGS.UI.MAINSCREEN.TOOLTIP_QUIT, self.tooltip)

	local menu_items = {
        {widget = quit_button},
        {widget = options_button},
        {widget = summary_button},
        {widget = host_button},
        {widget = browse_button},
    }

    if MODS_ENABLED then
        local mods_button = MakeMainMenuButton(STRINGS.UI.MAINSCREEN.MODS, function() self:OnModsButton() end, STRINGS.UI.MAINSCREEN.TOOLTIP_MODS, self.tooltip)
        -- Mods should appear above quit (the last menu option).
        table.insert(menu_items, 2, {widget = mods_button})
    end
	if SHOW_QUICKJOIN and not TheFrontEnd:GetIsOfflineMode() and not IsAnyFestivalEventActive() then
        local quickjoin_button = MakeMainMenuButton(STRINGS.UI.MAINSCREEN.QUICKJOIN, function() self:OnQuickJoinServersButton() end, STRINGS.UI.MAINSCREEN.TOOLTIP_QUICKJOIN, self.tooltip)
		table.insert(menu_items, {widget = quickjoin_button})
	end
    if IsAnyFestivalEventActive() then
        local festival_button = MakeMainMenuButton(STRINGS.UI.MAINSCREEN.FESTIVALEVENT[string.upper(WORLD_FESTIVAL_EVENT)], function() self:OnFestivalEventButton() end, STRINGS.UI.MAINSCREEN.TOOLTIP_FESTIVALEVENT[string.upper(WORLD_FESTIVAL_EVENT)], self.tooltip)
        -- Event should appear first in the menu.
        table.insert(menu_items, {widget = festival_button})
    end

    self.menu = self.menu_root:AddChild(TEMPLATES.StandardMenu(menu_items, 38, nil, nil, true))

    -- For Debugging/Testing    
    if SHOW_DST_DEBUG_HOST_JOIN then
		local debug_menu_items = {}
        table.insert( debug_menu_items, {text=STRINGS.UI.MAINSCREEN.JOIN, cb= function() self:OnJoinButton() end})
        table.insert( debug_menu_items, {text=STRINGS.UI.MAINSCREEN.HOST, cb= function() self:OnHostButton() end})

		self.debug_menu = self.fixed_root:AddChild(Menu(debug_menu_items, 74))
		self.debug_menu:SetPosition(-50, 250)
		self.debug_menu:SetScale(.8)
    end
end

function MultiplayerMainScreen:MakeSubMenu()
    local submenuitems = {}

    local function MakeSubMenuButton(name, text, onclick)
        local btn = ImageButton("images/frontscreen.xml", name..".tex", nil, nil, nil, nil, {1,1}, {0,0})
        btn.image:SetPosition(0, 70)
        btn:SetTextColour(UICOLOURS.GOLD)
        btn:SetTextFocusColour(UICOLOURS.GOLD)
        btn:SetFocusScale(1.05, 1.05, 1.05)
        btn:SetNormalScale(1, 1, 1)
        btn:SetText(text)
        btn.bg = btn:AddChild(Image("images/ui.xml", "blank.tex"))
        local w,h = btn.text:GetRegionSize()
        btn.bg:ScaleToSize(w+15, h+15)
        local gainfocusfn = btn.OnGainFocus
        local losefocusfn = btn.OnLoseFocus
        btn.OnGainFocus = function()
            gainfocusfn(btn)
            btn:SetTextSize(43)
        end
        btn.OnLoseFocus = function()
            losefocusfn(btn)
            btn:SetTextSize(40)
        end
        btn:SetOnClick(onclick)
        btn:SetScale(.75)

        return btn
    end

    local credits_button = TEMPLATES.old.IconButton("images/button_icons.xml", "credits.tex", STRINGS.UI.MAINSCREEN.CREDITS, false, true, function() self:OnCreditsButton() end, {font=NEWFONT_OUTLINE, focus_colour={1,1,1,1}})
    local movie_button = TEMPLATES.old.IconButton("images/button_icons.xml", "movie.tex", STRINGS.UI.MAINSCREEN.MOVIE, false, true, function() self:OnMovieButton() end, {font=NEWFONT_OUTLINE, focus_colour={1,1,1,1}})
    local forums_button = TEMPLATES.old.IconButton("images/button_icons.xml", "forums.tex", STRINGS.UI.MAINSCREEN.FORUM, false, true, function() self:Forums() end, {font=NEWFONT_OUTLINE, focus_colour={1,1,1,1}})
    local newsletter_button = TEMPLATES.old.IconButton("images/button_icons.xml", "newsletter.tex", STRINGS.UI.MAINSCREEN.NOTIFY, false, true, function() self:EmailSignup() end, {font=NEWFONT_OUTLINE, focus_colour={1,1,1,1}})

    if PLATFORM == "WIN32_STEAM" or PLATFORM == "LINUX_STEAM" or PLATFORM == "OSX_STEAM" then

        local more_games_button = TEMPLATES.old.IconButton("images/button_icons.xml", "more_games.tex", STRINGS.UI.MAINSCREEN.MOREGAMES, false, true, function() VisitURL("http://store.steampowered.com/search/?developer=Klei%20Entertainment") end, {font=NEWFONT_OUTLINE, focus_colour={1,1,1,1}})

        if TheFrontEnd:GetAccountManager():HasSteamTicket() then

            local manage_account_button = TEMPLATES.old.IconButton("images/button_icons.xml", "profile.tex", STRINGS.UI.SERVERCREATIONSCREEN.MANAGE_ACCOUNT, false, true, function() VisitURL(TheFrontEnd:GetAccountManager():GetViewAccountURL(), true ) end, {font=NEWFONT_OUTLINE, focus_colour={1,1,1,1}})

			local online = TheNet:IsOnlineMode() and not TheFrontEnd:GetIsOfflineMode()
			if online then
				local redeem_button = TEMPLATES.old.IconButton("images/button_icons.xml", "redeem.tex", STRINGS.UI.MAINSCREEN.REDEEM, false, true, function() self:OnRedeemButton() end, {font=NEWFONT_OUTLINE, focus_colour={1,1,1,1}})
	            submenuitems =
				{
            		{widget = redeem_button},
					{widget = manage_account_button},
                    {widget = movie_button},
					{widget = credits_button},
					{widget = forums_button},
					{widget = more_games_button},
					{widget = newsletter_button},
				}
			else
				--have steam ticket, but offline
				submenuitems =
				{
					{widget = manage_account_button},
                    {widget = movie_button},
					{widget = credits_button},
					{widget = forums_button},
					{widget = more_games_button},
					{widget = newsletter_button},
				}
			end
        else
			--no valid steam ticket
            submenuitems =
            {
                {widget = movie_button},
                {widget = credits_button},
                {widget = forums_button},
                {widget = more_games_button},
                {widget = newsletter_button},
            }
        end
    else
        submenuitems =
            {
                {widget = movie_button},
                {widget = credits_button},
                {widget = forums_button},
                {widget = newsletter_button},
            }
    end

    self.submenu = self.fixed_root:AddChild(Menu(submenuitems, 75, true))
    if TheInput:ControllerAttached() then
        self.submenu:SetPosition( RESOLUTION_X*.5 - (#submenuitems*60), -(RESOLUTION_Y*.5)+80, 0)
    else
        self.submenu:SetPosition( RESOLUTION_X*.5 - (#submenuitems*60), -(RESOLUTION_Y*.5)+77, 0)    
    end
    self.submenu:SetScale(.8)
end

function MultiplayerMainScreen:OnBecomeActive()
    MultiplayerMainScreen._base.OnBecomeActive(self)

    ValidateItemsInProfile(Profile)

    if self.leaving and self.userprogress then
        -- Maybe have returned from collection with new icon or from game with
        -- more xp.
        self.userprogress:UpdateProgress()
    end

    if not self.shown then
        self:Show()
    end

	self.menu:RestoreFocusTo(self.last_focus_widget)

    if self.debug_menu then self.debug_menu:Enable() end

    self.leaving = nil

    self:StartMusic()

    --start a new query everytime we go back to the mainmenu
	if TheSim:IsLoggedOn() then
		TheSim:StartWorkshopQuery()
	end

end

function MultiplayerMainScreen:FinishedFadeIn()
	--Do new entitlement items
	local items = {} -- early access thank you gifts
    local entitlement_items = TheInventory:GetUnopenedEntitlementItems()
	for _,item in pairs(entitlement_items) do
		table.insert(items, { item = item.item_type, item_id = item.item_id, gifttype = SkinGifts.types[item.item_type] or "DEFAULT" })
	end
	
    if #items > 0 then
        local thankyou_popup = ThankYouPopup(items)
        TheFrontEnd:PushScreen(thankyou_popup)
    else
		--Make sure we only do one mainscreen popup at a time
		--Do language mods assistance popup
		local interface_lang = TheNet:GetLanguageCode()
		if interface_lang ~= "english" then
			if Profile:GetValue("language_mod_asked_"..interface_lang) ~= true then
				TheSim:QueryServer( "https://s3.amazonaws.com/ds-mod-language/dst_mod_languages.json",
				function( result, isSuccessful, resultCode )
 					if isSuccessful and string.len(result) > 1 and resultCode == 200 then
 						local status, language_mods = pcall( function() return json.decode(result) end )
						local lang_popup = language_mods[interface_lang]
						if status and lang_popup ~= nil then
							if lang_popup.collection ~= "" then
								local popup_screen = PopupDialogScreen( lang_popup.title, lang_popup.body,
										{
											{text=lang_popup.yes, cb = function() VisitURL("http://steamcommunity.com/workshop/filedetails/?id="..lang_popup.collection) TheFrontEnd:PopScreen() self:OnModsButton() end },
											{text=lang_popup.no, cb = function() TheFrontEnd:PopScreen() end}
										}
									)

								TheFrontEnd:PushScreen( popup_screen )
								Profile:SetValue("language_mod_asked_"..interface_lang, true)
								Profile:Save()
							end
						end
					end
				end, "GET" )
			end
		end
	end
end


function MultiplayerMainScreen:OnUpdate(dt)
end

function MultiplayerMainScreen:OnGetMOTDImageQueryComplete( is_successful )
	if is_successful then
		self.motd.motdimage:SetTextures( "images/motd.xml", "motd.tex", "motd.tex", "motd.tex", "motd.tex", "motd.tex" )
		self.motd.motdimage:Show()
	end	
end

local function push_motd_event( event, url, image_version )
	local values = {}
	values.url = url .. "#" .. tostring(image_version)
	Stats.PushMetricsEvent(event, TheNet:GetUserID(), values)
end

function MultiplayerMainScreen:SetMOTD(str, cache)
	--print("MultiplayerMainScreen:SetMOTD", str, cache)

	local status, motd = pcall( function() return json.decode(str) end )
	--print("decode:", status, motd)
	if status and motd then
	    if cache then
	 		SavePersistentString("motd_image", str)
	    end

        local platform_motd = motd.dststeam

		if platform_motd then
			--make sure we have an actual valid URL
			if platform_motd.link_url
                and not string.match( platform_motd.link_url, "http://" )
                and not string.match( platform_motd.link_url, "https://" )
                then
				platform_motd.link_url = "http://" .. platform_motd.link_url
			end
			
		    self.motd:Show()
		    if platform_motd.motd_title and string.len(platform_motd.motd_title) > 0 and
			    	platform_motd.motd_body and string.len(platform_motd.motd_body) > 0 then
			    
			    self.motd.motdtitle:Show()
				self.motd.motdtitle:SetString(platform_motd.motd_title)
				self.motd.motdtext:Show()
				self.motd.motdtext:SetString(platform_motd.motd_body)
				self.motd.motdimage:Hide()

			    if platform_motd.link_title and string.len(platform_motd.link_title) > 0 and
				    	platform_motd.link_url and string.len(platform_motd.link_url) > 0 then
				    self.motd.button:SetText(platform_motd.link_title)
				    self.motd.button:SetOnClick( function()
				    	push_motd_event( "motd.clicked", platform_motd.link_url, platform_motd.image_version or 0 )
						VisitURL(platform_motd.link_url)
					end )
				else
					self.motd.button:Hide()
				end
		    elseif platform_motd.image_url and string.len(platform_motd.image_url) > 0 then

				self.motd.motdtitle:Hide()
				self.motd.motdtext:Hide()
				
				local use_disk_file = not cache
				if use_disk_file then
					self.motd.motdimage:Hide()
				end
				
				if platform_motd.link_title and string.len(platform_motd.link_title) > 0 and
				    	platform_motd.link_url and string.len(platform_motd.link_url) > 0 then
				    self.motd.button:SetText(platform_motd.link_title)
				    self.motd.button:SetOnClick( function()
				    	push_motd_event( "motd.clicked", platform_motd.link_url, platform_motd.image_version or 0 )
						VisitURL(platform_motd.link_url)
					end )
				else
					self.motd.button:Hide()
				end
				
				TheSim:GetMOTDImage( platform_motd.image_url, use_disk_file, platform_motd.image_version or "", function(...) self:OnGetMOTDImageQueryComplete(...) end )
		    else
				print("HIDE MOTD")
				self.motd:Hide()
		    end
		    
		    
			if platform_motd.link_url and cache then --the one we cache is the latest we downloaded
				push_motd_event( "motd.seen", platform_motd.link_url, platform_motd.image_version or 0 )
			end
	    else
			print("HIDE MOTD")
			self.motd:Hide()
		end
	end
end

function MultiplayerMainScreen:OnMOTDQueryComplete( result, isSuccessful, resultCode )
	--print( "MultiplayerMainScreen:OnMOTDQueryComplete", result, isSuccessful, resultCode )
 	if isSuccessful and string.len(result) > 1 and resultCode == 200 then 
 		self:SetMOTD(result, true)
	end
end

function MultiplayerMainScreen:OnCachedMOTDLoad(load_success, str)
	--print("MultiplayerMainScreen:OnCachedMOTDLoad", load_success, str)
	if load_success and string.len(str) > 1 then
		self:SetMOTD(str, false)
	end
	TheSim:QueryServer( "https://d21wmy1ql1e52r.cloudfront.net/ds_image_motd.json", function(...) self:OnMOTDQueryComplete(...) end, "GET" )
	--TheSim:QueryServer( "https://s3-us-west-2.amazonaws.com/kleifiles/external/ds_image_motd.json", function(...) self:OnMOTDQueryComplete(...) end, "GET" )
end

function MultiplayerMainScreen:UpdateMOTD()
	if SHOW_MOTD then
		TheSim:GetPersistentString("motd_image", function(...) self:OnCachedMOTDLoad(...) end)
	else
		self.motd:Hide()
	end
end


function MultiplayerMainScreen:CheckNewUser(onnofn, no_button_text)
    if Profile:SawNewUserPopup() then
        return false
    end

    local popup = PopupDialogScreen(
        STRINGS.UI.MAINSCREEN.NEWUSER_DETECTED_HEADER,
        STRINGS.UI.MAINSCREEN.NEWUSER_DETECTED_BODY,
        {
            {
                text = STRINGS.UI.MAINSCREEN.NEWUSER_YES,
                cb = function()
                    TheFrontEnd:PopScreen()
                    Profile:ShowedNewUserPopup()
                    self:OnCreateServerButton()
                end,
            },
            {
                text = no_button_text,
                cb = function()
                    TheFrontEnd:PopScreen()
                    Profile:ShowedNewUserPopup()
                    onnofn(self)
                end,
            },
        }
    )

    TheFrontEnd:PushScreen(popup)
    return true
end

return MultiplayerMainScreen
