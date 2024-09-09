local Widget = require "widgets/widget"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"

local scroll_per_click = 1
local scroll_per_page = 5

local button_repeat_time = .15

local arrow_button_size = 40

local DRAG_SCROLL_X_THRESHOLD = 150

local SCROLLBAR_STYLE = {
    BLACK = {
        atlas = "images/ui.xml",
        up = "arrow_scrollbar_up.tex",
        down = "arrow_scrollbar_down.tex",
        bar = "scrollbarline.tex",
        handle = "scrollbarbox.tex",
        --~ scale = 0.4,
        scale = 1.0,
    },
    GOLD = {
        atlas = "images/global_redux.xml",
        up = "scrollbar_arrow_up.tex",
        down = "scrollbar_arrow_down.tex",
        bar = "scrollbar_bar.tex",
        handle = "scrollbar_handle.tex",
        scale = 0.3,
    }
}

-- ScrollableList expects a table of pre-constructed items to be handed in as the "items" param OR
-- for the "items" table to be a normalized table of data where each table entry is the data that will be handed as the parameters to the supplied function for "updatefn"
local ScrollableList = Class(Widget, function(self, items, listwidth, listheight, itemheight, itempadding, updatefn, widgetstoupdate, widgetXOffset, always_show_static, starting_offset, yInit, bar_width_scale_factor, bar_height_scale_factor, scrollbar_style)
    Widget._ctor(self, "ScrollBar")
    -- Can remove bar_width_scale_factor, bar_height_scale_factor. Nothing active uses them.
    bar_width_scale_factor = bar_width_scale_factor or 1
    bar_height_scale_factor = bar_height_scale_factor or 1

    self.height = listheight
    self.width = listwidth
    self.bg = self:AddChild(Image("images/ui.xml", "blank.tex")) -- so that we have focus whenever the mouse is over this thing
    self.bg:ScaleToSize(self.width, self.height)
    self.items = {}
    self.item_height = itemheight or 40
    self.item_padding = itempadding or 10
    self.x_offset = widgetXOffset or 0
    self.yInitial = yInit or 0
    self.always_show_static_widgets = always_show_static or false
    self.focused_index = 1
    self.focus_children = true
    self.scrollbar_style = SCROLLBAR_STYLE[scrollbar_style or "BLACK"]
    assert(self.scrollbar_style, "If you can't pass a valid scrollbar_style, then don't pass one at all.")

    self.items = items
    if updatefn and widgetstoupdate then
        self.updatefn = updatefn
        self.static_widgets = widgetstoupdate
    else
        for i,v in pairs(self.items) do
            self:AddChild(v)
        end
    end

    self:RecalculateStepSize()

    self.view_offset = starting_offset or 0

    -- self.widget_bg = self:AddChild(Image("images/ui.xml", "1percent_clickbox.tex"))
    -- self.widget_bg:SetTint(1,1,1,0)
    -- self.widget_bg:ScaleToSize(self.width, self.height)

    self.scroll_bar_container = self:AddChild(Widget("scroll-bar-container"))

    self.up_button = self.scroll_bar_container:AddChild(ImageButton(self.scrollbar_style.atlas, self.scrollbar_style.up))
    self.up_button:SetScale(self.scrollbar_style.scale)
    local handle_scale = bar_width_scale_factor * self.scrollbar_style.scale
    self.up_button:SetPosition(self.width/2, self.height/2-10, 0)
    self.up_button:SetWhileDown( function()
        if not self.last_up_button_time or GetStaticTime() - self.last_up_button_time > button_repeat_time then
            self.last_up_button_time = GetStaticTime()
            self:Scroll(-scroll_per_click, true)
        end
    end)
    self.up_button:SetOnClick( function()
        self.last_up_button_time = nil
    end)
    -- self.up_button:StartUpdating()


    self.down_button = self.scroll_bar_container:AddChild(ImageButton(self.scrollbar_style.atlas, self.scrollbar_style.down))
    self.down_button:SetScale(self.scrollbar_style.scale)
    self.down_button:SetPosition(self.width/2, -self.height/2+10, 0)
    self.down_button:SetWhileDown( function()
        if not self.last_down_button_time or GetStaticTime() - self.last_down_button_time > button_repeat_time then
            self.last_down_button_time = GetStaticTime()
            self:Scroll(scroll_per_click, true)
        end
    end)
    self.down_button:SetOnClick( function()
        self.last_down_button_time = nil
    end)
    -- self.down_button:StartUpdating()

    self.scroll_bar_line = self.scroll_bar_container:AddChild(Image(self.scrollbar_style.atlas, self.scrollbar_style.bar))
    self.scroll_bar_line:ScaleToSize( 11*bar_width_scale_factor, self.height - arrow_button_size - 20)
    self.scroll_bar_line:SetPosition(self.width/2, 0)

    self.scroll_bar = self.scroll_bar_container:AddChild(ImageButton("images/ui.xml", "1percent_clickbox.tex", "1percent_clickbox.tex", "1percent_clickbox.tex", nil, nil, {1,1}, {0,0}))
    self.scroll_bar.image:ScaleToSize( 32, self.height - arrow_button_size - 20)
    self.scroll_bar.image:SetTint(1,1,1,0)
    self.scroll_bar.scale_on_focus = false
    self.scroll_bar.move_on_click = false
    self.scroll_bar:SetPosition(self.width/2, 0)
    self.scroll_bar:SetOnDown( function()
        self.page_jump = true
    end)
    self.scroll_bar:SetOnClick( function()
        if self.position_marker and self.page_jump then
            local marker = self.position_marker:GetWorldPosition()
            if TheFrontEnd.lasty >= marker.y then
                self:Scroll(-scroll_per_page, true)
            else
                self:Scroll(scroll_per_page, true)
            end
            self.page_jump = false
        end
    end )

    self.position_marker = self.scroll_bar_container:AddChild(ImageButton(self.scrollbar_style.atlas, self.scrollbar_style.handle))
    self.position_marker.scale_on_focus = false
    self.position_marker.move_on_click = false
    self.position_marker:SetPosition(self.width/2, self.height/2 - arrow_button_size, 0)
    local handle_scale = bar_width_scale_factor * self.scrollbar_style.scale
    self.position_marker:SetScale(handle_scale, handle_scale, 1)
    self.position_marker:SetOnDown( function()
        self.do_dragging = true
        self.y_adjustment = 0
    end)
    self.position_marker:SetWhileDown( function()
        if self.do_dragging then
            TheFrontEnd:LockFocus(true)
            self.dragging = true
            self:DoDragScroll()
        end
    end)
    self.position_marker.OnLoseFocus = function()
        TheFrontEnd:LockFocus(false)
        self.dragging = false
        self.do_dragging = false
        self.y_adjustment = 0
        self:MoveMarkerToNearestStep()
    end
    self.position_marker:SetOnClick( function()
        TheFrontEnd:LockFocus(false)
        self.dragging = false
        self.do_dragging = false
        self.y_adjustment = 0
        self:MoveMarkerToNearestStep()
    end)

    --self.position_marker:MoveToBack()
    self.scroll_bar_line:MoveToBack()
    self.scroll_bar_container:SetScale(1, bar_height_scale_factor)

    self:DoFocusHookups()

    self:RefreshView()
end)

