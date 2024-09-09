local Widget = require "widgets/widget"
local PresetBox = require "widgets/redux/worldsettings/presetbox"
local SettingsList = require "widgets/redux/worldsettings/settingslist"
local TEMPLATES = require "widgets/redux/templates"
local Image = require "widgets/image"

local Levels = require("map/levels")
local Customize = require("map/customize")

local function GetPresetBox(self)
    if self.mode == "combined" then
        return self.combined.presetbox
    elseif self.mode == "seperate" then
        return self.seperate.presetbox
    end
end

local WorldSettingsMenu = Class(Widget, function(self, levelcategory, parent_widget)
    Widget._ctor(self, "WorldSettingsMenu")

    self.levelcategory = levelcategory
    self.parent_widget = parent_widget

    self.mode = Profile:GetPresetMode()

    self.firstedit = true
    self.settings = {tweaks = {}}

    self.multipresetbox = self:AddChild(Widget("presetboxfocus"))
    self.multipresetbox.focus_forward = function()
        return GetPresetBox(self)
    end

    self.combined = self.multipresetbox:AddChild(Widget("combined"))

    local tab_tint_width = 250
    local tab_tint_height = 60

    self.combined.bg = self.combined:AddChild(TEMPLATES.PlainBackground())
    self.combined.bg:SetScissor(-tab_tint_width/2, -tab_tint_height/2, tab_tint_width, tab_tint_height)
    self.combined.bg:SetPosition(-390,290)

    self.combined.bg_tint = self.combined:AddChild(Image("images/global.xml", "square.tex"))
    local r,g,b = unpack(UICOLOURS.BROWN_DARK)
    self.combined.bg_tint:SetTint(r, g, b, 0.6)
    self.combined.bg_tint:SetSize(tab_tint_width, tab_tint_height)
    self.combined.bg_tint:SetPosition(-390,290)

    self.combined.presetbox = self.combined:AddChild(PresetBox(self, LEVELCATEGORY.COMBINED, 560))
    self.combined.presetbox:SetPosition(-390, 40)
    self.combined.presetbox.horizontal_line:Hide()

    self.seperate = self.multipresetbox:AddChild(Widget("seperate"))
    self.seperate.presetbox = self.seperate:AddChild(PresetBox(self, self.levelcategory))
    self.seperate.presetbox:SetPosition(-390, 10)

    self.settingslist = self:AddChild(SettingsList(self, self.levelcategory))
    self.settingslist:SetPosition(140, 10)

    self.parent_default_focus = self

    self.last_focus = self.multipresetbox

    self.focus_forward = function() return self.last_focus end

    self:DoFocusHookups()
end)

function WorldSettingsMenu:UpdatePresetMode()
    return self.parent_widget:UpdatePresetMode(self.mode)
end

function WorldSettingsMenu:SetPresetMode(mode)
    if self:IsNewShard() then
        self.mode = mode
    else
        self.mode = "seperate"
    end
    local wasfocused = GetPresetBox(self).changepresetmode.focus
    self:Refresh()
    if wasfocused then
        GetPresetBox(self).changepresetmode:SetFocus()
    end
end

function WorldSettingsMenu:IsEditable()
    return self.parent_widget:IsNewShard() or self.levelcategory == LEVELCATEGORY.SETTINGS
end

function WorldSettingsMenu:IsNewShard()
    return self.parent_widget:IsNewShard()
end

function WorldSettingsMenu:GetValueForOption(option)
    local presetdata = Levels.GetDataForID(self.levelcategory, self.settings.preset)
    return self.settings.tweaks[option] or presetdata.overrides[option] or Customize.GetLocationDefaultForOption(presetdata.location, option)
end

function WorldSettingsMenu:SetTweak(option, value)
    self.settings.tweaks[option] = value
    if not self.refreshing then self:Refresh() end
end

function WorldSettingsMenu:UpdatePresetInfo()
    if not self.parent_widget:IsLevelEnabled() then return end

    local presetbox = GetPresetBox(self)

    if self.settings.custompreset then
        presetbox:SetTextAndDesc(
            self.settings.customname,
            self.settings.customdesc
        )
    else
        presetbox:SetTextAndDesc(
            Levels.GetNameForID(self.levelcategory, self.settings.preset),
            Levels.GetDescForID(self.levelcategory, self.settings.preset)
        )
    end

    presetbox:SetEditable(self:IsEditable())
    presetbox:SetRevertable(self:GetNumberOfTweaks() > 0)
    presetbox:SetPresetEditable(CustomPresetManager:IsCustomPreset(self.levelcategory, self.settings.preset))
