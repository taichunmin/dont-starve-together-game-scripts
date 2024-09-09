local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Spinner = require "widgets/spinner"
local NumericSpinner = require "widgets/numericspinner"
local PopupDialogScreen = require "screens/popupdialog"
local CustomizationList = require "widgets/customizationlist"
local TEMPLATES = require "widgets/templates"

local Customize = require "map/customize"
local Levels = require "map/levels"

local function OnClickTab(self, level)
    if level ~= 1 and not self:IsLevelEnabled(level) then
        local locationid = self:GetLocationStringID(level)
        local locationname = STRINGS.UI.SANDBOXMENU.LOCATIONTABNAME[locationid]

        TheFrontEnd:PushScreen(
            PopupDialogScreen(
                string.format(STRINGS.UI.SANDBOXMENU.ADDLEVEL, locationname),
                string.format(STRINGS.UI.SANDBOXMENU.ADDLEVEL_WARNING, locationname),
                {
                    {
                        text = STRINGS.UI.MODSSCREEN.YES,
                        cb = function()
                            TheFrontEnd:PopScreen()
                            self:AddMultiLevel(level)
                            self:SelectMultilevel(level)
                            if TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
                                self:SetFocus(self.default_focus)
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
    else
        self:SelectMultilevel(level)
        if TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
            self:SetFocus(self.default_focus)
        end
    end
end

local CustomizationTab = Class(Widget, function(self, servercreationscreen)
    Widget._ctor(self, "CustomizationTab")

	self.current_level_locations = SERVER_LEVEL_LOCATIONS

    self.slotoptions = {}
    self.slot = -1
    self.currentmultilevel = 1
    self.allowEdit = true

    self.servercreationscreen = servercreationscreen

    -- Build the options menu so that the spinners are shown in an order that makes sense/in order of how impactful the changes are

    self.current_option_settings = {}

    local left_col =-RESOLUTION_X*.25 - 50
    local right_col = RESOLUTION_X*.25 - 75

    --set up the preset spinner

    self.max_custom_presets = 5

    self.presetpanel = self:AddChild(Widget("presetpanel"))
    self.presetpanel:SetPosition(left_col,15,0)

    self.multileveltabs = self.presetpanel:AddChild(Widget("multileveltabs"))
    self.multileveltabs:SetPosition(0, 140, 0)

    self.multileveltabs_bg = self.multileveltabs:AddChild(Image("images/ui.xml", "black.tex"))
    self.multileveltabs_bg:SetSize(320, 60)
    self.multileveltabs_bg:SetPosition(0, 12)

    self.multileveltabs_bg_2 = self.multileveltabs:AddChild(Image("images/options_bg.xml", "options_panel_bg_narrow.tex"))
    self.multileveltabs_bg_2:SetSize(320, 334)
    self.multileveltabs_bg_2:SetPosition(0, -175)

    self.multileveltabs.tabs = {}
    local tabboxwidth = 310
    local tabboxspacing = 5
    for i,location in ipairs(self.current_level_locations) do
        local tabwidth = tabboxwidth/#self.current_level_locations - tabboxspacing
        local tabpos = (-tabboxwidth/2)+(tabwidth/2)+(tabwidth)*(i-1)+(tabboxspacing*i)-(tabboxspacing/2)
        self.multileveltabs.tabs[i] = self.multileveltabs:AddChild(TEMPLATES.TabButton(tabpos, 0, "", function() OnClickTab(self, i) end, "small"))
        self.multileveltabs.tabs[i]:SetTextSize(24)
        self.multileveltabs.tabs[i]:ForceImageSize(tabwidth, 60)
    end

    for i, v in ipairs(self.multileveltabs.tabs) do
        v:SetTextSize(24)
    end

    self.left_line = self:AddChild(Image("images/ui.xml", "line_vertical_5.tex"))
    self.left_line:SetScale(1, .6)
    self.left_line:SetPosition(-530, 5, 0)

    self.middle_line = self:AddChild(Image("images/ui.xml", "line_vertical_5.tex"))
    self.middle_line:SetScale(1, .59)
    self.middle_line:SetPosition(-210, 2, 0)

    self.presettitle = self.presetpanel:AddChild(Text(BUTTONFONT, 40))
    self.presettitle:SetColour(0,0,0,1)
    self.presettitle:SetHAlign(ANCHOR_MIDDLE)
    self.presettitle:SetRegionSize( 400, 70 )
    self.presettitle:SetString(STRINGS.UI.CUSTOMIZATIONSCREEN.USEPRESETS)
    self.presettitle:SetPosition(0, 85, 0)

    self.presetdesc = self.presetpanel:AddChild(Text(NEWFONT, 25))
    self.presetdesc:SetColour(0,0,0,1)
    self.presetdesc:SetHAlign(ANCHOR_MIDDLE)
    self.presetdesc:SetRegionSize( 300, 110 )
    self.presetdesc:SetString("")
    self.presetdesc:EnableWordWrap(true)
    self.presetdesc:SetPosition(0, -40, 0)

    local spinner_width = 290
    local spinner_height = nil -- use default height
    self.presetspinner = self.presetpanel:AddChild(Widget("presetspinner"))
    self.presetspinner:SetPosition(0, 35, 0)
    self.presetspinner.spinner = self.presetspinner:AddChild(Spinner( {}, spinner_width, spinner_height, {font=NEWFONT, size=22}, nil, nil, nil, true))
    self.presetspinner.focus_forward = self.presetspinner.spinner
    self.presetspinner.spinner:SetTextColour(0,0,0,1)
    self.presetspinner.bg = self.presetspinner:AddChild(Image("images/ui.xml", "single_option_bg_large.tex"))
    self.presetspinner.bg:SetScale(.57,.46)
    self.presetspinner.bg:SetPosition(-1,1)
    self.presetspinner.bg:MoveToBack()
    self.presetspinner.bg:SetClickable(false)
    self.presetspinner.spinner.OnChanged =
        function( _, data, oldData )
            if self:GetNumberOfTweaks(self.currentmultilevel) > 0 then
                if self.servercreationscreen then self.servercreationscreen.last_focus = TheFrontEnd:GetFocusWidget() end
                TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.CUSTOMIZATIONSCREEN.LOSECHANGESTITLE, STRINGS.UI.CUSTOMIZATIONSCREEN.LOSECHANGESBODY,
                    {
                        {text=STRINGS.UI.CUSTOMIZATIONSCREEN.YES, cb = function()
                            self:LoadPreset(self.currentmultilevel, data)
                            self:Refresh()
                            TheFrontEnd:PopScreen()
                        end},
                        {text=STRINGS.UI.CUSTOMIZATIONSCREEN.NO, cb = function()
                            self.presetspinner.spinner:SetSelected(oldData)
                            TheFrontEnd:PopScreen()
                        end}
                    }))
            else
                self:LoadPreset(self.currentmultilevel, data)
                self:Refresh()
            end
            self.servercreationscreen:UpdateButtons(self.slot)
            self.servercreationscreen:MakeDirty()
        end

    self.revertbutton = self.presetpanel:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "undo.tex", STRINGS.UI.CUSTOMIZATIONSCREEN.REVERTCHANGES, false, false, function() self:RevertChanges() end))
    self.revertbutton:SetPosition(-35, -125, 0)
    self.revertbutton:Select()

    self.savepresetbutton = self.presetpanel:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "save.tex", STRINGS.UI.CUSTOMIZATIONSCREEN.SAVEPRESET, false, false, function() self:SavePreset() end))
    self.savepresetbutton:SetPosition(40, -125, 0)

    self.removemultilevel = self.presetpanel:AddChild(TEMPLATES.SmallButton(nil, 23, nil,
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
                                self:SelectMultilevel(1)
                                if TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
                                    self:SetFocus(self.default_focus)
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
        end))
    self.removemultilevel.image:SetScale(.5, .4)
    self.removemultilevel.text:SetPosition(0, -2, 0)
    self.removemultilevel:SetPosition(0, -170, 0)

    --add the custom options panel

    self.current_option_settingspanel = self:AddChild(Widget("optionspanel"))
    self.current_option_settingspanel:SetScale(.9)
    self.current_option_settingspanel:SetPosition(right_col,20,0)

    self:HookupFocusMoves()

    self.default_focus = self.presetspinner
    self.focus_forward = self.presetspinner
