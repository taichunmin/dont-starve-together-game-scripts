local Widget = require "widgets/widget"
local PlantPageWidget = require "widgets/redux/plantpagewidget"
local Text = require "widgets/text"
local TEMPLATES = require "widgets/redux/templates"

local UnknownPlantPage = Class(PlantPageWidget, function(self, plantspage, data)
    PlantPageWidget._ctor(self, "UnknownPlantPage", plantspage, data)

    local name_font_size = 24
    local needs_research_font_size = 32

    self.plant_name = self.root:AddChild(Text(HEADERFONT, name_font_size, STRINGS.UI.PLANTREGISTRY.MYSTERY_PLANT, PLANTREGISTRYUICOLOURS.LOCKEDBROWN))
    self.plant_name:SetPosition(0, 275 - 15 - 17.5)
    self.plant_name:SetHAlign(ANCHOR_MIDDLE)

    self.needs_research = self.root:AddChild(Text(HEADERFONT, needs_research_font_size, STRINGS.UI.PLANTREGISTRY.NEEDSPLANTRESEARCH, PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN))
    self.needs_research:SetHAlign(ANCHOR_MIDDLE)
    self.needs_research:SetVAlign(ANCHOR_MIDDLE)

end)

return UnknownPlantPage