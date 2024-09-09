local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local TEMPLATES = require "widgets/redux/templates"

local function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local KitcoonNamePopup = Class(Screen, function(self, onNamed, onCancel )
	Screen._ctor(self, "KitcoonNamePopup")

	--darken everything behind the dialog
    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.black:SetTint(0,0,0,.75)

    self.root = self:AddChild(TEMPLATES.ScreenRoot())

	local spacing = 165
    local buttons = {}

	buttons[#buttons+1] =
		{text=STRINGS.UI.TRADESCREEN.KITCOON_GAME.OKAY, cb = function()
			self:OnNamed()
		end}

	buttons[#buttons+1] =
		{text=STRINGS.KITCOON_NAMING.MENU_RANDOM, cb = function()
			local r = GetRandomItem( STRINGS.KITCOON_NAMING.NAMES )
			self.textbox_root.textbox:SetString(r)
			
			self.dialog.actions.items[1]:Enable()
		end}

	buttons[#buttons+1] =
		{text=STRINGS.KITCOON_NAMING.MENU_CANCEL, cb = function()
            self:OnCancel()
        end}

	self.dialog = self.root:AddChild(TEMPLATES.CurlyWindow(480, 180, STRINGS.UI.TRADESCREEN.KITCOON_GAME.NAME_POPUP_TITLE, buttons, nil, STRINGS.UI.TRADESCREEN.KITCOON_GAME.NAME_POPUP_BODY))
	self.dialog.body:SetSize(20)
	self.dialog.body:SetPosition( 0, 65 )
	self.dialog.actions.items[1]:Disable()

	local box_size = 440
    local box_height = 40
	self.textbox_root = self.dialog:AddChild(TEMPLATES.StandardSingleLineTextEntry(" ", box_size, box_height))
    self.textbox_root.textbox:SetTextLengthLimit(50)
    self.textbox_root.textbox:SetForceEdit(true)
    self.textbox_root.textbox:EnableWordWrap(false)
    self.textbox_root.textbox:EnableScrollEditWindow(true)
    self.textbox_root.textbox:SetHelpTextEdit("")
	--self.textbox_root.textbox:SetHelpTextApply(STRINGS.UI.MODSSCREEN.SEARCH)
    --self.textbox_root.textbox:SetTextPrompt(STRINGS.UI.MODSSCREEN.SEARCH, UICOLOURS.GREY)
    --self.textbox_root.textbox.prompt:SetHAlign(ANCHOR_MIDDLE)
	self.textbox_root.textbox.OnTextInputted = function()
		local name = self.textbox_root.textbox:GetString()
		name = trim(name)
		if string.len( name ) == 0 then
			self.dialog.actions.items[1]:Disable()
		else
			self.dialog.actions.items[1]:Enable()
		end
    end
	self.textbox_root.textbox.OnTextEntered = function()
		local name = self.textbox_root.textbox:GetString()
		name = trim(name)
		if string.len( name ) ~= 0 then
			self:OnNamed()
		end
	end

	self.dialog:SetFocusChangeDir(MOVE_UP, self.textbox_root)
    self.textbox_root:SetFocusChangeDir(MOVE_DOWN, self.dialog.actions.items[2])

	self.default_focus = self.textbox_root.textbox

	self.onNamed = onNamed
	self.onCancel = onCancel
end)

function KitcoonNamePopup:OnBecomeActive()
    self._base.OnBecomeActive(self)

    self.textbox_root.textbox:SetFocus()
	if not TheInput:ControllerAttached() then 
		self.textbox_root.textbox:SetEditing(true)
    end
end

function KitcoonNamePopup:OnControl(control, down)
    if KitcoonNamePopup._base.OnControl(self,control, down) then
        return true
    end

    if control == CONTROL_CANCEL and not down then
        self:OnCancel()
    end
end

function KitcoonNamePopup:OnNamed()
	self:Disable()
	TheFrontEnd:PopScreen()
	
	local name = self.textbox_root.textbox:GetString()
	name = trim(name)
	self.onNamed(name)
end

function KitcoonNamePopup:OnCancel()
    self:Disable()
	TheFrontEnd:PopScreen()
	self.onCancel()
end

return KitcoonNamePopup
