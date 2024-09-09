local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"
local Text = require "widgets/text"

local Customize = require("map/customize")

local num_columns = 3
--the size of each world customization button
local button_width = 240
local button_height = 50
--the size of the customization icon
local image_size = button_height
--size plus padding so that the buttons aren't to close together
local padded_width = button_width + 10
local padded_height = button_height + 10
--width available to the spinner
local spinner_width = padded_width - image_size
--width available to the text entry
local textentry_width = padded_width - image_size - 40
--calculation to make the menu take up exactly 500 pixels in height
local num_rows = math.floor(500 / padded_height)
local peek_height = math.abs(num_rows * padded_height - 500)

local function MakeLabel(text)
    local label = Widget("label")
    local label_root = label:AddChild(Widget("label_root"))
    -- Push right to centre across all columns.
    label_root:SetPosition(padded_width * (num_columns-1)/2, 0)

    local label_width = padded_width * num_columns
    label_root.bg = label_root:AddChild(TEMPLATES.ListItemBackground(label_width, button_height))
    label_root.label_text = label_root:AddChild(Text(HEADERFONT, 28))
    label_root.label_text:SetHAlign(ANCHOR_MIDDLE)
    label_root.label_text:SetRegionSize(label_width, button_height)

    label.SetText = function(_, new_label, is_title)
        label_root.label_text:SetString(new_label)
        -- Not using GOLD_SELECTED for titles because it's indistinguishable
        -- from GOLD_UNIMPORTANT.
        label_root.label_text:SetColour( is_title and UICOLOURS.GOLD or UICOLOURS.GOLD_UNIMPORTANT )
    end
    label:SetText(text)

    -- Let bg get focus to change colour with gamepad navigation.
    label.focus_forward = label_root.bg

    return label
end

local function CreateOptionSpinner(spinnerCB)
    local opt = Widget("opt_spinner")
    opt.bg = opt:AddChild(TEMPLATES.ListItemBackground_Static(padded_width, padded_height))

    local image_parent = opt:AddChild(Widget("imageparent"))
    opt.image = image_parent:AddChild(Image())
    opt.icon_txt = image_parent:AddChild(Text(NEWFONT_OUTLINE, 14))

    local spinner_height = button_height
    local spinner = opt:AddChild(TEMPLATES.StandardSpinner({}, spinner_width, spinner_height, nil, 14))
    spinner:EnablePendingModificationBackground()

    spinner.focus_scale = {spinner_width - 25, spinner_height}
    -- Only the spinner shows focus.
    opt.focus_forward = spinner
    opt.image.focus_forward = spinner
    opt.bg.focus_forward = spinner

    spinner.OnChanged = function( _, selection)
        spinnerCB(opt.parent.data.option, spinner, selection)
    end

    spinner:SetHasModification(true) -- we process this manually because we have three states

    local slightly_offcentre = 10 -- consume some edge padding, but looks more centred in space
    local item_width = button_width - slightly_offcentre
    spinner:SetPosition((item_width/2)-(spinner_width/2) + slightly_offcentre, 0)
    image_parent:SetPosition((-item_width/2)+(image_size/2), 0)

    local height_offset = spinner_height/4 - 2
    spinner.text:SetPosition(0, -height_offset - 3)
    spinner.label = spinner.text:AddChild(Text(TITLEFONT, 18, nil, UICOLOURS.GOLD_UNIMPORTANT))
    spinner.label:SetPosition(0, height_offset*2)
    spinner.label:SetRegionSize(spinner_width, spinner_height)

    spinner.SetEditable = function(_, is_editable)
        if is_editable then
            spinner:Enable()
        else
            spinner:Disable()
        end
    end

    opt.spinner = spinner

    return opt
end