end)

function CustomizationTab:OnChangeGameMode(gamemode)
	local leveltype = GetLevelType(gamemode)
    if EVENTSERVER_LEVEL_LOCATIONS[leveltype] ~= nil then
		self.current_level_locations = EVENTSERVER_LEVEL_LOCATIONS[leveltype]
		self.currentmultilevel = 1
		if self:IsLevelEnabled(2) then
			self:RemoveMultiLevel(2)
		end
	else
		self.current_level_locations = SERVER_LEVEL_LOCATIONS
	end

    self:Refresh()
end

function CustomizationTab:OnChangeLevelLocations(level_locations)
	self.current_level_locations = level_locations
    self:Refresh()
end

function CustomizationTab:Refresh()
    self:UpdatePresetList()
    self:UpdatePresetInfo(self.currentmultilevel)
    self:UpdateMultilevelUI()
end

function CustomizationTab:UpdatePresetList()
    --
    -- PRESETS
    --

    local presets = nil
    if self.allowEdit == false then
        presets = {
            {
                text = self.slotoptions[self.slot][self.currentmultilevel].name,
                data = self.slotoptions[self.slot][self.currentmultilevel].id,
            }
        }
        self.presetspinner.spinner:SetOptions(presets)
        self.presetspinner.spinner:SetSelected(self.slotoptions[self.slot][self.currentmultilevel].id)
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
        self.customizationlist = self.current_option_settingspanel:AddChild(CustomizationList(location, options,
            function(option, value)
                self:SetTweak(self.currentmultilevel, option, value)
            end))
        self.customizationlist:SetPosition(-245, -24, 0)
        self.customizationlist:SetFocusChangeDir(MOVE_LEFT, self.presetspinner)
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


