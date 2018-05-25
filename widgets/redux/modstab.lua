local Widget = require "widgets/widget"
local Subscreener = require "screens/redux/subscreener"
local Text = require "widgets/text"
local TopModsPanel = require "widgets/redux/topmodspanel"
local Image = require "widgets/image"
local Menu = require "widgets/menu"
local TEMPLATES = require "widgets/redux/templates"
local PopupDialogScreen = require "screens/redux/popupdialog"
local ModConfigurationScreen = require "screens/redux/modconfigurationscreen"


local item_width,item_height = 340, 90 -- copied from TEMPLATES.ModListItem

local ModsTab = Class(Widget, function(self, servercreationscreen, settings)
    Widget._ctor(self, "ModsTab")
    self.settings = settings

    self.mods_page = self:AddChild(Widget("mods_page"))
    self.mods_page:SetPosition(10, 10)

    self.slotnum = -1

    self.servercreationscreen = servercreationscreen

    self.currentmodtype = ""

    -- save current mod index before user configuration
    KnownModIndex:CacheSaveData()
    -- get the latest mod info
    KnownModIndex:UpdateModInfo()

    self.infoprefabs = {}

    self:CreateDetailPanel()

    local hovertext_top = {
        offset_x = 2,
        offset_y = 45,
    }
    self.modconfigbutton = TEMPLATES.IconButton("images/button_icons.xml", "configure_mod.tex", STRINGS.UI.MODSSCREEN.CONFIGUREMOD, false, false, function() self:ConfigureSelectedMod() end, hovertext_top)
    self.modconfigable = false

    self.modupdatebutton = TEMPLATES.IconButton("images/button_icons.xml", "update.tex", STRINGS.UI.MODSSCREEN.UPDATEMOD, false, false, function() self:UpdateSelectedMod() end, hovertext_top)
    self.modupdateable = false

    self.modlinkbutton = TEMPLATES.IconButton("images/button_icons.xml", "more_info.tex", STRINGS.UI.MODSSCREEN.MODLINK_MOREINFO, false, false, function() self:ModLinkCurrent() end, hovertext_top)

    -- Options for the mod selected in mods_scroll_list.
    self.selectedmodmenu = self.mods_page:AddChild(Menu({
                { widget = self.modconfigbutton, },
                { widget = self.modupdatebutton, },
                { widget = self.modlinkbutton, },
        }, 65, true))
    self.selectedmodmenu:SetPosition(260, -250)
    self.selectedmodmenu:MoveToFront()

    -- When mods are empty. Clobbered when mod list is populated.
    self.mods_page.focus_forward = self.selectedmodmenu

    local hovertext_side = {
        offset_x = -60,
        offset_y = 5,
    }
    self.cleanallbutton = TEMPLATES.IconButton("images/button_icons.xml", "clean_all.tex", STRINGS.UI.MODSSCREEN.CLEANALL, false, false, function() self:CleanAllButton() end, hovertext_side)

    local function BuildOutOfDateBadge()
        local out_of_date = Image()
        out_of_date:SetScale(.6)
        out_of_date:SetClickable(false)
        out_of_date.count = out_of_date:AddChild(Text(CHATFONT, 30, ""))
        out_of_date.count:SetRegionSize(40, 30)
        out_of_date.count:SetHAlign(ANCHOR_MIDDLE)
        out_of_date.count:SetColour(UICOLOURS.BLACK)
        out_of_date.count:SetPosition(1,1)
        out_of_date.SetCount = function(_, new_count)
            out_of_date.count:SetString(tostring(new_count))
            out_of_date.updatevisibility_fn(new_count)
            if new_count > 0 then
                out_of_date:SetTexture("images/frontend.xml", "circle_red.tex")
            else
                out_of_date:SetTexture("images/frontend.xml", "circle.tex")
            end
        end
        out_of_date.updatevisibility_fn = function(count)
            if count > 0 then
                out_of_date:Show()
            else
                out_of_date:Hide()
            end
        end
        return out_of_date
    end

    self.updateallbutton = TEMPLATES.IconButton("images/button_icons.xml", "updateall.tex", STRINGS.UI.MODSSCREEN.UPDATEALL, false, false, function() self:UpdateAllButton() end, hovertext_side)
    self.out_of_date_badge = self.updateallbutton:AddChild(BuildOutOfDateBadge())
    self.out_of_date_badge:SetPosition(-22,-20)
    self.out_of_date_badge:SetCount(0)

    self.allmodsmenu = self.mods_page:AddChild(Menu({
                { widget = self.cleanallbutton, },
                { widget = self.updateallbutton, },
        }, 65, true))
    self.allmodsmenu:SetPosition(-420, -323)
    self.servercreationscreen:RepositionModsButtonMenu(self.allmodsmenu, self.selectedmodmenu)

    -- Since we're hiding the update all button, we need to show the
    -- out of date indicator somewhere else.
    if not self.updateallbutton:IsVisible() then
        self.controller_out_of_date = self.mods_page:AddChild(Widget("controller_out_of_date"))
        self.controller_out_of_date:SetPosition(-420, 295)
        self.controller_out_of_date.label = self.controller_out_of_date:AddChild(Text(CHATFONT, 24, STRINGS.UI.MODSSCREEN.OUT_OF_DATE))
        self.controller_out_of_date.label:SetColour(UICOLOURS.GOLD)
        -- Text starts at root's origin.
        local w,h = self.controller_out_of_date.label:GetRegionSize()
        self.controller_out_of_date.label:SetPosition(w/2, 0)

        -- Move badge from update button to out of date text indicator.
        self.out_of_date_badge = self.controller_out_of_date:AddChild(self.out_of_date_badge)
        -- Right after text.
        self.out_of_date_badge:SetPosition(w + 15, -2)

        self.out_of_date_badge.updatevisibility_fn = function() end -- always visible now
        self.out_of_date_badge:Show()
    end


    local function _BuildMenu(screen, subscreener)
        self.tooltip = screen.tooltip or screen.root:AddChild(TEMPLATES.ScreenTooltip())

        local showcase_button = subscreener:MenuButton(STRINGS.UI.MODSSCREEN.SHOWCASEMODS, "showcase", STRINGS.UI.MODSSCREEN.TOOLTIP_SHOWCASEMODS, self.tooltip)
        local server_button = subscreener:MenuButton(STRINGS.UI.MODSSCREEN.SERVERMODS, "server", STRINGS.UI.MODSSCREEN.TOOLTIP_SERVERMODS, self.tooltip)
        local client_button = subscreener:MenuButton(STRINGS.UI.MODSSCREEN.CLIENTMODS, "client", STRINGS.UI.MODSSCREEN.TOOLTIP_CLIENTMODS, self.tooltip)

        local menu_items = {
            {widget = client_button},
            {widget = server_button},
            {widget = showcase_button},
        }

        return self.servercreationscreen:BuildModsMenu(menu_items, subscreener)
    end
    self.subscreener = Subscreener(self.servercreationscreen,
        _BuildMenu,
        {
            -- The mod lists use the same widgets and we just switch which data
            -- is presented in them.
            client = self.mods_page,
            server = self.mods_page,
            showcase = self:AddChild(TopModsPanel()),
        })

    self.subscreener:SetPostMenuSelectionAction(function(selection)
        self:_SetModsList(selection)
    end)

    if self.settings.is_configuring_server then
        self.subscreener.sub_screens.showcase:SetPosition(-50,0) -- server screen doesn't have as much space
        self.subscreener:OnMenuButtonSelected("server")
    else
        -- ModsScreen uses "client" as default: it's more relevant from that
        -- screen (it can apply client mods but only view server mods).
        self.subscreener:OnMenuButtonSelected("client")
    end

    self:DoFocusHookups()

    self.focus_forward = self.subscreener.menu
end)

