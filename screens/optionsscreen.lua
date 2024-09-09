require "util"
require "strings"
require "constants"

local Screen = require "widgets/screen"
local ImageButton = require "widgets/imagebutton"
local Menu = require "widgets/menu"
local Grid = require "widgets/grid"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Spinner = require "widgets/spinner"
local NumericSpinner = require "widgets/numericspinner"
local Widget = require "widgets/widget"
local ScrollableList = require "widgets/scrollablelist"
local PopupDialogScreen = require "screens/popupdialog"
local OnlineStatus = require "widgets/onlinestatus"
local TEMPLATES = require "widgets/templates"


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

	local graphicsOptions = TheFrontEnd:GetGraphicsOptions()

	self.options = {
		fxvolume = TheMixer:GetLevel( "set_sfx" ) * 10,
		musicvolume = TheMixer:GetLevel( "set_music" ) * 10,
		ambientvolume = TheMixer:GetLevel( "set_ambience" ) * 10,
		bloom = PostProcessor:IsBloomEnabled(),
		smalltextures = graphicsOptions:IsSmallTexturesMode(),
		distortion = PostProcessor:IsDistortionEnabled(),
		screenshake = Profile:IsScreenShakeEnabled(),
		hudSize = Profile:GetHUDSize(),
		netbookmode = TheSim:IsNetbookMode(),
		vibration = Profile:GetVibrationEnabled(),
		showpassword = Profile:GetShowPasswordEnabled(),
        movementprediction = Profile:GetMovementPredictionEnabled(),
		automods = Profile:GetAutoSubscribeModsEnabled(),
		wathgrithrfont = Profile:IsWathgrithrFontEnabled(),
	}


	--[[if PLATFORM == "WIN32_STEAM" and not self.in_game then
		self.options.steamcloud = TheSim:GetSetting("STEAM", "DISABLECLOUD") ~= "true"
	end--]]

	if show_graphics then

		self.options.display = graphicsOptions:GetFullscreenDisplayID()
		self.options.refreshrate = graphicsOptions:GetFullscreenDisplayRefreshRate()
		self.options.fullscreen = graphicsOptions:IsFullScreen()
		self.options.mode_idx = graphicsOptions:GetCurrentDisplayModeID( self.options.display )
	end

	self.working = deepcopy(self.options)

	self.is_mapping = false

    TheInputProxy:StartMappingControls()

    if prev_screen ~= nil then
        self.prev_screen = prev_screen
        prev_screen:TransferPortalOwnership(prev_screen, self)
    else
        self.bg = self:AddChild(TEMPLATES.NoPortalBackground())
        self.letterbox = self:AddChild(TEMPLATES.ForegroundLetterbox())
    end

	self.root = self:AddChild(Widget("ROOT"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetPosition(0,0,0)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.menu_bg = self.root:AddChild(TEMPLATES.LeftGradient())

	local panel_bg_frame = self.root:AddChild(TEMPLATES.CenterPanel())

	local panel_frame = panel_bg_frame:AddChild(Image("images/options.xml", "panel_frame.tex"))
	panel_frame:SetPosition(8, -20)
	panel_frame:SetScale(.69,.69)

	self.onlinestatus = self.root:AddChild(OnlineStatus())

	self.nav_bar = self.root:AddChild(TEMPLATES.NavBarWithScreenTitle(STRINGS.UI.MAINSCREEN.OPTIONS, "short"))
	self.settings_button = self.nav_bar:AddChild(TEMPLATES.NavBarButton(25, STRINGS.UI.OPTIONS.SETTINGS,function() self:SetTab("settings") end))
	self.controls_button = self.nav_bar:AddChild(TEMPLATES.NavBarButton(-25, STRINGS.UI.OPTIONS.CONTROLS,function() self:SetTab("controls") end))

	self:MakeBackButton()

	self.menu = self.root:AddChild(Menu(nil, -80, false))
	self.menu:SetPosition(2, -RESOLUTION_Y*.5 + BACK_BUTTON_Y - 4,0)
	-- self.menu:SetScale(.8)

    self.settingsroot = self.root:AddChild(self:_BuildSettings())
    self.settingsroot:SetPosition(-48, 10)
    self.controlsroot = self.root:AddChild(self:_BuildControls())
    self.controlsroot:SetPosition(-48, 10)

	self:DoInit()
	self:InitializeSpinners(true)

	-------------------------------------------------------
	-- Must get done AFTER InitializeSpinners()
    self._deviceSaved = self.deviceSpinner:GetSelectedData()
    if self._deviceSaved ~= 0 then
        self.kb_controllist:Hide()
        self.active_list = self.controller_controllist
        self.active_list:Show()
        self.controls_header:SetString(STRINGS.UI.CONTROLSSCREEN.INPUT_NAMES[self._deviceSaved])
    else
        self.controller_controllist:Hide()
        self.active_list = self.kb_controllist
        self.active_list:Show()
        self.controls_header:SetString(STRINGS.UI.CONTROLSSCREEN.INPUT_NAMES[1])
    end

	self:LoadCurrentControls()

	self.controls_horizontal_line:MoveToFront()
	self.controls_vertical_line:MoveToFront()

	---------------------------------------------------

	self:SetTab("settings")

	self.default_focus = self.settings_button
end)


-- This is the "options" tab
function OptionsScreen:_BuildSettings()
    local settingsroot = Widget("ROOT")

    settingsroot.settings_title = settingsroot:AddChild(Text(BUTTONFONT, 50, STRINGS.UI.MAINSCREEN.SETTINGS))
    settingsroot.settings_title:SetPosition(95,220)
    settingsroot.settings_title:SetColour(0,0,0,1)

    -- NOTE: if we add more options, they should be made scrollable. Look
    -- at customization screen for an example.
    self.grid = settingsroot:AddChild(Grid())
    self.grid:SetPosition(-180, 144, 0)
    return settingsroot
end

-- This is the "controls" tab
function OptionsScreen:_BuildControls()
    local controlsroot = Widget("ROOT")

    controlsroot.controls_title = controlsroot:AddChild(Text(BUTTONFONT, 50, STRINGS.UI.MAINSCREEN.CONTROLS))
    controlsroot.controls_title:SetPosition(95,220)
    controlsroot.controls_title:SetColour(0,0,0,1)

    self.controls_horizontal_line = controlsroot:AddChild(Image("images/ui.xml", "line_horizontal_5.tex"))
    self.controls_horizontal_line:SetScale(.65, .65)
    self.controls_horizontal_line:SetPosition(90, 135)

    self.controls_vertical_line = controlsroot:AddChild(Image("images/ui.xml", "line_vertical_5.tex"))
    self.controls_vertical_line:SetScale(.70, .63)
    self.controls_vertical_line:SetPosition(265, -40)
    return controlsroot
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

function OptionsScreen:SetTab(tab)
	if tab == "settings" then
		self.selected_tab = "settings"
		if self.settings_button.shown then self.settings_button:Select() end
		if self.controls_button.shown then self.controls_button:Unselect() end
		self.settingsroot:Show()
		self.controlsroot:Hide()
		-- self.grid:SetFocus()
	elseif tab == "controls" then
		self.selected_tab = "controls"
		if self.settings_button.shown then self.settings_button:Unselect() end
		if self.controls_button.shown then self.controls_button:Select() end
		self.settingsroot:Hide()
		self.controlsroot:Show()
		-- self.active_list:SetFocus()
	end
	self:UpdateMenu()
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

function OptionsScreen:Close()
	self.nav_bar:Disable()
	if TheFrontEnd:GetFadeLevel() < 1 then
		TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()
	        TheFrontEnd:PopScreen()
	        TheFrontEnd:Fade(FADE_IN, SCREEN_FADE_TIME)
	    end)
	else
		TheFrontEnd:PopScreen()
	    TheFrontEnd:Fade(FADE_IN, SCREEN_FADE_TIME)
	end