function CustomizationTab:GetValueForOption(level, option)
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

function CustomizationTab:AddMultiLevel(level)
    if level ~= 1 and self.current_option_settings[level] == nil then
        self:LoadPreset(level, nil)
    end
end

function CustomizationTab:RemoveMultiLevel(level)
    if level ~= 1 and self.current_option_settings[level] ~= nil then
        self.current_option_settings[level] = nil
        if self.currentmultilevel == level then
            self.currentmultilevel = self.currentmultilevel - 1
        end
    end
end

function CustomizationTab:GetLocationForLevel(level)
    return (self.current_option_settings[level] ~= nil
            and self.current_option_settings[level].preset ~= nil
            and Levels.GetLocationForLevelID(self.current_option_settings[level].preset))
        or self.current_level_locations[level]
end

function CustomizationTab:GetLocationStringID(level)
    if self.current_option_settings[level] ~= nil
        and self.current_option_settings[level].preset ~= nil then

        local location = Levels.GetLocationForLevelID(self.current_option_settings[level].preset)
        return location ~= nil and string.upper(location) or "UNKNOWN"
    end

    -- if there is no preset yet, use the default
    return string.upper(self.current_level_locations[level])
end


function CustomizationTab:UpdateMultilevelUI()

    if self.allowEdit and self.currentmultilevel ~= 1 then
        self.removemultilevel:Show()
    else
        self.removemultilevel:Hide()
    end


    local locationid = self:GetLocationStringID(self.currentmultilevel)
    local locationname = STRINGS.UI.SANDBOXMENU.LOCATION[locationid] or STRINGS.UI.SANDBOXMENU.LOCATION["UNKNOWN"]

    self.presettitle:SetString(string.format(STRINGS.UI.SANDBOXMENU.USEPRESETS_LOCATION, locationname))

    locationname = STRINGS.UI.SANDBOXMENU.LOCATIONTABNAME[locationid] or STRINGS.UI.SANDBOXMENU.LOCATION["UNKNOWN"]

    self.removemultilevel:SetText(string.format(STRINGS.UI.SANDBOXMENU.REMOVELEVEL, locationname))

    for i, tabbtn in ipairs(self.multileveltabs.tabs) do
		local valid_level = self.current_level_locations[i] ~= nil

        local locationid = valid_level and self:GetLocationStringID(i) or nil
        local locationname = locationid and STRINGS.UI.SANDBOXMENU.LOCATIONTABNAME[locationid] or ""

		if not valid_level then
            --tab is disabled, there is no level to pick from
            tabbtn:SetText("")
            tabbtn:SetTextures("images/frontend.xml", "tab2_button.tex", "tab2_button.tex", "tab2_button.tex", nil, nil, { 1, 1 }, { 0, 0 })
            tabbtn.image:SetScale(.73)
            tabbtn:SetFont(NEWFONT_SMALL)
            tabbtn:SetDisabledFont(NEWFONT_SMALL)
            tabbtn:SetTextColour(unpack(BLACK))
            tabbtn:SetTextFocusColour(unpack(BLACK))
            tabbtn:SetTextDisabledColour(unpack(BLACK))
        elseif self:IsLevelEnabled(i) then
            --tab is enabled, make it look like a regular tab
            tabbtn:SetText(locationname)
            tabbtn:SetTextures("images/frontend.xml", "tab2_button.tex", "tab2_button_highlight.tex", "tab2_selected.tex", nil, nil, { 1, 1 }, { 0, 0 })
            tabbtn.image:SetScale(.73)
            tabbtn:SetFont(NEWFONT_OUTLINE)
            tabbtn:SetDisabledFont(NEWFONT_SMALL)
            tabbtn:SetTextColour(unpack(GOLD))
            tabbtn:SetTextFocusColour(unpack(GOLD))
            tabbtn:SetTextDisabledColour(unpack(BLACK))
        elseif self.allowEdit then
            --tab is disabled, make it look like an "Add ___" button
            tabbtn:SetText(string.format(STRINGS.UI.SANDBOXMENU.ADDLEVEL, locationname))
            tabbtn:SetTextures("images/frontend.xml", "button_long.tex", "button_long_highlight.tex", "button_long_disabled.tex", "button_long_halfshadow.tex", nil, { 1, 1 }, { 6, 2 })
            tabbtn.image:SetScale(.5, .6)
            tabbtn:SetFont(NEWFONT_SMALL)
            tabbtn:SetDisabledFont(NEWFONT_SMALL)
            tabbtn:SetTextColour(unpack(BLACK))
            tabbtn:SetTextFocusColour(unpack(BLACK))
            tabbtn:SetTextDisabledColour(unpack(BLACK))
        else
            --tab is disabled, but we can't add it because this slot is not editable
            tabbtn:SetText(string.format(STRINGS.UI.SANDBOXMENU.DISABLEDLEVEL, locationname))
            tabbtn:SetTextures("images/frontend.xml", "tab2_button.tex", "tab2_button.tex", "tab2_button.tex", nil, nil, { 1, 1 }, { 0, 0 })
            tabbtn.image:SetScale(.73)
            tabbtn:SetFont(NEWFONT_SMALL)
            tabbtn:SetDisabledFont(NEWFONT_SMALL)
            tabbtn:SetTextColour(unpack(BLACK))
            tabbtn:SetTextFocusColour(unpack(BLACK))
            tabbtn:SetTextDisabledColour(unpack(BLACK))
        end

        if valid_level == false or i == self.currentmultilevel or not (self.allowEdit or self:IsLevelEnabled(i)) then
            tabbtn:Disable()
        else
            tabbtn:Enable()
        end
    end

