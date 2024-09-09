local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Menu = require "widgets/menu"
local ScrollableList = require "widgets/scrollablelist"

local TEMPLATES = require "widgets/templates"
local PopupDialogScreen = require "screens/popupdialog"

local ModConfigurationScreen = require "screens/modconfigurationscreen"

local DISABLE = 0
local ENABLE = 1

local mid_col = RESOLUTION_X*.07
local left_col = -RESOLUTION_X*.3
local right_col = RESOLUTION_X*.37

local ModsTab = Class(Widget, function(self, servercreationscreen)
    Widget._ctor(self, "ModsTab")

    self.mods_page = self:AddChild(Widget("mods_page"))

    self.slotnum = -1

    self.servercreationscreen = servercreationscreen

	self.currentmodtype = ""

    -- save current mod index before user configuration
    KnownModIndex:CacheSaveData()
    -- get the latest mod info
    KnownModIndex:UpdateModInfo()

    self.infoprefabs = {}

    self.nav_bar = self.mods_page:AddChild(TEMPLATES.NavBarWithScreenTitle(nil, "short"))
    self.servermodsbutton = self.nav_bar:AddChild(TEMPLATES.NavBarButton(25, STRINGS.UI.MODSSCREEN.SERVERMODS, function() self:SetModsList("server") end))
    self.clientmodsbutton = self.nav_bar:AddChild(TEMPLATES.NavBarButton(-25, STRINGS.UI.MODSSCREEN.CLIENTMODS, function() self:SetModsList("client") end))

    self.servermodsbutton.active_page_image:SetScale(.55,.65)
    self.clientmodsbutton.active_page_image:SetScale(.55,.65)

    self.nav_bar.bg:SetPosition(-5, 0)
    self.nav_bar:SetScale(.85, .8)
    self.nav_bar:SetPosition(-RESOLUTION_X*.364, RESOLUTION_Y*.192)

    self.left_line = self.mods_page:AddChild(Image("images/ui.xml", "line_vertical_5.tex"))
    self.left_line:SetScale(1, .59)
    self.left_line:SetPosition(-380, 5, 0)
    self.left_line:MoveToBack()

    self.middle_line = self.mods_page:AddChild(Image("images/ui.xml", "line_vertical_5.tex"))
    self.middle_line:SetScale(1, .59)
    self.middle_line:SetPosition(-83, 5, 0)

    self.mainmenu = self.mods_page:AddChild(Menu(nil, 0, true))
    self.mainmenu:SetPosition(mid_col, -155, 0)

    self.modconfigbutton = self.mainmenu:AddCustomItem(TEMPLATES.IconButton("images/button_icons.xml", "configure_mod.tex", STRINGS.UI.MODSSCREEN.CONFIGUREMOD, false, false, function() self:ConfigureSelectedMod() end), Vector3(40, 0, 0))
    self.modconfigable = false

    self.modupdatebutton = self.mainmenu:AddCustomItem(TEMPLATES.IconButton("images/button_icons.xml", "update.tex", STRINGS.UI.MODSSCREEN.UPDATEMOD, false, false, function() self:UpdateSelectedMod() end), Vector3(110, -0, 0))
    self.modupdateable = false

    self.modlinkbutton = self.mainmenu:AddCustomItem(TEMPLATES.IconButton("images/button_icons.xml", "more_info.tex", STRINGS.UI.MODSSCREEN.MODLINK_MOREINFO, false, false, function() self:ModLinkCurrent() end), Vector3(180, 0, 0))

    self.mainmenu:MoveToFront()

    self.cleanallbutton = self.mainmenu:AddCustomItem(TEMPLATES.IconButton("images/button_icons.xml", "clean_all.tex", STRINGS.UI.MODSSCREEN.CLEANALL, false, false, function() self:CleanAllButton() end), Vector3(-587, 0, 0))

    self.updateallbutton = self.mainmenu:AddCustomItem(TEMPLATES.IconButton("images/button_icons.xml", "updateall.tex", STRINGS.UI.MODSSCREEN.UPDATEALL, false, false, function() self:UpdateAllButton() end), Vector3(-517, 0, 0))
    self.updateallbutton.out_of_date_image = self.updateallbutton:AddChild(Image("images/frontend.xml", "circle_red.tex"))
    self.updateallbutton.out_of_date_image:SetScale(.6)
    self.updateallbutton.out_of_date_image:SetPosition(-28,-20)
    self.updateallbutton.out_of_date_image:SetClickable(false)
    self.updateallbutton.out_of_date_image.count = self.updateallbutton.out_of_date_image:AddChild(Text(BUTTONFONT, 30, ""))
    self.updateallbutton.out_of_date_image.count:SetColour(0,0,0,1)
    self.updateallbutton.out_of_date_image.count:SetPosition(2,0)
    self.updateallbutton.out_of_date_image:Hide()

	self.currentmodtype = "server"

    self:SetModsList("server")

    self:DoFocusHookups()

    self.default_focus = self.servermodsbutton
    self.focus_forward = self.servermodsbutton
end)

