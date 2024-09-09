local Screen = require "widgets/screen"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/templates"



local SetPopupDialog = Class(Screen, function(self, set_item_type)
	Screen._ctor(self, "SetPopupDialog")

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
    self.bg = self.proot:AddChild(TEMPLATES.CurlyWindow(0, 400, 1, 1, 62, -40, 10))
    self.bg.fill = self.proot:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tall.tex"))
    self.bg.fill:SetScale(.59, 0.63)
    self.bg.fill:SetPosition(8, 14)

	--title
    self.title = self.proot:AddChild(Text(BUTTONFONT, 44))
    self.title:SetPosition(8, 220, 0)
    self.title:SetColour(0,0,0,1)
	self.title:SetString( STRINGS.SET_NAMES[set_item_type] )

	--info
    self.info_txt = self.proot:AddChild(Text(BUTTONFONT, 26))
    self.info_txt:SetPosition(8, 150, 0)
    self.info_txt:SetRegionSize( 400, 185 )
    self.info_txt:SetColour(0,0,0,1)
    self.info_txt:SetHAlign(ANCHOR_MIDDLE)
    self.info_txt:SetVAlign(ANCHOR_MIDDLE)
    self.info_txt:EnableWordWrap(true)
	self.info_txt:SetString( STRINGS.SET_DESCRIPTIONS[set_item_type] )

    self.horizontal_line = self.proot:AddChild(Image("images/ui.xml", "line_horizontal_6.tex"))
	self.horizontal_line:SetScale( 1, 0.55)
	self.horizontal_line:SetPosition( 5, 96, 0)


	local LINE_HEIGHT = 44
	local TEXT_WIDTH = 300
	local TEXT_OFFSET = 40
	local FONT = BUTTONFONT
	local FONT_SIZE = 32
	local ITEM_SCALE = 0.6
	local IMAGE_X = -55

	--local temp = Text(FONT, FONTSIZE, "")
	--local maxwidth = 0

	local SKIN_SET_ITEMS = require("skin_set_info")
	local i = 1

	local item_y = 58
	local NUM_ITEMS = #(SKIN_SET_ITEMS[set_item_type][1])
	local steps = 5 - NUM_ITEMS
	item_y = item_y - (steps * LINE_HEIGHT/2)

	self.input_item_imagetext = {}
	for _,input_item_type in pairs(SKIN_SET_ITEMS[set_item_type][1]) do
    	local type = GetTypeForItem(input_item_type)

		local color = GREY
		local show_check = false
		if TheInventory:CheckOwnership(input_item_type) then
			color = {0, 0, 0, 1}
			show_check = true
		end

		self.input_item_imagetext[i] = self.proot:AddChild(TEMPLATES.ItemImageText("body", "body_default1", ITEM_SCALE, FONT, FONT_SIZE, "", color, TEXT_WIDTH, TEXT_OFFSET))
    	self.input_item_imagetext[i]:SetPosition( IMAGE_X, item_y, 0)

    	if show_check then
    		self.input_item_imagetext[i].check:SetPosition(-61, 0)
    		self.input_item_imagetext[i].check:SetScale(.15)
    		self.input_item_imagetext[i].check:Show()
    	end

		self.input_item_imagetext[i].text:SetString(GetSkinName(input_item_type))

		self.input_item_imagetext[i].icon:SetItem(type, input_item_type, nil, nil)
		self.input_item_imagetext[i].icon:SetItemRarity(GetRarityForItem(input_item_type))

    	i = i + 1
    	item_y = item_y - LINE_HEIGHT
    end

    self.reward_horizontal_line = self.proot:AddChild(Image("images/ui.xml", "line_horizontal_6.tex"))
	self.reward_horizontal_line:SetScale( 1, 0.55)
	self.reward_horizontal_line:SetPosition( 5, -155, 0)


	local color = GREY
	if TheInventory:CheckOwnership(set_item_type) then
		color = {0, 0, 0, 1}
	end
	self.reward = self.proot:AddChild(TEMPLATES.ItemImageText("body", "body_default1", ITEM_SCALE, FONT, FONT_SIZE, "", color, TEXT_WIDTH, TEXT_OFFSET))
	self.reward:SetPosition(IMAGE_X, -193, 0)
	self.reward.text:SetString(GetSkinName(set_item_type))

	self.reward_txt = self.proot:AddChild(Text(BUTTONFONT, 30))
	self.reward_txt:SetHAlign(ANCHOR_RIGHT)
	self.reward_txt:SetRegionSize(200, 100)
	self.reward_txt:SetPosition(-183, -195, 0)

	if TheInventory:CheckOwnership(set_item_type) then
		self.reward_txt:SetColour(0,0,0,1)
	else
		self.reward_txt:SetColour(GREY)
	end
	self.reward_txt:SetString(STRINGS.UI.SETPOPUP.REWARD)

	local reward_type = GetTypeForItem(set_item_type)
	self.reward.icon:SetItem(reward_type, set_item_type, nil, nil)
	self.reward.icon:SetItemRarity(GetRarityForItem(set_item_type))


    local buttons =
    {
        {text=STRINGS.UI.SETPOPUP.OK, cb = function() self:Close() end },
    }

	self.menu = self.proot:AddChild(Menu(buttons, 200, true))
	self.menu:SetPosition(10, -253, 0)
    for i,v in pairs(self.menu.items) do
        v:SetScale(.7)
    end
	self.buttons = buttons
	self.default_focus = self.menu
end)

function SetPopupDialog:OnBecomeActive()
    self._base.OnBecomeActive(self)
end



function SetPopupDialog:OnControl(control, down)
    if SetPopupDialog._base.OnControl(self,control, down) then return true end

    if control == CONTROL_CANCEL and not down then
        if #self.buttons > 1 and self.buttons[#self.buttons] then
            self.buttons[#self.buttons].cb()
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
            return true
        end
    end
end

function SetPopupDialog:Close()
	TheFrontEnd:PopScreen(self)
end

function SetPopupDialog:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	local t = {}
	if #self.buttons > 1 and self.buttons[#self.buttons] then
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
    end
	return table.concat(t, "  ")
end

return SetPopupDialog
