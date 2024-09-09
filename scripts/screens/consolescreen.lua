require "util"
local Screen = require "widgets/screen"
local Image = require "widgets/image"
local TextEdit = require "widgets/textedit"
local Text = require "widgets/text"
local Widget = require "widgets/widget"
local ConsoleHistoryWidget = require "widgets/consolehistorywidget"

-- fix syntax highlighting due to above list: "'

-- To start your game with a prepopulated history, add to your customcommands.lua:
--      ConsoleScreenSettings:AddLastExecutedCommand('c_give("batbat"', true)

local DEBUG_MODE = BRANCH == "dev"

local ConsoleScreen = Class(Screen, function(self)
	Screen._ctor(self, "ConsoleScreen")
    self.runtask = nil
	self:DoInit()

	self.ctrl_pasting = false

	SetConsoleAutopaused(true)
end)

function ConsoleScreen:OnBecomeActive()
	ConsoleScreen._base.OnBecomeActive(self)
	TheFrontEnd:ShowConsoleLog()

	self.console_edit:SetFocus()
	self.console_edit:SetEditing(true)

	self:ToggleRemoteExecute(InGamePlay()) -- if we are admin, start in remote mode
end

function ConsoleScreen:OnBecomeInactive()
    ConsoleScreen._base.OnBecomeInactive(self)

    if self.runtask ~= nil then
        self.runtask:Cancel()
        self.runtask = nil
    end
end

function ConsoleScreen:OnDestroy()
	SetConsoleAutopaused(false)

	ConsoleScreen._base.OnDestroy(self)
end

function ConsoleScreen:OnControl(control, down)
	if self.runtask ~= nil or ConsoleScreen._base.OnControl(self, control, down) then return true end

	if not down and (control == CONTROL_CANCEL or control == CONTROL_OPEN_DEBUG_CONSOLE) then
		self:Close()
		return true
	end
end

function ConsoleScreen:ToggleRemoteExecute(force)
    local is_valid_time_to_use_remote = TheNet:GetIsClient() and (TheNet:GetIsServerAdmin() or IsConsole())
    if is_valid_time_to_use_remote then
        self.console_remote_execute:Show()
        if force == nil then
            self.toggle_remote_execute = not self.toggle_remote_execute
        elseif force == true then
            self.toggle_remote_execute = true
        elseif force == false then
            self.toggle_remote_execute = false
        end

        if self.toggle_remote_execute then
        	self.console_remote_execute:SetString(STRINGS.UI.CONSOLESCREEN.REMOTEEXECUTE)
        	self.console_remote_execute:SetColour(0.7,0.7,1,1)
        else
        	self.console_remote_execute:SetString(STRINGS.UI.CONSOLESCREEN.LOCALEXECUTE)
        	self.console_remote_execute:SetColour(1,0.7,0.7,1)
        end
	else
		self.console_remote_execute:Hide()
		if force == true or force == false then
			self.toggle_remote_execute = force
		else
			self.toggle_remote_execute = TheNet:GetIsServer()
		end
    end
end

function ConsoleScreen:OnRawKey(key, down)
	if TheInput:IsKeyDown(KEY_CTRL) and TheInput:IsPasteKey(key) then
		self.ctrl_pasting = true
	end

	if down then return end

	if self.runtask ~= nil then return true end
	if ConsoleScreen._base.OnRawKey(self, key, down) then
		return true
	end

	return self:OnRawKeyHandler(key, down)
end

function ConsoleScreen:OnRawKeyHandler(key, down)
	if TheInput:IsKeyDown(KEY_CTRL) and TheInput:IsPasteKey(key) then
		self.ctrl_pasting = true
	end

	if down then return end

	if key == KEY_UP then
		local history = ConsoleScreenSettings:GetConsoleHistory()
		local len = #history
		if len > 0 then
			if self.history_idx ~= nil then
				self.history_idx = math.clamp(self.history_idx - 1, 1, len)
			else
				self.history_idx = len
			end
			local historyline = history[self.history_idx]
			self.console_edit:SetString(historyline.str)
			self:ToggleRemoteExecute(historyline.remote or false) --can't pass nil, otherwise it will auto-toggle
			if BRANCH == "dev" then
				self.console_history:Show(history, self.history_idx)
			end
			self.console_edit.inst:PushEvent("onconsolehistoryupdated")
		end
	elseif key == KEY_DOWN then
		local history = ConsoleScreenSettings:GetConsoleHistory()
		local len = #history
		if len > 0 then
			if self.history_idx ~= nil then
				if self.history_idx >= len then
					self.console_edit:SetString( "" )
					self:ToggleRemoteExecute(InGamePlay())
					self.history_idx = len + 1
				else
					self.history_idx = self.history_idx + 1
					local historyline = history[self.history_idx]
					self.console_edit:SetString(historyline.str)
					self:ToggleRemoteExecute(historyline.remote or false) --can't pass nil, otherwise it will auto-toggle
					if BRANCH == "dev" then
						self.console_history:Show(history, self.history_idx)
					end
					self.console_edit.inst:PushEvent("onconsolehistoryupdated")
				end
			end
		end
	elseif (key == KEY_LCTRL or key == KEY_RCTRL) and not self.ctrl_pasting then
       self:ToggleRemoteExecute()
	end

	if self.ctrl_pasting and (key == KEY_LCTRL or key == KEY_RCTRL) then
		self.ctrl_pasting = false
	end

	return true
