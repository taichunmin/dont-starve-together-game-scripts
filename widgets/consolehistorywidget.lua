local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local Button = require "widgets/button"
local Image = require "widgets/image"

local FONT_SIZE = 22
local PADDING = 10

local MAX_LINES = 10

local ConsoleHistoryWidget = Class(Widget, function(self, text_edit, remote_execute, max_width, mode)
    Widget._ctor(self, "ConsoleHistoryWidget")

	self.text_edit = text_edit
	self.console_remote_execute = remote_execute

	self.enter_complete = string.match(mode, "enter", 1, true) ~= nil
	self.tab_complete = string.match(mode, "tab", 1, true) ~= nil

	self.sizey = FONT_SIZE + 4
	self.max_width = max_width or 300

	local root = self:AddChild(Widget("consolehistorywidget_root"))
	root:SetPosition(0, self.sizey * 0.5)

    self.backing = root:AddChild(Image("images/ui.xml", "black.tex"))
    self.backing:SetTint(1,1,1,.8)
	self.backing:SetPosition(-5, 0)
    self.backing:SetHRegPoint(ANCHOR_LEFT)

	self.history_root = root:AddChild(Widget("history_root"))

	self.starting_offset_x = 0

	local dismiss_btn = root:AddChild(ImageButton("images/global_redux.xml", "close.tex"))
	dismiss_btn:SetOnClick(function()
		self:Dismiss()
		TheFrontEnd:SetConsoleLogPosition(0, 0, 0)
	end)
	dismiss_btn:SetNormalScale(.50)
	dismiss_btn:SetFocusScale(.50)
	dismiss_btn:SetImageNormalColour(UICOLOURS.GREY)
	dismiss_btn:SetImageFocusColour(UICOLOURS.WHITE)
	dismiss_btn:SetPosition(10, 0)
	dismiss_btn:SetHoverText(STRINGS.UI.WORDPREDICTIONWIDGET.DISMISS)
	self.starting_offset_x = 20 + PADDING
end)

function ConsoleHistoryWidget:IsMouseOnly()
	return self.enter_complete == false and self.tab_complete == false
end

function ConsoleHistoryWidget:OnRawKey(key, down)
	if key == KEY_TAB then
		self:Hide()
		return self.tab_complete
	elseif key == KEY_ENTER then
		return self.enter_complete
	elseif key == KEY_UP and not self:IsMouseOnly() then
		if down then
			if self.active_selection_btn - self.start_offset < #self.selection_btns then
				self.selection_btns[self.active_selection_btn - self.start_offset + 1]:Select()
			else
				local history = ConsoleScreenSettings:GetConsoleHistory()
				if self.active_selection_btn < #history then
					local index = #history - self.active_selection_btn + 1
					self:RefreshHistory(history, index - 1)
					TheFrontEnd:StopTrackingMouse()
				end
			end
		end
		return true
	elseif key == KEY_DOWN and not self:IsMouseOnly() then
		if down then
			if self.active_selection_btn - self.start_offset > 1 then
				self.selection_btns[self.active_selection_btn - self.start_offset - 1]:Select()
			else
				local history = ConsoleScreenSettings:GetConsoleHistory()
				local index = #history - self.active_selection_btn + 1
				if index >= #history then
					self.text_edit:SetString("")
				else
					self:RefreshHistory(history, index + 1)
					TheFrontEnd:StopTrackingMouse()
				end
			end
		end
		return true
	elseif key == KEY_ESCAPE then
		return true
	end
	return false
end

function ConsoleHistoryWidget:OnControl(control, down)
    if ConsoleHistoryWidget._base.OnControl(self,control, down) then return true end

	if control == CONTROL_CANCEL then
		if not down then
			self:Dismiss()
		end
		return true
	end

	return false
end

function ConsoleHistoryWidget:Show(history, index)
	self._base.Show(self)
	TheFrontEnd:StopTrackingMouse()
	self:Enable()
	self:RefreshHistory(history, index)
