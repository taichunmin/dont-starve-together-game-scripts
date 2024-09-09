local easing = require("easing")
local Widget = require "widgets/widget"
local DebugPanel2 = CAN_USE_DBUI and require("dbui_no_package/debug_panel2") or nil
local DebugEntity = CAN_USE_DBUI and require("dbui_no_package/debug_entity") or nil
local DebugNodes = CAN_USE_DBUI and require("dbui_no_package/debug_nodes") or nil
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local Image = require "widgets/image"
local ConsoleScreen = require "screens/consolescreen"
local DebugMenuScreen = require "screens/DebugMenuScreen"
local PopupDialogScreen = require "screens/popupdialog"
local PopupDialogScreenRedux = require "screens/redux/popupdialog"
local TEMPLATES = require "widgets/templates"
local ServerPauseWidget = require "widgets/redux/serverpausewidget"

require "constants"
require "splitscreenutils_pc"

local MotdManager = require "motdmanager"

local REPEAT_TIME = .15
local SCROLL_REPEAT_TIME = .05
local MOUSE_SCROLL_REPEAT_TIME = 0
local SPINNER_REPEAT_TIME = .25

local HELP_TEXT_SCALE_FACTOR = 1/63	-- dunno where this magic number came from
local HELP_TEXT_BG_SCALE_X = RESOLUTION_X * HELP_TEXT_SCALE_FACTOR + 8 
local HELP_TEXT_BG_SCALE_Y = 2 * HELP_TEXT_SCALE_FACTOR
local HELP_TEXT_BG_HEIGHT = 80
local HELP_TEXT_FONT_SIZE = 30
local HELP_TEXT_MAX_LINES = 2
local HELP_TEXT_MAX_WIDTH = RESOLUTION_X * .95
local HELP_TEXT_MAX_CHARS_PER_LINE = 130
local HELP_TEXT_MAX_CHARS_PER_LINE_SPLITSCREEN = 80

local save_fade_time = .5

local DebugMenu = CAN_USE_DBUI and require("dbui_no_package/debugmenu") or nil

global_error_widget = nil

FrontEnd = Class(function(self, name)
	self.screenstack = {}

	self.screenroot = Widget("screenroot")
    self.screenroot.global_widget = true
    self.screenroot.is_screen = true

	self.overlayroot = Widget("overlayroot")
    self.overlayroot.global_widget = true

	------ CONSOLE -----------
	self.consoletext = Text(BODYTEXTFONT, 20, "CONSOLE TEXT")
	self.consoletext:SetVAlign(ANCHOR_BOTTOM)
	self.consoletext:SetHAlign(ANCHOR_LEFT)
    self.consoletext:SetVAnchor(ANCHOR_MIDDLE)
    self.consoletext:SetHAnchor(ANCHOR_MIDDLE)
	self.consoletext:SetScaleMode(SCALEMODE_PROPORTIONAL)

	self.consoletext:SetRegionSize(900, 406)
	self.consoletext:SetPosition(0,0,0)
	self.consoletext:Hide()
    -----------------

	------ SERVERPAUSE -----------
	self.serverpausewidget = ServerPauseWidget()
	self.serverpausewidget:SetPosition(0,0,0)
	self.serverpausewidget:Hide()
    -----------------

    self.blackoverlay = Image("images/global.xml", "square.tex")
    self.blackoverlay:SetVRegPoint(ANCHOR_MIDDLE)
    self.blackoverlay:SetHRegPoint(ANCHOR_MIDDLE)
    self.blackoverlay:SetVAnchor(ANCHOR_MIDDLE)
    self.blackoverlay:SetHAnchor(ANCHOR_MIDDLE)
    self.blackoverlay:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.blackoverlay:SetTint(0,0,0,0)
	self.blackoverlay:SetClickable(false)
	self.blackoverlay:Hide()

    self.topblackoverlay = Image("images/global.xml", "square.tex")
    self.topblackoverlay:SetVRegPoint(ANCHOR_MIDDLE)
    self.topblackoverlay:SetHRegPoint(ANCHOR_MIDDLE)
    self.topblackoverlay:SetVAnchor(ANCHOR_MIDDLE)
    self.topblackoverlay:SetHAnchor(ANCHOR_MIDDLE)
    self.topblackoverlay:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.topblackoverlay:SetTint(0,0,0,0)
	self.topblackoverlay:SetClickable(false)
	self.topblackoverlay:Hide()

	self.swipeoverlay = Image("images/global.xml", "noise.tex")
	self.swipeoverlay:SetEffect( "shaders/swipe_fade.ksh" )
	self.swipeoverlay:SetEffectParams(0.5,0,0,0)
    self.swipeoverlay:SetVRegPoint(ANCHOR_MIDDLE)
    self.swipeoverlay:SetHRegPoint(ANCHOR_MIDDLE)
    self.swipeoverlay:SetVAnchor(ANCHOR_MIDDLE)
    self.swipeoverlay:SetHAnchor(ANCHOR_MIDDLE)
    self.swipeoverlay:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.swipeoverlay:SetTint(1,1,1,0)
	self.swipeoverlay:SetClickable(false)
	self.swipeoverlay:Hide()

	self.topswipeoverlay = Image("images/global.xml", "noise.tex")
	self.topswipeoverlay:SetEffect( "shaders/swipe_fade.ksh" )
	self.topswipeoverlay:SetEffectParams(0,0,0,0)
    self.topswipeoverlay:SetVRegPoint(ANCHOR_MIDDLE)
    self.topswipeoverlay:SetHRegPoint(ANCHOR_MIDDLE)
    self.topswipeoverlay:SetVAnchor(ANCHOR_MIDDLE)
    self.topswipeoverlay:SetHAnchor(ANCHOR_MIDDLE)
    self.topswipeoverlay:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.topswipeoverlay:SetTint(1,1,1,0)
	self.topswipeoverlay:SetClickable(false)
	self.topswipeoverlay:Hide()

	self.whiteoverlay = Image("images/global.xml", "square.tex")
    self.whiteoverlay:SetVRegPoint(ANCHOR_MIDDLE)
    self.whiteoverlay:SetHRegPoint(ANCHOR_MIDDLE)
    self.whiteoverlay:SetVAnchor(ANCHOR_MIDDLE)
    self.whiteoverlay:SetHAnchor(ANCHOR_MIDDLE)
    self.whiteoverlay:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.whiteoverlay:SetTint(FADE_WHITE_COLOUR[1], FADE_WHITE_COLOUR[2], FADE_WHITE_COLOUR[3], 0)
	self.whiteoverlay:SetClickable(false)
	self.whiteoverlay:Hide()

	self.vigoverlay = TEMPLATES.BackgroundVignette()
	self.vigoverlay:SetClickable(false)
	self.vigoverlay:Hide()

    self.topwhiteoverlay = Image("images/global.xml", "square.tex")
    self.topwhiteoverlay:SetVRegPoint(ANCHOR_MIDDLE)
    self.topwhiteoverlay:SetHRegPoint(ANCHOR_MIDDLE)
    self.topwhiteoverlay:SetVAnchor(ANCHOR_MIDDLE)
    self.topwhiteoverlay:SetHAnchor(ANCHOR_MIDDLE)
    self.topwhiteoverlay:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.topwhiteoverlay:SetTint(FADE_WHITE_COLOUR[1], FADE_WHITE_COLOUR[2], FADE_WHITE_COLOUR[3], 0)
	self.topwhiteoverlay:SetClickable(false)
	self.topwhiteoverlay:Hide()

	self.topvigoverlay = TEMPLATES.BackgroundVignette()
	self.topvigoverlay:SetClickable(false)
	self.topvigoverlay:Hide()
	
	self.is_splitscreen = HaveMultipleViewports()
	self.helptext_max_characters_per_line = (self.is_splitscreen and HELP_TEXT_MAX_CHARS_PER_LINE_SPLITSCREEN) or HELP_TEXT_MAX_CHARS_PER_LINE

	self.helptext = self.overlayroot:AddChild(Widget("HelpText"))
	self.helptext:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.helptext:SetHAnchor(ANCHOR_MIDDLE)
    self.helptext:SetVAnchor(ANCHOR_BOTTOM)

    self.helptextbg = self.helptext:AddChild(Image("images/global.xml", "square.tex"))
	self.helptextbg:SetScale(HELP_TEXT_BG_SCALE_X, HELP_TEXT_BG_HEIGHT * HELP_TEXT_BG_SCALE_Y)
	self.helptextbg:SetPosition(0, -HELP_TEXT_BG_HEIGHT/2)
--	self.helptextbg:SetClickable(false)
	self.helptextbg:SetTint(0,0,0,.75)

	self.helptexttext = self.helptext:AddChild(Text(UIFONT, HELP_TEXT_FONT_SIZE))
	self.helptexttext:SetPosition(0, -5)
	self.helptexttext:SetHAlign(ANCHOR_LEFT)
	self.helptexttext:SetVAlign(ANCHOR_TOP)
	self.helptextstring = ""

	self.overlayroot:AddChild(self.topblackoverlay)
	self.overlayroot:AddChild(self.topwhiteoverlay)
	self.overlayroot:AddChild(self.topvigoverlay)
	self.overlayroot:AddChild(self.topswipeoverlay)
	self.screenroot:AddChild(self.blackoverlay)
	self.screenroot:AddChild(self.whiteoverlay)
	self.screenroot:AddChild(self.vigoverlay)
	self.screenroot:AddChild(self.swipeoverlay)
	self.screenroot:AddChild(self.consoletext)
    self.screenroot:AddChild(self.serverpausewidget)

    self.alpha = 0

    self.title = Text(TITLEFONT, 100)
    self.title:SetPosition(0, -30, 0)
    self.title:Hide()
    self.title:SetVAnchor(ANCHOR_MIDDLE)
    self.title:SetHAnchor(ANCHOR_MIDDLE)
	self.overlayroot:AddChild(self.title)

    self.subtitle = Text(TITLEFONT, 70)
    self.subtitle:SetPosition(0, 70, 0)
    self.subtitle:Hide()
    self.subtitle:SetVAnchor(ANCHOR_MIDDLE)
    self.subtitle:SetHAnchor(ANCHOR_MIDDLE)
	self.overlayroot:AddChild(self.subtitle)

    if IsConsole() then
        self.saving_indicator = UIAnim()
        self.saving_indicator:GetAnimState():SetBank("saving_indicator")
        self.saving_indicator:GetAnimState():SetBuild("saving_indicator")
        self.saving_indicator:GetAnimState():PlayAnimation("save_loop", true)
        self.saving_indicator:SetVAnchor(ANCHOR_BOTTOM)
        self.saving_indicator:SetHAnchor(ANCHOR_RIGHT)
        self.saving_indicator:SetScaleMode(SCALEMODE_PROPORTIONAL)
        self.saving_indicator:SetMaxPropUpscale(MAX_HUD_SCALE)
        self.saving_indicator:SetPosition(-10, 40)
        self.saving_indicator:Hide()
    end

	self:HideTitle()

	self.gameinterface = CreateEntity("GameInterface")
	self.gameinterface.entity:AddSoundEmitter()
	self.gameinterface.entity:AddGraphicsOptions()
	if IsNotConsole() then
		self.gameinterface.entity:AddTwitchOptions()
	end
	self.gameinterface.entity:AddAccountManager()

	TheInput:AddKeyHandler(function(key, down) self:OnRawKey(key, down) end )
	TheInput:AddTextInputHandler(function(text) self:OnTextInput(text) end )

	self.tracking_mouse = true

	self:UpdateRepeatDelays() -- crafting menu and inventory navigation

	self.repeat_time = -1
	self.repeat_reps = 0
    self.scroll_repeat_time = -1
    self.spinner_repeat_time = -1

	self.topFadeHidden = false

	self.updating_widgets = setmetatable({}, {__mode="k"})
	self.num_pending_saves = 0
	self.save_indicator_time_left = 0
	self.save_indicator_fade_time = 0
	self.save_indicator_fade = nil
	self.autosave_enabled = true

    if CAN_USE_DBUI then
        self.imgui = require("dbui_no_package/imgui")
        self.debug_panels = {}
        self.imgui_font_size = Profile:GetValue("imgui_font_size") or 1

        self.debugMenu = DebugMenu()
    end

    -- data from the current game that is to be passed back to the game when the server resets (used for showing results in events when back in the lobby)
    -- Never set this to nil or people will crash. If needed, test for empty list if needed to control flow.
    self.match_results = {}

	self.MotdManager = MotdManager()
end)

