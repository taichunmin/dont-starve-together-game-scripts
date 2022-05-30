local Widget = require "widgets/widget"
local Subscreener = require "screens/redux/subscreener"
local Text = require "widgets/text"
local TopModsPanel = require "widgets/redux/topmodspanel"
local Image = require "widgets/image"
local Menu = require "widgets/menu"
local TEMPLATES = require "widgets/redux/templates"
local ModFilterBar = require "widgets/redux/modfilterbar"
local PopupDialogScreen = require "screens/redux/popupdialog"
local ModConfigurationScreen = require "screens/redux/modconfigurationscreen"
local ModsListPopup = require "screens/redux/modslistpopup"

require("metaclass")

local OptionWidget = MetaClass(function(self, ...)
    self.normal = {}
    self.dl = {}
end)

function OptionWidget:__index(k)
    --attempting to index this table with numbers will go index the normal and then dl tables
    if type(k) == "number" then
        if k <= #self.normal then
            return self.normal[k]
        else
            return self.dl[k - #self.normal]
        end
    end
    return metarawget(self, k)
end

function OptionWidget:__newindex(k, v)
    --setting number values is ignored
    if type(k) ~= "number" then
        metarawset(self, k, v)
    end
end

--length is the length of both normal and dl tables
function OptionWidget:__len()
    return #self.normal + #self.dl
end

function OptionWidget:__ipairs()
    --see https://www.lua.org/pil/9.3.html
    --using a coroutine to maintain a state inside the function
    --this iterates over first t.normal, and then t.dl
    local idx_add = 0
    return coroutine.wrap(function()
        for _, t in ipairs({self.normal, self.dl}) do
            for i, v in ipairs(t) do
                --this is equivalent to return i, v that the next like function for ipairs does.
                coroutine.yield(i + idx_add, v)
            end
            idx_add = idx_add + #t
        end
    end)
end

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

    self.modnames_client = {}
    self.modnames_client_dl = {}
    self.modnames_server = {}
    self.modnames_server_dl = {}
    self.downloading_mods_count = 0

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

    self.optionwidgets_client = OptionWidget()
    self.optionwidgets_server = OptionWidget()

    self:CreateModsScrollList()

    local function workshopfnfilter(modname)
        return IsWorkshopMod(modname)
    end
    local function localfnfilter(modname)
        return not IsWorkshopMod(modname)
    end
    local function enabledfnfilter(modname)
        return KnownModIndex:IsModEnabled(modname)
    end
    local function disabledfnfilter(modname)
        return not KnownModIndex:IsModEnabled(modname)
    end

    self.modfilterbar = self.mods_page:AddChild(ModFilterBar(self, "modfilter"))
    self.modfilterbar:AddChild(self.modfilterbar:AddModTypeFilter(STRINGS.UI.MODSSCREEN.WORKSHOP_FILTER_FMT, "workshop_filter.tex", "local_filter.tex", "workshoplocal_filter.tex", "workshopfilter", workshopfnfilter, localfnfilter))
    self.modfilterbar:AddChild(self.modfilterbar:AddModStatusFilter(STRINGS.UI.MODSSCREEN.STATUS_FILTER_FMT, "enabled_filter.tex", "disabled_filter.tex", "enableddisabled_filter.tex", "statusfilter", enabledfnfilter, disabledfnfilter))
    self.modfilterbar:AddChild(self.modfilterbar:AddSearch())
    self.modfilterbar:SetPosition(-280, 233.75)
    self.modfilterbar:Hide()

    self.mods_page.focus_forward = self.modfilterbar:BuildFocusFinder()

    self.mods_filter_fn = function() return true end

    self.dependency_queue = {}

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

function ModsTab:_SetModsList(listtype, forcescroll)
    local scroll_to = forcescroll or self.currentmodtype ~= listtype
    self.currentmodtype = listtype
    if self.currentmodtype ~= listtype and self.modfilterbar then
        self.modfilterbar:RefreshFilterState()
        return --this does a callback to this function, so we return so don't run this logic twice.
    end

    -- Always show details so it can show the empty message (if workshop is
    -- slow, we'll at least have something reasonable visible).
    self.detailpanel:Refresh()

    if self.mods_scroll_list == nil then
        return
    end

    local function ShowLastClickedDetails(last_modname, modnames_list)
        local idx = #modnames_list > 0 and 1 or nil
        for i,v in metaipairs(modnames_list) do
            if last_modname == v.mod.modname then
                idx = i
                break
            end
        end
        self:ShowModDetails(idx, self.optionwidgets_client == modnames_list)

        if scroll_to and idx then
            -- On switching tabs, scroll the window to the selected item. (Can't do
            -- on ShowModDetails since it would snap on each click.)
            self.mods_scroll_list:ScrollToDataIndex(idx)
        end
    end

    if listtype == "client" then
        self.mods_scroll_list:SetItemsData(self.optionwidgets_client)
        if #self.modnames_client + #self.modnames_client_dl > 0 then
            self.modfilterbar:Show()
        else
            self.modfilterbar:Hide()
        end
        ShowLastClickedDetails(self.last_client_modname, self.optionwidgets_client)

    elseif listtype == "server" then
        self.mods_scroll_list:SetItemsData(self.optionwidgets_server)
        if #self.modnames_server + #self.modnames_server_dl > 0 then
            self.modfilterbar:Show()
        else
            self.modfilterbar:Hide()
        end
        ShowLastClickedDetails(self.last_server_modname, self.optionwidgets_server)
    end

    self:DoFocusHookups()
end

local function IsModOutOfDate( modname, workshop_version )
    return IsWorkshopMod(modname) and workshop_version ~= "" and workshop_version ~= (KnownModIndex:GetModInfo(modname) ~= nil and KnownModIndex:GetModInfo(modname).version or "")
end

function ModsTab:CreateModsScrollList()
    local function ScrollWidgetsCtor(context, index)
        local widget = Widget("widget-".. index)

        widget:SetOnGainFocus(function() self.mods_scroll_list:OnWidgetFocus(widget) end)

        widget.downloaditem = widget:AddChild(TEMPLATES.ModListItem_Downloading())

        widget.moditem = widget:AddChild(TEMPLATES.ModListItem(function()
            self:ShowModDetails(widget.data.widgetindex, widget.data.is_client_mod)
        end,
        function()
            self:EnableCurrent(widget.data.widgetindex)
        end,
        function()
            self:FavoriteCurrent(widget.data.widgetindex)
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
                self:EnableCurrent(widget.data.widgetindex)
                self.last_mod_click_time = nil
            elseif widget.data.is_client_mod or not self.settings.are_servermods_readonly then
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
            if opt.setfavorite.focus and opt.setfavorite:OnControl(control, down) then return true end

            -- Normal button logic
            if old_OnControl(_, control, down) then return true end

            -- We also handle X button.
            if not down then
                if control == CONTROL_MENU_MISC_1 then
                    if widget.data ~= nil then
                        self:EnableCurrent(widget.data.widgetindex)
                        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
                        return true
                    end
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

        opt:SetMod(modname, modinfo, modstatus, KnownModIndex:IsModEnabled(modname), Profile:IsModFavorited(modname))

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

    -- And make a scrollable list!
    if self.mods_scroll_list == nil then
        self.mods_scroll_list  = self.mods_page:AddChild(TEMPLATES.ScrollingGrid(
                self.optionwidgets_client,
                {
                    context = {},
                    widget_width  = item_width,
                    widget_height = item_height,
                    num_visible_rows = 5,
                    num_columns      = 1,
                    item_ctor_fn = ScrollWidgetsCtor,
                    apply_fn     = ApplyDataToWidget,
                    scrollbar_offset = 10,
                    scrollbar_height_offset = -60,
                    peek_percent = 0.50, -- may init with few clientmods, but have many servermods.
                    allow_bottom_empty_row = true -- it's hidden anyway
                }
            ))

        self.mods_scroll_list:SetPosition(-280, -43.75)
    end
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
    self.detailimage:SetSize(unpack(self.detailimage._align.size))

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
    self.detaildesc_empty:SetPosition(-117, 55, 0)
    self.detaildesc_empty:SetRegionSize(body_width, 225)
    self.detaildesc_empty:EnableWordWrap(true)


    self.detailpanel.Refresh = function(_)
        local num_mods = 0
        if self.currentmodtype == "client" then
            num_mods = #self.modnames_client + #self.modnames_client_dl
        else
            num_mods = #self.modnames_server + #self.modnames_server_dl
        end

        if num_mods > 0 then
            self.detailpanel.whenfull:Show()
            self.detailpanel.whenempty:Hide()

            self.modlinkbutton:SetHoverText(STRINGS.UI.MODSSCREEN.MODLINK_MOREINFO)
        else
            self.detailpanel.whenfull:Hide()
            self.detailpanel.whenempty:Show()

			local no_mods
			if IsRail() then
				no_mods =  (self.currentmodtype == "client") and STRINGS.UI.MODSSCREEN.NO_MODS_CLIENT_TGP or STRINGS.UI.MODSSCREEN.NO_MODS_SERVER_TGP
				self.modlinkbutton:Select()
			else
				no_mods = string.format(STRINGS.UI.MODSSCREEN.NO_MODS_TYPE, self.currentmodtype )
			end

            self.detaildesc_empty:SetString(no_mods)
            self:DisableConfigButton()
            self:DisableUpdateButton("uptodate")
            self.modlinkbutton:ClearHoverText()
        end
    end
end

function ModsTab:_CancelTasks()
    if self.workshopupdatetask ~= nil then
        self.workshopupdatetask:Cancel()
        self.workshopupdatetask = nil
    end
    if self.modsorderupdatetask ~= nil then
        self.modsorderupdatetask:Cancel()
        self.modsorderupdatetask = nil
    end
end

function ModsTab:StartModsOrderUpdate()
    if self.modsorderupdatetask ~= nil then
        self.modsorderupdatetask:Cancel()
        self.modsorderupdatetask = nil
    end

    self:UpdateModsOrder()
    self.modsorderupdatetask = staticScheduler:ExecutePeriodic(FRAMES * 2, self.UpdateModsOrder, nil, 0, "updatemodsorder", self)
end

function ModsTab:StartWorkshopUpdate()
    if self.workshopupdatetask ~= nil then
        self.workshopupdatetask:Cancel()
        self.workshopupdatetask = nil
    end

    self:UpdateForWorkshop()
    self.workshopupdatetask = staticScheduler:ExecutePeriodic( 1, self.UpdateForWorkshop, nil, 0, "updateforworkshop", self)
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

local alpasortcache = {}
local function alphasort(moda, modb)
    if not moda then return false end
    if not modb then return true end

    local moda_sort = alpasortcache[moda.modname]
    local modb_sort = alpasortcache[modb.modname]
    if not moda_sort then
        local fancy = KnownModIndex:GetModFancyName(moda.modname)
        moda_sort = {
            fav = Profile:IsModFavorited(moda.modname),
            name = string.lower(fancy):gsub('%W','')..fancy
        }
        alpasortcache[moda.modname] = moda_sort
    end
    if not modb_sort then
        local fancy = KnownModIndex:GetModFancyName(modb.modname)
        modb_sort = {
            fav = Profile:IsModFavorited(modb.modname),
            name = string.lower(fancy):gsub('%W','')..fancy
        }
        alpasortcache[modb.modname] = modb_sort
    end

    if moda_sort.fav ~= modb_sort.fav then
        return moda_sort.fav
    end
    return moda_sort.name < modb_sort.name
end

function ModsTab:UpdateModsOrder(force_refresh)
    --KnownModIndex:UpdateModInfo() --Note(Zachary): this is done in UpdateForWorkshop, so we don't reload modinfo every tick.
    local curr_modnames_client = KnownModIndex:GetClientModNamesTable()
    local curr_modnames_server = KnownModIndex:GetServerModNamesTable()
    table.sort(curr_modnames_client, alphasort)
    table.sort(curr_modnames_server, alphasort)
    alpasortcache = {}

    --update workshop version data into the curr list
    local has_local_client = false
    for k,v in pairs( curr_modnames_client ) do
        local is_workshop = IsWorkshopMod(v.modname)
        has_local_client = has_local_client or not is_workshop
        v.version = is_workshop and TheSim:GetWorkshopVersion(v.modname) or ""
    end
    local has_local_server = false
    for k,v in pairs( curr_modnames_server ) do
        --do this in here, since the UI won't explode, and we need to do this since mods can get downloaded from the steam workshop...
        if KnownModIndex:IsModDependedOn(v.modname) and not KnownModIndex:IsModEnabled(v.modname) then
            --this new mod could theoretically have dependencies, because the user already agreed to subscribing and enabling mods to get here, we just enable them all.
            self:EnableModDependencies(KnownModIndex:GetModDependencies(v.modname, true))
            self:OnConfirmEnable(false, v.modname)
        end
        local is_workshop = IsWorkshopMod(v.modname)
        has_local_server = has_local_server or not is_workshop
        v.version = is_workshop and TheSim:GetWorkshopVersion(v.modname) or ""
    end

    local need_to_update = force_refresh
    if not CompareModnamesTable( self.modnames_client, curr_modnames_client ) or
        not CompareModnamesTable( self.modnames_server, curr_modnames_server ) or
        self.forceupdatemodsorder then
        need_to_update = true
    end
    self.forceupdatemodsorder = nil

    --If nothing has changed bail out and leave the ui alone
    if not need_to_update or (self.mods_scroll_list and self.mods_scroll_list.dragging) then
        return
    end

    --hiding the filters also disables the filters, so we do this before sorting.
    if self.currentmodtype == "client" then
        if has_local_client then
            self.modfilterbar:ShowFilter("workshopfilter")
        else
            self.modfilterbar:HideFilter("workshopfilter")
        end
        self.modfilterbar:ShowFilter("statusfilter")
    elseif self.currentmodtype == "server" then
        if has_local_server then
            self.modfilterbar:ShowFilter("workshopfilter")
        else
            self.modfilterbar:HideFilter("workshopfilter")
        end
        if not self.settings.is_configuring_server then
            self.modfilterbar:HideFilter("statusfilter")
        else
            self.modfilterbar:ShowFilter("statusfilter")
        end
    end

    self.modnames_client = curr_modnames_client
    self.modnames_server = curr_modnames_server

    local out_of_date_mods = 0
    -- Now that we're up to date, build widgets for all the mods
    self.optionwidgets_client.normal = {}
    for i,v in ipairs(self.modnames_client) do
        if IsModOutOfDate( v.modname, v.version ) then
            out_of_date_mods = out_of_date_mods + 1
        end
        if self.mods_filter_fn(v.modname) then

            local data = {
                index = i,
                widgetindex = #self.optionwidgets_client.normal + 1,
                mod = v,
                is_client_mod = true,
            }

            table.insert(self.optionwidgets_client.normal, data)
        end
    end

    self.optionwidgets_server.normal = {}
    for i,v in ipairs(self.modnames_server) do
        if IsModOutOfDate( v.modname, v.version ) then
            out_of_date_mods = out_of_date_mods + 1
        end
        if self.mods_filter_fn(v.modname) then

            local data = {
                index = i,
                widgetindex = #self.optionwidgets_server.normal + 1,
                mod = v,
                is_client_mod = false,
            }

            table.insert(self.optionwidgets_server.normal, data)
        end
    end

    self:_SetModsList(self.currentmodtype)

    if self.downloading_mods_count > 0 then
        --updating
        self.updateallbutton:SetHoverText(STRINGS.UI.MODSSCREEN.UPDATINGMOD)
        self.out_of_date_badge:SetCount(self.downloading_mods_count)
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
end

function ModsTab:UpdateForWorkshop( force_refresh )
    if TheSim:TryLockModDir() then
        KnownModIndex:UpdateModInfo()
        self:ReloadModInfoPrefabs()

        local curr_modnames_client_dl = TheSim:GetClientModsDownloading()
        local curr_modnames_server_dl = TheSim:GetServerModsDownloading()

        --check it see if anything changed
        local need_to_update = force_refresh
        if not CompareModDLTable( self.modnames_client_dl, curr_modnames_client_dl ) or
            not CompareModDLTable( self.modnames_server_dl, curr_modnames_server_dl ) then
                need_to_update = true
        end

        --If nothing has changed bail out and leave the ui alone
        if not need_to_update or (self.mods_scroll_list and self.mods_scroll_list.dragging) then
            if TheSim:IsLoggedOn() then
                TheSim:StartWorkshopQuery()
            end
            TheSim:UnlockModDir()
            return
        end
        self.forceupdatemodsorder = true

        --print("### Do UpdateForWorkshop refresh")

        self.modnames_client_dl = curr_modnames_client_dl
        self.modnames_server_dl = curr_modnames_server_dl
        self.downloading_mods_count = #self.modnames_client_dl + #self.modnames_server_dl

        --If no mods, tell the user where to get them.
        --this one runs slower, so we put the no mods popup here
        if not self.settings.is_configuring_server
            and #self.modnames_client == 0
            and #self.modnames_server == 0
            and #self.modnames_client_dl == 0
            and #self.modnames_server_dl == 0 then

            -- Only show popup one at a time.
            if not self.no_mods_popup then
	            if not IsRail() then
					self.no_mods_popup = PopupDialogScreen( STRINGS.UI.MODSSCREEN.NO_MODS_TITLE, STRINGS.UI.MODSSCREEN.NO_MODS,
						{
							-- We don't dismiss the popup! Only dismiss once we have mods or user backs out.
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

        self.optionwidgets_client.dl = {}
        local item_count = #self.optionwidgets_client
        for i,v in ipairs(self.modnames_client_dl) do
            if not ModNameVersionTableContains( self.modnames_client, v.modname ) and self.mods_filter_fn(v.modname) then
                local data = {
                    index = i + item_count,
                    widgetindex = #self.optionwidgets_client + 1,
                    mod = v,
                    is_client_mod = true,
                    is_downloading = true,
                }

                table.insert(self.optionwidgets_client.dl, data)
            end
        end

        self.optionwidgets_server.dl = {}
        item_count = #self.optionwidgets_server
        for i,v in ipairs(self.modnames_server_dl) do
            if not ModNameVersionTableContains( self.modnames_server, v.modname ) and self.mods_filter_fn(v.modname) then
                local data = {
                    index = i + item_count,
                    widgetindex = #self.optionwidgets_server + 1,
                    mod = v,
                    is_client_mod = false,
                    is_downloading = true,
                }

                table.insert(self.optionwidgets_server.dl, data)
            end
        end

        self:_SetModsList(self.currentmodtype)

        TheSim:UnlockModDir()
    end
    local downloading_mods_count = #self.modnames_client_dl + #self.modnames_server_dl
    if downloading_mods_count > 0 then
        self.servercreationscreen:ShowWorkshopDownloadingNotification()
    elseif downloading_mods_count == 0 then
        self.servercreationscreen:RemoveWorkshopDownloadingNotification()
    end
end

function ModsTab:RefreshModFilter(filter_fn)
    self.mods_filter_fn = filter_fn
    self:UpdateModsOrder(true)

    self:_SetModsList(self.currentmodtype, true)

    --self:UpdateForWorkshop(true) --Zachary: don't do this, this will cause the game to lag for a teeny bit every time you change the filter options
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
        KnownModIndex:SetDependencyList(modname, KnownModIndex:GetModDependencies(modname))
    end

    --show the auto-download warning for non-workshop mods
    local modinfo = KnownModIndex:GetModInfo(modname)
    if KnownModIndex:IsLocalModWarningEnabled() and self.settings.is_configuring_server and
        KnownModIndex:IsModEnabled(modname) and modinfo.all_clients_require_mod then
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

    if self.servercreationscreen.DirtyFromMods then
        self.servercreationscreen:DirtyFromMods(self.slotnum)
    end

    if restart then
        KnownModIndex:Save()
        TheSim:Quit()
    end
end

function ModsTab:EnableCurrent(widget_idx)
    local items_table = self.currentmodtype == "client" and self.optionwidgets_client or self.optionwidgets_server
    local idx = items_table[widget_idx].index
    local modname = nil
    if self.currentmodtype == "client" then
        modname = self.modnames_client[idx].modname
    else
        modname = self.modnames_server[idx].modname
    end

    --note(Zachary): client mods aren't supported at the moment, and only client mods can set restart_required to true, so if this gets updated for client mods, update this also.
    local is_enabled = KnownModIndex:IsModEnabled(modname)
    if is_enabled and KnownModIndex:IsModDependedOn(modname) then
        local mod_dependents = KnownModIndex:GetModDependents(modname, true)
        self:DisplayModDependents(modname, mod_dependents)
        --the disabling of the mod happens inside the callback.
        return
    elseif not is_enabled then
        local mod_dependencies = KnownModIndex:GetModDependencies(modname, true)
        if #mod_dependencies > 0 then
            if KnownModIndex:DoModsExistAnyVersion(mod_dependencies) then
                self:EnableModDependencies(mod_dependencies)
            else
                self:DisplayModDependencies(modname, mod_dependencies)
                --the enabling of the mod happens in the callback
                return
            end
        end
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
    self:ShowModDetails(widget_idx, self.currentmodtype == "client")
    self:UpdateModsOrder(true)
    self.mods_scroll_list:RefreshView()
end

function ModsTab:FavoriteCurrent(widget_idx)
    local items_table = self.currentmodtype == "client" and self.optionwidgets_client or self.optionwidgets_server
    local idx = items_table[widget_idx].index
    local modname = nil
    if self.currentmodtype == "client" then
        modname = self.modnames_client[idx].modname
    else
        modname = self.modnames_server[idx].modname
    end
    Profile:SetModFavorited(modname, not Profile:IsModFavorited(modname))

    self.mods_scroll_list:RefreshView()
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

function ModsTab:ShowModDetails(widget_idx, client_mod)
    local items_table = client_mod and self.optionwidgets_client or self.optionwidgets_server
    local modnames_versions = client_mod and self.modnames_client or self.modnames_server

    if items_table and #items_table > 0 then
        for i, data in metaipairs(items_table) do
            data.is_selected = false
        end
        if items_table[widget_idx] then
            items_table[widget_idx].is_selected = true
        end
        self.mods_scroll_list:RefreshView()
    end
    local idx = items_table[widget_idx] and items_table[widget_idx].index or nil

    local modname = idx and modnames_versions[idx] and modnames_versions[idx].modname or nil

    self.currentmodname = modname
    if client_mod and self.currentmodname then
        self.last_client_modname = self.currentmodname
    else
        self.last_server_modname = self.currentmodname
    end

    local modinfo = modname and KnownModIndex:GetModInfo(modname) or {}

    local iconinfo = modname and self.infoprefabs[modname] or {}
    if iconinfo.icon and iconinfo.icon_atlas then
        self.detailimage:SetTexture(iconinfo.icon_atlas, iconinfo.icon)
    else
        self.detailimage:SetTexture("images/ui.xml", "portrait_bg.tex")
    end
    self.detailimage:SetSize(unpack(self.detailimage._align.size))

    local align = self.detailtitle._align
    self.detailtitle:SetMultilineTruncatedString(modinfo.name or modname or "", align.maxlines, align.width, align.maxchars, true)
    local w,h = self.detailtitle:GetRegionSize()
    self.detailtitle:SetPosition((w or 0)/2 - align.x, align.y)

    align = self.detailauthor._align
    self.detailauthor:SetTruncatedString(modname and string.format(STRINGS.UI.MODSSCREEN.AUTHORBY, modinfo.author or "unknown") or "", align.width, align.maxchars, true)
    w, h = self.detailauthor:GetRegionSize()
    self.detailauthor:SetPosition((w or 0)/2 - align.x, align.y)

    align = self.detaildesc._align
    self.detaildesc:SetMultilineTruncatedString(modinfo.description or "", align.maxlines, align.width, align.maxchars, true)
    w, h = self.detaildesc:GetRegionSize()
    self.detaildesc:SetPosition((w or 0)/2 - 190, 90 - .5 * (h or 0))

    if modinfo.dst_compatible then
        if modinfo.dst_compatibility_specified == false then
            self.detailcompatibility:SetString(STRINGS.UI.MODSSCREEN.COMPATIBILITY_UNKNOWN)
        else
            self.detailcompatibility:SetString(STRINGS.UI.MODSSCREEN.COMPATIBILITY_DST)
        end
    else
        self.detailcompatibility:SetString(modname and STRINGS.UI.MODSSCREEN.COMPATIBILITY_NONE or "")
    end

    if modname and KnownModIndex:HasModConfigurationOptions(modname) then
        self:EnableConfigButton()
    else
        self:DisableConfigButton()
    end

    --is workshop mod and is out of date version, and check if it's updating currently
    if modname and IsModOutOfDate( modname, modnames_versions[idx].version ) then
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

    if modname then
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
    else
        self.detailwarning:SetString("")
    end

    self.modlinkbutton:Unselect()
    if not modname then
        self.modlinkbutton:ClearHoverText()
    end
	if PLATFORM == "WIN32_RAIL" and self.currentmodname then
		if not IsWorkshopMod(self.currentmodname) then
			self.modlinkbutton:Select()
		end
	end
end

function ModsTab:EnableModDependencies(mod_dependencies)
    for i, modname in ipairs(mod_dependencies) do
        --enable all dependent mods
        if KnownModIndex:DoesModExistAnyVersion(modname) and not KnownModIndex:IsModEnabled(modname) then
            self:OnConfirmEnable(false, modname)
        end
    end
end

function ModsTab:DisableModDependents(mod_dependents)
    for i, modname in ipairs(mod_dependents) do
        --disable all dependent mods
        if KnownModIndex:IsModEnabled(modname) then
            self:OnConfirmEnable(false, modname)
        end
    end
end

function ModsTab:DisplayModDependencies(modname, mod_dependencies)
    --prompt the user to subscribe to the missing mods
    if TheFrontEnd:GetActiveScreen() ~= self.servercreationscreen then
        self.dependency_queue[modname] = mod_dependencies
        return
    end
    TheFrontEnd:PushScreen(ModsListPopup(mod_dependencies, STRINGS.UI.MODSSCREEN.MOD_DEPENDENCIES_TITLE,
        subfmt(STRINGS.UI.MODSSCREEN.MOD_HAS_DEPENDENCIES_FMT, {mod = KnownModIndex:GetModFancyName(modname)}),
        {
            {
                text=STRINGS.UI.MODSSCREEN.ENABLE,
                cb = function()
                    --pop the screen before letting possible local mod warning screens show up
                    TheFrontEnd:PopScreen()
                    self:EnableModDependencies(mod_dependencies)
                    if not KnownModIndex:IsModEnabled(modname) then
                        self:OnConfirmEnable(false, modname)
                        if self.currentmodtype == "server" then
                            local widget_idx
                            --use the correct optionwidget if its a client mod, if/when we add support for it in the future
                            for i, v in metaipairs(self.optionwidgets_server) do
                                if v.mod.modname == modname then
                                    widget_idx = i
                                end
                            end
                            --widget_idx might not exist depending on the filtering settings
                            if widget_idx then
                                self:ShowModDetails(widget_idx, false)
                            end
                        end
                    else
                        --reupdate the dependencies to subscribe to new mods.
                        KnownModIndex:ClearModDependencies(modname)
                        KnownModIndex:SetDependencyList(modname, mod_dependencies)
                    end
                    self:UpdateModsOrder(true)
                end,
                controller_control=CONTROL_MENU_MISC_1,
            },
            {
                text=STRINGS.UI.MODSSCREEN.DISABLE,
                cb = function()
                    TheFrontEnd:PopScreen()
                    local mod_dependents = KnownModIndex:GetModDependents(modname, true)
                    self:DisableModDependents(mod_dependents)
                    if KnownModIndex:IsModEnabled(modname) then
                        self:OnConfirmEnable(false, modname)
                    end
                    self:UpdateModsOrder(true)
                end,
                controller_control = CONTROL_CANCEL,
            },
        },
        nil, true
    ))
end

function ModsTab:DisplayModDependents(modname, mod_dependents)
    TheFrontEnd:PushScreen(ModsListPopup(mod_dependents, STRINGS.UI.MODSSCREEN.MOD_DEPENDENTS_TITLE,
    subfmt(STRINGS.UI.MODSSCREEN.MOD_HAS_DEPENDENTS_FMT, {mod = KnownModIndex:GetModFancyName(modname)}),
    {
        {
            text=STRINGS.UI.MODSSCREEN.DISABLE_ALL,
            cb = function()
                TheFrontEnd:PopScreen()
                self:DisableModDependents(mod_dependents)
                if KnownModIndex:IsModEnabled(modname) then
                    self:OnConfirmEnable(false, modname)
                    if self.currentmodtype == "server" then
                        local widget_idx
                        --use the correct optionwidget if its a client mod, if/when we add support for it in the future
                        for i, v in metaipairs(self.optionwidgets_server) do
                            if v.mod.modname == modname then
                                widget_idx = i
                            end
                        end
                        --widget_idx might not exist depending on the filtering settings
                        if widget_idx then
                            self:ShowModDetails(widget_idx, false)
                        end
                    end
                end
                self:UpdateModsOrder(true)
            end,
            controller_control=CONTROL_MENU_MISC_1,
        },
        {
            text=STRINGS.UI.MODSSCREEN.CANCEL,
            cb = function()
                TheFrontEnd:PopScreen()
            end,
            controller_control = CONTROL_CANCEL,
        },
    }))
end

function ModsTab:UnloadModInfoPrefabs()
    local prefabs_to_unload = {}
    for modname, _ in pairs(self.infoprefabs) do
        table.insert(prefabs_to_unload, "MODSCREEN_"..modname)
    end
    TheSim:UnloadPrefabs(prefabs_to_unload)
    TheSim:UnregisterPrefabs(prefabs_to_unload)
    self.infoprefabs = {}
end

function ModsTab:ReloadModInfoPrefabs()
    local prefabs_to_unload = {}
    local removed_mods = {}
    local new_mods = {}

    for modname, _ in pairs(self.infoprefabs) do
        removed_mods[modname] = true
    end

    for i, modname in ipairs(KnownModIndex:GetModNames()) do
        local info = KnownModIndex:GetModInfo(modname)
        if info.icon_atlas and info.iconpath then
            removed_mods[modname] = nil

            local old_icon = self.infoprefabs[modname]
            local icons_changed = old_icon and (old_icon.icon_atlas ~= info.icon_atlas or old_icon.iconpath ~= info.iconpath) or false

            if icons_changed then
                table.insert(prefabs_to_unload, "MODSCREEN_"..modname)
            end

            if not old_icon or icons_changed then
                new_mods[modname] = {icon_atlas = info.icon_atlas, iconpath = info.iconpath, icon = info.icon}
            end
        end
    end

    for modname, _ in pairs(removed_mods) do
        table.insert(prefabs_to_unload, "MODSCREEN_"..modname)
        self.infoprefabs[modname] = nil
    end
    TheSim:UnloadPrefabs(prefabs_to_unload)
    TheSim:UnregisterPrefabs(prefabs_to_unload)

    local prefabs_to_load = {}
    for modname, info in pairs(new_mods) do
        local modinfoassets = {
            Asset("ATLAS", info.icon_atlas),
            Asset("IMAGE", info.iconpath),
        }
        local prefab = Prefab("MODSCREEN_"..modname, nil, modinfoassets, nil)
        RegisterSinglePrefab(prefab)
        table.insert(prefabs_to_load, prefab.name)
        self.infoprefabs[modname] = info
    end
    TheSim:LoadPrefabs(prefabs_to_load)
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
    self:UnloadModInfoPrefabs()
end

-- Apply is called by our parent screen to apply our mod settings.
function ModsTab:Apply()
    -- Note: After "apply", the mods tab is no longer in a working state, it
    -- must be restarted with :StartWorkshopUpdate()
    self:_CancelTasks()

    KnownModIndex:Save()
    Profile:Save()
    self.selectedmodmenu:Disable()
    self.allmodsmenu:Disable()

    if self.slotnum > -1 then
        -- We don't have a valid slot from ModsScreen (we're not configuring a
        -- server).
        ShardSaveGameIndex:SetSlotEnabledServerMods( self.slotnum )
        ShardSaveGameIndex:Save()
    else
        -- ModsScreen needs us to reload so frontend UI mods can work.
        TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()
            self:UnloadModInfoPrefabs()
            ForceAssetReset()
            SimReset()
        end)
    end
end

function ModsTab:OnDestroy()
    self:_CancelTasks()

    self:UnloadModInfoPrefabs()
end

local function AllModsSubscribed(mod_dependencies)
    for i, modname in ipairs(mod_dependencies) do
        if not KnownModIndex:IsModDependedOn(modname) then
            return false
        end
    end
    return true
end

function ModsTab:OnBecomeActive()
    self:StartWorkshopUpdate()
    self:StartModsOrderUpdate()
    self.modfilterbar:RefreshFilterState()
    self.inst:DoTaskInTime(0.5, function()
        for modname, mod_dependencies in pairs(self.dependency_queue) do
            self.dependency_queue[modname] = nil
            if KnownModIndex:IsModEnabled(modname) then
                --recheck if dependencies have been subscribed already.
                if AllModsSubscribed(mod_dependencies) then
                    self:EnableModDependencies(mod_dependencies)
                    if not KnownModIndex:IsModEnabled(modname) then
                        self:OnConfirmEnable(false, modname)
                    end
                else
                    self:DisplayModDependencies(modname, mod_dependencies)
                    return
                end
            end
        end
    end)
end

function ModsTab:OnBecomeInactive()
    Profile:Save()
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
        self:UpdateModsOrder()
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

                        self:UnloadModInfoPrefabs()
                        ForceAssetReset()
                        SimReset()
                    end)
                end},
            {text=STRINGS.UI.SERVERLISTINGSCREEN.CANCEL, cb = function() TheFrontEnd:PopScreen() end}
        }
    )
    TheFrontEnd:PushScreen( mod_warning )
