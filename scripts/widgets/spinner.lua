require "fonts"
local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local ThreeSlice = require "widgets/threeslice"
local Text = require "widgets/text"
local Image = require "widgets/image"
--
-- You should override the On* functions to implement desired behaviour.
--
-- For example, OnChanged gets called by Changed, the base function. Both get passed the newly selected item.


local spinner_images = {
	arrow_normal = "spin_arrow.tex",
	arrow_over = "spin_arrow_over.tex",
	arrow_disabled = "spin_arrow_disabled.tex",
	arrow_down = "spin_arrow_down.tex",
	bg_middle = "spinner_short.tex",
	bg_middle_focus = "spinner_short_focus.tex",
	bg_middle_changing = "spinner_short_changing.tex",
	bg_end = "spinner_end.tex",
	bg_end_focus = "spinner_end_focus.tex",
	bg_end_changing = "spinner_end_changing.tex",
}

local spinner_lean_images = {
	arrow_left_normal = "arrow2_left.tex",
	arrow_left_over = "arrow2_left_over.tex",
	arrow_left_disabled = "arrow_left_disabled.tex",
	arrow_left_down = "arrow2_left_down.tex",
	arrow_right_normal = "arrow2_right.tex",
	arrow_right_over = "arrow2_right_over.tex",
	arrow_right_disabled = "arrow_right_disabled.tex",
	arrow_right_down = "arrow2_right_down.tex",
	bg_middle = "blank.tex",
	bg_middle_focus = "spinner_focus.tex",
	bg_middle_changing = "blank.tex",
	bg_end = "blank.tex",
	bg_end_focus = "blank.tex",
	bg_end_changing = "blank.tex",
	bg_modified = "option_highlight.tex",
}

local spinner_atlas = "images/ui.xml"
local spinfont = { font = BUTTONFONT, size = 30 }
local spinfontlean = { font = NEWFONT, size = 30 }
local default_width = 150
local default_height = 40

local Spinner = Class(Widget, function( self, options, width, height, textinfo, editable, atlas, textures, lean, textwidth, textheight)
    Widget._ctor(self, "SPINNER")


    self.width = width or default_width
    self.height = height or default_height

    self.lean = lean

	self.control_prev = CONTROL_PREVVALUE
	self.control_next = CONTROL_NEXTVALUE

    self.atlas = atlas or spinner_atlas
    if self.lean then
        self.textures = textures or spinner_lean_images
        self.textinfo = textinfo or spinfontlean
    else
        self.textures = textures or spinner_images
        self.textinfo = textinfo or spinfont
    end

    self.editable = editable or false
    self.options = options
    self.selectedIndex = 1
    self.textsize = {width = textwidth or self.width, height = textheight or self.height}

    self.arrow_scale = 1

    self.textcolour = { 1, 1, 1, 1 }

    if self.lean then
    	self.background = self:AddChild( Image(self.atlas, self.textures.bg_middle_focus) )
    	self.background:ScaleToSize(self.width, self.height)
    	self.background:SetTint(1,1,1,0)
    	self.leftimage = self:AddChild( ImageButton(self.atlas, self.textures.arrow_left_normal, self.textures.arrow_left_over, self.textures.arrow_left_disabled, self.textures.arrow_left_down, nil,{1,1}, {0,0}) )
    	self.rightimage = self:AddChild( ImageButton(self.atlas, self.textures.arrow_right_normal, self.textures.arrow_right_over, self.textures.arrow_right_disabled, self.textures.arrow_right_down, nil,{1,1}, {0,0}) )
    else
    	self.background = self:AddChild(ThreeSlice(self.atlas, self.textures.bg_end, self.textures.bg_middle))
    	self.background:Flow(self.width, self.height, true)
	    self.leftimage = self:AddChild( ImageButton(self.atlas, self.textures.arrow_normal, self.textures.arrow_over, self.textures.arrow_disabled, self.textures.arrow_down, nil,{1,1}, {0,0}) )
    	self.rightimage = self:AddChild( ImageButton(self.atlas, self.textures.arrow_normal, self.textures.arrow_over, self.textures.arrow_disabled, self.textures.arrow_down, nil,{1,1}, {0,0}) )
	end
    self.leftimage.silent = true
    self.rightimage.silent = true

    self.arrow_scale = 1 -- used in other methods to get the actual arrow size
    local arrow_width, arrow_height = self.leftimage:GetSize()
    self.arrow_scale = self.height / arrow_height
    self.leftimage:SetScale( self.arrow_scale, self.arrow_scale, 1 )
    self.rightimage:SetScale( self.arrow_scale, self.arrow_scale, 1 )

	self.fgimage = self:AddChild( Image() )

	if editable then
	    self.text = self:AddChild( TextEdit( self.textinfo.font, self.textinfo.size ) )
	else
	    self.text = self:AddChild( Text( self.textinfo.font, self.textinfo.size ) )
	end
	if self.lean then
		self.text:SetPosition(2,0)
	end

	if self.lean then
		self:SetTextColour(1,1,1,1)
	end

    self.text:Show()

	self.updating = false

	self:Layout()
	self:SetSelectedIndex(1)

	self.changing = false
	self.leftimage:SetOnClick(function() self:Prev(true) end)
	self.rightimage:SetOnClick(function() self:Next(true) end)
end)


