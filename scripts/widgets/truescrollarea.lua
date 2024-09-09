local Widget = require "widgets/widget"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"

-------------------------------------------------------------------------------------------------------

-- A scrolling area, the volume to scroll through must be calculated by the person making the content.
--
--
local TrueScrollArea = Class(Widget, function(self, context, scissor, scrollbar_v)
    Widget._ctor(self, "TrueScrollArea")

    -- Contextual data passed to input functions. Do not use this data inside
    -- TrueScrollArea.
    self.context = context

	self.scrollbar_v = scrollbar_v or {}

--    self.bg = self:AddChild(Image("images/ui.xml", "white.tex")) --"blank.tex"))
--	self.bg:SetTint(1,1,1,0.5)
    self.bg = self:AddChild(Image("images/ui.xml", "blank.tex"))
    self.bg:ScaleToSize(scissor.width, scissor.height)
	self.bg:SetPosition(scissor.width/2 - scissor.x, scissor.y + scissor.height/2)
	self.bg:SetTint(1,1,1,0.5)

	self.scissored_root = self:AddChild(Widget("scissored_root"))
    self.scissored_root:SetScissor(scissor.x, scissor.y, scissor.width, scissor.height)

	self.context_root = self.scissored_root:AddChild(context.widget) --this is the data that we'll be scrolling, and then it'll be the thing getting scissored.

   	--self.repeat_time = (TheInput:ControllerAttached() and SCROLL_REPEAT_TIME) or MOUSE_SCROLL_REPEAT_TIME

	self.current_scroll_pos = 0
	self.target_scroll_pos = 0
	self.scroll_pos_end = math.max(0, context.size.height - scissor.height)
	self.scroll_per_click = self.scrollbar_v.scroll_per_click or 20

    -- Position scrollbar next to scissor region
	self.scrollbar_offset = {
        scissor.x + scissor.width + 20 + (self.scrollbar_v.h_offset or 0),
        scissor.y + scissor.height/2,
    }
	self.scrollbar_height = scissor.height - 40 + (self.scrollbar_v.v_offset or 0)

	self:BuildScrollBar()

    self.focus_forward = self.context_root

	self:RefreshView()
    self:StartUpdating()
end)

local button_repeat_time = .15
local bar_width_scale_factor = 1
local arrow_button_size = 30

function TrueScrollArea:BuildScrollBar()
    local nudge_y = arrow_button_size/3
	self.scroll_bar_container = self:AddChild(Widget("scroll-bar-container"))
    self.scroll_bar_container:SetPosition(unpack(self.scrollbar_offset))

    self.up_button = self.scroll_bar_container:AddChild(ImageButton("images/global_redux.xml", "scrollbar_arrow_up.tex"))
    self.up_button:SetPosition(0, self.scrollbar_height/2 + nudge_y/2)
    self.up_button:SetScale(0.3)
    self.up_button:SetWhileDown( function()
        if not self.last_up_button_time or GetStaticTime() - self.last_up_button_time > button_repeat_time then
            self.last_up_button_time = GetStaticTime()
            self:Scroll(-self.scroll_per_click)
        end
    end)
    self.up_button:SetOnClick( function()
        self.last_up_button_time = nil
    end)

    self.down_button = self.scroll_bar_container:AddChild(ImageButton("images/global_redux.xml", "scrollbar_arrow_down.tex"))
    self.down_button:SetPosition(0, -self.scrollbar_height/2 - nudge_y/2)
    self.down_button:SetScale(0.3)
    self.down_button:SetWhileDown( function()
        if not self.last_down_button_time or GetStaticTime() - self.last_down_button_time > button_repeat_time then
            self.last_down_button_time = GetStaticTime()
            self:Scroll(self.scroll_per_click)
        end
    end)
    self.down_button:SetOnClick( function()
        self.last_down_button_time = nil
    end)

    local line_height = self.scrollbar_height - arrow_button_size/2
    self.scroll_bar_line = self.scroll_bar_container:AddChild(Image("images/global_redux.xml", "scrollbar_bar.tex"))
    self.scroll_bar_line:ScaleToSize(11*bar_width_scale_factor, line_height)
    self.scroll_bar_line:SetPosition(0, 0)

	--self.scroll_bar is used just for clicking on it
    self.scroll_bar = self.scroll_bar_container:AddChild(ImageButton("images/ui.xml", "1percent_clickbox.tex", "1percent_clickbox.tex", "1percent_clickbox.tex", nil, nil, {1,1}, {0,0}))
    self.scroll_bar.image:ScaleToSize(32, line_height)
    self.scroll_bar.image:SetTint(1,1,1,0)
    self.scroll_bar.scale_on_focus = false
    self.scroll_bar.move_on_click = false
    self.scroll_bar:SetPosition(0, 0)
	self.scroll_bar:SetOnClick( function()
		if self.position_marker then
			local marker = self.position_marker:GetWorldPosition()
			if TheFrontEnd.lasty >= marker.y then
				self:Scroll(-self.scroll_per_click)
			else
				self:Scroll(self.scroll_per_click)
			end
		end
	end )

    self.position_marker = self.scroll_bar_container:AddChild(ImageButton("images/global_redux.xml", "scrollbar_handle.tex"))
    self.position_marker.scale_on_focus = false
    self.position_marker.move_on_click = false
    self.position_marker.show_stuff = true
    self.position_marker:SetPosition(0, self.scrollbar_height/2 - arrow_button_size)
    self.position_marker:SetScale(bar_width_scale_factor*0.3, bar_width_scale_factor*0.3, 1)
    self.position_marker:SetOnDown( function()
        TheFrontEnd:LockFocus(true)
        self.dragging = true
        self.saved_scroll_pos = self.current_scroll_pos
    end)
    self.position_marker:SetWhileDown( function()
		self:DoDragScroll()
    end)
    self.position_marker.OnLoseFocus = function()
        --do nothing OnLoseFocus
    end
    self.position_marker:SetOnClick( function()
        self.dragging = nil
        TheFrontEnd:LockFocus(false)
        self:RefreshView() --refresh again after we've been moved back to the "up-click" position in Button:OnControl
    end)
