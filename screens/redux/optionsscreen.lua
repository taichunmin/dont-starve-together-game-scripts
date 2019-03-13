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
local MovieDialog = require "screens/moviedialog"
local CreditsScreen = require "screens/creditsscreen"
local TEMPLATES = require "widgets/redux/templates"

local controls_ui = {
    action_label_width = 375,
    action_btn_width = 250,
    action_height = 48,
}
local show_graphics = PLATFORM ~= "NACL"

local enableDisableOptions = { { text = STRINGS.UI.OPTIONS.DISABLED, data = false }, { text = STRINGS.UI.OPTIONS.ENABLED, data = true } }

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
    {name=CONTROL_INSPECT_SELF, keyboard=CONTROL_INSPECT_SELF, controller=nil},

    -- inventory
    {name=CONTROL_OPEN_CRAFTING, keyboard=CONTROL_OPEN_CRAFTING, controller=CONTROL_OPEN_CRAFTING},
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

local OptionsScreen = Class(Screen, function(self, prev_screen)
	Screen._ctor(self, "OptionsScreen")

    self.show_language_options = (prev_screen ~= nil and prev_screen.name == "MultiplayerMainScreen") and IsConsole()
	self.show_datacollection = IsSteam() and not InGamePlay()
	self.show_cinematics = not InGamePlay()

	local graphicsOptions = TheFrontEnd:GetGraphicsOptions()

	self.options = {
		fxvolume = TheMixer:GetLevel( "set_sfx" ) * 10,
		musicvolume = TheMixer:GetLevel( "set_music" ) * 10,
		ambientvolume = TheMixer:GetLevel( "set_ambience" ) * 10,
		bloom = graphicsOptions:IsBloomEnabled(),
		smalltextures = graphicsOptions:IsSmallTexturesMode(),
		distortion = graphicsOptions:IsDistortionEnabled(),
		screenshake = Profile:IsScreenShakeEnabled(),
		hudSize = Profile:GetHUDSize(),
		netbookmode = TheSim:IsNetbookMode(),
		vibration = Profile:GetVibrationEnabled(),
		showpassword = Profile:GetShowPasswordEnabled(),
        movementprediction = Profile:GetMovementPredictionEnabled(),
		automods = Profile:GetAutoSubscribeModsEnabled(),
		wathgrithrfont = Profile:IsWathgrithrFontEnabled(),
        lang_id = Profile:GetLanguageID(),
	}


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
    
	self.onlinestatus = self.root:AddChild(OnlineStatus())

    -- action menu is the bottom buttons
	self.action_menu = self.root:AddChild(self:_BuildActionMenu())
	self.action_menu:SetPosition(2, -RESOLUTION_Y*.5 + BACK_BUTTON_Y - 4,0)
	self.action_menu:SetScale(.8)
	self:MakeBackButton()
    self:_RefreshScreenButtons()

    self.dialog = self.root:AddChild(TEMPLATES.RectangleWindow(830, 450))
    self.dialog:SetPosition(140, -20)
    self.panel_root = self.dialog:AddChild(Widget("panel_root"))
    self.panel_root:SetPosition(-90, 35)


	self:DoInit()

    local menu_items = {
            -- Left menu items
            settings = self.panel_root:AddChild(self:_BuildSettings()),
            controls = self.panel_root:AddChild(self:_BuildControls()),
        }
    if self.show_language_options then
        menu_items["languages"] = self.panel_root:AddChild(self:_BuildLanguages())
    end
	if self.show_cinematics then
	    menu_items.cinematics = self.panel_root:AddChild(self:_BuildCinematics())
	end

    self.subscreener = Subscreener(self, self._BuildMenu, menu_items )
    self.subscreener:SetPostMenuSelectionAction(function(selection)
        self.selected_tab = selection
        self:UpdateMenu()
    end)

	self:InitializeSpinners(true)

	-------------------------------------------------------
	-- Must get done AFTER InitializeSpinners()
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

	---------------------------------------------------

    self.subscreener:OnMenuButtonSelected("settings")

    self:_DoFocusHookups()
	self.default_focus = self.subscreener.menu
end)

