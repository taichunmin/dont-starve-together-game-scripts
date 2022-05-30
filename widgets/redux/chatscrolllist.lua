local Widget = require "widgets/widget"
local Image = require "widgets/image"

local DEBUG_MODE = BRANCH == "dev"

-------------------------------------------------------------------------------------------------------

-- A scrolling list of items.
--
-- We have a visible set of widgets and shift data between them to simulate
-- scrolling. SetItemsData and update_fn apply new data to widgets.
--
-- create_widgets_fn must create a set of widgets that can be updated by
-- update_fn. ChatScrollList will move `parent` for scrolling motion.
--
-- update_fn must apply the input data (an element of items from SetItemsData)
-- into the widget.
--
-- scissor_x/y/width/height are a bottom-left anchored box of the visible
-- region.
local ChatScrollList = Class(Widget, function(self, create_widgets_fn, update_fn, can_scroll_fn, scissor_x, scissor_y, scissor_width, scissor_height)
    Widget._ctor(self, "ChatScrollList")

	assert(create_widgets_fn ~= nil and update_fn ~= nil and can_scroll_fn ~= nil, "ChatScrollList requires create widgets, update, and can scroll functions.")

	self.scroll_per_click = 1

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
	self.list_root = self.scissored_root:AddChild(Widget("list_root"))

    self.scissor_width = scissor_width
    self.scissor_height = scissor_height

    self.widgets_to_update, self.row_height = create_widgets_fn( self.list_root, self )
	self.update_fn = update_fn
    self.can_scroll_fn = can_scroll_fn

	self.items_per_view = #self.widgets_to_update

    self.current_scroll_pos = 0
	self.target_scroll_pos = 0

    self.focus_forward = self.list_root

    self:StartUpdating()
end)

function ChatScrollList:DebugDraw_AddSection(dbui, panel)
    ChatScrollList._base.DebugDraw_AddSection(self, dbui, panel)

    local force_reposition = false
    if self.scissor_preview.image == nil then
        self.scissor_preview.image = self.scissored_root:AddChild(Image("images/ui.xml", "white.tex"))
        self.scissor_preview.image:SetSize(self.scissor_preview.width, self.scissor_preview.height)
        self.scissor_preview.image:Hide()
        force_reposition = true
    end

    dbui.Spacing()
    dbui.Text("ChatScrollList")
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
            --Changes in size affect anchor position.
            force_reposition = true
        end
        if force_reposition or changed_pos then
            --Scissor region is anchored at bottom left instead of centre like widgets.
            self.scissor_preview.image:SetPosition(
                self.scissor_preview.x + self.scissor_preview.width/2,
                self.scissor_preview.y + self.scissor_preview.height/2)
        end
    end
    dbui.Unindent()
end

function ChatScrollList:GetListWidgets()
	return self.widgets_to_update
end

function ChatScrollList:OnUpdate(dt)
    if self.current_scroll_pos == self.target_scroll_pos then
        return
    end

	self.current_scroll_pos = math.diff(self.current_scroll_pos, self.target_scroll_pos) > 0.01 and Lerp(self.current_scroll_pos, self.target_scroll_pos, 0.25) or self.target_scroll_pos

    self:RefreshView()
end

function ChatScrollList:ResetScroll()
	self.current_scroll_pos = 0
	self.target_scroll_pos = 0
    self:RefreshView()
end

function ChatScrollList:Scroll(scroll_step, instant)
    local scroll_dir = scroll_step < 0 and -1 or 1
    scroll_step = math.abs(scroll_step)

    local last_current_scroll_pos = self.current_scroll_pos

    while scroll_step > 0 do
        local scroll_amount
        local scroll_offset = math.abs(self.target_scroll_pos % 1)
        if scroll_offset ~= 0 then
            --partial scrolling to the next number is always possible.
            scroll_amount = math.min(scroll_step, scroll_offset)

            if (scroll_dir == 1 and self.target_scroll_pos > 0) or
            (scroll_dir == -1 and self.target_scroll_pos < 0) then
                scroll_amount = 1 - scroll_amount
            end
        else
            --ask the creator if we can scroll up/down
            if not self.can_scroll_fn(self.target_scroll_pos + scroll_dir, self.target_scroll_pos) then
                return
            end

            scroll_amount = math.min(scroll_step, 1)
        end
        self.target_scroll_pos = self.target_scroll_pos + (scroll_amount * scroll_dir)
        if instant then
            self.current_scroll_pos = self.current_scroll_pos + (scroll_amount * scroll_dir)
        end
        scroll_step = scroll_step - scroll_amount
    end

    if instant and self.current_scroll_pos ~= last_current_scroll_pos then
        self:RefreshView()
    end
end

function ChatScrollList:RefreshView()
    local current_row, row_offset = math.modf(self.current_scroll_pos)

    local data = nil
    if self.generate_data_fn then
        data = self.generate_data_fn(current_row, row_offset)
    end

	for i = 1, self.items_per_view do
        self.update_fn(self.widgets_to_update[i], i, current_row, row_offset, data)
	end

	self.list_root:SetPosition(0, row_offset * self.row_height, 0)
end

function ChatScrollList:OnChatControl(control, down)
    if down then
        if control == CONTROL_SCROLLBACK then
            local scroll_amt = -self.scroll_per_click
            if TheInput:ControllerAttached() then
                scroll_amt = scroll_amt / 2
            end
            self:Scroll(scroll_amt)
            return true
        elseif control == CONTROL_SCROLLFWD then
            local scroll_amt = self.scroll_per_click
            if TheInput:ControllerAttached() then
                scroll_amt = scroll_amt / 2
            end
            self:Scroll(scroll_amt)
            return true
        end
    end
end

return ChatScrollList

