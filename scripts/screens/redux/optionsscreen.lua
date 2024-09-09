require "util"
require "strings"
require "constants"

local Screen = require "widgets/screen"
local Subscreener = require "screens/redux/subscreener"
local ImageButton = require "widgets/imagebutton"
local Menu = require "widgets/menu"
local Grid = require "widgets/grid"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local ScrollableList = require "widgets/scrollablelist"
local PopupDialogScreen = require "screens/redux/popupdialog"
local OnlineStatus = require "widgets/onlinestatus"
local TEMPLATES = require "widgets/redux/templates"
local ModsScreen = require "screens/redux/modsscreen"

local KitcoonPuppet = require "widgets/kitcoonpuppet"

local DEVICE_DUALSHOCK4 = 2
local DEVICE_VITA = 3
local DEVICE_XBONE = 7
local DEVICE_SWITCH = 8

local controls_ui = {
    action_label_width = 375,
    action_btn_width = 250,
    action_height = 48,
}
local show_graphics = PLATFORM ~= "NACL" and IsNotConsole() and not IsSteamDeck() 

--Note(Peter) if you want to change dev_test_platform to another platform, you will need to uncomment the matching images in frontend.lua, look for dev_test_platform
local dev_test_platform = PLATFORM --"XBONE"
local PLATFORM_LAYOUT = (BRANCH == "dev" and PLATFORM == "WIN32_STEAM") and dev_test_platform or PLATFORM
local IsConsoleLayout = (BRANCH == "dev" and PLATFORM == "WIN32_STEAM") 
	and function ()
		return dev_test_platform == "PS4" or dev_test_platform == "XBONE" or dev_test_platform == "SWITCH"
	end
	or function ()
		return IsConsole()
	end

local enableDisableOptions = { { text = STRINGS.UI.OPTIONS.DISABLED, data = false }, { text = STRINGS.UI.OPTIONS.ENABLED, data = true } }
local invertDisableOptions = { { text = STRINGS.UI.OPTIONS.DEFAULT, data = false }, { text = STRINGS.UI.OPTIONS.INVERT, data = true } }
local craftingHintOptions = { { text = STRINGS.UI.OPTIONS.DEFAULT, data = false }, { text = STRINGS.UI.OPTIONS.CRAFTING_HINTALL_ENABLED, data = true } }
local steamCloudLocalOptions = { { text = STRINGS.UI.OPTIONS.LOCAL_SAVES, data = false }, { text = STRINGS.UI.OPTIONS.STEAM_CLOUD_SAVES, data = true } }
local integratedbackpackOptions = { { text = STRINGS.UI.OPTIONS.INTEGRATEDBACKPACK_DISABLED, data = false }, { text = STRINGS.UI.OPTIONS.INTEGRATEDBACKPACK_ENABLED, data = true } }
local enableScreenFlashOptions = { { text = STRINGS.UI.OPTIONS.DEFAULT, data = 1 }, { text = STRINGS.UI.OPTIONS.DIM, data = 2 } , { text = STRINGS.UI.OPTIONS.DIMMEST, data = 3 } }
local distortionLevelOptions = { 
	{ text = STRINGS.UI.OPTIONS.DISABLED, data = 0 },
	{ text = STRINGS.UI.OPTIONS.FAINT, data = 0.25 },
	{ text = STRINGS.UI.OPTIONS.WEAK, data = 0.5 },
	{ text = STRINGS.UI.OPTIONS.STRONG, data = 0.75 },
	{ text = STRINGS.UI.OPTIONS.MAX, data = 1 }
}

local loadingtipsOptions =
{
	{ text = STRINGS.UI.OPTIONS.LOADING_TIPS_SHOW_ALL, data = LOADING_SCREEN_TIP_OPTIONS.ALL },
	{ text = STRINGS.UI.OPTIONS.LOADING_TIPS_TIPS_ONLY, data = LOADING_SCREEN_TIP_OPTIONS.TIPS_ONLY },
	{ text = STRINGS.UI.OPTIONS.LOADING_TIPS_LORE_ONLY, data = LOADING_SCREEN_TIP_OPTIONS.LORE_ONLY },
	{ text = STRINGS.UI.OPTIONS.LOADING_TIPS_SHOW_NONE, data = LOADING_SCREEN_TIP_OPTIONS.NONE },
}

local npcChatOptions = -- NPC Chat messages with priorities >= these values will be shown in the chat history.
{
	{ text = STRINGS.UI.OPTIONS.NPCCHAT_ALL,	data = CHATPRIORITIES.LOW },
	{ text = STRINGS.UI.OPTIONS.NPCCHAT_SOME,	data = CHATPRIORITIES.HIGH },
	{ text = STRINGS.UI.OPTIONS.NPCCHAT_NONE,	data = CHATPRIORITIES.MAX },
}

local function FindEnableScreenFlashOptionsIndex(value)
    for i = 1, #enableScreenFlashOptions do
		if enableScreenFlashOptions[i].data == value then
			return i
		end
	end
	return 1
end

local function FindDistortionLevelOptionsIndex(value)
    for i = 1, #distortionLevelOptions do
		if distortionLevelOptions[i].data == value then
			return i
		end
	end
	return 4
end

local function FindNPCChatOptionsIndex(value)
    for i = 1, #npcChatOptions do
		if npcChatOptions[i].data == value then
			return i
		end
	end
	return 1
end

local all_controls =
{
    -- mouse
    {name=CONTROL_PRIMARY, keyboard=CONTROL_PRIMARY, controller=nil},
    {name=CONTROL_SECONDARY, keyboard=CONTROL_SECONDARY, controller=nil},

    -- actions
    {name=CONTROL_CONTROLLER_ACTION, keyboard=CONTROL_ACTION, controller=CONTROL_CONTROLLER_ACTION},
    {name=CONTROL_CONTROLLER_ATTACK, keyboard=CONTROL_ATTACK, controller=CONTROL_CONTROLLER_ATTACK},
    {name=CONTROL_FORCE_INSPECT, keyboard=CONTROL_FORCE_INSPECT, controller=nil},
    {name=CONTROL_FORCE_ATTACK, keyboard=CONTROL_FORCE_ATTACK, controller=nil},
    {name=CONTROL_CONTROLLER_ALTACTION, keyboard=nil, controller=CONTROL_CONTROLLER_ALTACTION},
    {name=CONTROL_INSPECT, keyboard=nil, controller=CONTROL_INSPECT},

    -- movement
    {name=CONTROL_MOVE_UP, keyboard=CONTROL_MOVE_UP, controller=CONTROL_MOVE_UP},
    {name=CONTROL_MOVE_DOWN, keyboard=CONTROL_MOVE_DOWN, controller=CONTROL_MOVE_DOWN},
    {name=CONTROL_MOVE_LEFT, keyboard=CONTROL_MOVE_LEFT, controller=CONTROL_MOVE_LEFT},
    {name=CONTROL_MOVE_RIGHT, keyboard=CONTROL_MOVE_RIGHT, controller=CONTROL_MOVE_RIGHT},

    -- view
    {name=CONTROL_MAP, keyboard=CONTROL_MAP, controller=CONTROL_MAP},
    {name=CONTROL_MAP_ZOOM_IN, keyboard=CONTROL_MAP_ZOOM_IN, controller=CONTROL_MAP_ZOOM_IN},
    {name=CONTROL_MAP_ZOOM_OUT, keyboard=CONTROL_MAP_ZOOM_OUT, controller=CONTROL_MAP_ZOOM_OUT},
    {name=CONTROL_ROTATE_LEFT, keyboard=CONTROL_ROTATE_LEFT, controller=CONTROL_ROTATE_LEFT},
    {name=CONTROL_ROTATE_RIGHT, keyboard=CONTROL_ROTATE_RIGHT, controller=CONTROL_ROTATE_RIGHT},
    {name=CONTROL_ZOOM_IN, keyboard=CONTROL_ZOOM_IN, controller=CONTROL_ZOOM_IN},
    {name=CONTROL_ZOOM_OUT, keyboard=CONTROL_ZOOM_OUT, controller=CONTROL_ZOOM_OUT},

    -- communication
    {name=CONTROL_TOGGLE_SAY, keyboard=CONTROL_TOGGLE_SAY, controller=CONTROL_TOGGLE_SAY},
    {name=CONTROL_TOGGLE_WHISPER, keyboard=CONTROL_TOGGLE_WHISPER, controller=CONTROL_TOGGLE_WHISPER},
    {name=CONTROL_SHOW_PLAYER_STATUS, keyboard=CONTROL_SHOW_PLAYER_STATUS, controller=CONTROL_TOGGLE_PLAYER_STATUS},
    {name=CONTROL_PAUSE, keyboard=CONTROL_PAUSE, controller=CONTROL_PAUSE},
	{name=CONTROL_SERVER_PAUSE, keyboard=CONTROL_SERVER_PAUSE, controller=nil},
    {name=CONTROL_INSPECT_SELF, keyboard=CONTROL_INSPECT_SELF, controller=nil},

    -- inventory
    {name=CONTROL_OPEN_CRAFTING, keyboard=CONTROL_OPEN_CRAFTING, controller=CONTROL_OPEN_CRAFTING},
    {name=CONTROL_CRAFTING_MODIFIER, keyboard=CONTROL_CRAFTING_MODIFIER, controller=nil},
    {name=CONTROL_CRAFTING_PINLEFT, keyboard=CONTROL_CRAFTING_PINLEFT, controller=nil},
    {name=CONTROL_CRAFTING_PINRIGHT, keyboard=CONTROL_CRAFTING_PINRIGHT, controller=nil},
    {name=CONTROL_OPEN_INVENTORY, keyboard=nil, controller=CONTROL_OPEN_INVENTORY},
    {name=CONTROL_INVENTORY_UP, keyboard=nil, controller=CONTROL_INVENTORY_UP},
    {name=CONTROL_INVENTORY_DOWN, keyboard=nil, controller=CONTROL_INVENTORY_DOWN},
    {name=CONTROL_INVENTORY_LEFT, keyboard=nil, controller=CONTROL_INVENTORY_LEFT},
    {name=CONTROL_INVENTORY_RIGHT, keyboard=nil, controller=CONTROL_INVENTORY_RIGHT},
    {name=CONTROL_INVENTORY_EXAMINE, keyboard=nil, controller=CONTROL_INVENTORY_EXAMINE},
    {name=CONTROL_INVENTORY_USEONSELF, keyboard=nil, controller=CONTROL_INVENTORY_USEONSELF},
    {name=CONTROL_INVENTORY_USEONSCENE, keyboard=nil, controller=CONTROL_INVENTORY_USEONSCENE},
    {name=CONTROL_INVENTORY_DROP, keyboard=nil, controller=CONTROL_INVENTORY_DROP},
    {name=CONTROL_PUTSTACK, keyboard=nil, controller=CONTROL_PUTSTACK},
    {name=CONTROL_USE_ITEM_ON_ITEM, keyboard=nil, controller=CONTROL_USE_ITEM_ON_ITEM},
    {name=CONTROL_SPLITSTACK, keyboard=CONTROL_SPLITSTACK, controller=nil},
    {name=CONTROL_TRADEITEM, keyboard=CONTROL_TRADEITEM, controller=nil},
    --{name=CONTROL_TRADESTACK, keyboard=CONTROL_TRADESTACK, controller=nil},
    {name=CONTROL_FORCE_TRADE, keyboard=CONTROL_FORCE_TRADE, controller=nil},
    {name=CONTROL_FORCE_STACK, keyboard=CONTROL_FORCE_STACK, controller=nil},
    {name=CONTROL_INV_1, keyboard=CONTROL_INV_1, controller=nil},
    {name=CONTROL_INV_2, keyboard=CONTROL_INV_2, controller=nil},
    {name=CONTROL_INV_3, keyboard=CONTROL_INV_3, controller=nil},
    {name=CONTROL_INV_4, keyboard=CONTROL_INV_4, controller=nil},
    {name=CONTROL_INV_5, keyboard=CONTROL_INV_5, controller=nil},
    {name=CONTROL_INV_6, keyboard=CONTROL_INV_6, controller=nil},
    {name=CONTROL_INV_7, keyboard=CONTROL_INV_7, controller=nil},
    {name=CONTROL_INV_8, keyboard=CONTROL_INV_8, controller=nil},
    {name=CONTROL_INV_9, keyboard=CONTROL_INV_9, controller=nil},
    {name=CONTROL_INV_10, keyboard=CONTROL_INV_10, controller=nil},
    {name=CONTROL_INV_11, keyboard=CONTROL_INV_11, controller=nil},
    {name=CONTROL_INV_12, keyboard=CONTROL_INV_12, controller=nil},
    {name=CONTROL_INV_13, keyboard=CONTROL_INV_13, controller=nil},
    {name=CONTROL_INV_14, keyboard=CONTROL_INV_14, controller=nil},
    {name=CONTROL_INV_15, keyboard=CONTROL_INV_15, controller=nil},

    -- menu
    {name=CONTROL_ACCEPT, keyboard=CONTROL_ACCEPT, controller=CONTROL_ACCEPT},
    {name=CONTROL_CANCEL, keyboard=CONTROL_CANCEL, controller=CONTROL_CANCEL},
    {name=CONTROL_FOCUS_UP, keyboard=CONTROL_FOCUS_UP, controller=CONTROL_FOCUS_UP},
    {name=CONTROL_FOCUS_DOWN, keyboard=CONTROL_FOCUS_DOWN, controller=CONTROL_FOCUS_DOWN},
    {name=CONTROL_FOCUS_LEFT, keyboard=CONTROL_FOCUS_LEFT, controller=CONTROL_FOCUS_LEFT},
    {name=CONTROL_FOCUS_RIGHT, keyboard=CONTROL_FOCUS_RIGHT, controller=CONTROL_FOCUS_RIGHT},
    {name=CONTROL_PREVVALUE, keyboard=CONTROL_PREVVALUE, controller=CONTROL_PREVVALUE},
    {name=CONTROL_NEXTVALUE, keyboard=CONTROL_NEXTVALUE, controller=CONTROL_NEXTVALUE},
    {name=CONTROL_SCROLLBACK, keyboard=CONTROL_SCROLLBACK, controller=CONTROL_SCROLLBACK},
    {name=CONTROL_SCROLLFWD, keyboard=CONTROL_SCROLLFWD, controller=CONTROL_SCROLLFWD},
    {name=CONTROL_MENU_MISC_1, keyboard=nil, controller=CONTROL_MENU_MISC_1},
    {name=CONTROL_MENU_MISC_2, keyboard=nil, controller=CONTROL_MENU_MISC_2},
    {name=CONTROL_MENU_MISC_3, keyboard=nil, controller=CONTROL_MENU_MISC_3},
    {name=CONTROL_MENU_MISC_4, keyboard=nil, controller=CONTROL_MENU_MISC_4},

    -- Chat based commands.
    {name=CONTROL_TOGGLE_SLASH_COMMAND, keyboard=CONTROL_TOGGLE_SLASH_COMMAND, controller=nil},
    {name=CONTROL_START_EMOJI, keyboard=CONTROL_START_EMOJI, controller=nil},

    -- Available debug commands.
    {name=CONTROL_OPEN_DEBUG_CONSOLE, keyboard=CONTROL_OPEN_DEBUG_CONSOLE, controller=nil},
    {name=CONTROL_TOGGLE_LOG, keyboard=CONTROL_TOGGLE_LOG, controller=nil},
    {name=CONTROL_TOGGLE_DEBUGRENDER, keyboard=CONTROL_TOGGLE_DEBUGRENDER, controller=nil},
}