local function CreateTextExtry(textentryCB)
    local opt = Widget("opt_textentry")
    opt.bg = opt:AddChild(TEMPLATES.ListItemBackground_Static(padded_width, padded_height))

    local image_parent = opt:AddChild(Widget("imageparent"))
    opt.image = image_parent:AddChild(Image())
    opt.icon_txt = image_parent:AddChild(Text(NEWFONT_OUTLINE, 14))

    opt.focus_img = opt:AddChild(Image("images/global_redux.xml", "spinner_focus.tex"))
    opt.focus_img:ScaleToSize(textentry_width + 15, button_height)
    opt.focus_img:SetTint(1,1,1,0)

    local textentry_height = button_height - 20
    local textentry = opt:AddChild(TEMPLATES.StandardSingleLineTextEntry(nil, textentry_width, textentry_height, NEWFONT, 18, ""))
    textentry.textbox:SetHAlign(ANCHOR_MIDDLE)
    textentry.textbox.prompt:SetHAlign(ANCHOR_MIDDLE)

    textentry.changed_image = textentry:AddChild(Image("images/global_redux.xml", "option_highlight.tex"))
    textentry.changed_image:SetPosition(0, 0)
    textentry.changed_image:ScaleToSizeIgnoreParent(textentry_width + 28, button_height)
    textentry.changed_image:MoveToBack()
    textentry.changed_image:SetClickable(false)
    textentry.changed_image:SetTint(1,1,1,0.3)

    -- Only the textentry shows focus.
    opt.focus_forward = textentry.textbox
    opt.image.focus_forward = textentry.textbox
    opt.bg.focus_forward = textentry.textbox
    opt.focus_img.focus_forward = textentry.textbox

    textentry.textbox.OnTextInputted = function()
        textentryCB(opt.parent.data.option, textentry, textentry.textbox:GetLineEditString())
    end

    local slightly_offcentre = 10 -- consume some edge padding, but looks more centred in space
    local item_width = button_width - slightly_offcentre
    opt.focus_img:SetPosition((item_width/2)-(textentry_width/2+20) + slightly_offcentre, 0)
    textentry:SetPosition((item_width/2)-(textentry_width/2) - 9, 0)
    image_parent:SetPosition((-item_width/2)+(image_size/2), 0)

    local _OnGainFocus = textentry.OnGainFocus
    textentry.OnGainFocus = function(_)
        _OnGainFocus(_)
        opt.focus_img:SetTint(1,1,1,1)
    end

    local _OnLoseFocus = textentry.OnLoseFocus
    textentry.OnLoseFocus = function(_)
        _OnLoseFocus(_)
        opt.focus_img:SetTint(1,1,1,0)
    end

    textentry.SetEditable = function(_, is_editable)
        if is_editable then
            textentry.textbox:Enable()
        else
            textentry.textbox:Disable()
        end
    end

    textentry.SetPrompt = function(_, prompt_text)
        if prompt_text then
            textentry.textbox.prompt:SetString(prompt_text)
        else
            textentry.textbox.prompt:SetString("")
        end
        textentry.textbox:_TryUpdateTextPrompt()
    end

    textentry.SetSelected = function(_, text)
        textentry.textbox:SetString(text)
    end

    opt.textentry = textentry

    return opt
end

local SettingsList = Class(Widget, function(self, parent_widget, levelcategory)
    Widget._ctor(self, "PresetBox")

    self.parent_widget = parent_widget
    self.levelcategory = levelcategory

    self.presetvalues = {}

    self.focus_forward = function() return self.scroll_list end
end)

local function IsEntryInSpinOptions(spin_options, entry)
    for i, n in ipairs(spin_options) do
        if n.data == entry then
            return true
        end
    end
    return false
end

