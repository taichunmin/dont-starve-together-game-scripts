
if IsSteamDeck() then
	return require "widgets/textedit_steamdeck"
end

local Widget = require "widgets/widget"
local Text = require "widgets/text"
local WordPredictionWidget = require "widgets/wordpredictionwidget"

local TextEdit = Class(Text, function(self, font, size, text, colour)
    Text._ctor(self, font, size, text, colour)

    self.inst.entity:AddTextEditWidget()
    self:SetString(text)
    self.limit = nil
    self.regionlimit = false
    self.editing = false
    self.editing_enter_down = false --track enter key while editing: ignore enter key up if key down wasn't recorded while editing
    self.allow_newline = false
    self.enable_accept_control = true
    self:SetEditing(false)
    self.validrawkeys = {}
    self.force_edit = false
    self.pasting = false
    self.pass_controls_to_screen = {}
	self.ignore_controls = {}

    self.idle_text_color = {0,0,0,1}
    self.edit_text_color = {0,0,0,1}--{1,1,1,1}

    self.idle_tint = {1,1,1,1}
    self.hover_tint = {1,1,1,1}
    self.selected_tint = {1,1,1,1}

    self:SetColour(self.idle_text_color[1], self.idle_text_color[2], self.idle_text_color[3], self.idle_text_color[4])

    -- Controller help text strings. You can hide a x_helptext by setting it to and empty string.
    self.edit_helptext = STRINGS.UI.HELP.CHANGE_TEXT
    self.cancel_helptext = STRINGS.UI.HELP.BACK
    self.apply_helptext = STRINGS.UI.HELP.APPLY

    --Default cursor colour is WHITE { 1, 1, 1, 1 }
    self:SetEditCursorColour(0,0,0,1)

    self.conversions = {} --text character transformations, see OnTextInput
end)

function TextEdit:DebugDraw_AddSection(dbui, panel)
    TextEdit._base.DebugDraw_AddSection(self, dbui, panel)

    dbui.Spacing()
    dbui.Text("TextEdit")
    dbui.Indent() do
        dbui.Checkbox("regionlimit",           self.regionlimit)
        dbui.Checkbox("editing",               self.editing)
        dbui.Checkbox("editing_enter_down",    self.editing_enter_down)
        dbui.Checkbox("allow_newline",         self.allow_newline)
        dbui.Checkbox("enable_accept_control", self.enable_accept_control)
        dbui.Checkbox("force_edit",            self.force_edit)
        dbui.Checkbox("pasting",               self.pasting)

        dbui.ColorEdit4("idle_text_color", unpack(self.idle_text_color))
        dbui.ColorEdit4("edit_text_color", unpack(self.edit_text_color))
        dbui.ColorEdit4("idle_tint",       unpack(self.idle_tint))
        dbui.ColorEdit4("hover_tint",      unpack(self.hover_tint))
        dbui.ColorEdit4("selected_tint",   unpack(self.selected_tint))
    end
    dbui.Unindent()
end

function TextEdit:SetForceEdit(force)
    self.force_edit = force
end

function TextEdit:SetString(str)
    str = self:FormatString(str)
    if self.inst and self.inst.TextEditWidget then
        self.inst.TextEditWidget:SetString(str or "")
    end
    self:_TryUpdateTextPrompt()
end

function TextEdit:SetAllowNewline(allow_newline)
	self.allow_newline = allow_newline

	-- We have to enable the accept control when we're not editing, so that
	-- the user can click the control to start editing, but while edting, we
	-- don't want the enter key to stop editing.
    self.enable_accept_control = not (self.allow_newline and self.editing)
end