end

function ConsoleHistoryWidget:Hide()
	self._base.Hide(self)
	self:Disable()
	TheFrontEnd:SetConsoleLogPosition(0, 0, 0)
end

function ConsoleHistoryWidget:Dismiss()
	self.selection_btns = {}
	self.active_selection_btn = nil
	self.history_root:KillAllChildren()

	self:Hide()
	self:Disable()
end

function ConsoleHistoryWidget:RefreshHistory(history, index)
	if not (history and #history > 0) then
		return
	end

	-- Index is reversed, so need to account for this
	self.active_selection_btn = index and (#history - index + 1) or 1
	self.start_offset = self.active_selection_btn > MAX_LINES and self.active_selection_btn - MAX_LINES or 0

	self.selection_btns = {}
	self.history_root:KillAllChildren()

	local offset_x = self.starting_offset_x
	local offset_y = 0
	local backing_width = 0
	local backing_height = self.sizey + 4

	local start = 1 + self.start_offset
	for i = start, #history do
		if i - self.start_offset > MAX_LINES then
			break
		end
		local btn = self.history_root:AddChild(Button())
		btn:SetFont(CHATFONT)
		btn:SetDisabledFont(CHATFONT)
		btn:SetTextColour(UICOLOURS.GOLD_CLICKABLE)
		btn:SetTextFocusColour(UICOLOURS.GOLD_CLICKABLE)
		btn:SetTextSelectedColour(UICOLOURS.GOLD_FOCUS)
		btn:SetText(history[#history - i + 1].str)
		btn:SetTextSize(FONT_SIZE)
		btn.clickoffset = Vector3(0,0,0)

		btn.bg = btn:AddChild(Image("images/ui.xml", "blank.tex"))
		local w,h = btn.text:GetRegionSize()
		btn.bg:ScaleToSize(w, h)
		btn.bg:SetPosition(0,0)
		btn.bg:MoveToBack()

		btn:SetOnClick(function()
			if self.active_selection_btn ~= nil then
				self.text_edit:SetString(self.selection_btns[self.active_selection_btn - self.start_offset].name)
				self.inst:PushEvent("onconsolehistoryitemclicked", i)
				self:Hide()
				self:Disable()
			end
		end)
		btn:SetOnSelect(function()
			if self.active_selection_btn ~= nil and self.active_selection_btn ~= i then
				local prev_btn = self.selection_btns[self.active_selection_btn - self.start_offset]
				prev_btn._unselecting = true
				prev_btn:Unselect()
				prev_btn._unselecting = nil
			end
			self.active_selection_btn = i
			self.text_edit.inst:PushEvent("onhistoryupdated", #history - i + 1)
		end)
		btn.ongainfocus = function()
			if not btn._unselecting then
				btn:Select()
			end
		end
		btn.AllowOnControlWhenSelected = true

		if self:IsMouseOnly() then
			btn.onlosefocus = function()
				if btn:IsSelected() then
					btn._unselecting = true
					btn:Unselect()
					btn._unselecting = nil
					self.active_selection_btn = nil
				end
			end
		end

		local sx, sy = btn.text:GetRegionSize()
		btn:SetPosition(sx * 0.5 + offset_x, offset_y)
		offset_y = offset_y + backing_height

		backing_width = offset_x > backing_width and offset_x or backing_width

		table.insert(self.selection_btns, btn)
	end

	if self:IsMouseOnly() then
		self.active_selection_btn = nil
	else
		self.selection_btns[self.active_selection_btn - self.start_offset]:Select()
	end

	local num_rows = math.min(#history, MAX_LINES)
	self.backing:SetSize(self.max_width, backing_height * num_rows)
	local pos = backing_height * (num_rows - 1)
	self.backing:SetPosition(-5, pos * 0.5)

	local scale = self.backing:GetScale()
	TheFrontEnd:SetConsoleLogPosition(0, pos * scale.y + PADDING, 0)
end

return ConsoleHistoryWidget
