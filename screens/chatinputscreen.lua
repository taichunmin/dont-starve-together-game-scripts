require "util"
local TextCompleter = require "util/textcompleter"
local Screen = require "widgets/screen"
local TextEdit = require "widgets/textedit"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local ScrollableChatQueue = require "widgets/redux/scrollablechatqueue"
--local VirtualKeyboard = require "screens/virtualkeyboard"


local Emoji = require("util/emoji")
local UserCommands = require("usercommands")

local use_virtual_keyboard = TheInput ~= nil and TheInput:PlatformUsesVirtualKeyboard() or false -- nil check is for build scripts
local is_steam_deck = IsSteamDeck()

local ChatInputScreen = Class(Screen, function(self, whisper)
    Screen._ctor(self, "ChatInputScreen")
    self.whisper = whisper
    self.runtask = nil
    self:DoInit()
end)

function ChatInputScreen:OnBecomeActive()
    ChatInputScreen._base.OnBecomeActive(self)

    self.chat_edit:SetFocus()
    self.chat_edit:SetEditing(true)

	if IsConsole() then
		TheFrontEnd:LockFocus(true)
	end

    if ThePlayer ~= nil and ThePlayer.HUD ~= nil then
        ThePlayer.HUD.controls.networkchatqueue:Hide()
    end
end

function ChatInputScreen:OnBecomeInactive()
    ChatInputScreen._base.OnBecomeInactive(self)

    if self.runtask ~= nil then
        self.runtask:Cancel()
        self.runtask = nil
    end

    if ThePlayer ~= nil and ThePlayer.HUD ~= nil then
        ThePlayer.HUD.controls.networkchatqueue:Show()
    end
end

function ChatInputScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

	if is_steam_deck then
		if not self:HasMessageToSend() then
			table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.CHATINPUTSCREEN.HELP_OPEN_VIRTUAL_KEYBOARD)
		else
			table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_1) .. " " .. STRINGS.UI.CHATINPUTSCREEN.HELP_WHISPER)
			table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.CHATINPUTSCREEN.HELP_SAY)
		end
	else
		if self.whisper then
			table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2) .. " " .. STRINGS.UI.CHATINPUTSCREEN.HELP_SAY)
			table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.CHATINPUTSCREEN.HELP_WHISPER)
		else
			table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2) .. " " .. STRINGS.UI.CHATINPUTSCREEN.HELP_WHISPER)
			table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.CHATINPUTSCREEN.HELP_SAY)
		end
	end

    return table.concat(t, "  ")
end

function ChatInputScreen:OnControl(control, down)
    if self.runtask ~= nil or ChatInputScreen._base.OnControl(self, control, down) then return true end

    if self.networkchatqueue:OnChatControl(control, down) then return true end

    --jcheng: don't allow debug menu stuff going on right now
    if control == CONTROL_OPEN_DEBUG_CONSOLE then
        return true
    end

	if not down and (control == CONTROL_CANCEL) then
		self:Close()
		return true
	end

    -- For controllers, the misc_2 button will whisper if in say mode or say if in whisper mode. This is to allow the player to only bind one key to initiate chat mode.
	if not use_virtual_keyboard then
		if TheInput:ControllerAttached() then
			if not down and control == CONTROL_MENU_MISC_2 then
				self.whisper = not self.whisper
				self:OnTextEntered()
				return true
			end

			if not down and (control == CONTROL_TOGGLE_SAY or control == CONTROL_TOGGLE_WHISPER) then
				self:Close()
				return true
			end
		end
	else -- has virtual keyboard
		if not down then
			if is_steam_deck then
				if control == CONTROL_MENU_MISC_1 then
					if self:HasMessageToSend() then
						self.whisper = true
						self:OnTextEntered()
					else
						self.chat_edit:SetEditing(true)
					end
					return true
				elseif control == CONTROL_ACCEPT then
					if self:HasMessageToSend() then
						self.whisper = false
						self:OnTextEntered()
					else
						self.chat_edit:SetEditing(true)
					end
					return true
				elseif control == CONTROL_CANCEL then
					self:Close()
					return true
				end
			else
				if control == CONTROL_MENU_MISC_2 then
					self.whisper = self.whisper
					self.chat_edit:SetEditing(true)
					return true
				elseif control == CONTROL_ACCEPT then
					self.whisper = false
					self.chat_edit:SetEditing(true)
					return true
				elseif control == CONTROL_CANCEL then
					self:Close()
					return true
				end
			end
		end
	end
end

function ChatInputScreen:OnRawKey(key, down)
    if self.runtask ~= nil then return true end
    if ChatInputScreen._base.OnRawKey(self, key, down) then
        return true
    end

    return false
end

function ChatInputScreen:HasMessageToSend()
	return self.chat_edit:GetString():match("^%s*(.-%S)%s*$") ~= nil
end

function ChatInputScreen:Run()
    local chat_string = self.chat_edit:GetString()
    chat_string = chat_string ~= nil and chat_string:match("^%s*(.-%S)%s*$") or ""
    if chat_string == "" then
        return
    elseif string.sub(chat_string, 1, 1) == "/" then
        --Process slash commands:
        UserCommands.RunTextUserCommand(string.sub(chat_string, 2), ThePlayer, false)
    elseif chat_string:utf8len() <= MAX_CHAT_INPUT_LENGTH then
        --Default to sending regular chat
        TheNet:Say(chat_string, self.whisper)
    end
