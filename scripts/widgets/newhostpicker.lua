local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local RadioButtons = require "widgets/radiobuttons"

local newhost_options =
{
    {
        data = "ALONE",
        atlas = "images/new_host_picker.xml",
        image = "alone.tex",
    },
    {
        data = "TOGETHER",
        atlas = "images/new_host_picker.xml",
        image = "together.tex",
    },
}

local TILEWIDTH = 228 -- this is the width of the actual graphic
local tile_width = 250 -- our target width
local tile_height = 210
local tile_scale = { tile_width / TILEWIDTH, tile_height / TILEWIDTH }
local tile_spacing = 10

local NewHostPicker = Class(Widget, function(self)
    Widget._ctor(self, "NewHostPicker")

    self.buttons = {}

    local function CheckClearDescription()
        for i, v in ipairs(self.buttons) do
            if v.focus then
                return
            end
        end
        --None of the buttons has focus
        self.description:SetString("")
    end

    for i, v in ipairs(newhost_options) do
        self.buttons[i] = self:AddChild(ImageButton("images/ui.xml", "in-window_button_tile_idle.tex", "in-window_button_tile_hl.tex", "in-window_button_tile_disabled.tex", "in-window_button_tile_hl_noshadow.tex", "in-window_button_tile_disabled.tex", tile_scale, { 0, 0 }))

        self.buttons[i].bigicon = self.buttons[i]:AddChild(Image(newhost_options[i].atlas, newhost_options[i].image))
        self.buttons[i].bigicon:SetScale(.4)
        self.buttons[i].bigicon:SetPosition(0, -12)

        self.buttons[i]:SetText(STRINGS.UI.SERVERCREATIONSCREEN.NEWHOST_TYPE[newhost_options[i].data])
        self.buttons[i]:SetFont(BUTTONFONT)
        self.buttons[i].text:SetPosition(0, 62)
        self.buttons[i].text:MoveToFront()

        self.buttons[i]:SetOnGainFocus(function()
            self.description:SetString(STRINGS.UI.SERVERCREATIONSCREEN.NEWHOST_DESC[newhost_options[i].data])
        end)
        self.buttons[i]:SetOnLoseFocus(CheckClearDescription)
        self.buttons[i]:SetOnClick(function()
            if self.cb ~= nil then
                self.cb(newhost_options[i].data)
            end
        end)

        local pos_index = i - 1 - (#newhost_options - 1) / 2
        self.buttons[i]:SetPosition(pos_index * tile_width + pos_index * tile_spacing, -155)
    end

    for i, v in ipairs(self.buttons) do
        if i > 1 then
            v:SetFocusChangeDir(MOVE_LEFT, self.buttons[i - 1])
        end
        if i < #self.buttons then
            v:SetFocusChangeDir(MOVE_RIGHT, self.buttons[i + 1])
        end
    end

    self.headertext = self:AddChild(Text(BUTTONFONT, 40, STRINGS.UI.SERVERCREATIONSCREEN.NEWHOST_TITLE))
    self.headertext:SetRegionSize(800, 40)
    self.headertext:SetPosition(0, -25)
    self.headertext:SetVAlign(ANCHOR_TOP)
    self.headertext:SetColour(0,0,0,1)

    self.description = self:AddChild(Text(NEWFONT, 30, ""))
    self.description:SetRegionSize(510, 280)
    self.description:SetPosition(0, -400)
    self.description:SetColour(0,0,0,1)
    self.description:EnableWordWrap(true)
    self.description:SetHAlign(ANCHOR_MIDDLE)
    self.description:SetVAlign(ANCHOR_TOP)
end)

function NewHostPicker:SetCallback(cb)
    self.cb = cb
end

function NewHostPicker:SetSelected(intention)
    for i,v in ipairs(intention_options) do
        if intention == v.data then
            self.next_focus = self.buttons[i]
            break
        end
    end
end

function NewHostPicker:SetFocus(direction)
    if self.next_focus ~= nil then
        self.next_focus:SetFocus()
        self.next_focus = nil
        return
    end

    if direction == MOVE_LEFT then
        self.buttons[#self.buttons]:SetFocus()
    else
        self.buttons[1]:SetFocus()
    end
end

return NewHostPicker
