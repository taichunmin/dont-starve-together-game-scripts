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
local FestivalEventScreen = require "screens/redux/festivaleventscreen"
local ModsScreen = require "screens/redux/modsscreen"
local OptionsScreen = require "screens/redux/optionsscreen"
local PlayerSummaryScreen = require "screens/redux/playersummaryscreen"
local QuickJoinScreen = require "screens/redux/quickjoinscreen"
local ServerListingScreen = require "screens/redux/serverlistingscreen"
local ServerCreationScreen = require "screens/redux/servercreationscreen"

local TEMPLATES = require "widgets/redux/templates"

local FriendsManager = require "widgets/friendsmanager"
local OnlineStatus = require "widgets/onlinestatus"
local ThankYouPopup = require "screens/thankyoupopup"
local SkinGifts = require("skin_gifts")
local Stats = require("stats")

local MainMenuMotdPanel = require "widgets/redux/mainmenu_motdpanel"
local MainMenuStatsPanel = require "widgets/redux/mainmenu_statspanel"
local PurchasePackScreen = require "screens/redux/purchasepackscreen"

local SHOW_DST_DEBUG_HOST_JOIN = BRANCH == "dev"
local SHOW_QUICKJOIN = false

local function PlayBannerSound(inst, self, sound)
    if self.bannersoundsenabled then
        TheFrontEnd:GetSound():PlaySound(sound)
    end
end