function OptionsScreen:_BuildMenu(subscreener)
    self.tooltip = self.root:AddChild(TEMPLATES.ScreenTooltip())
	
	local settings_button = subscreener:MenuButton(STRINGS.UI.OPTIONS.SETTINGS, "settings", STRINGS.UI.OPTIONS.TOOLTIP_SETTINGS, self.tooltip)
	local controls_button = subscreener:MenuButton(STRINGS.UI.OPTIONS.CONTROLS, "controls", STRINGS.UI.OPTIONS.TOOLTIP_CONTROLS, self.tooltip)
	local languages_button = nil
    if self.show_language_options then
        languages_button = subscreener:MenuButton(STRINGS.UI.OPTIONS.LANGUAGES, "languages", STRINGS.UI.OPTIONS.TOOLTIP_LANGUAGES, self.tooltip)
    end

    local menu_items = {
        {widget = controls_button},
        {widget = settings_button},
    }

    if self.show_language_options then
        table.insert( menu_items, 1, {widget = languages_button} )
    end
	if self.show_cinematics then
	    table.insert( menu_items, 1, {widget = subscreener:MenuButton(STRINGS.UI.OPTIONS.CINEMATICS, "cinematics", STRINGS.UI.OPTIONS.TOOLTIP_CINEMATICS, self.tooltip)} )
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
		elseif control == CONTROL_MAP and TheInput:ControllerAttached() then
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
	    elseif control == CONTROL_PAUSE and TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
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
					self:Apply()
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
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MAP, false, false) .. " " .. STRINGS.UI.CONTROLSSCREEN.RESET)
	end

	if self:IsDirty() then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_PAUSE) .. " " .. STRINGS.UI.HELP.APPLY)
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
	Profile:SetDistortionEnabled( self.options.distortion )
	Profile:SetScreenShakeEnabled( self.options.screenshake )
	Profile:SetWathgrithrFontEnabled( self.options.wathgrithrfont )
	Profile:SetHUDSize( self.options.hudSize )
	Profile:SetVibrationEnabled( self.options.vibration )
	Profile:SetShowPasswordEnabled( self.options.showpassword )
    Profile:SetMovementPredictionEnabled(self.options.movementprediction)
	Profile:SetAutoSubscribeModsEnabled( self.options.automods )

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

						self:Apply()
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
	gopts:SetBloomEnabled( self.working.bloom )
	gopts:SetDistortionEnabled( self.working.distortion )
	gopts:SetSmallTexturesMode( self.working.smalltextures )
	Profile:SetScreenShakeEnabled( self.working.screenshake )
	Profile:SetWathgrithrFontEnabled( self.working.wathgrithrfont )
	TheSim:SetNetbookMode(self.working.netbookmode)

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

    TheInputProxy:MapControl(deviceId, controlId)
    self.is_mapping = true
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

        elseif v.control.controller and self.deviceSpinner:GetSelectedData() and v.binding_btn then
            local controllerString = controllerDeviceId ~= nil and TheInput:GetLocalizedControl(controllerDeviceId, v.control.controller) or ""
            v.binding_btn:SetText(controllerString)
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
        else
            return self.active_list
        end
	end

    self.grid:SetFocusChangeDir(MOVE_RIGHT, self.action_menu)
    self.controller_controllist:SetFocusChangeDir(MOVE_RIGHT, self.action_menu)
    self.kb_controllist:SetFocusChangeDir(MOVE_RIGHT, self.action_menu)

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

-- This is the "languages" tab
function OptionsScreen:_BuildLanguages()
    local languagesRoot = Widget("ROOT")
    
    languagesRoot:SetPosition(0,0)
    
    local button_width = 430
    local button_height = 45

    self.langtitle = languagesRoot:AddChild(BuildSectionTitle(STRINGS.UI.OPTIONS.LANG_TITLE, 200))
    self.langtitle:SetPosition(92, 160)

    self.langButtons = {}

    self.lang_grid = languagesRoot:AddChild(Grid())
    self.lang_grid:SetPosition(-125, 90)
    for _,id in pairs(LOC.GetLanguages()) do
        table.insert(self.langButtons, self:_BuildLangButton(button_width, button_height, id))
    end
    self.lang_grid:FillGrid(2, button_width, button_height, self.langButtons)
    
    languagesRoot.focus_forward = self.lang_grid

    return languagesRoot
end

