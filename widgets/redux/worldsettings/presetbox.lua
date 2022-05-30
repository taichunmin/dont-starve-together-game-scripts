local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"
local Text = require "widgets/text"
local PopupDialogScreen = require "screens/redux/popupdialog"
local PresetPopupScreen = require "screens/redux/presetpopupscreen"
local NamePresetScreen = require "screens/redux/namepresetscreen"
local Image = require "widgets/image"

local Levels = require("map/levels")

local preset_width = 250
local preset_height = 500
local preset_button_size = 50

local PresetBox = Class(Widget, function(self, parent_widget, levelcategory, height)
    Widget._ctor(self, "PresetBox")

    self.height = height or preset_height

    self.parent_widget = parent_widget
    self.levelcategory = levelcategory

    local preset_str
    if self.levelcategory == LEVELCATEGORY.SETTINGS then
        preset_str = STRINGS.UI.CUSTOMIZATIONSCREEN.SETTINGSPRESET
    elseif self.levelcategory == LEVELCATEGORY.WORLDGEN then
        preset_str = STRINGS.UI.CUSTOMIZATIONSCREEN.WORLDGENPRESET
    elseif self.levelcategory == LEVELCATEGORY.COMBINED then
        preset_str = STRINGS.UI.CUSTOMIZATIONSCREEN.COMBINEDPRESET
    end

    self.root = self:AddChild(Image("images/dialogrect_9slice.xml", "center.tex"))--self:AddChild(TEMPLATES.RectangleWindow(preset_width, preset_height))
    self.root:SetSize(preset_width, self.height)
    local r,g,b = unpack(UICOLOURS.BROWN_DARK)
    self.root:SetTint(r,g,b,0.6)

    self.presets = self.root:AddChild(Text(CHATFONT, 35))
    self.presets:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
    self.presets:SetHAlign(ANCHOR_MIDDLE)
    self.presets:SetString(preset_str)
    self.presets:SetPosition(0, self.height/2 - 30)

    self.horizontal_line = self.root:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
    self.horizontal_line:SetPosition(0,self.height/2 - 60)
    self.horizontal_line:SetSize(preset_width+2, 5)

    self.presetname_bg = self.root:AddChild(TEMPLATES.ListItemBackground_Static(preset_width - 10, 40))
    self.presetname_bg:SetPosition(0, self.height/2 - 100)

    self.presetname = self.presetname_bg:AddChild(Text(CHATFONT, 22))
    self.presetname:SetColour(UICOLOURS.GOLD_SELECTED)
    self.presetname:SetHAlign(ANCHOR_MIDDLE)
    self.presetname:SetRegionSize(preset_width-20, 40)
    self.presetname:SetString("")
    self.presetname:EnableWordWrap(true)

    self.presetdesc = self.root:AddChild(Text(CHATFONT, 20))
    self.presetdesc:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
    self.presetdesc:SetVAlign(ANCHOR_TOP)
    self.presetdesc:SetHAlign(ANCHOR_MIDDLE)
    self.presetdesc:SetRegionSize(preset_width-40, 200)
    self.presetdesc:SetString("")
    self.presetdesc:EnableWordWrap(true)
    self.presetdesc:SetPosition(0, 20)

    local hover_config = {
        offset_x = 0,
        offset_y = 65,
    }

    self.revertbutton = self.root:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "undo.tex", STRINGS.UI.CUSTOMIZATIONSCREEN.REVERTCHANGES, false, false, function() self:OnRevertChanges() end, hover_config))
    self.revertbutton:SetPosition(-25, -self.height/2 + 140)
    self.revertbutton:ForceImageSize(preset_button_size, preset_button_size)
    self.revertbutton:Select()

    self.editpresetbutton = self.root:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "save.tex", STRINGS.UI.CUSTOMIZATIONSCREEN.EDITPRESET, false, false, function() self:OnEditPreset() end, hover_config))
    self.editpresetbutton:SetPosition(25, -self.height/2 + 140)
    self.editpresetbutton:ForceImageSize(preset_button_size, preset_button_size)

    local presetmode_image
    local presetmode_str
    if self.levelcategory == LEVELCATEGORY.SETTINGS or self.levelcategory == LEVELCATEGORY.WORLDGEN then
        presetmode_image = "preset_unlinked.tex"
        presetmode_str = STRINGS.UI.CUSTOMIZATIONSCREEN.LINKPRESETSTR
    elseif self.levelcategory == LEVELCATEGORY.COMBINED then
        presetmode_image = "preset_linked.tex"
        presetmode_str = STRINGS.UI.CUSTOMIZATIONSCREEN.UNLINKPRESETSTR
    end

    self.changepresetmode = self.root:AddChild(TEMPLATES.IconButton("images/button_icons2.xml", presetmode_image, presetmode_str, false, false, function() self:OnPresetModeChange() end, hover_config))
    self.changepresetmode:SetPosition(75, -self.height/2 + 140)
    self.changepresetmode:ForceImageSize(preset_button_size, preset_button_size)

    local load_str
    if self.levelcategory == LEVELCATEGORY.SETTINGS then
        load_str = STRINGS.UI.CUSTOMIZATIONSCREEN.LOADPRESET_SETINGS
    elseif self.levelcategory == LEVELCATEGORY.WORLDGEN then
        load_str = STRINGS.UI.CUSTOMIZATIONSCREEN.LOADPRESET_WORLDGEN
    elseif self.levelcategory == LEVELCATEGORY.COMBINED then
        load_str = STRINGS.UI.CUSTOMIZATIONSCREEN.LOADPRESET_COMBINED
    end
    self.presetbutton = self.root:AddChild(TEMPLATES.StandardButton(function() self:OnPresetButton() end, load_str, {preset_width - 40, 60}))
    self.presetbutton:SetPosition(0, -self.height/2 + 90)
    self.presetbutton:SetTextSize(20)

    self.savepresetbutton = self.root:AddChild(TEMPLATES.StandardButton(function() self:OnSavePreset() end, STRINGS.UI.CUSTOMIZATIONSCREEN.SAVEPRESET, {preset_width - 40, 60}))
    self.savepresetbutton:SetPosition(0, -self.height/2 + 35)
    self.savepresetbutton:SetTextSize(20)

    self.focus_forward = function()
        if self.revertbutton:IsSelected() then
            return self.presetbutton
        end
        return self.revertbutton
    end

    self:DoFocusHookups()