end

function ChatInputScreen:Close()
    --SetPause(false)
    TheInput:EnableDebugToggle(true)
    TheFrontEnd:PopScreen(self)
end

local function DoRun(inst, self)
    self.runtask = nil
    self:Run()
    self:Close()
end

function ChatInputScreen:OnTextEntered()
    if self.runtask ~= nil then
        self.runtask:Cancel()
    end
    self.runtask = self.inst:DoTaskInTime(0, DoRun, self)
end

function ChatInputScreen:DoInit()
    --SetPause(true,"console")
    TheInput:EnableDebugToggle(false)

    local label_height = 50
    local fontsize = 30
    local edit_width = 850
    local edit_width_padding = 0
    local chat_type_width = 150

	if is_steam_deck then
		self.black = self:AddChild(Image("images/global.xml", "square.tex"))
		self.black:SetVRegPoint(ANCHOR_MIDDLE)
		self.black:SetHRegPoint(ANCHOR_MIDDLE)
		self.black:SetVAnchor(ANCHOR_MIDDLE)
		self.black:SetHAnchor(ANCHOR_MIDDLE)
		self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
		self.black:SetTint(0, 0, 0, .5)
	end

	self.screen_root = self:AddChild(Widget("chat_queue_root"))
    self.screen_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.screen_root:SetHAnchor(ANCHOR_MIDDLE)
    self.screen_root:SetVAnchor(ANCHOR_BOTTOM)

    self.chat_queue_root = self.screen_root:AddChild(Widget(""))
    self.chat_queue_root:SetPosition(-90,765,0)
    self.networkchatqueue = self.chat_queue_root:AddChild(ScrollableChatQueue())

    self.root = self.screen_root:AddChild(Widget(""))
    self.root:SetPosition(45.2, 100, 0)

	self.chat_type = self.root:AddChild(Text(TALKINGFONT, fontsize))
	self.chat_type:SetPosition(-505, 0, 0)
	self.chat_type:SetRegionSize(chat_type_width, label_height)
	self.chat_type:SetHAlign(ANCHOR_RIGHT)
	if self.whisper then
	    self.chat_type:SetString(STRINGS.UI.CHATINPUTSCREEN.WHISPER)
	else
	    self.chat_type:SetString(STRINGS.UI.CHATINPUTSCREEN.SAY)
	end
	self.chat_type:SetColour(.6, .6, .6, 1)

    self.chat_edit = self.root:AddChild(TextEdit(TALKINGFONT, fontsize, ""))
    self.chat_edit.edit_text_color = WHITE
    self.chat_edit.idle_text_color = WHITE
    self.chat_edit:SetEditCursorColour(unpack(WHITE))
    self.chat_edit:SetRegionSize(edit_width - edit_width_padding, label_height)
    self.chat_edit:SetHAlign(ANCHOR_LEFT)

    -- the screen will handle the help text
    self.chat_edit:SetHelpTextApply("")
    self.chat_edit:SetHelpTextCancel("")
    self.chat_edit:SetHelpTextEdit("")
    self.chat_edit.HasExclusiveHelpText = function() return false end

    self.chat_edit.OnTextEntered = function() self:OnTextEntered() end
    self.chat_edit:SetPassControlToScreen(CONTROL_CANCEL, true)
    self.chat_edit:SetPassControlToScreen(CONTROL_MENU_MISC_2, true) -- toggle between say and whisper
    self.chat_edit:SetPassControlToScreen(CONTROL_SCROLLBACK, true)
    self.chat_edit:SetPassControlToScreen(CONTROL_SCROLLFWD, true)
    self.chat_edit:SetTextLengthLimit(MAX_CHAT_INPUT_LENGTH)
    self.chat_edit:EnableWordWrap(false)
    --self.chat_edit:EnableWhitespaceWrap(true)
    self.chat_edit:EnableRegionSizeLimit(true)
    self.chat_edit:EnableScrollEditWindow(false)

	self.chat_edit:SetForceEdit(true)
    self.chat_edit.OnStopForceEdit = function() self:Close() end

    self.chat_edit:EnableWordPrediction({width = 800, mode=Profile:GetChatAutocompleteMode()})
    self.chat_edit:AddWordPredictionDictionary(Emoji.GetWordPredictionDictionary())
    self.chat_edit:AddWordPredictionDictionary(UserCommands.GetEmotesWordPredictionDictionary())

    self.chat_edit:SetString("")

	if is_steam_deck then
		self.default_focus = self.chat_edit

		self.chat_edit:SetPosition(-.5 * edit_width_padding, 520, 0)
		self.chat_edit:SetPassControlToScreen(CONTROL_ACCEPT, true)

		self.chat_type:SetString(STRINGS.UI.CHATINPUTSCREEN.STEAMDECK_MSG_PROMPT)
		self.chat_type:SetPosition(-505, 520, 0)
	elseif use_virtual_keyboard then
		self.chat_type:Hide()
	end
end

return ChatInputScreen
