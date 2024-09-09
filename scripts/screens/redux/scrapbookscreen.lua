require "util"
require "strings"
require "constants"

local DEBUG_MODE = BRANCH == "dev"

--[[
TheScrapbookPartitions:WasSeenInGame("prefab")
TheScrapbookPartitions:SetSeenInGame("prefab")

TheScrapbookPartitions:WasViewedInScrapbook("prefab")
TheScrapbookPartitions:SetViewedInScrapbook("prefab")

TheScrapbookPartitions:WasInspectedByCharacter(inst, "wilson")
TheScrapbookPartitions:SetInspectedByCharacter(inst, "wilson")

TheScrapbookPartitions:DebugDeleteAllData()
TheScrapbookPartitions:DebugSeenEverything()
TheScrapbookPartitions:DebugUnlockEverything()
]]

local recipes_filter = require("recipes_filter")

local Screen = require "widgets/screen"
local Subscreener = require "screens/redux/subscreener"
local TextButton = require "widgets/textbutton"
local ImageButton = require "widgets/imagebutton"
local Menu = require "widgets/menu"
local Grid = require "widgets/grid"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local ScrollableList = require "widgets/scrollablelist"
local PopupDialogScreen = require "screens/redux/popupdialog"
local OnlineStatus = require "widgets/onlinestatus"
local TEMPLATES = require "widgets/redux/templates"
local TrueScrollArea = require "widgets/truescrollarea"
local UIAnim = require "widgets/uianim"

local dataset = require("screens/redux/scrapbookdata")

local PANEL_WIDTH = 1000
local PANEL_HEIGHT = 530
local SEARCH_BOX_HEIGHT = 40
local SEARCH_BOX_WIDTH = 300

local FILLER = "zzzzzzz"
local UNKNOWN = "unknown"

local UK_TINT = {0.5,0.5,0.5,1}

---------------------------------------
-- SEEDED RANDOM NUMBER
local A1, A2 = 727595, 798405 -- 5^17=D20*A1+A2
local D20, D40 = 1048576, 1099511627776 -- 2^20, 2^40
local X1, X2 = 0, 1

function rand()
  	local U = X2 * A2
  	local V = (X1 * A2 + X2 * A1) % D20
  	V = (V * D20 + U) % D40
  	X1 = math.floor(V / D20)
  	X2 = V - X1 * D20
  	return V / D40
end

function primeRand(seed)
	X1= seed
 	A1, A2 = 727595, 798405 -- 5^17=D20*A1+A2
	D20, D40 = 1048576, 1099511627776 -- 2^20, 2^40
	X2 = 1
end

local function GetPeriodString(period)
	local days = math.floor(period/60/8*100)/100

	if days < 1 then
		local minutes = math.floor(period/60*100)/100

		if minutes < 1 then
			return subfmt(STRINGS.SCRAPBOOK.DATA_TIME, { time = period, txt = STRINGS.SCRAPBOOK.DATA_SECONDS })
		end

		return subfmt(STRINGS.SCRAPBOOK.DATA_TIME, { time = minutes, txt = (minutes <= 1 and STRINGS.SCRAPBOOK.DATA_MINUTE or STRINGS.SCRAPBOOK.DATA_MINUTES) })
	else
		return subfmt(STRINGS.SCRAPBOOK.DATA_TIME, { time = days, txt = (days <= 1 and STRINGS.SCRAPBOOK.DATA_DAY or STRINGS.SCRAPBOOK.DATA_DAYS) })
	end
end

local DESCRIPTION_STATUS_LOOKUP =
{
	ARCHIVE_COOKPOT = "EMPTY",
	ARCHIVE_RUNE_STATUE = "LINE_1",
	ARCHIVE_SWITCH = "GEMS",
	ATRIUM_GATE = "OFF",
	ATRIUM_LIGHT = "OFF",
	ATRIUM_RUBBLE = "LINE_1",
	BLUEPRINT = "COMMON",
	CAVE_EXIT = "OPEN",
	COOKPOT = "EMPTY",
	FIRESUPPRESSOR = "OFF",
	MOLE = "ABOVEGROUND",
	MUSHROOM_FARM = "EMPTY",
	MUSHROOM_LIGHT = "OFF",
	MUSHROOM_LIGHT2 = "OFF",
	NIGHTMARE_TIMEPIECE = "WARN",
	SANITYROCK = "INACTIVE",
	SCULPTINGTABLE = "EMPTY",
	SCULPTURE_BISHOPBODY = "UNCOVERED",
	SCULPTURE_KNIGHTBODY = "UNCOVERED",
	SCULPTURE_ROOKBODY = "UNCOVERED",
	STAGEHAND = "HIDING",
	STAGEUSHER = "SITTING",
	TELEBASE = "VALID",
	WORM = "WORM",

}

local FUELTYPE_SUBICON_LOOKUP = {
	[FUELTYPE.BURNABLE]  = "icon_fuel_burnable.tex",
	[FUELTYPE.CAVE] 	 = "icon_fuel_cavelight.tex",
	[FUELTYPE.CHEMICAL]  = "icon_fuel_chemical.tex",
	[FUELTYPE.NIGHTMARE] = "icon_fuel_nightmare.tex",
	[FUELTYPE.WORMLIGHT] = "icon_fuel_wormlight.tex",
}

local FUELTYPE_SUBICONS = table.getkeys(FUELTYPE_SUBICON_LOOKUP)

--------------------------------------------------

local ScrapbookScreen = Class(Screen, function( self, prev_screen, default_section )
	Screen._ctor(self, "ScrapbookScreen")

    self.letterbox = self:AddChild(TEMPLATES.old.ForegroundLetterbox())
	self.root = self:AddChild(TEMPLATES.ScreenRoot("ScrapBook"))
    self.bg = self.root:AddChild(TEMPLATES.PlainBackground())

    if not TheScrapbookPartitions:ApplyOnlineProfileData() then
        local msg = not TheInventory:HasSupportForOfflineSkins() and (TheFrontEnd ~= nil and TheFrontEnd:GetIsOfflineMode() or not TheNet:IsOnlineMode()) and STRINGS.UI.SCRAPBOOK.ONLINE_DATA_USER_OFFLINE or STRINGS.UI.SCRAPBOOK.ONLINE_DATA_DOWNLOAD_FAILED
        self.sync_status = self.root:AddChild(Text(HEADERFONT, 24, msg, UICOLOURS.WHITE))
        self.sync_status:SetVAnchor(ANCHOR_TOP)
        self.sync_status:SetHAnchor(ANCHOR_RIGHT)
        local w, h = self.sync_status:GetRegionSize()
        self.sync_status:SetPosition(-w/2 - 2, -h/2 - 2) -- 2 Pixel padding, top right screen justification.
    end

	if DEBUG_MODE then
        self.debugentry = self.root:AddChild(TextButton())
        self.debugentry:SetTextSize(12)
        self.debugentry:SetFont(HEADERFONT)
        self.debugentry:SetVAnchor(ANCHOR_BOTTOM)
        self.debugentry:SetHAnchor(ANCHOR_RIGHT)
		self.debugentry:SetScaleMode(SCALEMODE_PROPORTIONAL)
		self.debugentry.clickoffset = Vector3(0, 0, 0)

        self.debugentry:SetOnClick(function()
            nolineprint(self.debugentry.build..".fla")
        end)
	end

    self:SetPlayerKnowledge()
	self:LinkDeps()

	self.closing = false
	self.columns_setting = Profile:GetScrapbookColumnsSetting()
	self.current_dataset = self:CollectType(dataset,"creature")
	self.current_view_data = self:CollectType(dataset,"creature")

    self:MakeSideBar()

	self.current_dataset = self:CollectType(dataset,"creature")
	self.current_view_data = self:CollectType(dataset,"creature")
    self:SelectSideButton("creature")

    self.title = self.root:AddChild(TEMPLATES.ScreenTitle(STRINGS.UI.SCRAPBOOK.TITLE, ""))

	self:MakeBackButton()

    self.dialog = self.root:AddChild(TEMPLATES.RectangleWindow(PANEL_WIDTH, PANEL_HEIGHT))
    self.dialog:SetPosition(0, 0)

    self.detailsroot = self.dialog:AddChild(Widget("details_root"))
    self.detailsroot:SetPosition(-250,0)

    self.gridroot = self.dialog:AddChild(Widget("grid_root"))
    self.gridroot:SetPosition(240,0)

    self.item_grid = self.gridroot:AddChild( self:BuildItemGrid() )
    self.item_grid:SetPosition(0, 0)

    self.item_grid:SetItemsData(self.current_view_data)

	local grid_w, grid_h = self.item_grid:GetScrollRegionSize()

	self.details = self.detailsroot:AddChild(self:PopulateInfoPanel())

	self:MakeBottomBar()
	self:MakeTopBar()
	self:SetGrid()

	self.focus_forward = self.item_grid

	if TheInput:ControllerAttached() then
		self:SetFocus()
	end

	SetAutopaused(true)
end)


function ScrapbookScreen:SetPlayerKnowledge()
	for prefab,data in pairs(dataset) do
		data.knownlevel = TheScrapbookPartitions:GetLevelFor(prefab)
	end
end

function ScrapbookScreen:LinkDeps()
	for entry, data in pairs(dataset) do
		if data.entry ~= nil then break end -- Dependencies are already linked!

		data.entry = entry
		data.deps = data.deps or {}

		for _, dep in ipairs(data.deps) do
			local depdata = dataset[dep]

			if depdata ~= nil then
				depdata.deps = depdata.deps or {}

				if not table.contains(depdata.deps, entry) then
					table.insert(depdata.deps, entry)
				end
			end
		end
	end
end

function ScrapbookScreen:FilterData(search_text, search_set)
	if not search_set  then
		search_set = self:CollectType(dataset)
	end

	if not search_text or search_text == "" then
		-- Return to last selected filter!
		self:SelectSideButton(self.last_filter)
		self.current_view_data = self:CollectType(dataset, self.last_filter)
		return
	end

	local newset = {}
	for i,set in ipairs( search_set ) do
		local name = nil
		if set.type ~= UNKNOWN then
			name = TrimString(string.lower(STRINGS.NAMES[string.upper(set.name)])):gsub(" ", "")

		--local name = TrimString(string.lower(set.name)):gsub(" ", "")
			if set.subcat then
				name = name .. TrimString(string.lower(STRINGS.SCRAPBOOK.SUBCATS[string.upper(set.subcat)])):gsub(" ", "")
			end
			local num = string.find(name, search_text, 1, true)
			if num then
				table.insert(newset,set)
			end
		end
	end

	self.current_view_data = newset
end

function ScrapbookScreen:SetSearchText(search_text)
	search_text = TrimString(string.lower(search_text)):gsub(" ", "")

	self:FilterData(search_text)

	self:SetGrid()
end