function ModsTab:DisableConfigButton(modWidget)
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

function ModsTab:EnableConfigButton(modWidget)
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

function ModsTab:DisableUpdateButton(mode)
    self.modupdateable = false

    self.modupdatebutton:Select()

	if mode == "uptodate" then
		self.modupdatebutton:SetHoverText(STRINGS.UI.MODSSCREEN.UPTODATE)
	else
		self.modupdatebutton:SetHoverText(STRINGS.UI.MODSSCREEN.UPDATINGMOD)
	end

    self:DoFocusHookups()
end

function ModsTab:EnableUpdateButton()
    self.modupdateable = true

    if not TheInput:ControllerAttached() then
        if self.modupdatebutton then self.modupdatebutton:Unselect() end
    end

	self.modupdatebutton:SetHoverText(STRINGS.UI.MODSSCREEN.UPDATEMOD)

    self:DoFocusHookups()
end

function ModsTab:SetModsList(listtype)
	self.currentmodtype = listtype

	if self.options_scroll_list_client == nil then
		return
	end

	self:CreateDetailPanel()
    if listtype == "client" then
        if self.options_scroll_list_client then self.options_scroll_list_client:Show() end
        if self.options_scroll_list_server then self.options_scroll_list_server:Hide() end
        self:DoFocusHookups()

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
        if self.options_scroll_list_client then self.options_scroll_list_client:Hide() end
        if self.options_scroll_list_server then self.options_scroll_list_server:Show() end
        self:DoFocusHookups()

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

