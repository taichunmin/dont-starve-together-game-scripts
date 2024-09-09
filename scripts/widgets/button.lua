local Widget = require "widgets/widget"
local Text = require "widgets/text"

--base class for imagebuttons and animbuttons.
local Button = Class(Widget, function(self)
    Widget._ctor(self, "BUTTON")

    self.font = NEWFONT
    self.fontdisabled = NEWFONT

	self.textcolour = {0,0,0,1}
	self.textfocuscolour = {0,0,0,1}
	self.textdisabledcolour = {0,0,0,1}
    self.textselectedcolour = {0,0,0,1}

    self.text = self:AddChild(Text(self.font, 40))
	self.text:SetVAlign(ANCHOR_MIDDLE)
    self.text:SetColour(self.textcolour)
    self.text:Hide()

	self.clickoffset = Vector3(0,-3,0)

	self.selected = false

	self.control = CONTROL_ACCEPT
	self.mouseonly = false
	self.help_message = STRINGS.UI.HELP.SELECT
end)

function Button:DebugDraw_AddSection(dbui, panel)
    Button._base.DebugDraw_AddSection(self, dbui, panel)

    dbui.Spacing()
    dbui.Text("Button")
    dbui.Indent() do
        dbui.Value("IsSelected", self:IsSelected())
        dbui.Value("IsEnabled", self:IsEnabled())

        dbui.ColorEdit4("textcolour        ", unpack(self.textcolour))
        dbui.ColorEdit4("textfocuscolour   ", unpack(self.textfocuscolour))
        dbui.ColorEdit4("textdisabledcolour", unpack(self.textdisabledcolour))
        dbui.ColorEdit4("textselectedcolour", unpack(self.textselectedcolour))
    end
    dbui.Unindent()
end

function Button:SetControl(ctrl)
	if ctrl == CONTROL_PRIMARY then
		self.control = CONTROL_ACCEPT
	elseif ctrl then
		self.control = ctrl
	end
	self.mouseonly = ctrl == CONTROL_PRIMARY
end

function Button:OnControl(control, down)
	if Button._base.OnControl(self, control, down) then return true end

	if not self:IsEnabled() or not self.focus then return false end

	if self:IsSelected() and not self.AllowOnControlWhenSelected then return false end

	if control == self.control and (not self.mouseonly or TheFrontEnd.isprimary) then

		if down then
			if not self.down then
                if not self.stopclicksound then
					TheFrontEnd:GetSound():PlaySound(self.overrideclicksound or "dontstarve/HUD/click_move")
                end
				self.o_pos = self:GetLocalPosition()
				self:SetPosition(self.o_pos + self.clickoffset)
				self.down = true
				if self.whiledown then
					self:StartUpdating()
				end
				if self.ondown then
					self.ondown()
				end
			end
		else
			if self.down then
				self.down = false
                self:ResetPreClickPosition()
				if self.onclick then
					self.onclick()
				end
				self:StopUpdating()
			end
		end

		return true
	end

end

-- Will only run if the button is manually told to start updating: we don't want a bunch of unnecessarily updating widgets
function Button:OnUpdate(dt)
	if self.down and self.whiledown then
		self.whiledown()
	end
end

function Button:OnGainFocus()
	Button._base.OnGainFocus(self)

	if self:IsEnabled() and not self:IsSelected() then
		self.text:SetColour(self.textfocuscolour)
		if TheFrontEnd:GetFadeLevel() <= 0 then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
		end
	end

    if self.ongainfocus then
        self.ongainfocus(self:IsEnabled())
    end
end

function Button:ResetPreClickPosition()
	if self.o_pos then
		self:SetPosition(self.o_pos)
        self.o_pos = nil
    end
end

function Button:OnLoseFocus()
	Button._base.OnLoseFocus(self)

	if self.down then
		self.down = false
		self:ResetPreClickPosition()
		self:StopUpdating()
	end

	if not (self:IsDisabledState() or self:IsSelected()) then
		self.text:SetColour(self.textcolour)
	end

    if self.onlosefocus then
        self.onlosefocus(self:IsEnabled())
    end
end

function Button:OnEnable()
	if not self:IsSelected() then
		self.text:SetFont(self.font)
		if self:IsFocusedState() then
			self:OnGainFocus()
		else
			self:OnLoseFocus()
		end
	end
end

function Button:OnDisable()
	if self.down then
		self.down = false
		self:ResetPreClickPosition()
		self:StopUpdating()
	end
	if not self:IsSelected() then
		self.text:SetColour(self.textdisabledcolour)
		self.text:SetFont(self.fontdisabled)
	end
end