function ScrapbookScreen:MakeSearchBox(box_width, box_height)
    local searchbox = Widget("search")
	searchbox:SetHoverText(STRINGS.UI.CRAFTING_MENU.SEARCH, {offset_y = 30, attach_to_parent = self })

    searchbox.textbox_root = searchbox:AddChild(TEMPLATES.StandardSingleLineTextEntry(nil, box_width, box_height))
    searchbox.textbox = searchbox.textbox_root.textbox
    searchbox.textbox:SetTextLengthLimit(200)
    searchbox.textbox:SetForceEdit(true)
    searchbox.textbox:EnableWordWrap(false)
    searchbox.textbox:EnableScrollEditWindow(true)
    searchbox.textbox:SetHelpTextEdit("")
    searchbox.textbox:SetHelpTextApply(STRINGS.UI.SERVERCREATIONSCREEN.SEARCH)
    searchbox.textbox:SetTextPrompt(STRINGS.UI.SERVERCREATIONSCREEN.SEARCH, UICOLOURS.GREY)
    searchbox.textbox.prompt:SetHAlign(ANCHOR_MIDDLE)
    searchbox.textbox.OnTextInputted = function(keydown)
		if keydown then
			self:SelectSideButton()
			self:SetSearchText(self.searchbox.textbox:GetString())
		end
    end

     -- If searchbox ends up focused, highlight the textbox so we can tell something is focused.
    searchbox:SetOnGainFocus( function() searchbox.textbox:OnGainFocus() end )
    searchbox:SetOnLoseFocus( function() searchbox.textbox:OnLoseFocus() end )

    searchbox.focus_forward = searchbox.textbox

    return searchbox
end

function ScrapbookScreen:CollectType(set, filter)
	local newset = {}
	local blankset = {}
	local blank = {type=UNKNOWN, name=FILLER}
	for i,data in pairs(set)do
		if not filter or data.type == filter then
			local ok = false
			if self.menubuttons then
				for i, button in ipairs (self.menubuttons) do
					if button.filter == data.type then
						ok = true
						break
					end
				end
			else
				ok = true
			end

			if data.knownlevel > 0 and ok then
				table.insert(newset,deepcopy(data))
			elseif ok then
				table.insert(blankset,deepcopy(blank))
			end
		end
	end

	for i,blank in ipairs(blankset)do
		table.insert(newset,blank)
	end
	return newset
end

function ScrapbookScreen:updatemenubuttonflashes()

	for i,button in ipairs(self.menubuttons)do
		button.flash:Hide()
	end
	local noflash = true
	for prefab,data in pairs(dataset)do
		if not TheScrapbookPartitions:WasViewedInScrapbook(prefab) and data.knownlevel > 0 then
			for i,button in ipairs(self.menubuttons)do
				if button.filter == dataset[prefab].type then
					button.flash:Show()
					noflash = false
				end
			end
		end
 	end

 	self.flashestoclear = true
 	if noflash then
 		self.flashestoclear = nil
 	end

 	if self.clearflash then
		self.clearflash:Show()
	 	if noflash then
			self.clearflash:Hide()
	 	end
 	end
end

