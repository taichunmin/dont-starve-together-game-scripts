local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"

local DEBUG_MODE = BRANCH == "dev"

-------------------------------------------------------------------------------------------------------

-- A scrolling list of items.
--
-- We have a visible set of widgets and shift data between them to simulate
-- scrolling. SetItemsData and update_fn apply new data to widgets.
--
-- create_widgets_fn must create a set of widgets that can be updated by
-- update_fn. TrueScrollList will move `parent` for scrolling motion.
--
-- update_fn must apply the input data (an element of items from SetItemsData)
-- into the widget.
--
-- scissor_x/y/width/height are a bottom-left anchored box of the visible
-- region.
local TrueScrollList = Class(Widget, function(self, context, create_widgets_fn, update_fn, scissor_x, scissor_y, scissor_width, scissor_height, scrollbar_offset, scrollbar_height_offset, scroll_per_click)
    Widget._ctor(self, "TrueScrollList")

	assert(create_widgets_fn ~= nil and update_fn ~= nil, "TrueScrollList requires create widgets and update functions")

    -- Contextual data passed to input functions. Do not use this data inside
    -- TrueScrollList.
    self.context = context or {}

	self.scroll_per_click = scroll_per_click or 1

	self.control_up = CONTROL_SCROLLBACK
	self.control_down = CONTROL_SCROLLFWD
	self.control_scroll_repeat_time = nil -- disabled state

    -- Scroll-region-sized spanning image to ensure we don't lose focus
    -- due to gaps between widgets.
    self.bg = self:AddChild(Image("images/ui.xml", "blank.tex"))
    self.bg:ScaleToSize(scissor_width, scissor_height)

	self.scissored_root = self:AddChild(Widget("scissored_root"))
    self.scissored_root:SetScissor(scissor_x, scissor_y, scissor_width, scissor_height)
    if DEBUG_MODE then
        self.scissor_preview = {
            x = scissor_x,
            y = scissor_y,
            width = scissor_width,
            height = scissor_height,
        }
    end
	self.list_root = self.scissored_root:AddChild(Widget("list_root")) --this is the container that we'll be scrolling, and then it'll be scissored by the list itself.

    self.scissor_width = scissor_width
    self.scissor_height = scissor_height

    self.widgets_to_update, self.widgets_per_row, self.row_height, self.visible_rows, self.end_offset = create_widgets_fn( self.context, self.list_root, self )
	self.update_fn = update_fn

	self.items_per_view = #self.widgets_to_update

	for i = 1, #self.widgets_to_update do
		 self.widgets_to_update[i].IsFullyInView = function() return self:IsItemFullyVisible(i) end
	end

   	--self.repeat_time = (TheInput:ControllerAttached() and SCROLL_REPEAT_TIME) or MOUSE_SCROLL_REPEAT_TIME

    self.current_scroll_pos = 1
	self.target_scroll_pos = 1
	self.end_pos = 1
    -- The row of widgets, not the item row! (Never more than visible_rows.)
    self.focused_widget_row = 1

    self.focused_widget_index = 1
    self.displayed_start_index = 0

    -- Position scrollbar next to scissor region
	self.scrollbar_offset = {
        scissor_x + scissor_width + (scrollbar_offset or 0),
        scissor_y + scissor_height/2,
    }
	self.scrollbar_height = scissor_height + (scrollbar_height_offset or 0)
	self:BuildScrollBar()

    self.getnextitemindex = function(dir, focused_item_index)
        return (dir == MOVE_UP and focused_item_index - self.widgets_per_row) or
            (dir == MOVE_DOWN and focused_item_index + self.widgets_per_row) or nil
    end

    self.focus_forward = self.list_root

	self:SetItemsData(nil) --initialize with no data

    self:StartUpdating()
end)

