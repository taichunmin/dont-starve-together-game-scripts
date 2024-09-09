
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local Button = require "widgets/button"
local Image = require "widgets/image"

local WordPredictor = require "util/wordpredictor"

local DEBUG_SHOW_MAX_WITH = false

local FONT_SIZE = 22
local PADDING = 10

local MAX_ROWS = 5

-- Override functions for the scroll arrows; we want them to eat clicks to avoid closing the entire widget when reaching the beginning/end
local function EnableButton(inst)
	inst:SetImageNormalColour(UICOLOURS.GOLD)
	inst.button_enabled = true
end

local function DisableButton(inst)
	inst:SetImageNormalColour(UICOLOURS.GREY)
	inst.button_enabled = false
end

local WordPredictionWidget = Class(Widget, function(self, text_edit, max_width, mode)
    Widget._ctor(self, "WordPredictionWidget")

    self.word_predictor = WordPredictor()
	self.text_edit = text_edit

	local function onconsolehistoryupdated()
		if self:IsVisible() then
			self:Hide()
		end
	end
	self.text_edit.inst:ListenForEvent("onconsolehistoryupdated", onconsolehistoryupdated)

	self.enter_complete = string.match(mode, "enter", 1, true) ~= nil
	self.tab_complete = string.match(mode, "tab", 1, true) ~= nil

	self.sizey = FONT_SIZE + 4
	self.max_width = max_width or 300

	local root = self:AddChild(Widget("wordpredictionwidget_root"))
	root:SetPosition(0, self.sizey*0.5)

    self.backing = root:AddChild(Image("images/ui.xml", "black.tex"))
    self.backing:SetTint(1,1,1,.8)
	self.backing:SetPosition(-5, 0)
    self.backing:SetHRegPoint(ANCHOR_LEFT)

	self.prediction_root = root:AddChild(Widget("prediction_root"))

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

	self.start_index = 1

	self.scrollleft_btn = root:AddChild(ImageButton("images/ui.xml", "arrow2_left.tex"))
	self.scrollleft_btn:SetOnClick(function()
		if not self.scrollleft_btn.button_enabled then
			return
		end
		self.start_index = self.start_index - 1
		if self.start_index <= 1 then
			self.scrollleft_btn:DisableButton()
		end
		self:RefreshPredictions()
	end)
	self.scrollleft_btn:SetNormalScale(0.3)
	self.scrollleft_btn:SetFocusScale(0.4)
	self.scrollleft_btn:SetImageNormalColour(UICOLOURS.GOLD)
	self.scrollleft_btn:SetImageFocusColour(UICOLOURS.WHITE)
	self.scrollleft_btn:SetPosition(-60, 0)
	self.scrollleft_btn:SetHoverText(STRINGS.UI.WORDPREDICTIONWIDGET.PREV)
	self.scrollleft_btn.EnableButton = EnableButton
	self.scrollleft_btn.DisableButton = DisableButton
	self.scrollleft_btn:DisableButton()

	self.scrollright_btn = root:AddChild(ImageButton("images/ui.xml", "arrow2_right.tex"))
	self.scrollright_btn:SetOnClick(function()
		if not self.scrollright_btn.button_enabled then
			return
		end
		self.start_index = self.start_index + 1
		self.scrollleft_btn:EnableButton()
		self:RefreshPredictions()
	end)
	self.scrollright_btn:SetNormalScale(0.3)
	self.scrollright_btn:SetFocusScale(0.4)
	self.scrollright_btn:SetImageNormalColour(UICOLOURS.GOLD)
	self.scrollright_btn:SetImageFocusColour(UICOLOURS.WHITE)
	self.scrollright_btn:SetPosition(-30, 0)
	self.scrollright_btn:SetHoverText(STRINGS.UI.WORDPREDICTIONWIDGET.NEXT)
	self.scrollright_btn.EnableButton = EnableButton
	self.scrollright_btn.DisableButton = DisableButton
	self.scrollright_btn:DisableButton()

	local function Expand()
		self.expanded = not self.expanded

		if self.expanded then
			self.expand_btn:SetTextures("images/ui.xml", "arrow2_down.tex")
			self.expand_btn:SetHoverText(STRINGS.UI.WORDPREDICTIONWIDGET.MINIMIZE)
			self:RefreshPredictions()
		else
			self.expand_btn:SetTextures("images/ui.xml", "arrow2_up.tex")
			self.expand_btn:SetHoverText(STRINGS.UI.WORDPREDICTIONWIDGET.EXPAND)
			self:RefreshPredictions()
		end
	end

	self.expand_btn = root:AddChild(ImageButton("images/ui.xml", "arrow2_up.tex"))
	self.expand_btn:SetOnClick(Expand)
	self.expand_btn:SetNormalScale(0.3)
	self.expand_btn:SetFocusScale(0.4)
	self.expand_btn:SetImageNormalColour(UICOLOURS.GOLD)
	self.expand_btn:SetImageFocusColour(UICOLOURS.WHITE)
	self.expand_btn:SetPosition(self.max_width + PADDING, 0)
	self.expand_btn:SetHoverText(STRINGS.UI.WORDPREDICTIONWIDGET.EXPAND)

	self.expanded = not ConsoleScreenSettings:IsWordPredictionWidgetExpanded()
	Expand()

	self:Hide()
end)