end)

function PresetBox:OnPresetModeChange()
    self.parent_widget:UpdatePresetMode()
end

function PresetBox:OnPresetChosen(presetid)
    if self.parent_widget:GetNumberOfTweaks(self.currentmultilevel) > 0 then
        if self.parent_widget:GetParentScreen() then self.parent_widget:GetParentScreen().last_focus = TheFrontEnd:GetFocusWidget() end
        TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.CUSTOMIZATIONSCREEN.LOSECHANGESTITLE, STRINGS.UI.CUSTOMIZATIONSCREEN.LOSECHANGESBODY,
            {
                {
                    text = STRINGS.UI.CUSTOMIZATIONSCREEN.YES,
                    cb = function()
                        self.parent_widget:OnPresetButton(presetid)
                        TheFrontEnd:PopScreen()
                    end
                },
                {
                    text=STRINGS.UI.CUSTOMIZATIONSCREEN.NO,
                    cb = function()
                        TheFrontEnd:PopScreen()
                    end
                }
            })
        )
    else
        self.parent_widget:OnPresetButton(presetid)
    end
end

function PresetBox:OnCombinedPresetChosen(presetid)
    if self.parent_widget:GetNumberOfCombinedTweaks(self.currentmultilevel) > 0 then
        if self.parent_widget:GetParentScreen() then self.parent_widget:GetParentScreen().last_focus = TheFrontEnd:GetFocusWidget() end
        TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.CUSTOMIZATIONSCREEN.LOSECHANGESTITLE, STRINGS.UI.CUSTOMIZATIONSCREEN.LOSECHANGESBODY,
            {
                {
                    text = STRINGS.UI.CUSTOMIZATIONSCREEN.YES,
                    cb = function()
                        self.parent_widget:OnCombinedPresetButton(presetid)
                        TheFrontEnd:PopScreen()
                    end
                },
                {
                    text=STRINGS.UI.CUSTOMIZATIONSCREEN.NO,
                    cb = function()
                        TheFrontEnd:PopScreen()
                    end
                }
            })
        )
    else
        self.parent_widget:OnCombinedPresetButton(presetid)
    end
