local OnlineStatus = require "widgets/onlinestatus"
local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local TEMPLATES = require "widgets/redux/templates"
local ServerSaveSlot = require "widgets/redux/serversaveslot"
local ServerCreationScreen = require "screens/redux/servercreationscreen"
local SaveFilterBar = require "widgets/redux/savefilterbar"
local BansPopup = require "screens/redux/banspopup"

local KitcoonPuppet = require "widgets/kitcoonpuppet"

local dialog_size_x = 860
local dialog_size_y = 500

local ServerSlotScreen = Class(Screen, function(self, prev_screen)
    Screen._ctor(self, "ServerSlotScreen")

    self.slot_cache = {}

    self.letterbox = self:AddChild(TEMPLATES.old.ForegroundLetterbox())

	self.root = self:AddChild(TEMPLATES.ScreenRoot())
    self.bg = self.root:AddChild(TEMPLATES.PlainBackground())
    self.title = self.root:AddChild(TEMPLATES.ScreenTitle(STRINGS.UI.SERVERCREATIONSCREEN.HOST_GAME))

    self.kit_puppet = self.root:AddChild(KitcoonPuppet( Profile, nil, {
        {x = -100, y = 255,},
        {x = 290, y = 255,},
        {x = 515, y = -255,},
    } ))

	self.onlinestatus = self.root:AddChild(OnlineStatus())

    self.detail_panel_frame_parent = self.root:AddChild(Widget("detail_frame"))
    self.detail_panel_frame_parent:SetPosition(0, 0)
    self.detail_panel_frame = self.detail_panel_frame_parent:AddChild(TEMPLATES.RectangleWindow(dialog_size_x, dialog_size_y))
    local r,g,b = unpack(UICOLOURS.BROWN_DARK)
    self.detail_panel_frame:SetBackgroundTint(r,g,b,0.6)

	self.noservers_message = self.root:AddChild(Text(CHATFONT, 26, STRINGS.UI.SERVERCREATIONSCREEN.NO_MATCHING_SERVERS, UICOLOURS.GOLD_UNIMPORTANT))
	self.noservers_message:Hide()
    self.noservers_message:SetPosition(0, 0)

	self.server_scroll_list = self.root:AddChild(self:_BuildSaveSlotList())
    self.server_scroll_list:SetPosition(0, -26)

    self.savefilterbar = self.root:AddChild(SaveFilterBar(self))
    self.savefilterbar:AddChild(self.savefilterbar:AddSorter())
    self.savefilterbar:AddChild(self.savefilterbar:AddSearch())
    self.savefilterbar:SetPosition(0, 220)

    self.filterfn = function(savename) return true end

	if not TheInput:ControllerAttached() then
		self.cancelbutton = self.root:AddChild(TEMPLATES.BackButton(function() self:Close() end))
        self.new_button = self.root:AddChild(TEMPLATES.StandardButton(function() self:OnCreateNewSlot() end, STRINGS.UI.SERVERCREATIONSCREEN.CREATENEWGAME, {582, 90}))
        self.new_button:SetScale(.65)
        self.new_button:SetPosition(0, -310)
	end
    self.bans_button = self.root:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "view_ban.tex"))
    self.bans_button:SetOnClick(function() self:OnBansButton() end)
    self.bans_button:SetHoverText(STRINGS.UI.SERVERCREATIONSCREEN.VIEWBANS)
    self.bans_button:SetScale(0.9)
    local gap = 10
    if TheInput:ControllerAttached() or IsConsole() then
        gap = 30
    end
    self.bans_button:SetPosition((860/2) - self.bans_button.size_x/2 - gap, 223)

    self.default_focus = self.server_scroll_list
    self:_DoFocusHookups()
    self.focus_forward = self.savefilterbar:BuildFocusFinder()
end)

local lastplayedtime = {}
local function sorttime(a, b)
    local aslot = a.server_slot
    local bslot = b.server_slot
    lastplayedtime[aslot] = lastplayedtime[aslot] or ShardSaveGameIndex:GetSlotLastTimePlayed(aslot)
    lastplayedtime[bslot] = lastplayedtime[bslot] or ShardSaveGameIndex:GetSlotLastTimePlayed(bslot)

    local atime = lastplayedtime[aslot] or 0
    local btime = lastplayedtime[bslot] or 0

    if atime == btime then
        return aslot < bslot
    end
    return atime > btime
end

local mostdays = {}
local function sortdays(a, b)
    local aslot = a.server_slot
    local bslot = b.server_slot
    mostdays[aslot] = mostdays[aslot] or ShardSaveGameIndex:GetSlotDay(aslot)
    mostdays[bslot] = mostdays[bslot] or ShardSaveGameIndex:GetSlotDay(bslot)

    local aday = mostdays[aslot] or 0
    local bday = mostdays[bslot] or 0

    if aday == bday then
        return aslot < bslot
    end
    return aday > bday