function ModsTab:CreateDetailPanel()
    if self.detailpanel then
		self.detailpanel:KillAllChildren()
		self.detailpanel:Kill()
	end

    self.detailpanel = self.mods_page:AddChild(Widget("detailpanel"))
    self.detailpanel:SetPosition(115,0,0)

	local num_mods = 0
	if self.currentmodtype == "client" then num_mods = #self.modnames_client else num_mods = #self.modnames_server end

    if num_mods > 0 then
        self.detailimage = self.detailpanel:AddChild(Image("images/ui.xml", "portrait_bg.tex"))
        self.detailimage:SetSize(102, 102)
        self.detailimage:SetScale(0.8,0.8,0.8)
        self.detailimage:SetPosition(-148, 145, 0)

        self.detailtitle = self.detailpanel:AddChild(Text(NEWFONT, 30, ""))
        self.detailtitle:SetPosition(-100, 176)
        self.detailtitle:SetColour(0,0,0,1)

        self.detailtitle2 = self.detailpanel:AddChild(Text(NEWFONT, 30, ""))
        self.detailtitle2:SetHAlign(ANCHOR_LEFT)
        self.detailtitle2:SetPosition(35, 151)
        self.detailtitle2:SetRegionSize(270, 45)
        self.detailtitle2:SetColour(0,0,0,1)

        self.detailauthor = self.detailpanel:AddChild(Text(NEWFONT, 20, ""))
        self.detailauthor:SetColour(0,0,0,1)
        --self.detailauthor:SetColour(0.9,0.8,0.6,1) -- link colour
        self.detailauthor:SetPosition(-100, 128, 0)

        self.detailcompatibility = self.detailpanel:AddChild(Text(NEWFONT, 18, ""))
        self.detailcompatibility:SetColour(0,0,0,1)
        self.detailcompatibility:SetPosition(35, 111, 0)
        self.detailcompatibility:SetRegionSize(270, 30)
        self.detailcompatibility:SetHAlign(ANCHOR_LEFT)

        self.detaildesc = self.detailpanel:AddChild(Text(NEWFONT, 20, ""))
        self.detaildesc:SetColour(0,0,0,1)
        self.detaildesc:SetPosition(-187, 97, 0)
        self.detaildesc:SetHAlign(ANCHOR_LEFT)

        self.detailwarning = self.detailpanel:AddChild(Text(BODYTEXTFONT, 25, ""))
        self.detailwarning:SetColour(0.8,0.6,0.5, 1)
        self.detailwarning:SetPosition(-107, -153, 0)
        self.detailwarning:SetRegionSize( 360, 107 )
        self.detailwarning:EnableWordWrap(true)

        self.modlinkbutton:SetHoverText(STRINGS.UI.MODSSCREEN.MODLINK_MOREINFO)
		self.modlinkbutton:Unselect()
    else
        self.detaildesc = self.detailpanel:AddChild(Text(NEWFONT, 25))
        local no_mods = string.format(STRINGS.UI.MODSSCREEN.NO_MODS_TYPE, self.currentmodtype )
        self.detaildesc:SetString(no_mods)
        self.detaildesc:SetColour(0,0,0,1)
        self.detaildesc:SetPosition(-7, 55, 0)
        self.detaildesc:SetRegionSize( 360, 225 )
        self.detaildesc:EnableWordWrap(true)

		self:DisableConfigButton()
		self:DisableUpdateButton("uptodate")
        self.modlinkbutton:ClearHoverText()
		self.modlinkbutton:Unselect()
    end

    self.mainmenu:MoveToFront()
end

function ModsTab:StartWorkshopUpdate()
    if self.updatetask ~= nil then
        self.updatetask:Cancel()
        self.updatetask = nil
    end

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

function ModsTab:UpdateForWorkshop( force_refresh )
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
		local need_to_udpate = force_refresh
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

		--figure out the current selection after the refresh
		local mod_index = 1
		local client_mod_type = self.client_only
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
							self:ShowModDetails(idx, false)
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

				table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.HELP.SELECT)
				table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_1) .. " " .. STRINGS.UI.HELP.TOGGLE)

				return table.concat(t, "  ")
			end

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
			self.options_scroll_list_client = self.mods_page:AddChild(ScrollableList(self.optionwidgets_client, 183, 450, 90, 3, nil, nil, nil, nil, nil, -15))
			self.options_scroll_list_client:SetPosition(-172, 0)
			self.options_scroll_list_client:SetScale(.8)
			self.options_scroll_list_server = self.mods_page:AddChild(ScrollableList(self.optionwidgets_server, 183, 450, 90, 3, nil, nil, nil, nil, nil, -15))
			self.options_scroll_list_server:SetPosition(-172, 0)
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
			self.updateallenabled = false
		elseif out_of_date_mods > 0 then
			self.updateallbutton:SetHoverText(STRINGS.UI.MODSSCREEN.UPDATEALL)
			self.updateallbutton.out_of_date_image:Show()
			self.updateallbutton.out_of_date_image.count:SetString(tostring(out_of_date_mods))
			self.updateallbutton:Unselect()
			self.updateallenabled = true
		else
			self.updateallbutton:SetHoverText(STRINGS.UI.MODSSCREEN.UPTODATEALL)
			self.updateallbutton.out_of_date_image:Hide()
			self.updateallbutton.out_of_date_image.count:SetString("")
			self.updateallbutton:Select()
			self.updateallenabled = false
		end

		--Note(Peter) do we need to do this focus hookup?
		self:DoFocusHookups()

		TheSim:UnlockModDir()
	end
