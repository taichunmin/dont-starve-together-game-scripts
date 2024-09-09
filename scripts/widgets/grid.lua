local Widget = require "widgets/widget"

local Grid = Class(Widget, function(self)
    Widget._ctor(self, "GRID")
    self.h_offset = 100
    self.v_offset = 100
    self.items_by_coords = {}
    self.rows = 0
    self.cols = 0
    self.layout_left_to_right_top_to_bottom = false
end)

function Grid:SetLooping(h, v)
	self.h_loop = h
	self.v_loop = v
	self:DoFocusHookups()
end

function Grid:InitSize(c,r, coffset, roffset)
	self:Clear()

	self.h_offset = coffset
	self.v_offset = roffset
	self.rows = r
	self.cols = c
	self.items_by_coords = {}
	for k = 1, r do
		local col = {}
		for k = 1,c do
			table.insert(col, nil)
		end
		table.insert(self.items_by_coords, col)
	end
end

-- Use the expected english text flow style layout.
function Grid:UseNaturalLayout()
    assert(#self.children == 0, "Call UseNaturalLayout before adding any items to the grid!")
    self.layout_left_to_right_top_to_bottom = true
end

function Grid:Clear()
	for k,v in pairs(self.items_by_coords) do
		for k,v in pairs(v) do
			v:Kill()
		end
	end
    self.items_by_coords = {}
end

function Grid:DoFocusHookups()
	for c = 1, self.cols do
		for r = 1, self.rows do
			local item = self:GetItemInSlot(c,r)
			if item then
				item:ClearFocusDirs()
				local up = r > 1 and self:GetItemInSlot(c,r-1)
				local down = r < self.rows and self:GetItemInSlot(c,r+1)
				local left = c > 1 and self:GetItemInSlot(c-1,r)
				local right = c < self.cols and self:GetItemInSlot(c+1,r)

				if self.h_loop then
					if c == 1 then left = self:GetItemInSlot(self.cols,r) end
					if c == self.cols then right = self:GetItemInSlot(1,r) end
				end

				if self.v_loop then
					if r == 1 then up = self:GetItemInSlot(c,self.rows) end
					if r == self.rows then down = self:GetItemInSlot(c,1) end
				end

				if up then item:SetFocusChangeDir(MOVE_UP, up) end
				if down then item:SetFocusChangeDir(MOVE_DOWN, down) end
				if left then item:SetFocusChangeDir(MOVE_LEFT, left) end
				if right then item:SetFocusChangeDir(MOVE_RIGHT, right) end
			end
		end
	end

end

function Grid:GetRowsInCol(c)
	if c <= self.cols then
		for r = self.rows, 1, -1 do
			if self.items_by_coords[r][c] ~= nil then
				return r
			end
		end
	end
	return 0
end

function Grid:SetFocus(c, r)
    -- Grid itself cannot receive focus -- only its children (so don't call
    -- parent function).
	r = r or 1
	c = c or 1

	if c < 0 then
		c = c + self.cols + 1
	end

	if r < 0 then
		r = r + self.rows + 1
	end

	local item = self:GetItemInSlot(c, r)
	if item then
		item:SetFocus()
	end
end


-- Find the first item in the grid matching a predicate.
function Grid:FindItemSlot(compare_fn)
    assert(type(compare_fn) == 'function')
    for c = 1, self.cols do
        for r = 1, self.rows do
            local found = self:GetItemInSlot(c,r)
            if found and compare_fn(found) then
                return c, r
            end
        end
    end
end


function Grid:GetItemInSlot(c,r)
	if r > self.rows or c > self.cols then return end

	if not self.items_by_coords[r] then
		return
	end

	return self.items_by_coords[r][c]
end


function Grid:AddItem(widget, c, r)
	if r > self.rows or c > self.cols then return end

	local old_item = self:GetItemInSlot(c,r)

	if old_item then
		old_item:Kill()
		self.items_by_coords[r][c] = nil
	end

	self:AddChild(widget)

	self.items_by_coords[r][c] = widget

    self:_Layout(c,r, widget)

	self:DoFocusHookups()
	return widget
end

-- Apply a new layout to the input widget.
--
-- Grid is intended to be a static widget that gives a
-- good initial layout. We may need to rethink somethings if we want to call
-- this in an update loop.
function Grid:_Layout(c,r, widget)
    local row_on_screen = r - 1
    local col_on_screen = c - 1
    if self.layout_left_to_right_top_to_bottom then
        row_on_screen = 1 - r
    end
	widget:SetPosition(Vector3(self.h_offset*col_on_screen, self.v_offset*row_on_screen, 0))
end

-- Add a list of items to the grid.
--
-- Defaults to starting at the beginning. Great for initial fill of content.
function Grid:AddList(widget_list, initial_row, initial_col)
    local c = initial_col or 1
    local r = initial_row or 1
    for i,w in ipairs(widget_list) do
        self:AddItem(w,c,r)
        c = c + 1
        if c > self.cols then
            c = 1
            r = r + 1
            if r > self.rows then
                return
            end
        end
    end
end

-- Easily initialize the grid.
--
-- Orders left to right and top to bottom. Should work how you'd expect.
--      local g = Grid()
--      g:FillGrid(2, 100, 100, { Text(UIFONT, 20, "1"), Text(UIFONT, 20, "2"), Text(UIFONT, 20, "3"), })
-- Gives a grid like:
--      1  2
--      3
function Grid:FillGrid(num_columns, coffset, roffset, items)
    self.num_rows = math.ceil(#items / num_columns)
    self:UseNaturalLayout()
    self:InitSize(num_columns, self.num_rows, coffset, roffset)
    self:AddList(items)
end

function Grid:DebugDraw_AddSection(dbui, panel)
    Grid._base.DebugDraw_AddSection(self, dbui, panel)

    dbui.Spacing()
    dbui.Text("Grid")
    dbui.Indent() do
        dbui.Value("max rows", self.rows)
        dbui.Value("max cols", self.cols)

        local changed_layout, should_layout = dbui.Checkbox("use natural layout", self.layout_left_to_right_top_to_bottom)
        if changed_layout then
            self.layout_left_to_right_top_to_bottom = should_layout
        end

        local changed_h, new_h = dbui.DragFloat("h_offset", self.h_offset, 10, 0, 10000, "%.1f", 1)
        local changed_v, new_v = dbui.DragFloat("v_offset", self.v_offset, 10, 0, 10000, "%.1f", 1)
        if changed_h then
            self.h_offset = new_h
        end
        if changed_v then
            self.v_offset = new_v
        end

        if changed_layout or changed_h or changed_v then
            for c = 1, self.cols do
                for r = 1, self.rows do
                    local item = self:GetItemInSlot(c,r)
                    if item then
                        self:_Layout(c,r,item)
                    end
                end
            end
        end
    end
    dbui.Unindent()
end



return Grid