function ScrapbookScreen:SetGrid()
	if self.item_grid then
		self.gridroot:KillAllChildren()
	end
	self.item_grid = nil
	self.item_grid = self.gridroot:AddChild( self:BuildItemGrid(self.columns_setting) )
	self.item_grid:SetPosition(0, 0)
	local griddata = deepcopy(self.current_view_data)

	local setfocus = true
	if #griddata <= 0 then
		setfocus = false

		for i=1,self.columns_setting do
			table.insert(griddata,{name=FILLER})
		end
	end

	if #griddata%self.columns_setting > 0 then
		for i=1,self.columns_setting -(#self.current_view_data%self.columns_setting) do
			table.insert(griddata,{name=FILLER})
		end
	end

	self.item_grid:SetItemsData( griddata )
	local grid_w, grid_h = self.item_grid:GetScrollRegionSize()

	self:updatemenubuttonflashes()
	self:DoFocusHookups()
	self.focus_forward = self.item_grid

	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/scrapbook_pageflip")

	if TheInput:ControllerAttached() then
		if setfocus and not self.searchbox.focus then
			self:SetFocus()
		else
			self.searchbox:SetFocus()
		end
	end
end

function ScrapbookScreen:SelectMenuItem(dir)
	local cat = "creature"
	if self.menubuttons_selected then
		local selected = nil
		for i,button in ipairs(self.menubuttons) do
			if button.filter ==  self.menubuttons_selected then
				selected = i
			end
		end
		if dir == "down" then
			if selected == #self.menubuttons then
				selected = 1
			else
				selected = selected +1
			end
		else
			if selected == 1 then
				selected = #self.menubuttons
			else
				selected = selected -1
			end
		end
		cat = self.menubuttons[selected].filter
	end

	self:SelectSideButton(cat)
	self.current_dataset = self:CollectType(dataset,cat)
	self.current_view_data = self:CollectType(dataset,cat)
	self:SetGrid()
end

function ScrapbookScreen:SelectSideButton(category)
	self.last_filter = self.menubuttons_selected or self.last_filter -- No nil value!
	self.menubuttons_selected = category

	for i, button in ipairs(self.menubuttons) do
		if button.filter == category then
			button.selectimg:Show()
		else
			button.selectimg:Hide()
		end

	end
end

function ScrapbookScreen:MakeSideBar()

	self.menubuttons = {}
	local colors = {
		{114/255,56/255,56/255},
		{111/255,85/255,47/255},
		{137/255,126/255,89/255},
		--{195/255,179/255,109/255},
		{95/255,123/255,87/255},
		{113/255,127/255,126/255},
		{74/255,84/255,99/255},
		{79/255,73/255,107/255},
	}

	local buttons = {
		{name="Creatures", filter="creature"},
		{name="Giants", filter="giant"},
		{name="Items", filter="item"},
		{name="Food", filter="food"},
		{name="Things", filter="thing"},
		{name="POI", filter="POI"},
		{name="Biomes", filter="biome"},
		{name="Seasons", filter="season"},
	}

	for i, button in ipairs(buttons)do
		local idx = i % #colors
		if idx == 0 then idx = #colors end
		button.color = colors[idx]
	end

	for t=#buttons,1,-1 do
		local ok =false
		for i,cat in ipairs(SCRAPBOOK_CATS)do
			if buttons[t].filter == cat then
				ok = true
				break
			end
		end
		if not ok then
			table.remove(buttons,t)
		end
	end

	local buttonwidth = 252/2.2--75
	local buttonheight = 112/2.2--30

	-- PANEL_HEIGHT

	local totalheight = PANEL_HEIGHT - 100

	local MakeButton = function(idx,data)

		local y = totalheight/2 - ((totalheight/7) * idx-1) + 50

		local buttonwidget = self.root:AddChild(Widget())

		local button = buttonwidget:AddChild(ImageButton("images/scrapbook.xml", "tab.tex"))
		button:ForceImageSize(buttonwidth,buttonheight)
		button.scale_on_focus = false
		button.basecolor = {data.color[1],data.color[2],data.color[3]}
		button:SetImageFocusColour(math.min(1,data.color[1]*1.2),math.min(1,data.color[2]*1.2),math.min(1,data.color[3]*1.2),1)
		button:SetImageNormalColour(data.color[1],data.color[2],data.color[3],1)
		button:SetImageSelectedColour(data.color[1],data.color[2],data.color[3],1)
		button:SetImageDisabledColour(data.color[1],data.color[2],data.color[3],1)
		button:SetOnClick(function()
				self:SelectSideButton(data.filter)
				self.current_dataset = self:CollectType(dataset,data.filter)
				self.current_view_data = self:CollectType(dataset,data.filter)
				self:SetGrid()
			end)

		buttonwidget.focusimg = button:AddChild(Image("images/scrapbook.xml", "tab_over.tex"))
		buttonwidget.focusimg:ScaleToSize(buttonwidth,buttonheight)
		buttonwidget.focusimg:SetClickable(false)
		buttonwidget.focusimg:Hide()

		buttonwidget.selectimg = button:AddChild(Image("images/scrapbook.xml", "tab_selected.tex"))
		buttonwidget.selectimg:ScaleToSize(buttonwidth,buttonheight)
		buttonwidget.selectimg:SetClickable(false)
		buttonwidget.selectimg:Hide()

		buttonwidget:SetOnGainFocus(function()
			buttonwidget.focusimg:Show()
		end)
		buttonwidget:SetOnLoseFocus(function()
			buttonwidget.focusimg:Hide()
		end)

		local text = button:AddChild(Text(HEADERFONT, 12, STRINGS.SCRAPBOOK.CATS[string.upper(data.name)] , UICOLOURS.WHITE))
		text:SetPosition(10,-8)
		buttonwidget:SetPosition(522+buttonwidth/2, y)

		local total = 0
		local count = 0
		for i,set in pairs(dataset)do
			if set.type == data.filter then
				total = total +1
				if set.knownlevel > 0 then
					count = count+1
				end
			end
		end
		if total > 0 then

 			local percent = (count/total)*100
			if percent < 1 then
				percent = math.floor(percent*100)/100
			else
				percent = math.floor(percent)
			end

			local progress = buttonwidget:AddChild(Text(HEADERFONT, 18, percent.."%" , UICOLOURS.GOLD))
			progress:SetPosition(15,17)
		end

		buttonwidget.newcreatures = {}

		buttonwidget.flash = buttonwidget:AddChild(UIAnim())
		buttonwidget.flash:GetAnimState():SetBank("cookbook_newrecipe")
		buttonwidget.flash:GetAnimState():SetBuild("cookbook_newrecipe")
		buttonwidget.flash:GetAnimState():PlayAnimation("anim", true)
		buttonwidget.flash:GetAnimState():SetDeltaTimeMultiplier(1.25)
		buttonwidget.flash:SetScale(.8, .8, .8)
		buttonwidget.flash:SetPosition(40, 0, 0)
		buttonwidget.flash:Hide()
		buttonwidget.flash:SetClickable(false)

		buttonwidget.filter = data.filter
		buttonwidget.focus_forward = button

		table.insert(self.menubuttons,buttonwidget)
	end

	for i,data in ipairs(buttons)do
		MakeButton(i,data)
	end
end

function ScrapbookScreen:updatemenubuttonnewitem(data, setting)
	local buttontype = data.type
	for i, button in ipairs(self.menubuttons)do
		if button.filter == buttontype then
			button.newcreatures[data.prefab] = setting

			button.flash:Hide()

			for prefab,bool in pairs(button.newcreatures)do
				if bool == true then
					button.flash:Show()
					break
				end
			end
			break
		end
	end
end

function ScrapbookScreen:ClearFlashes()
	for prefab,data in pairs(dataset)do
        if TheScrapbookPartitions:GetLevelFor(prefab) > 0 then
		    TheScrapbookPartitions:SetViewedInScrapbook(prefab)
        end
	end
	self:SetGrid()
end

function ScrapbookScreen:MakeBottomBar()
	if not TheInput:ControllerAttached() then
		self.clearflash = self.root:AddChild(ImageButton("images/global_redux.xml", "button_carny_long_normal.tex", "button_carny_long_hover.tex", "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
		self.clearflash.image:SetScale(.6)
		self.clearflash:SetFont(HEADERFONT)
		self.clearflash:SetText(STRINGS.SCRAPBOOK.CLEARFLASH)
		self.clearflash.text:SetColour(0,0,0,1)
		self.clearflash:SetPosition(220+(SEARCH_BOX_WIDTH/2)+28+28, -PANEL_HEIGHT/2 -38)
		self.clearflash:SetTextSize(16)
		self.clearflash:SetOnClick(function()
				self:ClearFlashes()
			end)
	end
end



function ScrapbookScreen:MakeTopBar()
	self.search_text = ""

	self.searchbox = self.root:AddChild(self:MakeSearchBox(300, SEARCH_BOX_HEIGHT))
	self.searchbox:SetPosition(220, PANEL_HEIGHT/2 +33)

	self.display_col_1_button = self.root:AddChild(ImageButton("images/scrapbook.xml", "sort1.tex"))
	self.display_col_1_button:SetPosition(220+(SEARCH_BOX_WIDTH/2)+28, PANEL_HEIGHT/2 +33)
	self.display_col_1_button:ForceImageSize(25,25)
	self.display_col_1_button.scale_on_focus = false
	self.display_col_1_button.focus_scale = {1.1,1.1,1.1}
	self.display_col_1_button.ignore_standard_scaling = true
	self.display_col_1_button:SetOnClick(function()
		if self.columns_setting ~= 1 then
			self.columns_setting = 1
			self:SetGrid()

			Profile:SetScrapbookColumnsSetting(self.columns_setting)
		end
	end)

	self.display_col_2_button = self.root:AddChild(ImageButton("images/scrapbook.xml", "sort2.tex"))
	self.display_col_2_button:SetPosition(220+(SEARCH_BOX_WIDTH/2)+28+28, PANEL_HEIGHT/2 +33)
	self.display_col_2_button:ForceImageSize(25,25)
	self.display_col_2_button.scale_on_focus = false
	self.display_col_2_button.focus_scale = {1.1,1.1,1.1}
	self.display_col_2_button.ignore_standard_scaling = true
	self.display_col_2_button:SetOnClick(function()
		if self.columns_setting ~= 2 then
			self.columns_setting = 2
			self:SetGrid()

			Profile:SetScrapbookColumnsSetting(self.columns_setting)
		end
	end)

	self.display_col_3_button = self.root:AddChild(ImageButton("images/scrapbook.xml", "sort3.tex"))
	self.display_col_3_button:SetPosition(220+(SEARCH_BOX_WIDTH/2)+28+28+28, PANEL_HEIGHT/2 +33)
	self.display_col_3_button:ForceImageSize(25,25)
	self.display_col_3_button.scale_on_focus = false
	self.display_col_3_button.focus_scale = {1.1,1.1,1.1}
	self.display_col_3_button.ignore_standard_scaling = true
	self.display_col_3_button:SetOnClick(function()
		if self.columns_setting ~= 3 then
			self.columns_setting = 3
			self:SetGrid()

			Profile:SetScrapbookColumnsSetting(self.columns_setting)
		end
	end)

	self.display_col_grid_button = self.root:AddChild(ImageButton("images/scrapbook.xml", "sort4.tex"))
	self.display_col_grid_button:SetPosition(220+(SEARCH_BOX_WIDTH/2)+28+28+28+28, PANEL_HEIGHT/2 +33)
	self.display_col_grid_button:ForceImageSize(25,25)
	self.display_col_grid_button.scale_on_focus = false
	self.display_col_grid_button.focus_scale = {1.1,1.1,1.1}
	self.display_col_grid_button.ignore_standard_scaling = true
	self.display_col_grid_button:SetOnClick(function()
		if self.columns_setting ~= 7 then
			self.columns_setting = 7
			self:SetGrid()

			Profile:SetScrapbookColumnsSetting(self.columns_setting)
		end
	end)

	self.topbuttons = {}
	table.insert(self.topbuttons, self.searchbox)
	table.insert(self.topbuttons, self.display_col_1_button)
	table.insert(self.topbuttons, self.display_col_2_button)
	table.insert(self.topbuttons, self.display_col_3_button)
	table.insert(self.topbuttons, self.display_col_grid_button)
end

function ScrapbookScreen:MakeBackButton()
	self.cancel_button = self.root:AddChild(TEMPLATES.BackButton(
		function()
			self:Close() --go back
		end))
end

function ScrapbookScreen:Close(fn)
    TheFrontEnd:FadeBack(nil, nil, fn)
end

function ScrapbookScreen:GetData(name)
	if dataset[name] then
		return dataset[name]
	end
end

function ScrapbookScreen:BuildItemGrid()
	self.MISSING_STRINGS = {}
	local totalwidth = 465
	local columns = self.columns_setting
	local imagesize = 32
	local bigimagesize = 64
	local imagebuffer = 6
	local row_w = totalwidth/columns

	if columns > 3 then
 		imagesize = bigimagesize
 		imagebuffer = 12
 		row_w = imagesize
	end

	local row_h = imagesize

    local row_spacing = 5
    local bg_padding = 3
    local name_pos = -5
    local catname_pos = 8

	table.sort(self.current_view_data, function(a, b)
		local a_name = STRINGS.NAMES[string.upper(a.name)] or FILLER
		local b_name = STRINGS.NAMES[string.upper(b.name)] or FILLER
		if a.subcat then a_name = STRINGS.SCRAPBOOK.SUBCATS[string.upper(a.subcat)] .. a_name end
		if b.subcat then b_name = STRINGS.SCRAPBOOK.SUBCATS[string.upper(b.subcat)] .. b_name end

		if not a_name or not b_name then
			return false
		end

		if a_name == b_name and a.entry and b.entry then
			return a.entry < b.entry
		end

		return a_name < b_name
	end)

	for i, data in ipairs(self.current_view_data) do
		data.index = i
	end

    local function ScrollWidgetsCtor(context, index)
        local w = Widget("recipe-cell-".. index)

		----------------
		w.item_root = w:AddChild(Widget("item_root"))

		w.item_root.bg = w.item_root:AddChild(Image("images/global.xml", "square.tex"))
		w.item_root.bg:ScaleToSize(totalwidth+((row_spacing+bg_padding)*columns), row_h+bg_padding)
		w.item_root.bg:SetPosition(-(((columns-1)*.5) * row_w),0)
		w.item_root.bg:SetTint(1,1,1,0.1)

		w.item_root.button = w.item_root:AddChild(ImageButton("images/global.xml", "square.tex"))
		w.item_root.button:SetImageNormalColour(1,1,1,0)
		w.item_root.button:SetImageFocusColour(1,1,1,0.3)
		w.item_root.button.scale_on_focus = false
		w.item_root.button.clickoffset = Vector3(0, 0, 0)
		w.item_root.button:ForceImageSize(row_w+bg_padding, row_h+bg_padding)

		w.item_root.image = w.item_root:AddChild(Image(GetScrapbookIconAtlas("cactus.tex"), "cactus.tex"))
		w.item_root.image:ScaleToSize(imagesize, imagesize)
		w.item_root.image:SetPosition((-row_w/2)+imagesize/2,0 )
		w.item_root.image:SetClickable(false)

		w.item_root.inv_image = w.item_root:AddChild(Image(GetScrapbookIconAtlas("cactus.tex"), "cactus.tex"))
		w.item_root.inv_image:ScaleToSize(imagesize-imagebuffer, imagesize-imagebuffer)
		w.item_root.inv_image:SetPosition((-row_w/2)+imagesize/2,0 )
		w.item_root.inv_image:SetClickable(false)
		w.item_root.inv_image:Hide()

		w.item_root.name = w.item_root:AddChild(Text(HEADERFONT, 18, "NAME OF CRITTER", UICOLOURS.WHITE))
		w.item_root.name:SetPosition((-row_w/2)+imagesize + 5 ,name_pos)

		w.item_root.catname = w.item_root:AddChild(Text(HEADERFONT, 10, "NAME OF CRITTER", UICOLOURS.GOLD))
		w.item_root.catname:SetPosition((-row_w/2)+imagesize + 5 ,catname_pos)

		w.item_root.flash =w.item_root:AddChild(UIAnim())
		w.item_root.flash:GetAnimState():SetBank("cookbook_newrecipe")
		w.item_root.flash:GetAnimState():SetBuild("cookbook_newrecipe")
		w.item_root.flash:GetAnimState():PlayAnimation("anim", true)
		w.item_root.flash:GetAnimState():PlayAnimation("anim", true)
		w.item_root.flash:GetAnimState():SetDeltaTimeMultiplier(1.25)
		w.item_root.flash:SetScale(.5, .5, .5)
		w.item_root.flash:SetPosition((-row_w/2)+imagesize-(imagesize*0.1), (-row_h/2)+imagesize-(imagesize*0.1))
		w.item_root.flash:Hide()
		w.item_root.flash:SetClickable(false)

		w.item_root.button:SetOnClick(function()

			if ThePlayer and ThePlayer.scrapbook_seen then
				if ThePlayer.scrapbook_seen[w.data.prefab] then
					ThePlayer.scrapbook_seen[w.data.prefab] = nil
					w.item_root.flash:Hide()
				end
			end

			self:updatemenubuttonflashes()

			if self.details.entry ~= w.data.entry then
				self.detailsroot:KillAllChildren()
				self.details = nil
				self.details = self.detailsroot:AddChild(self:PopulateInfoPanel(w.data.entry))
				self:DoFocusHookups()
			end
		end)


		w.item_root.ongainfocusfn = function()
			self.lastselecteditem = w.item_root.button
		end

		w.focus_forward = w.item_root.button

		w.item_root.button:SetOnGainFocus(function()
			self.item_grid:OnWidgetFocus(w)
		end)

		----------------
		return w
    end

    local function ScrollWidgetSetData(context, widget, data, index)
		widget.item_root.image:SetTint(1,1,1,1)
		widget.item_root.inv_image:SetTint(1,1,1,1)
		widget.item_root.flash:Hide()

		widget.data = data

		if data ~= nil and data.name ~= FILLER and data.type ~= UNKNOWN then
			widget.item_root.image:Show()
			widget.item_root.button:Show()
			if not widget.item_root.button:IsEnabled() then
				widget.item_root.button:Enable()
			end

			if columns <= 3 then
				widget.item_root.name:Show()
			else
				widget.item_root.name:Hide()
			end
			widget.item_root.catname:Hide()
			widget.item_root.inv_image:Hide()

			if data.type == "item" or data.type == "food" then
				widget.item_root.image:SetTexture("images/scrapbook.xml", "inv_item_background.tex")
				widget.item_root.image:ScaleToSize(imagesize, imagesize)
				widget.item_root.inv_image:Show()
				widget.item_root.inv_image:SetTexture(GetInventoryItemAtlas(data.tex), data.tex)
				widget.item_root.inv_image:ScaleToSize(imagesize-imagebuffer, imagesize-imagebuffer)
			else
				widget.item_root.image:SetTexture(GetScrapbookIconAtlas(data.tex) or GetScrapbookIconAtlas("cactus.tex"), data.tex or "cactus.tex")
			end

			if data.knownlevel == 1 then
				widget.item_root.inv_image:SetTint(unpack(UK_TINT))
				widget.item_root.image:SetTint(unpack(UK_TINT))
			end

			if columns <= 3 then
				local name = STRINGS.NAMES[string.upper(data.name)]
				local maxwidth = row_w - imagesize - 15

				--maxcharsperline, ellipses, shrink_to_fit, min_shrink_font_size, linebreak_string)
				widget.item_root.name:SetTruncatedString(name, maxwidth, nil, true)
				local tw, th = widget.item_root.name:GetRegionSize()
				widget.item_root.name:SetPosition((-row_w/2)+imagesize + 5 +(tw/2) ,name_pos)

				if data.subcat  then
					widget.item_root.catname:Show()
					local subcat = STRINGS.SCRAPBOOK.SUBCATS[string.upper(data.subcat)]
					widget.item_root.catname:SetTruncatedString(subcat.."/", maxwidth, nil, true)
					local tw, th = widget.item_root.catname:GetRegionSize()
					widget.item_root.catname:SetPosition((-row_w/2)+imagesize + 5 +(tw/2) ,catname_pos)
				end
			end

			widget.item_root.button:SetOnClick(function()
				widget.item_root.flash:Hide()
				self:updatemenubuttonflashes()

				if self.details.entry ~= widget.data.entry then
					self.detailsroot:KillAllChildren()
					self.details = nil
					self.details = self.detailsroot:AddChild(self:PopulateInfoPanel(widget.data.entry))
					self:DoFocusHookups()
					TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/scrapbook_pageflip")
				end
			end)
		else
			if data and data.type == UNKNOWN then
				widget.item_root.image:SetTexture(GetScrapbookIconAtlas("unknown.tex"), "unknown.tex")
				widget.item_root.image:Show()
				widget.item_root.button:Show()
				widget.item_root.image:SetTint(1,1,1,1)
				widget.item_root.flash:Hide()
				widget.item_root.image:ScaleToSize(imagesize, imagesize)
			else
				widget.item_root.image:Hide()

				if not TheInput:ControllerAttached() then
					widget.item_root.button:Hide()
				end
			end

			widget.item_root.button:SetOnClick(function()
			end)

			widget.item_root.name:Hide()
			widget.item_root.catname:Hide()
			widget.item_root.inv_image:Hide()
		end

		if data and data.name ~= FILLER and data.type ~= UNKNOWN then
			if not TheScrapbookPartitions:WasViewedInScrapbook(data.prefab) then
				widget.item_root.flash:Show()
			else
				widget.item_root.flash:Hide()
			end
		end

		if columns > 3 then
			widget.item_root.bg:Hide()
		else
			if index % (columns *2) ~= 0 then
				widget.item_root.bg:Hide()
			else
				widget.item_root.bg:Show()
			end
		end

    end

    local grid = TEMPLATES.ScrollingGrid(
        {},
        {
            context = {},
            widget_width  = row_w+row_spacing,
            widget_height = row_h+row_spacing,
			force_peek    = true,
            num_visible_rows = imagesize == bigimagesize and 7 or 13,
            num_columns      = columns,
            item_ctor_fn = ScrollWidgetsCtor,
            apply_fn     = ScrollWidgetSetData,
            scrollbar_offset = 20,
            scrollbar_height_offset = -60
        })

    return grid
end

function calculteRotatedHeight(angle,w,h)
	return math.sin(angle*DEGREES)*w  +  math.sin((90-angle)*DEGREES)*h
end

function calculteRotatedWidth(angle,w,h)
	return math.cos(angle*DEGREES)*w  +  math.cos((90-angle)*DEGREES)*h
end

function ScrapbookScreen:PopulateInfoPanel(entry)
	local data = self:GetData(entry)

	primeRand(hash((data and data.name or "")..ThePlayer.userid))

    local page = Widget("page")
    if data then TheScrapbookPartitions:SetViewedInScrapbook(data.prefab) end
	self:updatemenubuttonflashes()

	page.entry = entry

    page:SetPosition(-PANEL_WIDTH/4 - 20,0)

    local sub_root = Widget("text_root")

	local width = PANEL_WIDTH/2-40

	local left = 0
	local height = 0
	local title_space = 5
	local section_space = 22

	local applytexturesize = function(widget,w,h, tex, source)
		local suffix = "_square"
		local ratio = w/h
		if ratio > 5 then
			suffix = "_thin"
		elseif ratio > 1 then
			suffix = "_wide"
		elseif ratio < 0.75 then
			suffix = "_tall"
		end

		local materials = {
			"scrap",
			"scrap2",
		}
		if not tex then
			tex = materials[math.ceil(rand()*#materials)]..suffix.. ".tex"
		end
		if not source then
			source = "images/scrapbook.xml"
		end

		widget:SetTexture(source, tex, tex)
		widget:ScaleToSize(w,h)
	end

	local setattachmentdetils = function (widget,w,h, shortblock)
		local choice = rand()

		if choice < 0.4 and not shortblock then
			-- picture tabs
			local mat = "corner.tex"
			if rand() < 0.5 then
				mat = "corner2.tex"
			end
			local tape1 = widget:AddChild(Image("images/scrapbook.xml", mat))
			tape1:SetScale(0.5)
			tape1:SetClickable(false)
			tape1:SetPosition(-w/2+15,-h/2+15)
			tape1:SetRotation(0)

			local tape2 = widget:AddChild(Image("images/scrapbook.xml", mat))
			tape2:SetScale(0.5)
			tape2:SetClickable(false)
			tape2:SetPosition(-w/2+15,h/2-15)
			tape2:SetRotation(90)

			local tape3 = widget:AddChild(Image("images/scrapbook.xml", mat))
			tape3:SetScale(0.5)
			tape3:SetClickable(false)
			tape3:SetPosition(w/2-15,h/2-15)
			tape3:SetRotation(180)

			local tape4 = widget:AddChild(Image("images/scrapbook.xml", mat))
			tape4:SetScale(0.5)
			tape4:SetClickable(false)
			tape4:SetPosition(w/2-15,-h/2+15)
			tape4:SetRotation(270)
		elseif choice < 0.7 then
			local tape1 = widget:AddChild(Image("images/scrapbook.xml", "tape".. math.ceil(rand()*2).."_centre.tex"))
			tape1:SetScale(0.5)
			tape1:SetClickable(false)
			tape1:SetPosition(0,h/2)
			tape1:SetRotation(rand()*3- 1.5)
		elseif choice < 0.8 then
			--tape
			local diagonal = false
			local right = true
			if shortblock then
				if rand()<0.3 then
					diagonal = true
					if rand()<0.5 then
						right = false
					end
				end
			end
			if (rand() < 0.5 and not shortblock) or (diagonal==true and right==false) then
				local tape1 = widget:AddChild(Image("images/scrapbook.xml", "tape".. math.ceil(rand()*2).."_corner.tex"))
				tape1:SetScale(0.5)
				tape1:SetClickable(false)
				tape1:SetPosition(-w/2+5,-h/2+5)
				local rotation = -45
				tape1:SetRotation(rotation)
			end

			if not diagonal or right then
				local tape2 = widget:AddChild(Image("images/scrapbook.xml", "tape".. math.ceil(rand()*2).."_corner.tex"))
				tape2:SetScale(0.5)
				tape2:SetClickable(false)
				tape2:SetPosition(-w/2+5,h/2-5)
				local rotation = 45
				tape2:SetRotation(rotation)
			end

			if not diagonal or right == false then
				local tape3 = widget:AddChild(Image("images/scrapbook.xml", "tape".. math.ceil(rand()*2).."_corner.tex"))
				tape3:SetScale(0.5)
				tape3:SetClickable(false)
				tape3:SetPosition(w/2-5,h/2-5)
				local rotation = 90 +45
				tape3:SetRotation(rotation)
			end

			if (rand() < 0.5 and not shortblock) or (diagonal==true and right==true) then
				local tape4 = widget:AddChild(Image("images/scrapbook.xml", "tape".. math.ceil(rand()*2).."_corner.tex"))
				tape4:SetScale(0.5)
				tape4:SetClickable(false)
				tape4:SetPosition(w/2-5,-h/2+5)
				local rotation = -90 - 45
				tape4:SetRotation(rotation)
			end
		else
			local ropechoice = math.ceil(rand()*3)
			local rope = widget:AddChild(Image("images/scrapbook.xml", "rope".. ropechoice.."_corner.tex"))
			rope:SetScale(0.5)
			rope:SetClickable(false)
			if ropechoice == 1 then
				rope:SetPosition(-w/2+5,h/2-10)
			elseif ropechoice == 3 then
				rope:SetPosition(-w/2+5,h/2-13)
			else
				rope:SetPosition(-w/2+13,h/2-16)
			end
		end
	end

	local settextblock = function (height, data) -- font, size, str, color,leftmargin,rightmargin, leftoffset, ignoreheightchange, widget
		assert(data.font and data.size and data.str and data.color, "Missing String Data")
		local targetwidget = data.widget and data.widget or sub_root
		local txt = targetwidget:AddChild(Text(data.font, data.size, data.str, data.color))
		txt:SetHAlign(ANCHOR_LEFT)
		txt:SetVAlign(ANCHOR_TOP)
		local subwidth = data.width or width
		local adjustedwidth = subwidth - (data.leftmargin and data.leftmargin or 0) - (data.rightmargin and data.rightmargin or 0)
		txt:SetMultilineTruncatedString(data.str, 100, adjustedwidth)
		local x, y = txt:GetRegionSize()
		local adjustedleft = left + (data.leftmargin and data.leftmargin or 0) + (data.leftoffset and data.leftoffset or 0)
		txt:SetPosition(adjustedleft + (0.5 * x) , height - (0.5 * y))
		if not data.ignoreheightchange then
			height = height - y - section_space
		end

		return height, txt
	end

	local setimageblock = function(height, data) -- source, tex, w,h,rotation,leftoffset, ignoreheightchange, widget)
		assert(data.source and data.tex, "Missing Image Data")
		local targetwidget = data.widget and data.widget or sub_root
		local img = targetwidget:AddChild(Image(data.source, data.tex))
		if data.w and data.h then
			applytexturesize(img,w,h, data.source, data.tex)
		end
		if data.rotation then
			img:SetRotation(data.rotation)
		end
		local x, y = img:GetSize()
		local truewidth = calculteRotatedWidth(data.rotation and data.rotation or 0,x,y)
		local trueheight = calculteRotatedHeight(data.rotation and data.rotation or 0,x,y)
		local adjustedoffset = data.leftoffset and data.leftoffset or  0
		img:SetPosition(left + truewidth + adjustedoffset, height - (0.5 * trueheight))
		img:SetClickable(false)
		if not data.ignoreheightchange then
			height = height - trueheight - section_space
		end

		return height, img
	end

	local setcustomblock = function(height,data)
		local panel = sub_root:AddChild(Widget("custompanel"))
		local bg
		height, bg = setimageblock(height,{ignoreheightchange=true, widget=panel, source="images/scrapbook.xml", tex="scrap_square.tex"})

		local shade = 0.8 + rand()*0.2
		bg:SetTint(shade,shade,shade,1)

		local MARGIN = data.margin and data.margin or 15
		local textblock
		height, textblock = settextblock(height, {str=data.str, width=data.width or nil, font=data.font or CHATFONT, size=data.size or 15, color=data.fontcolor or UICOLOURS.BLACK, leftmargin=MARGIN+50, rightmargin=MARGIN+50, leftoffset = -width/2, ignoreheightchange=true, widget=panel})
		local pos_t = textblock:GetPosition()
		textblock:SetPosition(0,0)

		local w,h= textblock:GetRegionSize()
		local boxwidth = w+(MARGIN*2)
		local widthdiff = 0
		if data.minwidth and boxwidth < data.minwidth then
			widthdiff = data.minwidth - boxwidth
			boxwidth = data.minwidth
		end

		applytexturesize(bg, boxwidth,h+(MARGIN*2))

		local angle =  data.norotation and 0 or rand()*3- 1.5
 		panel:SetRotation(angle)

		pos_t = textblock:GetPosition()
		bg:SetPosition(0,0)

 		local attachments = panel:AddChild(Widget("attachments"))
 		attachments:SetPosition(0,0)
 		setattachmentdetils(attachments, boxwidth,h+(MARGIN*2), data.shortblock)
 		local newheight = calculteRotatedHeight(angle,boxwidth,h+(MARGIN*2))
 		--
		panel:SetPosition( boxwidth/2 + (data.leftoffset or 0) ,height - (newheight/2) - (data.topoffset or 0))
		if not data.ignoreheightchange then
			height = height - newheight - section_space
		end
 		return height, panel, newheight
	end
	---------------------------------
	-- set the title
	local cattitle
	if data and data.subcat then
		local subcat = STRINGS.SCRAPBOOK.SUBCATS[string.upper(data.subcat)]
		height, cattitle = settextblock(height, {font=HEADERFONT, size=25, str= subcat.."/  ", color=UICOLOURS.GOLD,  ignoreheightchange=true})
	end

	local title
	local leftoffset = 0
	if cattitle then
		leftoffset = cattitle:GetRegionSize()
	end

	local name = data ~= nil and STRINGS.NAMES[string.upper(data.name)] or ""

	height, title = settextblock(height, {font=HEADERFONT, size=25, str=name, color=UICOLOURS.WHITE, leftoffset=leftoffset})

	------------------------------------

	height = height  - 10

	-- set the photo
	local rotation = (rand() * 5)-2.5

	--------------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------

	local CUSTOM_SIZE = Vector3(150,250,0)
	local CUSTOM_ANIMOFFSET = Vector3(0,-40,0)
	local CUSTOM_INDENT = 40 + (rand() * 25)

	local STAT_PANEL_WIDTH = 220
	local STAT_PANEL_INDENT = 30
	local STAT_GAP_SMALL = 5
	local STAT_ICONSIZE = 32

	local stats,statsheight

	local statwidget = 	sub_root:AddChild(Widget("statswidget"))
	local statbg = statwidget:AddChild(Image("images/fepanel_fills.xml", "panel_fill_large.tex"))
	local statsheight = 0
	statsheight = statsheight - STAT_PANEL_INDENT

	local showstats = false
	local makeentry = function(tex,text)
		showstats = true
		if tex then
			local icon = statwidget:AddChild(Image(GetScrapbookIconAtlas(tex) or GetScrapbookIconAtlas("cactus.tex"), tex))
			icon:ScaleToSize(STAT_ICONSIZE,STAT_ICONSIZE)
			icon:SetPosition(STAT_PANEL_INDENT+(STAT_ICONSIZE/2), statsheight-STAT_ICONSIZE/2)
		end
		local txt = statwidget:AddChild(Text(HEADERFONT, 18, text, UICOLOURS.BLACK))
		local tw, th = txt:GetRegionSize()
		txt:SetPosition(STAT_PANEL_INDENT+STAT_ICONSIZE + STAT_GAP_SMALL + (tw/2), statsheight-(STAT_ICONSIZE/2)-2)
		txt:SetHAlign(ANCHOR_LEFT)
		statsheight = statsheight - STAT_ICONSIZE - STAT_GAP_SMALL
	end
	local makesubentry = function(text)
		showstats = true
		local txt = statwidget:AddChild(Text(HEADERFONT, 12, text, UICOLOURS.BLACK))
		local tw, th = txt:GetRegionSize()
		txt:SetPosition(STAT_PANEL_INDENT+STAT_ICONSIZE + STAT_GAP_SMALL + (tw/2), statsheight+STAT_GAP_SMALL)
		statsheight = statsheight - STAT_GAP_SMALL
	end

	local makesubiconentry = function(tex,subwidth,text)
		showstats = true
		local icon = statwidget:AddChild(Image(GetScrapbookIconAtlas(tex) or GetScrapbookIconAtlas("cactus.tex"), tex))
		icon:ScaleToSize(STAT_ICONSIZE,STAT_ICONSIZE)
		icon:SetPosition(STAT_PANEL_INDENT+ subwidth +(STAT_ICONSIZE/2), statsheight+STAT_GAP_SMALL+(STAT_ICONSIZE/2) )
		local txt = statwidget:AddChild(Text(HEADERFONT, 18, text, UICOLOURS.BLACK))
		local tw, th = txt:GetRegionSize()
		txt:SetPosition(STAT_PANEL_INDENT+ subwidth +STAT_ICONSIZE + (tw/2), statsheight+STAT_GAP_SMALL+(STAT_ICONSIZE/2)-2)		--+ STAT_GAP_SMALL
		subwidth = subwidth + STAT_ICONSIZE+ tw
		return subwidth
	end

	local makelistentry = function(textures, texts, iconsize, maxgap)
		local x = 75
		local addedtext = false

		statsheight = statsheight - 5

		for i, iconname in ipairs(textures) do
			local tex = iconname .. ".tex"
			local icon = statwidget:AddChild(Image(GetScrapbookIconAtlas(tex) or GetInventoryItemAtlas(tex), tex))
			icon:ScaleToSize(iconsize, iconsize)
			icon:SetPosition(x, statsheight)

			if texts ~= nil and texts[i] ~= nil then
				addedtext = true

				local txt = statwidget:AddChild(Text(HEADERFONT, 13, texts[i], UICOLOURS.BLACK))
				txt:SetPosition(x, statsheight - iconsize)
			end

			x =  x + math.min((140/#textures), maxgap or math.huge)
		end

		statsheight = statsheight - iconsize - STAT_GAP_SMALL * (addedtext and 3 or 0)
	end

	---------------------------------------------
	if data then

		if data.health then
			makeentry("icon_health.tex", tostring(checknumber(data.health) and math.floor(data.health) or data.health))
		end

		if data.damage then
			makeentry("icon_damage.tex", tostring(checknumber(data.damage) and math.floor(data.damage) or data.damage))
			if data.planardamage then
				makesubentry("+"..math.floor(data.planardamage) .. STRINGS.SCRAPBOOK.DATA_PLANAR_DAMAGE)
			end
		end

		if data.sanityaura then
			local sanitystr = ""
			if data.sanityaura >= TUNING.SANITYAURA_HUGE then
				sanitystr = STRINGS.SCRAPBOOK.SANITYDESC.POSHIGH
			elseif data.sanityaura >= TUNING.SANITYAURA_MED then
				sanitystr = STRINGS.SCRAPBOOK.SANITYDESC.POSMED
			elseif data.sanityaura > 0 then
				sanitystr = STRINGS.SCRAPBOOK.SANITYDESC.POSSMALL
			elseif data.sanityaura == 0 then
				sanitystr = nil
			elseif data.sanityaura < 0 and data.sanityaura > -TUNING.SANITYAURA_MED then
				sanitystr = STRINGS.SCRAPBOOK.SANITYDESC.NEGSMALL
			elseif data.sanityaura > -TUNING.SANITYAURA_HUGE then
				sanitystr = STRINGS.SCRAPBOOK.SANITYDESC.NEGMED
			else
				sanitystr = STRINGS.SCRAPBOOK.SANITYDESC.NEGHIGH
			end
			if sanitystr then
				makeentry("icon_sanity.tex",sanitystr)
			end
		end

		if data.type == "item" or data.type == "food" then
			if data.stacksize then
				makeentry("icon_stack.tex",data.stacksize..STRINGS.SCRAPBOOK.DATA_STACK)
			end
		end

		local showfood = true
		if data.hungervalue and data.hungervalue == 0 and
			data.healthvalue and data.healthvalue == 0 and
			data.sanityvalue and data.sanityvalue == 0 then
			showfood = false
		end
--[[
		if data.foodtype == FOODTYPE.ELEMENTAL or data.foodtype == FOODTYPE.ROUGHAGE or data.foodtype == FOODTYPE.HORRIBLE then
			showfood = false
		end
]]
		if showfood and data.foodtype then
			local str = STRINGS.SCRAPBOOK.FOODTYPE[data.foodtype]
			makeentry("icon_food.tex",str)
			if not table.contains(FOODGROUP.OMNI.types, data.foodtype) then
				makesubentry(STRINGS.SCRAPBOOK.DATA_NON_PLAYER_FOOD)
				statsheight = statsheight - (STAT_GAP_SMALL * 2)
			end
		end

		if showfood and
			data.hungervalue ~= nil and
			data.healthvalue ~= nil and
			data.sanityvalue ~= nil
		then
			local icons = {
				"icon_hunger",
				"icon_health",
				"icon_sanity",
			}

			local texts = {
				(data.hungervalue > 0 and "+" or "")..(data.hungervalue % 1 > 0 and string.format("%.1f", data.hungervalue) or math.floor(data.hungervalue)),
				(data.healthvalue > 0 and "+" or "")..(data.healthvalue % 1 > 0 and string.format("%.1f", data.healthvalue) or math.floor(data.healthvalue)),
				(data.sanityvalue > 0 and "+" or "")..(data.sanityvalue % 1 > 0 and string.format("%.1f", data.sanityvalue) or math.floor(data.sanityvalue)),
			}

			makelistentry(icons, texts, STAT_ICONSIZE - 10)
		end

		if data.weapondamage then
			makeentry("icon_damage.tex", tostring(checknumber(data.weapondamage) and math.floor(data.weapondamage) or data.weapondamage))
			if data.planardamage then
				makesubentry("+"..math.floor(data.planardamage) .. STRINGS.SCRAPBOOK.DATA_PLANAR_DAMAGE)
			end

			if data.areadamage then
				statsheight = statsheight - STAT_GAP_SMALL -2
				makesubentry("+"..math.floor(data.areadamage) .. STRINGS.SCRAPBOOK.DATA_SPLASHDAMAGE)
			end

			if data.weaponrange then
				statsheight = statsheight - STAT_GAP_SMALL -2
				makesubentry("+"..math.floor(data.weaponrange) .. STRINGS.SCRAPBOOK.DATA_RANGE)
			end
		end

		if data.finiteuses then
			makeentry("icon_uses.tex",math.floor(data.finiteuses)..STRINGS.SCRAPBOOK.DATA_USES)
		end

		if data.toolactions then
			local actions = ""
			for i,action in ipairs(data.toolactions)do
				actions = actions .. action
				if i ~= #data.toolactions then
					actions = actions .. ", "
				end
			end
			makesubentry(actions)
		end

		if data.armor then
			makeentry("icon_armor.tex",math.floor(data.armor))
		end

		if data.absorb_percent then
			makesubentry(STRINGS.SCRAPBOOK.DATA_ARMOR_ABSORB..(data.absorb_percent*100).. "%")
		end

		if data.armor_planardefense then
			if data.absorb_percent then
				statsheight = statsheight - STAT_GAP_SMALL -2
			end
			makesubentry("+"..data.armor_planardefense ..STRINGS.SCRAPBOOK.DATA_PLANAR_DEFENSE)
		end

		if data.forgerepairable then
			makeentry("icon_wrench.tex",STRINGS.SCRAPBOOK.DATA_NOBREAK)
			makesubentry(STRINGS.SCRAPBOOK.DATA_REPAIRABLE)

			makelistentry(data.forgerepairable, nil, STAT_ICONSIZE/1.5, 30)
		end

		if data.repairitems then
			makeentry("icon_wrench.tex",STRINGS.SCRAPBOOK.DATA_REPAIRABLE)

			makelistentry(data.repairitems, nil, STAT_ICONSIZE/1.5, 30)
		end

		if data.waterproofer then
			makeentry("icon_wetness.tex",STRINGS.SCRAPBOOK.DATA_WETNESS ..(data.waterproofer*100) .. "%")
		end

		if data.insulator then
			local icon = "icon_cold.tex"
			if data.insulator_type and data.insulator_type == SEASONS.SUMMER then
				icon = "icon_heat.tex"
			end
			makeentry(icon, data.insulator..STRINGS.SCRAPBOOK.DATA_INSULATION)
		end

		if data.dapperness and data.dapperness ~= 0 then
			local dir = data.dapperness < 0 and "" or "+"

			makeentry("icon_sanity.tex", string.format("%s%.2f%s", dir, data.dapperness * 60, STRINGS.SCRAPBOOK.DATA_PERMIN ))
		end

	 	-- FUEL + FUEL TYPES
		if data.fueledrate ~= nil and data.fueledmax  ~= nil and data.fueledtype1 ~= nil then
			local icon = data.fueledtype1 == FUELTYPE.USAGE and "icon_clothing.tex" or "icon_needfuel.tex"

			data.fueledrate = data.fueledrate == 0 and 1 or data.fueledrate

			local time = data.fueledmax/data.fueledrate
			local time_str = data.fueleduses and (math.floor(time)..STRINGS.SCRAPBOOK.DATA_USES) or GetPeriodString(time)

			if not table.contains(FUELTYPE_SUBICONS, data.fueledtype1) then
				makeentry(icon, time_str)

			else
				local subicon1 = FUELTYPE_SUBICON_LOOKUP[data.fueledtype1]
				local subicon2 = data.fueledtype2 ~= nil and FUELTYPE_SUBICON_LOOKUP[data.fueledtype2] or nil

				if subicon1 ~= nil then
					makeentry(icon, "")

					local subwidth = STAT_ICONSIZE + STAT_GAP_SMALL + (subicon2 and STAT_ICONSIZE/3 or 0)

					makesubiconentry(subicon1, subwidth, time_str)
				end

				local subwidth = STAT_ICONSIZE + STAT_GAP_SMALL - STAT_ICONSIZE/4

				if data.fueledtype2 ~= nil and data.fueledtype2 ~= FUELTYPE.USAGE then
					if subicon2 ~= nil then
						makesubiconentry(subicon2, subwidth, "")
					end
				end
			end
		end

		if data.fueltype ~= nil and data.fuelvalue ~= nil then
			local time_str = GetPeriodString(data.fuelvalue)

			if not table.contains(FUELTYPE_SUBICONS, data.fueltype) then
				makeentry("icon_fuel.tex", time_str)
			else
				local icon = FUELTYPE_SUBICON_LOOKUP[data.fueltype]

				if icon then
					makeentry("icon_fuel.tex", "")

					local subwidth = STAT_ICONSIZE + STAT_GAP_SMALL

					subwidth = makesubiconentry(icon, subwidth, time_str)
				end
			end
		end

		if data.sewable then
			makeentry("icon_sewingkit.tex", STRINGS.SCRAPBOOK.DATA_SEWABLE )
		end

		-- PERISHABLE
		if data.perishable then
			makeentry("icon_spoil.tex", GetPeriodString(data.perishable))
		end

		-- NOTES
		if data.notes then
			if data.notes.shadow_aligned then
				makeentry("icon_shadowaligned.tex",STRINGS.SCRAPBOOK.NOTE_SHADOW_ALIGNED)
			end
			if data.notes.lunar_aligned then
				makeentry("icon_moonaligned.tex",STRINGS.SCRAPBOOK.NOTE_LUNAR_ALIGNED)
			end
		end

		if data.lightbattery then
			makeentry("icon_lightbattery.tex",STRINGS.SCRAPBOOK.DATA_LIGHTBATTERY)
		end

		if data.float_range and data.float_accuracy  then
			makeentry("icon_bobber.tex",STRINGS.SCRAPBOOK.DATA_FLOAT_RANGE ..data.float_range)
			makesubentry(STRINGS.SCRAPBOOK.DATA_FLOAT_ACCURACY..data.float_accuracy)
		end

		if data.lure_charm and data.lure_dist and data.lure_radius then
			makeentry("icon_lure.tex",STRINGS.SCRAPBOOK.DATA_LURE_RADIUS ..data.lure_radius)
			makesubentry(STRINGS.SCRAPBOOK.DATA_LURE_CHARM..data.lure_charm)
			statsheight = statsheight - STAT_GAP_SMALL -2
			makesubentry(STRINGS.SCRAPBOOK.DATA_LURE_DIST..data.lure_dist)
		end

		if data.oar_force and data.oar_velocity then
			makeentry("icon_oar.tex", STRINGS.SCRAPBOOK.DATA_OAR_VELOCITY.. data.oar_velocity)
			makesubentry(STRINGS.SCRAPBOOK.DATA_OAR_FORCE.. data.oar_force)
		end

		if data.workable then
			if data.workable == ACTIONS.HAMMER.id then
				makeentry("icon_uses.tex",STRINGS.SCRAPBOOK.DATA_WORKABLE_HAMMER)
			end
			if data.workable == ACTIONS.CHOP.id then
				makeentry("icon_uses.tex",STRINGS.SCRAPBOOK.DATA_WORKABLE_CHOP)
			end
			if data.workable == ACTIONS.DIG.id then
				makeentry("icon_uses.tex",STRINGS.SCRAPBOOK.DATA_WORKABLE_DIG)
			end
			if data.workable == ACTIONS.MINE.id then
				makeentry("icon_uses.tex",STRINGS.SCRAPBOOK.DATA_WORKABLE_MINE)
			end
		end
		if data.fishable then
			makeentry("icon_uses.tex",STRINGS.SCRAPBOOK.DATA_FISHABLE)
		end
		if data.pickable then
			makeentry("icon_action.tex",STRINGS.SCRAPBOOK.DATA_PICKABLE)
		end
		if data.harvestable then
			makeentry("icon_action.tex",STRINGS.SCRAPBOOK.DATA_HARVESTABLE)
		end
		if data.stewer then
			makeentry("icon_action.tex",STRINGS.SCRAPBOOK.DATA_STEWER)
		end
		if data.activatable then
			makeentry("icon_action.tex",string.upper(STRINGS.ACTIONS.ACTIVATE[data.activatable]))
		end
		if data.burnable then
			makeentry("icon_burnable.tex", STRINGS.SCRAPBOOK.DATA_BURNABLE)
		end
	end

	---------------------------------------------

	statsheight = statsheight - (STAT_PANEL_INDENT - STAT_GAP_SMALL)

	applytexturesize(statbg,STAT_PANEL_WIDTH,math.abs(statsheight))

	local attachments = statwidget:AddChild(Widget("attachments"))
	attachments:SetPosition(STAT_PANEL_WIDTH/2,-math.abs(statsheight)/2)
	statbg:SetPosition(STAT_PANEL_WIDTH/2,-math.abs(statsheight)/2)
	setattachmentdetils(attachments, STAT_PANEL_WIDTH,math.abs(statsheight))

	--------------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------

	local photostack = sub_root:AddChild(Widget("photostack"))
	local photo = photostack:AddChild(Image("images/fepanel_fills.xml", "panel_fill_large.tex"))

	photo:SetClickable(false)
	local BUFFER = 35
	local ACTUAL_X = CUSTOM_SIZE.x
	local ACTUAL_Y = CUSTOM_SIZE.y
	local offsety = 0
	local offsetx = 0
	local animal = nil

	if data then
    	animal = photostack:AddChild(UIAnim())
		local animstate = animal:GetAnimState()

		animstate:SetBuild(data.build)
		animstate:SetBank(data.bank)
		animstate:SetPercent(data.anim or "", data.animpercent or rand())

		if data.facing then
			animal:SetFacing(data.facing)
			animstate:MakeFacingDirty()
		end

		if data.alpha or data.multcolour then
			local r, g, b = unpack(data.multcolour or {1, 1, 1})
			animstate:SetMultColour(r, g, b, data.alpha or 1)
		end

		if data.overridebuild then
			animstate:AddOverrideBuild(data.overridebuild)
		end

		animstate:Hide("snow")

		if data.hide then
			for i,hide in ipairs(data.hide) do
				animstate:Hide(hide)
			end
		end

		if data.hidesymbol then
			for i,hide in ipairs(data.hidesymbol) do
				animstate:HideSymbol(hide)
			end
		end

		if data.overridesymbol then
			if type(data.overridesymbol[1]) ~= "table" then
				animstate:OverrideSymbol(data.overridesymbol[1], data.overridesymbol[2], data.overridesymbol[3])

				if data.overridesymbol[4] then
					animstate:SetSymbolMultColour(data.overridesymbol[1], 1, 1, 1, tonumber(data.overridesymbol[4]))
				end
			else
				for i, set in ipairs( data.overridesymbol ) do
					animstate:OverrideSymbol(set[1], set[2], set[3])

					if set[4] then
						animstate:SetSymbolMultColour(set[1], 1, 1, 1, tonumber(set[4]))
					end
				end
			end
		end

		local x1, y1, x2, y2 = animstate:GetVisualBB()

		local ax,ay = animal:GetBoundingBoxSize()

		local SCALE = CUSTOM_SIZE.x/ax

		if ay*SCALE >= ACTUAL_Y then
			SCALE = ACTUAL_Y/ay
			ACTUAL_X = ax*SCALE
		else
			ACTUAL_Y = ay*SCALE
		end

		SCALE = SCALE*(data.scale or 1)

		animal:SetScale(math.min(0.5,SCALE))
 		offsety = ACTUAL_Y/2 -(y2*SCALE)
 		offsetx = ACTUAL_X/2 -(x2*SCALE)

		if data.floater ~= nil then
			local size, vert_offset, xscale, yscale = unpack(data.floater)

			local floater = animal:AddChild(UIAnim())
			local floater_animstate = floater:GetAnimState()

			floater_animstate:SetBuild("float_fx")
			floater_animstate:SetBank("float_front")
			floater_animstate:SetPercent("idle_front_" .. size, rand())
			floater_animstate:SetFloatParams(-0.05, 1.0, 0)

			floater:SetPosition(0, tonumber(vert_offset), 0)
			floater:SetScale(tonumber(xscale) - .05, tonumber(yscale) - .05)
			floater:SetClickable(false)
		end

	else
		animal = photostack:AddChild(Image("images/scrapbook.xml", "icon_empty.tex"))
		ACTUAL_X = CUSTOM_SIZE.x
		ACTUAL_Y = CUSTOM_SIZE.x/379*375
		animal:ScaleToSize(ACTUAL_X,ACTUAL_Y)
		offsetx = 0
		offsety = 0
	end

    local extraoffsetbgx = data and data.animoffsetbgx or 0
    local extraoffsetbgy = data and data.animoffsetbgy or 0

	-- if extraoffsetbgx > 0 then
	-- 	offsetx = offsetx + extraoffsetbgx/2
	-- end

    local BG_X = (ACTUAL_X + BUFFER+ extraoffsetbgx)
    local BG_Y = (ACTUAL_Y + BUFFER+ extraoffsetbgy)

	applytexturesize(photo,BG_X, BG_Y)
	setattachmentdetils(photostack, BG_X, BG_Y)

    animal:SetClickable(false)

    CUSTOM_ANIMOFFSET = Vector3(offsetx,-offsety,0)
    local extraoffsetx = data and data.animoffsetx or 0
    local extraoffsety = data and data.animoffsety or 0

    local posx =(CUSTOM_ANIMOFFSET.x+extraoffsetx) *(data and data.scale and data.scale * .5 or 1)
    local posy =(CUSTOM_ANIMOFFSET.y+extraoffsety) *(data and data.scale and data.scale or 1)

    animal:SetPosition(posx,posy)

    if data and data.knownlevel == 1 then
    	animal:GetAnimState():SetSaturation(0)
    	photo:SetTint(unpack(UK_TINT))
    end

	self.animal = animal

    photostack:SetRotation(rotation)

	local ROT_X = ACTUAL_X + extraoffsetbgx
	local ROT_Y = ACTUAL_Y + extraoffsetbgy

    local rotheight = calculteRotatedHeight(rotation, ROT_X, ROT_Y)
	local rotwidth = calculteRotatedWidth(rotation, ROT_X, ROT_Y)

	if statwidget then
	    local pos_s = statwidget:GetPosition()

	   statwidget:SetPosition(rotwidth+ CUSTOM_INDENT +30 ,height)
	end
	if not showstats or (data and data.knownlevel < 2) then
		statwidget:Hide()
	end

	height = height - 20

    photostack:SetPosition(left + (rotwidth/2) + CUSTOM_INDENT, height - (0.5 * rotheight))

	local finalheight = ( (rotheight+20 > math.abs(statsheight)) or (data and data.knownlevel < 2) ) and rotheight+20 or math.abs(statsheight)

    height = height - finalheight - section_space

	if data and data.knownlevel == 1 then
		local inspectbody
		height, inspectbody = setcustomblock(height,{str=STRINGS.SCRAPBOOK.DATA_NEEDS_INVESTIGATION, minwidth=width-100, leftoffset=40, shortblock=true})
	end
	if not data then
		local inspectbody
		height, inspectbody = setcustomblock(height,{str=" \n \n \n \n \n ", minwidth=width-100, leftoffset=40,})
	end


------------------------ SPECIAL INFO -------------------------------

	local specialinfo = data and (data.specialinfo and STRINGS.SCRAPBOOK.SPECIALINFO[data.specialinfo] or STRINGS.SCRAPBOOK.SPECIALINFO[string.upper(data.prefab)])

	if specialinfo and data.knownlevel > 1 then
		local body
		local shortblock = string.len(specialinfo) < 110
		height, body = setcustomblock(height,{str=specialinfo, minwidth=width-100, leftoffset=40, shortblock=shortblock})
	end

----------------------- DEPS -----------------------------------------

	self.depsbuttons = {}
	self.character_pannel_first = nil

    local DEPS_COLS = 9
    if data and data.deps and #data.deps>0 then

    	local idx = 1
    	local row= 1
    	local cols = DEPS_COLS --5
    	local gaps = 7 --10
    	local imagesize = 32
		local imagebuffer = 5
    	local depstoshow = shallowcopy(data.deps)

		table.sort(depstoshow, function(a, b)
			local a = self:GetData(a)
			local b = self:GetData(b)

			local a_name = STRINGS.NAMES[string.upper(a.name)] or FILLER
			local b_name = STRINGS.NAMES[string.upper(b.name)] or FILLER
			if a.subcat then a_name = STRINGS.SCRAPBOOK.SUBCATS[string.upper(a.subcat)] .. a_name end
			if b.subcat then b_name = STRINGS.SCRAPBOOK.SUBCATS[string.upper(b.subcat)] .. b_name end

			if a.knownlevel == 0 or b.knownlevel == 0 then
				return a.knownlevel > b.knownlevel
			end

			if not a_name or not b_name then
				return false
			end

			if a_name == b_name and a.entry and b.entry then
				return a.entry < b.entry
			end

			return a_name < b_name
		end)

		local dep_imgsize = imagesize - imagebuffer
		local needs_img_types = { "item", "food" }

		for i, dep in ipairs(depstoshow)do
			local xidx = i%cols
			if xidx == 0 then
				xidx = cols
			end

			local depdata = self:GetData(dep)

			if depdata ~= nil then
				local tex = depdata.tex
				local atlas = GetScrapbookIconAtlas(tex)
				local button = sub_root:AddChild(ImageButton(atlas or GetScrapbookIconAtlas("cactus.tex"), atlas ~= nil and tex or "cactus.tex" ))

				local frame = sub_root:AddChild(Image("images/skilltree.xml","frame.tex" ))
				frame:ScaleToSize(imagesize+13,imagesize+13)
				frame:SetPosition(75+((imagesize+gaps)*(xidx-1)),height-imagesize/2 - ((row-1)*(imagesize+gaps)) )
				frame:Hide()

				button.ignore_standard_scaling = true
				button.scale_on_focus = true
				button.clickoffset = Vector3(0, 0, 0)
				button:SetFocusScale(1.12, 1.12, 1.12)
				button:SetPosition(75+((imagesize+gaps)*(xidx-1)),height-imagesize/2 - ((row-1)*(imagesize+gaps)) )
				button:ForceImageSize(imagesize+2,imagesize+2)
				button:SetOnClick(function()
					self.detailsroot:KillAllChildren()
					self.details = nil
					self.details = self.detailsroot:AddChild(self:PopulateInfoPanel(dep))
					self:DoFocusHookups()
					if TheInput:ControllerAttached() then
						self.details:SetFocus()
					end
				end)


				if depdata.knownlevel == 1 then
					button:SetImageNormalColour(unpack(UK_TINT))
					button:SetImageFocusColour(unpack(UK_TINT))
				end
				local buttonimg
				if depdata.knownlevel == 0 then
					button:SetTextures(GetScrapbookIconAtlas("unknown.tex"), "unknown.tex")
					button:SetOnClick(function() end)

				elseif table.contains(needs_img_types, depdata.type) then
					button:SetTextures("images/scrapbook.xml", "inv_item_background.tex")

					atlas = GetInventoryItemAtlas(tex)

					local img = button:AddChild(Image(atlas, tex))
					img:ScaleToSize(dep_imgsize, dep_imgsize)

					if depdata.knownlevel == 1 then
						img:SetTint(unpack(UK_TINT))
					end
					buttonimg = img
				end

				button:SetOnGainFocus(function()
					if TheInput:ControllerAttached() then
						frame:Show()
					end
					if buttonimg and depdata.knownlevel ~= 0 then
						buttonimg:ScaleToSize(dep_imgsize*button.focus_scale[1], dep_imgsize*button.focus_scale[2])
					end
				end)

				button:SetOnLoseFocus(function()
					if TheInput:ControllerAttached() then
						frame:Hide()
					end
					if buttonimg and depdata.knownlevel ~= 0 then
						buttonimg:ScaleToSize(dep_imgsize*button.normal_scale[1], dep_imgsize*button.normal_scale[2])
					end
				end)

				table.insert(self.depsbuttons, button)
			end

			if xidx == cols and i < #depstoshow then
				row = row +1
			end
		end

		height = height - ((imagesize+gaps) * row) -section_space
	end


	if #self.depsbuttons > 0 then

		for i,button in ipairs(self.depsbuttons) do
			if i > DEPS_COLS then
				button:SetFocusChangeDir(MOVE_UP,							function(button) return self.depsbuttons[i-DEPS_COLS] end)
			end
			if i%DEPS_COLS ~= 1 then
				button:SetFocusChangeDir(MOVE_LEFT,							function(button) return self.depsbuttons[i-1] end)
			end
			if i%DEPS_COLS ~= 0 then
				button:SetFocusChangeDir(MOVE_RIGHT,						function(button) return self.depsbuttons[i+1] end)
			end
			if i+DEPS_COLS <= #self.depsbuttons then
				button:SetFocusChangeDir(MOVE_DOWN,							function(button) return self.depsbuttons[i+DEPS_COLS] end)
			else
				button:SetFocusChangeDir(MOVE_DOWN,							function(button)
					if TheInput:ControllerAttached() and self.character_pannel_first ~= nil then
						local x,y,z = self.character_pannel_first:GetPositionXYZ()
						local scrollpos = (math.abs(y)/math.abs(self.scroll_area.maximum_height)) * self.scroll_area.scroll_pos_end
						self.scroll_area.target_scroll_pos = scrollpos
					end

					return  self.character_pannel_first
				end)
			end
		end

	end

	------------------------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------------------------
	if data then
		if STRINGS.RECIPE_DESC[string.upper(data.prefab)] then

			local STAT_PANEL_WIDTH = width -40
			local STAT_PANEL_INDENT = 20
			local STAT_GAP_SMALL = 5
			local STAT_ICONSIZE = 40

			local recipewidget,recipeheight

			local recipewidget = sub_root:AddChild(Widget("statswidget"))
			local recipebg = recipewidget:AddChild(Image("images/fepanel_fills.xml", "panel_fill_large.tex"))
			local recipeheight = 0

			recipeheight = recipeheight - STAT_PANEL_INDENT

			local atlas,tex

			for cat,recdata in pairs(CRAFTING_FILTERS) do
				local breakout = false
				if recdata.recipes then

					if type(recdata.recipes) == "function" then
						recdata.recipes = recdata.recipes()
					end

					for idx,recipe in ipairs(recdata.recipes)do
						if recipe == data.prefab then
							atlas = recdata.atlas()
							tex = recdata.image
							breakout = true
							break
						end
					end
				end
				if breakout then
					break
				end
			end

			if type(tex) == "function" then
				tex = tex(data.craftingprefab and {prefab=data.craftingprefab} or nil)
			end

			local makerecipeentry = function(tex,text)
				local icon = recipewidget:AddChild(Image(atlas, tex))
				icon:ScaleToSize(STAT_ICONSIZE,STAT_ICONSIZE)
				icon:SetPosition(STAT_PANEL_INDENT+(STAT_ICONSIZE/2), recipeheight-STAT_ICONSIZE/2)
				local txt = recipewidget:AddChild(Text(CHATFONT, 15, text, UICOLOURS.BLACK))
				txt:SetMultilineTruncatedString(text, 100, STAT_PANEL_WIDTH-(STAT_PANEL_INDENT*2) - STAT_ICONSIZE - STAT_GAP_SMALL)
				local tw, th = txt:GetRegionSize()
				txt:SetPosition(STAT_PANEL_INDENT+STAT_ICONSIZE + STAT_GAP_SMALL + (tw/2), recipeheight-STAT_ICONSIZE/2 )
				txt:SetHAlign(ANCHOR_LEFT)
				recipeheight = recipeheight - STAT_ICONSIZE - STAT_GAP_SMALL
			end

			local makerecipesubentry = function(text)
				local txt = recipewidget:AddChild(Text(CHATFONT, 15, text, UICOLOURS.BLACK))
				local tw, th = txt:GetRegionSize()
				txt:SetPosition(STAT_PANEL_WIDTH/2, recipeheight- (th/2) - STAT_GAP_SMALL)
				recipeheight = recipeheight - STAT_GAP_SMALL - th
			end

			local maketextentry = function(text)
				local txt = recipewidget:AddChild(Text(HEADERFONT, 15, text, UICOLOURS.BLACK))
				local tw, th = txt:GetRegionSize()
				txt:SetPosition(STAT_PANEL_WIDTH/2, recipeheight- (th/2) - STAT_GAP_SMALL)
				recipeheight = recipeheight - STAT_GAP_SMALL - th
			end

			---------------------------------------------

			maketextentry(STRINGS.SCRAPBOOK.DATA_CRAFTING)

			makerecipeentry(tex,STRINGS.RECIPE_DESC[string.upper(data.prefab)])

			--makerecipesubentry(STRINGS.RECIPE_DESC[string.upper(data.prefab)])

			---------------------------------------------
			recipeheight = recipeheight - (STAT_PANEL_INDENT - STAT_GAP_SMALL)

			applytexturesize(recipebg,STAT_PANEL_WIDTH,math.abs(recipeheight))

			local attachments = recipewidget:AddChild(Widget("attachments"))
			attachments:SetPosition(STAT_PANEL_WIDTH/2,-math.abs(recipeheight)/2)
			recipebg:SetPosition(STAT_PANEL_WIDTH/2,-math.abs(recipeheight)/2)
			setattachmentdetils(attachments, STAT_PANEL_WIDTH,math.abs(recipeheight))

			recipewidget:SetPosition( STAT_PANEL_INDENT ,height)  --rotwidth+ CUSTOM_INDENT +30

			local rotation = (rand() * 5)-2.5
			recipewidget:SetRotation(rotation)

		    local rotheight = calculteRotatedHeight(rotation,STAT_PANEL_WIDTH, math.abs(recipeheight))

		 	height = height - math.abs(rotheight) - (section_space*2)
		end
	end
	------------------------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------------------------

	if data then
		local character_panels = {}
		local viewed_characters = {}

		for i, char in ipairs(DST_CHARACTERLIST)do
			if TheScrapbookPartitions:WasInspectedByCharacter(data.prefab, char) then
				table.insert(viewed_characters, char)
			end
		end

		local entry_upper = string.upper(data.speechname or data.prefab)

		if data.knownlevel > 1 and STRINGS.CHARACTERS.GENERIC.DESCRIBE[entry_upper] and #viewed_characters > 0 then
			local row= 1
            local valid_index = 1
            local buttonorder = {}
			for i, char in ipairs(viewed_characters)do

				local xidx = valid_index%9
			    if xidx == 0 then
			    	xidx = 9
			    end

				if char ~= "wonkey" then
					local body = nil
					local descstr = ""
					local descchar = string.upper(char)
					if char == "wilson" then
						descchar = "GENERIC"
					end

					local objstr = ""
					if char ~= "wes" then
						objstr = STRINGS.CHARACTERS[descchar].DESCRIBE[entry_upper]
					end

					if not objstr then
						objstr = STRINGS.CHARACTERS.GENERIC.DESCRIBE[entry_upper]
					end

					if type(objstr) == "table" then
						if #objstr > 0 then
							objstr = objstr[math.floor(rand()*#objstr)+1]

						elseif DESCRIPTION_STATUS_LOOKUP[entry_upper] ~= nil then
							objstr = objstr[DESCRIPTION_STATUS_LOOKUP[entry_upper]]

						elseif entry_upper == "ABIGAIL" then
							objstr = objstr["LEVEL1"][1]

						elseif entry_upper == "FLOWER" and data.prefab == "flower_rose" then
							objstr = objstr["ROSE"]

						else
							objstr = objstr["GENERIC"]
						end
					end

                    if objstr and objstr:find("only_used_by_") then
                        objstr = nil
                    end

					if objstr then
						descstr = descstr.. objstr
						descstr = descstr.. " - "..STRINGS.CHARACTER_NAMES[char]
						height, body = setcustomblock(height,{str=descstr, minwidth=width-100, leftoffset=40,ignoreheightchange=true, shortblock=true})
					end
					character_panels[char] = body
					if body then
                        body.id = i
						body:Hide()

						local button = sub_root:AddChild(ImageButton("images/crafting_menu_avatars.xml", "avatar_".. char ..".tex"))
						button._panel = character_panels[char]
						button:ForceImageSize(50,50)
						character_panels[char].facebutton = button
						button.ignore_standard_scaling = true
						button.scale_on_focus = true
						button:SetOnClick(function()
							for t, subchar in ipairs(DST_CHARACTERLIST)do
								if character_panels[subchar] then
									character_panels[subchar].facebutton:ForceImageSize(50,50)
									character_panels[subchar]:Hide()
								end
							end
							character_panels[char].facebutton:ForceImageSize(65,65)
							character_panels[char]:Show()

							self.current_panel = i
						end)
						button:SetPosition(((width/(#DST_CHARACTERLIST/2)) *xidx) ,height-40 -((row)*50))
                        valid_index = valid_index + 1

						table.insert(buttonorder, button)
					end
				end

				if xidx == 9 and valid_index< #DST_CHARACTERLIST then
					row = row +1
				end

				self.character_pannel_first = buttonorder[1]
			end

			if #buttonorder > 0 then
				for i,button in ipairs(buttonorder) do

					button:SetFocusChangeDir(MOVE_UP, function(button)
						if TheInput:ControllerAttached() and self.depsbuttons[1] ~= nil then
							local x,y,z = self.depsbuttons[1]:GetPositionXYZ()
							local scrollpos = (math.abs(y)/math.abs(self.scroll_area.maximum_height)) * self.scroll_area.scroll_pos_end
							self.scroll_area.target_scroll_pos = scrollpos
						end

						return self.depsbuttons[1]
					end)

					if i ~= 1 then
						button:SetFocusChangeDir(MOVE_LEFT,							function(button) return buttonorder[i-1] end)
					end
					if i ~= #buttonorder then
						button:SetFocusChangeDir(MOVE_RIGHT,						function(button) return buttonorder[i+1] end)
					end
				end

			end

            local this_character_panel = character_panels[ThePlayer and TheScrapbookPartitions:WasInspectedByCharacter(data.prefab, ThePlayer.prefab) and ThePlayer.prefab or nil] or (self.character_pannel_first and self.character_pannel_first._panel) or nil

			if this_character_panel then
				this_character_panel.facebutton:ForceImageSize(65, 65)
				this_character_panel:Show()
				self.current_panel = this_character_panel.id
			end
		end

		self.character_panels = character_panels
		self.character_panels_total = #viewed_characters
	end

	height = height - 200

	height = math.abs(height)

	local max_visible_height = PANEL_HEIGHT -60  -- -20
	local padding = 5

	local top = math.min(height, max_visible_height)/2 - padding

	local scissor_data = {x = 0, y = -max_visible_height/2, width = width, height = max_visible_height}
	local context = {widget = sub_root, offset = {x = 0, y = top}, size = {w = width, height = height + padding} }
	local scrollbar = { scroll_per_click = 20*3 }
	self.scroll_area = page:AddChild(TrueScrollArea(context, scissor_data, scrollbar))

	if height < (PANEL_HEIGHT-60) then
		self.scroll_area:SetPosition(0,(((PANEL_HEIGHT-60)/2) - (height/2)) )
	end

	page.focus_forward = self.scroll_area
	if self.depsbuttons then
		self.scroll_area.focus_forward = self.depsbuttons[1]
	end

	if self.debugentry ~= nil and data ~= nil then
		local msg = string.format("DEBUG - Entry:\n%s\n%s.fla", tostring(page.entry or "???"), tostring(data.build or "???"))

		self.debugentry.entry = page.entry
		self.debugentry.build = data.build
		self.debugentry:SetText(msg)

        local w, h = self.debugentry.text:GetRegionSize()
        self.debugentry:SetPosition(-w*2 - 5, h*2 + 5)
	end
	self.scroll_area.maximum_height = height
    return page
end

function ScrapbookScreen:CycleChraterQuotes(dir)
	if self.current_panel and self.character_panels and self.character_panels_total > 1 then

		for char,panel in pairs(self.character_panels) do
			if panel.id == self.current_panel then
				if  TheInput:ControllerAttached() then
					panel.facebutton:ForceImageSize(50,50)
				end
				panel:Hide()
				break
			end
		end

		if dir == "left" then
			self.current_panel = self.current_panel -1
			if self.current_panel < 1 then
				self.current_panel = self.character_panels_total

			end
		else
			self.current_panel = self.current_panel +1
			if self.current_panel > self.character_panels_total then
				self.current_panel = 1

			end
		end

		for char,panel in pairs(self.character_panels) do
			if panel.id == self.current_panel then

				if  TheInput:ControllerAttached() then
					panel.facebutton:ForceImageSize(65,65)
				end

				panel:Show()
				break
			end
		end
	end
end

function ScrapbookScreen:OnControl(control, down)
    if ScrapbookScreen._base.OnControl(self, control, down) then return true end

    if not down and not self.closing then
	    if control == CONTROL_CANCEL then
			self.closing = true

			self:Close() --go back

			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			return true
		end

		 if control == CONTROL_MENU_L2 and TheInput:ControllerAttached() and self.details.entry then
		 	self.details:SetFocus()

			if TheInput:ControllerAttached() and self.depsbuttons[1] ~= nil then
				local x,y,z = self.depsbuttons[1]:GetPositionXYZ()
				local scrollpos = (math.abs(y)/math.abs(self.scroll_area.maximum_height)) * self.scroll_area.scroll_pos_end
				self.scroll_area.target_scroll_pos = scrollpos

				self.depsbuttons[1]:SetFocus()

			elseif TheInput:ControllerAttached() and self.character_pannel_first ~= nil then
				local x,y,z = self.character_pannel_first:GetPositionXYZ()
				local scrollpos = (math.abs(y)/math.abs(self.scroll_area.maximum_height)) * self.scroll_area.scroll_pos_end
				self.scroll_area.target_scroll_pos = scrollpos

				self.character_pannel_first:SetFocus()
			end
		 end
		 if control == CONTROL_MENU_R2 and TheInput:ControllerAttached() then
		 	if self.lastselecteditem then
		 		self.lastselecteditem:SetFocus()
		 	else
		 		self.item_grid:SetFocus()
		 	end
		 end

	    if control == CONTROL_MENU_START and TheInput:ControllerAttached() then
			if self.columns_setting == 1 then
				self.columns_setting = 2
			elseif self.columns_setting == 2 then
				self.columns_setting = 3
			elseif self.columns_setting == 3 then
				self.columns_setting = 7
			elseif self.columns_setting == 7 then
				self.columns_setting = 1
			end

			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")

			self:SetGrid()

			Profile:SetScrapbookColumnsSetting(self.columns_setting)

			return true
		end

	    if control == CONTROL_MENU_MISC_2 then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			self:SelectMenuItem("down")
			return true
		end

	    if control == CONTROL_MENU_BACK then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			self:CycleChraterQuotes("right")
			return true
		end

		if self.flashestoclear then
  			if control == CONTROL_MENU_MISC_1 then
  				self.flashestoclear = nil
  				self:ClearFlashes()
				return true
			end
		end

	end
end

--CONTROL_MENU_L2  --CONTROL_MENU_R2
function ScrapbookScreen:GetHelpText()
	local t = {}
	local controller_id = TheInput:GetControllerID()

	table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

	table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2) .. " " .. STRINGS.SCRAPBOOK.CYCLE_CAT)

	if self.character_panels and self.character_panels_total>1 and self.details.focus == true then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_BACK).. " " .. STRINGS.SCRAPBOOK.CYCLE_QUOTES)
	end

	table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_START) .. " " .. STRINGS.SCRAPBOOK.CYCLE_VIEW)

	if self.searchbox.focus then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.SCRAPBOOK.SEARCH)
	end

	if self.flashestoclear then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_1) .. " " .. STRINGS.SCRAPBOOK.CLEARFLASH)
	end

	if self.details.entry and not self.details.focus then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_L2) .. " " .. STRINGS.SCRAPBOOK.SELECT_INFO_PAGE)
	end
	if not self.item_grid.focus then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_R2) .. " " .. STRINGS.SCRAPBOOK.SELECT_ITEM_PAGE)
	end



	return table.concat(t, "  ")