-- Calling "Select" on a button makes it behave as if it were disabled (i.e. won't respond to being clicked), but will still be able
-- to be focused by the mouse or controller. The original use case for this was the page navigation buttons: when you click a button
-- to navigate to a page, you select that page and, because you're already on that page, the button for that page becomes unable to
-- be clicked. But because fully disabling the button creates weirdness when navigating with a controller (disabled widgets can't be
-- focused), we have this new state, Selected.
-- NB: For image buttons, you need to set the image_selected variable. Best practice is for this to be the same texture as disabled.
function Button:Select()
	self.selected = true
	self:OnSelect()
end

-- This is roughly equivalent to calling Enable after calling Disable--it cancels the Selected state. An unselected button will behave normally.
function Button:Unselect()
	self.selected = false
	self:OnUnselect()
end

-- This is roughly equivalent to OnDisable
function Button:OnSelect()
	if self.down and not self.AllowOnControlWhenSelected then
		self.down = false
		self:ResetPreClickPosition()
		self:StopUpdating()
	end
	self.text:SetColour(self.textselectedcolour)
	if not self.enabled then --in case we were disabled
		self.text:SetFont(self.font)
	end
    if self.onselect then
        self.onselect()
    end
end

-- This is roughly equivalent to OnEnable
function Button:OnUnselect()
	if self:IsDisabledState() then
		self:OnDisable()
	else
		self:OnEnable()
	end
    if self.onunselect then
        self.onunselect()
    end
end

--------------------------------------------------------------------------
--V2C: IsEnabled() checks hierarchy, but OnEnable()/OnDisable() don't notify children.
--     These helpers will give more consistent behaviour regarding the state of the button.
--NOTE: While the selected, enabled, focus flags aren't mutually exclusive, we can only
--      be in one of these states at a time visually, ordered by priority below.

function Button:IsSelected()
	return self.selected
end

function Button:IsDisabledState()
	return not (self.enabled or self:IsSelected())
end

function Button:IsFocusedState()
	return self.focus and self:IsEnabled() and not self:IsSelected()
end

function Button:IsNormalState()
	return self.enabled and not (self.focus and self:IsEnabled()) and not self:IsSelected()
end

--------------------------------------------------------------------------

function Button:SetOnClick( fn )
    self.onclick = fn
end

function Button:SetOnSelect( fn )
    self.onselect = fn
end

function Button:SetOnUnSelect( fn )
    self.onunselect = fn
end

function Button:SetOnUnselect( fn )
    self.onunselect = fn
end

function Button:SetOnDown( fn )
	self.ondown = fn
end

function Button:SetWhileDown( fn )
	self.whiledown = fn
end

function Button:SetFont(font)
	self.font = font
	if not self:IsDisabledState() then
		self.text:SetFont(font)
		if self.text_shadow then
			self.text_shadow:SetFont(font)
		end
	end
end

function Button:SetDisabledFont(font)
	self.fontdisabled = font
	if self:IsDisabledState() then
		self.text:SetFont(font)
		if self.text_shadow then
			self.text_shadow:SetFont(font)
		end
	end
end

function Button:SetTextColour(r,g,b,a)
	if type(r) == "number" then
		self.textcolour = {r,g,b,a}
	else
		self.textcolour = r
	end

	if self:IsNormalState() then
		self.text:SetColour(self.textcolour)
	end
end

function Button:SetTextFocusColour(r,g,b,a)
	if type(r) == "number" then
		self.textfocuscolour = {r,g,b,a}
	else
		self.textfocuscolour = r
	end

	if self:IsFocusedState() then
		self.text:SetColour(self.textfocuscolour)
	end
end

function Button:SetTextDisabledColour(r,g,b,a)
	if type(r) == "number" then
		self.textdisabledcolour = {r,g,b,a}
	else
		self.textdisabledcolour = r
	end

	if self:IsDisabledState() then
		self.text:SetColour(self.textdisabledcolour)
	end
end

function Button:SetTextSelectedColour(r,g,b,a)
	if type(r) == "number" then
		self.textselectedcolour = {r,g,b,a}
	else
		self.textselectedcolour = r
	end

	if self:IsSelected() then
		self.text:SetColour(self.textselectedcolour)
	end
end

function Button:SetTextSize(sz)
	self.size = sz
	self.text:SetSize(sz)
	if self.text_shadow then self.text_shadow:SetSize(sz) end
end

function Button:GetText()
    return self.text:GetString()
end

function Button:SetText(msg, dropShadow, dropShadowOffset)
    if msg then
    	self.name = msg or "button"
        self.text:SetString(msg)
        self.text:Show()
		if self:IsDisabledState() then
			self.text:SetColour(self.textdisabledcolour)
		else
			self.text:SetColour(
				(self:IsSelected() and self.textselectedcolour) or
				(self:IsFocusedState() and self.textfocuscolour) or
				self.textcolour
			)
		end

		if dropShadow then
			if self.text_shadow == nil then
				self.text_shadow = self:AddChild(Text(self.font, self.size or 40))
				self.text_shadow:SetVAlign(ANCHOR_MIDDLE)
				self.text_shadow:SetColour(.1,.1,.1,1)
				local offset = dropShadowOffset or {-2, -2}
				self.text_shadow:SetPosition(offset[1], offset[2])
			    self.text:MoveToFront()
			end
		    self.text_shadow:SetString(msg)
		end
    else
        self.text:Hide()
        if self.text_shadow then self.text_shadow:Hide() end
    end
end

function Button:SetHelpTextMessage(str)
	if str then
		self.help_message = str
	end
end

function Button:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	local t = {}
	if (not self:IsSelected() or self.AllowOnControlWhenSelected) and self.help_message ~= "" then
    	table.insert(t, TheInput:GetLocalizedControl(controller_id, self.control, false, false ) .. " " .. self.help_message)
    end
	return table.concat(t, "  ")
end

return Button
