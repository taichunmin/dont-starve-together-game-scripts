local Screen = require "widgets/screen"
local AnimButton = require "widgets/animbutton"
local TextButton = require "widgets/textbutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local PopupDialogScreen = require "screens/popupdialog"
local ModConfigurationScreen = require "screens/modconfigurationscreen"

local UIAnim = require "widgets/uianim"

local TEMPLATES = require "widgets/templates"

local ScrollableList = require "widgets/scrollablelist"
local OnlineStatus = require "widgets/onlinestatus"

local text_font = DEFAULTFONT--NUMBERFONT

local display_rows = 5

local DISABLE = 0
local ENABLE = 1

local mid_col = RESOLUTION_X*.07
local left_col = -RESOLUTION_X*.3
local right_col = RESOLUTION_X*.37

local title_x = -73

local ModsScreen = Class(Screen, function(self, prev_screen)
    Widget._ctor(self, "ModsScreen")

    self.currentmodtype = ""
    self.dirty = false

	-- save current mod index before user configuration
	KnownModIndex:CacheSaveData()
	-- get the latest mod info
	KnownModIndex:UpdateModInfo()

	self.infoprefabs = {}

    self.prev_screen = prev_screen
    prev_screen:TransferPortalOwnership(prev_screen, self)

    self.root = self:AddChild(Widget("root"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)

	self.root:AddChild(TEMPLATES.LeftGradient())

	-- top mods panel
	self:CreateTopModsPanel()

	self.optionspanel = self.root:AddChild(TEMPLATES.CenterPanel(.64, .68, false, 575, 510, 46, -29, .64, .68, 5 ))
	self.optionspanel:SetPosition(-18,-10)

	self.optionschildren = self.optionspanel:AddChild(Widget("root"))
	self.optionschildren:SetPosition(10, 10)

	self.nav_bar = self.root:AddChild(TEMPLATES.NavBarWithScreenTitle(STRINGS.UI.MODSSCREEN.MODTITLE, "short"))
	self.servermodsbutton = self.nav_bar:AddChild(TEMPLATES.NavBarButton(25, STRINGS.UI.MODSSCREEN.SERVERMODS, function() self:SetModsList("server") end))
	self.clientmodsbutton = self.nav_bar:AddChild(TEMPLATES.NavBarButton(-25, STRINGS.UI.MODSSCREEN.CLIENTMODS, function() self:SetModsList("client") end))

	self.top_line = self.optionschildren:AddChild(Image("images/ui.xml", "line_horizontal_5.tex"))
    self.top_line:SetScale(.68, 1)
    self.top_line:SetPosition(0, 215, 0)

    self.bottom_line = self.optionschildren:AddChild(Image("images/ui.xml", "line_horizontal_5.tex"))
    self.bottom_line:SetScale(.68, 1)
    self.bottom_line:SetPosition(0, -257, 0)

    self.left_line = self.optionschildren:AddChild(Image("images/ui.xml", "line_vertical_5.tex"))
    self.left_line:SetScale(1, .72)
    self.left_line:SetPosition(-442, -23, 0)

    self.middle_line = self.optionschildren:AddChild(Image("images/ui.xml", "line_vertical_5.tex"))
    self.middle_line:SetScale(1, .70)
    self.middle_line:SetPosition(-120, -20, 0)

    self.right_line = self.optionschildren:AddChild(Image("images/ui.xml", "line_vertical_5.tex"))
    self.right_line:SetScale(1, .72)
    self.right_line:SetPosition(409, -23, 0)

	self.mainmenu = self.root:AddChild(Menu(nil, 0, true))
    self.mainmenu:SetPosition(mid_col, 2, 0)

	self.applybutton = self.mainmenu:AddCustomItem(TEMPLATES.Button(STRINGS.UI.MODSSCREEN.APPLY, function() self:Apply() end), Vector3(223, -RESOLUTION_Y*.5 + BACK_BUTTON_Y - 8,0))

	self.modconfigbutton = self.mainmenu:AddCustomItem(TEMPLATES.IconButton("images/button_icons.xml", "configure_mod.tex", STRINGS.UI.MODSSCREEN.CONFIGUREMOD, false, false, function() self:ConfigureSelectedMod() end), Vector3(148, -230, 0))
	self.modconfigable = false

	self.modupdatebutton = self.mainmenu:AddCustomItem(TEMPLATES.IconButton("images/button_icons.xml", "update.tex", STRINGS.UI.MODSSCREEN.UPDATEMOD, false, false, function() self:UpdateSelectedMod() end), Vector3(214, -230, 0))
	self.modupdateable = false

	self.modlinkbutton = self.mainmenu:AddCustomItem(TEMPLATES.IconButton("images/button_icons.xml", "more_info.tex", STRINGS.UI.MODSSCREEN.MODLINK_MOREINFO, false, false, function() self:ModLinkCurrent() end), Vector3(279, -230, 0))

	self.mainmenu:MoveToFront()

	self.modtypetitle = self.optionschildren:AddChild(Text(BUTTONFONT, 37))
	self.modtypetitle:SetHAlign(ANCHOR_MIDDLE)
	self.modtypetitle:SetPosition(0, 240, 0)
	self.modtypetitle:SetColour(0,0,0,1)

	self.cleanallbutton = self.mainmenu:AddCustomItem(TEMPLATES.IconButton("images/button_icons.xml", "clean_all.tex", STRINGS.UI.MODSSCREEN.CLEANALL, false, false, function() self:CleanAllButton() end), Vector3(-415, -RESOLUTION_Y*.5 + BACK_BUTTON_Y - 10, 0))
    -- self.cleanallbutton.image:SetScale(.7,1)
    -- self.cleanallbutton:SetScale(.4)
    if TheInput:ControllerAttached() then
    	self.cleanallbutton:Hide()
    end

    self.updateallbutton = self.mainmenu:AddCustomItem(TEMPLATES.IconButton("images/button_icons.xml", "updateall.tex", STRINGS.UI.MODSSCREEN.UPDATEALL, false, false, function() self:UpdateAllButton() end), Vector3(-325, -RESOLUTION_Y*.5 + BACK_BUTTON_Y - 10, 0))
    -- self.updateallbutton.image:SetScale(.7,1)
    -- self.updateallbutton:SetScale(.4)
    self.updateallbutton.out_of_date_image = self.updateallbutton:AddChild(Image("images/frontend.xml", "circle_red.tex"))
    self.updateallbutton.out_of_date_image:SetScale(.6)
    self.updateallbutton.out_of_date_image:SetPosition(-28,-20)
    self.updateallbutton.out_of_date_image:SetClickable(false)
    self.updateallbutton.out_of_date_image.count = self.updateallbutton.out_of_date_image:AddChild(Text(BUTTONFONT, 30, ""))
    self.updateallbutton.out_of_date_image.count:SetColour(0,0,0,1)
    self.updateallbutton.out_of_date_image.count:SetPosition(2,0)
    self.updateallbutton.out_of_date_image:Hide()
    if TheInput:ControllerAttached() then
    	self.updateallbutton:Hide()
    	self.controller_out_of_date = self.optionschildren:AddChild(Widget("controller_out_of_date"))
    	self.controller_out_of_date:SetPosition(-252, 234, 0)
    	self.controller_out_of_date.bg = self.controller_out_of_date:AddChild(Image("images/ui.xml", "single_option_bg.tex"))
		self.controller_out_of_date.bg:SetScale(.35, .75)
		self.controller_out_of_date.bg:SetPosition(-70, 3)
    	self.controller_out_of_date.image = self.controller_out_of_date:AddChild(Image("images/frontend.xml", "circle_red.tex"))
    	self.controller_out_of_date.image:SetScale(.55)
	    self.controller_out_of_date.count = self.controller_out_of_date:AddChild(Text(BUTTONFONT, 18, ""))
	    self.controller_out_of_date.count:SetColour(0,0,0,1)
	    self.controller_out_of_date.count:SetPosition(1,0)
	    self.controller_out_of_date.label = self.controller_out_of_date:AddChild(Text(NEWFONT, 24, STRINGS.UI.MODSSCREEN.OUT_OF_DATE))
	    self.controller_out_of_date.label:SetColour(0,0,0,1)
	    local w,h = self.controller_out_of_date.label:GetRegionSize()
	    self.controller_out_of_date.label:SetPosition(-w + 50, 3)
    end

	self.onlinestatus = self.root:AddChild(OnlineStatus())
	self.cancelbutton = self.root:AddChild(TEMPLATES.BackButton(function() self:Cancel() end))

	self.currentmodtype = "client"
    --Reminder to DON'T initialize these!
	----self.modnames_client = {}
	----self.modnames_server = {}
	----self.modnames_client_dl = {}
	----self.modnames_server_dl = {}
    --

	self:StartWorkshopUpdate()

	self.default_focus = self.servermodsbutton
	self:DoFocusHookups()

    if self.cancelbutton then self.cancelbutton:MoveToFront() end
    if self.applybutton then self.applybutton:MoveToFront() end
end)

function ModsScreen:OnDestroy()
    self.prev_screen:TransferPortalOwnership(self, self.prev_screen)
    self._base.OnDestroy(self)
end

function ModsScreen:OnBecomeActive()
    ModsScreen._base.OnBecomeActive(self)
	self.mainmenu:Enable()
	if TheInput:ControllerAttached() then
		if self.currentmodtype == "client" then
			if self.options_scroll_list_client ~= nil then
				self.options_scroll_list_client:SetFocus()
			end
		elseif self.currentmodtype == "server" then
			if self.options_scroll_list_server ~= nil then
				self.options_scroll_list_server:SetFocus()
			end
		elseif self.modlinks and self.modlinks[1] then
			self.modlinks[1]:SetFocus()
		end
	else
		self.mainmenu:SetFocus()
	end
end

function ModsScreen:GenerateRandomPicks(num, numrange)
	local picks = {}

	while #picks < num do
		local num = math.random(1, numrange)
		if not table.contains(picks, num) then
			table.insert(picks, num)
		end
	end
	return picks
end

function ModsScreen:OnStatsQueried( result, isSuccessful, resultCode )
	if not (self.inst:IsValid() and self:IsVisible()) then
		return
	end

	if not result or not isSuccessful or string.len(result) <= 1 then return end

	local status, jsonresult = pcall( function() return json.decode(result) end )

	if not jsonresult or type(jsonresult) ~= "table" or not status or jsonresult["modnames"] == nil then return end

	local randomPicks = self:GenerateRandomPicks(#self.modlinks, 20)

	for i = 1, #self.modlinks do
		local title = jsonresult["modnames"][randomPicks[i]]
		if title then
			local url = jsonresult["modlinks"][title]
			title = string.gsub(title, "(ws%-)", "")
			if string.len(title) > 25 then
				title = string.sub(title, 0, 25).."..."
			end
			self.modlinks[i]:SetText(title)
			if url then
				self.modlinks[i]:SetOnClick(function() VisitURL(url) end)
			end
		end
	end

	local title, url = next(jsonresult["modfeature"])
	if title and url then
		title = string.gsub(title, "(ws%-)", "")
		self.featuredbutton:SetText(title)
		self.featuredbutton:SetOnClick(function() VisitURL(url) end)
	end
end

function ModsScreen:CreateTopModsPanel()

	--Top Mods Stuff--
	self.topmods = self.root:AddChild(Widget("topmods"))
    self.topmods:SetPosition(right_col+37,0,0)

	self.topmodsbg = self.topmods:AddChild( Image( "images/fepanels.xml", "panel_topmods.tex" ) )
	self.topmodsbg:SetScale(.8,.8,1)
	self.topmodsbg:SetPosition(0, 10)

	self.topmodsgreybg = self.topmods:AddChild( Image( "images/frontend.xml", "submenu_greybox.tex") )
	self.topmodsgreybg:SetScale(.6, .8, 1)
	self.topmodsgreybg:SetPosition(0, 0)
	self.topmodsgreybg:SetTint(0.7,0.7,0.7,1)

    self.morebutton = self.topmods:AddChild(TEMPLATES.Button(STRINGS.UI.MODSSCREEN.MOREMODS, function() self:MoreWorkshopMods() end))
    self.morebutton:SetPosition(Vector3(0,-230,0))
    self.morebutton:SetScale(.6)

    local region_size = 160

    self.title = self.topmods:AddChild(Text(TITLEFONT, 36))
    self.title:SetPosition(Vector3(0,170,0))
    self.title:SetRegionSize(region_size, 70)
    self.title:SetHAlign(ANCHOR_MIDDLE)
    self.title:SetString(STRINGS.UI.MODSSCREEN.TOPMODS)

	self.modlinks = {}

	local yoffset = 120
	for i = 1, 5 do
		local modlink = self.topmods:AddChild(TextButton("images/ui.xml", "blank.tex","blank.tex","blank.tex","blank.tex"))
	    modlink:SetPosition(Vector3(3,yoffset,0))
	    modlink.text:SetRegionSize(region_size, 70)
		modlink.text:SetHAlign(ANCHOR_MIDDLE)
	    modlink:SetText(STRINGS.UI.MODSSCREEN.LOADING.."...")
	    modlink:SetTextSize(28)
	    modlink:SetFont(UIFONT)
    	modlink:SetTextColour(0.9,0.8,0.6,1)
		modlink:SetTextFocusColour(1,1,1,1)
	    table.insert(self.modlinks, modlink)
	    yoffset = yoffset - 45
	end

	self.featuredtitle = self.topmods:AddChild(Text(TITLEFONT, 36))
	self.featuredtitle:SetRegionSize( region_size, 70 )
    self.featuredtitle:SetHAlign(ANCHOR_MIDDLE)
    self.featuredtitle:SetPosition(Vector3(0,-120,0))
    self.featuredtitle:SetString(STRINGS.UI.MODSSCREEN.FEATUREDMOD)

    self.featuredtitleunderline = self.topmods:AddChild( Image( "images/ui.xml", "line_horizontal_white.tex") )
	self.featuredtitleunderline:SetScale(.8, 1, 1)
	self.featuredtitleunderline:SetPosition(0, 150)

	self.featuredbutton = self.topmods:AddChild(TextButton("images/ui.xml", "blank.tex","blank.tex","blank.tex","blank.tex"))
    self.featuredbutton:SetPosition(Vector3(3,-170,0))
    self.featuredbutton.text:SetRegionSize(region_size, 70)
    self.featuredbutton.text:SetHAlign(ANCHOR_MIDDLE)
    self.featuredbutton:SetText(STRINGS.UI.MODSSCREEN.LOADING.."...")
	self.featuredbutton:SetFont(UIFONT)
	self.featuredbutton:SetTextSize(28)
	self.featuredbutton:SetTextColour(0.9,0.8,0.6,1)
	self.featuredbutton:SetTextFocusColour(1,1,1,1)

	self.featuredbuttonunderline = self.topmods:AddChild( Image( "images/ui.xml", "line_horizontal_white.tex") )
	self.featuredbuttonunderline:SetScale(.8, 1, 1)
	self.featuredbuttonunderline:SetPosition(0, -140)
end

function ModsScreen:DisableConfigButton(modWidget)
	self.modconfigable = false

	if self.modconfigbutton then
		self.modconfigbutton:Select()
		self.modconfigbutton:SetHoverText(STRINGS.UI.MODSSCREEN.NOCONFIG)
	end

	if modWidget then
		modWidget.configurable_image:Hide()
	end

	self:DoFocusHookups()
end

function ModsScreen:EnableConfigButton(modWidget)
	self.modconfigable = true

	if self.modconfigbutton then
		self.modconfigbutton:Unselect()
		self.modconfigbutton:SetHoverText(STRINGS.UI.MODSSCREEN.CONFIGUREMOD)
	end

	if modWidget then
		modWidget.configurable_image:Show()
	end

	self:DoFocusHookups()
end

function ModsScreen:DisableUpdateButton(mode)
	self.modupdateable = false

	self.modupdatebutton:Select()

	if mode == "uptodate" then
		self.modupdatebutton:SetHoverText(STRINGS.UI.MODSSCREEN.UPTODATE)
	else
		self.modupdatebutton:SetHoverText(STRINGS.UI.MODSSCREEN.UPDATINGMOD)
	end

	self:DoFocusHookups()
end

function ModsScreen:EnableUpdateButton(idx)
	self.modupdateable = true

	self.modupdatebutton:Unselect()
	self.modupdatebutton:SetHoverText(STRINGS.UI.MODSSCREEN.UPDATEMOD)

	self:DoFocusHookups()
end

function ModsScreen:CreateDetailPanel()
	if self.detailpanel then
		self.detailpanel:KillAllChildren()
		self.detailpanel:Kill()
	end

	self.detailpanel = self.optionschildren:AddChild(Widget("detailpanel"))
    self.detailpanel:SetPosition(75,0,0)

	local num_mods = 0
	if self.currentmodtype == "client" then num_mods = #self.modnames_client else num_mods = #self.modnames_server end

	if num_mods > 0 then
		self.detailimage = self.detailpanel:AddChild(Image("images/ui.xml", "portrait_bg.tex"))
		self.detailimage:SetSize(102, 102)
		--self.detailimage:SetScale(0.8,0.8,0.8)
		self.detailimage:SetPosition(-133, 150, 0)

		self.detailtitle = self.detailpanel:AddChild(Text(NEWFONT, 40, ""))
		self.detailtitle:SetPosition(title_x, 189, 0)
		self.detailtitle:SetColour(0,0,0,1)

        self.detailtitle2 = self.detailpanel:AddChild(Text(NEWFONT, 40, ""))
        self.detailtitle2:SetHAlign(ANCHOR_LEFT)
        self.detailtitle2:SetRegionSize(400, 55)
        self.detailtitle2:SetPosition(title_x + 200, 156, 0)
        self.detailtitle2:SetColour(0,0,0,1)

		self.detailauthor = self.detailpanel:AddChild(Text(NEWFONT, 25, ""))
		self.detailauthor:SetColour(0,0,0,1)
		--self.detailauthor:SetColour(0.9,0.8,0.6,1) -- link colour
		self.detailauthor:SetPosition(title_x, 125, 0)

		self.detailcompatibility = self.detailpanel:AddChild(Text(NEWFONT, 20, ""))
		self.detailcompatibility:SetColour(0,0,0,1)
		self.detailcompatibility:SetHAlign(ANCHOR_LEFT)
		self.detailcompatibility:SetPosition(title_x + 200, 105, 0)
		self.detailcompatibility:SetRegionSize(400, 30)

		self.detaildesc = self.detailpanel:AddChild(Text(NEWFONT, 20, ""))
		self.detaildesc:SetColour(0,0,0,1)
		self.detaildesc:SetPosition(-183, 84, 0)
		self.detaildesc:SetHAlign(ANCHOR_LEFT)

		self.detailwarning = self.detailpanel:AddChild(Text(BODYTEXTFONT, 30, ""))
		self.detailwarning:SetColour(0.8,0.6,0.5, 1)
		self.detailwarning:SetPosition(-23, -220, 0)
		self.detailwarning:SetRegionSize( 600, 107 )
		self.detailwarning:EnableWordWrap(true)

		self.modlinkbutton:SetHoverText(STRINGS.UI.MODSSCREEN.MODLINK_MOREINFO)
		self.modlinkbutton:Unselect()
	else
		self.detaildesc = self.detailpanel:AddChild(Text(NEWFONT, 25))
		local no_mods = string.format(STRINGS.UI.MODSSCREEN.NO_MODS_TYPE, self.currentmodtype )
		self.detaildesc:SetString(no_mods)
		self.detaildesc:SetColour(0,0,0,1)
		self.detaildesc:SetPosition(80, -8, 0)
		self.detaildesc:SetRegionSize( 400, 165 )
		self.detaildesc:EnableWordWrap(true)

		self:DisableConfigButton()
		self:DisableUpdateButton("uptodate")
		self.modlinkbutton:ClearHoverText()
		self.modlinkbutton:Unselect()
	end

	self.mainmenu:MoveToFront()
end

function ModsScreen:StartWorkshopUpdate()
	local linkpref = (PLATFORM == "WIN32_STEAM" and "external") or "klei"
	TheSim:QueryStats( '{ "req":"modrank", "field":"Session.Loads.Mods.list", "fieldop":"unwind", "linkpref":"'..linkpref..'", "limit": 20}',
		function(result, isSuccessful, resultCode) self:OnStatsQueried(result, isSuccessful, resultCode) end)

	self:UpdateForWorkshop()
	self.updatetask = staticScheduler:ExecutePeriodic( TUNING.MODS_QUERY_TIME, self.UpdateForWorkshop, nil, 0, "updateforworkshop", self )

end

local function ModNameVersionTableContains( modnames_versions, modname )
	for _,v in pairs(modnames_versions) do
		if modname == v.modname then
			return true
		end
	end
	return false
end

local function CompareModnamesTable( t1, t2 )
	if #t1 ~= #t2 then
		return false
	end
	for i = 1, #t1 do
		if t1[i].modname ~= t2[i].modname or t1[i].version ~= t2[i].version then
			return false
		end
	end
	return true
end
local function CompareModDLTable( t1, t2 )
	if #t1 ~= #t2 then
		return false
	end
	for i = 1, #t1 do
		if t1[i].modname ~= t2[i].modname then
			return false
		end
	end
	return true
end

local function IsModOutOfDate( modname, workshop_version )
	return IsWorkshopMod(modname) and workshop_version ~= "" and workshop_version ~= KnownModIndex:GetModInfo(modname).version
end

function ModsScreen:UpdateForWorkshop()
	if TheSim:TryLockModDir() then
		KnownModIndex:UpdateModInfo()
		local curr_modnames_client = KnownModIndex:GetClientModNamesTable()
		local curr_modnames_server = KnownModIndex:GetServerModNamesTable()
		local curr_modnames_client_dl = TheSim:GetClientModsDownloading()
		local curr_modnames_server_dl = TheSim:GetServerModsDownloading()
		local function alphasort(moda, modb)
			if not moda then return false end
			if not modb then return true end
			return string.lower(KnownModIndex:GetModFancyName(moda.modname)) < string.lower(KnownModIndex:GetModFancyName(modb.modname))
		end
		table.sort(curr_modnames_client, alphasort)
		table.sort(curr_modnames_server, alphasort)

		--update workshop version data into the curr list
		for k,v in pairs( curr_modnames_client ) do
			v.version = IsWorkshopMod(v.modname) and TheSim:GetWorkshopVersion(v.modname) or ""
		end
		for k,v in pairs( curr_modnames_server ) do
			v.version = IsWorkshopMod(v.modname) and TheSim:GetWorkshopVersion(v.modname) or ""
		end

		--check it see if anything changed
		local need_to_udpate = false
		if self.modnames_client == nil or
			not CompareModnamesTable( self.modnames_client, curr_modnames_client ) or
			not CompareModnamesTable( self.modnames_server, curr_modnames_server ) or
			not CompareModDLTable( self.modnames_client_dl, curr_modnames_client_dl ) or
			not CompareModDLTable( self.modnames_server_dl, curr_modnames_server_dl ) then
			need_to_udpate = true
		end

		--If nothing has changed bail out and leave the ui alone
		if not need_to_udpate then
			if TheSim:IsLoggedOn() then
				TheSim:StartWorkshopQuery()
			end
			TheSim:UnlockModDir()
			return
		end
		--print("### Do UpdateForWorkshop refresh")

		self.modnames_client = curr_modnames_client
		self.modnames_server = curr_modnames_server
		self.modnames_client_dl = curr_modnames_client_dl
		self.modnames_server_dl = curr_modnames_server_dl

		self:ReloadModInfoPrefabs()

		if #self.modnames_client == 0
			and #self.modnames_server == 0
			and #self.modnames_client_dl == 0
			and #self.modnames_server_dl == 0 then
			self.inst:DoTaskInTime(0.1, function()
				TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MODSSCREEN.NO_MODS_TITLE, STRINGS.UI.MODSSCREEN.NO_MODS,
					{
						{text=STRINGS.UI.MODSSCREEN.NO_MODS_OK, cb = function() self:MoreWorkshopMods() TheFrontEnd:PopScreen() end },
						{text=STRINGS.UI.MODSSCREEN.CANCEL, cb = function() self:Cancel(true) end },
					}))
			end, self)
		end

		--figure out the current selection after the refresh
		local mod_index = 1
		local client_mod_type = true
		if self.currentmodtype ~= nil then
			client_mod_type = self.currentmodtype == "client"
		end
		if self.currentmodname ~= nil then
			if client_mod_type then
				for k,v in pairs(self.modnames_client) do
					if v.modname == self.currentmodname then
						mod_index = k
					end
				end
			else
				for k,v in pairs(self.modnames_server) do
					if v.modname == self.currentmodname then
						mod_index = k
					end
				end
			end
		end


		local out_of_date_mods = 0
		-- Now that we're up to date, build widgets for all the mods
		self.optionwidgets_client = {}
		for i,v in ipairs(self.modnames_client) do

			local idx = i

			local modname = v.modname
			local modinfo = KnownModIndex:GetModInfo(modname)
			local modstatus = self:GetBestModStatus(modname)

			local opt = TEMPLATES.ModListItem(modname, modinfo, modstatus, KnownModIndex:IsModEnabled(modname))
			opt.idx = idx

			opt.OnGainFocus =
				function()
					TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
					opt.state_bg:Show()
				end

			opt.OnLoseFocus =
				function()
					opt.state_bg:Hide()
                    if opt.o_pos ~= nil then
                        opt:SetPosition(opt.o_pos)
                        opt.o_pos = nil
                    end
				end

			opt.StartClick = function()
				if modname ~= self.currentmodname then
					self.last_mod_click_time = nil
				end
			end

			opt.FinishClick = function()
        		local double = false
				if modname == self.currentmodname and self.last_mod_click_time and GetTimeReal() - self.last_mod_click_time <= DOUBLE_CLICK_TIMEOUT then
					self:EnableCurrent(idx)
					double = true
				end

				if double then
            		self.last_mod_click_time = nil
				else
            		self.last_mod_click_time = GetTimeReal()
				end
			end

			opt.OnControl =
				function(_, control, down)
					if Widget.OnControl(opt, control, down) then return true end
					if down then
						if control == CONTROL_ACCEPT or (control == CONTROL_MENU_MISC_2 and TheInput:ControllerAttached()) then
                            if opt.o_pos == nil then
                                opt.o_pos = opt:GetLocalPosition()
                                opt:SetPosition(opt.o_pos + opt.clickoffset)
                            end
							if control == CONTROL_ACCEPT then
								opt.StartClick()
							end
						end
					else
						if opt.o_pos ~= nil then
							opt:SetPosition(opt.o_pos)
							opt.o_pos = nil
						end
						if control == CONTROL_ACCEPT then
							opt.FinishClick()
							TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
							self:ShowModDetails(idx, true)
							return true
						elseif control == CONTROL_MENU_MISC_1 then
							self:EnableCurrent(idx)
							TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
							return true
						end
					end
				end

			opt.checkbox.OnControl =
				function(_, control, down)
					if Widget.OnControl(opt.checkbox, control, down) then return true end
					if not down then
						if opt.o_pos then
							opt:SetPosition(opt.o_pos)
							opt.o_pos = nil
						end
						if control == CONTROL_ACCEPT and (not TheInput:ControllerAttached() or TheFrontEnd.tracking_mouse) then
							self:EnableCurrent(idx)
							TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
							return true
						elseif control == CONTROL_MENU_MISC_1 then
							self:EnableCurrent(idx)
							TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
							return true
						end
					end
				end

			opt.GetHelpText = function()
				local controller_id = TheInput:GetControllerID()
    			local t = {}

    			table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_1) .. " " .. STRINGS.UI.HELP.TOGGLE)
        		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.HELP.SELECT)

	   			return table.concat(t, "  ")
      		end

			table.insert(self.optionwidgets_client, opt)

			if IsModOutOfDate( modname, v.version ) then
				out_of_date_mods = out_of_date_mods + 1
				opt.out_of_date_image:Show()
			else
				opt.out_of_date_image:Hide()
			end

			if KnownModIndex:HasModConfigurationOptions(modname) then
				opt.configurable_image:Show()
			end
		end
		for _,v in ipairs(self.modnames_client_dl) do
			if not ModNameVersionTableContains( self.modnames_client, v.modname ) then
				local opt = TEMPLATES.ModDLListItem(v.fancy_name)
				table.insert(self.optionwidgets_client, opt)
			end
		end

		self.optionwidgets_server = {}
		for i,v in ipairs(self.modnames_server) do

			local idx = i

			local modname = v.modname
			local modinfo = KnownModIndex:GetModInfo(modname)
			local modstatus = self:GetBestModStatus(modname)

			local opt = TEMPLATES.ModListItem(modname, modinfo, modstatus, KnownModIndex:IsModEnabled(modname))
			opt.idx = idx

			opt.OnGainFocus =
				function()
					TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
					opt.state_bg:Show()
				end

			opt.OnLoseFocus =
				function()
					opt.state_bg:Hide()
                    if opt.o_pos ~= nil then
                        opt:SetPosition(opt.o_pos)
                        opt.o_pos = nil
                    end
				end

			opt.OnControl =
				function(_, control, down)
					if Widget.OnControl(opt, control, down) then return true end
					if down then
						if control == CONTROL_ACCEPT or (control == CONTROL_MENU_MISC_2 and TheInput:ControllerAttached()) then
                            if opt.o_pos == nil then
                                opt.o_pos = opt:GetLocalPosition()
                                opt:SetPosition(opt.o_pos + opt.clickoffset)
                            end
						end
					else
						if opt.o_pos ~= nil then
							opt:SetPosition(opt.o_pos)
							opt.o_pos = nil
						end
						if control == CONTROL_ACCEPT then
							TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
							self:ShowModDetails(idx, false)
							return true
						end
					end
				end

			opt.GetHelpText = function()
				local controller_id = TheInput:GetControllerID()
    			local t = {}

        		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.HELP.SELECT)

	   			return table.concat(t, "  ")
      		end

			opt.checkbox:Kill()
			opt.checkbox = nil

			opt.image:SetTint(1,1,1,1)

			opt.status:Kill()
			opt.status = nil

			table.insert(self.optionwidgets_server, opt)

			if IsModOutOfDate( modname, v.version ) then
				out_of_date_mods = out_of_date_mods + 1
				opt.out_of_date_image:Show()
			else
				opt.out_of_date_image:Hide()
			end

			if KnownModIndex:HasModConfigurationOptions(modname) then
				opt.configurable_image:Show()
			end
		end
		for _,v in ipairs(self.modnames_server_dl) do
			if not ModNameVersionTableContains( self.modnames_server, v.modname ) then
				local opt = TEMPLATES.ModDLListItem(v.fancy_name)
				table.insert(self.optionwidgets_server, opt)
			end
		end

		-- And make a scrollable list!
		if self.options_scroll_list_client ~= nil then
			self.options_scroll_list_client:SetList(self.optionwidgets_client)
			self.options_scroll_list_server:SetList(self.optionwidgets_server)
		else
			self.options_scroll_list_client = self.optionschildren:AddChild(ScrollableList(self.optionwidgets_client, 183, 566, 93, 3, nil, nil, nil, nil, nil, -22))
			self.options_scroll_list_client:SetPosition(-210, -20)
			self.options_scroll_list_client:SetScale(.8)
			self.options_scroll_list_server = self.optionschildren:AddChild(ScrollableList(self.optionwidgets_server, 183, 566, 93, 3, nil, nil, nil, nil, nil, -22))
			self.options_scroll_list_server:SetPosition(-210, -20)
			self.options_scroll_list_server:SetScale(.8)
		end

		self:SetModsList(self.currentmodtype)
		self:ShowModDetails(mod_index, client_mod_type)

		--update the text on Update All button to indicate how many mods are out of date
		if #self.modnames_client_dl > 0 or #self.modnames_server_dl > 0 then
			--updating
			self.updateallbutton:SetHoverText(STRINGS.UI.MODSSCREEN.UPDATINGMOD)

			self.updateallbutton.out_of_date_image:Show()
			self.updateallbutton.out_of_date_image.count:SetString(tostring(#self.modnames_client_dl + #self.modnames_server_dl))
			self.updateallbutton:Select()
			if self.controller_out_of_date then
				self.controller_out_of_date.image:SetTexture("images/frontend.xml", "circle_red.tex")
				self.controller_out_of_date.count:SetString(tostring(#self.modnames_client_dl + #self.modnames_server_dl))
			end
			self.updateallenabled = false
		elseif out_of_date_mods > 0 then
			self.updateallbutton:SetHoverText(STRINGS.UI.MODSSCREEN.UPDATEALL)
			self.updateallbutton.out_of_date_image:Show()
			self.updateallbutton.out_of_date_image.count:SetString(tostring(out_of_date_mods))
			self.updateallbutton:Unselect()
			if self.controller_out_of_date then
				self.controller_out_of_date.image:SetTexture("images/frontend.xml", "circle_red.tex")
				self.controller_out_of_date.count:SetString(tostring(out_of_date_mods))
			end
			self.updateallenabled = true
		else
			self.updateallbutton:SetHoverText(STRINGS.UI.MODSSCREEN.UPTODATEALL)
			self.updateallbutton.out_of_date_image:Hide()
			self.updateallbutton.out_of_date_image.count:SetString("")
			self.updateallbutton:Select()
			if self.controller_out_of_date then
				self.controller_out_of_date.image:SetTexture("images/frontend.xml", "circle.tex")
				self.controller_out_of_date.count:SetString("0")
			end
			self.updateallenabled = false
		end

		--Note(Peter) do we need to do this focus hookup?
		self:DoFocusHookups()

		TheSim:UnlockModDir()
	end
end

function ModsScreen:SetModsList(listtype)
	self.currentmodtype = listtype

	if self.options_scroll_list_client == nil then
		return
	end

	self:CreateDetailPanel()
	if listtype == "client" then
		self.options_scroll_list_client:Show()
		self.options_scroll_list_server:Hide()
		self:DoFocusHookups()
		--#srosen this is making the first entry in the list flash when we switch tabs, which is ugly
		self.modtypetitle:SetString(STRINGS.UI.MODSSCREEN.CLIENTMODS)
		if self.clientmodsbutton.shown then self.clientmodsbutton:Select() end
		if self.servermodsbutton.shown then self.servermodsbutton:Unselect() end

		local idx = 1
		for i,v in ipairs(self.modnames_client) do
			if self.last_client_modname == v.modname then
				idx = i
				break
			end
		end
		self:ShowModDetails(idx, true)
	elseif listtype == "server" then
		self.options_scroll_list_client:Hide()
		self.options_scroll_list_server:Show()
		self:DoFocusHookups()
		--#srosen this is making the first entry in the list flash when we switch tabs, which is ugly
		self.modtypetitle:SetString(STRINGS.UI.MODSSCREEN.SERVERMODS_TITLE_GENERIC)
		if self.clientmodsbutton.shown then self.clientmodsbutton:Unselect() end
		if self.servermodsbutton.shown then self.servermodsbutton:Select() end

		local idx = 1
		for i,v in ipairs(self.modnames_server) do
			if self.last_server_modname == v.modname then
				idx = i
				break
			end
		end
		self:ShowModDetails(idx, false)
	end
end

function ModsScreen:DoFocusHookups()

    local function tomiddlecol()
    	if self.currentmodtype == "client" then
			return self.options_scroll_list_client
		elseif self.currentmodtype == "server" then
			return self.options_scroll_list_server
		end
	end

	self.servermodsbutton:SetFocusChangeDir(MOVE_RIGHT, tomiddlecol)
	self.servermodsbutton:SetFocusChangeDir(MOVE_DOWN, self.clientmodsbutton)
	self.clientmodsbutton:SetFocusChangeDir(MOVE_UP, self.servermodsbutton)
	self.clientmodsbutton:SetFocusChangeDir(MOVE_RIGHT, tomiddlecol)
	self.clientmodsbutton:SetFocusChangeDir(MOVE_DOWN, self.cancelbutton)

	if self.options_scroll_list_client then
		self.options_scroll_list_client:SetFocusChangeDir(MOVE_RIGHT, self.modconfigbutton)
		self.options_scroll_list_client:SetFocusChangeDir(MOVE_LEFT, self.servermodsbutton)
	end

	if self.options_scroll_list_server then
		self.options_scroll_list_server:SetFocusChangeDir(MOVE_RIGHT, self.modconfigbutton)
		self.options_scroll_list_server:SetFocusChangeDir(MOVE_LEFT, self.servermodsbutton)
	end

	self.featuredbutton:SetFocusChangeDir(MOVE_UP, self.modlinks[5])
	self.featuredbutton:SetFocusChangeDir(MOVE_LEFT, self.modlinkbutton)
	self.featuredbutton:SetFocusChangeDir(MOVE_DOWN, self.morebutton)

	self.morebutton:SetFocusChangeDir(MOVE_UP, self.featuredbutton)
	self.morebutton:SetFocusChangeDir(MOVE_LEFT, self.modlinkbutton)
	self.morebutton:SetFocusChangeDir(MOVE_DOWN, self.applybutton)

	if self.modlinks then
		for i = 1, 5 do
			if self.modlinks[i+1] ~= nil then
				self.modlinks[i]:SetFocusChangeDir(MOVE_DOWN, self.modlinks[i+1])
			else
				self.modlinks[i]:SetFocusChangeDir(MOVE_DOWN, self.featuredbutton)
			end

			if self.modlinks[i-1] ~= nil then
				self.modlinks[i]:SetFocusChangeDir(MOVE_UP, self.modlinks[i-1])
			end

			if self.modlinks[i] ~= nil then
				self.modlinks[i]:SetFocusChangeDir(MOVE_LEFT, self.modlinkbutton)
			end
		end
	end

	self.cancelbutton:SetFocusChangeDir(MOVE_RIGHT, self.cleanallbutton)
	self.cancelbutton:SetFocusChangeDir(MOVE_UP, self.clientmodsbutton)

	self.cleanallbutton:SetFocusChangeDir(MOVE_LEFT, self.cancelbutton)
    self.cleanallbutton:SetFocusChangeDir(MOVE_RIGHT, self.updateallbutton)
    self.cleanallbutton:SetFocusChangeDir(MOVE_UP, tomiddlecol)

    self.updateallbutton:SetFocusChangeDir(MOVE_LEFT, self.cleanallbutton)
    self.updateallbutton:SetFocusChangeDir(MOVE_RIGHT, self.applybutton)
    self.updateallbutton:SetFocusChangeDir(MOVE_UP, tomiddlecol)

	self.applybutton:SetFocusChangeDir(MOVE_RIGHT, self.morebutton)
	self.applybutton:SetFocusChangeDir(MOVE_LEFT, self.updateallbutton)
	self.applybutton:SetFocusChangeDir(MOVE_UP, self.modconfigbutton)

	self.modlinkbutton:SetFocusChangeDir(MOVE_RIGHT, self.morebutton)
	self.modlinkbutton:SetFocusChangeDir(MOVE_LEFT, self.modupdatebutton)
	self.modlinkbutton:SetFocusChangeDir(MOVE_DOWN, self.applybutton)

	self.modupdatebutton:SetFocusChangeDir(MOVE_RIGHT, self.modlinkbutton)
	self.modupdatebutton:SetFocusChangeDir(MOVE_LEFT, self.modconfigbutton)
	self.modupdatebutton:SetFocusChangeDir(MOVE_DOWN, self.applybutton)

	self.modconfigbutton:SetFocusChangeDir(MOVE_LEFT, tomiddlecol)
	self.modconfigbutton:SetFocusChangeDir(MOVE_RIGHT, self.modupdatebutton)
	self.modconfigbutton:SetFocusChangeDir(MOVE_DOWN, self.applybutton)

	if TheInput:ControllerAttached() then
		if self.applybutton then self.applybutton:Hide() end
		if self.cancelbutton then self.cancelbutton:Hide() end
	end
end

function ModsScreen:OnControl(control, down)
	if ModsScreen._base.OnControl(self, control, down) then return true end

	if not down then
		if control == CONTROL_CANCEL then
			self:Cancel()
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			return true
		elseif TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
			if control == CONTROL_MENU_START then
				self:Apply()
				TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
				return true
			elseif control == CONTROL_MENU_BACK then
				self:CleanAllButton()
				TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
				return true
			elseif control == CONTROL_MENU_MISC_2 then
				self:UpdateAllButton()
				TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
				return true
			end
		end
	end

end


function ModsScreen:RefreshControls()
   self:DoFocusHookups()
end


function ModsScreen:GetBestModStatus(modname)
	local modinfo = KnownModIndex:GetModInfo(modname)
	if KnownModIndex:IsModEnabled(modname) then
		return "WORKING_NORMALLY"
	else
		if KnownModIndex:GetModInfo(modname).failed or KnownModIndex:IsModKnownBad(modname) then
			return "DISABLED_ERROR"
		else
			return "DISABLED_MANUAL"
		end
	end
end

local splitChars = {" ", "-", "_", "|", "/", "\\", "+", "=", "(", ")", ".", ",", "~", "*", "[", "]", "<", ">"}

function ModsScreen:ShowModDetails(idx, client_mod)
	local widgetTable = client_mod and self.optionwidgets_client or self.optionwidgets_server
	local modnames_versions = client_mod and self.modnames_client or self.modnames_server
	local modWidget
	if widgetTable and #widgetTable > 0 and modnames_versions and #modnames_versions > 0 then
		for k,_ in pairs(widgetTable) do
			widgetTable[k].white_bg:SetTint(1,1,1,1)
			widgetTable[k].name:SetColour(0,0,0,1)
		end
        modWidget = widgetTable[idx]
		modWidget.white_bg:SetTint(0,0,0,1)
        modWidget.name:SetColour(1,1,1,1)
    else
		self.currentmodname = nil
		return --no list to populate
    end

	local modname = modnames_versions[idx].modname
	if modname == nil then
		self.currentmodname = nil
		return --no actual mod found, it's probably in the download list
	end
	self.currentmodname = modname
	if client_mod then
        self.last_client_modname = self.currentmodname
    else
        self.last_server_modname = self.currentmodname
    end

	local modinfo = KnownModIndex:GetModInfo(modname)
	if modinfo.icon and modinfo.icon_atlas then
		self.detailimage:SetTexture(modinfo.icon_atlas, modinfo.icon)
		self.detailimage:SetSize(102, 102)
	else
		self.detailimage:SetTexture("images/ui.xml", "portrait_bg.tex")
		self.detailimage:SetSize(102, 102)
	end

    self.detailtitle:SetMultilineTruncatedString(modinfo.name or modname, 2, 400, 65, true)
    local nameLines = self.detailtitle:GetString():split("\n")
    if #nameLines > 1 then
        self.detailtitle:SetString(nameLines[1])
        print(self.detailtitle:GetString():len())
        local w = self.detailtitle:GetRegionSize()
        self.detailtitle:SetPosition(title_x + w * .5, 189)
        self.detailtitle2:SetString(nameLines[2])
    else
        local w = self.detailtitle:GetRegionSize()
        self.detailtitle:SetPosition(title_x + w * .5, 165)
        self.detailtitle2:SetString("")
    end

    self.detailauthor:SetTruncatedString(string.format(STRINGS.UI.MODSSCREEN.AUTHORBY, modinfo.author or "unknown"), 400, 105, true)
    local w, h = self.detailauthor:GetRegionSize()
    self.detailauthor:SetPosition(title_x + w * .5, 125)

    self.detaildesc:SetMultilineTruncatedString(modinfo.description or "", 14, 510, 163, true)
    w, h = self.detaildesc:GetRegionSize()
    self.detaildesc:SetPosition(w * .5 - 183, 84 - .5 * h)

	-- if self.modlinkbutton then
	-- 	if (modinfo.forumthread and modinfo.forumthread ~= "") or string.sub(modname, 1, 9) == "workshop-" then
	-- 		self.modlinkbutton:SetText(STRINGS.UI.MODSSCREEN.MODLINK)
	-- 	else
	-- 		self.modlinkbutton:SetText(STRINGS.UI.MODSSCREEN.MODLINKGENERIC)
	-- 	end
	-- end

	if modinfo.dst_compatible then
		if modinfo.dst_compatibility_specified == false then
			self.detailcompatibility:SetString(STRINGS.UI.MODSSCREEN.COMPATIBILITY_UNKNOWN)
		else
			self.detailcompatibility:SetString(STRINGS.UI.MODSSCREEN.COMPATIBILITY_DST)
		end
	else
		self.detailcompatibility:SetString(STRINGS.UI.MODSSCREEN.COMPATIBILITY_NONE)
	end

	if KnownModIndex:HasModConfigurationOptions(modname) then
		self:EnableConfigButton(modWidget)
	else
		self:DisableConfigButton(modWidget)
	end

	--is workshop mod and is out of date version, and check if it's updating currently
	if IsModOutOfDate( modname, modnames_versions[idx].version ) then
		local is_updating = false
		for _,dl_table in pairs( {self.modnames_client_dl, self.modnames_server_dl} ) do
			for _,v in ipairs(dl_table) do
				if v.modname == modname then
					is_updating = true
					break
				end
			end
		end
		if is_updating then
			self:DisableUpdateButton("updating")
		else
			self:EnableUpdateButton(idx)
		end
	else
		self:DisableUpdateButton("uptodate")
	end

	---------------------------------------------
	-- TODO: enable/disable update button here (similar to config button)
	---------------------------------------------

	local modStatus = self:GetBestModStatus(modname)
    if modStatus == "WORKING_NORMALLY" then
        self.detailwarning:SetString(STRINGS.UI.MODSSCREEN.WORKING_NORMALLY)
        self.detailwarning:SetColour(59/255, 222/255, 99/255, 1)
        if widgetTable and widgetTable[idx] and widgetTable[idx].status then
            widgetTable[idx].status:SetString(STRINGS.UI.MODSSCREEN.STATUS.WORKING_NORMALLY)
            widgetTable[idx].status:SetColour(59/255, 222/255, 99/255, 1)
        end
    elseif modStatus == "DISABLED_ERROR" then
        self.detailwarning:SetColour(242/255, 99/255, 99/255, 1) --(242/255, 99/255, 99/255, 1)--0.9,0.3,0.3,1)
        self.detailwarning:SetString(STRINGS.UI.MODSSCREEN.DISABLED_ERROR)
        if widgetTable and widgetTable[idx] and widgetTable[idx].status then
            widgetTable[idx].status:SetColour(242/255, 99/255, 99/255, 1)
            widgetTable[idx].status:SetString(STRINGS.UI.MODSSCREEN.STATUS.DISABLED_ERROR)
        end
    elseif modStatus == "DISABLED_MANUAL" then
        self.detailwarning:SetString(STRINGS.UI.MODSSCREEN.DISABLED_MANUAL)
        self.detailwarning:SetColour(.6,.6,.6,1)
        if widgetTable and widgetTable[idx] and widgetTable[idx].status then
            widgetTable[idx].status:SetColour(.6,.6,.6,1)
            widgetTable[idx].status:SetString(STRINGS.UI.MODSSCREEN.STATUS.DISABLED_MANUAL)
        end
    end

    if not client_mod then
    	self.detailwarning:SetString(STRINGS.UI.MODSSCREEN.VIEW_AND_CONFIGURE)
        -- self.detailwarning:SetColour(.6,.6,.6,1)
        self.detailwarning:SetColour(WET_TEXT_COLOUR)
    end

	if widgetTable and KnownModIndex:IsModEnabled(modname) then
        widgetTable[idx].image:SetTint(1,1,1,1)
		if widgetTable[idx].checkbox then
			widgetTable[idx].checkbox:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {1,1}, {0,0})
		end
    elseif widgetTable then
    	if client_mod then
        	widgetTable[idx].image:SetTint(1.0,0.5,0.5,1)
        end
		if widgetTable[idx].checkbox then
			widgetTable[idx].checkbox:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {1,1}, {0,0})
		end
    end
end

function ModsScreen:OnConfirmEnable(restart, modname)
	if KnownModIndex:IsModEnabled(modname) then
		KnownModIndex:Disable(modname)
	else
		KnownModIndex:Enable(modname)
	end

	local modinfo = KnownModIndex:GetModInfo(modname)

	--Warn about incompatible mods being enabled
	if KnownModIndex:IsModEnabled(modname) and (not modinfo.dst_compatible or modinfo.dst_compatibility_specified == false) then
		TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MODSSCREEN.MOD_WARNING_TITLE, STRINGS.UI.MODSSCREEN.DST_COMPAT_WARNING,
		{
			{text=STRINGS.UI.MODSSCREEN.OK, cb = function() TheFrontEnd:PopScreen() end }
		}))
	end

	self:MakeDirty()

	if restart then
		KnownModIndex:Save()
		TheSim:Quit()
	end