function MakeBanner(self)
	local banner_height = 350

	local baner_root = Widget("banner_root")
	baner_root:SetPosition(0, RESOLUTION_Y / 2 - banner_height / 2 + 1 )

	local anim = baner_root:AddChild(UIAnim())
	
	if IsFestivalEventActive(FESTIVAL_EVENTS.LAVAARENA) then
		anim:GetAnimState():SetBuild("dst_menu_lavaarena_s2")
		anim:GetAnimState():SetBank("dst_menu_lavaarena_s2")
		anim:GetAnimState():PlayAnimation("idle", true)
		anim:SetScale(0.48)
		anim:SetPosition(0, -160)
	elseif IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
		anim:GetAnimState():SetBuild("dst_menu_halloween")
		anim:GetAnimState():SetBank("dst_menu_halloween")
		anim:GetAnimState():PlayAnimation("anim", true)
		anim:SetScale(0.67)
		anim:SetPosition(183, 40)
	elseif IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
		local anim_bg = baner_root:AddChild(UIAnim())
		anim_bg:GetAnimState():SetBuild("dst_menu_feast_bg")
		anim_bg:GetAnimState():SetBank("dst_menu_bg")
		anim_bg:SetScale(0.7)
		anim_bg:GetAnimState():SetDeltaTimeMultiplier(1.6)
		anim_bg:GetAnimState():PlayAnimation("loop", true)
		anim_bg:MoveToBack()
        
		anim:GetAnimState():SetBuild("dst_menu_feast")
		anim:GetAnimState():SetBank("dst_menu")
		anim:SetScale(0.7)
		anim:GetAnimState():PlayAnimation("loop", true)
	elseif IsSpecialEventActive(SPECIAL_EVENTS.YOTP) then
		local anim_bg = baner_root:AddChild(UIAnim())
		anim_bg:GetAnimState():SetBuild("dst_menu_pig_bg")
		anim_bg:GetAnimState():SetBank("dst_menu_pig_bg")
		anim_bg:SetScale(0.7)
		anim_bg:GetAnimState():PlayAnimation("loop", true)
		anim_bg:MoveToBack()
        
		anim:GetAnimState():SetBuild("dst_menu_pigs")
		anim:GetAnimState():SetBank("dst_menu_pigs")
		anim:SetScale(2/3)

        local function onanimover(inst)
            inst.AnimState:PlayAnimation("loop")

            inst:DoTaskInTime(94 * FRAMES, PlayBannerSound, self, "dontstarve/pig/pig_king_laugh")
            inst:DoTaskInTime(102 * FRAMES, PlayBannerSound, self, "dontstarve/pig/pig_king_laugh")
            inst:DoTaskInTime(109 * FRAMES, PlayBannerSound, self, "dontstarve/pig/pig_king_laugh")
            inst:DoTaskInTime(118 * FRAMES, PlayBannerSound, self, "dontstarve/pig/pig_king_laugh")

            inst:DoTaskInTime(32 * FRAMES, PlayBannerSound, self, "dontstarve/pig/come_at_me")
            inst:DoTaskInTime(40 * FRAMES, PlayBannerSound, self, "dontstarve/pig/come_at_me")
            inst:DoTaskInTime(151 * FRAMES, PlayBannerSound, self, "dontstarve/pig/come_at_me")
            inst:DoTaskInTime(161 * FRAMES, PlayBannerSound, self, "dontstarve/pig/come_at_me")
        end
        anim.inst:ListenForEvent("animover", onanimover)
        onanimover(anim.inst)
	elseif true then
		-- beta banner
		anim:GetAnimState():SetBuild("dst_menu_lunacy")
        anim:GetAnimState():SetBank("dst_menu_lunacy")
        anim:GetAnimState():PlayAnimation("loop", true)
        anim:SetScale(.667)
        anim:SetPosition(0, 0)
	else
		--[[anim:GetAnimState():SetBuild("dst_menu")
		anim:GetAnimState():SetBank("dst_menu")
		anim:GetAnimState():PlayAnimation("loop", true)
		anim:SetScale(0.63)
		anim:SetPosition(347, 85)]]
        --[[anim:GetAnimState():SetBuild("dst_menu_winona")
        anim:GetAnimState():SetBank("dst_menu_winona")
        anim:GetAnimState():PlayAnimation("loop", true)
        anim:SetScale(0.475)
        anim:SetPosition(327, -17)]]
        --[[anim:GetAnimState():SetBuild("dst_menu_wortox")
        anim:GetAnimState():SetBank("dst_menu_wortox")
        anim:GetAnimState():PlayAnimation("loop", true)
        anim:SetScale(.667)
        anim:SetPosition(0, 0)]]
        --[[anim:GetAnimState():SetBuild("dst_menu_willow")
        anim:GetAnimState():SetBank("dst_menu_willow")
        anim:GetAnimState():PlayAnimation("loop", true)
        anim:SetScale(.667)
        anim:SetPosition(0, 0)]]
        --[[anim:GetAnimState():SetBuild("dst_menu_wormwood")
        anim:GetAnimState():SetBank("dst_menu_wormwood")
        anim:GetAnimState():PlayAnimation("loop", true)
        anim:SetScale(.667)
        anim:SetPosition(0, 0)]]
        anim:GetAnimState():SetBuild("dst_menu_warly")
        anim:GetAnimState():SetBank("dst_menu_warly")
        anim:GetAnimState():PlayAnimation("loop", true)
        anim:SetScale(.667)
        anim:SetPosition(0, 0)
	end

	if IsFestivalEventActive(FESTIVAL_EVENTS.LAVAARENA) then
		self.logo = baner_root:AddChild(Image("images/lavaarena_frontend.xml", "title.tex"))
		self.logo:SetScale(.6)
		self.logo:SetPosition( -RESOLUTION_X/2 + 180, 5)
	else
		self.logo = baner_root:AddChild(Image("images/frontscreen.xml", "title.tex"))
		self.logo:SetScale(.36)
		self.logo:SetPosition( -RESOLUTION_X/2 + 180, 5)
		self.logo:SetTint(unpack(FRONTEND_TITLE_COLOUR))
	end
	
--[[
	local title_str = STRINGS.UI.MAINSCREEN.MAINBANNER_ROT_BETA_TITLE
	if title_str ~= nil then
		local x = 165
		local y = -140
		local text_width = 880

		local font_size = 22
		local title = baner_root:AddChild(Text(self.info_font, font_size, title_str, UICOLOURS.HIGHLIGHT_GOLD))
		title:SetRegionSize(text_width, font_size + 2)
		title:SetHAlign(ANCHOR_RIGHT)
		title:SetPosition(x, y + 4)

		local shadow = baner_root:AddChild(Text(self.info_font, font_size, title_str, UICOLOURS.BLACK))
		shadow:SetRegionSize(text_width, font_size + 2)
		shadow:SetHAlign(ANCHOR_RIGHT)
		shadow:SetPosition(x + 1.5, y - 1.5)
		shadow:MoveToBack()
	end
]]

	return baner_root