function ModsTab:DisableConfigButton()
    self.modconfigable = false

    if self.modconfigbutton then
        self.modconfigbutton:Select()
        self.modconfigbutton:SetHoverText(STRINGS.UI.MODSSCREEN.NOCONFIG)
    end

    self:DoFocusHookups()
end

function ModsTab:EnableConfigButton()
    self.modconfigable = true

    if self.modconfigbutton then
        self.modconfigbutton:Unselect()
        self.modconfigbutton:SetHoverText(STRINGS.UI.MODSSCREEN.CONFIGUREMOD)
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

    self.modupdatebutton:Unselect()
    self.modupdatebutton:SetHoverText(STRINGS.UI.MODSSCREEN.UPDATEMOD)

    self:DoFocusHookups()
end

function ModsTab:_SetModsList(listtype)
    local scroll_to = self.currentmodtype ~= listtype
    self.currentmodtype = listtype

    -- Always show details so it can show the empty message (if workshop is
    -- slow, we'll at least have something reasonable visible).
    self.detailpanel:Refresh()

    if self.mods_scroll_list == nil then
        return
    end

    local function ShowLastClickedDetails(last_modname, modnames_list)
        local idx = 1
        for i,v in ipairs(modnames_list) do
            if last_modname == v.modname then
                idx = i
                break
            end
        end
        self:ShowModDetails(idx, self.modnames_client == modnames_list)

        if scroll_to then
            -- On switching tabs, scroll the window to the selected item. (Can't do
            -- on ShowModDetails since it would snap on each click.)
            self.mods_scroll_list:ScrollToDataIndex(idx)
        end
    end

    if listtype == "client" then
        self.mods_scroll_list:SetItemsData(self.optionwidgets_client)
        ShowLastClickedDetails(self.last_client_modname, self.modnames_client)

    elseif listtype == "server" then
        self.mods_scroll_list:SetItemsData(self.optionwidgets_server)
        ShowLastClickedDetails(self.last_server_modname, self.modnames_server)
    end

    self:DoFocusHookups()
end

function ModsTab:CreateDetailPanel()
    self.detailpanel = self.mods_page:AddChild(Widget("detailpanel"))
    self.detailpanel:SetPosition(115,70)

    self.detailpanel.whenfull = self.detailpanel:AddChild(Widget("whenfull"))
    self.detailpanel.whenempty = self.detailpanel:AddChild(Widget("whenempty"))

    local image_width = 90
    local body_width = self.settings.details_width
    local header_width = body_width - image_width
    local header_offset_x = 95

    --
    -- With content
    self.detailimage = self.detailpanel.whenfull:AddChild(Image("images/ui.xml", "portrait_bg.tex"))
    self.detailimage:SetPosition(-148, 145, 0)
    self.detailimage._align = {
        size = {image_width,image_width},
    }

    self.detailtitle = self.detailpanel.whenfull:AddChild(Text(HEADERFONT, 26, ""))
    self.detailtitle:SetColour(UICOLOURS.GOLD_SELECTED)
    self.detailtitle:SetHAlign(ANCHOR_LEFT)
    self.detailtitle._align = {
        x = header_offset_x,
        y = 170,
        maxlines = 2,
        width = header_width,
        maxchars = 60,
    }

    self.detailauthor = self.detailpanel.whenfull:AddChild(Text(CHATFONT, 22, ""))
    self.detailauthor:SetColour(UICOLOURS.GOLD)
    self.detailauthor._align = {
        x = header_offset_x,
        y = 135,
        width = header_width,
        maxchars = 88,
    }

    self.detailcompatibility = self.detailpanel.whenfull:AddChild(Text(CHATFONT, 18, ""))
    self.detailcompatibility:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
    self.detailcompatibility:SetPosition(header_width/2 - header_offset_x, 111)
    self.detailcompatibility:SetRegionSize(header_width, 30)
    self.detailcompatibility:SetHAlign(ANCHOR_LEFT)

    self.detaildesc = self.detailpanel.whenfull:AddChild(Text(CHATFONT, 22, ""))
    self.detaildesc:SetColour(UICOLOURS.WHITE)
    self.detaildesc:SetHAlign(ANCHOR_LEFT)
    self.detaildesc._align = {
        maxlines = 17,
        width = body_width,
        maxchars = 77,
    }

    self.detailwarning = self.detailpanel.whenfull:AddChild(Text(BODYTEXTFONT, 25, ""))
    self.detailwarning:SetColour(59/255, 222/255, 99/255, 1)
    self.detailwarning:SetPosition(body_width/2 - 190, -320)
    self.detailwarning:SetRegionSize(body_width, 40)
    self.detailwarning:SetHAlign(ANCHOR_LEFT)
    self.detailwarning:EnableWordWrap(true)

    --
    -- No mods to display
    self.detaildesc_empty = self.detailpanel.whenempty:AddChild(Text(CHATFONT, 25))
    self.detaildesc_empty:SetColour(UICOLOURS.GOLD)
    self.detaildesc_empty:SetPosition(-7, 55, 0)
    self.detaildesc_empty:SetRegionSize(body_width, 225)
    self.detaildesc_empty:EnableWordWrap(true)


    self.detailpanel.Refresh = function(_)
        local num_mods = 0
        if self.modnames_client then
            if self.currentmodtype == "client" then
                num_mods = #self.modnames_client
            else
                num_mods = #self.modnames_server
            end
        end

        if num_mods > 0 then
            self.detailpanel.whenfull:Show()
            self.detailpanel.whenempty:Hide()

            self.modlinkbutton:SetHoverText(STRINGS.UI.MODSSCREEN.MODLINK_MOREINFO)
        else
            self.detailpanel.whenfull:Hide()
            self.detailpanel.whenempty:Show()

			local no_mods
			if PLATFORM == "WIN32_RAIL" then
				if TheSim:RAILGetPlatform() == "TGP" then
					no_mods =  (self.currentmodtype == "client") and STRINGS.UI.MODSSCREEN.NO_MODS_CLIENT_TGP or STRINGS.UI.MODSSCREEN.NO_MODS_SERVER_TGP
				else
					no_mods = (self.currentmodtype == "client") and STRINGS.UI.MODSSCREEN.NO_MODS_CLIENT_QQGAME or STRINGS.UI.MODSSCREEN.NO_MODS_SERVER_QQGAME
				end
				self.modlinkbutton:Select()
			else
				no_mods = string.format(STRINGS.UI.MODSSCREEN.NO_MODS_TYPE, self.currentmodtype )
			end
           
            self.detaildesc_empty:SetString(no_mods)
            self:DisableConfigButton()
            self:DisableUpdateButton("uptodate")
            self.modlinkbutton:SetHoverText(STRINGS.UI.MODSSCREEN.MORE_MODS)
        end
    end
end

function ModsTab:_CancelTasks()
    if self.updatetask ~= nil then
        self.updatetask:Cancel()
        self.updatetask = nil
    end
end

function ModsTab:StartWorkshopUpdate()
    self:_CancelTasks()

    self:UpdateForWorkshop()
    self.updatetask = scheduler:ExecutePeriodic( 1, self.UpdateForWorkshop, nil, 0, "updateforworkshop", self )

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
    return IsWorkshopMod(modname) and workshop_version ~= "" and workshop_version ~= (KnownModIndex:GetModInfo(modname) ~= nil and KnownModIndex:GetModInfo(modname).version or "")
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
        if not need_to_udpate or (self.mods_scroll_list and self.mods_scroll_list.dragging) then
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

        -- If no mods, tell the user where to get them.
        if not self.settings.is_configuring_server
            and #self.modnames_client == 0
            and #self.modnames_server == 0
            and #self.modnames_client_dl == 0
            and #self.modnames_server_dl == 0 then

            -- Only show popup one at a time.
            if not self.no_mods_popup then
	            if PLATFORM ~= "WIN32_RAIL" then
					self.no_mods_popup = PopupDialogScreen( STRINGS.UI.MODSSCREEN.NO_MODS_TITLE, STRINGS.UI.MODSSCREEN.NO_MODS,
						{
							-- We don't dismiss the popup! Only dismiss once we
							-- have mods or user backs out.
							{text=STRINGS.UI.MODSSCREEN.NO_MODS_OK, cb = function() ModManager:ShowMoreMods() end },
							{text=STRINGS.UI.MODSSCREEN.CANCEL, cb = function() self:_CancelTasks() TheFrontEnd:PopScreen() self.servercreationscreen:Cancel() end },
						})
					TheFrontEnd:PushScreen(self.no_mods_popup)
				end
            end
        else
            -- We have mods! If we're showing the popup, then dismiss it.
            if self.no_mods_popup then
                TheFrontEnd:PopScreen()
                self.no_mods_popup = nil
            end
        end


        local function ScrollWidgetsCtor(context, index)
            local widget = Widget("widget-".. index)

            widget:SetOnGainFocus(function() self.mods_scroll_list:OnWidgetFocus(widget) end)

            widget.downloaditem = widget:AddChild(TEMPLATES.ModListItem_Downloading())

            widget.moditem = widget:AddChild(TEMPLATES.ModListItem(function()
                self:ShowModDetails(widget.data.index, widget.data.is_client_mod)
            end,
            function()
                self:EnableCurrent(widget.data.index)
            end))
            local opt = widget.moditem


            opt.StartClick = function()
                if widget.data.mod.modname ~= self.currentmodname then
                    self.last_mod_click_time = nil
                end
            end

            opt.FinishClick = function()
                if widget.data.mod.modname == self.currentmodname and self.last_mod_click_time and GetTimeReal() - self.last_mod_click_time <= DOUBLE_CLICK_TIMEOUT then
                    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
                    self:EnableCurrent(widget.data.index)
                    self.last_mod_click_time = nil
                else
                    self.last_mod_click_time = GetTimeReal()
                end
            end

            -- Use implement double clicking here because opt is not
            -- a button and opt's ListItemBackground is selected
            -- after clicking (so it would ignore doubleclicks).
            -- Having nested buttons seems like a worse idea.
            local old_OnControl = opt.backing.OnControl
            opt.backing.OnControl = function(_, control, down)
                -- Process double clicking before base to prevent button from
                -- blocking initial click. No returns because we're only capturing data.
                if down then
                    if control == CONTROL_ACCEPT then
                        opt.StartClick()
                    end
                else
                    if control == CONTROL_ACCEPT then
                        opt.FinishClick()
                    end
                end

                -- Force attempting input on checkbox before the button. Not
                -- sure why we're getting focus first despite it being our
                -- focused child.
                if opt.checkbox.focus and opt.checkbox:OnControl(control, down) then return true end

                -- Normal button logic
                if old_OnControl(_, control, down) then return true end

                -- We also handle X button.
                if not down then
                    if control == CONTROL_MENU_MISC_1 then
                        self:EnableCurrent(widget.data.index)
                        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
                        return true
                    end
                end
            end

            opt.GetHelpText = function()
                local controller_id = TheInput:GetControllerID()
                local t = {}

                table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_1) .. " " .. STRINGS.UI.HELP.TOGGLE)

                return table.concat(t, "  ")
            end

            -- Get the actual widget representing this mod (not the root).
            widget.GetModWidget = function(_)
                return opt
            end

            widget.focus_forward = opt

            return widget
        end

        local function ApplyDataToWidget(context, widget, data, index)
            widget.data = data
            widget.moditem:Hide()
            widget.downloaditem:Hide()
            if not data then
                widget.focus_forward = nil
                return
            end

            if data.is_downloading then
                widget.focus_forward = widget.downloaditem
                widget.downloaditem:Show()
                widget.downloaditem:SetMod(data.mod)
                return
            end

            widget.focus_forward = widget.moditem
            widget.moditem:Show()

            local opt = widget.moditem

            -- ModsScreen has no associated server, so it's not enableable.
            opt:SetModReadOnly(not data.is_client_mod and self.settings.are_servermods_readonly)

            if widget.data.is_selected then
                opt:Select()
            else
                opt:Unselect()
            end

            local modname = data.mod.modname
            local modinfo = KnownModIndex:GetModInfo(modname)
            local modstatus = self:GetBestModStatus(modname)

            opt:SetMod(modname, modinfo, modstatus, KnownModIndex:IsModEnabled(modname))

            if IsModOutOfDate( modname, data.mod.version ) then
                opt.out_of_date_image:Show()
            else
                opt.out_of_date_image:Hide()
            end

            if KnownModIndex:HasModConfigurationOptions(modname) then
                opt.configurable_image:Show()
            else
                opt.configurable_image:Hide()
            end
        end

        local out_of_date_mods = 0
        -- Now that we're up to date, build widgets for all the mods
        self.optionwidgets_client = {}
        for i,v in ipairs(self.modnames_client) do
            if IsModOutOfDate( v.modname, v.version ) then
                out_of_date_mods = out_of_date_mods + 1
            end

            local data = {
                index = i,
                mod = v,
                is_client_mod = true,
            }

            table.insert(self.optionwidgets_client, data)
        end
        local item_count = #self.optionwidgets_client
        for i,v in ipairs(self.modnames_client_dl) do
            if not ModNameVersionTableContains( self.modnames_client, v.modname ) then
                local data = {
                    index = i+item_count,
                    mod = v,
                    is_client_mod = true,
                    is_downloading = true,
                }

                table.insert(self.optionwidgets_client, data)
            end
        end

        self.optionwidgets_server = {}
        for i,v in ipairs(self.modnames_server) do
            if IsModOutOfDate( v.modname, v.version ) then
                out_of_date_mods = out_of_date_mods + 1
            end

            local data = {
                index = i,
                mod = v,
                is_client_mod = false,
            }

            table.insert(self.optionwidgets_server, data)
        end
        item_count = #self.optionwidgets_client
        for i,v in ipairs(self.modnames_server_dl) do
            if not ModNameVersionTableContains( self.modnames_server, v.modname ) then
                local data = {
                    index = i+item_count,
                    mod = v,
                    is_client_mod = false,
                    is_downloading = true,
                }

                table.insert(self.optionwidgets_server, data)
            end
        end

        -- And make a scrollable list!
        if self.mods_scroll_list == nil then
            self.mods_scroll_list  = self.mods_page:AddChild(TEMPLATES.ScrollingGrid(
                    self.optionwidgets_client,
                    {
                        context = {},
                        widget_width  = item_width,
                        widget_height = item_height,
                        num_visible_rows = 6,
                        num_columns      = 1,
                        item_ctor_fn = ScrollWidgetsCtor,
                        apply_fn     = ApplyDataToWidget,
                        scrollbar_offset = 10,
                        scrollbar_height_offset = -60,
                        peek_percent = 0.25, -- may init with few clientmods, but have many servermods.
                        allow_bottom_empty_row = true, -- it's hidden anyway
                    }
                ))

            self.mods_scroll_list:SetPosition(-280, -10)

            self.mods_page.focus_forward = self.mods_scroll_list
        end

        self.subscreener:OnMenuButtonSelected(self.currentmodtype)

        --update the text on Update All button to indicate how many mods are out of date
        if #self.modnames_client_dl > 0 or #self.modnames_server_dl > 0 then
            --updating
            self.updateallbutton:SetHoverText(STRINGS.UI.MODSSCREEN.UPDATINGMOD)
            self.out_of_date_badge:SetCount(#self.modnames_client_dl + #self.modnames_server_dl)
            self.updateallbutton:Select()
            self.updateallenabled = false
        elseif out_of_date_mods > 0 then
            self.updateallbutton:SetHoverText(STRINGS.UI.MODSSCREEN.UPDATEALL)
            self.out_of_date_badge:SetCount(out_of_date_mods)
            self.updateallbutton:Unselect()
            self.updateallenabled = true
        else
            self.updateallbutton:SetHoverText(STRINGS.UI.MODSSCREEN.UPTODATEALL)
            self.out_of_date_badge:SetCount(0)
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
        -- Need mod partially loaded so it applies to server and
        -- worldgen settings.
        ModManager:FrontendLoadMod(modname)
    end

    --show the auto-download warning for non-workshop mods
    local modinfo = KnownModIndex:GetModInfo(modname)
    if self.settings.is_configuring_server and KnownModIndex:IsModEnabled(modname) and modinfo.all_clients_require_mod then
        local workshop_prefix = "workshop-"
        if string.sub( modname, 0, string.len(workshop_prefix) ) ~= workshop_prefix then
            TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MODSSCREEN.MOD_WARNING_TITLE, STRINGS.UI.MODSSCREEN.MOD_WARNING,
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

    if self.servercreationscreen.DirtyFromMods then
        self.servercreationscreen:DirtyFromMods(self.slotnum)
    end

    if restart then
        KnownModIndex:Save()
        TheSim:Quit()
    end
end

function ModsTab:EnableCurrent(idx)
    local modname = nil
    if self.currentmodtype == "client" then
        modname = self.modnames_client[idx].modname
    else
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
    if KnownModIndex:IsModEnabled(modname) then
        return "WORKING_NORMALLY"
    else
        if KnownModIndex:GetModInfo(modname) == nil or KnownModIndex:GetModInfo(modname).failed or KnownModIndex:IsModKnownBad(modname) then
            return "DISABLED_ERROR"
        else
            return "DISABLED_MANUAL"
        end
    end
end

function ModsTab:ShowModDetails(idx, client_mod)
    local items_table = client_mod and self.optionwidgets_client or self.optionwidgets_server
    local modnames_versions = client_mod and self.modnames_client or self.modnames_server
    if items_table and #items_table > 0 and modnames_versions and #modnames_versions > 0 then
        for k,data in pairs(items_table) do
            data.is_selected = false
        end
        items_table[idx].is_selected = true
        self.mods_scroll_list:RefreshView()
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
    else
        self.detailimage:SetTexture("images/ui.xml", "portrait_bg.tex")
    end
    self.detailimage:SetSize(unpack(self.detailimage._align.size))

    local align = self.detailtitle._align
    self.detailtitle:SetMultilineTruncatedString(modinfo.name or modname, align.maxlines, align.width, align.maxchars, true)
    local w,h = self.detailtitle:GetRegionSize()
    self.detailtitle:SetPosition(w/2 - align.x, align.y)

    align = self.detailauthor._align
    self.detailauthor:SetTruncatedString(string.format(STRINGS.UI.MODSSCREEN.AUTHORBY, modinfo.author or "unknown"), align.width, align.maxchars, true)
    w, h = self.detailauthor:GetRegionSize()
    self.detailauthor:SetPosition(w/2 - align.x, align.y)

    align = self.detaildesc._align
    self.detaildesc:SetMultilineTruncatedString(modinfo.description or "", align.maxlines, align.width, align.maxchars, true)
    w, h = self.detaildesc:GetRegionSize()
    self.detaildesc:SetPosition(w/2 - 190, 90 - .5 * h)

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
        self:EnableConfigButton()
    else
        self:DisableConfigButton()
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

    local modStatus = self:GetBestModStatus(modname)
    if modStatus == "WORKING_NORMALLY" then
        self.detailwarning:SetString(STRINGS.UI.MODSSCREEN.WORKING_NORMALLY)
        self.detailwarning:SetColour(59/255, 222/255, 99/255, 1)
    elseif modStatus == "DISABLED_ERROR" then
        self.detailwarning:SetColour(242/255, 99/255, 99/255, 1) --(242/255, 99/255, 99/255, 1)--0.9,0.3,0.3,1)
        self.detailwarning:SetString(STRINGS.UI.MODSSCREEN.DISABLED_ERROR)
    elseif modStatus == "DISABLED_MANUAL" then
        self.detailwarning:SetString(STRINGS.UI.MODSSCREEN.DISABLED_MANUAL)
        self.detailwarning:SetColour(.6,.6,.6,1)
    end

    if not client_mod and self.settings.are_servermods_readonly then
        -- Can configure readonly mods (ModsScreen).
        self.detailwarning:SetString(STRINGS.UI.MODSSCREEN.VIEW_AND_CONFIGURE)
        self.detailwarning:SetColour(WET_TEXT_COLOUR)
    end
    
	self.modlinkbutton:Unselect()
	if PLATFORM == "WIN32_RAIL" then
		if not IsWorkshopMod(self.currentmodname) then
			self.modlinkbutton:Select()
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
            RegisterPrefabs( prefab )
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
    if self.currentmodname then
        local link_fn = ModManager:GetLinkForMod(self.currentmodname)
        link_fn()
    else
        ModManager:ShowMoreMods()
    end