end

function ModsScreen:EnableCurrent(idx)
	local modname = nil
	if self.currentmodtype == "client" then
		modname = self.modnames_client[idx].modname
	end

	local modinfo = KnownModIndex:GetModInfo(modname)

	if modinfo and modinfo.restart_required then
		print("RESTART REQUIRED")
		TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MODSSCREEN.RESTART_TITLE, STRINGS.UI.MODSSCREEN.RESTART_REQUIRED,
		{
			{text=STRINGS.UI.MODSSCREEN.RESTART, cb = function() self:OnConfirmEnable(true, modname) end },
			{text=STRINGS.UI.MODSSCREEN.CANCEL, cb = function() TheFrontEnd:PopScreen() end}
		}))
	elseif modname then
		self:OnConfirmEnable(false, modname)
	end
	self:ShowModDetails(idx, true)
end

function ModsScreen:ModLinkCurrent()
    local link_fn = ModManager:GetLinkForMod(self.currentmodname)
    link_fn()
end

function ModsScreen:MoreMods()
	VisitURL("http://forums.kleientertainment.com/files/")
end

function ModsScreen:MoreWorkshopMods()
	VisitURL("http://steamcommunity.com/app/322330/workshop/")
end

function ModsScreen:MakeDirty()
	self.dirty = true