end

function ConsoleScreen:Run()
	local fnstr = self.console_edit:GetString()

    SuUsedAdd("console_used")

	if fnstr ~= "" then
		ConsoleScreenSettings:AddLastExecutedCommand(fnstr, self.toggle_remote_execute)
	end

	if self.toggle_remote_execute and TheNet:GetIsClient() and (TheNet:GetIsServerAdmin() or IsConsole()) then
        local x, y, z = TheSim:ProjectScreenPos(TheSim:GetPosition())
		TheNet:SendRemoteExecute(fnstr, x, z)
	else
		ExecuteConsoleCommand(fnstr)
	end
end

function ConsoleScreen:Close()
	--SetPause(false)
	TheInput:EnableDebugToggle(true)
	TheFrontEnd:PopScreen(self)
	TheFrontEnd:HideConsoleLog()
end

local function DoRun(inst, self)
    self.runtask = nil
    self:Run()
    self:Close()
    if TheFrontEnd.consoletext.closeonrun then
        TheFrontEnd:HideConsoleLog()
    end

	ConsoleScreenSettings:Save()
end

function ConsoleScreen:OnTextEntered()
	if BRANCH == "dev" then
		if self.console_history:IsVisible() then
			self.console_history:Hide()
			self.console_edit:SetFocus()
			self.console_edit:SetEditing(true)
			return
		end
	end

    if self.runtask ~= nil then
        self.runtask:Cancel()
	end
    self.runtask = self.inst:DoTaskInTime(0, DoRun, self)
end

-- NOTES(JBK): Caching these to only walk the tables once if a player opens the console or has it enabled to open they should know what they are doing for memory usage.
local prediction_command_c, prediction_command_d, prefab_names