end

local MultiplayerMainScreen = Class(Screen, function(self, prev_screen, profile, offline, session_data)
	Screen._ctor(self, "MultiplayerMainScreen")

	self.info_font = BODYTEXTFONT -- CHATFONT, FALLBACK_FONT, CHATFONT_OUTLINE


    self.profile = profile
    self.offline = offline
    self.session_data = session_data
	self.log = true
    self.prev_screen = prev_screen
	self:DoInit()
	self.default_focus = self.menu
end)

function MultiplayerMainScreen:GotoShop( filter_info )
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
		self:_FadeToScreen(PurchasePackScreen, {Profile, filter_info})
	end
end


function MultiplayerMainScreen:getStatsPanel()
    return MainMenuStatsPanel({store_cb = function()
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
            self:_FadeToScreen(PurchasePackScreen, {Profile})
        end
    end
    })
end
function MultiplayerMainScreen:DoInit()
    self.fixed_root = self:AddChild(Widget("root"))
    self.fixed_root:SetVAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetHAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.letterbox = self:AddChild(TEMPLATES.old.ForegroundLetterbox())

	self.banner_root = self.fixed_root:AddChild(MakeBanner(self))

	local bg = self.fixed_root:AddChild(Image("images/bg_redux_dark_bottom_solid.xml", "dark_bottom_solid.tex"))
	bg:SetScale(.669)
	bg:SetPosition(0, -160)
	bg:SetClickable(false)

	-- new MOTD
	if TheFrontEnd.MotdManager:IsEnabled() then
		local info_panel = MainMenuMotdPanel({font = self.info_font, bg = bg, 
			error_cb = function() 
				if self.info_panel ~= nil then
					self.info_panel:Kill() 
				end
				self.info_panel = self.fixed_root:AddChild(self:getStatsPanel())
			end,
			on_to_skins_cb = function( filter_info ) self:GotoShop( filter_info ) end,
			})
		if self.info_panel == nil then
			self.info_panel = self.fixed_root:AddChild(info_panel)
		end
	else
		self.info_panel = self.fixed_root:AddChild(self:getStatsPanel())
	end

    if IsAnyFestivalEventActive() then        
        if not TheFrontEnd:GetIsOfflineMode() then
			self.userprogress = self.fixed_root:AddChild(TEMPLATES.UserProgress(function()
				self:OnPlayerSummaryButton()
			end))
		end
    end
	
	self.fixed_root:AddChild(Widget("left"))
    
    self:MakeMainMenu()
	self:MakeSubMenu()

    self.onlinestatus = self.fixed_root:AddChild(OnlineStatus( true ))

	if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
		self.banner_snowfall = self.banner_root:AddChild(TEMPLATES.old.Snowfall(-.39 * RESOLUTION_Y, .35, 3, 15))
		self.banner_snowfall:SetVAnchor(ANCHOR_TOP)
		self.banner_snowfall:SetHAnchor(ANCHOR_MIDDLE)
		self.banner_snowfall:SetScaleMode(SCALEMODE_PROPORTIONAL)

		self.snowfall = self.fixed_root:AddChild(TEMPLATES.old.Snowfall(-.97 * RESOLUTION_Y, .15, 5, 20))
		self.snowfall:SetVAnchor(ANCHOR_TOP)
		self.snowfall:SetHAnchor(ANCHOR_MIDDLE)
		self.snowfall:SetScaleMode(SCALEMODE_PROPORTIONAL)
	end

    ----------------------------------------------------------

	self:DoFocusHookups()
    self.menu:SetFocus(#self.menu.items)

    --V2C: This is so the first time we become active will trigger OnShow to UpdatePuppets
    self:Hide()
end

function MultiplayerMainScreen:DoFocusHookups()
    --focus moving
    self.submenu:SetFocusChangeDir(MOVE_UP, self.menu.items[1])
    self.menu:SetFocusChangeDir(MOVE_DOWN, self.submenu)

    if self.debug_menu then
        self.menu:SetFocusChangeDir(MOVE_UP, self.debug_menu, -1)
        self.menu:SetFocusChangeDir(MOVE_RIGHT, self.debug_menu, -1)
        self.debug_menu:SetFocusChangeDir(MOVE_LEFT, self.menu)
    end

	self.menu:SetFocusChangeDir(MOVE_RIGHT, self.info_panel)
	self.info_panel:SetFocusChangeDir(MOVE_LEFT, self.menu)
end

function MultiplayerMainScreen:EnableBannerSounds(enable)
    self.bannersoundsenabled = enable
end

function MultiplayerMainScreen:OnShow()
    self._base.OnShow(self)
    if self.snowfall ~= nil then
        self.snowfall:EnableSnowfall(not (TheSim:IsNetbookMode() or TheFrontEnd:GetGraphicsOptions():IsSmallTexturesMode()))
        self.snowfall:StartSnowfall()
    end
    if self.banner_snowfall ~= nil then
        self.banner_snowfall:EnableSnowfall(not (TheSim:IsNetbookMode() or TheFrontEnd:GetGraphicsOptions():IsSmallTexturesMode()))
        self.banner_snowfall:StartSnowfall()
    end
    self:EnableBannerSounds(true)

    TheSim:PauseFileExistsAsync(false)
end

function MultiplayerMainScreen:OnHide()
    self._base.OnHide(self)
    if self.snowfall ~= nil then
        self.snowfall:StopSnowfall()
    end
    if self.banner_snowfall ~= nil then
        self.banner_snowfall:StopSnowfall()
    end
    self:EnableBannerSounds(false)
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
--V2C: Peter: Currently only "screens with their own music" transitions use these music helpers

function MultiplayerMainScreen:StopMusic()
    if not self.musicstopped then
        self.musicstopped = true
        TheFrontEnd:GetSound():KillSound("FEMusic")
        --TheFrontEnd:GetSound():KillSound("FEPortalSFX")
    elseif self.musictask ~= nil then
        self.musictask:Cancel()
        self.musictask = nil
    end
end

local function OnStartMusic(inst, self)
    self.musictask = nil
    self.musicstopped = false
    TheFrontEnd:GetSound():PlaySound(FE_MUSIC, "FEMusic")
    --TheFrontEnd:GetSound():PlaySound("dontstarve/together_FE/portal_idle_vines", "FEPortalSFX")
end

function MultiplayerMainScreen:StartMusic()
    TheFrontEnd:GetSound():SetParameter("FEMusic", "fade", 0)
    if self.musicstopped and self.musictask == nil then
        self.musictask = self.inst:DoTaskInTime(1.25, OnStartMusic, self)
    end
end

--------------------------------------------------------------------------------
function MultiplayerMainScreen:_GoToFestfivalEventScreen(fadeout_cb)
    if GetFestivalEventInfo().FEMUSIC ~= nil then
        self:StopMusic() --only stop the main menu music if we have something for the next screeen
    end
	
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
        TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_TITLE, STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_BODY[WORLD_FESTIVAL_EVENT], 
            {
                {text=STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_LOGIN, cb = function()
                        SimReset()
                    end},
                {text=STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_BACK, cb=function() TheFrontEnd:PopScreen() end },
            }))
    else
		if AreAnyModsEnabled() and not KnownModIndex:GetIsSpecialEventModWarningDisabled() then
			local popup_body = subfmt(STRINGS.UI.FESTIVALEVENTSCREEN.MODS_POPUP_BODY, {event=STRINGS.UI.GAMEMODES[string.upper(GetFestivalEventInfo().GAME_MODE)]})
			TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.FESTIVALEVENTSCREEN.MODS_POPUP_TITLE, popup_body, 
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
    self:_FadeToScreen(OptionsScreen, {self})