end

function ModsScreen:MakeClean()
	self.dirty = false
end

function ModsScreen:IsDirty()
	return self.dirty
end

function ModsScreen:Cancel(extrapop)
	if self:IsDirty() then
		TheFrontEnd:PushScreen(
            PopupDialogScreen( STRINGS.UI.MODSSCREEN.CANCEL_TITLE, STRINGS.UI.MODSSCREEN.CANCEL_BODY,
              {
                {
                    text = STRINGS.UI.MODSSCREEN.OK,
                    cb = function()
                        self:MakeClean()
				        if self.updatetask then
							self.updatetask:Cancel()
							self.updatetask = nil
						end

						KnownModIndex:RestoreCachedSaveData()
						self.mainmenu:Disable()
						TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()
							self:UnloadModInfoPrefabs(self.infoprefabs)
							if extrapop then TheFrontEnd:PopScreen() end
							TheFrontEnd:PopScreen()
							TheFrontEnd:PopScreen()
							TheFrontEnd:Fade(FADE_IN, SCREEN_FADE_TIME)
						end)
                    end
                },

                {
                    text = STRINGS.UI.MODSSCREEN.CANCEL,
                    cb = function()
                        TheFrontEnd:PopScreen()
                    end
                }
              }
            )
        )
	else
		if self.updatetask then
			self.updatetask:Cancel()
			self.updatetask = nil
		end

		KnownModIndex:RestoreCachedSaveData()
		self.mainmenu:Disable()
		TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()
			self:UnloadModInfoPrefabs(self.infoprefabs)
			if extrapop then TheFrontEnd:PopScreen() end
			TheFrontEnd:PopScreen()
			TheFrontEnd:Fade(FADE_IN, SCREEN_FADE_TIME)
		end)
	end