end

local function DoUpdateAll(self)
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
    self:UpdateModsOrder()
end

function ModsTab:UpdateAllButton(force)
    if force then
        DoUpdateAll(self)
    elseif self.updateallenabled then
        local mod_warning = PopupDialogScreen(STRINGS.UI.MODSSCREEN.UPDATEALL_TITLE, STRINGS.UI.MODSSCREEN.UPDATEALL_BODY,
            {
                {text=STRINGS.UI.SERVERLISTINGSCREEN.OK,
                    cb = function()
                        DoUpdateAll(self)

                        TheFrontEnd:PopScreen()
                    end
                },
                {text=STRINGS.UI.SERVERLISTINGSCREEN.CANCEL, cb = function() TheFrontEnd:PopScreen() end}
            })
        TheFrontEnd:PushScreen( mod_warning )
    end
end

function ModsTab:UpdateSaveSlot(slotnum)
    self.slotnum = slotnum
end

function ModsTab:SetDataForSlot(slotnum)
    if slotnum == self.slotnum then return end

    ModManager:FrontendUnloadMod(nil) -- all mods

    self.slotnum = slotnum
    ShardSaveGameIndex:LoadSlotEnabledServerMods( self.slotnum )

    for i, name in ipairs(ModManager:GetEnabledServerModNames()) do
        ModManager:FrontendLoadMod(name)
        KnownModIndex:SetDependencyList(name, KnownModIndex:GetModDependencies(name), true)
    end
    --load up all mods and dependencies first, then check for new dependencies
    for i, name in ipairs(ModManager:GetEnabledServerModNames()) do
        local mod_dependencies = KnownModIndex:GetModDependencies(name, true)
        if #mod_dependencies > 0 then
            if KnownModIndex:DoModsExistAnyVersion(mod_dependencies) then
                self:EnableModDependencies(mod_dependencies)
            else
                self:DisplayModDependencies(name, mod_dependencies)
            end
        end
    end

    self:UpdateForWorkshop(true)
    self:UpdateModsOrder(true)
end

function ModsTab:GetNumberOfModsEnabled()
    return #ModManager:GetEnabledServerModNames()
end

function ModsTab:DoFocusHookups()
    local tomiddlecol = self.subscreener:GetActiveSubscreenFn()

    self.subscreener.menu:SetFocusChangeDir(MOVE_DOWN, self.cleanallbutton)

    if self.mods_scroll_list then
        self.mods_scroll_list:SetFocusChangeDir(MOVE_RIGHT, self.selectedmodmenu)
        self.mods_scroll_list:SetFocusChangeDir(MOVE_UP, self.modfilterbar)
    end
    if self.modfilterbar then
        self.modfilterbar:SetFocusChangeDir(MOVE_DOWN, tomiddlecol)
    end

    self.allmodsmenu:SetFocusChangeDir(MOVE_UP, self.subscreener.menu)
    self.allmodsmenu:SetFocusChangeDir(MOVE_RIGHT, tomiddlecol)

    self.selectedmodmenu:SetFocusChangeDir(MOVE_LEFT, tomiddlecol)
end

return ModsTab
