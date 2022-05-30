require "util"
local Screen = require "widgets/screen"
local Image = require "widgets/image"
local TextEdit = require "widgets/textedit"
local Text = require "widgets/text"
local Widget = require "widgets/widget"

-- fix syntax highlighting due to above list: "'

-- To start your game with a prepopulated history, add to your customcommands.lua:
--      require "screens/consolescreen"
--      table.insert(GetConsoleHistory(), 'c_give("batbat")')

local DEBUG_MODE = BRANCH == "dev"
local CONSOLE_HISTORY = {}
local CONSOLE_LOCALREMOTE_HISTORY = {}

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

    self:ToggleRemoteExecute(true) -- if we are admin, start in remote mode
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
    elseif self.toggle_remote_execute then
        self.console_remote_execute:Hide()
        self.toggle_remote_execute = false
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
		local len = #CONSOLE_HISTORY
		if len > 0 then
			if self.history_idx ~= nil then
				self.history_idx = math.max( 1, self.history_idx - 1 )
			else
				self.history_idx = len
			end
			self.console_edit:SetString( CONSOLE_HISTORY[ self.history_idx ] )
			self:ToggleRemoteExecute( CONSOLE_LOCALREMOTE_HISTORY[self.history_idx] )
		end
	elseif key == KEY_DOWN then
		local len = #CONSOLE_HISTORY
		if len > 0 then
			if self.history_idx ~= nil then
				if self.history_idx == len then
					self.console_edit:SetString( "" )
					self:ToggleRemoteExecute( true )
				else
					self.history_idx = math.min( len, self.history_idx + 1 )
					self.console_edit:SetString( CONSOLE_HISTORY[ self.history_idx ] )
					self:ToggleRemoteExecute( CONSOLE_LOCALREMOTE_HISTORY[self.history_idx] )
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
		table.insert( CONSOLE_HISTORY, fnstr )
		table.insert( CONSOLE_LOCALREMOTE_HISTORY, self.toggle_remote_execute )
	end

	if self.toggle_remote_execute then
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
end

function ConsoleScreen:OnTextEntered()
    if self.runtask ~= nil then
        self.runtask:Cancel()
	end
    self.runtask = self.inst:DoTaskInTime(0, DoRun, self)
end

function GetConsoleHistory()
    return CONSOLE_HISTORY
end

function GetConsoleLocalRemoteHistory()
    return CONSOLE_LOCALREMOTE_HISTORY
end

function SetConsoleHistory(history)
    if type(history) == "table" and type(history[1]) == "string" then
        CONSOLE_HISTORY = history
    end
end

function SetConsoleLocalRemoteHistory(history)
    if type(history) == "table" and type(history[1]) == "boolean" then
        CONSOLE_LOCALREMOTE_HISTORY = history
    end
end

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
    local prefab_names = {}
	for name,_ in pairs(Prefabs) do
		table.insert(prefab_names, name)
	end

	self.console_edit:EnableWordPrediction({width = 1000, mode=Profile:GetConsoleAutocompleteMode()})
	self.console_edit:AddWordPredictionDictionary({words = prefab_names, delim = '"', postfix='"', skip_pre_delim_check=true})
	self.console_edit:AddWordPredictionDictionary({words = prefab_names, delim = "'", postfix="'", skip_pre_delim_check=true})
	local prediction_command = {"setmightiness", "spawn", "save", "gonext", "give", "mat", "list", "findnext", "countprefabs", "selectnear", "removeall", "shutdown", "regenerateworld", "reset", "despawn", "godmode", "supergodmode", "armor", "makeboat", "makeboatspiral", "autoteleportplayers", "gatherplayers", "dumpentities", "freecrafting", "selectnext", "sounddebug" }
	self.console_edit:AddWordPredictionDictionary({words = prediction_command, delim = "c_", num_chars = 0})

	self.console_edit:SetForceEdit(true)
    self.console_edit.OnStopForceEdit = function() self:Close() end
    self.console_edit.OnRawKey = function(s, key, down) if TextEdit.OnRawKey(self.console_edit, key, down) then return true end self:OnRawKeyHandler(key, down) end

	self.console_edit.validrawkeys[KEY_LCTRL] = true
	self.console_edit.validrawkeys[KEY_RCTRL] = true
	self.console_edit.validrawkeys[KEY_UP] = true
	self.console_edit.validrawkeys[KEY_DOWN] = true
	self.console_edit.validrawkeys[KEY_V] = true
	self.toggle_remote_execute = false

end

return ConsoleScreen