end

function ModsScreen:Apply()
	if self.updatetask then
		self.updatetask:Cancel()
		self.updatetask = nil
	end

	KnownModIndex:Save()
	self.mainmenu:Disable()
	TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()
		self:UnloadModInfoPrefabs(self.infoprefabs)
		ForceAssetReset()
		SimReset()
	end)
end

function ModsScreen:ConfigureSelectedMod()
	if self.modconfigable then
		local modinfo = KnownModIndex:GetModInfo(self.currentmodname)
		self.mainmenu:Disable()
		TheFrontEnd:PushScreen(ModConfigurationScreen(self.currentmodname, true))
	end
end

function ModsScreen:UpdateSelectedMod()
	if self.modupdateable then
		TheSim:UpdateWorkshopMod(self.currentmodname)
		self:UpdateForWorkshop()
	end
end

function ModsScreen:LoadModInfoPrefabs(prefabtable)
	for i,modname in ipairs(KnownModIndex:GetModNames()) do
		local info = KnownModIndex:GetModInfo(modname)
		if info.icon_atlas and info.iconpath then
			local modinfoassets = {
				Asset("ATLAS", info.icon_atlas),
				Asset("IMAGE", info.iconpath),
			}
			local prefab = Prefab("MODSCREEN_"..modname, nil, modinfoassets, nil)
			RegisterSinglePrefab( prefab )
			table.insert(prefabtable, prefab.name)
		end
	end

	TheSim:LoadPrefabs( prefabtable )
