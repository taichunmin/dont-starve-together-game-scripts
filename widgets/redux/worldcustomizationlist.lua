local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"
local TEMPLATES = require "widgets/redux/templates"


-- from ServerCreationScreen
local dialog_size_x = 830
local dialog_width = dialog_size_x + (60*2) -- nineslice sides are 60px each

local num_columns = 2
local end_spacing = 10
local item_height = 70
local padded_height = item_height + end_spacing
local padded_width = dialog_width/num_columns * 0.95
local item_width = padded_width - end_spacing*2
local spinner_width = item_width - item_height

local CustomizationList = Class(Widget, function(self, location, options, spinnerCB)
    Widget._ctor(self, "CustomizationList")
    self.location = location
    self.options = options
    self.spinnerCB = spinnerCB

    self.allowEdit = true
    self.presetvalues = {}
    self.title = nil

    self:MakeOptionSpinners()

    self.focus_forward = self.scroll_list
end)

local function MakeLabel(text)
    local label = Widget("label")
    local label_root = label:AddChild(Widget("label_root"))
    -- Push right to centre across all columns.
    label_root:SetPosition(padded_width * (num_columns-1)/2, 0)

    local label_width = padded_width * num_columns
    label_root.bg = label_root:AddChild(TEMPLATES.ListItemBackground(label_width, item_height))
    label_root.label_text = label_root:AddChild(Text(HEADERFONT, 28))
    label_root.label_text:SetHAlign(ANCHOR_MIDDLE)
    label_root.label_text:SetRegionSize(label_width, item_height)

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

function CustomizationList:SetTitle(title)
    assert(title, "Removing title is not supported.")
    if self.title == title then
        return
    end

    self.title = title

    table.insert(self.optionitems, 1, { heading_text = title, is_title = true })
    for col=2,num_columns do
        table.insert(self.optionitems, 2, { is_empty = true })
    end

    self.scroll_list:SetItemsData(self.optionitems)
end

local OPTIONS_REMAP =
{
	autumn	= {img = "blank_season_yellow.tex" },
	spring	= {img = "blank_season_yellow.tex" },
	summer	= {img = "blank_season_yellow.tex" },
	winter	= {img = "blank_season_yellow.tex" },

	prefabswaps_start = {img = "blank_grassy.tex" },

	branching		= {img = "blank_world.tex" },
	loop			= {img = "blank_world.tex" },
	task_set		= {img = "blank_world.tex" },
	world_size		= {img = "blank_world.tex" },
	start_location	= {img = "blank_world.tex" },

	day				= {img = "blank_season_red.tex" },
	season_start	= {img = "blank_season_red.tex" },

	--Unused options icons
	--["season.tex"]		= {img = "blank_season_yellow.tex" },
	--["changing_resources.tex"]	= {img = "blank_grassy.tex" },
	--["periodic_resource.tex"]	= {img = "blank_world.tex" },
	--["start_resource.tex"]		= {img = "blank_world.tex" },
	--["season_length.tex"]		= {img = "blank_season_red.tex" },
}