local function GetResolutionString( w, h )
	--return string.format( "%dx%d @ %dHz", w, h, hz )
	return string.format( "%d x %d", w, h )
end

local function SortKey( data )
	local key = data.w * 16777216 + data.h * 65536-- + data.hz
	return key
end

local function ValidResolutionSorter( a, b )
	return SortKey( a.data ) < SortKey( b.data )
end

local function GetDisplays()
	local gOpts = TheFrontEnd:GetGraphicsOptions()
	local num_displays = gOpts:GetNumDisplays()
	local displays = {}
	for i = 0, num_displays - 1 do
		table.insert( displays, { text = STRINGS.UI.OPTIONS.DISPLAY.." "..i+1, data = i } )
	end

	return displays
end

local function GetRefreshRates( display_id, mode_idx )
	local gOpts = TheFrontEnd:GetGraphicsOptions()

	local w, h, hz = gOpts:GetDisplayMode( display_id, mode_idx )
	local num_refresh_rates = gOpts:GetNumRefreshRates( display_id, w, h )

	local refresh_rates = {}
	for i = 0, num_refresh_rates - 1 do
		local refresh_rate = gOpts:GetRefreshRate( display_id, w, h, i )
		table.insert( refresh_rates, { text = string.format( "%d", refresh_rate ), data = refresh_rate } )
	end

	return refresh_rates
end

local function GetDisplayModes( display_id )
	local gOpts = TheFrontEnd:GetGraphicsOptions()
	local num_modes = gOpts:GetNumDisplayModes( display_id )

	local res_data = {}
	for i = 0, num_modes - 1 do
		local w, h, hz = gOpts:GetDisplayMode( display_id, i )
		local res_str = GetResolutionString( w, h )
		res_data[ res_str ] = { w = w, h = h, hz = hz, idx = i }
	end

	local valid_resolutions = {}
	for res_str, data in pairs( res_data ) do
		table.insert( valid_resolutions, { text = res_str, data = data } )
	end

	table.sort( valid_resolutions, ValidResolutionSorter )

	local result = {}
	for k, v in pairs( valid_resolutions ) do
		table.insert( result, { text = v.text, data = v.data } )
	end

	return result
end

local function GetDisplayModeIdx( display_id, w, h, hz )
	local gOpts = TheFrontEnd:GetGraphicsOptions()
	local num_modes = gOpts:GetNumDisplayModes( display_id )

	for i = 0, num_modes - 1 do
		local tw, th, thz = gOpts:GetDisplayMode( display_id, i )
		if tw == w and th == h and thz == hz then
			return i
		end
	end

	return nil
end

local function GetDisplayModeInfo( display_id, mode_idx )
	local gOpts = TheFrontEnd:GetGraphicsOptions()
	local w, h, hz = gOpts:GetDisplayMode( display_id, mode_idx )

	return w, h, hz
end

local OptionsScreen = Class(Screen, function( self, prev_screen, default_section )
	Screen._ctor(self, "OptionsScreen")

    self.show_language_options = (prev_screen ~= nil and prev_screen.name == "MultiplayerMainScreen") and (IsConsole() or IsSteam())
	self.show_mod_language_options = (prev_screen ~= nil and prev_screen.name == "MultiplayerMainScreen") and IsSteam()
	self.show_datacollection = IsSteam() and not InGamePlay()

	local graphicsOptions = TheFrontEnd:GetGraphicsOptions()

	self.options = {
		fxvolume = TheMixer:GetLevel( "set_sfx" ) * 10,
		musicvolume = TheMixer:GetLevel( "set_music" ) * 10,
		ambientvolume = TheMixer:GetLevel( "set_ambience" ) * 10,
		bloom = PostProcessor:IsBloomEnabled(),
		smalltextures = graphicsOptions:GetSmallTexturesModeSettingValue(),
		screenflash = Profile:GetScreenFlash(),
		distortion_modifier = Profile:GetDistortionModifier(),
		screenshake = Profile:IsScreenShakeEnabled(),
		hudSize = Profile:GetHUDSize(),
		craftingmenusize = Profile:GetCraftingMenuSize(),
		craftingmenunumpinpages = Profile:GetCraftingNumPinnedPages(),
		craftingmenusensitivity = Profile:GetCraftingMenuSensitivity(),
		inventorysensitivity = Profile:GetInventorySensitivity(),
		minimapzoomsensitivity = Profile:GetMiniMapZoomSensitivity(),
		boathopdelay = Profile:GetBoatHopDelay(),
		netbookmode = TheSim:IsNetbookMode(),
		vibration = Profile:GetVibrationEnabled(),
		showpassword = Profile:GetShowPasswordEnabled(),
		profanityfilterservernames = Profile:GetProfanityFilterServerNamesEnabled(),
		profanityfilterchat = Profile:GetProfanityFilterChatEnabled(),
        movementprediction = Profile:GetMovementPredictionEnabled(),
		automods = Profile:GetAutoSubscribeModsEnabled(),
		autologin = Profile:GetAutoLoginEnabled(),
        npcchat = Profile:GetNPCChatLevel(),
		animatedheads = Profile:GetAnimatedHeadsEnabled(),
		wathgrithrfont = Profile:IsWathgrithrFontEnabled(),
		boatcamera = Profile:IsBoatCameraEnabled(),
		InvertCameraRotation = Profile:GetInvertCameraRotation(),
		integratedbackpack = Profile:GetIntegratedBackpack(),
        lang_id = Profile:GetLanguageID(),
		texturestreaming = Profile:GetTextureStreamingEnabled(),
		dynamictreeshadows = Profile:GetDynamicTreeShadowsEnabled(),
		autopause = Profile:GetAutopauseEnabled(),
		consoleautopause = Profile:GetConsoleAutopauseEnabled(),
		craftingautopause = Profile:GetCraftingAutopauseEnabled(),
		craftingmenubufferedbuildautoclose = Profile:GetCraftingMenuBufferedBuildAutoClose(),
		craftinghintallrecipes = Profile:GetCraftingHintAllRecipesEnabled(),
		waltercamera = Profile:IsCampfireStoryCameraEnabled(),
		minimapzoomcursor = Profile:IsMinimapZoomCursorFollowing(),
		loadingtips = Profile:GetLoadingTipsOption(),
		defaultcloudsaves = Profile:GetDefaultCloudSaves(),
		scrapbookhuddisplay = Profile:GetScrapbookHudDisplay(),
		poidisplay = Profile:GetPOIDisplay(),
	}

	if IsWin32() then
		self.options.threadedrender = Profile:GetThreadedRenderEnabled()
	end

	--[[if PLATFORM == "WIN32_STEAM" and not self.in_game then
		self.options.steamcloud = TheSim:GetSetting("STEAM", "DISABLECLOUD") ~= "true"
	end--]]

	if self.show_datacollection then
		self.options.datacollection = TheSim:GetDataCollectionSetting()
	end

	if show_graphics then
		self.options.display = graphicsOptions:GetFullscreenDisplayID()
		self.options.refreshrate = graphicsOptions:GetFullscreenDisplayRefreshRate()
		self.options.fullscreen = graphicsOptions:IsFullScreen()
		self.options.mode_idx = graphicsOptions:GetCurrentDisplayModeID( self.options.display )
	end

	self.working = deepcopy(self.options)

	self.is_mapping = false

    TheInputProxy:StartMappingControls()

    self.letterbox = self:AddChild(TEMPLATES.old.ForegroundLetterbox())

	self.root = self:AddChild(TEMPLATES.ScreenRoot("GameOptions"))
    self.bg = self.root:AddChild(TEMPLATES.PlainBackground())
    self.title = self.root:AddChild(TEMPLATES.ScreenTitle(STRINGS.UI.OPTIONS.TITLE, ""))

    self.kit_puppet = self.root:AddChild(KitcoonPuppet( Profile, nil, {
        { x = -260, y = 284, scale = 0.75 },
        { x = 260,  y = 284, scale = 0.75 },
        { x = 50,   y = 284, scale = 0.75 },
    } ))

	self.onlinestatus = self.root:AddChild(OnlineStatus())

    -- action menu is the bottom buttons
	self.action_menu = self.root:AddChild(self:_BuildActionMenu())
	self.action_menu:SetPosition(2, -RESOLUTION_Y*.5 + BACK_BUTTON_Y - 4,0)
	self.action_menu:SetScale(.8)
	self:MakeBackButton()
    self:_RefreshScreenButtons()

    self.dialog = self.root:AddChild(TEMPLATES.RectangleWindow(830, 530))
    self.dialog:SetPosition(140, 5)
    self.panel_root = self.dialog:AddChild(Widget("panel_root"))
    self.panel_root:SetPosition(-90, 55)

	self:DoInit()

    local menu_items = {
            -- Left menu items
            settings = self.panel_root:AddChild(self:_BuildSettings()),
            graphics = self.panel_root:AddChild(self:_BuildGraphics()),
            advanced = self.panel_root:AddChild(self:_BuildAdvancedSettings()),
        }
	if IsConsoleLayout() then	
        menu_items["controls"] = self.panel_root:AddChild(self:_BuildController())
	else
        menu_items["controls"] = self.panel_root:AddChild(self:_BuildControls())
	end
    if self.show_language_options then
        menu_items["languages"] = self.panel_root:AddChild(self:_BuildLanguages())
    end

    self.subscreener = Subscreener(self, self._BuildMenu, menu_items )
    self.subscreener:SetPostMenuSelectionAction(function(selection)
        self.selected_tab = selection
        self:UpdateMenu()
    end)

	self:InitializeSpinners(true)

	-------------------------------------------------------
	-- Must get done AFTER InitializeSpinners()
	if not IsConsoleLayout() then
		self._deviceSaved = self.deviceSpinner:GetSelectedData()
		if self._deviceSaved ~= 0 then
			self.kb_controllist:Hide()
			self.active_list = self.controller_controllist
			self.active_list:Show()
		else
			self.controller_controllist:Hide()
			self.active_list = self.kb_controllist
			self.active_list:Show()
		end
		self.controls_header:SetString(self.deviceSpinner:GetSelectedText())

		self:LoadCurrentControls()

		self.controls_horizontal_line:MoveToFront()
		self.controls_vertical_line:MoveToFront()
	end

	---------------------------------------------------

    self.subscreener:OnMenuButtonSelected("settings")

    self:_DoFocusHookups()
	self.default_focus = self.subscreener.menu

	if default_section == "LANG" then
		self.subscreener.menu.items[1]:onclick() --index 1 should be the Languages button
	end
end)

function OptionsScreen:_BuildMenu(subscreener)
    self.tooltip = self.root:AddChild(TEMPLATES.ScreenTooltip())

	local settings_button = subscreener:MenuButton(STRINGS.UI.OPTIONS.SETTINGS, "settings", STRINGS.UI.OPTIONS.TOOLTIPS.SETTINGS, self.tooltip)
	local graphics_button = subscreener:MenuButton(STRINGS.UI.OPTIONS.GRAPHICS, "graphics", STRINGS.UI.OPTIONS.TOOLTIPS.GRAPHICS, self.tooltip)
	local advanced_button = subscreener:MenuButton(STRINGS.UI.OPTIONS.ADVANCED, "advanced", STRINGS.UI.OPTIONS.TOOLTIPS.ADVANCED, self.tooltip)
	local controls_button = subscreener:MenuButton(STRINGS.UI.OPTIONS.CONTROLS, "controls", STRINGS.UI.OPTIONS.TOOLTIPS.CONTROLS, self.tooltip)
	local languages_button = nil
    if self.show_language_options then
        languages_button = subscreener:MenuButton(STRINGS.UI.OPTIONS.LANGUAGES, "languages", STRINGS.UI.OPTIONS.TOOLTIPS.LANGUAGES, self.tooltip)
    end

    local menu_items = {
        {widget = controls_button},
		{widget = advanced_button},
        {widget = graphics_button},
        {widget = settings_button},
    }

    if self.show_language_options then
        table.insert( menu_items, 1, {widget = languages_button} )
    end

    return self.root:AddChild(TEMPLATES.StandardMenu(menu_items, 38, nil, nil, true))
end

function OptionsScreen:MakeBackButton()
	self.cancel_button = self.root:AddChild(TEMPLATES.BackButton(
		function()
			if self:IsDirty() then
				self:ConfirmRevert() --revert and go back, or stay
			else
				self:Close() --go back
			end
		end))
end

function OptionsScreen:_RefreshScreenButtons()
    if TheInput:ControllerAttached() then
        self.cancel_button:Hide()
		self.action_menu:Hide()
    else
        self.cancel_button:Show()
        self.action_menu:Show()
    end
end


function OptionsScreen:OnControl(control, down)
    if OptionsScreen._base.OnControl(self, control, down) then return true end

    if not down then
	    if control == CONTROL_CANCEL then
			if self:IsDirty() then
				self:ConfirmRevert() --revert and go back, or stay
			else
				self:Close() --go back
			end
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			return true
		elseif control == CONTROL_MENU_BACK and TheInput:ControllerAttached() then
            TheFrontEnd:PushScreen(PopupDialogScreen( STRINGS.UI.CONTROLSSCREEN.RESETTITLE, STRINGS.UI.CONTROLSSCREEN.RESETBODY,
            {
                {
                    text = STRINGS.UI.CONTROLSSCREEN.YES,
                    cb = function()
                        self:LoadDefaultControls()
                        TheFrontEnd:PopScreen()
                    end
                },
                {
                    text = STRINGS.UI.CONTROLSSCREEN.NO,
                    cb = function()
                        TheFrontEnd:PopScreen()
                    end
                }
            }))
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
            return true
	    elseif control == CONTROL_MENU_START and TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
	    	if self:IsDirty() then
	    		self:ApplyChanges() --apply changes and go back, or stay
	    		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
	    		return true
	    	end
	    end
	end
end