end

function ModsScreen:UnloadModInfoPrefabs(prefabtable)
	TheSim:UnloadPrefabs( prefabtable )
	for k,v in pairs(prefabtable) do
		prefabtable[k] = nil
	end
end

function ModsScreen:ReloadModInfoPrefabs()
	-- load before unload -- this prevents the refcounts of prefabs from going 1,
	-- 0, 1 (which triggers a resource unload and crashes). Instead we load first,
	-- so the refcount goes 1, 2, 1 for existing prefabs so everything stays the
	-- same.
	local oldprefabs = self.infoprefabs
	local newprefabs = {}
	self:LoadModInfoPrefabs(newprefabs)
	self:UnloadModInfoPrefabs(oldprefabs)
	self.infoprefabs = newprefabs
end

function ModsScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_BACK) .. " " .. STRINGS.UI.MODSSCREEN.CLEANALL)

    if self.updateallenabled then
    	table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2) .. " " .. STRINGS.UI.MODSSCREEN.UPDATEALL)
    end

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_START) .. " " .. STRINGS.UI.MODSSCREEN.APPLY)

    return table.concat(t, "  ")
end

function ModsScreen:CleanAllButton()
	local mod_warning = PopupDialogScreen(STRINGS.UI.MODSSCREEN.CLEANALL_TITLE, STRINGS.UI.MODSSCREEN.CLEANALL_BODY,
		{
			{text=STRINGS.UI.SERVERLISTINGSCREEN.OK, cb =
				function()
					TheSim:CleanAllMods()

					KnownModIndex:DisableAllMods()
					KnownModIndex:Save()

					if self.options_scroll_list_client ~= nil then
						self.options_scroll_list_client:Clear()
						self.options_scroll_list_server:Clear()
					end
					TheFrontEnd:PopScreen()

					self.mainmenu:Disable()
					TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()

						self:UnloadModInfoPrefabs(self.infoprefabs)
						ForceAssetReset()
						SimReset()
					end)
				end},
			{text=STRINGS.UI.SERVERLISTINGSCREEN.CANCEL, cb = function() TheFrontEnd:PopScreen() end}
		}
	)
	TheFrontEnd:PushScreen( mod_warning )