end

function ModsTab:GetOutOfDateEnabledMods()
    local outofdate = {}
    local enabled = ModManager:GetEnabledServerModNames()

    for i,v in pairs(enabled) do
        local version = IsWorkshopMod(v) and TheSim:GetWorkshopVersion(v) or ""
        if IsModOutOfDate( v, version ) then
            table.insert(outofdate, v)
        end
    end

    return outofdate
end

function ModsTab:OnConfirmEnable(restart, modname)
    if KnownModIndex:IsModEnabled(modname) then
        ModManager:FrontendUnloadMod(modname)
		KnownModIndex:Disable(modname)
	else
		KnownModIndex:Enable(modname)
        ModManager:FrontendLoadMod(modname)
	end

    --show the auto-download warning for non-workshop mods
    local modinfo = KnownModIndex:GetModInfo(modname)
    if KnownModIndex:IsModEnabled(modname) and modinfo.all_clients_require_mod then
        if not IsWorkshopMod(modname) then
			local warn_txt = STRINGS.UI.MODSSCREEN.MOD_WARNING
			if IsRail() then
				warn_txt = STRINGS.UI.MODSSCREEN.MOD_WARNING_RAIL
			end
			TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MODSSCREEN.MOD_WARNING_TITLE, warn_txt,
            {
                {text=STRINGS.UI.MODSSCREEN.OK, cb = function() TheFrontEnd:PopScreen() end }
            }))
        end
    end

    --Warn about incompatible mods being enabled
    if KnownModIndex:IsModEnabled(modname) and (not modinfo.dst_compatible or modinfo.dst_compatibility_specified == false) then
        TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MODSSCREEN.MOD_WARNING_TITLE, STRINGS.UI.MODSSCREEN.DST_COMPAT_WARNING,
        {
            {text=STRINGS.UI.MODSSCREEN.OK, cb = function() TheFrontEnd:PopScreen() end }
        }))
    end

    self.servercreationscreen:UpdateModeSpinner(self.slotnum)
    self.servercreationscreen:UpdateButtons(self.slotnum)
    self.servercreationscreen:MakeDirty()
    self.servercreationscreen.world_tab:Refresh()

    if restart then
        KnownModIndex:Save()
        TheSim:Quit()
    end
end

function ModsTab:EnableCurrent(idx)
    local modname = nil
	if self.currentmodtype == "client" then
		modname = self.modnames_client[idx].modname
	elseif not self.client_only then
		modname = self.modnames_server[idx].modname
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
	self:ShowModDetails(idx, self.currentmodtype == "client")
end

function ModsTab:GetBestModStatus(modname)
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