end

function CustomizationTab:UpdatePresetInfo(level)
    if level ~= self.currentmultilevel then
        -- this might be called for the "unselected" level, so we don't want to do anything.
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

function CustomizationTab:SelectMultilevel(level)
    self.currentmultilevel = level
    self:Refresh()
end

function CustomizationTab:SetTweak(level, option, value)
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

function CustomizationTab:VerifyValidSeasonSettings()
    local autumn = self:GetValueForOption(1, "autumn")
    local winter = self:GetValueForOption(1, "winter")
    local spring = self:GetValueForOption(1, "spring")
    local summer = self:GetValueForOption(1, "summer")
    if autumn == "noseason" and winter == "noseason" and spring == "noseason" and summer == "noseason" then
        return false
    end
    return true
end

function CustomizationTab:LoadPreset(level, preset)

    local presetdata = nil
    if preset ~= nil then
        presetdata = Levels.GetDataForLevelID(preset)
    else
        local level_type = GetLevelType( self.servercreationscreen:GetGameMode() )
        local location = self.current_level_locations[level]
        presetdata = Levels.GetDefaultLevelData(level_type, location)
    end

    if self.allowEdit then
        assert(presetdata ~= nil, "Could not load a preset with id "..tostring(preset))
    else
        if presetdata == nil then
            print(string.format("WARNING! Could not load a preset with id %s, loading MOD_MISSING preset instead.", tostring(preset)))
            presetdata = Levels.GetDataForLevelID("MOD_MISSING")
        end
    end

    self.current_option_settings[level] = {}
    self.current_option_settings[level].preset = presetdata.id
    self.current_option_settings[level].tweaks = {}

    self:UpdatePresetInfo(level)
