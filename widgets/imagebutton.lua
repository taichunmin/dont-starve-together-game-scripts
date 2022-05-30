local Button = require "widgets/button"
local Image = require "widgets/image"

local ImageButton = Class(Button, function(self, atlas, normal, focus, disabled, down, selected, scale, offset)
    Button._ctor(self, "ImageButton")

    self.image = self:AddChild(Image())
    self.image:MoveToBack()

	self:SetTextures( atlas, normal, focus, disabled, down, selected, scale, offset )

    self.scale_on_focus = true
    self.move_on_click = true

    self.focus_scale = {1.2, 1.2, 1.2}
    self.normal_scale = {1, 1, 1}

    self.focus_sound = nil

    -- self.image:SetTexture(self.atlas, self.image_normal)
end)

function ImageButton:DebugDraw_AddSection(dbui, panel)
    ImageButton._base.DebugDraw_AddSection(self, dbui, panel)

    dbui.Spacing()
    dbui.Text("ImageButton")
    dbui.Indent() do
        dbui.ColorEdit4("imagenormalcolour  ", unpack(self.imagenormalcolour   or {0,0,0,0}))
        dbui.ColorEdit4("imagefocuscolour   ", unpack(self.imagefocuscolour    or {0,0,0,0}))
        dbui.ColorEdit4("imagedisabledcolour", unpack(self.imagedisabledcolour or {0,0,0,0}))
        dbui.ColorEdit4("imageselectedcolour", unpack(self.imageselectedcolour or {0,0,0,0}))
    end
    dbui.Unindent()
end

function ImageButton:ForceImageSize(x, y)
	self.size_x = x
	self.size_y = y
    self.image:ScaleToSize(self.size_x, self.size_y)
end

function ImageButton:SetTextures(atlas, normal, focus, disabled, down, selected, image_scale, image_offset)
    local default_textures = false
    if not atlas then
        atlas = atlas or "images/frontend.xml"
        normal = normal or "button_long.tex"
        focus = focus or "button_long_halfshadow.tex"
        disabled = disabled or "button_long_disabled.tex"
        down = down or "button_long_halfshadow.tex"
        selected = selected or "button_long_disabled.tex"
        default_textures = true
    end

    self.atlas = atlas
	self.image_normal = normal
    self.image_focus = focus or normal
    self.image_disabled = disabled or normal
    self.image_down = down or self.image_focus
    self.image_selected = selected or disabled
    self.has_image_down = down ~= nil

    local scale = {.7, .7}
    local offset = {3,-7}
    if not default_textures then
        scale = {1, 1}
        offset = {0, 0}
    end
    scale = image_scale or self.normal_scale or scale
    offset = image_offset or offset
    self.image_scale = scale
    self.image_offset = offset
    self.image:SetPosition(self.image_offset[1], self.image_offset[2])
    self.image:SetScale(self.image_scale[1], self.image_scale[2] or self.image_scale[1])

    self:_RefreshImageState()
end

function ImageButton:_RefreshImageState()
    if self:IsSelected() then
        self:OnSelect()
    elseif self:IsEnabled() then
        if self.focus then
            self:OnGainFocus()
        else
            self:OnLoseFocus()
        end
    else
        self:OnDisable()
    end
end

-- Apply a focus overlay to all image states.
--
-- Instead (or in addition to) having a focus image state, add a focus overlay
-- that's drawn on top of our image state when focus. This overlay is drawn
-- even when button is selected or disabled. Prevents focus from disappearing
-- when passing over selected items (essential on gamepad).
--
-- Common bug: you probably want scale_on_focus = false or customize scaling.
function ImageButton:UseFocusOverlay(focus_selected_texture)
    if not self.hover_overlay then
        self.hover_overlay = self.image:AddChild(Image())
    end
    self.hover_overlay:SetTexture(self.atlas, focus_selected_texture)
    self.hover_overlay:Hide()
    self:_RefreshImageState()
end

function ImageButton:OnGainFocus()
	ImageButton._base.OnGainFocus(self)

    if self.hover_overlay then
        self.hover_overlay:Show()
    end

    if self:IsSelected() then return end

    if self:IsEnabled() then
        self.image:SetTexture(self.atlas, self.image_focus)

        if self.size_x and self.size_y then
            self.image:ScaleToSize(self.size_x, self.size_y)
        end
    end

    if self.image_focus == self.image_normal and self.scale_on_focus and self.focus_scale then
        self.image:SetScale(self.focus_scale[1], self.focus_scale[2], self.focus_scale[3])
    end

    if self.imagefocuscolour then
        self.image:SetTint(unpack(self.imagefocuscolour))
    end

    if self.focus_sound then
        TheFrontEnd:GetSound():PlaySound(self.focus_sound)
    end
end

function ImageButton:OnLoseFocus()
	ImageButton._base.OnLoseFocus(self)

    if self.hover_overlay then
        self.hover_overlay:Hide()
    end

    if self:IsSelected() then return end

    if self:IsEnabled() then
        self.image:SetTexture(self.atlas, self.image_normal)

        if self.size_x and self.size_y then
            self.image:ScaleToSize(self.size_x, self.size_y)
        end
    end

    if self.image_focus == self.image_normal and self.scale_on_focus and self.normal_scale then
        self.image:SetScale(self.normal_scale[1], self.normal_scale[2], self.normal_scale[3])
    end

    if self.imagenormalcolour then
        self.image:SetTint(self.imagenormalcolour[1], self.imagenormalcolour[2], self.imagenormalcolour[3], self.imagenormalcolour[4])
    end