function ConsoleScreen:DoInit()
	--SetPause(true,"console")
	TheInput:EnableDebugToggle(false)

	local label_height = 50
	local fontsize = 30
	local edit_width = 900
	local edit_bg_padding = 100

	self.edit_width   = edit_width
	self.label_height = label_height

	self.root = self:AddChild(Widget(""))
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetVAnchor(ANCHOR_BOTTOM)
    --self.root:SetMaxPropUpscale(MAX_HUD_SCALE)
	self.root = self.root:AddChild(Widget(""))
	self.root:SetPosition(0,100,0)

    self.edit_bg = self.root:AddChild( Image() )
	self.edit_bg:SetTexture( "images/textboxes.xml", "textbox_long.tex" )
	self.edit_bg:SetPosition( 0, 0 )
	self.edit_bg:ScaleToSize( edit_width + edit_bg_padding, label_height )

	self.console_remote_execute = self.root:AddChild( Text( DEFAULTFONT, fontsize ) )
	self.console_remote_execute:SetString( STRINGS.UI.CONSOLESCREEN.REMOTEEXECUTE )
	self.console_remote_execute:SetRegionSize( 200, fontsize + 5 )
	self.console_remote_execute:SetPosition( -edit_width*0.5 -200*0.5 - 35, 0 )
	self.console_remote_execute:SetHAlign( ANCHOR_RIGHT )
	self.console_remote_execute:SetColour( 0.7, 0.7, 1, 1 )
	self.console_remote_execute:Hide()

	self.console_edit = self.root:AddChild( TextEdit( DEFAULTFONT, fontsize, "" ) )
	self.console_edit.edit_text_color = {1,1,1,1}
	self.console_edit.idle_text_color = {1,1,1,1}
	self.console_edit:SetEditCursorColour(1,1,1,1)
	self.console_edit:SetPosition( -4,0,0)
	self.console_edit:SetRegionSize( edit_width, label_height )
	self.console_edit:SetHAlign(ANCHOR_LEFT)
	self.console_edit:SetHelpTextEdit("")
    self.console_edit.ignoreVirtualKeyboard = true

	self.console_edit.OnTextEntered = function() self:OnTextEntered() end
	self.console_edit:SetInvalidCharacterFilter( [[`	]] )
    self.console_edit:SetPassControlToScreen(CONTROL_CANCEL, true)

	self.console_edit:SetString("")

	--setup prefab keys
    if not prefab_names then
        prefab_names = {}
        for name, _ in pairs(Prefabs) do
            table.insert(prefab_names, name)
        end
    end

	self.console_edit:EnableWordPrediction({width = 1000, mode=Profile:GetConsoleAutocompleteMode()})
	self.console_edit:AddWordPredictionDictionary({words = prefab_names, delim = '"', postfix='"', skip_pre_delim_check=true})
	self.console_edit:AddWordPredictionDictionary({words = prefab_names, delim = "'", postfix="'", skip_pre_delim_check=true})

    local should_c = not prediction_command_c
    -- NOTES(JBK): In production debugcommands is not loaded this package.loaded check is here if a player manually loads it up later.
    local should_d = not prediction_command_d and package.loaded["debugcommands"]

    if should_c or should_d then
        if should_c then
            prediction_command_c = {}
        end
        if should_d then
            prediction_command_d = {}
        end
        for k, v in pairs(_G) do
            if type(v) == "function" then
                if should_c and k:find("c_") == 1 then
                    table.insert(prediction_command_c, k:sub(3, -1))
                elseif should_d and k:find("d_") == 1 then
                    table.insert(prediction_command_d, k:sub(3, -1))
                end
            end
        end
    end
    self.console_edit:AddWordPredictionDictionary({words = prediction_command_c, delim = "c_", num_chars = 0})
    if prediction_command_d then
        self.console_edit:AddWordPredictionDictionary({words = prediction_command_d, delim = "d_", num_chars = 0})
    end

	self.console_edit:SetForceEdit(true)
    self.console_edit.OnStopForceEdit = function() self:Close() end
    self.console_edit.OnRawKey = function(s, key, down) if TextEdit.OnRawKey(self.console_edit, key, down) then return true end self:OnRawKeyHandler(key, down) end

	self.console_edit.validrawkeys[KEY_LCTRL] = true
	self.console_edit.validrawkeys[KEY_RCTRL] = true
	self.console_edit.validrawkeys[KEY_UP] = true
	self.console_edit.validrawkeys[KEY_DOWN] = true
	self.console_edit.validrawkeys[KEY_V] = true
	self.toggle_remote_execute = false

	if BRANCH == "dev" then
		-- Setup console history display
		self.console_history = self.console_edit:AddChild(ConsoleHistoryWidget(self.console_edit, self.console_remote_execute, 800, Profile:GetConsoleAutocompleteMode()))
		local sx, sy = self.console_edit:GetRegionSize()
		self.console_history:SetPosition(-sx * 0.5, sy * 0.5 + 5)
		self.console_history:Hide()

		self.console_history.inst:ListenForEvent("onconsolehistoryitemclicked", function()
			local history = ConsoleScreenSettings:GetConsoleHistory()
			local historyline = history[self.history_idx]
			if historyline then
				self:ToggleRemoteExecute(historyline.remote or false) --can't pass nil, otherwise it will auto-toggle
			else
				self:ToggleRemoteExecute(InGamePlay())
			end
		end)

		self.console_edit.inst:ListenForEvent("onwordpredictionupdated", function()
			if self.console_history:IsVisible() then
				self.console_history:Hide()
				if not InGamePlay() then
					self:ToggleRemoteExecute(false)
				end
			end
		end)
	end

	local function onhistoryupdated(inst, index)
		if index == nil then
			return
		end
		self.history_idx = index

		local history = ConsoleScreenSettings:GetConsoleHistory()
		local historyline = history[self.history_idx]
		if historyline then
			self.console_edit:SetString(historyline.str or "")
			self:ToggleRemoteExecute(historyline.remote or false) --can't pass nil, otherwise it will auto-toggle
		else
			self.console_edit:SetString("")
			self:ToggleRemoteExecute(InGamePlay())
		end
	end

	self.console_edit.inst:ListenForEvent("onhistoryupdated", onhistoryupdated)
end

return ConsoleScreen