end

local datecreated = {}
local function sortcreated(a, b)
    local aslot = a.server_slot
    local bslot = b.server_slot
    datecreated[aslot] = datecreated[aslot] or ShardSaveGameIndex:GetSlotDateCreated(aslot)
    datecreated[bslot] = datecreated[bslot] or ShardSaveGameIndex:GetSlotDateCreated(bslot)

    local acreated = datecreated[aslot] or 0
    local bcreated = datecreated[bslot] or 0

    if acreated == bcreated then
        return aslot < bslot
    end
    return acreated < bcreated
end

function ServerSlotScreen:_CancelTasks()
    if self.updatesavefilestask ~= nil then
        self.updatesavefilestask:Cancel()
        self.updatesavefilestask = nil
    end
end

function ServerSlotScreen:StartUpdateSaveFiles()
    if self.updatesavefilestask ~= nil then
        self.updatesavefilestask:Cancel()
        self.updatesavefilestask = nil
    end

    self:UpdateSaveFiles()
    self.updatesavefilestask = staticScheduler:ExecutePeriodic(30, self.UpdateSaveFiles, nil, 0, "updatesavefiles", self)
end

local function CompareSaveFilesTable(a, b)
    if #a ~= #b then
        return false
    end
    for i, v in ipairs(a) do
        if a[i].server_slot ~= b[i].server_slot then
            return false
        end
    end
    return true
end

function ServerSlotScreen:UpdateSaveFiles(force_update)
    ShardSaveGameIndex.slots = TheSim:GetSaveFiles()

    local savefilescrollitems = {}
    for i, slot in ipairs(ShardSaveGameIndex:GetValidSlots()) do
        local _, character = self:GetCharacterPortrait(slot)
        if self.filterfn(slot, character) then
            table.insert(savefilescrollitems, {server_slot=slot})
        end
    end

    --Sort the data that is going into the list
    local sort_type = Profile:GetServerSortMode() or "SORT_LASTPLAYED"
    local sort_fn = nil
    if sort_type == "SORT_LASTPLAYED" then
        sort_fn = sorttime
    elseif sort_type == "SORT_MOSTDAYS" then
        sort_fn = sortdays
    elseif sort_type == "SORT_DATECREATED" then
        sort_fn = sortcreated
    end
    table.sort(savefilescrollitems, sort_fn)

    if not force_update and CompareSaveFilesTable(self.savefilescrollitems, savefilescrollitems) then
        return
    end

    self.savefilescrollitems = savefilescrollitems

	if #self.savefilescrollitems == 0 then
		self.noservers_message:Show()
	else
		self.noservers_message:Hide()
	end

    self.server_scroll_list:SetItemsData(self.savefilescrollitems)
    self.server_scroll_list:SetPosition(0, -26)
    self.server_scroll_list:RefreshView()
end

function ServerSlotScreen:RefreshSaveFilter(filterfn)
    self.filterfn = filterfn
    self:UpdateSaveFiles()
end

function ServerSlotScreen:GetCharacterPortrait(slot)
    local cache_slot = self.slot_cache[slot]
    if not cache_slot or not cache_slot.character_portrait then
        cache_slot = cache_slot or {}
        -- ShardSaveGameIndex:GetSlotCharacter is not cheap! Use it in FE only.
        -- V2C: This comment is here as a warning to future copy&pasters - __-"
        cache_slot.character_portrait = {character = ShardSaveGameIndex:GetSlotCharacter(slot) or ""}

        local cache = cache_slot.character_portrait
        if cache.atlas == nil then
            cache.atlas = "images/saveslot_portraits"
            if not table.contains(DST_CHARACTERLIST, cache.character) then
                if table.contains(MODCHARACTERLIST, cache.character) then
                    cache.atlas = cache.atlas.."/"..cache.character
                else
                    cache.character = #cache.character > 0 and "mod" or "unknown"
                end
            end
            cache.atlas = cache.atlas..".xml"
        end

        self.slot_cache[slot] = cache_slot
    end

    return cache_slot.character_portrait.atlas, cache_slot.character_portrait.character

end

function ServerSlotScreen:GetDayAndSeasonText(slot)
    local cache_slot = self.slot_cache[slot]
    if not cache_slot or not cache_slot.dayandseason_text then
        cache_slot = cache_slot or {}
        cache_slot.dayandseason_text = ShardSaveGameIndex:GetSlotDayAndSeasonText(slot)
        self.slot_cache[slot] = cache_slot
    end

    return cache_slot.dayandseason_text
end

function ServerSlotScreen:GetPresetText(slot)
    local cache_slot = self.slot_cache[slot]
    if not cache_slot or not cache_slot.preset_text then
        cache_slot = cache_slot or {}
        cache_slot.preset_text = ShardSaveGameIndex:GetSlotPresetText(slot)
        self.slot_cache[slot] = cache_slot
    end

    return cache_slot.preset_text