function FrontEnd:ShowSavingIndicator()
    if self.saving_indicator ~= nil and TheSystemService:IsStorageEnabled() then
		if not self.saving_indicator.shown then
			self.save_indicator_time_left = 3
			self.saving_indicator:Show()
			self.saving_indicator:ForceStartWallUpdating()
			self.save_indicator_fade_time = save_fade_time
			self.saving_indicator:GetAnimState():SetMultColour(1,1,1,0)
			self.save_indicator_fade = "in"
		end

	    self.num_pending_saves = self.num_pending_saves + 1
	end
end

function FrontEnd:HideSavingIndicator()
	if self.saving_indicator ~= nil and self.num_pending_saves > 0 then
		self.num_pending_saves = self.num_pending_saves - 1
	end
end

function FrontEnd:HideTopFade()
	self.topwhiteoverlay:Hide()
	self.topvigoverlay:Hide()
	self.topblackoverlay:Hide()
	self.topswipeoverlay:Hide()
	self.topFadeHidden = true
end

function FrontEnd:ShowTopFade()
	self.topFadeHidden = false
	if self.fade_type == "white" then
		self.topwhiteoverlay:Show()
		self.topvigoverlay:Show()
	elseif self.fade_type == "black" then
		self.topblackoverlay:Show()
	elseif self.fade_type == "swipe" then
		self.topswipeoverlay:Show()
	end
end