function OptionsScreen:ApplyChanges()
	if self:IsDirty() then
		if self:IsGraphicsDirty() then
			self:ConfirmGraphicsChanges()
		else
			self:ConfirmApply()
		end
	end
end

function OptionsScreen:Close(fn)
    TheFrontEnd:FadeBack(nil, nil, fn)
end

function OptionsScreen:ConfirmRevert()
	TheFrontEnd:PushScreen(
		PopupDialogScreen( STRINGS.UI.OPTIONS.BACKTITLE, STRINGS.UI.OPTIONS.BACKBODY,
		  {
		  	{
		  		text = STRINGS.UI.OPTIONS.YES,
		  		cb = function()
					self:RevertChanges()
					self:Close(function() TheFrontEnd:PopScreen() end)
				end
			},

			{
				text = STRINGS.UI.OPTIONS.NO,
				cb = function()
					TheFrontEnd:PopScreen()
				end
			}
		  }
		)
	)
end

function OptionsScreen:ConfirmApply( )

	TheFrontEnd:PushScreen(
		PopupDialogScreen( STRINGS.UI.OPTIONS.ACCEPTTITLE, STRINGS.UI.OPTIONS.ACCEPTBODY,
		  {
		  	{
		  		text = STRINGS.UI.OPTIONS.ACCEPT,
		  		cb = function()
					self:Save(function()
						self:Close(function() TheFrontEnd:PopScreen() end)
					end)
				end
			},

			{
				text = STRINGS.UI.OPTIONS.CANCEL,
				cb = function()
					TheFrontEnd:PopScreen()
				end
			}
		  }
		)
	)
end

function OptionsScreen:GetHelpText()
	local t = {}
	local controller_id = TheInput:GetControllerID()

	table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

	if self.selected_tab == "controls" then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_BACK, false, false) .. " " .. STRINGS.UI.CONTROLSSCREEN.RESET)
	end

	if self:IsDirty() then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_START) .. " " .. STRINGS.UI.HELP.APPLY)
	end

	return table.concat(t, "  ")
end


function OptionsScreen:Accept()
	self:Save(function() self:Close() end )
end

function OptionsScreen:Save(cb)
	self.options = deepcopy( self.working )

	Profile:SetVolume( self.options.ambientvolume, self.options.fxvolume, self.options.musicvolume )
	Profile:SetBloomEnabled( self.options.bloom )
	Profile:SetDistortionEnabled( self.options.distortion_modifier > 0 )
	Profile:SetDistortionModifier( self.options.distortion_modifier )
	Profile:SetScreenShakeEnabled( self.options.screenshake )
	Profile:SetWathgrithrFontEnabled( self.options.wathgrithrfont )
	Profile:SetBoatCameraEnabled( self.options.boatcamera )
	Profile:SetInvertCameraRotation( self.options.InvertCameraRotation )
	Profile:SetHUDSize( self.options.hudSize )
	Profile:SetCraftingMenuSize( self.options.craftingmenusize )
	Profile:SetCraftingMenuNumPinPages( self.options.craftingmenunumpinpages )
	Profile:SetCraftingMenuSensitivity( self.options.craftingmenusensitivity )
	Profile:SetInventorySensitivity( self.options.inventorysensitivity )
	Profile:SetMiniMapZoomSensitivity( self.options.minimapzoomsensitivity )
    Profile:SetBoatHopDelay( self.options.boathopdelay )
	Profile:SetScreenFlash( self.options.screenflash )
	Profile:SetVibrationEnabled( self.options.vibration )
	Profile:SetShowPasswordEnabled( self.options.showpassword )
	Profile:SetProfanityFilterServerNamesEanbled( self.options.profanityfilterservernames )
	Profile:SetProfanityFilterChatEanbled( self.options.profanityfilterchat )
    Profile:SetMovementPredictionEnabled(self.options.movementprediction)
	Profile:SetAutoSubscribeModsEnabled( self.options.automods )
	Profile:SetAutoLoginEnabled( self.options.autologin )
    Profile:SetNPCChatLevel(self.options.npcchat)
	Profile:SetAnimatedHeadsEnabled( self.options.animatedheads )
	Profile:SetTextureStreamingEnabled( self.options.texturestreaming )
	if IsWin32() then
		Profile:SetThreadedRenderEnabled( self.options.threadedrender )
	end
	Profile:SetDynamicTreeShadowsEnabled( self.options.dynamictreeshadows )
	Profile:SetAutopauseEnabled( self.options.autopause )
	Profile:SetConsoleAutopauseEnabled( self.options.consoleautopause )
	Profile:SetCraftingMenuBufferedBuildAutoClose( self.options.craftingmenubufferedbuildautoclose )
	Profile:SetCraftingHintAllRecipesEnabled( self.options.craftinghintallrecipes )
	Profile:SetCraftingAutopauseEnabled( self.options.craftingautopause )
	Profile:SetLoadingTipsOption( self.options.loadingtips )
	Profile:SetCampfireStoryCameraEnabled( self.options.waltercamera )
	Profile:SetMinimapZoomCursorEnabled( self.options.minimapzoomcursor )
	Profile:SetDefaultCloudSaves( self.options.defaultcloudsaves )
	Profile:SetScrapbookHudDisplay( self.options.scrapbookhuddisplay )
	Profile:SetPOIDisplay( self.options.poidisplay )	

	if self.integratedbackpackSpinner:IsEnabled() then
		Profile:SetIntegratedBackpack( self.options.integratedbackpack )
	end

	self:Apply()

	Profile:Save( function() if cb then cb() end end)
end

function OptionsScreen:RevertChanges()
    for i, v in ipairs(self.devices) do
        if v.data ~= 0 then -- never disable the keyboard
            TheInputProxy:EnableInputDevice(v.data, v.data == self._deviceSaved)
        end
    end
	self.working = deepcopy(self.options)
	self:LoadCurrentControls()
	self:Apply()
	self:InitializeSpinners()
	self:UpdateMenu()
end

function OptionsScreen:MakeDirty()
    self.dirty = true
    self:UpdateMenu()
end

function OptionsScreen:MakeClean()
    self.dirty = false
    self:UpdateMenu()
end

function OptionsScreen:IsDirty()
	for k,v in pairs(self.working) do
		if v ~= self.options[k] then
			return true
		end
	end
	return self.dirty
end

function OptionsScreen:IsGraphicsDirty()
	return self.working.display ~= self.options.display or
		self.working.mode_idx ~= self.options.mode_idx or
		self.working.fullscreen ~= self.options.fullscreen
end

function OptionsScreen:ChangeGraphicsMode()
	if show_graphics then
		local gOpts = TheFrontEnd:GetGraphicsOptions()
		local w, h, hz = gOpts:GetDisplayMode( self.working.display, self.working.mode_idx )
		local mode_idx = GetDisplayModeIdx( self.working.display, w, h, self.working.refreshrate) or 0
		gOpts:SetDisplayMode( self.working.display, mode_idx, self.working.fullscreen )
	end

end

function OptionsScreen:ConfirmGraphicsChanges(fn)

	if not self.applying then
		self:ChangeGraphicsMode()

		TheFrontEnd:PushScreen(
			PopupDialogScreen( STRINGS.UI.OPTIONS.ACCEPTGRAPHICSTITLE, STRINGS.UI.OPTIONS.ACCEPTGRAPHICSBODY,
			  { { text = STRINGS.UI.OPTIONS.ACCEPT, cb =
					function()

						self:Save(
							function()
								self.applying = false
								self:UpdateMenu()
								TheFrontEnd:PopScreen()
							end)
					end
				},
				{ text = STRINGS.UI.OPTIONS.CANCEL, cb =
					function()
						self.applying = false
						self:RevertChanges()
						self:ChangeGraphicsMode()
						TheFrontEnd:PopScreen()
					end
				}
			  }
			)
		)
	end
end

function OptionsScreen:ApplyVolume()
	TheMixer:SetLevel("set_sfx", self.working.fxvolume / 10 )
	TheMixer:SetLevel("set_music", self.working.musicvolume / 10 )
	TheMixer:SetLevel("set_ambience", self.working.ambientvolume / 10 )
end

function OptionsScreen:Apply()
	self:ApplyVolume()

	TheInputProxy:EnableVibration(self.working.vibration)

	local gopts = TheFrontEnd:GetGraphicsOptions()
	PostProcessor:SetBloomEnabled( self.working.bloom )
	PostProcessor:SetDistortionEnabled( self.working.distortion_modifier > 0 )
	if TheWorld and TheWorld.components.colourcube then
		TheWorld.components.colourcube:SetDistortionModifier( self.working.distortion_modifier )
	end
	gopts:SetSmallTexturesMode( self.working.smalltextures )
	Profile:SetScreenShakeEnabled( self.working.screenshake )
	Profile:SetWathgrithrFontEnabled( self.working.wathgrithrfont )
	Profile:SetCampfireStoryCameraEnabled( self.working.waltercamera )
	Profile:SetMinimapZoomCursorEnabled( self.working.minimapzoomcursor )
	Profile:SetBoatCameraEnabled( self.working.boatcamera )
	Profile:SetInvertCameraRotation( self.working.InvertCameraRotation )
	TheSim:SetNetbookMode(self.working.netbookmode)

	EnableShadeRenderer( self.working.dynamictreeshadows )

	Profile:SetAutopauseEnabled( self.working.autopause )
	Profile:SetConsoleAutopauseEnabled( self.working.consoleautopause )
	Profile:SetCraftingAutopauseEnabled( self.working.craftingautopause )
	Profile:SetCraftingMenuBufferedBuildAutoClose( self.working.craftingmenubufferedbuildautoclose )
	Profile:SetCraftingHintAllRecipesEnabled( self.working.craftinghintallrecipes )
	Profile:SetLoadingTipsOption( self.working.loadingtips )
	Profile:SetDefaultCloudSaves( self.options.defaultcloudsaves )
	Profile:SetScrapbookHudDisplay( self.options.scrapbookhuddisplay )
	Profile:SetPOIDisplay( self.options.poidisplay )
	
	DoAutopause()
	local pausescreen = TheFrontEnd:GetOpenScreenOfType("PauseScreen")
	if pausescreen ~= nil then pausescreen:BuildMenu() end

	if self.integratedbackpackSpinner:IsEnabled() then
		Profile:SetIntegratedBackpack( self.working.integratedbackpack )
	end

	TheInputProxy:ApplyControlMapping()
    self._deviceSaved = 0 --Default if nothing else was enabled
    for i, v in ipairs(self.devices) do
        local guid, data, enabled = TheInputProxy:SaveControls(self.devices[i].data)
        if guid ~= nil and data ~= nil then
            Profile:SetControls(guid, data, enabled)
            if enabled and self.devices[i].data ~= 0 then
                self._deviceSaved = self.devices[i].data
            end
        end
    end

    if ThePlayer ~= nil then
        ThePlayer:EnableMovementPrediction(self.working.movementprediction)
		ThePlayer:EnableBoatCamera(self.working.boatcamera)
    end

    if self.working.lang_id ~= Profile:GetLanguageID() then
        Profile:SetLanguageID(self.working.lang_id, function() SimReset() end )
    end

    self:MakeClean()
end

function OptionsScreen:LoadDefaultControls()
	TheInputProxy:LoadDefaultControlMapping()
	self:MakeDirty()
	self:RefreshControls()
end

function OptionsScreen:LoadCurrentControls()
	TheInputProxy:LoadCurrentControlMapping()
	self:MakeClean()
    self:RefreshControls()
end

--[[function OptionsScreen:MapControlInputHandler(control, down)
    if not down and control == CONTROL_CANCEL then
        TheInputProxy:CancelMapping()
        self.is_mapping = false
        TheFrontEnd:PopScreen()
    end
end--]]

function OptionsScreen:MapControl(deviceId, controlId)
    --print("Mapping control [" .. controlId .. "] on device [" .. deviceId .. "]")
    local controlIndex = controlId + 1      -- C++ control id is zero-based, we were passed a 1-based (lua) array index
    local loc_text = TheInput:GetLocalizedControl(deviceId, controlId, true)
    local default_text = string.format(STRINGS.UI.CONTROLSSCREEN.DEFAULT_CONTROL_TEXT, loc_text)
    local body_text = STRINGS.UI.CONTROLSSCREEN.CONTROL_SELECT .. "\n\n" .. default_text
    local popup = PopupDialogScreen(STRINGS.UI.CONTROLSSCREEN.CONTROLS[controlIndex], body_text, {})

    -- Better position within dialog.
    popup.dialog.body:SetPosition(0, 0)

    -- Prevent any inputs from being consumed so TheInputProxy can work.
    popup.OnControl = function(_, control, down) --[[self:MapControlInputHandler(control, down)]] return true end
	TheFrontEnd:PushScreen(popup)

	-- Delaying the MapControl one frame. Done for Steam Deck, but this wont impact other systems.
	self.inst:DoTaskInTime(0, function() 
		TheInputProxy:MapControl(deviceId, controlId) 
		self.is_mapping = true 
	end)
end

function OptionsScreen:OnControlMapped(deviceId, controlId, inputId, hasChanged)
    if self.is_mapping then
       -- print("Control [" .. controlId .. "] is now [" .. inputId .. "]", hasChanged, debugstack())

        -- removes the "press a button to bind" popup screen. This is not needed when clearing a binding because there is no popup
        if inputId ~= 0xFFFFFFFF then
            TheFrontEnd:PopScreen()
        end

        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        for k, v in pairs(self.active_list.items) do
            if controlId == v.controlId then
                if hasChanged then
                    local ctrlString = TheInput:GetLocalizedControl(deviceId, v.controlId)
                    v.binding_btn:SetText(ctrlString)
                    -- hasChanged only refers to the immediate change, but if a control is modified
                    -- and then modified again to the original we shouldn't highlight it
                    local changedFromOriginal = TheInputProxy:HasMappingChanged(deviceId, controlId)
                    if changedFromOriginal then
                        v.changed_image:Show()
                    else
                        v.changed_image:Hide()
                    end
                end
            end
        end

        -- set the dirty flag (if something changed) if it hasn't yet been set
        if not self:IsDirty() and hasChanged then
            self:MakeDirty()
        end

	    self.is_mapping = false
    end
end

