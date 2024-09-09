local Screen = require "widgets/screen"
local Text = require "widgets/text"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"
local AccountItemFrame = require "widgets/redux/accountitemframe"

local BeefaloSkinPresetsPopup = Class(Screen, function(self, user_profile, character, selected_skins, apply_cb)
    Screen._ctor(self, "BeefaloSkinPresetsPopup")

    self.user_profile = user_profile
    self.character = character
    self.selected_skins = selected_skins
    self.apply_cb = apply_cb

    self.list_items = {}
    for i=1,NUM_SKIN_PRESET_SLOTS do
        self.list_items[i] = self.user_profile:GetSkinPresetForCharacter(self.character, i)
    end

    local scroll_height = 460
    local content_width = 390
    local item_height = 60

    self.black = self:AddChild(TEMPLATES.BackgroundTint())
    self.proot = self:AddChild(TEMPLATES.ScreenRoot())

    self.buttons = {
        {
            text=STRINGS.UI.HELP.BACK,
            cb = function()
                self:_Cancel()
            end,
            controller_control = CONTROL_CANCEL,
        },
    }
    self.dialog = self.proot:AddChild(TEMPLATES.CurlyWindow(470,
            scroll_height,
            STRINGS.UI.SKIN_PRESETS.TITLE,
            self.buttons,
            30,
            "" -- force creation of body to re-use sizing data
        ))

    self.oncontrol_fn, self.gethelptext_fn = TEMPLATES.ControllerFunctionsFromButtons(self.buttons)
    if TheInput:ControllerAttached() then
        self.dialog.actions:Hide()
    end


    local function ScrollWidgetsCtor(context, i)
        local item = Widget("item-"..i)
        item.root = item:AddChild(Widget("root"))

        item.row_label = item.root:AddChild(Text(BODYTEXTFONT, 28))
        item.row_label:SetColour(UICOLOURS.IVORY)
        item.row_label:SetHAlign(ANCHOR_RIGHT)

        local x_start = -180
        local x_step = 50

        if table.contains(DST_CHARACTERLIST, self.character) then --no base option for mod characters
            item.base_icon = item.root:AddChild( AccountItemFrame() )
            item.base_icon:SetStyle_Normal()
            item.base_icon:SetScale(0.4)
            item.base_icon:SetPosition(x_start + 0 * x_step,0)

            item.row_label:SetPosition(-210,-1)
            item.root:SetPosition(20,0)
        else
            item.row_label:SetPosition(-160,-1)
            item.root:SetPosition(-20,0)
        end

        item.beef_body_icon = item.root:AddChild( AccountItemFrame() )
        item.beef_body_icon:SetStyle_Normal()
        item.beef_body_icon:SetScale(0.4)
        item.beef_body_icon:SetPosition(x_start + 1 * x_step,0)

        item.beef_horn_icon = item.root:AddChild( AccountItemFrame() )
        item.beef_horn_icon:SetStyle_Normal()
        item.beef_horn_icon:SetScale(0.4)
        item.beef_horn_icon:SetPosition(x_start + 2 * x_step,0)

        item.beef_head_icon = item.root:AddChild( AccountItemFrame() )
        item.beef_head_icon:SetStyle_Normal()
        item.beef_head_icon:SetScale(0.4)
        item.beef_head_icon:SetPosition(x_start + 3 * x_step,0)

        item.beef_feet_icon = item.root:AddChild( AccountItemFrame() )
        item.beef_feet_icon:SetStyle_Normal()
        item.beef_feet_icon:SetScale(0.4)
        item.beef_feet_icon:SetPosition(x_start + 4 * x_step,0)

        item.beef_tail_icon = item.root:AddChild( AccountItemFrame() )
        item.beef_tail_icon:SetStyle_Normal()
        item.beef_tail_icon:SetScale(0.4)
        item.beef_tail_icon:SetPosition(x_start + 5 * x_step,0)


        item.load_btn = item.root:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "apply_skins.tex", nil, nil, nil, function(a) self:_LoadPreset(item.i) end, STRINGS.UI.SKIN_PRESETS.LOAD))
        item.load_btn:SetPosition(125,-1)
        item.load_btn:SetScale(0.7)

        item.save_btn = item.root:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "save.tex", nil, nil, nil, function() self:_SetPreset(item.i) end, STRINGS.UI.SKIN_PRESETS.SAVE))
        item.save_btn:SetPosition(175,-1)
        item.save_btn:SetScale(0.7)

        item.load_btn:SetFocusChangeDir(MOVE_RIGHT, item.save_btn)
		item.save_btn:SetFocusChangeDir(MOVE_LEFT, item.load_btn)

        item.focus_forward = item.load_btn

        item:SetOnGainFocus(function()
            self.scroll_list:OnWidgetFocus(item)
        end)

        return item
    end
    local function ScrollWidgetApply(context, item, data, index)
        if data then
            item.i = index
            item.row_label:SetString(tostring(index)..":")

            if table.contains(DST_CHARACTERLIST, self.character) then --no base option for mod characters
                if data.base then
                    item.base_icon:SetItem(data.base)
                else
                    item.base_icon:SetItem(self.character.."_none")
                end
            end

            if data.beef_body then
                item.beef_body_icon:SetItem(data.beef_body)
            else
                item.beef_body_icon:SetItem("beef_body_default1")
            end

            if data.beef_horn then
                item.beef_horn_icon:SetItem(data.beef_horn)
            else
                item.beef_horn_icon:SetItem("beef_horn_default1")
            end

            if data.beef_head then
                item.beef_head_icon:SetItem(data.beef_head)
            else
                item.beef_head_icon:SetItem("beef_head_default1")
            end

            if data.beef_feet then
                item.beef_feet_icon:SetItem(data.beef_feet)
            else
                item.beef_feet_icon:SetItem("beef_feet_default1")
            end

            if data.beef_tail then
                item.beef_tail_icon:SetItem(data.beef_tail)
            else
                item.beef_tail_icon:SetItem("beef_tail_default1")
            end

            item.root:Show()
        else
            item.root:Hide()
        end
    end

    self.scroll_list = self.proot:AddChild(
        TEMPLATES.ScrollingGrid(
            self.list_items,
            {
                context = {},
                widget_width  = content_width + 40,
                widget_height =  item_height,
                num_visible_rows = math.floor(scroll_height/item_height) - 1,
                num_columns      = 1,
                item_ctor_fn = ScrollWidgetsCtor,
                apply_fn     = ScrollWidgetApply,
                scrollbar_height_offset = -60
            }
        ))
    self.scroll_list:SetPosition(0, 30)

    self.scroll_list:SetFocusChangeDir(MOVE_DOWN, self.dialog.actions)
    self.scroll_list:SetFocusChangeDir(MOVE_RIGHT, self.dialog.actions)
    self.dialog.actions:SetFocusChangeDir(MOVE_UP, self.scroll_list)

    self.default_focus = self.scroll_list
end)

function BeefaloSkinPresetsPopup:_LoadPreset(i)
    self.apply_cb(self.list_items[i])
    TheFrontEnd:PopScreen(self)
end
function BeefaloSkinPresetsPopup:_SetPreset(i)
    self.user_profile:SetSkinPresetForCharacter(self.character, i, self.selected_skins)
    TheFrontEnd:PopScreen(self)
end

function BeefaloSkinPresetsPopup:OnControl(control, down)
    if BeefaloSkinPresetsPopup._base.OnControl(self,control, down) then
        return true
    end

    return self.oncontrol_fn(control, down)
end

function BeefaloSkinPresetsPopup:GetHelpText()
    return self.gethelptext_fn()
end

function BeefaloSkinPresetsPopup:_Cancel()
    TheFrontEnd:PopScreen(self)
end

return BeefaloSkinPresetsPopup