function ModsTab:ShowModDetails(idx, client_mod)
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
	if modinfo == nil then
		return
	end
    if modinfo.icon and modinfo.icon_atlas then
        self.detailimage:SetTexture(modinfo.icon_atlas, modinfo.icon)
        self.detailimage:SetSize(102, 102)
    else
        self.detailimage:SetTexture("images/ui.xml", "portrait_bg.tex")
        self.detailimage:SetSize(102, 102)
    end

    self.detailtitle:SetMultilineTruncatedString(modinfo.name or modname, 2, 270, 60, true)
    local nameLines = self.detailtitle:GetString():split("\n")
    if #nameLines > 1 then
        self.detailtitle:SetString(nameLines[1])
        local w = self.detailtitle:GetRegionSize()
        self.detailtitle:SetPosition(w * .5 - 100, 176)
        self.detailtitle2:SetString(nameLines[2])
    else
        local w = self.detailtitle:GetRegionSize()
        self.detailtitle:SetPosition(w * .5 - 100, 160)
        self.detailtitle2:SetString("")
    end

    self.detailauthor:SetTruncatedString(string.format(STRINGS.UI.MODSSCREEN.AUTHORBY, modinfo.author or "unknown"), 270, 88, true)
    local w, h = self.detailauthor:GetRegionSize()
    self.detailauthor:SetPosition(w * .5 - 100, 128)

    self.detaildesc:SetMultilineTruncatedString(modinfo.description or "", 11, 360, 77, true)
    w, h = self.detaildesc:GetRegionSize()
    self.detaildesc:SetPosition(w * .5 - 187, 97 - .5 * h)

    -- if self.modlinkbutton then
    --     if (modinfo.forumthread and modinfo.forumthread ~= "") or string.sub(modname, 1, 9) == "workshop-" then
    --         self.modlinkbutton:SetText(STRINGS.UI.MODSSCREEN.MODLINK)
    --     else
    --         self.modlinkbutton:SetText(STRINGS.UI.MODSSCREEN.MODLINKGENERIC)
    --     end
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
			self:DisableUpdateButton("updating", idx)
		else
			self:EnableUpdateButton(idx)
		end
	else
		self:DisableUpdateButton("uptodate", idx)
	end

    ---------------------------------------------
    -- TODO: enable/disable update button here (similar to config button)
    ---------------------------------------------

    local modStatus = self:GetBestModStatus(modname)
    if modStatus == "WORKING_NORMALLY" then
        self.detailwarning:SetString(STRINGS.UI.MODSSCREEN.WORKING_NORMALLY)
        self.detailwarning:SetColour(59/255, 222/255, 99/255, 1)
        if widgetTable then
            widgetTable[idx].status:SetString(STRINGS.UI.MODSSCREEN.STATUS.WORKING_NORMALLY)
            widgetTable[idx].status:SetColour(59/255, 222/255, 99/255, 1)
        end
    elseif modStatus == "DISABLED_ERROR" then
        self.detailwarning:SetColour(242/255, 99/255, 99/255, 1) --(242/255, 99/255, 99/255, 1)--0.9,0.3,0.3,1)
        self.detailwarning:SetString(STRINGS.UI.MODSSCREEN.DISABLED_ERROR)
        if widgetTable then
            widgetTable[idx].status:SetColour(242/255, 99/255, 99/255, 1)
            widgetTable[idx].status:SetString(STRINGS.UI.MODSSCREEN.STATUS.DISABLED_ERROR)
        end
    elseif modStatus == "DISABLED_MANUAL" then
        self.detailwarning:SetString(STRINGS.UI.MODSSCREEN.DISABLED_MANUAL)
        self.detailwarning:SetColour(.6,.6,.6,1)
        if widgetTable then
            widgetTable[idx].status:SetColour(.6,.6,.6,1)
            widgetTable[idx].status:SetString(STRINGS.UI.MODSSCREEN.STATUS.DISABLED_MANUAL)
        end
    end

    if widgetTable and KnownModIndex:IsModEnabled(modname) then
        widgetTable[idx].image:SetTint(1,1,1,1)
		if widgetTable[idx].checkbox then
			widgetTable[idx].checkbox:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {1,1}, {0,0})
		end
    elseif widgetTable then
        widgetTable[idx].image:SetTint(1.0,0.5,0.5,1)
		if widgetTable[idx].checkbox then
			widgetTable[idx].checkbox:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {1,1}, {0,0})
		end
    end
end

function ModsTab:LoadModInfoPrefabs(prefabtable)
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

function ModsTab:UnloadModInfoPrefabs(prefabtable)
    TheSim:UnloadPrefabs( prefabtable )
    for k,v in pairs(prefabtable) do
        prefabtable[k] = nil
    end