end

function CustomizationTab:SavePreset()

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

        self:LoadPreset(self.currentmultilevel, presetid)
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
        modal = PopupDialogScreen(STRINGS.UI.CUSTOMIZATIONSCREEN.MAX_PRESETS_EXCEEDED_TITLE, STRINGS.UI.CUSTOMIZATIONSCREEN.MAX_PRESETS_EXCEEDED_BODY, menuitems)

        local spinner_options = {}
        for i=1,self.max_custom_presets do
            table.insert(spinner_options, {text=tostring(i), data=i})
        end
        local size = JapaneseOnPS4() and 28 or 30
        modal.overwrite_spinner = modal.proot:AddChild(TEMPLATES.LabelSpinner(STRINGS.UI.CUSTOMIZATIONSCREEN.CUSTOM_PRESET, spinner_options, 200, 110, 40, 5, NEWFONT, size))
        modal.overwrite_spinner.spinner:SetSelected("1")
        modal.overwrite_spinner:SetPosition(0,-60,0)
        local bg = modal.overwrite_spinner:AddChild(Image("images/ui.xml", "single_option_bg.tex"))
        bg:MoveToBack()
        bg:SetClickable(false)
        bg:SetScale(.75,.95)


        modal.menu:SetFocusChangeDir(MOVE_UP, modal.overwrite_spinner)
        modal.overwrite_spinner:SetFocusChangeDir(MOVE_DOWN, modal.menu)

        modal.menu.items[1]:SetScale(.7)
        modal.menu.items[2]:SetScale(.7)
        modal.text:SetPosition(5, 10, 0)
        if self.servercreationscreen then self.servercreationscreen.last_focus = TheFrontEnd:GetFocusWidget() end
        TheFrontEnd:PushScreen(modal)
    else -- Otherwise, just save it
        AddPreset(presetnum, Levels.GetDataForLevelID(self.current_option_settings[self.currentmultilevel].preset, true), self.current_option_settings[self.currentmultilevel].tweaks)
    end
end

function CustomizationTab:IsLevelEnabled(level)
    return self.current_option_settings[level] ~= nil
end

function CustomizationTab:CollectOptions()
    -- Everything outside of this screen only ever sees a flattened final list of settings.
    local specialevent = nil
    local ret = {}
    for level_index,level in ipairs(self.current_option_settings) do
        ret[level_index] = Levels.GetDataForLevelID(level.preset)
        local options = Customize.GetOptionsWithLocationDefaults(Levels.GetLocationForLevelID(level.preset), level_index == 1)
        for i,option in ipairs(options) do
            ret[level_index].overrides[option.name] = self:GetValueForOption(level_index, option.name)
            if option.name ==  "specialevent" then
                specialevent = ret[level_index].overrides["specialevent"]
            end
        end
    end

    --Duplicate special event setting to all shards
    if specialevent ~= nil then
        for level_index, level in ipairs(ret) do
            level.overrides["specialevent"] = level.overrides["specialevent"] or specialevent
        end
    end

    return ret
end