end

function TrueScrollArea:DoDragScroll()
    --Check if we're near the scroll bar
    local marker = self.position_marker:GetWorldPosition()
	local DRAG_SCROLL_X_THRESHOLD = 150
    if math.abs(TheFrontEnd.lastx - marker.x) <= DRAG_SCROLL_X_THRESHOLD then
		--Note(Peter): Forgive me... I'm abusing the setting of local positions and getting of world positions to get the world(screen) space extents of the scroll bar so I can compare it to the mouse position
        self.position_marker:SetPosition(0, self:GetSlideStart())
        marker = self.position_marker:GetWorldPosition()
        local start_y = marker.y
        self.position_marker:SetPosition(0, self:GetSlideStart() - self:GetSlideRange())
        marker = self.position_marker:GetWorldPosition()
        local end_y = marker.y

        local scroll_value = math.clamp( (TheFrontEnd.lasty - end_y)/(start_y - end_y), 0, 1 )
        self.current_scroll_pos = Lerp( scroll_value, 1, self.scroll_pos_end )
        self.target_scroll_pos = self.current_scroll_pos

    else
		-- Far away from the scroll bar, revert to original pos
        self.current_scroll_pos = self.saved_scroll_pos
        self.target_scroll_pos = self.saved_scroll_pos
    end

    self:RefreshView()
end

function TrueScrollArea:GetListWidgets()
	return self.widgets_to_update
end

function TrueScrollArea:OnUpdate(dt)
	local blend_weight = 0.7
	local last_scroll_pos = self.current_scroll_pos
	self.current_scroll_pos = self.current_scroll_pos * blend_weight + self.target_scroll_pos * (1 - blend_weight)

	if self.current_scroll_pos < 0 then
		--print("hit the start")
		self.current_scroll_pos = 0
		self.target_scroll_pos = 0
	end
	if self.current_scroll_pos > self.scroll_pos_end then
		--print("hit the end" )
		self.current_scroll_pos = self.scroll_pos_end
		self.target_scroll_pos = self.scroll_pos_end
	end

	--only bother refreshing if we've actually moved a bit
	if math.abs(last_scroll_pos - self.current_scroll_pos) > 0.01 then
		self:RefreshView()
	end
end

function TrueScrollArea:ResetScroll()
	self.current_scroll_pos = 0
	self.target_scroll_pos = 0
    self:RefreshView()
end

function TrueScrollArea:Scroll(scroll_step)
	self.target_scroll_pos = self.target_scroll_pos + scroll_step
end

function TrueScrollArea:CanScroll()
	return self.scroll_pos_end > 0
end

function TrueScrollArea:GetPositionScale()
	return (self.current_scroll_pos) / (self.scroll_pos_end)
end

function TrueScrollArea:GetSlideStart()
	return self.scrollbar_height/2 - arrow_button_size
end

function TrueScrollArea:GetSlideRange()
	return self.scrollbar_height - 2*arrow_button_size
end

function TrueScrollArea:_GetScrollAmountPerRow()
	return self.scroll_per_click
end


function TrueScrollArea:RefreshView()
	local x = self.context.offset.x
    local y = self.context.offset.y + self.current_scroll_pos --math.floor(self:GetPositionScale())

	self.context_root:SetPosition(x, y)

    -- Track the start of data so we can determine widget:item map elsewhere.
    self.displayed_start_index = 0

	--position the scroll bar marker
	if self:CanScroll() then
		self.scroll_bar_container:Show()
		self.position_marker:SetPosition(0, self:GetSlideStart() - self:GetPositionScale() * self:GetSlideRange())
	else
		self.scroll_bar_container:Hide()
	end
end

function TrueScrollArea:OnControl(control, down)
	if TrueScrollArea._base.OnControl(self, control, down) then return true end

    if down and (self.focus and self.scroll_bar:IsVisible()) then
        if control == CONTROL_SCROLLBACK then
            local scroll_amt = -self.scroll_per_click
            if TheInput:ControllerAttached() then
                scroll_amt = scroll_amt / 2
            end
            if self:Scroll(scroll_amt) then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
            end
            return true
        elseif control == CONTROL_SCROLLFWD then
            local scroll_amt = self.scroll_per_click
            if TheInput:ControllerAttached() then
                scroll_amt = scroll_amt / 2
            end
            if self:Scroll(scroll_amt) then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
            end
            return true
        end
    end
end

function TrueScrollArea:GetHelpText()
	local controller_id = TheInput:GetControllerID()

	local t = {}
	if self:CanScroll() then
	    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_SCROLLBACK) .. "/" .. TheInput:GetLocalizedControl(controller_id, CONTROL_SCROLLFWD) .. " " .. STRINGS.UI.HELP.SCROLL)
	end

	return table.concat(t, "  ")
end

return TrueScrollArea