function TextEdit:SetEditing(editing)
    --print("TextEdit:SetEditing:", self.editing, "->", editing, self.name, self:GetString())

    if editing and not self.editing then
        self.editing = true
        self.editing_enter_down = false

        self:SetFocus()
        -- Guarantee that we're highlighted
        self:DoSelectedImage()
        TheInput:EnableDebugToggle(false)
        --#srosen this is where we should push whatever text input widget we have for controllers
        -- we probably don't want to set the focus and whatnot here if controller attached:
        -- it screws with textboxes that are child widgets in scroll lists (and on the lobby screen)
        -- instead, we should go into "edit mode" by pushing a modal screen, rather than giving this thing focus and gobbling input
        --if TheInput:ControllerAttached() then

        --end

        if self.edit_text_color ~= nil then
            self:SetColour(unpack(self.edit_text_color))
        end

        if self.force_edit then
            TheFrontEnd:SetForceProcessTextInput(true, self)
        end
    elseif not editing and self.editing then
        self.editing = false
        self.editing_enter_down = false

        if self.focus then
            self:DoHoverImage()
        else
            self:DoIdleImage()
        end

        if self.idle_text_color ~= nil then
            self:SetColour(unpack(self.idle_text_color))
        end

        if self.force_edit then
            TheFrontEnd:SetForceProcessTextInput(false, self)
        end

        if self.prediction_widget ~= nil then
			self.prediction_widget:Dismiss()
		end
        TheInput:EnableDebugToggle(true)
	end

	-- Update the enable_accept_control flag
	self:SetAllowNewline(self.allow_newline)

    self.inst.TextWidget:ShowEditCursor(self.editing)
    self:_TryUpdateTextPrompt()
end

function TextEdit:OnMouseButton(button, down, x, y)
-- disabling this because it is conflicing with OnControl()
--  self:SetEditing(true)
end

function TextEdit:ValidateChar(text)
    local invalidchars = string.char(8, 22, 27)
    if not self.allow_newline then
        invalidchars = invalidchars .. string.char(10, 13)
    end
    return (self.validchars == nil or string.find(self.validchars, text, 1, true))
        and (self.invalidchars == nil or not string.find(self.invalidchars, text, 1, true))
        and not string.find(invalidchars, text, 1, true)
        -- Note: even though text is in utf8, only testing the first bit is enough based on the current exclusion list
end

function TextEdit:ValidatedString(str)
    local res = ""
    for i=1,#str do
        local char = str:sub(i,i)
        if self:ValidateChar(char) then
            res = res .. char
        end
    end
    return res
end

