local Widget = require "widgets/widget"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local TEMPLATES = require "widgets/redux/templates"
local Image = require "widgets/image"

local function MakeDetailsLine(root, x, y, scale, image_override)
	local value_title_line = root:AddChild(Image("images/plantregistry.xml", image_override or "details_line.tex"))
	value_title_line:SetScale(scale, scale)
    value_title_line:SetPosition(x, y)
    return value_title_line
end

local item_icon_remap = {}
item_icon_remap.onion = "quagmire_onion"
item_icon_remap.tomato = "quagmire_tomato"
local item_name_remap = {}

local function MakeItemWidget(root, x, y, item_size, item_name)
    local img_name = (item_icon_remap[item_name] or item_name)..".tex"
    local img_atlas = GetInventoryItemAtlas(img_name, true)
    local backing = root:AddChild(Image(img_atlas or "images/plantregistry.xml", img_atlas ~= nil and img_name or "missing.tex"))
    backing:ScaleToSize(item_size, item_size)
    backing:SetPosition(x, y)
    backing:SetHoverText(STRINGS.NAMES[string.upper(item_name_remap[item_name] or item_name)], {offset_y = 64})

    return backing
end

local FarmPlantSummaryWidget = Class(Widget, function(self, w, data)
    Widget._ctor(self, "FarmPlantSummaryWidget")

    self.w = w
    self.data = data

    self.root = self:AddChild(Widget("root"))

    local x_start = 0
    local y_start = 60

    local spacing_gap = 8

    local details_line_size = 10 * 0.4

    local item_offset = 25
    local item_size = 32

    self.seed_icon = MakeItemWidget(self.root, x_start - item_offset, y_start, item_size, self.data.plant_def.seed)
    self.product_icon = MakeItemWidget(self.root, x_start + item_offset, y_start, item_size, self.data.plant_def.product)

    y_start = y_start - (item_size / 2) - spacing_gap * 1.5

    self.season_seperator = MakeDetailsLine(self.root, x_start, y_start, 0.4)

    y_start = y_start - details_line_size - (spacing_gap / 4)

    local season_size = 24
    local season_gap = 2

    y_start = y_start - (season_size / 2)

    self.season_icons = {}
    for season in pairs(self.data.plant_def.good_seasons) do
        local season_icon = self.root:AddChild(Image("images/plantregistry.xml", "season_"..season..".tex"))
        season_icon:ScaleToSize(season_size, season_size)
        season_icon.season = season
        season_icon:SetHoverText(STRINGS.UI.CUSTOMIZATIONSCREEN.ICON_TITLES[string.upper(season)], {offset_y = 48})
        table.insert(self.season_icons, season_icon)
    end

    local season_count = #self.season_icons
    local season_x = x_start - ((season_count * season_size) + ((season_count - 1) * season_gap)) / 2

    local season_sort = {
        autumn = 4,
        winter = 3,
        spring = 2,
        summer = 1,
    }
    table.sort(self.season_icons, function(a, b)
        return season_sort[a.season] > season_sort [b.season]
    end)

    for i, season_icon in ipairs(self.season_icons) do
        season_x = season_x + season_size / 2
        season_icon:SetPosition(season_x, y_start)
        season_x = season_x + season_size / 2 + season_gap
    end

    y_start = y_start - (season_size / 2) - spacing_gap * 1.5

    self.water_seperator = MakeDetailsLine(self.root, x_start, y_start, 0.4)

    y_start = y_start - details_line_size - (spacing_gap / 4)

    local water_size = 24
    local water_gap = 2

    y_start = y_start - (water_size / 2)

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

    for i, season_icon in ipairs(self.water_icons) do
        water_x = water_x + water_size / 2
        season_icon:SetPosition(water_x, y_start)
        water_x = water_x + water_size / 2 + water_gap
    end

    y_start = y_start - (water_size / 2) - spacing_gap * 1.5

    self.nutrients_seperator = MakeDetailsLine(self.root, x_start, y_start, 0.4)

    y_start = y_start - details_line_size - (spacing_gap / 4)

    local nutrients_size = 18
    local nutrients_gap = 4

    y_start = y_start - (nutrients_size / 2)

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
        nutrients_icon:ScaleToSize(nutrients_size, nutrients_size)

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

        total_width = total_width + (nutrients_size * 2) + 2

        table.insert(self.nutrients_icons, nutrients_icon)
    end

    local nutrients_count = #self.nutrients_icons
    local nutrients_x = x_start - (total_width + (nutrients_count - 1) * nutrients_gap) / 2

    for i, nutrients_icon in ipairs(self.nutrients_icons) do
        nutrients_x = nutrients_x + nutrients_size / 2
        nutrients_icon:SetPosition(nutrients_x, y_start)
        nutrients_x = nutrients_x + nutrients_size + 2
        nutrients_icon.modifier:SetPosition(nutrients_x, y_start)
        nutrients_x = nutrients_x + nutrients_size / 2 + nutrients_gap
    end
end)

return FarmPlantSummaryWidget