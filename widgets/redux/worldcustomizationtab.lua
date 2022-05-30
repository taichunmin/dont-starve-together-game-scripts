local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local PopupDialogScreen = require "screens/redux/popupdialog"
local WorldCustomizationList = require "widgets/redux/worldcustomizationlist"
local TEMPLATES = require "widgets/redux/templates"

local Customize = require "map/customize"
local Levels = require "map/levels"

local WorldCustomizationTab = Class(Widget, function(self, tab_location_index, servercreationscreen)
    Widget._ctor(self, "WorldCustomizationTab")
    self.tab_location_index = tab_location_index

	self.current_level_locations = SERVER_LEVEL_LOCATIONS
    assert(self.current_level_locations[self.tab_location_index])

    self.slotoptions = {}
    self.slot = -1
    -- TODO: due to legacy of supporting multiple world tabs inside this tab,
    -- we have the idea that currentmultilevel could change.
    self.currentmultilevel = self.tab_location_index
    self.allowEdit = true

    self.servercreationscreen = servercreationscreen

    -- Build the options menu so that the spinners are shown in an order that makes sense/in order of how impactful the changes are

    self.current_option_settings = {}

    --set up the preset spinner
    self.max_custom_presets = 5

    self.settings_root = self:AddChild(Widget("settings_root"))

    local spacing = 3
    local end_spacing = 15
    local label_width = 350
    local spinner_width = 375
    local spinner_height = 40 -- use default height
    local btn_width = 50
    local remove_width = 190
    local preset_width = label_width + spacing + spinner_width
    local header_width = preset_width + (spacing + btn_width)*2

    -- Top border of the scroll list.
	self.customizations_horizontal_line = self.settings_root:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
    self.customizations_horizontal_line:SetPosition(0,223)
    self.customizations_horizontal_line:SetSize(header_width+end_spacing, 5)

    self.presetpanel = self.settings_root:AddChild(Widget("presetpanel"))
    self.presetpanel:SetPosition(0, 287)
    self.presetpanel.bg = self.presetpanel:AddChild(TEMPLATES.ListItemBackground(header_width+end_spacing*2, spinner_height+end_spacing))

    self.presetdesc = self.presetpanel:AddChild(Text(CHATFONT, 25))
    self.presetdesc:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
    self.presetdesc:SetHAlign(ANCHOR_LEFT)
    self.presetdesc:SetRegionSize(header_width-remove_width, 40)
    self.presetdesc:SetString("")
    self.presetdesc:EnableWordWrap(true)
    self.presetdesc:SetPosition(-remove_width/2, -47)

    -- not sure why we have this offset
    local x = -50

    self.presetspinner = self.presetpanel:AddChild(TEMPLATES.LabelSpinner(STRINGS.UI.CUSTOMIZATIONSCREEN.USEPRESETS, {}, label_width, spinner_width, spinner_height, spacing))
    self.presetspinner:SetPosition(x,0)
    self.presetspinner.label:SetHAlign(ANCHOR_LEFT)
    self.presetspinner.spinner.OnChanged =
        function( _, data, oldData )
            if self:GetNumberOfTweaks(self.currentmultilevel) > 0 then
                if self.servercreationscreen then self.servercreationscreen.last_focus = TheFrontEnd:GetFocusWidget() end
                TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.CUSTOMIZATIONSCREEN.LOSECHANGESTITLE, STRINGS.UI.CUSTOMIZATIONSCREEN.LOSECHANGESBODY,
                    {
                        {text=STRINGS.UI.CUSTOMIZATIONSCREEN.YES, cb = function()
                            self:LoadPreset(data)
                            self:Refresh()
                            TheFrontEnd:PopScreen()
                        end},
                        {text=STRINGS.UI.CUSTOMIZATIONSCREEN.NO, cb = function()
                            self.presetspinner.spinner:SetSelected(oldData)
                            TheFrontEnd:PopScreen()
                        end}
                    }))
            else
                self:LoadPreset(data)
                self:Refresh()
            end
            self.servercreationscreen:UpdateButtons(self.slot)
            self.servercreationscreen:MakeDirty()
        end

    self.presetpanel.focus_forward = self.presetspinner

    -- edge of spinner text region is 20 over for some reason
    x = x + preset_width/2 + 20 + spacing

    local hover_config = {
        offset_x = 2,
        offset_y = -25, -- prevent hovertext from overlapping with removelevelbutton
    }
    self.revertbutton = self.presetpanel:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "undo.tex", STRINGS.UI.CUSTOMIZATIONSCREEN.REVERTCHANGES, false, false, function() self:RevertChanges() end, hover_config))
    self.revertbutton:SetPosition(x, 0)
    self.revertbutton:ForceImageSize(btn_width, btn_width)
    self.revertbutton:Select()

    x = x + btn_width + spacing

    self.savepresetbutton = self.presetpanel:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "save.tex", STRINGS.UI.CUSTOMIZATIONSCREEN.SAVEPRESET, false, false, function() self:SavePreset() end, hover_config))
    self.savepresetbutton:SetPosition(x, 0)
    self.savepresetbutton:ForceImageSize(btn_width, btn_width)

    self.removelevelbutton = self.presetpanel:AddChild(TEMPLATES.StandardButton(
        function()
            local locationname =
                STRINGS.UI.SANDBOXMENU.LOCATIONTABNAME[string.upper(Levels.GetLocationForLevelID(self.current_option_settings[self.currentmultilevel].preset) or "")] or
                STRINGS.UI.SANDBOXMENU.LOCATIONTABNAME.UNKNOWN
            TheFrontEnd:PushScreen(
                PopupDialogScreen(
                    string.format(STRINGS.UI.SANDBOXMENU.REMOVELEVEL, locationname),
                    string.format(STRINGS.UI.SANDBOXMENU.REMOVELEVEL_WARNING, locationname),
                    {
                        {
                            text = STRINGS.UI.MODSSCREEN.YES,
                            cb = function()
                                TheFrontEnd:PopScreen()
                                self:RemoveMultiLevel(self.currentmultilevel)
                                self:Refresh()
                                if TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
                                    self:SetFocus(self.focus_forward)
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
        end,
        "",
        {remove_width, 89*0.6}
        ))
    self.removelevelbutton:SetPosition(355, -42)
    self.removelevelbutton:MoveToBack() -- move behind preset buttons' hovertext
    self.removelevelbutton:SetScale(.8)
    self.presetpanel.bg:MoveToBack()

    --add the custom options panel
    self.current_option_settingspanel = self.settings_root:AddChild(Widget("optionspanel"))
    self.current_option_settingspanel:SetScale(.9)
    self.current_option_settingspanel:SetPosition(0,-10)

    local locationname, tabname = self:GetLocationName(self.tab_location_index)
    local action = string.format(STRINGS.UI.SANDBOXMENU.ADDLEVEL, tabname)
    self.sublevel_adder_overlay = self:AddChild(TEMPLATES.CurlyWindow(550,170,
            action,
            {
                {
                    text = action,
                    cb = function()
                        local function addmultilevel()
                            self:AddMultiLevel(self.tab_location_index)
                            self:Refresh()
                            if TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
                                self:SetFocus(self.focus_forward)
                            end
                            self:_SetSublevelAdderVisibility(false)
                        end
                        if not ShardSaveGameIndex:IsSlotEmpty(self.slot) then
                            TheFrontEnd:PushScreen(
                                PopupDialogScreen(action, STRINGS.UI.SANDBOXMENU.ADDLEVEL_EXISTINGWARNING,
                                {
                                    {
                                        text = action,
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
        -- Get the add caves button
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
    self.sublevel_adder_overlay.actions.items[1]:SetFocusChangeDir(MOVE_UP, self.autoaddcaves)

    self.no_sublevel = self:AddChild(Text(HEADERFONT, 40, string.format(STRINGS.UI.SANDBOXMENU.DISABLEDLEVEL, tabname), UICOLOURS.GOLD_SELECTED))

    self:HookupFocusMoves()
end)

function WorldCustomizationTab:_SetSublevelAdderVisibility(should_be_visible, should_be_enabled)
    self.sublevel_adder_overlay:GetAddButton():Disable()
    self.sublevel_adder_overlay:Hide()
    self.no_sublevel:Hide()
    if should_be_visible then
        local active = nil
        if self.allowEdit then
            active = self.sublevel_adder_overlay
            if should_be_enabled == "enabled" then
                active:GetAddButton():Enable()
            end
        else
            active = self.no_sublevel
        end
        active:Show()
        self.settings_root:Hide()
        self.focus_forward = active
    else
        self.settings_root:Show()
        self.focus_forward = self.presetspinner
    end
end

function WorldCustomizationTab:OnChangeGameMode(gamemode)
	local leveltype = GetLevelType(gamemode)

    if EVENTSERVER_LEVEL_LOCATIONS[leveltype] ~= nil then
		self.current_level_locations = EVENTSERVER_LEVEL_LOCATIONS[leveltype]
	else
		self.current_level_locations = SERVER_LEVEL_LOCATIONS
	end

    if self.current_level_locations[self.tab_location_index] == nil and self:IsLevelEnabled(self.tab_location_index) then
		self:RemoveMultiLevel(self.tab_location_index)
    end

    self:Refresh()
end

function WorldCustomizationTab:OnChangeLevelLocations(level_locations)
	self.current_level_locations = level_locations
    self:Refresh()
end

function WorldCustomizationTab:Refresh()
    self:UpdatePresetList()
    self:UpdatePresetInfo(self.currentmultilevel)
    self:UpdateMultilevelUI()
end

function WorldCustomizationTab:UpdatePresetList()
    if not self.current_option_settings[self.tab_location_index] or not self.current_level_locations[self.tab_location_index] then
        -- Our tab doesn't exist or represents an invalid level.
        return
    end

    --
    -- PRESETS
    --

    local presets = nil
    if self.allowEdit == false then
        local level = self.slotoptions[self.slot][self.currentmultilevel]
        presets = {
            {
                text = level.name,
                data = level.id,
            }
        }
        self.presetspinner.spinner:SetOptions(presets)
        self.presetspinner.spinner:SetSelected(level.id)
    else
        local level_type = GetLevelType( self.servercreationscreen:GetGameMode() )
        presets = Levels.GetLevelList(level_type, self.current_level_locations[self.currentmultilevel], true)
        self.presetspinner.spinner:SetOptions(presets)
        self.presetspinner.spinner:SetSelected(self.current_option_settings[self.currentmultilevel].preset)
        -- In case our preset disappeared, grab whatever is in the spinner.
        self.current_option_settings[self.currentmultilevel].preset = self.presetspinner.spinner:GetSelectedData()
    end

    --
    -- CUSTOMIZATION LIST
    --
    local location = self:GetLocationForLevel(self.currentmultilevel)
    assert(location ~= nil, "Can only load values for a preset with a location!")

    local options = Customize.GetOptionsWithLocationDefaults(location, self.currentmultilevel == 1)

    if self.customizationlist ~= nil then
        self.customizationlist:Kill()
    end

    if self:IsLevelEnabled(self.currentmultilevel) then
        self.customizationlist = self.current_option_settingspanel:AddChild(WorldCustomizationList(location, options,
            function(option, value)
                self:SetTweak(self.currentmultilevel, option, value)
            end))
        self.customizationlist:SetFocusChangeDir(MOVE_LEFT, self.servercreationscreen.getfocussaveslot)
        self.customizationlist:SetFocusChangeDir(MOVE_UP, self.presetpanel)
        local leveldata = Levels.GetDataForLevelID(self.current_option_settings[self.currentmultilevel].preset)
        if leveldata ~= nil then -- e.g. loading a slot for a disabled mod
            self.customizationlist:SetPresetValues(leveldata.overrides)
        end
        self.customizationlist:SetEditable(self.allowEdit)

        for i,v in ipairs(options) do
            self.customizationlist:SetValueForOption(v.name, self:GetValueForOption(self.currentmultilevel, v.name))
        end
    end
end


function WorldCustomizationTab:GetValueForOption(level, option)
    local presetdata = nil
    if not self.allowEdit then
        presetdata = deepcopy(self.slotoptions[self.slot][level])
    else
        presetdata = Levels.GetDataForLevelID(self.current_option_settings[level].preset)
    end
    return self.current_option_settings[level].tweaks[option]
        or (presetdata ~= nil and presetdata.overrides[option])
        or Customize.GetLocationDefaultForOption(presetdata.location, option)
end

function WorldCustomizationTab:AddMultiLevel(level)
    if level ~= 1 and self.current_option_settings[level] == nil then
        self:LoadPreset(nil)
    end
end

function WorldCustomizationTab:RemoveMultiLevel(level)
    if level ~= 1 and self.current_option_settings[level] ~= nil then
        self.current_option_settings[level] = nil
    end
end

function WorldCustomizationTab:GetLocationForLevel(level)
    return (self.current_option_settings[level] ~= nil
            and self.current_option_settings[level].preset ~= nil
            and Levels.GetLocationForLevelID(self.current_option_settings[level].preset))
        or self.current_level_locations[level]
end

function WorldCustomizationTab:GetLocationStringID(level)
    if self.current_option_settings[level] ~= nil
        and self.current_option_settings[level].preset ~= nil then

        local location = Levels.GetLocationForLevelID(self.current_option_settings[level].preset)
        return location ~= nil and string.upper(location) or "UNKNOWN"
    end

    -- if there is no preset yet, use the default
    return string.upper(self.current_level_locations[level])
end

function WorldCustomizationTab:GetLocationName(level)
    local locationid = self:GetLocationStringID(level)
    local locationname = STRINGS.UI.SANDBOXMENU.LOCATION[locationid] or STRINGS.UI.SANDBOXMENU.LOCATION["UNKNOWN"]
    local tabname = STRINGS.UI.SANDBOXMENU.LOCATIONTABNAME[locationid] or STRINGS.UI.SANDBOXMENU.LOCATION["UNKNOWN"]
    return locationname, tabname
end

function WorldCustomizationTab:BuildMenuEntry()
    local locationname,tabname = self:GetLocationName(self.tab_location_index)
    return { key = self.current_level_locations[self.tab_location_index], text = tabname, }
end

function WorldCustomizationTab:UpdateMultilevelUI()

    if self.allowEdit and self.currentmultilevel ~= 1 and IsNotConsole() then
        self.removelevelbutton:Show()
    else
        self.removelevelbutton:Hide()
    end

    local i = self.tab_location_index
    local valid_level = self.current_level_locations[i] ~= nil

    if valid_level then
        local locationname, tabname = self:GetLocationName(self.currentmultilevel)
        self.presetspinner.label:SetString(string.format(STRINGS.UI.SANDBOXMENU.USEPRESETS_LOCATION, locationname))
        self.removelevelbutton:SetText(string.format(STRINGS.UI.SANDBOXMENU.REMOVELEVEL, tabname))
    end

    if not valid_level then
        --tab is disabled, there is no level to pick from
        self:_SetSublevelAdderVisibility(true, "disabled")
    elseif self:IsLevelEnabled(i) then
        --tab is enabled, make it look like a regular tab
        self:_SetSublevelAdderVisibility(false)
    elseif self.allowEdit then
        --tab is useful, make it look like an "Add ___" button
        self:_SetSublevelAdderVisibility(true, "enabled")
    else
        --tab is disabled, but we can't add it because this slot is not editable
        self:_SetSublevelAdderVisibility(true, "disabled")
    end
end

function WorldCustomizationTab:UpdatePresetInfo(level)
    if level ~= self.currentmultilevel -- this might be called for the "unselected" level, so we don't want to do anything.
        or not self:IsLevelEnabled(level) -- invalid so we can't show anything.
        then
        return
    end

    local clean = self:GetNumberOfTweaks(self.currentmultilevel) == 0

    if not self.allowEdit then
        self.presetdesc:SetString(self.slotoptions[self.slot][self.currentmultilevel].desc)
        self.presetspinner.spinner:UpdateText(self.slotoptions[self.slot][self.currentmultilevel].name)
    elseif clean then
        self.presetdesc:SetString(Levels.GetDescForLevelID(self.current_option_settings[self.currentmultilevel].preset))
        self.presetspinner.spinner:UpdateText(Levels.GetNameForLevelID(self.current_option_settings[self.currentmultilevel].preset))
    elseif self.current_option_settings[self.currentmultilevel].preset == "MOD_MISSING" then
        self.presetdesc:SetString(Levels.GetDescForLevelID("MOD_MISSING"))
        self.presetspinner.spinner:UpdateText(Levels.GetNameForLevelID("MOD_MISSING"))
    else
        self.presetdesc:SetString(STRINGS.UI.CUSTOMIZATIONSCREEN.CUSTOMDESC)
        self.presetspinner.spinner:UpdateText(string.format(STRINGS.UI.CUSTOMIZATIONSCREEN.CUSTOM, Levels.GetNameForLevelID(self.current_option_settings[self.currentmultilevel].preset)))
    end

    if self.allowEdit then
        self.revertbutton:Show()
        self.savepresetbutton:Show()
    else
        self.revertbutton:Hide()
        self.savepresetbutton:Hide()
    end

    if not clean and self.allowEdit then
        self.revertbutton:Unselect()
    else
        self.revertbutton:Select()
    end
end

function WorldCustomizationTab:SetTweak(level, option, value)
    local presetdata = Levels.GetDataForLevelID(self.current_option_settings[level].preset)
    if presetdata ~= nil and presetdata.overrides[option] ~= nil then
        if value == presetdata.overrides[option] then
            self.current_option_settings[level].tweaks[option] = nil
        else
            self.current_option_settings[level].tweaks[option] = value
        end
    else
        if value == Customize.GetLocationDefaultForOption(presetdata.location, option) then
            self.current_option_settings[level].tweaks[option] = nil
        else
            self.current_option_settings[level].tweaks[option] = value
        end
    end
    self:UpdatePresetInfo(level)
end

function WorldCustomizationTab:VerifyValidSeasonSettings()
    -- Only main world (index 1) has seasons.
    if self.tab_location_index == 1 then
        local autumn = self:GetValueForOption(self.tab_location_index, "autumn")
        local winter = self:GetValueForOption(self.tab_location_index, "winter")
        local spring = self:GetValueForOption(self.tab_location_index, "spring")
        local summer = self:GetValueForOption(self.tab_location_index, "summer")
        if autumn == "noseason" and winter == "noseason" and spring == "noseason" and summer == "noseason" then
            return false
        end
    end
    return true
end

function WorldCustomizationTab:LoadPreset(preset)
    local presetdata = nil
    if preset ~= nil then
        presetdata = Levels.GetDataForLevelID(preset)
    else
        local level_type = GetLevelType( self.servercreationscreen:GetGameMode() )
        local location = self.current_level_locations[self.tab_location_index]
        presetdata = Levels.GetDefaultLevelData(level_type, location)
    end

    if self.allowEdit then
        assert(presetdata ~= nil, "Could not load a preset with id "..tostring(preset) ..". ", tostring(self.servercreationscreen:GetGameMode()), tostring(GetLevelType(self.servercreationscreen:GetGameMode())), tostring(self.current_level_locations[self.tab_location_index]))
    else
        if presetdata == nil then
            print(string.format("WARNING! Could not load a preset with id %s, loading MOD_MISSING preset instead.", tostring(preset)))
            presetdata = Levels.GetDataForLevelID("MOD_MISSING")
        end
    end

    self.current_option_settings[self.tab_location_index] = {}
    self.current_option_settings[self.tab_location_index].preset = presetdata.id
    self.current_option_settings[self.tab_location_index].tweaks = {}

    self:UpdatePresetInfo(self.tab_location_index)
end

function WorldCustomizationTab:SavePreset()

    local function AddPreset(index, sourcedata, tweaks)
        local presetid = "CUSTOM_PRESET_"..index
        local presetname = STRINGS.UI.CUSTOMIZATIONSCREEN.CUSTOM_PRESET.." "..index
        local presetdesc = STRINGS.UI.CUSTOMIZATIONSCREEN.CUSTOM_PRESET_DESC.." "..index..". "..STRINGS.UI.CUSTOMIZATIONSCREEN.CUSTOMDESC

        local preset = {
            id        = presetid,
            name      = presetname,
            desc      = presetdesc,
            overrides = deepcopy(tweaks),
        }

        preset = MergeMapsDeep(sourcedata, preset)

        -- And save it to the profile
        Profile:AddWorldCustomizationPreset(preset, index)
        Profile:Save()

        self:LoadPreset(presetid)
        self:Refresh()

        if self.servercreationscreen then self.servercreationscreen:UpdateButtons(self.slot) end
    end

    if self:GetNumberOfTweaks() <= 0 then return end

    -- Figure out what the id, name and description should be
    local presetnum = (Profile:GetWorldCustomizationPresets() and #Profile:GetWorldCustomizationPresets() or 0) + 1

    -- If we're at max num of presets, show a modal dialog asking which one to replace
    if presetnum > self.max_custom_presets then
        local modal = nil -- forward declare
        local menuitems =
        {
            {text=STRINGS.UI.CUSTOMIZATIONSCREEN.OVERWRITE,
                cb = function()
                    TheFrontEnd:PopScreen()
                    AddPreset(modal.overwrite_spinner.spinner:GetSelectedIndex(), Levels.GetDataForLevelID(self.current_option_settings[self.currentmultilevel].preset, true), self.current_option_settings[self.currentmultilevel].tweaks)
                end},
            {text=STRINGS.UI.CUSTOMIZATIONSCREEN.CANCEL,
                cb = function()
                    TheFrontEnd:PopScreen()
                end}
        }
        modal = PopupDialogScreen(
            STRINGS.UI.CUSTOMIZATIONSCREEN.MAX_PRESETS_EXCEEDED_TITLE,
            STRINGS.UI.CUSTOMIZATIONSCREEN.MAX_PRESETS_EXCEEDED_BODY,
            menuitems,
            nil,
            "big"
            )

        local spinner_options = {}
        for i=1,self.max_custom_presets do
            table.insert(spinner_options, {text=tostring(i), data=i})
        end
        local size = JapaneseOnPS4() and 28 or 30
        modal.overwrite_spinner = modal.proot:AddChild(TEMPLATES.LabelSpinner(STRINGS.UI.CUSTOMIZATIONSCREEN.CUSTOM_PRESET, spinner_options, 200, 110, 40, 5, NEWFONT, size))
        modal.overwrite_spinner.spinner:SetSelected("1")
        modal.overwrite_spinner:SetPosition(-30,-20)
        -- This spinner bg doesn't look good on black.
        --~ modal.overwrite_spinner.bg = modal.overwrite_spinner:AddChild(TEMPLATES.ListItemBackground_Static(270, 60))
        --~ modal.overwrite_spinner.bg:MoveToBack()
        --~ modal.overwrite_spinner.bg.focus_forward = modal.overwrite_spinner
        --~ modal.overwrite_spinner.bg:SetTint(1,1,1,1) -- too dark to see
        --~ modal.overwrite_spinner.bg:SetPosition(25,0)

        modal.dialog.actions:SetFocusChangeDir(MOVE_UP, modal.overwrite_spinner)
        modal.overwrite_spinner:SetFocusChangeDir(MOVE_DOWN, modal.dialog.actions)

        modal.dialog.body:SetPosition(0, 60)
        if self.servercreationscreen then self.servercreationscreen.last_focus = TheFrontEnd:GetFocusWidget() end
        TheFrontEnd:PushScreen(modal)
    else -- Otherwise, just save it
        AddPreset(presetnum, Levels.GetDataForLevelID(self.current_option_settings[self.currentmultilevel].preset, true), self.current_option_settings[self.currentmultilevel].tweaks)
    end
end

function WorldCustomizationTab:IsLevelEnabled(level)
    return self.current_option_settings[level] ~= nil
end

function WorldCustomizationTab:CollectOptions()
    -- Everything outside of this screen only ever sees a flattened final list of settings.
    local ret = nil
    local level_index,level = self.tab_location_index, self.current_option_settings[self.tab_location_index]
    if level then
		local preset = level.preset
        ret = Levels.GetDataForLevelID(preset)
        local options = Customize.GetOptionsWithLocationDefaults(Levels.GetLocationForLevelID(preset), level_index == 1)
        for i,option in ipairs(options) do
            ret.overrides[option.name] = self:GetValueForOption(level_index, option.name)
        end
    end

    return ret
end

function WorldCustomizationTab:UpdateSaveSlot(slot)
    self.slot = slot
end

function WorldCustomizationTab:SetDataForSlot(slot)
    self.allowEdit = true
    self.slot = slot

    self.current_option_settings = {}

    -- No save data
    if ShardSaveGameIndex:IsSlotEmpty(slot) then
        if self.tab_location_index == 1 or Profile:GetAutoCavesEnabled() then
            -- If we're the default location, load up a preset. (Otherwise, we
            -- wait for user to add us.)
            self:LoadPreset(nil)
			self:UpdateMultilevelUI()
        end
    else -- Save data
        self.allowEdit = false

        local options = ShardSaveGameIndex:GetSlotGenOptions(slot, self.tab_location_index == 1 and "Master" or "Caves")
        if options == nil or GetTableSize(options) == 0 then

            local use_legacy_session_path = ShardSaveGameIndex:GetSlotServerData(slot).use_legacy_session_path
            if not use_legacy_session_path and self.tab_location_index ~= 1 and not ShardSaveGameIndex:IsSlotMultiLevel(slot) then
                self.allowEdit = true
            end

            self.slotoptions[slot] = self.slotoptions[slot] or {}
            if not self.allowEdit then
                -- Ruh roh! Bad data. Fill in with a default.
                local location = self.current_level_locations[self.tab_location_index]
                local level_type = GetLevelType( self.servercreationscreen:GetGameMode() )
                local presetdata = Levels.GetDefaultLevelData(level_type, location)
                self.slotoptions[slot][self.tab_location_index] = presetdata
            end
        else
            self.slotoptions[slot] = self.slotoptions[slot] or {}
            self.slotoptions[slot][self.tab_location_index] = options
        end

        local level = self.slotoptions[slot][self.tab_location_index]
        if level then
            self:LoadPreset(level.id)
            for option, value in pairs(level.overrides or {}) do
                self:SetTweak(self.tab_location_index, option, value) -- SetTweak deduplicates.
            end
        end
    end

    self:Refresh()
end

function WorldCustomizationTab:GetNumberOfTweaks(levelonly)
    local numTweaks = 0
    for i, level in pairs(self.current_option_settings) do
        if levelonly == nil or i == levelonly then
            if level then
                for tweak,v in pairs(level.tweaks) do
                    numTweaks = numTweaks + 1
                end
            end
        end
    end
    return numTweaks
end

function WorldCustomizationTab:RevertChanges()
    if self.servercreationscreen then self.servercreationscreen.last_focus = TheFrontEnd:GetFocusWidget() end
    TheFrontEnd:PushScreen(
        PopupDialogScreen( STRINGS.UI.CUSTOMIZATIONSCREEN.BACKTITLE, STRINGS.UI.CUSTOMIZATIONSCREEN.BACKBODY,
        {
            {
                text = STRINGS.UI.CUSTOMIZATIONSCREEN.YES,
                cb = function()

                    self:LoadPreset(self.current_option_settings[self.currentmultilevel].preset)
                    self:Refresh()

                    TheFrontEnd:PopScreen()
                end,
            },
            {
                text = STRINGS.UI.CUSTOMIZATIONSCREEN.NO,
                cb = function()
                    TheFrontEnd:PopScreen()
                end,
            },
          }
        )
    )
end

function WorldCustomizationTab:HookupFocusMoves()
    -- We Kill the list repeatedly so we need a level of indirection to find it again.
    local function tocustomizationlist()
        return self.customizationlist
    end

    local function SequenceFocusHorizontal(left, right)
        left:SetFocusChangeDir(MOVE_RIGHT, right)
        right:SetFocusChangeDir(MOVE_LEFT, left)
    end

    self.presetpanel:SetFocusChangeDir(MOVE_DOWN, tocustomizationlist)
    SequenceFocusHorizontal(self.presetspinner, self.revertbutton)
    SequenceFocusHorizontal(self.revertbutton, self.savepresetbutton)
    self.presetspinner:SetFocusChangeDir(MOVE_DOWN, self.removelevelbutton)
    self.revertbutton:SetFocusChangeDir(MOVE_DOWN, self.removelevelbutton)
    self.savepresetbutton:SetFocusChangeDir(MOVE_DOWN, self.removelevelbutton)
    self.removelevelbutton:SetFocusChangeDir(MOVE_UP, self.presetspinner)
end

return WorldCustomizationTab