function OptionsScreen:_BuildActionMenu()
	local action_menu = Menu(nil, -80, false)
    action_menu.horizontal = true

    self.apply_button = self.root:AddChild(TEMPLATES.StandardButton(function() self:ApplyChanges() end, STRINGS.UI.OPTIONS.APPLY))
    action_menu:AddCustomItem(self.apply_button, Vector3(450, 0, 0))

    self.reset_button = self.root:AddChild(TEMPLATES.StandardButton(
            function()
                TheFrontEnd:PushScreen(PopupDialogScreen( STRINGS.UI.CONTROLSSCREEN.RESETTITLE, STRINGS.UI.CONTROLSSCREEN.RESETBODY,
                        {
                            {
                                text = STRINGS.UI.CONTROLSSCREEN.YES,
                                cb = function()
                                    self:LoadDefaultControls()
                                    TheFrontEnd:PopScreen()
                                end
                            },
                            {
                                text = STRINGS.UI.CONTROLSSCREEN.NO,
                                cb = function()
                                    TheFrontEnd:PopScreen()
                                end
                            }
                    }))
            end,
            STRINGS.UI.CONTROLSSCREEN.RESET
        ))
    self.reset_button:SetScale(.8)
    action_menu:AddCustomItem(self.reset_button, Vector3(230, 0, 0))

    return action_menu
end

function OptionsScreen:UpdateMenu()
	if self:IsDirty() then
		self.apply_button:Enable()
	else
		self.apply_button:Disable()
	end

	if self.selected_tab == "controls" then
		self.reset_button:Show()
	else
		self.reset_button:Hide()
	end
end

function OptionsScreen:OnDestroy()
    TheInputProxy:StopMappingControls()

	if self.inputhandlers then
	    for k,v in pairs(self.inputhandlers) do
	        v:Remove()
	    end
	end

	self._base.OnDestroy(self)
end