function ScrollableList:DebugDraw_AddSection(dbui, panel)
    ScrollableList._base.DebugDraw_AddSection(self, dbui, panel)

    dbui.Spacing()
    dbui.Text("ScrollableList")
    dbui.Indent() do
        local step, step_fast = 1, 5
        local has_modified_x, out_x = dbui.InputFloat("width", self.width, step, step_fast)
        if has_modified_x then
            self.width = out_x
        end
        local has_modified_y, out_y = dbui.InputFloat("height", self.height, step, step_fast)
        if has_modified_y then
            self.height = out_y
        end
        local has_modified_height, out_height = dbui.InputFloat("item_height", self.item_height, step, step_fast)
        if has_modified_height then
            self.item_height = out_height
        end
        local has_modified_padding, out_padding = dbui.InputFloat("item_padding", self.item_padding, step, step_fast)
        if has_modified_padding then
            self.item_padding = out_padding
        end
        local has_modified_offset, out_offset = dbui.InputFloat("x_offset", self.x_offset, step, step_fast)
        if has_modified_offset then
            self.x_offset = out_offset
        end
        local has_modified_initialy, out_initialy = dbui.InputFloat("yInitial", self.yInitial, step, step_fast)
        if has_modified_initialy then
            self.yInitial = out_initialy
        end
        local has_modified_show, out_show = dbui.Checkbox("always_show_static_widgets", self.always_show_static_widgets)
        if has_modified_show then
            self.always_show_static_widgets = out_show
        end
        dbui.Value("focused_index", self.focused_index)
        dbui.Checkbox("focus_children", self.focus_children)
        dbui.Value("#items", #self.items)
        --~ local item_names = {}
        --~ for i,val in ipairs(self.items) do
        --~     table.insert(item_names, tostring(val))
        --~ end
        --~ dbui.ListBox("items", item_names)

        if has_modified_x or has_modified_y or has_modified_height or has_modified_padding or has_modified_offset or has_modified_initialy or has_modified_show then
            -- Resize commands copied from ctor
            self.bg:ScaleToSize(self.width, self.height)
            self.up_button:SetPosition(self.width/2, self.height/2-10, 0)
            self.down_button:SetPosition(self.width/2, -self.height/2+10, 0)
            self.scroll_bar_line:SetPosition(self.width/2, 0)
            self.scroll_bar:SetPosition(self.width/2, 0)

            self:LayOutStaticWidgets(self.yInitial)
            self:RefreshView(true)
        end
    end
    dbui.Unindent()
end

function ScrollableList:OnControl(control, down, force)
    if ScrollableList._base.OnControl(self, control, down) then return true end

    if down and ((self.focus and self.scroll_bar:IsVisible()) or force) then
        if control == CONTROL_SCROLLBACK then
            if self:Scroll(-scroll_per_click, true) then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
            end
            return true
        elseif control == CONTROL_SCROLLFWD then
            if self:Scroll(scroll_per_click, true) then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
            end
            return true
        end
    end
end

function ScrollableList:Scroll(amt, movemarker)
    local prev = self.view_offset

    -- Do Scroll on list
    self.view_offset = self.view_offset + amt
    if self.view_offset < 0 or self.max_step <= 0 then
        self.view_offset = 0
    elseif self.view_offset > self.max_step then
        self.view_offset = self.max_step
    end

    local didScrolling = self.view_offset ~= prev

    -- Move the marker
    if movemarker then
        local marker = self.position_marker:GetPosition()
        local newY = (self.height/2 - arrow_button_size) - (self.view_offset * self.step_size)
        if newY < -self.height/2 + arrow_button_size then
            newY = -self.height/2 + arrow_button_size
        elseif newY > self.height/2 - arrow_button_size then
            newY = self.height/2 - arrow_button_size
        end
        self.position_marker:SetPosition(marker.x, newY)
    end

    -- Refresh the view
    self:RefreshView()

    if self.onscrollcb ~= nil then
        self.onscrollcb()
    end
    return didScrolling
end

function ScrollableList:RefreshView(movemarker)
    local showing = false
    local nextYPos = self.height/2 - (arrow_button_size * .5) + self.yInitial

    local numShown = 0
    for i,v in ipairs(self.items) do
        local item_offset = (self.view_offset+1) - i
        if item_offset > 0 then
            showing = false
        elseif item_offset == 0 then
            showing = true
        end

        if showing then
            if self.updatefn ~= nil and self.static_widgets ~= nil then
                if self.static_widgets[i - self.view_offset] then
                    -- if i - self.view_offset > #self.static_widgets then break end -- just in case we get into a bad spot
                    self.updatefn(self.static_widgets[i - self.view_offset], v, i)
                    self.static_widgets[i - self.view_offset]:SetPosition(-self.width/2 + self.x_offset, nextYPos + ((self.item_height + self.item_padding) * item_offset))
                end
            else
                v:SetPosition(-self.width/2 + self.x_offset, nextYPos + ((self.item_height + self.item_padding) * item_offset))
                v:Show()
            end
            numShown = numShown + 1

            -- Make sure we can actually fit another widget below us
            if numShown >= self.widgets_per_view then
                showing = false
            end
        elseif self.updatefn ~= nil and self.static_widgets ~= nil then
            --#srosen controller scrolling is a little wonky here: focus is getting placed on weird things (update & constructed)
            if self.focused_index < self.view_offset+1 then
                self.focused_index = self.view_offset+1
            elseif self.focused_index > self.view_offset+self.widgets_per_view then
                self.focused_index = self.view_offset+self.widgets_per_view
            end
        else
            if v.focus then
                if i < self.view_offset+1 then
                    self.items[self.view_offset+1]:SetFocus()
                    self.focused_index = self.view_offset+1
                elseif i > self.view_offset+self.widgets_per_view then
                    self.items[self.view_offset+self.widgets_per_view]:SetFocus()
                    self.focused_index = self.view_offset+self.widgets_per_view
                end
            end
            v:SetPosition(-self.width/2 + self.x_offset, nextYPos + ((self.item_height + self.item_padding) * item_offset))
            v:Hide()
        end
    end

    if self.static_widgets and #self.items < #self.static_widgets and not self.always_show_static_widgets then
        for i,v in ipairs(self.static_widgets) do
            if i <= #self.items then
                v:Show()
            else
                v:Hide()
            end
        end
    elseif self.static_widgets and #self.items < #self.static_widgets and self.always_show_static_widgets then
        for i,v in ipairs(self.static_widgets) do
            if i <= #self.items then
                self.updatefn(v, self.items[i])
            else
                self.updatefn(v, nil)
            end
        end
    elseif self.static_widgets and #self.items >= #self.static_widgets then
        for i,v in ipairs(self.static_widgets) do
            v:Show()
        end
    end

    if #self.items <= self.widgets_per_view then
        self.up_button:Hide()
        self.down_button:Hide()
        self.position_marker:Hide()
        self.scroll_bar:Hide()
        self.scroll_bar_line:Hide()
    else
        self.up_button:Show()
        self.down_button:Show()
        self.position_marker:Show()
        self.scroll_bar:Show()
        self.scroll_bar_line:Show()
    end

    -- Move the marker
    if movemarker then
        local marker = self.position_marker:GetPosition()
        local newY = (self.height/2 - arrow_button_size) - (self.view_offset * self.step_size)
        if newY < -self.height/2 + arrow_button_size then
            newY = -self.height/2 + arrow_button_size
        elseif newY > self.height/2 - arrow_button_size then
            newY = self.height/2 - arrow_button_size
        end
        self.position_marker:SetPosition(marker.x, newY)
    end
end

-- skip fixup is for when there's a widget that is already adding the scroll list help text and control stuff for the update style (i.e. ListCursor)
-- focus children should be false when it's just an information list (i.e. the morgue) and there's nothing interactable in the list
-- if set to false, then we keep the focus on the scroll list so that it can handle the scroll input properly
function ScrollableList:LayOutStaticWidgets(yInitial, skipFixUp, focusChildren)
    if self.static_widgets then
        local showing = false
        self.yInitial = yInitial or 0
        local nextYPos = self.height/2 - (arrow_button_size * .5) + self.yInitial

        local numShown = 0
        for i, v in ipairs(self.static_widgets) do
            v:SetPosition(-self.width/2 + self.x_offset, nextYPos)
            nextYPos = nextYPos - self.item_height - self.item_padding

            if not skipFixUp then
                local helptextFn = v.GetHelpText
                v.GetHelpText = function()
                    local controller_id = TheInput:GetControllerID()
                    local t = {}
                    if self.scroll_bar and self.scroll_bar:IsVisible() then
                        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_SCROLLBACK, false, false).."/"..TheInput:GetLocalizedControl(controller_id, CONTROL_SCROLLFWD, false, false).. " " .. STRINGS.UI.HELP.SCROLL)
                    end
                    if helptextFn then
                        table.insert(t, helptextFn())
                    end
                    return table.concat(t, "  ")
                end

                local gainfocusFn = v.OnGainFocus
                v.OnGainFocus = function()
                    gainfocusFn(v)
                    self.focused_index = self.view_offset + i
                end

                v:SetParentScrollList(self)
            end
        end

        if focusChildren ~= nil then
            self.focus_children = focusChildren
        end
    end