end

function MultiplayerMainScreen:OnModsButton()
    self:_FadeToScreen(ModsScreen, {})
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
    self.menu_root:SetPosition(0,-95)

--    self.tooltip = self.menu_root:AddChild(TEMPLATES.ScreenTooltip())
--    self.tooltip:SetPosition( -(RESOLUTION_X*.5)+220, -(RESOLUTION_Y*.5)+157 )
--    self.tooltip:SetRegionSize(300,100)

    local function MakeMainMenuButton(text, onclick, tooltip_text, tooltip_widget)
        local btn = TEMPLATES.MenuButton(text, onclick, tooltip_text, tooltip_widget)
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

	if IsConsole() then
		local shop_button = MakeMainMenuButton(STRINGS.UI.PLAYERSUMMARYSCREEN.PURCHASE, function() self:GotoShop() end, STRINGS.UI.PLAYERSUMMARYSCREEN.TOOLTIP_PURCHASE, self.tooltip)
		table.insert(menu_items, 2, {widget = shop_button})
	end

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
		self.debug_menu:SetPosition(-450, 250)
		self.debug_menu:SetScale(.8)
    end
end

function MultiplayerMainScreen:MakeSubMenu()
    local submenuitems = {}

    if IsSteam() or IsRail() then
		if not IsLinux() then
			table.insert(submenuitems, {widget = TEMPLATES.IconButton("images/button_icons.xml", "folder.tex", STRINGS.UI.MAINSCREEN.SAVE_LOCATION, false, true, function() TheSim:OpenDocumentsFolder() end, {font=NEWFONT_OUTLINE})})
		end

        if TheFrontEnd:GetAccountManager():HasSteamTicket() then
            table.insert(submenuitems, {widget = TEMPLATES.IconButton("images/button_icons.xml", "profile.tex", STRINGS.UI.SERVERCREATIONSCREEN.MANAGE_ACCOUNT, false, true, function() VisitURL( TheFrontEnd:GetAccountManager():GetAccountURL(), true ) end, {font=NEWFONT_OUTLINE})})
        end

		if not IsRail() then
			table.insert(submenuitems, {widget = TEMPLATES.IconButton("images/button_icons.xml", "forums.tex", STRINGS.UI.MAINSCREEN.FORUM, false, true, function() VisitURL("http://forums.kleientertainment.com/forums/forum/73-dont-starve-together/") end, {font=NEWFONT_OUTLINE})})
	        table.insert(submenuitems, {widget = TEMPLATES.IconButton("images/button_icons.xml", "more_games.tex", STRINGS.UI.MAINSCREEN.MOREGAMES, false, true, function() VisitURL("http://store.steampowered.com/search/?developer=Klei%20Entertainment") end, {font=NEWFONT_OUTLINE})})
		end
    end

    self.submenu = self.fixed_root:AddChild(Menu(submenuitems, 75, true))
    self.submenu:SetPosition( -RESOLUTION_X*.5 + 90, -(RESOLUTION_Y*.5)+85, 0)
    self.submenu:SetScale(.8)