function SettingsList:MakeScrollList()
    if self.scroll_list then
        self.scroll_list:Kill()
        self.scroll_list = nil
    end

    self.optionitems = {}

    local function spinnerCB(option, spinner, value, ...)
        self:OnSpinnerChanged(option, spinner, value, ...)
    end

    local function textentryCB(option, textentry, value, ...)
        self:OnTextEntryChanged(option, textentry, value, ...)
    end

    local function ScrollWidgetsCtor(context, i)
        local item = Widget("item-"..i)
        item.label = item:AddChild(MakeLabel(""))
        item.opt_spinner = item:AddChild(CreateOptionSpinner(spinnerCB))
        item.opt_textentry = item:AddChild(CreateTextExtry(textentryCB))
        item:SetOnGainFocus(function() self.scroll_list:OnWidgetFocus(item) end)
        return item
    end

    local function ApplyDataToWidget(context, widget, data, index)
        if not data or data ~= widget.data then
            widget.data = data

            if not data or data.is_empty then
                widget:Hide()
                widget.focus_forward = nil
                return
            else
                widget:Show()
            end

            if data.heading_text then
                widget.opt_spinner:Hide()
                widget.opt_textentry:Hide()

                widget.focus_forward = nil

                widget.label:Show()
                widget.label:SetText(data.heading_text, data.is_title)
                return
            else
                widget.label:Hide()
            end

            local v = data.option
            assert(v)

            if v.widget_type == "textentry" then
                local opt = widget.opt_textentry
                opt:Show()

                widget.focus_forward = opt

                local icon_image = v.image
                local atlas = v.atlas
                local icon_txt = nil
                if PLATFORM == "WIN32_RAIL" and v.options_remap then
                    atlas = v.options_remap.atlas or atlas
                    icon_image = v.options_remap.img
                    icon_txt = STRINGS.UI.CUSTOMIZATIONSCREEN.ICON_TITLES[string.upper(v.name)]
                end

                opt.image:SetTexture(atlas or "images/customisation.xml", icon_image)
                opt.image:SetSize(image_size, image_size)
                opt.icon_txt:SetString(icon_txt)

                opt.textentry:SetSelected(self.parent_widget:GetValueForOption(v.name) or v.default)
                self:SetBGForTextEntry(opt.textentry, data.option)

                opt.textentry:SetPrompt(STRINGS.UI.CUSTOMIZATIONSCREEN[string.upper(v.name)])

                opt.textentry:SetEditable(self.parent_widget:IsEditable())
            else
                widget.opt_textentry:Hide()
            end

            if v.widget_type == "optionsspinner" then
                local opt = widget.opt_spinner
                opt:Show()

                widget.focus_forward = opt

                local spin_options = {}
                for i, n in ipairs(v.options) do
                    table.insert(spin_options, {text = n.text, data = n.data})
                end

                local icon_image = v.image
                local icon_atlas = v.atlas or "images/customisation.xml"
                local icon_txt = nil
                if PLATFORM == "WIN32_RAIL" and v.options_remap then
                    icon_image = v.options_remap.img
                    icon_atlas = v.options_remap.atlas or icon_atlas
                    icon_txt = STRINGS.UI.CUSTOMIZATIONSCREEN.ICON_TITLES[string.upper(v.name)]
                end
                opt.image:SetTexture(icon_atlas, icon_image)
                opt.image:SetSize(image_size, image_size)
                opt.icon_txt:SetString(icon_txt)

                opt.spinner:SetOptions(spin_options)

                local val = self.parent_widget:GetValueForOption(v.name) or v.default
                if not IsEntryInSpinOptions(spin_options, val) then val = v.default end
                opt.spinner:SetSelected(val)
                self:SetBGForSpinner(opt.spinner, data.option)

                opt.spinner.label:SetString(STRINGS.UI.CUSTOMIZATIONSCREEN[string.upper(v.name)])

                opt.spinner:SetEditable(self.parent_widget:IsEditable())
            else
                widget.opt_spinner:Hide()
            end
        elseif self.forceupdate then
            if not data or data.is_empty or data.heading_text then
                return
            end

            local v = data.option
            assert(v)

            if v.widget_type == "textentry" then
                widget.opt_textentry.textentry:SetSelected(self.parent_widget:GetValueForOption(v.name) or v.default)
                self:SetBGForTextEntry(widget.opt_textentry.textentry, data.option)
            elseif v.widget_type == "optionsspinner" then
                local val = self.parent_widget:GetValueForOption(v.name) or v.default
                if not IsEntryInSpinOptions(v.options, val) then val = v.default end
                widget.opt_spinner.spinner:SetSelected(val)
                self:SetBGForSpinner(widget.opt_spinner.spinner, data.option)
            end
        end
    end

    self.scroll_list = self:AddChild(TEMPLATES.ScrollingGrid(
        self.optionitems,
        {
            context = {},
            widget_width  = padded_width,
            widget_height = padded_height,
            num_visible_rows = num_rows,
            num_columns      = num_columns,
            item_ctor_fn = ScrollWidgetsCtor,
            apply_fn     = ApplyDataToWidget,
            scrollbar_offset = 17.5,
            scrollbar_height_offset = -50,
            peek_height = peek_height,
            force_peek = true,
            end_offset = 1 - (peek_height-10)/padded_height,
        }
    ))

    self.scroll_list.getnextitemindex = function(dir, focused_item_index)
        local mov = (dir == MOVE_UP and -self.scroll_list.widgets_per_row) or (dir == MOVE_DOWN and self.scroll_list.widgets_per_row)
        local stop = (dir == MOVE_UP and 1) or (dir == MOVE_DOWN and #self.optionitems)
        if mov then
            local last_i
            for i = focused_item_index + mov, stop, mov do
                local opt = self.optionitems[i]
                if opt and not opt.is_empty and not opt.heading_text then
                    return i
                end
                last_i = i
            end
            return nil, last_i
        end
    end

    local scroll_grid = self.scroll_list.list_root.grid

    local _SetFocus = scroll_grid.SetFocus
    function scroll_grid.SetFocus(_, c, r)
        if not (r or c) then
            for i = 1, scroll_grid.rows do
                local item = scroll_grid:GetItemInSlot(1, i)
                if item.data and not item.data.is_empty and not item.data.heading_text then
                    r = i
                    break
                end
            end
        end
        return _SetFocus(_, c, r)
    end

    function scroll_grid.DoFocusHookups()
        for c = 1, scroll_grid.cols do
            for r = 1, scroll_grid.rows do
                local item = scroll_grid:GetItemInSlot(c,r)
                if item then
                    item:ClearFocusDirs()
                    local function left_function()
                        for i = c - 1, 1, -1 do
                            local wdg = scroll_grid:GetItemInSlot(i, r)
                            if wdg and wdg.data then
                                return wdg
                            end
                        end
                    end
                    local function right_function()
                        for i = c + 1, scroll_grid.cols, 1 do
                            local wdg = scroll_grid:GetItemInSlot(i, r)
                            if wdg and wdg.data then
                                return wdg
                            end
                        end
                    end
                    item:SetFocusChangeDir(MOVE_LEFT, left_function)
                    item:SetFocusChangeDir(MOVE_RIGHT, right_function)
                end
            end
        end
    end
    scroll_grid:DoFocusHookups()

    self:RefreshOptionItems()
end

function SettingsList:RefreshOptionItems()
    if not self.scroll_list then return end

    self.options = self.parent_widget:GetOptions()

    self.optionitems = {}

    local lastgroup = nil
    for i,v in ipairs(self.options) do
        --Insert text headings between groups
        if v.group ~= lastgroup then

            -- Combining multiple column items and cross-column titles in one
            -- grid, so we need to pad out previous sections with empty if they
            -- aren't full and insert an empties after the header to fill the
            -- rest of the row.
            local wrapped_index = #self.optionitems % num_columns
            if wrapped_index > 0 then
                for col = wrapped_index + 1, num_columns do
                    table.insert(self.optionitems, {is_empty = true})
                end
            end

            table.insert(self.optionitems, {heading_text = v.grouplabel})

            for col = 2, num_columns do
                table.insert(self.optionitems, {is_empty = true})
            end

            lastgroup = v.group
        end

        table.insert(self.optionitems, {option = v})
    end
    local wrapped_index = #self.optionitems % num_columns
    if wrapped_index > 0 then
        for col = wrapped_index + 1, num_columns do
            table.insert(self.optionitems, {is_empty = true})
        end
    end

    self.forceupdate = true
    self.scroll_list:SetItemsData(self.optionitems)
    self.forceupdate = false

    self.scroll_list:SetPosition(self.scroll_list:CanScroll() and -15 or 0, 0)
end

function SettingsList:SetPresetValues(values)
    self.presetvalues = values
end

function SettingsList:SetBGForSpinner(spinner, option)
    local value = spinner:GetSelectedData()
    local preset_value = self.presetvalues[option.name]

    if value == option.default and (preset_value == nil or preset_value == option.default) then
        -- No bg for unchanged. This matches the options screen.
        spinner.changed_image:SetTint(1,1,1,0)
    elseif value == preset_value then
        -- Light bg for preset values.
        spinner.changed_image:SetTint(1,1,1,0.1)
    else
        -- Standard modification bg for changes (see
        -- EnablePendingModificationBackground).
        spinner.changed_image:SetTint(1,1,1,0.3)
    end
end

function SettingsList:SetBGForTextEntry(textentry, option)
    local value = textentry.textbox:GetLineEditString()
    local preset_value = self.presetvalues[option.name]

    if value == option.default and (preset_value == nil or preset_value == option.default) then
        -- No bg for unchanged. This matches the options screen.
        textentry.changed_image:SetTint(1,1,1,0)
    elseif value == preset_value then
        -- Light bg for preset values.
        textentry.changed_image:SetTint(1,1,1,0.1)
    else
        -- Standard modification bg for changes (see
        -- EnablePendingModificationBackground).
        textentry.changed_image:SetTint(1,1,1,0.3)
    end
end

function SettingsList:OnTextEntryChanged(option, textentry, value)
	if option then
		self.parent_widget:SetTweak(option.name, value)
		self:SetBGForTextEntry(textentry, option)
	end
end

function SettingsList:OnSpinnerChanged(option, spinner, value)
	-- there seem to be spinners on all list entries, even the headers which don't have any data to drive the spinners
	-- and it's also possible to trigger an OnSpinnerChanged event on these headers (with a controller)
	-- so check for valid options before trying to use them
	if option then	
		self.parent_widget:SetTweak(option.name, value)
		self:SetBGForSpinner(spinner, option)
	end
end

function SettingsList:Refresh(force)
    self.forceupdate = force
    if self.scroll_list then
        self.scroll_list:RefreshView()
    end
    self.forceupdate = nil
end

return SettingsList