end

function ScrollableList:GetNearestStep()
    local marker = self.position_marker:GetPosition()
    return math.floor((marker.y / self.step_size) + 0.5)
end

function ScrollableList:GetHierarchicalScale()
		local scaleX, scaleY, scaleZ = self.inst.UITransform:GetScale()

		local parent = self:GetParent()
		while parent do
			local parentScaleX, parentScaleY, parentScaleZ = parent.inst.UITransform:GetScale()
			scaleX = scaleX * parentScaleX
			scaleY = scaleY * parentScaleY
			scaleZ = scaleZ * parentScaleZ
			parent = parent:GetParent()
		end
		return scaleX, scaleY, scaleZ
end

function ScrollableList:DoDragScroll()
    -- Near the scroll bar, keep drag-scrolling
    local marker = self.position_marker:GetWorldPosition()
    if self.dragging and math.abs(TheFrontEnd.lastx - marker.x) <= DRAG_SCROLL_X_THRESHOLD then
        local pos = self:GetWorldPosition()

		local _,scaleY,_ = self:GetHierarchicalScale()

        local click_y = TheFrontEnd.lasty
        local prev_step = self:GetNearestStep()

		local scaledHalflength = (self.height/2) * scaleY
		local scaledArrowHeight = arrow_button_size * scaleY

		click_y = click_y - pos.y
		click_y = math.clamp(click_y, - scaledHalflength + scaledArrowHeight, scaledHalflength - scaledArrowHeight)

		click_y = click_y / scaleY

        self.position_marker:SetPosition(self.width/2, click_y + self.y_adjustment)
        local curr_step = self:GetNearestStep()
        if curr_step ~= prev_step then
            self:Scroll(prev_step - curr_step, false)
        end
    else -- Far away from the scroll bar, revert to original pos
        local prev_step = self:GetNearestStep()
        if self.position_marker.o_pos then
            self.position_marker:SetPosition(self.position_marker.o_pos)
        end
        local curr_step = self:GetNearestStep()
        if curr_step ~= prev_step then
            self:Scroll(prev_step - curr_step, false)
        end
        self:MoveMarkerToNearestStep()
    end
