local Screen = require "widgets/screen"
local Widget= require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"
local Text = require "widgets/text"
local NamePresetScreen = require "screens/redux/namepresetscreen"
local PopupDialogScreen = require "screens/redux/popupdialog"

local Levels = require("map/levels")

local window_width = 400
local window_height = 550

local widget_width = 400
local widget_height = 80

local padded_width = widget_width + 10
local padded_height = widget_height + 10

local num_rows = math.floor(500 / padded_height)
local peek_height = math.abs(num_rows * padded_height - 500)

local presetstr = {}
local function GetTruncatedMultiLineString(textwidget, str)
    textwidget:SetMultilineTruncatedString(str, 3, padded_width - 40, nil, "...")
    return textwidget:GetString()
end

local PresetPopupScreen = Class(Screen, function(self, currentpreset, onconfirmfn, oneditfn, ondeletefn, levelcategory, level_type, location)
    assert(onconfirmfn, "PresetPopupScreen requires a onconfirmfn")
    assert(oneditfn, "PresetPopupScreen requires a oneditfn")
    assert(ondeletefn, "PresetPopupScreen requires a ondeletefn")

    Screen._ctor(self, "PresetPopupScreen")

    self.originalpreset = currentpreset
    self.levelcategory = levelcategory
    self.level_type = level_type
    self.location = location

    self.onconfirmfn = onconfirmfn
    self.oneditfn = oneditfn
    self.ondeletefn = ondeletefn

    self.root = self:AddChild(TEMPLATES.ScreenRoot())
    self.bg = self.root:AddChild(TEMPLATES.BackgroundTint(0.7))

    self.dialog_bg = self.root:AddChild(TEMPLATES.PlainBackground())
    local dialog_width = window_width + 72
    local dialog_height = window_height + 4
    self.dialog_bg:SetScissor(-dialog_width/2, -dialog_height/2, dialog_width, dialog_height)

    self.dialog = self.root:AddChild(TEMPLATES.RectangleWindow(window_width, window_height))
    local r,g,b = unpack(UICOLOURS.BROWN_DARK)
    self.dialog:SetBackgroundTint(r,g,b, 0.6) --need high opacity because of text behind

    if not TheInput:ControllerAttached() then
        self.cancel_button = self.root:AddChild(TEMPLATES.BackButton(function() self:OnCancel() end))
        self.select_button = self.root:AddChild(TEMPLATES.StandardButton(function() self:OnConfirmPreset() end, STRINGS.UI.CUSTOMIZATIONSCREEN.CONFIRM_PRESET))
        self.select_button:SetScale(0.7)
        self.select_button:SetPosition(420, -310)
    end

    local preset_str
    if self.levelcategory == LEVELCATEGORY.SETTINGS then
        preset_str = STRINGS.UI.CUSTOMIZATIONSCREEN.SETTINGSPRESET
    elseif self.levelcategory == LEVELCATEGORY.WORLDGEN then
        preset_str = STRINGS.UI.CUSTOMIZATIONSCREEN.WORLDGENPRESET
    elseif self.levelcategory == LEVELCATEGORY.COMBINED then
        preset_str = STRINGS.UI.CUSTOMIZATIONSCREEN.COMBINEDPRESET
    end

    self.presets = self.root:AddChild(Text(CHATFONT, 35))
    self.presets:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
    self.presets:SetHAlign(ANCHOR_MIDDLE)
    self.presets:SetString(preset_str)
    self.presets:SetPosition(0, 250)

    self.horizontal_line = self.root:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
    self.horizontal_line:SetPosition(0,window_height/2 - 48)
    self.horizontal_line:SetSize(dialog_width, 5)

    self.presets = Levels.GetList(self.levelcategory, self.level_type, self.location, true)

    self:OnSelectPreset(currentpreset or self.presets[1].data)

    local normal_list_item_bg_tint = {1, 1, 1, 0.4}
    local focus_list_item_bg_tint  = {1, 1, 1, 0.6}
    local current_list_item_bg_tint = {1, 1, 1, 0.8}
    local focus_current_list_item_bg_tint  = {1, 1, 1, 1}

    local hover_config = {
        offset_x = 0,
        offset_y = 48,
    }

    local function ScrollWidgetsCtor(context, i)
        local preset = Widget("preset-"..i)
        preset:SetOnGainFocus(function() self.scroll_list:OnWidgetFocus(preset) end)

        preset.backing = preset:AddChild(TEMPLATES.ListItemBackground(padded_width, padded_height, function() self:OnPresetButton(preset.data) end))
        preset.backing.move_on_click = true

        preset.name = preset.backing:AddChild(Text(CHATFONT, 26))
        preset.name:SetHAlign(ANCHOR_LEFT)
        preset.name:SetRegionSize(padded_width - 40, 30)
        preset.name:SetPosition(0, padded_height/2 - 20)

        preset.desc = preset.backing:AddChild(Text(CHATFONT, 16))
        preset.desc:SetVAlign(ANCHOR_MIDDLE)
        preset.desc:SetHAlign(ANCHOR_LEFT)
        preset.desc:SetPosition(0, padded_height/2 -(20 + 26 + 10))

        preset.edit = preset.backing:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "mods.tex", STRINGS.UI.CUSTOMIZATIONSCREEN.EDITPRESET, false, false, function() self:EditPreset(preset.data.data) end, hover_config))
        preset.edit:SetScale(0.5)
        preset.edit:SetPosition(140, padded_height/2 - 22.5)

        preset.delete = preset.backing:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "delete.tex", STRINGS.UI.CUSTOMIZATIONSCREEN.DELETEPRESET, false, false, function() self:DeletePreset(preset.data.data) end, hover_config))
        preset.delete:SetScale(0.5)
        preset.delete:SetPosition(175, padded_height/2 - 22.5)

        preset.modded = preset.backing:AddChild(Image("images/button_icons2.xml", "workshop_filter.tex"))
        preset.modded:SetScale(.1)
        preset.modded:SetClickable(false)
        preset.modded:Hide()

        local _OnControl = preset.backing.OnControl
        preset.backing.OnControl = function(_, control, down)
            if preset.edit.focus and preset.edit:OnControl(control, down) then return true end
            if preset.delete.focus and preset.delete:OnControl(control, down) then return true end

            --Normal button logic
            if _OnControl(_, control, down) then return true end

            if not down and preset.data and CustomPresetManager:IsCustomPreset(self.levelcategory, preset.data.data) then
                if control == CONTROL_MENU_MISC_1 then
                    if preset.data then
                        self:EditPreset(preset.data.data)
                        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
                        return true
                    end
                elseif control == CONTROL_MENU_MISC_2 then
                    if preset.data then
                        self:DeletePreset(preset.data.data)
                        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
                        return true
                    end
                end
            end
        end

        preset.GetHelpText = function()
            local controller_id = TheInput:GetControllerID()
            local t = {}

            if preset.data and CustomPresetManager:IsCustomPreset(self.levelcategory, preset.data.data) then
                table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_1) .. " " .. STRINGS.UI.CUSTOMIZATIONSCREEN.EDITPRESET)
                table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2) .. " " .. STRINGS.UI.CUSTOMIZATIONSCREEN.DELETEPRESET)
            end

            return table.concat(t, "  ")
        end

        preset.focus_forward = preset.backing

        return preset
    end

    local function ApplyDataToWidget(context, preset, data, index)
        if not data then
            preset.backing:Hide()
            preset.data = nil
            return
        end

        if self.selectedpreset == data.data then
            preset.backing:Select()
            preset.name:SetColour(UICOLOURS.GOLD_SELECTED)
        else
            preset.backing:Unselect()
            preset.name:SetColour(UICOLOURS.GOLD_CLICKABLE)
        end

        if preset.data ~= data then
            preset.data = data
            preset.backing:Show()

            preset.name:SetString(data.text)
            if presetstr[data.data] then
                preset.desc:SetString(presetstr[data.data])
            else
                presetstr[data.data] = GetTruncatedMultiLineString(preset.desc, Levels.GetDescForID(self.levelcategory, data.data)) --also sets the string
            end

            if data.data == self.originalpreset then
                preset.backing:SetImageNormalColour(unpack(current_list_item_bg_tint))
                preset.backing:SetImageFocusColour(unpack(focus_current_list_item_bg_tint))
                preset.backing:SetImageSelectedColour(unpack(current_list_item_bg_tint))
                preset.backing:SetImageDisabledColour(unpack(current_list_item_bg_tint))
            else
                preset.backing:SetImageNormalColour(unpack(normal_list_item_bg_tint))
                preset.backing:SetImageFocusColour(unpack(focus_list_item_bg_tint))
                preset.backing:SetImageSelectedColour(unpack(normal_list_item_bg_tint))
                preset.backing:SetImageDisabledColour(unpack(normal_list_item_bg_tint))
            end

            if CustomPresetManager:IsCustomPreset(self.levelcategory, data.data) then
                preset.edit:Show()
                preset.delete:Show()
                if data.modded then
                    preset.modded:SetPosition(110, padded_height/2 - 22.5)
                    preset.modded:Show()
                else
                    preset.modded:Hide()
                end
            else
                preset.edit:Hide()
                preset.delete:Hide()
                if data.modded then
                    preset.modded:SetPosition(175, padded_height/2 - 22.5)
                    preset.modded:Show()
                else
                    preset.modded:Hide()
                end
            end
        end
    end

    self.scroll_list = self.root:AddChild(TEMPLATES.ScrollingGrid(
        self.presets,
        {
            context = {},
            widget_width  = padded_width,
            widget_height = padded_height,
            num_visible_rows = num_rows,
            num_columns      = 1,
            item_ctor_fn = ScrollWidgetsCtor,
            apply_fn     = ApplyDataToWidget,
            scrollbar_offset = 10,
            scrollbar_height_offset = -50,
            peek_height = peek_height,
            force_peek = true,
            end_offset = 1 - peek_height/padded_height,
        }
    ))
    self.scroll_list:SetPosition(0 + (self.scroll_list:CanScroll() and -10 or 0), -25)

    self.default_focus = self.scroll_list