end

function ModsTab:Cancel()
    self:_CancelTasks()

    ModManager:FrontendUnloadMod(nil) -- all mods

    KnownModIndex:RestoreCachedSaveData()
    self:UnloadModInfoPrefabs(self.infoprefabs)
end

-- Apply is called by our parent screen to apply our mod settings.
function ModsTab:Apply()
    -- Note: After "apply", the mods tab is no longer in a working state, it
    -- must be restarted with :StartWorkshopUpdate()
    self:_CancelTasks()

    KnownModIndex:Save()
    self.selectedmodmenu:Disable()
    self.allmodsmenu:Disable()

    if self.slotnum > -1 then
        -- We don't have a valid slot from ModsScreen (we're not configuring a
        -- server).
        SaveGameIndex:SetServerEnabledMods( self.slotnum )
        SaveGameIndex:Save()
    else
        -- ModsScreen needs us to reload so frontend UI mods can work.
        TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()
            self:UnloadModInfoPrefabs(self.infoprefabs)
            ForceAssetReset()
            SimReset()
        end)
    end
end

function ModsTab:OnDestroy()
    self:_CancelTasks()

    self:UnloadModInfoPrefabs(self.infoprefabs)
end

function ModsTab:OnBecomeActive()
    self:StartWorkshopUpdate()
