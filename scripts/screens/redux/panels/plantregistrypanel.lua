
local Widget = require "widgets/widget"
local PlantRegistryWidget = require "widgets/redux/plantregistrywidget"

local PlantRegistryPanel = Class(Widget, function(self, parent_screen)
    Widget._ctor(self, "PlantRegistryPanel")

    self.root = self:AddChild(Widget("ROOT"))

    self.root:SetPosition(0, -15)

	ThePlantRegistry:ClearFilters()

	self.plantregistry = self.root:AddChild(PlantRegistryWidget(self))

    self.focus_forward = self.plantregistry
end)

return PlantRegistryPanel
