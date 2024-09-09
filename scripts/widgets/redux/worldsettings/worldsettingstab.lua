local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local PopupDialogScreen = require "screens/redux/popupdialog"
local WorldSettingsMenu = require "widgets/redux/worldsettings/worldsettingsmenu"
local TEMPLATES = require "widgets/redux/templates"

local Levels = require("map/levels")

local remove_width = 190

local width_scale = 275/256
local height_scale = 45/64

local WorldSettingsTab = Class(Widget, function(self, location_index, servercreationscreen)
    Widget._ctor(self, "WorldSettingsTab")

    self.location_index = location_index
    self.servercreationscreen = servercreationscreen

	self.locations = SERVER_LEVEL_LOCATIONS
    assert(self.locations[self.location_index])

    self.root = self:AddChild(Widget("root"))

    self.settings_root = self.root:AddChild(Widget("settings_root"))
    self.tab_root = self.settings_root:AddChild(Widget("tab_root"))

    self.settings_widget = self.settings_root:AddChild(WorldSettingsMenu(LEVELCATEGORY.SETTINGS, self))
    self.settings_widget:Hide()
    self.worldgen_widget = self.settings_root:AddChild(WorldSettingsMenu(LEVELCATEGORY.WORLDGEN, self))
    self.worldgen_widget:Hide()

    self.worldsettings_widgets = {
        self.settings_widget,
        self.worldgen_widget,
    }

    local tab_tint_width = 1073
    local tab_tint_height = 60

    self.tab_tint_bg = self.tab_root:AddChild(TEMPLATES.PlainBackground())
    self.tab_tint_bg:SetScissor(-tab_tint_width/2, -tab_tint_height/2, tab_tint_width, tab_tint_height)
    self.tab_tint_bg:SetPosition(0,295)

    self.tab_tint = self.tab_root:AddChild(Image("images/global.xml", "square.tex"))
    local r,g,b = unpack(UICOLOURS.BROWN_DARK)
    self.tab_tint:SetTint(r, g, b, 0.2)
    self.tab_tint:SetSize(tab_tint_width, tab_tint_height)
    self.tab_tint:SetPosition(0,295)

    local button_data = {
        {text = STRINGS.UI.CUSTOMIZATIONSCREEN.TAB_TITLE_WORLDSETTINGS, get_widget_fn = function() return self.settings_widget end},
        {text = STRINGS.UI.CUSTOMIZATIONSCREEN.TAB_TITLE_WORLDGENERATION, get_widget_fn = function() return self.worldgen_widget end},
	}

    local function MakeTab(data, index)
        local tab = ImageButton("images/frontend_redux.xml", "list_tabs_normal.tex", nil, nil, nil, "list_tabs_selected.tex", nil, {0,4})

		tab:SetText(data.text)
        tab:SetTextSize(22)
		tab:SetNormalScale(width_scale, height_scale)
        tab.scale_on_focus = false
        tab:UseFocusOverlay("list_tabs_hover.tex")
        tab:SetFont(CHATFONT)
        tab:SetDisabledFont(CHATFONT)
        tab:SetTextColour(UICOLOURS.GOLD_CLICKABLE)
        tab:SetTextFocusColour(UICOLOURS.GOLD_FOCUS)
        tab:SetTextDisabledColour(UICOLOURS.GOLD_UNIMPORTANT)
        tab:SetTextSelectedColour(UICOLOURS.BLACK)

        tab:SetOnClick(function()
	        self.last_selected:Unselect()
	        self.last_selected = tab
			tab:Select()
            tab:MoveToFront()

            self.activesettingswidget:Hide()
            self.activesettingswidget = data.get_widget_fn()
            self.activesettingswidget:Show()
        end)

		return tab
	end

	self.tabs = {}
	for i = 1, #button_data do
		table.insert(self.tabs, self.tab_root:AddChild(MakeTab(button_data[i], i)))
		self.tabs[#self.tabs]:MoveToBack()
    end
    self.tab_tint:MoveToBack()
    self.tab_tint_bg:MoveToBack()
    self:_PositionTabs(self.tabs, 230*width_scale, 283)

	self.last_selected = self.tabs[1]
	self.last_selected:Select()
	self.last_selected:MoveToFront()
	self.activesettingswidget = button_data[1].get_widget_fn()
    self.activesettingswidget:Show()

	self.focus_forward = function() return self.last_selected end

    -- Top border of the scroll list.
    self.customizations_horizontal_line = self.settings_root:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
    self.customizations_horizontal_line:SetPosition(0,285-(64*height_scale)/2)
    self.customizations_horizontal_line:SetSize(1073, 5)

    if not self:IsMasterLevel() then
        local locationname = self:GetLocationName()
        local tabname = self:GetLocationTabName()

        local remove_action = string.format(STRINGS.UI.SANDBOXMENU.REMOVELEVEL, tabname)

        self.removelevelbutton = self.tab_root:AddChild(TEMPLATES.StandardButton(
            function()
                local locationtabname = self:GetLocationTabName()
                TheFrontEnd:PushScreen(
                    PopupDialogScreen(
                        string.format(STRINGS.UI.SANDBOXMENU.REMOVELEVEL, locationtabname),
                        string.format(STRINGS.UI.SANDBOXMENU.REMOVELEVEL_WARNING, locationtabname),
                        {
                            {
                                text = STRINGS.UI.MODSSCREEN.YES,
                                cb = function()
                                    TheFrontEnd:PopScreen()
                                    self:RemoveMultiLevel()
                                    self:Refresh()
                                    if TheInput:ControllerAttached() then
                                        self:ClearFocus()
                                        self:SetFocus()
                                    end
                                end,
                            },
                            {
                                text = STRINGS.UI.MODSSCREEN.NO,
                                cb = function() TheFrontEnd:PopScreen() end,
                            },
                        }
                    )
                )
            end, remove_action, {remove_width, 89*0.6}))
        self.removelevelbutton:SetPosition(460, 285)
        self.removelevelbutton:SetScale(0.8)

        local add_action = string.format(STRINGS.UI.SANDBOXMENU.ADDLEVEL, tabname)
        self.sublevel_adder_overlay = self.root:AddChild(TEMPLATES.CurlyWindow(550,170,
            add_action,
            {
                {
                    text = add_action,
                    cb = function()
                        local function addmultilevel()
                            self:AddMultiLevel()
                            self:Refresh()
                            if TheInput:ControllerAttached() then
                                self:ClearFocus()
                                self:SetFocus()
                            end
                        end
                        if not ShardSaveGameIndex:IsSlotEmpty(self.slot) then
                            TheFrontEnd:PushScreen(
                                PopupDialogScreen(add_action, STRINGS.UI.SANDBOXMENU.ADDLEVEL_EXISTINGWARNING,
                                {
                                    {
                                        text = add_action,
                                        cb = function()
                                            TheFrontEnd:PopScreen()
                                            addmultilevel()
                                        end
                                    },
                                    {
                                        text = STRINGS.UI.SERVERCREATIONSCREEN.CANCEL,
                                        cb = function()
                                            TheFrontEnd:PopScreen()
                                        end
                                    }
                                }
                                )
                            )
                        else
                            addmultilevel()
                        end
                    end,
                },
            },
            nil,
            string.format(STRINGS.UI.SANDBOXMENU.ADDLEVEL_WARNING, locationname)
        ))
        self.sublevel_adder_overlay.GetAddButton = function(_)
            --Get the add caves button
            return self.sublevel_adder_overlay.actions.items[1]
        end
        self.sublevel_adder_overlay.body:SetPosition(0, 60)

        self.autoaddcaves = self.sublevel_adder_overlay:AddChild(TEMPLATES.LabelCheckbox(
                function(w)
                    w.checked = not w.checked
                    Profile:SetAutoCavesEnabled(w.checked)
                    Profile:Save()
                    w:Refresh()
                end,
                Profile:GetAutoCavesEnabled(),
                string.format(STRINGS.UI.SANDBOXMENU.AUTOADDLEVEL, tabname)))

        local text_width = self.autoaddcaves.text:GetRegionSize()
        self.autoaddcaves:SetPosition(-0.5 * text_width, -10)
        self.autoaddcaves:SetFocusChangeDir(MOVE_DOWN, self.sublevel_adder_overlay.actions.items[1])
        self.sublevel_adder_overlay:GetAddButton():SetFocusChangeDir(MOVE_UP, self.autoaddcaves)

        self.no_sublevel = self.root:AddChild(Text(HEADERFONT, 40, string.format(STRINGS.UI.SANDBOXMENU.DISABLEDLEVEL, tabname), UICOLOURS.GOLD_SELECTED))
    end

    self:DoFocusHookups()
end)

function WorldSettingsTab:_PositionTabs(tabs, w, y)
	local offset = #self.tabs / 2
	for i = 1, #self.tabs do
		local x = (i - offset - 0.5) * w
		tabs[i]:SetPosition(x, y)
	end
end

function WorldSettingsTab:AddMultiLevel()
    if not self.level_enabled then
        self.level_enabled = true
        for i, v in ipairs(self.worldsettings_widgets) do
            v:LoadPreset()
            v:Refresh()
        end
    end
end

function WorldSettingsTab:RemoveMultiLevel()
    if not self:IsMasterLevel() and self.level_enabled then
        self.level_enabled = false
    end
end

function WorldSettingsTab:UpdateSublevelControlsVisibility()
    if not self:IsMasterLevel() then
        if self.isnewshard and IsNotConsole() then
            self.removelevelbutton:Show()
        else
            self.removelevelbutton:Hide()
        end

        local valid_level = self.locations[self.location_index] ~= nil

        self.sublevel_adder_overlay:GetAddButton():Disable()
        self.sublevel_adder_overlay:Hide()
        self.no_sublevel:Hide()
        if not valid_level or not self.level_enabled then
            local active = nil
            if self.isnewshard and valid_level then
                active = self.sublevel_adder_overlay
                active:GetAddButton():Enable()
            else
                active = self.no_sublevel
            end
            active:Show()
            self.settings_root:Hide()
            self.focus_forward = active
            return
        else
            self.focus_forward = function() return self.last_selected end
        end
        self:DoFocusHookups()
    end

    self.settings_root:Show()
end

function WorldSettingsTab:Refresh()
    for i, v in ipairs(self.worldsettings_widgets) do
        v:Refresh()
    end
    self:UpdateSublevelControlsVisibility()
end

function WorldSettingsTab:GetSlotOptions()
    local options = ShardSaveGameIndex:GetSlotGenOptions(self.slot, SERVER_LEVEL_SHARDS[self.location_index])
    if not options or IsTableEmpty(options) then
        options = nil
    end
    return options
end

function WorldSettingsTab:IsNewShard()
    return self.isnewshard
end

function WorldSettingsTab:GetLocations()
    return self.locations
end

function WorldSettingsTab:GetCurrentLocation()
    return self.locations[self.location_index]
end

function WorldSettingsTab:GetGameMode()
    return self.servercreationscreen:GetGameMode()
end

function WorldSettingsTab:IsLevelEnabled()
    return self.level_enabled
end

function WorldSettingsTab:IsMasterLevel()
    return self.location_index == 1
end

function WorldSettingsTab:GetLocation()
    return self.worldgen_widget:GetLocation() or self:GetCurrentLocation()
end

function WorldSettingsTab:GetLocationStringID()
    return string.upper(self.worldgen_widget:GetLocation() or self:GetCurrentLocation())
end

function WorldSettingsTab:GetLocationName()
    return STRINGS.UI.SANDBOXMENU.LOCATION[self:GetLocationStringID()]
end

function WorldSettingsTab:GetLocationTabName()
    return STRINGS.UI.SANDBOXMENU.LOCATIONTABNAME[self:GetLocationStringID()]
end

function WorldSettingsTab:UpdatePresetMode(mode)
    self.servercreationscreen:UpdatePresetMode(mode == "seperate" and "combined" or "seperate")
end

function WorldSettingsTab:SetPresetMode(mode)
    Profile:SetPresetMode(mode)
    self.settings_widget:SetPresetMode(mode)
    self.worldgen_widget:SetPresetMode(mode)
end

function WorldSettingsTab:OnCombinedPresetButton(presetid)
    local gamemode = self:GetGameMode()
    local level_type = GetLevelType(gamemode)
    local location = self:GetCurrentLocation()

    local settings_presetdata = Levels.GetDataForID(LEVELCATEGORY.SETTINGS, presetid)
    local settings_defaultdata = Levels.GetDefaultData(LEVELCATEGORY.SETTINGS, level_type, location)
    local settings_presetid = settings_presetdata ~= nil and presetid or settings_defaultdata.id
    self.settings_widget:OnPresetButton(settings_presetid)

    local worldgen_presetdata = Levels.GetDataForID(LEVELCATEGORY.WORLDGEN, presetid)
    local worldgen_defaultdata = Levels.GetDefaultData(LEVELCATEGORY.WORLDGEN, level_type, location)
    local worldgen_presetid = worldgen_presetdata ~= nil and presetid or worldgen_defaultdata.id
    self.worldgen_widget:OnPresetButton(worldgen_presetid)
end

function WorldSettingsTab:RefreshPlaystyleIndicator(playstyle)
	self.settings_widget:RefreshPlaystyleIndicator(playstyle)
end

function WorldSettingsTab:GetNumberOfCombinedTweaks()
    return self.settings_widget:GetNumberOfTweaks() + self.worldgen_widget:GetNumberOfTweaks()
end

function WorldSettingsTab:SaveCombinedPreset(presetid, name, desc, noload)
    local saved = self.settings_widget:SavePreset(presetid, name, desc, true)
    saved = saved and self.worldgen_widget:SavePreset(presetid, name, desc, true)

    if not saved then
        self:DeleteCombinedPreset(presetid)
    elseif not noload then
        self.settings_widget:OnPresetButton(presetid)
        self.worldgen_widget:OnPresetButton(presetid)
    end
    return saved
end

function WorldSettingsTab:EditCombinedPreset(originalid, presetid, name, desc, updateoverrides)
    local saved = true
    if updateoverrides then
        saved = saved and self.settings_widget:SavePreset(presetid, name, desc, true)
    else
        saved = saved and CustomPresetManager:SaveCustomPreset(self.settings_widget.levelcategory, presetid, self.settings_widget.settings.basepreset or self.settings_widget.settings.preset, {}, name, desc)
    end

    if updateoverrides then
        saved = saved and self.worldgen_widget:SavePreset(presetid, name, desc, true)
    else
        saved = saved and CustomPresetManager:SaveCustomPreset(self.worldgen_widget.levelcategory, presetid, self.worldgen_widget.settings.basepreset or self.worldgen_widget.settings.preset, {}, name, desc)
    end

    if not saved then
        if presetid ~= originalid then
            self:DeleteCombinedPreset(originalid)
        end
    else
        self.settings_widget:OnPresetButton(presetid)
        self.worldgen_widget:OnPresetButton(presetid)
        if presetid ~= originalid then
            self:DeleteCombinedPreset(originalid)
        end
    end
    return saved
end

function WorldSettingsTab:DeleteCombinedPreset(presetid)
    self.settings_widget:DeletePreset(presetid)
    self.worldgen_widget:DeletePreset(presetid)
end

--called from ServerCreationScreen
function WorldSettingsTab:RefreshOptionItems()
    for i, v in ipairs(self.worldsettings_widgets) do
        v:ReloadPreset()
        v:RefreshOptionItems()
    end
end

--called from ServerCreationScreen
function WorldSettingsTab:UpdateSaveSlot(slot)
    self.slot = slot
end

--called from ServerCreationScreen
function WorldSettingsTab:SetDataForSlot(slot, ...)
    self.slot = slot
    self.isnewshard = ShardSaveGameIndex:IsSlotEmpty(slot)

    if self.isnewshard then
        if self:IsMasterLevel() or Profile:GetAutoCavesEnabled() then
            self:AddMultiLevel()
        end
    else
        local options = ShardSaveGameIndex:GetSlotGenOptions(slot, SERVER_LEVEL_SHARDS[self.location_index])
        if options == nil or IsTableEmpty(options) then
            local use_legacy_session_path = ShardSaveGameIndex:GetSlotServerData(slot).use_legacy_session_path
            if not use_legacy_session_path and not self:IsMasterLevel() and not ShardSaveGameIndex:IsSlotMultiLevel(slot) then
                self.isnewshard = true
            end

            if not self.isnewshard then
                self.level_enabled = true
                for i, v in ipairs(self.worldsettings_widgets) do
                    v:SetDataFromOptions()
                end
            end
        else
            self.level_enabled = true
            for i, v in ipairs(self.worldsettings_widgets) do
                v:SetDataFromOptions(options)
            end
        end
    end

    self:Refresh()
end

--called from ServerCreationScreen
function WorldSettingsTab:CollectOptions()
    if self:IsLevelEnabled() then
        local worldgen_options = self.worldgen_widget:CollectOptions()
        local settings_options = self.settings_widget:CollectOptions()
        local options = MergeMapsDeep(worldgen_options, settings_options)
        options.location = worldgen_options.location --location only matters for worldgen presets
        return options
    end
end

--called from ServerCreationScreen
function WorldSettingsTab:OnChangeGameMode(gamemode)
    self:OnChangeLevelLocations(EVENTSERVER_LEVEL_LOCATIONS[GetLevelType(gamemode)] or SERVER_LEVEL_LOCATIONS)
end

--called from ServerCreationScreen
function WorldSettingsTab:OnChangeLevelLocations(level_locations)
    local old_location = self.locations[self.location_index]
    self.locations = level_locations or SERVER_LEVEL_LOCATIONS
    local new_location = self.locations[self.location_index]

    if new_location == nil then
		self:RemoveMultiLevel()
    elseif new_location ~= old_location then
        for i, v in ipairs(self.worldsettings_widgets) do
            v:LoadPreset()
        end
    end

    self:RefreshOptionItems()
    self:Refresh()
end

--called from ServerCreationScreen
function WorldSettingsTab:BuildMenuEntry()
    return {key = self.locations[self.location_index], text = self:GetLocationTabName()}
end

--called from ServerCreationScreen
function WorldSettingsTab:VerifyValidSeasonSettings()
    for i, v in ipairs(self.worldsettings_widgets) do
        if not v:VerifyValidSeasonSettings() then
            return false
        end
    end
    return true
end

function WorldSettingsTab:DoFocusHookups()
    local function getactivemenu() return self.activesettingswidget.parent_default_focus end
    for i, v in ipairs(self.tabs) do
        if self.tabs[i - 1] then
            v:SetFocusChangeDir(MOVE_LEFT, self.tabs[i - 1])
        end
        if self.tabs[i + 1] then
            v:SetFocusChangeDir(MOVE_RIGHT, self.tabs[i + 1])
        end
        v:SetFocusChangeDir(MOVE_DOWN, getactivemenu)
    end

    if self.removelevelbutton and self.removelevelbutton:IsVisible() then
        local last_tab = self.tabs[#self.tabs]
        last_tab:SetFocusChangeDir(MOVE_RIGHT, self.removelevelbutton)

        self.removelevelbutton:SetFocusChangeDir(MOVE_LEFT, last_tab)
        self.removelevelbutton:SetFocusChangeDir(MOVE_DOWN, getactivemenu)
    end
end
return WorldSettingsTab