end

function MultiplayerMainScreen:OnBecomeActive()
    MultiplayerMainScreen._base.OnBecomeActive(self)

    ValidateItemsInProfile(Profile)

    if self.leaving and self.userprogress then
        -- Maybe have returned from collection with new icon or from game with  more xp.
        self.userprogress:UpdateProgress()
    end

    if not self.shown then
        self:Show()
    end

    local friendsmanager = self:AddChild(FriendsManager())
    friendsmanager:SetHAnchor(ANCHOR_RIGHT)
    friendsmanager:SetVAnchor(ANCHOR_BOTTOM)
    friendsmanager:SetScaleMode(SCALEMODE_PROPORTIONAL)

	if self.last_focus_widget then
		self.menu:RestoreFocusTo(self.last_focus_widget)
	end

    if self.debug_menu then self.debug_menu:Enable() end

    self.leaving = nil

    self:StartMusic()

    --start a new query everytime we go back to the mainmenu
	if TheSim:IsLoggedOn() then
		TheSim:StartWorkshopQuery()
	end

	if self.info_panel ~= nil and self.info_panel.OnBecomeActive ~= nil then
		self.info_panel:OnBecomeActive()
	end

    --delay for a frame to allow the screen to finish building, then check the entity count for leaks
    self.inst:DoTaskInTime(0, function()
        if self.cached_entity_count ~= nil and self.cached_entity_count ~= TheSim:GetNumberOfEntities() then
            print("### Error: Leaked entities in the frontend.", self.cached_entity_count)
            for k, v in pairs(Ents) do if v.widget and (not v:IsValid() or v.widget.parent == nil) then
                print(k, v.widget.name, v:IsValid(), v.widget.parent ~= nil, v) end
            end
        end
        self.cached_entity_count = TheSim:GetNumberOfEntities()
    end)
