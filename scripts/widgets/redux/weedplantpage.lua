local Widget = require "widgets/widget"
local PlantPageWidget = require "widgets/redux/plantpagewidget"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local TEMPLATES = require "widgets/redux/templates"
local Image = require "widgets/image"

local LEARN_PERCENTS = {
    WATER = 1/3,
    NUTRIENTS = 2/3,
    EFFECTS = 3/3,
}

local function MakeDetailsLine(root, x, y, scale, image_override)
	local value_title_line = root:AddChild(Image("images/plantregistry.xml", image_override or "details_line.tex"))
	value_title_line:SetScale(scale, scale)
    value_title_line:SetPosition(x, y)
    return value_title_line
end

local item_icon_remap = {}
local item_name_remap = {}

local function MakeItemWidget(root, cursor, x, y, ingredient_size, item_name, name_prefix)
    name_prefix = name_prefix or ""

    local img_name = (item_icon_remap[item_name] or item_name)..".tex"
    local img_atlas = GetInventoryItemAtlas(img_name, true)
    local backing = root:AddChild(Image(img_atlas or "images/plantregistry.xml", img_atlas ~= nil and img_name or "missing.tex"))
    backing:ScaleToSize(ingredient_size, ingredient_size)
    backing:SetPosition(x, y)
    backing:SetHoverText(STRINGS.NAMES[string.upper(name_prefix..(item_name_remap[item_name] or item_name))] or STRINGS.UI.PLANTREGISTRY.NEEDSMORERESEARCH, {offset_y = 80})

    local _OnGainFocus = backing.OnGainFocus
    function backing.OnGainFocus()
        _OnGainFocus(backing)
        cursor:GetParent():RemoveChild(cursor)
        backing:AddChild(cursor)
        cursor:ScaleToSizeIgnoreParent(ingredient_size, ingredient_size)
        cursor:Show()
    end
    local _OnLoseFocus = backing.OnLoseFocus
    function backing.OnLoseFocus()
        _OnLoseFocus(backing)
        if cursor:GetParent() == backing then
            backing:RemoveChild(cursor)
            root:AddChild(cursor)
            cursor:Hide()
        end
    end

    return backing
end