function OptionsScreen:_BuildCinematics()
    local root = Widget("ROOT")
    
    root:SetPosition(85,0)

    local scale = 0.6
    local button_width = 432 * scale
    local button_height = 90 * scale

    local title = root:AddChild(BuildSectionTitle(STRINGS.UI.OPTIONS.CINEMATICS, 200))
    title:SetPosition(0, 160)

    self.buttons = {}

	local function OnMovieDone()
		TheFrontEnd:GetSound():PlaySound(FE_MUSIC, "FEMusic")
		TheFrontEnd:GetSound():SetParameter("FEMusic", "fade", 0)
		TheFrontEnd:Fade(FADE_IN, 1)
		self:Show()
	end

	table.insert(self.buttons, TEMPLATES.StandardButton(function()
			TheFrontEnd:GetSound():KillSound("FEMusic")
			if self.debug_menu then self.debug_menu:Disable() end
			TheFrontEnd:FadeToScreen( self, function() return MovieDialog("movies/intro.ogv", OnMovieDone) end, nil )
		end,
		STRINGS.UI.OPTIONS.INTRO_MOVIE, {button_width, button_height})
	)
	table.insert(self.buttons, TEMPLATES.StandardButton(function()
			TheFrontEnd:GetSound():KillSound("FEMusic")
			if self.debug_menu then self.debug_menu:Disable() end
			TheFrontEnd:FadeToScreen( self, function() return CreditsScreen() end, nil )
		end,
		STRINGS.UI.OPTIONS.CREDITS, {button_width, button_height})
	)
	
	if IsSteam() then
		table.insert(self.buttons, TEMPLATES.StandardButton(function() VisitURL("https://www.youtube.com/channel/UCzbYAkDCuQYdZ_fKz9MLrWA") end, STRINGS.UI.OPTIONS.VIDEO_CHANNEL, {button_width, button_height}))
	end
	
    self.grid = root:AddChild(Grid())
    self.grid:SetPosition(0, 90)

    self.grid:FillGrid(1, button_width, button_height, self.buttons)
    
    root.focus_forward = self.grid

    return root
end

