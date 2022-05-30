local Screen = require "widgets/screen"
local Button = require "widgets/button"
local ImageButton = require "widgets/imagebutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local ScrollableList = require "widgets/scrollablelist"
local TEMPLATES = require "widgets/templates"

-- Deprecated. Replaced with TextListPopup.
local TextListPopupDialogScreen = Class(Screen, function(self, title, str, body, buttons, spacing, strfont)
    Screen._ctor(self, "PopupDialogScreen")

    --darken everything behind the dialog
    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black:SetTint(0,0,0,.75)

    self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetPosition(0,0,0)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

    --throw up the background
    self.bg = self.proot:AddChild(TEMPLATES.CurlyWindow(1, 325, .8, .8, 54, -32))
    self.bg.fill = self.proot:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tall.tex"))
    self.bg.fill:SetScale(.47, -.495)
    self.bg.fill:SetPosition(8, 10)
    self.bg:SetPosition(0,0,0)

    --title
    self.title = self.proot:AddChild(Text(BUTTONFONT, 45))
    self.title:SetPosition(5, 170, 0)
    self.title:SetString(title)
    self.title:SetColour(0,0,0,1)

    --text
    self.listwidgets = {}
    local liststrings = {}
    if type(str) == "table" then
        liststrings = str
    elseif str ~= "" then
        local startPos = 1
        local endPos = 1
        local token = ""
        if string.len(str) == 1 then
            table.insert(self.queryTokens, string.lower(str))
        else
            for i=1, string.len(str) do
                -- Separate search tokens by , (and make sure we grab the trailing token)
                if string.sub(str,i,i) == "," or i == string.len(str) then
                    endPos = i
                end
                if (endPos ~= startPos and endPos > startPos) or (endPos == string.len(str)) then
                    if endPos < string.len(str) or (endPos == string.len(str) and string.sub(str, endPos, endPos) == ",") then
                        endPos = endPos - 1
                    end
                    token = string.sub(str, startPos, endPos) -- Grab the token
                    token = string.gsub(token, "^%s*(.-)%s*$", "%1") -- Get rid of whitespace on the ends
                    table.insert(liststrings, token)
                    startPos = endPos + 2 -- Increase startPos so we skip the comma for the next token
                end
            end
        end
    end

    for i,v in ipairs(liststrings) do
        local widg = Widget("str"..i)
        local strWidg = widg:AddChild(Text(strfont or NEWFONT, 25, "", {0,0,0,1}))
        strWidg:SetTruncatedString(v, 285, 75, true)
        local w, h = strWidg:GetRegionSize()
        strWidg:SetPosition(23 + w * .5, 0, 0)
        widg.text = strWidg
        table.insert(self.listwidgets, widg)
    end

    if buttons ~= nil then
        if not TheInput:ControllerAttached() then
            self.menu = self.proot:AddChild(Menu(buttons, spacing or 245, true))
            self.menu:SetPosition(15 + -(200*(#buttons-1))/2, -210, 0)
            self.menu:SetScale(.75)
        else
            -- Reverse the table so our help text shows in a nice order
            local revButtons = {}
            for i,v in ipairs(buttons) do
                revButtons[#buttons-i+1] = v
            end
            buttons = revButtons
        end
        self.buttons = buttons
    elseif not TheInput:ControllerAttached() then
        self.button = self.proot:AddChild(ImageButton())
        self.button:SetText(STRINGS.UI.SERVERLISTINGSCREEN.OK)
        self.button:SetOnClick(function() self:Close() end)
        self.button:SetPosition(5,-210)
        self.button:SetScale(.85)
    end

    if body ~= nil then
        self.body = self.proot:AddChild(Text(NEWFONT, 23))
        self.body:SetPosition(0, 130, 0)
        self.body:SetRegionSize(300,200)
        self.body:EnableWordWrap(true)
        self.body:SetString(body)
        self.body:SetColour(0,0,0,1)

        self.scrolllist = self.proot:AddChild(ScrollableList(self.listwidgets, 330, 260, 30, 5, nil, nil, nil, nil, nil, 10))
        self.scrolllist:SetPosition(-10,-40)
    else
        self.scrolllist = self.proot:AddChild(ScrollableList(self.listwidgets, 330, 300, 30, 5, nil, nil, nil, nil, nil, 10))
        self.scrolllist:SetPosition(-10,-10)
    end

    self.default_focus = self.scrolllist
end)

function TextListPopupDialogScreen:SetTitleTextSize(size)
    self.title:SetSize(size)
end

function TextListPopupDialogScreen:OnControl(control, down)
    if TextListPopupDialogScreen._base.OnControl(self,control, down) then return true end

    if down then
        return false
    elseif control == CONTROL_CANCEL then
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        self:Close()
        return true
    elseif self.buttons ~= nil and TheInput:ControllerAttached() then
        for i,v in ipairs(self.buttons) do
            if control == v.controller_control then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
                v.cb()
                return true
            end
        end
    end

    return false
end

function TextListPopupDialogScreen:Close()
    TheFrontEnd:PopScreen(self)
end

function TextListPopupDialogScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    if self.buttons then
        for i,v in ipairs(self.buttons) do
            table.insert(t, TheInput:GetLocalizedControl(controller_id, v.controller_control) .. " " .. v.text)
        end
    else
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
    end
    return table.concat(t, "  ")
end

return TextListPopupDialogScreen