function CustomizationTab:UpdateSlot(slotnum, prevslot, delete)
    if not delete and (slotnum == prevslot or not slotnum or not prevslot) then return end

    self.allowEdit = true
    self.slot = slotnum

    -- Remember what was typed/set
    local prev_option_settings = nil
    if prevslot and prevslot > 0 then
        prev_option_settings = deepcopy(self.current_option_settings)
    end

    self.current_option_settings = {}

    -- No save data
    if SaveGameIndex:IsSlotEmpty(slotnum) then
        -- no slot, so hide all the details and set all the text boxes back to their defaults
        if prevslot and prevslot > 0 and SaveGameIndex:IsSlotEmpty(prevslot) then
            -- Duplicate prevslot's data into our new slot if it was also a blank slot
            for i,prev in ipairs(prev_option_settings) do
                self:LoadPreset(i, prev.preset)
                self.current_option_settings[i].tweaks = deepcopy(prev.tweaks)
            end
        else
            local location = self.current_level_locations[1]

            self:LoadPreset(1, nil)
        end
    else -- Save data
        self.allowEdit = false
        local options = SaveGameIndex:GetSlotGenOptions(slotnum)
        if options == nil or GetTableSize(options) == 0 then
            -- Ruh roh! Bad data. Fill in with a default.
            local location = self.current_level_locations[1]
            local level_type = GetLevelType( self.servercreationscreen:GetGameMode() )
            local presetdata = Levels.GetDefaultLevelData(level_type, location)
            self.slotoptions[slotnum] = { presetdata }
        else
            self.slotoptions[slotnum] = options
        end

        for i,level in ipairs(self.slotoptions[slotnum]) do
            self:LoadPreset(i, level.id)
            for option, value in pairs(level.overrides) do
                self:SetTweak(i, option, value) -- SetTweak deduplicates.
            end
        end
    end

    local previouslevel = self.currentmultilevel
    self.currentmultilevel = 1

    self:Refresh()

    if previouslevel ~= self.currentmultilevel and self:IsLevelEnabled(previouslevel) then
        self:SelectMultilevel(previouslevel)
    end
end

function CustomizationTab:GetNumberOfTweaks(levelonly)
    local numTweaks = 0
    for i, level in ipairs(self.current_option_settings) do
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

function CustomizationTab:RevertChanges()
    if self.servercreationscreen then self.servercreationscreen.last_focus = TheFrontEnd:GetFocusWidget() end
    TheFrontEnd:PushScreen(
        PopupDialogScreen( STRINGS.UI.CUSTOMIZATIONSCREEN.BACKTITLE, STRINGS.UI.CUSTOMIZATIONSCREEN.BACKBODY,
        {
            {
                text = STRINGS.UI.CUSTOMIZATIONSCREEN.YES,
                cb = function()

                    self:LoadPreset(self.currentmultilevel, self.current_option_settings[self.currentmultilevel].preset)
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

function CustomizationTab:HookupFocusMoves()
    local tosaveslots = self.servercreationscreen ~= nil and self.servercreationscreen.getfocussaveslot or nil

    local function tocustomizationlist()
        return self.customizationlist
    end

    local function toleveltab()
        return self.multileveltabs.tabs[self.currentmultilevel < #self.multileveltabs.tabs and self.currentmultilevel + 1 or self.currentmultilevel - 1]
    end

    for i, v in ipairs(self.multileveltabs.tabs) do
        v:SetFocusChangeDir(MOVE_DOWN, self.presetspinner)
        v:SetFocusChangeDir(MOVE_RIGHT, i < #self.multileveltabs.tabs and self.multileveltabs.tabs[i + 1] or tocustomizationlist)
        v:SetFocusChangeDir(MOVE_LEFT, i > 1 and self.multileveltabs.tabs[i - 1] or tosaveslots)
    end
    self.presetspinner:SetFocusChangeDir(MOVE_UP, toleveltab)
    self.presetspinner:SetFocusChangeDir(MOVE_RIGHT, tocustomizationlist)
    self.presetspinner:SetFocusChangeDir(MOVE_DOWN, self.revertbutton)
    self.revertbutton:SetFocusChangeDir(MOVE_RIGHT, self.savepresetbutton)
    self.revertbutton:SetFocusChangeDir(MOVE_UP, self.presetspinner)
    self.revertbutton:SetFocusChangeDir(MOVE_DOWN, self.removemultilevel)
    self.savepresetbutton:SetFocusChangeDir(MOVE_LEFT, self.revertbutton)
    self.savepresetbutton:SetFocusChangeDir(MOVE_UP, self.presetspinner)
    self.savepresetbutton:SetFocusChangeDir(MOVE_RIGHT, tocustomizationlist)
    self.savepresetbutton:SetFocusChangeDir(MOVE_DOWN, self.removemultilevel)
    self.removemultilevel:SetFocusChangeDir(MOVE_UP, self.savepresetbutton)
    self.removemultilevel:SetFocusChangeDir(MOVE_LEFT, tosaveslots)
    self.removemultilevel:SetFocusChangeDir(MOVE_RIGHT, tocustomizationlist)

    self.presetspinner:SetFocusChangeDir(MOVE_LEFT, tosaveslots)
    self.revertbutton:SetFocusChangeDir(MOVE_LEFT, tosaveslots)
end

return CustomizationTab
