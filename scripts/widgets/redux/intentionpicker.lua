local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"

local intention_options = {
    {text=STRINGS.UI.INTENTION.SOCIAL,      data=INTENTIONS.SOCIAL,      atlas="images/server_intentions.xml", image="social.tex"},
    {text=STRINGS.UI.INTENTION.COOPERATIVE, data=INTENTIONS.COOPERATIVE, atlas="images/server_intentions.xml", image="coop.tex"},
    {text=STRINGS.UI.INTENTION.COMPETITIVE, data=INTENTIONS.COMPETITIVE, atlas="images/server_intentions.xml", image="competitive.tex"},
    {text=STRINGS.UI.INTENTION.MADNESS,     data=INTENTIONS.MADNESS,     atlas="images/server_intentions.xml", image="madness.tex"},
}

local TILEWIDTH = 228 -- this is the width of the actual graphic
local tile_width = 170 -- our target width
local tile_scale = tile_width/TILEWIDTH
local tile_spacing = 10

local IntentionPicker = Class(Widget, function(self, titlestring, descriptionstrings, allowany)
    Widget._ctor(self, "IntentionPicker")

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

    for i, v in ipairs(intention_options) do
        self.buttons[i] = self:AddChild(ImageButton("images/ui.xml", "in-window_button_tile_idle.tex", "in-window_button_tile_hl.tex", "in-window_button_tile_disabled.tex", "in-window_button_tile_hl_noshadow.tex", "in-window_button_tile_disabled.tex", {tile_scale, tile_scale}, {0,0}))

        self.buttons[i]:SetImageNormalColour(UICOLOURS.GOLD_SELECTED)
        self.buttons[i]:SetImageFocusColour(UICOLOURS.GOLD_SELECTED)
        self.buttons[i]:SetImageDisabledColour(UICOLOURS.GOLD_SELECTED)
        self.buttons[i]:SetImageSelectedColour(UICOLOURS.GOLD_SELECTED)

        self.buttons[i].bigicon = self.buttons[i]:AddChild(Image(intention_options[i].atlas, intention_options[i].image))
        self.buttons[i].bigicon:SetScale(0.45)
        self.buttons[i].bigicon:SetPosition(0,-10)

        self.buttons[i]:SetText(intention_options[i].text)
        self.buttons[i]:SetFont(BUTTONFONT)
        self.buttons[i].text:SetPosition(0,50)
        self.buttons[i].text:MoveToFront()

        self.buttons[i]:SetOnGainFocus(function()
            self.description:SetString(descriptionstrings[string.upper(v.data)])
        end)
        self.buttons[i]:SetOnLoseFocus(CheckClearDescription)
        self.buttons[i]:SetOnClick(function()
            if self.cb ~= nil then
                self.cb(intention_options[i].data)
            end
        end)

        local pos_index = i-1 - (#intention_options-1)/2
        self.buttons[i]:SetPosition(pos_index * tile_width + pos_index * tile_spacing, -145)
    end

    for i,v in ipairs(self.buttons) do
        if i > 1 then
            v:SetFocusChangeDir(MOVE_LEFT, self.buttons[i-1])
        end
        if i < #self.buttons then
            v:SetFocusChangeDir(MOVE_RIGHT, self.buttons[i+1])
        end
    end

    self.headertext = self:AddChild(Text(HEADERFONT, 40, titlestring))
    self.headertext:SetRegionSize(800, 40)
    self.headertext:SetPosition(0, -25)
    self.headertext:SetVAlign(ANCHOR_TOP)
    self.headertext:SetColour(UICOLOURS.GOLD_SELECTED)

    self.description = self:AddChild(Text(CHATFONT, 30, ""))
    self.description:SetRegionSize(500, 280)
    self.description:SetPosition(0, -380)
    self.description:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
    self.description:EnableWordWrap(true)
    self.description:SetHAlign(ANCHOR_MIDDLE)
    self.description:SetVAlign(ANCHOR_TOP)

    if allowany then
        self.anybutton = self:AddChild(ImageButton("images/ui.xml", "in-window_button_idle.tex", "in-window_button_hl.tex", "in-window_button_disabled.tex", "in-window_button_hl_noshadow.tex", "in-window_button_disabled.tex", {1, 1}, {0,0}))
        self.anybutton:SetPosition(0, -385)
        self.anybutton:SetText(STRINGS.UI.INTENTION.ANY)
        self.anybutton:SetFont(BUTTONFONT)
        self.anybutton:SetOnGainFocus(function()
            self.description:SetString(descriptionstrings.ANY)
        end)
        self.anybutton:SetOnClick(function()
            if self.cb then
                self.cb(INTENTIONS.ANY)
            end
        end)

        for i,v in ipairs(self.buttons) do
            v:SetFocusChangeDir(MOVE_DOWN, self.anybutton)
        end
        self.anybutton:SetFocusChangeDir(MOVE_UP, self.buttons[2])
    end

end)

function IntentionPicker:SetCallback(cb)
    self.cb = cb
end

function IntentionPicker:SetSelected(intention)
    for i,v in ipairs(intention_options) do
        if intention == v.data then
            self.next_focus = self.buttons[i]
            break
        end
    end
end

function IntentionPicker:SetFocus(direction)
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

return IntentionPicker