function WordPredictionWidget:IsMouseOnly()
	return self.enter_complete == false and self.tab_complete == false
end

function WordPredictionWidget:OnRawKey(key, down)
	if key == KEY_BACKSPACE or key == KEY_DELETE then
		self.active_prediction_btn = nil
		self:RefreshPredictions(true)
		return false  -- do not consume the key press

	elseif self.word_predictor.prediction ~= nil then
		if key == KEY_TAB then
			return self.tab_complete
		elseif key == KEY_ENTER then
			return self.enter_complete
		elseif key == KEY_LEFT and not self:IsMouseOnly() then
			if down and self.active_prediction_btn > 1 then
				self.prediction_btns[self.active_prediction_btn - 1]:Select()
			end
			return true
		elseif key == KEY_RIGHT and not self:IsMouseOnly() then
			if down and self.active_prediction_btn < #self.prediction_btns then
				self.prediction_btns[self.active_prediction_btn + 1]:Select()
			end
			return true
		elseif key == KEY_ESCAPE then
			return true
		end
	end

	return false
end

function WordPredictionWidget:OnControl(control, down)
    if WordPredictionWidget._base.OnControl(self,control, down) then return true end

	if self.word_predictor.prediction ~= nil then
		if control == CONTROL_CANCEL then
			if not down then
				self:Dismiss()
			end
			return true
		elseif control == CONTROL_ACCEPT then
			if self.enter_complete then
				if not down then
					self.text_edit:ApplyWordPrediction(self.active_prediction_btn + self.start_index - 1)
				end
				return true
			end
		end
	end

	return false
end

function WordPredictionWidget:OnTextInput(text)
	if self.word_predictor.prediction ~= nil and text == "\t" and self.tab_complete then
		self.text_edit:ApplyWordPrediction(self.active_prediction_btn + self.start_index - 1)
		return true -- consume the tab key
	end
	return false
end

function WordPredictionWidget:ResolvePrediction(prediction_index)
	return self.word_predictor:Apply(prediction_index)
end

function WordPredictionWidget:Dismiss()
	self.word_predictor:Clear()

	self.prediction_btns = {}
	self.active_prediction_btn = nil
	self.prediction_root:KillAllChildren()

	ConsoleScreenSettings:SetWordPredictionWidgetExpanded(self.expanded)
	ConsoleScreenSettings:Save()

	self:Hide()
	self:Disable()
end

