
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local Button = require "widgets/button"
local Image = require "widgets/image"

local WordPredictor = require "util/wordpredictor"

local DEBUG_SHOW_MAX_WITH = false

local FONT_SIZE = 22
local PADDING = 10

local WordPredictionWidget = Class(Widget, function(self, text_edit, max_width)
    Widget._ctor(self, "WordPredictionWidget")
    
    self.word_predictor = WordPredictor()
	self.text_edit = text_edit
	
	self.sizey = FONT_SIZE + 4
	self.max_width = max_width or 300

	local root = self:AddChild(Widget("wordpredictionwidget_root"))
	root:SetPosition(0, self.sizey*0.5)

    self.backing = root:AddChild(Image("images/ui.xml", "black.tex"))
    self.backing:SetTint(1,1,1,.8)
	self.backing:SetPosition(-5, 0)
    self.backing:SetHRegPoint(ANCHOR_LEFT)

	self.prediction_root = root:AddChild(Widget("prediction_root"))

	self.starting_offset = 0

	local dismiss_btn = root:AddChild(ImageButton("images/global_redux.xml", "close.tex"))
	dismiss_btn:SetOnClick(function() self:Dismiss() end)
	dismiss_btn:SetNormalScale(.50)
	dismiss_btn:SetFocusScale(.50)
	dismiss_btn:SetImageNormalColour(UICOLOURS.GREY)
	dismiss_btn:SetImageFocusColour(UICOLOURS.WHITE)
	dismiss_btn:SetPosition(10, 0)
	dismiss_btn:SetHoverText(STRINGS.UI.WORDPREDICTIONWIDET.DISMISS, {size = 20})
	self.starting_offset = 20 + PADDING

	self:Hide()
end)

function WordPredictionWidget:OnRawKey(key, down)
	if key == KEY_BACKSPACE or key == KEY_DELETE then
		self.active_prediction_btn = nil
		self:RefreshPredictions()
		return false  -- do not consume the key press

	elseif self.word_predictor.prediction ~= nil then
		if key == KEY_TAB or key == KEY_ENTER then
			return true
		elseif key == KEY_LEFT then
			if down and self.active_prediction_btn > 1 then
				self.prediction_btns[self.active_prediction_btn - 1]:Select()
			end
			return true
		elseif key == KEY_RIGHT then
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
			if not down then
				self.text_edit:ApplyWordPrediction(self.active_prediction_btn)
			end
			return true
		end
	end
		
	return false
end

function WordPredictionWidget:OnTextInput(text)
	if self.word_predictor.prediction ~= nil and text == "\t" then
		self.text_edit:ApplyWordPrediction(self.active_prediction_btn)
		return true -- consume the tab key
	end
	return false
end

function WordPredictionWidget:ResolvePrediction(prediction_index)
	return self.word_predictor:Apply(prediction_index)
end

function WordPredictionWidget:Dismiss()
	self.word_predictor.prediction = nil

	self.prediction_btns = {}
	self.active_prediction_btn = nil
	self.prediction_root:KillAllChildren()

	self:Hide()
	self:Disable()
end

function WordPredictionWidget:RefreshPredictions()
	local prev_active_prediction = self.active_prediction_btn ~= nil and self.prediction_btns[self.active_prediction_btn].name or nil

	self.word_predictor:RefreshPredictions(self.text_edit:GetString(), self.text_edit.inst.TextEditWidget:GetEditCursorPos())

	self.prediction_btns = {}
	self.active_prediction_btn = nil
	self.prediction_root:KillAllChildren()

	if self.word_predictor.prediction ~= nil then
		self:Show()
		self:Enable()

		local prediction = self.word_predictor.prediction
		local offset = self.starting_offset

		for i, v in ipairs(prediction.matches) do
			local str = self.word_predictor:GetDisplayInfo(i)
			
			local btn = self.prediction_root:AddChild(Button())
			btn:SetFont(CHATFONT)
			btn:SetDisabledFont(CHATFONT)
			btn:SetTextColour(UICOLOURS.GOLD_CLICKABLE)
			btn:SetTextSelectedColour(UICOLOURS.GOLD_FOCUS)
			btn:SetTextFocusColour(UICOLOURS.GOLD_FOCUS)
			btn:SetText(str)
			btn:SetTextSize(FONT_SIZE)
			btn.clickoffset = Vector3(0,0,0)

			btn.bg = btn:AddChild(Image("images/ui.xml", "blank.tex"))
			--btn.bg = btn:AddChild(Image("images/global.xml", "square.tex"))
			local w,h = btn.text:GetRegionSize()
			btn.bg:ScaleToSize(w, h)
			btn.bg:SetPosition(0,0)
			btn.bg:MoveToBack()

			btn:SetOnClick(function() self.text_edit:ApplyWordPrediction(i) end)
			btn:SetOnSelect(function() if self.active_prediction_btn ~= nil and self.active_prediction_btn ~= i then self.prediction_btns[self.active_prediction_btn]:Unselect() end self.active_prediction_btn = i end)
			btn.ongainfocus = function() btn:Select() end
			btn.AllowOnControlWhenSelected = true

			local sx, sy = btn.text:GetRegionSize()
			btn:SetPosition(sx * 0.5 + offset, 0)

			if offset + sx > self.max_width then
				if DEBUG_SHOW_MAX_WITH then
					offset = self.max_width
				end
				btn:Kill()
				break
			else
				offset = offset + sx + PADDING

				table.insert(self.prediction_btns, btn)
				if prev_active_prediction ~= nil and btn.name == prev_active_prediction then
					self.active_prediction_btn = i
				end
			end
		end
		
		self.backing:SetSize(offset, self.sizey + 4)
		self.prediction_btns[self.active_prediction_btn or 1]:Select()
	else
		self:Hide()
		self:Disable()
	end
end

return WordPredictionWidget