end

function ModsScreen:UpdateAllButton()
	if self.updateallenabled then
		local mod_warning = PopupDialogScreen(STRINGS.UI.MODSSCREEN.UPDATEALL_TITLE, STRINGS.UI.MODSSCREEN.UPDATEALL_BODY,
			{
				{text=STRINGS.UI.SERVERLISTINGSCREEN.OK, cb =
					function()
						for _,name_version in pairs(self.modnames_client) do
							if IsWorkshopMod(name_version.modname) and name_version.version ~= "" and name_version.version ~= KnownModIndex:GetModInfo(name_version.modname).version then
								TheSim:UpdateWorkshopMod(name_version.modname)
							end
						end
						for _,name_version in pairs(self.modnames_server) do
							if IsWorkshopMod(name_version.modname) and name_version.version ~= "" and name_version.version ~= KnownModIndex:GetModInfo(name_version.modname).version then
								TheSim:UpdateWorkshopMod(name_version.modname)
							end
						end
						self:UpdateForWorkshop()

						TheFrontEnd:PopScreen()
					end},
				{text=STRINGS.UI.SERVERLISTINGSCREEN.CANCEL, cb = function() TheFrontEnd:PopScreen() end}
			}
		)
		TheFrontEnd:PushScreen( mod_warning )
	end
end

return ModsScreen