end)

function PresetPopupScreen:EditPreset(presetid)
    local presetdata
    if self.levelcategory == LEVELCATEGORY.COMBINED then
        presetdata = Levels.GetDataForID(LEVELCATEGORY.SETTINGS, presetid) or Levels.GetDataForID(LEVELCATEGORY.WORLDGEN, presetid)
    else
        presetdata = Levels.GetDataForID(self.levelcategory, presetid)
    end
    TheFrontEnd:PushScreen(
        NamePresetScreen(
            self.levelcategory,
            STRINGS.UI.CUSTOMIZATIONSCREEN.EDITPRESET,
            STRINGS.UI.CUSTOMIZATIONSCREEN.SAVEPRESETCHANGES,
            function(newid, name, description)
                if not self.oneditfn(self.levelcategory, presetid, newid, name, description) then
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
                    return
                end
                self:UpdatePresetList()
            end,
            presetid,
            presetdata.name,
            presetdata.desc
        )
    )
end

function PresetPopupScreen:DeletePreset(presetid)
    TheFrontEnd:PushScreen(
        PopupDialogScreen(string.format(STRINGS.UI.CUSTOMIZATIONSCREEN.DELETEPRESET_TITLE, Levels.GetNameForID(self.levelcategory, presetid)), STRINGS.UI.CUSTOMIZATIONSCREEN.DELETEPRESET_BODY,
        {
            {
                text = STRINGS.UI.CUSTOMIZATIONSCREEN.CANCEL,
                cb = function()
                    TheFrontEnd:PopScreen()
                end,
            },
            {
                text = STRINGS.UI.CUSTOMIZATIONSCREEN.DELETE,
                cb = function()
                    self.ondeletefn(self.levelcategory, presetid)
                    self:UpdatePresetList()
                    TheFrontEnd:PopScreen()
                end,
            },
        })
    )