end

function WorldSettingsMenu:Refresh(force)
    if self.refreshing == true then return end
    self.refreshing = true
    if not self:IsNewShard() then
        self.mode = "seperate"
    end
    if self.mode == "combined" then
        self.seperate:Hide()
        self.combined:Show()
    elseif self.mode == "seperate" then
        self.combined:Hide()
        self.seperate:Show()
    end
    self:UpdatePresetInfo()
    self.settingslist:Refresh(force)
    GetPresetBox(self):Refresh()


	if self.levelcategory == LEVELCATEGORY.SETTINGS and self.parent_widget:IsMasterLevel() then
		self:GetParentScreen():UpdatePlaystyle(self.settings.tweaks)
	end

    self.refreshing = false
end

function WorldSettingsMenu:RefreshPlaystyleIndicator(playstyle)
	GetPresetBox(self):SetPlaystyleIcon(playstyle)
end

function WorldSettingsMenu:SavePreset(presetid, name, desc, noload)
    local defaultoverrides
    if self.levelcategory == LEVELCATEGORY.SETTINGS then
        defaultoverrides = Customize.GetWorldSettingsOptionsWithLocationDefaults(self:GetLocation(), self.parent_widget:IsMasterLevel())
    elseif self.levelcategory == LEVELCATEGORY.WORLDGEN then
        defaultoverrides = Customize.GetWorldGenOptionsWithLocationDefaults(self:GetLocation(), self.parent_widget:IsMasterLevel())
    end
    if not defaultoverrides then return end
    local presetdata = Levels.GetDataForID(self.levelcategory, self.settings.preset)

    local overrides = {}
    for _, v in ipairs(defaultoverrides) do
        if v.default ~= nil and v.default ~= "" then --implication behind these being the default value means they probably shouldn't be saved with a preset.
            overrides[v.name] = self.settings.tweaks[v.name] or presetdata.overrides[v.name] or v.default
        end
    end
    if CustomPresetManager:SaveCustomPreset(self.levelcategory, presetid, self.settings.basepreset or self.settings.preset, overrides, name, desc) then
        if not noload then
            self:LoadPreset(presetid)
            self:Refresh(true)
        end
        return true
    end
end

function WorldSettingsMenu:SaveCombinedPreset(presetid, name, desc, noload)
    return self.parent_widget:SaveCombinedPreset(presetid, name, desc, noload)
end

function WorldSettingsMenu:EditPreset(originalid, presetid, name, desc, updateoverrides)
    if updateoverrides then
        --save the preset changes first, since updating overrides won't work if we change the preset id.
        if not self:SavePreset(presetid, name, desc, true) then
            return false
        end
    end
    if CustomPresetManager:MoveCustomPreset(self.levelcategory, originalid, presetid, name, desc) then
        if self.settings.preset == originalid then
            self:LoadPreset(presetid)
            self:Refresh(true)
        end
        return true
    end
end

function WorldSettingsMenu:EditCombinedPreset(originalid, presetid, name, desc, updateoverrides)
    return self.parent_widget:EditCombinedPreset(originalid, presetid, name, desc, updateoverrides)
end

function WorldSettingsMenu:DeletePreset(presetid)
    CustomPresetManager:DeleteCustomPreset(self.levelcategory, presetid)

    if self.settings.preset == presetid then
        --if your deleting the preset your save is currently using, go back to the base preset, but still keep the overrides.
        local overrides = self.settings.tweaks
        self:LoadPreset(self.settings.basepreset)
        for option, value in pairs(overrides) do
            self:SetTweak(option, value)
        end

        self:Refresh(true)
    end
end

function WorldSettingsMenu:DeleteCombinedPreset(presetid)
    self.parent_widget:DeleteCombinedPreset(presetid)
end

function WorldSettingsMenu:RevertChanges()
    if self.parent_widget:IsNewShard() then
        self:LoadPreset(self.settings.preset)
    else
        local options = self.parent_widget:GetSlotOptions()
        self:SetDataFromOptions(options)
    end

    self:Refresh(true)
end

function WorldSettingsMenu:OnPresetButton(presetid)
    self:LoadPreset(presetid)
    self:Refresh(true)
end