function TrueScrollList:DebugDraw_AddSection(dbui, panel)
    TrueScrollList._base.DebugDraw_AddSection(self, dbui, panel)

    local force_reposition = false
    if self.scissor_preview.image == nil then
        self.scissor_preview.image = self.scissored_root:AddChild(Image("images/ui.xml", "white.tex"))
        self.scissor_preview.image:SetSize(self.scissor_preview.width, self.scissor_preview.height)
        self.scissor_preview.image:Hide()
        force_reposition = true
    end

    dbui.Spacing()
    dbui.Text("TrueScrollList")
    dbui.Indent() do
        local changed, show = dbui.Checkbox("white out scissor region", self.scissor_preview.image:IsVisible())
        if changed then
            if show then
                self.scissor_preview.image:Show()
            else
                self.scissor_preview.image:Hide()
            end
        end
        local changed_pos, x,y = dbui.DragFloat3("scissor pos", self.scissor_preview.x, self.scissor_preview.y, 0, 1, -900, 900)
        if changed_pos then
            self.scissor_preview.x, self.scissor_preview.y = x,y
        end
        local changed_size, w,h = dbui.DragFloat3("scissor size", self.scissor_preview.width, self.scissor_preview.height, 0, 1, 10, 900)
        if changed_size then
            self.scissor_preview.width, self.scissor_preview.height = w,h
            self.scissor_preview.image:SetSize(self.scissor_preview.width, self.scissor_preview.height)
            -- Changes in size affect anchor position.
            force_reposition = true
        end
        if force_reposition or changed_pos then
            -- Scissor region is anchored at bottom left instead of centre like widgets.
            self.scissor_preview.image:SetPosition(
                self.scissor_preview.x + self.scissor_preview.width/2,
                self.scissor_preview.y + self.scissor_preview.height/2)
        end

        -- Need to do some math to expose the input scrollbar_offset.
        local scissor_component = self.scissor_preview.x + self.scissor_preview.width
        x,y = unpack(self.scrollbar_offset)
        x = x - scissor_component
        changed, x = dbui.DragFloat("scrollbar_offset", x, 1, 10, 900)
        if changed then
            x = x + scissor_component
            self.scrollbar_offset = { x,y }
            self.scroll_bar_container:SetPosition(unpack(self.scrollbar_offset))
        end
    end
    dbui.Unindent()
end

local button_repeat_time = .15
local scroll_per_page = 3
local bar_width_scale_factor = 1
local arrow_button_size = 30

function TrueScrollList:BuildScrollBar()
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

	self.up_button_controllerhint = self.scroll_bar_container:AddChild(Text(UIFONT, 20))
    self.up_button_controllerhint:SetPosition(0, self.scrollbar_height/2 + nudge_y/2)
	self.up_button_controllerhint:Hide()

	self.down_button_controllerhint = self.scroll_bar_container:AddChild(Text(UIFONT, 20))
    self.down_button_controllerhint:SetPosition(0, -self.scrollbar_height/2 - nudge_y/2)
	self.down_button_controllerhint:Hide()

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
				self:Scroll(-scroll_per_page)
			else
				self:Scroll(scroll_per_page)
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



function TrueScrollList:DoDragScroll()
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
        self.current_scroll_pos = Lerp( scroll_value, 1, self.end_pos )
        self.target_scroll_pos = self.current_scroll_pos

    else
		-- Far away from the scroll bar, revert to original pos
        self.current_scroll_pos = self.saved_scroll_pos
        self.target_scroll_pos = self.saved_scroll_pos
    end

    self:RefreshView()
end

function TrueScrollList:GetListWidgets()
	return self.widgets_to_update
end