end

function ImageButton:OnControl(control, down)
    if not self:IsEnabled() or not self.focus then return end

	if self:IsSelected() and not self.AllowOnControlWhenSelected then return false end

	if control == self.control and (not self.mouseonly or TheFrontEnd.isprimary) then
        if down then
            if not self.down then
                if self.has_image_down then
                    self.image:SetTexture(self.atlas, self.image_down)

                    if self.size_x and self.size_y then
                        self.image:ScaleToSize(self.size_x, self.size_y)
                    end
                end
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
                self.o_pos = self:GetLocalPosition()
                if self.move_on_click then
                    self:SetPosition(self.o_pos + self.clickoffset)
                end
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
                if self.has_image_down then
                    self.image:SetTexture(self.atlas, self.image_focus)

                    if self.size_x and self.size_y then
                        self.image:ScaleToSize(self.size_x, self.size_y)
                    end
                end
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

function ImageButton:OnEnable()
	ImageButton._base.OnEnable(self)
    if self.focus then
        self:OnGainFocus()
    else
        self:OnLoseFocus()
    end
end

function ImageButton:OnDisable()
	ImageButton._base.OnDisable(self)
	self.image:SetTexture(self.atlas, self.image_disabled)

    if self.imagedisabledcolour then
        self.image:SetTint(unpack(self.imagedisabledcolour))
    end

	if self.size_x and self.size_y then
		self.image:ScaleToSize(self.size_x, self.size_y)
	end
end

-- This is roughly equivalent to OnDisable.
-- Calling "Select" on a button makes it behave as if it were disabled (i.e. won't respond to being clicked), but will still be able
-- to be focused by the mouse or controller. The original use case for this was the page navigation buttons: when you click a button
-- to navigate to a page, you select that page and, because you're already on that page, the button for that page becomes unable to
-- be clicked. But because fully disabling the button creates weirdness when navigating with a controller (disabled widgets can't be
-- focused), we have this new state, Selected.
-- NB: For image buttons, you need to set the image_selected variable. Best practice is for this to be the same texture as disabled.
function ImageButton:OnSelect()
    ImageButton._base.OnSelect(self)
	if self.image_selected then
	    self.image:SetTexture(self.atlas, self.image_selected)
	end
    if self.imageselectedcolour then
        self.image:SetTint(unpack(self.imageselectedcolour))
    end
end

-- This is roughly equivalent to OnEnable--it's what happens when canceling the Selected state. An unselected button will behave normally.
function ImageButton:OnUnselect()
    ImageButton._base.OnUnselect(self)
    if self:IsEnabled() then
        self:OnEnable()
    else
        self:OnDisable()
    end
end

function ImageButton:GetSize()
    return self.image:GetSize()
end

function ImageButton:SetFocusScale(scaleX, scaleY, scaleZ)
    if type(scaleX) == "number" then
        self.focus_scale = {scaleX, scaleY, scaleZ or 1}
    else
        self.focus_scale = scaleX
    end

    if self.focus and self.scale_on_focus and not self.selected then
        self.image:SetScale(self.focus_scale[1], self.focus_scale[2], self.focus_scale[3])
    end
end

function ImageButton:SetNormalScale(scaleX, scaleY, scaleZ)
    if type(scaleX) == "number" then
        self.normal_scale = {scaleX, scaleY, scaleZ or 1}
    else
        self.normal_scale = scaleX
    end

    if not self.scale_on_focus or not self.focus then
        self.image:SetScale(self.normal_scale[1], self.normal_scale[2], self.normal_scale[3])
    end
end

function ImageButton:SetImageNormalColour(r,g,b,a)
    if type(r) == "number" then
        self.imagenormalcolour = {r, g, b, a}
    else
        self.imagenormalcolour = r
    end

    if self:IsEnabled() and not self.focus and not self.selected then
        self.image:SetTint(self.imagenormalcolour[1], self.imagenormalcolour[2], self.imagenormalcolour[3], self.imagenormalcolour[4])
    end
end

function ImageButton:SetImageFocusColour(r,g,b,a)
    if type(r) == "number" then
        self.imagefocuscolour = {r,g,b,a}
    else
        self.imagefocuscolour = r
    end

    if self.focus and not self.selected then
        self.image:SetTint(unpack(self.imagefocuscolour))
    end
end

function ImageButton:SetImageDisabledColour(r,g,b,a)
    if type(r) == "number" then
        self.imagedisabledcolour = {r,g,b,a}
    else
        self.imagedisabledcolour = r
    end

    if not self:IsEnabled() then
        self.image:SetTint(unpack(self.imagedisabledcolour))
    end
end

function ImageButton:SetImageSelectedColour(r,g,b,a)
    if type(r) == "number" then
        self.imageselectedcolour = {r,g,b,a}
    else
        self.imageselectedcolour = r
    end

    if self.selected then
        self.image:SetTint(unpack(self.imageselectedcolour))
    end
end

function ImageButton:SetFocusSound(sound)
    self.focus_sound = sound
end

return ImageButton
