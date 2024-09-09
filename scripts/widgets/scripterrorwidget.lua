local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"

local ScriptErrorWidget = Class(Widget, function(self, title, text, buttons, texthalign, additionaltext, textsize, timeout)
    Widget._ctor(self, "ScriptErrorWidget")

	self.is_screen = true -- hack to reduce log spam of: "Widget:SetFocusFromChild is happening on a widget outside of the screen/widget hierachy"

    self:SetHAnchor(ANCHOR_LEFT)
    self:SetVAnchor(ANCHOR_BOTTOM)

    TheInputProxy:SetCursorVisible(true)

    self.special_general_control = TheInput:AddGeneralControlHandler(function(control, down) self:OnControl(control == CONTROL_PRIMARY and CONTROL_ACCEPT or control, down) end)
    self.special_mouse_control = TheInput:AddMouseButtonHandler(function(button, down, x, y) self:OnMouseButton(button, down, x, y) end)

    --darken everything behind the dialog
    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black:SetTint(0,0,0,.8)

    self.root = self:AddChild(Widget("ROOT"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetPosition(0,0,0)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    --title
    self.title = self.root:AddChild(Text(TITLEFONT, 50))
    self.title:SetPosition(0, 170, 0)
    self.title:SetString(title)

    --text
    local defaulttextsize = 24
    if textsize then
        defaulttextsize = textsize
    end

    self.text = self.root:AddChild(Text(BODYTEXTFONT, defaulttextsize))
    self.text:SetVAlign(ANCHOR_TOP)

    if texthalign then
        self.text:SetHAlign(texthalign)
    end

    self.text:SetPosition(0, 40, 0)
    self.text:SetString(text)
    self.text:EnableWordWrap(true)
    self.text:SetRegionSize(480*2, 200)

    if additionaltext then
        self.additionaltext = self.root:AddChild(Text(BODYTEXTFONT, 24))
        self.additionaltext:SetVAlign(ANCHOR_TOP)
        self.additionaltext:SetPosition(0, -150, 0)
        self.additionaltext:SetString(additionaltext)
        self.additionaltext:EnableWordWrap(true)
        self.additionaltext:SetRegionSize(480*2, 100)
    end

    self.version = self:AddChild(Text(BODYTEXTFONT, 20))
    --self.version:SetHRegPoint(ANCHOR_LEFT)
    --self.version:SetVRegPoint(ANCHOR_BOTTOM)
    self.version:SetHAnchor(ANCHOR_LEFT)
    self.version:SetVAnchor(ANCHOR_BOTTOM)
    self.version:SetHAlign(ANCHOR_LEFT)
    self.version:SetVAlign(ANCHOR_BOTTOM)
    self.version:SetRegionSize(200, 40)
    self.version:SetPosition(110, 30, 0)
    self.version:SetString("Rev. "..APP_VERSION.." "..PLATFORM)

    if buttons ~= nil then
        --create the menu itself
        local button_w = 200
        local space_between = 20
        local spacing = button_w + space_between

        self.menu = self.root:AddChild(Menu(buttons, 250, true))
        self.menu:SetHRegPoint(ANCHOR_MIDDLE)
        self.menu:SetPosition(0, -250, 0)
        self.default_focus = self.menu
    end

    TheSim:SetUIRoot(self.inst.entity)
end)

function ScriptErrorWidget:GoAway()
    -- Undo special handling this widget typically has.
    global_error_widget = nil
    TheInput.oncontrol:RemoveHandler(self.special_general_control)
    self.special_general_control = nil
    TheInput.onmousebutton:RemoveHandler(self.special_mouse_control)
    self.special_mouse_control = nil
    self:Kill()
    TheSim:SetUIRoot(LastUIRoot)
end

function ScriptErrorWidget:OnControl(control, down)
    if ScriptErrorWidget._base.OnControl(self, control, down) then return true end
end

function ScriptErrorWidget:OnUpdate( dt )
    local x,y = TheSim:GetPosition()
    local entitiesundermouse = TheSim:GetEntitiesAtScreenPoint(x, y, true)
    local hover_inst = entitiesundermouse[1]
    if hover_inst and hover_inst.widget then
        hover_inst.widget:SetFocus()
    else
        self.menu:SetFocus(1)
    end

    if self.timeout then
        self.timeout.timeout = self.timeout.timeout - dt
        if self.timeout.timeout <= 0 then
            self.timeout.cb()
        end
    end

    -- DebugKeys are disabled at this point, so check manually
	if TheInput:IsKeyDown(KEY_R) and TheInput:IsKeyDown(KEY_CTRL) then
        TheSim:ResetError()
        c_reset()
    end

    return true
end

return ScriptErrorWidget