function OptionsScreen:RefreshControls()

	if IsConsoleLayout() then
		return
	end

	local focus = self:GetDeepestFocus()
	local old_idx = focus and focus.idx

	local deviceId = self.deviceSpinner:GetSelectedData()
    local controllerDeviceId =
        (deviceId ~= 0 and deviceId) or
        (self.deviceSpinner.options[2] ~= nil and self.deviceSpinner.options[2].data) or
        nil
    --print("RefreshControls device is [" .. deviceId .. "]")
    --print("Current controller device is ["..(controllerDeviceId or "none").."]")

	for i,v in pairs(self.active_list.items) do
		local hasChanged = TheInputProxy:HasMappingChanged(deviceId, v.controlId)
		if hasChanged then
		    v.changed_image:Show()
		else
		    v.changed_image:Hide()
		end

        if v.device_type == "keyboard" and v.control.keyboard and v.binding_btn then
            local kbString = TheInput:GetLocalizedControl(0, v.control.keyboard)
            v.binding_btn:SetText(kbString)

			self.integratedbackpackSpinner:Enable()
			self.integratedbackpackSpinner:SetSelectedIndex(self.integratedbackpackSpinner.selectedIndex)

        elseif v.control.controller and self.deviceSpinner:GetSelectedData() and v.binding_btn then
            local controllerString = controllerDeviceId ~= nil and TheInput:GetLocalizedControl(controllerDeviceId, v.control.controller) or ""
            v.binding_btn:SetText(controllerString)

			self.integratedbackpackSpinner:Disable()
			self.integratedbackpackSpinner:UpdateText(STRINGS.UI.OPTIONS.INTEGRATEDBACKPACK_ENABLED)
        end
	end

	if self.selected_tab == "controls" then
		if old_idx then
			self.active_list.items[math.min(#self.active_list.items, old_idx)].button:SetFocus()
		end
	end

	self:UpdateMenu()
end

function OptionsScreen:_DoFocusHookups()
	local function torightcol()
        if self.selected_tab == "settings" then
			return self.grid
		elseif self.selected_tab == "graphics" then
		    return self.grid_graphics
        else
            return self.active_list
        end
	end

    self.grid:SetFocusChangeDir(MOVE_RIGHT, self.action_menu)
    self.grid_graphics:SetFocusChangeDir(MOVE_RIGHT, self.action_menu)
    if not IsConsoleLayout() then
		self.controller_controllist:SetFocusChangeDir(MOVE_RIGHT, self.action_menu)
		self.kb_controllist:SetFocusChangeDir(MOVE_RIGHT, self.action_menu)
	end

    self.action_menu:SetFocusChangeDir(MOVE_LEFT, self.subscreener.menu)
    self.action_menu:SetFocusChangeDir(MOVE_UP, torightcol)

    self.cancel_button:SetFocusChangeDir(MOVE_UP, self.subscreener.menu)
end

function OptionsScreen:DoInit()
	self:UpdateMenu()

	self.devices = TheInput:GetInputDevices()

	self.inputhandlers = {}
    table.insert(self.inputhandlers, TheInput:AddControlMappingHandler(
        function(deviceId, controlId, inputId, hasChanged)
            self:OnControlMapped(deviceId, controlId, inputId, hasChanged)
        end
    ))
end


local function BuildSectionTitle(text, region_size)
    local title_root = Widget("title_root")
    local title = title_root:AddChild(Text(HEADERFONT, 26))
    title:SetRegionSize(region_size, 70)
    title:SetString(text)
    title:SetColour(UICOLOURS.GOLD_SELECTED)

    local titleunderline = title_root:AddChild( Image("images/frontend_redux.xml", "achievements_divider_top.tex") )
    titleunderline:SetScale(0.4, 0.5)
    titleunderline:SetPosition(0, -20)

    return title_root
end

function OptionsScreen:_BuildLangButton(region_size, button_height, lang_id)
    -- Use noop function to make ListItemBackground build something that's clickable.
    local langButton = TEMPLATES.ListItemBackground(region_size, button_height, function() end)
    langButton.move_on_click = true
    langButton.text:SetRegionSize(region_size, 70)
    langButton:SetTextSize(28)
    langButton:SetFont(CHATFONT)
    langButton:SetTextColour(UICOLOURS.GOLD_CLICKABLE)
    langButton:SetTextFocusColour(UICOLOURS.GOLD_FOCUS)
    langButton:SetTextSelectedColour(UICOLOURS.GOLD_FOCUS)

    if lang_id == Profile:GetLanguageID() then
        langButton:Select()
        self.last_selected = langButton
    end

    local name = STRINGS.PRETRANSLATED.LANGUAGES[lang_id]
    langButton:SetText(name)
    langButton:SetOnClick(function()
        self.working.lang_id = lang_id
        langButton:Select()
        if self.last_selected ~= nil then
            self.last_selected:Unselect()
        end
        self.last_selected = langButton

        self:UpdateMenu()
    end)

    return langButton
end

function OptionsScreen:_BuildModLangButton(region_size, button_height, mod_data, last_item)
    if mod_data == nil then
		return
	end
	-- Use noop function to make ListItemBackground build something that's clickable.
    local langButton = TEMPLATES.ListItemBackground(region_size, button_height, function() end)
    langButton.move_on_click = true
    langButton.text:SetRegionSize(region_size, 70)
    langButton:SetTextSize(28)
    langButton:SetFont(CHATFONT)
    langButton:SetTextColour(UICOLOURS.GOLD_CLICKABLE)
    langButton:SetTextFocusColour(UICOLOURS.GOLD_FOCUS)
    langButton:SetTextSelectedColour(UICOLOURS.GOLD_FOCUS)
    langButton:SetText(mod_data.name)
    langButton:SetOnClick(function()
		VisitURL(mod_data.url)
        if not last_item then --dirty hack. The last item is always the go to support url
			TheFrontEnd:FadeToScreen( self, function() return ModsScreen(self) end, nil )
		end
    end)

    return langButton
end

function OptionsScreen:_BuildModLangButtonRow(region_size, button_height, language_mods, index)
    local row = Widget("row")
	local left = self:_BuildModLangButton(region_size, button_height, language_mods[index], #language_mods == index)
	row:AddChild(left)
	left:SetPosition(-region_size/2,0)
	left.ongainfocusfn = function() self.column_in = "left" end

	local right = self:_BuildModLangButton(region_size, button_height, language_mods[index+1], #language_mods == index) 
	if right then
		row:AddChild(right)
		right:SetPosition(region_size/2,0)
		right.ongainfocusfn = function() self.column_in = "right" end
		
		left:SetFocusChangeDir(MOVE_RIGHT, right)
		right:SetFocusChangeDir(MOVE_LEFT, left)
	end
	
	row.focus_forward = function()
		if self.column_in == "right" and right ~= nil then
			return right
		end
		return left
	end

    return row
end

-- This is the "languages" tab
function OptionsScreen:_BuildLanguages()
    local languagesRoot = Widget("LANG_ROOT")

    languagesRoot:SetPosition(0,0)

    local button_width = 430
    local button_height = 45

    local langtitle = languagesRoot:AddChild(BuildSectionTitle(STRINGS.UI.OPTIONS.LANG_TITLE, 200))
    langtitle:SetPosition(92, 160)

    local langButtons = {}

    self.lang_grid = languagesRoot:AddChild(Grid())
    self.lang_grid:SetPosition(-125, 90)
    for _,id in pairs(LOC.GetLanguages()) do
        table.insert(langButtons, self:_BuildLangButton(button_width, button_height, id))
    end
    self.lang_grid:FillGrid(2, button_width, button_height, langButtons)

	if self.show_mod_language_options then
		TheSim:QueryServer( "https://dst-translation-mods.klei.com/mods.json",
		function( result, isSuccessful, resultCode )
			if isSuccessful and string.len(result) > 1 and resultCode == 200 then
				local status, language_mods = pcall( function() return json.decode(result) end )
				if status then					
    				local modsRoot = languagesRoot:AddChild(Widget("MOD_LANG_ROOT"))
					modsRoot:SetPosition(0, -145)

					local modLangtitle = modsRoot:AddChild(BuildSectionTitle(STRINGS.UI.OPTIONS.MOD_LANGUAGES_TITLE, 400))
					modLangtitle:SetPosition(92, 80)
				
    				local mod_button_width = 410
					local modLangButtons = {}
					for i,_ in pairs(language_mods) do
						if i % 2 == 1 then --evens do new rows
							table.insert(modLangButtons, self:_BuildModLangButtonRow(mod_button_width, button_height, language_mods, i))
						end
					end

					local list = ScrollableList(modLangButtons, button_width, 200, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "GOLD")
					self.mods_list = modsRoot:AddChild(list)
					self.mods_list:SetPosition(290, -65)
				
					self.lang_grid:SetFocusChangeDir(MOVE_DOWN, self.mods_list)
					modsRoot:SetFocusChangeDir(MOVE_UP, self.lang_grid)
				end
			end
		end, "GET" )
	end

    languagesRoot.focus_forward = self.lang_grid

    return languagesRoot
end

local function EnabledOptionsIndex(enabled)
    return enabled and 2 or 1
end

--shared section for graphics and settings
local label_width = 200
local spinner_width = 220
local spinner_height = 36 --nil -- use default
local spinner_scale_x = .76
local spinner_scale_y = .68
local narrow_field_nudge = -50
local space_between = 5

local function AddListItemBackground(w)
	local total_width = label_width + spinner_width + space_between
	w.bg = w:AddChild(TEMPLATES.ListItemBackground(total_width + 15, spinner_height + 5))
	w.bg:SetPosition(-40,0)
	w.bg:MoveToBack()
end
local function CreateTextSpinner(labeltext, spinnerdata, tooltip_text)
	local w = TEMPLATES.LabelSpinner(labeltext, spinnerdata, label_width, spinner_width, spinner_height, space_between, nil, nil, narrow_field_nudge, nil, nil, tooltip_text)
	AddListItemBackground(w)
	return w.spinner
end

local function CreateNumericSpinner(labeltext, min, max, tooltip_text)
	local w = TEMPLATES.LabelNumericSpinner(labeltext, min, max, label_width, spinner_width, spinner_height, space_between, nil, nil, narrow_field_nudge, tooltip_text)
	AddListItemBackground(w)
	return w.spinner
end

local function CreateCheckBox(labeltext, onclicked, checked, tooltip_text)
	local w = TEMPLATES.OptionsLabelCheckbox(onclicked, labeltext, checked, label_width, spinner_width, spinner_height, spinner_height + 15, space_between, CHATFONT, nil, narrow_field_nudge, tooltip_text)
	AddListItemBackground(w)
	return w.button
end

local function AddSpinnerTooltip(widget, tooltip, tooltipdivider)
	tooltipdivider:Hide()
	local function ongainfocus(is_enabled)
		if tooltip ~= nil and widget.tooltip_text ~= nil then
			tooltip:SetString(widget.tooltip_text)
			tooltipdivider:Show()
		end
	end
	
	local function onlosefocus(is_enabled)
		if widget.parent and not widget.parent.focus then
			tooltip:SetString("")
			tooltipdivider:Hide()
		end
	end

	widget.bg.ongainfocus = ongainfocus

	if widget.spinner then
		widget.spinner.ongainfocusfn = ongainfocus
	elseif widget.button then -- Handles the data collection checkbox option
		widget.button.ongainfocus = ongainfocus
	end

	widget.bg.onlosefocus = onlosefocus

	if widget.spinner then
		widget.spinner.onlosefocusfn = onlosefocus
	elseif widget.button then -- Handles the data collection checkbox option
		widget.button.onlosefocus = onlosefocus
	end

end

local function MakeSpinnerTooltip(root)
	local spinner_tooltip = root:AddChild(Text(CHATFONT, 25, ""))
	spinner_tooltip:SetPosition(90, -275)
	spinner_tooltip:SetHAlign(ANCHOR_LEFT)
	spinner_tooltip:SetVAlign(ANCHOR_TOP)
	spinner_tooltip:SetRegionSize(800, 80)
	spinner_tooltip:EnableWordWrap(true)
	return spinner_tooltip
end

-- This is the "graphics" tab
function OptionsScreen:_BuildGraphics()
	local graphicsroot = Widget("ROOT")

	-- NOTE: if we add more options, they should be made scrollable. Look at customization screen for an example.
    self.grid_graphics = graphicsroot:AddChild(Grid())
    self.grid_graphics:SetPosition(-90, 184, 0)


	--------------
	--------------
	-- GRAPHICS --
	--------------
	--------------

	if show_graphics then
		local gOpts = TheFrontEnd:GetGraphicsOptions()

		self.fullscreenSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.FULLSCREEN, enableDisableOptions, STRINGS.UI.OPTIONS.TOOLTIPS.FULLSCREEN)
		self.fullscreenSpinner.OnChanged =
			function( _, data )
				self.working.fullscreen = data
				self:UpdateResolutionsSpinner()
				self:UpdateMenu()
			end
		if gOpts:IsFullScreenEnabled() then
			self.fullscreenSpinner:Enable()
		else
			self.fullscreenSpinner:Disable()
		end

		local valid_displays = GetDisplays()
		self.displaySpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.DISPLAY, valid_displays, STRINGS.UI.OPTIONS.TOOLTIPS.DISPLAY)
		self.displaySpinner.OnChanged =
			function( _, data )
				self.working.display = data
				self:UpdateResolutionsSpinner()
				self:UpdateRefreshRatesSpinner()
				self:UpdateMenu()
			end

		local refresh_rates = GetRefreshRates( self.working.display, self.working.mode_idx )
		self.refreshRateSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.REFRESHRATE, refresh_rates, STRINGS.UI.OPTIONS.TOOLTIPS.REFRESHRATE)
		self.refreshRateSpinner.OnChanged =
			function( _, data )
				self.working.refreshrate = data
				self:UpdateMenu()
			end

		local modes = GetDisplayModes( self.working.display )
		self.resolutionSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.RESOLUTION, modes, STRINGS.UI.OPTIONS.TOOLTIPS.RESOLUTION)
		self.resolutionSpinner.OnChanged =
			function( _, data )
				self.working.mode_idx = data.idx
				self:UpdateRefreshRatesSpinner()
				self:UpdateMenu()
			end

		self.netbookModeSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.NETBOOKMODE, enableDisableOptions, STRINGS.UI.OPTIONS.TOOLTIPS.NETBOOKMODE)
		self.netbookModeSpinner.OnChanged =
			function( _, data )
				self.working.netbookmode = data
				--self:Apply()
				self:UpdateMenu()
			end

		self.smallTexturesSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.SMALLTEXTURES, enableDisableOptions, STRINGS.UI.OPTIONS.TOOLTIPS.SMALLTEXTURES)
		self.smallTexturesSpinner.OnChanged =
			function( _, data )
				self.working.smalltextures = data
				--self:Apply()
				self:UpdateMenu()
			end

	end

	self.bloomSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.BLOOM, enableDisableOptions, STRINGS.UI.OPTIONS.TOOLTIPS.BLOOM)
	self.bloomSpinner.OnChanged =
		function( _, data )
			self.working.bloom = data
			--self:Apply()
			self:UpdateMenu()
		end

	self.distortionSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.DISTORTION, distortionLevelOptions, STRINGS.UI.OPTIONS.TOOLTIPS.DISTORTION)
	self.distortionSpinner.OnChanged =
		function( _, data )
			self.working.distortion_modifier = data
			--self:Apply()
			self:UpdateMenu()
		end

	self.screenshakeSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.SCREENSHAKE, enableDisableOptions, STRINGS.UI.OPTIONS.TOOLTIPS.SCREENSHAKE)
	self.screenshakeSpinner.OnChanged =
		function( _, data )
			self.working.screenshake = data
			--self:Apply()
			self:UpdateMenu()
		end

	self.screenFlashSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.SCREEN_FLASH_INTENSITY, enableScreenFlashOptions, STRINGS.UI.OPTIONS.TOOLTIPS.SCREEN_FLASH_INTENSITY)
	self.screenFlashSpinner.OnChanged =
		function( _, data )
			self.working.screenflash = data
			--self:Apply()
			self:UpdateMenu()
		end

	self.texturestreamingSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.TEXTURESTREAMING, enableDisableOptions, STRINGS.UI.OPTIONS.TOOLTIPS.TEXTURESTREAMING)
	self.texturestreamingSpinner.OnChanged =
		function( spinner, data )
			--print(v,data)
			if not self.shownTextureStreamingWarning then
				TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.OPTIONS.RESTART_TEXTURE_STREAMING_TITLE, STRINGS.UI.OPTIONS.RESTART_TEXTURE_STREAMING_BODY,
				{
					{text=STRINGS.UI.OPTIONS.OK,     cb = function()
																self.shownTextureStreamingWarning = true
																self.working.texturestreaming = data

																if self.smallTexturesSpinner ~= nil and APP_ARCHITECTURE == "x32" then
																	if self.working.texturestreaming == false then
																		self.smallTexturesSpinner:Disable()
																		self.smallTexturesSpinner:UpdateText(STRINGS.UI.OPTIONS.ENABLED)
																	else
																		self.smallTexturesSpinner:Enable()
																		self.smallTexturesSpinner:SetSelectedIndex(self.smallTexturesSpinner.selectedIndex)
																	end
																end

																TheFrontEnd:PopScreen()
																self:UpdateMenu()
															end },
					{text=STRINGS.UI.OPTIONS.CANCEL, cb = function()
																spinner:SetSelectedIndex(EnabledOptionsIndex( self.working.texturestreaming ))
																spinner:SetHasModification(false)
																TheFrontEnd:PopScreen()
																self:UpdateMenu()	-- not needed but meh
															end}
				}))
			else
				self.working.texturestreaming = data

				if self.smallTexturesSpinner ~= nil and APP_ARCHITECTURE == "x32" then
					if self.working.texturestreaming == false then
						self.smallTexturesSpinner:Disable()
						self.smallTexturesSpinner:UpdateText(STRINGS.UI.OPTIONS.ENABLED)
					else
						self.smallTexturesSpinner:Enable()
						self.smallTexturesSpinner:SetSelectedIndex(self.smallTexturesSpinner.selectedIndex)
					end
				end

				self:UpdateMenu()	-- not needed but meh
			end
		end

	if IsWin32() then
		self.threadedrenderSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.THREADEDRENDER, enableDisableOptions, STRINGS.UI.OPTIONS.TOOLTIPS.THREADEDRENDER)
		self.threadedrenderSpinner.OnChanged =
			function( spinner, data )
				--print(v,data)
				if not self.shownThreadedRenderWarning then
					TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.OPTIONS.RESTART_THREADED_RENDER_TITLE, STRINGS.UI.OPTIONS.RESTART_THREADED_RENDER_BODY,
					{
						{text=STRINGS.UI.OPTIONS.OK,     cb = function()
																	self.shownThreadedRenderWarning = true
																	self.working.threadedrender = data
																	TheFrontEnd:PopScreen()
																	self:UpdateMenu()
																end },
						{text=STRINGS.UI.OPTIONS.CANCEL, cb = function()
																	spinner:SetSelectedIndex(EnabledOptionsIndex( self.working.threadedrender ))
																	spinner:SetHasModification(false)
																	TheFrontEnd:PopScreen()
																	self:UpdateMenu()	-- not needed but meh
																end}
					}))
				else
					self.working.threadedrender = data
					self:UpdateMenu()	-- not needed but meh
				end
			end
	end

	self.dynamicTreeShadowsSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.DYNAMIC_TREE_SHADOWS, enableDisableOptions, STRINGS.UI.OPTIONS.TOOLTIPS.DYNAMIC_TREE_SHADOWS)
	self.dynamicTreeShadowsSpinner.OnChanged =
		function( _, data )
			self.working.dynamictreeshadows = data
			--self:Apply()
			self:UpdateMenu()
		end

	self.left_spinners_graphics = {}
	self.right_spinners_graphics = {}

	if IsSteamDeck() then
		table.insert( self.left_spinners_graphics, self.screenshakeSpinner )
		table.insert( self.left_spinners_graphics, self.screenFlashSpinner )
		table.insert( self.left_spinners_graphics, self.dynamicTreeShadowsSpinner )

		table.insert( self.right_spinners_graphics, self.distortionSpinner )
		table.insert( self.right_spinners_graphics, self.bloomSpinner )
		table.insert( self.right_spinners_graphics, self.texturestreamingSpinner )
		if IsWin32() then
			table.insert( self.right_spinners_graphics, self.threadedrenderSpinner )
		end
	else
		table.insert( self.left_spinners_graphics, self.fullscreenSpinner )
		table.insert( self.left_spinners_graphics, self.resolutionSpinner )
		table.insert( self.left_spinners_graphics, self.displaySpinner )
		table.insert( self.left_spinners_graphics, self.refreshRateSpinner )
		table.insert( self.left_spinners_graphics, self.smallTexturesSpinner )
		table.insert( self.left_spinners_graphics, self.netbookModeSpinner )
		table.insert( self.left_spinners_graphics, self.texturestreamingSpinner )

		if IsWin32() then
			table.insert( self.left_spinners_graphics, self.threadedrenderSpinner )
		end

		table.insert( self.right_spinners_graphics, self.screenshakeSpinner )
		table.insert( self.right_spinners_graphics, self.distortionSpinner )
		table.insert( self.right_spinners_graphics, self.bloomSpinner )
		table.insert( self.right_spinners_graphics, self.screenFlashSpinner )
		table.insert( self.right_spinners_graphics, self.dynamicTreeShadowsSpinner )
	end

	self.grid_graphics:UseNaturalLayout()
	self.grid_graphics:InitSize(2, math.max(#self.left_spinners_graphics, #self.right_spinners_graphics), 440, 40)

	local spinner_tooltip = MakeSpinnerTooltip(graphicsroot)

	local spinner_tooltip_divider = graphicsroot:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
	spinner_tooltip_divider:SetPosition(90, -225)

    -- Ugh. Using parent because the spinner lists contain a child of a composite widget.
	for k,v in ipairs(self.left_spinners_graphics) do
		self.grid_graphics:AddItem(v.parent, 1, k)
		AddSpinnerTooltip(v.parent, spinner_tooltip, spinner_tooltip_divider)
	end

	for k,v in ipairs(self.right_spinners_graphics) do
		self.grid_graphics:AddItem(v.parent, 2, k)
		AddSpinnerTooltip(v.parent, spinner_tooltip, spinner_tooltip_divider)
	end

    graphicsroot.focus_forward = self.grid_graphics
    return graphicsroot
end

-- This is the "settings" tab
function OptionsScreen:_BuildSettings()
    local settingsroot = Widget("ROOT")

    -- NOTE: if we add more options, they should be made scrollable. Look
    -- at customization screen for an example.
    self.grid = settingsroot:AddChild(Grid())
    self.grid:SetPosition(-90, 184, 0)
	self.settings_tooltip = settingsroot:AddChild(TEMPLATES.ScreenTooltip())

	--------------
	--------------
	-- SETTINGS --
	--------------
	--------------

	self.fxVolume = CreateNumericSpinner(STRINGS.UI.OPTIONS.FX, 0, 10, STRINGS.UI.OPTIONS.TOOLTIPS.FX)
	self.fxVolume.OnChanged =
		function( _, data )
			self.working.fxvolume = data
			self:ApplyVolume()
			self:UpdateMenu()
		end

	self.musicVolume = CreateNumericSpinner(STRINGS.UI.OPTIONS.MUSIC, 0, 10, STRINGS.UI.OPTIONS.TOOLTIPS.MUSIC)
	self.musicVolume.OnChanged =
		function( _, data )
			self.working.musicvolume = data
			self:ApplyVolume()
			self:UpdateMenu()
		end

	self.ambientVolume = CreateNumericSpinner(STRINGS.UI.OPTIONS.AMBIENT, 0, 10, STRINGS.UI.OPTIONS.TOOLTIPS.AMBIENT)
	self.ambientVolume.OnChanged =
		function( _, data )
			self.working.ambientvolume = data
			self:ApplyVolume()
			self:UpdateMenu()
		end

	self.hudSize = CreateNumericSpinner(STRINGS.UI.OPTIONS.HUDSIZE, 0, 10, STRINGS.UI.OPTIONS.TOOLTIPS.HUDSIZE)
	self.hudSize.OnChanged =
		function( _, data )
			self.working.hudSize = data
			--self:Apply()
			self:UpdateMenu()
		end

	self.craftingmenusize = CreateNumericSpinner(STRINGS.UI.OPTIONS.CRAFTINGMENUSIZE, 0, 10, STRINGS.UI.OPTIONS.TOOLTIPS.CRAFTINGMENUSIZE)
	self.craftingmenusize.OnChanged =
		function( _, data )
			self.working.craftingmenusize = data
			--self:Apply()
			self:UpdateMenu()
		end

	self.scrapbookhuddisplaySpinner =  CreateTextSpinner(STRINGS.UI.OPTIONS.SCAPBOOKHUDDISPLAY, enableDisableOptions, STRINGS.UI.OPTIONS.TOOLTIPS.SCAPBOOKHUDDISPLAY)
	self.scrapbookhuddisplaySpinner.OnChanged =
		function( _, data )
			self.working.scrapbookhuddisplay = data
			--self:Apply()
			self:UpdateMenu()
		end

	self.craftingmenunumpinpagesSpinner = CreateNumericSpinner(STRINGS.UI.OPTIONS.CRAFTINGMENUNUMPINPAGES, 2, 9, STRINGS.UI.OPTIONS.TOOLTIPS.CRAFTINGMENUNUMPINPAGES)
	self.craftingmenunumpinpagesSpinner.OnChanged =
		function( _, data )
			self.working.craftingmenunumpinpages = data
			--self:Apply()
			self:UpdateMenu()
		end		

	self.craftingautopauseSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.CRAFTINGAUTOPAUSE, enableDisableOptions, STRINGS.UI.OPTIONS.TOOLTIPS.CRAFTINGAUTOPAUSE)
	self.craftingautopauseSpinner.OnChanged =
		function( _, data )
			self.working.craftingautopause = data
			--self:Apply()
			self:UpdateMenu()
		end
	
	self.vibrationSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.VIBRATION, enableDisableOptions, STRINGS.UI.OPTIONS.TOOLTIPS.VIBRATION)
	self.vibrationSpinner.OnChanged =
		function( _, data )
			self.working.vibration = data
			--self:Apply()
			self:UpdateMenu()
		end

	self.passwordSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.SHOWPASSWORD, enableDisableOptions, STRINGS.UI.OPTIONS.TOOLTIPS.SHOWPASSWORD)
	self.passwordSpinner.OnChanged =
		function( _, data )
			self.working.showpassword = data
			--self:Apply()
			self:UpdateMenu()
		end

	self.profanityfilterSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.SERVER_NAME_PROFANITY_FILTER, enableDisableOptions, STRINGS.UI.OPTIONS.TOOLTIPS.SERVER_NAME_PROFANITY_FILTER)
	self.profanityfilterSpinner.OnChanged =
		function( _, data )
			self.working.profanityfilterservernames = data
			--self:Apply()
			self:UpdateMenu()
		end

	if not TheSim:IsSteamChinaClient() then
		self.profanityfilterchatSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.SERVER_NAME_PROFANITY_CHAT_FILTER, enableDisableOptions, STRINGS.UI.OPTIONS.TOOLTIPS.SERVER_NAME_PROFANITY_CHAT_FILTER)
		self.profanityfilterchatSpinner.OnChanged =
			function( _, data )
				self.working.profanityfilterchat = data
				--self:Apply()
				self:UpdateMenu()
			end
	end

	self.boatcameraSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.BOATCAMERA, enableDisableOptions, STRINGS.UI.OPTIONS.TOOLTIPS.BOATCAMERA)
	self.boatcameraSpinner.OnChanged =
		function( _, data )
			self.working.boatcamera = data
			--self:Apply()
			self:UpdateMenu()
		end

	self.integratedbackpackSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.BACKPACKMODE, integratedbackpackOptions, STRINGS.UI.OPTIONS.TOOLTIPS.BACKPACKMODE)
	self.integratedbackpackSpinner.OnChanged =
		function( _, data )
			self.working.integratedbackpack = data
			--self:Apply()
			self:UpdateMenu()
		end


	if self.show_datacollection then
		self.datacollectionCheckbox = CreateCheckBox(STRINGS.UI.OPTIONS.DATACOLLECTION,
			function()
				local opt_in = not TheSim:GetDataCollectionSetting()
				local str = STRINGS.UI.DATACOLLECTION_POPUP[opt_in and "OPT_IN" or "OPT_OUT"]
				TheFrontEnd:PushScreen(PopupDialogScreen( STRINGS.UI.DATACOLLECTION_POPUP.TITLE, STRINGS.UI.DATACOLLECTION_POPUP.BODY,
				{
					{
						text = str.CONTINUE,
						cb = function()
							local saved = TheSim:SetDataCollectionSetting( opt_in )
						    known_assert(saved, "AGREEMENTS_WRITE_PERMISSION")
							SimReset()
						end
					},
					{
						text = STRINGS.UI.DATACOLLECTION_POPUP.PRIVACY_PORTAL,
						cb = function()
							VisitURL("https://www.klei.com/privacy-policy")
						end
					},
					{
						text = STRINGS.UI.DATACOLLECTION_POPUP.CANCEL,
						cb = function()
							TheFrontEnd:PopScreen()
						end
					}
				},
				nil, "big", "dark_wide"))

				return not opt_in -- bit of a hack to keep the check box looking the same as it was. This works because toggling the value will reset the sim.
			end,
			TheSim:GetDataCollectionSetting(), STRINGS.UI.OPTIONS.TOOLTIPS.DATACOLLECTION)
	end

	self.deviceSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.INPUT, self.devices, STRINGS.UI.OPTIONS.TOOLTIPS.INPUT)
	self.deviceSpinner.OnChanged =
		function( _, data )
            for i, v in ipairs(self.devices) do
                if v.data ~= 0 then -- never disable the keyboard
                    TheInputProxy:EnableInputDevice(v.data, v.data == self.deviceSpinner:GetSelectedData())
                end
            end

            self.controls_header:SetString(self.deviceSpinner:GetSelectedText())

            if self.deviceSpinner:GetSelectedData() ~= 0 then
                self.kb_controllist:Hide()
                self.controller_controllist:Show()
                self.active_list = self.controller_controllist
                self.inst:DoTaskInTime(0, function() TheFrontEnd:StopTrackingMouse() end)
            else
                self.controller_controllist:Hide()
                self.kb_controllist:Show()
                self.active_list = self.kb_controllist
            end

            self:_RefreshScreenButtons()
            self:RefreshControls()
            self:MakeDirty()
		end


	self.autologinSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.AUTOLOGIN, enableDisableOptions, STRINGS.UI.OPTIONS.TOOLTIPS.AUTOLOGIN)
	self.autologinSpinner.OnChanged =
		function( _, data )
			self.working.autologin = data
			self:UpdateMenu()
		end
		
	self.autopauseSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.AUTOPAUSE, enableDisableOptions, STRINGS.UI.OPTIONS.TOOLTIPS.AUTOPAUSE)
	self.autopauseSpinner.OnChanged =
		function( _, data )
			self.working.autopause = data
			--self:Apply()
			self:UpdateMenu()
		end

	self.loadingtipsSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.LOADING_TIPS, loadingtipsOptions, STRINGS.UI.OPTIONS.TOOLTIPS.LOADING_TIPS)
	self.loadingtipsSpinner.OnChanged =
		function( _, data )
			self.working.loadingtips = data
			self:UpdateMenu()
		end

	self.left_spinners = {}
	self.right_spinners = {}

    table.insert( self.left_spinners, self.deviceSpinner )
    table.insert( self.left_spinners, self.vibrationSpinner)
    table.insert( self.left_spinners, self.fxVolume )
    table.insert( self.left_spinners, self.musicVolume )
    table.insert( self.left_spinners, self.ambientVolume )
    table.insert( self.left_spinners, self.hudSize )
    table.insert( self.left_spinners, self.craftingmenusize )
	table.insert( self.left_spinners, self.loadingtipsSpinner )
	table.insert( self.left_spinners, self.autologinSpinner )

    table.insert( self.right_spinners, self.passwordSpinner )
    table.insert( self.right_spinners, self.boatcameraSpinner )
    table.insert( self.right_spinners, self.integratedbackpackSpinner )
	if IsSteam() and not TheSim:IsSteamChinaClient() then
	    table.insert( self.right_spinners, self.profanityfilterchatSpinner )
	end
    table.insert( self.right_spinners, self.profanityfilterSpinner )
    table.insert( self.right_spinners, self.autopauseSpinner )
	table.insert( self.right_spinners, self.craftingautopauseSpinner )
	table.insert( self.right_spinners, self.craftingmenunumpinpagesSpinner )
	table.insert( self.right_spinners, self.scrapbookhuddisplaySpinner )
	
	if self.show_datacollection then
		table.insert( self.right_spinners, self.datacollectionCheckbox)
	end

	self.grid:UseNaturalLayout()
	self.grid:InitSize(2, math.max(#self.left_spinners, #self.right_spinners), 440, 40)

	local spinner_tooltip = MakeSpinnerTooltip(settingsroot)

	local spinner_tooltip_divider = settingsroot:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
	spinner_tooltip_divider:SetPosition(90, -225)

    -- Ugh. Using parent because the spinner lists contain a child of a composite widget.
	for k,v in ipairs(self.left_spinners) do
		self.grid:AddItem(v.parent, 1, k)
		AddSpinnerTooltip(v.parent, spinner_tooltip, spinner_tooltip_divider)
	end

	for k,v in ipairs(self.right_spinners) do
		self.grid:AddItem(v.parent, 2, k)
		AddSpinnerTooltip(v.parent, spinner_tooltip, spinner_tooltip_divider)
	end

    settingsroot.focus_forward = self.grid
    return settingsroot
end


-- This is the "advanced settings" tab
function OptionsScreen:_BuildAdvancedSettings()
    local advancedsettingsroot = Widget("ROOT")

    -- NOTE: if we add more options, they should be made scrollable. Look
    -- at customization screen for an example.
    self.grid_advanced = advancedsettingsroot:AddChild(Grid())
    self.grid_advanced:SetPosition(-90, 184, 0)

	--------------
	--------------
	-- SETTINGS --
	--------------
	-------------

	self.wathgrithrfontSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.WATHGRITHRFONT, enableDisableOptions, STRINGS.UI.OPTIONS.TOOLTIPS.WATHGRITHRFONT)
	self.wathgrithrfontSpinner.OnChanged =
		function( _, data )
			self.working.wathgrithrfont = data
			--self:Apply()
			self:UpdateMenu()
		end

	self.waltercameraSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.WALTERCAMERA, enableDisableOptions, STRINGS.UI.OPTIONS.TOOLTIPS.WALTERCAMERA)
	self.waltercameraSpinner.OnChanged =
		function( _, data )
			self.working.waltercamera = data
			--self:Apply()
			self:UpdateMenu()
		end

	self.poidisplaySpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.POIDISPLAY, enableDisableOptions, STRINGS.UI.OPTIONS.TOOLTIPS.POIDISPLAY)
	self.poidisplaySpinner.OnChanged =
		function( _, data )
			self.working.poidisplay = data
			--self:Apply()
			self:UpdateMenu()
		end

    self.npcchatSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.NPCCHAT, npcChatOptions, STRINGS.UI.OPTIONS.TOOLTIPS.NPCCHAT)
    self.npcchatSpinner.OnChanged = function(_, data)
        self.working.npcchat = data
        self:UpdateMenu()
    end

	self.minimapzoomcursorSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.MINIMAPZOOMCURSOR, enableDisableOptions, STRINGS.UI.OPTIONS.TOOLTIPS.MINIMAPZOOMCURSOR)
	self.minimapzoomcursorSpinner.OnChanged =
		function( _, data )
			self.working.minimapzoomcursor = data
			--self:Apply()
			self:UpdateMenu()
		end

    self.movementpredictionSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.MOVEMENTPREDICTION,
        {
            { text = STRINGS.UI.OPTIONS.MOVEMENTPREDICTION_DISABLED, data = false },
            { text = STRINGS.UI.OPTIONS.MOVEMENTPREDICTION_ENABLED, data = true },
        }, STRINGS.UI.OPTIONS.TOOLTIPS.MOVEMENTPREDICTION)
    self.movementpredictionSpinner.OnChanged =
        function(_, data)
            self.working.movementprediction = data
            self:UpdateMenu()
        end

	self.automodsSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.AUTOMODS, enableDisableOptions, STRINGS.UI.OPTIONS.TOOLTIPS.AUTOMODS)
	self.automodsSpinner.OnChanged =
		function( _, data )
			self.working.automods = data
			self:UpdateMenu()
		end

	self.animatedHeadsSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.ANIMATED_HEADS, enableDisableOptions, STRINGS.UI.OPTIONS.TOOLTIPS.ANIMATED_HEADS)
		self.animatedHeadsSpinner.OnChanged =
			function( _, data )
				self.working.animatedheads = data
				self:UpdateMenu()
			end

	self.consoleautopauseSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.CONSOLEAUTOPAUSE, enableDisableOptions, STRINGS.UI.OPTIONS.TOOLTIPS.CONSOLEAUTOPAUSE)
	self.consoleautopauseSpinner.OnChanged =
		function( _, data )
			self.working.consoleautopause = data
			--self:Apply()
			self:UpdateMenu()
		end

	self.craftingmenubufferedbuildautocloseSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.CRAFTINGMENUBUFFEREDBUILDAUTOCLOSE, enableDisableOptions, STRINGS.UI.OPTIONS.TOOLTIPS.CRAFTINGMENUBUFFEREDBUILDAUTOCLOSE)
	self.craftingmenubufferedbuildautocloseSpinner.OnChanged =
		function( _, data )
			self.working.craftingmenubufferedbuildautoclose = data
			--self:Apply()
			self:UpdateMenu()
		end

	self.craftinghintallrecipesSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.CRAFTINGHINTALLRECIPES, craftingHintOptions, STRINGS.UI.OPTIONS.TOOLTIPS.CRAFTINGHINTALLRECIPES)
	self.craftinghintallrecipesSpinner.OnChanged =
		function( _, data )
			self.working.craftinghintallrecipes = data
			--self:Apply()
			self:UpdateMenu()
		end

	self.craftingmenusensitivitySpinner = CreateNumericSpinner(STRINGS.UI.OPTIONS.CRAFTINGMENUSENSITIVITY, 0, 20, STRINGS.UI.OPTIONS.TOOLTIPS.CRAFTINGMENUSENSITIVITY)
	self.craftingmenusensitivitySpinner.OnChanged =
		function( _, data )
			self.working.craftingmenusensitivity = data
			--self:Apply()
			self:UpdateMenu()
		end
	self.inventorysensitivitySpinner = CreateNumericSpinner(STRINGS.UI.OPTIONS.INVENTORYSENSITIVITY, 0, 20, STRINGS.UI.OPTIONS.TOOLTIPS.INVENTORYSENSITIVITY)
	self.inventorysensitivitySpinner.OnChanged =
		function( _, data )
			self.working.inventorysensitivity = data
			--self:Apply()
			self:UpdateMenu()
		end

	self.minimapzoomsensitivitySpinner = CreateNumericSpinner(STRINGS.UI.OPTIONS.MINIMAPZOOMSENSITIVITY, 5, 30, STRINGS.UI.OPTIONS.TOOLTIPS.MINIMAPZOOMSENSITIVITY)
	self.minimapzoomsensitivitySpinner.OnChanged =
		function( _, data )
			self.working.minimapzoomsensitivity = data
			--self:Apply()
			self:UpdateMenu()
		end
    self.boathopdelaySpinner = CreateNumericSpinner(STRINGS.UI.OPTIONS.BOATHOPDELAY, 0, 16, STRINGS.UI.OPTIONS.TOOLTIPS.BOATHOPDELAY)
    self.boathopdelaySpinner.OnChanged =
        function( _, data )
            self.working.boathopdelay = data
            --self:Apply()
            self:UpdateMenu()
        end

	if IsSteam() then
		self.defaultcloudsavesSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.DEFAULTCLOUDSAVES, steamCloudLocalOptions, STRINGS.UI.OPTIONS.TOOLTIPS.DEFAULTCLOUDSAVES)
		self.defaultcloudsavesSpinner.OnChanged =
			function( _, data )
				self.working.defaultcloudsaves = data
				--self:Apply()
				self:UpdateMenu()
			end
	end

	self.left_spinners = {}
	self.right_spinners = {}

	if IsSteam() then
		table.insert( self.left_spinners, self.defaultcloudsavesSpinner )
	end
    table.insert( self.left_spinners, self.movementpredictionSpinner )
    table.insert( self.left_spinners, self.automodsSpinner )
	table.insert( self.left_spinners, self.animatedHeadsSpinner )
    table.insert( self.left_spinners, self.wathgrithrfontSpinner)
	table.insert( self.left_spinners, self.waltercameraSpinner)
	table.insert( self.left_spinners, self.poidisplaySpinner)
    table.insert( self.left_spinners, self.npcchatSpinner)

	table.insert( self.right_spinners, self.consoleautopauseSpinner )
	table.insert( self.right_spinners, self.craftingmenubufferedbuildautocloseSpinner )
	table.insert( self.right_spinners, self.craftinghintallrecipesSpinner )
	table.insert( self.right_spinners, self.craftingmenusensitivitySpinner )
	table.insert( self.right_spinners, self.inventorysensitivitySpinner )
	table.insert( self.right_spinners, self.minimapzoomcursorSpinner )
	table.insert( self.right_spinners, self.minimapzoomsensitivitySpinner )
	table.insert( self.right_spinners, self.boathopdelaySpinner )
	
	self.grid_advanced:UseNaturalLayout()
	self.grid_advanced:InitSize(2, math.max(#self.left_spinners, #self.right_spinners), 440, 40)

	local spinner_tooltip = MakeSpinnerTooltip(advancedsettingsroot)

	local spinner_tooltip_divider = advancedsettingsroot:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
	spinner_tooltip_divider:SetPosition(90, -225)

    -- Ugh. Using parent because the spinner lists contain a child of a composite widget.
	for k,v in ipairs(self.left_spinners) do
		self.grid_advanced:AddItem(v.parent, 1, k)
		AddSpinnerTooltip(v.parent, spinner_tooltip, spinner_tooltip_divider)
	end

	for k,v in ipairs(self.right_spinners) do
		self.grid_advanced:AddItem(v.parent, 2, k)
		AddSpinnerTooltip(v.parent, spinner_tooltip, spinner_tooltip_divider)
	end

    advancedsettingsroot.focus_forward = self.grid_advanced
    return advancedsettingsroot
end

function OptionsScreen:_PopulateLayout(root,device)
    local layout = root:AddChild(Widget("layout"))
    local image = nil
	local LEFT_SIDE = -415
	local RIGHT_SIDE = 415
	local LEFT_SIDE_VITA = -415
	local RIGHT_SIDE_VITA = 420
	local LABEL_WIDTH = 320
	local LABEL_HEIGHT = 50
	local font_size = LANGUAGE.RUSSIAN == LOC.GetLanguage() and 30 or 26
	local CONTROLLER_IMAGES = {
	    [DEVICE_DUALSHOCK4] = "controls_image_ds4.tex",
	    [DEVICE_VITA] = "controls_image_vita.tex",
	    [DEVICE_XBONE] = "controls_image_xb1.tex",
	    [DEVICE_SWITCH] = "controls_image_nx.tex",            
	}
	local LABELS = {
	    [DEVICE_DUALSHOCK4] = {
	        { x = 20,        y = 275,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.TOUCHPAD },
	        { x = 80,        y = 275,  anchor = ANCHOR_LEFT,  text = STRINGS.UI.CONTROLSSCREEN.PS4.OPTIONS },

	        { x = LEFT_SIDE, y = 255,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.L2 },
	        { x = LEFT_SIDE, y = 155,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.L1 },

	        { x = LEFT_SIDE, y = 55,   anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.DPAD_UP },
	        { x = LEFT_SIDE, y = 15,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.DPAD_LEFT },
	        { x = LEFT_SIDE, y = -20,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.DPAD_BOTTOM },
	        { x = LEFT_SIDE, y = -65, anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.DPAD_RIGHT, multiline=true },

	        { x = LEFT_SIDE, y = -210, anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.LSTICK },
	--        { x = LEFT_SIDE, y = -170, anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.L3 },

	        { x = RIGHT_SIDE, y = 255,  anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.R2 },
	        { x = RIGHT_SIDE, y = 155,  anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.R1 },

	        { x = RIGHT_SIDE, y = 65,   anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.TRIANGLE },
	        { x = RIGHT_SIDE, y = 20,  anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.CIRCLE },
	        { x = RIGHT_SIDE, y = -20,  anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.CROSS },
	        { x = RIGHT_SIDE, y = -65, anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.SQUARE },

	        { x = RIGHT_SIDE, y = -210, anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.RSTICK },
	        { x = RIGHT_SIDE, y = -165, anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.R3 },
	    },
	    [DEVICE_VITA] = {
	        { x = 28,              y =  190, anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.VITA.TOUCHPAD },
	        { x = RIGHT_SIDE_VITA, y = -135, anchor = ANCHOR_LEFT,  text = STRINGS.UI.CONTROLSSCREEN.VITA.OPTIONS },

	        { x = LEFT_SIDE_VITA,  y = 230,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.VITA.L1 },
	--        { x = LEFT_SIDE_VITA,  y =-208,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.VITA.L3 },
	        { x = LEFT_SIDE_VITA,  y = 180,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.VITA.L2 },

	        { x = LEFT_SIDE_VITA,  y = 60,   anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.VITA.DPAD_UP },
	        { x = LEFT_SIDE_VITA,  y =  5,   anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.VITA.DPAD_LEFT },
	        { x = LEFT_SIDE_VITA,  y = -35,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.VITA.DPAD_BOTTOM },
	        { x = LEFT_SIDE_VITA,  y = 100,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.VITA.DPAD_RIGHT },

	        { x = LEFT_SIDE_VITA,  y = -85,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.VITA.LSTICK },

	        { x = RIGHT_SIDE_VITA, y = 230,  anchor = ANCHOR_LEFT,  text = STRINGS.UI.CONTROLSSCREEN.VITA.R1 },
	        { x = RIGHT_SIDE_VITA, y =-208,  anchor = ANCHOR_LEFT,  text = STRINGS.UI.CONTROLSSCREEN.VITA.R3, multiline=true },
	        { x = RIGHT_SIDE_VITA, y = 180,  anchor = ANCHOR_LEFT,  text = STRINGS.UI.CONTROLSSCREEN.VITA.R2 },

	        { x = RIGHT_SIDE_VITA, y =  55,  anchor = ANCHOR_LEFT,  text = STRINGS.UI.CONTROLSSCREEN.VITA.TRIANGLE },
	        { x = RIGHT_SIDE_VITA, y =  10,  anchor = ANCHOR_LEFT,  text = STRINGS.UI.CONTROLSSCREEN.VITA.CIRCLE },
	        { x = RIGHT_SIDE_VITA, y = -35,  anchor = ANCHOR_LEFT,  text = STRINGS.UI.CONTROLSSCREEN.VITA.CROSS },
	        { x = RIGHT_SIDE_VITA, y =  95,  anchor = ANCHOR_LEFT,  text = STRINGS.UI.CONTROLSSCREEN.VITA.SQUARE },

	        { x = RIGHT_SIDE_VITA, y = -88, anchor = ANCHOR_LEFT,  text = STRINGS.UI.CONTROLSSCREEN.VITA.RSTICK },
	    },
	    [DEVICE_XBONE] = {
	        { x = -20,        y = 275,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.TOUCHPAD },
	        { x = 30,        y = 275,  anchor = ANCHOR_LEFT,  text = STRINGS.UI.CONTROLSSCREEN.PS4.OPTIONS },

	        { x = LEFT_SIDE, y = 255,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.L2 },
	        { x = LEFT_SIDE, y = 205,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.L1 },

	        { x = LEFT_SIDE, y = 30,   anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.DPAD_UP },
	        { x = LEFT_SIDE, y = -7,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.DPAD_LEFT },
	        { x = LEFT_SIDE, y = -42,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.DPAD_BOTTOM },
	        { x = LEFT_SIDE, y = -90, anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.DPAD_RIGHT },

	        { x = LEFT_SIDE, y = 100, anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.LSTICK },
	        --{ x = LEFT_SIDE, y = 100, anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.L3 },

	        { x = RIGHT_SIDE, y = 255,  anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.R2 },
	        { x = RIGHT_SIDE, y = 205,  anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.R1 },

	        { x = RIGHT_SIDE, y = 140,   anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.TRIANGLE },
	        { x = RIGHT_SIDE, y = 100,  anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.CIRCLE },
	        { x = RIGHT_SIDE, y = 55,  anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.CROSS },
	        { x = RIGHT_SIDE, y = 0, anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.SQUARE },

	        { x = RIGHT_SIDE, y = -185, anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.RSTICK },
	        { x = RIGHT_SIDE, y = -130, anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.R3 },
	    },
	    [DEVICE_SWITCH] = {
	        { x = -20,        y = 275,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.TOUCHPAD },
	        { x = 30,        y = 275,  anchor = ANCHOR_LEFT,  text = STRINGS.UI.CONTROLSSCREEN.PS4.OPTIONS },
	        { x = LEFT_SIDE, y = 255,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.L2 },
	        { x = LEFT_SIDE, y = 205,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.L1 },
	        { x = LEFT_SIDE, y = 30,   anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.DPAD_UP },
	        { x = LEFT_SIDE, y = -7,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.DPAD_LEFT },
	        { x = LEFT_SIDE, y = -42,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.DPAD_BOTTOM },
	        { x = LEFT_SIDE, y = -90, anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.DPAD_RIGHT },
	        { x = LEFT_SIDE, y = 100, anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.LSTICK },
	        --{ x = LEFT_SIDE, y = 100, anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.L3 },
	        { x = RIGHT_SIDE, y = 255,  anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.R2 },
	        { x = RIGHT_SIDE, y = 205,  anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.R1 },
	        { x = RIGHT_SIDE, y = 140,   anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.TRIANGLE },
	        { x = RIGHT_SIDE, y = 100,  anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.CIRCLE },
	        { x = RIGHT_SIDE, y = 55,  anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.CROSS },
	        { x = RIGHT_SIDE, y = 0, anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.SQUARE },
	        { x = RIGHT_SIDE, y = -185, anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.RSTICK },
	        { x = RIGHT_SIDE, y = -130, anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.R3 },
	    }
	}
    if PLATFORM_LAYOUT == "XBONE" then
        image = layout:AddChild( Image( "images/xb1_controllers.xml", CONTROLLER_IMAGES[device] ) )
    elseif PLATFORM_LAYOUT == "SWITCH" then
        image = layout:AddChild( Image( "images/nx_controllers.xml", CONTROLLER_IMAGES[device] ) )
    elseif PLATFORM_LAYOUT == "PS4" then
        image = layout:AddChild( Image( "images/ps4_controllers.xml", CONTROLLER_IMAGES[device] ) )
    end
    image:SetPosition( 12,0,0 )
    for _, v in pairs(LABELS[device]) do
        local label
        if JapaneseOnPS4() then
            label = layout:AddChild(Text(HEADERFONT, font_size * 0.7))
        else
            label = layout:AddChild(Text(HEADERFONT, font_size))
        end
        label:SetString(v.text)
        label:SetRegionSize( LABEL_WIDTH, v.multiline and (LABEL_HEIGHT * 2) or LABEL_HEIGHT )
        label:SetHAlign(v.anchor)
		label:EnableWordWrap(true)
		label:SetColour(UICOLOURS.GOLD)
        if v.anchor == ANCHOR_RIGHT then
            label:SetPosition(v.x - LABEL_WIDTH/2 - 8, v.y, 0)
        else
            label:SetPosition(v.x + LABEL_WIDTH/2, v.y, 0)
        end
    end
    return layout
end

-- This is the "controller" tab for console
function OptionsScreen:_BuildController()
    local controlsroot = Widget("ROOT")
	
	self.layouts = {}
	if PLATFORM_LAYOUT == "PS4" then -- TODO vita?
	    self.layouts[DEVICE_DUALSHOCK4] = self:_PopulateLayout(controlsroot,DEVICE_DUALSHOCK4)
	    self.layouts[DEVICE_DUALSHOCK4]:Hide()
	    self.layouts[DEVICE_DUALSHOCK4]:SetPosition(65,-50,0)
	    self.layouts[DEVICE_DUALSHOCK4]:SetScale(0.6)

	    self.layouts[DEVICE_VITA] = self:_PopulateLayout(controlsroot,DEVICE_VITA)
	    self.layouts[DEVICE_VITA]:Hide()
	    self.layouts[DEVICE_VITA]:SetPosition(65,-40,0)
		self.layouts[DEVICE_VITA]:SetScale(0.6)
	end

	if PLATFORM_LAYOUT == "XBONE" then
	    self.layouts[DEVICE_XBONE] = self:_PopulateLayout(controlsroot,DEVICE_XBONE)
	    self.layouts[DEVICE_XBONE]:Hide()
	    self.layouts[DEVICE_XBONE]:SetPosition(65,-50,0)
	    self.layouts[DEVICE_XBONE]:SetScale(0.6)
	end

	if PLATFORM_LAYOUT == "SWITCH" then
	    self.layouts[DEVICE_SWITCH] = self:_PopulateLayout(controlsroot,DEVICE_SWITCH)
	    self.layouts[DEVICE_SWITCH]:Hide()
	    self.layouts[DEVICE_SWITCH]:SetPosition(65,-50,0)
	    self.layouts[DEVICE_SWITCH]:SetScale(0.6)
	end
    local device = nil
	if PLATFORM_LAYOUT == "PS4" then
		device = TheInputProxy:GetInputDeviceType(0) == DEVICE_VITA and DEVICE_VITA or DEVICE_DUALSHOCK4
	elseif PLATFORM_LAYOUT == "XBONE" then
    	device = DEVICE_XBONE
    elseif PLATFORM_LAYOUT == "SWITCH" then
    	device = DEVICE_SWITCH
    end
    self.device = device
    self.layouts[device]:Show()

	-- Options

	self.InvertCameraRotationSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.INVERTCAMERAROTATION, invertDisableOptions, STRINGS.UI.OPTIONS.TOOLTIPS.INVERTCAMERAROTATION)
	self.InvertCameraRotationSpinner.OnChanged =
		function( _, data )
			self.working.InvertCameraRotation = data
			--self:Apply()
			self:UpdateMenu()
		end


	self.left_spinners = {}
	table.insert( self.left_spinners, self.InvertCameraRotationSpinner )
	
	self.grid_controller = controlsroot:AddChild(Grid())
	self.grid_controller:UseNaturalLayout()
	--self.grid_controller:InitSize(2, math.max(#self.left_spinners, #self.right_spinners), 440, 40)
    --self.grid_controller:SetPosition(-90, 184)
	self.grid_controller:InitSize(1, #self.left_spinners, 440, 40)
    self.grid_controller:SetPosition(120, 184)

	local spinner_tooltip = MakeSpinnerTooltip(controlsroot)

	local spinner_tooltip_divider = controlsroot:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
	spinner_tooltip_divider:SetPosition(90, -225)

    -- Ugh. Using parent because the spinner lists contain a child of a composite widget.
	for k,v in ipairs(self.left_spinners) do
		self.grid_controller:AddItem(v.parent, 1, k)
		AddSpinnerTooltip(v.parent, spinner_tooltip, spinner_tooltip_divider)
	end

	--for k,v in ipairs(self.right_spinners) do
	--	self.grid_controller:AddItem(v.parent, 2, k)
	--	AddSpinnerTooltip(v.parent, spinner_tooltip, spinner_tooltip_divider)
	--end

    controlsroot.focus_forward = self.grid_controller


    return controlsroot
end

-- This is the "controls" tab
function OptionsScreen:_BuildControls()
    local controlsroot = Widget("ROOT")

    controlsroot:SetPosition(290,-20)

	self.controls_horizontal_line = controlsroot:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
    self.controls_horizontal_line:SetScale(.9)
    self.controls_horizontal_line:SetPosition(-210, 175)

	--------------
	--------------
	-- CONTROLS --
	--------------
	--------------

	local button_x = -371 -- x coord of the left edge
    local button_width = controls_ui.action_btn_width
    local button_height = controls_ui.action_height
    local spacing = 15
    local function BuildControlGroup(is_valid_fn, device_type, initial_device_id, control, index)

        if control and control[device_type] then

            local group = Widget("control"..index)
            group.bg = group:AddChild(TEMPLATES.ListItemBackground(700, button_height))
            group.bg:SetPosition(-60,0)
			if device_type == "keyboard" then
	            group.bg:SetScale(1.025, 1)
			end
            group:SetScale(1,1,0.75)

            group.device_type = device_type
            group.control = control
            group.controlName = control.name
            group.controlId = control[device_type]

            local x = button_x

            group.label = group:AddChild(Text(CHATFONT, 28))
            local ctrlString = STRINGS.UI.CONTROLSSCREEN.CONTROLS[group.controlName+1]
            group.label:SetString(ctrlString)
            group.label:SetHAlign(ANCHOR_LEFT)
            group.label:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
            group.label:SetRegionSize(controls_ui.action_label_width, 50)
            x = x + controls_ui.action_label_width/2
            group.label:SetPosition(x,0)
            x = x + controls_ui.action_label_width/2 + spacing
            group.label:SetClickable(false)

            x = x + button_width/2
            group.changed_image = group:AddChild(Image("images/global_redux.xml", "wardrobe_spinner_bg.tex"))
            group.changed_image:SetTint(1,1,1,0.3)
            group.changed_image:ScaleToSize(button_width, button_height)
            group.changed_image:SetPosition(x,0)
            group.changed_image:Hide()

            group.binding_btn = group:AddChild(ImageButton("images/global_redux.xml", "blank.tex", "spinner_focus.tex"))
            group.binding_btn:ForceImageSize(button_width, button_height)
            group.binding_btn:SetTextColour(UICOLOURS.GOLD_CLICKABLE)
            group.binding_btn:SetTextFocusColour(UICOLOURS.GOLD_FOCUS)
            group.binding_btn:SetFont(CHATFONT)
            group.binding_btn:SetTextSize(30)
            group.binding_btn:SetPosition(x,0)
            group.binding_btn.idx = index
            group.binding_btn:SetOnClick(
                function()
                    local device_id = self.deviceSpinner:GetSelectedData()
                    if is_valid_fn(device_id) then
                        self:MapControl(device_id, group.controlId)
                    end
                end)
            x = x + button_width/2 + spacing

            group.binding_btn:SetHelpTextMessage(STRINGS.UI.CONTROLSSCREEN.CHANGEBIND)
            group.binding_btn:SetDisabledFont(CHATFONT)
            if group.controlId then
                group.binding_btn:SetText(initial_device_id and TheInput:GetLocalizedControl(initial_device_id, group.controlId) or "")
            end

			if device_type == "keyboard" then
				group.unbinding_btn = group:AddChild(ImageButton("images/global_redux.xml", "close.tex", "close.tex"))
				group.unbinding_btn:SetOnClick(
					function()
						local device_id = self.deviceSpinner:GetSelectedData()
						if is_valid_fn(device_id) then
							self.is_mapping = true
							if not TheInputProxy:UnMapControl(device_id, group.control.keyboard) then
								self.is_mapping = false
							end
						end
					end)
				group.unbinding_btn:SetPosition(x - 5,0)
				group.unbinding_btn:SetScale(0.4, 0.4)
				group.unbinding_btn:SetHoverText(STRINGS.UI.CONTROLSSCREEN.UNBIND)
			end

            group.focus_forward = group.binding_btn

            return group
        end
    end

    self.kb_controlwidgets = {}
    self.controller_controlwidgets = {}

    for i,v in ipairs(all_controls) do
		local function is_valid_keyboard(device_id) return device_id == 0 and all_controls[i] and all_controls[i].keyboard end
        local group = BuildControlGroup(is_valid_keyboard, "keyboard", 0, all_controls[i], i)
        if group then
            group.binding_btn:SetHelpTextMessage(STRINGS.UI.CONTROLSSCREEN.CHANGEBIND)

            table.insert(self.kb_controlwidgets, group)
        end
    end


    -- Try really hard to find a good initial value for gamepad device.
    local deviceId = self.deviceSpinner:GetSelectedData()
    local controllerDeviceId =
        (deviceId ~= 0 and deviceId) or
        (self.deviceSpinner.options[2] ~= nil and self.deviceSpinner.options[2].data) or
        nil

    for i,v in ipairs(all_controls) do
        local function is_valid_controller(device_id) return device_id and device_id ~= 0 and all_controls[i] and all_controls[i].controller end
        local group = BuildControlGroup(is_valid_controller, "controller", controllerDeviceId, all_controls[i], i)
        if group then
            group.binding_btn.OnControl =
                function( _, control, down)
					if group.binding_btn._base.OnControl(group.binding_btn, control, down) then return true end

                    local device_id = self.deviceSpinner:GetSelectedData()
					if not self.is_mapping and device_id ~= 0 then
						if not down and control == CONTROL_MENU_MISC_2 then
							-- Unbind the game control
                            self.is_mapping = true
							if not TheInputProxy:UnMapControl(device_id, group.control.controller) then
								self.is_mapping = false
							end

							return true
						end
					end
                end
           group.binding_btn.GetHelpText =
				function()
					local controller_id = TheInput:GetControllerID()
					local t = {}
					table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2, false, false ) .. " " .. STRINGS.UI.CONTROLSSCREEN.UNBIND)
					table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT, false, false ) .. " " .. STRINGS.UI.CONTROLSSCREEN.CHANGEBIND)
					return table.concat(t, "  ")
				end

            table.insert(self.controller_controlwidgets, group)
        end
    end

    local align_to_scroll = controlsroot:AddChild(Widget(""))
    align_to_scroll:SetPosition(-160, 200) -- hand-tuned amount that aligns with scrollablelist

    local x = button_x
    x = x + controls_ui.action_label_width/2
	self.actions_header = align_to_scroll:AddChild(Text(HEADERFONT, 30, STRINGS.UI.OPTIONS.ACTION))
	self.actions_header:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
	self.actions_header:SetPosition(x-20, 0) -- move a bit towards text
	self.actions_header:SetRegionSize(controls_ui.action_label_width, 50)
    self.actions_header:SetHAlign(ANCHOR_MIDDLE)
    x = x + controls_ui.action_label_width/2

    self.controls_vertical_line = align_to_scroll:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
    self.controls_vertical_line:SetScale(.7, .43)
    self.controls_vertical_line:SetRotation(90)
    self.controls_vertical_line:SetPosition(x, -200)
    self.controls_vertical_line:SetTint(1,1,1,.1)
    x = x + spacing

    x = x + button_width/2
    self.controls_header = align_to_scroll:AddChild(Text(HEADERFONT, 30))
    self.controls_header:SetString(self.deviceSpinner:GetSelectedText())
    self.controls_header:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
    self.controls_header:SetPosition(x, 0)
    x = x + button_width/2 + spacing

    local function CreateScrollableList(items)
        local width = controls_ui.action_label_width + spacing + controls_ui.action_btn_width
        return ScrollableList(items, width/2, 420, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "GOLD")
    end
	self.kb_controllist = controlsroot:AddChild(CreateScrollableList(self.kb_controlwidgets))
	self.kb_controllist:SetPosition(0, -50)
    self.controller_controllist = controlsroot:AddChild(CreateScrollableList(self.controller_controlwidgets))
    self.controller_controllist:SetPosition(0, -50)

    controlsroot.focus_forward = function()
        return self.active_list
    end
    return controlsroot
