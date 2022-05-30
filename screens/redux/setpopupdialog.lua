local Screen = require "widgets/screen"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"

local SKIN_SET_ITEMS = require("skin_set_info")

local MAX_ITEMS = 5
local LINE_HEIGHT = 44
local TEXT_WIDTH = 300
local TEXT_OFFSET = 40
local FONT = BUTTONFONT
local FONT_SIZE = 32
local ITEM_SCALE = 0.6
local IMAGE_X = -55
local OWNED_COLOUR = UICOLOURS.WHITE
local NEED_COLOUR = UICOLOURS.GREY

local SetPopupDialog = Class(Screen, function(self, set_item_type)
	Screen._ctor(self, "SetPopupDialog")

	self.set_item_type = set_item_type

	--darken everything behind the dialog
    self.black = self:AddChild(TEMPLATES.BackgroundTint())

	self.proot = self:AddChild(TEMPLATES.ScreenRoot("ROOT"))

    self.buttons =
    {
        {text=STRINGS.UI.SETPOPUP.OK, cb = function() self:Close() end },
    }

    local width = 400
    self.dialog = self.proot:AddChild(TEMPLATES.CurlyWindow(width, 450, STRINGS.SET_NAMES[self.set_item_type], self.buttons))

    self.content_root = self.proot:AddChild(Widget("content_root"))
    self.content_root:SetPosition(0,40)

	--info
    self.info_txt = self.content_root:AddChild(Text(CHATFONT, 26, nil, UICOLOURS.WHITE))
    self.info_txt:SetPosition(0, 150)
    self.info_txt:SetRegionSize(width, 85)
    self.info_txt:SetHAlign(ANCHOR_MIDDLE)
    self.info_txt:SetVAlign(ANCHOR_MIDDLE)
    self.info_txt:EnableWordWrap(true)
	self.info_txt:SetString( STRINGS.SET_DESCRIPTIONS[self.set_item_type] )

    self.horizontal_line = self.content_root:AddChild(Image("images/ui.xml", "line_horizontal_6.tex"))
	self.horizontal_line:SetScale( 1, 0.55)
	self.horizontal_line:SetPosition( 5, 96, 0)


	self.num_sets = #SKIN_SET_ITEMS[self.set_item_type]
	if self.num_sets > 1 then
		local set_data = {}
		for i = 1,self.num_sets do
			set_data[i] = {
				text = "",
				data = {set=i},
			}
		end

		local setselector = TEMPLATES.StandardSpinner(set_data, 350)
		setselector:SetOnChangedFn(function(selected_data, old)
			self.current_set = selected_data.set
			self:RefreshDisplay()
		end)

		self.set_selector = self.content_root:AddChild(setselector)
		self.set_selector:SetPosition(0, 60)
	end

	local item_y = 58
	self.max_num_items = 0
	for _,item_set in pairs(SKIN_SET_ITEMS[self.set_item_type]) do
		self.max_num_items = math.max( self.max_num_items, #item_set)
	end
	local steps = MAX_ITEMS - self.max_num_items
	item_y = item_y - (steps * LINE_HEIGHT/2)

	self.input_item_imagetext = {}

	for i = 1,self.max_num_items do
		self.input_item_imagetext[i] = self.content_root:AddChild(TEMPLATES.old.ItemImageText("body", "body_default1", ITEM_SCALE, FONT, FONT_SIZE, "", NEED_COLOUR, TEXT_WIDTH, TEXT_OFFSET))
        self.input_item_imagetext[i]:SetPosition(IMAGE_X, item_y)
		self.input_item_imagetext[i].check:SetPosition(-61, 0)
		self.input_item_imagetext[i].check:SetScale(.15)
    	item_y = item_y - LINE_HEIGHT
    end
    self.current_set = 1
    self:RefreshDisplay()

    self.reward_horizontal_line = self.content_root:AddChild(Image("images/ui.xml", "line_horizontal_6.tex"))
	self.reward_horizontal_line:SetScale( 1, 0.55)
	self.reward_horizontal_line:SetPosition( 5, -155, 0)


	local color = NEED_COLOUR
	if TheInventory:CheckOwnership(self.set_item_type) then
		color = OWNED_COLOUR
	end
	self.reward = self.content_root:AddChild(TEMPLATES.old.ItemImageText("body", "body_default1", ITEM_SCALE, FONT, FONT_SIZE, "", color, TEXT_WIDTH, TEXT_OFFSET))
	self.reward:SetPosition(IMAGE_X, -193, 0)
	self.reward.text:SetString(GetSkinName(self.set_item_type))

	self.reward_txt = self.content_root:AddChild(Text(BUTTONFONT, 30))
	self.reward_txt:SetHAlign(ANCHOR_RIGHT)
	self.reward_txt:SetRegionSize(200, 100)
	self.reward_txt:SetPosition(-183, -195, 0)

    self.reward_txt:SetColour(color)
	self.reward_txt:SetString(STRINGS.UI.SETPOPUP.REWARD)

	local reward_type = GetTypeForItem(self.set_item_type)
	self.reward.icon:SetItem(reward_type, self.set_item_type, nil, nil)
	self.reward.icon:SetItemRarity(GetRarityForItem(self.set_item_type))


	self.default_focus = self.dialog
end)

function SetPopupDialog:RefreshDisplay()
	for i = 1,self.max_num_items do
		self.input_item_imagetext[i]:Hide()
	end
	local i = 1
	for _,input_item_type in pairs(SKIN_SET_ITEMS[self.set_item_type][self.current_set]) do
		self.input_item_imagetext[i]:Show()

		if TheInventory:CheckOwnership(input_item_type) then
			self.input_item_imagetext[i].text:SetColour(OWNED_COLOUR)
    		self.input_item_imagetext[i].check:Show()
		else
			self.input_item_imagetext[i].text:SetColour(NEED_COLOUR)
    		self.input_item_imagetext[i].check:Hide()
		end

		self.input_item_imagetext[i].text:SetString(GetSkinName(input_item_type))

		local type = GetTypeForItem(input_item_type)
		self.input_item_imagetext[i].icon:SetItem(type, input_item_type, nil, nil)
		self.input_item_imagetext[i].icon:SetItemRarity(GetRarityForItem(input_item_type))

    	i = i + 1
    end
end

function SetPopupDialog:OnControl(control, down)
    if SetPopupDialog._base.OnControl(self,control, down) then return true end

    if control == CONTROL_CANCEL and not down then
        self.buttons[#self.buttons].cb()
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        return true
    end
    if self.set_selector then
        if control == CONTROL_SCROLLBACK and not down then
            self.set_selector:Prev()
        elseif control == CONTROL_SCROLLFWD and not down then
            self.set_selector:Next()
        end
    end
end

function SetPopupDialog:Close()
	TheFrontEnd:PopScreen(self)
end

function SetPopupDialog:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	local t = {}

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
    if self.num_sets > 1 then
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_SCROLLBACK) .. " " .. STRINGS.UI.SETPOPUP.PREV_SET)
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_SCROLLFWD) .. " " .. STRINGS.UI.SETPOPUP.NEXT_SET)
    end
	return table.concat(t, "  ")
end

return SetPopupDialog