function WorldSettingsMenu:OnCombinedPresetButton(presetid)
    self.parent_widget:OnCombinedPresetButton(presetid)
end

function WorldSettingsMenu:GetNumberOfTweaks()
    local presetdata = Levels.GetDataForID(self.levelcategory, self.settings.preset)
    local locationdata = Levels.GetDataForLocation(presetdata.location)
    local numTweaks = 0
    for tweak, value in pairs(self.settings.tweaks) do
        local default = presetdata.overrides[tweak] or (locationdata and locationdata.overrides[tweak]) or Customize.GetDefaultForOption(tweak)
        if value ~= default then
            numTweaks = numTweaks + 1
        end
    end
    return numTweaks
end

function WorldSettingsMenu:GetNumberOfCombinedTweaks()
    return self.parent_widget:GetNumberOfCombinedTweaks()
end

function WorldSettingsMenu:GetCurrentPresetId()
    if self.settings.custompreset then return nil end
    return self.settings.preset
end

function WorldSettingsMenu:GetParentScreen()
    return self.parent_widget.servercreationscreen
end

function WorldSettingsMenu:GetOptions()
    if self.levelcategory == LEVELCATEGORY.SETTINGS then
        return Customize.GetWorldSettingsOptionsWithLocationDefaults(self.parent_widget:GetCurrentLocation(), self.parent_widget:IsMasterLevel())
    elseif self.levelcategory == LEVELCATEGORY.WORLDGEN then
        return Customize.GetWorldGenOptionsWithLocationDefaults(self.parent_widget:GetCurrentLocation(), self.parent_widget:IsMasterLevel())
    end
end

--called by parent widget
function WorldSettingsMenu:RefreshOptionItems()
    self.settingslist:RefreshOptionItems()
end

--called by parent widget
function WorldSettingsMenu:CollectOptions()
    -- Everything outside of this screen only ever sees a flattened final list of settings.
    local preset = self.settings.basepreset or self.settings.preset
    local collectedoptions = deepcopy(Levels.GetDataForID(self.levelcategory, preset))

    if CustomPresetManager:IsCustomPreset(self.levelcategory, self.settings.preset) then
        local custompresetdata = Levels.GetDataForID(self.levelcategory, self.settings.preset)
        if self.levelcategory == LEVELCATEGORY.SETTINGS then
            collectedoptions.custom_settings_id = custompresetdata.id
            collectedoptions.custom_settings_name = custompresetdata.name
            collectedoptions.custom_settings_desc = custompresetdata.desc
        elseif self.levelcategory == LEVELCATEGORY.WORLDGEN then
            collectedoptions.custom_worldgen_id = custompresetdata.id
            collectedoptions.custom_worldgen_name = custompresetdata.name
            collectedoptions.custom_worldgen_desc = custompresetdata.desc
        end
    elseif self.settings.custompreset then
        if self.levelcategory == LEVELCATEGORY.SETTINGS then
            collectedoptions.custom_settings_id = self.settings.custompreset
            collectedoptions.custom_settings_name = self.settings.customname
            collectedoptions.custom_settings_desc = self.settings.customdesc
        elseif self.levelcategory == LEVELCATEGORY.WORLDGEN then
            collectedoptions.custom_worldgen_id = self.settings.custompreset
            collectedoptions.custom_worldgen_name = self.settings.customname
            collectedoptions.custom_worldgen_desc = self.settings.customdesc
        end
    end

    if self.settings.errorpreset then
        collectedoptions:SetID(self.settings.errorpreset)
    end

    local location = collectedoptions.location
    local ismaster = self.parent_widget:IsMasterLevel()

    local options
    if self.levelcategory == LEVELCATEGORY.SETTINGS then
        options = Customize.GetWorldSettingsOptionsWithLocationDefaults(location, ismaster)
    elseif self.levelcategory == LEVELCATEGORY.WORLDGEN then
        options = Customize.GetWorldGenOptionsWithLocationDefaults(location, ismaster)
    end
    for i, option in ipairs(options) do
        collectedoptions.overrides[option.name] = self:GetValueForOption(option.name)
    end
    return collectedoptions
end

