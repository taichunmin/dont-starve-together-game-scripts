require "fonts"
local Widget = require "widgets/widget"
local TextButton = require "widgets/textbutton"
local Text = require "widgets/text"
local Image = require "widgets/image"

local RadioButtons = Class(Widget, function(self, options, width, height, buttonsettings, horizontal_layout, onbuttonconstruct)
    Widget._ctor(self, "RADIOBUTTONS")

    self.options = options
    self.width = width
    self.height = height
    self.buttonsettings = buttonsettings
    self.horizontal_layout = horizontal_layout
    self.onbuttonconstruct = onbuttonconstruct

    self.buttonwidgets = {}
    self.selectedIndex = 1


    self:UpdateButtons()
end)

function RadioButtons:MakeRadioButton()
    local wdg = Widget("radiowidget")
    wdg.radio = Image(self.buttonsettings.atlas or "images/ui.xml", self.buttonsettings.off_image or "radiobutton_off.tex")
    if self.buttonsettings.image_scale then
        wdg.radio:SetScale(self.buttonsettings.image_scale, self.buttonsettings.image_scale)
    end
    local radiosz_x, radiosz_y = wdg.radio:GetSize()

    wdg.background = wdg:AddChild(Image("images/ui.xml", "spinner_focus.tex"))
    wdg.background:SetTint(1,1,1,0)
    wdg.background:ScaleToSize(self.buttonsettings.width, self.buttonsettings.height)
    wdg.background:MoveToBack()

    wdg.button = wdg:AddChild(TextButton())
    wdg.button.text:SetHAlign(ANCHOR_LEFT)
    wdg.button:SetFont(self.buttonsettings.font or NEWFONT)
    if self.buttonsettings.font_size then
        wdg.button:SetTextSize(self.buttonsettings.font_size)
    end
    wdg.button:SetTextColour(self.buttonsettings.normal_colour or {0,0,0,1})
    wdg.button:SetTextFocusColour(self.buttonsettings.hover_colour or {0,0,0,1})
    wdg.button:SetTextDisabledColour(self.buttonsettings.disabled_colour or {0.5, 0.5, 0.5, 1})
    wdg.button:SetTextSelectedColour(self.buttonsettings.selected_colour or {0,0,0,1})
    wdg.button.text:SetRegionSize(self.buttonsettings.width-radiosz_x, self.buttonsettings.height)
    wdg.button:SetPosition(radiosz_x/2, 0)

    -- Okay, this a little weird, we need to add the radio indicator as a child of the button for clickability,
    -- but position it relative to the container widget, so the numbers going into setposition get odd...
    wdg.button:AddChild(wdg.radio)
    wdg.radio:SetPosition(-self.buttonsettings.width/2 + radiosz_x/2 - radiosz_x/2, 0)

    local origfocus = wdg.OnGainFocus
    wdg.OnGainFocus = function(obj)
        origfocus(obj)
        if wdg.button:IsEnabled() then
            wdg.background:SetTint(1,1,1,1)
        end
    end
    local origlosefocus = wdg.OnLoseFocus
    wdg.OnLoseFocus = function(obj)
        origlosefocus(obj)
        wdg.background:SetTint(1,1,1,0)
    end
    return wdg
end

