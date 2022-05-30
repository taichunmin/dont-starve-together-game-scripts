require "util"
require "strings"
local Image = require "widgets/image"
local Screen = require "widgets/screen"
local Text = require "widgets/text"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"
local PopupDialogScreen = require "screens/redux/popupdialog"

local ModConfigurationScreen = Class(Screen, function(self, modname, client_config)
	Screen._ctor(self, "ModConfigurationScreen")
	self.modname = modname
	self.config = KnownModIndex:LoadModConfigurationOptions(modname, client_config)

	self.client_config = client_config

    self.options = {}

    local is_client_only = KnownModIndex:GetModInfo(modname) and KnownModIndex:GetModInfo(modname).client_only_mod

	if self.config and type(self.config) == "table" then
		for i,v in ipairs(self.config) do
			-- Only show the option if it matches our format exactly
            if v.name and v.options and (v.saved ~= nil or v.default ~= nil) then
                if is_client_only or not v.client or self.client_config then
                    local _value = v.saved
                    if _value == nil then _value = v.default end
                    table.insert(self.options, {name = v.name, label = v.label, options = v.options, default = v.default, value = _value, hover = v.hover})
                end
			end
		end
	end

	self.started_default = self:IsDefaultSettings()

    self.black = self:AddChild(TEMPLATES.BackgroundTint())
    self.root = self:AddChild(TEMPLATES.ScreenRoot())

	local label_width = 300
    local spinner_width = 225
    local item_width, item_height = label_width + spinner_width + 30, 40

    local buttons = {
        { text = STRINGS.UI.MODSSCREEN.APPLY,        cb = function() self:Apply() end,                },
        { text = STRINGS.UI.MODSSCREEN.RESETDEFAULT, cb = function() self:ResetToDefaultValues() end, },
        { text = STRINGS.UI.MODSSCREEN.BACK,         cb = function() self:Cancel() end,               },
    }

    self.dialog = self.root:AddChild(TEMPLATES.RectangleWindow(item_width + 20, 580, nil, buttons))

    self.option_header = self.dialog:AddChild(Widget("option_header"))
    self.option_header:SetPosition(0, 270)

    local title_max_w = 420
    local title_max_chars = 70
    local title = self.option_header:AddChild(Text(HEADERFONT, 28, " "..STRINGS.UI.MODSSCREEN.CONFIGSCREENTITLESUFFIX))
    local title_suffix_w = title:GetRegionSize()
    title:SetColour(UICOLOURS.GOLD_SELECTED)
    if title_suffix_w < title_max_w then
        title:SetTruncatedString(KnownModIndex:GetModFancyName(modname), title_max_w - title_suffix_w, title_max_chars - 1 - STRINGS.UI.MODSSCREEN.CONFIGSCREENTITLESUFFIX:len(), true)
        title:SetString(title:GetString().." "..STRINGS.UI.MODSSCREEN.CONFIGSCREENTITLESUFFIX)
    else
        -- translation was so long we can't fit any more text
        title:SetTruncatedString(STRINGS.UI.MODSSCREEN.CONFIGSCREENTITLESUFFIX, title_max_w, title_max_chars, true)
    end

    self.option_description = self.option_header:AddChild(Text(CHATFONT, 22))
    self.option_description:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
    self.option_description:SetPosition(0,-48)
    self.option_description:SetRegionSize(item_width+30, 50)
    self.option_description:SetVAlign(ANCHOR_TOP) -- stop text from jumping around as we scroll
    self.option_description:EnableWordWrap(true)

    self.value_description = self.option_header:AddChild(Text(CHATFONT, 22))
    self.value_description:SetColour(UICOLOURS.GOLD)
    self.value_description:SetPosition(0,-85)
    self.value_description:SetRegionSize(item_width+30, 25)

    self.optionspanel = self.dialog:InsertWidget(Widget("optionspanel"))
    self.optionspanel:SetPosition(0,-60)

	self.dirty = false

    self.optionwidgets = {}

    local function ScrollWidgetsCtor(context, idx)
        local widget = Widget("option"..idx)
        widget.bg = widget:AddChild(TEMPLATES.ListItemBackground(item_width, item_height))
        widget.opt = widget:AddChild(TEMPLATES.LabelSpinner("", {}, label_width, spinner_width, item_height))

        widget.opt.spinner:EnablePendingModificationBackground()

        widget.ApplyDescription = function(_)
            local option = widget.opt.data and widget.opt.data.option.hover or ""
            local value = widget.opt.data and widget.opt.data.spin_options_hover[widget.opt.data.selected_value] or ""
            self.option_description:SetString(option)
            self.value_description:SetString(value)
        end

        widget:SetOnGainFocus(function(_)
            self.options_scroll_list:OnWidgetFocus(widget)
            widget:ApplyDescription()
        end)

        widget.real_index = idx
        widget.opt.spinner.OnChanged =
            function( _, data )
                self.options[widget.real_index].value = data
                widget.opt.data.selected_value = data
                widget.opt.spinner:SetHasModification(widget.opt.data.selected_value ~= widget.opt.data.initial_value)
                widget:ApplyDescription()
                self:MakeDirty()
            end

        widget.focus_forward = widget.opt

        return widget
	end
    local function ApplyDataToWidget(context, widget, data, idx)
        widget.opt.data = data
		if data then
            widget.real_index = idx

            widget.opt:Show()
			widget.opt.spinner:SetOptions(data.spin_options)

            if data.is_header then
                widget.bg:Hide()
                widget.opt.spinner:Hide()
                widget.opt.label:SetSize(30)
            else
                widget.bg:Show()
                widget.opt.spinner:Show()
                widget.opt.label:SetSize(25) -- same as LabelSpinner's default.
            end

			widget.opt.spinner:SetSelected(data.selected_value)

            local label = (data.option.label or data.option.name or STRINGS.UI.MODSSCREEN.UNKNOWN_MOD_CONFIG_SETTING)
            if not data.is_header then
                label =  label .. ":"
            end
			widget.opt.label:SetString(label)

            widget.opt.spinner:SetHasModification(widget.opt.data.selected_value ~= widget.opt.data.initial_value)

            if widget.focus then
                widget:ApplyDescription()
            end
        else
            widget.opt:Hide()
            widget.bg:Hide()
		end
	end

    for idx,option_item in ipairs(self.options) do
        local spin_options = {} --{{text="default"..tostring(idx), data="default"},{text="2", data="2"}, }
        local spin_options_hover = {}
        for _,v in ipairs(option_item.options) do
            table.insert(spin_options, {text=v.description, data=v.data})
            spin_options_hover[v.data] = v.hover
        end
        local initial_value = option_item.value
        if initial_value == nil then
            initial_value = option_item.default
        end
        local data = {
            is_header = #spin_options == 1 and spin_options[1].text:len() == 0,
            option = option_item,
            initial_value = initial_value,
            selected_value = initial_value,
            spin_options = spin_options,
            spin_options_hover = spin_options_hover,
        }

        table.insert(self.optionwidgets, data)
    end

    self.options_scroll_list = self.optionspanel:AddChild(TEMPLATES.ScrollingGrid(
            self.optionwidgets,
            {
                scroll_context = {
                },
                widget_width  = item_width,
                widget_height = item_height,
                num_visible_rows = 11,
                num_columns = 1,
                item_ctor_fn = ScrollWidgetsCtor,
                apply_fn = ApplyDataToWidget,
                scrollbar_offset = 20,
                scrollbar_height_offset = -60
            }
        ))
    self.options_scroll_list:SetPosition(0,-6)

    -- Top border of the scroll list.
	self.horizontal_line = self.optionspanel:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
    self.horizontal_line:SetPosition(0,self.options_scroll_list.visible_rows/2 * item_height)
    self.horizontal_line:SetSize(item_width+30, 5)



	if TheInput:ControllerAttached() then
        self.dialog.actions:Hide()
	end

	self.default_focus = self.options_scroll_list
	self:HookupFocusMoves()
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
    -- This resets to the mod's defaults, so it's not the same as backing out.
    -- This may result in many spinners showing modification!

    local function reset()
        for i,v in pairs(self.optionwidgets) do
            self.options[i].value = self.options[i].default
            v.selected_value = self.options[i].default
        end
        self.options_scroll_list:RefreshView()
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
            return true

	    elseif control == CONTROL_PAUSE and TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
            self:Apply()
            return true

        elseif control == CONTROL_MAP and TheInput:ControllerAttached() then
			self:ResetToDefaultValues()
			return true
        end
	end
end

function ModConfigurationScreen:HookupFocusMoves()

end

function ModConfigurationScreen:GetHelpText()
	local t = {}
	local controller_id = TheInput:GetControllerID()

	table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
	table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MAP) .. " " .. STRINGS.UI.MODSSCREEN.RESETDEFAULT)
	if self:IsDirty() then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_PAUSE) .. " " .. STRINGS.UI.HELP.APPLY)
	end

	return table.concat(t, "  ")
end

return ModConfigurationScreen