function WordPredictionWidget:RefreshPredictions(reset)
	local prev_active_prediction = self.active_prediction_btn ~= nil and self.prediction_btns[self.active_prediction_btn].name or nil

	self.word_predictor:RefreshPredictions(self.text_edit:GetString(), self.text_edit.inst.TextEditWidget:GetEditCursorPos())

	self.prediction_btns = {}
	self.active_prediction_btn = nil
	self.prediction_root:KillAllChildren()

	if reset then
		self.start_index = 1
		self.scrollleft_btn:DisableButton()
		self.scrollright_btn:DisableButton()
	end

	if self.word_predictor.prediction ~= nil then
		self:Show()
		self:Enable()

		local prediction = self.word_predictor.prediction
		local offset_x = self.starting_offset_x
		local offset_y = 0
		local backing_width = 0
		local backing_height = self.sizey + 4
		local num_rows = 1

		for i, v in ipairs(prediction.matches) do
			if i >= self.start_index then
				local str = self.word_predictor:GetDisplayInfo(i)

				local btn = self.prediction_root:AddChild(Button())
				btn:SetFont(CHATFONT)
				btn:SetDisabledFont(CHATFONT)
				btn:SetTextColour(UICOLOURS.GOLD_CLICKABLE)
				btn:SetTextFocusColour(UICOLOURS.GOLD_CLICKABLE)
				btn:SetTextSelectedColour(UICOLOURS.GOLD_FOCUS)
				btn:SetText(str)
				btn:SetTextSize(FONT_SIZE)
				btn.clickoffset = Vector3(0,0,0)

				btn.bg = btn:AddChild(Image("images/ui.xml", "blank.tex"))
				--btn.bg = btn:AddChild(Image("images/global.xml", "square.tex"))
				local w,h = btn.text:GetRegionSize()
				btn.bg:ScaleToSize(w, h)
				btn.bg:SetPosition(0,0)
				btn.bg:MoveToBack()

				btn:SetOnClick(function()
					if self.active_prediction_btn ~= nil then
						self.text_edit:ApplyWordPrediction(self.active_prediction_btn + self.start_index - 1)
					end
				end)
				btn:SetOnSelect(function()
					if self.active_prediction_btn ~= nil and self.active_prediction_btn + self.start_index - 1 ~= i then
						local prev_btn = self.prediction_btns[self.active_prediction_btn]
						prev_btn._unselecting = true
						prev_btn:Unselect()
						prev_btn._unselecting = nil
					end
					self.active_prediction_btn = i - self.start_index + 1
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
							self.active_prediction_btn = nil
						end
					end
				end

				local sx, sy = btn.text:GetRegionSize()
				btn:SetPosition(sx * 0.5 + offset_x, offset_y)

				if offset_x + sx > self.max_width then
					if DEBUG_SHOW_MAX_WITH then
						offset_x = self.max_width
					end

					if self.expanded and num_rows < MAX_ROWS then
						num_rows = num_rows + 1
						offset_x = self.starting_offset_x
						offset_y = offset_y + backing_height
						btn:SetPosition(sx * 0.5 + offset_x, offset_y)
					else
						self.scrollright_btn:EnableButton()
						--self.scrollright_btn:SetImageNormalColour(UICOLOURS.GOLD)
						btn:Kill()
						break
					end
				end

				offset_x = offset_x + sx + PADDING

				backing_width = offset_x > backing_width and offset_x or backing_width

				table.insert(self.prediction_btns, btn)
				if prev_active_prediction ~= nil and btn.name == prev_active_prediction then
					self.active_prediction_btn = i - self.start_index + 1
				end

				if i == #prediction.matches then
					self.scrollright_btn:DisableButton()
				end
			end
		end

		if self:IsMouseOnly() then
			self.active_prediction_btn = nil
		else
			self.prediction_btns[self.active_prediction_btn or 1]:Select()
		end

		self.backing:SetSize(backing_width, backing_height * num_rows)
		local pos = backing_height * (num_rows - 1)
		self.backing:SetPosition(-5, pos * 0.5)

		local scale = self.backing:GetScale()
		TheFrontEnd:SetConsoleLogPosition(0, pos * scale.y + PADDING, 0)
	else
		self:Hide()
		self:Disable()
		TheFrontEnd:SetConsoleLogPosition(0, 0, 0)
	end

	self.text_edit.inst:PushEvent("onwordpredictionupdated")
end

return WordPredictionWidget