function RadioButtons:UpdateButtons()
    for i,option in ipairs(self.options) do
        if self.buttonwidgets[i] == nil then
            self.buttonwidgets[i] = self:AddChild(self:MakeRadioButton())

            if self.horizontal_layout then
                local spacing = (self.width / #self.options)
                self.buttonwidgets[i]:SetPosition(spacing * (i+1) - self.width + spacing/2, 0)
            else
                local spacing = (self.height / #self.options)
                self.buttonwidgets[i]:SetPosition(0, spacing * (i+1) - self.height + spacing/2)
            end
            if self.onbuttonconstruct then
                self.onbuttonconstruct(self, self.buttonwidgets[i])
            end
        end
        self.buttonwidgets[i].button:SetText(option.text)
        self.buttonwidgets[i].button.onclick = function() self:SetSelectedIndex(i) end
        if i == self.selectedIndex then
            self.buttonwidgets[i].button:Select()
            self.buttonwidgets[i].radio:SetTexture(self.buttonsettings.atlas or "images/ui.xml", self.buttonsettings.on_image or "radiobutton_on.tex")
        else
            self.buttonwidgets[i].button:Unselect()
            self.buttonwidgets[i].radio:SetTexture(self.buttonsettings.atlas or "images/ui.xml", self.buttonsettings.off_image or "radiobutton_off.tex")
        end
    end

    for i=#self.buttonwidgets,#self.options+1,-1 do
        self.buttonwidgets[i]:Kill()
        self.buttonwidgets[i] = nil
    end

    -- ensure focus hookups
    local prevenabled = nil
    for i,buttonwidget in ipairs(self.buttonwidgets) do
        if buttonwidget.button:IsEnabled() == true then

            -- clear these, they may get set again if there is a next widget
            buttonwidget.button:SetFocusChangeDir(MOVE_RIGHT, nil)
            buttonwidget.button:SetFocusChangeDir(MOVE_DOWN, nil)

            if prevenabled ~= nil then
                if self.horizontal_layout then
                    buttonwidget.button:SetFocusChangeDir(MOVE_LEFT, prevenabled.button)
                    prevenabled.button:SetFocusChangeDir(MOVE_RIGHT, buttonwidget.button)
                else
                    buttonwidget.button:SetFocusChangeDir(MOVE_UP, prevenabled.button)
                    prevenabled.button:SetFocusChangeDir(MOVE_DOWN, buttonwidget.button)
                end
            else
                buttonwidget.button:SetFocusChangeDir(MOVE_LEFT, nil)
                buttonwidget.button:SetFocusChangeDir(MOVE_UP, nil)
            end

            -- Make the currently selected radio the focus_forward target. This might not be good general-case,
            -- but it feels quite comfortable in the current setup. ~gjans
            if i == self.selectedIndex then
                self.focus_forward = buttonwidget.button
            end

            prevenabled = buttonwidget
        end
    end
end

function RadioButtons:SetSelected( data )
    for i,v in ipairs(self.options) do
        if v.data == data then
            self:SetSelectedIndex(i)
            return
        end
    end
end

function RadioButtons:SetSelectedIndex( i )
    if i > 0 and i <= #self.options then
        local currentdata = self:GetSelectedData()

        self.selectedIndex = i
        self:UpdateButtons()

        if currentdata ~= self:GetSelectedData() then
            self:OnChanged()
        end
    end
end

function RadioButtons:GetSelectedData()
    if self.selectedIndex > 0 and self.selectedIndex <= #self.options then
        return self.options[ self.selectedIndex ].data
    end
end

function RadioButtons:EnableButton( data )
    for i,v in ipairs(self.options) do
        if v.data == data then
            self.buttonwidgets[i].button:Enable()
            return true
        end
    end
    return false
end

function RadioButtons:EnableAllButtons()
    for i,buttonwidget in ipairs(self.buttonwidgets) do
        buttonwidget.button:Enable()
    end
end

function RadioButtons:DisableButton( data )
    for i,v in ipairs(self.options) do
        if v.data == data then
            self.buttonwidgets[i].button:Disable()
            return true
        end
    end
    return false
end

function RadioButtons:DisableAllButtons()
    for i,buttonwidget in ipairs(self.buttonwidgets) do
        buttonwidget.button:Disable()
    end
end

function RadioButtons:SetOnChangedFn(fn)
    self.onchangedfn = fn
end

function RadioButtons:OnChanged()
    if self.onchangedfn ~= nil then
        self.onchangedfn( self:GetSelectedData() )
    end
end

return RadioButtons