function CustomizationList:MakeOptionSpinners()
    self.optionitems = {}

    local function CreateOptionSpinner()
        local opt = Widget("opt_spinner")
        opt.bg = opt:AddChild(TEMPLATES.ListItemBackground_Static(padded_width, padded_height))

        local image_parent = opt:AddChild(Widget("imageparent"))
        opt.image = image_parent:AddChild(Image())
        opt.icon_txt = image_parent:AddChild(Text(NEWFONT_OUTLINE, 20))

        local spinner_height = item_height
        local spinner = opt:AddChild(TEMPLATES.StandardSpinner({}, spinner_width, spinner_height))
        spinner:EnablePendingModificationBackground()
        -- Only the spinner shows focus.
        opt.focus_forward = spinner
        opt.image.focus_forward = spinner
        opt.bg.focus_forward = spinner


        spinner.OnChanged =
            function( _, selection)
                opt.data.selection = selection
                if self.spinnerCB then
                    self.spinnerCB(opt.data.option.name, selection)
                end
                self:SetBGForSpinner(spinner, opt.data.option)
            end

        spinner:SetHasModification(true) -- we process this manually because we have three states

        local slightly_offcentre = 5 -- consume some edge padding, but looks more centred in space
        spinner:SetPosition((item_width/2)-(spinner_width/2) + slightly_offcentre, 0)
        image_parent:SetPosition((-item_width/2)+(item_height/2), 0)

        local height_offset = spinner_height/4 - 2
        spinner.text:SetPosition(0, -height_offset - 3)
        spinner.label = spinner.text:AddChild(Text(TITLEFONT, 28, nil, UICOLOURS.GOLD_UNIMPORTANT))
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

    local location_name = STRINGS.UI.SANDBOXMENU.LOCATION[string.upper(self.location)] or STRINGS.UI.SANDBOXMENU.LOCATION.UNKNOWN
    local lastgroup = nil
    for i,v in ipairs(self.options) do

        -- Insert text headings between groups
        if v.group ~= lastgroup then

            -- Combining multiple column items and cross-column titles in one
            -- grid, so we need to pad out previous sections with empty if they
            -- aren't full and insert an empties after the header to fill the
            -- rest of the row.
            local wrapped_index = #self.optionitems % num_columns
            if wrapped_index > 0 then
                for col=wrapped_index+1,num_columns do
                    table.insert(self.optionitems, {
                            is_empty = true,
                        })
                end
            end

            table.insert(self.optionitems, {
                    heading_text = string.format("%s %s",
                        location_name,
                        v.grouplabel)
                })

            for col=2,num_columns do
                table.insert(self.optionitems, {
                        is_empty = true,
                    })
            end

            lastgroup = v.group
        end

        table.insert(self.optionitems, {
                option = v,
                selection = v.default,
        })
    end

    local function ScrollWidgetsCtor(context, i)
        local item = Widget("item-"..i)
        item.label = item:AddChild(MakeLabel(""))
        item.opt_spinner = item:AddChild(CreateOptionSpinner())
        item:SetOnGainFocus(function() self.scroll_list:OnWidgetFocus(item) end)
        return item
    end
    local function ApplyDataToWidget(context, widget, data, index)
        widget.opt_spinner:Hide()
        widget.label:Hide()

        if not data or data.is_empty then
            widget.focus_forward = nil
            return
        end

        if data.heading_text then
            widget.focus_forward = widget.label
            widget.label:Show()
            widget.label:SetText(data.heading_text, data.is_title)
            return
        end

        local v = data.option
        assert(v)

        local opt = widget.opt_spinner
        widget.focus_forward = opt
        opt:Show()
        opt.data = data


        local spin_options = {}
        for m,n in ipairs(v.options) do
            table.insert(spin_options, {text=n.text, data=n.data})
        end

        local icon_image = v.image
        local icon_txt = nil
        -- TODO(petera): Test text looks good on Rail
        if PLATFORM == "WIN32_RAIL" and OPTIONS_REMAP[v.name] then
			--~ print( v.image, v.name )
			icon_image = OPTIONS_REMAP[v.name].img
			icon_txt = STRINGS.UI.CUSTOMIZATIONSCREEN.ICON_TITLES[string.upper(v.name)]
		end
        opt.image:SetTexture(v.atlas or "images/customisation.xml", icon_image)
        opt.image:SetSize(item_height, item_height)
        opt.icon_txt:SetString(icon_txt)

        opt.spinner:SetOptions(spin_options)

        opt.spinner:SetSelected(opt.data.selection)
        self:SetBGForSpinner(opt.spinner, opt.data.option)

        opt.spinner.label:SetString(STRINGS.UI.CUSTOMIZATIONSCREEN[string.upper(v.name)])

        opt.spinner:SetEditable(self.allowEdit or FunctionOrValue(v.alwaysedit, self.location))
    end

    self.scroll_list = self:AddChild(TEMPLATES.ScrollingGrid(
            self.optionitems,
            {
                context = {},
                widget_width  = padded_width,
                widget_height = padded_height,
                num_visible_rows = 6,
                num_columns      = num_columns,
                item_ctor_fn = ScrollWidgetsCtor,
                apply_fn     = ApplyDataToWidget,
                scrollbar_offset = 20,
                scrollbar_height_offset = -50
            }
        ))

end

function CustomizationList:SetEditable(editable)
    self.allowEdit = editable

    self.scroll_list:RefreshView()
end

function CustomizationList:SetPresetValues(values)
    self.presetvalues = values
end

function CustomizationList:SetValueForOption(option, value)
    -- Why do we set each option individually causing two loops for each
    -- option? Why not pass a table?
    for i,data in pairs(self.optionitems) do
        if data.option and data.option.name == option then
            data.selection = value
            break
        end
    end
    self.scroll_list:RefreshView()
end

function CustomizationList:SetBGForSpinner(spinner, option)
    local value = spinner:GetSelectedData()
    local preset_value = self.presetvalues[option.name]

    if value == option.default
        and (preset_value == nil or preset_value == option.default) then
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

return CustomizationList