-- This is the "settings" tab
function OptionsScreen:_BuildSettings()
    local settingsroot = Widget("ROOT")

    -- NOTE: if we add more options, they should be made scrollable. Look
    -- at customization screen for an example.
    self.grid = settingsroot:AddChild(Grid())
    self.grid:SetPosition(-90, 144, 0)


	--------------
	--------------
	-- SETTINGS --
	--------------
	--------------

	local this = self

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

    local function CreateTextSpinner(labeltext, spinnerdata)
        local w = TEMPLATES.LabelSpinner(labeltext, spinnerdata, label_width, spinner_width, spinner_height, space_between, nil, nil, narrow_field_nudge)
        AddListItemBackground(w)
        return w.spinner
    end

    local function CreateNumericSpinner(labeltext, min, max)
        local w = TEMPLATES.LabelNumericSpinner(labeltext, min, max, label_width, spinner_width, spinner_height, space_between, nil, nil, narrow_field_nudge)
        AddListItemBackground(w)
        return w.spinner
    end

    local function CreateCheckBox(labeltext, onclicked, checked )
        local w = TEMPLATES.OptionsLabelCheckbox(onclicked, labeltext, checked, label_width, spinner_width, spinner_height, spinner_height + 15, space_between, CHATFONT, nil, narrow_field_nudge)
        AddListItemBackground(w)
        return w.button
    end

	if show_graphics then
		local gOpts = TheFrontEnd:GetGraphicsOptions()
											
		self.fullscreenSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.FULLSCREEN, enableDisableOptions)
		self.fullscreenSpinner.OnChanged =
			function( _, data )
				this.working.fullscreen = data
				this:UpdateResolutionsSpinner()
				self:UpdateMenu()				
			end
		if gOpts:IsFullScreenEnabled() then
			self.fullscreenSpinner:Enable()
		else
			self.fullscreenSpinner:Disable()
		end

		local valid_displays = GetDisplays()
		self.displaySpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.DISPLAY, valid_displays)
		self.displaySpinner.OnChanged =
			function( _, data )
				this.working.display = data
				this:UpdateResolutionsSpinner()
				this:UpdateRefreshRatesSpinner()
				self:UpdateMenu()
			end
		
		local refresh_rates = GetRefreshRates( self.working.display, self.working.mode_idx )
		self.refreshRateSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.REFRESHRATE, refresh_rates) 
		self.refreshRateSpinner.OnChanged =
			function( _, data )
				this.working.refreshrate = data
				self:UpdateMenu()
			end

		local modes = GetDisplayModes( self.working.display )
		self.resolutionSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.RESOLUTION, modes)
		self.resolutionSpinner.OnChanged =
			function( _, data )
				this.working.mode_idx = data.idx
				this:UpdateRefreshRatesSpinner()
				self:UpdateMenu()
			end			
			
		self.netbookModeSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.NETBOOKMODE, enableDisableOptions)
		self.netbookModeSpinner.OnChanged =
			function( _, data )
				this.working.netbookmode = data
				--this:Apply()
				self:UpdateMenu()
			end

		self.smallTexturesSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.SMALLTEXTURES, enableDisableOptions)
		self.smallTexturesSpinner.OnChanged =
			function( _, data )
				this.working.smalltextures = data
				--this:Apply()
				self:UpdateMenu()
			end
						
	end
	
	self.bloomSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.BLOOM, enableDisableOptions)
	self.bloomSpinner.OnChanged =
		function( _, data )
			this.working.bloom = data
			--this:Apply()
			self:UpdateMenu()
		end
		
	self.distortionSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.DISTORTION, enableDisableOptions)
	self.distortionSpinner.OnChanged =
		function( _, data )
			this.working.distortion = data
			--this:Apply()
			self:UpdateMenu()
		end

	self.screenshakeSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.SCREENSHAKE, enableDisableOptions)
	self.screenshakeSpinner.OnChanged =
		function( _, data )
			this.working.screenshake = data
			--this:Apply()
			self:UpdateMenu()
		end

	self.fxVolume = CreateNumericSpinner(STRINGS.UI.OPTIONS.FX, 0, 10)
	self.fxVolume.OnChanged =
		function( _, data )
			this.working.fxvolume = data
			this:ApplyVolume()
			self:UpdateMenu()
		end

	self.musicVolume = CreateNumericSpinner(STRINGS.UI.OPTIONS.MUSIC, 0, 10)
	self.musicVolume.OnChanged =
		function( _, data )
			this.working.musicvolume = data
			this:ApplyVolume()
			self:UpdateMenu()
		end

	self.ambientVolume = CreateNumericSpinner(STRINGS.UI.OPTIONS.AMBIENT, 0, 10)
	self.ambientVolume.OnChanged =
		function( _, data )
			this.working.ambientvolume = data
			this:ApplyVolume()
			self:UpdateMenu()
		end
		
	self.hudSize = CreateNumericSpinner(STRINGS.UI.OPTIONS.HUDSIZE, 0, 10)
	self.hudSize.OnChanged =
		function( _, data )
			this.working.hudSize = data
			--this:Apply()
			self:UpdateMenu()
		end

	self.vibrationSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.VIBRATION, enableDisableOptions)
	self.vibrationSpinner.OnChanged =
		function( _, data )
			this.working.vibration = data
			--this:Apply()
			self:UpdateMenu()
		end

	self.passwordSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.SHOWPASSWORD, enableDisableOptions)
	self.passwordSpinner.OnChanged =
		function( _, data )
			this.working.showpassword = data
			--this:Apply()
			self:UpdateMenu()
		end

	self.wathgrithrfontSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.WATHGRITHRFONT, enableDisableOptions)
	self.wathgrithrfontSpinner.OnChanged =
		function( _, data )
			this.working.wathgrithrfont = data
			--this:Apply()
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
			TheSim:GetDataCollectionSetting())
	end

    self.movementpredictionSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.MOVEMENTPREDICTION,
        {
            { text = STRINGS.UI.OPTIONS.MOVEMENTPREDICTION_DISABLED, data = false },
            { text = STRINGS.UI.OPTIONS.MOVEMENTPREDICTION_ENABLED, data = true },
        },
        spinner_width, spinner_height, nil, nil, nil, nil, true, nil, nil, spinner_scale_x, spinner_scale_y)
    self.movementpredictionSpinner.OnChanged =
        function(_, data)
            this.working.movementprediction = data
            self:UpdateMenu()
        end

	self.automodsSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.AUTOMODS, enableDisableOptions)
	self.automodsSpinner.OnChanged =
		function( _, data )
			this.working.automods = data
			--this:Apply()
			self:UpdateMenu()
		end

	self.deviceSpinner = CreateTextSpinner(STRINGS.UI.OPTIONS.INPUT, self.devices)
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
		
	self.left_spinners = {}
	self.right_spinners = {}
	
    table.insert( self.left_spinners, self.deviceSpinner )
    table.insert( self.left_spinners, self.vibrationSpinner)
    table.insert( self.left_spinners, self.fxVolume )
    table.insert( self.left_spinners, self.musicVolume )
    table.insert( self.left_spinners, self.ambientVolume )
    table.insert( self.left_spinners, self.passwordSpinner)
    table.insert( self.left_spinners, self.automodsSpinner )
    table.insert( self.left_spinners, self.wathgrithrfontSpinner)
    table.insert( self.left_spinners, self.hudSize)

	if self.show_datacollection then
		table.insert( self.left_spinners, self.datacollectionCheckbox)
	end

    table.insert( self.right_spinners, self.screenshakeSpinner )
    table.insert( self.right_spinners, self.distortionSpinner )
    table.insert( self.right_spinners, self.bloomSpinner )

	if show_graphics then
		table.insert( self.right_spinners, self.fullscreenSpinner )
		table.insert( self.right_spinners, self.resolutionSpinner )
		table.insert( self.right_spinners, self.displaySpinner )
		table.insert( self.right_spinners, self.refreshRateSpinner )
		table.insert( self.right_spinners, self.smallTexturesSpinner )
		table.insert( self.right_spinners, self.netbookModeSpinner )
        table.insert( self.right_spinners, self.movementpredictionSpinner )
	end

	self.grid:UseNaturalLayout()
	self.grid:InitSize(2, 10, 440, 40)

    -- Ugh. Using parent because the spinner lists contain a child of a
    -- composite widget.
	for k,v in ipairs(self.left_spinners) do
		self.grid:AddItem(v.parent, 1, k)
	end

	for k,v in ipairs(self.right_spinners) do
		self.grid:AddItem(v.parent, 2, k)
	end

    settingsroot.focus_forward = self.grid
    return settingsroot
