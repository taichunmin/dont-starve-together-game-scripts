local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local ScrollableList = require "widgets/scrollablelist"

-- A dropdown list widget. When closed, it is a box containing a text string and a down arrow button. When the button is clicked, it opens to
-- show a scrollable list of text strings.
--
-- Size parameters may be nil.
-- The start text is shown in the closed box before any selections have been made.
-- Items is a list of text strings to display in the list.

-- allowMultipleSelections controls the mode of this dropdown.
-- If this flag is false, then clicking on an item in the list will close the list and change the text in the box to the text of the item.
-- If this flag is true, clicking on an item in the list will select it (and onselectfn will be called), but the list remains open. Selected items
-- have a gold diamond to their left. Any number of items may be selected. The list does not close until the arrow button is clicked again, and
-- the text in the box does not change.

-- onselectfn is called whenever an item in the list is selected, and gets the text of that item as its parameter.

local DropDown = Class(Widget, function(self, size_x, size_y, start_text, items, allowMultipleSelections, onselectfn, onunselectfn)
	Widget._ctor(self, "DropDown")

	size_x = size_x or 150
	size_y = size_y or 40

	self.start_text = start_text
	self.allowMultipleSelections = allowMultipleSelections
	self.onselectfn = onselectfn
	self.onunselectfn = onunselectfn

	items = items or {"---"}

	self.fixed_root = self:AddChild(Widget("root"))


    -- add background + scroll list for dropdown
    -- each item in scroll list textbox
	-- text should be gold like nav bar buttons


	self.drop_list = self.fixed_root:AddChild(Widget("drop-list"))

	self.drop_list.list_length = math.min(#items, 5)

	self.drop_list.bg = self.drop_list:AddChild(Image("images/frontend.xml", "submenu_greybox.tex"))
	self.drop_list.bg:ScaleToSize(size_x-4, size_y * (self.drop_list.list_length+2))
	self.drop_list.height = size_y*self.drop_list.list_length
	self.drop_list.width = size_x

    self.drop_list.list_root = self.drop_list:AddChild(Widget("list-root"))
    self.drop_list.list_widget_root = self.drop_list:AddChild(Widget("list-widget-root"))


	--print("Size", self.drop_list.width, self.drop_list.height)

	self.list_widgets = {}
	for i = 1, self.drop_list.list_length do
		local widget = self:BuildListWidget(items[i], size_x, size_y)
		table.insert(self.list_widgets, widget)
	end

	self.items_data = {}
	for i = 1, #items do
		self.items_data[i] = { text = items[i], isselected = false}
	end

	local padding = 3
	self.drop_list.list = self.drop_list.list_root:AddChild(ScrollableList(self.items_data, size_x/2, (size_y+padding)*self.drop_list.list_length, size_y, padding,
																			function(widget, data, index)
																				--print("got", widget, data, index)
																				widget.text:SetString(data.text)
																				widget.index = index
																				if data.isselected then
																					widget.Select()
																				else
																					widget.Unselect()
																				end
																			end,
																			self.list_widgets))
	self.drop_list.list:LayOutStaticWidgets()
	self.drop_list.list:SetPosition(size_x*(20/150), 0, 0)

	self.drop_list:SetPosition(0, -0.5 * self.drop_list.height - size_y, 0)

	self.drop_list:Hide()


	-- add background + textbox for selected item
	self.selection_box = self.fixed_root:AddChild(Widget("selection-box"))
	self.selection_box.bg = self.selection_box:AddChild( Image("images/textboxes.xml", "textbox2_gold_greyfill.tex") )
	self.selection_box.bg:ScaleToSize(size_x, size_y)

	self.selection_box.text = self.selection_box:AddChild(Text(UIFONT, 24, start_text, GOLD))
	self.selection_box.text:SetPosition(0, -2)
	self.selection_box.text:SetRegionSize(size_x, size_y)

	-- arrow pointing down (clickable)
	self.down_arrow = self.fixed_root:AddChild(ImageButton("images/ui.xml", "arrow2_down.tex", "arrow2_down_over.tex", "arrow2_down_down.tex", "arrow2_down_down.tex", "arrow2_down_down.tex", {1,1}, {0,0}))
	self.down_arrow:SetOnClick(function() self:Open() end)
	self.down_arrow:ForceImageSize(size_y - 10, size_y - 10)
	self.down_arrow:SetPosition((size_x/2) - (size_y/2), 0)

	self.up_arrow = self.fixed_root:AddChild(ImageButton("images/ui.xml", "arrow2_up.tex", "arrow2_up_over.tex", "arrow2_up_down.tex", "arrow2_up_down.tex", "arrow2_up_down.tex", {1,1}, {0,0}))
	self.up_arrow:SetOnClick(function() self:Close() end)
	self.up_arrow:ForceImageSize(size_y - 10, size_y - 10)
	self.up_arrow:SetPosition((size_x/2) - (size_y/2), 0)
	self.up_arrow:Hide()

end)


function DropDown:BuildListWidget(text, size_x, size_y)

	local widget = self.drop_list.list_widget_root:AddChild(Widget("list-item"))

	-- This image is here to catch mouse events, because text boxes don't catch them.
	widget.image = widget:AddChild(Image("images/ui.xml", "blank.tex"))
    widget.image:ScaleToSize(2*size_x/3, size_y)
    widget.image:SetPosition(30, 0)

    -- selected items in scroll list should have a gold diamond like the nav buttons
	widget.selected = widget:AddChild(Image("images/frontend.xml", "nav_cursor.tex"))
	widget.selected:SetScale(.67)
	widget.selected:SetPosition(-0.5*size_x + (size_x*55/150), 0)
	widget.selected:Hide()

	widget.text = widget:AddChild(Text(UIFONT, 22, text, GOLD))
	widget.text:SetPosition(30, 0)

	widget.OnControl = function(this, control, down)
		--print("Got oncontrol", control)
		if self.allowMultipleSelections then
	    	if control == CONTROL_ACCEPT and down then
		    	if not widget.isselected then
		    		widget.Select() -- Do this FIRST in case SetSelection needs to change it
		    		--print("Selected", widget.text:GetString())
		   			self:SetSelection(widget.text:GetString())
		   		else
		   			widget.Unselect()
		   			--print("Clearing selection")
		   			self:ClearSelection(widget.text:GetString())

		   			if self.onunselectfn then
		   				self.onunselectfn(widget.text:GetString())
		   			end
		   		end
		   	end
	    else
	    	-- For the single selection case, we must use the up event rather than the down because otherwise the up event is caught by
	    	-- whatever is under the mouse when the dropdown closes.
	    	if control == CONTROL_ACCEPT and not down then
		   		self:ClearAllSelections()
		   		widget.Select()
		   		self:SetSelection(widget.text:GetString())
		   	end
		end
	end

	widget.OnGainFocus = function()
		--print("ongainfocus")
		widget.selected:Show()
	end

	widget.OnLoseFocus = function()
		--print("onlosefocus")
		if not widget.isselected then
			widget.selected:Hide()
		end
	end

	widget.Select = function()
		widget.isselected = true
		self.items_data[widget.index].isselected = true
		widget.selected:Show()
	end

	widget.Unselect = function()
		--print("Unselecting ", widget.text:GetString())
		widget.isselected = false
		self.items_data[widget.index].isselected = false
		widget.selected:Hide()
	end

	return widget
end

function DropDown:ClearAllSelections()
	for i = 1, #self.list_widgets do
		self.list_widgets[i].Unselect()
	end

	for i = 1, #self.items_data do
		self.items_data[i].isselected = false
	end
end

function DropDown:ClearSelection(text)
	self.selection_box.text:SetString(self.start_text)
end

function DropDown:SetSelection(text)

	-- Should be able to select more than one thing

	-- If selecting multiple items is allowed, then don't close the list when something is selected
	-- But if only one is allowed, then auto-close the list

	-- Call onselectfn when an item is selected

	if not self.allowMultipleSelections then
		self.selection_box.text:SetString(text)

		self:Close()
	end

	if self.onselectfn then
		self.onselectfn(text)
	end
end

function DropDown:SetPosition(x, y, z)
	self.fixed_root:SetPosition(x, y, z)
end

function DropDown:SetScale(value)
	self.fixed_root:SetScale(value)
end


function DropDown:Open()
	if not self.isopen then
		self.isopen = true
		self.down_arrow:Hide()
		self.up_arrow:Show()
		self.drop_list:Show()
		--print("open")
	end
end


function DropDown:Close()
	if self.isopen then
		self.isopen = false
		self.up_arrow:Hide()
		self.down_arrow:Show()
		self.drop_list:Hide()
		--print("close")
	end
end

return DropDown