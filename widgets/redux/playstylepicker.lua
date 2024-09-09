local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"

local Levels = require("map/levels")


local TILEWIDTH = 228 -- this is the width of the actual graphic
local tile_width = 170 -- our target width
local tile_scale = tile_width/TILEWIDTH
local tile_spacing = 10

local PlaystylePicker = Class(Widget, function(self, titlestring, any_desc)
    Widget._ctor(self, "PlaystylePicker")

	self.buttons = {}

    local function CheckClearDescription()
		-- Why on earth do we call gain focus on the new widget before lose focus on the old widget?!?
        for i, v in ipairs(self.buttons) do
            if v.focus then
                return
            end
        end
        --None of the buttons has focus
        self.description:SetString("")
    end

	self.button_root = self:AddChild(Widget("button_root"))
	self.button_root:SetPosition(0, -145)
	self.button_root:SetScale(0.9)

	local playstyles = Levels.GetPlaystyles()
	for i, playstyle_id in ipairs(playstyles) do
		local playstyle_def = Levels.GetPlaystyleDef(playstyle_id)

        self.buttons[i] = self.button_root:AddChild(ImageButton("images/serverplaystyles.xml", "frame.tex", "frame_hl.tex", "frame_hl.tex", "frame_hl.tex", "frame_hl.tex", {tile_scale, tile_scale}, {0,0}))

        self.buttons[i]:SetImageNormalColour(UICOLOURS.GOLD_SELECTED)
        self.buttons[i]:SetImageFocusColour(UICOLOURS.GOLD_SELECTED)
        self.buttons[i]:SetImageDisabledColour(UICOLOURS.GOLD_SELECTED)
        self.buttons[i]:SetImageSelectedColour(UICOLOURS.GOLD_SELECTED)

		self.buttons[i].bigicon = self.buttons[i]:AddChild(Image(playstyle_def.image.atlas, playstyle_def.image.icon))
		self.buttons[i].bigicon:SetScale(0.46)
		self.buttons[i].bigicon:MoveToBack()

		self.buttons[i]:SetText(playstyle_def.name)
		self.buttons[i]:SetFont(CHATFONT)
		self.buttons[i]:SetTextFocusColour(UICOLOURS.GOLD_FOCUS)
		self.buttons[i]:SetTextSelectedColour(UICOLOURS.GOLD_FOCUS)
		self.buttons[i]:SetTextColour(UICOLOURS.GOLD_SELECTED)
		self.buttons[i].text:SetPosition(0, 96)
		self.buttons[i].text:SetSize(28)
		self.buttons[i].text:MoveToFront()

        self.buttons[i]:SetOnGainFocus(function()
            self.description:SetString(playstyle_def.desc)
        end)
        self.buttons[i]:SetOnLoseFocus(CheckClearDescription)
        self.buttons[i]:SetOnClick(function()
            if self.cb ~= nil then
                self.cb(playstyle_id)
            end
        end)

        local pos_index = i-1 - (#playstyles-1)/2
        self.buttons[i]:SetPosition(pos_index * tile_width + pos_index * tile_spacing, 0)
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
    self.headertext:SetPosition(0, 25)
    self.headertext:SetVAlign(ANCHOR_TOP)
    self.headertext:SetColour(UICOLOURS.GOLD_SELECTED)

    self.description = self:AddChild(Text(CHATFONT, 26, ""))
    self.description:SetRegionSize(800, 280)
    self.description:SetPosition(0, -380)
    self.description:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
    self.description:EnableWordWrap(true)
    self.description:SetHAlign(ANCHOR_MIDDLE)
    self.description:SetVAlign(ANCHOR_TOP)

    if any_desc then
        self.anybutton = self:AddChild(ImageButton("images/ui.xml", "in-window_button_idle.tex", "in-window_button_hl.tex", "in-window_button_disabled.tex", "in-window_button_hl_noshadow.tex", "in-window_button_disabled.tex", {1, 1}, {0,0}))
        self.anybutton:SetPosition(0, -385)
        self.anybutton:SetText(STRINGS.UI.PLAYSTYLE_ANY)
        self.anybutton:SetFont(BUTTONFONT)
        self.anybutton:SetOnGainFocus(function()
            self.description:SetString(any_desc)
        end)
        self.anybutton:SetOnClick(function()
            if self.cb then
                self.cb(PLAYSTYLE_ANY)
            end
        end)

        for i,v in ipairs(self.buttons) do
            v:SetFocusChangeDir(MOVE_DOWN, self.anybutton)
        end
        self.anybutton:SetFocusChangeDir(MOVE_UP, self.buttons[2])
    end

end)

function PlaystylePicker:SetCallback(cb)
    self.cb = cb
end

function PlaystylePicker:SetSelected(playstyle)
    for i,v in ipairs(Levels.GetPlaystyles()) do
        if playstyle == v.data then
            self.next_focus = self.buttons[i]
            break
        end
    end
end

function PlaystylePicker:SetFocus(direction)
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

return PlaystylePicker
