local Screen = require "widgets/screen"
local Text = require "widgets/text"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"

-- A popup displaying a list of text.
--
-- body_text can be two lines of text
local TextListPopup = Class(Screen, function(self, list_items, title_text, body_text, buttons, spacing, nohelpbutton)
    Screen._ctor(self, "TextListPopup")

    local scroll_height = 380
    local body_height = 0
    if body_text then
        body_height = 100
    end

    self.black = self:AddChild(TEMPLATES.BackgroundTint())
    self.proot = self:AddChild(TEMPLATES.ScreenRoot())

    self.buttons = buttons or {}

    if not nohelpbutton then
        table.insert(self.buttons, {
            text=STRINGS.UI.HELP.BACK,
            cb = function()
                self:_Cancel()
            end,
            controller_control = CONTROL_CANCEL,
        })
    end
    self.dialog = self.proot:AddChild(TEMPLATES.CurlyWindow(470,
            scroll_height + body_height,
            title_text,
            self.buttons,
            spacing,
            body_text or "" -- force creation of body to re-use sizing data
        ))
    local _,content_width = self.dialog.body:GetRegionSize()

    self.oncontrol_fn, self.gethelptext_fn = TEMPLATES.ControllerFunctionsFromButtons(self.buttons)
    if TheInput:ControllerAttached() then
        self.dialog.actions:Hide()
    end

    local item_height = 30
    local do_items_have_buttons = false
    for i,item in ipairs(list_items) do
        if item.onclick then
            do_items_have_buttons = true
            item_height = 40
            break
        end
    end

    local function ScrollWidgetsCtor(context, i)
        local item = Widget("item-"..i)
        item.root = item:AddChild(Widget("root"))
        if do_items_have_buttons then
            item.btn = item.root:AddChild(TEMPLATES.StandardButton(nil, "", {content_width+20,item_height+10}))
            item.text = item.btn.text

            item.SetOnClick = function(_, onclick)
                item.btn:SetOnClick(onclick)
                if onclick then
                    item.btn:Enable()
                else
                    item.btn:Disable()
                end
            end

            item.focus_forward = item.btn
        else
            item.text = item.root:AddChild(Text(CHATFONT, 25, "", UICOLOURS.GOLD_UNIMPORTANT))

            item.SetOnClick = function(_, onclick)
            end

            item.focus_forward = item.text
        end

        item:SetOnGainFocus(function()
            self.scroll_list:OnWidgetFocus(item)
        end)

        return item
    end
    local function ScrollWidgetApply(context, item, data, index)
        if data then
            item:SetOnClick(data.onclick)
            item.text:SetTruncatedString(data.text, content_width-25, 75, true)
            -- left align
            local w, h = item.text:GetRegionSize()
            item.text:SetPosition(-content_width/2 + w/2 + 20, 0, 0)

            item.root:Show()
        else
            item.root:Hide()
        end
    end

    self.scroll_list = self.proot:AddChild(
        TEMPLATES.ScrollingGrid(
            list_items,
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

    if body_text then
        self.dialog.body:SetPosition(0, 210)
        self.dialog.body:SetRegionSize(content_width, body_height)
        self.scroll_list:SetPosition(0, -10)
    end

    self.scroll_list:SetFocusChangeDir(MOVE_DOWN, self.dialog.actions)
    self.scroll_list:SetFocusChangeDir(MOVE_RIGHT, self.dialog.actions)
    self.dialog.actions:SetFocusChangeDir(MOVE_UP, self.scroll_list)

    self.default_focus = self.scroll_list
end)

function TextListPopup:OnControl(control, down)
    if TextListPopup._base.OnControl(self,control, down) then
        return true
    end

    return self.oncontrol_fn(control, down)
end

function TextListPopup:GetHelpText()
    return self.gethelptext_fn()
end

function TextListPopup:_Cancel()
    TheFrontEnd:PopScreen(self)
end

return TextListPopup