function Spinner:DebugDraw_AddSection(dbui, panel)
    Spinner._base.DebugDraw_AddSection(self, dbui, panel)
    local DebugPickers = require("dbui_no_package/debug_pickers")

    dbui.Spacing()
    dbui.Text("Spinner")
    dbui.Indent() do
        dbui.Value("lean",       self.lean)

        local changed, w = dbui.DragFloat("width", self.width, 1,1,1000)
        if changed then
            self.width = w
            self:Layout()
        end
        -- Can't change height -- it's only used in ctor.
        dbui.Value("height",     self.height)

        local colour = DebugPickers.Colour(dbui, "textcolour", self.textcolour)
        if colour then
            self:SetTextColour(colour)
        end

        dbui.Text("atlas: "..    self.atlas)
        panel:AppendTable(dbui, self.textures, "textures")
    end
    dbui.Unindent()
end

-- Setup a "dirty" background for spinners that hold a state that can be
-- applied & reverted or represent a change from normal state.
-- Use SetHasModification to toggle the background.
function Spinner:EnablePendingModificationBackground()
    self.changed_image = self:AddChild(Image(self.atlas, self.textures.bg_modified, "blank.tex"))
    self.changed_image:SetPosition(1, 0)
    self.changed_image:ScaleToSize(self.width-45, self.height)
    self.changed_image:MoveToBack()
    self.changed_image:SetClickable(false)
    self.changed_image:SetTint(1,1,1,0.3)
    self.changed_image:Hide()
    self.SetHasModification = function(_, is_modified)
        if is_modified then
            self.changed_image:Show()
        else
            self.changed_image:Hide()
        end
    end
end

function Spinner:OnFocusMove(dir, down)
	if Spinner._base.OnFocusMove(self,dir,down) then return true end

	if self.changing and down then
		if dir == MOVE_LEFT then
			self:Prev()
			return true
		elseif dir == MOVE_RIGHT then
			self:Next()
			return true
		else
			self.changing = false
			self:UpdateBG()
		end
	end

end

function Spinner:OnGainFocus()
	Spinner._base.OnGainFocus(self)
	self:UpdateBG()
end

function Spinner:GetHelpText()
	local controller_id = TheInput:GetControllerID()

	local t = {}
	if self.leftimage.enabled then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, self.control_prev, false, false) .. " " .. STRINGS.UI.HELP.PREVVALUE)
	end

	if self.rightimage.enabled then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, self.control_next, false, false) .. " " .. STRINGS.UI.HELP.NEXTVALUE)
	end

	return table.concat(t, "  ")
end

-- This function allows display of hint text next to the arrow buttons
-- TODO: only tested with XBOX one controller. Test with other controller types to make sure there's room for the symbols.
function Spinner:AddControllerHints(control_prev, control_next, mute_negative_sound)
	self.control_prev = control_prev or self.control_prev
	self.control_next = control_next or self.control_next
	self.mute_negative_sound = mute_negative_sound

	local w = self.rightimage:GetSize() * self.arrow_scale

	self.left_hint = self:AddChild( Text( BODYTEXTFONT, 26 ) )
	self.left_hint:SetPosition( -self.width/2 + w/2 + 32, 0, 0 )

	self.right_hint = self:AddChild( Text( BODYTEXTFONT, 26 ) )
	self.right_hint:SetPosition( self.width/2 - w/2 - 27, 0, 0 )

	if TheInput:ControllerAttached() then
		self.right_hint:SetString(TheInput:GetLocalizedControl(TheInput:GetControllerID(), self.control_next))
		self.left_hint:SetString(TheInput:GetLocalizedControl(TheInput:GetControllerID(), self.control_prev))
	else
		self.left_hint:Hide()
		self.right_hint:Hide()
	end

	self.hints_enabled = true
end


function Spinner:OnLoseFocus()
	Spinner._base.OnLoseFocus(self)
	self.changing = false
	self:UpdateBG()
end