-- * is a valid input char, any other char is formatting.
function TextEdit:SetFormat(format)
    self.format = format
    if format ~= nil then
        self:SetTextLengthLimit(#format)
    end
end

function TextEdit:FormatString(str)
    if self.format == nil then
        return str
    end

    local unformatted = self:ValidatedString(str)
    local res = ""
    for i=0,#unformatted do
        while #res < #self.format and self.format:sub(#res+1,#res+1) ~= "*" do
            res = res .. self.format:sub(#res+1,#res+1)
        end
        res = res .. unformatted:sub(i,i)
    end
    return res
end

function TextEdit:SetTextConversion(in_char, out_char)
    self.conversions[in_char] = out_char
end

--NOTE: text is expected to be one char
--pasting: was from a pasted string, not a keypress, so skip the tab next widget test
function TextEdit:OnTextInput(text)
	if not self.pasting and self.prediction_widget ~= nil and self.prediction_widget:OnTextInput(text) then
		return true
	end

    if not (self.shown and self.editing) or
        (self.limit ~= nil and self:GetString():utf8len() >= self.limit) or
        (not self.pasting and self.nextTextEditWidget ~= nil and text == "\t") then
        --fail if we've reached our limit already
        --fail if we pressed tab (checked b4 text conversion) and tab advances to next widget
        return false
    end

    --do text conversions
    text = self.conversions[text] or text

    if not self:ValidateChar(text) then
        return false
    end

    self.inst.TextEditWidget:OnTextInput(text)

	if self.editing and self.prediction_widget ~= nil then
		self.prediction_widget:RefreshPredictions(true)
	end

    local overflow = self.regionlimit and self.inst.TextWidget:HasOverflow()
    if overflow then
        self.inst.TextEditWidget:OnKeyDown(KEY_BACKSPACE)
    end
    if self.format ~= nil then
        self:SetString(self:FormatString(self:GetString()))
    end

    return true, overflow
end

function TextEdit:OnProcess()
    self:SetEditing(false)
    TheInputProxy:FlushInput()
    if self.OnTextEntered then
        self.OnTextEntered(self:GetString())
    end
end

function TextEdit:SetOnTabGoToTextEditWidget(texteditwidget)
    if texteditwidget and (type(texteditwidget) == "table" and texteditwidget.inst.TextEditWidget) or (type(texteditwidget) == "function") then
        self.nextTextEditWidget = texteditwidget
    end
end

function TextEdit:OnStopForceProcessTextInput()
    if self.editing then
        self:SetEditing(false)

        if self.OnStopForceEdit ~= nil then
			self.OnStopForceEdit(self)
        end
    end
end

function TextEdit:OnRawKey(key, down)
	if self.editing and self.prediction_widget ~= nil and self.prediction_widget:OnRawKey(key, down) then
		self.editing_enter_down = false
		return true
	end

    if TextEdit._base.OnRawKey(self, key, down) then
        self.editing_enter_down = false
        return true
    end

    if self.editing then
        if down then
            if TheInput:IsPasteKey(key) then
                self.pasting = true
                local clipboard = TheSim:GetClipboardData()
                for i = 1, #clipboard do
                    local success, overflow = self:OnTextInput(clipboard:sub(i, i))
                    if overflow then
                        break
                    end
                end
                self.pasting = false
            elseif self.allow_newline and key == KEY_ENTER and down then
                self:OnTextInput("\n")
            else
                self.inst.TextEditWidget:OnKeyDown(key)
            end
            self.editing_enter_down = key == KEY_ENTER
        elseif key == KEY_ENTER and not self.focus then
                -- this is a fail safe incase the mouse changes the focus widget while editing the text field. We could look into FrontEnd:LockFocus but some screens require focus to be soft (eg: lobbyscreen's chat)
                if self.editing_enter_down then
                    self.editing_enter_down = false
                    if not self.allow_newline then
                        self:OnProcess()
                    end
                end
                return true
        elseif key == KEY_TAB and self.nextTextEditWidget ~= nil then
            self.editing_enter_down = false
            local nextWidg = self.nextTextEditWidget
            if type(nextWidg) == "function" then
                nextWidg = nextWidg()
            end
            if nextWidg ~= nil and type(nextWidg) == "table" and nextWidg.inst.TextEditWidget ~= nil then
                self:SetEditing(false)
                nextWidg:SetEditing(true)
            end
            -- self.nextTextEditWidget:OnControl(CONTROL_ACCEPT, false)
        else
            self.editing_enter_down = false
            self.inst.TextEditWidget:OnKeyUp(key)
        end

        if self.OnTextInputted ~= nil then
            self.OnTextInputted(down)
        end
    end

    --gobble up unregistered valid raw keys, or we will engage debug keys!
    return not self.validrawkeys[key]
end

function TextEdit:SetPassControlToScreen(control, pass)
    self.pass_controls_to_screen[control] = pass or nil
end

function TextEdit:SetIgnoreControl(control, ignore)
    self.ignore_controls[control] = ignore or nil
end

function TextEdit:OnControl(control, down)
    if not self:IsEnabled() then return end
	if self.editing and self.prediction_widget ~= nil and self.prediction_widget:OnControl(control, down) then
		return true
	end

	if self.ignore_controls[control] then
		return false
	end

    if TextEdit._base.OnControl(self, control, down) then return true end

    --gobble up extra controls
    if self.editing and (control ~= CONTROL_CANCEL and control ~= CONTROL_OPEN_DEBUG_CONSOLE and control ~= CONTROL_ACCEPT) then
        return not self.pass_controls_to_screen[control]
    end

    if self.editing and not down and control == CONTROL_CANCEL then
        self:SetEditing(false)
        return not self.pass_controls_to_screen[control]
    end

    if self.enable_accept_control and not down and control == CONTROL_ACCEPT then
        if not self.editing then
            self:SetEditing(true)
            return not self.pass_controls_to_screen[control]
        else
            -- Previously this was being done only in the OnRawKey, but that doesnt handle controllers very well, this does.
            self:OnProcess()
            return not self.pass_controls_to_screen[control]
        end
    end

    return false
end

function TextEdit:OnFocusMove(dir, down)

    -- Note: It would be nice to call OnProcces() here, but this gets called when pressing WASD so it wont work.

    -- prevent the focus move while editing the text string
    if self.editing then return true end

    -- otherwise, allow focus to move as normal
    return TextEdit._base.OnFocusMove(self, dir, down)
end

function TextEdit:OnGainFocus()
    Widget.OnGainFocus(self)

    if not self.editing then
        self:DoHoverImage()
    end

end

function TextEdit:OnLoseFocus()
    Widget.OnLoseFocus(self)

    if not self.editing then
        self:DoIdleImage()
    end
end

function TextEdit:DoHoverImage()
    if not self:IsEnabled() then return end
    if self.focusedtex then
        self.focusimage:SetTexture(self.atlas, self.focusedtex)
        self.focusimage:SetTint(self.hover_tint[1],self.hover_tint[2],self.hover_tint[3],self.hover_tint[4])
    end
end

function TextEdit:DoSelectedImage()
    if self.activetex then
        self.focusimage:SetTexture(self.atlas, self.activetex)
        self.focusimage:SetTint(self.selected_tint[1],self.selected_tint[2],self.selected_tint[3],self.selected_tint[4])
    end
end

function TextEdit:DoIdleImage()
    if self.unfocusedtex then
        self.focusimage:SetTexture(self.atlas, self.unfocusedtex)
        self.focusimage:SetTint(self.idle_tint[1],self.idle_tint[2],self.idle_tint[3],self.idle_tint[4])
    end
end

function TextEdit:SetFocusedImage(widget, atlas, unfocused, hovered, active)
    self.focusimage = widget
    self.atlas = atlas
    self.focusedtex = hovered
    self.unfocusedtex = unfocused
    self.activetex = active

    if self.focusedtex and self.unfocusedtex and self.activetex then
        self.focusimage:SetTexture(self.atlas, self.focus and self.focusedtex or self.unfocusedtex)
        if self.editing then
            self:DoSelectedImage()
        elseif self.focus then
            self:DoHoverImage()
        else
            self:DoIdleImage()
        end
    end
end

function TextEdit:SetIdleTextColour(r,g,b,a)
    if type(r) == "number" then
        self.idle_text_color = {r, g, b, a}
    else
        self.idle_text_color = r
    end
    if not self.editing then
        self:SetColour(self.idle_text_color[1], self.idle_text_color[2], self.idle_text_color[3], self.idle_text_color[4])
    end
end

function TextEdit:SetEditTextColour(r,g,b,a)
    if type(r) == "number" then
        self.edit_text_color = {r, g, b, a}
    else
        self.edit_text_color = r
    end
    if self.editing then
        self:SetColour(self.edit_text_color[1], self.edit_text_color[2], self.edit_text_color[3], self.edit_text_color[4])
    end
end

function TextEdit:SetEditCursorColour(r,g,b,a)
    if type(r) == "number" then
        self.inst.TextWidget:SetEditCursorColour(r, g, b, a)
    else
        self.inst.TextWidget:SetEditCursorColour(unpack(r))
    end
end

-- function Text:SetFadeAlpha(a, doChildren)
--  if not self.can_fade_alpha then return end

--     self:SetColour(self.colour[1], self.colour[2], self.colour[3], self.colour[4] * a)
--     Widget.SetFadeAlpha( self, a, doChildren )
-- end

function TextEdit:SetTextLengthLimit(limit)
    self.limit = limit
end

function TextEdit:EnableRegionSizeLimit(enable)
    self.regionlimit = enable
end

function TextEdit:SetCharacterFilter(validchars)
    self.validchars = validchars
end

function TextEdit:SetInvalidCharacterFilter(invalidchars)
    self.invalidchars = invalidchars
end

-- Unlike GetString() which returns the string stored in the displayed text widget
-- GetLineEditString will return the 'intended' string, even if the display is nulled out (for passwords)
function TextEdit:GetLineEditString()
    return self.inst.TextEditWidget:GetString()
end

function TextEdit:SetPassword(to)
    self.inst.TextEditWidget:SetPassword(to)
end

function TextEdit:SetForceUpperCase(to)
    self.inst.TextEditWidget:SetForceUpperCase(to)
end

function TextEdit:EnableScrollEditWindow(enable)
    self.inst.TextEditWidget:EnableScrollEditWindow(enable)
end

function TextEdit:SetHelpTextEdit(str)
    if str then
        self.edit_helptext = str
    end
end

function TextEdit:SetHelpTextCancel(str)
    if str then
        self.cancel_helptext = str
    end
end

function TextEdit:SetHelpTextApply(str)
    if str then
        self.apply_helptext = str
    end
end

function TextEdit:HasExclusiveHelpText()
    -- When editing a TextEdit widget, hide the screen's help text
    return self.editing
end

function TextEdit:GetHelpText()
    local t = {}
    local controller_id = TheInput:GetControllerID()

    if self.editing then
        if self.cancel_helptext ~= "" then
            table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. self.cancel_helptext)
        end

        if self.apply_helptext ~= "" then
            table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT, false, false ) .. " " .. self.apply_helptext)
        end
    else
        if self.edit_helptext ~= "" then
            table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT, false, false ) .. " " .. self.edit_helptext)
        end
    end

    return table.concat(t, "  ")