end

-- This is the "controls" tab
function OptionsScreen:_BuildControls()
    local controlsroot = Widget("ROOT")

    controlsroot:SetPosition(290,-40)

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

            group.focus_forward = group.binding_btn

            return group
        end
    end

    self.kb_controlwidgets = {}
    self.controller_controlwidgets = {}

    local function is_valid_keyboard(device_id) return device_id == 0 end

    for i,v in ipairs(all_controls) do
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
						    TheInputProxy:UnMapControl(device_id, group.control.controller)
	
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
        return ScrollableList(items, width/2, 330, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "GOLD")
    end
	self.kb_controllist = controlsroot:AddChild(CreateScrollableList(self.kb_controlwidgets))
    self.controller_controllist = controlsroot:AddChild(CreateScrollableList(self.controller_controlwidgets))

    controlsroot.focus_forward = function()
        return self.active_list
    end
    return controlsroot
end


local function EnabledOptionsIndex(enabled)
    return enabled and 2 or 1
end

function OptionsScreen:InitializeSpinners(first)
	if show_graphics then
		self.fullscreenSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.fullscreen ) )
		self:UpdateDisplaySpinner()
		self:UpdateResolutionsSpinner()
		self:UpdateRefreshRatesSpinner()
		self.smallTexturesSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.smalltextures ) )
		self.netbookModeSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.netbookmode ) )
	end

	--[[if PLATFORM == "WIN32_STEAM" and not self.in_game then
		self.steamcloudSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.steamcloud ) )
	end
	--]]

	self.bloomSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.bloom ) )
	self.distortionSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.distortion ) )
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
	self.vibrationSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.vibration ) )
	self.passwordSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.showpassword ) )
    self.movementpredictionSpinner:SetSelectedIndex(EnabledOptionsIndex(self.working.movementprediction))
	self.wathgrithrfontSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.wathgrithrfont ) )
	
	if self.show_datacollection then
		--self.datacollectionCheckbox: -- the current behaviour does not reuqire this to be (re)initialized at any point after construction
	end

	self.automodsSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.automods ) )

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

return OptionsScreen