function Spinner:OnControl(control, down)
	if Spinner._base.OnControl(self, control, down) then return true end

	if down then
		if control == self.control_prev then
			self:Prev()
			return true
		elseif control == self.control_next then
			self:Next()
			return true
		end
	end

	--[[if not down and control == CONTROL_ACCEPT then
		if self.changing then
			self.changing = false
			self:UpdateBG()
		else
			self.changing = true
			self:UpdateBG()
			self.saved_idx = self:GetSelectedIndex()
		end
		return true
	end

	if not down and control == CONTROL_CANCEL then
		if self.changing then
			self.changing = false
			self:UpdateBG()
			if self.saved_idx then
				self:SetSelectedIndex(self.saved_idx)
				self.saved_idx = nil
			end
			return true
		end
	end--]]


end

function Spinner:UpdateBG()
	if self.changing then
		if self.lean then
			self.background:SetTint(1,1,1,1)
		else
			self.background:SetImages(self.atlas, self.textures.bg_end_changing, self.textures.bg_middle_changing)
		end
	elseif self.focus then
		if self.lean then
			self.background:SetTint(1,1,1,1)
		else
			self.background:SetImages(self.atlas, self.textures.bg_end_focus, self.textures.bg_middle_focus)
		end
	else
		if self.lean then
			self.background:SetTint(1,1,1,0)
		else
			self.background:SetImages(self.atlas, self.textures.bg_end, self.textures.bg_middle)
		end
	end
	if self.changing and self.changing_scale then
		if self.lean then
			self.background:ScaleToSize(unpack(self.changing_scale))
		else
			self.background:Flow(self.changing_scale[1], self.changing_scale[2], true)
		end
	elseif self.focus and self.focus_scale then
		if self.lean then
			self.background:ScaleToSize(unpack(self.focus_scale))
		else
			self.background:Flow(self.focus_scale[1], self.focus_scale[2], true)
		end
	elseif self.scale then
		if self.lean then
			self.background:ScaleToSize(unpack(self.scale))
		else
			self.background:Flow(self.scale[1], self.scale[2], true)
		end
	else
		if self.lean then
			self.background:ScaleToSize(self.width, self.height)
		else
			self.background:Flow(self.width, self.height, true)
		end
	end
end

function Spinner:SetTextColour(r,g,b,a)
    self.textcolour = type(r) == "number" and { r, g, b, a } or r
	self.text:SetColour(self.textcolour)
end

function Spinner:Enable()
	Spinner._base.Enable(self)
	self.text:SetColour( self.textcolour )
	self:UpdateState()
end

function Spinner:Disable()
	Spinner._base.Disable(self)
	-- self.text:SetColour(.7,.7,.7,1)
	self.text:SetColour(.5,.5,.5,1)
	self.leftimage:Disable()
	self.rightimage:Disable()

	if self.hints_enabled then
		self.left_hint:Hide()
		self.right_hint:Hide()
	end
end

function Spinner:SetFont(font)
	self.text:SetFont(font)
end

function Spinner:SetOnClick( fn )
    self.onclick = fn
end

function Spinner:SetTextSize(sz)
	self.text:SetSize(sz)
end

function Spinner:GetWidth()
	return self.width
end

function Spinner:Layout()
	local w = self.rightimage:GetSize() * self.arrow_scale
	self.rightimage:SetPosition( self.width/2 - w/2, 0, 0 )
	self.leftimage:SetPosition( -self.width/2 + w/2, 0, 0 )
end

function Spinner:SetTextHAlign( align )
    self.text:SetHAlign( align )
end

function Spinner:SetTextVAlign( align )
    self.text:SetVAlign( align )
end

function Spinner:Next(noclicksound)
	local oldSelection = self.selectedIndex
	local newSelection = oldSelection
	if self.enabled then
		if self.enableWrap then
			newSelection = self.selectedIndex + 1
			if newSelection > self:MaxIndex() then
				newSelection = self:MinIndex()
			end
		else
			newSelection = math.min( newSelection + 1, self:MaxIndex() )
		end
	end
	if newSelection ~= oldSelection then
		if not noclicksound then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		end
		self:OnNext()
		self:SetSelectedIndex(newSelection)
		self:Changed(oldSelection)
	elseif not self.mute_negative_sound then
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_negative")
	end
end

function Spinner:Prev(noclicksound)
	local oldSelection = self.selectedIndex
	local newSelection = oldSelection
	if self.enabled then
		if self.enableWrap then
			newSelection = self.selectedIndex - 1
			if newSelection < self:MinIndex() then
				newSelection = self:MaxIndex()
			end
		else
			newSelection = math.max( self.selectedIndex - 1, self:MinIndex() )
		end
	end
	if newSelection ~= oldSelection then
		if not noclicksound then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		end
		self:OnPrev()
		self:SetSelectedIndex(newSelection)
		self:Changed(oldSelection)
	elseif not self.mute_negative_sound then
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_negative")
	end
end