end

function ScrollableList:MoveMarkerToNearestStep()
    local y = (self.height/2 - arrow_button_size) - (self.view_offset * self.step_size)
    if y > self.height/2 - arrow_button_size then
        y = self.height/2 - arrow_button_size
    elseif y < -self.height/2 + arrow_button_size then
        y = -self.height/2 + arrow_button_size
    end
    self.position_marker:SetPosition(self.width/2, y)
end

function ScrollableList:SetScrollPerClick(amt)
    scroll_per_click = amt
end

function ScrollableList:SetScrollPerPage(amt)
    scroll_per_page = amt
end

function ScrollableList:RecalculateStepSize()
    self.widgets_per_view = math.ceil(self.height / (self.item_height + self.item_padding))
    self.max_step = math.ceil(#self.items - self.widgets_per_view)
    self.step_size = (self.height - (2*arrow_button_size)) / (#self.items - self.widgets_per_view)
    if self.view_offset and self.max_step and self.view_offset > math.abs(self.max_step) then --#srosen we want to do percentage based marker movement
        if self.max_step > 0 then
            self.view_offset = self.max_step
        else
            self.view_offset = 0
        end
    end
end

function ScrollableList:SetListItemPadding(pad)
    self.item_padding = pad
    self:RecalculateStepSize()
    self:RefreshView()
end

function ScrollableList:SetListItemHeight(ht)
    self.item_height = ht
    self:RecalculateStepSize()
    self:RefreshView()
end

--keeprelativefocusindex: keep the focus on the same physical
--slot, even as the items get shifted from updating the list.
function ScrollableList:SetList(list, keepitems, scrollto, keeprelativefocusindex)
    local rel_focus_index = self.focused_index - self.view_offset
    if not keepitems and self.updatefn == nil and self.static_widgets == nil then
        for i, v in ipairs(self.items) do
            v:Kill()
        end

        for i, v in ipairs(list) do
            self:AddChild(v)
        end
    end

    self.items = list

    --scroll by 0 to update the position to match the new list size
    self:Scroll(scrollto ~= nil and scrollto - self.view_offset or 0, true)
    self:RecalculateStepSize()
    self:DoFocusHookups()

    if keeprelativefocusindex then
        self.focused_index = self.view_offset + rel_focus_index
    end

    self:RefreshView(true)
end

function ScrollableList:AddItem(item, before_widget)
    self:RemoveItem(item) -- don't let an item be added in two positions!

    if before_widget ~= nil then
        local index = -1
        for i,v in ipairs(self.items) do
            if v == before_widget then
                index = i
                break
            end
        end
        table.insert(self.items, index, item)
        self:AddChild(item)
    else
        table.insert(self.items, item)
        self:AddChild(item)
    end

    self:Scroll(0, true) --scroll by 0 to update the position to match the new list size
    self:RecalculateStepSize()
    self:DoFocusHookups()
    self:RefreshView(true)
end

function ScrollableList:RemoveItem(item)
    local index = -1
    for i,v in ipairs(self.items) do
        if v == item then
            index = i
            break
        end
    end

    if index > -1 then
        table.remove(self.items, index)

        self:Scroll(0, true) --scroll by 0 to update the position to match the new list size
        self:RecalculateStepSize()
        self:DoFocusHookups()
        self:RefreshView(true)
    end
end

function ScrollableList:Clear()
    if self.updatefn == nil and self.static_widgets == nil then
        for i, v in ipairs(self.items) do
            v:Kill()
        end
    end
    self.items = {}
    self:RecalculateStepSize()
    self:RefreshView(true)
end

function ScrollableList:GetNumberOfItems()
    return #self.items
end

function ScrollableList:OnGainFocus()
    ScrollableList._base.OnGainFocus(self)

    -- Static table of widgets that we show and hide
    if self.updatefn ~= nil and self.static_widgets ~= nil then
        for i, v in ipairs(self.static_widgets) do
            if v.focus then
                self.focused_index = self.view_offset + i
                return
            end
        end
    elseif self.items ~= nil then
        for i, v in ipairs(self.items) do
            if v.focus then
                self.focused_index = i
                return
            end
        end
    end
    self.focused_index = 1
end

function ScrollableList:OnLoseFocus()
    ScrollableList._base.OnLoseFocus(self)

    -- Static table of widgets that we show and hide
    if self.updatefn ~= nil and self.static_widgets ~= nil then
        for i, v in ipairs(self.static_widgets) do
            if v.focus then
                self.focused_index = self.view_offset + i
                return
            end
        end
    elseif self.items ~= nil then
        for i, v in ipairs(self.items) do
            if v.focus then
                self.focused_index = i
                return
            end
        end
    end
    self.focused_index = 1
end

function ScrollableList:SetFocus()
    local index = self.focused_index
    if self.items ~= nil and #self.items < index then
        index = #self.items
    end

    if index <= self.view_offset then
        index = self.view_offset + 1
    elseif index > self.view_offset + self.widgets_per_view then
        index = self.view_offset + self.widgets_per_view
    end

    if self.updatefn ~= nil and self.static_widgets ~= nil then
        local focused_widget = self.static_widgets[index - self.view_offset]
        if focused_widget ~= nil and focused_widget.SetFocus ~= nil then
            if self.focus_children then
                focused_widget:SetFocus()
            else
                self.bg:SetFocus()
            end
            self.focused_index = index
        end
    elseif self.items ~= nil and self.items[index] ~= nil and self.items[index].SetFocus ~= nil then
        self.items[index]:SetFocus()
        self.focused_index = index
    end
end

function ScrollableList:DoFocusHookups()
    -- Static table of widgets that we show and hide
    if self.items and not self.updatefn and not self.static_widgets then
        for k,v in ipairs(self.items) do
            if k > 1 then
                self.items[k]:SetFocusChangeDir(MOVE_UP, self.items[k-1])
            end

            if k < #self.items then
                self.items[k]:SetFocusChangeDir(MOVE_DOWN, self.items[k+1])
            end
        end
    elseif self.updatefn and self.static_widgets then
        for k,v in ipairs(self.static_widgets) do
            if k > 1 then
                self.static_widgets[k]:SetFocusChangeDir(MOVE_UP, self.static_widgets[k-1])
            end

            if k < #self.static_widgets then
                self.static_widgets[k]:SetFocusChangeDir(MOVE_DOWN, self.static_widgets[k+1])
            end
        end
    end
end

function ScrollableList:OnFocusMove(dir, down)
    if ScrollableList._base.OnFocusMove(self,dir,down) then return true end

    if down then
        -- Static table of widgets that we show and hide
        if self.updatefn ~= nil and self.static_widgets ~= nil then
            for i, v in ipairs(self.static_widgets) do
                if v.focus then
                    self.focused_index = i + self.view_offset
                    break
                end
            end

            if dir == MOVE_UP then
                if self.focused_index <= self.view_offset + 1 then
                    self:Scroll(-1, true)
                    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
                    self.static_widgets[1]:SetFocus()
                    self.focused_index = self.focused_index - 1
                    return true
                end
            elseif dir == MOVE_DOWN and self.focused_index >= self.view_offset + #self.static_widgets and self.view_offset + #self.static_widgets < #self.items then
                self:Scroll(1, true)
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
                self.static_widgets[#self.static_widgets]:SetFocus()
                self.focused_index = self.focused_index + 1
                return true
            end
        elseif self.items ~= nil then
            for i, v in ipairs(self.items) do
                if v.focus then
                    self.focused_index = i
                    break
                end
            end

            if dir == MOVE_UP and self.focused_index > 1 then
                if self.focused_index <= self.view_offset + 1 then
                    self:Scroll(-1, true)
                    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
                    self.items[self.view_offset + 1]:SetFocus()
                    self.focused_index = self.focused_index - 1
                end
                return true
            elseif dir == MOVE_DOWN and self.focused_index < #self.items then
                if self.focused_index >= self.view_offset + self.widgets_per_view then
                    self:Scroll(1, true)
                    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
                    self.items[self.view_offset + self.widgets_per_view]:SetFocus()
                    self.focused_index = self.focused_index + 1
                end
                return true
            end
        end
    end
    return false
end

function ScrollableList:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}
    if self.scroll_bar and self.scroll_bar:IsVisible() then
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_SCROLLBACK, false, false).."/"..TheInput:GetLocalizedControl(controller_id, CONTROL_SCROLLFWD, false, false).. " " .. STRINGS.UI.HELP.SCROLL)
    end
    return table.concat(t, "  ")
end

function ScrollableList:IsAtEnd()
    return self.view_offset == self.max_step
end

function ScrollableList:ScrollToEnd()
    if self.scroll_bar and self.scroll_bar:IsVisible() then
        self:Scroll(self:GetNumberOfItems(), true)
    end
end

return ScrollableList