end

function ModsTab:ReloadModInfoPrefabs()
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

function ModsTab:ModLinkCurrent()
    local link_fn = ModManager:GetLinkForMod(self.currentmodname)
    link_fn()
end

function ModsTab:MoreMods()
    VisitURL("http://forums.kleientertainment.com/files/")
end

function ModsTab:MoreWorkshopMods()
    VisitURL("http://steamcommunity.com/app/322330/workshop/")
end

function ModsTab:SetTopModsPanel(panel)
    self.top_mods_panel = panel

    self:DoFocusHookups()
end

function ModsTab:Cancel()
	if self.updatetask then
		self.updatetask:Cancel()
		self.updatetask = nil
	end

    ModManager:FrontendUnloadMod(nil) -- all mods
    KnownModIndex:RestoreCachedSaveData()
    self:UnloadModInfoPrefabs(self.infoprefabs)
end

function ModsTab:Apply()
    -- Note: After "apply", the mods tab is no longer in a working state, it must be restarted with :StartWorkshopUpdate()
	if self.updatetask then
		self.updatetask:Cancel()
		self.updatetask = nil
	end

    KnownModIndex:Save()
    SaveGameIndex:SetServerEnabledMods( self.slotnum )
    SaveGameIndex:Save()
end

function ModsTab:OnDestroy()
	if self.updatetask then
		self.updatetask:Cancel()
		self.updatetask = nil
	end
    self:UnloadModInfoPrefabs(self.infoprefabs)
end

function ModsTab:OnBecomeActive()
    self:StartWorkshopUpdate()
end

function ModsTab:ConfigureSelectedMod()
    if self.modconfigable then
        local modinfo = KnownModIndex:GetModInfo(self.currentmodname)
        TheFrontEnd:PushScreen(ModConfigurationScreen(self.currentmodname, false))
    end
end

function ModsTab:UpdateSelectedMod()
    if self.modupdateable then
        TheSim:UpdateWorkshopMod(self.currentmodname)
		self:UpdateForWorkshop()
    end
end