end

function PresetBox:OnPresetButton()
    if self.parent_widget:GetParentScreen() then self.parent_widget:GetParentScreen().last_focus = TheFrontEnd:GetFocusWidget() end
    TheFrontEnd:PushScreen(
        PresetPopupScreen(
            self.parent_widget:GetCurrentPresetId(),
            function(levelcategory, presetid)
                if levelcategory == LEVELCATEGORY.COMBINED then
                    return self:OnCombinedPresetChosen(presetid)
                end
                self:OnPresetChosen(presetid)
            end,
            function(levelcategory, originalid, presetid, name, desc)
                if levelcategory == LEVELCATEGORY.COMBINED then
                    return self:EditCombinedPreset(originalid, presetid, name, desc, false)
                end
                return self:EditPreset(originalid, presetid, name, desc, false)
            end,
            function(levelcategory, presetid)
                if levelcategory == LEVELCATEGORY.COMBINED then
                    return self:DeleteCombinedPreset(presetid)
                end
                self:DeletePreset(presetid)
            end,
            self.levelcategory,
            GetLevelType(self.parent_widget:GetGameMode()),
            self.parent_widget:GetLocation()
        )
    )
end

function PresetBox:OnRevertChanges()
    local backbody = STRINGS.UI.CUSTOMIZATIONSCREEN.BACKBODY
    if self.levelcategory == LEVELCATEGORY.SETTINGS then
        backbody = STRINGS.UI.CUSTOMIZATIONSCREEN.BACKBODY_SETTINGS
    elseif self.levelcategory == LEVELCATEGORY.WORLDGEN then
        backbody = STRINGS.UI.CUSTOMIZATIONSCREEN.BACKBODY_WORLDGEN
    elseif self.levelcategory == LEVELCATEGORY.COMBINED then
        backbody = STRINGS.UI.CUSTOMIZATIONSCREEN.BACKBODY_COMBINED
    end

    if self.parent_widget:GetParentScreen() then self.parent_widget:GetParentScreen().last_focus = TheFrontEnd:GetFocusWidget() end
    TheFrontEnd:PushScreen(
        PopupDialogScreen(STRINGS.UI.CUSTOMIZATIONSCREEN.BACKTITLE, backbody,
        {
            {
                text = STRINGS.UI.CUSTOMIZATIONSCREEN.YES,
                cb = function()
                    self.parent_widget:RevertChanges()
                    TheFrontEnd:PopScreen()
                end,
            },
            {
                text = STRINGS.UI.CUSTOMIZATIONSCREEN.NO,
                cb = function()
                    TheFrontEnd:PopScreen()
                end,
            },
        })
    )
end

function PresetBox:Refresh()
    if self.parent_widget:IsNewShard() then
        self.changepresetmode:Show()
    else
        self.changepresetmode:Hide()
    end
    self:DoFocusHookups()
end

function PresetBox:OnSavePreset()
    if self.parent_widget:GetParentScreen() then self.parent_widget:GetParentScreen().last_focus = TheFrontEnd:GetFocusWidget() end
    TheFrontEnd:PushScreen(
        NamePresetScreen(
            self.levelcategory,
            STRINGS.UI.CUSTOMIZATIONSCREEN.NEWPRESET,
            STRINGS.UI.CUSTOMIZATIONSCREEN.SAVEPRESET,
            function(id, name, description)
                if self.levelcategory == LEVELCATEGORY.COMBINED then
                    if self.parent_widget:SaveCombinedPreset(id, name, description) then return end
                else
                    if self.parent_widget:SavePreset(id, name, description) then return end
                end
                TheFrontEnd:PushScreen(
                    PopupDialogScreen(STRINGS.UI.CUSTOMIZATIONSCREEN.SAVECHANGESFAILED_TITLE, STRINGS.UI.CUSTOMIZATIONSCREEN.SAVECHANGESFAILED_BODY,
                    {
                        {
                            text = STRINGS.UI.CUSTOMIZATIONSCREEN.BACK,
                            cb = function()
                                TheFrontEnd:PopScreen()
                            end,
                        },
                    })
                )
            end
        )
    )
