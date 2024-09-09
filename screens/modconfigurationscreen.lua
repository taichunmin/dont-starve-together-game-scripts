require "util"
require "strings"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Spinner = require "widgets/spinner"
local NumericSpinner = require "widgets/numericspinner"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/templates"

local PopupDialogScreen = require "screens/popupdialog"

local ScrollableList = require "widgets/scrollablelist"

local text_font = UIFONT

local enableDisableOptions = { { text = STRINGS.UI.OPTIONS.DISABLED, data = false }, { text = STRINGS.UI.OPTIONS.ENABLED, data = true } }
local spinnerFont = { font = BUTTONFONT, size = 30 }

local COLS = 2
local ROWS_PER_COL = 7

local ModConfigurationScreen = Class(Screen, function(self, modname, client_config)
	Screen._ctor(self, "ModConfigurationScreen")
	self.modname = modname
	self.config = KnownModIndex:LoadModConfigurationOptions(modname, client_config)

	self.client_config = client_config

	self.options = {}

	if self.config and type(self.config) == "table" then
		for i,v in ipairs(self.config) do
			-- Only show the option if it matches our format exactly
			if v.name and v.options and (v.saved ~= nil or v.default ~= nil) then
				local _value = v.saved
				if _value == nil then _value = v.default end
				table.insert(self.options, {name = v.name, label = v.label, options = v.options, default = v.default, value = _value, hover = v.hover})
			end
		end
	end

	self.started_default = self:IsDefaultSettings()

    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.black:SetTint(0,0,0,.75)

    self.root = self:AddChild(Widget("ROOT"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetPosition(0,0,0)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.shield = self.root:AddChild(TEMPLATES.CurlyWindow(40, 365, 1, 1, 67, -41))
    self.shield.fill = self.root:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tall.tex"))
	self.shield.fill:SetScale(.64, -.57)
	self.shield.fill:SetPosition(8, 12)
    self.shield:SetPosition(0,0,0)

    local title_max_w = 420
    local title_max_chars = 70
    local title = self.root:AddChild(Text(BUTTONFONT, 45, " "..STRINGS.UI.MODSSCREEN.CONFIGSCREENTITLESUFFIX))
    local title_suffix_w = title:GetRegionSize()
    title:SetPosition(10, 190)
    title:SetColour(0, 0, 0, 1)
    if title_suffix_w < title_max_w then
        title:SetTruncatedString(KnownModIndex:GetModFancyName(modname), title_max_w - title_suffix_w, title_max_chars - 1 - STRINGS.UI.MODSSCREEN.CONFIGSCREENTITLESUFFIX:len(), true)
        title:SetString(title:GetString().." "..STRINGS.UI.MODSSCREEN.CONFIGSCREENTITLESUFFIX)
    else
        title:SetTruncatedString(STRINGS.UI.MODSSCREEN.CONFIGSCREENTITLESUFFIX, title_max_w, title_max_chars, true)
    end

	self.option_offset = 0
    self.optionspanel = self.root:AddChild(Widget("optionspanel"))
    self.optionspanel:SetPosition(0,-20)

	self.dirty = false

	self.options_scroll_list = self.optionspanel:AddChild(ScrollableList({}, 450, 350, 40, 10))

    self.optionwidgets = {}

	local i = 1
	local label_width = 225
	while i <= #self.options do
		if self.options[i] then
			local spin_options = {} --{{text="default"..tostring(idx), data="default"},{text="2", data="2"}, }
			local spin_options_hover = {}
			local idx = i
			for _,v in ipairs(self.options[idx].options) do
				table.insert(spin_options, {text=v.description, data=v.data})
				spin_options_hover[v.data] = v.hover
			end

			local opt = Widget("option"..idx)

			local spinner_height = 40
			local spinner_width = 170
			opt.spinner = opt:AddChild(Spinner( spin_options, spinner_width, nil, {font=NEWFONT, size=25}, nil, nil, nil, true, 100, nil))
			opt.spinner:SetTextColour(0,0,0,1)
			local default_value = self.options[idx].value
			if default_value == nil then default_value = self.options[idx].default end

			opt.spinner.OnChanged =
				function( _, data )
					self.options[idx].value = data
					opt.spinner:SetHoverText( spin_options_hover[data] or "" )
					self:MakeDirty()
				end
			opt.spinner:SetSelected(default_value)
			opt.spinner:SetHoverText( spin_options_hover[default_value] or "" )
			opt.spinner:SetPosition( 325, 0, 0 )

			local label = opt.spinner:AddChild( Text( NEWFONT, 25, (self.options[idx].label or self.options[idx].name) .. ":" or STRINGS.UI.MODSSCREEN.UNKNOWN_MOD_CONFIG_SETTING..":" ) )
			label:SetColour( 0, 0, 0, 1 )
			label:SetPosition( -label_width/2 - 90, 0, 0 )
			label:SetRegionSize( label_width, 50 )
			label:SetHAlign( ANCHOR_RIGHT )
			label:SetHoverText( self.options[idx].hover or "" )
			if TheInput:ControllerAttached() then
				opt:SetHoverText( self.options[idx].hover or "" )
			end

			opt.spinner.OnGainFocus = function()
  				Spinner._base.OnGainFocus(self)
				opt.spinner:UpdateBG()
  			end
			opt.focus_forward = opt.spinner

			opt.id = idx

			table.insert(self.optionwidgets, opt)
			i = i + 1
		end
	end

	if not TheInput:ControllerAttached() then
		self.menu = self.root:AddChild(Menu(nil, 0, true))
		self.resetbutton = self.menu:AddItem(STRINGS.UI.MODSSCREEN.RESETDEFAULT, function() self:ResetToDefaultValues() end,  Vector3(5, -230, 0))
		self.applybutton = self.menu:AddItem(STRINGS.UI.MODSSCREEN.APPLY, function() self:Apply() end, Vector3(165, -230, 0), "large")
		self.cancelbutton = self.menu:AddItem(STRINGS.UI.MODSSCREEN.BACK, function() self:Cancel() end,  Vector3(-155, -230, 0))
		self.applybutton:SetScale(.7)
		self.cancelbutton:SetScale(.7)
		self.resetbutton:SetScale(.7)
		self.menu:SetPosition(5,0)
	end

	self.default_focus = self.optionwidgets[1]
	self:HookupFocusMoves()

	self.options_scroll_list:SetList(self.optionwidgets)
	if self.options_scroll_list.scroll_bar_line:IsVisible() then
		self.options_scroll_list:SetPosition(0, 0)
	else
		self.options_scroll_list:SetPosition(-20, 0)
	end
end)

function ModConfigurationScreen:CollectSettings()
	local settings = nil
	for i,v in pairs(self.options) do
		if not settings then settings = {} end
		table.insert(settings, {name=v.name, label = v.label, options=v.options, default=v.default, saved=v.value})
	end
	return settings
end

function ModConfigurationScreen:ResetToDefaultValues()
	local function reset()
		for i,v in pairs(self.optionwidgets) do
			if v.id then
				self.options[v.id].value = self.options[v.id].default
				v.spinner:SetSelected(self.options[v.id].value)
				v.spinner:Changed()
			end
		end
	end

	if not self:IsDefaultSettings() then
		self:ConfirmRevert(function()
			TheFrontEnd:PopScreen()
			self:MakeDirty()
			reset()
		end)
	end
end

function ModConfigurationScreen:Apply()
	if self:IsDirty() then
		local settings = self:CollectSettings()
		KnownModIndex:SaveConfigurationOptions(function()
			self:MakeDirty(false)
		    TheFrontEnd:PopScreen()
		end, self.modname, settings, self.client_config)
	else
		self:MakeDirty(false)
	    TheFrontEnd:PopScreen()
	end
end

function ModConfigurationScreen:ConfirmRevert(callback)
	TheFrontEnd:PushScreen(
		PopupDialogScreen( STRINGS.UI.MODSSCREEN.BACKTITLE, STRINGS.UI.MODSSCREEN.BACKBODY,
		  {
		  	{
		  		text = STRINGS.UI.MODSSCREEN.YES,
		  		cb = callback or function() TheFrontEnd:PopScreen() end
			},
			{
				text = STRINGS.UI.MODSSCREEN.NO,
				cb = function()
					TheFrontEnd:PopScreen()
				end
			}
		  }
		)
	)
end

function ModConfigurationScreen:Cancel()
	if self:IsDirty() and not (self.started_default and self:IsDefaultSettings()) then
		self:ConfirmRevert(function()
			self:MakeDirty(false)
			TheFrontEnd:PopScreen()
		    TheFrontEnd:PopScreen()
		end)
	else
		self:MakeDirty(false)
	    TheFrontEnd:PopScreen()
	end
end

function ModConfigurationScreen:MakeDirty(dirty)
	if dirty ~= nil then
		self.dirty = dirty
	else
		self.dirty = true
	end
end

function ModConfigurationScreen:IsDefaultSettings()
	local alldefault = true
	for i,v in pairs(self.options) do
		-- print(options[i].value, options[i].default)
		if self.options[i].value ~= self.options[i].default then
			alldefault = false
			break
		end
	end
	return alldefault
end

function ModConfigurationScreen:IsDirty()
	return self.dirty
end

function ModConfigurationScreen:OnControl(control, down)
    if ModConfigurationScreen._base.OnControl(self, control, down) then return true end

    if not down then
	    if control == CONTROL_CANCEL then
			self:Cancel()
	    elseif control == CONTROL_MENU_START and TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
	    	self:Apply() --apply changes and go back, or stay
    	elseif control == CONTROL_MENU_BACK and TheInput:ControllerAttached() then
			self:ResetToDefaultValues()
			return true
		else
    		return false
    	end

    	return true
	end
end

function ModConfigurationScreen:HookupFocusMoves()

end

function ModConfigurationScreen:GetHelpText()
	local t = {}
	local controller_id = TheInput:GetControllerID()

	table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
	table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_BACK) .. " " .. STRINGS.UI.MODSSCREEN.RESETDEFAULT)
	if self:IsDirty() then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_START) .. " " .. STRINGS.UI.HELP.APPLY)
	end

	return table.concat(t, "  ")
end

return ModConfigurationScreen