end

function OptionsScreen:ConfirmRevert()

	TheFrontEnd:PushScreen(
		PopupDialogScreen( STRINGS.UI.OPTIONS.BACKTITLE, STRINGS.UI.OPTIONS.BACKBODY,
		  {
		  	{
		  		text = STRINGS.UI.OPTIONS.YES,
		  		cb = function()
					self:RevertChanges()
					TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()
						TheFrontEnd:PopScreen()
						self:Close()
					end)
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
						TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()
							TheFrontEnd:PopScreen()
							self:Close()
						end)
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
    self:RefreshNav()
end

function OptionsScreen:MakeClean()
    self.dirty = false
    self:UpdateMenu()
    self:RefreshNav()
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
			  },
			  { timeout = 10, cb =
				function()
					self.applying = false
					self:RevertChanges()
					self:ChangeGraphicsMode()
					TheFrontEnd:PopScreen()
				end
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
	PostProcessor:SetDistortionEnabled( self.working.distortion )
	gopts:SetSmallTexturesMode( self.working.smalltextures )
	Profile:SetScreenShakeEnabled( self.working.screenshake )
	Profile:SetWathgrithrFontEnabled( self.working.wathgrithrfont )
	TheSim:SetNetbookMode(self.working.netbookmode)

    local portalsmoke = not (self.working.smalltextures or self.working.netbookmode)
    if self.bg ~= nil and self.bg.EnableSmoke ~= nil then
        self.bg:EnableSmoke(portalsmoke)
    end
    if self.fg ~= nil and self.fg.EnableSmoke ~= nil then
        self.fg:EnableSmoke(portalsmoke)
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
    popup.text:SetRegionSize(480, 150)
    popup.text:SetPosition(0, -25, 0)
    if TheInput:GetStringIsButtonImage(loc_text) then
        popup.text:SetColour(1,1,1,1)
        popup.text:SetFont(UIFONT)
    else
        popup.text:SetColour(0,0,0,1)
        popup.text:SetFont(NEWFONT)
    end

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
                    if TheInput:GetStringIsButtonImage(ctrlString) then
                        if deviceId == 0 then --keyboard
                            v.button_kb:SetTextColour(1,1,1,1)
                            v.button_kb:SetFont(UIFONT)
                            v.button_kb:SetText(ctrlString)
                        else --other
                            v.button_controller:SetTextColour(1,1,1,1)
                            v.button_controller:SetFont(UIFONT)
                            v.button_controller:SetText(ctrlString)
                        end
                    else
                        if deviceId == 0 then --keyboard
                            v.button_kb:SetTextColour(0,0,0,1)
                            v.button_kb:SetFont(NEWFONT)
                            v.button_kb:SetText(ctrlString)
                        else --other
                            v.button_controller:SetTextColour(0,0,0,1)
                            v.button_controller:SetFont(NEWFONT)
                            v.button_controller:SetText(ctrlString)
                        end
                    end
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

function OptionsScreen:CreateSpinnerGroup( text, spinner )
	local label_width = 200
	spinner:SetTextColour(0,0,0,1)
	local group = Widget( "SpinnerGroup" )
	local bg = group:AddChild(Image("images/ui.xml", "single_option_bg.tex"))
	bg:SetSize(380, 40)
	bg:SetPosition(50, 0, 0)

	local label = group:AddChild( Text( NEWFONT, 26, text ) )
	label:SetPosition( -label_width/2 + 55, 0, 0 )
	label:SetRegionSize( label_width, 50 )
	label:SetHAlign( ANCHOR_RIGHT )
	label:SetColour(0,0,0,1)

	group:AddChild( spinner )
	spinner:SetPosition( 148, 0, 0 )
	spinner:SetTextSize(22)

	--pass focus down to the spinner
	group.focus_forward = spinner
	return group
end

function OptionsScreen:UpdateMenu()
	if TheInput:ControllerAttached() then
		self.menu:Hide()
		return
	end

	self.menu:Show()

	if #self.menu.items == 0 then
		self.menu.horizontal = true

		self.apply_button = self.root:AddChild(TEMPLATES.Button(STRINGS.UI.OPTIONS.APPLY, function() self:ApplyChanges() end))
		self.menu:AddCustomItem(self.apply_button, Vector3(350, 0, 0))

		self.reset_button = self.root:AddChild(TEMPLATES.Button(STRINGS.UI.CONTROLSSCREEN.RESET, function()
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
	    end))
	    self.reset_button:SetScale(.8)
	    self.menu:AddCustomItem(self.reset_button, Vector3(230, 0, 0))
	end

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

    if self.prev_screen ~= nil then
        self.prev_screen:TransferPortalOwnership(self, self.prev_screen)
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
    --print("Current device is [" .. deviceId .. "]")
    --print("Current controller device is ["..(controllerDeviceId or "none").."]")

	for i,v in pairs(self.active_list.items) do
		local hasChanged = TheInputProxy:HasMappingChanged(deviceId, v.controlId)
		if hasChanged then
		    v.changed_image:Show()
		else
		    v.changed_image:Hide()
		end

        if v.control.keyboard and v.button_kb then
            local kbString = TheInput:GetLocalizedControl(0, v.control.keyboard)
            v.button_kb:SetText(kbString)
        end

        if v.control.controller and self.deviceSpinner:GetSelectedData() and v.button_controller then
            local controllerString = controllerDeviceId ~= nil and TheInput:GetLocalizedControl(controllerDeviceId, v.control.controller) or ""
            v.button_controller:SetText(controllerString)

            if TheInput:GetStringIsButtonImage(controllerString) then
                v.button_controller:SetTextColour(1,1,1,1)
                v.button_controller:SetTextFocusColour(1,1,1,1)
                v.button_controller.text:SetFont(UIFONT)
            else
                v.button_controller:SetTextColour(0,0,0,1)
                v.button_controller:SetTextFocusColour(0,0,0,1)
                v.button_controller.text:SetFont(NEWFONT)
            end
        end
	end

	self:RefreshNav()

	if self.selected_tab == "controls" then
		if old_idx then
			self.active_list.items[math.min(#self.active_list.items, old_idx)].button:SetFocus()
		end
	end

	self:UpdateMenu()
end

function OptionsScreen:RefreshNav()

    local function toleftcol()
        if self.settings_button:IsEnabled() then
            return self.settings_button
        else
            return self.controls_button
        end
    end

	local function torightcol()
        if self.selected_tab == "settings" then
		    return self.grid
        else
            return self.active_list
        end
	end

    if self.active_list and self.active_list.items then
    	for k,v in pairs(self.active_list.items) do
            if v.button_kb then
    		    v.button_kb:SetFocusChangeDir(MOVE_LEFT, toleftcol)
            elseif v.button_controller then
                v.button_controller:SetFocusChangeDir(MOVE_LEFT, toleftcol)
            end
    	end
    end

    self.grid:SetFocusChangeDir(MOVE_LEFT, toleftcol)

    self.active_list:SetFocusChangeDir(MOVE_LEFT, toleftcol)
    self.active_list:SetFocusChangeDir(MOVE_RIGHT, self.menu)

    self.menu:SetFocusChangeDir(MOVE_LEFT, self.cancel_button)
    self.menu:SetFocusChangeDir(MOVE_UP, torightcol())

    self.cancel_button:SetFocusChangeDir(MOVE_UP, toleftcol)

    self.cancel_button:SetFocusChangeDir(MOVE_RIGHT, self.menu)
    self.settings_button:SetFocusChangeDir(MOVE_RIGHT, torightcol)
    self.controls_button:SetFocusChangeDir(MOVE_RIGHT, torightcol)

    self.settings_button:SetFocusChangeDir(MOVE_DOWN, self.controls_button)
    self.controls_button:SetFocusChangeDir(MOVE_UP, self.settings_button)
    self.controls_button:SetFocusChangeDir(MOVE_DOWN, self.cancel_button)

    if TheInput:ControllerAttached() then
        self.cancel_button:Hide()
    else
        self.cancel_button:Show()
    end
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

	--------------
	--------------
	-- SETTINGS --
	--------------
	--------------

	local this = self

	local spinner_width = 180
	local spinner_height = 36 --nil -- use default
	local spinner_scale_x = .76
	local spinner_scale_y = .68

	if show_graphics then
		local gOpts = TheFrontEnd:GetGraphicsOptions()

		self.fullscreenSpinner = Spinner( enableDisableOptions, spinner_width, spinner_height, nil, false, nil, nil, true, nil, nil, spinner_scale_x, spinner_scale_y )
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
		self.displaySpinner = Spinner( valid_displays, spinner_width, spinner_height, nil, nil, nil, nil, true, nil, nil, spinner_scale_x, spinner_scale_y )
		self.displaySpinner.OnChanged =
			function( _, data )
				this.working.display = data
				this:UpdateResolutionsSpinner()
				this:UpdateRefreshRatesSpinner()
				self:UpdateMenu()
			end

		local refresh_rates = GetRefreshRates( self.working.display, self.working.mode_idx )
		self.refreshRateSpinner = Spinner( refresh_rates, spinner_width, spinner_height, nil, nil, nil, nil, true, nil, nil, spinner_scale_x, spinner_scale_y )
		self.refreshRateSpinner.OnChanged =
			function( _, data )
				this.working.refreshrate = data
				self:UpdateMenu()
			end

		local modes = GetDisplayModes( self.working.display )
		self.resolutionSpinner = Spinner( modes, spinner_width, spinner_height, nil, nil, nil, nil, true, nil, nil, spinner_scale_x, spinner_scale_y )
		self.resolutionSpinner.OnChanged =
			function( _, data )
				this.working.mode_idx = data.idx
				this:UpdateRefreshRatesSpinner()
				self:UpdateMenu()
			end

		self.netbookModeSpinner = Spinner( enableDisableOptions, spinner_width, spinner_height, nil, nil, nil, nil, true, nil, nil, spinner_scale_x, spinner_scale_y )
		self.netbookModeSpinner.OnChanged =
			function( _, data )
				this.working.netbookmode = data
				--this:Apply()
				self:UpdateMenu()
			end

		self.smallTexturesSpinner = Spinner( enableDisableOptions, spinner_width, spinner_height, nil, nil, nil, nil, true, nil, nil, spinner_scale_x, spinner_scale_y )
		self.smallTexturesSpinner.OnChanged =
			function( _, data )
				this.working.smalltextures = data
				--this:Apply()
				self:UpdateMenu()
			end

	end

	self.bloomSpinner = Spinner( enableDisableOptions, spinner_width, spinner_height, nil, nil, nil, nil, true, nil, nil, spinner_scale_x, spinner_scale_y )
	self.bloomSpinner.OnChanged =
		function( _, data )
			this.working.bloom = data
			--this:Apply()
			self:UpdateMenu()
		end

	self.distortionSpinner = Spinner( enableDisableOptions, spinner_width, spinner_height, nil, nil, nil, nil, true, nil, nil, spinner_scale_x, spinner_scale_y )
	self.distortionSpinner.OnChanged =
		function( _, data )
			this.working.distortion = data
			--this:Apply()
			self:UpdateMenu()
		end

	self.screenshakeSpinner = Spinner( enableDisableOptions, spinner_width, spinner_height, nil, nil, nil, nil, true, nil, nil, spinner_scale_x, spinner_scale_y )
	self.screenshakeSpinner.OnChanged =
		function( _, data )
			this.working.screenshake = data
			--this:Apply()
			self:UpdateMenu()
		end

	self.fxVolume = NumericSpinner( 0, 10, spinner_width, spinner_height, nil, nil, nil, nil, true, nil, nil, spinner_scale_x, spinner_scale_y )
	self.fxVolume.OnChanged =
		function( _, data )
			this.working.fxvolume = data
			this:ApplyVolume()
			self:UpdateMenu()
		end

	self.musicVolume = NumericSpinner( 0, 10, spinner_width, spinner_height, nil, nil, nil, nil, true, nil, nil, spinner_scale_x, spinner_scale_y )
	self.musicVolume.OnChanged =
		function( _, data )
			this.working.musicvolume = data
			this:ApplyVolume()
			self:UpdateMenu()
		end

	self.ambientVolume = NumericSpinner( 0, 10, spinner_width, spinner_height, nil, nil, nil, nil, true, nil, nil, spinner_scale_x, spinner_scale_y )
	self.ambientVolume.OnChanged =
		function( _, data )
			this.working.ambientvolume = data
			this:ApplyVolume()
			self:UpdateMenu()
		end

	self.hudSize = NumericSpinner( 0, 10, spinner_width, spinner_height, nil, nil, nil, nil, true, nil, nil, spinner_scale_x, spinner_scale_y )
	self.hudSize.OnChanged =
		function( _, data )
			this.working.hudSize = data
			--this:Apply()
			self:UpdateMenu()
		end

	self.vibrationSpinner = Spinner( enableDisableOptions, spinner_width, spinner_height, nil, nil, nil, nil, true, nil, nil, spinner_scale_x, spinner_scale_y )
	self.vibrationSpinner.OnChanged =
		function( _, data )
			this.working.vibration = data
			--this:Apply()
			self:UpdateMenu()
		end

	self.passwordSpinner = Spinner( enableDisableOptions, spinner_width, spinner_height, nil, nil, nil, nil, true, nil, nil, spinner_scale_x, spinner_scale_y )
	self.passwordSpinner.OnChanged =
		function( _, data )
			this.working.showpassword = data
			--this:Apply()
			self:UpdateMenu()
		end

	self.wathgrithrfontSpinner = Spinner( enableDisableOptions, spinner_width, spinner_height, nil, nil, nil, nil, true, nil, nil, spinner_scale_x, spinner_scale_y )
	self.wathgrithrfontSpinner.OnChanged =
		function( _, data )
			this.working.wathgrithrfont = data
			--this:Apply()
			self:UpdateMenu()
		end

    self.movementpredictionSpinner = Spinner(
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

	self.automodsSpinner = Spinner( enableDisableOptions, spinner_width, spinner_height, nil, nil, nil, nil, true, nil, nil, spinner_scale_x, spinner_scale_y )
	self.automodsSpinner.OnChanged =
		function( _, data )
			this.working.automods = data
			--this:Apply()
			self:UpdateMenu()
		end

	self.deviceSpinner = Spinner( self.devices, spinner_width, spinner_height, nil, nil, nil, nil, true, 250, nil, spinner_scale_x, spinner_scale_y )
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

            self:RefreshControls()
            self:MakeDirty()
		end

	self.left_spinners = {}
	self.right_spinners = {}

    table.insert( self.left_spinners, { STRINGS.UI.OPTIONS.INPUT, self.deviceSpinner } )
    table.insert( self.left_spinners, { STRINGS.UI.OPTIONS.VIBRATION, self.vibrationSpinner} )
    table.insert( self.left_spinners, { STRINGS.UI.OPTIONS.FX, self.fxVolume } )
    table.insert( self.left_spinners, { STRINGS.UI.OPTIONS.MUSIC, self.musicVolume } )
    table.insert( self.left_spinners, { STRINGS.UI.OPTIONS.AMBIENT, self.ambientVolume } )
    table.insert( self.left_spinners, { STRINGS.UI.OPTIONS.SHOWPASSWORD, self.passwordSpinner} )
    table.insert( self.left_spinners, { STRINGS.UI.OPTIONS.AUTOMODS, self.automodsSpinner } )
    table.insert( self.left_spinners, { STRINGS.UI.OPTIONS.WATHGRITHRFONT, self.wathgrithrfontSpinner} )
    table.insert( self.left_spinners, { STRINGS.UI.OPTIONS.HUDSIZE, self.hudSize} )

    table.insert( self.right_spinners, { STRINGS.UI.OPTIONS.SCREENSHAKE, self.screenshakeSpinner } )
    table.insert( self.right_spinners, { STRINGS.UI.OPTIONS.DISTORTION, self.distortionSpinner } )
    table.insert( self.right_spinners, { STRINGS.UI.OPTIONS.BLOOM, self.bloomSpinner } )

	if show_graphics then
		table.insert( self.right_spinners, { STRINGS.UI.OPTIONS.FULLSCREEN, self.fullscreenSpinner } )
		table.insert( self.right_spinners, { STRINGS.UI.OPTIONS.RESOLUTION, self.resolutionSpinner } )
		table.insert( self.right_spinners, { STRINGS.UI.OPTIONS.DISPLAY, self.displaySpinner } )
		table.insert( self.right_spinners, { STRINGS.UI.OPTIONS.REFRESHRATE, self.refreshRateSpinner } )
		table.insert( self.right_spinners, { STRINGS.UI.OPTIONS.SMALLTEXTURES, self.smallTexturesSpinner } )
		table.insert( self.right_spinners, { STRINGS.UI.OPTIONS.NETBOOKMODE, self.netbookModeSpinner } )
        table.insert( self.right_spinners, { STRINGS.UI.OPTIONS.MOVEMENTPREDICTION, self.movementpredictionSpinner } )
	end

	self.grid:InitSize(2, 10, 440, -40)

	for k,v in ipairs(self.left_spinners) do
		self.grid:AddItem(self:CreateSpinnerGroup(v[1], v[2]), 1, k)
	end

	for k,v in ipairs(self.right_spinners) do
		self.grid:AddItem(self:CreateSpinnerGroup(v[1], v[2]), 2, k)
	end

	--------------
	--------------
	-- CONTROLS --
	--------------
	--------------

	local button_x = 177 -- x coord of the right column
	local keyboard = true
    self.kb_controlwidgets = {}
    self.controller_controlwidgets = {}
	for i,v in ipairs(all_controls) do

        if all_controls[i] and all_controls[i].keyboard then

            local group = Widget("control"..i)
            group:SetScale(1,1,0.75)

            group.control = all_controls[i]
            group.controlName = all_controls[i].name
    		group.controlId = all_controls[i].keyboard

    		group.bg = group:AddChild(Image("images/ui.xml", "single_option_bg.tex"))
    	    group.bg:SetPosition(-115, 3, 0)
            group.bg:SetScale(1.5, 1, 1)

    		group.changed_image = group:AddChild(Image("images/ui.xml", "option_highlight.tex"))
    		-- group.changed_image:SetTint(unpack(BGCOLOURS.GREY))
    		group.changed_image:SetPosition(button_x-1,2,0)
    		group.changed_image:SetScale(.71, .79)

            local hasChanged = false
            --keyboard
            if group.control.keyboard then
                hasChanged = TheInputProxy:HasMappingChanged(0, group.control.keyboard)
            end
            if hasChanged then
    		    group.changed_image:Show()
    		else
    		    group.changed_image:Hide()
    		end

            group.label = group:AddChild(Text(NEWFONT, 28))
            local ctrlString = STRINGS.UI.CONTROLSSCREEN.CONTROLS[group.controlName+1]
            group.label:SetString(ctrlString)
            group.label:SetHAlign(ANCHOR_LEFT)
            group.label:SetColour(0,0,0,1)
            group.label:SetRegionSize( 500, 50 )
            group.label:SetPosition(-146,5,0)
            group.label:SetClickable(false)

    		group.button_kb = group:AddChild(ImageButton("images/ui.xml", "blank.tex", "spinner_focus.tex", nil, nil, nil, {1,1}, {0,0}))
    		group.button_kb:ForceImageSize(198, 48)

    		group.button_kb:SetTextColour(0,0,0,1)
            group.button_kb:SetFont(NEWFONT)
            group.button_kb:SetTextSize(30)
    		group.button_kb:SetPosition(button_x,2,0)
    		group.button_kb.idx = i
            group.button_kb:SetOnClick(
                function()
                    self:MapControl(0, group.control.keyboard) --kb is always 0
                end
            )
            group.button_kb:SetHelpTextMessage(STRINGS.UI.CONTROLSSCREEN.CHANGEBIND)
            group.button_kb:SetDisabledFont(NEWFONT)
            if group.control.keyboard then
                group.button_kb:SetText(TheInput:GetLocalizedControl(0, group.control.keyboard)) --kb is always 0
            end

            group.focus_forward = group.button_kb

		    table.insert(self.kb_controlwidgets, group)

        end
	end

    local deviceId = self.deviceSpinner:GetSelectedData()
    local controllerDeviceId =
        (deviceId ~= 0 and deviceId) or
        (self.deviceSpinner.options[2] ~= nil and self.deviceSpinner.options[2].data) or
        nil
    for i,v in ipairs(all_controls) do

        if all_controls[i] and all_controls[i].controller then

            local group = Widget("control"..i)
            group:SetScale(1,1,0.75)

            group.control = all_controls[i]
            group.controlName = all_controls[i].name
            group.controlId = all_controls[i].controller

            group.bg = group:AddChild(Image("images/ui.xml", "single_option_bg.tex"))
            group.bg:SetPosition(-115, 3, 0)
            group.bg:SetScale(1.5, 1, 1)

            group.changed_image = group:AddChild(Image("images/ui.xml", "option_highlight.tex"))
            -- group.changed_image:SetTint(unpack(BGCOLOURS.GREY))
    		group.changed_image:SetPosition(button_x-1,2,0)
    		group.changed_image:SetScale(.71, .79)

            local hasChanged = false

            --selected controller, if any
            if deviceId ~= nil and deviceId ~= 0 and group.control.controller then
                hasChanged = hasChanged or TheInputProxy:HasMappingChanged(deviceId, group.control.controller)
            end
            if hasChanged then
                group.changed_image:Show()
            else
                group.changed_image:Hide()
            end

            group.label = group:AddChild(Text(NEWFONT, 28))
            local ctrlString = STRINGS.UI.CONTROLSSCREEN.CONTROLS[group.controlName+1]
            group.label:SetString(ctrlString)
            group.label:SetHAlign(ANCHOR_LEFT)
            group.label:SetColour(0,0,0,1)
            group.label:SetRegionSize( 500, 50 )
            group.label:SetPosition(-146,5,0)
            group.label:SetClickable(false)

            group.button_controller = group:AddChild(ImageButton("images/ui.xml", "blank.tex", "spinner_focus.tex", nil, nil, nil, {1,1}, {0,0}))
            group.button_controller:ForceImageSize(198, 48)

            group.button_controller.text:SetColour(0,0,0,1)
            group.button_controller:SetFont(NEWFONT)
            group.button_controller:SetTextSize(30)
            group.button_controller:SetPosition(button_x,2,0)
            group.button_controller.idx = i
            group.button_controller:SetOnClick(
                function()
                    if self.deviceSpinner:GetSelectedData() ~= 0 then
                        self:MapControl(self.deviceSpinner:GetSelectedData(), group.control.controller)
                    end
                end
            )
            group.button_controller.OnControl =
                function( _, control, down)
					if group.button_controller._base.OnControl(group.button_controller, control, down) then return true end

					if not self.is_mapping and self.deviceSpinner:GetSelectedData() ~= 0 then
						if not down and control == CONTROL_MENU_MISC_2 then
							-- Unbind the game control
  							self.is_mapping = true
						    TheInputProxy:UnMapControl(self.deviceSpinner:GetSelectedData(), group.control.controller)

							return true
						end
					end
                end
           group.button_controller.GetHelpText =
				function( self )
					local controller_id = TheInput:GetControllerID()
					local t = {}
					table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2, false, false ) .. " " .. STRINGS.UI.CONTROLSSCREEN.UNBIND)
					table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT, false, false ) .. " " .. STRINGS.UI.CONTROLSSCREEN.CHANGEBIND)
					return table.concat(t, "  ")
				end

            group.button_controller:SetDisabledFont(NEWFONT)
            if group.control.controller then
                group.button_controller:SetText(controllerDeviceId ~= nil and TheInput:GetLocalizedControl(controllerDeviceId, group.control.controller) or "")
            end

            if TheInput:GetStringIsButtonImage(group.button_controller:GetText()) then
                group.button_controller:SetTextColour(1,1,1,1)
                group.button_controller:SetTextFocusColour(1,1,1,1)
                group.button_controller.text:SetFont(UIFONT)
            else
                group.button_controller:SetTextColour(0,0,0,1)
                group.button_controller:SetTextFocusColour(0,0,0,1)
                group.button_controller.text:SetFont(NEWFONT)
            end

            group.focus_forward = group.button_controller

            table.insert(self.controller_controlwidgets, group)

        end
    end

	local header_y = 150
	local header_x = 375 -- location of the header on the right column

	self.actions_header = self.controlsroot:AddChild(Text(NEWFONT, 30, STRINGS.UI.OPTIONS.ACTION))
	self.actions_header:SetColour(0,0,0,1)
	self.actions_header:SetPosition(header_x-550,header_y,0)

    self.controls_header = self.controlsroot:AddChild(Text(NEWFONT, 30, STRINGS.UI.CONTROLSSCREEN.INPUT_NAMES[1]))
    if self.deviceSpinner:GetSelectedData() ~= 0 then
        self.controls_header:SetString(self.deviceSpinner:GetSelectedText())
    end
    self.controls_header:SetColour(0,0,0,1)
    self.controls_header:SetPosition(header_x,header_y,0)

	self.kb_controllist = self.controlsroot:AddChild(ScrollableList(self.kb_controlwidgets, 300, 330))
	self.kb_controllist:SetPosition(340, -40)

    self.controller_controllist = self.controlsroot:AddChild(ScrollableList(self.controller_controlwidgets, 300, 330))
    self.controller_controllist:SetPosition(340, -40)
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

	self.automodsSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.automods ) )

	if first then
		-- Add the bg change when non-init value for all spinners
        local function SetupOnChange(i,v)
			if v and v[2] then
				local spinner = v[2]
			    spinner.changed_image = spinner:AddChild(Image("images/ui.xml", "option_highlight.tex"))
				spinner.changed_image:SetPosition(-1, -1)
				spinner.changed_image:SetScale(.6, .67)
				spinner.changed_image:MoveToBack()
				spinner.changed_image:SetClickable(false)
				spinner.changed_image:Hide()
				spinner.background:SetPosition(0,-1)

				spinner.default_index = spinner:GetSelectedIndex()

				local spinOnChanged = spinner.OnChanged

				spinner.OnChanged = function(_, data)
					spinOnChanged(_, data)

					if spinner:GetSelectedIndex() ~= spinner.default_index then
                        spinner.changed_image:Show()
                    else
                        spinner.changed_image:Hide()
                    end
				end
			end
        end
		for i,v in pairs(self.left_spinners) do
            SetupOnChange(i,v)
		end

		for i,v in pairs(self.right_spinners) do
            SetupOnChange(i,v)
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