end


function OptionsScreen:InitializeSpinners(first)
	if show_graphics then
		self.fullscreenSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.fullscreen ) )
		self:UpdateDisplaySpinner()
		self:UpdateResolutionsSpinner()
		self:UpdateRefreshRatesSpinner()
		self.smallTexturesSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.smalltextures ) )
		self.netbookModeSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.netbookmode ) )

		if APP_ARCHITECTURE == "x32" and not self.working.texturestreaming then
			self.smallTexturesSpinner:UpdateText(STRINGS.UI.OPTIONS.ENABLED)
			self.smallTexturesSpinner:Disable()
		end
	end

	--[[if PLATFORM == "WIN32_STEAM" and not self.in_game then
		self.steamcloudSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.steamcloud ) )
	end
	--]]

	self.bloomSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.bloom ) )
	self.distortionSpinner:SetSelectedIndex( FindDistortionLevelOptionsIndex( self.working.distortion_modifier ) )
	self.screenshakeSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.screenshake ) )

	for i,v in ipairs(self.devices) do
		if TheInputProxy:IsInputDeviceEnabled(v.data) then
			self.deviceSpinner:SetSelectedIndex(i)
		end
	end

	local spinners = { fxvolume = self.fxVolume, musicvolume = self.musicVolume, ambientvolume = self.ambientVolume }
	for key, spinner in pairs( spinners ) do
		local volume = self.working[ key ] or 7
		spinner:SetSelectedIndex( math.floor( volume + 0.5 ) )
	end

	self.hudSize:SetSelectedIndex( self.working.hudSize or 5)
	self.craftingmenusize:SetSelectedIndex( self.working.craftingmenusize or 5)
	self.craftingmenunumpinpagesSpinner:SetSelectedIndex( self.working.craftingmenunumpinpages or 3)
	self.craftingmenusensitivitySpinner:SetSelectedIndex( self.working.craftingmenusensitivity or 12)
	self.inventorysensitivitySpinner:SetSelectedIndex( self.working.inventorysensitivity or 16)
	self.minimapzoomsensitivitySpinner:SetSelectedIndex( self.working.minimapzoomsensitivity or 15)
	self.boathopdelaySpinner:SetSelectedIndex( self.working.boathopdelay or 8)
	self.screenFlashSpinner:SetSelectedIndex( FindEnableScreenFlashOptionsIndex( self.working.screenflash ) )
	self.vibrationSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.vibration ) )
	self.passwordSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.showpassword ) )
	self.profanityfilterSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.profanityfilterservernames ) )
	if not TheSim:IsSteamChinaClient() then
		self.profanityfilterchatSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.profanityfilterchat ) )
	end
	self.scrapbookhuddisplaySpinner:SetSelectedIndex( EnabledOptionsIndex(self.working.scrapbookhuddisplay))
    self.movementpredictionSpinner:SetSelectedIndex(EnabledOptionsIndex(self.working.movementprediction))
	self.wathgrithrfontSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.wathgrithrfont ) )
	self.waltercameraSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.waltercamera ) )
	self.poidisplaySpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.poidisplay ) )
    self.npcchatSpinner:SetSelectedIndex( FindNPCChatOptionsIndex(self.working.npcchat) )
	self.minimapzoomcursorSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.minimapzoomcursor ) )
	self.boatcameraSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.boatcamera ) )
	self.integratedbackpackSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.integratedbackpack ) )
	self.texturestreamingSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.texturestreaming ) )
	if IsWin32() then
		self.threadedrenderSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.threadedrender ) )
	end
	if IsConsoleLayout() then
		self.InvertCameraRotationSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.InvertCameraRotation ) )
	end
	self.dynamicTreeShadowsSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.dynamictreeshadows ) )

	if self.show_datacollection then
		--self.datacollectionCheckbox: -- the current behaviour does not reuqire this to be (re)initialized at any point after construction
	end

	self.automodsSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.automods ) )
	self.autologinSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.autologin ) )
	self.animatedHeadsSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.animatedheads ) )
	self.autopauseSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.autopause ) )
	self.consoleautopauseSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.consoleautopause ) )
	self.craftingautopauseSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.craftingautopause ) )
	self.craftingmenubufferedbuildautocloseSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.craftingmenubufferedbuildautoclose ) )
	self.craftinghintallrecipesSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.craftinghintallrecipes ) )
	self.loadingtipsSpinner:SetSelectedIndex( self.working.loadingtips or LOADING_SCREEN_TIP_OPTIONS.ALL )
	if IsSteam() then
		self.defaultcloudsavesSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.defaultcloudsaves ) )
	end

	if first then
		-- Add the bg change when non-init value for all spinners
        local function SetupOnChange(i,spinner)
			if spinner and spinner.GetSelectedIndex ~= nil then
				spinner.default_index = spinner:GetSelectedIndex()
                spinner:EnablePendingModificationBackground()

				local spinOnChanged = spinner.OnChanged
				spinner.OnChanged = function(_, data)
					spinOnChanged(_, data)
					spinner:SetHasModification(spinner:GetSelectedIndex() ~= spinner.default_index)
				end
			end
        end
		for i,spinner in pairs(self.left_spinners) do
            SetupOnChange(i,spinner)
		end

		for i,spinner in pairs(self.right_spinners) do
            SetupOnChange(i,spinner)
		end

		for i,spinner in pairs(self.left_spinners_graphics) do
            SetupOnChange(i,spinner)
		end

		for i,spinner in pairs(self.right_spinners_graphics) do
            SetupOnChange(i,spinner)
		end
	end
