local Screen = require "widgets/screen"
local TEMPLATES = require "widgets/redux/templates"
local PopupDialogScreen = require "screens/redux/popupdialog"

local label_width = 200 -- width of the label on the wide fields
local input_width = 500
local field_nudge = -55
local label_height = 40
local space_between = 5
local font_size = 25

local PRESET_NAME_MAX_LENGTH = 50
local PRESET_DESCRIPTION_MAX_LENGTH = 1000

local INVALID_CHARACTER_FILTER = [[<>:"/\|?*]]
local invalidcharints = {}
for i = 1, 31 do table.insert(invalidcharints, i) end
INVALID_CHARACTER_FILTER = INVALID_CHARACTER_FILTER..string.char(unpack(invalidcharints))

local NamePresetScreen = Class(Screen, function(self, category, title, confirmstr, onconfirmfn, editingpresetid, name, desc)
    assert(onconfirmfn, "NamePresetScreen requires a onconfirmfn")

    Screen._ctor(self, "NamePresetScreen")

    self.levelcategory = category
    self.onconfirmfn = onconfirmfn
    self.editingpresetid = editingpresetid

    self.root = self:AddChild(TEMPLATES.ScreenRoot())
    self.bg = self.root:AddChild(TEMPLATES.BackgroundTint(0.7))

    local buttons = {
        {
            text = STRINGS.UI.CUSTOMIZATIONSCREEN.CANCEL,
            cb = function() self:Close() end,
        },
        {
            text = confirmstr,
            cb = function() self:SavePreset() end
        }
    }

    self.window = self.root:AddChild(TEMPLATES.CurlyWindow(600, 150, title, buttons))

    self.preset_name = self.window:AddChild(TEMPLATES.LabelTextbox(STRINGS.UI.CUSTOMIZATIONSCREEN.NAMEPRESET, name or "", label_width, input_width, label_height, space_between, NEWFONT, font_size, field_nudge))
    self.preset_name.textbox:SetTextLengthLimit(PRESET_NAME_MAX_LENGTH)
    self.preset_name.textbox:SetInvalidCharacterFilter(INVALID_CHARACTER_FILTER)
    self.preset_name:SetPosition(0, 60)

    self.preset_desc = self.window:AddChild(TEMPLATES.LabelTextbox(STRINGS.UI.CUSTOMIZATIONSCREEN.DESCRIBEPRESET, desc or "", label_width, input_width, label_height, space_between, NEWFONT, font_size, field_nudge))
    self.preset_desc.textbox:SetTextLengthLimit(PRESET_DESCRIPTION_MAX_LENGTH)
    self.preset_desc:SetPosition(0, 10)

    self.default_focus = self.preset_name

    self:DoFocusHookups()
end)

function NamePresetScreen:SavePreset()
    local name = self.preset_name.textbox:GetString()

    if not name or #name:gsub("%s", "") == 0 then
        TheFrontEnd:PushScreen(
            PopupDialogScreen(STRINGS.UI.CUSTOMIZATIONSCREEN.MISSINGPRESETNAME_TITLE, STRINGS.UI.CUSTOMIZATIONSCREEN.MISSINGPRESETNAME_BODY,
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

    local desc = self.preset_desc.textbox:GetString()
    local id = self:GetID(name)

    if CustomPresetManager:PresetIDExists(self.levelcategory, id) and CustomPresetManager:IsValidPreset(self.levelcategory, id) then
        if id ~= self.editingpresetid then
            TheFrontEnd:PushScreen(
                PopupDialogScreen(STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETEXISTS_TITLE, string.format(STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETEXISTS_BODY, name),
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
    end
    self:Close()
    self.onconfirmfn(id, name, desc)
end

function NamePresetScreen:Close()
    TheFrontEnd:PopScreen()
end

function NamePresetScreen:GetID(name)
    return "CUSTOM_"..name:upper()
end

function NamePresetScreen:DoFocusHookups()
    self.preset_name:SetFocusChangeDir(MOVE_DOWN, self.preset_desc.textbox)

    self.preset_desc:SetFocusChangeDir(MOVE_UP, self.preset_name.textbox)
    self.preset_desc:SetFocusChangeDir(MOVE_DOWN, self.window)

    self.window:SetFocusChangeDir(MOVE_UP, self.preset_desc.textbox)
end

function NamePresetScreen:OnControl(control, down)
    if NamePresetScreen._base.OnControl(self, control, down) then return true end

    if not down then
        if control == CONTROL_CANCEL then
            self:Close()
            return true
        end
    end
end

function NamePresetScreen:GetHelpText()
	local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.CANCEL)

	return table.concat(t, "  ")
end

return NamePresetScreen