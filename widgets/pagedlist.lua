local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"


local SCROLL_REPEAT_TIME = .15
local MOUSE_SCROLL_REPEAT_TIME = 0

-------------------------------------------------------------------------------------------------------

-- This is based on ScrollableList. Like Scrollable list, it takes a pre-built list of static widgets and a list of data to update those widgets with.
-- Unlike Scrollable list, it always updates all the widgets at once (page by page) instead of one row at a time.

-- Items should be a list of data items to pass to updatefn
-- widgetstoupdate should be a static set of widgets that get updated by updatefn
-- Itemheight and itempadding are used to place the widgets (note: for a grid, each widget should be one row in the grid)
local PagedList = Class(Widget, function(self, width, updatefn, widgetstoupdate)
    Widget._ctor(self, "PagedList")


    self.static_widgets = widgetstoupdate

    self.items_per_page = #widgetstoupdate

    if updatefn and widgetstoupdate then
    	self.updatefn = updatefn
    	self.static_widgets = widgetstoupdate
    else
	    assert(false, "PagedList requires static widgets and an update function")
	end

	self.page_number = 1

   	self.repeat_time = (TheInput:ControllerAttached() and SCROLL_REPEAT_TIME) or MOUSE_SCROLL_REPEAT_TIME

	self.left_button = self:AddChild(ImageButton("images/lobbyscreen.xml", "DSTMenu_PlayerLobby_arrow_paper_L.tex", "DSTMenu_PlayerLobby_arrow_paperHL_L.tex", nil, nil, nil, {1,1}, {0,0}))
	self.left_button:SetPosition( -width/2, 0, 0)
	self.left_button:SetScale(.55)
	self.left_button:SetOnClick( function()
		self:ChangePage(-1)
	end)

	self.right_button = self:AddChild(ImageButton("images/lobbyscreen.xml", "DSTMenu_PlayerLobby_arrow_paper_R.tex", "DSTMenu_PlayerLobby_arrow_paperHL_R.tex", nil, nil, nil, {1,1}, {0,0}))
	self.right_button:SetPosition( width/2, 0, 0)
	self.right_button:SetScale(.55)
	self.right_button:SetOnClick( function()
		self:ChangePage(1)
	end)


	self:SetItemsData(nil) --initialize with no data

    self:StartUpdating()
end)

function PagedList:SetItemsData(items)
	self.items = items or {}
   	self.num_pages = math.max(1, math.ceil(#self.items/self.items_per_page))
 	self:ChangePage(0)
end

function PagedList:OnUpdate(dt)
	if self.repeat_time > -.01 then
        self.repeat_time = self.repeat_time - dt
    end
end

function PagedList:ChangePage(dir)
	if dir > 0 then
		self.page_number = self.page_number + 1
	elseif dir < 0 then
		self.page_number = self.page_number - 1
	end

	if self.page_number < 1 then
		self.page_number = 1
	end

	if self.page_number > self.num_pages then
		self.page_number = self.num_pages
	end

	self:RefreshView()
end

function PagedList:SetPage(page)
	if page and page > 0 and page <= self.num_pages then
		self.page_number = page
	end

	self:RefreshView()
end

function PagedList:EvaluateArrows()
	--show both then hide them if needed
	self.left_button:Show()
	self.left_button:Enable()
	self.right_button:Show()
	self.right_button:Enable()

	--if no pages, hide both, otherwise just hide the one at the ends
	if self.num_pages < 2 then
		self.left_button:Hide()
		self.left_button:Disable()
		self.right_button:Hide()
		self.right_button:Disable()
	else
		if self.page_number == self.num_pages then
			self.right_button:Hide()
			self.right_button:Disable()
		elseif self.page_number == 1 then
			self.left_button:Hide()
			self.left_button:Disable()
		end
	end
end

function PagedList:RefreshView()
	-- figure out which set of data we're using
	local start_index = ((self.page_number - 1) * self.items_per_page)

	-- call updatefn for each
	for i = 1,self.items_per_page do
		if self.items[start_index + i] then
			self.updatefn(self.static_widgets[i], self.items[start_index + i] )
			self.static_widgets[i]:Show()
		else
			self.updatefn(self.static_widgets[i], nil)
			self.static_widgets[i]:Show()
		end
	end

	self:EvaluateArrows()
end

function PagedList:OnControl(control, down)
	--print("PagedList got control", control, down)

	if PagedList._base.OnControl(self, control, down) then return true end
end

function PagedList:GetHelpText()
	local controller_id = TheInput:GetControllerID()

	local t = {}
	if self.left_button and self.left_button:IsEnabled() then

		if self.right_button and self.right_button:IsEnabled() then
			table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_SCROLLBACK, false, false) .. "/" .. TheInput:GetLocalizedControl(controller_id, CONTROL_SCROLLFWD, false, false) .. " " .. STRINGS.UI.HELP.CHANGEPAGE)
		else
			table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_SCROLLBACK, false, false) .. " " .. STRINGS.UI.HELP.PREVPAGE)
		end
	elseif self.right_button and self.right_button:IsEnabled() then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_SCROLLFWD, false, false) .. " " .. STRINGS.UI.HELP.NEXTPAGE)
	end

	return table.concat(t, "  ")
end

return PagedList