local WeedPlantPage = Class(PlantPageWidget, function(self, plantspage, data)
    PlantPageWidget._ctor(self, "WeedPlantPage", plantspage, data)

    self.known_percent = ThePlantRegistry:GetPlantPercent(data.plant, data.info)

    local name_font_size = 24
    local unknown_font_size = 16
    local title_font_size = 16

    local ingredient_size = 48

    local plant_name_str = ThePlantRegistry:KnowsPlantName(self.data.plant, self.data.info) and
        STRINGS.NAMES[string.upper(self.data.plant_def.prefab)] or
        STRINGS.UI.PLANTREGISTRY.MYSTERY_PLANT

    self.cursor = self.root:AddChild(Image("images/plantregistry.xml", "cursor.tex"))
    self.cursor:SetClickable(false)
    self.cursor:Hide()

    self.plant_name = self.root:AddChild(Text(HEADERFONT, name_font_size, plant_name_str))
    self.plant_name:SetPosition(0, 275 - 15 - 17.5)
    self.plant_name:SetHAlign(ANCHOR_MIDDLE)

    if plant_name_str == STRINGS.UI.PLANTREGISTRY.MYSTERY_PLANT then
        self.plant_name:SetColour(PLANTREGISTRYUICOLOURS.LOCKEDBROWN)
    else
        self.plant_name:SetColour(PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN)
    end

    local line_width = 170
    local line_gap = 10

    local large_line_width = line_width * 2 + line_gap

    local x_start = 0 - (line_width + line_gap)
    local y_start = -70

    if not self.data.plant_def.product then
        x_start = x_start + (line_width + line_gap) * 0.5
    end

    --water--
    local water_y = y_start - title_font_size/2 - 3
    local water_size = 32
    local water_gap = 6

    self.water = self.root:AddChild(Text(HEADERFONT, title_font_size, STRINGS.UI.PLANTREGISTRY.WEEDPLANTS.WATER, PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN))
    self.water:SetPosition(x_start, y_start)
    self.water:SetHAlign(ANCHOR_MIDDLE)
    self.water_line = MakeDetailsLine(self.root, x_start, water_y, 0.5)
    --display water consumption

    if self.known_percent >= LEARN_PERCENTS.WATER then
        local water_icon_count =
        {
            [TUNING.FARM_PLANT_DRINK_LOW] = 1,
            [TUNING.FARM_PLANT_DRINK_MED] = 2,
            [TUNING.FARM_PLANT_DRINK_HIGH] = 3,
        }

        self.water_icons = {}
        for i = 1, water_icon_count[self.data.plant_def.moisture.drink_rate] do
            local water_icon = self.root:AddChild(Image("images/plantregistry.xml", "water.tex"))
            water_icon:ScaleToSize(water_size, water_size)
            table.insert(self.water_icons, water_icon)
        end

        local water_count = #self.water_icons
        local water_x = x_start - ((water_count * water_size) + ((water_count - 1) * water_gap)) / 2
        water_y = water_y - water_size / 2 - water_gap

        for i, season_icon in ipairs(self.water_icons) do
            water_x = water_x + water_size / 2
            season_icon:SetPosition(water_x, water_y)
            water_x = water_x + water_size / 2 + water_gap
        end
    else
        water_y = water_y - 10 - unknown_font_size / 2
        self.unknown_water_text = self.root:AddChild(Text(HEADERFONT, unknown_font_size, STRINGS.UI.PLANTREGISTRY.NEEDSMORERESEARCH, PLANTREGISTRYUICOLOURS.LOCKEDBROWN))
        self.unknown_water_text:SetPosition(x_start, water_y)
        self.unknown_water_text:SetHAlign(ANCHOR_MIDDLE)
        self.water:SetColour(PLANTREGISTRYUICOLOURS.LOCKEDBROWN)
    end
    --water--

    x_start = x_start + line_width + line_gap

    --nutrients--
    local nutrients_y = y_start - title_font_size/2 - 3
    local nutrients_size = 24
    local nutrients_gap = 6

    self.nutrients = self.root:AddChild(Text(HEADERFONT, title_font_size, STRINGS.UI.PLANTREGISTRY.WEEDPLANTS.NUTRIENTS, PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN))
    self.nutrients:SetPosition(x_start, y_start)
    self.nutrients:SetHAlign(ANCHOR_MIDDLE)
    self.nutrients_line = MakeDetailsLine(self.root, x_start, nutrients_y, 0.5)
    --display nutrients consumption

    if self.known_percent >= LEARN_PERCENTS.NUTRIENTS then
        --display nutrients icons.
        self.nutrients_icons = {}

        local restore_nutrients = self.data.plant_def.nutrient_restoration ~= nil

        local total_nutrients = 0
        for i, v in ipairs(self.data.plant_def.nutrient_consumption) do
            total_nutrients = total_nutrients + v
        end
        local nutrients_restore = not restore_nutrients and 0 or total_nutrients / GetTableSize(self.data.plant_def.nutrient_restoration)

        local total_width = 0
        for nutrient_type = 1, 3 do
            local consume_count = -self.data.plant_def.nutrient_consumption[nutrient_type]
            if restore_nutrients and self.data.plant_def.nutrient_restoration[nutrient_type] then
                consume_count = consume_count + nutrients_restore
            end
            local nutrients_icon = self.root:AddChild(Image("images/plantregistry.xml", "nutrient_"..nutrient_type..".tex"))
            nutrients_icon:ScaleToSize(nutrients_size,nutrients_size)

            nutrients_icon.nutrient_type = nutrient_type
            local neutral = consume_count == 0
            local positive = consume_count > 0

            local imagename
            local prefix
            if neutral then
                imagename = "nutrient_neutral.tex"
                prefix = STRINGS.UI.PLANTREGISTRY.NUTRIENTS.NEUTRAL
            else
                local abs_consume_count = math.abs(consume_count)
                local nutrients_modifier_num = (abs_consume_count <= TUNING.FARM_PLANT_CONSUME_NUTRIENT_LOW and 1) or (abs_consume_count >= TUNING.FARM_PLANT_CONSUME_NUTRIENT_HIGH and 4) or 2
                if positive then
                    imagename = "nutrient_up_"..nutrients_modifier_num..".tex"
                    prefix = STRINGS.UI.PLANTREGISTRY.NUTRIENTS.RESTORE
                else
                    imagename = "nutrient_down_"..nutrients_modifier_num..".tex"
                    prefix = STRINGS.UI.PLANTREGISTRY.NUTRIENTS.CONSUME
                end
            end

            nutrients_icon:SetHoverText(prefix..STRINGS.UI.PLANTREGISTRY.NUTRIENTS[string.upper("nutrient_"..nutrient_type)], {offset_y = 48})

            nutrients_icon.modifier = self.root:AddChild(Image("images/plantregistry.xml", imagename))
            nutrients_icon.modifier:ScaleToSize(nutrients_size,nutrients_size)

            local _OnGainFocus = nutrients_icon.OnGainFocus
            function nutrients_icon.OnGainFocus()
                _OnGainFocus(nutrients_icon)
                self.cursor:GetParent():RemoveChild(self.cursor)
                nutrients_icon:AddChild(self.cursor)
                self.cursor:ScaleToSizeIgnoreParent(nutrients_size, nutrients_size)
                self.cursor:Show()
            end
            local _OnLoseFocus = nutrients_icon.OnLoseFocus
            function nutrients_icon.OnLoseFocus()
                _OnLoseFocus(nutrients_icon)
                if self.cursor:GetParent() == nutrients_icon then
                    nutrients_icon:RemoveChild(self.cursor)
                    self.root:AddChild(self.cursor)
                    self.cursor:Hide()
                end
            end

            total_width = total_width + (nutrients_size * 2) + 2

            table.insert(self.nutrients_icons, nutrients_icon)
        end

        local nutrients_count = #self.nutrients_icons
        local nutrients_x = x_start - (total_width + (nutrients_count - 1) * nutrients_gap) / 2
        nutrients_y = nutrients_y - 10 - nutrients_size / 2

        for i, nutrients_icon in ipairs(self.nutrients_icons) do
            nutrients_x = nutrients_x + nutrients_size / 2
            nutrients_icon:SetPosition(nutrients_x, nutrients_y)
            nutrients_x = nutrients_x + nutrients_size + 2
            nutrients_icon.modifier:SetPosition(nutrients_x, nutrients_y)
            nutrients_x = nutrients_x + nutrients_size / 2 + nutrients_gap
        end

    else
        nutrients_y = nutrients_y - 10 - unknown_font_size / 2
        self.unknown_nutrients_text = self.root:AddChild(Text(HEADERFONT, unknown_font_size, STRINGS.UI.PLANTREGISTRY.NEEDSMORERESEARCH, PLANTREGISTRYUICOLOURS.LOCKEDBROWN))
        self.unknown_nutrients_text:SetPosition(x_start, nutrients_y)
        self.unknown_nutrients_text:SetHAlign(ANCHOR_MIDDLE)
        self.nutrients:SetColour(PLANTREGISTRYUICOLOURS.LOCKEDBROWN)
    end
    --nutrients--

    x_start = x_start + line_width + line_gap

    --product--
    if self.data.plant_def.product then
        local knows_plant = ThePlantRegistry:KnowsPlantName(self.data.plant, self.data.info)

        local product_y = y_start - title_font_size/2 - 3
        self.product = self.root:AddChild(Text(HEADERFONT, title_font_size, STRINGS.UI.PLANTREGISTRY.WEEDPLANTS.PRODUCT, PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN))
        self.product:SetPosition(x_start, y_start)
        self.product:SetHAlign(ANCHOR_MIDDLE)
        if not knows_plant then
            self.product:SetColour(PLANTREGISTRYUICOLOURS.LOCKEDBROWN)
        end

        self.product_line = MakeDetailsLine(self.root, x_start, product_y, 0.5)
        product_y = product_y - 2 - ingredient_size / 2

        local product_name = knows_plant and self.data.plant_def.product or ""
        self.product_icon = MakeItemWidget(self.root, self.cursor, x_start, product_y, ingredient_size, product_name)
    end
    --product--

    x_start = 0
    y_start = y_start - 75

    --effects--
    local effects_y = y_start - title_font_size/2 - 3

    self.effects = self.root:AddChild(Text(HEADERFONT, title_font_size, STRINGS.UI.PLANTREGISTRY.WEEDPLANTS.EFFECTS, PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN))
    self.effects:SetPosition(x_start, y_start)
    self.effects:SetHAlign(ANCHOR_MIDDLE)
    self.effects_line = MakeDetailsLine(self.root, x_start, effects_y, 0.5, "details_line_wide.tex")
    --display effects

    if self.known_percent >= LEARN_PERCENTS.EFFECTS then
        self.effects_text = self.root:AddChild(Text(HEADERFONT, title_font_size, nil, PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN))

        self.effects_text:SetMultilineTruncatedString(
            STRINGS.UI.PLANTREGISTRY.EFFECTS[string.upper(self.data.plant)] or
            STRINGS.UI.PLANTREGISTRY.EFFECTS.NONE, 3, large_line_width - 10, nil, nil, true)

        local w, h = self.effects_text:GetRegionSize()
        effects_y = effects_y - 10 - h / 2

        self.effects_text:SetPosition(x_start, effects_y)
        self.effects_text:SetHAlign(ANCHOR_MIDDLE)
    else
        effects_y = effects_y - 10 - unknown_font_size / 2
        self.unknown_effects_text = self.root:AddChild(Text(HEADERFONT, unknown_font_size, STRINGS.UI.PLANTREGISTRY.NEEDSMORERESEARCH, PLANTREGISTRYUICOLOURS.LOCKEDBROWN))
        self.unknown_effects_text:SetPosition(x_start, effects_y)
        self.unknown_effects_text:SetHAlign(ANCHOR_MIDDLE)
        self.effects:SetColour(PLANTREGISTRYUICOLOURS.LOCKEDBROWN)
    end
    --effects--

    self:BuildPlantGrid()

    self.focus_forward = self.plant_grid[1]

    self:_DoFocusHookups()
end)