end

function OptionsScreen:UpdateDisplaySpinner()
	if show_graphics then
		local graphicsOptions = TheFrontEnd:GetGraphicsOptions()
		local display_id = graphicsOptions:GetFullscreenDisplayID() + 1
		self.displaySpinner:SetSelectedIndex( display_id )
	end
end

function OptionsScreen:UpdateRefreshRatesSpinner()
	if show_graphics then
		local current_refresh_rate = self.working.refreshrate

		local refresh_rates = GetRefreshRates( self.working.display, self.working.mode_idx )
		self.refreshRateSpinner:SetOptions( refresh_rates )
		self.refreshRateSpinner:SetSelectedIndex( 1 )

		for idx, refresh_rate_data in ipairs( refresh_rates ) do
			if refresh_rate_data.data == current_refresh_rate then
				self.refreshRateSpinner:SetSelectedIndex( idx )
				break
			end
		end

		self.working.refreshrate = self.refreshRateSpinner:GetSelected().data
	end
end

function OptionsScreen:UpdateResolutionsSpinner()
	if show_graphics then
		local resolutions = GetDisplayModes( self.working.display )
		self.resolutionSpinner:SetOptions( resolutions )

		if self.fullscreenSpinner:GetSelected().data then
			self.displaySpinner:Enable()
			self.refreshRateSpinner:Enable()
			self.resolutionSpinner:Enable()

			local spinner_idx = 1
			if self.working.mode_idx then
				local gOpts = TheFrontEnd:GetGraphicsOptions()
				local mode_idx = gOpts:GetCurrentDisplayModeID( self.options.display )
				local w, h, hz = GetDisplayModeInfo( self.working.display, mode_idx )

				for idx, option in pairs( self.resolutionSpinner.options ) do
					if option.data.w == w and option.data.h == h then
						spinner_idx = idx
						break
					end
				end
			end
			self.resolutionSpinner:SetSelectedIndex( spinner_idx )
		else
			self.displaySpinner:Disable()
			self.refreshRateSpinner:Disable()
			self.resolutionSpinner:Disable()
		end
	end
end

function OptionsScreen:OnBecomeActive()
    OptionsScreen._base.OnBecomeActive(self)

    if self.kit_puppet then
        self.kit_puppet:Enable()
    end
end

function OptionsScreen:OnBecomeInactive()
    OptionsScreen._base.OnBecomeInactive(self)

    if self.kit_puppet then
        self.kit_puppet:Disable()
    end
end

return OptionsScreen