function ModsTab:CleanAllButton()
    local mod_warning = PopupDialogScreen(STRINGS.UI.MODSSCREEN.CLEANALL_TITLE, STRINGS.UI.MODSSCREEN.CLEANALL_BODY,
        {
            {text=STRINGS.UI.SERVERLISTINGSCREEN.OK, cb =
                function()
                    TheSim:CleanAllMods()

                    KnownModIndex:DisableAllMods()
                    KnownModIndex:Save()

					if self.options_scroll_list_client then
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

function ModsTab:UpdateAllButton(force)
    if force then
		if self.modnames_client ~= nil then
			for _,name_version in pairs(self.modnames_client) do
				if IsWorkshopMod(name_version.modname) and name_version.version ~= "" and name_version.version ~= KnownModIndex:GetModInfo(name_version.modname).version then
					TheSim:UpdateWorkshopMod(name_version.modname)
				end
			end
		end
		if self.modnames_server ~= nil then
			for _,name_version in pairs(self.modnames_server) do
				if IsWorkshopMod(name_version.modname) and name_version.version ~= "" and name_version.version ~= KnownModIndex:GetModInfo(name_version.modname).version then
					TheSim:UpdateWorkshopMod(name_version.modname)
				end
			end
		end
        self:UpdateForWorkshop()
	elseif self.updateallenabled then
		local mod_warning = PopupDialogScreen(STRINGS.UI.MODSSCREEN.UPDATEALL_TITLE, STRINGS.UI.MODSSCREEN.UPDATEALL_BODY,
			{
				{text=STRINGS.UI.SERVERLISTINGSCREEN.OK, cb =
					function()
						if self.modnames_client ~= nil then
							for _,name_version in pairs(self.modnames_client) do
								if IsWorkshopMod(name_version.modname) and name_version.version ~= "" and name_version.version ~= KnownModIndex:GetModInfo(name_version.modname).version then
									TheSim:UpdateWorkshopMod(name_version.modname)
								end
							end
						end
						if self.modnames_server ~= nil then
							for _,name_version in pairs(self.modnames_server) do
								if IsWorkshopMod(name_version.modname) and name_version.version ~= "" and name_version.version ~= KnownModIndex:GetModInfo(name_version.modname).version then
									TheSim:UpdateWorkshopMod(name_version.modname)
								end
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

function ModsTab:SetSaveSlot(slotnum, fromDelete)
    if not fromDelete and slotnum == self.slotnum then return end

    ModManager:FrontendUnloadMod(nil) -- all mods

    self.slotnum = slotnum
    SaveGameIndex:LoadServerEnabledModsFromSlot( self.slotnum )

    self:UpdateForWorkshop(true)

    for i, name in ipairs(ModManager:GetEnabledServerModNames()) do
        ModManager:FrontendLoadMod(name)
    end
end

function ModsTab:GetNumberOfModsEnabled()
    return #ModManager:GetEnabledServerModNames()
end

function ModsTab:DoFocusHookups()
    local function tomiddlecol()
        return (self.currentmodtype == "client" and self.options_scroll_list_client)
            or (self.currentmodtype == "server" and self.options_scroll_list_server)
            or nil
	end

    self.servermodsbutton:SetFocusChangeDir(MOVE_RIGHT, tomiddlecol)
    self.clientmodsbutton:SetFocusChangeDir(MOVE_RIGHT, tomiddlecol)
    self.servermodsbutton:SetFocusChangeDir(MOVE_DOWN, self.clientmodsbutton)
    self.clientmodsbutton:SetFocusChangeDir(MOVE_DOWN, self.cleanallbutton)
    self.clientmodsbutton:SetFocusChangeDir(MOVE_UP, self.servermodsbutton)

    if self.options_scroll_list_client then
        self.options_scroll_list_client:SetFocusChangeDir(MOVE_RIGHT, self.modconfigbutton)
        self.options_scroll_list_client:SetFocusChangeDir(MOVE_LEFT, self.servermodsbutton)
    end

    if self.options_scroll_list_server then
        self.options_scroll_list_server:SetFocusChangeDir(MOVE_RIGHT, self.modconfigbutton)
        self.options_scroll_list_server:SetFocusChangeDir(MOVE_LEFT, self.servermodsbutton)
    end

    self.cleanallbutton:SetFocusChangeDir(MOVE_UP, self.clientmodsbutton)
    self.updateallbutton:SetFocusChangeDir(MOVE_UP, self.clientmodsbutton)

    self.cleanallbutton:SetFocusChangeDir(MOVE_RIGHT, self.updateallbutton)
    self.updateallbutton:SetFocusChangeDir(MOVE_RIGHT, tomiddlecol)
    self.updateallbutton:SetFocusChangeDir(MOVE_LEFT, self.cleanallbutton)

    self.modlinkbutton:SetFocusChangeDir(MOVE_LEFT, self.modupdatebutton)

    self.modupdatebutton:SetFocusChangeDir(MOVE_RIGHT, self.modlinkbutton)
    self.modupdatebutton:SetFocusChangeDir(MOVE_LEFT, self.modconfigbutton)

    self.modconfigbutton:SetFocusChangeDir(MOVE_LEFT, tomiddlecol)
    self.modconfigbutton:SetFocusChangeDir(MOVE_RIGHT, self.modupdatebutton)

    if self.top_mods_panel ~= nil then
        self.top_mods_panel:SetFocusChangeDir(MOVE_LEFT, self.modlinkbutton)
        self.modlinkbutton:SetFocusChangeDir(MOVE_RIGHT, self.top_mods_panel.morebutton)
    end
end

return ModsTab