end

function ServerSlotScreen:ClearSlotCache(slot)
    self.slot_cache[slot] = nil
end

function ServerSlotScreen:OnBansButton()
    TheFrontEnd:PushScreen(BansPopup())
end

function ServerSlotScreen:OnCreateNewSlot()
    TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()
        TheFrontEnd:PushScreen(ServerCreationScreen(self, ShardSaveGameIndex:GetNextNewSlot()))
        TheFrontEnd:Fade(FADE_IN, SCREEN_FADE_TIME)
    end)
end

function ServerSlotScreen:_BuildSaveSlotList()

	local function ScrollWidgetsCtor(context, index)
		local widget = ServerSaveSlot(self)
		widget.ongainfocusfn = function(is_btn_enabled)
            self.server_scroll_list:OnWidgetFocus(widget)
        end
		return widget
    end

	local function ScrollWidgetApply(context, widget, data, index)
		widget:SetSaveSlot(data and data.server_slot or -1)
    end

    self.savefilescrollitems = {}
	for i, slot in ipairs(ShardSaveGameIndex:GetValidSlots()) do
		table.insert(self.savefilescrollitems, {server_slot=slot})
    end

    table.sort(self.savefilescrollitems, sorttime)

    local row_w = 910
    local row_h = 80
    local row_spacing = 5
    local scrollbar_offset = -12.5

    if TheInput:ControllerAttached() or IsConsole() then
        row_w = 870
        scrollbar_offset = -5
    end

	local extra_rows = nil
    if IsConsole() then
        extra_rows = 0
	end

    local grid = TEMPLATES.ScrollingGrid(
        self.savefilescrollitems,
        {
            context = {},
            widget_width  = row_w,
            widget_height = row_h+row_spacing,
            num_visible_rows = 5,
            num_columns      = 1,
            item_ctor_fn = ScrollWidgetsCtor,
            apply_fn     = ScrollWidgetApply,
            scrollbar_offset = scrollbar_offset,
            scrollbar_height_offset = -60,
			extra_rows = extra_rows,
        })

    return grid
end

function ServerSlotScreen:OnBecomeActive()
    ServerSlotScreen._base.OnBecomeActive(self)
    if IsTableEmpty(ShardSaveGameIndex:GetValidSlots()) then
        if not self.immediatenewslot then
            TheFrontEnd:PushScreen(ServerCreationScreen(self, ShardSaveGameIndex:GetNextNewSlot()))
            self.immediatenewslot = true
        else
	        TheFrontEnd:PopScreen()
            self.immediatenewslot = nil
        end
        return
    end
    self:StartUpdateSaveFiles()
    self.savefilterbar:RefreshFilterState()
    self.server_scroll_list:RefreshView()

    if self.kit_puppet then
        self.kit_puppet:Enable()
    end

    self:Show()
end

function ServerSlotScreen:OnBecomeInactive()
    ServerSlotScreen._base.OnBecomeInactive(self)
    self:_CancelTasks()

    if self.kit_puppet then
        self.kit_puppet:Disable()
    end
end

function ServerSlotScreen:OnDestroy()
    self._base.OnDestroy(self)
end

function ServerSlotScreen:Close()
	if TheFrontEnd:GetFadeLevel() < 1 then
		TheFrontEnd:Fade(false, SCREEN_FADE_TIME, function()
	        TheFrontEnd:PopScreen()
	        TheFrontEnd:Fade(true, SCREEN_FADE_TIME)
	    end)
	else
		TheFrontEnd:PopScreen()
	    TheFrontEnd:Fade(true, SCREEN_FADE_TIME)
	end
end

function ServerSlotScreen:OnControl(control, down)
    if ServerSlotScreen._base.OnControl(self, control, down) then return true end

	if not down then
		if control == CONTROL_CANCEL then
			self:Close()
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			return true
        elseif control == CONTROL_MENU_MISC_1 then
            self:OnCreateNewSlot()
            return true
		end
	end
end

function ServerSlotScreen:_DoFocusHookups()
    self.server_scroll_list:SetFocusChangeDir(MOVE_UP, self.savefilterbar)
    self.savefilterbar:SetFocusChangeDir(MOVE_DOWN, self.server_scroll_list)
    self.savefilterbar:SetFocusChangeDir(MOVE_RIGHT, self.bans_button)
    self.bans_button:SetFocusChangeDir(MOVE_LEFT, self.savefilterbar)
    self.bans_button:SetFocusChangeDir(MOVE_DOWN, self.server_scroll_list)
end

function ServerSlotScreen:GetHelpText()
	local t = {}
	local controller_id = TheInput:GetControllerID()

	table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

	table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_1) .. " " .. STRINGS.UI.SERVERCREATIONSCREEN.CREATENEWGAME)

	return table.concat(t, "  ")
end

return ServerSlotScreen