--called by parent widget
function WorldSettingsMenu:SetDataFromOptions(options)
    options = options or Levels.GetDefaultData(self.levelcategory, GetLevelType(self:GetGameMode()), self.parent_widget:GetCurrentLocation())
    local id
    local customid
    local customname
    local customdesc
    if self.levelcategory == LEVELCATEGORY.SETTINGS then
        id = options.settings_id or options.id
        customid = options.custom_settings_id
        customname = options.custom_settings_name
        customdesc = options.custom_settings_desc
    elseif self.levelcategory == LEVELCATEGORY.WORLDGEN then
        id = options.worldgen_id or options.id
        customid = options.custom_worldgen_id
        customname = options.custom_worldgen_name
        customdesc = options.custom_worldgen_desc
    end
    self:LoadPreset(id)

    self.settings.custompreset = customid
    self.settings.customname = customname
    self.settings.customdesc = customdesc

    if options.overrides then
        self.settingslist:SetPresetValues(options.overrides)
        for option, value in pairs(options.overrides) do
            self:SetTweak(option, value)
        end
    end
    self:Refresh(true)
end

--called by parent widget
function WorldSettingsMenu:ReloadPreset()
    local preset = self.settings and self.settings.preset or nil
    if preset then
        local presetdata = Levels.GetDataForID(self.levelcategory, preset)
        if not presetdata or preset ~= presetdata.id then
            self:LoadPreset()
        end
    end
end

--called by parent widget
function WorldSettingsMenu:LoadPreset(preset)
	self.refreshing = true

    local gamemode = self:GetGameMode()
    local level_type = GetLevelType(gamemode)
    local location = self.parent_widget:GetCurrentLocation()

    local presetdata = nil

    if preset ~= nil then
        presetdata = Levels.GetDataForID(self.levelcategory, preset)
    else
        presetdata = Levels.GetDefaultData(self.levelcategory, level_type, location)
    end

    if self.parent_widget:IsNewShard() then
        assert(presetdata ~= nil, "Could not load a preset with id "..tostring(preset) ..", "..tostring(gamemode)..", "..tostring(level_type)..", "..tostring(location))
    else
        if presetdata == nil then
            print(string.format("WARNING! Could not load a preset with id %s, loading MOD_MISSING preset instead.", tostring(preset)))
            presetdata = Levels.GetDataForID(self.levelcategory, "MOD_MISSING")
        end
    end

    self.settings = {preset = presetdata.id, basepreset = presetdata.baseid, tweaks = {}}
    if CustomPresetManager:IsCustomPreset(self.levelcategory, self.settings.preset) then
        assert(self.settings.basepreset, "Custom Preset is missing a base preset")
    end

    if self.settings.preset == "MOD_MISSING" then
        self.settings.errorpreset = preset
    end

	for k, v in pairs(presetdata.overrides) do
		self:SetTweak(k, v)
	end

    self.settingslist:SetPresetValues(presetdata.overrides)

    if not self.settingslist.scroll_list then
        self.settingslist:MakeScrollList()
    end

	self.refreshing = false
end

--called by parent widget
function WorldSettingsMenu:VerifyValidSeasonSettings()
    -- Only main world (index 1) has seasons.
    if self.parent_widget:IsMasterLevel() and self.levelcategory == LEVELCATEGORY.SETTINGS then
        for i, season in ipairs({"autumn", "winter", "spring", "summer"}) do
            if self:GetValueForOption(season) ~= "noseason" then
                return true
            end
        end
        return false
    end
    return true
end

function WorldSettingsMenu:GetGameMode()
    return self.parent_widget:GetGameMode()
end

--called by parent widget
function WorldSettingsMenu:GetLocation()
    return self.settings.preset and Levels.GetLocationForID(self.levelcategory, self.settings.preset)
end

--called by parent widget
function WorldSettingsMenu:GetLocationStringID()
    if self.settings.preset then
        local location = Levels.GetLocationForID(self.levelcategory, self.settings.preset)
        return location and string.upper(location) or "UNKNOWN"
    end
end

function WorldSettingsMenu:DoFocusHookups()
    self.multipresetbox:SetFocusChangeDir(MOVE_RIGHT, self.settingslist)
    self.settingslist:SetFocusChangeDir(MOVE_LEFT, self.multipresetbox)

    self.multipresetbox:SetFocusChangeDir(MOVE_UP, self.parent_widget)
    self.settingslist:SetFocusChangeDir(MOVE_UP, self.parent_widget)
end

function WorldSettingsMenu:SetFocusFromChild(child)
    WorldSettingsMenu._base.SetFocusFromChild(self, child)

    if self.focus then
        self.last_focus = child
    end
end

return WorldSettingsMenu