end

function PresetBox:OnEditPreset()
    if self.parent_widget:GetParentScreen() then self.parent_widget:GetParentScreen().last_focus = TheFrontEnd:GetFocusWidget() end
    local presetid = self.parent_widget:GetCurrentPresetId()
    local presetdata = Levels.GetDataForID(self.levelcategory, presetid)
    TheFrontEnd:PushScreen(
        NamePresetScreen(
            self.levelcategory,
            STRINGS.UI.CUSTOMIZATIONSCREEN.EDITPRESET,
            STRINGS.UI.CUSTOMIZATIONSCREEN.SAVEPRESETCHANGES,
            function(id, name, description)
                if self.levelcategory == LEVELCATEGORY.COMBINED then
                    if self:EditCombinedPreset(presetid, id, name, description, true) then return end
                else
                    if self:EditPreset(presetid, id, name, description, true) then return end
                end
                TheFrontEnd:PushScreen(
                    PopupDialogScreen(STRINGS.UI.CUSTOMIZATIONSCREEN.SAVECHANGESFAILED_TITLE, STRINGS.UI.CUSTOMIZATIONSCREEN.SAVECHANGESFAILED_BODY,
                    {
                        {
                            text = STRINGS.UI.CUSTOMIZATIONSCREEN.BACK,
                            cb = function()
                                TheFrontEnd:PopScreen()
                            end,
                        },
                    })
                )
            end,
            presetid,
            presetdata.name,
            presetdata.desc
        )
    )
end

function PresetBox:EditPreset(originalid, presetid, name, desc, updateoverrides)
    return self.parent_widget:EditPreset(originalid, presetid, name, desc, updateoverrides)
end

function PresetBox:EditCombinedPreset(originalid, presetid, name, desc, updateoverrides)
    return self.parent_widget:EditCombinedPreset(originalid, presetid, name, desc, updateoverrides)
end

function PresetBox:DeletePreset(presetid)
    self.parent_widget:DeletePreset(presetid)
end

function PresetBox:DeleteCombinedPreset(presetid)
    self.parent_widget:DeleteCombinedPreset(presetid)
end

function PresetBox:SetTextAndDesc(text, desc)
    self.presetname:SetString(text)
    self.presetdesc:SetString(desc)
end

function PresetBox:SetEditable(editable)
    if editable then
        self.presetbutton:Show()
        self.revertbutton:Show()
        self.savepresetbutton:Show()
        self.editpresetbutton:Show()
    else
        self.presetbutton:Hide()
        self.revertbutton:Hide()
        self.savepresetbutton:Hide()
        self.editpresetbutton:Hide()
    end
end

function PresetBox:SetRevertable(revertable)
    if revertable then
        self.revertbutton:Unselect()
    else
        self.revertbutton:Select()
    end
end

function PresetBox:SetPresetEditable(editable)
    if editable then
        self.editpresetbutton:Unselect()
    else
        self.editpresetbutton:Select()
    end
end

function PresetBox:DoFocusHookups()
    self.revertbutton:SetFocusChangeDir(MOVE_DOWN, self.presetbutton)
    self.revertbutton:SetFocusChangeDir(MOVE_RIGHT, self.editpresetbutton)

    self.editpresetbutton:ClearFocusDirs() --we need to clear focus because its possible to have a MOVE_RIGHT focus that doesn't get updated.
    self.editpresetbutton:SetFocusChangeDir(MOVE_DOWN, self.presetbutton)
    self.editpresetbutton:SetFocusChangeDir(MOVE_LEFT, self.revertbutton)

    if self.parent_widget:IsNewShard() then
        self.editpresetbutton:SetFocusChangeDir(MOVE_RIGHT, self.changepresetmode)

        self.changepresetmode:SetFocusChangeDir(MOVE_LEFT, self.editpresetbutton)
        self.changepresetmode:SetFocusChangeDir(MOVE_DOWN, self.presetbutton)
    end

    self.presetbutton:SetFocusChangeDir(MOVE_UP, self.revertbutton)
    self.presetbutton:SetFocusChangeDir(MOVE_DOWN, self.savepresetbutton)

    self.savepresetbutton:SetFocusChangeDir(MOVE_UP, self.presetbutton)
end

return PresetBox