end

function TextEdit:EnableWordPrediction(layout, dictionary)
	if layout.mode ~= "disabled" then
		if self.prediction_widget == nil then
			self.prediction_widget = self:AddChild(WordPredictionWidget(self, layout.width, layout.mode))
			local sx, sy = self:GetRegionSize()
			local pad_y = layout.pad_y or 5
			self.prediction_widget:SetPosition(-sx*0.5, sy*0.5 + pad_y)
		end
		if dictionary ~= nil then
			self:AddWordPredictionDictionary(dictionary)
		end
	end
end

function TextEdit:AddWordPredictionDictionary(dictionary)
	if self.prediction_widget ~= nil then
	    self.prediction_widget.word_predictor:AddDictionary(dictionary)
	end
end

function TextEdit:ApplyWordPrediction(prediction_index)
	if self.prediction_widget ~= nil then
		local new_str, cursor_pos = self.prediction_widget:ResolvePrediction(prediction_index)
		if new_str ~= nil then
			self:SetString(new_str)
			self.inst.TextEditWidget:SetEditCursorPos(cursor_pos)
			self.prediction_widget:Dismiss()
			return true
		end
	end

	return false
end

function TextEdit:Disable()
    TextEdit._base.Disable(self)
    self:SetEditing(false)
    self:DoIdleImage()
end

-- Ghostly text in the text field that indicates what content goes in the text
-- field. Something to prompt the user for what to write.
--
-- Set this after doing SetRegionSize!
function TextEdit:SetTextPrompt(prompt_text, colour)
    assert(prompt_text)
    self.prompt = self:AddChild(Text(self.font, self.size, prompt_text, colour or self.colour))
    self.prompt:SetRegionSize(self:GetRegionSize())
    self.prompt:SetHAlign(ANCHOR_LEFT)
end

function TextEdit:_TryUpdateTextPrompt()
    if self.prompt then
        if self:GetString():len() > 0 or self.editing then
            self.prompt:Hide()
        else
            self.prompt:Show()
        end
    end
end

return TextEdit