end

function PresetPopupScreen:OnPresetButton(presetinfo)
    self:OnSelectPreset(presetinfo.data)
    self:Refresh()
end

function PresetPopupScreen:UpdatePresetList()
    self.presets = Levels.GetList(self.levelcategory, self.level_type, self.location, true)
    self.scroll_list:SetItemsData(self.presets)
    self.scroll_list:SetPosition(0 + (self.scroll_list:CanScroll() and -10 or 0), -25)
end

function PresetPopupScreen:Refresh()
    self.scroll_list:RefreshView()
end

function PresetPopupScreen:OnCancel()
    self:_Close()
end

function PresetPopupScreen:OnConfirmPreset()
    self:_Close()
    self.onconfirmfn(self.levelcategory, self.selectedpreset)
end

function PresetPopupScreen:OnSelectPreset(presetid)
    self.selectedpreset = presetid
end

function PresetPopupScreen:OnControl(control, down)
    if PresetPopupScreen._base.OnControl(self, control, down) then return true end

    if not down then
        if control == CONTROL_CANCEL then
            self:OnCancel()
            return true
        elseif control == CONTROL_PAUSE then
            self:OnConfirmPreset()
            return true
        end
    end
end

function PresetPopupScreen:GetHelpText()
	local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.CANCEL)
    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_PAUSE) .. " " .. STRINGS.UI.CUSTOMIZATIONSCREEN.CONFIRM_PRESET)

	return table.concat(t, "  ")
end

function PresetPopupScreen:_Close()
    TheFrontEnd:PopScreen()
end

return PresetPopupScreen