end

function MultiplayerMainScreen:FinishedFadeIn()
    if HasNewSkinDLCEntitlements() then
        if IsSteam() then
            local popup_screen = PopupDialogScreen( STRINGS.UI.PURCHASEPACKSCREEN.GIFT_RECEIVED_TITLE, STRINGS.UI.PURCHASEPACKSCREEN.GIFT_RECEIVED_BODY,
                    {
                        { text=STRINGS.UI.PURCHASEPACKSCREEN.OK, cb = function()
                                TheFrontEnd:PopScreen()
                                MakeSkinDLCPopup( function() self:FinishedFadeIn() end )
                            end
                        },
                    }
                )

            TheFrontEnd:PushScreen( popup_screen )
        else
            MakeSkinDLCPopup( function() self:FinishedFadeIn() end )
        end
    else
		--Do new entitlement items
		local items = {}
		local entitlement_items = TheInventory:GetUnopenedEntitlementItems()
		for _,item in pairs(entitlement_items) do
			table.insert(items, { item = item.item_type, item_id = item.item_id, gifttype = SkinGifts.types[item.item_type] or "DEFAULT" })
        end
        
        local daily_gift = GetDailyGiftItem()
        if daily_gift then
            table.insert(items, { item = daily_gift, item_id = 0, gifttype = "DAILY_GIFT" })
        end
	
		if #items > 0 then
			local thankyou_popup = ThankYouPopup(items)
			TheFrontEnd:PushScreen(thankyou_popup)
		else
            if IsConsole() or IsSteam() then
			    --Make sure we only do one mainscreen popup at a time
			    --Do language assistance popup
			    local interface_lang = TheNet:GetLanguageCode()
			    if interface_lang ~= "english" then
                    if Profile:GetValue("language_asked_"..interface_lang) ~= true then
                        local lang_id = LANGUAGE_STEAMCODE_TO_ID[interface_lang]
                        local locale = LOC.GetLocale(lang_id)
                        if locale ~= nil then
                            local show_dialog = false
                            if IsConsole() then
                                show_dialog = locale.in_console_menu
                            elseif IsSteam() then
                                show_dialog = locale.in_steam_menu
                            end

                            if show_dialog then
                                local popup_screen = PopupDialogScreen( STRINGS.PRETRANSLATED.LANGUAGES_TITLE[locale.id], STRINGS.PRETRANSLATED.LANGUAGES_BODY[locale.id],
                                        {
                                            { text = STRINGS.PRETRANSLATED.LANGUAGES_YES[locale.id], cb = function() Profile:SetLanguageID(lang_id, function() SimReset() end ) end },
                                            { text = STRINGS.PRETRANSLATED.LANGUAGES_NO[locale.id], cb = function() TheFrontEnd:PopScreen() end}
                                        }
                                    )
                                TheFrontEnd:PushScreen( popup_screen )
                                Profile:SetValue("language_asked_"..interface_lang, true)
                                Profile:Save()
                            end
                        end
                    end
			    end
            end
		end
	end
end


function MultiplayerMainScreen:OnUpdate(dt)
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