end

function ScrapbookScreen:DoFocusHookups()

	self.item_grid:SetFocusChangeDir(MOVE_UP,							function(w) return self.searchbox end)


	self.searchbox:SetFocusChangeDir(MOVE_DOWN,							function(w) return self.item_grid end)

	--self.depsbuttons:SetFocusChangeDir(MOVE_DOWN,							function(w) return self.character_panels end)
	--self.character_panels:SetFocusChangeDir(MOVE_UP,							function(w) return self.depsbuttons end)

end

function ScrapbookScreen:OnDestroy()
	SetAutopaused(false)
	self._base.OnDestroy(self)
end

function ScrapbookScreen:OnBecomeActive()
    ScrapbookScreen._base.OnBecomeActive(self)

    ThePlayer:PushEvent("scrapbookopened")
end

function ScrapbookScreen:OnBecomeInactive()
    ScrapbookScreen._base.OnBecomeInactive(self)
end

function ScrapbookScreen:SelectEntry(entry)
	self:updatemenubuttonflashes()

	if self.details.entry ~= entry and self:GetData(entry) ~= nil then
		self.detailsroot:KillAllChildren()
		self.details = nil
		self.details = self.detailsroot:AddChild(self:PopulateInfoPanel(entry))
		self:DoFocusHookups()
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/scrapbook_pageflip")
	end
end

return ScrapbookScreen