function WeedPlantPage:_DoFocusHookups()
    local plant_grid_first = self.plant_grid[1]
    local plant_grid_last = self.plant_grid[#self.plant_grid]

    local nutrients_icon_first = self.nutrients_icons and self.nutrients_icons[1]

    if self.product_icon then
        self.product_icon:SetFocusChangeDir(MOVE_UP, plant_grid_last)
    end

    if self.nutrients_icons then
        for i, nutrients_icon in ipairs(self.nutrients_icons) do
            nutrients_icon:SetFocusChangeDir(MOVE_UP, plant_grid_first)

            if self.nutrients_icons[i - 1] then
                nutrients_icon:SetFocusChangeDir(MOVE_LEFT, self.nutrients_icons[i - 1])
            end

            if self.nutrients_icons[i + 1] then
                nutrients_icon:SetFocusChangeDir(MOVE_RIGHT, self.nutrients_icons[i + 1])
            elseif self.product_icon then
                nutrients_icon:SetFocusChangeDir(MOVE_RIGHT, self.product_icon)
                self.product_icon:SetFocusChangeDir(MOVE_LEFT, nutrients_icon)
            end
        end
    end

    local previous_plant_widget = nil
    for i, info in ipairs(self.data.info) do
        local plant_widget = self.plant_grid[i]
        if plant_widget then
            if i / #self.data.info <= 0.5 then
                plant_widget:SetFocusChangeDir(MOVE_DOWN, nutrients_icon_first or self.product_icon)
            else
                plant_widget:SetFocusChangeDir(MOVE_DOWN, self.product_icon or nutrients_icon_first)
            end

            if previous_plant_widget then
                plant_widget:SetFocusChangeDir(MOVE_LEFT, previous_plant_widget)
            end

            local next_plant_widget
            for k = i + 1, #self.data.info do
                local _plant_widget = self.plant_grid[k]
                if _plant_widget then
                    next_plant_widget = _plant_widget
                    break
                end
            end

            if next_plant_widget then
                plant_widget:SetFocusChangeDir(MOVE_RIGHT, next_plant_widget)
            end

            previous_plant_widget = plant_widget
        end
    end
end

function WeedPlantPage:BuildPlantGrid()
    local row_h = 230
    local row_spacing = 2

	local font = HEADERFONT
    local font_size = 16

    self.plant_grid_root = self.root:AddChild(Widget("plant_grid_root"))
    self.plant_grid_root:SetPosition(0, 275 - 15 - (230 / 2) - 35)
    self.plant_grid = {}
    local start_x = 0
    local entries = 0
    for i, info in ipairs(self.data.info) do
        if not info.hidden or ThePlantRegistry:KnowsPlantStage(self.data.plant, i) then
            entries = entries + 1
            local row_w = 120
            start_x = start_x - (row_w / 2)
            local w = self.plant_grid_root:AddChild(Widget("plant-grid-"..i))
            w.info = info
            w.row_w = row_w

            if ThePlantRegistry:KnowsPlantStage(self.data.plant, i) then
                w.cell_root = w:AddChild(Image("images/plantregistry.xml", row_w >= 100 and "plant_cell_active.tex" or "plant_cell_narrow_active.tex"))
            else
                w.cell_root = w:AddChild(Image("images/plantregistry.xml", row_w >= 100 and "plant_cell.tex" or "plant_cell_narrow.tex"))
            end
            w.cell_root:ScaleToSize(row_w, row_h)

            if ThePlantRegistry:KnowsPlantStage(self.data.plant, i) then
                w.plant_anim = w:AddChild(UIAnim())
                w.plant_anim:SetPosition(0, -85)
                w.plant_anim:SetScale(0.4, 0.4)
                w.plant_anim:GetAnimState():OverrideSymbol("soil01", "farm_soil", "soil01")
                w.plant_anim:GetAnimState():SetBuild(self.data.plant_def.build)
                w.plant_anim:GetAnimState():SetBankAndPlayAnimation(w.info.bank or self.data.plant_def.bank, w.info.anim, w.info.loop ~= false)

                w.cell_root.OnGainFocus = function()
                    if w.info.grow_anim and w.plant_anim:GetAnimState():IsCurrentAnimation(w.info.anim) then
                        w.plant_anim:GetAnimState():PlayAnimation(w.info.grow_anim, false)
                        w.plant_anim:GetAnimState():PushAnimation(w.info.anim, w.info.loop ~= false)
                    end
                    w.cell_root:SetTexture("images/plantregistry.xml", w.row_w >= 100 and "plant_cell_active_focus.tex" or "plant_cell_narrow_active_focus.tex")

                    w.plant_label:SetColour(PLANTREGISTRYUICOLOURS.LOCKEDBROWN)
                end
                w.cell_root.OnLoseFocus = function()
                    w.cell_root:SetTexture("images/plantregistry.xml", w.row_w >= 100 and "plant_cell_active.tex" or "plant_cell_narrow_active.tex")

                    w.plant_label:SetColour(PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN)
                end
                w.plant_anim.focus_forward = w.cell_root
            else
                w.plant_locked = w:AddChild(Image("images/plantregistry.xml", "locked.tex"))
                w.plant_locked:SetScale(0.25, 0.25)
                w.plant_locked.focus_forward = w.cell_root

                w.cell_root.OnGainFocus = function()
                    w.cell_root:SetTexture("images/plantregistry.xml", w.row_w >= 100 and "plant_cell_focus.tex" or "plant_cell_narrow_focus.tex")
                end
                w.cell_root.OnLoseFocus = function()
                    w.cell_root:SetTexture("images/plantregistry.xml", w.row_w >= 100 and "plant_cell.tex" or "plant_cell_narrow.tex")
                end
            end

            w.plant_label = w:AddChild(Text(font, font_size, STRINGS.UI.PLANTREGISTRY.PLANT_GROWTH_STAGES[string.upper(w.info.text)], PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN))
            w.plant_label:SetPosition(0, 97.5)
            w.plant_label:SetHAlign(ANCHOR_MIDDLE)

            if not ThePlantRegistry:KnowsPlantStage(self.data.plant, i) then
                w.plant_label:SetColour(PLANTREGISTRYUICOLOURS.LOCKEDBROWN)
            end

            w.focus_forward = w.cell_root

            self.plant_grid[i] = w
        end
    end
    start_x = start_x - ((row_spacing / 2) * (entries - 1))

    for i in ipairs(self.data.info) do
        local plant_widget = self.plant_grid[i]
        if plant_widget then
            local row_w = plant_widget.row_w
            start_x = start_x + row_w / 2
            plant_widget:SetPosition(start_x, 0)
            start_x = start_x + row_w / 2 + row_spacing
        end
    end
end

return WeedPlantPage