function Spinner:GetSelected()
	return self.options[ self.selectedIndex ]
end

function Spinner:GetSelectedIndex()
	return self.selectedIndex
end

function Spinner:GetSelectedText()
	if self.options[self.selectedIndex] and self.options[self.selectedIndex].text then
		return self.options[ self.selectedIndex ].text, self.options[self.selectedIndex].colour
	else
		return ""
	end
end

function Spinner:GetSelectedImage()
	return self.options[ self.selectedIndex ].image
end

function Spinner:GetSelectedData()
	return self.options[ self.selectedIndex ].data
end

function Spinner:SetSelectedIndex( idx )
	self.updating = true
	self.selectedIndex = math.max(self:MinIndex(), math.min(self:MaxIndex(), idx))

	local selected_text, selected_colour = self:GetSelectedText()
	self:UpdateText( selected_text )
	if selected_colour then
		self:SetTextColour( unpack(selected_colour) )
	else
		self:SetTextColour( unpack(self.textcolour) )
	end

	if self.options[ self.selectedIndex ] ~= nil then
		local selected_image = self:GetSelectedImage()
		if selected_image ~= nil then
			self.fgimage:SetTexture( unpack(selected_image) )
		end
	end

	self:UpdateState()
	self.updating = false
end

function Spinner:SetSelected(data)
	for k,v in pairs(self.options) do
		if v.data == data then
			local oldSelection = self.selectedIndex
			self:SetSelectedIndex(k)
			if self.selectedIndex ~= oldSelection then
				self:Changed(oldSelection)
			end
			return
		end
	end
end

function Spinner:UpdateText( msg )
	local _msg = tostring(msg) --Bogus data in spinners was using numbers as strings. The previous function here, SetString handled that, but SetTruncatedString does not.

	local width = self.textsize.width - 50 --offset for space for the spinner buttons
	local chars = width / 4 --Note(Peter): 4 is roughly the right size of a miniumum character, no guarantees!

	if chars > 5 and width > 10 then --Note(Peter): Quick hack fix to address tiny spinners in mods.
		if self.auto_shrink_text then
			self.text:SetMultilineTruncatedString(_msg, 1, width, nil, nil, true)
		else
			self.text:SetTruncatedString(_msg, width, chars, true)
		end
	else
		self.text:SetString(_msg)
	end
end

function Spinner:GetText()
	return self.text:GetString()
end

function Spinner:OnNext()
end

function Spinner:OnPrev()
end

function Spinner:Changed(oldSelection)
	if not self.updating then
		self:OnChanged( self:GetSelectedData(), self.options[oldSelection] and self.options[oldSelection].data or nil)
		self:UpdateState()
	end
end

function Spinner:SetOnChangedFn(fn)
	self.onchangedfn = fn
end

function Spinner:OnChanged( selected, old )
	if self.onchangedfn then
		self.onchangedfn(selected, old)
	end
end

function Spinner:MinIndex()
	return 1
end

function Spinner:MaxIndex()
	return #self.options
end

function Spinner:SetWrapEnabled(enable)
	self.enableWrap = enable
	self:UpdateState()
end

function Spinner:RefreshControllers(controller_mode)
	if controller_mode and self.hints_enabled then
		self.left_hint:SetString(TheInput:GetLocalizedControl(TheInput:GetControllerID(), self.control_prev))
		self.right_hint:SetString(TheInput:GetLocalizedControl(TheInput:GetControllerID(), self.control_next))
		self:UpdateState()
	else
		self.left_hint:Hide()
		self.right_hint:Hide()
	end
end

function Spinner:UpdateState()
	if self.enabled then
		self.leftimage:Enable()
		self.rightimage:Enable()

		if self.hints_enabled then
			if TheInput:ControllerAttached() then
				self.left_hint:Show()
				self.right_hint:Show()
			else
				self.left_hint:Hide()
				self.right_hint:Hide()
			end
		end

		if not self.enableWrap then
			if self.selectedIndex == self:MinIndex() then
				self.leftimage:Disable()
				if self.hints_enabled then
					self.left_hint:Hide()
				end
			end
			if self.selectedIndex == self:MaxIndex() then
				self.rightimage:Disable()
				if self.hints_enabled then
					self.right_hint:Hide()
				end
			end
		end
	else
		self.leftimage:Disable()
		self.rightimage:Disable()

		if self.hints_enabled then
			self.left_hint:Hide()
			self.right_hint:Hide()
		end
	end
end


function Spinner:SetOptions( options )
	self.options = options
	if self.selectedIndex > #self.options then
		self:SetSelectedIndex( #self.options )
	else
		-- update fgimage
		self:SetSelectedIndex(self.selectedIndex)
	end
	self:UpdateState()
end

return Spinner