function TrueScrollList:SetItemsData(items)
	self.items = items or {}
   	self.total_rows = math.max(1, math.ceil(#self.items/self.widgets_per_row))
	self.end_pos = self.total_rows - self.visible_rows + self.end_offset

	if self.end_pos < 1 then self.end_pos = 1 end --clamp a tiny item set to be at the start position

    local focused_item_index = self.focused_widget_index + self.displayed_start_index
    if self.focus and #self.items > 0 and not self.items[focused_item_index] then
        --print("We filtered out the selected icon, so we need to move the focus back to the start otherwise controller input will be stuck")
        self.widgets_to_update[1]:SetFocus()
    end

 	self:RefreshView()
end

local SCROLL_REPEAT_TIME = .05
local MOUSE_SCROLL_REPEAT_TIME = 0

function TrueScrollList:OnUpdate(dt)
	if self.control_scroll_repeat_time ~= nil then
        --Scroll repeat
        if not (TheInput:IsControlPressed(self.control_up) or
                TheInput:IsControlPressed(self.control_down)) then
            self.control_scroll_repeat_time = -1
        elseif self.control_scroll_repeat_time > dt then
            self.control_scroll_repeat_time = self.control_scroll_repeat_time - dt
        elseif TheInput:IsControlPressed(self.control_up) then
            local repeat_time =
                TheInput:GetControlIsMouseWheel(self.control_up) and
                MOUSE_SCROLL_REPEAT_TIME or
                SCROLL_REPEAT_TIME
            if self.control_scroll_repeat_time < 0 then
                self.control_scroll_repeat_time = repeat_time > dt and repeat_time - dt or 0
            else
                self.control_scroll_repeat_time = repeat_time
                self:OnControl(self.control_up, true)
            end
        else--if TheInput:IsControlPressed(self.control_down) then
            local repeat_time =
                TheInput:GetControlIsMouseWheel(self.control_down) and
                MOUSE_SCROLL_REPEAT_TIME or
                SCROLL_REPEAT_TIME
            if self.control_scroll_repeat_time < 0 then
                self.control_scroll_repeat_time = repeat_time > dt and repeat_time - dt or 0
            else
                self.control_scroll_repeat_time = repeat_time
                self:OnControl(self.control_down, true)
            end
        end
	end
	
    local last_scroll_pos = self.current_scroll_pos
	self.current_scroll_pos = math.abs(self.current_scroll_pos - self.target_scroll_pos) > 0.01 and Lerp(self.current_scroll_pos, self.target_scroll_pos, 0.25) or self.target_scroll_pos

	if self.current_scroll_pos < 1 then
		--print("hit the start")
		self.current_scroll_pos = 1
		self.target_scroll_pos = 1
	end
	if self.current_scroll_pos > self.end_pos then
		--print("hit the end" )
		self.current_scroll_pos = self.end_pos
		self.target_scroll_pos = self.end_pos
	end

	--only bother refreshing if we've actually moved a bit
	if self.current_scroll_pos ~= last_scroll_pos then
        self:RefreshView()
    else
        self.itemfocus = nil
	end
end

function TrueScrollList:ResetScroll()
	self.current_scroll_pos = 1
	self.target_scroll_pos = 1
    self:RefreshView()
end

function TrueScrollList:Scroll(scroll_step)
	self.target_scroll_pos = self.target_scroll_pos + scroll_step
end

-- Snaps scroll to put the item with input index at the top of the view (if possible).
function TrueScrollList:ScrollToDataIndex(index)
   	local target_row = Clamp(math.ceil(index/self.widgets_per_row) - self.visible_rows + 1, 1, self.end_pos)

    self.current_scroll_pos = target_row
    self.target_scroll_pos = target_row
    self:RefreshView()
end

function TrueScrollList:ScrollToScrollPos(target_row)
    self.current_scroll_pos = target_row
    self.target_scroll_pos = target_row
    self:RefreshView()
end


-- Scrolls so the input widget is at the top of the list (if possible).
-- Maintains the current amount of offset (so if the top widget is half
-- visible, it will remain half visible).
function TrueScrollList:ScrollToWidgetIndex(index)
    local row_num = math.floor(self.current_scroll_pos)
    local row_offset = self.current_scroll_pos - row_num
    local target = index + row_offset
    self.current_scroll_pos = target
	self.target_scroll_pos = target
    self:RefreshView()
end

function TrueScrollList:FindDataIndex(target_data)
	if target_data ~= nil then
		for i = 1, #self.items do
			if self.items[i] == target_data then
				return i
			end
		end
	end
	return nil
end

function TrueScrollList:OnWidgetFocus(focused_widget)
    -- OnWidgetFocus is not called when scrolling with CONTROL_SCROLLFWD/BACK,
    -- so you can't capture item indexes here! (see displayed_start_index instead)
    for i = 1,self.items_per_view do
        if self.widgets_to_update[i] == focused_widget then
            self.focused_widget_index = i
            self.focused_widget_row = math.ceil(i / self.widgets_per_row)
            return
        end
    end
    assert(false, "Some unrelated widget is calling OnWidgetFocus")
end

function TrueScrollList:CanScroll()
	return self.end_pos > 1
end

function TrueScrollList:GetPositionScale()
	return (self.current_scroll_pos - 1) / (self.end_pos - 1)
end

function TrueScrollList:GetSlideStart()
	return self.scrollbar_height/2 - arrow_button_size
end

function TrueScrollList:GetSlideRange()
	return self.scrollbar_height - 2*arrow_button_size
end

function TrueScrollList:_GetScrollAmountPerRow()
    local scroll_amount = self.end_pos / self.total_rows * 2

	-- cap the scroll amount at 1 otherwise focus is going to be skipping rows
	return (scroll_amount < 1) and scroll_amount or 1
end

-- Get the index in GetListWidgets for the first visible widget.
-- Also returns an offset for how much of the widget is displayed (no promises).
function TrueScrollList:GetIndexOfFirstVisibleWidget(current_scroll_pos)
    current_scroll_pos = current_scroll_pos or self.current_scroll_pos
    local row_num = math.floor(current_scroll_pos)
    local row_offset = current_scroll_pos - row_num
	return ((row_num - 1) * self.widgets_per_row), row_offset
end

function TrueScrollList:RefreshView()
	-- figure out which set of data we're using
	local start_index, row_offset = self:GetIndexOfFirstVisibleWidget()
    -- Track the start of data so we can determine widget:item map elsewhere.
    self.displayed_start_index = start_index

	-- call update_fn for each
	for i = 1,self.items_per_view do
        self.update_fn(self.context, self.widgets_to_update[i], self.items[start_index + i], start_index + i)
        if self.itemfocus and self.itemfocus == start_index + i then
            --Check if we're on an active screen. Something could be on the stack in front of us and we don't want to steal focus back
            if self:GetParentScreen() == TheFrontEnd:GetActiveScreen() then
                self.widgets_to_update[i]:SetFocus()
            end
        end
        --self.widgets_to_update[i]:Show()
	end

	--position the scroll bar marker
	if self:CanScroll() then
		self.scroll_bar_container:Show()
		self.position_marker:SetPosition(0, self:GetSlideStart() - self:GetPositionScale() * self:GetSlideRange())
	else
		self.scroll_bar_container:Hide()
	end

	--do root partial-offset
	self.list_root:SetPosition( 0, row_offset * self.row_height, 0 )

	--reset the focus states
	TheFrontEnd:DoHoverFocusUpdate(true)
end

function TrueScrollList:ForceItemFocus(itemindex)
    local currentindex = itemindex - self.displayed_start_index
    if self.widgets_to_update[currentindex] then
        self.widgets_to_update[currentindex]:SetFocus()
    else
        self:SetFocus()
    end
    self.itemfocus = itemindex
end

function TrueScrollList:IsItemFullyVisible(itemindex)
	local item_row = math.ceil(itemindex / self.widgets_per_row)
    local first_fully_visible_row = math.ceil(self.target_scroll_pos - math.floor(self.target_scroll_pos)) + 1

	return item_row >= first_fully_visible_row and item_row <= (first_fully_visible_row + self.visible_rows - 1)
end

function TrueScrollList:GetNextWidget(dir)
    local displayed_start_index, row_offset = self:GetIndexOfFirstVisibleWidget(self.target_scroll_pos)
    local used_row_height = row_offset > 0 and ((1 - row_offset) * self.row_height) or 0

    local first_fully_visible_index = (math.ceil(self.target_scroll_pos) - 1) * self.widgets_per_row
    local last_fully_visible_index = first_fully_visible_index + (math.floor((self.scissor_height - used_row_height) / self.row_height) * self.widgets_per_row)

    local focused_item_index = self.itemfocus or (self.focused_widget_index + displayed_start_index)
    local next_item_index, scroll_index = self.getnextitemindex(dir, focused_item_index)

    scroll_index = scroll_index or next_item_index

    if scroll_index and self.items[scroll_index] then
        local did_scroll = false
        --scroll if we are already not fully visible
        local current_row = math.ceil(focused_item_index / self.widgets_per_row)
        if focused_item_index <= first_fully_visible_index then
            self:Scroll((current_row - math.ceil(first_fully_visible_index / self.widgets_per_row)) - 1)
            did_scroll = true
        elseif focused_item_index > last_fully_visible_index then
            self:Scroll(current_row - math.ceil(last_fully_visible_index / self.widgets_per_row))
            did_scroll = true
        end
        --scroll if the target isn't fully visible
        if scroll_index <= first_fully_visible_index or scroll_index > last_fully_visible_index then
            self:Scroll(math.ceil(scroll_index / self.widgets_per_row) - current_row)
            did_scroll = true
        end

        --force focus onto the next widget (handled in RefreshView)
        if next_item_index and self.items[next_item_index] then
            self:ForceItemFocus(next_item_index)
            did_scroll = true --reusing variable, for return value --meh
        elseif did_scroll then
            self:ForceItemFocus(focused_item_index)
        end
        return did_scroll
    end
    return false
end

function TrueScrollList:OnFocusMove(dir, down)
    -- ignore down. it's always true?!

    -- Instead of changing focus to the next widget (calling base), we are
    -- scrolling the widgets to move the above/below item into the current widget!
    if dir == MOVE_UP or dir == MOVE_DOWN then
        if self:GetNextWidget(dir) then
            return true
        end
    end

    local prev_focus = self.widgets_to_update[self.focused_widget_index]
    local did_parent_move = TrueScrollList._base.OnFocusMove(self, dir, down)
    if prev_focus and did_parent_move then
        local focused_item_index = self.focused_widget_index + self.displayed_start_index
        if not self.items[focused_item_index] then
            -- New widget is empty, undo parent's move to focus valid widget.
            prev_focus:SetFocus()
            return false
        end
    end

    return did_parent_move
end

function TrueScrollList:OverrideControllerButtons(control_up, control_down, hints_enabled)
	self.control_up = control_up or self.control_up
	self.control_down = control_down or self.control_down
	self.control_scroll_repeat_time = -1

	if hints_enabled then
		self.up_button_controllerhint:SetString(TheInput:GetLocalizedControl(TheInput:GetControllerID(), self.control_up))
		self.down_button_controllerhint:SetString(TheInput:GetLocalizedControl(TheInput:GetControllerID(), self.control_down))

		self.up_button_controllerhint:Show()
		self.down_button_controllerhint:Show()

		self.up_button:Hide()
		self.down_button:Hide()
	end
end

function TrueScrollList:ClearOverrideControllerButtons()
	self.control_up = CONTROL_SCROLLBACK
	self.control_down = CONTROL_SCROLLFWD
	self.control_scroll_repeat_time = nil -- disabled state

	self.up_button:Show()
	self.down_button:Show()

	self.up_button_controllerhint:Hide()
	self.down_button_controllerhint:Hide()
end

function TrueScrollList:OnControl(control, down)
	if TrueScrollList._base.OnControl(self, control, down) then return true end

    if down and (self.focus or FunctionOrValue(self.custom_focus_check)) and self.scroll_bar:IsVisible() then
        if control == self.control_up then
            local scroll_amt = -self.scroll_per_click
            if TheInput:ControllerAttached() then
                scroll_amt = scroll_amt / 2
            end
            if self:Scroll(scroll_amt) then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
            end
            return true
        elseif control == self.control_down then
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

function TrueScrollList:GetHelpText()
	local controller_id = TheInput:GetControllerID()

	local t = {}
	if self:CanScroll() then
	    table.insert(t, TheInput:GetLocalizedControl(controller_id, self.control_up) .. "/" .. TheInput:GetLocalizedControl(controller_id, self.control_down) .. " " .. STRINGS.UI.HELP.SCROLL)
	end

	return table.concat(t, "  ")
end

return TrueScrollList