function FrontEnd:GetFocusWidget()
	if #self.screenstack > 0 then
		return self.screenstack[#self.screenstack]:GetDeepestFocus()
	end
end

function FrontEnd:GetIntermediateFocusWidgets()
	if #self.screenstack > 0 then
		local widgs = {}
		if self.screenstack[#self.screenstack] then
			local nextWidget = self.screenstack[#self.screenstack]:GetFocusChild()

			while nextWidget and nextWidget ~= self:GetFocusWidget() do
				table.insert(widgs, nextWidget)
				nextWidget = nextWidget:GetFocusChild()
			end
		end
		return widgs
	end
end

function FrontEnd:GetHelpText()
	local t = {}

	local widget = self:GetFocusWidget()
    local active_screen = self:GetActiveScreen()

	if active_screen ~= widget and active_screen ~= nil then
		local str = active_screen:GetHelpText()
		if str ~= nil and str ~= "" then
			table.insert(t, str)
		end
	end

	-- Show the help text for secondary widgets, like scroll bars
	local intermediate_widgets = self:GetIntermediateFocusWidgets()
	if intermediate_widgets then
		for i,v in ipairs(intermediate_widgets) do
			if v and v ~= widget and v.GetHelpText then
				local str = v:GetHelpText()
				if str and str ~= "" then
					if v.HasExclusiveHelpText and v:HasExclusiveHelpText() then
						-- Only use this widgets help text, clear all other help text
						t = {}
						table.insert(t, v:GetHelpText())
						break
					else
						table.insert(t, v:GetHelpText())
					end
				end
			end
		end
	end

	-- Show the help text for the focused widget
	if widget and widget.GetHelpText then
		if widget.HasExclusiveHelpText and widget:HasExclusiveHelpText() then
			-- Only use this widgets help text, clear all other help text
			t = {}
		end

		local str = widget:GetHelpText()
		if str and str ~= "" then
			table.insert(t, widget:GetHelpText())
		end
	end

	return table.concat(t, "  ")
end

function FrontEnd:UpdateHelpTextSize(num_lines)
	local splitscreen_scale = (self.is_splitscreen and not IsGameInstance(Instances.Overlay)) and 1.8 or 1
	if PLATFORM == "XBONE" and splitscreen_scale == 1.8 then
		splitscreen_scale = 1.63
	end
		
	if self.helptext_scale ~= splitscreen_scale then
		self.helptexttext:SetSize(HELP_TEXT_FONT_SIZE*splitscreen_scale)
		self.helptext_scale = splitscreen_scale
	end
	
	local help_height = HELP_TEXT_BG_HEIGHT * splitscreen_scale * num_lines

	self.helptextbg:SetScale(HELP_TEXT_BG_SCALE_X, help_height * HELP_TEXT_BG_SCALE_Y)
	self.helptextbg:SetPosition(0, -help_height/2)

	self.helptexttext:SetRegionSize(HELP_TEXT_MAX_WIDTH, help_height)
end

function FrontEnd:StopTrackingMouse(autofocus)
	self.tracking_mouse = false
    if autofocus then
        local screen = self:GetActiveScreen()
        if screen ~= nil then
            screen:SetDefaultFocus()
        end
    end
end

function FrontEnd:IsControlsDisabled()
    return self:GetFadeLevel() > 0
        or (self.fadedir == FADE_OUT and self.fade_delay_time == nil)
        or global_error_widget ~= nil
end

function FrontEnd:OnFocusMove(dir, down)
    if self.focus_locked or self:IsControlsDisabled() then
        return true
	elseif #self.screenstack > 0 then
		if self.screenstack[#self.screenstack]:OnFocusMove(dir, down) then
	   		self:GetSound():PlaySound("dontstarve/HUD/click_mouseover_controller")
			self.tracking_mouse = false
			return true
		elseif self.tracking_mouse and down and self.screenstack[#self.screenstack]:SetDefaultFocus() then
			self.tracking_mouse = false
			return true
		end
	end
end

function FrontEnd:OnControl(control, down)
    -- if there is a textedit that is currently editing, stop editing if the player clicks somewhere else
    if self.textProcessorWidget ~= nil and not self.textProcessorWidget.focus and not down and control == CONTROL_PRIMARY then
        self:SetForceProcessTextInput(false, self.textProcessorWidget)
    end

    self.isprimary = control == CONTROL_PRIMARY
    if self:IsControlsDisabled() then
        self.isprimary = false
        return false
    --handle focus moves

    -- map CONTROL_PRIMARY to CONTROL_ACCEPT for buttons
    -- while editing a text box and hovering over something else, consume the accept button (the raw key handlers will deal with it).
    elseif #self.screenstack > 0
        and not (self.textProcessorWidget ~= nil and not self.textProcessorWidget.focus and self.textProcessorWidget:OnControl(control == CONTROL_PRIMARY and CONTROL_ACCEPT or control, down))
        and self.screenstack[#self.screenstack]:OnControl(control == CONTROL_PRIMARY and CONTROL_ACCEPT or control, down) then
            self.isprimary = false
        return true

    elseif CONSOLE_ENABLED and not down and control == CONTROL_OPEN_DEBUG_CONSOLE then
        self.isprimary = false
        self:PushScreen(ConsoleScreen())
        return true

    elseif DEBUG_MENU_ENABLED and not down and control == CONTROL_OPEN_DEBUG_MENU then
        self.isprimary = false
        self:PushScreen(DebugMenuScreen())
        return true

    elseif SHOWLOG_ENABLED and not down and control == CONTROL_TOGGLE_LOG then
        self.isprimary = false
        if self.consoletext.shown then
            self:HideConsoleLog()
        else
            self:ShowConsoleLog()
        end
        return true

    elseif DEBUGRENDER_ENABLED and not down and control == CONTROL_TOGGLE_DEBUGRENDER then
        self.isprimary = false
        --V2C: Special logic when text edit has focus, and assuming
        --     CONTROL_TOGGLE_DEBUGRENDER will always be BACKSPACE.

        --NOTE: Even though it looks like we're traversing the
        --      screen hierarchy again, it's still better than
        --      embedding the logic in Widget:OnControl, since
        --      it only triggers here on a backspace keyup.

        if #self.screenstack > 0 and self.screenstack[#self.screenstack]:IsEditing() then
            --Ignore since backspace is used by text edit
        elseif TheInput:IsKeyDown(KEY_CTRL) then
            TheSim:SetDebugPhysicsRenderEnabled(not TheSim:GetDebugPhysicsRenderEnabled())
        else
            TheSim:SetDebugRenderEnabled(not TheSim:GetDebugRenderEnabled())
        end
        return true

--[[
    elseif control == CONTROL_CANCEL then
        return screen:OnCancel(down)
--]]
    end
    self.isprimary = false
end

function FrontEnd:ShowTitle(text,subtext)
	self.title:SetString(text)
	self.title:Show()
	self.subtitle:SetString(subtext)
	self.subtitle:Show()
	self:StartTileFadeIn()
end

local fade_time = 2

function FrontEnd:DoTitleFade(dt)
	if self.fade_title_in == true or self.fade_title_out == true then
		dt = math.min(dt, 1/30)
		if self.fade_title_in == true and self.fade_title_time <fade_time then
			self.fade_title_time = self.fade_title_time + dt
		elseif self.fade_title_out == true and self.fade_title_time >0 then
			self.fade_title_time = self.fade_title_time - dt
		end

		self.fade_title_alpha = easing.inOutCubic(self.fade_title_time, 0, 1, fade_time)

		self.title:SetAlpha(self.fade_title_alpha)
		self.subtitle:SetAlpha(self.fade_title_alpha)

		if self.fade_title_in == true and self.fade_title_time >=fade_time then
			self:StartTileFadeOut()
		end
	end
end

function FrontEnd:StartTileFadeIn()
	self.fade_title_in = true
	self.fade_title_time = 0
	self.fade_title_out = false
	self:DoTitleFade(0)
end

function FrontEnd:StartTileFadeOut()
	self.fade_title_in = false
	self.fade_title_out = true
end

function FrontEnd:HideTitle()
	self.title:Hide()
	self.subtitle:Hide()
	self.fade_title_in = false
	self.fade_title_time = 0
	self.fade_title_out = false
end

function FrontEnd:LockFocus(lock)
	self.focus_locked = lock
end

function FrontEnd:SendScreenEvent(type, message)
	if #self.screenstack > 0 then
		self.screenstack[#self.screenstack]:HandleEvent(type, message)
	end
end

function FrontEnd:GetSound()
	return self.gameinterface.SoundEmitter
end

function FrontEnd:GetGraphicsOptions()
	return self.gameinterface.GraphicsOptions
end

function FrontEnd:GetTwitchOptions()
	return self.gameinterface.TwitchOptions
end

function FrontEnd:GetAccountManager()
	return self.gameinterface.AccountManager
end

function FrontEnd:SetFadeLevel(alpha, time, time_total)
    self.alpha = alpha
    DoAutopause()
    if alpha <= 0 then
        if self.blackoverlay ~= nil then
            self.blackoverlay:Hide()
            self.whiteoverlay:Hide()
            self.vigoverlay:Hide()
            self.swipeoverlay:Hide()
        end
        if self.topblackoverlay ~= nil then
            self.topblackoverlay:Hide()
            self.topwhiteoverlay:Hide()
            self.topvigoverlay:Hide()
            self.topswipeoverlay:Hide()
        end
        if self.fade_type == "alpha" then
            local screen = self:GetActiveScreen()
            if screen and screen.children then
                for k,v in pairs(screen.children) do
                    v:SetFadeAlpha(1)
                end
            end
        end
    elseif self.fade_type == "white" then
        self.whiteoverlay:Show()
        self.whiteoverlay:SetTint(FADE_WHITE_COLOUR[1], FADE_WHITE_COLOUR[2], FADE_WHITE_COLOUR[3], alpha)
        self.vigoverlay:Show()
        self.vigoverlay:SetTint(1, 1, 1, alpha)
        if not self.topFadeHidden then
            self.topwhiteoverlay:Show()
            self.topvigoverlay:Show()
        end
        self.topwhiteoverlay:SetTint(FADE_WHITE_COLOUR[1], FADE_WHITE_COLOUR[2], FADE_WHITE_COLOUR[3], alpha)
        self.topvigoverlay:SetTint(1, 1, 1, alpha)
    elseif self.fade_type == "alpha" then
        local screen = self:GetActiveScreen()
        if screen ~= nil and screen.children ~= nil then
            for k, v in pairs(screen.children) do
                v:SetFadeAlpha(1 - alpha) -- "alpha" here is the intensity of the fade, 1 is full intensity, so 0 widget alpha
            end
        end
    elseif self.fade_type == "black" then
        self.blackoverlay:Show()
        self.blackoverlay:SetTint(0, 0, 0, alpha)
        if not self.topFadeHidden then
            self.topblackoverlay:Show()
        end
        self.topblackoverlay:SetTint(0, 0, 0, alpha)
    elseif self.fade_type == "swipe" then
        self.swipeoverlay:Show()
        self.swipeoverlay:SetTint(1, 1, 1, alpha)
        if not self.topFadeHidden then
            self.topswipeoverlay:Show()
        end
        self.topswipeoverlay:SetTint(1, 1, 1, alpha)

        local progress = 0 --progress should be a float from 0 to 1 over the whole fade in and out
        local phase_1 = 0
        local fade_progress = time and (time/time_total) or 0
        if self.fadedir == FADE_IN then
			progress = 0.5 + (fade_progress/2)
			phase_1 = 1
        else--if self.fadedir == FADE_OUT then
			progress = fade_progress/2
			phase_1 = 0
        end

        self.swipeoverlay:SetEffectParams(progress, phase_1, 0, 0)
        self.topswipeoverlay:SetEffectParams(progress, phase_1, 0, 0)
    end
end

function FrontEnd:GetFadeLevel()
    return self.alpha
end

function FrontEnd:DoFadingUpdate(dt)
        dt = math.min(dt, FRAMES)
        if self.fade_delay_time ~= nil then
                self.fade_delay_time = self.fade_delay_time - dt
                if self.fade_delay_time <= 0 then
                        self.fade_delay_time = nil
                        if self.delayovercb ~= nil then
                                self.delayovercb()
                                self.delayovercb = nil
                        end
                end
                return
        elseif self.fadedir ~= nil then
                self.fade_time = self.fade_time + dt

                local alpha = 0
                if self.fadedir == FADE_IN then
                        if self.total_fade_time == 0 then
                                alpha = 0
                        else
                                alpha = easing.inOutCubic(self.fade_time, 1, -1, self.total_fade_time)
                        end
                elseif self.fadedir == FADE_OUT then
                        if self.total_fade_time == 0 then
                                alpha = 1
                        else
                                alpha = easing.outCubic(self.fade_time, 0, 1, self.total_fade_time)
                        end
                end

                self:SetFadeLevel(alpha, self.fade_time, self.total_fade_time)
                if self.fade_time >= self.total_fade_time then
                        self.fadedir = nil
                        if self.fadecb ~= nil then
                                local cb = self.fadecb
                                self.fadecb = nil
                                cb()
                        end
                end
        end
end

function FrontEnd:UpdateConsoleOutput()
    local consolestr = table.concat(GetConsoleOutputList(), "\n")
    consolestr = consolestr.."\n(Press CTRL+L to close this log)"
   	self.consoletext:SetString(consolestr)
end

function FrontEnd:_RefreshRepeatDelay(control)
	if self.repeat_reps <= 1 then
		self.repeat_time = self.crafting_repeat_base
	elseif self.repeat_reps >= 3 and Input:GetAnalogControlValue(control) > 0.95 then
		self.repeat_time = self.crafting_repeat_ninja
	else
		self.repeat_time = self.crafting_repeat_fast
	end
end

function FrontEnd:Update(dt)
    if DEBUGGER_ENABLED then
        Debuggee.poll()
    end

    if CHEATS_ENABLED then
        ProbeReload(TheInput:IsKeyDown(KEY_F6))
    end

	local controller = TheInput:ControllerAttached()

	if self.saving_indicator ~= nil and self.saving_indicator.shown then
		if self.save_indicator_fade then
			local alpha = 1
			self.save_indicator_fade_time = self.save_indicator_fade_time - math.min(dt, 1/60)

			if self.save_indicator_fade_time < 0 then
				if self.save_indicator_fade == "in" then
					alpha = 1
				else
					alpha = 0
					self.saving_indicator:ForceStopWallUpdating()
					self.saving_indicator:Hide()
				end
				self.save_indicator_fade = nil
			else
				if self.save_indicator_fade == "in" then
					alpha = math.max(0, 1 - self.save_indicator_fade_time/save_fade_time)
				elseif self.save_indicator_fade == "out" then
					alpha = math.min(1,self.save_indicator_fade_time/save_fade_time)
				end
			end
			self.saving_indicator:GetAnimState():SetMultColour(1,1,1,alpha)
		else
			self.save_indicator_time_left = self.save_indicator_time_left - dt
			if self.num_pending_saves <= 0 and self.save_indicator_time_left <= 0 then
				self.save_indicator_fade = "out"
				self.save_indicator_fade_time = save_fade_time
			end
		end
	end

	if self.consoletext.shown then
		self:UpdateConsoleOutput()
	end

	self:DoFadingUpdate(dt)
	self:DoTitleFade(dt)

	if #self.screenstack > 0 then
		self.screenstack[#self.screenstack]:OnUpdate(dt)
	end

    if not self:IsControlsDisabled() then

        --Spinner repeat
        if not (TheInput:IsControlPressed(CONTROL_PREVVALUE) or
                TheInput:IsControlPressed(CONTROL_NEXTVALUE)) then
            self.spinner_repeat_time = -1
        elseif self.spinner_repeat_time > dt then
            self.spinner_repeat_time = self.spinner_repeat_time - dt
        elseif self.spinner_repeat_time < 0 then
            self.spinner_repeat_time = SPINNER_REPEAT_TIME > dt and SPINNER_REPEAT_TIME - dt or 0
        elseif TheInput:IsControlPressed(CONTROL_PREVVALUE) then
            self.spinner_repeat_time = SPINNER_REPEAT_TIME
            self:OnControl(CONTROL_PREVVALUE, true)
        else--if TheInput:IsControlPressed(CONTROL_NEXTVALUE) then
            self.spinner_repeat_time = SPINNER_REPEAT_TIME
            self:OnControl(CONTROL_NEXTVALUE, true)
        end

        --Scroll repeat
        if not (TheInput:IsControlPressed(CONTROL_SCROLLBACK) or
                TheInput:IsControlPressed(CONTROL_SCROLLFWD)) then
            self.scroll_repeat_time = -1
        elseif self.scroll_repeat_time > dt then
            self.scroll_repeat_time = self.scroll_repeat_time - dt
        elseif TheInput:IsControlPressed(CONTROL_SCROLLBACK) then
            local repeat_time =
                TheInput:GetControlIsMouseWheel(CONTROL_SCROLLBACK) and
                MOUSE_SCROLL_REPEAT_TIME or
                SCROLL_REPEAT_TIME
            if self.scroll_repeat_time < 0 then
                self.scroll_repeat_time = repeat_time > dt and repeat_time - dt or 0
            else
                self.scroll_repeat_time = repeat_time
                self:OnControl(CONTROL_SCROLLBACK, true)
            end
        else--if TheInput:IsControlPressed(CONTROL_SCROLLFWD) then
            local repeat_time =
                TheInput:GetControlIsMouseWheel(CONTROL_SCROLLFWD) and
                MOUSE_SCROLL_REPEAT_TIME or
                SCROLL_REPEAT_TIME
            if self.scroll_repeat_time < 0 then
                self.scroll_repeat_time = repeat_time > dt and repeat_time - dt or 0
            else
                self.scroll_repeat_time = repeat_time
                self:OnControl(CONTROL_SCROLLFWD, true)
            end
        end

        --Menu nav repeat
        --skip while editing a text box
        if self.repeat_time > dt then
            self.repeat_time = self.repeat_time - dt

			if self.crafting_navigation_mode then
				if not (   TheInput:IsControlPressed(CONTROL_INVENTORY_LEFT) or (not controller and TheInput:IsControlPressed(CONTROL_FOCUS_LEFT))
						or TheInput:IsControlPressed(CONTROL_INVENTORY_RIGHT) or (not controller and TheInput:IsControlPressed(CONTROL_FOCUS_RIGHT))
						or TheInput:IsControlPressed(CONTROL_INVENTORY_UP) or (not controller and TheInput:IsControlPressed(CONTROL_FOCUS_UP))
						or TheInput:IsControlPressed(CONTROL_INVENTORY_DOWN) or (not controller and TheInput:IsControlPressed(CONTROL_FOCUS_DOWN)) ) then

            		self.repeat_time = 0
					self.repeat_reps = 0
				end
			else
				if not (   TheInput:IsControlPressed(CONTROL_MOVE_LEFT) or TheInput:IsControlPressed(CONTROL_FOCUS_LEFT)
            			or TheInput:IsControlPressed(CONTROL_MOVE_RIGHT) or TheInput:IsControlPressed(CONTROL_FOCUS_RIGHT)
            			or TheInput:IsControlPressed(CONTROL_MOVE_UP) or TheInput:IsControlPressed(CONTROL_FOCUS_UP)
            			or TheInput:IsControlPressed(CONTROL_MOVE_DOWN) or TheInput:IsControlPressed(CONTROL_FOCUS_DOWN) ) then

            		self.repeat_time = 0
					self.repeat_reps = 0
				end
			end
		elseif not (self.textProcessorWidget ~= nil) then
            self.repeat_reps = self.repeat_reps and (self.repeat_reps + 1) or 1

			if self.crafting_navigation_mode then
				if TheInput:IsControlPressed(CONTROL_INVENTORY_LEFT) or (not controller and TheInput:IsControlPressed(CONTROL_FOCUS_LEFT)) then
					self:_RefreshRepeatDelay(CONTROL_INVENTORY_LEFT)
					self:OnFocusMove(MOVE_LEFT, true)
				elseif TheInput:IsControlPressed(CONTROL_INVENTORY_RIGHT) or (not controller and TheInput:IsControlPressed(CONTROL_FOCUS_RIGHT)) then
					self:_RefreshRepeatDelay(CONTROL_INVENTORY_RIGHT)
					self:OnFocusMove(MOVE_RIGHT, true)
				elseif TheInput:IsControlPressed(CONTROL_INVENTORY_UP) or (not controller and TheInput:IsControlPressed(CONTROL_FOCUS_UP)) then
					self:_RefreshRepeatDelay(CONTROL_INVENTORY_UP)
					self:OnFocusMove(MOVE_UP, true)
				elseif TheInput:IsControlPressed(CONTROL_INVENTORY_DOWN) or (not controller and TheInput:IsControlPressed(CONTROL_FOCUS_DOWN)) then
					self:_RefreshRepeatDelay(CONTROL_INVENTORY_DOWN)
					self:OnFocusMove(MOVE_DOWN, true)
				else
					self.repeat_time = 0
					self.repeat_reps = 0
				end
			else
				self.repeat_time = REPEAT_TIME

				if TheInput:IsControlPressed(CONTROL_MOVE_LEFT) or TheInput:IsControlPressed(CONTROL_FOCUS_LEFT) then
					self:OnFocusMove(MOVE_LEFT, true)
				elseif TheInput:IsControlPressed(CONTROL_MOVE_RIGHT) or TheInput:IsControlPressed(CONTROL_FOCUS_RIGHT) then
					self:OnFocusMove(MOVE_RIGHT, true)
				elseif TheInput:IsControlPressed(CONTROL_MOVE_UP) or TheInput:IsControlPressed(CONTROL_FOCUS_UP) then
					self:OnFocusMove(MOVE_UP, true)
				elseif TheInput:IsControlPressed(CONTROL_MOVE_DOWN) or TheInput:IsControlPressed(CONTROL_FOCUS_DOWN) then
					self:OnFocusMove(MOVE_DOWN, true)
				else
					self.repeat_time = 0
					self.repeat_reps = 0
				end
			end
        end

        self:DoHoverFocusUpdate()
    end

    self:OnRenderImGui(dt)

	TheSim:ProfilerPush("update widgets")
	if not self.updating_widgets_alt then
		self.updating_widgets_alt = {}
	end

	for k,v in pairs(self.updating_widgets) do
		self.updating_widgets_alt[k] = v
	end

	for k,v in pairs(self.updating_widgets_alt) do
		if k.enabled then
			k:OnUpdate(dt)
		end
		self.updating_widgets_alt[k] = nil
	end

	self.helptext:Hide()
	if controller
        and self:GetFadeLevel() < 1
		and not self.crafting_navigation_mode
        and not (self.fadedir == FADE_OUT and self.fade_type ~= "black") then
		local str = self:GetHelpText()
		if str ~= "" then
			if str ~= self.helptextstring then
				self.helptexttext:SetRegionSize(100, 40)
				local num_lines = self.helptexttext:SetMultilineTruncatedString(str, HELP_TEXT_MAX_LINES, HELP_TEXT_MAX_WIDTH, self.helptext_max_characters_per_line, nil, nil, nil, "  ")
				self:UpdateHelpTextSize(num_lines)				
				self.helptextstring = str
			end
			self.helptext:Show()
		end
	end

	TheSim:ProfilerPop()
end

function FrontEnd:DoHoverFocusUpdate(manual_update)
    if self.tracking_mouse and not self.focus_locked then
		if manual_update then
			--something has been manually moved, so we want to update the entities under the mouse and re-evaluate the hover/focus state
			TheInput:UpdateEntitiesUnderMouse()
		end
	    local entitiesundermouse = TheInput:GetAllEntitiesUnderMouse()
        local hover_inst = entitiesundermouse[1]
        if hover_inst and hover_inst.widget then
            hover_inst.widget:SetFocus()
        elseif #self.screenstack > 0 then
            self.screenstack[#self.screenstack]:SetFocus()
        end
    end
end

function FrontEnd:StartUpdatingWidget(w)
	self.updating_widgets[w] = true
end

function FrontEnd:StopUpdatingWidget(w)
	self.updating_widgets[w] = nil
end

function FrontEnd:InsertScreenAtIndex(screen, idx)
    self.screenroot:AddChild(screen)
    table.insert(self.screenstack, idx, screen)
    for i = idx, #self.screenstack do
        self.screenstack[i]:MoveToFront()
    end
    self.consoletext:MoveToFront()
    self.serverpausewidget:MoveToFront()
end

function FrontEnd:InsertScreenUnderTop(screen)
    self.screenroot:AddChild(screen)
    table.insert(self.screenstack, #self.screenstack, screen)
    self.screenstack[#self.screenstack]:MoveToFront()
    self.consoletext:MoveToFront()
    self.serverpausewidget:MoveToFront()
end

function FrontEnd:PushScreen(screen)
	self.focus_locked = false
	self:SetForceProcessTextInput(false)
	TheInputProxy:FlushInput()

	--self.tracking_mouse = false
	--jcheng: don't allow any other screens to push if we're displaying an error
    --if global_error_widget ~= nil then return end -- Note: this just leaves screens outside the screen hierarchy which is worse than having them pushed

    Print(VERBOSITY.DEBUG, 'FrontEnd:PushScreen', screen.name)
    if #self.screenstack > 0 then
        self.screenstack[#self.screenstack]:OnBecomeInactive()
    end

    self.screenroot:AddChild(screen)
    table.insert(self.screenstack, screen)
    self.consoletext:MoveToFront()
    self.serverpausewidget:MoveToFront()
    self.serverpausewidget:SetOffset(0, 0)

    if screen.OffsetServerPausedWidget then
        screen:OffsetServerPausedWidget(self.serverpausewidget)
    end

    -- screen:Show()
    if not self.tracking_mouse then
        screen:SetDefaultFocus()
    end
    screen:OnBecomeActive()
    self:Update(0)

	--print("FOCUS IS", screen:GetDeepestFocus(), self.tracking_mouse)
	--self:Fade(FADE_IN, 2)
end

function FrontEnd:ClearScreens()
	if #self.screenstack > 0 then
		self.screenstack[#self.screenstack]:OnLoseFocus()
	end

	while #self.screenstack > 0 do
		self.screenstack[#self.screenstack]:OnDestroy()
		table.remove(self.screenstack, #self.screenstack)
	end
end

function FrontEnd:ShowConsoleLog()
	self.consoletext:Show()
end

function FrontEnd:HideConsoleLog()
	self.consoletext:Hide()
end

function FrontEnd:SetConsoleLogPosition(x, y, z)
    self.consoletext:SetPosition(x, y, z)
end

function FrontEnd:DoFadeIn(time_to_take)
	self:Fade(FADE_IN, time_to_take)
end

-- **CAUTION** about using the "alpha" fade: it leaves your screen's widgets at alpha 0 when it's finished AND makes all children of the screen not clickable
-- It generally leaves the screen in bad state: don't use lightly for screens that will be returned to (ex: we only use it leading into a sim reset)
-- Fixup after using an "alpha" fade would include making the appropriate children of the screen clickable and setting alphas appropriately
function FrontEnd:Fade(in_or_out, time_to_take, cb, fade_delay_time, delayovercb, fadeType)
	self.fadedir = in_or_out
	self.total_fade_time = time_to_take
	self.fadecb = cb
	self.fade_time = 0
	self.fade_type = fadeType or "black"
	if in_or_out == FADE_IN then
		self:SetFadeLevel(1)
	else
		-- starting a fade out, make the top fade visible again
		-- this place it can actually be out of sync with the backfade, so make it full trans
		if self.fade_type == "white" then
			self.topwhiteoverlay:SetTint(FADE_WHITE_COLOUR[1], FADE_WHITE_COLOUR[2], FADE_WHITE_COLOUR[3], 0)
			self.topvigoverlay:SetTint(1,1,1,0)
		elseif self.fade_type == "black" then
			self.topblackoverlay:SetTint(0,0,0,0)
		elseif self.fade_type == "swipe" then
			self.topswipeoverlay:SetTint(1,1,1,0)
			self.topswipeoverlay:SetEffectParams(0,0,0,0)
		end
		self:ShowTopFade()
        DoAutopause()
	end
	self.fade_delay_time = fade_delay_time
	self.delayovercb = delayovercb
end

function FrontEnd:FadeToScreen( existing_screen, new_screen_fn, fade_complete_cp, fade_type )
	local fade_time = SCREEN_FADE_TIME
	if fade_type == "swipe" then
		fade_time = SWIPE_FADE_TIME
	end

	self:Fade(FADE_OUT, fade_time,
		function()
			local new_screen = new_screen_fn()
			TheFrontEnd:PushScreen( new_screen )
            TheFrontEnd:Fade(FADE_IN, fade_time, fade_complete_cp and function() fade_complete_cp(new_screen) end, 0, nil, fade_type )
            existing_screen:Hide()
		end,
	0, nil, fade_type)
end

function FrontEnd:FadeBack( fade_complete_cb, fade_type, fade_out_complete_cb )
	local fade_time = SCREEN_FADE_TIME
	if fade_type == "swipe" then
		fade_time = SWIPE_FADE_TIME
	end

	self:Fade(FADE_OUT, fade_time,
		function()
			if fade_out_complete_cb ~= nil then
				fade_out_complete_cb()
			end
			TheFrontEnd:PopScreen()
            TheFrontEnd:Fade(FADE_IN, fade_time, fade_complete_cb, 0, nil, fade_type)
            TheFrontEnd:GetActiveScreen():Show()
		end,
	0, nil, fade_type)
end

function FrontEnd:PopScreen(screen)
	self.focus_locked = false
	self:SetForceProcessTextInput(false)
	TheInputProxy:FlushInput()
	--self.tracking_mouse = false

	local old_head = #self.screenstack > 0 and self.screenstack[#self.screenstack]
	if screen then
		-- screen:Hide()
		Print(VERBOSITY.DEBUG,'FrontEnd:PopScreen', screen.name)
		for k,v in ipairs(self.screenstack) do
			if v == screen then
				if old_head == v then
					screen:OnBecomeInactive()
				end
				table.remove(self.screenstack, k)
				screen:OnDestroy()
				self.screenroot:RemoveChild(screen)
				break
			end
		end
	else
		Print(VERBOSITY.DEBUG,'FrontEnd:PopScreen')
		if #self.screenstack > 0 then
			local screen = self.screenstack[#self.screenstack]
			table.remove(self.screenstack, #self.screenstack)
			screen:OnBecomeInactive()
			screen:OnDestroy()
			self.screenroot:RemoveChild(screen)
		end

	end

    local top_screen = self.screenstack[#self.screenstack]
	if top_screen and old_head ~= top_screen then
		top_screen:SetFocus()
		top_screen:OnBecomeActive()

        self.serverpausewidget:SetOffset(0, 0)

        if top_screen.OffsetServerPausedWidget then
            top_screen:OffsetServerPausedWidget(self.serverpausewidget)
        end

        TheInput:UpdateEntitiesUnderMouse()
		self:Update(0)

		--print ("POP!", self.screenstack[#self.screenstack]:GetDeepestFocus(), self.tracking_mouse)
		--self:Fade(FADE_IN, 1)
	end
end

function FrontEnd:ClearFocus()
	if #self.screenstack > 0 then
		self.screenstack[#self.screenstack]:SetFocus()
	end
end

function FrontEnd:GetActiveScreen()
    return #self.screenstack > 0 and self.screenstack[#self.screenstack] or nil
end

function FrontEnd:GetOpenScreenOfType(screenname)
	for _,v in ipairs_reverse(self.screenstack) do
		if v.name == screenname then
			return v
		end
	end

	return nil
end

function FrontEnd:GetScreenStackSize()
    return #self.screenstack
end

function FrontEnd:ShowScreen(screen)
	self:ClearScreens()
	if screen then
		self:PushScreen(screen)
	end
end

function FrontEnd:SetForceProcessTextInput(takeText, widget)
	if takeText and widget then
		-- Tell whatever the previous widget was to quit it
		if self.textProcessorWidget then
			self.textProcessorWidget:OnStopForceProcessTextInput()
		end
		self.textProcessorWidget = widget
		self.forceProcessText = true
	elseif widget == nil or widget == self.textProcessorWidget then
		if self.textProcessorWidget then
			self.textProcessorWidget:OnStopForceProcessTextInput()
		end
		self.textProcessorWidget = nil
		self.forceProcessText = false
	end
end

function FrontEnd:OnRawKey(key, down)
    if self:IsControlsDisabled() then
        return false
    end

    local screen = self:GetActiveScreen()
    if screen ~= nil then
        if self.forceProcessText and self.textProcessorWidget ~= nil then
            self.textProcessorWidget:OnRawKey(key, down)
        elseif not screen:OnRawKey(key, down) and CHEATS_ENABLED then
            DoDebugKey(key, down)
        end
    end
end

function FrontEnd:OnTextInput(text)
    if self:IsControlsDisabled() then
        return false
    end

    local screen = self:GetActiveScreen()
    if screen ~= nil then
        if self.forceProcessText and self.textProcessorWidget ~= nil then
            self.textProcessorWidget:OnTextInput(text)
        else
            screen:OnTextInput(text)
        end
    end
end

--V2C: -exclude resolution scaling
--     -useful when parents already have SCALEMODE_PROPORTIONAL
function FrontEnd:GetProportionalHUDScale()
	local size = Profile:GetHUDSize()
	local min_scale = .75
	local max_scale = 1.1

	return easing.linear(size, min_scale, max_scale - min_scale, 10)
end

function FrontEnd:GetHUDScale()
    local size = Profile:GetHUDSize()
    local min_scale = .75
    local max_scale = 1.1

    --testing high res displays
    local w, h = TheSim:GetScreenSize()

    local res_scale_x = math.max(1, w / 1920)
    local res_scale_y = math.max(1, h / 1200)
    local res_scale = math.min(res_scale_x, res_scale_y)

    return easing.linear(size, min_scale, max_scale - min_scale, 10) * res_scale
end

function FrontEnd:GetCraftingMenuScale()
    local size = Profile:GetCraftingMenuSize()
    local min_scale = .6
    local max_scale = 1.15
	if IsSplitScreen() then
		min_scale = 1.0
		max_scale = 1.92
	end

    --testing high res displays
    local w, h = TheSim:GetScreenSize()

    local res_scale_x = math.max(1, w / 1920)
    local res_scale_y = math.max(1, h / 1200)
    local res_scale = math.min(res_scale_x, res_scale_y)

    return easing.linear(size, min_scale, max_scale - min_scale, 10) * res_scale
end

function FrontEnd:UpdateRepeatDelays()
	local craft_sensitivity = Profile:GetCraftingMenuSensitivity()
	self.crafting_repeat_base = easing.linear(20-craft_sensitivity, .11, .4 - .11, 20)
	self.crafting_repeat_fast = self.crafting_repeat_base * 0.4
	self.crafting_repeat_ninja = self.crafting_repeat_base * 0.2

	local inv_sensitivity = Profile:GetInventorySensitivity()
	self.inventory_repeat_base = easing.linear(20-inv_sensitivity, .11, .4 - .11, 20)
	self.inventory_repeat_fast = self.inventory_repeat_base * 0.4
	self.inventory_repeat_ninja = self.inventory_repeat_base * 0.2

	--print("UpdateRepeatDelays crafting  ", craft_sensitivity, self.crafting_repeat_base, self.crafting_repeat_fast, self.crafting_repeat_ninja)
	--print("                   inventory ", inv_sensitivity, self.inventory_repeat_base, self.inventory_repeat_fast, self.inventory_repeat_ninja)
end

function FrontEnd:OnMouseButton(button, down, x, y)
    if self:IsControlsDisabled() then
        return false
    end

    self.tracking_mouse = true

    if #self.screenstack > 0 and self.screenstack[#self.screenstack]:OnMouseButton(button, down, x, y) then
        return true
    end

    return CHEATS_ENABLED and DoDebugMouse(button, down, x, y)
end

function FrontEnd:OnMouseMove(x, y)
    if self:IsControlsDisabled() then
        return false
    end

    if self.lastx ~= nil and self.lasty ~= nil and self.lastx ~= x and self.lasty ~= y then
        self.tracking_mouse = true
    end

    self.lastx = x
	self.lasty = y
end

function FrontEnd:OnSaveLoadError(operation, filename, status)
    self:HideSavingIndicator() -- in case it's still being shown for some reason

    local function retry()
        self:PopScreen() -- saveload error message box
        if operation == SAVELOAD.OPERATION.LOAD then

            local function OnSaveGameIndexLoaded(success)
                --print("OnSaveGameIndexLoaded", success)
            end

            local function OnProfileLoaded(success)
                --print("OnProfileLoaded", success)
                if success then

                    SaveGameIndex:Load(function()
                        ShardSaveGameIndex:Load(function()
                            ShardGameIndex:Load(OnSaveGameIndexLoaded)
                        end)
                    end)
                end
            end

            local function OnMorgueLoaded(success)
                --print("OnMorgueloaded", success)
                if success then
                    Profile:Load(OnProfileLoaded)
                end
            end

            Morgue:Load(OnMorgueLoaded)

        elseif operation == SAVELOAD.OPERATION.SAVE then
            -- the system service knows which files are not saved and will try to save them
            self:ShowSavingIndicator()
            TheSystemService:RetryOperation(operation, filename)
        elseif operation == SAVELOAD.OPERATION.DELETE then
            TheSystemService:RetryOperation(operation, filename)
        end
    end

    if status == SAVELOAD.STATUS.DAMAGED then
        print("OnSaveLoadError", "Damaged save data popup")
        local function overwrite()
            local function on_overwritten(success)
                self:HideSavingIndicator()
                TheSystemService:EnableAutosave(success)
            end

            -- OverwriteStorage will also try to resave any files found in the cache
            self:ShowSavingIndicator()
            TheSystemService:OverwriteStorage(on_overwritten)
            self:PopScreen() -- saveload error message box
        end

        local function cancel()
            TheSystemService:EnableStorage(TheSystemService:IsAutosaveEnabled())
            TheSystemService:ClearLastOperation()
            self:PopScreen() -- saveload error message box
        end

        local function confirm_autosave_disable()

            local function disable_autosave()
                TheSystemService:EnableStorage(false)
                TheSystemService:EnableAutosave(false)
                TheSystemService:ClearLastOperation()
                self:PopScreen() -- confirmation message box
                self:PopScreen() -- saveload error message box
            end

            local function dont_disable()
                self:PopScreen() -- confirmation message box
            end

            local confirmation = PopupDialogScreen(STRINGS.UI.SAVELOAD.DISABLE_AUTOSAVE, "",
                {
                    {text=STRINGS.UI.SAVELOAD.YES, cb = disable_autosave},
                    {text=STRINGS.UI.SAVELOAD.NO, cb = dont_disable},
                }
            )
            confirmation.title:SetPosition(0, 40, 0)
            self:PushScreen(confirmation)
        end

        local cancel_cb = cancel
        if TheSystemService:IsAutosaveEnabled() then
            cancel_cb = confirm_autosave_disable
        end

        local popup = PopupDialogScreen(STRINGS.UI.SAVELOAD.DATA_DAMAGED, "",
            {
                {text=STRINGS.UI.SAVELOAD.RETRY, cb = retry},
                {text=STRINGS.UI.SAVELOAD.OVERWRITE, cb = overwrite},
                {text=STRINGS.UI.SAVELOAD.CANCEL, cb = cancel_cb},
            }
        )
        self:PushScreen(popup)

    elseif status == SAVELOAD.STATUS.FAILED then

        local function cancel()
            TheSystemService:ClearLastOperation()
            self:PopScreen() -- saveload error message box
        end

        local text
        if operation == SAVELOAD.OPERATION.LOAD then
            text = STRINGS.UI.SAVELOAD.LOAD_FAILED
        elseif operation == SAVELOAD.OPERATION.SAVE then
            text = STRINGS.UI.SAVELOAD.SAVE_FAILED
        elseif operation == SAVELOAD.OPERATION.DELETE then
            text = STRINGS.UI.SAVELOAD.DELETE_FAILED
        end

        local popup = PopupDialogScreen(text, "",
            {
                {text=STRINGS.UI.SAVELOAD.RETRY, cb = retry},
                {text=STRINGS.UI.SAVELOAD.CANCEL, cb = cancel},
            }
        )
        self:PushScreen(popup)
    end
end

function OnSaveLoadError(operation, filename, status)
    TheFrontEnd:OnSaveLoadError(operation, filename, status)
end

function FrontEnd:IsScreenInStack(screen)
    for _,screen_in_stack in pairs(self.screenstack) do
        if screen_in_stack == screen then
            return true
        end
    end
    return false
end

function FrontEnd:SetOfflineMode(isOffline)
    self.offline = isOffline
end

function FrontEnd:GetIsOfflineMode()
    return self.offline
end

function FrontEnd:ToggleImgui(node)
	if not CAN_USE_DBUI then
		return
	end

    if TheRawImgui:IsImguiEnabled() then
        if self.imgui_enabled then
            self.imgui_enabled = false
        else
            self.imgui_enabled = true
            self.imgui.ActivateImgui()

            if #self.debug_panels == 0 and not node then
                self:CreateDebugPanel( DebugEntity() )
            end
        end
    else
        print("IsImguiEnabled is disabled due to threaded renderer being enabled")
        if self.ignoredebugpanelwarning == nil then
            local dialogue = PopupDialogScreenRedux("[DEV] Bad threaded renderer setting!", "You are trying to use a debug panel but have threaded renderer ON, please turn it OFF.", {
                {
                    text = "Ignore for now",
                    cb = function()
                        self.ignoredebugpanelwarning = true
                        TheFrontEnd:PopScreen()
                    end
                },{
                    text = "Turn OFF and Quit",
                    cb = function()
                        Profile:SetThreadedRenderEnabled(false)
                        Profile:Save(function()
                            RequestShutdown()
                        end)
                    end
                },
            }, nil, "big")
            self:PushScreen(dialogue)
        end
    end
end


function FrontEnd:IsDebugPanelOpen( nodename )
	if not CAN_USE_DBUI then
		return false
	end

    for i, panel in ipairs(self.debug_panels) do
        if panel:GetNode().NodeName == nodename then
            return true
        end
    end
    return false
end

function FrontEnd:CloseDebugPanel( nodename )
	if not CAN_USE_DBUI then
		return
	end

    for i, panel in ipairs(self.debug_panels) do
        if panel:GetNode().NodeName == nodename then
            panel:OnClose()
            table.remove( self.debug_panels, i )
        end
    end
end

function FrontEnd:CreateDebugPanel( node )
	if not CAN_USE_DBUI then
		return
	end

	local node = DebugPanel2( node )
    node.type = node
	if not self.imgui_enabled then
		self:ToggleImgui(node)
	end

	table.insert( self.debug_panels, node )
    -- If you want to stuff values into the PrefabEditor, it's the input node
	-- that you want to modify, not this panel. If you want to modify windowing
	-- info, then this panel is where it's at.
	return node
end

-- Takes the same argument as CreateDebugPanel -- the class of a debug panel
-- node.
function FrontEnd:FindOpenDebugPanel( node )
	for _, panel in ipairs(self.debug_panels) do
		if panel.type:is_a(node) then
			return panel
		end
	end
end

function FrontEnd:GetNumberOpenDebugPanels( node )
	local numOpenPanels = 0
	for _, panel in ipairs(self.debug_panels) do
		if panel.type:is_a(node) then
			numOpenPanels = numOpenPanels + 1
		end
	end

	return numOpenPanels
end

function FrontEnd:GetSelectedDebugPanel()

	for _, panel in ipairs(self.debug_panels) do
		if panel.isSelected then
			return panel
		end
	end

	return nil
end

function FrontEnd:SetImguiFontSize( font_size )
	self.imgui_font_size = font_size
    Profile:SetValue("imgui_font_size", self.imgui_font_size)
    Profile.dirty = true
    Profile:Save()
end

function FrontEnd:OnRenderImGui(dt)
	if not CAN_USE_DBUI then
		return
	end

	if not self.imgui_is_running and self.imgui_enabled then

		local i = 1

		--jcheng: this is to stop imgui from re-running while inside imgui, for example if you do a sim step
		self.imgui_is_running = true

		while i <= #self.debug_panels do
			local panel = self.debug_panels[i]

			local ok, result = xpcall( function() return panel:RenderPanel(self.imgui, i, dt) end, generic_error )
			if ok and panel:WantsToClose() then
				result = false
			end

			if not ok or not result then
				print("closing panel "..tostring(panel))
				panel:OnClose()
				table.remove( self.debug_panels, i )
				if not ok then
					print( tostring(result) )
					break
				end
			else
				i = i + 1
			end
		end

		if #self.debug_panels == 0 then
			self.imgui_enabled = false
		end

		self.imgui_is_running = false
	end

	self.debugMenu:Render(dt)
end

function FrontEnd:IsImGuiWindowFocused(flags)
	if not CAN_USE_DBUI then
		return false
	end

    return self.imgui ~= nil and imgui ~= nil and self.imgui:IsWindowFocused(flags or imgui.FocusedFlags.AnyWindow)
end

function FrontEnd:SetServerPauseText(source)
    self.serverpausewidget:UpdateText(source)
end

function FrontEnd:SetGlobalErrorWidget(...)
	if not self.cachedError then
		self.cachedError = {...}
	end
end

function FrontEnd:ResetGlobalErrorWidget()
	self.cachedError = nil
end

function FrontEnd:CheckCachedError()
	if self.cachedError and not global_error_widget then
		local widget = ScriptErrorWidget(unpack(self.cachedError))
		widget:MarkTransformDirty()
		self:PushScreen(widget)

		-- Pushing screens is not allowed after creating the error widget, so
		-- assign it last.
		global_error_widget = widget
	end
end