end

function ModsTab:ConfigureSelectedMod()
    if self.modconfigable then
        -- ModConfigurationScreen has different behavior for server (a save
        -- slot) and client (frontend mods).
        local is_clientonly_config = not self.settings.is_configuring_server
        TheFrontEnd:PushScreen(ModConfigurationScreen(self.currentmodname, is_clientonly_config))
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

                    if self.mods_scroll_list then
                        self.mods_scroll_list:SetItemsData({})
                    end
                    TheFrontEnd:PopScreen()

                    self.selectedmodmenu:Disable()
                    self.allmodsmenu:Disable()
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
                {text=STRINGS.UI.SERVERLISTINGSCREEN.OK,
                    cb = function()
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
                    end
                },
                {text=STRINGS.UI.SERVERLISTINGSCREEN.CANCEL, cb = function() TheFrontEnd:PopScreen() end}
            })
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
    local tomiddlecol = self.subscreener:GetActiveSubscreenFn()

    self.subscreener.menu:SetFocusChangeDir(MOVE_DOWN, self.cleanallbutton)

    if self.mods_scroll_list then
        self.mods_scroll_list:SetFocusChangeDir(MOVE_RIGHT, self.selectedmodmenu)
    end

    self.allmodsmenu:SetFocusChangeDir(MOVE_UP, self.subscreener.menu)
    self.allmodsmenu:SetFocusChangeDir(MOVE_RIGHT, tomiddlecol)

    self.selectedmodmenu:SetFocusChangeDir(MOVE_LEFT, tomiddlecol)
end

return ModsTab
